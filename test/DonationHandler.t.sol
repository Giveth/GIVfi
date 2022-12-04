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

    function _encode(address token, uint256 amount, address recipient) internal pure returns (bytes memory) {
        return abi.encode(token, amount, recipient);
    }

    function testFail_donateWithoutApproval() public {
        bytes[] memory donation = new bytes[](1);
        donation[0] = _encode(address(allowedToken), 100, address(1));
        donationHandler.vote(donation, deployer);
    }

    function _donate() internal {
        bytes[] memory donation = new bytes[](2);

        donation[0] = _encode(address(allowedToken), 100, address(1));
        donation[1] = _encode(address(allowedToken2), 100, address(1));

        allowedToken.approve(address(donationHandler), 100);
        allowedToken2.approve(address(donationHandler), 100);

        donationHandler.vote(donation, deployer);
    }

    function test_donate() public {
        _donate();
        assertEq(donationHandler.balanceOf(address(allowedToken), address(1)), 90);

        uint256[] memory balances = donationHandler.balancesOf(acceptedToken, address(1));
        assertEq(balances.length, 2);
        assertEq(balances[0], 90);
        assertEq(balances[1], 90);
    }

    function testFail_donateToWrongRecipient() public {
        allowedToken.approve(address(donationHandler), 100);
        bytes[] memory donation = new bytes[](1);
        donation[0] = _encode(address(allowedToken), 100, address(2));
        donationHandler.vote(donation, deployer);
    }

    function testFail_donateWithWrongToken() public {
        notAllowedToken.approve(address(donationHandler), 100);
        bytes[] memory donation = new bytes[](1);
        donation[0] = _encode(address(notAllowedToken), 100, address(1));
        donationHandler.vote(donation, deployer);
    }

    function test_donateEth() public {
        bytes[] memory donation = new bytes[](1);
        donation[0] = _encode(NATIVE, 100, address(1));
        donationHandler.vote{value: 100}(donation, deployer);
        assertEq(donationHandler.balanceOf(NATIVE, address(1)), 90);
    }

    function test_donateMany() public {
        bytes[] memory donation = new bytes[](2);

        donation[0] = _encode(address(allowedToken), 200, address(1));
        donation[1] = _encode(address(allowedToken2), 200, address(1));

        allowedToken.approve(address(donationHandler), 200);
        allowedToken2.approve(address(donationHandler), 200);

        donationHandler.vote(donation, deployer);

        assertEq(donationHandler.balanceOf(address(allowedToken), address(1)), 180);
        assertEq(donationHandler.balanceOf(address(allowedToken), address(donationHandler)), 20);

        assertEq(donationHandler.balanceOf(address(allowedToken2), address(1)), 180);
        assertEq(donationHandler.balanceOf(address(allowedToken2), address(donationHandler)), 20);
    }

    // withdraw

    function test_withdraw() public {
        _donate();
        vm.prank(address(1));
        donationHandler.withdraw(address(allowedToken), 90);
        assertEq(donationHandler.balanceOf(address(allowedToken), address(1)), 0);
        assertEq(allowedToken.balanceOf(address(1)), 90);
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
        donationHandler.withdraw(address(notAllowedToken), 90);
    }

    function testFail_withdrawWrongRecipient() public {
        _donate();
        vm.prank(address(2));
        donationHandler.withdraw(address(allowedToken), 90);
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
        bytes[] memory donation = new bytes[](1);
        donation[0] = _encode(NATIVE, 100, address(1));

        donationHandler.vote{value: 100}(donation, deployer);

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
