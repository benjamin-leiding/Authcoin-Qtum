pragma solidity ^0.4.15;


import "./EntityIdentityRecord.sol";


// EntityIdentityRecordFactory is an interface to support different types of
// entity identity records.
contract EntityIdentityRecordFactory {

    // Creates a new instance of EIR.
    function create(
        int id,
        uint timestamp,
        bytes content,
        bool revoked,
        bytes32[] identifiers,
        bytes32 hash,
        bytes signature,
        address authCoinAddress) returns (EntityIdentityRecord);

}
