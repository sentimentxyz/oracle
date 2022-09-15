// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IVault {
    function deposit(uint256) external;
    function depositAll() external;
    function withdraw(uint256) external;
    function withdrawAll() external;
    function getPricePerFullShare() external view returns (uint256);
    function upgradeStrat() external;
    function balance() external view returns (uint256);
    function want() external view returns (address);
    function strategy() external view returns (address);
}