pragma solidity ^0.4.15;


import "./EntityIdentityRecord.sol";


// EntityIdentityRecordFactory is an interface to support different types of
// entity identity records.
contract EntityIdentityRecordFactory {

    //  creates a new instance of EIR.
    function create(bytes data) returns (EntityIdentityRecord eir);

}
