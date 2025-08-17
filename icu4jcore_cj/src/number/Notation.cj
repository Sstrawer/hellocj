package icu4cj.number


public class Notation {
    private static let SCIENTIFIC = ScientificNotation(1, false, 1, NumberFormatter_SignDisplay.AUTO)

    private static let ENGINEERING = ScientificNotation(3, false, 1, NumberFormatter_SignDisplay.AUTO)

    private static let COMPACT_SHORT = CompactNotation(CompactDecimalFormat_CompactStyle.SHORT)

    private static let COMPACT_LONG = CompactNotation(CompactDecimalFormat_CompactStyle.LONG)

    private static let SIMPLE = SimpleNotation()


    public static func scientific(): ScientificNotation {
        return SCIENTIFIC
    }

    public static func engineering(): ScientificNotation {
        return ENGINEERING
    }

    public static func compactShort(): CompactNotation {
        return COMPACT_SHORT
    }

    public static func compactLong(): CompactNotation {
        return COMPACT_LONG
    }

    public static func simple(): SimpleNotation {
        return SIMPLE
    }
}
