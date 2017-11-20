pragma solidity ^0.4.15;


import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AuthCoin.sol";
import "../contracts/ChallengeRecord.sol";
import "../contracts/EntityIdentityRecord.sol";
import "./helpers/DummyEirFactory.sol";
import "./helpers/ErrorProxy.sol";
import "../contracts/signatures/RsaSignatureVerifier.sol";


contract TestChallengeResponseRecord {

    AuthCoin ac;
    EntityIdentityRecord verifier;
    EntityIdentityRecord target;

    function beforeAll() {
        ac = new AuthCoin();
        ac.registerEirFactory(new DummyEirFactory(), bytes32("dummy"));
        ac.registerSignatureVerifier(new RsaSignatureVerifier(), "dummy");
        ac.registerEir("dummy", 1, block.timestamp, new bytes(42), false, new bytes32[](0), bytes32(0x0), new bytes(128));
        ac.registerEir("dummy", 2, block.timestamp, new bytes(42), false, new bytes32[](0), bytes32(0x0), new bytes(128));
        verifier = ac.getEir(1);
        target = ac.getEir(2);
        var result = ac.registerChallengeRecord(1, 1, block.timestamp, bytes32("sign"), bytes32("description"), verifier.getId(), target.getId(), bytes32(0x0), new bytes(128));
        var targetResult = ac.registerChallengeRecord(2, 1, block.timestamp, bytes32("sign"), bytes32("description"), target.getId(), verifier.getId(), bytes32(0x0), new bytes(128));
    }

    function testRegisterChallengeResponseRecord() {
        var result = ac.registerChallengeResponse(1, 1, block.timestamp, bytes32(0x0), bytes32(0x0), new bytes(128));
        Assert.isTrue(result, "Challenge response record registration failed");
    }

    function testRegisterChallengeResponseRecord_UnknownVaeId() {
        var result = ac.registerChallengeRecord(3, 6, block.timestamp, bytes32("sign"), bytes32("description"), verifier.getId(), target.getId(), bytes32(0x0), new bytes(128));
        ErrorProxy proxy = new ErrorProxy(address(ac));
        AuthCoin(address(proxy)).registerChallengeResponse(6, 3, block.timestamp, bytes32(0x0), bytes32(0x0), new bytes(128));
        Assert.isFalse(proxy.execute(), "Should fail because incorrect VAE status");
    }

    function testRegisterChallengeResponseRecord_VaeIsInIncorrectStatus() {
        ErrorProxy proxy = new ErrorProxy(address(ac));
        AuthCoin(address(proxy)).registerChallengeResponse(10, 1, block.timestamp, bytes32(0x0), bytes32(0x0), new bytes(128));
        Assert.isFalse(proxy.execute(), "VAE shouldn't exist");
    }

    function testRegisterChallengeResponseRecord_UnknownChallengeId() {
        ErrorProxy proxy = new ErrorProxy(address(ac));
        AuthCoin(address(proxy)).registerChallengeResponse(1, 4, block.timestamp, bytes32(0x0), bytes32(0x0), new bytes(128));
        Assert.isFalse(proxy.execute(), "Challenge response record should be unknown");
    }

    function testRegisterChallengeResponseRecordMultipleTimes() {
        ac.registerEir("dummy", 20, block.timestamp, new bytes(42), false, new bytes32[](0), bytes32(0x0), new bytes(128));
        ac.registerEir("dummy", 21, block.timestamp, new bytes(42), false, new bytes32[](0), bytes32(0x0), new bytes(128));
        ac.registerChallengeRecord(20, 20, block.timestamp, bytes32("sign"), bytes32("description"), 20, 21, bytes32(0x0), new bytes(128));
        ac.registerChallengeRecord(21, 20, block.timestamp, bytes32("sign"), bytes32("description"), 21, 20, bytes32(0x0), new bytes(128));
        ac.registerChallengeResponse(20, 20, block.timestamp, bytes32(0x0), bytes32(0x0), new bytes(128));
        ErrorProxy proxy = new ErrorProxy(address(ac));
        AuthCoin(address(proxy)).registerChallengeResponse(20, 20, block.timestamp, bytes32(0x0), bytes32(0x0), new bytes(128));
        Assert.isFalse(proxy.execute(), "Challenge response record can not be registered multiple times");
    }

}
