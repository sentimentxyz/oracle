// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IOracle} from "./IOracle.sol";
import {Errors} from "../utils/Errors.sol";
import {Ownable} from "../utils/Ownable.sol";

/**
    @title Oracle Facade
    @notice This contract acts as a single interface for the client to fetch
    price of a given token in terms of eth
*/
contract OracleFacade is Ownable, IOracle {

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Mapping of token to Price Oracle for the token
    mapping(address => IOracle) public oracle;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /// @notice Contract Constructor
    constructor() Ownable(msg.sender) {}

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    event UpdateOracle(address indexed token, address indexed feed);

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address token) external view returns (uint) {
        if(address(oracle[token]) == address(0)) revert Errors.PriceUnavailable();
        return oracle[token].getPrice(token);
    }

    /* -------------------------------------------------------------------------- */
    /*                               ADMIN FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    function setOracle(address token, IOracle _oracle) external adminOnly {
        oracle[token] = _oracle;
        emit UpdateOracle(token, address(_oracle));
    }
}