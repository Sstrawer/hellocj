package icu4cj.text

public abstract class UnicodeFilter <: UnicodeMatcher {
    public func contains(c: Int32): Bool

    public override func matches(text: Replaceable, offset: Array<Int32>, limit: Int32, incremental: Bool): Int32 {
        let c: Int32
        if (offset[0] < limit && contains(match (0) { case _ => c = text.char32At(offset[0]); c })) {
            offset[0] += UTF16.getCharCount(c)
            return U_MATCH
        }
        if (offset[0] > limit && contains(text.char32At(offset[0]))) {
            offset[0] -= 1
            if (offset[0] >= 0) {
                offset[0] -= UTF16.getCharCount(text.char32At(offset[0])) - 1
            }
            return U_MATCH
        }
        if (incremental && offset[0] == limit) {
            return U_PARTIAL_MATCH
        }
        return U_MISMATCH
    }

    
}
