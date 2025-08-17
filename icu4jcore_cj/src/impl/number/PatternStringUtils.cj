package icu4cj.impl.number

public class PatternStringUtils {

    public static func ignoreRoundingIncrement(roundIncrDec: BigDecimal, maxFrac: Int32): Bool {
        var roundIncr = roundIncrDec.doubleValue()
        if (roundIncr == 0.0) {
            return true
        }
        if (maxFrac < 0) {
            return false
        }
        var frac = 0
        roundIncr *= 2.0
        frac = 0
        while (frac <= maxFrac && roundIncr <= 1.0) {
            frac++
            roundIncr *= 10.0
        }
        return (frac > maxFrac)
    }

    public static func propertiesToPatternString(properties: DecimalFormatProperties): String {
        let sb = StringBuilder()
        let dosMax = 100
        var grouping1 = max(0, min(properties.getGroupingSize(), dosMax))
        var grouping2 = max(0, min(properties.getSecondaryGroupingSize(), dosMax))
        let useGrouping = properties.getGroupingUsed()
        let paddingWidth = min(properties.getFormatWidth(), dosMax)
        let paddingLocation = properties.getPadPosition()
        let paddingString = properties.getPadString()
        let minInt = max(0, min(properties.getMinimumIntegerDigits(), dosMax))
        let maxInt = min(properties.getMaximumIntegerDigits(), dosMax)
        let minFrac = max(0, min(properties.getMinimumFractionDigits(), dosMax))
        let maxFrac = min(properties.getMaximumFractionDigits(), dosMax)
        let minSig = min(properties.getMinimumSignificantDigits(), dosMax)
        let maxSig = min(properties.getMaximumSignificantDigits(), dosMax)
        let alwaysShowDecimal = properties.getDecimalSeparatorAlwaysShown()
        let currencyAsDecimal = properties.getCurrencyAsDecimal()
        let exponentDigits = min(properties.getMinimumExponentDigits(), dosMax)
        let exponentShowPlusSign = properties.getExponentSignAlwaysShown()
        let affixes = PropertiesAffixPatternProvider.forProperties(properties)
        sb.append(affixes.getString(AffixPatternProvider.FLAG_POS_PREFIX))
        var afterPrefixPos = Int32(sb.size)
        if (!useGrouping) {
            grouping1 = 0
            grouping2 = 0
        } else if (grouping1 == grouping2) {
            grouping1 = 0
        }
        let groupingLength = grouping1 + grouping2 + 1
        let roundingInterval = properties.getRoundingIncrement()
        let digitsString = StringBuilder()
        var digitsStringScale = 0
        if (maxSig != min(dosMax, -1)) {
            while (Int32(digitsString.size) < minSig) {
                digitsString.append('@')
            }
            while (Int32(digitsString.size) < maxSig) {
                digitsString.append('#')
            }
        } else if (roundingInterval.isSome() && !ignoreRoundingIncrement(roundingInterval, maxFrac)) {
            digitsStringScale = -roundingInterval.scale()
            let str = roundingInterval.scaleByPowerOfTen(roundingInterval.scale()).toPlainString()
            if (Char(str[0]) == '-') {
                digitsString.append(str, 1, Int32(str.size))
            } else {
                digitsString.append(str)
            }
        }
        while (Int32(digitsString.size) + digitsStringScale < minInt) {
            digitsString.insert(0, '0')
        }
        while (-digitsStringScale < minFrac) {
            digitsString.append('0')
            digitsStringScale--
        }
        var m0 = max(groupingLength, Int32(digitsString.size) + digitsStringScale)
        m0 = if (maxInt != dosMax) { max(maxInt, m0) - 1 } else { m0 - 1 }
        let mN = if (maxFrac != dosMax) { min(-maxFrac, digitsStringScale) } else { digitsStringScale }
        var magnitude = m0
        while (magnitude >= mN) {
            let di = Int32(digitsString.size) + digitsStringScale - magnitude - 1
            if (di < 0 || di >= Int32(digitsString.size)) {
                sb.append('#')
            } else {
                sb.append(digitsString.get(Int64(di)))
            }
            if (magnitude == 0 && (alwaysShowDecimal || mN < 0)) {
                if (currencyAsDecimal) {
                    sb.append('\u{00a4}')
                } else {
                    sb.append('.')
                }
            }
            if (!useGrouping) {
                continue
            }
            if (magnitude > 0 && magnitude == grouping1) {
                sb.append(',')
            }
            if (magnitude > grouping1 && grouping2 > 0 && (magnitude - grouping1) % grouping2 == 0) {
                sb.append(',')
            }
            magnitude--
        }
        if (exponentDigits != min(dosMax, -1)) {
            sb.append('E')
            if (exponentShowPlusSign) {
                sb.append('+')
            }
            var i = 0
            while (i < exponentDigits) {
                sb.append('0')
                i++
            }
        }
        var beforeSuffixPos = Int32(sb.size)
        sb.append(affixes.getString(AffixPatternProvider.FLAG_POS_SUFFIX))
        if (paddingWidth > 0) {
            while (paddingWidth - Int32(sb.size) > 0) {
                sb.insert(Int64(afterPrefixPos), '#')
                beforeSuffixPos++
            }
            let addedLength: Int32
            match (paddingLocation) {
                case Padder_PadPosition.BEFORE_PREFIX =>
                    addedLength = PatternStringUtils.escapePaddingString(paddingString, sb, 0)
                    sb.insert(0, '*')
                    afterPrefixPos += addedLength + 1
                    beforeSuffixPos += addedLength + 1
                case Padder_PadPosition.AFTER_PREFIX =>
                    addedLength = PatternStringUtils.escapePaddingString(paddingString, sb, afterPrefixPos)
                    sb.insert(Int64(afterPrefixPos), '*')
                    afterPrefixPos += addedLength + 1
                    beforeSuffixPos += addedLength + 1
                case Padder_PadPosition.BEFORE_SUFFIX =>
                    PatternStringUtils.escapePaddingString(paddingString, sb, beforeSuffixPos)
                    sb.insert(Int64(beforeSuffixPos), '*')
                case Padder_PadPosition.AFTER_SUFFIX =>
                    sb.append('*')
                    PatternStringUtils.escapePaddingString(paddingString, sb, Int32(sb.size))
                case _ => ()
            }
        }
        if (affixes.hasNegativeSubpattern()) {
            sb.append(';')
            sb.append(affixes.getString(AffixPatternProvider.FLAG_NEG_PREFIX))
            sb.append(sb.toString(), afterPrefixPos, beforeSuffixPos)
            sb.append(affixes.getString(AffixPatternProvider.FLAG_NEG_SUFFIX))
        }
        return sb.toString()
    }

