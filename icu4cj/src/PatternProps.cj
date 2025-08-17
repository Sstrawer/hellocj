package icu4cj

/**
 * ICU PatternProps class for Cangjie
 * Implements the immutable Unicode properties Pattern_Syntax and Pattern_White_Space.
 * Enhanced with UTF-8 support for proper handling of multi-byte characters.
 */
class PatternProps {
    
    /**
     * @return true if c is a Pattern_Syntax code point.
     */
    public static func isSyntax(c: Int64): Bool {
        if (c < 0) {
            return false
        } else if (c <= 0xff) {
            return latin1[c] == 3
        } else if (c < 0x2010) {
            return false
        } else if (c <= 0x3030) {
            let bits = syntax2000[Int64(index2000[(c - 0x2000) >> 5])]
            return ((bits >> (c & 0x1f)) & 1) != 0
        } else if (0xfd3e <= c && c <= 0xfe46) {
            return c <= 0xfd3f || 0xfe45 <= c
        } else {
            return false
        }
    }

    /**
     * @return true if c is a Pattern_Syntax or Pattern_White_Space code point.
     */
    public static func isSyntaxOrWhiteSpace(c: Int64): Bool {
        if (c < 0) {
            return false
        } else if (c <= 0xff) {
            return latin1[c] != 0
        } else if (c < 0x200e) {
            return false
        } else if (c <= 0x3030) {
            let bits = syntaxOrWhiteSpace2000[Int64(index2000[(c - 0x2000) >> 5])]
            return ((bits >> (c & 0x1f)) & 1) != 0
        } else if (0xfd3e <= c && c <= 0xfe46) {
            return c <= 0xfd3f || 0xfe45 <= c
        } else {
            return false
        }
    }

    /**
     * @return true if c is a Pattern_White_Space character.
     */
    public static func isWhiteSpace(c: Int64): Bool {
        if (c < 0) {
            return false
        } else if (c <= 0xff) {
            return latin1[c] == 5
        } else if (0x200e <= c && c <= 0x2029) {
            return c <= 0x200f || 0x2028 <= c
        } else {
            return false
        }
    }

    /**
     * Decodes a UTF-8 character starting at the given index in the string.
     * @param s The UTF-8 encoded string
     * @param index The starting index (byte position)
     * @return A tuple containing (decoded_character, next_index)
     */
    private static func decodeUTF8Char(s: String, index: Int64): (Int64, Int64) {
        if (index >= s.size) {
            return (-1, index)
        }
        
        let firstByte = Int64(s[index])
        
        // ASCII character (0xxxxxxx)
        if (firstByte < 0x80) {
            return (firstByte, index + 1)
        }
        
        // Multi-byte character
        if (index + 1 >= s.size) {
            return (-1, index)
        }
        
        let secondByte = Int64(s[index + 1])
        
        // 2-byte character (110xxxxx 10xxxxxx)
        if ((firstByte & 0xE0) == 0xC0) {
            if (index + 2 > s.size) {
                return (-1, index)
            }
            let codePoint = ((firstByte & 0x1F) << 6) | (secondByte & 0x3F)
            return (codePoint, index + 2)
        }
        
        // 3-byte character (1110xxxx 10xxxxxx 10xxxxxx)
        if ((firstByte & 0xF0) == 0xE0) {
            if (index + 3 > s.size) {
                return (-1, index)
            }
            let thirdByte = Int64(s[index + 2])
            let codePoint = ((firstByte & 0x0F) << 12) | ((secondByte & 0x3F) << 6) | (thirdByte & 0x3F)
            return (codePoint, index + 3)
        }
        
        // 4-byte character (11110xxx 10xxxxxx 10xxxxxx 10xxxxxx)
        if ((firstByte & 0xF8) == 0xF0) {
            if (index + 4 > s.size) {
                return (-1, index)
            }
            let thirdByte = Int64(s[index + 2])
            let fourthByte = Int64(s[index + 3])
            let codePoint = ((firstByte & 0x07) << 18) | ((secondByte & 0x3F) << 12) | ((thirdByte & 0x3F) << 6) | (fourthByte & 0x3F)
            return (codePoint, index + 4)
        }
        
        // Invalid UTF-8 sequence
        return (-1, index + 1)
    }



    /**
     * @return s except with leading and trailing Pattern_White_Space removed.
     * Enhanced to handle UTF-8 encoded strings correctly.
     */
    public static func trimWhiteSpace(s: String): String {
        if (s.size == 0) {
            return s
        }
        
        var start: Int64 = 0
        var limit: Int64 = s.size
        
        // Skip leading whitespace
        while (start < limit) {
            let (char, nextIndex) = decodeUTF8Char(s, start)
            if (char == -1) {
                start = start + 1
            } else if (!isWhiteSpace(char)) {
                break
            } else {
                start = nextIndex
            }
        }
        
        // Skip trailing whitespace
        if (start < limit) {
            var tempIndex = limit - 1
            while (tempIndex >= start) {
                // Find the start of the last character
                var charStart = tempIndex
                while (charStart > start && (Int64(s[charStart]) & 0xC0) == 0x80) {
                    charStart = charStart - 1
                }
                
                let (char, _) = decodeUTF8Char(s, charStart)
                if (char == -1 || !isWhiteSpace(char)) {
                    break
                }
                tempIndex = charStart - 1
            }
            limit = tempIndex + 1
        }
        
        if (start == 0 && limit == s.size) {
            return s
        } else {
            return s[start..limit]
        }
    }

