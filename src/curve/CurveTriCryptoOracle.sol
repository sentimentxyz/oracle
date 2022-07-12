// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {IOracle} from "../core/IOracle.sol";

interface ICurveTriCryptoOracle {
    function lp_price() external view returns (uint256);
}

/**
    @title Curve tri crypto oracle
    @notice Price Oracle for crv3crypto
*/
contract CurveTriCryptoOracle is IOracle {

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice curve tri crypto price oracle
    // https://twitter.com/curvefinance/status/1441538795493478415
    ICurveTriCryptoOracle immutable curveTriCryptoOracle;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _curveTriCryptoOracle curve tri crypto price oracle
    */
    constructor(ICurveTriCryptoOracle _curveTriCryptoOracle) {
        curveTriCryptoOracle = _curveTriCryptoOracle;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address) external view returns (uint) {
        return curveTriCryptoOracle.lp_price();
    }
}