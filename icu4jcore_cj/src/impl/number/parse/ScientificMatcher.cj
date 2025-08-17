package icu4cj.impl.number.parse

public class ScientificMatcher <: NumberParseMatcher {
    private let exponentSeparatorString: String

    private let exponentMatcher: DecimalMatcher

    private let ignorablesMatcher: IgnorablesMatcher

    private let customMinusSign: String

    private let customPlusSign: String

    public static func getInstance(symbols: DecimalFormatSymbols, grouper: Grouper): ScientificMatcher {
        return ScientificMatcher(symbols, grouper)
    }

    private init(symbols: DecimalFormatSymbols, grouper: Grouper) {
        exponentSeparatorString = symbols.getExponentSeparator()
        exponentMatcher = DecimalMatcher.getInstance(symbols, grouper, ParsingUtils.PARSE_FLAG_INTEGER_ONLY | ParsingUtils.PARSE_FLAG_GROUPING_DISABLED)
        ignorablesMatcher = IgnorablesMatcher.getInstance(ParsingUtils.PARSE_FLAG_STRICT_IGNORABLES)
        let minusSign = symbols.getMinusSignString()
        customMinusSign = if (minusSignSet().contains(minusSign)) { None } else { minusSign }
        let plusSign = symbols.getPlusSignString()
        customPlusSign = if (plusSignSet().contains(plusSign)) { None } else { plusSign }
    }

    private static func minusSignSet(): UnicodeSet {
        return StaticUnicodeSets.get(StaticUnicodeSets_Key.MINUS_SIGN)
    }

    private static func plusSignSet(): UnicodeSet {
        return StaticUnicodeSets.get(StaticUnicodeSets_Key.PLUS_SIGN)
    }

    public override func match(segment: StringSegment, result: ParsedNumber): Bool {
        if (!result.seenNumber()) {
            return false
        }
        if (0 != (result.flags & ParsedNumber.FLAG_HAS_EXPONENT)) {
            return false
        }
        let initialOffset = segment.getOffset()
        var overlap = segment.getCommonPrefixLength(exponentSeparatorString)
        if (overlap == Int32(exponentSeparatorString.size)) {
            if (segment.size == overlap) {
                return true
            }
            segment.adjustOffset(overlap)
            ignorablesMatcher.match(segment, None)
            if (segment.size == 0) {
                segment.setOffset(initialOffset)
                return true
            }
            var exponentSign = 1
            if (segment.startsWith(minusSignSet())) {
                exponentSign = -1
                segment.adjustOffsetByCodePoint()
            } else if (segment.startsWith(plusSignSet())) {
                segment.adjustOffsetByCodePoint()
            } else if (segment.startsWith(customMinusSign)) {
                overlap = segment.getCommonPrefixLength(customMinusSign)
                if (overlap != Int32(customMinusSign.size)) {
                    segment.setOffset(initialOffset)
                    return true
                }
                exponentSign = -1
                segment.adjustOffset(overlap)
            } else if (segment.startsWith(customPlusSign)) {
                overlap = segment.getCommonPrefixLength(customPlusSign)
                if (overlap != Int32(customPlusSign.size)) {
                    segment.setOffset(initialOffset)
                    return true
                }
                segment.adjustOffset(overlap)
            }
            if (segment.size == 0) {
                segment.setOffset(initialOffset)
                return true
            }
            ignorablesMatcher.match(segment, None)
            if (segment.size == 0) {
                segment.setOffset(initialOffset)
                return true
            }
            let wasNull = (result.quantity.isNone())
            if (wasNull) {
                result.quantity = DecimalQuantity_DualStorageBCD()
            }
            let digitsOffset = segment.getOffset()
            let digitsReturnValue = exponentMatcher.match(segment, result, exponentSign)
            if (wasNull) {
                result.quantity = None
            }
            if (segment.getOffset() != digitsOffset) {
                result.flags |= ParsedNumber.FLAG_HAS_EXPONENT
            } else {
                segment.setOffset(initialOffset)
            }
            return digitsReturnValue
        } else if (overlap == segment.size) {
            return true
        }
        return false
    }

    public override func smokeTest(segment: StringSegment): Bool {
        return segment.startsWith(exponentSeparatorString)
    }

    public override func postProcess(result: ParsedNumber): Unit { }

    public override func toString(): String {
        return "<ScientificMatcher " + (exponentSeparatorString) + ">"
    }
}
