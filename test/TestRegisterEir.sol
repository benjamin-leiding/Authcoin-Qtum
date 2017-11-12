pragma solidity ^0.4.15;


import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AuthCoin.sol";
import "./helpers/DummyEirFactory.sol";
import "./helpers/ErrorProxy.sol";


contract TestRegisterEir {

    function testRegisterDummyEir() public {
        AuthCoin ac = new AuthCoin();
        ac.registerEirFactory(new DummyEirFactory(), "dummy");
        bytes memory input = new bytes(42);
        var hash = bytes32(0x0);
        var signature = new  bytes(128);
        var identifiers = new bytes32[](0);

        Assert.isTrue(ac.registerEir("dummy", 1, block.timestamp, "dummyContentType", input, false, identifiers, hash, signature), "EIR registration failed");
        Assert.equal(ac.getEirCount(), 1, "Should be 1");

        address eir = ac.getEir(1);
        Assert.notEqual(eir, address(0), "Should not be zero address");
    }

    function testRegisterUnknownEir() public {
        AuthCoin ac = new AuthCoin();
        ErrorProxy proxy = new ErrorProxy(address(ac));
        bytes memory input = new bytes(42);
        var identifiers = new bytes32[](0);

        AuthCoin(address(proxy)).registerEir("dummy-2", 1, block.timestamp, "dummyContentType", input, false, identifiers, bytes32(0x0), new  bytes(128));
        bool r = proxy.execute();
        Assert.isFalse(r, "registration did not fail");
    }

    function testGetUnknownEir() public {
        AuthCoin ac = new AuthCoin();
        address eir = ac.getEir(0);
        Assert.equal(eir, address(0), "Should be zero address");
    }

}
