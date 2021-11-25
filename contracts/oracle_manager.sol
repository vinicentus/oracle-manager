pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

import { Oracle } from './oracle.sol';
import { UserManager } from './user_manager.sol';

contract OracleManager {

    // MAP OF ALL ORACLES, [ORACLE ID => CONTRACT]
    mapping (string => Oracle) oracles;

    // USER DEVICE COLLECTIONS, [USER ADDRESS => LIST OF ORACLE IDs]
    mapping (address => string[]) collections;

    // REFERENCES
    UserManager public user_manager;
    address public task_manager;

    // INIT STATUS
    bool public initialized = false;

    // ORACLE ADDED EVENT
    event added();

    // FETCH ORACLE BY ID
    function fetch_oracle(string memory id) public view returns(Oracle) {
        return oracles[id];
    }

    // FETCH USER COLLECTION
    function fetch_collection(address user) public view returns(string[] memory) {
        return collections[user];
    }

    // CREATE NEW ORACLE
    function create(string memory id, uint price) public {

        // IF THE CONTRACT HAS BEEN INITIALIZED
        // IF THE USER IS REGISTERED
        // IF THE DEVICE DOES NOT EXIST
        require(initialized, 'contract has not been initialized');
        require(user_manager.exists(msg.sender), 'you need to be a registered user');
        require(!exists(id), 'identifier already exists');

        // INSTATIATE & INDEX NEW ORACLE
        oracles[id] = new Oracle(
            price,
            msg.sender,
            task_manager
        );

        // PUSH INTO SENDERS COLLECTION
        collections[msg.sender].push(id);

        // EMIT EVENT
        emit added();
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
    function exists(string memory id) public view returns(bool) {
        if (address(oracles[id]) != 0x0000000000000000000000000000000000000000) {
            return true;
        } else {
            return false;
        }
    }
}