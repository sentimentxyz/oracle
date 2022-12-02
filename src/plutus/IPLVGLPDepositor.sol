// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPLVGLPDepositor {
    function previewRedeem(address,uint256) external view returns (uint256, uint256, uint256);
    function depositAll() external;
    function redeemAll() external;
}