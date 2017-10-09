pragma solidity ^0.4.0;


import "../contracts/PublicKeyEntityIdentityRecord.sol";
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";


contract TestPublicKeyEntityIdentityRecord {

    function testCreateNewPublicKeyEntityIdentityRecord() {
        var data = new bytes(42);
        PublicKeyEntityIdentityRecord r = new PublicKeyEntityIdentityRecord(data);
        Assert.notEqual(r.getOwner(), address(0), "invalid owner");
        Assert.equal(r.getTimestamp(), block.timestamp, "invalid block timestamp");
        Assert.isFalse(r.isRevoked(), "should not be revoked");
        Assert.equal(bytes32(r.getType()), bytes32("pub-key"), "invalid EIR type");
    }
}
