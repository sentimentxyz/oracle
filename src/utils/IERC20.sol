// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function decimals() external view returns (uint8);
    function balanceOf(address) external view returns (uint);
}