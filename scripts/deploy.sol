// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "forge-std/Test.sol";

import {OracleFacade} from "../src/core/OracleFacade.sol";
import {IOracle} from "../src/core/IOracle.sol";
import {WETHOracle} from "../src/weth/WETHOracle.sol";
import {ArbiChainlinkOracle} from "../src/chainlink/ArbiChainlinkOracle.sol";
import {CurveTriCryptoOracle} from "../src/curve/CurveTriCryptoOracle.sol";
import {ATokenOracle} from "../src/aave/ATokenOracle.sol";
import {UniV2LpOracle} from "../src/uniswap/UniV2LpOracle.sol";
import {ComposableStableBalancerLPOracleV2} from "../src/balancer/ComposableStableBalancerLPOracleV2.sol";
import {StableBalancerLPOracleV2} from "../src/balancer/StableBalancerLPOracleV2.sol";
import {WeightedBalancerLPOracleV2} from "../src/balancer/WeightedBalancerLPOracleV2.sol";
import {ConvexRewardPoolOracle} from "../src/convex/ConvexRewardPoolOracle.sol";
import {Stable2CurveOracle} from "../src/curve/Stable2CurveOracle.sol";
import {Stable2CurveGaugeOracle} from "../src/curve/Stable2CurveGaugeOracle.sol";
import {ERC4626Oracle} from "../src/erc4626/ERC4626Oracle.sol";
import {GLPOracle} from "../src/gmx/GLPOracle.sol";
import {WSTETHOracle} from "../src/wsteth/WSTETHOracle.sol";

