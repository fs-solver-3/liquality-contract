const { ethers, upgrades } = require("hardhat");
async function main() {
  const LiqualityInstance = await ethers.getContractFactory("Liquality");
  const LiqualityContract = await LiqualityInstance.deploy();
  console.log("Liquality Contract is deployed to:", LiqualityContract.address);
}

main();
