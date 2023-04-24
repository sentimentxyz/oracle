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
contract OAssetOracle is IOracle {
    using FixedPointMathLib for uint256;

    /// @notice Oracle Facade
    IOracle public immutable oracleFacade;

    /// @notice origami glp wrapper
    address public immutable oGLP;

    /// @notice origami gmx wrapper
    address public immutable oGMX;

    /// @notice sGLP token
    address public constant sGLP = 0x5402B5F40310bDED796c7D0F3FF6683f5C0cFfdf;

    /// @notice GMX token
    address public constant GMX = 0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a;

    constructor(IOracle _oracleFacade, address _oGLP, address _oGMX) {
        oracleFacade = _oracleFacade;
        oGLP = _oGLP;
        oGMX = _oGMX;
    }

    /// @inheritdoc IOracle
    function getPrice(address token) external override returns (uint256) {
        address baseToken = getBaseToken(token);

        (IOrigamiInvestment.ExitQuoteData memory data, uint256[] memory fees) =
            IOrigamiInvestment(token).exitQuote(10 ** IERC20(token).decimals(), baseToken, 0, block.timestamp);

        uint256 expectedToTokenAmount = data.expectedToTokenAmount;

        for (uint256 i = 0; i < fees.length; i++) {
            expectedToTokenAmount = applyFees(expectedToTokenAmount, fees[i]);
        }

        return expectedToTokenAmount.mulDivDown(oracleFacade.getPrice(baseToken), 10 ** IERC20(baseToken).decimals());
    }

    function getBaseToken(address token) internal view returns (address) {
        if (token == oGLP) return sGLP;
        if (token == oGMX) return GMX;

        return IOrigamiInvestment(token).baseToken();
    }

    function applyFees(uint256 amount, uint256 fee) internal pure returns (uint256) {
        return amount * (10000 - fee) / 10000;
    }
}
