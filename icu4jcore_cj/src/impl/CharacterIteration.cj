package icu4cj.impl


public class CharacterIteration {

    public static let DONE32 = 2147483647

    public static func next32(ci: CharacterIterator): Int32 {
        var c = Int32(UInt32(ci.current()))
        if (c >= UTF16.LEAD_SURROGATE_MIN_VALUE && c <= UTF16.LEAD_SURROGATE_MAX_VALUE) {
            c = Int32(UInt32(ci.next()))
            if (c < UTF16.TRAIL_SURROGATE_MIN_VALUE || c > UTF16.TRAIL_SURROGATE_MAX_VALUE) {
                ci.previous()
            }
        }
        c = Int32(UInt32(ci.next()))
        if (c >= UTF16.LEAD_SURROGATE_MIN_VALUE) {
            c = nextTrail32(ci, c)
        }
        if (c >= UTF16.SUPPLEMENTARY_MIN_VALUE && c != DONE32) {
            ci.previous()
        }
        return c
    }

    public static func nextTrail32(ci: CharacterIterator, lead: Int32): Int32 {
        if (lead == Int32(UInt32(CharacterIterator.DONE)) && ci.getIndex() >= ci.getEndIndex()) {
            return DONE32
        }
        var retVal = lead
        if (lead <= UTF16.LEAD_SURROGATE_MAX_VALUE) {
            let cTrail = ci.next()
            if (UTF16.isTrailSurrogate(Int32(UInt32(cTrail)))) {
                retVal = (shl((lead - UTF16.LEAD_SURROGATE_MIN_VALUE), 10)) + (Int32(UInt32(cTrail)) - UTF16.TRAIL_SURROGATE_MIN_VALUE) + UTF16.SUPPLEMENTARY_MIN_VALUE
            } else {
                ci.previous()
            }
        }
        return retVal
    }

    public static func previous32(ci: CharacterIterator): Int32 {
        if (ci.getIndex() <= ci.getBeginIndex()) {
            return DONE32
        }
        let trail = ci.previous()
        var retVal = Int32(UInt32(trail))
        if (UTF16.isTrailSurrogate(Int32(UInt32(trail))) && ci.getIndex() > ci.getBeginIndex()) {
            let lead = ci.previous()
            if (UTF16.isLeadSurrogate(Int32(UInt32(lead)))) {
                retVal = (shl((Int32(UInt32(lead)) - UTF16.LEAD_SURROGATE_MIN_VALUE), 10)) + (Int32(UInt32(trail)) - UTF16.TRAIL_SURROGATE_MIN_VALUE) + UTF16.SUPPLEMENTARY_MIN_VALUE
            } else {
                ci.next()
            }
        }
        return retVal
    }

    public static func current32(ci: CharacterIterator): Int32 {
        let lead = ci.current()
        var retVal = Int32(UInt32(lead))
        if (retVal < UTF16.LEAD_SURROGATE_MIN_VALUE) {
            return retVal
        }
        if (UTF16.isLeadSurrogate(Int32(UInt32(lead)))) {
            let trail = Int32(UInt32(ci.next()))
            ci.previous()
            if (UTF16.isTrailSurrogate(trail)) {
                retVal = (shl((Int32(UInt32(lead)) - UTF16.LEAD_SURROGATE_MIN_VALUE), 10)) + (trail - UTF16.TRAIL_SURROGATE_MIN_VALUE) + UTF16.SUPPLEMENTARY_MIN_VALUE
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
