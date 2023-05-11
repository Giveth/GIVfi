// Import necessary libraries and contracts
const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("GIVfiWrappedBeefyV6Vault", function() {

  // Define variables to be used in test cases
  let beefyV6Mock;
  let givVault;
  let underlyingToken;
  let owner;
  let user;

  beforeEach(async function () {
   
    // Get the signers
    [owner, user] = await ethers.getSigners();

    // Deploy the mock BeefyVault contract
    const BeefyVault = await ethers.getContractFactory("BeefyV6Mock");
    beefyV6Mock = await BeefyVault.deploy();
    await beefyV6Mock.deployed();

    // Deploy the GIVfiWrappedBeefyV6Vault contract
    const GIVfiWrappedBeefyV6Vault = await ethers.getContractFactory("GIVfiWrappedBeefyV6Vault");
    givVault = await GIVfiWrappedBeefyV6Vault.deploy(beefyV6Mock.address);
    await givVault.deployed();

    // Deploy the mock underlying token contract
    const MockERC20 = await ethers.getContractFactory("MockERC20");
    underlyingToken = await MockERC20.deploy("Underlying Token", "UNDERLYING");
    await underlyingToken.deployed();

    // Transfer some underlying tokens to the user
    await underlyingToken.transfer(user.address, 1000);

    // Approve the GIVfiWrappedBeefyV6Vault contract to spend user's underlying tokens
    await underlyingToken.connect(user).approve(givVault.address, 1000);

  });

  
});