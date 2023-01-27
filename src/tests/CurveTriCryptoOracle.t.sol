// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {CurveTriCryptoOracle, ICurvePool} from "../curve/CurveTriCryptoOracle.sol";
import {AggregatorV3Interface} from "../chainlink/AggregatorV3Interface.sol";

interface ITriCryptoPool {
    function remove_liquidity_one_coin(uint256 amt, uint256 i, uint256 minAmt) external;
    function add_liquidity(uint256[3] memory amounts, uint256 minAmt) external;
    function remove_liquidity(uint256, uint256[3] memory) external;
    function exchange(
        uint256,
        uint256,
        uint256,
        uint256,
        bool
    ) external payable returns (uint256);
}

contract CurveTriCryptoOracleTest is Test {

    CurveTriCryptoOracle oracle;

    IERC20 WETH = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    IERC20 triCrypto = IERC20(0x8e0B8c8BB9db49a46697F3a5Bb8A308e744821D2);
    address triCryptoPool = 0x960ea3e3C7FB317332d990873d354E18d7645590;

    uint priceBefore;
    uint priceAfter;

    function setUp() public {
        oracle = new CurveTriCryptoOracle(
            AggregatorV3Interface(0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612),
            AggregatorV3Interface(0x6ce185860a4963106506C203335A2910413708e9),
            AggregatorV3Interface(0x3f3f5dF88dC9F13eac63DF89EC16ef6e7E25DdE7),
            ICurvePool(triCryptoPool)
        );
    }

    function testPrice() public view {
        uint price = oracle.getPrice(address(0));
        console.log(price);
    }

    function testPriceAfterDeposit(uint80 amount) public {
        priceBefore = oracle.getPrice(address(0));

        deposit(amount);

        priceAfter = oracle.getPrice(address(0));

        assertApproxEqAbs(priceBefore, priceAfter, 1e15);
    }

    function testPriceAfterWithdraw(uint80 amount) public {
        testPriceAfterDeposit(amount);

        withdraw();

        priceAfter = oracle.getPrice(address(0));

        assertApproxEqAbs(priceBefore, priceAfter, 1e15);
    }

    function testPriceAfterExchange(uint64 amount) public {
        priceBefore = oracle.getPrice(address(0));

        exchange(amount);
        console.log(1);

        priceAfter = oracle.getPrice(address(0));

        assertApproxEqAbs(priceBefore, priceAfter, 1e15);
    }

    function deposit(uint80 amount) internal {
        vm.assume(amount > 1e15);
        deal(address(WETH), address(this), amount, true);

        WETH.approve(triCryptoPool, amount);

        uint256[3] memory amounts;
        amounts[2] = amount;

        ITriCryptoPool(triCryptoPool).add_liquidity(amounts, 1);
    }

    function withdraw() internal {
        uint balance = triCrypto.balanceOf(address(this));
        triCrypto.approve(address(triCryptoPool), balance);
        uint[3] memory amounts;
        amounts[0] = 1;
        amounts[1] = 1;
        amounts[2] = 1;
        ITriCryptoPool(triCryptoPool).remove_liquidity(balance, amounts);
    }

    function exchange(uint64 amount) internal {
        vm.assume(amount > 1e18);
        deal(address(WETH), address(this), amount, true);
        WETH.approve(triCryptoPool, amount);

        ITriCryptoPool(triCryptoPool).exchange(2, 0, amount, 1, false);
    }
}