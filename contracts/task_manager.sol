pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

// IMPORT INTERFACE
import { Task } from './task.sol';
import { UserManager } from './user_manager.sol';
import { DeviceManager } from './device_manager.sol';
import { TokenManager } from './token_manager.sol';
import { ServiceManager } from './service_manager.sol';

contract TaskManager {

    // MAP OF ALL TASKS, [ADDRESS => INTERFACE]
    mapping (address => Task) public tasks;

    // ITERABLE LIST OF OPEN TASKS
    Task[] public open;

    // MAP OF ALL TASK RESULTS, [ADDRESS => STRUCT]
    mapping (address => result) public results;

    // TASK RESULT STRUCT
    struct result {
        string key;         // PUBLIC ENCRYPTION KEY
        string ipfs;        // IPFS QN-HASH
    }

    // TOKEN FEE FOR TASK CREATION
    uint public fee;

    // INIT STATUS & MANAGER REFERENCES
    bool public initialized = false;
    UserManager public user_manager;
    DeviceManager public device_manager;
    TokenManager public token_manager;
    ServiceManager public service_manager;

    // CHANGE EVENT IN OPEN TASKS
    event change(Task[] open);

    // FETCH TASK
    function fetch_task(address task) public view returns(Task) {
        return tasks[task];
    }

    // FETCH TASK RESULT
    function fetch_result(address task) public view returns(result memory) {
        return results[task];
    }

    // FETCH OPEN TASKS
    function fetch_open() public view returns(Task[] memory) {
        return open;
    }

    // ADD NEW TASK
    function add(
        string memory _service,
        string memory _device,
        string memory _encryption,
        uint _timelimit
    ) public {

        // IF CONTRACT HAS BEEN INITIALIZED
        // SENDER IS A REGISTERED USER
        // DEVICE EXISTS
        // DEVICE IS SET TO ACTIVE
        // IF DEVICE HAS SERVICE
        require(initialized, 'contracts have not been initialized');
        require(user_manager.exists(msg.sender), 'you need to be registered');
        require(device_manager.exists(_device), 'the device does not exist');
        require(device_manager.fetch_device(_device).active(), 'the device is not active');
        require(device_manager.has_service(_device, _service), 'the device does not provide this service');

        // THE SERVICE PRICE
        uint service_price = service_manager.fetch_service(_service).price;

        // IF SENDER HAS ENOUGH TOKENS
        require(token_manager.balance(msg.sender) >= service_price + fee, 'insufficient tokens');

        // INSTANTIATE NEW TASK
        Task task = new Task(
            msg.sender,
            _service,
            _device,
            service_price,
            _encryption,
            _timelimit
        );

        // ADD IT TO BOTH CONTAINERS
        tasks[address(task)] = task;
        open.push(task);

        // ASSIGN TASK TO THE DEVICE
        device_manager.fetch_device(_device).assign_task(address(task));

        // CONSUME TOKEN FEE FROM THE CREATOR
        token_manager.consume(fee, msg.sender);

        // TRANSFER THE REWARD TOKENS TO THE TASK MANAGER
        token_manager.transfer(service_price, msg.sender, address(this));

        // TRIGGER ASYNC UPDATE TO SUBSCRIBERS
        emit change(open);
    }

    // COMPLETE A TASK
    function complete(
        address _task,
        string memory _ipfs,
        string memory _key
    ) public {

        // IF THE TASK EXISTS
        require(exists(_task), 'task does not exist');

        // TASK SHORTHAND
        Task task = fetch_task(_task);

        // EXTRACT DEVICE OWNER
        string memory device = task.device();
        address device_owner = device_manager.fetch_device(device).owner();

        // IF THE DEVICE OWNER IS THE SENDER
        require(msg.sender == device_owner, 'you are not the task device');

        // SAVE THE RESULT
        results[_task] = result({
            key: _key,
            ipfs: _ipfs
        });

        // TRANSFER THE REWARD
        token_manager.transfer(
            task.reward(),
            address(this),
            device_owner
        );

        // AWARD BOTH PARTIES WITH REPUTATION
        user_manager.fetch(task.creator()).award(1);
        user_manager.fetch(device_owner).award(2);

        // ADD REFERENCE THE THE TASK CREATORS CONTRACT
        user_manager.fetch(task.creator()).add_result(_task);

        // REMOVE TASK FROM DEVICE BACKLOG
        device_manager.fetch_device(task.device()).clear_task(_task, 1);

        // UNLIST & DESTROY THE TASK
        unlist(_task);
        task.destroy();

        // TRIGGER ASYNC UPDATE TO SUBSCRIBERS
        emit change(open);
    }

    // RETIRE A TASK
    function retire(address _task) public {

        // IF THE TASK EXISTS
        require(exists(_task), 'task does not exist');

        // SHORTHAND FOR TASK
        Task task = fetch_task(_task);

        // IF THE TASK CREATOR IS THE SENDER
        require(msg.sender == task.creator(), 'you are not the owner');

        // TRANSFER THE TOKEN REWARD BACK
        token_manager.transfer(
            task.reward(),
            address(this),
            task.creator()
        );

        // REMOVE TASK FROM DEVICE BACKLOG
        device_manager.fetch_device(task.device()).clear_task(_task, 0);

        // UNLIST & DESTROY THE TASK
        unlist(_task);
        task.destroy();

        // TRIGGER ASYNC UPDATE TO SUBSCRIBERS
        emit change(open);
    }

    // SET STATIC VARIABLES
    function init(
        uint _fee,
        address _user_manager,
        address _device_manager,
        address _token_manager,
        address _service_manager
    ) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED
        require(!initialized, 'contract has already been initialized');

        // SET TASK TOKEN FEE
        fee = _fee;

        // SET CONTRACT REFERENCES
        user_manager = UserManager(_user_manager);
        device_manager = DeviceManager(_device_manager);
        token_manager = TokenManager(_token_manager);
        service_manager = ServiceManager(_service_manager);

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

    // UNLIST TASK FROM OPEN
    function unlist(address target) private {
        for(uint index = 0; index < open.length; index++) {
            if (address(open[index]) == target) {
                delete open[index];
            }
        }
    }
}