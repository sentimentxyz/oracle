// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IVault} from "./IVault.sol";
import {IOracle} from "../core/IOracle.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

contract BeefyOracle is IOracle {
    using FixedPointMathLib for uint256;

    IOracle immutable oracleFacade;

    constructor(IOracle _oracleFacade) {
        oracleFacade = _oracleFacade;
    }

    function getPrice(address token) external view returns (uint256) {
        return IVault(token).getPricePerFullShare()
            .mulWadDown(
                oracleFacade.getPrice(
                    IVault(token).want()
                )
            );
    }
}