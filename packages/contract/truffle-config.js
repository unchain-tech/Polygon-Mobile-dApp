const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();
const fs = require('fs');
const mnemonic = fs.readFileSync('.secret').toString().trim();

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 9545,
      network_id: '*',
    },
    matic: {
      provider: () =>
        new HDWalletProvider({
          mnemonic: {
            phrase: mnemonic,
          },
          providerOrUrl: process.env.POLYGON_URL,
          chainId: 80001,
        }),
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
      chainId: 80001,
    },
    sepolia: {
      provider: () =>
        new HDWalletProvider(
          process.env.PRIVATE_KEY,
          process.env.INFURA_API_URL,
        ),
      network_id: 11155111,
      timeoutBlocks: 200000,
      skipDryRun: true,
      chainId: 11155111,
    },
  },
  contracts_directory: './contracts',
  compilers: {
    solc: {
      version: '0.8.17',
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  db: {
    enabled: false,
  },
  mocha: {
    enableTimeouts: false,
    before_timeout: 120000,
  },
};
