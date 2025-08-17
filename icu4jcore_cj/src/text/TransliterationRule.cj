package icu4cj.text


class TransliterationRule {
    private var anteContext: StringMatcher

    private var key: StringMatcher

    private var postContext: StringMatcher

    private var output: UnicodeReplacer

    private var pattern: String

    var segments: Array<UnicodeMatcher>

    private var anteContextLength: Int32 = 0

    private var keyLength: Int32 = 0

    var flags: UInt8 = 0

    static let ANCHOR_START = 1

    static let ANCHOR_END = 2

    private let data: RuleBasedTransliterator_Data

    public init(input: String, anteContextPos: Int32, postContextPos: Int32, output: String, cursorPos: Int32, cursorOffset: Int32, segs: Array<UnicodeMatcher>, anchorStart: Bool, anchorEnd: Bool, theData: RuleBasedTransliterator_Data) {
        var tempcursorPos = cursorPos
        data = theData
        if (anteContextPos < 0) {
            anteContextLength = 0
        } else {
            if (anteContextPos > Int32(input.size)) {
                throw IllegalArgumentException("Invalid ante context")
            }
            anteContextLength = anteContextPos
        }
        if (postContextPos < 0) {
            keyLength = Int32(input.size) - anteContextLength
        } else {
            if (postContextPos < anteContextLength || postContextPos > Int32(input.size)) {
                throw IllegalArgumentException("Invalid post context")
            }
            keyLength = postContextPos - anteContextLength
        }
        if (tempcursorPos < 0) {
            tempcursorPos = Int32(output.size)
        } else if (tempcursorPos > Int32(output.size)) {
            throw IllegalArgumentException("Invalid cursor position")
        }
        this.segments = segs
        pattern = input
        flags = 0
        if (anchorStart) {
            flags |= UInt8(ANCHOR_START)
        }
        if (anchorEnd) {
            flags |= UInt8(ANCHOR_END)
        }
        anteContext = None
        if (anteContextLength > 0) {
            anteContext = StringMatcher(pattern[0..Int64(anteContextLength)], 0, data)
        }
        key = None
        if (keyLength > 0) {
            key = StringMatcher(pattern[Int64(anteContextLength)..Int64(anteContextLength + keyLength)], 0, data)
        }
        let postContextLength = Int32(pattern.size) - keyLength - anteContextLength
        postContext = None
        if (postContextLength > 0) {
            postContext = StringMatcher(pattern[Int64(anteContextLength + keyLength)..], 0, data)
        }
        this.output = StringReplacer(output, tempcursorPos + cursorOffset, data)
    }

    public func getAnteContextLength(): Int32 {
        return anteContextLength + (if ((Int32(flags) & ANCHOR_START) != 0) { 1 } else { 0 })
    }

    func getIndexValue(): Int32 {
        if (anteContextLength == Int32(pattern.size)) {
            return -1
        }
        let c = UTF16.toRuneArray()[pattern, anteContextLength]
        return if (data.lookupMatcher(c).isNone()) { (c & 255) } else { -1 }
    }

    func matchesIndexValue(v: Int32): Bool {
        let m = if (key.isSome()) { key } else { postContext }
        return if (m.isSome()) { m.matchesIndexValue(v) } else { true }
    }

    public func masks(r2: TransliterationRule): Bool {
        let len = Int32(pattern.size)
        let left = anteContextLength
        let left2 = r2.anteContextLength
        let right = Int32(pattern.size) - left
        let right2 = Int32(r2.pattern.size) - left2
        if (left == left2 && right == right2 && keyLength <= r2.keyLength && r2.pattern.regionMatches(0, pattern, 0, len)) {
            return (flags == r2.flags) || (!((Int32(flags) & ANCHOR_START) != 0) && !((Int32(flags) & ANCHOR_END) != 0)) || (((Int32(r2.flags) & ANCHOR_START) != 0) && ((Int32(r2.flags) & ANCHOR_END) != 0))
        }
        return left <= left2 && (right < right2 || (right == right2 && keyLength <= r2.keyLength)) && r2.pattern.regionMatches(left2 - left, pattern, 0, len)
    }

    static func posBefore(str: Replaceable, pos: Int32): Int32 {
        return if (pos > 0) { pos - UTF16.getCharCount(str.char32At(pos - 1)) } else { pos - 1 }
    }

    static func posAfter(str: Replaceable, pos: Int32): Int32 {
        return if (pos >= 0 && pos < str.size) { pos + UTF16.getCharCount(str.char32At(pos)) } else { pos + 1 }
    }

