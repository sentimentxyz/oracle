// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {IOracle} from "../core/IOracle.sol";
import {IOracleFacade} from "../core/IOracleFacade.sol";

interface IYVault {
    function token() external view returns (address);
    function pricePerShare() external view returns (uint256);
    function decimals() external view returns (uint256);
}

/**
    @title Yearn YToken Oracle
    @notice Price oracle for yToken
*/
contract YTokenOracle is IOracle {

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Oracle Facade
    IOracleFacade public oracle;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _oracle Address for oracle facade
    */
    constructor(IOracleFacade _oracle) {
        oracle = _oracle;
    }

    /// @inheritdoc IOracle
    function getPrice(address token) external view returns (uint price) {
        address underlying_token = IYVault(token).token();
        price = IYVault(token).pricePerShare() *
            oracle.getPrice(underlying_token) /
            10 ** IYVault(underlying_token).decimals();
    }
}