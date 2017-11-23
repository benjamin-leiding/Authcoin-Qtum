var AuthCoinContract = artifacts.require("./AuthCoin.sol");
var BytesUtils = artifacts.require("./utils/BytesUtils.sol");

module.exports = function(deployer) {
  deployer.deploy([BytesUtils]);
  deployer.link(BytesUtils, AuthCoinContract);
  deployer.deploy([AuthCoinContract]);
};
