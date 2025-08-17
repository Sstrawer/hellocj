package icu4cj.impl.number


public class PatternStringParser {

    public static let IGNORE_ROUNDING_NEVER = 0

    public static let IGNORE_ROUNDING_IF_CURRENCY = 1

    public static let IGNORE_ROUNDING_ALWAYS = 2

    public static func parseToPatternInfo(patternString: String): PatternStringParser_ParsedPatternInfo {
        let state = PatternStringParser_ParserState(patternString)
        let result = PatternStringParser_ParsedPatternInfo(patternString)
        consumePattern(state, result)
        return result
    }

    public static func parseToProperties(pattern: String, ignoreRounding: Int32): DecimalFormatProperties {
        let properties = DecimalFormatProperties()
        parseToExistingPropertiesImpl(pattern, properties, ignoreRounding)
        return properties
    }

    public static func parseToProperties(pattern: String): DecimalFormatProperties {
        return parseToProperties(pattern, PatternStringParser.IGNORE_ROUNDING_NEVER)
    }

    public static func parseToExistingProperties(pattern: String, properties: DecimalFormatProperties, ignoreRounding: Int32): Unit {
        parseToExistingPropertiesImpl(pattern, properties, ignoreRounding)
    }

    public static func parseToExistingProperties(pattern: String, properties: DecimalFormatProperties): Unit {
        parseToExistingProperties(pattern, properties, PatternStringParser.IGNORE_ROUNDING_NEVER)
    }

    private static func consumePattern(state: PatternStringParser_ParserState, result: PatternStringParser_ParsedPatternInfo): Unit {
        result.positive = PatternStringParser_ParsedSubpatternInfo()
        consumeSubpattern(state, result.positive)
        if (state.peek() == Int32(UInt32(';'))) {
            state.next()
            if (state.peek() != -1) {
                result.negative = PatternStringParser_ParsedSubpatternInfo()
                consumeSubpattern(state, result.negative)
            }
        }
        if (state.peek() != -1) {
            throw state.toParseException("Found unquoted special character")
        }
    }

    private static func consumeSubpattern(state: PatternStringParser_ParserState, result: PatternStringParser_ParsedSubpatternInfo): Unit {
        consumePadding(state, result, Padder_PadPosition.BEFORE_PREFIX)
        result.prefixEndpoints = consumeAffix(state, result)
        consumePadding(state, result, Padder_PadPosition.AFTER_PREFIX)
        consumeFormat(state, result)
        consumeExponent(state, result)
        consumePadding(state, result, Padder_PadPosition.BEFORE_SUFFIX)
        result.suffixEndpoints = consumeAffix(state, result)
        consumePadding(state, result, Padder_PadPosition.AFTER_SUFFIX)
    }

    private static func consumePadding(state: PatternStringParser_ParserState, result: PatternStringParser_ParsedSubpatternInfo, paddingLocation: Padder_PadPosition): Unit {
        if (state.peek() != Int32(UInt32('*'))) {
            return
        }
        if (result.paddingLocation.isSome()) {
            throw state.toParseException("Cannot have multiple pad specifiers")
        }
        result.paddingLocation = paddingLocation
        state.next()
        result.paddingEndpoints |= Int64(state.offset)
        consumeLiteral(state)
        result.paddingEndpoints |= shl(Int64(state.offset), 32)
    }

