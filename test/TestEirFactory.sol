pragma solidity ^0.4.15;


import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AuthCoin.sol";
import "./helpers/DummyEirFactory.sol";
import "./helpers/ErrorProxy.sol";


contract TestEirFactory {

    function testRegisterNewEirFactory() public {
        AuthCoin ac = new AuthCoin();
        var success = ac.registerEirFactory(new DummyEirFactory(), "dummy");
        Assert.isTrue(success, "dummy EIR factory registration failed");
        Assert.equal(ac.getEirFactoryCount(), 2, "invalid number of factories created");
    }

    function testRegisterMultipleFactoriesWithSameType() public {
        AuthCoin ac = new AuthCoin();
        ac.registerEirFactory(new DummyEirFactory(), "dummy");

        ErrorProxy proxy = new ErrorProxy(address(ac));
        AuthCoin(address(proxy)).registerEirFactory(new DummyEirFactory(), "dummy");
        bool r = proxy.execute();
        Assert.isFalse(r, "registration did not fail");
    }

}
