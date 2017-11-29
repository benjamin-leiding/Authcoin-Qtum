pragma solidity ^0.4.17;


import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/AuthCoin.sol";
import "../contracts/ChallengeRecord.sol";
import "../contracts/EntityIdentityRecord.sol";
import "../contracts/signatures/RsaSignatureVerifier.sol";
import "../contracts/signatures/ECSignatureVerifier.sol";

contract TestRevokeEntityIdentityRecord {

    function testRevokeEntityIdentityRecordByRSAPublicKey() public {
        AuthCoin ac = new AuthCoin();
        ac.registerSignatureVerifier(new RsaSignatureVerifier(), "dummy");
        bytes memory publicKey = hex"9ffabf3dd8add28b8b08ee6f868ec0628081f6acf8a340da4e5b4624959f1e61fb5cdccf25e25c582eca14c200e57443933819a81b7b1d35165c9d869fec9135";
        bytes memory directKeyRevocationSignature = hex"216c3a465148643dc7eeb38bd79c5453fc98f02fc80a93e39b4f957c0f00bcc3c00af2eeaf076f9be066778bca05a71d5147aca2f6dcb8b97b88f2c647a422f9";

        ac.registerEir(publicKey,"dummy", new bytes32[](0), bytes32(0x1), new  bytes(128));
        ac.revokeEir(directKeyRevocationSignature, publicKey);

        EntityIdentityRecord revokedEir = ac.getEir(1);
        Assert.isTrue(revokedEir.isRevoked(), "EIR should be revoked");
    }

    function testRevokeEntityIdentityRecordByECPublicKey() public {
        AuthCoin ac = new AuthCoin();
        ac.registerSignatureVerifier(new ECSignatureVerifier(), "dummy");
        bytes memory publicKey = hex'fdaa33846e677adac0a66ba60029319698e58623';
        bytes memory directKeyRevocationSignature = hex"27dd01b872b09b6007e5f401494caeb75fbc21e61836b1f9d875d07fc468dcb825bf76eaa6cf7090c6a3e365c3e7b1f1bf7a67707f6c0f92dd3e3aa9ae9e7a3b00";

        ac.registerEir(publicKey, "dummy", new bytes32[](0), bytes32(0x1), new  bytes(128));
        ac.revokeEir(directKeyRevocationSignature, publicKey);

        EntityIdentityRecord revokedEir = ac.getEir(2);
        Assert.isTrue(revokedEir.isRevoked(), "EIR should be revoked");
    }

}
