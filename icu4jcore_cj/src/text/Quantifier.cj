package icu4cj.text

class Quantifier <: UnicodeMatcher {
    private var matcher: UnicodeMatcher

    private var minCount: Int32 = 0

    private var maxCount: Int32 = 0

    public static let MAX = Int32.Max

    public init(theMatcher: UnicodeMatcher, theMinCount: Int32, theMaxCount: Int32) {
        if (theMatcher.isNone() || theMinCount < 0 || theMaxCount < 0 || theMinCount > theMaxCount) {
            throw IllegalArgumentException()
        }
        matcher = theMatcher
        minCount = theMinCount
        maxCount = theMaxCount
    }

    public override func matches(text: Replaceable, offset: Array<Int32>, limit: Int32, incremental: Bool): Int32 {
        let start = offset[0]
        var count = 0
        while (count < maxCount) {
            let pos = offset[0]
            let m = matcher.matches(text, offset, limit, incremental)
            if (m == U_MATCH) {
                count++
                if (pos == offset[0]) {
                    break
                }
            } else if (incremental && m == U_PARTIAL_MATCH) {
                return U_PARTIAL_MATCH
            } else {
                break
            }
        }
        if (incremental && offset[0] == limit) {
            return U_PARTIAL_MATCH
        }
        if (count >= minCount) {
            return U_MATCH
        }
        offset[0] = start
        return U_MISMATCH
    }

    public override func toPattern(escapeUnprintable: Bool): String {
        let result = StringBuilder()
        result.append(matcher.toPattern(escapeUnprintable))
        if (minCount == 0) {
            if (maxCount == 1) {
                return result.append('?').toString()
            } else if (maxCount == MAX) {
                return result.append('*').toString()
            }
        } else if (minCount == 1 && maxCount == MAX) {
            return result.append('+').toString()
        }
        result.append('{')
        result.append(Utility.hex(Int64(minCount), 1))
        result.append(',')
        if (maxCount != MAX) {
            result.append(Utility.hex(Int64(maxCount), 1))
        }
        result.append('}')
        return result.toString()
    }

    public override func matchesIndexValue(v: Int32): Bool {
        return (minCount == 0) || matcher.matchesIndexValue(v)
    }

    public override func addMatchSetTo(toUnionTo: UnicodeSet): Unit {
        if (maxCount > 0) {
            matcher.addMatchSetTo(toUnionTo)
        }
    }
}
