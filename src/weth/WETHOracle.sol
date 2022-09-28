// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IOracle} from "../core/IOracle.sol";

/**
    @title WETH Oracle
    @notice Price Oracle for WETH
    @dev Used for address(0) and WETH price calls to the Oracle
*/
contract WETHOracle is IOracle {

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address) external pure returns (uint) { return 1e18; }
}