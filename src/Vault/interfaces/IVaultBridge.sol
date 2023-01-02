// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IVaultBridge {
    function initialize(address _donationHandler, address _vault) external;

    function bridge() external;

    function withdraw(uint256 _amount) external;

    function getVault() external view returns (address);

    function getAsset() external view returns (address);

    function getDonationHanlder() external view returns (address);
}
