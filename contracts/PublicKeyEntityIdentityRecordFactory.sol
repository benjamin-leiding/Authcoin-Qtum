pragma solidity ^0.4.17;


import "./PublicKeyEntityIdentityRecord.sol";
import "./EntityIdentityRecord.sol";
import "./EntityIdentityRecordFactory.sol";


contract PublicKeyEntityIdentityRecordFactory is EntityIdentityRecordFactory {

    function create(
        int id,
        uint timestamp,
        bytes content,
        bool revoked,
        bytes32[] identifiers,
        bytes32 hash, bytes signature,
        address authCoinAddress) returns (EntityIdentityRecord)
    {
        return new PublicKeyEntityIdentityRecord(id, timestamp, content, revoked, identifiers, hash, signature, authCoinAddress);
    }

}
