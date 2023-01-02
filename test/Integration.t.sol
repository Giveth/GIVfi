// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./shared/SharedInitializationBridgeable.sol";
import "../src/Vault/Vault.sol";
import "../src/Vault/VaultBridge.sol";

contract IntegrationTest is SharedInitializationBridgeable {
    VaultBridge public bridge;
    Vault public vault;

    function setUp() public override {
        _initializeVariables();
        bridge = new VaultBridge();
        vault = new Vault();

        vault.initialize("Vault", "VLT", allowedToken);
        bridge.initialize(address(donationHandler), address(vault));
        donationHandler.init(); // called by round contract
        donationHandler.initialize(acceptedToken, donationRecipient, feeReceiver, admins, 1e17, address(bridge), false);
    }

    function _encode(address token, uint256 amount, address recipient) internal pure returns (bytes memory) {
        return abi.encode(token, amount, recipient);
    }

    function _donate() internal {
        bytes[] memory donation = new bytes[](2);

        donation[0] = _encode(address(allowedToken), 100, address(1));
        donation[1] = _encode(address(allowedToken2), 100, address(1));

        allowedToken.approve(address(donationHandler), 100);
        allowedToken2.approve(address(donationHandler), 100);

        donationHandler.vote(donation, deployer);
    }

    function test_donateAndBridge() public {
        _donate();

        assertEq(donationHandler.balanceOf(address(allowedToken), address(1)), 90);

        uint256[] memory balances = donationHandler.balancesOf(acceptedToken, address(1));

        assertEq(balances.length, 2);
        assertEq(balances[0], 90);
        assertEq(balances[1], 90);

        vm.prank(address(3)); // donation handler admin
        bridge.bridge(); // only dh admin

        assertEq(vault.balanceOf(address(bridge)), 100);
        assertEq(allowedToken.balanceOf(address(donationHandler)), 0);
        assertEq(allowedToken.balanceOf(address(vault)), 100);
    }

    function test_withdrawAfterBridge() public {
        _donate();
        vm.prank(address(3)); // donation handler admin
        bridge.bridge(); // only dh admin

        vm.prank(address(1)); // recipient
        donationHandler.withdraw(address(allowedToken), 90);
        assertEq(donationHandler.balanceOf(address(allowedToken), address(1)), 0);
        assertEq(allowedToken.balanceOf(address(1)), 90);
    }
}
