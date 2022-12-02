
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "../utils/IERC20.sol";
import {IOracle} from "../core/IOracle.sol";
import {IERC4626} from "../erc4626/IERC4626.sol";
import {IPLVGLPDepositor} from "./IPLVGLPDepositor.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

contract PLVGLPOracle is IOracle {
    using FixedPointMathLib for uint256;

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice address of oracle facade
    IOracle public immutable oracleFacade;

    /// @notice PLVGLP Depositor
    IPLVGLPDepositor public immutable vault;

    /// @notice Staked GLP
    address public immutable sGLP;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _oracleFacade address oracle facade
    */
    constructor(IOracle _oracleFacade, address _SGLP, IPLVGLPDepositor _vault) {
        oracleFacade = _oracleFacade;
        sGLP = _SGLP;
        vault = _vault;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address) external view returns (uint) {
        (,, uint assets) = vault.previewRedeem(address(0), 1e18);
        return assets.mulWadDown(
            oracleFacade.getPrice(sGLP)
        );
    }
}