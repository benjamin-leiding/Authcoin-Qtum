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

    function testRegisterNewEirFactory() {
        AuthCoin ac = new AuthCoin();
        var success = ac.registerEirFactory(new DummyEirFactory(), "dummy");
        Assert.isTrue(success, "dummy EIR factory registration failed");
        Assert.equal(ac.getEirFactoryCount(), 2, "invalid number of factories created");
    }

    function testRegisterMultipleFactoriesWithSameType() {
        AuthCoin ac = new AuthCoin();
        ac.registerEirFactory(new DummyEirFactory(), "dummy");

        ErrorProxy proxy = new ErrorProxy(address(ac));
        AuthCoin(address(proxy)).registerEirFactory(new DummyEirFactory(), "dummy");
        bool r = proxy.execute();
        Assert.isFalse(r, "registration did not fail");
    }

    function testRegisterDummyEir() {
        AuthCoin ac = new AuthCoin();
        ac.registerEirFactory(new DummyEirFactory(), "dummy");
        bytes memory input = new bytes(42);
        Assert.isTrue(ac.registerEir("dummy", input, "test"), "EIR registration failed");
        Assert.equal(ac.getEirCount(), 1, "Should be 1");
    }

    function testRegisterUnknownEir() {
        AuthCoin ac = new AuthCoin();
        ErrorProxy proxy = new ErrorProxy(address(ac));
        AuthCoin(address(proxy)).registerEir("dummy", new bytes(42), "test");
        bool r = proxy.execute();
        Assert.isFalse(r, "registration did not fail");
    }

    function testGetEir() {
        AuthCoin ac = new AuthCoin();
        ac.registerEirFactory(new DummyEirFactory(), "dummy");
        bytes memory input = new bytes(42);
        ac.registerEir("dummy", input, "test");

        address eir = ac.getEir("test");
        Assert.notEqual(eir, address(0), "Should not be zero address");
    }

    function testGetUnknownEir() {
        AuthCoin ac = new AuthCoin();
        address eir = ac.getEir(0x0);
        Assert.equal(eir, address(0), "Should be zero address");
    }


}
