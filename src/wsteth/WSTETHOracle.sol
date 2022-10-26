// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Errors} from "../utils/Errors.sol";
import {IOracle} from "src/core/IOracle.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {AggregatorV3Interface} from "../chainlink/AggregatorV3Interface.sol";

/**
    @title WSTETH Oracle
    @notice Oracle that returns price of wsteth
    arbi:0x5979D7b546E38E414F7E9822514be443A4800529
*/
contract WSTETHOracle is IOracle {
    using FixedPointMathLib for uint;

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice WSTETH/STETH chainlink price feed
    AggregatorV3Interface immutable WSTETHFeed;

    /// @notice STETH/USD chainlink price feed
    AggregatorV3Interface immutable STETHFeed;

    /// @notice ETH USD Chainlink price feed
    AggregatorV3Interface immutable ethUsdPriceFeed;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    constructor(
        AggregatorV3Interface _WSTETHFeed,
        AggregatorV3Interface _STETHFeed,
        AggregatorV3Interface _ethUsdPriceFeed
    )
    {
        WSTETHFeed = _WSTETHFeed;
        STETHFeed = _STETHFeed;
        ethUsdPriceFeed = _ethUsdPriceFeed;
    }

    /// @inheritdoc IOracle
    function getPrice(address token) external view returns (uint) {
        (, int answer,, uint updatedAt,) =
            WSTETHFeed.latestRoundData();

        if (block.timestamp - updatedAt >= 86400)
            revert Errors.StalePrice(token, address(WSTETHFeed));

        if (answer <= 0)
            revert Errors.NegativePrice(token, address(WSTETHFeed));

        return uint(answer).mulWadDown(getSTETHPrice());
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    function getSTETHPrice() internal view returns (uint) {
        (, int answer,, uint updatedAt,) =
            STETHFeed.latestRoundData();

        if (block.timestamp - updatedAt >= 86400)
            revert Errors.StalePrice(address(0), address(WSTETHFeed));

        if (answer <= 0)
            revert Errors.NegativePrice(address(0), address(WSTETHFeed));

        return (
            (uint(answer)*1e18)/getEthPrice()
        );
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