    /**
     * Tests whether the CharSequence contains a "pattern identifier", that is,
     * whether it contains only non-Pattern_White_Space, non-Pattern_Syntax characters.
     * Enhanced to handle UTF-8 encoded strings correctly.
     * @return true if there are no Pattern_White_Space or Pattern_Syntax characters in s.
     */
    public static func isIdentifier(s: String): Bool {
        let limit = s.size
        if (limit == 0) {
            return false
        }
        
        var index: Int64 = 0
        while (index < limit) {
            let (char, nextIndex) = decodeUTF8Char(s, index)
            if (char == -1) {
                // Invalid UTF-8 sequence, treat as invalid
                return false
            } else if (isSyntaxOrWhiteSpace(char)) {
                return false
            }
            index = nextIndex
        }
        return true
    }

    /**
     * Skips over Pattern_White_Space starting at index i of the CharSequence.
     * Enhanced to handle UTF-8 encoded strings correctly.
     * @return The smallest index at or after i with a non-white space character.
     */
    public static func skipWhiteSpace(s: String, i: Int64): Int64 {
        var index = i
        while (index < s.size) {
            let (char, nextIndex) = decodeUTF8Char(s, index)
            if (char == -1) {
                index = index + 1
            } else if (!isWhiteSpace(char)) {
                break
            } else {
                index = nextIndex
            }
        }
        return index
    }

    /**
     * Skips over a "pattern identifier" starting at index i of the CharSequence.
     * Enhanced to handle UTF-8 encoded strings correctly.
     * @return The smallest index at or after i with
     *         a Pattern_White_Space or Pattern_Syntax character.
     */
    public static func skipIdentifier(s: String, i: Int64): Int64 {
        var index = i
        while (index < s.size) {
            let (char, nextIndex) = decodeUTF8Char(s, index)
            if (char == -1) {
                index = index + 1
            } else if (isSyntaxOrWhiteSpace(char)) {
                break
            } else {
                index = nextIndex
            }
        }
        return index
    }

    /*
     * One byte per Latin-1 character.
     * Bit 0 is set if either Pattern property is true,
     * bit 1 if Pattern_Syntax is true,
     * bit 2 if Pattern_White_Space is true.
     * That is, Pattern_Syntax is encoded as 3 and Pattern_White_Space as 5.
     */
    private static let latin1: VArray<Int8, $256> = [
        // WS: 9..D
        0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        // WS: 20  Syntax: 21..2F
        5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        // Syntax: 3A..40
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3,
        3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        // Syntax: 5B..5E
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 0,
        // Syntax: 60
        3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        // Syntax: 7B..7E
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 0,
        // WS: 85
        0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        // Syntax: A1..A7, A9, AB, AC, AE
        0, 3, 3, 3, 3, 3, 3, 3, 0, 3, 0, 3, 3, 0, 3, 0,
        // Syntax: B0, B1, B6, BB, BF
        3, 3, 0, 0, 0, 0, 3, 0, 0, 0, 0, 3, 0, 0, 0, 3,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        // Syntax: D7
        0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        // Syntax: F7
        0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0
    ]

    /*
     * One byte per 32 characters from U+2000..U+303F indexing into
     * a small table of 32-bit data words.
     * The first two data words are all-zeros and all-ones.
     */
    private static let index2000: VArray<Int8, $130> = [
        2, 3, 4, 0, 0, 0, 0, 0,  // 20xx
        0, 0, 0, 0, 5, 1, 1, 1,  // 21xx
        1, 1, 1, 1, 1, 1, 1, 1,  // 22xx
        1, 1, 1, 1, 1, 1, 1, 1,  // 23xx
        1, 1, 1, 0, 0, 0, 0, 0,  // 24xx
        1, 1, 1, 1, 1, 1, 1, 1,  // 25xx
        1, 1, 1, 1, 1, 1, 1, 1,  // 26xx
        1, 1, 1, 6, 7, 1, 1, 1,  // 27xx
        1, 1, 1, 1, 1, 1, 1, 1,  // 28xx
        1, 1, 1, 1, 1, 1, 1, 1,  // 29xx
        1, 1, 1, 1, 1, 1, 1, 1,  // 2Axx
        1, 1, 1, 1, 1, 1, 1, 1,  // 2Bxx
        0, 0, 0, 0, 0, 0, 0, 0,  // 2Cxx
        0, 0, 0, 0, 0, 0, 0, 0,  // 2Dxx
        1, 1, 1, 1, 0, 0, 0, 0,  // 2Exx
        0, 0, 0, 0, 0, 0, 0, 0,  // 2Fxx
        8, 9  // 3000..303F
    ]

    /*
     * One byte per 32 characters from U+2000..U+303F indexing into
     * a small table of 32-bit data words.
     * The first two data words are all-zeros and all-ones.
     */
    private static let syntax2000: VArray<Int32, $16> = [
        0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
        0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
    ]

    /*
     * One byte per 32 characters from U+2000..U+303F indexing into
     * a small table of 32-bit data words.
     * The first two data words are all-zeros and all-ones.
     */
    private static let syntaxOrWhiteSpace2000: VArray<Int32, $16> = [
        0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
        0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000
    ]
}
