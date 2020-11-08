pragma solidity ^0.7.0;
// SPDX-License-Identifier: MIT

contract User {

    // CURRENT REPUTATION
    uint public reputation = 1;

    // ITERABLE LIST OF TASK RESULTS
    address[] public results;

    // TASK MANAGER REFERENCE
    address task_manager;

    // VALUE CHANGED EVENT
    event changes(
        address[] results,
        uint reputation
    );

    // WHEN CREATED, SET TASK MANAGER REFERENCE
    constructor(address _task_manager) {
        task_manager = _task_manager;
    }

    // FETCH CONTRACT DETAILS
    function details() public view returns(address[] memory, uint) {
        return (results, reputation);
    }

    // ADD TASK RESULT
    function add_result(address task) public {

        // IF SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // PUSH TO RESULTS
        results.push(task);

        // EMIT ASYNC EVENT
        emit changes(results, reputation);
    }

    // INCREASE REPUTATION
    function award(uint amount) public {

        // IF SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');

        // INCREASE BY AMOUNT
        reputation += amount;

        // EMIT ASYNC EVENT
        emit changes(results, reputation);
    }
}