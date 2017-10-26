pragma solidity ^0.4.15;


import "../../contracts/EntityIdentityRecord.sol";


contract DummyEir is EntityIdentityRecord {

    bytes private dummyData;

    int private id;

    function DummyEir(int _id, uint timestamp, bytes content, bool revoked, bytes32[] identifiers, bytes32 hash, bytes signature, address authCoinAddress) {
        id = _id;
    }

    function getTimestamp() public returns (uint) {
        return 1;
    }

    function isRevoked() public returns (bool) {
        return false;
    }

    function getOwner() public returns (address) {
        return address(0);
    }

    function getType() public returns (bytes32) {
        return bytes32("dummy");
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

}
