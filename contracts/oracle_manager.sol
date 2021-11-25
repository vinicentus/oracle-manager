pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

import { Oracle } from './oracle.sol';
import { UserManager } from './user_manager.sol';

contract OracleManager {

    // MAP OF ALL ORACLES, [ORACLE ADDRESS => CONTRACT]
    mapping (address => Oracle) oracles;

    // USER DEVICE COLLECTIONS, [USER ADDRESS => LIST OF ORACLE ADDRESSES]
    mapping (address => address[]) collections;

    // REFERENCES
    UserManager public user_manager;
    address public task_manager;

    // INIT STATUS
    bool public initialized = false;

    // ORACLE ADDED EVENT
    event added(address indexed _address);

    // FETCH ORACLE BY ADDRESS
    function fetch_oracle(address id) public view returns(Oracle) {
        return oracles[id];
    }

    // FETCH USER COLLECTION
    function fetch_collection(address user) public view returns(address[] memory) {
        return collections[user];
    }

    // CREATE NEW ORACLE
    function create(string memory info, uint price) public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE USER IS REGISTERED
        // IF THE DEVICE DOES NOT EXIST
        require(initialized, 'contract has not been initialized');
        require(user_manager.exists(msg.sender), 'you need to be a registered user');

        // INSTATIATE & INDEX NEW ORACLE
        Oracle temp_oracle = new Oracle(
            info,
            price,
            msg.sender,
            task_manager
        );

        oracles[address(temp_oracle)] = temp_oracle;

        // PUSH INTO SENDERS COLLECTION
        collections[msg.sender].push(address(temp_oracle));

        // EMIT EVENT
        emit added(address(temp_oracle));
    }

    // INITIALIZE THE CONTRACT
    function init(address _user_manager, address _task_manager) public {

        // IF THE CONTRACT HAS NOT BEEN INITIALIZED BEFORE
        require(!initialized, 'contract has already been initialized');

        // SET REFERENCES
        user_manager = UserManager(_user_manager);
        task_manager = _task_manager;

        // BLOCK RE-INITIALIZATION
        initialized = true;
    }

    // CHECK IF ORACLE EXISTS
    // TODO: verify that this works and that we compare the right lenght...
    function exists(address id) public view returns(bool) {
        if (address(oracles[id]) != 0x0000000000000000000000000000000000000000) {
            return true;
        } else {
            return false;
        }
    }
}