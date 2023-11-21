//written largely by chatgpt may have errors not fully tested
//maybe look at https://etherscan.io/address/0x7dd7aa4b560692c882d982312c0b53b24c51523a#code for base32 stuff for cidv1 encoding

// SPDX-License-Identifier: MIT
// Updated for custom Base32 encoding

pragma solidity ^0.8.20;

/**
 * @dev Provides a set of functions to operate with Base32 strings.
 */
library Base32 {
    /**
     * @dev Custom Base32 Encoding Table
     */
    string internal constant _CUSTOM_TABLE32 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";

    /**
     * @dev Converts a `string` to its Base32 `bytes` representation.
     */
    function encodeToCustomBase32(string memory data) internal pure returns (bytes memory) {
        bytes memory dataBytes = bytes(data);
        if (dataBytes.length == 0) return bytes("");

        // Loads the table into memory
        string memory table = _CUSTOM_TABLE32;

        // Encoding takes 8 bytes chunks of binary data from `bytes` data parameter
        // and split into 5 numbers of 8 bits.
        // The final Base32 length should be `bytes` data length multiplied by 5/8 rounded up
        // - `data.length + 7`  -> Round up
        // - `/ 8`              -> Number of 8-bytes chunks
        // - `5 *`              -> 5 characters for each chunk
        bytes memory result = new bytes(5 * ((dataBytes.length + 7) / 8));

        // Iterate over the input, 8 bytes at a time
        for (uint256 i = 0; i < dataBytes.length; i += 8) {
            // Advance 8 bytes
            bytes8 input = bytes8(0);
            for (uint256 j = 0; j < 8 && i + j < dataBytes.length; j++) {
                input |= bytes8(dataBytes[i + j]) >> (j * 8);
            }

            // To write each character, shift the 8 bytes (64 bits) chunk
            // 5 times in blocks of 8 bits for each character (56, 48, 40, 32, 24)
            // and apply logical AND with 0x1F which is the number of
            // the previous character in the custom Base32 table
            // The result is then added to the table to get the character to write
            for (uint256 k = 0; k < 5; k++) {
                result[i * 5 / 8 + k] = bytes1(uint8((input >> (56 - k * 8)) & 0x1F));
            }
        }

        return result;
    }

}
