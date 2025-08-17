package icu4cj.number


class NumberFormatterImpl {
    public init(macros: MacroProps) {
        micros = MicroProps(true)
        microPropsGenerator = macrosToMicroGenerator(macros, micros, true)
    }

    public static func formatStatic(macros: MacroProps, inValue: DecimalQuantity, outString: FormattedStringBuilder): MicroProps {
        let result = preProcessUnsafe(macros, inValue)
        let length = writeNumber(result, inValue, outString, 0)
        writeAffixes(result, outString, 0, length)
        return result
    }

    public static func getPrefixSuffixStatic(macros: MacroProps, signum: UInt8, plural: StandardPlural, output: FormattedStringBuilder): Int32 {
        let micros = MicroProps(false)
        let microPropsGenerator = macrosToMicroGenerator(macros, micros, false)
        return getPrefixSuffixImpl(microPropsGenerator, signum, output)
    }

    private static let DEFAULT_CURRENCY = Currency.getInstance("XXX")

    let micros: MicroProps

    let microPropsGenerator: MicroPropsGenerator

    public func format(inValue: DecimalQuantity, outString: FormattedStringBuilder): MicroProps {
        let result = preProcess(inValue)
        let length = writeNumber(result, inValue, outString, 0)
        writeAffixes(result, outString, 0, length)
        return result
    }

    public func preProcess(inValue: DecimalQuantity): MicroProps {
        let micros = microPropsGenerator.processQuantity(inValue)
        if (micros.integerWidth.maxInt == -1) {
            inValue.setMinInteger(micros.integerWidth.minInt)
        } else {
            inValue.setMinInteger(micros.integerWidth.minInt)
            inValue.applyMaxInteger(micros.integerWidth.maxInt)
        }
        return micros
    }

    private static func preProcessUnsafe(macros: MacroProps, inValue: DecimalQuantity): MicroProps {
        var micros: MicroProps = MicroProps(false)
        let microPropsGenerator = macrosToMicroGenerator(macros, micros, false)
        micros = microPropsGenerator.processQuantity(inValue)
        if (micros.integerWidth.maxInt == -1) {
            inValue.setMinInteger(micros.integerWidth.minInt)
        } else {
            inValue.setMinInteger(micros.integerWidth.minInt)
            inValue.applyMaxInteger(micros.integerWidth.maxInt)
        }
        return micros
    }

    public func getPrefixSuffix(signum: UInt8, plural: StandardPlural, output: FormattedStringBuilder): Int32 {
        return getPrefixSuffixImpl(microPropsGenerator, signum, output)
    }

    private static func getPrefixSuffixImpl(generator: MicroPropsGenerator, signum: UInt8, output: FormattedStringBuilder): Int32 {
        let quantity = DecimalQuantity_DualStorageBCD(0)
        if (Int32(signum) < 0) {
            quantity.negate()
        }
        let micros = generator.processQuantity(quantity)
        micros.modMiddle.apply(output, 0, 0)
        return micros.modMiddle.getPrefixLength()
    }

    public func getRawMicroProps(): MicroProps {
        return micros
    }

    private static func unitIsCurrency(unit: MeasureUnit): Bool {
        return unit.isSome() && "currency".equals(unit.getType())
    }

    private static func unitIsBaseUnit(unit: MeasureUnit): Bool {
        return unit.isNone()
    }

    private static func unitIsPercent(unit: MeasureUnit): Bool {
        return unit.isSome() && "percent".equals(unit.getSubtype())
    }

    private static func unitIsPermille(unit: MeasureUnit): Bool {
        return unit.isSome() && "permille".equals(unit.getSubtype())
    }