contract Deploy is Test {

    // Balancer
    address BLPWBTCWETHUSDC = 0x64541216bAFFFEec8ea535BB71Fbc927831d0595;
    address BLPWSTETHUSDC = 0x178E029173417b1F9C8bC16DCeC6f697bC323746;
    address BLPWSTETHWETH = 0xFB5e6d0c1DfeD2BA000fBC040Ab8DF3615AC329c;
    address BLPUSDTDAIUSDC = 0x1533A3278f3F9141d5F820A184EA4B017fce2382;
    address BLPWSTETHWETHSTABLE = 0x36bf227d6BaC96e2aB1EbB5492ECec69C691943f;
    address BLPWBTCWETHUSDCGAUGE = 0x104f1459a2fFEa528121759B238BB609034C2f01;
    address BLPWSTETHUSDCGAUGE = 0x9232EE56ab3167e2d77E491fBa82baBf963cCaCE;
    address BLPWSTETHWETHGAUGE = 0x5b6776cD9c51768Fc915caD7a7e8F5c4a6331131;
    address BLPWSTETHWETHSTABLEGAUGE = 0x251e51b25AFa40F2B6b9F05aaf1bC7eAa0551771;

    // SushiSwap
    address WBTCWETHSLP = 0x515e252b2b5c22b4b2b6Df66c2eBeeA871AA4d69;
    address WETHARBSLP = 0xBF6CBb1F40a542aF50839CaD01b0dc1747F11e18;
    address WETHUSDCSLP = 0x905dfCD5649217c42684f23958568e533C711Aa3;

    // Curve
    address triCrypto = 0x8e0B8c8BB9db49a46697F3a5Bb8A308e744821D2;
    address twoCRV = 0x7f90122BF0700F9E7e1F688fe926940E8839F353;
    address triCryptoGauge = 0x555766f3da968ecBefa690Ffd49A2Ac02f47aa5f;
    address twoCRVGauge = 0xCE5F24B7A95e9cBa7df4B54E911B4A3Dc8CDAf6f;
    address fraxBPCRV = 0xC9B8a3FDECB9D5b218d02555a8Baf332E5B740d5;
    address fraxBPCRVGauge = 0x95285Ea6fF14F80A2fD3989a6bAb993Bd6b5fA13;

    // Convex
    address CVX2CRV = 0x63F00F688086F0109d586501E783e33f2C950e78;
    address CVX3CRYPTO = 0x90927a78ad13C0Ec9ACf546cE0C16248A7E7a86D;
    address CVXFRAXBP = 0xc501491b0e4A73B2eFBaC564a412a927D2fc83dD;
    address CVX2CRVV2 = 0x971E732B5c91A59AEa8aa5B0c763E6d648362CF8;
    address CVX3CRYPTOV2 = 0xA9249f8667cb120F065D9dA1dCb37AD28E1E8FF0;
    address CVXFRAXBPV2 = 0x93729702Bf9E1687Ae2124e191B8fFbcC0C8A0B0;

    // Aave
    address aWETH = 0xe50fA9b3c56FfB159cB0FCA61F5c9D750e8128c8;
    address aUSDC = 0x625E7708f30cA75bfd92586e17077590C60eb4cD;
    address aWBTC = 0x078f358208685046a11C85e8ad32895DED33A249;
    address aDAI = 0x82E64f49Ed5EC1bC6e43DAD4FC8Af9bb3A2312EE;
    address aUSDT = 0x6ab707Aca953eDAeFBc4fD23bA73294241490620;

    // GMX
    address SGLP = 0x5402B5F40310bDED796c7D0F3FF6683f5C0cFfdf;

    // ERC20
    address WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address USDC = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    address DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    address USDT = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;
    address CURVE = 0x11cDb42B0EB46D95f990BeDD4695A6e3fA034978;
    address WBTC = 0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f;
    address WSTETH = 0x5979D7b546E38E414F7E9822514be443A4800529;
    address BAL = 0x040d1EdC9569d4Bab2D15287Dc5A4F10F56a56B8;
    address LDO = 0x13Ad51ed4F1B7e9Dc168d8a00cB3f4dDD85EfA60;
    address CVX = 0xb952A807345991BD529FDded05009F5e80Fe8F45;
    address GMX = 0xfc5A1A6EB076a2C7aD06eD22C90d7E710E35ad0a;
    address FRAX = 0x17FC002b466eEc40DaE837Fc4bE5c67993ddBd6F;
    address ARB = 0x912CE59144191C1204E64559FE8253a0e49E6548;

    // Oracles
    OracleFacade oracle = OracleFacade(0xc79C23DEcc176Bd03dea9Ec6E56383589c0894A6);
    OracleFacade oldOracle = OracleFacade(0x08F81E1637230d25b4ea6d4a69D74373E433Efb3);
    WETHOracle wethOracle = WETHOracle(0x0F8011D2575C05dFd526C1AeA7BfA8f082d7e830);
    ArbiChainlinkOracle chainlinkOracle = ArbiChainlinkOracle(0xecB0AB1B57BcDa08D96E5580B034bA02B9de0aD8);
    CurveTriCryptoOracle curveTriCryptoOracle = CurveTriCryptoOracle(0x4e828A117Ddc3e4dd919b46c90D4E04678a05504);
    GLPOracle gLPOracle = GLPOracle(0xBBA8E744B7E3d69909E413Cf411B6CB92a27d4c9);
    WSTETHOracle wstethOracle = WSTETHOracle(0x1Dd8ce83B8C0dA4d180b372458D342f55C02845B);
    ComposableStableBalancerLPOracleV2 composableStableBalancerLPOracleV2 = ComposableStableBalancerLPOracleV2(0xf3156636e3aed16bfaB0Bdd6A865476230b14F93);
    StableBalancerLPOracleV2 stableBalancerLPOracleV2 = StableBalancerLPOracleV2(0xF913537aCA8495F279C77e6ccc6B50689fA5FF4f);
    WeightedBalancerLPOracleV2 weightedBalancerLPOracleV2 = WeightedBalancerLPOracleV2(0xC0Fc3193Bf2176D1DA6D2F24C14996766f46eB67);

    ATokenOracle aTokenOracle;
    UniV2LpOracle SLPOracle;
    ConvexRewardPoolOracle convexRewardPoolOracle;
    Stable2CurveOracle stable2crvOracle;
    Stable2CurveGaugeOracle stable2CurveGaugeOracle;
    ERC4626Oracle erc4626Oracle;


    function run() public {
        vm.startBroadcast();

        oracle = new OracleFacade();

        /// Setup Aaave
        aTokenOracle = new ATokenOracle(oracle);
        oracle.setOracle(aWETH, aTokenOracle);
        oracle.setOracle(aUSDC, aTokenOracle);
        oracle.setOracle(aDAI, aTokenOracle);
        oracle.setOracle(aWBTC, aTokenOracle);
        oracle.setOracle(aUSDT, aTokenOracle);

        /// Setup sushi
        SLPOracle = new UniV2LpOracle(oracle);
        oracle.setOracle(WBTCWETHSLP, SLPOracle);
        oracle.setOracle(WETHUSDCSLP, SLPOracle);
        oracle.setOracle(WETHARBSLP, SLPOracle);

        /// Setup Convex
        convexRewardPoolOracle = new ConvexRewardPoolOracle(oracle);
        oracle.setOracle(CVX2CRV, convexRewardPoolOracle);
        oracle.setOracle(CVX3CRYPTO, convexRewardPoolOracle);
        oracle.setOracle(CVXFRAXBP, convexRewardPoolOracle);
        oracle.setOracle(CVX2CRVV2, convexRewardPoolOracle);
        oracle.setOracle(CVX3CRYPTOV2, convexRewardPoolOracle);
        oracle.setOracle(CVXFRAXBPV2, convexRewardPoolOracle);

        /// Setup Curve
        stable2crvOracle = new Stable2CurveOracle(oracle);
        oracle.setOracle(twoCRV, stable2crvOracle);
        oracle.setOracle(fraxBPCRV, stable2crvOracle);

        /// Setup curve and balance gauge
        stable2CurveGaugeOracle = new Stable2CurveGaugeOracle(oracle);
        oracle.setOracle(twoCRVGauge, stable2CurveGaugeOracle);
        oracle.setOracle(fraxBPCRVGauge, stable2CurveGaugeOracle);
        oracle.setOracle(BLPWBTCWETHUSDCGAUGE, stable2CurveGaugeOracle);
        oracle.setOracle(BLPWSTETHUSDCGAUGE, stable2CurveGaugeOracle);
        oracle.setOracle(BLPWSTETHWETHGAUGE, stable2CurveGaugeOracle);
        oracle.setOracle(BLPWSTETHWETHSTABLEGAUGE, stable2CurveGaugeOracle);

        /// Setup old oracles
        oracle.setOracle(WETH, oldOracle.oracle(WETH));
        oracle.setOracle(USDC, oldOracle.oracle(USDC));
        oracle.setOracle(USDT, oldOracle.oracle(USDT));
        oracle.setOracle(DAI, oldOracle.oracle(DAI));
        oracle.setOracle(WBTC, oldOracle.oracle(WBTC));
        oracle.setOracle(CURVE, oldOracle.oracle(CURVE));
        oracle.setOracle(WSTETH, oldOracle.oracle(WSTETH));
        oracle.setOracle(BAL, oldOracle.oracle(BAL));
        oracle.setOracle(LDO, oldOracle.oracle(LDO));
        oracle.setOracle(CVX, oldOracle.oracle(CVX));
        oracle.setOracle(FRAX, oldOracle.oracle(FRAX));
        oracle.setOracle(GMX, oldOracle.oracle(GMX));
        oracle.setOracle(SGLP, oldOracle.oracle(SGLP));
        oracle.setOracle(ARB, oldOracle.oracle(ARB));
        oracle.setOracle(triCrypto, oldOracle.oracle(triCrypto));
        oracle.setOracle(triCryptoGauge, oldOracle.oracle(triCryptoGauge));
        oracle.setOracle(twoCRVGauge, oldOracle.oracle(twoCRVGauge));

        /// Setup balancer bpt oracles
        oracle.setOracle(BLPWBTCWETHUSDC, IOracle(address(weightedBalancerLPOracleV2)));
        oracle.setOracle(BLPWSTETHUSDC, IOracle(address(weightedBalancerLPOracleV2)));
        oracle.setOracle(BLPWSTETHWETH, IOracle(address(composableStableBalancerLPOracleV2)));
        oracle.setOracle(BLPWSTETHWETHSTABLE, IOracle(address(stableBalancerLPOracleV2)));
        oracle.setOracle(BLPUSDTDAIUSDC, IOracle(address(stableBalancerLPOracleV2)));


        vm.stopBroadcast();
    }

    function printControllers() internal view {
        console.log("aTokenOracle", address(aTokenOracle));
        console.log("SLPOracle", address(SLPOracle));
        console.log("convexRewardPoolOracle", address(convexRewardPoolOracle));
        console.log("stable2crvOracle", address(stable2crvOracle));
        console.log("stable2CurveGaugeOracle", address(stable2CurveGaugeOracle));
    }
}
