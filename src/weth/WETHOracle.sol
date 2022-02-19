// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IOracle} from "../core/IOracle.sol";

/// @dev Used for address(0) and WETH price calls to the Oracle
contract WETHOracle is IOracle {
    function getPrice(address) external pure returns (uint) { return 1e18; }
}