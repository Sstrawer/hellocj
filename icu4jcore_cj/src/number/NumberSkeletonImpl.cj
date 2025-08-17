package icu4cj.number


class NumberSkeletonImpl {

    static let WILDCARD_CHAR = '*'

    static let ALT_WILDCARD_CHAR = '+'

    static func isWildcardChar(c: Char): Bool {
        return c == WILDCARD_CHAR || c == ALT_WILDCARD_CHAR
    }

    static let STEM_ENUM_VALUES = NumberSkeletonImpl_StemEnum.values()

    static let SERIALIZED_STEM_TRIE = buildStemTrie()

    static func buildStemTrie(): String {
        let b = CharsTrieBuilder()
        b.add("compact-short", NumberSkeletonImpl_StemEnum.STEM_COMPACT_SHORT.ordinal)
        b.add("compact-long", NumberSkeletonImpl_StemEnum.STEM_COMPACT_LONG.ordinal)
        b.add("scientific", NumberSkeletonImpl_StemEnum.STEM_SCIENTIFIC.ordinal)
        b.add("engineering", NumberSkeletonImpl_StemEnum.STEM_ENGINEERING.ordinal)
        b.add("notation-simple", NumberSkeletonImpl_StemEnum.STEM_NOTATION_SIMPLE.ordinal)
        b.add("base-unit", NumberSkeletonImpl_StemEnum.STEM_BASE_UNIT.ordinal)
        b.add("percent", NumberSkeletonImpl_StemEnum.STEM_PERCENT.ordinal)
        b.add("permille", NumberSkeletonImpl_StemEnum.STEM_PERMILLE.ordinal)
        b.add("precision-integer", NumberSkeletonImpl_StemEnum.STEM_PRECISION_INTEGER.ordinal)
        b.add("precision-unlimited", NumberSkeletonImpl_StemEnum.STEM_PRECISION_UNLIMITED.ordinal)
        b.add("precision-currency-standard", NumberSkeletonImpl_StemEnum.STEM_PRECISION_CURRENCY_STANDARD.ordinal)
        b.add("precision-currency-cash", NumberSkeletonImpl_StemEnum.STEM_PRECISION_CURRENCY_CASH.ordinal)
        b.add("rounding-mode-ceiling", NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_CEILING.ordinal)
        b.add("rounding-mode-floor", NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_FLOOR.ordinal)
        b.add("rounding-mode-down", NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_DOWN.ordinal)
        b.add("rounding-mode-up", NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_UP.ordinal)
        b.add("rounding-mode-half-even", NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_HALF_EVEN.ordinal)
        b.add("rounding-mode-half-down", NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_HALF_DOWN.ordinal)
        b.add("rounding-mode-half-up", NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_HALF_UP.ordinal)
        b.add("rounding-mode-unnecessary", NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_UNNECESSARY.ordinal)
        b.add("integer-width-trunc", NumberSkeletonImpl_StemEnum.STEM_INTEGER_WIDTH_TRUNC.ordinal)
        b.add("group-off", NumberSkeletonImpl_StemEnum.STEM_GROUP_OFF.ordinal)
        b.add("group-min2", NumberSkeletonImpl_StemEnum.STEM_GROUP_MIN2.ordinal)
        b.add("group-auto", NumberSkeletonImpl_StemEnum.STEM_GROUP_AUTO.ordinal)
        b.add("group-on-aligned", NumberSkeletonImpl_StemEnum.STEM_GROUP_ON_ALIGNED.ordinal)
        b.add("group-thousands", NumberSkeletonImpl_StemEnum.STEM_GROUP_THOUSANDS.ordinal)
        b.add("latin", NumberSkeletonImpl_StemEnum.STEM_LATIN.ordinal)
        b.add("unit-width-narrow", NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_NARROW.ordinal)
        b.add("unit-width-short", NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_SHORT.ordinal)
        b.add("unit-width-full-name", NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_FULL_NAME.ordinal)
        b.add("unit-width-iso-code", NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_ISO_CODE.ordinal)
        b.add("unit-width-formal", NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_FORMAL.ordinal)
        b.add("unit-width-variant", NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_VARIANT.ordinal)
        b.add("unit-width-hidden", NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_HIDDEN.ordinal)
        b.add("sign-auto", NumberSkeletonImpl_StemEnum.STEM_SIGN_AUTO.ordinal)
        b.add("sign-always", NumberSkeletonImpl_StemEnum.STEM_SIGN_ALWAYS.ordinal)
        b.add("sign-never", NumberSkeletonImpl_StemEnum.STEM_SIGN_NEVER.ordinal)
        b.add("sign-accounting", NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING.ordinal)
        b.add("sign-accounting-always", NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_ALWAYS.ordinal)
        b.add("sign-except-zero", NumberSkeletonImpl_StemEnum.STEM_SIGN_EXCEPT_ZERO.ordinal)
        b.add("sign-accounting-except-zero", NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_EXCEPT_ZERO.ordinal)
        b.add("sign-negative", NumberSkeletonImpl_StemEnum.STEM_SIGN_NEGATIVE.ordinal)
        b.add("sign-accounting-negative", NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_NEGATIVE.ordinal)
        b.add("decimal-auto", NumberSkeletonImpl_StemEnum.STEM_DECIMAL_AUTO.ordinal)
        b.add("decimal-always", NumberSkeletonImpl_StemEnum.STEM_DECIMAL_ALWAYS.ordinal)
        b.add("precision-increment", NumberSkeletonImpl_StemEnum.STEM_PRECISION_INCREMENT.ordinal)
        b.add("measure-unit", NumberSkeletonImpl_StemEnum.STEM_MEASURE_UNIT.ordinal)
        b.add("per-measure-unit", NumberSkeletonImpl_StemEnum.STEM_PER_MEASURE_UNIT.ordinal)
        b.add("unit", NumberSkeletonImpl_StemEnum.STEM_UNIT.ordinal)
        b.add("usage", NumberSkeletonImpl_StemEnum.STEM_UNIT_USAGE.ordinal)
        b.add("currency", NumberSkeletonImpl_StemEnum.STEM_CURRENCY.ordinal)
        b.add("integer-width", NumberSkeletonImpl_StemEnum.STEM_INTEGER_WIDTH.ordinal)
        b.add("numbering-system", NumberSkeletonImpl_StemEnum.STEM_NUMBERING_SYSTEM.ordinal)
        b.add("scale", NumberSkeletonImpl_StemEnum.STEM_SCALE.ordinal)
        b.add("K", NumberSkeletonImpl_StemEnum.STEM_COMPACT_SHORT.ordinal)
        b.add("KK", NumberSkeletonImpl_StemEnum.STEM_COMPACT_LONG.ordinal)
        b.add("%", NumberSkeletonImpl_StemEnum.STEM_PERCENT.ordinal)
        b.add("%x100", NumberSkeletonImpl_StemEnum.STEM_PERCENT_100.ordinal)
        b.add(",_", NumberSkeletonImpl_StemEnum.STEM_GROUP_OFF.ordinal)
        b.add(",", NumberSkeletonImpl_StemEnum.STEM_GROUP_MIN2.ordinal)
        b.add(",!", NumberSkeletonImpl_StemEnum.STEM_GROUP_ON_ALIGNED.ordinal)
        b.add("+!", NumberSkeletonImpl_StemEnum.STEM_SIGN_ALWAYS.ordinal)
        b.add("+_", NumberSkeletonImpl_StemEnum.STEM_SIGN_NEVER.ordinal)
        b.add("()", NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING.ordinal)
        b.add("()!", NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_ALWAYS.ordinal)
        b.add("+", NumberSkeletonImpl_StemEnum.STEM_SIGN_EXCEPT_ZERO.ordinal)
        b.add("()", NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_EXCEPT_ZERO.ordinal)
        b.add("+-", NumberSkeletonImpl_StemEnum.STEM_SIGN_NEGATIVE.ordinal)
        b.add("()-", NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_NEGATIVE.ordinal)
        return toString(b.buildCharSequence(StringTrieBuilder_Option.FAST))
    }

    private static let cache: CacheBase<String, UnlocalizedNumberFormatter, Void> = NumberSkeletonImpl_1()

    public static func getOrCreate(skeletonString: String): UnlocalizedNumberFormatter {
        return cache.getInstance(skeletonString, None)
    }

    public static func create(skeletonString: String): UnlocalizedNumberFormatter {
        let macros = parseSkeleton(skeletonString)
        return NumberFormatter.`with`().macros(macros)
    }

    public static func generate(macros: MacroProps): String {
        let sb = StringBuilder()
        generateSkeleton(macros, sb)
        return sb.toString()
    }

