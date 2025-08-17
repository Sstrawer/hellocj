package icu4cj.impl.number.parse

public class PaddingMatcher <: SymbolMatcher & NumberParseMatcher_Flexible {
    public static func getInstance(padString: String): PaddingMatcher {
        return PaddingMatcher(padString)
    }

    private init(symbolString: String) {
        super(symbolString, UnicodeSet.EMPTY)
    }

    override protected func isDisabled(result: ParsedNumber): Bool {
        return false
    }

    override protected func accept(segment: StringSegment, result: ParsedNumber): Unit { }

    public override func toString(): String {
        return "<PaddingMatcher>"
    }
}
