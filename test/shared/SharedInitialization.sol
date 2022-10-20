// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/DonationHandler.sol";
import "../mocks/MockERC20.sol";

contract SharedInitialization is Test {
    address deployer = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;
    address public constant NATIVE = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    DonationHandler public donationHandler;
    MockERC20 public allowedToken;
    MockERC20 public allowedToken2;
    MockERC20 public notAllowedToken;

    address[] acceptedToken = new address[](2);
    address[] donationRecipient = new address[](1);
    address[] feeReceiver = new address[](1);
    address[] admins = new address[](1);

    function setUp() public virtual {
        _initializeVariables();
        _initializeDonationHandler();
    }

    function _initializeVariables() internal {
        allowedToken = new MockERC20("Mock", "MCK");
        allowedToken2 = new MockERC20("Mock2", "MCK2");
        notAllowedToken = new MockERC20("XXXX", "XXX");

        donationHandler = new DonationHandler();

        acceptedToken[0] = address(allowedToken);
        acceptedToken[1] = address(allowedToken2);
        donationRecipient[0] = address(1);
        feeReceiver[0] = address(2);
        admins[0] = address(3);
    }

    function _initializeDonationHandler() internal {
        donationHandler.initialize(acceptedToken, donationRecipient, feeReceiver, admins);
    }
}