    private static func macrosToMicroGenerator(macros: MacroProps, micros: MicroProps, safe: Bool): MicroPropsGenerator {
        var chain = micros
        let isCurrency = unitIsCurrency(macros.unit)
        let isBaseUnit = unitIsBaseUnit(macros.unit)
        let isPercent = unitIsPercent(macros.unit)
        let isPermille = unitIsPermille(macros.unit)
        let isCompactNotation = (checkOptionalIs<CompactNotation, Notation>(macros.notation))
        let isAccounting = refEq(macros.sign, NumberFormatter_SignDisplay.ACCOUNTING) || refEq(macros.sign, NumberFormatter_SignDisplay.ACCOUNTING_ALWAYS) || refEq(macros.sign, NumberFormatter_SignDisplay.ACCOUNTING_EXCEPT_ZERO) || refEq(macros.sign, NumberFormatter_SignDisplay.ACCOUNTING_NEGATIVE)
        let currency = if (isCurrency) { macros.unit } else { DEFAULT_CURRENCY }
        var unitWidth: NumberFormatter_UnitWidth = NumberFormatter_UnitWidth.SHORT
        if (macros.unitWidth.isSome()) {
            unitWidth = macros.unitWidth
        }
        let isCldrUnit = !isCurrency && !isBaseUnit && (refEq(unitWidth, NumberFormatter_UnitWidth.FULL_NAME) || !(isPercent || isPermille) || isCompactNotation)
        let isMixedUnit = isCldrUnit && macros.unit.getType().isNone() && refEq(macros.unit.getComplexity(), MeasureUnit_Complexity.MIXED)
        var rules = macros.rules
        let ns: NumberingSystem
        if (checkOptionalIs<NumberingSystem, Object>(macros.symbols)) {
            ns = macros.symbols
        } else {
            ns = NumberingSystem.getInstance(macros.loc)
        }
        micros.nsName = ns.getName()
        micros.gender = ""
        if (checkOptionalIs<DecimalFormatSymbols, Object>(macros.symbols)) {
            micros.symbols = macros.symbols
        } else {
            micros.symbols = DecimalFormatSymbols.forNumberingSystem(macros.loc, ns)
            if (isCurrency) {
                micros.symbols.setCurrency(currency)
            }
        }
        var pattern: String
        if (isCurrency && micros.symbols.getCurrencyPattern().isSome()) {
            pattern = micros.symbols.getCurrencyPattern()
        }
        if (pattern.isNone()) {
            let patternStyle: Int32
            if (isCldrUnit) {
                patternStyle = NumberFormat.NUMBERSTYLE
            } else if (isPercent || isPermille) {
                patternStyle = NumberFormat.PERCENTSTYLE
            } else if (!isCurrency || refEq(unitWidth, NumberFormatter_UnitWidth.FULL_NAME)) {
                patternStyle = NumberFormat.NUMBERSTYLE
            } else if (isAccounting) {
                patternStyle = NumberFormat.ACCOUNTINGCURRENCYSTYLE
            } else {
                patternStyle = NumberFormat.CURRENCYSTYLE
            }
            pattern = NumberFormat.getPatternForStyleAndNumberingSystem(macros.loc, micros.nsName, patternStyle)
        }
        let patternInfo = PatternStringParser.parseToPatternInfo(pattern)
        var usagePrefsHandler: UsagePrefsHandler
        if (macros.usage.isSome()) {
            if (!isCldrUnit) {
                throw IllegalIcuArgumentException("We only support \"usage\" when the input unit is specified, and is a CLDR Unit.")
            }
            chain = match (0) { case _ => usagePrefsHandler = UsagePrefsHandler(macros.loc, macros.unit, macros.usage, chain); usagePrefsHandler }
        } else if (isMixedUnit) {
            chain = UnitConversionHandler(macros.unit, chain)
        }
        if (macros.scale.isSome()) {
            chain = MultiplierFormatHandler(macros.scale, chain)
        }
        if (macros.precision.isSome()) {
            micros.rounder = macros.precision
        } else if (isCompactNotation) {
            micros.rounder = Precision.COMPACT_STRATEGY
        } else if (isCurrency) {
            micros.rounder = Precision.MONETARY_STANDARD
        } else if (macros.usage.isSome()) {
            micros.rounder = Precision.BOGUS_PRECISION
        } else {
            micros.rounder = Precision.DEFAULT_MAX_FRAC_6
        }
        if (macros.roundingMode.isSome()) {
            micros.rounder = micros.rounder.withMode(RoundingUtils.mathContextUnlimited(macros.roundingMode))
        }
        micros.rounder = micros.rounder.withLocaleData(currency)
        if (checkOptionalIs<Grouper, Object>(macros.grouping)) {
            micros.grouping = macros.grouping
        } else if (checkOptionalIs<NumberFormatter_GroupingStrategy, Object>(macros.grouping)) {
            micros.grouping = Grouper.forStrategy(macros.grouping)
        } else if (isCompactNotation) {
            micros.grouping = Grouper.forStrategy(NumberFormatter_GroupingStrategy.MIN2)
        } else {
            micros.grouping = Grouper.forStrategy(NumberFormatter_GroupingStrategy.AUTO)
        }
        micros.grouping = micros.grouping.withLocaleData(macros.loc, patternInfo)
        if (macros.padder.isSome()) {
            micros.padding = macros.padder
        } else {
            micros.padding = Padder.NONE
        }
        if (macros.integerWidth.isSome()) {
            micros.integerWidth = macros.integerWidth
        } else {
            micros.integerWidth = IntegerWidth.DEFAULT
        }
        if (macros.sign.isSome()) {
            micros.sign = macros.sign
        } else {
            micros.sign = NumberFormatter_SignDisplay.AUTO
        }
        if (macros.decimal.isSome()) {
            micros.decimal = macros.decimal
        } else {
            micros.decimal = NumberFormatter_DecimalSeparatorDisplay.AUTO
        }
        micros.useCurrency = isCurrency
        if (checkOptionalIs<ScientificNotation, Notation>(macros.notation)) {
            chain = macros.notation.withLocaleData(micros.symbols, safe, chain)
        } else {
            micros.modInner = ConstantAffixModifier.EMPTY
        }
        let patternMod = MutablePatternModifier(false)
        let affixProvider = if (macros.affixProvider.isSome() && (!isCompactNotation || isCurrency == macros.affixProvider.hasCurrencySign())) { macros.affixProvider } else { patternInfo }
        patternMod.setPatternInfo(affixProvider, None)
        let approximately = if (macros.approximately.isSome()) { macros.approximately.booleanValue() } else { false }
        patternMod.setPatternAttributes(micros.sign, isPermille, approximately)
        if (patternMod.needsPlurals()) {
            if (rules.isNone()) {
                rules = PluralRules.forLocale(macros.loc)
            }
            patternMod.setSymbols(micros.symbols, currency, unitWidth, rules)
        } else {
            patternMod.setSymbols(micros.symbols, currency, unitWidth, None)
        }
        var immPatternMod: MutablePatternModifier_ImmutablePatternModifier
        if (safe) {
            immPatternMod = patternMod.createImmutable()
        }
        if (affixProvider.currencyAsDecimal()) {
            micros.currencyAsDecimal = patternMod.getCurrencySymbolForUnitWidth()
        }
        if (isCldrUnit) {
            var unitDisplayCase: String
            if (macros.unitDisplayCase.isSome()) {
                unitDisplayCase = macros.unitDisplayCase
            }
            if (rules.isNone()) {
                rules = PluralRules.forLocale(macros.loc)
            }
            let pluralRules = if (macros.rules.isSome()) { macros.rules } else { PluralRules.forLocale(macros.loc) }
            if (macros.usage.isSome()) {
                if (!usagePrefsHandler.isSome()) {
                    throw AssertionError()
                }
                chain = LongNameMultiplexer.forMeasureUnits(macros.loc, usagePrefsHandler.getOutputUnits(), unitWidth, unitDisplayCase, pluralRules, chain)
            } else if (isMixedUnit) {
                chain = MixedUnitLongNameHandler.forMeasureUnit(macros.loc, macros.unit, unitWidth, unitDisplayCase, pluralRules, chain)
            } else {
                var unit = macros.unit
                if (macros.perUnit.isSome()) {
                    unit = unit.product(macros.perUnit.reciprocal())
                    if (unit.getType().isNone() && (macros.unit.getType().isNone() || macros.perUnit.getType().isNone())) {
                        throw UnsupportedOperationException("perUnit() can only be used if unit and perUnit are both built-ins, or the combination is a built-in")
                    }
                }
                chain = LongNameHandler.forMeasureUnit(macros.loc, unit, unitWidth, unitDisplayCase, pluralRules, chain)
            }
        } else if (isCurrency && refEq(unitWidth, NumberFormatter_UnitWidth.FULL_NAME)) {
            if (rules.isNone()) {
                rules = PluralRules.forLocale(macros.loc)
            }
            chain = LongNameHandler.forCurrencyLongNames(macros.loc, currency, rules, chain)
        } else {
            micros.modOuter = ConstantAffixModifier.EMPTY
        }
        if (isCompactNotation) {
            if (rules.isNone()) {
                rules = PluralRules.forLocale(macros.loc)
            }
            let compactType: CompactData_CompactType = if (checkOptionalIs<Currency, MeasureUnit>(macros.unit) && !refEq(macros.unitWidth, NumberFormatter_UnitWidth.FULL_NAME)) { CompactData_CompactType.CURRENCY } else { CompactData_CompactType.DECIMAL }
            chain = macros.notation.withLocaleData(macros.loc, micros.nsName, compactType, rules, patternMod, safe, chain)
        }
        if (safe) {
            chain = immPatternMod.addToChain(chain)
        } else {
            chain = patternMod.addToChain(chain)
        }
        return chain
    }

