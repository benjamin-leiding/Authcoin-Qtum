pragma solidity ^0.4.15;


import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AuthCoin.sol";
import "./helpers/DummyEirFactory.sol";
import "./helpers/ErrorProxy.sol";


contract TestAuthCoinContract {

    function testCrateAuthCoinContract() {
        AuthCoin ac = AuthCoin(DeployedAddresses.AuthCoin());
        Assert.equal(ac.getEirFactoryCount(), 1, "");
        Assert.equal(ac.getEirCount(), 0, "Should be 0");
    }

}