    private static func consumeAffix(state: PatternStringParser_ParserState, result: PatternStringParser_ParsedSubpatternInfo): Int64 {
        var endpoints = Int64(state.offset)
        let cp = state.peek()
        if (cp == Int32(UInt32('@')) || cp == Int32(UInt32(';')) || cp == Int32(UInt32('*')) || cp == Int32(UInt32('.')) || cp == Int32(UInt32(',')) || (cp >= Int32(UInt32('0')) && cp <= Int32(UInt32('9'))) {
            // Continue processing
        } else if (cp == -1) {
            break outer
        } else if (cp == Int32(UInt32('%'))) {
            result.hasPercentSign = true
        } else if (cp == Int32(UInt32('\u{2030}'))) {
            result.hasPerMilleSign = true
        } else if (cp == Int32(UInt32('\u{00a4}'))) {
            result.hasCurrencySign = true
        } else if (cp == Int32(UInt32('-'))) {
            result.hasMinusSign = true
        } else if (cp == Int32(UInt32('+'))) {
            result.hasPlusSign = true
        }
        consumeLiteral(state)
        endpoints |= shl(Int64(state.offset), 32)
        return endpoints
    }

    private static func consumeLiteral(state: PatternStringParser_ParserState): Unit {
        if (state.peek() == -1) {
            throw state.toParseException("Expected unquoted literal but found EOL")
        } else if (state.peek() == Int32(UInt32('\''))) {
            state.next()
            while (state.peek() != Int32(UInt32('\''))) {
                if (state.peek() == -1) {
                    throw state.toParseException("Expected quoted literal but found EOL")
                } else {
                    state.next()
                }
            }
            state.next()
        } else {
            state.next()
        }
    }

    private static func consumeFormat(state: PatternStringParser_ParserState, result: PatternStringParser_ParsedSubpatternInfo): Unit {
        consumeIntegerFormat(state, result)
        if (state.peek() == Int32(UInt32('.'))) {
            state.next()
            result.hasDecimal = true
            result.widthExceptAffixes += 1
            consumeFractionFormat(state, result)
        } else if (state.peek() == Int32(UInt32('\u{00a4}'))) {
            let cp2 = state.peek2()
            if (cp2 == Int32(UInt32('#')) || (cp2 >= Int32(UInt32('0')) && cp2 <= Int32(UInt32('3'))) {

            } else if (cp2 >= Int32(UInt32('4')) && cp2 <= Int32(UInt32('9'))) {
                // Continue processing
            } else {
                return
            }
            result.hasCurrencySign = true
            result.hasCurrencyDecimal = true
            result.hasDecimal = true
            result.widthExceptAffixes += 1
            state.next()
            consumeFractionFormat(state, result)
        }
    }

    private static func consumeIntegerFormat(state: PatternStringParser_ParserState, result: PatternStringParser_ParsedSubpatternInfo): Unit {
            let cp = state.peek()
            if (cp == Int32(UInt32('#'))) {
                if (result.integerNumerals > 0) {
                    throw state.toParseException("# cannot follow 0 before decimal point")
                }
                result.widthExceptAffixes += 1
                result.groupingSizes += 1
                if (result.integerAtSigns > 0) {
                    result.integerTrailingHashSigns += 1
                } else {
                    result.integerLeadingHashSigns += 1
                }
                result.integerTotal += 1

            } else if (cp == Int32(UInt32('@'))) {
                if (result.integerNumerals > 0) {
                    throw state.toParseException("Cannot mix 0 and @")
                }
                if (result.integerTrailingHashSigns > 0) {
                    throw state.toParseException("Cannot nest # inside of a run of @")
                }
                result.widthExceptAffixes += 1
                result.groupingSizes += 1
                result.integerAtSigns += 1
                result.integerTotal += 1

            } else if (cp >= Int32(UInt32('0')) && cp <= Int32(UInt32('5'))) {
                if (result.integerAtSigns > 0) {
                    throw state.toParseException("Cannot mix @ and 0")
                }
                result.widthExceptAffixes += 1
                result.groupingSizes += 1
                result.integerNumerals += 1
                result.integerTotal += 1
                if (state.peek() != Int32(UInt32('0')) && result.rounding == None) {
                    result.rounding = DecimalQuantity_DualStorageBCD()
                }
                if (result.rounding.isSome()) {
                    result.rounding.unwrap().appendDigit(Int8(state.peek() - Int32(UInt32('0'))), 0, true)
                }
            } else if (cp >= Int32(UInt32('6')) && cp <= Int32(UInt32('9'))) {
                if (result.integerAtSigns > 0) {
                    throw state.toParseException("Cannot mix @ and 0")
                }
                result.widthExceptAffixes += 1
                result.groupingSizes += 1
                result.integerNumerals += 1
                result.integerTotal += 1
                if (state.peek() != Int32(UInt32('0')) && result.rounding == None) {
                    result.rounding = DecimalQuantity_DualStorageBCD()
                }
                if (result.rounding.isSome()) {
                    result.rounding.unwrap().appendDigit(Int8(state.peek() - Int32(UInt32('0'))), 0, true)
                }
            } else {
                break outer
            }
            state.next()
        }
        let grouping1 = Int16(result.groupingSizes & 65535)
        let grouping2 = Int16((ushr(result.groupingSizes, 16)) & 65535)
        let grouping3 = Int16((ushr(result.groupingSizes, 32)) & 65535)
        if (Int32(grouping1) == 0 && Int32(grouping2) != -1) {
            throw state.toParseException("Trailing grouping separator is invalid")
        }
        if (Int32(grouping2) == 0 && Int32(grouping3) != -1) {
            throw state.toParseException("Grouping width of zero is invalid")
        }
    }

    private static func consumeFractionFormat(state: PatternStringParser_ParserState, result: PatternStringParser_ParsedSubpatternInfo): Unit {
        var zeroCounter = 0
        while (true) {
            let cp = state.peek()
        if (cp == Int32(UInt32('#'))) {
            result.widthExceptAffixes += 1
            result.fractionHashSigns += 1
            result.fractionTotal += 1
            zeroCounter++

        } else if (cp >= Int32(UInt32('0')) && cp <= Int32(UInt32('9'))) {
            if (result.fractionHashSigns > 0) {
                throw state.toParseException("0 cannot follow # after decimal point")
            }
            result.widthExceptAffixes += 1
            result.fractionNumerals += 1
            result.fractionTotal += 1
            if (state.peek() == Int32(UInt32('0'))) {
                zeroCounter++
            } else {
                if (result.rounding == None) {
                    result.rounding = DecimalQuantity_DualStorageBCD()
                }
                result.rounding.unwrap().appendDigit(Int8(state.peek() - Int32(UInt32('0'))), zeroCounter, false)
                zeroCounter = 0
            }
        } else {
            return
        }
            state.next()
        }
    }

    private static func consumeExponent(state: PatternStringParser_ParserState, result: PatternStringParser_ParsedSubpatternInfo): Unit {
        if (state.peek() != Int32(UInt32('E'))) {
            return
        }
        if ((result.groupingSizes & 4294901760) != 4294901760) {
            throw state.toParseException("Cannot have grouping separator in scientific notation")
        }
        state.next()
        result.widthExceptAffixes++
        if (state.peek() == Int32(UInt32('+'))) {
            state.next()
            result.exponentHasPlusSign = true
            result.widthExceptAffixes++
        }
        while (state.peek() == Int32(UInt32('0'))) {
            state.next()
            result.exponentZeros += 1
            result.widthExceptAffixes++
        }
    }

    private static func parseToExistingPropertiesImpl(pattern: String, properties: DecimalFormatProperties, ignoreRounding: Int32): Unit {
        if (pattern.isNone() || Int32(pattern.size) == 0) {
            properties.clear()
            return
        }
        let patternInfo = parseToPatternInfo(pattern)
        patternInfoToProperties(properties, patternInfo, ignoreRounding)
    }

    private static func patternInfoToProperties(properties: DecimalFormatProperties, patternInfo: PatternStringParser_ParsedPatternInfo, _ignoreRounding: Int32): Unit {
        let positive = patternInfo.positive
        let ignoreRounding: Bool
        if (_ignoreRounding == PatternStringParser.IGNORE_ROUNDING_NEVER) {
            ignoreRounding = false
        } else if (_ignoreRounding == PatternStringParser.IGNORE_ROUNDING_IF_CURRENCY) {
            ignoreRounding = positive.hasCurrencySign
        } else {
            if (!(_ignoreRounding == PatternStringParser.IGNORE_ROUNDING_ALWAYS)) {
                throw AssertionError()
            }
            ignoreRounding = true
        }
        let grouping1 = Int16(positive.groupingSizes & 65535)
        let grouping2 = Int16((ushr(positive.groupingSizes, 16)) & 65535)
        let grouping3 = Int16((ushr(positive.groupingSizes, 32)) & 65535)
        if (Int32(grouping2) != -1) {
            properties.setGroupingSize(Int32(grouping1))
            properties.setGroupingUsed(true)
        } else {
            properties.setGroupingSize(-1)
            properties.setGroupingUsed(false)
        }
        if (Int32(grouping3) != -1) {
            properties.setSecondaryGroupingSize(Int32(grouping2))
        } else {
            properties.setSecondaryGroupingSize(-1)
        }
        let minInt: Int32
        let minFrac: Int32
        if (positive.integerTotal == 0 && positive.fractionTotal > 0) {
            minInt = 0
            minFrac = max(1, positive.fractionNumerals)
        } else if (positive.integerNumerals == 0 && positive.fractionNumerals == 0) {
            minInt = 1
            minFrac = 0
        } else {
            minInt = positive.integerNumerals
            minFrac = positive.fractionNumerals
        }
        if (positive.integerAtSigns > 0) {
            properties.setMinimumFractionDigits(-1)
            properties.setMaximumFractionDigits(-1)
            properties.setRoundingIncrement(None)
            properties.setMinimumSignificantDigits(positive.integerAtSigns)
            properties.setMaximumSignificantDigits(positive.integerAtSigns + positive.integerTrailingHashSigns)
        } else if (positive.rounding.isSome()) {
            if (!ignoreRounding) {
                properties.setMinimumFractionDigits(minFrac)
                properties.setMaximumFractionDigits(positive.fractionTotal)
                properties.setRoundingIncrement(positive.rounding.toBigDecimal().setScale(positive.fractionNumerals))
            } else {
                properties.setMinimumFractionDigits(-1)
                properties.setMaximumFractionDigits(-1)
                properties.setRoundingIncrement(None)
            }
            properties.setMinimumSignificantDigits(-1)
            properties.setMaximumSignificantDigits(-1)
        } else {
            if (!ignoreRounding) {
                properties.setMinimumFractionDigits(minFrac)
                properties.setMaximumFractionDigits(positive.fractionTotal)
                properties.setRoundingIncrement(None)
            } else {
                properties.setMinimumFractionDigits(-1)
                properties.setMaximumFractionDigits(-1)
                properties.setRoundingIncrement(None)
            }
            properties.setMinimumSignificantDigits(-1)
            properties.setMaximumSignificantDigits(-1)
        }
        if (positive.hasDecimal && positive.fractionTotal == 0) {
            properties.setDecimalSeparatorAlwaysShown(true)
        } else {
            properties.setDecimalSeparatorAlwaysShown(false)
        }
        properties.setCurrencyAsDecimal(positive.hasCurrencyDecimal)
        if (positive.exponentZeros > 0) {
            properties.setExponentSignAlwaysShown(positive.exponentHasPlusSign)
            properties.setMinimumExponentDigits(positive.exponentZeros)
            if (positive.integerAtSigns == 0) {
                properties.setMinimumIntegerDigits(positive.integerNumerals)
                properties.setMaximumIntegerDigits(positive.integerTotal)
            } else {
                properties.setMinimumIntegerDigits(1)
                properties.setMaximumIntegerDigits(-1)
            }
        } else {
            properties.setExponentSignAlwaysShown(false)
            properties.setMinimumExponentDigits(-1)
            properties.setMinimumIntegerDigits(minInt)
            properties.setMaximumIntegerDigits(-1)
        }
        let posPrefix = patternInfo.getString(AffixPatternProvider_Flags.PREFIX)
        let posSuffix = patternInfo.getString(0)
        if (positive.paddingLocation.isSome()) {
            let paddingWidth = positive.widthExceptAffixes + AffixUtils.estimateLength(posPrefix) + AffixUtils.estimateLength(posSuffix)
            properties.setFormatWidth(paddingWidth)
            let rawPaddingString = patternInfo.getString(AffixPatternProvider_Flags.PADDING)
            if (Int32(rawPaddingString.size) == 1) {
                properties.setPadString(rawPaddingString)
            } else if (Int32(rawPaddingString.size) == 2) {
                if (Char(rawPaddingString[0]) == '\'') {
                    properties.setPadString("'")
                } else {
                    properties.setPadString(rawPaddingString)
                }
            } else {
                properties.setPadString(rawPaddingString[1..Int64(Int32(rawPaddingString.size) - 1)])
            }
            if (!positive.paddingLocation.isSome()) {
                throw AssertionError()
            }
            properties.setPadPosition(positive.paddingLocation)
        } else {
            properties.setFormatWidth(-1)
            properties.setPadString(None)
            properties.setPadPosition(None)
        }
        properties.setPositivePrefixPattern(posPrefix)
        properties.setPositiveSuffixPattern(posSuffix)
        if (patternInfo.negative.isSome()) {
            properties.setNegativePrefixPattern(patternInfo.getString(AffixPatternProvider_Flags.NEGATIVE_SUBPATTERN | AffixPatternProvider_Flags.PREFIX))
            properties.setNegativeSuffixPattern(patternInfo.getString(AffixPatternProvider_Flags.NEGATIVE_SUBPATTERN))
        } else {
            properties.setNegativePrefixPattern(None)
            properties.setNegativeSuffixPattern(None)
        }
        if (positive.hasPercentSign) {
            properties.setMagnitudeMultiplier(2)
        } else if (positive.hasPerMilleSign) {
            properties.setMagnitudeMultiplier(3)
        } else {
            properties.setMagnitudeMultiplier(0)
        }
    }
}


public class PatternStringParser_ParsedPatternInfo <: AffixPatternProvider {
    public var pattern: String

