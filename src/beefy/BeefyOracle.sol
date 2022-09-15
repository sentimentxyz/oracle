// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IVault} from "./IVault.sol";
import {IOracle} from "../core/IOracle.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

/**
    @title Beefy Vault Oracle (V6 and V7)
    @notice Price oracle for beefy v6 and v7 vaults
*/
contract BeefyOracle is IOracle {
    using FixedPointMathLib for uint256;

    /* -------------------------------------------------------------------------- */
    /*                               STATE_VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Oracle facade
    IOracle immutable oracleFacade;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice contract constructor
        @param _oracleFacade Oracle Facade
    */
    constructor(IOracle _oracleFacade) {
        oracleFacade = _oracleFacade;
    }

    /// @inheritdoc IOracle
    function getPrice(address token) external view returns (uint256) {
        return IVault(token).getPricePerFullShare()
            .mulWadDown(
                oracleFacade.getPrice(
                    IVault(token).want()
                )
            );
    }
}