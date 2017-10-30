pragma solidity ^0.4.17;

library BytesUtils {

    /**
     * @dev Copies bytes from source to destination.
     *
     * Not safe to use if `src` and `dest` overlap.
     *
     * @param src The source slice.
     * @param srcoffset Offset into the source slice.
     * @param dst The destination bytes.
     * @param dstoffset Offset into the destination slice.
     * @param len Number of bytes to copy.
     */
    function memcopy(bytes src, uint srcoffset, bytes dst, uint dstoffset, uint len) pure internal {
        assembly {
            src := add(src, add(32, srcoffset))
            dst := add(dst, add(32, dstoffset))

            // copy 32 bytes at once
            for
            {}
            iszero(lt(len, 32))
            {
            dst := add(dst, 32)
            src := add(src, 32)
            len := sub(len, 32)
            }
            { mstore(dst, mload(src)) }

                // copy the remainder (0 < len < 32)
            let mask := sub(exp(256, sub(32, len)), 1)
            let srcpart := and(mload(src), not(mask))
            let dstpart := and(mload(dst), mask)
            mstore(dst, or(srcpart, dstpart))
        }
    }
}
