// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {OracleFacade} from "../core/OracleFacade.sol";
import {GLPOracle} from "../gmx/GLPOracle.sol";
import {IPLVGLPDepositor} from "../plutus/IPLVGLPDepositor.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";
import {PLVGLPOracle} from "../plutus/PLVGLPOracle.sol";
import {IGLPManager} from "../gmx/IGLPManager.sol";
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

interface IWhitelist {
    function whitelistAdd(address) external;
}

contract PLVGLPOracleTest is Test {

    OracleFacade oracle;
    PLVGLPOracle plvGLPOracle;
    GLPOracle glpOracle;
    uint priceBefore;
    uint priceAfter;

    address PLVGLP = 0x5326E71Ff593Ecc2CF7AcaE5Fe57582D6e74CFF1;
    address SGLP = 0x5402B5F40310bDED796c7D0F3FF6683f5C0cFfdf;

    IRewardRouter router = IRewardRouter(0xB95DB5B167D75e6d04227CfFFA61069348d271F5);
    IERC20 sGLP = IERC20(0x5402B5F40310bDED796c7D0F3FF6683f5C0cFfdf);
    IERC20 WETH = IERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);

    IPLVGLPDepositor depositor = IPLVGLPDepositor(0x13F0D29b5B83654A200E4540066713d50547606E);

    address admin = 0xa5c1c5a67Ba16430547FEA9D608Ef81119bE1876;
    IWhitelist whitelist = IWhitelist(0x440B15954545FE2590a3693cFFE1F2b132891f61);

    function setUp() public {
        hoax(admin);
        whitelist.whitelistAdd(address(this));
        oracle = new OracleFacade();

        plvGLPOracle = new PLVGLPOracle(
            oracle,
            SGLP,
            depositor
        );

        glpOracle = new GLPOracle(
            IGLPManager(0x3963FfC9dff443c2A94f21b129D429891E32ec18),
            AggregatorV3Interface(0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612)
        );

        oracle.setOracle(SGLP, glpOracle);
        oracle.setOracle(PLVGLP, plvGLPOracle);
    }

    function testPrice() public view {
        uint price = oracle.getPrice(PLVGLP);
        console.log(price);
    }

    function testPriceAfterDeposit(uint64 amount) public {
        priceBefore = oracle.getPrice(PLVGLP);

        deposit(amount);

        priceAfter = oracle.getPrice(PLVGLP);

        assertApproxEqAbs(priceBefore, priceAfter, 1e3);
    }

    function testPriceAfterWithdraw(uint64 amount) public {
        testPriceAfterDeposit(amount);

        withdraw();

        priceAfter = oracle.getPrice(PLVGLP);

        assertApproxEqAbs(priceBefore, priceAfter, 1e11);
    }

    function deposit(uint64 amount) internal {
        vm.assume(amount > 1e15);
        deal(address(WETH), address(this), amount, true);

        WETH.approve(0x3963FfC9dff443c2A94f21b129D429891E32ec18, amount);

        router.mintAndStakeGlp(address(WETH), amount, 0, 0);

        IERC20(0x2F546AD4eDD93B956C8999Be404cdCAFde3E89AE).approve(address(depositor), type(uint).max);

        depositor.depositAll();
    }

    function withdraw() internal {
        IERC20(PLVGLP).approve(address(depositor), type(uint).max);
        depositor.redeemAll();
    }

}