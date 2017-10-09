pragma solidity ^0.4.15;


import "../../contracts/EntityIdentityRecordFactory.sol";
import "./DummyEir.sol";


contract DummyEirFactory is EntityIdentityRecordFactory {

    function create(bytes data) returns (EntityIdentityRecord eir) {
        eir = new DummyEir(data);
    }

}
