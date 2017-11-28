pragma solidity ^0.4.17;


import "../contracts/signatures/ECSignatureVerifier.sol";
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

contract TestECSignatureVerification {

    ECSignatureVerifier ecSignatureVerifier;

    function beforeAll() public {
        ecSignatureVerifier = new ECSignatureVerifier();
    }

    function testVerifySignature() public {
        // Public key: 0x148513eeff92789e0c36afa6333376880d79d41027a68cab84d49891f7b36678e68039199d1baba3448f66a19a8ab67b9854c9ce4a4f5940e2a8e84996ebc7d9
        // Public key => Address: 0x192e545a9025d55e6088c55c7755ab3633e3e589
        bytes memory message = "signed message";
        bytes memory publicKeyAddress = hex'192e545a9025d55e6088c55c7755ab3633e3e589';
        bytes memory signature = hex"6552605df777d92d476430f49d0b1bc5f19536f9a584925fa76cb219c8256ad14c2cb9f7d46c1e12e2ca3ef6572e7144866a03caca9a117b050220591f9929a300";
        Assert.isTrue(ecSignatureVerifier.verify(message, signature, publicKeyAddress), "Invalid signature or signature does not contain message hash");
    }

    function testVerifySignature_InvalidMessage() public {
        bytes memory message = "invlid message";
        bytes memory publicKeyAddress = hex'192e545a9025d55e6088c55c7755ab3633e3e589';
        bytes memory signature = hex"6552605df777d92d476430f49d0b1bc5f19536f9a584925fa76cb219c8256ad14c2cb9f7d46c1e12e2ca3ef6572e7144866a03caca9a117b050220591f9929a300";
        Assert.isFalse(ecSignatureVerifier.verify(message, signature, publicKeyAddress), "Signature verification should fail");
    }

    function testVerifySignature_InvalidSignature() public {
        bytes memory message = "signed message";
        bytes memory publicKeyAddress = hex'192e545a9025d55e6088c55c7755ab3633e3e589';
        bytes memory signature = hex"6552605df777d92d476430f49d0b1bc5f19536f9a584925fa76cb219c8256ad14c2cb9f7d46c1e12e2ca3ef6572e7144866a03caca9a117b050220591f9929a301";
        Assert.isFalse(ecSignatureVerifier.verify(message, signature, publicKeyAddress), "Signature verification should fail");
    }

    function testVerifySignature_InvalidPublicKey() public {
        bytes memory message = "invlid message";
        bytes memory publicKeyAddress = hex'192e545a9025d55e6088c55c7755ab3633e3e580';
        bytes memory signature = hex"6552605df777d92d476430f49d0b1bc5f19536f9a584925fa76cb219c8256ad14c2cb9f7d46c1e12e2ca3ef6572e7144866a03caca9a117b050220591f9929a300";
        Assert.isFalse(ecSignatureVerifier.verify(message, signature, publicKeyAddress), "Signature verification should fail");
    }

    function testVerifyDirectKeySignature() public {
        // Public key: 0x6ced77e44edaf028d45aa24a1fa5f0e9b310d1b9bd92a883f8bb2812e0a8f5a84fc0aeda0c96b8d15074b23fefc0ced1f5ba151b95808e6031dc5b1b5b1c3112
        // Public key => Address: 0xfdaa33846e677adac0a66ba60029319698e58623
        bytes memory publicKeyAddress = hex'fdaa33846e677adac0a66ba60029319698e58623';
        bytes memory signature = hex"27dd01b872b09b6007e5f401494caeb75fbc21e61836b1f9d875d07fc468dcb825bf76eaa6cf7090c6a3e365c3e7b1f1bf7a67707f6c0f92dd3e3aa9ae9e7a3b00";
        Assert.isTrue(ecSignatureVerifier.verifyDirectKeySignature(signature, publicKeyAddress), "Invalid signature or signature does not contain public key address");
    }

    function testVerifyDirectKeySignature_InvalidPublicKey() public {
        bytes memory publicKeyAddress = hex'fdaa33846e677adac0a66ba60029319698e58620';
        bytes memory signature = hex"27dd01b872b09b6007e5f401494caeb75fbc21e61836b1f9d875d07fc468dcb825bf76eaa6cf7090c6a3e365c3e7b1f1bf7a67707f6c0f92dd3e3aa9ae9e7a3b00";
        Assert.isFalse(ecSignatureVerifier.verifyDirectKeySignature(signature, publicKeyAddress), "Signature verification should fail");
    }

    function testVerifyDirectKeySignature_InvalidSignature() public {
        bytes memory publicKeyAddress = hex'fdaa33846e677adac0a66ba60029319698e58623';
        bytes memory signature = hex"27dd01b872b09b6007e5f401494caeb75fbc21e61836b1f9d875d07fc468dcb825bf76eaa6cf7090c6a3e365c3e7b1f1bf7a67707f6c0f92dd3e3aa9ae9e7a3b01";
        Assert.isFalse(ecSignatureVerifier.verifyDirectKeySignature(signature, publicKeyAddress), "Signature verification should fail");
    }
}
