// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPool {
    function getRate() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function getPoolId() external view returns (bytes32);
    function getNormalizedWeights() external view returns (uint256[] memory);
}
