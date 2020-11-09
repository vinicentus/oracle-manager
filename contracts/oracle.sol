pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

contract Oracle {

    // ADDRESS REFERENCES
    address public owner;
    address public oracle_manager;
    address public task_manager;

    // SERVICE TOKEN PRICE
    uint public price;

    // ITERABLE ASSIGNMENT BACKLOG
    address[] public backlog;

    // DEVICE STATUS
    bool public active;
    bool public discoverable;

    // DISCOVERY CONFIGURATION
    string public discovery;

    // NUMBER OF COMPLETED ASSIGNMENTS
    uint public completed;

    // EVENTS
    event middleware();
    event modification();

    // SET ADDRESS REFERENCES
    constructor(uint _price, address _owner, address _task_manager) {
        price = _price;
        owner = _owner;
        task_manager = _task_manager;
    }

    // FETCH CONTRACT DETAILS
    function details() public view returns(address, bool, bool, string memory, uint, address[] memory) {
        return (
            owner,
            active,
            discoverable,
            discovery,
            completed,
            backlog
        );
    }

    // UPDATE DEVICE MIDDLEWARE
    function update_middleware() public {

        // IF THE SENDER IS THE DEVICE ORACLES OWNER
        require(msg.sender == owner, 'permission denied');

        // EMIT EVENT TO DEVICE
        emit middleware();
    }

    // UPDATE DEVICE DISCOVERY CONFIG
    function update_discovery(string memory data) public {

        // IF THE SENDER IS THE DEVICE ORACLES OWNER
        require(msg.sender == owner, 'permission denied');

        // SAVE THE NEW CONFIG IN THE CONTRACT
        discovery = data;

        // EMIT CONTRACT MODIFIED EVENT
        emit modification();
    }

    // TOGGLE ACTIVE STATUS
    function toggle_active() public {

        // IF THE SENDER IS THE ORACLES OWNER
        require(msg.sender == owner, 'permission denied');

        // TOGGLE STATUS
        active = !active;

        // EMIT CONTRACT MODIFIED EVENT
        emit modification();
    }

    // TOGGLE DISCOVERABLE STATUS
    function toggle_discoverable() public {

        // IF THE SENDER IS THE ORACLES OWNER
        require(msg.sender == owner, 'permission denied');

        // TOGGLE STATUS
        discoverable = !discoverable;

        // EMIT CONTRACT MODIFIED EVENT
        emit modification();
    }

    // ASSIGN TASK TO DEVICE
    function assign_task(address task) public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // ADD TASK TO BACKLOG
        backlog.push(task);

        // EMIT CONTRACT MODIFIED EVENT
        emit modification();
    }

    // CLEAR FINISHED TASK FROM BACKLOG
    function clear_task(address target, uint reward) public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // LOOP & FIND
        for(uint index = 0; index < backlog.length; index++) {
            if (address(backlog[index]) == target) {

                // DELETE THE ASSIGNMENT & INCREMENT COMPLETED
                delete backlog[index];
                completed += reward;

                // EMIT CONTRACT MODIFIED EVENT
                emit modification();
            }
        }
    }
}