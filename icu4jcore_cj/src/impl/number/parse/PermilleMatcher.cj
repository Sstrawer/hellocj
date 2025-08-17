package icu4cj.impl.number.parse


public class PermilleMatcher <: SymbolMatcher {
    private static let DEFAULT = PermilleMatcher()

    public static func getInstance(symbols: DecimalFormatSymbols): PermilleMatcher {
        let symbolString = symbols.getPerMillString()
        if (DEFAULT.uniSet.contains(symbolString)) {
            return DEFAULT
        } else {
            return PermilleMatcher(symbolString)
        }
    }

    private init(symbolString: String) {
        super(symbolString, DEFAULT.uniSet)
    }

    private init() {
        super(StaticUnicodeSets_Key.PERMILLE_SIGN)
    }

    override protected func isDisabled(result: ParsedNumber): Bool {
        return 0 != (result.flags & ParsedNumber.FLAG_PERMILLE)
    }

    override protected func accept(segment: StringSegment, result: ParsedNumber): Unit {
        result.flags |= ParsedNumber.FLAG_PERMILLE
        result.setCharsConsumed(segment)
    }

    public override func toString(): String {
        return "<PermilleMatcher>"
    }
}
