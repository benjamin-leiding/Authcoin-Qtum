pragma solidity ^0.4.0;


import "../contracts/EntityIdentityRecord.sol";
import "../contracts/ValidationAuthenticationEntry.sol";
import "./helpers/DummyEir.sol";
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";


contract TestValidationAuthenticationEntry {

    EntityIdentityRecord eir1;
    EntityIdentityRecord eir2;

    function beforeAll() {
        eir1 = new DummyEir(1, block.timestamp, new bytes(42), false, new bytes32[](0), bytes32(0x0), new  bytes(128), DeployedAddresses.AuthCoin());
        eir2 = new DummyEir(1, block.timestamp, new bytes(42), false, new bytes32[](0), bytes32(0x0), new  bytes(128), DeployedAddresses.AuthCoin());
    }

    function testCreateNewValidationAuthenticationEntry() {
        ValidationAuthenticationEntry vae = new ValidationAuthenticationEntry(2, eir1, eir2, DeployedAddresses.AuthCoin());
        Assert.equal(vae.getVaeId(), 2, "VAE id should be 2");
        Assert.equal(vae.getVerifier(), address(eir1), "Invalid 'verifier' contract");
        Assert.equal(vae.getTarget(), address(eir2), "Invalid 'target' contract");
        Assert.equal(vae.getStatus(), 0, "Invalid status");
        Assert.equal(vae.getTimestamp(), block.timestamp, "Timestamp should be equal to block time");
        Assert.equal(vae.getOwner(), DeployedAddresses.AuthCoin(), "Invalid owner");
    }

}
