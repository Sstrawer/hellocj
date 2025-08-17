package icu4cj.impl.number.parse


public class DecimalMatcher <: NumberParseMatcher {
    private let requireGroupingMatch: Bool

    private let groupingDisabled: Bool

    private let integerOnly: Bool

    private let grouping1: Int32

    private let grouping2: Int32

    private let groupingSeparator: String

    private let decimalSeparator: String

    private let groupingUniSet: UnicodeSet

    private let decimalUniSet: UnicodeSet

    private let separatorSet: UnicodeSet

    private let leadSet: UnicodeSet

    private let digitStrings: Array<String>

    public static func getInstance(symbols: DecimalFormatSymbols, grouper: Grouper, parseFlags: Int32): DecimalMatcher {
        return DecimalMatcher(symbols, grouper, parseFlags)
    }

    private init(symbols: DecimalFormatSymbols, grouper: Grouper, parseFlags: Int32) {
        if (0 != (parseFlags & ParsingUtils.PARSE_FLAG_MONETARY_SEPARATORS)) {
            groupingSeparator = symbols.getMonetaryGroupingSeparatorString()
            decimalSeparator = symbols.getMonetaryDecimalSeparatorString()
        } else {
            groupingSeparator = symbols.getGroupingSeparatorString()
            decimalSeparator = symbols.getDecimalSeparatorString()
        }
        let strictSeparators = 0 != (parseFlags & ParsingUtils.PARSE_FLAG_STRICT_SEPARATORS)
        let groupingKey: StaticUnicodeSets_Key = if (strictSeparators) { StaticUnicodeSets_Key.STRICT_ALL_SEPARATORS } else { StaticUnicodeSets_Key.ALL_SEPARATORS }
        groupingUniSet = StaticUnicodeSets.get(groupingKey)
        let decimalKey = StaticUnicodeSets.chooseFrom(decimalSeparator, if (strictSeparators) { StaticUnicodeSets_Key.STRICT_COMMA } else { StaticUnicodeSets_Key.COMMA }, if (strictSeparators) { StaticUnicodeSets_Key.STRICT_PERIOD } else { StaticUnicodeSets_Key.PERIOD })
        if (decimalKey.isSome()) {
            decimalUniSet = StaticUnicodeSets.get(decimalKey)
        } else if (!decimalSeparator.isEmpty()) {
            decimalUniSet = UnicodeSet().add(decimalSeparator.codePointAt(0)).freeze()
        } else {
            decimalUniSet = UnicodeSet.EMPTY
        }
        if (groupingKey.isSome() && decimalKey.isSome()) {
            separatorSet = groupingUniSet
            leadSet = StaticUnicodeSets.get(if (strictSeparators) { StaticUnicodeSets_Key.DIGITS_OR_ALL_SEPARATORS } else { StaticUnicodeSets_Key.DIGITS_OR_STRICT_ALL_SEPARATORS })
        } else {
            separatorSet = UnicodeSet().addAll(groupingUniSet).addAll(decimalUniSet).freeze()
            leadSet = None
        }
        let cpZero = symbols.getCodePointZero()
        if (cpZero == -1 || !UCharacter.isDigit(cpZero) || UCharacter.digit(cpZero) != 0) {
            digitStrings = symbols.getDigitStringsLocal()
        } else {
            digitStrings = None
        }
        requireGroupingMatch = 0 != (parseFlags & ParsingUtils.PARSE_FLAG_STRICT_GROUPING_SIZE)
        groupingDisabled = 0 != (parseFlags & ParsingUtils.PARSE_FLAG_GROUPING_DISABLED)
        integerOnly = 0 != (parseFlags & ParsingUtils.PARSE_FLAG_INTEGER_ONLY)
        grouping1 = Int32(grouper.getPrimary())
        grouping2 = Int32(grouper.getSecondary())
    }

    public override func match(segment: StringSegment, result: ParsedNumber): Bool {
        return match(segment, result, 0)
    }

