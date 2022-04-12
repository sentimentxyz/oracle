// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IOracle} from "../core/IOracle.sol";
import {Ownable} from "../utils/Ownable.sol";
import {AggregatorV3Interface} from "./AggregatorV3Interface.sol";

contract ChainlinkOracle is Ownable, IOracle {
    
    AggregatorV3Interface immutable ethPriceFeed;

    mapping(address => AggregatorV3Interface) public feed;

    event UpdateFeed(address indexed token, address indexed feed);

    constructor(AggregatorV3Interface _ethPriceFeed) Ownable(msg.sender) {
        ethPriceFeed = _ethPriceFeed;
    }

    function getPrice(address token) external view override returns (uint) {
        return (
            uint(feed[token].latestAnswer())*1e10/
            uint(ethPriceFeed.latestAnswer())*1e10
        );
    }

    // AdminOnly
    function setFeed(
        address token,
        AggregatorV3Interface _feed
    ) external adminOnly {
        feed[token] = _feed;
        emit UpdateFeed(token, address(_feed));
    }
}