    public var positive: PatternStringParser_ParsedSubpatternInfo

    public var negative: PatternStringParser_ParsedSubpatternInfo

    init(pattern: String) {
        this.pattern = pattern
    }

    public override func charAt(flags: Int32, index: Int32): Char {
        let endpoints = getEndpoints(flags)
        let left = Int32(endpoints & -1)
        let right = Int32(ushr(endpoints, 32))
        if (index < 0 || index >= right - left) {
            throw IndexOutOfBoundsException()
        }
        return Char(pattern[Int64(left + index)])
    }

    public override func length(flags: Int32): Int32 {
        return getLengthFromEndpoints(getEndpoints(flags))
    }

    public static func getLengthFromEndpoints(endpoints: Int64): Int32 {
        let left = Int32(endpoints & -1)
        let right = Int32(ushr(endpoints, 32))
        return right - left
    }

    public override func getString(flags: Int32): String {
        let endpoints = getEndpoints(flags)
        let left = Int32(endpoints & -1)
        let right = Int32(ushr(endpoints, 32))
        if (left == right) {
            return ""
        }
        return pattern[Int64(left)..Int64(right)]
    }

    private func getEndpoints(flags: Int32): Int64 {
        let prefix = (flags & AffixPatternProvider_Flags.PREFIX) != 0
        let isNegative = (flags & AffixPatternProvider_Flags.NEGATIVE_SUBPATTERN) != 0
        let padding = (flags & AffixPatternProvider_Flags.PADDING) != 0
        if (isNegative && padding) {
            return negative.paddingEndpoints
        } else if (padding) {
            return positive.paddingEndpoints
        } else if (prefix && isNegative) {
            return negative.prefixEndpoints
        } else if (prefix) {
            return positive.prefixEndpoints
        } else if (isNegative) {
            return negative.suffixEndpoints
        } else {
            return positive.suffixEndpoints
        }
    }

