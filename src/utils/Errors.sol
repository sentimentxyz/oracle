// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface Errors {
    error AdminOnly();
    error ZeroAddress();
    error PriceUnavailable();
    error L2SequencerUnavailable();
    error InactivePriceFeed(address feed);
    error NegativePrice(address token, address feed);
}