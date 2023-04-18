// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {IOracle} from "../core/IOracle.sol";
import {GammaLPOracle} from "../gamma/GammaLPOracle.sol";
import {IHypervisor} from "../gamma/IHypervisor.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

interface UniProxy {
    function deposit(uint256 deposit0, uint256 deposit1, address to, address pos, uint256[4] memory minIn)
        external
        returns (uint256 shares);

    function withdraw(uint256 shares, address to, address from, uint256[4] memory minIn)
        external
        returns (uint256);
}

interface IPool {
     function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);
}

contract GammaLPOracleTest is Test {
    using FixedPointMathLib for uint256;

    GammaLPOracle oracle;
    IOracle oracleFacade = IOracle(0xc79C23DEcc176Bd03dea9Ec6E56383589c0894A6);

    uint256 priceBefore;
    uint256 priceAfter;

    UniProxy proxy = UniProxy(0x22AE0dA638B4c4074A683045cCe759E8Ba990B1f);
    IHypervisor visor = IHypervisor(0xF08BDBC590C59cb7B27A8D224E419ef058952b5f);
    IERC20 WETH = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    IERC20 GMX = IERC20(0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a);
    IPool pool = IPool(0x1aEEdD3727A6431b8F070C0aFaA81Cc74f273882);

    function setUp() public {
        oracle = new GammaLPOracle(
            IOracle(0xc79C23DEcc176Bd03dea9Ec6E56383589c0894A6)
        );
    }

    function testPrice() public {
        uint256 price = oracle.getPrice(address(visor));
        console.log(price);
    }

    function testPriceAfterDeposit() public {
        priceBefore = oracle.getPrice(address(visor));

        deposit();

        priceAfter = oracle.getPrice(address(visor));

        assertApproxEqAbs(priceBefore, priceAfter, 1e15);
    }

    function testPriceAfterWithdraw() public {
        testPriceAfterDeposit();

        withdraw();

        priceAfter = oracle.getPrice(address(visor));

        assertApproxEqAbs(priceBefore, priceAfter, 1e15);
    }

    function deposit() internal {
        deal(address(GMX), address(this), 1500e18, true);
        deal(address(WETH), address(this), 28876766651804971143, true);

        WETH.approve(address(visor), type(uint256).max);
        GMX.approve(address(visor), type(uint256).max);

        uint256[4] memory a;

        proxy.deposit(WETH.balanceOf(address(this)), GMX.balanceOf(address(this)), address(this), address(visor), a);
    }

    function withdraw() internal {
        uint256 balance = IERC20(address(visor)).balanceOf(address(this));
        uint256[4] memory a;
        UniProxy(address(visor)).withdraw(balance, address(this), address(this), a);
    }

    function testFlashSwap() public {
        priceBefore = oracle.getPrice(address(visor));

        WETH.approve(address(pool), type(uint256).max);

        pool.swap(address(this), true, 2500e18, 4295128740, "");

        priceAfter = oracle.getPrice(address(visor));

        console.log(priceBefore);
        console.log(priceAfter);
        assertApproxEqAbs(priceBefore, priceAfter, 1e15);

        pool.swap(address(this), false, int(GMX.balanceOf(address(this))), 1461446703485210103287273052203988822378723970341, "");

        console.log("Price after flash swap", oracle.getPrice(address(visor)));
        console.log("WETH balance after flow", WETH.balanceOf(address(this)));
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata
    ) external {
        if (amount0Delta > 0) {
            deal(address(WETH), address(this), uint256(amount0Delta), false);
            WETH.transfer(address(pool), uint256(amount0Delta));
        } else {
            // deal(address(GMX), address(this), uint256(amount1Delta), false);
            GMX.transfer(address(pool), uint256(amount1Delta));
        }
    }
}
