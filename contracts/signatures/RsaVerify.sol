pragma solidity ^0.4.17;

import "./ModexpPrecompile.sol";
import "../utils/BytesUtils.sol";

library RsaVerify {
    using ModexpPrecompile for *;
    using BytesUtils for *;

    /**
     * @dev Verifies input data aginst signature.
     *
     * @param paddedData Padded data to verify against signature.
     * @param N public modulus.
     * @param e public exponent.
     * @param S signature to recover.
     * @return True if the input data is equal to the recovered signature data.
     */
    function verifySignature(bytes paddedData, bytes N, uint e, bytes S) internal view returns (bool) {
        var (modexpSuccess, modexpOutput) = ModexpPrecompile.modexp(S, e, N);
        // NOTE: keccak256 is the cheapest for equality comparison
        return modexpSuccess == true && keccak256(modexpOutput) == keccak256(paddedData);
    }

    /**
     * @dev Verifies direct key signature.
     *
     * @param signature signature to verify
     * @param signer public modulus.
     * @return True if the public key is contained signature.
     */
    function verifyDirectKeySignature(bytes signature, bytes signer) internal view returns (bool) {
        // TODO: What about exponent? Always 65537?
        var (modexpSuccess, modexpOutput) = ModexpPrecompile.modexp(signature, 65537, signer);
        bytes32 publicKeySHA256Hash = BytesUtils.copyToBytes32(modexpOutput, modexpOutput.length - 32);
        // TODO: BytesUtils.bytesToString(N)
        return modexpSuccess == true && publicKeySHA256Hash == sha256(BytesUtils.bytesToString(signer));
    }
}