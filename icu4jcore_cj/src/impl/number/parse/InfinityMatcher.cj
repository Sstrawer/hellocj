package icu4cj.impl.number.parse

public class InfinityMatcher <: SymbolMatcher {
    private static let DEFAULT = InfinityMatcher()

    public static func getInstance(symbols: DecimalFormatSymbols): InfinityMatcher {
        let symbolString = symbols.getInfinity()
        if (DEFAULT.uniSet.contains(symbolString)) {
            return DEFAULT
        } else {
            return InfinityMatcher(symbolString)
        }
    }

    private init(symbolString: String) {
        super(symbolString, DEFAULT.uniSet)
    }

    private init() {
        super(StaticUnicodeSets_Key.INFINITY_SIGN)
    }

    override protected func isDisabled(result: ParsedNumber): Bool {
        return 0 != (result.flags & ParsedNumber.FLAG_INFINITY)
    }

    override protected func accept(segment: StringSegment, result: ParsedNumber): Unit {
        result.flags |= ParsedNumber.FLAG_INFINITY
        result.setCharsConsumed(segment)
    }

    public override func toString(): String {
        return "<InfinityMatcher>"
    }
}