    private static func parseSkeleton(skeletonString: String): MacroProps {
        var tempskeletonString = skeletonString
        tempskeletonString += " "
        let macros = MacroProps()
        let segment = StringSegment(tempskeletonString, false)
        let stemTrie = CharsTrie(SERIALIZED_STEM_TRIE, 0)
        var stem: NumberSkeletonImpl_ParseState = NumberSkeletonImpl_ParseState.STATE_NULL
        var offset = 0
        while (offset < segment.size) {
            let cp = segment.codePointAt(offset)
            let isTokenSeparator = PatternProps.isWhiteSpace(cp)
            let isOptionSeparator = (cp == Int32(UInt32('/')))
            if (!isTokenSeparator && !isOptionSeparator) {
                offset += Character.charCount(cp)
                if (refEq(stem, NumberSkeletonImpl_ParseState.STATE_NULL)) {
                    stemTrie.nextForCodePoint(cp)
                }
                continue
            }
            if (offset != 0) {
                segment.setLength(offset)
                if (refEq(stem, NumberSkeletonImpl_ParseState.STATE_NULL)) {
                    stem = parseStem(segment, stemTrie, macros)
                    stemTrie.reset()
                } else {
                    stem = parseOption(stem, segment, macros)
                }
                segment.resetLength()
                segment.adjustOffset(offset)
                offset = 0
            } else if (!refEq(stem, NumberSkeletonImpl_ParseState.STATE_NULL)) {
                segment.setLength(Character.charCount(cp))
                throw SkeletonSyntaxException("Unexpected separator character", segment)
            } else { }
            if (isOptionSeparator && refEq(stem, NumberSkeletonImpl_ParseState.STATE_NULL)) {
                segment.setLength(Character.charCount(cp))
                throw SkeletonSyntaxException("Unexpected option separator", segment)
            }
            if (isTokenSeparator && !refEq(stem, NumberSkeletonImpl_ParseState.STATE_NULL)) {
                match (stem) {
                    case NumberSkeletonImpl_ParseState.STATE_INCREMENT_PRECISION | NumberSkeletonImpl_ParseState.STATE_MEASURE_UNIT | NumberSkeletonImpl_ParseState.STATE_PER_MEASURE_UNIT | NumberSkeletonImpl_ParseState.STATE_IDENTIFIER_UNIT | NumberSkeletonImpl_ParseState.STATE_UNIT_USAGE | NumberSkeletonImpl_ParseState.STATE_CURRENCY_UNIT | NumberSkeletonImpl_ParseState.STATE_INTEGER_WIDTH | NumberSkeletonImpl_ParseState.STATE_NUMBERING_SYSTEM | NumberSkeletonImpl_ParseState.STATE_SCALE =>
                        segment.setLength(Character.charCount(cp))
                        throw SkeletonSyntaxException("Stem requires an option", segment)
                    case _ => ()
                }
                stem = NumberSkeletonImpl_ParseState.STATE_NULL
            }
            segment.adjustOffset(Character.charCount(cp))
        }
        if (!refEq(stem, NumberSkeletonImpl_ParseState.STATE_NULL)) {
            throw AssertionError()
        }
        return macros
    }

    private static func parseStem(segment: StringSegment, stemTrie: CharsTrie, macros: MacroProps): NumberSkeletonImpl_ParseState {
        match (segment.toRuneArray()[0]) {
            case '.' =>
                checkNull(macros.precision, segment)
                NumberSkeletonImpl_BlueprintHelpers.parseFractionStem(segment, macros)
                return NumberSkeletonImpl_ParseState.STATE_FRACTION_PRECISION
            case '@' =>
                checkNull(macros.precision, segment)
                NumberSkeletonImpl_BlueprintHelpers.parseDigitsStem(segment, macros)
                return NumberSkeletonImpl_ParseState.STATE_PRECISION
            case 'E' =>
                checkNull(macros.notation, segment)
                NumberSkeletonImpl_BlueprintHelpers.parseScientificStem(segment, macros)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case '0' =>
                checkNull(macros.integerWidth, segment)
                NumberSkeletonImpl_BlueprintHelpers.parseIntegerStem(segment, macros)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case _ => ()
        }
        let stemResult = stemTrie.current()
        if (!refEq(stemResult, BytesTrie_Result.INTERMEDIATE_VALUE) && !refEq(stemResult, BytesTrie_Result.FINAL_VALUE)) {
            throw SkeletonSyntaxException("Unknown stem", segment)
        }
        let stem = STEM_ENUM_VALUES[Int64(stemTrie.getValue())]
        match (stem) {
            case NumberSkeletonImpl_StemEnum.STEM_COMPACT_SHORT | NumberSkeletonImpl_StemEnum.STEM_COMPACT_LONG | NumberSkeletonImpl_StemEnum.STEM_SCIENTIFIC | NumberSkeletonImpl_StemEnum.STEM_ENGINEERING | NumberSkeletonImpl_StemEnum.STEM_NOTATION_SIMPLE =>
                checkNull(macros.notation, segment)
                macros.notation = NumberSkeletonImpl_StemToObject.notation(stem)
                match (stem) {
                    case NumberSkeletonImpl_StemEnum.STEM_SCIENTIFIC | NumberSkeletonImpl_StemEnum.STEM_ENGINEERING => return NumberSkeletonImpl_ParseState.STATE_SCIENTIFIC
                    case _ => return NumberSkeletonImpl_ParseState.STATE_NULL
                }
            case NumberSkeletonImpl_StemEnum.STEM_BASE_UNIT | NumberSkeletonImpl_StemEnum.STEM_PERCENT | NumberSkeletonImpl_StemEnum.STEM_PERMILLE =>
                checkNull(macros.unit, segment)
                macros.unit = NumberSkeletonImpl_StemToObject.unit(stem)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_StemEnum.STEM_PERCENT_100 =>
                checkNull(macros.scale, segment)
                checkNull(macros.unit, segment)
                macros.scale = Scale.powerOfTen(2)
                macros.unit = NoUnit.PERCENT
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_StemEnum.STEM_PRECISION_INTEGER | NumberSkeletonImpl_StemEnum.STEM_PRECISION_UNLIMITED | NumberSkeletonImpl_StemEnum.STEM_PRECISION_CURRENCY_STANDARD | NumberSkeletonImpl_StemEnum.STEM_PRECISION_CURRENCY_CASH =>
                checkNull(macros.precision, segment)
                macros.precision = NumberSkeletonImpl_StemToObject.precision(stem)
                match (stem) {
                    case NumberSkeletonImpl_StemEnum.STEM_PRECISION_INTEGER => return NumberSkeletonImpl_ParseState.STATE_FRACTION_PRECISION
                    case _ => return NumberSkeletonImpl_ParseState.STATE_PRECISION
                }
            case NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_CEILING | NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_FLOOR | NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_DOWN | NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_UP | NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_HALF_EVEN | NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_HALF_DOWN | NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_HALF_UP | NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_UNNECESSARY =>
                checkNull(macros.roundingMode, segment)
                macros.roundingMode = NumberSkeletonImpl_StemToObject.roundingMode(stem)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_StemEnum.STEM_INTEGER_WIDTH_TRUNC =>
                checkNull(macros.integerWidth, segment)
                macros.integerWidth = IntegerWidth.zeroFillTo(0).truncateAt(0)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_StemEnum.STEM_GROUP_OFF | NumberSkeletonImpl_StemEnum.STEM_GROUP_MIN2 | NumberSkeletonImpl_StemEnum.STEM_GROUP_AUTO | NumberSkeletonImpl_StemEnum.STEM_GROUP_ON_ALIGNED | NumberSkeletonImpl_StemEnum.STEM_GROUP_THOUSANDS =>
                checkNull(macros.grouping, segment)
                macros.grouping = NumberSkeletonImpl_StemToObject.groupingStrategy(stem)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_StemEnum.STEM_LATIN =>
                checkNull(macros.symbols, segment)
                macros.symbols = NumberingSystem.LATIN
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_NARROW | NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_SHORT | NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_FULL_NAME | NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_ISO_CODE | NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_FORMAL | NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_VARIANT | NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_HIDDEN =>
                checkNull(macros.unitWidth, segment)
                macros.unitWidth = NumberSkeletonImpl_StemToObject.unitWidth(stem)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_StemEnum.STEM_SIGN_AUTO | NumberSkeletonImpl_StemEnum.STEM_SIGN_ALWAYS | NumberSkeletonImpl_StemEnum.STEM_SIGN_NEVER | NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING | NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_ALWAYS | NumberSkeletonImpl_StemEnum.STEM_SIGN_EXCEPT_ZERO | NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_EXCEPT_ZERO | NumberSkeletonImpl_StemEnum.STEM_SIGN_NEGATIVE | NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_NEGATIVE =>
                checkNull(macros.sign, segment)
                macros.sign = NumberSkeletonImpl_StemToObject.signDisplay(stem)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_StemEnum.STEM_DECIMAL_AUTO | NumberSkeletonImpl_StemEnum.STEM_DECIMAL_ALWAYS =>
                checkNull(macros.decimal, segment)
                macros.decimal = NumberSkeletonImpl_StemToObject.decimalSeparatorDisplay(stem)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_StemEnum.STEM_PRECISION_INCREMENT =>
                checkNull(macros.precision, segment)
                return NumberSkeletonImpl_ParseState.STATE_INCREMENT_PRECISION
            case NumberSkeletonImpl_StemEnum.STEM_MEASURE_UNIT =>
                checkNull(macros.unit, segment)
                return NumberSkeletonImpl_ParseState.STATE_MEASURE_UNIT
            case NumberSkeletonImpl_StemEnum.STEM_PER_MEASURE_UNIT =>
                if (checkOptionalIs<Currency, MeasureUnit>(macros.unit)) {
                    throw SkeletonSyntaxException("Duplicated setting", segment)
                }
                checkNull(macros.perUnit, segment)
                return NumberSkeletonImpl_ParseState.STATE_PER_MEASURE_UNIT
            case NumberSkeletonImpl_StemEnum.STEM_UNIT =>
                checkNull(macros.unit, segment)
                checkNull(macros.perUnit, segment)
                return NumberSkeletonImpl_ParseState.STATE_IDENTIFIER_UNIT
            case NumberSkeletonImpl_StemEnum.STEM_UNIT_USAGE =>
                checkNull(macros.usage, segment)
                return NumberSkeletonImpl_ParseState.STATE_UNIT_USAGE
            case NumberSkeletonImpl_StemEnum.STEM_CURRENCY =>
                checkNull(macros.unit, segment)
                checkNull(macros.perUnit, segment)
                return NumberSkeletonImpl_ParseState.STATE_CURRENCY_UNIT
            case NumberSkeletonImpl_StemEnum.STEM_INTEGER_WIDTH =>
                checkNull(macros.integerWidth, segment)
                return NumberSkeletonImpl_ParseState.STATE_INTEGER_WIDTH
            case NumberSkeletonImpl_StemEnum.STEM_NUMBERING_SYSTEM =>
                checkNull(macros.symbols, segment)
                return NumberSkeletonImpl_ParseState.STATE_NUMBERING_SYSTEM
            case NumberSkeletonImpl_StemEnum.STEM_SCALE =>
                checkNull(macros.scale, segment)
                return NumberSkeletonImpl_ParseState.STATE_SCALE
            case _ => throw AssertionError()
        }
    }