    public override func positiveHasPlusSign(): Bool {
        return positive.hasPlusSign
    }

    public override func hasNegativeSubpattern(): Bool {
        return negative.isSome()
    }

    public override func negativeHasMinusSign(): Bool {
        return negative.hasMinusSign
    }

    public override func hasCurrencySign(): Bool {
        return positive.hasCurrencySign || (negative.isSome() && negative.hasCurrencySign)
    }

    public override func containsSymbolType(Type: Int32): Bool {
        return AffixUtils.containsType(pattern, Type)
    }

    public override func hasBody(): Bool {
        return positive.integerTotal > 0
    }

    public override func currencyAsDecimal(): Bool {
        return positive.hasCurrencyDecimal
    }
}


public class PatternStringParser_ParsedSubpatternInfo {

    public var groupingSizes = 281474976645120

    public var integerLeadingHashSigns = 0

    public var integerTrailingHashSigns = 0

    public var integerNumerals = 0

    public var integerAtSigns = 0

    public var integerTotal = 0

    public var fractionNumerals = 0

    public var fractionHashSigns = 0

    public var fractionTotal = 0

    public var hasDecimal = false

    public var widthExceptAffixes = 0

    public var paddingLocation: Padder_PadPosition

    public var rounding: DecimalQuantity_DualStorageBCD

