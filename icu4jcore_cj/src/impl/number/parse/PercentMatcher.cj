package icu4cj.impl.number.parse

public class PercentMatcher <: SymbolMatcher {
    private static let DEFAULT = PercentMatcher()

    public static func getInstance(symbols: DecimalFormatSymbols): PercentMatcher {
        let symbolString = symbols.getPercentString()
        if (DEFAULT.uniSet.contains(symbolString)) {
            return DEFAULT
        } else {
            return PercentMatcher(symbolString)
        }
    }

    private init(symbolString: String) {
        super(symbolString, DEFAULT.uniSet)
    }

    private init() {
        super(StaticUnicodeSets_Key.PERCENT_SIGN)
    }

    override protected func isDisabled(result: ParsedNumber): Bool {
        return 0 != (result.flags & ParsedNumber.FLAG_PERCENT)
    }

    override protected func accept(segment: StringSegment, result: ParsedNumber): Unit {
        result.flags |= ParsedNumber.FLAG_PERCENT
        result.setCharsConsumed(segment)
    }

    public override func toString(): String {
        return "<PercentMatcher>"
    }
}
