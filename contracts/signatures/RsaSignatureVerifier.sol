pragma solidity ^0.4.17;


import "./SignatureVerifier.sol";
import "./ModexpPrecompile.sol";
import "../utils/BytesUtils.sol";


contract RsaSignatureVerifier is SignatureVerifier {
    using ModexpPrecompile for *;
    using BytesUtils for *;

    function verify(bytes32 messageHash, bytes signature, bytes signer) public view returns (bool) {
        var (modexpSuccess, modexpOutput) = ModexpPrecompile.modexp(signature, 65537, signer);
        bytes32 signedHash = BytesUtils.copyToBytes32(modexpOutput, modexpOutput.length - 32);
        return modexpSuccess == true && signedHash == messageHash;
    }

    function verify(bytes message, bytes signature, bytes signer) public view returns (bool) {
        return verify(sha256(message), signature, signer);
    }

    function verify(string message, bytes signature, bytes signer) public view returns (bool) {
        return verify(sha256(message), signature, signer);
    }

    function verifyDirectKeySignature(bytes signature, bytes signer) public view returns (bool) {
        return verify(sha256(BytesUtils.bytesToString(signer)), signature, signer);
    }
}