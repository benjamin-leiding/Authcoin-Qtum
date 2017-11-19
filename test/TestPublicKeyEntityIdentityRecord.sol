pragma solidity ^0.4.0;


import "../contracts/PublicKeyEntityIdentityRecord.sol";
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";


contract TestPublicKeyEntityIdentityRecord {

    function testCreateNewPublicKeyEntityIdentityRecord() {
        var data = new bytes(42);
        var hash = bytes32(0x0);
        var signature = new  bytes(128);
        var identifiers = new bytes32[](2);
        identifiers[0] = bytes32("test");
        identifiers[1] = bytes32("test2");
        PublicKeyEntityIdentityRecord r = new PublicKeyEntityIdentityRecord(1, block.timestamp, data, false, identifiers, hash, signature, DeployedAddresses.AuthCoin());
        Assert.equal(r.getId(), 1, "EIR id must be '1'");
        Assert.equal(r.getTimestamp(), block.timestamp, "invalid block timestamp");
        // TODO Assert.equal(r.getContent().length, 42, "invalid EIR content");
        Assert.isFalse(r.isRevoked(), "EIR should not be revoked");
        Assert.equal(r.getIdentifier(0), bytes32("test"), "Invalid identifier");
        Assert.equal(r.getIdentifier(1), bytes32("test2"), "Invalid identifier");

        //TODO hash & signature
        Assert.equal(bytes32(r.getType()), bytes32("pub-key"), "EIR type should be 'pub-key'");
        Assert.equal(r.getOwner(), DeployedAddresses.AuthCoin(), "EIR contracts must be owned by AuthCon contract");
    }

}
