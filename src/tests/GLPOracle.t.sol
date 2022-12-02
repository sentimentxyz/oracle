// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {GLPOracle} from "../gmx/GLPOracle.sol";
import {IGLPManager} from "../gmx/IGLPManager.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {AggregatorV3Interface} from "../chainlink/AggregatorV3Interface.sol";

interface IRewardRouter {
    function mintAndStakeGlp(
        address _token,
        uint256 _amount,
        uint256 _minUsdg,
        uint256 _minGlp
    ) external returns (uint256);

    function unstakeAndRedeemGlp(
        address _tokenOut,
        uint256 _glpAmount,
        uint256 _minOut,
        address _receiver
    ) external returns (uint256);
}

contract GLPOracleTest is Test {

    GLPOracle oracle;

    uint priceBefore;
    uint priceAfter;

    IRewardRouter router = IRewardRouter(0xB95DB5B167D75e6d04227CfFFA61069348d271F5);
    IERC20 WETH = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    IERC20 sGLP = IERC20(0x5402B5F40310bDED796c7D0F3FF6683f5C0cFfdf);

    function setUp() public {
        oracle = new GLPOracle(
            IGLPManager(0x3963FfC9dff443c2A94f21b129D429891E32ec18),
            AggregatorV3Interface(0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612)
        );
    }

    function testPrice() public view {
        uint price = oracle.getPrice(address(0));
        console.log(price);
    }

    function testPriceAfterDeposit(uint64 amount) public {
        priceBefore = oracle.getPrice(address(0));

        deposit(amount);

        priceAfter = oracle.getPrice(address(0));

        assertApproxEqAbs(priceBefore, priceAfter, 1e3);
    }

    function testPriceAfterWithdraw(uint64 amount) public {
        testPriceAfterDeposit(amount);

        withdraw();

        priceAfter = oracle.getPrice(address(0));

        assertApproxEqAbs(priceBefore, priceAfter, 1e3);
    }

    function deposit(uint64 amount) internal {
        vm.assume(amount > 1e15);
        deal(address(WETH), address(this), amount, true);

        WETH.approve(0x3963FfC9dff443c2A94f21b129D429891E32ec18, amount);

        router.mintAndStakeGlp(address(WETH), amount, 0, 0);
    }

    function withdraw() internal {
        uint balance = sGLP.balanceOf(address(this));
        router.unstakeAndRedeemGlp(address(WETH), balance, 1, address(this));
    }
}