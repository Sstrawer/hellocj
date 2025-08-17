package icu4cj.impl.number.parse


public abstract class SymbolMatcher <: NumberParseMatcher {
    protected let string: String

    protected let uniSet: UnicodeSet

    protected init(symbolString: String, symbolUniSet: UnicodeSet) {
        string = symbolString
        uniSet = symbolUniSet
    }

    protected init(key: StaticUnicodeSets_Key) {
        string = ""
        uniSet = StaticUnicodeSets.get(key)
    }

    public func getSet(): UnicodeSet {
        return uniSet
    }

    public override func match(segment: StringSegment, result: ParsedNumber): Bool {
        if (isDisabled(result)) {
            return false
        }
        var overlap = 0
        if (!string.isEmpty()) {
            overlap = segment.getCommonPrefixLength(string)
            if (overlap == Int32(string.size)) {
                segment.adjustOffset(Int32(string.size))
                accept(segment, result)
                return false
            }
        }
        if (segment.startsWith(uniSet)) {
            segment.adjustOffsetByCodePoint()
            accept(segment, result)
            return false
        }
        return overlap == segment.size
    }

    public override func smokeTest(segment: StringSegment): Bool {
        return segment.startsWith(uniSet) || segment.startsWith(string)
    }

    public override func postProcess(result: ParsedNumber): Unit { }

    protected func isDisabled(result: ParsedNumber): Bool

    protected func accept(segment: StringSegment, result: ParsedNumber): Unit
}