    public var exponentHasPlusSign = false

    public var exponentZeros = 0

    public var hasPercentSign = false

    public var hasPerMilleSign = false

    public var hasCurrencySign = false

    public var hasCurrencyDecimal = false

    public var hasMinusSign = false

    public var hasPlusSign = false

    public var prefixEndpoints = 0

    public var suffixEndpoints = 0

    public var paddingEndpoints = 0
}


class PatternStringParser_ParserState {
    let pattern: String

    var offset: Int32 = 0

    init(pattern: String) {
        this.pattern = pattern
        this.offset = 0
    }

    public func peek(): Int32 {
        if (offset == Int32(pattern.size)) {
            return -1
        } else {
            return pattern.codePointAt(offset)
        }
    }

    public func peek2(): Int32 {
        if (offset == Int32(pattern.size)) {
            return -1
        }
        let cp1 = pattern.codePointAt(offset)
        let offset2 = offset + Character.charCount(cp1)
        if (offset2 == Int32(pattern.size)) {
            return -1
        }
        return pattern.codePointAt(offset2)
    }

    public func next(): Int32 {
        let codePoint = peek()
        offset += Character.charCount(codePoint)
        return codePoint
    }

    public func toParseException(message: String): IllegalArgumentException {
        let sb = StringBuilder()
        sb.append("Malformed pattern for ICU DecimalFormat: \"")
        sb.append(pattern)
        sb.append("\": ")
        sb.append(message)
        sb.append(" at position ")
        sb.append(offset)
        return IllegalArgumentException(sb.toString())
    }
}
