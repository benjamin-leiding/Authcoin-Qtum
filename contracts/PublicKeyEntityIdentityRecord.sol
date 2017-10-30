pragma solidity ^0.4.17;


import "./EntityIdentityRecord.sol";


// Entity Identity Record (EIR) contract that stores public keys.
contract PublicKeyEntityIdentityRecord is EntityIdentityRecord {

    address private owner;

    int private id;

    uint private timestamp;

    bytes private publicKey;

    bool private revoked;

    bytes32[] private identifiers;

    bytes32 private hash;

    bytes private signature;

    function PublicKeyEntityIdentityRecord(
        int _id,
        uint _timestamp,
        bytes _content,
        bool _revoked,
        bytes32[] _identifiers,
        bytes32 _hash,
        bytes _signature,
        address _authCoinAddress) {

        //TODO validate the key?
        id = _id;
        timestamp = _timestamp;
        publicKey = _content;
        revoked = _revoked;
        identifiers = _identifiers;
        hash = _hash;
        signature = _signature;
        owner = _authCoinAddress;
    }

    function getId() public returns (int) {
        return id;
    }

    function getTimestamp() public returns (uint) {
        return timestamp;
    }

    function getOwner() public returns (address) {
        return owner;
    }

    function getType() public returns (bytes32) {
        return bytes32("pub-key");
    }

    function getContent() public returns (bytes) {
        return publicKey;
    }

    function isRevoked() public returns (bool) {
        return revoked;
    }

    function getIdentifiersCount() public returns(uint) {
        return identifiers.length;
    }

    function getIdentifier(uint index) public returns (bytes32) {
        return identifiers[index];
    }

}
