// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./shared/SharedInitialization.sol";

contract DonationHandlerInitializationTest is SharedInitialization {
    function setUp() public override {
        _initializeVariables();
    }

    function test_initialization() public {
        _initializeDonationHandler();

        assertEq(allowedToken.balanceOf(deployer), 1_000_000 * 1e18);
        assertFalse(donationHandler.isTokenAccepted(address(notAllowedToken)));
        assertTrue(donationHandler.isTokenAccepted(address(allowedToken)));
        assertTrue(donationHandler.isDonationRecipient(address(1)));
        assertTrue(donationHandler.isFeeReceiver(address(2)));
        assertTrue(donationHandler.isAdmin(address(3)));
    }

    function testFail_initializationSecondTime() public {
        _initializeDonationHandler();
        _initializeDonationHandler();
    }
}
