// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../DonationHandler/interface/IDonationHandlerBridgeable.sol";
import "./Vault.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IERC20Upgradeable as IERC20} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract VaultBridge is Initializable {
    IDonationHandlerBridgeable public donationHandler;
    Vault public vault;
    IERC20 public asset;

    function initialize(address _donationHandler, address _vault) external initializer {
        donationHandler = IDonationHandlerBridgeable(_donationHandler);
        vault = Vault(_vault);
        asset = IERC20(vault.asset());
    }

    function bridge() external {
        onlyVaultAdmin();
        uint256 amount = asset.balanceOf(address(donationHandler));
        if (amount > 0) {
            donationHandler.take(address(asset), amount);
            asset.approve(address(vault), amount);
            vault.deposit(amount, address(this));
        }

        emit Bridged(donationHandler, asset, amount);
    }

    function withdraw(uint256 _amount) external {
        onlyDonationHandler();
        vault.withdraw(_amount, address(donationHandler), address(this));
        emit Withdrawn(_amount, donationHandler, address(this));
    }

    function getVault() external view returns (address) {
        return address(vault);
    }

    function getAsset() external view returns (address) {
        return address(asset);
    }

    function getDonationHanlder() external view returns (address) {
        return address(donationHandler);
    }

    function onlyVaultAdmin() internal view {
        if (!donationHandler.isAdmin(msg.sender)) {
            revert donationHandlerAdminOnly();
        }
    }

    function onlyDonationHandler() internal view {
        if (address(donationHandler) != msg.sender) {
            revert donationHandlerOnly();
        }
    }

    error donationHandlerAdminOnly();
    error donationHandlerOnly();

    event Bridged(IDonationHandlerBridgeable indexed donationHandler, IERC20 indexed asset, uint256 amount);

    event Withdrawn(uint256 amount, IDonationHandlerBridgeable indexed donationHandler, address indexed to);
}