    private static func parseOption(stem: NumberSkeletonImpl_ParseState, segment: StringSegment, macros: MacroProps): NumberSkeletonImpl_ParseState {
        var tempstem = stem
        match (tempstem) {
            case NumberSkeletonImpl_ParseState.STATE_CURRENCY_UNIT =>
                NumberSkeletonImpl_BlueprintHelpers.parseCurrencyOption(segment, macros)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_ParseState.STATE_MEASURE_UNIT =>
                NumberSkeletonImpl_BlueprintHelpers.parseMeasureUnitOption(segment, macros)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_ParseState.STATE_PER_MEASURE_UNIT =>
                NumberSkeletonImpl_BlueprintHelpers.parseMeasurePerUnitOption(segment, macros)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_ParseState.STATE_IDENTIFIER_UNIT =>
                NumberSkeletonImpl_BlueprintHelpers.parseIdentifierUnitOption(segment, macros)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_ParseState.STATE_UNIT_USAGE =>
                NumberSkeletonImpl_BlueprintHelpers.parseUnitUsageOption(segment, macros)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_ParseState.STATE_INCREMENT_PRECISION =>
                NumberSkeletonImpl_BlueprintHelpers.parseIncrementOption(segment, macros)
                return NumberSkeletonImpl_ParseState.STATE_PRECISION
            case NumberSkeletonImpl_ParseState.STATE_INTEGER_WIDTH =>
                NumberSkeletonImpl_BlueprintHelpers.parseIntegerWidthOption(segment, macros)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_ParseState.STATE_NUMBERING_SYSTEM =>
                NumberSkeletonImpl_BlueprintHelpers.parseNumberingSystemOption(segment, macros)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case NumberSkeletonImpl_ParseState.STATE_SCALE =>
                NumberSkeletonImpl_BlueprintHelpers.parseScaleOption(segment, macros)
                return NumberSkeletonImpl_ParseState.STATE_NULL
            case _ => ()
        }
        match (tempstem) {
            case NumberSkeletonImpl_ParseState.STATE_SCIENTIFIC =>
                if (NumberSkeletonImpl_BlueprintHelpers.parseExponentWidthOption(segment, macros)) {
                    return NumberSkeletonImpl_ParseState.STATE_SCIENTIFIC
                }
                if (NumberSkeletonImpl_BlueprintHelpers.parseExponentSignOption(segment, macros)) {
                    return NumberSkeletonImpl_ParseState.STATE_SCIENTIFIC
                }
            case _ => ()
        }
        match (tempstem) {
            case NumberSkeletonImpl_ParseState.STATE_FRACTION_PRECISION =>
                if (NumberSkeletonImpl_BlueprintHelpers.parseFracSigOption(segment, macros)) {
                    return NumberSkeletonImpl_ParseState.STATE_PRECISION
                }
                tempstem = NumberSkeletonImpl_ParseState.STATE_PRECISION
            case _ => ()
        }
        match (tempstem) {
            case NumberSkeletonImpl_ParseState.STATE_PRECISION => if (NumberSkeletonImpl_BlueprintHelpers.parseTrailingZeroOption(segment, macros)) {
                return NumberSkeletonImpl_ParseState.STATE_NULL
            }
            case _ => ()
        }
        throw SkeletonSyntaxException("Invalid option", segment)
    }

    private static func generateSkeleton(macros: MacroProps, sb: StringBuilder): Unit {
        if (macros.notation.isSome() && NumberSkeletonImpl_GeneratorHelpers.notation(macros, sb)) {
            sb.append(' ')
        }
        if (macros.unit.isSome() && NumberSkeletonImpl_GeneratorHelpers.unit(macros, sb)) {
            sb.append(' ')
        }
        if (macros.usage.isSome() && NumberSkeletonImpl_GeneratorHelpers.usage(macros, sb)) {
            sb.append(' ')
        }
        if (macros.precision.isSome() && NumberSkeletonImpl_GeneratorHelpers.precision(macros, sb)) {
            sb.append(' ')
        }
        if (macros.roundingMode.isSome() && NumberSkeletonImpl_GeneratorHelpers.roundingMode(macros, sb)) {
            sb.append(' ')
        }
        if (macros.grouping.isSome() && NumberSkeletonImpl_GeneratorHelpers.grouping(macros, sb)) {
            sb.append(' ')
        }
        if (macros.integerWidth.isSome() && NumberSkeletonImpl_GeneratorHelpers.integerWidth(macros, sb)) {
            sb.append(' ')
        }
        if (macros.symbols.isSome() && NumberSkeletonImpl_GeneratorHelpers.symbols(macros, sb)) {
            sb.append(' ')
        }
        if (macros.unitWidth.isSome() && NumberSkeletonImpl_GeneratorHelpers.unitWidth(macros, sb)) {
            sb.append(' ')
        }
        if (macros.sign.isSome() && NumberSkeletonImpl_GeneratorHelpers.sign(macros, sb)) {
            sb.append(' ')
        }
        if (macros.decimal.isSome() && NumberSkeletonImpl_GeneratorHelpers.decimal(macros, sb)) {
            sb.append(' ')
        }
        if (macros.scale.isSome() && NumberSkeletonImpl_GeneratorHelpers.scale(macros, sb)) {
            sb.append(' ')
        }
        if (macros.padder.isSome()) {
            throw UnsupportedOperationException("Cannot generate number skeleton with custom padder")
        }
        if (macros.unitDisplayCase.isSome() && !macros.unitDisplayCase.isEmpty()) {
            throw UnsupportedOperationException("Cannot generate number skeleton with custom unit display case")
        }
        if (macros.affixProvider.isSome()) {
            throw UnsupportedOperationException("Cannot generate number skeleton with custom affix provider")
        }
        if (macros.rules.isSome()) {
            throw UnsupportedOperationException("Cannot generate number skeleton with custom plural rules")
        }
        if (Int32(sb.size) > 0) {
            sb.setLength(Int64(Int32(sb.size) - 1))
        }
    }

    private static func checkNull(value: Object, content: String): Unit {
        if (value.isSome()) {
            throw SkeletonSyntaxException("Duplicated setting", content)
        }
    }

    static func appendMultiple(sb: StringBuilder, cp: Int32, count: Int32): Unit {
        var i = 0
        while (i < count) {
            sb.appendCodePoint(cp)
            i++
        }
    }
}


class NumberSkeletonImpl_ParseState <: Enum<NumberSkeletonImpl_ParseState> {
    public static let STATE_NULL = NumberSkeletonImpl_ParseState("STATE_NULL", 0)

    public static let STATE_SCIENTIFIC = NumberSkeletonImpl_ParseState("STATE_SCIENTIFIC", 1)

    public static let STATE_FRACTION_PRECISION = NumberSkeletonImpl_ParseState("STATE_FRACTION_PRECISION", 2)

    public static let STATE_PRECISION = NumberSkeletonImpl_ParseState("STATE_PRECISION", 3)

    public static let STATE_INCREMENT_PRECISION = NumberSkeletonImpl_ParseState("STATE_INCREMENT_PRECISION", 4)

    public static let STATE_MEASURE_UNIT = NumberSkeletonImpl_ParseState("STATE_MEASURE_UNIT", 5)

    public static let STATE_PER_MEASURE_UNIT = NumberSkeletonImpl_ParseState("STATE_PER_MEASURE_UNIT", 6)

    public static let STATE_IDENTIFIER_UNIT = NumberSkeletonImpl_ParseState("STATE_IDENTIFIER_UNIT", 7)

    public static let STATE_UNIT_USAGE = NumberSkeletonImpl_ParseState("STATE_UNIT_USAGE", 8)

    public static let STATE_CURRENCY_UNIT = NumberSkeletonImpl_ParseState("STATE_CURRENCY_UNIT", 9)

    public static let STATE_INTEGER_WIDTH = NumberSkeletonImpl_ParseState("STATE_INTEGER_WIDTH", 10)

    public static let STATE_NUMBERING_SYSTEM = NumberSkeletonImpl_ParseState("STATE_NUMBERING_SYSTEM", 11)

