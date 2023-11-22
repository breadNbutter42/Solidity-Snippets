// SPDX-License-Identifier: MIT
// Updated for custom 5-bit ASCII encoding

pragma solidity ^0.8.20;

/**
 * @dev Library for 5-bit ASCII encoding and decoding.
 */
library FiveBitAscii {

    /**
     * @dev Bytes 5-bit lowercase ASCII Encoding Table = a=00001 b=00010 etc abcdefghijklmnopqrstuvwxyz
     */

    // Encoding: input string of 8 bit asciis to encode to 5 bits squished into multiple bytes efficiently for compressed storage of simple text on chain
    function encodeAsciiToFive(string memory input) internal pure returns (bytes memory) {

        bytes memory encodedResult = new bytes(1); // Build our bytes storage for encoding results to live in
        uint256 newBytesPointer = 0; // Tracks current byte storing encoding to
        uint8 remainingFiveBits = 5; // Bits left available from the current 5-bit value to store into the current byte
        uint8 bitmask;
        uint8 bitsLeftInByte = 8; // Track how many bits to store in the current byte
        uint8 fiveBitValue;
        uint8 bitsToStoreNow; // track how many bits from 5 bit value we want to put into byte next time
       /*removed for efficiency
        //uint8 asciiValue;
        //uint8 fiveBitValueShiftedRight;
        //uint8 fiveBitValueShiftedLeft;
        //uint8 bitmaskShiftedLeft;
        //uint8 maskedValue; 
        */

        // Loop through each byte in the input string
        for (uint256 i = 0; i < bytes(input).length; i++) {
        require(uint8(bytes(input)[i]) >= 97 && uint8(bytes(input)[i]) <= 122, "Invalid characters in input, must be all lowercase letters a-z");
                // Check if the ASCII value is in the range of lowercase letters

            // Extract the 5-bit value representation from the ASCII value by subtracting 96 from the string of lowercase letters
            fiveBitValue = uint8(bytes(input)[i]) - 96;

            // track if any bits left over from 5 bit value that didn't fit in the byte and if so make a new byte and encode remaining bits.
            remainingFiveBits = 5; // On each loop reset local variable 5 bit value encoding counter

            while (remainingFiveBits > 0) {
                if (bitsLeftInByte == 0) { // Check if we filled up the current byte yet
                    // If the current byte is full (8 bits stored), make a new byte
                    newBytesPointer++;//update current byte pointer
                    bitsLeftInByte = 8;//update bits counter
                    encodedResult = abi.encodePacked(encodedResult, bytes1(0));//add a byte to end of dynamic bytes memory with abi.encodePacked
                }

                // Update the remaining bits left of our 5 bits value for the next iteration to store into the next new byte by subtracting the bits that were available to store in the byte from bits we wanted to store of 5 bit value
                if (remainingFiveBits >= bitsLeftInByte) {//if there are more bits to store than bits space left in storage
                    remainingFiveBits -= bitsLeftInByte;//subtract available bits in byte from bits to store from 5 bit value
                    bitsToStoreNow = bitsLeftInByte; // calculate bits to store now into byte, which is as many as we can with available space so here since we have as much or more bits to store as space left we just store maximum space left
                    bitsLeftInByte = 0; //since there are more bits to store than storage space left then we have no more storage available after we fill it up
                } else {// if more storage than we need
                    bitsLeftInByte -= remainingFiveBits;//if plenty of storage just store remaining bits from five bit value
                    bitsToStoreNow = remainingFiveBits;//store rest of bits left since there's space for it all
                    remainingFiveBits = 0;//now we know it's all been stored since there is space
                }

                bitmask = uint8((1 << bitsToStoreNow) - 1); // Create a bitmask with bitsToStoreNow number of consecutive 1s to start with to mask off our 5 bit value to store

                //fiveBitValueShiftedRight = uint8(fiveBitValue >> remainingFiveBits); // Shift fiveBitValue to the right by remainingFiveBits to align 5 bit value with mask so we only work with bitsToStoreNow amount of bits currently
                //fiveBitValueShiftedLeft = uint8(fiveBitValueShiftedRight << bitsLeftInByte); // Shift fiveBitValueShiftedRight to the left by bitsLeftInByte to align with empty space left on byte storage
                //bitmaskShiftedLeft = uint8(bitmask << bitsLeftInByte); // Shift bitmask to the left by bitsLeftInByte to align with empty space left on byte storage
                //maskedValue = fiveBitValueShiftedLeft & bitmaskShiftedLeft; // Perform bitwise AND with fiveBitValue to retain only the bits we want to store
                //encodedResult[newBytesPointer] = bytes1((encodedResult[newBytesPointer] | bytes1(maskedValue)));//Perform the bitwise OR operation to store the masked value in the current byte
                // The result is a new byte with bitsToStoreNow many bits of our 5-bit value stored
                // at the correct position in the current byte without overwriting existing bits.
                encodedResult[newBytesPointer] = bytes1((encodedResult[newBytesPointer] | bytes1(uint8(uint8(fiveBitValue >> remainingFiveBits) << bitsLeftInByte) & uint8(uint8((1 << bitsToStoreNow) - 1) << bitsLeftInByte))));//condensed operations for efficiency
            }
        }

        return (encodedResult);
    }
