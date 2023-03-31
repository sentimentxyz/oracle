// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IOracle} from "../core/IOracle.sol";
import {Ownable} from "../utils/Ownable.sol";
import {IERC20} from "../utils/IERC20.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

interface IOVAsset {
    function reservesPerShare() external view returns (uint256);
    function decimals() external view returns (uint256);
}

contract OVOracle is IOracle, Ownable {
    using FixedPointMathLib for uint256;

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice address of oracle facade
    IOracle public immutable oracleFacade;

    /// @notice mapping of ovAsset to asset
    mapping(address => address) public ovAssetToAsset;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Contract constructor
     *     @param _oracleFacade address oracle facade
     */
    constructor(IOracle _oracleFacade) Ownable(msg.sender) {
        oracleFacade = _oracleFacade;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address ovAsset) external view override returns (uint256) {
        address asset = ovAssetToAsset[ovAsset];
        return IOVAsset(ovAsset).reservesPerShare().mulDivDown(
            oracleFacade.getPrice(asset), 10 ** IERC20(asset).decimals()
        );
    }

    function setOVAsset(address ovAsset, address asset) external adminOnly {
        ovAssetToAsset[ovAsset] = asset;
    }
}
