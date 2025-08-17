package icu4cj.number


class NumberPropertyMapper {

    public static func create(properties: DecimalFormatProperties, symbols: DecimalFormatSymbols): UnlocalizedNumberFormatter {
        let macros = oldToNew(properties, symbols, None)
        return NumberFormatter.`with`().macros(macros)
    }

    public static func create(properties: DecimalFormatProperties, symbols: DecimalFormatSymbols, exportedProperties: DecimalFormatProperties): UnlocalizedNumberFormatter {
        let macros = oldToNew(properties, symbols, exportedProperties)
        return NumberFormatter.`with`().macros(macros)
    }

    public static func create(pattern: String, symbols: DecimalFormatSymbols): UnlocalizedNumberFormatter {
        let properties = PatternStringParser.parseToProperties(pattern)
        return create(properties, symbols)
    }

    public static func oldToNew(properties: DecimalFormatProperties, symbols: DecimalFormatSymbols, exportedProperties: DecimalFormatProperties): MacroProps {
        let macros = MacroProps()
        let locale = symbols.getULocale()
        macros.symbols = symbols
        var rules = properties.getPluralRules()
        if (rules.isNone() && properties.getCurrencyPluralInfo().isSome()) {
            rules = properties.getCurrencyPluralInfo().getPluralRules()
        }
        macros.rules = rules
        let affixProvider = PropertiesAffixPatternProvider.forProperties(properties)
        macros.affixProvider = affixProvider
        let useCurrency = ((properties.getCurrency().isSome()) || properties.getCurrencyPluralInfo().isSome() || properties.getCurrencyUsage().isSome() || affixProvider.hasCurrencySign())
        let currency = CustomSymbolCurrency.resolve(properties.getCurrency(), locale, symbols)
        var currencyUsage = properties.getCurrencyUsage()
        let explicitCurrencyUsage = currencyUsage.isSome()
        if (!explicitCurrencyUsage) {
            currencyUsage = Currency_CurrencyUsage.STANDARD
        }
        if (useCurrency) {
            macros.unit = currency
        }
        var maxInt = properties.getMaximumIntegerDigits()
        var minInt = properties.getMinimumIntegerDigits()
        var maxFrac = properties.getMaximumFractionDigits()
        var minFrac = properties.getMinimumFractionDigits()
        var minSig = properties.getMinimumSignificantDigits()
        var maxSig = properties.getMaximumSignificantDigits()
        var roundingIncrement = properties.getRoundingIncrement()
        let mathContext = RoundingUtils.getMathContextOrUnlimited(properties)
        let explicitMinMaxFrac = minFrac != -1 || maxFrac != -1
        let explicitMinMaxSig = minSig != -1 || maxSig != -1
        if (useCurrency) {
            if (minFrac == -1 && maxFrac == -1) {
                minFrac = currency.getDefaultFractionDigits(currencyUsage)
                maxFrac = currency.getDefaultFractionDigits(currencyUsage)
            } else if (minFrac == -1) {
                minFrac = min(maxFrac, currency.getDefaultFractionDigits(currencyUsage))
            } else if (maxFrac == -1) {
                maxFrac = max(minFrac, currency.getDefaultFractionDigits(currencyUsage))
            } else { }
        }
        if (minInt == 0 && maxFrac != 0) {
            minFrac = if (minFrac < 0 || (minFrac == 0 && maxInt == 0)) { 1 } else { minFrac }
            maxFrac = if (maxFrac < 0) { -1 } else { if (maxFrac < minFrac) { minFrac } else { maxFrac } }
            minInt = 0
            maxInt = if (maxInt < 0) { -1 } else { if (maxInt > RoundingUtils.MAX_INT_FRAC_SIG) { -1 } else { maxInt } }
        } else {
            minFrac = if (minFrac < 0) { 0 } else { minFrac }
            maxFrac = if (maxFrac < 0) { -1 } else { if (maxFrac < minFrac) { minFrac } else { maxFrac } }
            minInt = if (minInt <= 0) { 1 } else { if (minInt > RoundingUtils.MAX_INT_FRAC_SIG) { 1 } else { minInt } }
            maxInt = if (maxInt < 0) { -1 } else { if (maxInt < minInt) { minInt } else { if (maxInt > RoundingUtils.MAX_INT_FRAC_SIG) { -1 } else { maxInt } } }
        }
        var rounding: Precision
        if (explicitCurrencyUsage) {
            rounding = Precision.constructCurrency(currencyUsage).withCurrency(currency)
        } else if (roundingIncrement.isSome()) {
            if (PatternStringUtils.ignoreRoundingIncrement(roundingIncrement, maxFrac)) {
                rounding = Precision.constructFraction(minFrac, maxFrac)
            } else {
                if (minFrac > roundingIncrement.scale()) {
                    roundingIncrement = roundingIncrement.setScale(minFrac)
                }
                rounding = Precision.constructIncrement(roundingIncrement)
            }
        } else if (explicitMinMaxSig) {
            minSig = if (minSig < 1) { 1 } else { if (minSig > RoundingUtils.MAX_INT_FRAC_SIG) { RoundingUtils.MAX_INT_FRAC_SIG } else { minSig } }
            maxSig = if (maxSig < 0) { RoundingUtils.MAX_INT_FRAC_SIG } else { if (maxSig < minSig) { minSig } else { if (maxSig > RoundingUtils.MAX_INT_FRAC_SIG) { RoundingUtils.MAX_INT_FRAC_SIG } else { maxSig } } }
            rounding = Precision.constructSignificant(minSig, maxSig)
        } else if (explicitMinMaxFrac) {
            rounding = Precision.constructFraction(minFrac, maxFrac)
        } else if (useCurrency) {
            rounding = Precision.constructCurrency(currencyUsage)
        }
        if (rounding.isSome()) {
            rounding = rounding.withMode(mathContext)
            macros.precision = rounding
        }
        macros.integerWidth = IntegerWidth.zeroFillTo(minInt).truncateAt(maxInt)
        macros.grouping = Grouper.forProperties(properties)
        if (properties.getFormatWidth() > 0) {
            macros.padder = Padder.forProperties(properties)
        }
        macros.decimal = if (properties.getDecimalSeparatorAlwaysShown()) { NumberFormatter_DecimalSeparatorDisplay.ALWAYS } else { NumberFormatter_DecimalSeparatorDisplay.AUTO }
        macros.sign = if (properties.getSignAlwaysShown()) { NumberFormatter_SignDisplay.ALWAYS } else { NumberFormatter_SignDisplay.AUTO }
        if (properties.getMinimumExponentDigits() != -1) {
            if (maxInt > 8) {
                maxInt = minInt
                macros.integerWidth = IntegerWidth.zeroFillTo(minInt).truncateAt(maxInt)
            } else if (maxInt > minInt && minInt > 1) {
                minInt = 1
                macros.integerWidth = IntegerWidth.zeroFillTo(minInt).truncateAt(maxInt)
            }
            let engineering = if (maxInt < 0) { -1 } else { maxInt }
            macros.notation = ScientificNotation(engineering, (engineering == minInt), properties.getMinimumExponentDigits(), if (properties.getExponentSignAlwaysShown()) { NumberFormatter_SignDisplay.ALWAYS } else { NumberFormatter_SignDisplay.AUTO })
            if (checkOptionalIs<FractionPrecision, Precision>(macros.precision)) {
                let maxInt_ = properties.getMaximumIntegerDigits()
                var minInt_ = properties.getMinimumIntegerDigits()
                let minFrac_ = properties.getMinimumFractionDigits()
                let maxFrac_ = properties.getMaximumFractionDigits()
                if (minInt_ == 0 && maxFrac_ == 0) {
                    macros.precision = Precision.constructInfinite().withMode(mathContext)
                } else if (minInt_ == 0 && minFrac_ == 0) {
                    macros.precision = Precision.constructSignificant(1, maxFrac_ + 1).withMode(mathContext)
                } else {
                    let maxSig_ = minInt_ + maxFrac_
                    if (maxInt_ > minInt_ && minInt_ > 1) {
                        minInt_ = 1
                    }
                    let minSig_ = minInt_ + minFrac_
                    macros.precision = Precision.constructSignificant(minSig_, maxSig_).withMode(mathContext)
                }
            }
        }
        if (properties.getCompactStyle().isSome()) {
            if (properties.getCompactCustomData().isSome()) {
                macros.notation = CompactNotation(properties.getCompactCustomData())
            } else if (refEq(properties.getCompactStyle(), CompactDecimalFormat_CompactStyle.LONG)) {
                macros.notation = Notation.compactLong()
            } else {
                macros.notation = Notation.compactShort()
            }
        }
        macros.scale = RoundingUtils.scaleFromProperties(properties)
        if (exportedProperties.isSome()) {
            exportedProperties.setCurrency(currency)
            exportedProperties.setMathContext(mathContext)
            exportedProperties.setRoundingMode(mathContext.getRoundingMode())
            exportedProperties.setMinimumIntegerDigits(minInt)
            exportedProperties.setMaximumIntegerDigits(if (maxInt == -1) { Int32.Max } else { maxInt })
            let rounding_: Precision
            if (checkOptionalIs<CurrencyPrecision, Precision>(rounding)) {
                rounding_ = rounding.withCurrency(currency)
            } else {
                rounding_ = rounding
            }
            var minFrac_ = minFrac
            var maxFrac_ = maxFrac
            var minSig_ = minSig
            var maxSig_ = maxSig
            var increment_: BigDecimal = None
            if (checkOptionalIs<Precision_FractionRounderImpl, Precision>(rounding_)) {
                minFrac_ = rounding_.minFrac
                maxFrac_ = rounding_.maxFrac
            } else if (checkOptionalIs<Precision_IncrementRounderImpl, Precision>(rounding_)) {
                increment_ = rounding_.increment
                minFrac_ = increment_.scale()
                maxFrac_ = increment_.scale()
            } else if (checkOptionalIs<Precision_SignificantRounderImpl, Precision>(rounding_)) {
                minSig_ = rounding_.minSig
                maxSig_ = rounding_.maxSig
            }
            exportedProperties.setMinimumFractionDigits(minFrac_)
            exportedProperties.setMaximumFractionDigits(maxFrac_)
            exportedProperties.setMinimumSignificantDigits(minSig_)
            exportedProperties.setMaximumSignificantDigits(maxSig_)
            exportedProperties.setRoundingIncrement(increment_)
        }
        return macros
    }
}