    public func match(segment: StringSegment, result: ParsedNumber, exponentSign: Int32): Bool {
        if (result.seenNumber() && exponentSign == 0) {
            return false
        } else if (exponentSign != 0) {
            if (!result.quantity.isSome()) {
                throw AssertionError()
            }
        }
        let initialOffset = segment.getOffset()
        var maybeMore = false
        var digitsConsumed: DecimalQuantity_DualStorageBCD
        var digitsAfterDecimalPlace = 0
        var actualGroupingString: String
        var actualDecimalString: String
        var currGroupOffset = 0
        var currGroupSepType = 0
        var currGroupCount = 0
        var prevGroupOffset = -1
        var prevGroupSepType = -1
        var prevGroupCount = -1
        while (segment.size > 0) {
            maybeMore = false
            var digit = 255u8
            let cp = segment.getCodePoint()
            if (UCharacter.isDigit(cp)) {
                segment.adjustOffset(Character.charCount(cp))
                digit = UInt8(UCharacter.digit(cp))
            }
            if (Int32(digit) == -1 && digitStrings.isSome()) {
                var i = 0
                while (i < Int32(digitStrings.size)) {
                    let str = digitStrings[Int64(i)]
                    if (str.isEmpty()) {
                        continue
                    }
                    let overlap = segment.getCommonPrefixLength(str)
                    if (overlap == Int32(str.size)) {
                        segment.adjustOffset(overlap)
                        digit = UInt8(i)
                        break
                    }
                    maybeMore = maybeMore || (overlap == segment.size)
                    i++
                }
            }
            if (Int32(digit) >= 0) {
                if (digitsConsumed.isNone()) {
                    digitsConsumed = DecimalQuantity_DualStorageBCD()
                }
                digitsConsumed.appendDigit(digit, 0, true)
                currGroupCount++
                if (actualDecimalString.isSome()) {
                    digitsAfterDecimalPlace++
                }
                continue
            }
            var isDecimal = false
            var isGrouping = false
            if (actualDecimalString.isNone() && !decimalSeparator.isEmpty()) {
                let overlap = segment.getCommonPrefixLength(decimalSeparator)
                maybeMore = maybeMore || (overlap == segment.size)
                if (overlap == Int32(decimalSeparator.size)) {
                    isDecimal = true
                    actualDecimalString = decimalSeparator
                }
            }
            if (actualGroupingString.isSome()) {
                let overlap = segment.getCommonPrefixLength(actualGroupingString)
                maybeMore = maybeMore || (overlap == segment.size)
                if (overlap == Int32(actualGroupingString.size)) {
                    isGrouping = true
                }
            }
            if (!groupingDisabled && actualGroupingString.isNone() && actualDecimalString.isNone() && !groupingSeparator.isEmpty()) {
                let overlap = segment.getCommonPrefixLength(groupingSeparator)
                maybeMore = maybeMore || (overlap == segment.size)
                if (overlap == Int32(groupingSeparator.size)) {
                    isGrouping = true
                    actualGroupingString = groupingSeparator
                }
            }
            if (!isGrouping && actualDecimalString.isNone()) {
                if (decimalUniSet.contains(cp)) {
                    isDecimal = true
                    actualDecimalString = UCharacter.toString(cp)
                }
            }
            if (!groupingDisabled && actualGroupingString.isNone() && actualDecimalString.isNone()) {
                if (groupingUniSet.contains(cp)) {
                    isGrouping = true
                    actualGroupingString = UCharacter.toString(cp)
                }
            }
            if (!isDecimal && !isGrouping) {
                break
            }
            if (isDecimal && integerOnly) {
                break
            } else if (currGroupSepType == 2 && isGrouping) {
                break
            }
            let prevValidSecondary = validateGroup(prevGroupSepType, prevGroupCount, false)
            let currValidPrimary = validateGroup(currGroupSepType, currGroupCount, true)
            if (!prevValidSecondary || (isDecimal && !currValidPrimary)) {
                if (isGrouping && currGroupCount == 0) {
                    if (!(currGroupSepType == 1)) {
                        throw AssertionError()
                    }
                } else if (requireGroupingMatch) {
                    digitsConsumed = None
                }
                break
            } else if (requireGroupingMatch && currGroupCount == 0 && currGroupSepType == 1) {
                break
            } else {
                prevGroupOffset = currGroupOffset
                prevGroupCount = currGroupCount
                if (isDecimal) {
                    prevGroupSepType = -1
                } else {
                    prevGroupSepType = currGroupSepType
                }
            }
            if (currGroupCount != 0) {
                currGroupOffset = segment.getOffset()
            }
            currGroupSepType = if (isGrouping) { 1 } else { 2 }
            currGroupCount = 0
            if (isGrouping) {
                segment.adjustOffset(Int32(actualGroupingString.size))
            } else {
                segment.adjustOffset(Int32(actualDecimalString.size))
            }
        }
        if (currGroupSepType != 2 && currGroupCount == 0) {
            maybeMore = true
            segment.setOffset(currGroupOffset)
            currGroupOffset = prevGroupOffset
            currGroupSepType = prevGroupSepType
            currGroupCount = prevGroupCount
            prevGroupOffset = -1
            prevGroupSepType = 0
            prevGroupCount = 1
        }
        var prevValidSecondary = validateGroup(prevGroupSepType, prevGroupCount, false)
        var currValidPrimary = validateGroup(currGroupSepType, currGroupCount, true)
        if (!requireGroupingMatch) {
            var digitsToRemove = 0
            if (!prevValidSecondary) {
                segment.setOffset(prevGroupOffset)
                digitsToRemove += prevGroupCount
                digitsToRemove += currGroupCount
            } else if (!currValidPrimary && (prevGroupSepType != 0 || prevGroupCount != 0)) {
                maybeMore = true
                segment.setOffset(currGroupOffset)
                digitsToRemove += currGroupCount
            }
            if (digitsToRemove != 0) {
                digitsConsumed.adjustMagnitude(-digitsToRemove)
                digitsConsumed.truncate()
            }
            prevValidSecondary = true
            currValidPrimary = true
        }
        if (currGroupSepType != 2 && (!prevValidSecondary || !currValidPrimary)) {
            digitsConsumed = None
        }
        if (digitsConsumed.isNone()) {
            maybeMore = maybeMore || (segment.size == 0)
            segment.setOffset(initialOffset)
            return maybeMore
        }
        digitsConsumed.adjustMagnitude(-digitsAfterDecimalPlace)
        if (exponentSign != 0 && segment.getOffset() != initialOffset) {
            var overflow = false
            if (digitsConsumed.fitsInLong()) {
                let exponentLong = digitsConsumed.toLong(false)
                if (!(exponentLong >= 0)) {
                    throw AssertionError()
                }
                if (exponentLong <= Int64(Int32.Max)) {
                    let exponentInt = Int32(exponentLong)
                    try {
                        result.quantity.adjustMagnitude(exponentSign * exponentInt)
                    } catch (e: ArithmeticException) {
                        overflow = true
                    }
                } else {
                    overflow = true
                }
            } else {
                overflow = true
            }
            if (overflow) {
                if (exponentSign == -1) {
                    result.quantity.clear()
                } else {
                    result.quantity = None
                    result.flags |= ParsedNumber.FLAG_INFINITY
                }
            }
        } else {
            result.quantity = digitsConsumed
        }
        if (actualDecimalString.isSome()) {
            result.flags |= ParsedNumber.FLAG_HAS_DECIMAL_SEPARATOR
        }
        result.setCharsConsumed(segment)
        return segment.size == 0 || maybeMore
    }

