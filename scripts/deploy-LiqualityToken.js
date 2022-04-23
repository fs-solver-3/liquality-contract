const { ethers, upgrades } = require("hardhat");
const { receiverWallet } = require("./secrets.json");
async function main() {
  const LiqualityTokenInstance = await ethers.getContractFactory("LiqualityToken");
  const LiqualityTokenContract = await LiqualityTokenInstance.deploy();
  console.log("Liquality Token Contract is deployed to:", LiqualityTokenContract.address);
}

main();
