// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "../core/IOracle.sol";
import "./IERC4626.sol";
import "solmate/utils/FixedPointMathLib.sol";

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
    function getPrice(address token) external view returns (uint) {
        uint decimals = IERC4626(token).decimals();
        return IERC4626(token).previewRedeem(
            10 ** decimals
        ).mulDivDown(
            oracleFacade.getPrice(IERC4626(token).asset()),
            10 ** decimals
        );
    }
}