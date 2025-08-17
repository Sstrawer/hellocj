package icu4cj.message2


class NumberFormatterFactory <: FormatterFactory & SelectorFactory {
    private let kind: String

    public init(kind: String) {
        var tempkind = kind
        match (tempkind) {
            case "number" | "integer" => ()
            case _ => tempkind = "number"
        }
        this.kind = tempkind
    }

    public override func createFormatter(locale: Locale, fixedOptions: Map<String, Object>): Formatter {
        return NumberFormatterFactory_NumberFormatterImpl(locale, fixedOptions, kind)
    }

    public override func createSelector(locale: Locale, fixedOptions: Map<String, Object>): Selector {
        let Type = OptUtils.getString(fixedOptions, "select", "")
        let pluralType: PluralRules_PluralType
        match (Type) {
            case "ordinal" => pluralType = PluralRules_PluralType.ORDINAL
            case "cardinal" => pluralType = PluralRules_PluralType.CARDINAL
            case _ => pluralType = PluralRules_PluralType.CARDINAL
        }
        let rules = PluralRules.forLocale(locale, pluralType)
        return NumberFormatterFactory_PluralSelectorImpl(locale, rules, fixedOptions, kind)
    }

    static func formatterForOptions(locale: Locale, fixedOptions: Map<String, Object>, kind: String): LocalizedNumberFormatter {
        var nf: UnlocalizedNumberFormatter
        let skeleton = OptUtils.getString(fixedOptions, "icu:skeleton")
        if (skeleton.isSome()) {
            return NumberFormatter.forSkeleton(skeleton).locale(locale)
        }
        var option: Int32
        var strOption: String
        nf = NumberFormatter.`with`()
        if ("number".equals(kind)) {
            let notation: Notation
            match (OptUtils.getString(fixedOptions, "notation", "standard")) {
                case "scientific" => notation = Notation.scientific()
                case "engineering" => notation = Notation.engineering()
                case "compact" => match (OptUtils.getString(fixedOptions, "compactDisplay", "short")) {
                    case "long" => notation = Notation.compactLong()
                    case "short" => notation = Notation.compactShort()
                    case _ => notation = Notation.compactShort()
                }
                case "standard" => notation = Notation.simple()
                case _ => notation = Notation.simple()
            }
            nf = nf.notation(notation)
            strOption = OptUtils.getString(fixedOptions, "style", "decimal")
            if (strOption == "percent") {
                nf = nf.unit(MeasureUnit.PERCENT).scale(Scale.powerOfTen(2))
            }
            option = OptUtils.getInteger(fixedOptions, "minimumFractionDigits")
            if (option.isSome()) {
                nf = nf.precision(Precision.minFraction(option))
            }
            option = OptUtils.getInteger(fixedOptions, "maximumFractionDigits")
            if (option.isSome()) {
                nf = nf.precision(Precision.maxFraction(option))
            }
            option = OptUtils.getInteger(fixedOptions, "minimumSignificantDigits")
            if (option.isSome()) {
                nf = nf.precision(Precision.minSignificantDigits(option))
            }
        }
        strOption = OptUtils.getString(fixedOptions, "numberingSystem", "")
        if (!strOption.isEmpty()) {
            strOption = strOption.toLowerCase(Locale.US)
            let ns = NumberingSystem.getInstanceByName(strOption)
            nf = nf.symbols(ns)
        }
        option = OptUtils.getInteger(fixedOptions, "minimumIntegerDigits")
        if (option.isSome()) { }
        option = OptUtils.getInteger(fixedOptions, "maximumSignificantDigits")
        if (option.isSome()) {
            nf = nf.precision(Precision.maxSignificantDigits(option))
        }
        strOption = OptUtils.getString(fixedOptions, "signDisplay", "auto")
        let signDisplay: NumberFormatter_SignDisplay
        match (strOption) {
            case "always" => signDisplay = NumberFormatter_SignDisplay.ALWAYS
            case "exceptZero" => signDisplay = NumberFormatter_SignDisplay.EXCEPT_ZERO
            case "negative" => signDisplay = NumberFormatter_SignDisplay.NEGATIVE
            case "never" => signDisplay = NumberFormatter_SignDisplay.NEVER
            case "auto" => signDisplay = NumberFormatter_SignDisplay.AUTO
            case _ => signDisplay = NumberFormatter_SignDisplay.AUTO
        }
        nf = nf.sign(signDisplay)
        let grp: NumberFormatter_GroupingStrategy
        strOption = OptUtils.getString(fixedOptions, "useGrouping", "auto")
        match (strOption) {
            case "always" => grp = NumberFormatter_GroupingStrategy.ON_ALIGNED
            case "never" => grp = NumberFormatter_GroupingStrategy.OFF
            case "min2" => grp = NumberFormatter_GroupingStrategy.MIN2
            case "auto" => grp = NumberFormatter_GroupingStrategy.AUTO
            case _ => grp = NumberFormatter_GroupingStrategy.AUTO
        }
        nf = nf.grouping(grp)
        if (kind == "integer") {
            nf = nf.precision(Precision.integer())
        }
        return nf.locale(locale)
    }
}


class NumberFormatterFactory_NumberFormatterImpl <: Formatter {
    private let locale: Locale

    private let fixedOptions: Map<String, Object>

    private let icuFormatter: LocalizedNumberFormatter

    private let kind: String

    let advanced: Bool

