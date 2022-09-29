require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ganache");
// import "@nomicfoundation/hardhat-chai-matchers";
// import "@nomiclabs/hardhat-ganache";


module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    ganache: {
      // gasLimit: 6000000000,
      // defaultBalanceEther: 10,
      url: "http://172.17.144.1:7545",
    },
    hardhat: {
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 20,
        passphrase: "",
      },
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/22ef7861e96f47c3b8e771dd70cdf3a7",
      accounts: [
        "b14d58e03ec32a7884d68112cc9068eb015845d118801fce5ad0c65da7baeddc",
        "b95bdfa2db8570f06289f187b1d37cc085a7e2e14b08eb2ae7d2c388928534ba",
        "48a2dad7021294952ba5871e0e01fa9c08d12aa25ee7c9b40c958ab4e0c44216",
      ],
    },
  },
  solidity: {
    version: "0.8.1",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: {
    timeout: 40000,
  },
};
