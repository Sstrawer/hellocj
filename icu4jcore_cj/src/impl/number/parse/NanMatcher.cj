package icu4cj.impl.number.parse


public class NanMatcher <: SymbolMatcher {
    private static let DEFAULT = NanMatcher("NaN")

    public static func getInstance(symbols: DecimalFormatSymbols, parseFlags: Int32): NanMatcher {
        let symbolString = symbols.getNaN()
        if (DEFAULT.string.equals(symbolString)) {
            return DEFAULT
        } else {
            return NanMatcher(symbolString)
        }
    }

    private init(symbolString: String) {
        super(symbolString, UnicodeSet.EMPTY)
    }

    override protected func isDisabled(result: ParsedNumber): Bool {
        return result.seenNumber()
    }

    override protected func accept(segment: StringSegment, result: ParsedNumber): Unit {
        result.flags |= ParsedNumber.FLAG_NAN
        result.setCharsConsumed(segment)
    }

    public override func toString(): String {
        return "<NanMatcher>"
    }
}
