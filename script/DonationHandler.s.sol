// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "./Config.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "../src/DonationHandler/DonationHandler.sol";

contract DeployDonationHandler is Script, Config {
    function run() external {
        Config config = new Config();

        vm.startBroadcast();

        ProxyAdmin proxyAdmin = new ProxyAdmin();
        DonationHandler donationHandler = new DonationHandler();

        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(donationHandler),
            address(proxyAdmin),
            ""
        );

        DonationHandler(address(proxy)).initialize(
            config.getAcceptedTokens(), config.getDonationRecipients(), config.getFeeReceivers(), config.getAdmins()
        );

        vm.stopBroadcast();

        console.log("deployer: ", msg.sender);
        console.log("proxyAdmin: ", address(proxyAdmin));
        console.log("donationHandler: ", address(donationHandler));
        console.log("proxy: ", address(proxy));
    }
}