    private func validateGroup(sepType: Int32, count: Int32, isPrimary: Bool): Bool {
        if (requireGroupingMatch) {
            if (sepType == -1) {
                return true
            } else if (sepType == 0) {
                if (isPrimary) {
                    return true
                } else {
                    return count != 0 && count <= grouping2
                }
            } else if (sepType == 1) {
                if (isPrimary) {
                    return count == grouping1
                } else {
                    return count == grouping2
                }
            } else {
                if (!(sepType == 2)) {
                    throw AssertionError()
                }
                return true
            }
        } else {
            if (sepType == 1) {
                return count != 1
            } else {
                return true
            }
        }
    }

    public override func smokeTest(segment: StringSegment): Bool {
        if (digitStrings.isNone() && leadSet.isSome()) {
            return segment.startsWith(leadSet)
        }
        if (segment.startsWith(separatorSet) || UCharacter.isDigit(segment.getCodePoint())) {
            return true
        }
        if (digitStrings.isNone()) {
            return false
        }
        var i = 0
        while (i < Int32(digitStrings.size)) {
            if (segment.startsWith(digitStrings[Int64(i)])) {
                return true
            }
            i++
        }
        return false
    }

    public override func postProcess(result: ParsedNumber): Unit { }

    public override func toString(): String {
        return "<DecimalMatcher>"
    }
}