    public static func writeAffixes(micros: MicroProps, string: FormattedStringBuilder, start: Int32, end: Int32): Int32 {
        var length = micros.modInner.apply(string, start, end)
        if (micros.padding.isValid()) {
            micros.padding.padAndApply(micros.modMiddle, micros.modOuter, string, start, end + length)
        } else {
            length += micros.modMiddle.apply(string, start, end + length)
            length += micros.modOuter.apply(string, start, end + length)
        }
        return length
    }

    public static func writeNumber(micros: MicroProps, quantity: DecimalQuantity, string: FormattedStringBuilder, index: Int32): Int32 {
        var length = 0
        if (quantity.isInfinite()) {
            length += string.insert(length + index, micros.symbols.getInfinity(), NumberFormat_Field.INTEGER)
        } else if (quantity.isNaN()) {
            length += string.insert(length + index, micros.symbols.getNaN(), NumberFormat_Field.INTEGER)
        } else {
            length += writeIntegerDigits(micros, quantity, string, length + index)
            if (quantity.getLowerDisplayMagnitude() < 0 || refEq(micros.decimal, NumberFormatter_DecimalSeparatorDisplay.ALWAYS)) {
                if (micros.currencyAsDecimal.isSome()) {
                    length += string.insert(length + index, micros.currencyAsDecimal, NumberFormat_Field.CURRENCY)
                } else if (micros.useCurrency) {
                    length += string.insert(length + index, micros.symbols.getMonetaryDecimalSeparatorString(), NumberFormat_Field.DECIMAL_SEPARATOR)
                } else {
                    length += string.insert(length + index, micros.symbols.getDecimalSeparatorString(), NumberFormat_Field.DECIMAL_SEPARATOR)
                }
            }
            length += writeFractionDigits(micros, quantity, string, length + index)
            if (length == 0) {
                if (micros.symbols.getCodePointZero() != -1) {
                    length += string.insertCodePoint(index, micros.symbols.getCodePointZero(), NumberFormat_Field.INTEGER)
                } else {
                    length += string.insert(index, micros.symbols.getDigitStringsLocal()[0], NumberFormat_Field.INTEGER)
                }
            }
        }
        return length
    }

