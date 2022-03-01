// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IOracle} from "../core/IOracle.sol";
import {Ownable} from "../utils/Ownable.sol";
import {AggregatorV3Interface} from "./AggregatorV3Interface.sol";

contract ChainlinkOracle is Ownable, IOracle {
    mapping(address => AggregatorV3Interface) public feed;

    event UpdateFeed(address indexed token, address indexed feed);

    constructor() Ownable(msg.sender) {}

    /// @dev Assume that the response has 18 decimals
    function getPrice(address token) external view override returns (uint) {
        (, int price, , ,) = feed[token].latestRoundData();
        return uint(price);
    }

    // AdminOnly
    function setFeed(address token, AggregatorV3Interface _feed) external adminOnly {
        feed[token] = _feed;
        emit UpdateFeed(token, address(_feed));
    }
}