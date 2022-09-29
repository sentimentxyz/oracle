// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC4626} from "./IERC4626.sol";
import {IERC20} from "../utils/IERC20.sol";
import {IOracle} from "../core/IOracle.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

contract ERC4626Oracle is IOracle {
    using FixedPointMathLib for uint256;

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice address of oracle facade
    IOracle immutable oracleFacade;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _oracleFacade address oracle facade
    */
    constructor(IOracle _oracleFacade) {
        oracleFacade = _oracleFacade;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address vault) external view returns (uint) {
        address asset = IERC4626(vault).asset();
        return IERC4626(vault).previewRedeem(
            10 ** IERC4626(vault).decimals()
        ).mulDivDown(
            oracleFacade.getPrice(asset),
            10 ** IERC20(asset).decimals()
        );
    }
}