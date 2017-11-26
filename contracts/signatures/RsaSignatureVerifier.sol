pragma solidity ^0.4.17;


import "./SignatureVerifier.sol";
import "./ModexpPrecompile.sol";
import "../utils/BytesUtils.sol";


contract RsaSignatureVerifier is SignatureVerifier {
    using ModexpPrecompile for *;
    using BytesUtils for *;

    function verify(bytes32 messageHash, bytes signature, bytes signer) public view returns (bool) {
        var (modexpSuccess, modexpOutput) = ModexpPrecompile.modexp(signature, 65537, signer);
        return modexpSuccess == true && keccak256(modexpOutput) == messageHash;
    }

    function verify(bytes message, bytes signature, bytes signer) public view returns (bool) {
        return verify(keccak256(message), signature, signer);
    }

    function verifyDirectKeySignature(bytes signature, bytes signer) public view returns (bool) {
        var (modexpSuccess, modexpOutput) = ModexpPrecompile.modexp(signature, 65537, signer);
        bytes32 publicKeySHA256Hash = BytesUtils.copyToBytes32(modexpOutput, modexpOutput.length - 32);
        return modexpSuccess == true && publicKeySHA256Hash == sha256(BytesUtils.bytesToString(signer));
    }
}