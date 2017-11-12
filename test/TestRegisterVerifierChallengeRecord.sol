pragma solidity ^0.4.15;


import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AuthCoin.sol";
import "../contracts/ChallengeRecord.sol";
import "../contracts/EntityIdentityRecord.sol";
import "./helpers/DummyEirFactory.sol";
import "./helpers/ErrorProxy.sol";


contract TestRegisterVerifierChallengeRecord {

    AuthCoin ac;

    EntityIdentityRecord verifier;

    EntityIdentityRecord target;

    function beforeEachRegisterEirFactory() {
        ac = new AuthCoin();
        ac.registerEirFactory(new DummyEirFactory(), bytes32("dummy"));
    }

    function beforeEachRegisterVerifier() {
        ac.registerEir("dummy", 1, block.timestamp, "dummyContentType", new bytes(42), false, new bytes32[](0), bytes32(0x0), new  bytes(128));
    }

    function beforeEachRegisterTarget() {
        ac.registerEir("dummy", 2, block.timestamp, "dummyContentType", new bytes(42), false, new bytes32[](0), bytes32(0x0), new  bytes(128));
    }

    function beforeEachGetVerifier() {
        verifier = ac.getEir(1);
    }

    function beforeEachGetTarget() {
        target = ac.getEir(2);
    }

    function testRegisterVerifierChallengeRecord() {
        var result = ac.registerChallengeRecord(1, 1, block.timestamp, bytes32("sign"), bytes32("description"), verifier.getId(), target.getId(), bytes32(0x0), new bytes(128));
        Assert.isTrue(result, "CR registration failed");
        Assert.equal(ac.getVAECount(), 1, "Should be first VAE");
    }

    function testRegisterVerifierAndTargetChallengeRecords() {
        var verifierResult = ac.registerChallengeRecord(1, 1, block.timestamp, bytes32("sign"), bytes32("description"), verifier.getId(), target.getId(), bytes32(0x0), new bytes(128));
        var targetResult = ac.registerChallengeRecord(2, 1, block.timestamp, bytes32("sign"), bytes32("description"), target.getId(), verifier.getId(), bytes32(0x0), new bytes(128));
        Assert.isTrue(verifierResult, "verifier CR registration failed");
        Assert.isTrue(targetResult, "target CR registration failed");
        Assert.equal(ac.getVAECount(), 1, "Should be first VAE");
    }

}
