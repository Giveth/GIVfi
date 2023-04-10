// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./shared/SharedInitialization.sol";

contract DonationHandlerRolesTest is SharedInitialization {
    // acceptedToken[0] = address(allowedToken);
    // acceptedToken[1] = address(allowedToken2);
    // donationRecipient[0] = address(1);
    // feeReceiver[0] = address(2);
    // admins[0] = address(3);

    // Admin

    function testFail_addAdminNotAdmin() public {
        address[] memory newAdmin = new address[](1);
        newAdmin[0] = address(8);
        donationHandler.addAdmin(newAdmin);
    }

    function test_addAdmin() public {
        address[] memory newAdmin = new address[](1);
        newAdmin[0] = address(8);
        vm.prank(address(3));
        donationHandler.addAdmin(newAdmin);
        assertTrue(donationHandler.isAdmin(address(8)));
    }

    function testFail_removeAdminNotAdmin() public {
        address[] memory newAdmin = new address[](1);
        newAdmin[0] = address(3);
        vm.prank(address(9));
        donationHandler.removeAdmin(newAdmin);
    }

    function test_removeAdmin() public {
        address[] memory newAdmin = new address[](1);
        newAdmin[0] = address(8);
        vm.prank(address(3));
        donationHandler.addAdmin(newAdmin);
        assertTrue(donationHandler.isAdmin(address(8)));
        donationHandler.removeAdmin(newAdmin);
        assertFalse(donationHandler.isAdmin(address(8)));
    }

    function testFail_revokeAdminNoAdmin() public {
        vm.prank(address(8));
        donationHandler.revokeAdmin();
    }

    function test_revokeAdmin() public {
        vm.prank(address(3));
        donationHandler.revokeAdmin();
        assertFalse(donationHandler.isAdmin(address(3)));
    }

    // Token

    function testFail_addTokenNotAdmin() public {
        vm.prank(address(4));
        address[] memory t = new address[](1);
        t[0] = address(notAllowedToken);
        donationHandler.addToken(t);
    }

    function test_addToken() public {
        vm.prank(address(3));
        address[] memory t = new address[](1);
        t[0] = address(notAllowedToken);
        donationHandler.addToken(t);
        assertTrue(donationHandler.isTokenAccepted(address(notAllowedToken)));
    }

    function testFail_removeTokenNotAdmin() public {
        vm.prank(address(4));
        donationHandler.removeToken(acceptedToken);
    }

    function test_removeToken() public {
        vm.prank(address(3));
        donationHandler.removeToken(acceptedToken);
        assertFalse(donationHandler.isTokenAccepted(address(allowedToken)));
        assertFalse(donationHandler.isTokenAccepted(address(allowedToken2)));
    }

    // Donation Recipient

    function testFail_addDonationRecipientNotAdmin() public {
        address[] memory newDonationRecipient = new address[](1);
        newDonationRecipient[0] = address(8);
        donationHandler.addDonationRecipient(newDonationRecipient);
    }

    function test_addDonationRecipient() public {
        address[] memory newDonationRecipient = new address[](1);
        newDonationRecipient[0] = address(8);
        vm.prank(address(3));
        donationHandler.addDonationRecipient(newDonationRecipient);
        assertTrue(donationHandler.isDonationRecipient(address(8)));
    }

    function testFail_removeDonationRecipientNotAdmin() public {
        address[] memory newDonationRecipient = new address[](1);
        newDonationRecipient[0] = address(3);
        vm.prank(address(9));
        donationHandler.removeDonationRecipient(newDonationRecipient);
    }

    function test_removeDonationRecipient() public {
        address[] memory newDonationRecipient = new address[](1);
        newDonationRecipient[0] = address(8);
        vm.prank(address(3));

        donationHandler.addDonationRecipient(newDonationRecipient);
        assertTrue(donationHandler.isDonationRecipient(address(8)));

        vm.prank(address(3));
        donationHandler.removeDonationRecipient(newDonationRecipient);
        assertFalse(donationHandler.isDonationRecipient(address(8)));
    }

    // Fee Receiver

    function testFail_addFeeReceiverNotAdmin() public {
        vm.prank(address(4));
        address[] memory a = new address[](1);
        a[0] = address(5);
        donationHandler.addFeeReceiver(a);
    }

    function test_addFeeReceiver() public {
        vm.prank(address(3));
        address[] memory a = new address[](1);
        a[0] = address(5);
        donationHandler.addFeeReceiver(a);
        assertTrue(donationHandler.isFeeReceiver(address(5)));
    }

    function testFail_removeFeeReceiverNotAdmin() public {
        vm.prank(address(4));
        donationHandler.removeFeeReceiver(feeReceiver);
    }

    function test_removeFeeReceiver() public {
        vm.prank(address(3));
        donationHandler.removeFeeReceiver(feeReceiver);
        assertFalse(donationHandler.isFeeReceiver(address(2)));
    }
}
