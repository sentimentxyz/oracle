// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {IOracle} from "../core/IOracle.sol";

interface IPriceOracle {
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
    IPriceOracle immutable priceOracle;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _priceOracle curve tri crypto price oracle
    */
    constructor(IPriceOracle _priceOracle) {
        priceOracle = _priceOracle;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address) external view returns (uint) {
        return IPriceOracle(priceOracle).lp_price();
    }
}