    private static func escapePaddingString(input: String, output: StringBuilder, startIndex: Int32): Int32 {
        var tempinput = input
        if (tempinput.isNone() || tempinput.size == 0) {
            tempinput = Padder.FALLBACK_PADDING_STRING
        }
        let startLength = Int32(output.size)
        if (tempinput.size == 1) {
            if (refEq(tempinput, "'")) {
                output.insert(Int64(startIndex), "''")
            } else {
                output.insert(Int64(startIndex), tempinput)
            }
        } else {
            output.insert(Int64(startIndex), '\'')
            var offset = 1
            var i = 0
            while (i < tempinput.size) {
                let ch = tempinput[i]
                if (ch == '\'') {
                    output.insert(Int64(startIndex + offset), "''")
                    offset += 2
                } else {
                    output.insert(Int64(startIndex + offset), ch)
                    offset += 1
                }
                i++
            }
            output.insert(Int64(startIndex + offset), '\'')
        }
        return Int32(output.size) - startLength
    }

    public static func convertLocalized(input: String, symbols: DecimalFormatSymbols, toLocalized: Bool): String {
        if (input.isNone()) {
            return None
        }
        let table = Array<Array<String>>(21) { _ => Array<String>(2) }
        let standIdx = if (toLocalized) { 0 } else { 1 }
        let localIdx = if (toLocalized) { 1 } else { 0 }
        table[0][Int64(standIdx)] = "%"
        table[0][Int64(localIdx)] = symbols.getPercentString()
        table[1][Int64(standIdx)] = "\u{2030}"
        table[1][Int64(localIdx)] = symbols.getPerMillString()
        table[2][Int64(standIdx)] = "."
        table[2][Int64(localIdx)] = symbols.getDecimalSeparatorString()
        table[3][Int64(standIdx)] = ","
        table[3][Int64(localIdx)] = symbols.getGroupingSeparatorString()
        table[4][Int64(standIdx)] = "-"
        table[4][Int64(localIdx)] = symbols.getMinusSignString()
        table[5][Int64(standIdx)] = "+"
        table[5][Int64(localIdx)] = symbols.getPlusSignString()
        table[6][Int64(standIdx)] = ";"
        table[6][Int64(localIdx)] = Character.toString(symbols.getPatternSeparator())
        table[7][Int64(standIdx)] = "@"
        table[7][Int64(localIdx)] = Character.toString(symbols.getSignificantDigit())
        table[8][Int64(standIdx)] = "E"
        table[8][Int64(localIdx)] = symbols.getExponentSeparator()
        table[9][Int64(standIdx)] = "*"
        table[9][Int64(localIdx)] = Character.toString(symbols.getPadEscape())
        table[10][Int64(standIdx)] = "#"
        table[10][Int64(localIdx)] = Character.toString(symbols.getDigit())
        } while (false)
        } while (false)
        let result = StringBuilder()
        var state = 0
    public static func patternInfoToStringBuilder(patternInfo: AffixPatternProvider, isPrefix: Bool, patternSignType: PatternStringUtils_PatternSignType, approximately: Bool, plural: StandardPlural, perMilleReplacesPercent: Bool, output: StringBuilder): Unit {
        let plusReplacesMinusSign = (refEq(patternSignType, PatternStringUtils_PatternSignType.POS_SIGN)) && !patternInfo.positiveHasPlusSign()
        let useNegativeAffixPattern = patternInfo.hasNegativeSubpattern() && (refEq(patternSignType, PatternStringUtils_PatternSignType.NEG) || (patternInfo.negativeHasMinusSign() && (plusReplacesMinusSign || approximately)))
        var flags = 0
        if (useNegativeAffixPattern) {
            flags |= AffixPatternProvider_Flags.NEGATIVE_SUBPATTERN
        }
        if (isPrefix) {
            flags |= AffixPatternProvider_Flags.PREFIX
        }
        if (plural.isSome()) {
            if (!(plural.ordinal == (AffixPatternProvider_Flags.PLURAL_MASK & plural.ordinal))) {
                throw AssertionError()
            }
            flags |= plural.ordinal
        }
        let prependSign: Bool
        if (!isPrefix || useNegativeAffixPattern) {
            prependSign = false
        } else if (refEq(patternSignType, PatternStringUtils_PatternSignType.NEG)) {
            prependSign = true
        } else {
            prependSign = plusReplacesMinusSign || approximately
        }
        var signSymbols: String = "-"
        if (approximately) {
            if (plusReplacesMinusSign) {
                signSymbols = "~+"
            } else if (refEq(patternSignType, PatternStringUtils_PatternSignType.NEG)) {
                signSymbols = "~-"
            } else {
                signSymbols = "~"
            }
        } else if (plusReplacesMinusSign) {
            signSymbols = "+"
        }
        let length = patternInfo.length(flags) + (if (prependSign) { 1 } else { 0 })
        output.setLength(0)
        var index = 0
        while (index < length) {
            var candidate: Char = '\u{0000}'
            if (prependSign && index == 0) {
                candidate = '-'
            } else if (prependSign) {
                candidate = patternInfo.toRuneArray()[flags, index - 1]
            } else {
                candidate = patternInfo.toRuneArray()[flags, index]
            }
            if (candidate == '-') {
                if (Int32(signSymbols.size) == 1) {
                    candidate = Char(signSymbols[0])
                } else {
                    output.append(Char(signSymbols[0]))
                    candidate = Char(signSymbols[1])
                }
            }
            if (perMilleReplacesPercent && candidate == '%') {
                candidate = '\u{2030}'
            }
            output.append(candidate)
            index++
        }
    }

    public static func resolveSignDisplay(signDisplay: NumberFormatter_SignDisplay, signum: Modifier_Signum): PatternStringUtils_PatternSignType {
        match (signDisplay) {
            case NumberFormatter_SignDisplay.AUTO | NumberFormatter_SignDisplay.ACCOUNTING => match (signum) {
                case Modifier_Signum.NEG | Modifier_Signum.NEG_ZERO => return PatternStringUtils_PatternSignType.NEG
                case Modifier_Signum.POS_ZERO | Modifier_Signum.POS => return PatternStringUtils_PatternSignType.POS
                case _ => ()
            }
            case NumberFormatter_SignDisplay.ALWAYS | NumberFormatter_SignDisplay.ACCOUNTING_ALWAYS => match (signum) {
                case Modifier_Signum.NEG | Modifier_Signum.NEG_ZERO => return PatternStringUtils_PatternSignType.NEG
                case Modifier_Signum.POS_ZERO | Modifier_Signum.POS => return PatternStringUtils_PatternSignType.POS_SIGN
                case _ => ()
            }
            case NumberFormatter_SignDisplay.EXCEPT_ZERO | NumberFormatter_SignDisplay.ACCOUNTING_EXCEPT_ZERO => match (signum) {
                case Modifier_Signum.NEG => return PatternStringUtils_PatternSignType.NEG
                case Modifier_Signum.NEG_ZERO | Modifier_Signum.POS_ZERO => return PatternStringUtils_PatternSignType.POS
                case Modifier_Signum.POS => return PatternStringUtils_PatternSignType.POS_SIGN
                case _ => ()
            }
            case NumberFormatter_SignDisplay.NEGATIVE | NumberFormatter_SignDisplay.ACCOUNTING_NEGATIVE => match (signum) {
                case Modifier_Signum.NEG => return PatternStringUtils_PatternSignType.NEG
                case Modifier_Signum.NEG_ZERO | Modifier_Signum.POS_ZERO | Modifier_Signum.POS => return PatternStringUtils_PatternSignType.POS
                case _ => ()
            }
            case NumberFormatter_SignDisplay.NEVER => return PatternStringUtils_PatternSignType.POS
            case _ => ()
        }
        throw Exception("Unreachable")
    }
}


public class PatternStringUtils_PatternSignType <: Enum<PatternStringUtils_PatternSignType> {
    public static let POS = PatternStringUtils_PatternSignType("POS", 0)

    public static let POS_SIGN = PatternStringUtils_PatternSignType("POS_SIGN", 1)

    public static let NEG = PatternStringUtils_PatternSignType("NEG", 2)

    private static func _values(): Array<PatternStringUtils_PatternSignType> {
        return [PatternStringUtils_PatternSignType.POS, PatternStringUtils_PatternSignType.POS_SIGN, PatternStringUtils_PatternSignType.NEG]
    }

    private static let _VALUES = PatternStringUtils_PatternSignType._values()

    public static func values(): Array<PatternStringUtils_PatternSignType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): PatternStringUtils_PatternSignType {
        return (TypeInfo.of<PatternStringUtils_PatternSignType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as PatternStringUtils_PatternSignType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public static let VALUES = PatternStringUtils_PatternSignType.values()
}
