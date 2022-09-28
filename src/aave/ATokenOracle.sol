// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAToken} from "./IAToken.sol";
import {IOracle} from "../core/IOracle.sol";

/**
    @title Aave aToken Oracle
    @notice Oracle for fetching price for aToken
*/
contract ATokenOracle is IOracle {

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Oracle Facade
    IOracle public immutable oracle;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _oracle Oracle Facade Address
    */
    constructor(IOracle _oracle) {
        oracle = _oracle;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address aToken) external view returns (uint) {
        return oracle.getPrice(IAToken(aToken).UNDERLYING_ASSET_ADDRESS());
    }
}