// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {AggregatorV3Interface} from "../chainlink/AggregatorV3Interface.sol";
import {ArbiChainlinkOracle} from "../chainlink/ArbiChainlinkOracle.sol";

contract ArbiChainlinkOracleTest is Test {

    ArbiChainlinkOracle oracle;

    address USDC = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    AggregatorV3Interface usdcFeed = AggregatorV3Interface(0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3);

    uint priceBefore;
    uint priceAfter;

    function setUp() public {
        oracle = new ArbiChainlinkOracle(
            AggregatorV3Interface(0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612),
            AggregatorV3Interface(0xFdB631F5EE196F0ed6FAa767959853A9F217697D)
        );
        oracle.setFeed(USDC, usdcFeed, 86400);
    }

    function testPrice() public view {
        uint price = oracle.getPrice(USDC);
        console.log(price);
    }

    function testFailStalePrice() public {
        skip(86400);
        oracle.getPrice(USDC);
    }

    function testFailNegativePrice() public {
        vm.mockCall(
            0x50834F3163758fcC1Df9973b6e91f0F0F0434aD3,
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(0, 0, 0, block.timestamp, 0)
        );
        oracle.getPrice(USDC);
    }

    function testFailSequencerDown() public {
        vm.mockCall(
            0xFdB631F5EE196F0ed6FAa767959853A9F217697D,
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(0, 1, 0, block.timestamp, 0)
        );
        oracle.getPrice(USDC);
    }
}
