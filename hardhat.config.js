require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
const { mnemonic, privateKey, apiKey, infuraKey } = require("./secrets.json");

const accounts = !!privateKey ? [`0x${privateKey}`] : undefined
// const accounts = { mnemonic: mnemonic },

module.exports = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        // TODO: Set 100 or 200, check contract size
        runs: 10,
      },
    },
  },
  networks: {
    mainnet: {
      url: "https://mainnet.infura.io/v3/" + infuraKey,
      gas: 10000000,
      
      accounts,
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/" + infuraKey,
      gas: 10000000,
      accounts,
    },
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      gas: 10000000,
      accounts,
    },
    bscmain: {
      url: "https://bsc-dataseed.binance.org/",
      gas: 10000000,
      accounts,
    },
  },
  etherscan: {
    apiKey,
    // apiKey: apiKeyBSC,
  },
};
