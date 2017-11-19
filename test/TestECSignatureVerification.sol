pragma solidity ^0.4.0;


import "../contracts/signatures/ECVerify.sol";
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

contract TestECSignatureVerification {

    function testVerifySignature() public {
        // Public key: 0x6ced77e44edaf028d45aa24a1fa5f0e9b310d1b9bd92a883f8bb2812e0a8f5a84fc0aeda0c96b8d15074b23fefc0ced1f5ba151b95808e6031dc5b1b5b1c3112
        // Public key => Address: 0xfdaa33846e677adac0a66ba60029319698e58623
        bytes memory publicKeyAddress = hex'fdaa33846e677adac0a66ba60029319698e58623';
        bytes32 publicKeyAddressHash = keccak256("fdaa33846e677adac0a66ba60029319698e58623");
        bytes memory signature = hex"27dd01b872b09b6007e5f401494caeb75fbc21e61836b1f9d875d07fc468dcb825bf76eaa6cf7090c6a3e365c3e7b1f1bf7a67707f6c0f92dd3e3aa9ae9e7a3b00";
        Assert.isTrue(ECVerify.verifySignature(publicKeyAddressHash, signature, publicKeyAddress), "Invalid signature or signature does not contain message hash");
    }

    function testVerifyDirectKeySignature() public {
        // Public key: 0x6ced77e44edaf028d45aa24a1fa5f0e9b310d1b9bd92a883f8bb2812e0a8f5a84fc0aeda0c96b8d15074b23fefc0ced1f5ba151b95808e6031dc5b1b5b1c3112
        // Public key => Address: 0xfdaa33846e677adac0a66ba60029319698e58623
        bytes memory publicKeyAddress = hex'fdaa33846e677adac0a66ba60029319698e58623';
        bytes memory signature = hex"27dd01b872b09b6007e5f401494caeb75fbc21e61836b1f9d875d07fc468dcb825bf76eaa6cf7090c6a3e365c3e7b1f1bf7a67707f6c0f92dd3e3aa9ae9e7a3b00";
        Assert.isTrue(ECVerify.verifyDirectKeySignature(signature, publicKeyAddress), "Invalid signature or signature does not contain public key address");
    }
}