    private static func writeIntegerDigits(micros: MicroProps, quantity: DecimalQuantity, string: FormattedStringBuilder, index: Int32): Int32 {
        var length = 0
        let integerCount = quantity.getUpperDisplayMagnitude() + 1
        var i = 0
        while (i < integerCount) {
            if (micros.grouping.groupAtPosition(i, quantity)) {
                length += string.insert(index, if (micros.useCurrency) { micros.symbols.getMonetaryGroupingSeparatorString() } else { micros.symbols.getGroupingSeparatorString() }, NumberFormat_Field.GROUPING_SEPARATOR)
            }
            let nextDigit = quantity.getDigit(i)
            if (micros.symbols.getCodePointZero() != -1) {
                length += string.insertCodePoint(index, micros.symbols.getCodePointZero() + Int32(nextDigit), NumberFormat_Field.INTEGER)
            } else {
                length += string.insert(index, micros.symbols.getDigitStringsLocal()[Int64(nextDigit)], NumberFormat_Field.INTEGER)
            }
            i++
        }
        return length
    }

    private static func writeFractionDigits(micros: MicroProps, quantity: DecimalQuantity, string: FormattedStringBuilder, index: Int32): Int32 {
        var length = 0
        let fractionCount = -quantity.getLowerDisplayMagnitude()
        var i = 0
        while (i < fractionCount) {
            let nextDigit = quantity.getDigit(-i - 1)
            if (micros.symbols.getCodePointZero() != -1) {
                length += string.insertCodePoint(length + index, micros.symbols.getCodePointZero() + Int32(nextDigit), NumberFormat_Field.FRACTION)
            } else {
                length += string.insert(length + index, micros.symbols.getDigitStringsLocal()[Int64(nextDigit)], NumberFormat_Field.FRACTION)
            }
            i++
        }
        return length
    }
}
