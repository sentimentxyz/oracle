// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface AggregatorV3Interface {
    function latestAnswer()
    external
    view
    returns (int256);
}