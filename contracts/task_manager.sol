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

    // MAP OF ALL TASK RESULTS, [ADDRESS => STRING]
    mapping (address => string) public results;

    // TOKEN FEE FOR TASK CREATION
    uint public fee;

    // INIT STATUS & MANAGER REFERENCES
    bool public initialized = false;
    UserManager public user_manager;
    OracleManager public oracle_manager;
    TokenManager public token_manager;

    // FETCH TASK
    function fetch_task(address task) public view returns(Task) {
        return tasks[task];
    }

    // FETCH TASK RESULT
    function fetch_result(address task) public view returns(string memory) {
        return results[task];
    }

    // CREATE NEW TASK
    function create(string memory _oracle, uint _timelimit, string memory _params) public returns(address) {

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

        // CHECK IF BOTH PARTIES OWN ENOUGH TOKENS
        require(token_manager.balance(msg.sender) >= oracle_price + fee, 'you have insufficient tokens');
        require(token_manager.balance(oracle_owner) >= oracle_price / 2, 'oracle owner has insufficient tokens');

        // INSTANTIATE NEW TASK
        Task task = new Task(
            msg.sender,
            _oracle,
            _timelimit,
            oracle_price + oracle_price / 2,
            _params
        );

        // INDEX THE TASK
        tasks[address(task)] = task;

        // ASSIGN TASK TO THE DEVICE
        oracle_manager.fetch_oracle(_oracle).assign_task(address(task));

        // CONSUME TOKEN FEE FROM THE CREATOR
        token_manager.consume(fee, msg.sender);

        // SEIZE TOKENS FROM BOTH PARTIES
        token_manager.transfer(oracle_price, msg.sender, address(this));
        token_manager.transfer(oracle_price / 2, oracle_owner, address(this));

        return address(task);
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

        // SAVE THE RESULT
        results[_task] = _data;

        // RELEASE SEIZED TOKENS TO THE ORACLE OWNER
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

        // REMOVE TASK FROM THE ORACLES BACKLOG
        oracle_manager.fetch_oracle(task.oracle()).clear_task(_task, 0);

        // SELF DESTRUCT THE TASK
        task.destroy();
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
}