// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {IOracle} from "../core/IOracle.sol";
import {Ownable} from "../utils/Ownable.sol";
import {Errors} from "../utils/Errors.sol";
import {AggregatorV3Interface} from "./AggregatorV3Interface.sol";

/**
    @title Arbitrum Chain Link Oracle
    @notice Oracle to fetch price using chainlink oracles on arbitrum
*/
contract ChainlinkOracle is Ownable, IOracle {

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice ETH USD Chainlink price feed
    AggregatorV3Interface immutable ethUsdPriceFeed;

    /// @notice L2 Sequencer feed
    AggregatorV3Interface immutable sequencer;

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

        (, int answer,,,) =
            feed[token].latestRoundData();

        if (answer < 0)
            revert Errors.NegativePrice(token, address(feed[token]));

        return (
            (uint(answer)*1e18)/getEthPrice()
        );
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    function getEthPrice() internal view returns (uint) {
        (, int answer,,,) =
            ethUsdPriceFeed.latestRoundData();

        if (answer < 0)
            revert Errors.NegativePrice(address(0), address(ethUsdPriceFeed));

        return uint(answer);
    }

    function isSequencerActive() internal view returns (bool) {
        (, int256 answer,,,) = sequencer.latestRoundData();
        return answer == 0;
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