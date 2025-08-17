package icu4cj.impl.number.parse

public class MinusSignMatcher <: SymbolMatcher {
    private static let DEFAULT = MinusSignMatcher(false)

    private static let DEFAULT_ALLOW_TRAILING = MinusSignMatcher(true)

    public static func getInstance(symbols: DecimalFormatSymbols, allowTrailing: Bool): MinusSignMatcher {
        let symbolString = symbols.getMinusSignString()
        if (DEFAULT.uniSet.contains(symbolString)) {
            return if (allowTrailing) { DEFAULT_ALLOW_TRAILING } else { DEFAULT }
        } else {
            return MinusSignMatcher(symbolString, allowTrailing)
        }
    }

    private let allowTrailing: Bool

    private init(symbolString: String, allowTrailing: Bool) {
        super(symbolString, DEFAULT.uniSet)
        this.allowTrailing = allowTrailing
    }

    private init(allowTrailing: Bool) {
        super(StaticUnicodeSets_Key.MINUS_SIGN)
        this.allowTrailing = allowTrailing
    }

    override protected func isDisabled(result: ParsedNumber): Bool {
        return !allowTrailing && result.seenNumber()
    }

    override protected func accept(segment: StringSegment, result: ParsedNumber): Unit {
        result.flags |= ParsedNumber.FLAG_NEGATIVE
        result.setCharsConsumed(segment)
    }

    public override func toString(): String {
        return "<MinusSignMatcher>"
    }
}
