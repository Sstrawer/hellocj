package icu4cj

/**
 * CharacterIteration utility class for Cangjie
 * Translated from Java to Cangjie
 */
class CharacterIteration {
    // disallow instantiation
    private init() { }
    
    // 32 bit Char value returned from when an iterator has run out of range.
    // Positive value so fast case (not end, not surrogate) can be checked
    // with a single test.
    public static let DONE32: Int64 = 0x7fffffff
    
    /**
     * Move the iterator forward to the next code point, and return that code point,
     * leaving the iterator positioned at char returned.
     * For Supplementary chars, the iterator is left positioned at the lead surrogate.
     * @param ci The character iterator
     * @return The next code point.
     */
    public static func next32(ci: CharacterIterator): Int64 {
        // If the current position is at a surrogate pair, move to the trail surrogate
        // which leaves it in position for underlying iterator's next() to work.
        var c = ci.current()
        if (c >= UTF16.LEAD_SURROGATE_MIN_VALUE && c <= UTF16.LEAD_SURROGATE_MAX_VALUE) {
            c = ci.next()
            if (c < UTF16.TRAIL_SURROGATE_MIN_VALUE || c > UTF16.TRAIL_SURROGATE_MAX_VALUE) {
                ci.previous()
            }
        }
        
        // For BMP chars, this next() is the real deal.
        c = ci.next()
        
        // If we might have a lead surrogate, we need to peak ahead to get the trail
        // even though we don't want to really be positioned there.
        if (c >= UTF16.LEAD_SURROGATE_MIN_VALUE) {
            c = nextTrail32(ci, c)
        }
        
        return c
    }
    
    /**
     * Helper function to get the trail surrogate for a supplementary character
     */
    private static func nextTrail32(ci: CharacterIterator, lead: Int64): Int64 {
        let trail = ci.next()
        if (UTF16.isTrailSurrogate(trail)) {
            return UTF16.getSupplementary(lead, trail)
        } else {
            ci.previous()
            return lead
        }
    }
    
    /**
     * Move the iterator backward to the previous code point, and return that code point,
     * leaving the iterator positioned at char returned.
     * For Supplementary chars, the iterator is left positioned at the trail surrogate.
     * @param ci The character iterator
     * @return The previous code point.
     */
    public static func previous32(ci: CharacterIterator): Int64 {
        if (ci.getIndex() <= ci.getBeginIndex()) {
            return DONE32
        }
        
        let trail = ci.previous()
        var retVal = trail
        
        if (UTF16.isTrailSurrogate(trail) && ci.getIndex() > ci.getBeginIndex()) {
            let lead = ci.previous()
            if (UTF16.isLeadSurrogate(lead)) {
                retVal = UTF16.getSupplementary(lead, trail)
            } else {
                ci.next()
            }
        }
        
        return retVal
    }
    
    /**
     * Get the current code point at the iterator's position.
     * For Supplementary chars, the iterator is left positioned at the lead surrogate.
     * @param ci The character iterator
     * @return The current code point.
     */
    public static func current32(ci: CharacterIterator): Int64 {
        let lead = ci.current()
        var retVal = lead
        
        if (retVal < UTF16.LEAD_SURROGATE_MIN_VALUE) {
            return retVal
        }
        
        if (UTF16.isLeadSurrogate(lead)) {
            let trail = ci.next()
            ci.previous()
            if (UTF16.isTrailSurrogate(trail)) {
                retVal = UTF16.getSupplementary(lead, trail)
            }
        } else {
            if (lead == CharacterIterator.DONE) {
                if (ci.getIndex() >= ci.getEndIndex()) {
                    retVal = DONE32
                }
            }
        }
        
        return retVal
    }
}

/**
 * CharacterIterator interface for Cangjie
 * Simplified version of Java's CharacterIterator
 */
class CharacterIterator {
    static let DONE: Int64 = -1
    
    func current(): Int64 {
        return DONE
    }
    
    func next(): Int64 {
        return DONE
    }
    
    func previous(): Int64 {
        return DONE
    }
    
    func getIndex(): Int64 {
        return 0
    }
    
    func getBeginIndex(): Int64 {
        return 0
    }
    
    func getEndIndex(): Int64 {
        return 0
    }
}
