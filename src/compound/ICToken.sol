// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICToken {
    function underlying() external view returns (address);
    function exchangeRateStored() external view returns (uint);
}