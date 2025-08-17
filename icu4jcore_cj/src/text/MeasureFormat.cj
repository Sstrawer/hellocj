package icu4cj.text


public class MeasureFormat <: UFormat & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    static let serialVersionUID = -7182021401701778240

     private let formatWidth: MeasureFormat_FormatWidth

     private let rules: PluralRules

     private let numericFormatters: MeasureFormat_NumericFormatters

     private let numberFormat: NumberFormat

     private let numberFormatter: LocalizedNumberFormatter

    private static let localeToNumericDurationFormatters = SimpleCache<ULocale, MeasureFormat_NumericFormatters>()

    private static let hmsTo012: Map<MeasureUnit, Int32> = HashMap<MeasureUnit, Int32>()


    static let MEASURE_FORMAT = 0

    static let TIME_UNIT_FORMAT = 1

    static let CURRENCY_FORMAT = 2

    public static func getInstance(locale: ULocale, formatWidth: MeasureFormat_FormatWidth): MeasureFormat {
        return getInstance(locale, formatWidth, NumberFormat.getInstance(locale))
    }

    public static func getInstance(locale: Locale, formatWidth: MeasureFormat_FormatWidth): MeasureFormat {
        return getInstance(ULocale.forLocale(locale), formatWidth)
    }

    public static func getInstance(locale: ULocale, formatWidth: MeasureFormat_FormatWidth, format: NumberFormat): MeasureFormat {
        return MeasureFormat(locale, formatWidth, format, None, None)
    }

    public static func getInstance(locale: Locale, formatWidth: MeasureFormat_FormatWidth, format: NumberFormat): MeasureFormat {
        return getInstance(ULocale.forLocale(locale), formatWidth, format)
    }

    public override func format(obj: Object, toAppendTo: StringBuffer, fpos: FieldPosition): StringBuffer {
        let prevLength = Int32(toAppendTo.size)
        fpos.setBeginIndex(0)
        fpos.setEndIndex(0)
        if (checkOptionalIs<Collection<Any>, Object>(obj)) {
            let coll = obj
            let measures = Array<Measure>(coll.size)
            var idx = 0
            for (o in coll) {
                if (!(checkOptionalIs<Measure, Object>(o))) {
                    throw IllegalArgumentException(toString(obj))
                }
                measures[Int64(match (0) { case _ => idx++; idx - 1 })] = o
            }
            formatMeasuresInternal(toAppendTo, fpos, measures)
        } else if (obj) {
            formatMeasuresInternal(toAppendTo, fpos, obj)
        } else if (checkOptionalIs<Measure, Object>(obj)) {
            let result = formatMeasure(obj)
            FormattedValueStringBuilderImpl.nextFieldPosition(result, fpos)
            Utility.appendTo(result, toAppendTo)
        } else {
            throw IllegalArgumentException(toString(obj))
        }
        if (prevLength > 0 && fpos.getEndIndex() != 0) {
            fpos.setBeginIndex(fpos.getBeginIndex() + prevLength)
            fpos.setEndIndex(fpos.getEndIndex() + prevLength)
        }
        return toAppendTo
    }

    public override func parseObject(source: String, pos: ParsePosition): Measure {
        throw UnsupportedOperationException()
    }

    public func formatMeasures(measures: Array<Measure>): String {
        return formatMeasures(StringBuilder(), DontCareFieldPosition.INSTANCE, measures).toString()
    }

    public func formatMeasurePerUnit(measure: Measure, perUnit: MeasureUnit, appendTo: StringBuilder, pos: FieldPosition): StringBuilder {
        let dq: DecimalQuantity = DecimalQuantity_DualStorageBCD(measure.getNumber())
        let string = FormattedStringBuilder()
        getUnitFormatterFromCache(NUMBER_FORMATTER_STANDARD, measure.getUnit(), perUnit).formatImpl(dq, string)
        DecimalFormat.fieldPositionHelper(dq, string, pos, Int32(appendTo.size))
        // Constraints not satisfied [^A <: interface java8$java.lang.Appendable=class std$core.StringBuilder]: Utility.appendTo(string, appendTo)
        return appendTo
    }

    public func formatMeasures(appendTo: StringBuilder, fpos: FieldPosition, measures: Array<Measure>): StringBuilder {
        let prevLength = Int32(appendTo.size)
        formatMeasuresInternal(appendTo, fpos, measures)
        if (prevLength > 0 && fpos.getEndIndex() > 0) {
            fpos.setBeginIndex(fpos.getBeginIndex() + prevLength)
            fpos.setEndIndex(fpos.getEndIndex() + prevLength)
        }
        return appendTo
    }

    private func formatMeasuresInternal(appendTo: Appendable, fieldPosition: FieldPosition, measures: Array<Measure>): Unit {
        if (Int32(measures.size) == 0) {
            return
        }
        if (Int32(measures.size) == 1) {
            let result = formatMeasure(measures[0])
            FormattedValueStringBuilderImpl.nextFieldPosition(result, fieldPosition)
            Utility.appendTo(result, appendTo)
            return
        }
        if (refEq(formatWidth, MeasureFormat_FormatWidth.NUMERIC)) {
            let hms = toHMS(measures)
            if (hms.isSome()) {
                formatNumeric(hms, appendTo)
                return
            }
        }
        let listFormatter = ListFormatter.getInstance(getLocale(), ListFormatter_Type.UNITS, formatWidth.listWidth)
        if (!refEq(fieldPosition, DontCareFieldPosition.INSTANCE)) {
            formatMeasuresSlowTrack(listFormatter, appendTo, fieldPosition, measures)
            return
        }
        let results = Array<String>(measures.size)
        var i = 0
        while (i < Int32(measures.size)) {
            if (i == Int32(measures.size) - 1) {
                results[Int64(i)] = formatMeasure(measures[Int64(i)]).toString()
            } else {
                results[Int64(i)] = formatMeasureInteger(measures[Int64(i)]).toString()
            }
            i++
        }
        let builder = listFormatter.formatImpl(results, false)
        builder.appendTo(appendTo)
    }

    public func getUnitDisplayName(unit: MeasureUnit): String {
        return LongNameHandler.getUnitDisplayName(getLocale(), unit, formatWidth.unitWidth)
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (!(checkOptionalIs<MeasureFormat, Object>(other))) {
            return false
        }
        let rhs = other
        return refEq(getWidth(), rhs.getWidth()) && getLocale().equals(rhs.getLocale()) && getNumberFormatInternal().equals(rhs.getNumberFormatInternal())
    }

    public override func hashCode(): Int64 {
        return Int64((Int32(getLocale().hashCode()) * 31 + Int32(getNumberFormatInternal().hashCode())) * 31 + Int32(getWidth().hashCode()))
    }

    public func getWidth(): MeasureFormat_FormatWidth {
        if (refEq(formatWidth, MeasureFormat_FormatWidth.DEFAULT_CURRENCY)) {
            return MeasureFormat_FormatWidth.WIDE
        }
        return formatWidth
    }

    public func getLocale(): ULocale {
        return getLocale(ULocale.VALID_LOCALE)
    }

    public func getNumberFormat(): NumberFormat {
        return numberFormat.clone()
    }

    public func getNumberFormatInternal(): NumberFormat {
        return numberFormat
    }

    public static func getCurrencyFormat(locale: ULocale): MeasureFormat {
        return CurrencyFormat(locale)
    }

    public static func getCurrencyFormat(locale: Locale): MeasureFormat {
        return getCurrencyFormat(ULocale.forLocale(locale))
    }

    public static func getCurrencyFormat(): MeasureFormat {
        return getCurrencyFormat(ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public func withLocale(locale: ULocale): MeasureFormat {
        return MeasureFormat.getInstance(locale, getWidth())
    }

    public func withNumberFormat(format: NumberFormat): MeasureFormat {
        return MeasureFormat(getLocale(), this.formatWidth, format, this.rules, this.numericFormatters)
    }

    init(locale: ULocale, formatWidth: MeasureFormat_FormatWidth) {
        this(locale, formatWidth, None, None, None)
    }

    private init(locale: ULocale, formatWidth: MeasureFormat_FormatWidth, numberFormat: NumberFormat, rules: PluralRules, formatters: MeasureFormat_NumericFormatters) {
        super()
        var temprules = rules
        var tempnumberFormat = numberFormat
        var tempformatters = formatters
        setLocale(locale, locale)
        this.formatWidth = formatWidth
        if (temprules.isNone()) {
            temprules = PluralRules.forLocale(locale)
        }
        this.rules = temprules
        if (tempnumberFormat.isNone()) {
            tempnumberFormat = NumberFormat.getInstance(locale)
        } else {
            tempnumberFormat = tempnumberFormat.clone()
        }
        this.numberFormat = tempnumberFormat
        if (tempformatters.isNone() && refEq(formatWidth, MeasureFormat_FormatWidth.NUMERIC)) {
            tempformatters = localeToNumericDurationFormatters.get(locale)
            if (tempformatters.isNone()) {
                tempformatters = loadNumericFormatters(locale)
                localeToNumericDurationFormatters.put(locale, tempformatters)
            }
        }
        this.numericFormatters = tempformatters
        if (!(checkOptionalIs<DecimalFormat, NumberFormat>(tempnumberFormat))) {
            throw IllegalArgumentException()
        }
        numberFormatter = tempnumberFormat.toNumberFormatter().unitWidth(formatWidth.unitWidth)
    }

    init(locale: ULocale, formatWidth: MeasureFormat_FormatWidth, numberFormat: NumberFormat, rules: PluralRules) {
        this(locale, formatWidth, numberFormat, rules, None)
        if (refEq(formatWidth, MeasureFormat_FormatWidth.NUMERIC)) {
            throw IllegalArgumentException("The format width 'numeric' is not allowed by this constructor")
        }
    }

    private static func loadNumericFormatters(locale: ULocale): MeasureFormat_NumericFormatters {
        let r = UResourceBundle.getBundleInstance(ICUData.ICU_UNIT_BASE_NAME, locale)
        return MeasureFormat_NumericFormatters(loadNumericDurationFormat(r, "hm"), loadNumericDurationFormat(r, "ms"), loadNumericDurationFormat(r, "hms"))
    }

    static let NUMBER_FORMATTER_STANDARD = 1

    static let NUMBER_FORMATTER_CURRENCY = 2

    static let NUMBER_FORMATTER_INTEGER = 3

     private var formatter1: MeasureFormat_NumberFormatterCacheEntry

     private var formatter2: MeasureFormat_NumberFormatterCacheEntry

     private var formatter3: MeasureFormat_NumberFormatterCacheEntry

    private func getUnitFormatterFromCache(Type: Int32, unit: MeasureUnit, perUnit: MeasureUnit): LocalizedNumberFormatter {
        synchronized (GeneratedLockObject) {
            if (formatter1.isSome()) {
                if (formatter1.Type == Type && refEq(formatter1.unit, unit) && refEq(formatter1.perUnit, perUnit)) {
                    return formatter1.formatter
                }
                if (formatter2.isSome()) {
                    if (formatter2.Type == Type && refEq(formatter2.unit, unit) && refEq(formatter2.perUnit, perUnit)) {
                        return formatter2.formatter
                    }
                    if (formatter3.isSome()) {
                        if (formatter3.Type == Type && refEq(formatter3.unit, unit) && refEq(formatter3.perUnit, perUnit)) {
                            return formatter3.formatter
                        }
                    }
                }
            }
            let formatter: LocalizedNumberFormatter
            if (Type == NUMBER_FORMATTER_STANDARD) {
                formatter = getNumberFormatter().unit(unit).perUnit(perUnit).unitWidth(formatWidth.unitWidth)
            } else if (Type == NUMBER_FORMATTER_CURRENCY) {
                formatter = NumberFormatter.withLocale(getLocale()).unit(unit).perUnit(perUnit).unitWidth(formatWidth.currencyWidth)
            } else {
                if (!(Type == NUMBER_FORMATTER_INTEGER)) {
                    throw AssertionError()
                }
                formatter = getNumberFormatter().unit(unit).perUnit(perUnit).unitWidth(formatWidth.unitWidth).precision(Precision.integer().withMode(RoundingUtils.mathContextUnlimited(RoundingMode.DOWN)))
            }
            formatter3 = formatter2
            formatter2 = formatter1
            formatter1 = MeasureFormat_NumberFormatterCacheEntry()
            formatter1.Type = Type
            formatter1.unit = unit
            formatter1.perUnit = perUnit
            formatter1.formatter = formatter
            return formatter
        }
    }

    public func clearCache(): Unit {
        synchronized (GeneratedLockObject) {
            formatter1 = None
            formatter2 = None
            formatter3 = None
        }
    }

    public func getNumberFormatter(): LocalizedNumberFormatter {
        return numberFormatter
    }

    private func formatMeasure(measure: Measure): FormattedStringBuilder {
        let unit = measure.getUnit()
        let dq: DecimalQuantity = DecimalQuantity_DualStorageBCD(measure.getNumber())
        let string = FormattedStringBuilder()
        if (checkOptionalIs<Currency, MeasureUnit>(unit)) {
            getUnitFormatterFromCache(NUMBER_FORMATTER_CURRENCY, unit, None).formatImpl(dq, string)
        } else {
            getUnitFormatterFromCache(NUMBER_FORMATTER_STANDARD, unit, None).formatImpl(dq, string)
        }
        return string
    }

    private func formatMeasureInteger(measure: Measure): FormattedStringBuilder {
        let dq: DecimalQuantity = DecimalQuantity_DualStorageBCD(measure.getNumber())
        let string = FormattedStringBuilder()
        getUnitFormatterFromCache(NUMBER_FORMATTER_INTEGER, measure.getUnit(), None).formatImpl(dq, string)
        return string
    }

    private func formatMeasuresSlowTrack(listFormatter: ListFormatter, appendTo: Appendable, fieldPosition: FieldPosition, measures: Array<Measure>): Unit {
        let results = Array<String>(measures.size)
        let fpos = FieldPosition(fieldPosition.getFieldAttribute(), fieldPosition.getField())
        var fieldPositionFoundIndex = -1
        var i = 0
        while (i < Int32(measures.size)) {
            let result: FormattedStringBuilder
            if (i == Int32(measures.size) - 1) {
                result = formatMeasure(measures[Int64(i)])
            } else {
                result = formatMeasureInteger(measures[Int64(i)])
            }
            if (fieldPositionFoundIndex == -1) {
                FormattedValueStringBuilderImpl.nextFieldPosition(result, fpos)
                if (fpos.getEndIndex() != 0) {
                    fieldPositionFoundIndex = i
                }
            }
            results[Int64(i)] = result.toString()
            i++
        }
        let builder = listFormatter.formatImpl(results, true)
        let offset = builder.getOffset(fieldPositionFoundIndex)
        if (offset != -1) {
            fieldPosition.setBeginIndex(fpos.getBeginIndex() + offset)
            fieldPosition.setEndIndex(fpos.getEndIndex() + offset)
        }
        builder.appendTo(appendTo)
    }

    private static func loadNumericDurationFormat(r: ICUResourceBundle, Type: String): String {
        var tempr = r
        tempr = tempr.getWithFallback(String.format("durationUnits/%s", [Type]))
        return tempr.getString().replace("h", "H")
    }

    private static func toHMS(measures: Array<Measure>): Array<Number> {
        let result = Array<Number>(3)
        var lastIdx = -1
        for (m in measures) {
            if (m.getNumber().doubleValue() < 0.0) {
                return None
            }
            let idxObj = hmsTo012.get(m.getUnit())
            if (idxObj.isNone()) {
                return None
            }
            let idx = idxObj
            if (idx <= lastIdx) {
                return None
            }
            lastIdx = idx
            result[Int64(idx)] = m.getNumber()
        }
        return result
    }

    private func formatNumeric(hms: Array<Number>, appendable: Appendable): Unit {
        let pattern: String
        if (hms[0].isSome() && hms[2].isSome()) {
            pattern = numericFormatters.getHourMinuteSecond()
            if (hms[1].isNone()) {
                hms[1] = 0
            }
            hms[1] = floor(hms[1].doubleValue())
            hms[0] = floor(hms[0].doubleValue())
        } else if (hms[0].isSome() && hms[1].isSome()) {
            pattern = numericFormatters.getHourMinute()
            hms[0] = floor(hms[0].doubleValue())
        } else if (hms[1].isSome() && hms[2].isSome()) {
            pattern = numericFormatters.getMinuteSecond()
            hms[1] = floor(hms[1].doubleValue())
        } else {
            throw Exception()
        }
        let numberFormatter2 = numberFormatter.integerWidth(IntegerWidth.zeroFillTo(2))
        let fsb = FormattedStringBuilder()
        var protect = false
        var i = 0
        while (i < Int32(pattern.size)) {
            let c = Char(pattern[Int64(i)])
            var value: Number = 0
            match (c) {
                case 'H' => value = hms[0]
                case 'm' => value = hms[1]
                case 's' => value = hms[2]
                case _ => ()
            }
            match (c) {
                case 'H' | 'm' | 's' => if (protect) {
                    fsb.appendChar16(c, None)
                } else {
                    if ((i + 1 < Int32(pattern.size)) && Char(pattern[Int64(i + 1)]) == c) {
                        fsb.append(numberFormatter2.format(value), None)
                        i++
                    } else {
                        fsb.append(numberFormatter.format(value), None)
                    }
                }
                case ''' => if ((i + 1 < Int32(pattern.size)) && Char(pattern[Int64(i + 1)]) == c) {
                    fsb.appendChar16(c, None)
                    i++
                } else {
                    protect = !protect
                }
                case _ => fsb.appendChar16(c, None)
            }
            i++
        }
        try {
            appendable.append(fsb)
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public func toTimeUnitProxy(): Object {
        return MeasureFormat_MeasureProxy(getLocale(), formatWidth, getNumberFormatInternal(), TIME_UNIT_FORMAT)
    }

    public func toCurrencyProxy(): Object {
        return MeasureFormat_MeasureProxy(getLocale(), formatWidth, getNumberFormatInternal(), CURRENCY_FORMAT)
    }

    private func writeReplace(): Object {
        return MeasureFormat_MeasureProxy(getLocale(), formatWidth, getNumberFormatInternal(), MEASURE_FORMAT)
    }

    static func fromFormatWidthOrdinal(ordinal: Int32): MeasureFormat_FormatWidth {
        let values = MeasureFormat_FormatWidth.values()
        if (ordinal < 0 || ordinal >= Int32(values.size)) {
            return MeasureFormat_FormatWidth.SHORT
        }
        return values[Int64(ordinal)]
    }

    private static let localeIdToRangeFormat = ConcurrentHashMap()

    
    public static func getRangeFormat(forLocale: ULocale, width: MeasureFormat_FormatWidth): String {
        if (forLocale.getLanguage() == "fr") {
            return getRangeFormat(ULocale.ROOT, width)
        }
        var result = localeIdToRangeFormat.get(forLocale)
        if (result.isNone()) {
            let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, forLocale)
            let realLocale = rb.getULocale()
            if (!forLocale.equals(realLocale)) {
                result = localeIdToRangeFormat.get(forLocale)
                if (result.isSome()) {
                    localeIdToRangeFormat.put(forLocale, result)
                    return result
                }
            }
            let ns = NumberingSystem.getInstance(forLocale)
            var resultString: String
            try {
                resultString = rb.getStringWithFallback("NumberElements/" + (ns.getName()) + "/miscPatterns/range")
            } catch (ex: MissingResourceException) {
                resultString = rb.getStringWithFallback("NumberElements/latn/patterns/range")
            }
            result = SimpleFormatterImpl.compileToStringMinMaxArguments(resultString, StringBuilder(), 2, 2)
            localeIdToRangeFormat.put(forLocale, result)
            if (!forLocale.equals(realLocale)) {
                localeIdToRangeFormat.put(realLocale, result)
            }
        }
        return result
    }
}


public class MeasureFormat_FormatWidth <: Enum<MeasureFormat_FormatWidth> {
    public static let WIDE = MeasureFormat_FormatWidth("WIDE", 0, ListFormatter_Width.WIDE, NumberFormatter_UnitWidth.FULL_NAME, NumberFormatter_UnitWidth.FULL_NAME)

    public static let SHORT = MeasureFormat_FormatWidth("SHORT", 1, ListFormatter_Width.SHORT, NumberFormatter_UnitWidth.SHORT, NumberFormatter_UnitWidth.ISO_CODE)

    public static let NARROW = MeasureFormat_FormatWidth("NARROW", 2, ListFormatter_Width.NARROW, NumberFormatter_UnitWidth.NARROW, NumberFormatter_UnitWidth.SHORT)

    public static let NUMERIC = MeasureFormat_FormatWidth("NUMERIC", 3, ListFormatter_Width.NARROW, NumberFormatter_UnitWidth.NARROW, NumberFormatter_UnitWidth.SHORT)

    
    public static let DEFAULT_CURRENCY = MeasureFormat_FormatWidth("DEFAULT_CURRENCY", 4, ListFormatter_Width.SHORT, NumberFormatter_UnitWidth.FULL_NAME, NumberFormatter_UnitWidth.SHORT)

    private static func _values(): Array<MeasureFormat_FormatWidth> {
        return [MeasureFormat_FormatWidth.WIDE, MeasureFormat_FormatWidth.SHORT, MeasureFormat_FormatWidth.NARROW, MeasureFormat_FormatWidth.NUMERIC, MeasureFormat_FormatWidth.DEFAULT_CURRENCY]
    }

    private static let _VALUES = MeasureFormat_FormatWidth._values()

    public static func values(): Array<MeasureFormat_FormatWidth> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): MeasureFormat_FormatWidth {
        return (TypeInfo.of<MeasureFormat_FormatWidth>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as MeasureFormat_FormatWidth
    }

    let listWidth: ListFormatter_Width

    let unitWidth: NumberFormatter_UnitWidth

    let currencyWidth: NumberFormatter_UnitWidth

    private init(_enum_name: String, _enum_ordinal: Int32, listWidth: ListFormatter_Width, unitWidth: NumberFormatter_UnitWidth, currencyWidth: NumberFormatter_UnitWidth) {
        super(_enum_name, _enum_ordinal)
        this.listWidth = listWidth
        this.unitWidth = unitWidth
        this.currencyWidth = currencyWidth
    }
}


class MeasureFormat_NumericFormatters {
    private var hourMinute: String

    private var minuteSecond: String

    private var hourMinuteSecond: String

    public init(hourMinute: String, minuteSecond: String, hourMinuteSecond: String) {
        this.hourMinute = hourMinute
        this.minuteSecond = minuteSecond
        this.hourMinuteSecond = hourMinuteSecond
    }

    public func getHourMinute(): String {
        return hourMinute
    }

    public func getMinuteSecond(): String {
        return minuteSecond
    }

    public func getHourMinuteSecond(): String {
        return hourMinuteSecond
    }
}


class MeasureFormat_NumberFormatterCacheEntry {

    var Type: Int32 = 0

    var unit: MeasureUnit

    var perUnit: MeasureUnit

    var formatter: LocalizedNumberFormatter
}


class MeasureFormat_MeasureProxy <: Externalizable {
    private static let serialVersionUID = -6033308329886716770

    private var locale: ULocale

    private var formatWidth: MeasureFormat_FormatWidth

    private var numberFormat: NumberFormat

    private var subClass: Int32 = 0

    private var keyValues: HashMap<Object, Object> = None

    public init(locale: ULocale, width: MeasureFormat_FormatWidth, numberFormat: NumberFormat, subClass: Int32) {
        this.locale = locale
        this.formatWidth = width
        this.numberFormat = numberFormat
        this.subClass = subClass
        this.keyValues = HashMap<Object, Object>()
    }


    public override func writeExternal(out: ObjectOutput): Unit {
        out.writeByte(0)
        out.writeUTF(locale.toLanguageTag())
        out.writeByte(formatWidth.ordinal)
        out.writeObject(numberFormat)
        out.writeByte(subClass)
        out.writeObject(keyValues)
    }

    public override func readExternal(input: ObjectInput): Unit {
        input.readByte()
        locale = ULocale.forLanguageTag(input.readUTF())
        formatWidth = MeasureFormat.fromFormatWidthOrdinal(Int32(input.readByte()) & 255)
        numberFormat = input.readObject()
        if (numberFormat.isNone()) {
            throw InvalidObjectException("Missing number format.")
        }
        subClass = Int32(input.readByte()) & 255
        keyValues = input.readObject()
        if (keyValues.isNone()) {
            throw InvalidObjectException("Missing optional values map.")
        }
    }

    private func createTimeUnitFormat(): TimeUnitFormat {
        let style: Int32
        if (refEq(formatWidth, MeasureFormat_FormatWidth.WIDE)) {
            style = TimeUnitFormat.FULL_NAME
        } else if (refEq(formatWidth, MeasureFormat_FormatWidth.SHORT)) {
            style = TimeUnitFormat.ABBREVIATED_NAME
        } else {
            throw InvalidObjectException("Bad width: " + formatWidth.asString())
        }
        let result = TimeUnitFormat(locale, style)
        result.setNumberFormat(numberFormat)
        return result
    }

    private func readResolve(): Object {
        match (subClass) {
            case 0 => return MeasureFormat.getInstance(locale, formatWidth, numberFormat)
            case 1 => return createTimeUnitFormat()
            case 2 => return MeasureFormat.getCurrencyFormat(locale)
            case _ => throw InvalidObjectException("Unknown subclass: " + subClass.toString())
        }
    }
}
