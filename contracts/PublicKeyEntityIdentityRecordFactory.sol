pragma solidity ^0.4.15;


import "./PublicKeyEntityIdentityRecord.sol";
import "./EntityIdentityRecord.sol";
import "./EntityIdentityRecordFactory.sol";


contract PublicKeyEntityIdentityRecordFactory is EntityIdentityRecordFactory {

    function create(bytes data) returns (EntityIdentityRecord eir) {
        return new PublicKeyEntityIdentityRecord(data);
    }
}
