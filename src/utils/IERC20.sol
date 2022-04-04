// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint);
}