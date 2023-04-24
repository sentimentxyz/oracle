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

    function reserveToken() external view returns (address);

    function exitQuote(uint256 investmentAmount, address toToken, uint256 maxSlippageBps, uint256 deadline)
        external
        view
        returns (ExitQuoteData memory quoteData, uint256[] memory exitFeeBps);

    /**
     * @notice Quote data required when exoomg this investment.
     */
    struct ExitQuoteData {
        /// @notice The amount of this investment to sell
        uint256 investmentTokenAmount;
        /// @notice The token to sell into, which must be one of `acceptedExitTokens()`
        address toToken;
        /// @notice The maximum acceptable slippage of the `expectedToTokenAmount`
        uint256 maxSlippageBps;
        /// @notice The maximum deadline to execute the transaction.
        uint256 deadline;
        /// @notice The expected amount of `toToken` to receive in return
        /// @dev Note slippage is applied to this when calling `invest()`
        uint256 expectedToTokenAmount;
        /// @notice The minimum amount of `toToken` to receive after
        /// slippage has been applied.
        uint256 minToTokenAmount;
        /// @notice Any extra quote parameters required by the underlying investment
        bytes underlyingInvestmentQuoteData;
    }
}
