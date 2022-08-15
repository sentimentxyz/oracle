// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "src/utils/IERC20.sol";

interface IERC4626 is IERC20 {
    function previewRedeem(uint256 shares) external view returns (uint256 assets);
    function asset() external view returns (address asset);
}