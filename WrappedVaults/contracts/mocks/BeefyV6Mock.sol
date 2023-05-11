// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.17;

import {ERC20Permit as ERC20} from "../element-fi/libraries/ERC20Permit.sol";
import "../IBeefyV6.sol";

contract BeefyV6Mock is IBeefyV6, ERC20 {
    ERC20 public underlyingToken;
    uint256 public sharePrice;

    constructor(address _underlyingToken) ERC20("BeefyV6Mock", "BEEFYV6MOCK") {
        underlyingToken = ERC20(_underlyingToken);
        sharePrice = 1e18;
    }

    function getPricePerFullShare() external view returns (uint256) {
        return sharePrice;
    }

    function deposit(uint256 _amount) external {
        uint256 sharesToMint = _amount * sharePrice / 1e18;
        underlyingToken.transferFrom(msg.sender, address(this), _amount);
        _mint(msg.sender, sharesToMint);
    }

    function withdraw(uint256 _shares) external {
        uint256 amountToWithdraw = _shares * 1e18 / sharePrice;
        _burn(msg.sender, _shares);
        underlyingToken.transfer(msg.sender, amountToWithdraw);
    }

    function withdrawAll() external {
        uint256 sharesOwned = this.balanceOf(msg.sender);
        uint256 amountToWithdraw = sharesOwned / sharePrice;
        _burn(msg.sender, sharesOwned);
        underlyingToken.transfer(msg.sender, amountToWithdraw);
    }

    function increaseSharePrice(uint256 _newSharePrice) external {
        require(
            _newSharePrice > sharePrice,
            "New share price must be greater than current share price"
        );
        sharePrice = _newSharePrice;
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
}
