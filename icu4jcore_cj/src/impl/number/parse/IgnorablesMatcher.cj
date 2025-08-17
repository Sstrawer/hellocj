package icu4cj.impl.number.parse

public class IgnorablesMatcher <: SymbolMatcher & NumberParseMatcher_Flexible {
    private static let DEFAULT = IgnorablesMatcher(StaticUnicodeSets.get(StaticUnicodeSets_Key.DEFAULT_IGNORABLES))

    private static let STRICT = IgnorablesMatcher(StaticUnicodeSets.get(StaticUnicodeSets_Key.STRICT_IGNORABLES))

    private static let JAVA_COMPATIBILITY = IgnorablesMatcher(StaticUnicodeSets.get(StaticUnicodeSets_Key.EMPTY))

    public static func getInstance(parseFlags: Int32): IgnorablesMatcher {
        if (0 != (parseFlags & ParsingUtils.PARSE_FLAG_JAVA_COMPATIBILITY_IGNORABLES)) {
            return JAVA_COMPATIBILITY
        } else if (0 != (parseFlags & ParsingUtils.PARSE_FLAG_STRICT_IGNORABLES)) {
            return STRICT
        } else {
            return DEFAULT
        }
    }

    private init(ignorables: UnicodeSet) {
        super("", ignorables)
    }

    override protected func isDisabled(result: ParsedNumber): Bool {
        return false
    }

    override protected func accept(segment: StringSegment, result: ParsedNumber): Unit { }

    public override func toString(): String {
        return "<IgnorablesMatcher>"
    }
}
