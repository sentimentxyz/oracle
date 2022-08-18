// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "src/core/IOracle.sol";
import "src/utils/IERC20.sol";
import "./library/FixedPoint.sol";

interface IPool {
    function totalSupply() external view returns (uint256);
    function getPoolId() external view returns (bytes32);
    function getNormalizedWeights() external view returns (uint256[] memory);
}

interface IVault {
    function getPoolTokens(bytes32) external view returns (address[] memory, uint256[] memory, uint256);
}

/**
    @title Balancer LP Oracle for weighted pool
    @notice Oracle for weighted balancer pool tokens
    https://dev.balancer.fi/references/lp-tokens/valuing
*/
contract WeightedBalancerLPOracle is IOracle {
    using FixedPoint for uint;

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
            uint256[] memory balances,
        ) = vault.getPoolTokens(IPool(token).getPoolId());

        uint256[] memory weights = IPool(token).getNormalizedWeights();

        uint length = weights.length;
        uint temp = 1e18;
        uint invariant = 1e18;
        for(uint i; i < length; i++) {
            temp = temp.mulDown(
                (oracleFacade.getPrice(poolTokens[i]).divDown(weights[i]))
                .powDown(weights[i])
            );
            invariant = invariant.mulDown(
                (balances[i] * 10 ** (18 - IERC20(poolTokens[i]).decimals()))
                .powDown(weights[i])
            );
        }
        return invariant
            .mulDown(temp)
            .divDown(IPool(token).totalSupply());
    }
}