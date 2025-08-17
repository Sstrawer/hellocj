// © 2016 and later: Unicode, Inc. and others.
// License & terms of use: http://www.unicode.org/copyright.html
/**
*******************************************************************************
* Copyright (C) 1996-2004, International Business Machines Corporation and    *
* others. All Rights Reserved.                                                *
*******************************************************************************
*/
package icu4cj

/**
* Internal character utility class for simple data type conversion and String 
* parsing functions. Does not have an analog in the JDK.
* @author Syn Wee Quek
* @since sep2900
*/
public class UCharacterUtility {
    // public methods -----------------------------------------------------
    
    /**
    * Determines if codepoint is a non character
    * @param ch codepoint
    * @return true if codepoint is a non character false otherwise
    */
    public static func isNonCharacter(ch: Int64): Bool {
        if ((ch & NON_CHARACTER_SUFFIX_MIN_3_0) == NON_CHARACTER_SUFFIX_MIN_3_0) {
            return true
        }
        
        return ch >= NON_CHARACTER_MIN_3_1 && ch <= NON_CHARACTER_MAX_3_1
    }
    
    // package private methods ---------------------------------------------
      
    /**
    * joining 2 chars to form an int
    * @param msc most significant char
    * @param lsc least significant char
    * @return int form
    */
    public static func toInt(msc: Int64, lsc: Int64): Int64 {
        return ((msc << 16) | lsc)
    }
       
    /**
    * Retrieves a null terminated substring from an array of bytes.
    * Substring is a set of non-zero bytes starting from argument start to the 
    * next zero byte. If the first byte is a zero, the next byte will be taken as
    * the first byte.
    * @param array byte array
    * @param index to start substring in byte count
    * @return tuple of (extracted string, end position within the character array)
    */
    public static func getNullTermByteSubString(array: Array<Int8>, index: Int64): (String, Int64) {
        var b: Int8 = 1
        var currentIndex = index
        var result = ""
        
        while (b != 0) {
            b = array[currentIndex]
            if (b != 0) {
                // Convert byte to character - simple ASCII conversion for now
                let asciiValue = Int64(b) & 0xFF
                if (asciiValue < 128) {
                    let r = Rune(asciiValue)
                    result = result + r.toString()
                }
            }
            currentIndex++
        }
        return (result, currentIndex)
    }
       
    /**
    * Compares a null terminated substring from an array of bytes.
    * Substring is a set of non-zero bytes starting from argument start to the 
    * next zero byte. if the first byte is a zero, the next byte will be taken as
    * the first byte.
    * @param str string to compare
    * @param array byte array
    * @param strindex index within str to start comparing
    * @param aindex array index to start in byte count
    * @return the end position of the substring within str if matches otherwise 
    *         a -1
    */
    public static func compareNullTermByteSubString(str: String, array: Array<Int8>, strindex: Int64, aindex: Int64): Int64 {
        var b: Int8 = 1
        let length = Int64(str.size)
        var currentStrIndex = strindex
        var currentAIndex = aindex
        
        while (b != 0) {
            b = array[currentAIndex]
            currentAIndex++
            if (b == 0) {
                break
            }
            // if we have reached the end of the string and yet the array has not 
            // reached the end of their substring yet, abort
            if (currentStrIndex == length || (getStringByteAt(str, currentStrIndex) != UInt8(Int64(b) & 0xFF))) {
                return -1
            }
            currentStrIndex++
        }
        return currentStrIndex
    }
       
    /**
    * Skip null terminated substrings from an array of bytes.
    * Substring is a set of non-zero bytes starting from argument start to the 
    * next zero byte. If the first byte is a zero, the next byte will be taken as
    * the first byte.
    * @param array byte array
    * @param index to start substrings in byte count
    * @param skipcount number of null terminated substrings to skip
    * @return the end position of the substrings within the character array
    */
    public static func skipNullTermByteSubString(array: Array<Int8>, index: Int64, skipcount: Int64): Int64 {
        var b: Int8
        var currentIndex = index
        
        for (i in 0..skipcount) {
            b = 1
            while (b != 0) {
                b = array[currentIndex]
                currentIndex++
            }
        }
        return currentIndex
    }
       
    /**
     * skip substrings from an array of characters, where each character is a set 
     * of 2 bytes. substring is a set of non-zero bytes starting from argument 
     * start to the byte of the argument value. skips up to a max number of 
     * characters
     * @param array byte array to parse
     * @param index to start substrings in byte count
     * @param length the max number of bytes to skip
     * @param skipend value of byte to skip to
     * @return the number of bytes skipped
     */
    public static func skipByteSubString(array: Array<Int8>, index: Int64, length: Int64, skipend: Int8): Int64 {
        var b: Int8
        
        for (i in 0..length) {
            b = array[index + i]
            if (b == skipend) {
                return i + 1  // Include the found byte in the count
            }
        }
        
        // If not found, return the maximum length searched
        return length
    }
    
    // Helper function to get byte at string index for UTF-8 string
    private static func getStringByteAt(str: String, index: Int64): UInt8 {
        // In Cangjie, string indexing returns UInt8 for UTF-8 encoded strings
        return str[index]
    }
    
    // private data member --------------------------------------------------
    
    /**
    * Minimum suffix value that indicates if a character is non character.
    * Unicode 3.0 non characters
    */
    private static let NON_CHARACTER_SUFFIX_MIN_3_0: Int64 = 0xFFFE
    /**
    * New minimum non character in Unicode 3.1
    */
    private static let NON_CHARACTER_MIN_3_1: Int64 = 0xFDD0
    /**
    * New non character range in Unicode 3.1
    */
    private static let NON_CHARACTER_MAX_3_1: Int64 = 0xFDEF
}
