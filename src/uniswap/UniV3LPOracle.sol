// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {IERC20} from "src/utils/IERC20.sol";
import {TickMath} from "./library/TickMath.sol";
import {IERC721Oracle} from "src/core/IERC721Oracle.sol";
import {IOracleFacade} from "src/core/IOracleFacade.sol";
import {IUniswapV3Pool} from "./interface/IUniswapV3Pool.sol";
import {LiquidityAmounts} from "./library/LiquidityAmounts.sol";
import {IERC721Enumerable} from "src/utils/IERC721Enumerable.sol";
import {IUniswapV3Factory} from "./interface/IUniswapV3Factory.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {INonfungiblePositionManager} from "./interface/INonfungiblePositionManager.sol";


contract UniV3LPOracle is IERC721Oracle {
    using FixedPointMathLib for uint256;

    IOracleFacade public immutable oracleFacade;
    INonfungiblePositionManager public immutable positionManager;
    IUniswapV3Factory public immutable uniswapFactory;

    constructor(
        IOracleFacade _oracle,
        INonfungiblePositionManager _positionManager,
        IUniswapV3Factory _uniswapFactory
    )
    {
        oracleFacade = _oracle;
        positionManager = _positionManager;
        uniswapFactory = _uniswapFactory;
    }

    /// @inheritdoc IERC721Oracle
    function getPrice(address token, address account) external view returns (uint256 price) {
        uint balance = IERC721Enumerable(token).balanceOf(account);
        for (uint i; i < balance; i++) {
            price += getPrice(IERC721Enumerable(token).tokenOfOwnerByIndex(account, i));
        }
    }

    function getPrice(uint tokenID) public view returns (uint256 value) {
        (
            address token0,
            uint256 amount0,
            address token1,
            uint256 amount1
        ) = getAmounts(tokenID);

        value = oracleFacade.getPrice(token0)
            .mulDivDown(
                amount0,
                10 ** IERC20(token0).decimals()
            );

        value += oracleFacade.getPrice(token1)
            .mulDivDown(
                amount1,
                10 ** IERC20(token1).decimals()
            );
    }

    function getAmounts(uint256 tokenID)
        internal
        view
        returns (address, uint256, address, uint256)
    {
        (
            , // [0]
            , // [1]
            address token0, // [2]
            address token1, // [3]
            uint24 fee, // [4]
            int24 tickLower, // [5]
            int24 tickUpper, // [6]
            uint128 liquidity, // [7]
            , // [8]
            , // [9]
            , // [10]
            // [11]
        ) = positionManager.positions(tokenID);

        (uint160 sqrtRatioX96, , , , , , ) =
            IUniswapV3Pool(uniswapFactory.getPool(token0, token1, fee)).slot0();

        (uint256 amount0, uint256 amount1) =
            LiquidityAmounts.getAmountsForLiquidity(
                sqrtRatioX96,
                TickMath.getSqrtRatioAtTick(tickLower),
                TickMath.getSqrtRatioAtTick(tickUpper),
                liquidity
            );
        return (token0, amount0, token1, amount1);
    }
}