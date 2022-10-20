// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./shared/SharedInitialization.sol";

contract DonationHandlerTest is SharedInitialization {
    // acceptedToken[0] = address(allowedToken);
    // acceptedToken[1] = address(allowedToken2);
    // donationRecipient[0] = address(1);
    // feeReceiver[0] = address(2);
    // admins[0] = address(3);

    // Donate

    function testFail_donateWithoutApproval() public {
        donationHandler.donate(address(allowedToken), address(1), 100, 0);
    }

    function test_donateWithoutFee() public {
        allowedToken.approve(address(donationHandler), 100);
        donationHandler.donate(address(allowedToken), address(1), 100, 0);
        assertEq(donationHandler.balanceOf(address(allowedToken), address(1)), 100);
    }

    function _donate() internal {
        allowedToken.approve(address(donationHandler), 100);
        donationHandler.donate(address(allowedToken), address(1), 100, 1e17); // 10% fee

        allowedToken2.approve(address(donationHandler), 100);
        donationHandler.donate(address(allowedToken2), address(1), 100, 1e17); // 10% fee
    }

    function test_donate() public {
        _donate();
        assertEq(donationHandler.balanceOf(address(allowedToken), address(1)), 90);
        assertEq(donationHandler.balanceOf(address(allowedToken), address(donationHandler)), 10);

        uint256[] memory balances = donationHandler.balancesOf(acceptedToken, address(1));
        assertEq(balances.length, 2);
        assertEq(balances[0], 90);
        assertEq(balances[1], 90);
    }

    function test_donateHundred() public {
        allowedToken.approve(address(donationHandler), 100);
        donationHandler.donate(address(allowedToken), address(1), 100, 1e18);
        assertEq(donationHandler.balanceOf(address(allowedToken), address(1)), 0);
        assertEq(donationHandler.balanceOf(address(allowedToken), address(donationHandler)), 100);
    }

    function testFail_donateTooHigh() public {
        allowedToken.approve(address(donationHandler), 100);
        donationHandler.donate(address(allowedToken), address(1), 100, 1.1e18); // 110% fee
    }

    function testFail_donateTooLow() public {
        donationHandler.setMinFee(1e17); // min fee: 10%
        allowedToken.approve(address(donationHandler), 100);
        donationHandler.donate(address(allowedToken), address(1), 100, 1e16); // 1% fee
    }

    function testFail_donateToWrongRecipient() public {
        allowedToken.approve(address(donationHandler), 100);
        donationHandler.donate(address(allowedToken), address(2), 100, 0);
    }

    function testFail_donateWithWrongToken() public {
        notAllowedToken.approve(address(donationHandler), 100);
        donationHandler.donate(address(notAllowedToken), address(1), 100, 0);
    }

    function test_donateEth() public {
        donationHandler.donate{value: 100}(NATIVE, address(1), 100, 1e17); // 10% fee
        assertEq(donationHandler.balanceOf(NATIVE, address(1)), 90);
        assertEq(donationHandler.balanceOf(NATIVE, address(donationHandler)), 10);
    }

    // withdraw

    function test_withdraw() public {
        _donate();
        vm.prank(address(1));
        donationHandler.withdraw(address(allowedToken), 80);
        assertEq(donationHandler.balanceOf(address(allowedToken), address(1)), 10);
        assertEq(allowedToken.balanceOf(address(1)), 80);
    }

    function test_withdrawMany() public {
        _donate();
        vm.prank(address(1));
        donationHandler.withdrawMany(acceptedToken);
        assertEq(donationHandler.balanceOf(address(allowedToken), address(1)), 0);
        assertEq(allowedToken.balanceOf(address(1)), 90);
        assertEq(allowedToken2.balanceOf(address(1)), 90);
    }

    function testFail_withdrawTooMuch() public {
        _donate();
        vm.prank(address(1));
        donationHandler.withdraw(address(allowedToken), 100);
    }

    function testFail_withdrawWrongToken() public {
        _donate();
        vm.prank(address(1));
        donationHandler.withdraw(address(notAllowedToken), 80);
    }

    function testFail_withdrawWrongRecipient() public {
        _donate();
        vm.prank(address(2));
        donationHandler.withdraw(address(allowedToken), 80);
    }

    function testFail_withdrawFeeNotAdmin() public {
        _donate();
        vm.prank(address(4));
        donationHandler.withdrawFee(address(allowedToken));
    }

    function test_withdrawFee() public {
        _donate();
        vm.prank(address(2));
        donationHandler.withdrawFee(address(allowedToken));
        assertEq(donationHandler.balanceOf(address(allowedToken), address(donationHandler)), 0);
        assertEq(allowedToken.balanceOf(address(2)), 10);
    }

    function test_withdrawFeeMany() public {
        _donate();
        vm.prank(address(2));
        donationHandler.withdrawFeeMany(acceptedToken);
        assertEq(allowedToken.balanceOf(address(2)), 10);
        assertEq(allowedToken2.balanceOf(address(2)), 10);
    }

    function test_WithdrawEth() public {
        donationHandler.donate{value: 100}(NATIVE, address(1), 100, 1e17); // 10% fee
        assertEq(donationHandler.balanceOf(NATIVE, address(1)), 90);
        assertEq(donationHandler.balanceOf(NATIVE, address(donationHandler)), 10);

        vm.prank(address(1));
        uint256 balanceBefore = address(1).balance;
        donationHandler.withdraw(NATIVE, 80);
        uint256 balanceAfter = address(1).balance;
        assertEq(donationHandler.balanceOf(NATIVE, address(1)), 10);
        assertEq(balanceAfter - balanceBefore, 80);
    }

    // distribute

    function test_distribute() public {
        _donate();
        vm.prank(address(8));
        donationHandler.distribute(acceptedToken, address(1));
        assertEq(allowedToken.balanceOf(address(1)), 90);
        assertEq(allowedToken2.balanceOf(address(1)), 90);
    }

    function test_distributeMany() public {
        _donate();
        vm.prank(address(8));
        donationHandler.distributeMany(acceptedToken, donationRecipient);
        assertEq(allowedToken.balanceOf(address(1)), 90);
        assertEq(allowedToken2.balanceOf(address(1)), 90);
    }

    // fee
    function testFail_setMinFeeNotAdmin() public {
        vm.prank(address(4));
        donationHandler.setMinFee(1e17);
    }

    function test_setMinFee() public {
        vm.prank(address(3));
        donationHandler.setMinFee(1e17);
        assertEq(donationHandler.minFee(), 1e17);
    }
}
