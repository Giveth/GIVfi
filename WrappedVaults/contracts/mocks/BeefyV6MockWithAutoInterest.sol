// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

import {ERC20Permit as ERC20} from "../element-fi/libraries/ERC20Permit.sol";
import "../IBeefyV6.sol";

contract BeefyV6MockWithAutoInterest is IBeefyV6, ERC20 {
    ERC20 public underlyingToken;
    uint256 public initialSharePrice;
    uint256 public annualInterestRate = 500; // 500% annual interest rate
    uint256 public deploymentTimestamp = block.timestamp;

    constructor(address _underlyingToken) ERC20("BeefyV6Mock", "BEEFYV6MOCK") {
        underlyingToken = ERC20(_underlyingToken);
        initialSharePrice = 1e18;
    }

    function getPricePerFullShare() external view returns (uint256) {
        uint256 currentSharePrice = calculateCurrentSharePrice();
        return currentSharePrice;
    }

    function deposit(uint256 _amount) external {
        uint256 sharesToMint = (_amount * initialSharePrice) / 1e18;
        underlyingToken.transferFrom(msg.sender, address(this), _amount);
        _mint(msg.sender, sharesToMint);
    }

    function withdraw(uint256 _shares) external {
        uint256 currentSharePrice = calculateCurrentSharePrice();
        uint256 amountToWithdraw = (_shares * currentSharePrice) / 1e18;
        _burn(msg.sender, _shares);
        underlyingToken.transfer(msg.sender, amountToWithdraw);
    }

    function withdrawAll() external {
        uint256 sharesOwned = this.balanceOf(msg.sender);
        uint256 currentSharePrice = calculateCurrentSharePrice();
        uint256 amountToWithdraw = (sharesOwned * currentSharePrice) / 1e18;
        _burn(msg.sender, sharesOwned);
        underlyingToken.transfer(msg.sender, amountToWithdraw);
    }

    function calculateCurrentSharePrice() internal view returns (uint256) {
        uint256 currentTimestamp = block.timestamp;
        uint256 timeSinceDeployment = currentTimestamp - deploymentTimestamp;
        uint256 interestRateFactor = (annualInterestRate * timeSinceDeployment) / (365 days);
        uint256 currentSharePrice = (initialSharePrice * (100 + interestRateFactor)) / 100;
        return currentSharePrice;
    }

    function earn() external pure {
        revert("earn not implemented");
    }

    function available() external view returns (uint256) {
        return underlyingToken.balanceOf(address(this));
    }

    function want() external view returns (IERC20) {
        return underlyingToken;
    }

    function setAnnualInterestRate (uint256 _annualInterestRate) external {
        annualInterestRate = _annualInterestRate;
    }
}
