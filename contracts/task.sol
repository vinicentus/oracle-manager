pragma solidity ^0.7.0;
// SPDX-License-Identifier: MIT

contract Task {

    // RELATED PARTIES
    address public creator;
    string public device;
    address public task_manager;

    // TASK DETAILS
    string public service;
    uint public reward;
    string public encryption;
    uint256 public expires;

    // CONTRACT INDEXING
    uint public device_index;
    uint public task_index;

    // DESTROYED EVENT
    event destroyed();

    // WHEN CREATED
    constructor(
        address _creator,
        string memory _service,
        string memory _device,
        uint _reward,
        string memory _encryption,
        uint timelimit
    ) {

        // SET PARTY PARAMS
        creator = _creator;
        service = _service;
        device = _device;
        encryption = _encryption;
        task_manager = msg.sender;

        // SET REWARD & EXPIRATION BLOCK
        reward = _reward;
        expires = block.number + timelimit;
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