// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IHypervisor {
    function getTotalAmounts() external view returns (uint256 total0, uint256 total1);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function totalSupply() external view returns (uint256);
    function getBasePosition() external view returns (uint128, uint256 total0, uint256 total1);
    function getLimitPosition() external view returns (uint128, uint256 total0, uint256 total1);
    function currentTick() external view returns (int24);
    function baseLower() external view returns (int24);
    function baseUpper() external view returns (int24);
    function limitLower() external view returns (int24);
    function limitUpper() external view returns (int24);
}
