pragma solidity ^0.4.15;


import "../../contracts/EntityIdentityRecordFactory.sol";
import "./DummyEir.sol";


contract DummyEirFactory is EntityIdentityRecordFactory {

    function create(int id, uint timestamp, bytes32 contentType, bytes content, bool revoked, bytes32[] identifiers, bytes32 hash, bytes signature, address authCoinAddress) returns (EntityIdentityRecord) {
        return new DummyEir(id, timestamp, contentType, content, revoked, identifiers, hash, signature, authCoinAddress);
    }

}
