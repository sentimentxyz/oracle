// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IPool} from "./IPool.sol";
import {IVault} from "./IVault.sol";
import {IERC20} from "../utils/IERC20.sol";
import {IOracle} from "../core/IOracle.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

/**
    @title Balancer LP Oracle for composable stable pool
    @notice Oracle for composable stable balancer pool tokens
*/
contract ComposableStableBalancerLPOracle is IOracle {
    using FixedPointMathLib for uint;

    /* -------------------------------------------------------------------------- */
    /*                              STORAGE VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    /// @notice Balancer vault
    IVault immutable vault;

    /// @notice Oracle Facade
    IOracle immutable oracleFacade;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _oracle Oracle Facade
        @param _vault Balance Vault
    */
    constructor(IOracle _oracle, IVault _vault) {
        vault = _vault;
        oracleFacade = _oracle;
    }

    /// @inheritdoc IOracle
    function getPrice(address token) external view returns (uint) {
        (
            address[] memory poolTokens,
            ,
        ) = vault.getPoolTokens(IPool(token).getPoolId());

        uint length = poolTokens.length;
        uint minPrice = type(uint).max;
        for(uint i = 0; i < length; i++) {
            if (poolTokens[i] == token) continue;
            uint price = oracleFacade.getPrice(poolTokens[i]);
            minPrice = (price < minPrice) ? price : minPrice;
        }
        return minPrice.mulWadDown(IPool(token).getRate());
    }
}