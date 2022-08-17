// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "ds-test/Test.sol";
import "src/balancer/BalancerLPOracle.sol";
import "src/core/IOracle.sol";
import "solmate/utils/FixedPointMathLib.sol";
import "src/utils/IERC20.sol";

contract TestOracle is DSTest {
    using FixedPointMathLib for uint;
    IOracle oracleFacade = IOracle(0x7b5A8801170b3d1090F1078667F7A20af4f08265);
    WeightedBalancerLPOracle oracle;

    function setUp() public {
        oracle = new WeightedBalancerLPOracle(
            oracleFacade,
            IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8)
        );
    }

    function testPrice() public {
        emit log_uint(
            oracle.getPrice(0x64541216bAFFFEec8ea535BB71Fbc927831d0595)
            .mulWadDown(IERC20(0x64541216bAFFFEec8ea535BB71Fbc927831d0595).balanceOf(0x884ba7391637BfCE1D0B8C3aF6723477f6541e0e))
        );
    }
}