pragma solidity ^0.4.15;


import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AuthCoin.sol";
import "../contracts/ChallengeRecord.sol";
import "../contracts/EntityIdentityRecord.sol";
import "./helpers/DummyEirFactory.sol";
import "./helpers/ErrorProxy.sol";


contract TestCreateChallengeRecord {

    AuthCoin ac;

    EntityIdentityRecord verifier;

    EntityIdentityRecord target;

    function beforeEachRegisterEirFactory() public {
        ac = new AuthCoin();
        ac.registerEirFactory(new DummyEirFactory(), bytes32("dummy"));
    }

    function beforeEachRegisterVerifier() public {
        ac.registerEir("dummy", 1, block.timestamp, "dummyContentType", new bytes(42), false, new bytes32[](0), bytes32(0x0), new  bytes(128));
    }

    function beforeEachRegisterTarget() public {
        ac.registerEir("dummy", 2, block.timestamp, "dummyContentType", new bytes(42), false, new bytes32[](0), bytes32(0x0), new  bytes(128));
    }

    function beforeEachGetVerifier() public {
        verifier = ac.getEir(1);
    }

    function beforeEachGetTarget() public {
        target = ac.getEir(2);
    }

    function testCreateChallengeRecord_EirDoesNotExist() public {
        ErrorProxy proxy = new ErrorProxy(address(ac));
        AuthCoin(address(proxy)).registerChallengeRecord(3, 2, block.timestamp, bytes32("sign"), bytes32("description"), 42, 43, bytes32(0x0), new bytes(128));
        Assert.isFalse(proxy.execute(), "error must be thrown if EIR doesn't exist");
    }

    function testCreateChallengeRecord_VerifierAndTargetAreEqual() public {
        ErrorProxy proxy = new ErrorProxy(address(ac));
        AuthCoin(address(proxy)).registerChallengeRecord(4, 3, block.timestamp, bytes32("sign"), bytes32("description"), verifier.getId(), verifier.getId(), bytes32(0x0), new bytes(128));
        Assert.isFalse(proxy.execute(), "verifier and target address can not be equal");
    }

}
