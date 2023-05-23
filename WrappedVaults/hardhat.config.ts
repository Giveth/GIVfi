import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";
// import "@nomiclabs/hardhat-waffle";
import "@openzeppelin/hardhat-upgrades";
import "@nomiclabs/hardhat-etherscan";

import dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY || "",
  },
  networks: {
    goerli: {
      url: process.env.GOERLI_RPC || "http://localhost:8545",
      accounts: [process.env.DEPLOYER_KEY || ""],
    },
    goerliOptimism: {
      url: process.env.GOERLI_O_RPC || "http://localhost:8545",
      accounts: [process.env.DEPLOYER_KEY || ""],
    },
  },
};

export default config;
