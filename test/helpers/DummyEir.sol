pragma solidity ^0.4.15;


import "../../contracts/EntityIdentityRecord.sol";


contract DummyEir is EntityIdentityRecord {

    bytes private dummyData;
    bytes32 private contentType;
    int private id;
    bool private revoked;

    function DummyEir(int _id, uint timestamp, bytes32 _contentType, bytes content, bool revoked, bytes32[] identifiers, bytes32 hash, bytes signature, address authCoinAddress) {
        id = _id;
        contentType = _contentType;
    }

    function getTimestamp() public returns (uint) {
        return 1;
    }

    function isRevoked() public returns (bool) {
        return revoked;
    }

    function getOwner() public returns (address) {
        return address(0);
    }

    function getType() public returns (bytes32) {
        return bytes32("dummy");
    }

    function getContentType() public returns (bytes32) {
        return contentType;
    }

    function getContent() public returns (bytes) {
        return new bytes(32);
    }

    function getId() public returns (int) {
        return id;
    }

    function getIdentifiersCount() public returns (uint) {
        return 0;
    }

    function getIdentifier(uint index) public returns (bytes32) {
        return bytes32(0);
    }

    function setRevoked(bool isRevoked) public {
        revoked = isRevoked;
    }
}
