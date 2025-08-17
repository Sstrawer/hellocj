package icu4cj.number


class NumberRangeFormatterImpl {
    let formatterImpl1: NumberFormatterImpl

    let formatterImpl2: NumberFormatterImpl

    let fSameFormatters: Bool

    let fCollapse: NumberRangeFormatter_RangeCollapse

    let fIdentityFallback: NumberRangeFormatter_RangeIdentityFallback

    var fRangePattern: String

    let fApproximatelyFormatter: NumberFormatterImpl

    let fPluralRanges: StandardPluralRanges

    public func identity2d(a: NumberRangeFormatter_RangeIdentityFallback, b: NumberRangeFormatter_RangeIdentityResult): Int32 {
        return a.ordinal | (shl(b.ordinal, 4))
    }

    private static func getNumberRangeData(locale: ULocale, nsName: String, out: NumberRangeFormatterImpl): Unit {
        let sb = StringBuilder()
        let sink = NumberRangeFormatterImpl_NumberRangeDataSink(sb)
        let resource: ICUResourceBundle
        resource = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, locale)
        sb.append("NumberElements/")
        sb.append(nsName)
        sb.append("/miscPatterns")
        let key: String = sb.toString()
        try {
            resource.getAllItemsWithFallback(key, sink)
        } catch (e: MissingResourceException) { }
        if (!sink.isComplete()) {
            resource.getAllItemsWithFallback("NumberElements/latn/miscPatterns", sink)
        }
        sink.fillInDefaults()
        out.fRangePattern = sink.rangePattern
    }

    public init(macros: RangeMacroProps) {
        let formatter1 = if (macros.formatter1.isSome()) { macros.formatter1.locale(macros.loc) } else { NumberFormatter.withLocale(macros.loc) }
        let formatter2 = if (macros.formatter2.isSome()) { macros.formatter2.locale(macros.loc) } else { NumberFormatter.withLocale(macros.loc) }
        formatterImpl1 = NumberFormatterImpl(formatter1.resolve())
        formatterImpl2 = NumberFormatterImpl(formatter2.resolve())
        fSameFormatters = macros.sameFormatters != 0
        fCollapse = if (macros.collapse.isSome()) { macros.collapse } else { NumberRangeFormatter_RangeCollapse.AUTO }
        fIdentityFallback = if (macros.identityFallback.isSome()) { macros.identityFallback } else { NumberRangeFormatter_RangeIdentityFallback.APPROXIMATELY }
        let nsName = formatterImpl1.getRawMicroProps().nsName
        if (nsName.isNone() || (!fSameFormatters && !nsName.equals(formatterImpl2.getRawMicroProps().nsName))) {
            throw IllegalArgumentException("Both formatters must have same numbering system")
        }
        getNumberRangeData(macros.loc, nsName, this)
        if (fSameFormatters && (refEq(fIdentityFallback, NumberRangeFormatter_RangeIdentityFallback.APPROXIMATELY) || refEq(fIdentityFallback, NumberRangeFormatter_RangeIdentityFallback.APPROXIMATELY_OR_SINGLE_VALUE))) {
            let approximatelyMacros = MacroProps()
            approximatelyMacros.approximately = Bool.valueOf(true)
            fApproximatelyFormatter = NumberFormatterImpl(formatter1.macros(approximatelyMacros).resolve())
        } else {
            fApproximatelyFormatter = None
        }
        fPluralRanges = StandardPluralRanges.forLocale(macros.loc)
    }

    public func format(quantity1: DecimalQuantity, quantity2: DecimalQuantity, equalBeforeRounding: Bool): FormattedNumberRange {
        let string = FormattedStringBuilder()
        let micros1 = formatterImpl1.preProcess(quantity1)
        let micros2: MicroProps
        if (fSameFormatters) {
            micros2 = formatterImpl1.preProcess(quantity2)
        } else {
            micros2 = formatterImpl2.preProcess(quantity2)
        }
        if (!micros1.modInner.semanticallyEquivalent(micros2.modInner) || !micros1.modMiddle.semanticallyEquivalent(micros2.modMiddle) || !micros1.modOuter.semanticallyEquivalent(micros2.modOuter)) {
            formatRange(quantity1, quantity2, string, micros1, micros2)
            return FormattedNumberRange(string, quantity1, quantity2, NumberRangeFormatter_RangeIdentityResult.NOT_EQUAL)
        }
        let identityResult: NumberRangeFormatter_RangeIdentityResult
        if (equalBeforeRounding) {
            identityResult = NumberRangeFormatter_RangeIdentityResult.EQUAL_BEFORE_ROUNDING
        } else if (refEq(quantity1, quantity2)) {
            identityResult = NumberRangeFormatter_RangeIdentityResult.EQUAL_AFTER_ROUNDING
        } else {
            identityResult = NumberRangeFormatter_RangeIdentityResult.NOT_EQUAL
        }
        // Switch statement for identity2d
        if (identity2d(fIdentityFallback, identityResult) == (3 | (2 << 4))) {

        } else if (identity2d(fIdentityFallback, identityResult) == (3 | (1 << 4))) {

        } else if (identity2d(fIdentityFallback, identityResult) == (3 | (0 << 4))) {

        } else if (identity2d(fIdentityFallback, identityResult) == (2 | (2 << 4))) {

        } else if (identity2d(fIdentityFallback, identityResult) == (1 | (2 << 4))) {

        } else if (identity2d(fIdentityFallback, identityResult) == (0 | (2 << 4))) {
            formatRange(quantity1, quantity2, string, micros1, micros2);
            break;

        } else if (identity2d(fIdentityFallback, identityResult) == (2 | (1 << 4))) {

        } else if (identity2d(fIdentityFallback, identityResult) == (2 | (0 << 4))) {

        } else if (identity2d(fIdentityFallback, identityResult) == (1 | (1 << 4))) {
            formatApproximately(quantity1, quantity2, string, micros1, micros2);
            break;

        } else if (identity2d(fIdentityFallback, identityResult) == (1 | (0 << 4))) {

        } else if (identity2d(fIdentityFallback, identityResult) == (2 | (0 << 4))) {

        } else if (identity2d(fIdentityFallback, identityResult) == (0 | (0 << 4))) {
            formatSingleValue(quantity1, quantity2, string, micros1, micros2);
            break;

        } else {
            if (!false) { throw AssertionError() }
            break;

        }
        return FormattedNumberRange(string, quantity1, quantity2, identityResult)
    }

    private func formatSingleValue(quantity1: DecimalQuantity, quantity2: DecimalQuantity, string: FormattedStringBuilder, micros1: MicroProps, micros2: MicroProps): Unit {
        if (fSameFormatters) {
            let length = NumberFormatterImpl.writeNumber(micros1, quantity1, string, 0)
            NumberFormatterImpl.writeAffixes(micros1, string, 0, length)
        } else {
            formatRange(quantity1, quantity2, string, micros1, micros2)
        }
    }

    private func formatApproximately(quantity1: DecimalQuantity, quantity2: DecimalQuantity, string: FormattedStringBuilder, micros1: MicroProps, micros2: MicroProps): Unit {
        if (fSameFormatters) {
            quantity1.resetExponent()
            let microsAppx = fApproximatelyFormatter.preProcess(quantity1)
            var length = NumberFormatterImpl.writeNumber(microsAppx, quantity1, string, 0)
            length += microsAppx.modInner.apply(string, 0, length)
            length += microsAppx.modMiddle.apply(string, 0, length)
            microsAppx.modOuter.apply(string, 0, length)
        } else {
            formatRange(quantity1, quantity2, string, micros1, micros2)
        }
    }

    private func formatRange(quantity1: DecimalQuantity, quantity2: DecimalQuantity, string: FormattedStringBuilder, micros1: MicroProps, micros2: MicroProps): Unit {
        let collapseOuter: Bool
        var collapseMiddle: Bool = false
        let collapseInner: Bool
        match (fCollapse) {
            case NumberRangeFormatter_RangeCollapse.ALL | NumberRangeFormatter_RangeCollapse.AUTO | NumberRangeFormatter_RangeCollapse.UNIT =>
                collapseOuter = micros1.modOuter.semanticallyEquivalent(micros2.modOuter)
                if (!collapseOuter) {
                    collapseMiddle = false
                    collapseInner = false
                    break
                }
                collapseMiddle = micros1.modMiddle.semanticallyEquivalent(micros2.modMiddle)
                if (!collapseMiddle) {
                    collapseInner = false
                    break
                }
                let mm = micros1.modMiddle
                if (refEq(fCollapse, NumberRangeFormatter_RangeCollapse.UNIT)) {
                    if (!mm.containsField(NumberFormat_Field.CURRENCY) && !mm.containsField(NumberFormat_Field.PERCENT)) {
                        collapseMiddle = false
                    }
                } else if (refEq(fCollapse, NumberRangeFormatter_RangeCollapse.AUTO)) {
                    if (mm.getCodePointCount() <= 1) {
                        collapseMiddle = false
                    }
                }
                if (!collapseMiddle || !refEq(fCollapse, NumberRangeFormatter_RangeCollapse.ALL)) {
                    collapseInner = false
                    break
                }
                collapseInner = micros1.modInner.semanticallyEquivalent(micros2.modInner)
                break
            case _ =>
                collapseOuter = false
                collapseMiddle = false
                collapseInner = false
        }
        let h = PrefixInfixSuffixLengthHelper()
        SimpleModifier.formatTwoArgPattern(fRangePattern, string, 0, h, None)
        if (!(h.lengthInfix > 0)) {
            throw AssertionError()
        }
        if (!PatternProps.isWhiteSpace(Int32(UInt32(string.toRuneArray()[h.index2() - 1])))) {
            h.lengthInfix += string.insertCodePoint(h.index2(), Int32(UInt32(' ')), None)
        }
        // End of do-while loop
        h.length1 += NumberFormatterImpl.writeNumber(micros1, quantity1, string, h.index0())
        let tempString = FormattedStringBuilder()
        NumberFormatterImpl.writeNumber(micros2, quantity2, tempString, 0)
        h.length2 += string.insert(h.index2(), tempString)
        if (collapseInner) {
            let mod = resolveModifierPlurals(micros1.modInner, micros2.modInner)
            h.lengthSuffix += mod.apply(string, h.index0(), h.index4())
            h.lengthPrefix += mod.getPrefixLength()
            h.lengthSuffix -= mod.getPrefixLength()
        } else {
            h.length1 += micros1.modInner.apply(string, h.index0(), h.index1())
            h.length2 += micros2.modInner.apply(string, h.index2(), h.index4())
        }
        if (collapseMiddle) {
            let mod = resolveModifierPlurals(micros1.modMiddle, micros2.modMiddle)
            h.lengthSuffix += mod.apply(string, h.index0(), h.index4())
            h.lengthPrefix += mod.getPrefixLength()
            h.lengthSuffix -= mod.getPrefixLength()
        } else {
            h.length1 += micros1.modMiddle.apply(string, h.index0(), h.index1())
            h.length2 += micros2.modMiddle.apply(string, h.index2(), h.index4())
        }
        if (collapseOuter) {
            let mod = resolveModifierPlurals(micros1.modOuter, micros2.modOuter)
            h.lengthSuffix += mod.apply(string, h.index0(), h.index4())
            h.lengthPrefix += mod.getPrefixLength()
            h.lengthSuffix -= mod.getPrefixLength()
        } else {
            h.length1 += micros1.modOuter.apply(string, h.index0(), h.index1())
            h.length2 += micros2.modOuter.apply(string, h.index2(), h.index4())
        }
        FormattedValueStringBuilderImpl.applySpanRange(string, NumberRangeFormatter_SpanField.NUMBER_RANGE_SPAN, 0, h.index0(), h.index1())
        FormattedValueStringBuilderImpl.applySpanRange(string, NumberRangeFormatter_SpanField.NUMBER_RANGE_SPAN, 1, h.index2(), h.index3())
    }

    public func resolveModifierPlurals(first: Modifier, second: Modifier): Modifier {
        let firstParameters = first.getParameters()
        if (firstParameters.isNone()) {
            return first
        }
        let secondParameters = second.getParameters()
        if (secondParameters.isNone()) {
            return first
        }
        let resultPlural = fPluralRanges.resolve(firstParameters.plural, secondParameters.plural)
        let mod = firstParameters.obj.getModifier(firstParameters.signum, resultPlural)
        if (!mod.isSome()) {
            throw AssertionError()
        }
        return mod
    }
}


class NumberRangeFormatterImpl_NumberRangeDataSink <: UResource_Sink {
    var rangePattern: String

    var sb: StringBuilder

    init(sb: StringBuilder) {
        super()
        this.sb = sb
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let miscTable = value.getTable()
        var i = 0
        while (miscTable.getKeyAndValue(i, key, value)) {
            if (key.contentEquals("range") && !hasRangeData()) {
                let pattern = value.getString()
                rangePattern = SimpleFormatterImpl.compileToStringMinMaxArguments(pattern, sb, 2, 2)
            }
            i++
        }
    }

    private func hasRangeData(): Bool {
        return rangePattern.isSome()
    }

    public func isComplete(): Bool {
        return hasRangeData()
    }

    public func fillInDefaults(): Unit {
        if (!hasRangeData()) {
            rangePattern = SimpleFormatterImpl.compileToStringMinMaxArguments("{0}\u{2013}{1}", sb, 2, 2)
        }
    }
}
