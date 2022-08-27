// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IVault {
    function getPoolTokens(bytes32) external view returns (address[] memory, uint256[] memory, uint256);
}