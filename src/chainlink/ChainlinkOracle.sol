// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IOracle} from "../core/IOracle.sol";
import {Ownable} from "../utils/Ownable.sol";
import {Errors} from "../utils/Errors.sol";
import {AggregatorV3Interface} from "./AggregatorV3Interface.sol";

/**
    @title Chain Link Oracle
    @notice Oracle to fetch price using chainlink oracles
*/
contract ChainlinkOracle is Ownable, IOracle {

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice ETH USD Chainlink price feed
    AggregatorV3Interface immutable ethUsdPriceFeed;

    uint constant heartBeat = 86400;

    /// @notice Mapping of token to token/usd chainlink price feed
    mapping(address => AggregatorV3Interface) public feed;

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    event UpdateFeed(address indexed token, address indexed feed);

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _ethUsdPriceFeed ETH USD Chainlink price feed
    */
    constructor(AggregatorV3Interface _ethUsdPriceFeed) Ownable(msg.sender) {
        ethUsdPriceFeed = _ethUsdPriceFeed;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address token) external view override returns (uint) {
        (, int tokenUSDPrice,, uint256 tokenUpdatedAt,) =
            feed[token].latestRoundData();
        (, int ethUSDPrice,, uint256 ethUpdatedAt,) =
            ethUsdPriceFeed.latestRoundData();

        if (block.timestamp - tokenUpdatedAt > heartBeat)
                revert Errors.InactivePriceFeed(address(feed[token]));

        if (block.timestamp - ethUpdatedAt > heartBeat)
                revert Errors.InactivePriceFeed(address(ethUsdPriceFeed));

        if (tokenUSDPrice < 0)
            revert Errors.NegativePrice(token, address(feed[token]));

        if (ethUSDPrice < 0)
            revert Errors.NegativePrice(address(0), address(ethUsdPriceFeed));

        return (
            (uint(tokenUSDPrice)*1e18)/
            uint(ethUSDPrice)
        );
    }

    /* -------------------------------------------------------------------------- */
    /*                               ADMIN FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    function setFeed(
        address token,
        AggregatorV3Interface _feed
    ) external adminOnly {
        feed[token] = _feed;
        emit UpdateFeed(token, address(_feed));
    }
}