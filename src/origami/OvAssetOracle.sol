// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "../utils/IERC20.sol";
import {IOracle} from "../core/IOracle.sol";
import {IOrigamiInvestment} from "./IOrigamiInvestment.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

/**
 * @title OvAssetOracle
 * @notice An Oracle for origami investment vaults.
 */
contract OvAssetOracle is IOracle {
    using FixedPointMathLib for uint256;

    /// @notice Oracle Facade
    IOracle public immutable oracleFacade;

    constructor(IOracle _oracleFacade) {
        oracleFacade = _oracleFacade;
    }

    /// @inheritdoc IOracle
    function getPrice(address token) external override returns (uint256) {
        address baseToken = IOrigamiInvestment(token).baseToken();
        return IOrigamiInvestment(token).reservesPerShare().mulDivDown(
            oracleFacade.getPrice(baseToken), 10 ** IERC20(baseToken).decimals()
        );
    }
}
