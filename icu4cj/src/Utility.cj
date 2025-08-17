// © 2016 and later: Unicode, Inc. and others.
// License & terms of use: http://www.unicode.org/copyright.html
/**
*******************************************************************************
* Copyright (C) 1996-2015, International Business Machines Corporation and    *
* others. All Rights Reserved.                                                *
*******************************************************************************
*/
package icu4cj

/**
* Utility class containing various helper methods for string processing,
* array comparison, character escaping, and other common operations.
* This is a simplified translation of com.ibm.icu.impl.Utility from Java to Cangjie.
*/
public class Utility {

    private static let APOSTROPHE: Int64 = 0x27  // '\''
    private static let BACKSLASH: Int64 = 0x5C   // '\\'
    private static let MAGIC_UNSIGNED: Int64 = 0x80000000

    /**
     * Convenience utility to compare two String arrays.
     * @param source source array
     * @param target target array  
     * @return true if arrays are equal
     */
    public static func arrayEquals(source: Option<Array<String>>, target: Option<Array<String>>): Bool {
        if (source.isSome() && target.isSome()) {
            let sourceArray = source.getOrThrow()
            let targetArray = target.getOrThrow()
            return (sourceArray.size == targetArray.size && 
                    arrayRegionMatches(sourceArray, 0, targetArray, 0, sourceArray.size))
        }
        return source.isNone() && target.isNone()
    }

    /**
     * Convenience utility to compare two int arrays
     * @param source source array
     * @param target target array
     * @return true if arrays are equal
     */
    public static func arrayEquals(source: Option<Array<Int64>>, target: Option<Array<Int64>>): Bool {
        if (source.isSome() && target.isSome()) {
            let sourceArray = source.getOrThrow()
            let targetArray = target.getOrThrow()
            return (sourceArray.size == targetArray.size && 
                    arrayRegionMatches(sourceArray, 0, targetArray, 0, sourceArray.size))
        }
        return source.isNone() && target.isNone()
    }

    /**
     * Convenience utility to compare two double arrays
     * @param source source array
     * @param target target array
     * @return true if arrays are equal
     */
    public static func arrayEquals(source: Option<Array<Float64>>, target: Option<Array<Float64>>): Bool {
        if (source.isSome() && target.isSome()) {
            let sourceArray = source.getOrThrow()
            let targetArray = target.getOrThrow()
            return (sourceArray.size == targetArray.size && 
                    arrayRegionMatches(sourceArray, 0, targetArray, 0, sourceArray.size))
        }
        return source.isNone() && target.isNone()
    }

    /**
     * Convenience utility to compare two byte arrays
     * @param source source array
     * @param target target array
     * @return true if arrays are equal
     */
    public static func arrayEquals(source: Option<Array<Int8>>, target: Option<Array<Int8>>): Bool {
        if (source.isSome() && target.isSome()) {
            let sourceArray = source.getOrThrow()
            let targetArray = target.getOrThrow()
            return (sourceArray.size == targetArray.size && 
                    arrayRegionMatches(sourceArray, 0, targetArray, 0, sourceArray.size))
        }
        return source.isNone() && target.isNone()
    }

    /**
     * Convenience utility to compare two String arrays within a region
     * @param source source array
     * @param sourceStart start index in source
     * @param target target array
     * @param targetStart start index in target
     * @param len length to compare
     * @return true if regions match
     */
    public static func arrayRegionMatches(source: Array<String>, sourceStart: Int64,
                                        target: Array<String>, targetStart: Int64,
                                        len: Int64): Bool {
        var tempLen = len
        var sourceIndex = sourceStart
        var targetIndex = targetStart
        
        if (tempLen < 0) {
            return false
        }
        
        while (tempLen > 0) {
            if (sourceIndex >= source.size || targetIndex >= target.size) {
                return false
            }
            if (source[sourceIndex] != target[targetIndex]) {
                return false
            }
            sourceIndex++
            targetIndex++
            tempLen--
        }
        return true
    }

    /**
     * Convenience utility to compare two int arrays within a region
     * @param source source array
     * @param sourceStart start index in source
     * @param target target array
     * @param targetStart start index in target
     * @param len length to compare
     * @return true if regions match
     */
    public static func arrayRegionMatches(source: Array<Int64>, sourceStart: Int64,
                                        target: Array<Int64>, targetStart: Int64,
                                        len: Int64): Bool {
        var tempLen = len
        var sourceIndex = sourceStart
        var targetIndex = targetStart
        
        if (tempLen < 0) {
            return false
        }
        
        while (tempLen > 0) {
            if (sourceIndex >= source.size || targetIndex >= target.size) {
                return false
            }
            if (source[sourceIndex] != target[targetIndex]) {
                return false
            }
            sourceIndex++
            targetIndex++
            tempLen--
        }
        return true
    }

