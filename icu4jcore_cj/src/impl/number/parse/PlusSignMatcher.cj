package icu4cj.impl.number.parse

public class PlusSignMatcher <: SymbolMatcher {
    private static let DEFAULT = PlusSignMatcher(false)

    private static let DEFAULT_ALLOW_TRAILING = PlusSignMatcher(true)

    public static func getInstance(symbols: DecimalFormatSymbols, allowTrailing: Bool): PlusSignMatcher {
        let symbolString = symbols.getPlusSignString()
        if (DEFAULT.uniSet.contains(symbolString)) {
            return if (allowTrailing) { DEFAULT_ALLOW_TRAILING } else { DEFAULT }
        } else {
            return PlusSignMatcher(symbolString, allowTrailing)
        }
    }

    private let allowTrailing: Bool

    private init(symbolString: String, allowTrailing: Bool) {
        super(symbolString, DEFAULT.uniSet)
        this.allowTrailing = allowTrailing
    }

    private init(allowTrailing: Bool) {
        super(StaticUnicodeSets_Key.PLUS_SIGN)
        this.allowTrailing = allowTrailing
    }

    override protected func isDisabled(result: ParsedNumber): Bool {
        return !allowTrailing && result.seenNumber()
    }

    override protected func accept(segment: StringSegment, result: ParsedNumber): Unit {
        result.setCharsConsumed(segment)
    }

    public override func toString(): String {
        return "<PlusSignMatcher>"
    }
}
