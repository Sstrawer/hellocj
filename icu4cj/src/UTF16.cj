package icu4cj

/**
 * UTF16 utility class for Cangjie
 * Standalone utility class providing UTF16 character conversions and indexing conversions.
 * Translated from Java to Cangjie
 */
class UTF16 {
    // Public constants
    public static let SINGLE_CHAR_BOUNDARY: Int64 = 1
    public static let LEAD_SURROGATE_BOUNDARY: Int64 = 2
    public static let TRAIL_SURROGATE_BOUNDARY: Int64 = 5
    
    // Unicode constants
    public static let LEAD_SURROGATE_MIN_VALUE: Int64 = 0xD800
    public static let LEAD_SURROGATE_MAX_VALUE: Int64 = 0xDBFF
    public static let TRAIL_SURROGATE_MIN_VALUE: Int64 = 0xDC00
    public static let TRAIL_SURROGATE_MAX_VALUE: Int64 = 0xDFFF
    public static let SUPPLEMENTARY_MIN_VALUE: Int64 = 0x10000
    
    /**
     * Check if a character is a lead surrogate
     */
    public static func isLeadSurrogate(ch: Int64): Bool {
        return ch >= LEAD_SURROGATE_MIN_VALUE && ch <= LEAD_SURROGATE_MAX_VALUE
    }
    
    /**
     * Check if a character is a trail surrogate
     */
    public static func isTrailSurrogate(ch: Int64): Bool {
        return ch >= TRAIL_SURROGATE_MIN_VALUE && ch <= TRAIL_SURROGATE_MAX_VALUE
    }
    
    /**
     * Check if a character is a surrogate
     */
    public static func isSurrogate(ch: Int64): Bool {
        return isLeadSurrogate(ch) || isTrailSurrogate(ch)
    }
    
    /**
     * Get the lead surrogate for a supplementary character
     */
    public static func getLeadSurrogate(ch: Int64): Int64 {
        if (ch < SUPPLEMENTARY_MIN_VALUE) {
            return ch
        }
        return ((ch - SUPPLEMENTARY_MIN_VALUE) >> 10) + LEAD_SURROGATE_MIN_VALUE
    }
    
    /**
     * Get the trail surrogate for a supplementary character
     */
    public static func getTrailSurrogate(ch: Int64): Int64 {
        if (ch < SUPPLEMENTARY_MIN_VALUE) {
            return ch
        }
        return ((ch - SUPPLEMENTARY_MIN_VALUE) & 0x3FF) + TRAIL_SURROGATE_MIN_VALUE
    }
    
    /**
     * Get the supplementary character from a surrogate pair
     */
    public static func getSupplementary(lead: Int64, trail: Int64): Int64 {
        if (isLeadSurrogate(lead) && isTrailSurrogate(trail)) {
            return ((lead - LEAD_SURROGATE_MIN_VALUE) << 10) + 
                   (trail - TRAIL_SURROGATE_MIN_VALUE) + 
                   SUPPLEMENTARY_MIN_VALUE
        }
        return lead
    }
    
    /**
     * Get the number of characters needed to represent a code point
     */
    public static func getCharCount(ch: Int64): Int64 {
        if (ch < SUPPLEMENTARY_MIN_VALUE) {
            return 1
        }
        return 2
    }
    
    /**
     * Get character at a specific index in a string
     */
    public static func charAt(s: String, index: Int64): Int64 {
        if (index < 0 || index >= s.size) {
            return -1
        }
        
        let ch = Int64(s[index])
        if (isLeadSurrogate(ch) && index + 1 < s.size) {
            let trail = Int64(s[index + 1])
            if (isTrailSurrogate(trail)) {
                return getSupplementary(ch, trail)
            }
        }
        return ch
    }
    
    /**
     * Get the bounds information for a string at a specific offset
     */
    public static func bounds(s: String, offset16: Int64): Int64 {
        if (offset16 < 0 || offset16 >= s.size) {
            return SINGLE_CHAR_BOUNDARY
        }
        
        let ch = Int64(s[offset16])
        if (isLeadSurrogate(ch)) {
            return LEAD_SURROGATE_BOUNDARY
        } else if (isTrailSurrogate(ch)) {
            return TRAIL_SURROGATE_BOUNDARY
        } else {
            return SINGLE_CHAR_BOUNDARY
        }
    }
}

