// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20Upgradeable as ERC20} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MockERC20 is Initializable, ERC20 {
    constructor(string memory _name, string memory _symbol) {
        _init(_name, _symbol);
        _mint(msg.sender, 1_000_000 * 1e18);
    }

    function _init(string memory _name, string memory _symbol) internal initializer {
        __ERC20_init(_name, _symbol);
    }
}
