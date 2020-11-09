pragma solidity ^0.7.0;
// SPDX-License-Identifier: MIT

contract Task {

    // RELATED PARTIES
    address public creator;
    address public task_manager;
    string public oracle;

    // TASK DETAILS
    uint256 public expires;
    uint public reward;

    // SELF DESTRUCTION EVENT
    event destroyed();

    // WHEN CREATED..
    constructor(address _creator, string memory _oracle, uint _timelimit, uint _reward) {

        // SET REFERENCES
        creator = _creator;
        task_manager = msg.sender;
        oracle = _oracle;

        // SET TASK DETAILS
        expires = block.number + _timelimit;
        reward = _reward;
    }

    // SELF DESTRUCT
    function destroy() public {

        // IF THE SENDER IS THE TASK MANAGER
        require(msg.sender == task_manager, 'permission denied');
        
        // EMIT DESTRUCTION EVENT & SELF DESTRUCT
        emit destroyed();
        selfdestruct(address(uint160(address(this))));
    }
}