// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Errors} from "../utils/Errors.sol";
import {IOracle} from "../core/IOracle.sol";
import {AggregatorV3Interface} from "../chainlink/AggregatorV3Interface.sol";

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

    /// @notice ETH USD Chainlink price feed
    AggregatorV3Interface immutable ethUsdPriceFeed;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _curveTriCryptoOracle curve tri crypto price oracle
        @param _feed eth/usd feed
    */
    constructor(
        ICurveTriCryptoOracle _curveTriCryptoOracle,
        AggregatorV3Interface _feed
    ) {
        curveTriCryptoOracle = _curveTriCryptoOracle;
        ethUsdPriceFeed = _feed;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address) external view returns (uint) {
        return curveTriCryptoOracle.lp_price() * 1e8 / getEthPrice();
    }

    function getEthPrice() internal view returns (uint) {
        (, int answer,, uint updatedAt,) =
            ethUsdPriceFeed.latestRoundData();

        if (block.timestamp - updatedAt >= 86400)
            revert Errors.StalePrice(address(0), address(ethUsdPriceFeed));

        if (answer <= 0)
            revert Errors.NegativePrice(address(0), address(ethUsdPriceFeed));

        return uint(answer);
    }
}