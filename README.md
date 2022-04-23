# Nova Topia NFT Auction Contract

This contract based on Hardhat builder.

## 1. Unit testing method

Run the following command in terminal <br/>
`npx hardhat node` <br/>
Open the new tab in termianl and run the following command <br/>
`npx hardhat test` <br/>

## 2. Deploy method

Copy secrets-sample.json and rename secrets.json and fill out the items.<br/>
privateKey, apiKey, infuraKey, receiverWallet<br/>

Run the following command. <br/>
`npx hardhat run scripts/deploy-NTC.js`

For the testnet, add `--network rinkeby`
