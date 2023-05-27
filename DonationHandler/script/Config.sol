// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Config {
    struct NetworkConfig {
        address[] acceptedToken;
        address[] donationRecipient;
        address[] feeReceiver;
        address[] admins;
    }

    NetworkConfig private activeNetworkConfig;
    mapping(uint256 => NetworkConfig) private chainIdToNetworkConfig;

    constructor() {
        // add new network here
        chainIdToNetworkConfig[5] = getGoerliEthConfig();
        chainIdToNetworkConfig[31337] = getLocalEthConfig();
        chainIdToNetworkConfig[100] = getGnosisEthConfig();

        activeNetworkConfig = chainIdToNetworkConfig[block.chainid];
    }

    // ================== Local/Test Config ==================

    function getLocalEthConfig() internal pure returns (NetworkConfig memory localConfig) {
        address[] memory acceptedTokens = new address[](1);
        address[] memory donationRecipients = new address[](1);
        address[] memory feeReceivers = new address[](1);
        address[] memory admins = new address[](1);

        acceptedTokens[0] = address(1);
        donationRecipients[0] = address(1);
        feeReceivers[0] = address(1);
        admins[0] = address(1);

        return getConfig(acceptedTokens, donationRecipients, feeReceivers, admins);
    }

    // ================== Gnosis Config ==================

    function getGnosisEthConfig() internal pure returns (NetworkConfig memory goerliConfig) {
        address[] memory acceptedTokens = new address[](1);
        address[] memory donationRecipients = new address[](1);
        address[] memory feeReceivers = new address[](1);
        address[] memory admins = new address[](1);

        acceptedTokens[0] = address(1);
        donationRecipients[0] = address(1);
        feeReceivers[0] = address(1);
        admins[0] = address(1);

        return getConfig(acceptedTokens, donationRecipients, feeReceivers, admins);
    }

    // ================== Goerli Config ==================

    function getGoerliEthConfig() internal pure returns (NetworkConfig memory goerliConfig) {
        address[] memory acceptedTokens = new address[](1);
        address[] memory donationRecipients = new address[](1);
        address[] memory feeReceivers = new address[](1);
        address[] memory admins = new address[](1);

        acceptedTokens[0] = address(1);
        donationRecipients[0] = address(1);
        feeReceivers[0] = address(1);
        admins[0] = address(1);

        return getConfig(acceptedTokens, donationRecipients, feeReceivers, admins);
    }

    // ================== Helper ==================

    function getActiveNetworkConfig() public view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }

    function getConfig(
        address[] memory _acceptedToken,
        address[] memory _donationRecipient,
        address[] memory _feeReceiver,
        address[] memory _admins
    ) internal pure returns (NetworkConfig memory) {
        uint256 tLength = _acceptedToken.length;
        uint256 dLength = _donationRecipient.length;
        uint256 fLength = _feeReceiver.length;
        uint256 aLength = _admins.length;

        NetworkConfig memory c = NetworkConfig({
            acceptedToken: new address[](tLength),
            donationRecipient: new address[](dLength),
            feeReceiver: new address[](fLength),
            admins: new address[](aLength)
        });

        for (uint256 i = 0; i < tLength; i++) {
            c.acceptedToken[i] = _acceptedToken[i];
        }

        for (uint256 i = 0; i < dLength; i++) {
            c.donationRecipient[i] = _donationRecipient[i];
        }

        for (uint256 i = 0; i < fLength; i++) {
            c.feeReceiver[i] = _feeReceiver[i];
        }

        for (uint256 i = 0; i < aLength; i++) {
            c.admins[i] = _admins[i];
        }

        return c;
    }

    function getAcceptedTokens() public view returns (address[] memory) {
        return activeNetworkConfig.acceptedToken;
    }

    function getDonationRecipients() public view returns (address[] memory) {
        return activeNetworkConfig.donationRecipient;
    }

    function getFeeReceivers() public view returns (address[] memory) {
        return activeNetworkConfig.feeReceiver;
    }

    function getAdmins() public view returns (address[] memory) {
        return activeNetworkConfig.admins;
    }
}
