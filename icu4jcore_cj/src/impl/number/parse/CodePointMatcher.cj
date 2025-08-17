package icu4cj.impl.number.parse


public class CodePointMatcher <: NumberParseMatcher {
    private let cp: Int32

    public static func getInstance(cp: Int32): CodePointMatcher {
        return CodePointMatcher(cp)
    }

    private init(cp: Int32) {
        this.cp = cp
    }

    public override func match(segment: StringSegment, result: ParsedNumber): Bool {
        if (segment.startsWith(cp)) {
            segment.adjustOffsetByCodePoint()
            result.setCharsConsumed(segment)
        }
        return false
    }

    public override func smokeTest(segment: StringSegment): Bool {
        return segment.startsWith(cp)
    }

    public override func postProcess(result: ParsedNumber): Unit { }

    public override func toString(): String {
        return "<CodePointMatcher U+" + cp.format("x") + ">"
    }
}
