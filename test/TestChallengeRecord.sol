pragma solidity ^0.4.15;


import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AuthCoin.sol";
import "../contracts/ChallengeRecord.sol";
import "../contracts/EntityIdentityRecord.sol";
import "./helpers/DummyEirFactory.sol";
import "./helpers/ErrorProxy.sol";


contract TestChallengeRecord {

    AuthCoin ac;
    EntityIdentityRecord verifier;
    EntityIdentityRecord target;

    function beforeEachCreateAuthCoinContract() {
        ac = new AuthCoin();
        ac.registerEirFactory(new DummyEirFactory(), bytes32("dummy"));
    }

    function beforeEachRegisterVerifierEIR() {
        ac.registerEir("dummy", 1, block.timestamp, new bytes(42), false, new bytes32[](0), bytes32(0x0), new  bytes(0));
        verifier = ac.getEir(1);
    }

    function beforeEachRegisterTargetEIR() {
        ac.registerEir("dummy", 2, block.timestamp, new bytes(42), false, new bytes32[](0), bytes32(0x0), new  bytes(0));
        target = ac.getEir(2);
    }

    function testRegisterVerifierChallengeRecord() {
        var result = ac.registerChallengeRecord(1, 10, block.timestamp, bytes32("sign"), bytes32("description"), verifier.getId(), target.getId(), bytes32(0x0), new bytes(0));
        Assert.isTrue(result, "CR registration failed");
        Assert.equal(ac.getVAECount(), 1, "Should be first VAE");
    }

    function testRegisterVerifierAndTargetChallengeRecords() {
        var verifierResult = ac.registerChallengeRecord(1, 1, block.timestamp, bytes32("sign"), bytes32("description"), verifier.getId(), target.getId(), bytes32(0x0), new bytes(0));
        var targetResult = ac.registerChallengeRecord(2, 1, block.timestamp, bytes32("sign"), bytes32("description"), target.getId(), verifier.getId(), bytes32(0x0), new bytes(0));
        Assert.isTrue(verifierResult, "verifier CR registration failed");
        Assert.isTrue(targetResult, "target CR registration failed");
        Assert.equal(ac.getVAECount(), 1, "Should be first VAE");
    }

    function testCreateChallengeRecord_EirDoesNotExist() {
        ErrorProxy proxy = new ErrorProxy(address(ac));
        AuthCoin(address(proxy)).registerChallengeRecord(3, 2, block.timestamp, bytes32("sign"), bytes32("description"), 42, 43, bytes32(0x0), new bytes(0));
        Assert.isFalse(proxy.execute(), "error must be thrown if EIR doesn't exist");
    }

    function testCreateChallengeRecord_VerifierAndTargetAreEqual() {
        ErrorProxy proxy = new ErrorProxy(address(ac));
        AuthCoin(address(proxy)).registerChallengeRecord(4, 3, block.timestamp, bytes32("sign"), bytes32("description"), verifier.getId(), verifier.getId(), bytes32(0x0), new bytes(0));
        Assert.isFalse(proxy.execute(), "verifier and target address can not be equal");
    }

}