    public static let STATE_SCALE = NumberSkeletonImpl_ParseState("STATE_SCALE", 12)

    private static func _values(): Array<NumberSkeletonImpl_ParseState> {
        return [NumberSkeletonImpl_ParseState.STATE_NULL, NumberSkeletonImpl_ParseState.STATE_SCIENTIFIC, NumberSkeletonImpl_ParseState.STATE_FRACTION_PRECISION, NumberSkeletonImpl_ParseState.STATE_PRECISION, NumberSkeletonImpl_ParseState.STATE_INCREMENT_PRECISION, NumberSkeletonImpl_ParseState.STATE_MEASURE_UNIT, NumberSkeletonImpl_ParseState.STATE_PER_MEASURE_UNIT, NumberSkeletonImpl_ParseState.STATE_IDENTIFIER_UNIT, NumberSkeletonImpl_ParseState.STATE_UNIT_USAGE, NumberSkeletonImpl_ParseState.STATE_CURRENCY_UNIT, NumberSkeletonImpl_ParseState.STATE_INTEGER_WIDTH, NumberSkeletonImpl_ParseState.STATE_NUMBERING_SYSTEM, NumberSkeletonImpl_ParseState.STATE_SCALE]
    }

    private static let _VALUES = NumberSkeletonImpl_ParseState._values()

