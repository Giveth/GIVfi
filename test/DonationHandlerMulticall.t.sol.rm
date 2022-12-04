// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./shared/SharedInitialization.sol";

contract DonationHandlerMulticallTest is SharedInitialization {
    // acceptedToken[0] = address(allowedToken);
    // acceptedToken[1] = address(allowedToken2);
    // donationRecipient[0] = address(1);
    // feeReceiver[0] = address(2);
    // admins[0] = address(3);

    // Donate

    function testFail_donateWithoutApproval() public {
        bytes[] memory data = new bytes[](1);
        data[0] = abi.encodeWithSelector(donationHandler.donate.selector, address(allowedToken), address(1), 100, 0);
        donationHandler.multicall(data);
    }

    function testFail_donateWithoutApproval2() public {
        allowedToken.approve(address(donationHandler), 100);

        bytes[] memory data = new bytes[](2);

        data[0] = abi.encodeWithSelector(donationHandler.donate.selector, address(allowedToken), address(1), 100, 1e17);
        data[1] = abi.encodeWithSelector(donationHandler.donate.selector, address(allowedToken2), address(1), 100, 1e17);

        donationHandler.multicall(data);
    }

    function test_donate() public {
        allowedToken.approve(address(donationHandler), 100);
        allowedToken2.approve(address(donationHandler), 200);

        bytes[] memory data = new bytes[](2);

        data[0] = abi.encodeWithSelector(donationHandler.donate.selector, address(allowedToken), address(1), 90, 10);
        data[1] = abi.encodeWithSelector(donationHandler.donate.selector, address(allowedToken2), address(1), 20, 180);

        vm.expectEmit(true, true, true, true, address(donationHandler));
        emit DonationRegistered(address(allowedToken), address(this), address(1), 90);

        vm.expectEmit(true, true, true, true, address(donationHandler));
        emit FeeRegistered(address(allowedToken), address(this), 10);

        vm.expectEmit(true, true, true, true, address(donationHandler));
        emit DonationRegistered(address(allowedToken2), address(this), address(1), 20);

        vm.expectEmit(true, true, true, true, address(donationHandler));
        emit FeeRegistered(address(allowedToken2), address(this), 180);

        donationHandler.multicall(data);
        assertEq(donationHandler.balanceOf(address(allowedToken), address(1)), 90);
        assertEq(donationHandler.balanceOf(address(allowedToken), address(donationHandler)), 10);

        assertEq(donationHandler.balanceOf(address(allowedToken2), address(1)), 20);
        assertEq(donationHandler.balanceOf(address(allowedToken2), address(donationHandler)), 180);

        uint256[] memory balances = donationHandler.balancesOf(acceptedToken, address(1));
        assertEq(balances.length, 2);
        assertEq(balances[0], 90);
        assertEq(balances[1], 20);
    }

    function test_donateWithoutFee() public {
        allowedToken.approve(address(donationHandler), 100);
        allowedToken2.approve(address(donationHandler), 100);

        bytes[] memory data = new bytes[](2);

        data[0] = abi.encodeWithSelector(donationHandler.donate.selector, address(allowedToken), address(1), 100, 0);
        data[1] = abi.encodeWithSelector(donationHandler.donate.selector, address(allowedToken2), address(1), 100, 0);

        vm.expectEmit(true, true, true, true, address(donationHandler));
        emit DonationRegistered(address(allowedToken), address(this), address(1), 100);

        vm.expectEmit(true, true, true, true, address(donationHandler));
        emit DonationRegistered(address(allowedToken2), address(this), address(1), 100);

        donationHandler.multicall(data);
    }
}
