// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Errors} from "./Errors.sol";

abstract contract Ownable {
    address public admin;

    event OwnershipTransferred(address indexed previousAdmin, address indexed newAdmin);

    constructor(address _admin) {
        if (_admin == address(0)) revert Errors.ZeroAddress();
        admin = _admin;
    }

    modifier adminOnly() {
        if (admin != msg.sender) revert Errors.AdminOnly();
        _;
    }

    function transferOwnership(address newAdmin) external virtual adminOnly {
        if (newAdmin == address(0)) revert Errors.ZeroAddress();
        emit OwnershipTransferred(admin, newAdmin);
        admin = newAdmin;
    }
}