    public func matchAndReplace(text: Replaceable, pos: Transliterator_Position, incremental: Bool): Int32 {
        if (segments.isSome()) {
            var i = 0
            while (i < Int32(segments.size)) {
                segments[Int64(i)].resetMatch()
                i++
            }
        }
        let keyLimit: Int32
        let intRef = Array<Int32>(1) { _ => 0 }
        var oText: Int32 = 0
        let minOText: Int32
        let anteLimit = posBefore(text, pos.contextStart)
        var match: Int32 = 0
        intRef[0] = posBefore(text, pos.start)
        if (anteContext.isSome()) {
            match = anteContext.matches(text, intRef, anteLimit, false)
            if (match != UnicodeMatcher.U_MATCH) {
                return UnicodeMatcher.U_MISMATCH
            }
        }
        oText = intRef[0]
        minOText = posAfter(text, oText)
        if (((Int32(flags) & ANCHOR_START) != 0) && oText != anteLimit) {
            return UnicodeMatcher.U_MISMATCH
        }
        intRef[0] = pos.start
        if (key.isSome()) {
            match = key.matches(text, intRef, pos.limit, incremental)
            if (match != UnicodeMatcher.U_MATCH) {
                return match
            }
        }
        keyLimit = intRef[0]
        if (postContext.isSome()) {
            if (incremental && keyLimit == pos.limit) {
                return UnicodeMatcher.U_PARTIAL_MATCH
            }
            match = postContext.matches(text, intRef, pos.contextLimit, incremental)
            if (match != UnicodeMatcher.U_MATCH) {
                return match
            }
        }
        oText = intRef[0]
        if (((Int32(flags) & ANCHOR_END)) != 0) {
            if (oText != pos.contextLimit) {
                return UnicodeMatcher.U_MISMATCH
            }
            if (incremental) {
                return UnicodeMatcher.U_PARTIAL_MATCH
            }
        }
        let newLength = output.replace(text, pos.start, keyLimit, intRef)
        let lenDelta = newLength - (keyLimit - pos.start)
        let newStart = intRef[0]
        oText += lenDelta
        pos.limit += lenDelta
        pos.contextLimit += lenDelta
        pos.start = max(minOText, min(min(oText, pos.limit), newStart))
        return UnicodeMatcher.U_MATCH
    }

    public func toRule(escapeUnprintable: Bool): String {
        let rule = StringBuffer()
        let quoteBuf = StringBuffer()
        let emitBraces = (anteContext.isSome()) || (postContext.isSome())
        if ((Int32(flags) & ANCHOR_START) != 0) {
            rule.append('^')
        }
        Utility.appendToRule(rule, anteContext, escapeUnprintable, quoteBuf)
        if (emitBraces) {
            Utility.appendToRule(rule, Int32(UInt32('{')), true, escapeUnprintable, quoteBuf)
        }
        Utility.appendToRule(rule, key, escapeUnprintable, quoteBuf)
        if (emitBraces) {
            Utility.appendToRule(rule, Int32(UInt32('}')), true, escapeUnprintable, quoteBuf)
        }
        Utility.appendToRule(rule, postContext, escapeUnprintable, quoteBuf)
        if ((Int32(flags) & ANCHOR_END) != 0) {
            rule.append('$')
        }
        Utility.appendToRule(rule, " > ", true, escapeUnprintable, quoteBuf)
        Utility.appendToRule(rule, output.toReplacerPattern(escapeUnprintable), true, escapeUnprintable, quoteBuf)
        Utility.appendToRule(rule, Int32(UInt32(';')), true, escapeUnprintable, quoteBuf)
        return toString(rule)
    }

    public override func toString(): String {
        return '{'.toString() + (toRule(true)) + '}'.toString()
    }

    public func addSourceTargetSet(filter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet, revisiting: UnicodeSet): Unit {
        let limit = anteContextLength + keyLength
        let tempSource = UnicodeSet()
        let temp = UnicodeSet()
        var i = anteContextLength
        while (i < limit) {
            let ch = UTF16.toRuneArray()[pattern, i]
            i += UTF16.getCharCount(ch)
            let matcher = data.lookupMatcher(ch)
            if (matcher.isNone()) {
                if (!filter.contains(ch)) {
                    return
                }
                tempSource.add(ch)
            } else {
                try {
                    if (!filter.containsSome(matcher)) {
                        return
                    }
                    matcher.addMatchSetTo(tempSource)
                } catch (e: ClassCastException) {
                    temp.clear()
                    matcher.addMatchSetTo(temp)
                    if (!filter.containsSome(temp)) {
                        return
                    }
                    tempSource.addAll(temp)
                }
            }
        }
        sourceSet.addAll(tempSource)
        output.addReplacementSetTo(targetSet)
    }
}
