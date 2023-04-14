pragma solidity ^0.8.17;
// SPDX-License-Identifier: AGPL-3.0-or-later
// Origami (interfaces/investments/IOrigamiInvestment.sol)

/**
 * @title Origami Investment
 * @notice Users invest in the underlying protocol and receive a number of this Origami investment in return.
 * Origami will apply the accepted investment token into the underlying protocol in the most optimal way.
 */
interface IOrigamiInvestment {
    /// @notice How many reserve tokens would one get given a single share, as of now
    function reservesPerShare() external view returns (uint256);

    /**
     * @notice The underlying token this investment wraps.
     * @dev For informational purposes only, eg integrations/FE
     * If the investment wraps a protocol without an ERC20 (eg a non-liquid staked position)
     * then this may be 0x0
     */
    function baseToken() external view returns (address);
}
