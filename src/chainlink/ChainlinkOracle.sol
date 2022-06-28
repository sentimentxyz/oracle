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
    AggregatorV3Interface immutable sequencer;

    uint constant heartBeat = 86400;

    /// @notice Mapping of token to token/usd chainlink price feed
    mapping(address => AggregatorV3Interface) public feed;
    mapping(address => uint) public heartBeatOf;

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    event UpdateFeed(address indexed token, address indexed feed, uint256 heartBeat);

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _ethUsdPriceFeed ETH USD Chainlink price feed
        @param _sequencer L2 sequencer
    */
    constructor(
        AggregatorV3Interface _ethUsdPriceFeed,
        AggregatorV3Interface _sequencer
    )
        Ownable(msg.sender)
    {
        ethUsdPriceFeed = _ethUsdPriceFeed;
        sequencer = _sequencer;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address token) external view override returns (uint) {
        if (!isSequencerActive()) revert Errors.L2SequencerUnavailable();

        (, int answer,, uint256 tokenUpdatedAt,) =
            feed[token].latestRoundData();

        if (block.timestamp - tokenUpdatedAt >= heartBeatOf[token])
            revert Errors.InactivePriceFeed(address(feed[token]));

        if (answer < 0)
            revert Errors.NegativePrice(token, address(feed[token]));

        return (
            (uint(answer)*1e18)/getEthPrice()
        );
    }

    /* -------------------------------------------------------------------------- */
    /*                               ADMIN FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    function getEthPrice() private view returns (uint) {
        (, int answer,, uint256 updatedAt,) =
            ethUsdPriceFeed.latestRoundData();

        if (block.timestamp - updatedAt >= heartBeatOf[address(0)])
            revert Errors.InactivePriceFeed(address(ethUsdPriceFeed));

        if (answer < 0)
            revert Errors.NegativePrice(address(0), address(ethUsdPriceFeed));

        return uint(answer);
    }

    function isSequencerActive() private view returns (bool) {
        (, int256 answer,, uint256 updatedAt,) = sequencer.latestRoundData();
        return (answer == 0 && (block.timestamp - updatedAt) < 3600);
    }

    // AdminOnly
    function setFeed(
        address token,
        AggregatorV3Interface _feed,
        uint256 heartBeat
    ) external adminOnly {
        feed[token] = _feed;
        heartBeatOf[token] = heartBeat;
        emit UpdateFeed(token, address(_feed), heartBeat);
    }
}