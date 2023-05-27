import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  BeefyV6Mock,
  ERC20Mock,
  GIVfiWrappedBeefyV6VaultUpgradeable,
} from "../typechain-types";

// Import necessary libraries and contracts
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GIVfiWrappedBeefyV6Vault", function () {
  const fee = 1e17.toString();
  // Define variables to be used in test cases
  let beefyV6Mock: BeefyV6Mock;
  let givVault: GIVfiWrappedBeefyV6VaultUpgradeable;
  let underlyingToken: ERC20Mock;
  let owner: SignerWithAddress;
  let user: SignerWithAddress;
  let user2: SignerWithAddress;
  let feeReceipient: SignerWithAddress;

  beforeEach(async function () {
    // Get the signers
    [owner, user, user2, feeReceipient] = await ethers.getSigners();

    // Deploy the mock underlying token contract
    const MockERC20 = await ethers.getContractFactory("ERC20Mock");
    underlyingToken = await MockERC20.deploy("Underlying Token", "UNDERLYING");
    await underlyingToken.deployed();

    // Transfer some underlying tokens to the user
    await underlyingToken.transfer(user.address, 1e18.toString());
    await underlyingToken.transfer(user2.address, 1e18.toString());

    // Deploy the mock BeefyVault contract
    const BeefyVault = await ethers.getContractFactory("BeefyV6Mock");
    beefyV6Mock = await BeefyVault.deploy(underlyingToken.address);
    await beefyV6Mock.deployed();

    // Deploy the GIVfiWrappedBeefyV6Vault contract
    const GIVfiWrappedBeefyV6Vault = await ethers.getContractFactory(
      "GIVfiWrappedBeefyV6VaultUpgradeable",
    );
    givVault = await GIVfiWrappedBeefyV6Vault.deploy();
    await givVault.deployed();

    await givVault.initialize(
      beefyV6Mock.address,
      underlyingToken.address,
      "GIVfiWrappedBeefyV6Vault",
      "GIVBEEF",
      owner.address,
      owner.address,
      fee, //10% fee
      feeReceipient.address,
    );

    // Approve the GIVfiWrappedBeefyV6Vault contract to spend user's underlying tokens
    await underlyingToken
      .connect(user)
      .approve(givVault.address, (100e18).toString());
  });

  it("should initialize the contract correctly", async function () {
    // Check the vault's name
    expect(await givVault.name()).to.equal("GIVfiWrappedBeefyV6Vault");
    // Check the vault's symbol
    expect(await givVault.symbol()).to.equal("GIVBEEF");
    // Check the vault's underlying token
    expect(await givVault.token()).to.equal(underlyingToken.address);
    // Check the vault's fee
    expect(await givVault.fee()).to.equal(fee);
    // Check the vault's fee receipient
    expect(await givVault.feeRecipient()).to.equal(feeReceipient.address);
  });

  it("should not be able to initialize the contract twice", async function () {
    // Try to initialize the contract again
    await expect(
      givVault.initialize(
        beefyV6Mock.address,
        underlyingToken.address,
        "GIVfiWrappedBeefyV6Vault",
        "GIVBEEF",
        owner.address,
        owner.address,
        fee, //10% fee
        feeReceipient.address,
      ),
    ).to.be.revertedWith("Initializable: contract is already initialized");
  });

  it("should set the fee", async function () {
    // Set a new fee
    await givVault.setFee(5e17.toString()); // 5% fee represented as a BigNumber

    // Check the updated fee
    expect(await givVault.fee()).to.equal(5e17.toString());
  });

  it("should not be able to set a fee greater than 100%", async function () {
    // Try to set a fee greater than 100%
    await expect(
      givVault.setFee(2e18.toString()),
    ).to.be.revertedWith(
      "Fee cannot be greater than 100%",
    );
  });

  it("should not be able to set a fee when the caller is not the owner", async function () {
    // Try to set a fee when the caller is not the owner
    await expect(
      givVault.connect(user).setFee(5e17.toString()), // 5% fee represented as a BigNumber
    ).to.be.revertedWith("Sender not owner");
  });

  it("should set the fee recipient", async function () {
    // Set a new fee recipient
    const newFeeRecipient = await ethers.getSigner();
    await givVault.setFeeRecipient(newFeeRecipient.address);

    // Check the updated fee recipient
    expect(await givVault.feeRecipient()).to.equal(newFeeRecipient.address);
  });

  it("should not be able to set a fee recipient when the caller is not the owner", async function () {
    // Try to set a fee recipient when the caller is not the owner
    await expect(
      givVault.connect(user).setFeeRecipient(user.address),
    ).to.be.revertedWith("Sender not owner");
  });

  it("should receive vault shares when depositing underlying tokens", async function () {
    // Deposit 100 underlying tokens to the vault
    await givVault.connect(user).deposit(user.address, 1e18.toString());

    // Check the user's vault shares balance
    expect(await givVault.balanceOf(user.address)).to.equal((1e18).toString());
  });

  it("should deduct no fee when withdrawing underlying tokens and no interest accrued", async function () {
    // Deposit 100 underlying tokens to the vault
    await givVault.connect(user).deposit(user.address, (1e18).toString());

    // Withdraw 100 underlying tokens from the vault
    await givVault
      .connect(user)
      .withdraw(user.address, (1e18).toString(), (1e18).toString());

    // Check the user's underlying token balance
    expect(await underlyingToken.balanceOf(user.address)).to.equal(
      (1e18).toString(),
    );
  });

  it("should deduct the fee when withdrawing underlying tokens and interest accrued", async function () {
    // Deposit 100 underlying tokens to the vault
    await givVault.connect(user).deposit(user.address, (1e18).toString());

    // Increase the underlying token balance of the vault
    // 1.2x increase in share price
    await beefyV6Mock.increaseSharePrice(12e17.toString());
    await underlyingToken.transfer(beefyV6Mock.address, 2e17.toString());

    // Withdraw 100% underlying tokens from the vault
    //  destination, shares, minUnderlying
    // 1 share = 1.2 underlying token (1.2x increase in share price)
    // fee = 10% of 0.2 underlying token = 0.02 underlying token
    // 1.2 - 0.02 = 1.18 underlying token
    // 1e18 shares = 1.18e18 underlying token
    await givVault.connect(user).withdraw(user.address, 1e18.toString(), 1.18e18.toString());

    // Check the user's underlying token balance
    expect(await underlyingToken.balanceOf(user.address)).to.equal(1.18e18.toString());

    // Check the fee receipient's givVault balance
    // fee: 0.02 eth in wei = 2e16
    // expect balanceOfUnderlying to be gte 1.99e16 and lte 2e16
    // (calculation/rounding errors)
    expect(await givVault.balanceOfUnderlying(feeReceipient.address)).to.be.gte(1.99e16.toString());
    expect(await givVault.balanceOfUnderlying(feeReceipient.address)).to.lte(2e16.toString());
  });
});
