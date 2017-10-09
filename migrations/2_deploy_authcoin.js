var AuthCoinContract = artifacts.require("./AuthCoin.sol");

module.exports = function(deployer) {
  deployer.deploy([AuthCoinContract]);
};
