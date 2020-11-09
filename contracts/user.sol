pragma solidity ^0.7.0;
// SPDX-License-Identifier: MIT

contract User {

    // TASK MANAGER REFERENCE
    address task_manager;

    // CURRENT REPUTATION & AWARD EVENT
    uint public reputation = 1;
    event awarded(uint reputation);

    // WHEN CREATED, SET TASK MANAGER REFERENCE
    constructor(address _task_manager) {
        task_manager = _task_manager;
    }

    // INCREASE REPUTATION
    function award(uint amount) public {

        // IF SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // INCREASE BY AMOUNT
        reputation += amount;

        // EMIT ASYNC EVENT
        emit awarded(reputation);
    }
}