// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IOracle} from "./IOracle.sol";
import {Errors} from "../utils/Errors.sol";
import {Ownable} from "../utils/Ownable.sol";

contract OracleFacade is Ownable, IOracle {
    mapping(address => IOracle) public oracle;

    constructor() Ownable(msg.sender) {}

    event UpdateOracle(address indexed token, address indexed feed);

    /// @dev Assume that the response has 18 decimals
    function getPrice(address token) external view returns (uint) {
        if(address(oracle[token]) == address(0)) revert Errors.PriceUnavailable();
        return oracle[token].getPrice(token);
    }

     // AdminOnly
    function setOracle(address token, IOracle _oracle) external adminOnly {
        oracle[token] = _oracle;
        emit UpdateOracle(token, address(_oracle));
    }
}