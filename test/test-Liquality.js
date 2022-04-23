const {
  constants,
  expectEvent,
  expectRevert,
  time,
} = require("@openzeppelin/test-helpers");
const { ZERO_ADDRESS } = constants;
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers");
const provider = ethers.getDefaultProvider("http://127.0.0.1:8545/");

let LiqualityInstance;
let LiqualityContract;
let owner;
let account1, account2;
let startTime;
const splitAmountETH = "1";
const splitAmountToken = "1";
const streamingTimeETH = 60 * 60;
const streamingTimeToken = 60 * 60;
let maxAmountOfMint = 10000;
let currentAuctionSituation;
let totalAuctionBalance = 0;

describe("Liquality", function () {
  beforeEach(async function () {
    [owner, account1, account2] = await ethers.getSigners();

    LiqualityInstance = await ethers.getContractFactory("Liquality");
    LiqualityContract = await LiqualityInstance.deploy();
    await LiqualityContract.deployed();

    LiqualityTokenInstance = await ethers.getContractFactory("LiqualityToken");
    LiqualityTokenContract = await LiqualityTokenInstance.deploy();
    await LiqualityTokenContract.deployed();
  });
  describe("Split ETH", function () {
    it("Check if contract has the split ETH enough", async function () {
      const signer = provider.getSigner();
      await signer.sendTransaction({
        to: LiqualityContract.address,
        value: ethers.utils.parseEther("1.0"),
      });
      ownerBalance = await provider.getBalance(owner.address);
      console.log("ownerBalance", ownerBalance);
      contractBalance = await provider.getBalance(LiqualityContract.address);
      console.log("contractBalance", contractBalance);
    });
    it("Start the split of ETH", async function () {
      await LiqualityContract.startSplitETH(
        ethers.utils.parseEther(splitAmountETH),
        [account1.address, account2.address],
        [300, 700],
        streamingTimeETH
      );
      expect(await LiqualityContract.getSplitETHStatus()).to.be.equal(true);
    });
    it("Revert if user requests the claim under the split ETH has not start", async function () {
      await expectRevert(
        LiqualityContract.connect(account1).claimETH(),
        "The split has not started!"
      );
    });
    it("Check user claim ETH", async function () {
      await LiqualityContract.startSplitETH(
        ethers.utils.parseEther(splitAmountETH),
        [account1.address, account2.address],
        [300, 700],
        streamingTimeETH
      );
      expect(await LiqualityContract.getSplitETHStatus()).to.be.equal(true);
      expect(
        await LiqualityContract.connect(account1).getsplitAmountETH()
      ).to.be.equal(ethers.utils.parseEther(splitAmountETH));
      expect(
        await LiqualityContract.connect(account1).getSplitETHOfAccount()
      ).to.be.equal(ethers.utils.parseEther(splitAmountETH).mul(300).div(1000));
      expect(
        await LiqualityContract.connect(account2).getSplitETHOfAccount()
      ).to.be.equal(ethers.utils.parseEther(splitAmountETH).mul(700).div(1000));

      // Assume that the Split ETH is 15 minutes old.
      startTime = Math.round(new Date() / 1000) - 15 * 60;
      await LiqualityContract.setStartTimeETH(startTime);

      await LiqualityContract.connect(account1).claimETH();
      expect(
        await LiqualityContract.connect(account1).getWithdrawnETHOfAccount()
      ).to.be.within(
        ethers.utils
          .parseEther(splitAmountETH)
          .mul(300)
          .div(1000)
          .mul(15)
          .div(60),
        ethers.utils
          .parseEther(splitAmountETH)
          .mul(300)
          .div(1000)
          .mul(16)
          .div(60)
      );
    });
  });
  describe("Split Token", function () {
    it("Check if contract has the split Token enough", async function () {
      await LiqualityTokenContract.mint(
        LiqualityContract.address,
        ethers.utils.parseEther("1.0")
      );
      ownerBalance = await LiqualityTokenContract.balanceOf(owner.address);
      console.log("ownerBalance", ownerBalance);
      contractBalance = await LiqualityTokenContract.balanceOf(
        LiqualityContract.address
      );
      console.log("contractBalance", contractBalance);
    });
    it("Start the split of Token", async function () {
      await LiqualityContract.startSplitToken(
        LiqualityTokenContract.address,
        ethers.utils.parseEther(splitAmountToken),
        [account1.address, account2.address],
        [300, 700],
        streamingTimeToken
      );
      expect(await LiqualityContract.getSplitTokenStatus()).to.be.equal(true);
      expect(await LiqualityContract.getSplitTokenContract()).to.be.equal(
        LiqualityTokenContract.address
      );
    });
    it("Revert if user requests the claim under the split Token has not start", async function () {
      await expectRevert(
        LiqualityContract.connect(account1).claimToken(),
        "The split has not started!"
      );
    });
    it("Check user claim ETH", async function () {
      await LiqualityTokenContract.mint(
        LiqualityContract.address,
        ethers.utils.parseEther("1.0")
      );
      await LiqualityContract.startSplitToken(
        LiqualityTokenContract.address,
        ethers.utils.parseEther(splitAmountToken),
        [account1.address, account2.address],
        [300, 700],
        streamingTimeToken
      );
      expect(await LiqualityContract.getSplitTokenStatus()).to.be.equal(true);
      expect(
        await LiqualityContract.connect(account1).getsplitAmountToken()
      ).to.be.equal(ethers.utils.parseEther(splitAmountToken));
      expect(
        await LiqualityContract.connect(account1).getSplitTokenOfAccount()
      ).to.be.equal(
        ethers.utils.parseEther(splitAmountToken).mul(300).div(1000)
      );
      expect(
        await LiqualityContract.connect(account2).getSplitTokenOfAccount()
      ).to.be.equal(
        ethers.utils.parseEther(splitAmountToken).mul(700).div(1000)
      );

      // Assume that the Split ETH is 15 minutes old.
      startTime = Math.round(new Date() / 1000) - 15 * 60;
      await LiqualityContract.setStartTimeToken(startTime);

      await LiqualityContract.connect(account1).claimToken();
      expect(
        await LiqualityContract.connect(account1).getWithdrawnTokenOfAccount()
      ).to.be.within(
        ethers.utils
          .parseEther(splitAmountToken)
          .mul(300)
          .div(1000)
          .mul(15)
          .div(60),
        ethers.utils
          .parseEther(splitAmountToken)
          .mul(300)
          .div(1000)
          .mul(16)
          .div(60)
      );
    });
  });
});
