pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

// IMPORT INTERFACE
import { Task } from './task.sol';
import { UserManager } from './user_manager.sol';
import { OracleManager } from './oracle_manager.sol';
import { TokenManager } from './token_manager.sol';

contract TaskManager {

    // MAP OF ALL TASKS, [ADDRESS => CONTRACT]
    mapping (address => Task) public tasks;
    
    // PENDING & COMPLETED TASKS FOR EACH USER -- REPLACED RESULTS
    mapping (address => address[]) public pending;
    mapping (address => result[]) public completed;

    // TASK RESULT OBJECT
    struct result {
        address task;
        string data;
    }

    // TOKEN FEE FOR TASK CREATION
    uint public fee;

    // INIT STATUS & MANAGER REFERENCES
    bool public initialized = false;
    UserManager public user_manager;
    OracleManager public oracle_manager;
    TokenManager public token_manager;

    // MODIFICATION EVENTS
    event task_created(address indexed task);
    event task_completed(address indexed task, string data);
    event task_retired(address indexed task);
    event task_cleared(address indexed task, address indexed user);

    // LEGACY EVENT, NEEDED FOR OLD distributed-task-manager UI
    event modification();

    // FETCH TASK
    function fetch_task(address task) public view returns(Task) {
        return tasks[task];
    }

    // FETCH USER RELATED TASK LISTS
    function fetch_lists(address user) public view returns(address[] memory, result[] memory) {
        return (pending[user], completed[user]);
    }

    // CREATE NEW TASK
    function create(
        string memory _oracle,
        uint _reward,
        uint _timelimit,
        string memory _params
    ) public {

        // IF CONTRACT HAS BEEN INITIALIZED
        // SENDER IS A REGISTERED USER
        // ORACLE EXISTS
        // ORACLE IS SET TO ACTIVE
        require(initialized, 'contracts have not been initialized');
        require(user_manager.exists(msg.sender), 'you need to be registered');
        require(oracle_manager.exists(_oracle), 'the oracle does not exist');
        require(oracle_manager.fetch_oracle(_oracle).active(), 'the oracle is not active');

        // EXTRACT THE ORACLES OWNER & SERVICE PRICE
        uint oracle_price = oracle_manager.fetch_oracle(_oracle).price();
        address oracle_owner = oracle_manager.fetch_oracle(_oracle).owner();

        // MAKE SURE THE PROVIDED REWARD IS SUFFICIENT
        require(_reward >= oracle_price, 'the reward must be higher or equal to the oracles service cost');

        // IF THE SENDER & ORACLE OWNER ARE THE SAME, 
        if (msg.sender == oracle_owner) {
            uint total = _reward + fee + (_reward / 2);
            require(token_manager.balance(oracle_owner) >= total, 'you have insufficient tokens');
        
        // OTHERWISE, CHECK THE BALANCE OF BOTH PARTICIPANTS
        } else {
            require(token_manager.balance(msg.sender) >= _reward + fee, 'you have insufficient tokens');
            require(token_manager.balance(oracle_owner) >= _reward / 2, 'oracle owner has insufficient tokens');
        }

        // INSTANTIATE NEW TASK
        Task task = new Task(
            msg.sender,
            _oracle,
            _timelimit,
            _reward + _reward / 2,
            _params
        );

        // INDEX THE TASK & ADD TO PENDING
        tasks[address(task)] = task;
        pending[msg.sender].push(address(task));

        // ASSIGN TASK TO THE DEVICE
        oracle_manager.fetch_oracle(_oracle).assign_task(address(task));

        // CONSUME TOKEN FEE FROM THE CREATOR
        token_manager.consume(fee, msg.sender);

        // SEIZE TOKENS FROM BOTH PARTIES
        token_manager.transfer(_reward, msg.sender, address(this));
        token_manager.transfer(_reward / 2, oracle_owner, address(this));

        // EMIT CONTRACT MODIFIED EVENT
        emit task_created(address(task));
        // LEGACY EVENT, see declaration for details
        emit modification();
    }

    // COMPLETE A TASK
    function complete(address _task, string memory _data) public {

        // IF THE TASK EXISTS
        require(exists(_task), 'task does not exist');

        // EXTRACT TASK & ORACLE INFO
        Task task = fetch_task(_task);
        string memory oracle = task.oracle();
        address oracle_owner = oracle_manager.fetch_oracle(oracle).owner();

        // IF THE DEVICE OWNER IS THE SENDER
        require(msg.sender == oracle_owner, 'you are not the oracles owner');

        // REMOVE FROM PENDING
        clear_task(msg.sender, _task);

        // SAVE IN COMPLETED
        completed[msg.sender].push(result({
            task: address(task),
            data: _data
        }));

        // RELEASE SEIZED TOKEN REWARD
        token_manager.transfer(
            task.reward(),
            address(this),
            oracle_owner
        );

        // AWARD BOTH PARTIES WITH REPUTATION
        user_manager.fetch(task.creator()).award(1);
        user_manager.fetch(oracle_owner).award(2);

        // REMOVE TASK FROM THE ORACLES BACKLOG
        oracle_manager.fetch_oracle(oracle).clear_task(_task, 1);

        // SELF DESTRUCT THE TASK
        task.destroy();

        // EMIT CONTRACT MODIFIED EVENT
        emit task_completed(_task, _data);
        // LEGACY EVENT, see declaration for details
        emit modification();
    }

    // RETIRE AN INCOMPLETE TASK
    function retire(address _task) public {

        // IF THE TASK EXISTS
        require(exists(_task), 'task does not exist');

        // SHORTHAND FOR TASK
        Task task = fetch_task(_task);

        // IF THE TASK CREATOR IS THE SENDER
        // IF THE TASK HAS EXPIRED
        require(msg.sender == task.creator(), 'you are not the task creator');
        require(block.number > task.expires(), 'task has not expired yet');

        // RELEASED SEIZED TOKENS TO THE TASK CREATOR
        token_manager.transfer(
            task.reward(),
            address(this),
            task.creator()
        );

        // REMOVE TASK FROM PENDING
        clear_task(task.creator(), _task);

        // REMOVE TASK FROM THE ORACLES BACKLOG
        oracle_manager.fetch_oracle(task.oracle()).clear_task(_task, 0);

        // SELF DESTRUCT THE TASK
        task.destroy();

        // EMIT CONTRACT MODIFIED EVENT
        emit task_retired(_task);
        // LEGACY EVENT, see declaration for details
        emit modification();
    }

    // INITIALIZE THE CONTRACT
    function init(
        uint _fee,
        address _user_manager,
        address _oracle_manager,
        address _token_manager
    ) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED
        require(!initialized, 'contract has already been initialized');

        // SET TASK TOKEN FEE
        fee = _fee;

        // SET CONTRACT REFERENCES
        user_manager = UserManager(_user_manager);
        oracle_manager = OracleManager(_oracle_manager);
        token_manager = TokenManager(_token_manager);

        // BLOCK FURTHER MODIFICATION
        initialized = true;
    }

    // CHECK IF TASK EXISTS
    function exists(address _task) public view returns(bool) {
        if (address(tasks[_task]) != 0x0000000000000000000000000000000000000000) {
            return true;
        } else {
            return false;
        }
    }

    // CLEAR TASK FROM PENDING
    function clear_task(address user, address task) private {

        // LOOP & FIND
        for(uint index = 0; index < pending[user].length; index++) {
            if (address(pending[user][index]) == task) {

                // DELETE THE ASSIGNMENT & INCREMENT COMPLETED
                delete pending[user][index];
                emit task_cleared(user, task);
            }
        }
    }
}