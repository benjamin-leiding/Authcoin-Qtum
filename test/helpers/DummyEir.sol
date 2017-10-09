pragma solidity ^0.4.15;


import "../../contracts/EntityIdentityRecord.sol";


contract DummyEir is EntityIdentityRecord {

    bytes private dummyData;

    function DummyEir(bytes data) {
        dummyData = data;
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

    function getData() public returns (bytes) {
        return new bytes(32);
    }

    function getId() public returns (int) {
        return 1;
    }

}
