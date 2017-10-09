pragma solidity ^0.4.15;


import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AuthCoin.sol";
import "./helpers/DummyEirFactory.sol";
import "./helpers/ErrorProxy.sol";


contract TestAuthCoinContract {

    function testCrateAuthCoinContract() {
        AuthCoin acc = AuthCoin(DeployedAddresses.AuthCoin());
        Assert.equal(acc.getEirFactoryCount(), 1, "");
        Assert.equal(acc.getEirCount(), 0, "Should be 1");
    }

    function testRegisterNewEirFactory() {
        AuthCoin acc = new AuthCoin();
        var success = acc.registerEirFactory(new DummyEirFactory(), "dummy");
        Assert.isTrue(success, "dummy EIR factory registration failed");
        Assert.equal(acc.getEirFactoryCount(), 2, "invalid number of factories created");
    }

    function testRegisterMultipleFactoriesWithSameType() {
        AuthCoin acc = new AuthCoin();
        acc.registerEirFactory(new DummyEirFactory(), "dummy");

        ErrorProxy proxy = new ErrorProxy(address(acc));
        AuthCoin(address(proxy)).registerEirFactory(new DummyEirFactory(), "dummy");
        bool r = proxy.execute();
        Assert.isFalse(r, "registration did not fail");
    }

    function testRegisterDummyEir() {
        AuthCoin acc = new AuthCoin();
        acc.registerEirFactory(new DummyEirFactory(), "dummy");
        bytes memory input = new bytes(42);
        Assert.isTrue(acc.registerEir("dummy", input, "test"), "EIR registration failed");
        Assert.equal(acc.getEirCount(), 1, "Should be 1");
    }

    function testRegisterUnknownEir() {
        AuthCoin acc = new AuthCoin();
        ErrorProxy proxy = new ErrorProxy(address(acc));
        AuthCoin(address(proxy)).registerEir("dummy", new bytes(42), "test");
        bool r = proxy.execute();
        Assert.isFalse(r, "registration did not fail");
    }

}
