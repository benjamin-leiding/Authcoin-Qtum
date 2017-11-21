pragma solidity ^0.4.17;


import "truffle/Assert.sol";


// Proxy contract for testing throws
contract ErrorProxy {
    address public target;

    bytes data;

    function ErrorProxy(address _target) {
        target = _target;
    }

    //prime the data using the fallback function.
    function() {
        data = msg.data;
    }

    function execute() returns (bool) {
        return target.call(data);
    }
}