    init(locale: Locale, fixedOptions: Map<String, Object>, kind: String) {
        this.locale = locale
        this.fixedOptions = HashMap<String, Object>(fixedOptions)
        let skeleton = OptUtils.getString(fixedOptions, "icu:skeleton")
        let fancy = skeleton.isSome()
        this.icuFormatter = NumberFormatterFactory.formatterForOptions(locale, fixedOptions, kind)
        this.advanced = fancy
        this.kind = kind
    }

    public func getIcuFormatter(): LocalizedNumberFormatter {
        return icuFormatter
    }

    public override func formatToString(toFormat: Object, variableOptions: Map<String, Object>): String {
        return format(toFormat, variableOptions).toString()
    }

    public override func format(toFormat: Object, variableOptions: Map<String, Object>): FormattedPlaceholder {
        let realFormatter: LocalizedNumberFormatter
        if (variableOptions.isEmpty()) {
            realFormatter = this.icuFormatter
        } else {
            let mergedOptions: Map<String, Object> = HashMap<String, Object>(fixedOptions)
            mergedOptions.putAll(variableOptions)
            realFormatter = NumberFormatterFactory.formatterForOptions(locale, mergedOptions, kind)
        }
        var offset = OptUtils.getInteger(variableOptions, "icu:offset")
        if (offset.isNone() && fixedOptions.isSome()) {
            offset = OptUtils.getInteger(fixedOptions, "icu:offset")
        }
        if (offset.isNone()) {
            offset = 0
        }
        var result: FormattedValue
        if (toFormat.isNone()) {
            throw NoneValueException("Argument to format can't be null")
        } else if (toFormat) {
            result = realFormatter.format(toFormat - Float64(offset))
        } else if (toFormat) {
            result = realFormatter.format(toFormat - Int64(offset))
        } else if (toFormat) {
            result = realFormatter.format(Int64(toFormat - offset))
        } else if (checkOptionalIs<BigDecimal, Object>(toFormat)) {
            let bd = toFormat
            result = realFormatter.format(bd.subtract(BigDecimal.valueOf(Int64(offset))))
        } else if (checkOptionalIs<Number, Object>(toFormat)) {
            result = realFormatter.format(toFormat.doubleValue() - Float64(offset))
        } else if (checkOptionalIs<CurrencyAmount, Object>(toFormat)) {
            result = realFormatter.format(toFormat)
        } else {
            let strValue = Objects.toString(toFormat)
            let nrValue = OptUtils.asNumber(strValue)
            if (nrValue.isSome()) {
                result = realFormatter.format(nrValue.doubleValue() - Float64(offset))
            } else {
                result = PlainStringFormattedValue("{|" + (strValue) + "|}")
            }
        }
        return FormattedPlaceholder(toFormat, result)
    }
}


class NumberFormatterFactory_PluralSelectorImpl <: Selector {
    private static let NO_MATCH = "\u{fffd}NO_MATCH\u{fffe}"

    private let rules: PluralRules

    private var fixedOptions: Map<String, Object> = None

    private var icuFormatter: LocalizedNumberFormatter

    init(locale: Locale, rules: PluralRules, fixedOptions: Map<String, Object>, kind: String) {
        this.rules = rules
        this.fixedOptions = fixedOptions
        this.icuFormatter = NumberFormatterFactory.formatterForOptions(locale, fixedOptions, kind)
    }

    public override func matches(value: Object, keys: ArrayList<String>, variableOptions: Map<String, Object>): ArrayList<String> {
        let result = ArrayList<String>()
        if (value.isNone()) {
            return result
        }
        for (key in keys) {
            if (matches(value, key, variableOptions)) {
                result.append(key)
            } else {
                result.append(NO_MATCH)
            }
        }
        result.sort(// Unimplemented feature MEMBER_REFERENCE: NumberFormatterFactory$PluralSelectorImpl::pluralComparator)
        return result
    }

    private static func pluralComparator(o1: String, o2: String): Int32 {
        if (o1.equals(o2)) {
            return 0
        }
        if (NO_MATCH.equals(o1)) {
            return 1
        }
        if (NO_MATCH.equals(o2)) {
            return -1
        }
        if ("*".equals(o1)) {
            return 1
        }
        if ("*".equals(o2)) {
            return -1
        }
        if (OptUtils.asNumber(o1).isSome()) {
            return -1
        }
        if (OptUtils.asNumber(o2).isSome()) {
            return 1
        }
        return o1.compare(o2).value()
    }

    private func matches(value: Object, key: String, variableOptions: Map<String, Object>): Bool {
        var tempvalue = value
        if ("*".equals(key)) {
            return true
        }
        var offset = OptUtils.getInteger(variableOptions, "icu:offset")
        if (offset.isNone() && fixedOptions.isSome()) {
            offset = OptUtils.getInteger(fixedOptions, "icu:offset")
        }
        if (offset.isNone()) {
            offset = 0
        }
        var valToCheck: Number = Float64.Min
        if (checkOptionalIs<FormattedPlaceholder, Object>(tempvalue)) {
            let fph = tempvalue
            tempvalue = fph.getInput()
        }
        if (checkOptionalIs<Number, Object>(tempvalue)) {
            valToCheck = tempvalue.doubleValue()
        } else {
            return false
        }
        let keyNrVal = OptUtils.asNumber(key)
        if (keyNrVal.isSome() && valToCheck.doubleValue() == keyNrVal.doubleValue()) {
            return true
        }
        let formatted = icuFormatter.format(valToCheck.doubleValue() - Float64(offset))
        var match = rules.select(formatted)
        if (match == "other") {
            match = "*"
        }
        return match.equals(key)
    }
}
