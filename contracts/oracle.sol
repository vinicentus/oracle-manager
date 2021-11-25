pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

contract Oracle {

    //TODO: store ID here
    string public info;

    // ADDRESS REFERENCES
    address public owner;
    address public task_manager;

    // SERVICE TOKEN PRICE
    uint public price;

    // ITERABLE ASSIGNMENT BACKLOG
    address[] public backlog;

    // DEVICE STATUS
    bool public active;

    // NUMBER OF COMPLETED ASSIGNMENTS
    uint public completed;

    // EVENTS
    event middleware();
    // TODO: break up into more events, or include details about what actually happened
    event modification();

    // SET ADDRESS REFERENCES
    constructor(string memory _info, uint _price, address _owner, address _task_manager ) {
        info = _info;
        price = _price;
        owner = _owner;
        task_manager = _task_manager;
    }

    // FETCH TASK BACKLOG
    function fetch_backlog() public view returns(address[] memory) {
        return backlog;
    }

    // UPDATE DEVICE MIDDLEWARE
    function update_middleware() public {

        // IF THE SENDER IS THE DEVICE ORACLES OWNER
        require(msg.sender == owner, 'permission denied');

        // EMIT EVENT TO DEVICE
        emit middleware();
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