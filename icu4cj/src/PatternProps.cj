package icu4cj

/**
 * ICU PatternProps class for Cangjie
 * Implements the immutable Unicode properties Pattern_Syntax and Pattern_White_Space.
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
     * @return s except with leading and trailing Pattern_White_Space removed.
     */
    public static func trimWhiteSpace(s: String): String {
        if (s.size == 0) {
            return s
        }
        var start: Int64 = 0
        var limit = s.size
        while (start < limit && isWhiteSpace(Int64(s[start]))) {
            start = start + 1
        }
        if (start < limit) {
            while (isWhiteSpace(Int64(s[limit - 1]))) {
                limit = limit - 1
            }
        }
        return s[start..limit]
    }

    /**
     * Tests whether the CharSequence contains a "pattern identifier"
     */
    public static func isIdentifier(s: String): Bool {
        let limit = s.size
        if (limit == 0) {
            return false
        }
        var start: Int64 = 0
        while (start < limit) {
            if (isSyntaxOrWhiteSpace(Int64(s[start]))) {
                return false
            }
            start = start + 1
        }
        return true
    }

    /**
     * Skips over Pattern_White_Space starting at index i of the CharSequence.
     * @return The smallest index at or after i with a non-white space character.
     */
    public static func skipWhiteSpace(s: String, i: Int64): Int64 {
        var index = i
        while (index < s.size && isWhiteSpace(Int64(s[index]))) {
            index = index + 1
        }
        return index
    }

    /**
     * Skips over a "pattern identifier" starting at index i of the CharSequence.
     * @return The smallest index at or after i with
     *         a Pattern_White_Space or Pattern_Syntax character.
     */
    public static func skipIdentifier(s: String, i: Int64): Int64 {
        var index = i
        while (index < s.size && !isSyntaxOrWhiteSpace(Int64(s[index]))) {
            index = index + 1
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
     * One 32-bit integer per 32 characters. Ranges of all-false and all-true
     * are mapped to the first two values, other ranges map to appropriate bit patterns.
     */
    private static let syntax2000: VArray<Int64, $10> = [
        0,
        -1,
        0xffff0000,  // 2: 2010..201F
        0x7fff00ff,  // 3: 2020..2027, 2030..203E
        0x7feffffe,  // 4: 2041..2053, 2055..205E
        0xffff0000,  // 5: 2190..219F
        0x003fffff,  // 6: 2760..2775
        0xfff00000,  // 7: 2794..279F
        0xffffff0e,  // 8: 3001..3003, 3008..301F
        0x00010001   // 9: 3020, 3030
    ]

    /*
     * Same as syntax2000, but with additional bits set for the
     * Pattern_White_Space characters 200E 200F 2028 2029.
     */
    private static let syntaxOrWhiteSpace2000: VArray<Int64, $10> = [
        0,
        -1,
        0xffffc000,  // 2: 200E..201F
        0x7fff03ff,  // 3: 2020..2029, 2030..203E
        0x7feffffe,  // 4: 2041..2053, 2055..205E
        0xffff0000,  // 5: 2190..219F
        0x003fffff,  // 6: 2760..2775
        0xfff00000,  // 7: 2794..279F
        0xffffff0e,  // 8: 3001..3003, 3008..301F
        0x00010001   // 9: 3020, 3030
    ]
}
