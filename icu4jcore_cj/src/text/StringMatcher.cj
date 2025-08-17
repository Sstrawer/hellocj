package icu4cj.text

class StringMatcher <: UnicodeMatcher & UnicodeReplacer {
    private var pattern: String

    private var matchStart: Int32 = 0

    private var matchLimit: Int32 = 0

    private var segmentNumber: Int32 = 0

    private let data: RuleBasedTransliterator_Data

    public init(theString: String, segmentNum: Int32, theData: RuleBasedTransliterator_Data) {
        data = theData
        pattern = theString
        matchStart = match (0) { case _ => matchLimit = -1; matchLimit }
        segmentNumber = segmentNum
    }

    public init(theString: String, start: Int32, limit: Int32, segmentNum: Int32, theData: RuleBasedTransliterator_Data) {
        this(theString[Int64(start)..Int64(limit)], segmentNum, theData)
    }

    public override func matches(text: Replaceable, offset: Array<Int32>, limit: Int32, incremental: Bool): Int32 {
        var i: Int32 = 0
        let cursor = [offset[0]]
        if (limit < cursor[0]) {
            i = Int32(pattern.size) - 1
            while (i >= 0) {
                let keyChar = Char(pattern[Int64(i)])
                let subm = data.lookupMatcher(Int32(UInt32(keyChar)))
                if (subm.isNone()) {
                    if (cursor[0] > limit && keyChar == text.toRuneArray()[cursor[0]]) {
                        cursor[0] -= 1
                    } else {
                        return U_MISMATCH
                    }
                } else {
                    let m = subm.matches(text, cursor, limit, incremental)
                    if (m != U_MATCH) {
                        return m
                    }
                }
                i--
            }
            if (matchStart < 0) {
                matchStart = cursor[0] + 1
                matchLimit = offset[0] + 1
            }
        } else {
            i = 0
            while (i < Int32(pattern.size)) {
                if (incremental && cursor[0] == limit) {
                    return U_PARTIAL_MATCH
                }
                let keyChar = Char(pattern[Int64(i)])
                let subm = data.lookupMatcher(Int32(UInt32(keyChar)))
                if (subm.isNone()) {
                    if (cursor[0] < limit && keyChar == text.toRuneArray()[cursor[0]]) {
                        cursor[0] += 1
                    } else {
                        return U_MISMATCH
                    }
                } else {
                    let m = subm.matches(text, cursor, limit, incremental)
                    if (m != U_MATCH) {
                        return m
                    }
                }
                i++
            }
            matchStart = offset[0]
            matchLimit = cursor[0]
        }
        offset[0] = cursor[0]
        return U_MATCH
    }

    public override func toPattern(escapeUnprintable: Bool): String {
        let result = StringBuffer()
        let quoteBuf = StringBuffer()
        if (segmentNumber > 0) {
            result.append('(')
        }
        var i = 0
        while (i < Int32(pattern.size)) {
            let keyChar = Char(pattern[Int64(i)])
            let m = data.lookupMatcher(Int32(UInt32(keyChar)))
            if (m.isNone()) {
                Utility.appendToRule(result, Int32(UInt32(keyChar)), false, escapeUnprintable, quoteBuf)
            } else {
                Utility.appendToRule(result, m.toPattern(escapeUnprintable), true, escapeUnprintable, quoteBuf)
            }
            i++
        }
        if (segmentNumber > 0) {
            result.append(')')
        }
        Utility.appendToRule(result, -1, true, escapeUnprintable, quoteBuf)
        return toString(result)
    }

    public override func matchesIndexValue(v: Int32): Bool {
        if (Int32(pattern.size) == 0) {
            return true
        }
        let c = UTF16.toRuneArray()[pattern, 0]
        let m = data.lookupMatcher(c)
        return if (m.isNone()) { ((c & 255) == v) } else { m.matchesIndexValue(v) }
    }

    public override func addMatchSetTo(toUnionTo: UnicodeSet): Unit {
        var ch: Int32 = 0
        var i = 0
        while (i < Int32(pattern.size)) {
            ch = UTF16.toRuneArray()[pattern, i]
            let matcher = data.lookupMatcher(ch)
            if (matcher.isNone()) {
                toUnionTo.add(ch)
            } else {
                matcher.addMatchSetTo(toUnionTo)
            }
            i += UTF16.getCharCount(ch)
        }
    }

    public override func replace(text: Replaceable, start: Int32, limit: Int32, cursor: Array<Int32>): Int32 {
        var outLen = 0
        let dest = limit
        if (matchStart >= 0) {
            if (matchStart != matchLimit) {
                text.copy(matchStart, matchLimit, dest)
                outLen = matchLimit - matchStart
            }
        }
        text.replace(start, limit, "")
        return outLen
    }

    public override func toReplacerPattern(escapeUnprintable: Bool): String {
        let rule = StringBuffer("$")
        Utility.appendNumber(rule, segmentNumber, 10, 1)
        return toString(rule)
    }

    public func resetMatch(): Unit {
        matchStart = match (0) { case _ => matchLimit = -1; matchLimit }
    }

    public override func addReplacementSetTo(toUnionTo: UnicodeSet): Unit { }
}