    public static func values(): Array<NumberSkeletonImpl_ParseState> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): NumberSkeletonImpl_ParseState {
        return (TypeInfo.of<NumberSkeletonImpl_ParseState>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as NumberSkeletonImpl_ParseState
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class NumberSkeletonImpl_StemEnum <: Enum<NumberSkeletonImpl_StemEnum> {
    public static let STEM_COMPACT_SHORT = NumberSkeletonImpl_StemEnum("STEM_COMPACT_SHORT", 0)

    public static let STEM_COMPACT_LONG = NumberSkeletonImpl_StemEnum("STEM_COMPACT_LONG", 1)

    public static let STEM_SCIENTIFIC = NumberSkeletonImpl_StemEnum("STEM_SCIENTIFIC", 2)

    public static let STEM_ENGINEERING = NumberSkeletonImpl_StemEnum("STEM_ENGINEERING", 3)

    public static let STEM_NOTATION_SIMPLE = NumberSkeletonImpl_StemEnum("STEM_NOTATION_SIMPLE", 4)

    public static let STEM_BASE_UNIT = NumberSkeletonImpl_StemEnum("STEM_BASE_UNIT", 5)

    public static let STEM_PERCENT = NumberSkeletonImpl_StemEnum("STEM_PERCENT", 6)

    public static let STEM_PERMILLE = NumberSkeletonImpl_StemEnum("STEM_PERMILLE", 7)

    public static let STEM_PERCENT_100 = NumberSkeletonImpl_StemEnum("STEM_PERCENT_100", 8)

    public static let STEM_PRECISION_INTEGER = NumberSkeletonImpl_StemEnum("STEM_PRECISION_INTEGER", 9)

    public static let STEM_PRECISION_UNLIMITED = NumberSkeletonImpl_StemEnum("STEM_PRECISION_UNLIMITED", 10)

    public static let STEM_PRECISION_CURRENCY_STANDARD = NumberSkeletonImpl_StemEnum("STEM_PRECISION_CURRENCY_STANDARD", 11)

    public static let STEM_PRECISION_CURRENCY_CASH = NumberSkeletonImpl_StemEnum("STEM_PRECISION_CURRENCY_CASH", 12)

    public static let STEM_ROUNDING_MODE_CEILING = NumberSkeletonImpl_StemEnum("STEM_ROUNDING_MODE_CEILING", 13)

    public static let STEM_ROUNDING_MODE_FLOOR = NumberSkeletonImpl_StemEnum("STEM_ROUNDING_MODE_FLOOR", 14)

    public static let STEM_ROUNDING_MODE_DOWN = NumberSkeletonImpl_StemEnum("STEM_ROUNDING_MODE_DOWN", 15)

    public static let STEM_ROUNDING_MODE_UP = NumberSkeletonImpl_StemEnum("STEM_ROUNDING_MODE_UP", 16)

    public static let STEM_ROUNDING_MODE_HALF_EVEN = NumberSkeletonImpl_StemEnum("STEM_ROUNDING_MODE_HALF_EVEN", 17)

    public static let STEM_ROUNDING_MODE_HALF_DOWN = NumberSkeletonImpl_StemEnum("STEM_ROUNDING_MODE_HALF_DOWN", 18)

    public static let STEM_ROUNDING_MODE_HALF_UP = NumberSkeletonImpl_StemEnum("STEM_ROUNDING_MODE_HALF_UP", 19)

    public static let STEM_ROUNDING_MODE_UNNECESSARY = NumberSkeletonImpl_StemEnum("STEM_ROUNDING_MODE_UNNECESSARY", 20)

    public static let STEM_INTEGER_WIDTH_TRUNC = NumberSkeletonImpl_StemEnum("STEM_INTEGER_WIDTH_TRUNC", 21)

    public static let STEM_GROUP_OFF = NumberSkeletonImpl_StemEnum("STEM_GROUP_OFF", 22)

    public static let STEM_GROUP_MIN2 = NumberSkeletonImpl_StemEnum("STEM_GROUP_MIN2", 23)

    public static let STEM_GROUP_AUTO = NumberSkeletonImpl_StemEnum("STEM_GROUP_AUTO", 24)

    public static let STEM_GROUP_ON_ALIGNED = NumberSkeletonImpl_StemEnum("STEM_GROUP_ON_ALIGNED", 25)

    public static let STEM_GROUP_THOUSANDS = NumberSkeletonImpl_StemEnum("STEM_GROUP_THOUSANDS", 26)

    public static let STEM_LATIN = NumberSkeletonImpl_StemEnum("STEM_LATIN", 27)

    public static let STEM_UNIT_WIDTH_NARROW = NumberSkeletonImpl_StemEnum("STEM_UNIT_WIDTH_NARROW", 28)

    public static let STEM_UNIT_WIDTH_SHORT = NumberSkeletonImpl_StemEnum("STEM_UNIT_WIDTH_SHORT", 29)

    public static let STEM_UNIT_WIDTH_FULL_NAME = NumberSkeletonImpl_StemEnum("STEM_UNIT_WIDTH_FULL_NAME", 30)

    public static let STEM_UNIT_WIDTH_ISO_CODE = NumberSkeletonImpl_StemEnum("STEM_UNIT_WIDTH_ISO_CODE", 31)

    public static let STEM_UNIT_WIDTH_FORMAL = NumberSkeletonImpl_StemEnum("STEM_UNIT_WIDTH_FORMAL", 32)

    public static let STEM_UNIT_WIDTH_VARIANT = NumberSkeletonImpl_StemEnum("STEM_UNIT_WIDTH_VARIANT", 33)

    public static let STEM_UNIT_WIDTH_HIDDEN = NumberSkeletonImpl_StemEnum("STEM_UNIT_WIDTH_HIDDEN", 34)

    public static let STEM_SIGN_AUTO = NumberSkeletonImpl_StemEnum("STEM_SIGN_AUTO", 35)

    public static let STEM_SIGN_ALWAYS = NumberSkeletonImpl_StemEnum("STEM_SIGN_ALWAYS", 36)

    public static let STEM_SIGN_NEVER = NumberSkeletonImpl_StemEnum("STEM_SIGN_NEVER", 37)

    public static let STEM_SIGN_ACCOUNTING = NumberSkeletonImpl_StemEnum("STEM_SIGN_ACCOUNTING", 38)

    public static let STEM_SIGN_ACCOUNTING_ALWAYS = NumberSkeletonImpl_StemEnum("STEM_SIGN_ACCOUNTING_ALWAYS", 39)

    public static let STEM_SIGN_EXCEPT_ZERO = NumberSkeletonImpl_StemEnum("STEM_SIGN_EXCEPT_ZERO", 40)

    public static let STEM_SIGN_ACCOUNTING_EXCEPT_ZERO = NumberSkeletonImpl_StemEnum("STEM_SIGN_ACCOUNTING_EXCEPT_ZERO", 41)

    public static let STEM_SIGN_NEGATIVE = NumberSkeletonImpl_StemEnum("STEM_SIGN_NEGATIVE", 42)

    public static let STEM_SIGN_ACCOUNTING_NEGATIVE = NumberSkeletonImpl_StemEnum("STEM_SIGN_ACCOUNTING_NEGATIVE", 43)

    public static let STEM_DECIMAL_AUTO = NumberSkeletonImpl_StemEnum("STEM_DECIMAL_AUTO", 44)

    public static let STEM_DECIMAL_ALWAYS = NumberSkeletonImpl_StemEnum("STEM_DECIMAL_ALWAYS", 45)

    public static let STEM_PRECISION_INCREMENT = NumberSkeletonImpl_StemEnum("STEM_PRECISION_INCREMENT", 46)

    public static let STEM_MEASURE_UNIT = NumberSkeletonImpl_StemEnum("STEM_MEASURE_UNIT", 47)

    public static let STEM_PER_MEASURE_UNIT = NumberSkeletonImpl_StemEnum("STEM_PER_MEASURE_UNIT", 48)

    public static let STEM_UNIT = NumberSkeletonImpl_StemEnum("STEM_UNIT", 49)

    public static let STEM_UNIT_USAGE = NumberSkeletonImpl_StemEnum("STEM_UNIT_USAGE", 50)

    public static let STEM_CURRENCY = NumberSkeletonImpl_StemEnum("STEM_CURRENCY", 51)

    public static let STEM_INTEGER_WIDTH = NumberSkeletonImpl_StemEnum("STEM_INTEGER_WIDTH", 52)

    public static let STEM_NUMBERING_SYSTEM = NumberSkeletonImpl_StemEnum("STEM_NUMBERING_SYSTEM", 53)

    public static let STEM_SCALE = NumberSkeletonImpl_StemEnum("STEM_SCALE", 54)

    private static func _values(): Array<NumberSkeletonImpl_StemEnum> {
        return [NumberSkeletonImpl_StemEnum.STEM_COMPACT_SHORT, NumberSkeletonImpl_StemEnum.STEM_COMPACT_LONG, NumberSkeletonImpl_StemEnum.STEM_SCIENTIFIC, NumberSkeletonImpl_StemEnum.STEM_ENGINEERING, NumberSkeletonImpl_StemEnum.STEM_NOTATION_SIMPLE, NumberSkeletonImpl_StemEnum.STEM_BASE_UNIT, NumberSkeletonImpl_StemEnum.STEM_PERCENT, NumberSkeletonImpl_StemEnum.STEM_PERMILLE, NumberSkeletonImpl_StemEnum.STEM_PERCENT_100, NumberSkeletonImpl_StemEnum.STEM_PRECISION_INTEGER, NumberSkeletonImpl_StemEnum.STEM_PRECISION_UNLIMITED, NumberSkeletonImpl_StemEnum.STEM_PRECISION_CURRENCY_STANDARD, NumberSkeletonImpl_StemEnum.STEM_PRECISION_CURRENCY_CASH, NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_CEILING, NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_FLOOR, NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_DOWN, NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_UP, NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_HALF_EVEN, NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_HALF_DOWN, NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_HALF_UP, NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_UNNECESSARY, NumberSkeletonImpl_StemEnum.STEM_INTEGER_WIDTH_TRUNC, NumberSkeletonImpl_StemEnum.STEM_GROUP_OFF, NumberSkeletonImpl_StemEnum.STEM_GROUP_MIN2, NumberSkeletonImpl_StemEnum.STEM_GROUP_AUTO, NumberSkeletonImpl_StemEnum.STEM_GROUP_ON_ALIGNED, NumberSkeletonImpl_StemEnum.STEM_GROUP_THOUSANDS, NumberSkeletonImpl_StemEnum.STEM_LATIN, NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_NARROW, NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_SHORT, NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_FULL_NAME, NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_ISO_CODE, NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_FORMAL, NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_VARIANT, NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_HIDDEN, NumberSkeletonImpl_StemEnum.STEM_SIGN_AUTO, NumberSkeletonImpl_StemEnum.STEM_SIGN_ALWAYS, NumberSkeletonImpl_StemEnum.STEM_SIGN_NEVER, NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING, NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_ALWAYS, NumberSkeletonImpl_StemEnum.STEM_SIGN_EXCEPT_ZERO, NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_EXCEPT_ZERO, NumberSkeletonImpl_StemEnum.STEM_SIGN_NEGATIVE, NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_NEGATIVE, NumberSkeletonImpl_StemEnum.STEM_DECIMAL_AUTO, NumberSkeletonImpl_StemEnum.STEM_DECIMAL_ALWAYS, NumberSkeletonImpl_StemEnum.STEM_PRECISION_INCREMENT, NumberSkeletonImpl_StemEnum.STEM_MEASURE_UNIT, NumberSkeletonImpl_StemEnum.STEM_PER_MEASURE_UNIT, NumberSkeletonImpl_StemEnum.STEM_UNIT, NumberSkeletonImpl_StemEnum.STEM_UNIT_USAGE, NumberSkeletonImpl_StemEnum.STEM_CURRENCY, NumberSkeletonImpl_StemEnum.STEM_INTEGER_WIDTH, NumberSkeletonImpl_StemEnum.STEM_NUMBERING_SYSTEM, NumberSkeletonImpl_StemEnum.STEM_SCALE]
    }

    private static let _VALUES = NumberSkeletonImpl_StemEnum._values()

    public static func values(): Array<NumberSkeletonImpl_StemEnum> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): NumberSkeletonImpl_StemEnum {
        return (TypeInfo.of<NumberSkeletonImpl_StemEnum>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as NumberSkeletonImpl_StemEnum
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class NumberSkeletonImpl_StemToObject {

    static func notation(stem: NumberSkeletonImpl_StemEnum): Notation {
        match (stem) {
            case NumberSkeletonImpl_StemEnum.STEM_COMPACT_SHORT => return Notation.compactShort()
            case NumberSkeletonImpl_StemEnum.STEM_COMPACT_LONG => return Notation.compactLong()
            case NumberSkeletonImpl_StemEnum.STEM_SCIENTIFIC => return Notation.scientific()
            case NumberSkeletonImpl_StemEnum.STEM_ENGINEERING => return Notation.engineering()
            case NumberSkeletonImpl_StemEnum.STEM_NOTATION_SIMPLE => return Notation.simple()
            case _ => throw AssertionError()
        }
    }

    static func unit(stem: NumberSkeletonImpl_StemEnum): MeasureUnit {
        match (stem) {
            case NumberSkeletonImpl_StemEnum.STEM_BASE_UNIT => return NoUnit.BASE
            case NumberSkeletonImpl_StemEnum.STEM_PERCENT => return NoUnit.PERCENT
            case NumberSkeletonImpl_StemEnum.STEM_PERMILLE => return NoUnit.PERMILLE
            case _ => throw AssertionError()
        }
    }

    static func precision(stem: NumberSkeletonImpl_StemEnum): Precision {
        match (stem) {
            case NumberSkeletonImpl_StemEnum.STEM_PRECISION_INTEGER => return Precision.integer()
            case NumberSkeletonImpl_StemEnum.STEM_PRECISION_UNLIMITED => return Precision.unlimited()
            case NumberSkeletonImpl_StemEnum.STEM_PRECISION_CURRENCY_STANDARD => return Precision.currency(Currency_CurrencyUsage.STANDARD)
            case NumberSkeletonImpl_StemEnum.STEM_PRECISION_CURRENCY_CASH => return Precision.currency(Currency_CurrencyUsage.CASH)
            case _ => throw AssertionError()
        }
    }

    static func roundingMode(stem: NumberSkeletonImpl_StemEnum): RoundingMode {
        match (stem) {
            case NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_CEILING => return RoundingMode.CEILING
            case NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_FLOOR => return RoundingMode.FLOOR
            case NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_DOWN => return RoundingMode.DOWN
            case NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_UP => return RoundingMode.UP
            case NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_HALF_EVEN => return RoundingMode.HALF_EVEN
            case NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_HALF_DOWN => return RoundingMode.HALF_DOWN
            case NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_HALF_UP => return RoundingMode.HALF_UP
            case NumberSkeletonImpl_StemEnum.STEM_ROUNDING_MODE_UNNECESSARY => return RoundingMode.UNNECESSARY
            case _ => throw AssertionError()
        }
    }

    static func groupingStrategy(stem: NumberSkeletonImpl_StemEnum): NumberFormatter_GroupingStrategy {
        match (stem) {
            case NumberSkeletonImpl_StemEnum.STEM_GROUP_OFF => return NumberFormatter_GroupingStrategy.OFF
            case NumberSkeletonImpl_StemEnum.STEM_GROUP_MIN2 => return NumberFormatter_GroupingStrategy.MIN2
            case NumberSkeletonImpl_StemEnum.STEM_GROUP_AUTO => return NumberFormatter_GroupingStrategy.AUTO
            case NumberSkeletonImpl_StemEnum.STEM_GROUP_ON_ALIGNED => return NumberFormatter_GroupingStrategy.ON_ALIGNED
            case NumberSkeletonImpl_StemEnum.STEM_GROUP_THOUSANDS => return NumberFormatter_GroupingStrategy.THOUSANDS
            case _ => return None
        }
    }

    static func unitWidth(stem: NumberSkeletonImpl_StemEnum): NumberFormatter_UnitWidth {
        match (stem) {
            case NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_NARROW => return NumberFormatter_UnitWidth.NARROW
            case NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_SHORT => return NumberFormatter_UnitWidth.SHORT
            case NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_FULL_NAME => return NumberFormatter_UnitWidth.FULL_NAME
            case NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_ISO_CODE => return NumberFormatter_UnitWidth.ISO_CODE
            case NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_FORMAL => return NumberFormatter_UnitWidth.FORMAL
            case NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_VARIANT => return NumberFormatter_UnitWidth.VARIANT
            case NumberSkeletonImpl_StemEnum.STEM_UNIT_WIDTH_HIDDEN => return NumberFormatter_UnitWidth.HIDDEN
            case _ => return None
        }
    }

    static func signDisplay(stem: NumberSkeletonImpl_StemEnum): NumberFormatter_SignDisplay {
        match (stem) {
            case NumberSkeletonImpl_StemEnum.STEM_SIGN_AUTO => return NumberFormatter_SignDisplay.AUTO
            case NumberSkeletonImpl_StemEnum.STEM_SIGN_ALWAYS => return NumberFormatter_SignDisplay.ALWAYS
            case NumberSkeletonImpl_StemEnum.STEM_SIGN_NEVER => return NumberFormatter_SignDisplay.NEVER
            case NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING => return NumberFormatter_SignDisplay.ACCOUNTING
            case NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_ALWAYS => return NumberFormatter_SignDisplay.ACCOUNTING_ALWAYS
            case NumberSkeletonImpl_StemEnum.STEM_SIGN_EXCEPT_ZERO => return NumberFormatter_SignDisplay.EXCEPT_ZERO
            case NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_EXCEPT_ZERO => return NumberFormatter_SignDisplay.ACCOUNTING_EXCEPT_ZERO
            case NumberSkeletonImpl_StemEnum.STEM_SIGN_NEGATIVE => return NumberFormatter_SignDisplay.NEGATIVE
            case NumberSkeletonImpl_StemEnum.STEM_SIGN_ACCOUNTING_NEGATIVE => return NumberFormatter_SignDisplay.ACCOUNTING_NEGATIVE
            case _ => return None
        }
    }

    static func decimalSeparatorDisplay(stem: NumberSkeletonImpl_StemEnum): NumberFormatter_DecimalSeparatorDisplay {
        match (stem) {
            case NumberSkeletonImpl_StemEnum.STEM_DECIMAL_AUTO => return NumberFormatter_DecimalSeparatorDisplay.AUTO
            case NumberSkeletonImpl_StemEnum.STEM_DECIMAL_ALWAYS => return NumberFormatter_DecimalSeparatorDisplay.ALWAYS
            case _ => return None
        }
    }
}


class NumberSkeletonImpl_EnumToStemString {

    static func roundingMode(value: RoundingMode, sb: StringBuilder): Unit {
        <-- Internal error: switch (value) {
        case RoundingMode.CEILING:
            sb.append("rounding-mode-ceiling");
            break;

        case RoundingMode.FLOOR:
            sb.append("rounding-mode-floor");
            break;

        case RoundingMode.DOWN:
            sb.append("rounding-mode-down");
            break;

        case RoundingMode.UP:
            sb.append("rounding-mode-up");
            break;

        case RoundingMode.HALF_EVEN:
            sb.append("rounding-mode-half-even");
            break;

        case RoundingMode.HALF_DOWN:
            sb.append("rounding-mode-half-down");
            break;

        case RoundingMode.HALF_UP:
            sb.append("rounding-mode-half-up");
            break;

        case RoundingMode.UNNECESSARY:
            sb.append("rounding-mode-unnecessary");
            break;

        default:
            throw new AssertionError();

        } -->
    }

    static func groupingStrategy(value: NumberFormatter_GroupingStrategy, sb: StringBuilder): Unit {
        match (value) {
            case NumberFormatter_GroupingStrategy.OFF => sb.append("group-off")
            case NumberFormatter_GroupingStrategy.MIN2 => sb.append("group-min2")
            case NumberFormatter_GroupingStrategy.AUTO => sb.append("group-auto")
            case NumberFormatter_GroupingStrategy.ON_ALIGNED => sb.append("group-on-aligned")
            case NumberFormatter_GroupingStrategy.THOUSANDS => sb.append("group-thousands")
            case _ => throw AssertionError()
        }
    }

    static func unitWidth(value: NumberFormatter_UnitWidth, sb: StringBuilder): Unit {
        match (value) {
            case NumberFormatter_UnitWidth.NARROW => sb.append("unit-width-narrow")
            case NumberFormatter_UnitWidth.SHORT => sb.append("unit-width-short")
            case NumberFormatter_UnitWidth.FULL_NAME => sb.append("unit-width-full-name")
            case NumberFormatter_UnitWidth.ISO_CODE => sb.append("unit-width-iso-code")
            case NumberFormatter_UnitWidth.FORMAL => sb.append("unit-width-formal")
            case NumberFormatter_UnitWidth.VARIANT => sb.append("unit-width-variant")
            case NumberFormatter_UnitWidth.HIDDEN => sb.append("unit-width-hidden")
            case _ => throw AssertionError()
        }
    }

    static func signDisplay(value: NumberFormatter_SignDisplay, sb: StringBuilder): Unit {
        match (value) {
            case NumberFormatter_SignDisplay.AUTO => sb.append("sign-auto")
            case NumberFormatter_SignDisplay.ALWAYS => sb.append("sign-always")
            case NumberFormatter_SignDisplay.NEVER => sb.append("sign-never")
            case NumberFormatter_SignDisplay.ACCOUNTING => sb.append("sign-accounting")
            case NumberFormatter_SignDisplay.ACCOUNTING_ALWAYS => sb.append("sign-accounting-always")
            case NumberFormatter_SignDisplay.EXCEPT_ZERO => sb.append("sign-except-zero")
            case NumberFormatter_SignDisplay.ACCOUNTING_EXCEPT_ZERO => sb.append("sign-accounting-except-zero")
            case NumberFormatter_SignDisplay.NEGATIVE => sb.append("sign-negative")
            case NumberFormatter_SignDisplay.ACCOUNTING_NEGATIVE => sb.append("sign-accounting-negative")
            case _ => throw AssertionError()
        }
    }

    static func decimalSeparatorDisplay(value: NumberFormatter_DecimalSeparatorDisplay, sb: StringBuilder): Unit {
        match (value) {
            case NumberFormatter_DecimalSeparatorDisplay.AUTO => sb.append("decimal-auto")
            case NumberFormatter_DecimalSeparatorDisplay.ALWAYS => sb.append("decimal-always")
            case _ => throw AssertionError()
        }
    }
}


class NumberSkeletonImpl_1 <: SoftCache<String, UnlocalizedNumberFormatter, Void> {
    init() {
        super()
    }

    override protected func createInstance(skeletonString: String, unused: Void): UnlocalizedNumberFormatter {
        return NumberSkeletonImpl.create(skeletonString)
    }
}


class NumberSkeletonImpl_BlueprintHelpers {

    static func parseExponentWidthOption(segment: StringSegment, macros: MacroProps): Bool {
        if (!NumberSkeletonImpl.isWildcardChar(segment.toRuneArray()[0])) {
            return false
        }
        var offset = 1
        var minExp = 0
        while (offset < segment.size) {
            if (segment.toRuneArray()[offset] == 'e') {
                minExp++
            } else {
                break
            }
            offset++
        }
        if (offset < segment.size) {
            return false
        }
        macros.notation = macros.notation.withMinExponentDigits(minExp)
        return true
    }

    static func generateExponentWidthOption(minExponentDigits: Int32, sb: StringBuilder): Unit {
        sb.append(NumberSkeletonImpl.WILDCARD_CHAR)
        NumberSkeletonImpl.appendMultiple(sb, Int32(UInt32('e')), minExponentDigits)
    }

    static func parseExponentSignOption(segment: StringSegment, macros: MacroProps): Bool {
        let tempStemTrie = CharsTrie(NumberSkeletonImpl.SERIALIZED_STEM_TRIE, 0)
        let result = tempStemTrie.next(segment, 0, segment.size)
        if (!refEq(result, BytesTrie_Result.INTERMEDIATE_VALUE) && !refEq(result, BytesTrie_Result.FINAL_VALUE)) {
            return false
        }
        let sign = NumberSkeletonImpl_StemToObject.signDisplay(NumberSkeletonImpl.STEM_ENUM_VALUES[Int64(tempStemTrie.getValue())])
        if (sign.isNone()) {
            return false
        }
        macros.notation = macros.notation.withExponentSignDisplay(sign)
        return true
    }

    static func parseCurrencyOption(segment: StringSegment, macros: MacroProps): Unit {
        let currencyCode: String = toString(segment.subSequence(0, segment.size))
        let currency: Currency
        try {
            currency = Currency.getInstance(currencyCode)
        } catch (e: IllegalArgumentException) {
            throw SkeletonSyntaxException("Invalid currency", segment, e)
        }
        macros.unit = currency
    }

    static func generateCurrencyOption(currency: Currency, sb: StringBuilder): Unit {
        sb.append(currency.getCurrencyCode())
    }

    static func parseMeasureUnitOption(segment: StringSegment, macros: MacroProps): Unit {
        var firstHyphen = 0
        while (firstHyphen < segment.size && segment.toRuneArray()[firstHyphen] != '-') {
            firstHyphen++
        }
        if (firstHyphen == segment.size) {
            throw SkeletonSyntaxException("Invalid measure unit option", segment)
        }
        let Type: String = toString(segment.subSequence(0, firstHyphen))
        let subType: String = toString(segment.subSequence(firstHyphen + 1, segment.size))
        let units = MeasureUnit.getAvailable(Type)
        for (unit in units) {
            if (subType.equals(unit.getSubtype())) {
                macros.unit = unit
                return
            }
        }
        throw SkeletonSyntaxException("Unknown measure unit", segment)
    }

    static func parseMeasurePerUnitOption(segment: StringSegment, macros: MacroProps): Unit {
        let numerator = macros.unit
        parseMeasureUnitOption(segment, macros)
        macros.perUnit = macros.unit
        macros.unit = numerator
    }

    static func parseIdentifierUnitOption(segment: StringSegment, macros: MacroProps): Unit {
        try {
            macros.unit = MeasureUnit.forIdentifier(segment.asString())
        } catch (e: IllegalArgumentException) {
            throw SkeletonSyntaxException("Invalid unit stem", segment)
        }
    }

    static func parseUnitUsageOption(segment: StringSegment, macros: MacroProps): Unit {
        macros.usage = segment.asString()
    }

    static func parseFractionStem(segment: StringSegment, macros: MacroProps): Unit {
        if (!(segment.toRuneArray()[0] == '.')) {
            throw AssertionError()
        }
        var offset = 1
        var minFrac = 0
        var maxFrac: Int32 = 0
        while (offset < segment.size) {
            if (segment.toRuneArray()[offset] == '0') {
                minFrac++
            } else {
                break
            }
            offset++
        }
        if (offset < segment.size) {
            if (NumberSkeletonImpl.isWildcardChar(segment.toRuneArray()[offset])) {
                maxFrac = -1
                offset++
            } else {
                maxFrac = minFrac
                while (offset < segment.size) {
                    if (segment.toRuneArray()[offset] == '#') {
                        maxFrac++
                    } else {
                        break
                    }
                    offset++
                }
            }
        } else {
            maxFrac = minFrac
        }
        if (offset < segment.size) {
            throw SkeletonSyntaxException("Invalid fraction stem", segment)
        }
        if (maxFrac == -1) {
            if (minFrac == 0) {
                macros.precision = Precision.unlimited()
            } else {
                macros.precision = Precision.minFraction(minFrac)
            }
        } else {
            macros.precision = Precision.minMaxFraction(minFrac, maxFrac)
        }
    }

    static func generateFractionStem(minFrac: Int32, maxFrac: Int32, sb: StringBuilder): Unit {
        if (minFrac == 0 && maxFrac == 0) {
            sb.append("precision-integer")
            return
        }
        sb.append('.')
        NumberSkeletonImpl.appendMultiple(sb, Int32(UInt32('0')), minFrac)
        if (maxFrac == -1) {
            sb.append(NumberSkeletonImpl.WILDCARD_CHAR)
        } else {
            NumberSkeletonImpl.appendMultiple(sb, Int32(UInt32('#')), maxFrac - minFrac)
        }
    }

    static func parseDigitsStem(segment: StringSegment, macros: MacroProps): Unit {
        if (!(segment.toRuneArray()[0] == '@')) {
            throw AssertionError()
        }
        var offset = 0
        var minSig = 0
        var maxSig: Int32 = 0
        while (offset < segment.size) {
            if (segment.toRuneArray()[offset] == '@') {
                minSig++
            } else {
                break
            }
            offset++
        }
        if (offset < segment.size) {
            if (NumberSkeletonImpl.isWildcardChar(segment.toRuneArray()[offset])) {
                maxSig = -1
                offset++
            } else {
                maxSig = minSig
                while (offset < segment.size) {
                    if (segment.toRuneArray()[offset] == '#') {
                        maxSig++
                    } else {
                        break
                    }
                    offset++
                }
            }
        } else {
            maxSig = minSig
        }
        if (offset < segment.size) {
            throw SkeletonSyntaxException("Invalid significant digits stem", segment)
        }
        if (maxSig == -1) {
            macros.precision = Precision.minSignificantDigits(minSig)
        } else {
            macros.precision = Precision.minMaxSignificantDigits(minSig, maxSig)
        }
    }

    static func generateDigitsStem(minSig: Int32, maxSig: Int32, sb: StringBuilder): Unit {
        NumberSkeletonImpl.appendMultiple(sb, Int32(UInt32('@')), minSig)
        if (maxSig == -1) {
            sb.append(NumberSkeletonImpl.WILDCARD_CHAR)
        } else {
            NumberSkeletonImpl.appendMultiple(sb, Int32(UInt32('#')), maxSig - minSig)
        }
    }

    static func parseScientificStem(segment: StringSegment, macros: MacroProps): Unit {
        if (!(segment.toRuneArray()[0] == 'E')) {
            throw AssertionError()
        }
    static func parseIntegerStem(segment: StringSegment, macros: MacroProps): Unit {
        if (!(segment.toRuneArray()[0] == '0')) {
            throw AssertionError()
        }
        var offset = 1
        while (offset < segment.size) {
            if (segment.toRuneArray()[offset] != '0') {
                offset--
                break
            }
            offset++
        }
        if (offset < segment.size) {
            throw SkeletonSyntaxException("Invalid integer stem", segment)
        }
        macros.integerWidth = IntegerWidth.zeroFillTo(offset)
        return
    }

    static func parseFracSigOption(segment: StringSegment, macros: MacroProps): Bool {
        if (segment.toRuneArray()[0] != '@') {
            return false
        }
        var offset = 0
        var minSig = 0
        var maxSig: Int32 = 0
        while (offset < segment.size) {
            if (segment.toRuneArray()[offset] == '@') {
                minSig++
            } else {
                break
            }
            offset++
        }
        if (offset < segment.size) {
            if (NumberSkeletonImpl.isWildcardChar(segment.toRuneArray()[offset])) {
                maxSig = -1
                offset++
            } else {
                maxSig = minSig
                while (offset < segment.size) {
                    if (segment.toRuneArray()[offset] == '#') {
                        maxSig++
                    } else {
                        break
                    }
                    offset++
                }
            }
        } else {
            maxSig = minSig
        }
        let oldRounder = macros.precision
        if (offset < segment.size) {
            let priority: NumberFormatter_RoundingPriority
            if (maxSig == -1) {
                throw SkeletonSyntaxException("Invalid digits option: Wildcard character not allowed with the priority annotation", segment)
            }
            if (segment.codePointAt(offset) == Int32(UInt32('r'))) {
                priority = NumberFormatter_RoundingPriority.RELAXED
                offset++
            } else if (segment.codePointAt(offset) == Int32(UInt32('s'))) {
                priority = NumberFormatter_RoundingPriority.STRICT
                offset++
            } else {
                if (!(offset < segment.size)) {
                    throw AssertionError()
                }
                priority = NumberFormatter_RoundingPriority.RELAXED
            }
            if (offset < segment.size) {
                throw SkeletonSyntaxException("Invalid digits option for fraction rounder", segment)
            }
            macros.precision = oldRounder.withSignificantDigits(minSig, maxSig, priority)
        } else if (maxSig == -1) {
            macros.precision = oldRounder.withMinDigits(minSig)
        } else if (minSig == 1) {
            macros.precision = oldRounder.withMaxDigits(maxSig)
        } else {
            throw SkeletonSyntaxException("Invalid digits option: Priority annotation required", segment)
        }
        return true
    }

    static func parseTrailingZeroOption(segment: StringSegment, macros: MacroProps): Bool {
        if (segment.contentEquals("w")) {
            macros.precision = macros.precision.trailingZeroDisplayMethod(NumberFormatter_TrailingZeroDisplay.HIDE_IF_WHOLE)
            return true
        }
        return false
    }

    static func parseIncrementOption(segment: StringSegment, macros: MacroProps): Unit {
        let str: String = toString(segment.subSequence(0, segment.size))
        let increment: BigDecimal
        try {
            increment = Decimal(str)
        } catch (e: TimeParseException) {
            throw SkeletonSyntaxException("Invalid rounding increment", segment, e)
        }
        macros.precision = Precision.increment(increment)
    }

    static func generateIncrementOption(increment: BigDecimal, sb: StringBuilder): Unit {
        sb.append(increment.toPlainString())
    }

    static func parseIntegerWidthOption(segment: StringSegment, macros: MacroProps): Unit {
        var offset = 0
        var minInt = 0
        var maxInt: Int32 = 0
        if (NumberSkeletonImpl.isWildcardChar(segment.toRuneArray()[0])) {
            maxInt = -1
            offset++
        } else {
            maxInt = 0
        }
        while (offset < segment.size) {
            if (maxInt != -1 && segment.toRuneArray()[offset] == '#') {
                maxInt++
            } else {
                break
            }
            offset++
        }
        if (offset < segment.size) {
            while (offset < segment.size) {
                if (segment.toRuneArray()[offset] == '0') {
                    minInt++
                } else {
                    break
                }
                offset++
            }
        }
        if (maxInt != -1) {
            maxInt += minInt
        }
        if (offset < segment.size) {
            throw SkeletonSyntaxException("Invalid integer width stem", segment)
        }
        if (maxInt == -1) {
            macros.integerWidth = IntegerWidth.zeroFillTo(minInt)
        } else {
            macros.integerWidth = IntegerWidth.zeroFillTo(minInt).truncateAt(maxInt)
        }
    }

    static func generateIntegerWidthOption(minInt: Int32, maxInt: Int32, sb: StringBuilder): Unit {
        if (maxInt == -1) {
            sb.append(NumberSkeletonImpl.WILDCARD_CHAR)
        } else {
            NumberSkeletonImpl.appendMultiple(sb, Int32(UInt32('#')), maxInt - minInt)
        }
        NumberSkeletonImpl.appendMultiple(sb, Int32(UInt32('0')), minInt)
    }

    static func parseNumberingSystemOption(segment: StringSegment, macros: MacroProps): Unit {
        let nsName: String = toString(segment.subSequence(0, segment.size))
        let ns = NumberingSystem.getInstanceByName(nsName)
        if (ns.isNone()) {
            throw SkeletonSyntaxException("Unknown numbering system", segment)
        }
        macros.symbols = ns
    }

    static func generateNumberingSystemOption(ns: NumberingSystem, sb: StringBuilder): Unit {
        sb.append(ns.getName())
    }

    static func parseScaleOption(segment: StringSegment, macros: MacroProps): Unit {
        let str: String = toString(segment.subSequence(0, segment.size))
        let bd: BigDecimal
        try {
            bd = Decimal(str)
        } catch (e: TimeParseException) {
            throw SkeletonSyntaxException("Invalid scale", segment, e)
        }
        macros.scale = Scale.byBigDecimal(bd)
    }

    static func generateScaleOption(scale: Scale, sb: StringBuilder): Unit {
        var bd = scale.arbitrary
        if (bd.isNone()) {
            bd = BigDecimal.ONE
        }
        bd = bd.scaleByPowerOfTen(scale.magnitude)
        sb.append(bd.toPlainString())
    }
}


class NumberSkeletonImpl_GeneratorHelpers {

    static func notation(macros: MacroProps, sb: StringBuilder): Bool {
        if (checkOptionalIs<CompactNotation, Notation>(macros.notation)) {
            if (refEq(macros.notation, Notation.compactLong())) {
                sb.append("compact-long")
                return true
            } else if (refEq(macros.notation, Notation.compactShort())) {
                sb.append("compact-short")
                return true
            } else {
                throw UnsupportedOperationException("Cannot generate number skeleton with custom compact data")
            }
        } else if (checkOptionalIs<ScientificNotation, Notation>(macros.notation)) {
            let impl = macros.notation
            if (impl.engineeringInterval == 3) {
                sb.append("engineering")
            } else {
                sb.append("scientific")
            }
            if (impl.minExponentDigits > 1) {
                sb.append('/')
                NumberSkeletonImpl_BlueprintHelpers.generateExponentWidthOption(impl.minExponentDigits, sb)
            }
            if (!refEq(impl.exponentSignDisplay, NumberFormatter_SignDisplay.AUTO)) {
                sb.append('/')
                NumberSkeletonImpl_EnumToStemString.signDisplay(impl.exponentSignDisplay, sb)
            }
            return true
        } else {
            if (!checkOptionalIs<SimpleNotation, Notation>(macros.notation)) {
                throw AssertionError()
            }
            return false
        }
    }

    static func unit(macros: MacroProps, sb: StringBuilder): Bool {
        var unit = macros.unit
        if (macros.perUnit.isSome()) {
            if (checkOptionalIs<Currency, MeasureUnit>(macros.unit) || checkOptionalIs<Currency, MeasureUnit>(macros.perUnit)) {
                throw UnsupportedOperationException("Cannot generate number skeleton with currency unit and per-unit")
            }
            unit = unit.product(macros.perUnit.reciprocal())
        }
        if (checkOptionalIs<Currency, MeasureUnit>(unit)) {
            sb.append("currency/")
            NumberSkeletonImpl_BlueprintHelpers.generateCurrencyOption(unit, sb)
            return true
        } else if (unit.equals(MeasureUnit.PERCENT)) {
            sb.append("percent")
            return true
        } else if (unit.equals(MeasureUnit.PERMILLE)) {
            sb.append("permille")
            return true
        } else {
            sb.append("unit/")
            sb.append(unit.getIdentifier())
            return true
        }
    }

    static func usage(macros: MacroProps, sb: StringBuilder): Bool {
        if (macros.usage.isSome() && Int32(macros.usage.size) > 0) {
            sb.append("usage/")
            sb.append(macros.usage)
            return true
        }
        return false
    }

    static func precision(macros: MacroProps, sb: StringBuilder): Bool {
        if (checkOptionalIs<Precision_InfiniteRounderImpl, Precision>(macros.precision)) {
            sb.append("precision-unlimited")
        } else if (checkOptionalIs<Precision_FractionRounderImpl, Precision>(macros.precision)) {
            let impl = macros.precision
            NumberSkeletonImpl_BlueprintHelpers.generateFractionStem(impl.minFrac, impl.maxFrac, sb)
        } else if (checkOptionalIs<Precision_SignificantRounderImpl, Precision>(macros.precision)) {
            let impl = macros.precision
            NumberSkeletonImpl_BlueprintHelpers.generateDigitsStem(impl.minSig, impl.maxSig, sb)
        } else if (checkOptionalIs<Precision_FracSigRounderImpl, Precision>(macros.precision)) {
            let impl = macros.precision
            NumberSkeletonImpl_BlueprintHelpers.generateFractionStem(impl.minFrac, impl.maxFrac, sb)
            sb.append('/')
            if (impl.retain) {
                if (refEq(impl.priority, NumberFormatter_RoundingPriority.RELAXED)) {
                    NumberSkeletonImpl_BlueprintHelpers.generateDigitsStem(impl.maxSig, -1, sb)
                } else {
                    NumberSkeletonImpl_BlueprintHelpers.generateDigitsStem(1, impl.maxSig, sb)
                }
            } else {
                NumberSkeletonImpl_BlueprintHelpers.generateDigitsStem(impl.minSig, impl.maxSig, sb)
                if (refEq(impl.priority, NumberFormatter_RoundingPriority.RELAXED)) {
                    sb.append('r')
                } else {
                    sb.append('s')
                }
            }
        } else if (checkOptionalIs<Precision_IncrementRounderImpl, Precision>(macros.precision)) {
            let impl = macros.precision
            sb.append("precision-increment/")
            NumberSkeletonImpl_BlueprintHelpers.generateIncrementOption(impl.increment, sb)
        } else {
            if (!checkOptionalIs<Precision_CurrencyRounderImpl, Precision>(macros.precision)) {
                throw AssertionError()
            }
            let impl = macros.precision
            if (refEq(impl.usage, Currency_CurrencyUsage.STANDARD)) {
                sb.append("precision-currency-standard")
            } else {
                sb.append("precision-currency-cash")
            }
        }
        if (refEq(macros.precision.trailingZeroDisplay, NumberFormatter_TrailingZeroDisplay.HIDE_IF_WHOLE)) {
            sb.append("/w")
        }
        return true
    }

    static func roundingMode(macros: MacroProps, sb: StringBuilder): Bool {
        if (refEq(macros.roundingMode, RoundingUtils.DEFAULT_ROUNDING_MODE)) {
            return false
        }
        NumberSkeletonImpl_EnumToStemString.roundingMode(macros.roundingMode, sb)
        return true
    }

    static func grouping(macros: MacroProps, sb: StringBuilder): Bool {
        if (checkOptionalIs<NumberFormatter_GroupingStrategy, Object>(macros.grouping)) {
            if (refEq(macros.grouping, NumberFormatter_GroupingStrategy.AUTO)) {
                return false
            }
            NumberSkeletonImpl_EnumToStemString.groupingStrategy(macros.grouping, sb)
            return true
        } else {
            throw UnsupportedOperationException("Cannot generate number skeleton with custom Grouper")
        }
    }

    static func integerWidth(macros: MacroProps, sb: StringBuilder): Bool {
        if (refEq(macros.integerWidth, IntegerWidth.DEFAULT)) {
            return false
        }
        if (macros.integerWidth.minInt == 0 && macros.integerWidth.maxInt == 0) {
            sb.append("integer-width-trunc")
            return true
        }
        sb.append("integer-width/")
        NumberSkeletonImpl_BlueprintHelpers.generateIntegerWidthOption(macros.integerWidth.minInt, macros.integerWidth.maxInt, sb)
        return true
    }

    static func symbols(macros: MacroProps, sb: StringBuilder): Bool {
        if (checkOptionalIs<NumberingSystem, Object>(macros.symbols)) {
            let ns = macros.symbols
            if (ns.getName() == "latn") {
                sb.append("latin")
            } else {
                sb.append("numbering-system/")
                NumberSkeletonImpl_BlueprintHelpers.generateNumberingSystemOption(ns, sb)
            }
            return true
        } else {
            if (!checkOptionalIs<DecimalFormatSymbols, Object>(macros.symbols)) {
                throw AssertionError()
            }
            throw UnsupportedOperationException("Cannot generate number skeleton with custom DecimalFormatSymbols")
        }
    }

    static func unitWidth(macros: MacroProps, sb: StringBuilder): Bool {
        if (refEq(macros.unitWidth, NumberFormatter_UnitWidth.SHORT)) {
            return false
        }
        NumberSkeletonImpl_EnumToStemString.unitWidth(macros.unitWidth, sb)
        return true
    }

    static func sign(macros: MacroProps, sb: StringBuilder): Bool {
        if (refEq(macros.sign, NumberFormatter_SignDisplay.AUTO)) {
            return false
        }
        NumberSkeletonImpl_EnumToStemString.signDisplay(macros.sign, sb)
        return true
    }

    static func decimal(macros: MacroProps, sb: StringBuilder): Bool {
        if (refEq(macros.decimal, NumberFormatter_DecimalSeparatorDisplay.AUTO)) {
            return false
        }
        NumberSkeletonImpl_EnumToStemString.decimalSeparatorDisplay(macros.decimal, sb)
        return true
    }

    static func scale(macros: MacroProps, sb: StringBuilder): Bool {
        if (!macros.scale.isValid()) {
            return false
        }
        sb.append("scale/")
        NumberSkeletonImpl_BlueprintHelpers.generateScaleOption(macros.scale, sb)
        return true
    }
}
