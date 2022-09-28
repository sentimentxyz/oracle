// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IOracle} from "../core/IOracle.sol";

interface ICurveTriCryptoOracle {
    function lp_price() external view returns (uint256);
}

interface ICurvePool {
    function price_oracle(uint256) external view returns (uint256);
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

    /// @notice curve tri crypto pool
    ICurvePool immutable pool;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _curveTriCryptoOracle curve tri crypto price oracle
        @param _pool curve tri crypto pool
    */
    constructor(ICurveTriCryptoOracle _curveTriCryptoOracle, ICurvePool _pool) {
        curveTriCryptoOracle = _curveTriCryptoOracle;
        pool = _pool;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    // pool.price_oracle(1) returns price of WETH
    function getPrice(address) external view returns (uint) {
        return curveTriCryptoOracle.lp_price() * 1e18 / pool.price_oracle(1);
    }
}