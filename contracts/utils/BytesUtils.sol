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

    function copyToBytes32(bytes src, uint offset) pure internal returns (bytes32) {
        bytes32 out;
        for (uint i = 0; i < 32; i++) {
            out |= bytes32(src[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

	function char(byte b) pure internal returns (byte c) {
        if (b < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }

    function bytesToString(bytes src) pure internal returns (string out) {
        uint l = src.length;
        bytes memory s = new bytes(l*2);

        for (uint i = 0; i < l; i++) {
            byte b = byte(src[i]);
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[i*2] = char(hi);
            s[i*2+1] = char(lo);
        }

        out = string(s);
    }

	function bytesToAddress(bytes _address) pure internal returns (address) {
		uint160 m = 0;
		uint160 b = 0;

		for (uint8 i = 0; i < 20; i++) {
		  m *= 256;
		  b = uint160(_address[i]);
		  m += (b);
		}

		return address(m);
	}

	function addressToBytes(address a) pure internal returns (bytes b){
	   assembly {
			let m := mload(0x40)
			mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
			mstore(0x40, add(m, 52))
			b := m
	   }
	}
}