    /**
     * Convenience utility to compare two double arrays within a region
     * @param source source array
     * @param sourceStart start index in source
     * @param target target array
     * @param targetStart start index in target
     * @param len length to compare
     * @return true if regions match
     */
    public static func arrayRegionMatches(source: Array<Float64>, sourceStart: Int64,
                                        target: Array<Float64>, targetStart: Int64,
                                        len: Int64): Bool {
        var tempLen = len
        var sourceIndex = sourceStart
        var targetIndex = targetStart
        
        if (tempLen < 0) {
            return false
        }
        
        while (tempLen > 0) {
            if (sourceIndex >= source.size || targetIndex >= target.size) {
                return false
            }
            if (source[sourceIndex] != target[targetIndex]) {
                return false
            }
            sourceIndex++
            targetIndex++
            tempLen--
        }
        return true
    }

    /**
     * Convenience utility to compare two byte arrays within a region
     * @param source source array
     * @param sourceStart start index in source
     * @param target target array
     * @param targetStart start index in target
     * @param len length to compare
     * @return true if regions match
     */
    public static func arrayRegionMatches(source: Array<Int8>, sourceStart: Int64,
                                        target: Array<Int8>, targetStart: Int64,
                                        len: Int64): Bool {
        var tempLen = len
        var sourceIndex = sourceStart
        var targetIndex = targetStart
        
        if (tempLen < 0) {
            return false
        }
        
        while (tempLen > 0) {
            if (sourceIndex >= source.size || targetIndex >= target.size) {
                return false
            }
            if (source[sourceIndex] != target[targetIndex]) {
                return false
            }
            sourceIndex++
            targetIndex++
            tempLen--
        }
        return true
    }

    /**
     * Check if two objects refer to the same instance
     * @param a first object
     * @param b second object
     * @return true if both refer to same object
     */
    public static func sameObjects(a: Option<String>, b: Option<String>): Bool {
        if (a.isSome() && b.isSome()) {
            return a.getOrThrow() == b.getOrThrow()
        }
        return a.isNone() && b.isNone()
    }

    /**
     * Convert a number to hexadecimal string
     * @param ch number to convert
     * @return hex string (simplified)
     */
    public static func hex(ch: Int64): String {
        return hexString(ch, 4)
    }

    /**
     * Find a string in an array of strings
     * @param source string to find
     * @param target array to search in
     * @return index if found, -1 if not found
     */
    public static func lookup(source: String, target: Array<String>): Int64 {
        for (i in 0..target.size) {
            if (target[i] == source) {
                return i
            }
        }
        return -1
    }

    /**
     * Check if a character is unprintable
     * @param c character code point
     * @return true if unprintable
     */
    public static func isUnprintable(c: Int64): Bool {
        return c < 0x20 || c > 0x7E
    }

    /**
     * Check if a character should always be escaped
     * @param c character code point
     * @return true if should be escaped
     */
    public static func shouldAlwaysBeEscaped(c: Int64): Bool {
        return c < 0x20 || c == 0x7F || (c >= 0x80 && c <= 0x9F)
    }

    /**
     * Compare two character sequences for equality
     * @param a first sequence
     * @param b second sequence
     * @return true if equal
     */
    public static func charSequenceEquals(a: Option<String>, b: Option<String>): Bool {
        if (a.isSome() && b.isSome()) {
            return a.getOrThrow() == b.getOrThrow()
        }
        return a.isNone() && b.isNone()
    }

    // Helper function to create hex string with specified width
    private static func hexString(value: Int64, width: Int64): String {
        var result = ""
        var temp = value
        let hexChars = "0123456789ABCDEF"
        
        // Handle negative values
        if (temp < 0) {
            temp = temp + 0x100000000  // Convert to unsigned equivalent
        }
        
        // Simple hex conversion
        if (temp == 0) {
            result = "0"
        } else {
            while (temp > 0) {
                let digit = temp % 16
                result = Rune(Int64(hexChars[digit])).toString() + result
                temp = temp / 16
            }
        }
        
        // Pad with zeros if needed
        while (Int64(result.size) < width) {
            result = "0" + result
        }
        
        return result
    }
}