package icu4cj.text


public class RelativeDateTimeFormatter {
    public static func getInstance(): RelativeDateTimeFormatter {
        return getInstance(ULocale.getDefault(), None, RelativeDateTimeFormatter_Style.LONG, DisplayContext.CAPITALIZATION_NONE)
    }

    public static func getInstance(locale: ULocale): RelativeDateTimeFormatter {
        return getInstance(locale, None, RelativeDateTimeFormatter_Style.LONG, DisplayContext.CAPITALIZATION_NONE)
    }

    public static func getInstance(locale: Locale): RelativeDateTimeFormatter {
        return getInstance(ULocale.forLocale(locale))
    }

    public static func getInstance(locale: ULocale, nf: NumberFormat): RelativeDateTimeFormatter {
        return getInstance(locale, nf, RelativeDateTimeFormatter_Style.LONG, DisplayContext.CAPITALIZATION_NONE)
    }

    public static func getInstance(locale: ULocale, nf: NumberFormat, style: RelativeDateTimeFormatter_Style, capitalizationContext: DisplayContext): RelativeDateTimeFormatter {
        var tempnf = nf
        let data = cache.get(locale)
        if (tempnf.isNone()) {
            tempnf = NumberFormat.getInstance(locale)
        } else {
            tempnf = tempnf.clone()
        }
        return RelativeDateTimeFormatter(data.qualitativeUnitMap, data.relUnitPatternMap, SimpleFormatterImpl.compileToStringMinMaxArguments(data.dateTimePattern, StringBuilder(), 2, 2), PluralRules.forLocale(locale), tempnf, style, capitalizationContext, if (refEq(capitalizationContext, DisplayContext.CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE)) { BreakIterator.getSentenceInstance(locale) } else { None }, locale)
    }

    public static func getInstance(locale: Locale, nf: NumberFormat): RelativeDateTimeFormatter {
        return getInstance(ULocale.forLocale(locale), nf)
    }

    public func format(quantity: Float64, direction: RelativeDateTimeFormatter_Direction, unit: RelativeDateTimeFormatter_RelativeUnit): String {
        let output = formatImpl(quantity, direction, unit)
        return adjustForContext(output.toString())
    }

    public func formatToValue(quantity: Float64, direction: RelativeDateTimeFormatter_Direction, unit: RelativeDateTimeFormatter_RelativeUnit): RelativeDateTimeFormatter_FormattedRelativeDateTime {
        checkNoAdjustForContext()
        return RelativeDateTimeFormatter_FormattedRelativeDateTime(formatImpl(quantity, direction, unit))
    }

    private func formatImpl(quantity: Float64, direction: RelativeDateTimeFormatter_Direction, unit: RelativeDateTimeFormatter_RelativeUnit): FormattedStringBuilder {
        if (!refEq(direction, RelativeDateTimeFormatter_Direction.LAST) && !refEq(direction, RelativeDateTimeFormatter_Direction.NEXT)) {
            throw IllegalArgumentException("direction must be NEXT or LAST")
        }
        let pastFutureIndex = (if (refEq(direction, RelativeDateTimeFormatter_Direction.NEXT)) { 1 } else { 0 })
        let output = FormattedStringBuilder()
        let pluralKeyword: String
        if (checkOptionalIs<DecimalFormat, NumberFormat>(numberFormat)) {
            let dq: DecimalQuantity = DecimalQuantity_DualStorageBCD(quantity)
            numberFormat.toNumberFormatter().formatImpl(dq, output)
            pluralKeyword = pluralRules.select(dq)
        } else {
            let result = numberFormat.format(quantity)
            output.append(result, None)
            pluralKeyword = pluralRules.select(quantity)
        }
        let pluralForm = StandardPlural.orOtherFromString(pluralKeyword)
        let compiledPattern = getRelativeUnitPluralPattern(style, unit, pastFutureIndex, pluralForm)
        SimpleFormatterImpl.formatPrefixSuffix(compiledPattern, RelativeDateTimeFormatter_Field.LITERAL, 0, output.lengthMethod(), output)
        return output
    }

    public func formatNumeric(offset: Float64, unit: RelativeDateTimeFormatter_RelativeDateTimeUnit): String {
        let output = formatNumericImpl(offset, unit)
        return adjustForContext(output.toString())
    }

    public func formatNumericToValue(offset: Float64, unit: RelativeDateTimeFormatter_RelativeDateTimeUnit): RelativeDateTimeFormatter_FormattedRelativeDateTime {
        checkNoAdjustForContext()
        return RelativeDateTimeFormatter_FormattedRelativeDateTime(formatNumericImpl(offset, unit))
    }

    private func formatNumericImpl(offset: Float64, unit: RelativeDateTimeFormatter_RelativeDateTimeUnit): FormattedStringBuilder {
        var tempoffset = offset
        var relunit: RelativeDateTimeFormatter_RelativeUnit = RelativeDateTimeFormatter_RelativeUnit.SECONDS
        match (unit) {
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.YEAR => relunit = RelativeDateTimeFormatter_RelativeUnit.YEARS
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.QUARTER => relunit = RelativeDateTimeFormatter_RelativeUnit.QUARTERS
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.MONTH => relunit = RelativeDateTimeFormatter_RelativeUnit.MONTHS
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.WEEK => relunit = RelativeDateTimeFormatter_RelativeUnit.WEEKS
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.DAY => relunit = RelativeDateTimeFormatter_RelativeUnit.DAYS
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.HOUR => relunit = RelativeDateTimeFormatter_RelativeUnit.HOURS
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.MINUTE => relunit = RelativeDateTimeFormatter_RelativeUnit.MINUTES
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.SECOND => ()
            case _ => throw UnsupportedOperationException("formatNumeric does not currently support RelativeUnit.SUNDAY..SATURDAY")
        }
        var direction: RelativeDateTimeFormatter_Direction = RelativeDateTimeFormatter_Direction.NEXT
        if (Float64.compare(tempoffset, 0.0) < 0) {
            direction = RelativeDateTimeFormatter_Direction.LAST
            tempoffset = -tempoffset
        }
        return formatImpl(tempoffset, direction, relunit)
    }

    private var styleToDateFormatSymbolsWidth: Array<Int32> = [DateFormatSymbols.WIDE, DateFormatSymbols.SHORT, DateFormatSymbols.NARROW]

    public func format(direction: RelativeDateTimeFormatter_Direction, unit: RelativeDateTimeFormatter_AbsoluteUnit): String {
        let result = formatAbsoluteImpl(direction, unit)
        return if (result.isSome()) { adjustForContext(result) } else { None }
    }

    public func formatToValue(direction: RelativeDateTimeFormatter_Direction, unit: RelativeDateTimeFormatter_AbsoluteUnit): RelativeDateTimeFormatter_FormattedRelativeDateTime {
        checkNoAdjustForContext()
        let string = formatAbsoluteImpl(direction, unit)
        if (string.isNone()) {
            return None
        }
        let nsb = FormattedStringBuilder()
        nsb.append(string, RelativeDateTimeFormatter_Field.LITERAL)
        return RelativeDateTimeFormatter_FormattedRelativeDateTime(nsb)
    }

    private func formatAbsoluteImpl(direction: RelativeDateTimeFormatter_Direction, unit: RelativeDateTimeFormatter_AbsoluteUnit): String {
        if (refEq(unit, RelativeDateTimeFormatter_AbsoluteUnit.NOW) && !refEq(direction, RelativeDateTimeFormatter_Direction.PLAIN)) {
            throw IllegalArgumentException("NOW can only accept direction PLAIN.")
        }
        let result: String
        if ((refEq(direction, RelativeDateTimeFormatter_Direction.PLAIN)) && (RelativeDateTimeFormatter_AbsoluteUnit.SUNDAY.ordinal <= unit.ordinal && unit.ordinal <= RelativeDateTimeFormatter_AbsoluteUnit.SATURDAY.ordinal)) {
            let dateSymbolsDayOrdinal = (unit.ordinal - RelativeDateTimeFormatter_AbsoluteUnit.SUNDAY.ordinal) + Calendar.SUNDAY
            let dayNames = dateFormatSymbols.getWeekdays(DateFormatSymbols.STANDALONE, styleToDateFormatSymbolsWidth[Int64(style.ordinal)])
            result = dayNames[Int64(dateSymbolsDayOrdinal)]
        } else {
            result = getAbsoluteUnitString(style, unit, direction)
        }
        return result
    }

    public func format(offset: Float64, unit: RelativeDateTimeFormatter_RelativeDateTimeUnit): String {
        return adjustForContext(toString(formatRelativeImpl(offset, unit)))
    }

    public func formatToValue(offset: Float64, unit: RelativeDateTimeFormatter_RelativeDateTimeUnit): RelativeDateTimeFormatter_FormattedRelativeDateTime {
        checkNoAdjustForContext()
        let cs = formatRelativeImpl(offset, unit)
        let nsb: FormattedStringBuilder
        if (checkOptionalIs<FormattedStringBuilder, String>(cs)) {
            nsb = cs
        } else {
            nsb = FormattedStringBuilder()
            nsb.append(cs, RelativeDateTimeFormatter_Field.LITERAL)
        }
        return RelativeDateTimeFormatter_FormattedRelativeDateTime(nsb)
    }

    private func formatRelativeImpl(offset: Float64, unit: RelativeDateTimeFormatter_RelativeDateTimeUnit): String {
        var useNumeric = true
        var direction: RelativeDateTimeFormatter_Direction = RelativeDateTimeFormatter_Direction.THIS
        if (offset > -2.1 && offset < 2.1) {
            let offsetx100 = offset * 100.0
            let intoffsetx100 = if (offsetx100 < 0.0) { Int32(offsetx100 - 0.5) } else { Int32(offsetx100 + 0.5) }
            match (intoffsetx100) {
                case -200 =>
                    direction = RelativeDateTimeFormatter_Direction.LAST_2
                    useNumeric = false
                case -100 =>
                    direction = RelativeDateTimeFormatter_Direction.LAST
                    useNumeric = false
                case 0 => useNumeric = false
                case 100 =>
                    direction = RelativeDateTimeFormatter_Direction.NEXT
                    useNumeric = false
                case 200 =>
                    direction = RelativeDateTimeFormatter_Direction.NEXT_2
                    useNumeric = false
                case _ => ()
            }
        }
        var absunit: RelativeDateTimeFormatter_AbsoluteUnit = RelativeDateTimeFormatter_AbsoluteUnit.NOW
        match (unit) {
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.YEAR => absunit = RelativeDateTimeFormatter_AbsoluteUnit.YEAR
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.QUARTER => absunit = RelativeDateTimeFormatter_AbsoluteUnit.QUARTER
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.MONTH => absunit = RelativeDateTimeFormatter_AbsoluteUnit.MONTH
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.WEEK => absunit = RelativeDateTimeFormatter_AbsoluteUnit.WEEK
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.DAY => absunit = RelativeDateTimeFormatter_AbsoluteUnit.DAY
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.SUNDAY => absunit = RelativeDateTimeFormatter_AbsoluteUnit.SUNDAY
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.MONDAY => absunit = RelativeDateTimeFormatter_AbsoluteUnit.MONDAY
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.TUESDAY => absunit = RelativeDateTimeFormatter_AbsoluteUnit.TUESDAY
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.WEDNESDAY => absunit = RelativeDateTimeFormatter_AbsoluteUnit.WEDNESDAY
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.THURSDAY => absunit = RelativeDateTimeFormatter_AbsoluteUnit.THURSDAY
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.FRIDAY => absunit = RelativeDateTimeFormatter_AbsoluteUnit.FRIDAY
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.SATURDAY => absunit = RelativeDateTimeFormatter_AbsoluteUnit.SATURDAY
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.HOUR => absunit = RelativeDateTimeFormatter_AbsoluteUnit.HOUR
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.MINUTE => absunit = RelativeDateTimeFormatter_AbsoluteUnit.MINUTE
            case RelativeDateTimeFormatter_RelativeDateTimeUnit.SECOND =>
                if (refEq(direction, RelativeDateTimeFormatter_Direction.THIS)) {
                    direction = RelativeDateTimeFormatter_Direction.PLAIN
                    break
                }
                useNumeric = true
            case _ => useNumeric = true
        }
        if (!useNumeric) {
            let result = formatAbsoluteImpl(direction, absunit)
            if (result.isSome() && Int32(result.size) > 0) {
                return result
            }
        }
        return formatNumericImpl(offset, unit)
    }

    private func getAbsoluteUnitString(style: RelativeDateTimeFormatter_Style, unit: RelativeDateTimeFormatter_AbsoluteUnit, direction: RelativeDateTimeFormatter_Direction): String {
        var tempstyle = style
        var unitMap: EnumMap = None
        var dirMap: EnumMap = None
                }
            }
        } while ((match (0) { case _ => tempstyle = fallbackCache[Int64(tempstyle.ordinal)]; tempstyle }).isSome())
        return None
    }

    public func combineDateAndTime(relativeDateString: String, timeString: String): String {
        return SimpleFormatterImpl.formatCompiledPattern(combinedDateAndTime, [timeString, relativeDateString])
    }

    public func getNumberFormat(): NumberFormat {
        synchronized (getMonitorByObject(numberFormat)) {
            return numberFormat.clone()
        }
    }

    public func getCapitalizationContext(): DisplayContext {
        return capitalizationContext
    }

    public func getFormatStyle(): RelativeDateTimeFormatter_Style {
        return style
    }

    private func adjustForContext(originalFormattedString: String): String {
        if (breakIterator.isNone() || Int32(originalFormattedString.size) == 0 || !UCharacter.isLowerCase(UCharacter.codePointAt(originalFormattedString, 0))) {
            return originalFormattedString
        }
        synchronized (getMonitorByObject(breakIterator)) {
            return UCharacter.toTitleCase(locale, originalFormattedString, breakIterator, UCharacter.TITLECASE_NO_LOWERCASE | UCharacter.TITLECASE_NO_BREAK_ADJUSTMENT)
        }
    }

    private func checkNoAdjustForContext(): Unit {
        if (breakIterator.isSome()) {
            throw UnsupportedOperationException("Capitalization context is not supported in formatV")
        }
    }

    private init(qualitativeUnitMap: EnumMap, patternMap: EnumMap, combinedDateAndTime: String, pluralRules: PluralRules, numberFormat: NumberFormat, style: RelativeDateTimeFormatter_Style, capitalizationContext: DisplayContext, breakIterator: BreakIterator, locale: ULocale) {
        this.qualitativeUnitMap = qualitativeUnitMap
        this.patternMap = patternMap
        this.combinedDateAndTime = combinedDateAndTime
        this.pluralRules = pluralRules
        this.numberFormat = numberFormat
        this.style = style
        if (!refEq(capitalizationContext.typeMethod(), DisplayContext_Type.CAPITALIZATION)) {
            throw IllegalArgumentException(capitalizationContext.toString())
        }
        this.capitalizationContext = capitalizationContext
        this.breakIterator = breakIterator
        this.locale = locale
        this.dateFormatSymbols = DateFormatSymbols(locale)
    }

    private func getRelativeUnitPluralPattern(style: RelativeDateTimeFormatter_Style, unit: RelativeDateTimeFormatter_RelativeUnit, pastFutureIndex: Int32, pluralForm: StandardPlural): String {
        if (!refEq(pluralForm, StandardPlural.OTHER)) {
            let formatter = getRelativeUnitPattern(style, unit, pastFutureIndex, pluralForm)
            if (formatter.isSome()) {
                return formatter
            }
        }
        return getRelativeUnitPattern(style, unit, pastFutureIndex, StandardPlural.OTHER)
    }

    private func getRelativeUnitPattern(style: RelativeDateTimeFormatter_Style, unit: RelativeDateTimeFormatter_RelativeUnit, pastFutureIndex: Int32, pluralForm: StandardPlural): String {
        var tempstyle = style
        let pluralIndex = pluralForm.ordinal
                }
            }
        } while ((match (0) { case _ => tempstyle = fallbackCache[Int64(tempstyle.ordinal)]; tempstyle }).isSome())
        return None
    }

    private let qualitativeUnitMap: EnumMap

    private let patternMap: EnumMap

    private let combinedDateAndTime: String

    private let pluralRules: PluralRules

    private let numberFormat: NumberFormat

    private let style: RelativeDateTimeFormatter_Style

    private let capitalizationContext: DisplayContext

    private let breakIterator: BreakIterator

    private let locale: ULocale

    private let dateFormatSymbols: DateFormatSymbols

    static let fallbackCache = Array<RelativeDateTimeFormatter_Style>(Int64(RelativeDateTimeFormatter_Style.INDEX_COUNT))

    static func keyToDirection(key: UResource_Key): RelativeDateTimeFormatter_Direction {
        if (key.contentEquals("-2")) {
            return RelativeDateTimeFormatter_Direction.LAST_2
        }
        if (key.contentEquals("-1")) {
            return RelativeDateTimeFormatter_Direction.LAST
        }
        if (key.contentEquals("0")) {
            return RelativeDateTimeFormatter_Direction.THIS
        }
        if (key.contentEquals("1")) {
            return RelativeDateTimeFormatter_Direction.NEXT
        }
        if (key.contentEquals("2")) {
            return RelativeDateTimeFormatter_Direction.NEXT_2
        }
        return None
    }

    private static let cache = RelativeDateTimeFormatter_Cache()
}


public class RelativeDateTimeFormatter_Style <: Enum<RelativeDateTimeFormatter_Style> {
    public static let LONG = RelativeDateTimeFormatter_Style("LONG", 0)

    public static let SHORT = RelativeDateTimeFormatter_Style("SHORT", 1)

    public static let NARROW = RelativeDateTimeFormatter_Style("NARROW", 2)

    private static func _values(): Array<RelativeDateTimeFormatter_Style> {
        return [RelativeDateTimeFormatter_Style.LONG, RelativeDateTimeFormatter_Style.SHORT, RelativeDateTimeFormatter_Style.NARROW]
    }

    private static let _VALUES = RelativeDateTimeFormatter_Style._values()

    public static func values(): Array<RelativeDateTimeFormatter_Style> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): RelativeDateTimeFormatter_Style {
        return (TypeInfo.of<RelativeDateTimeFormatter_Style>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as RelativeDateTimeFormatter_Style
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    static let INDEX_COUNT = 3
}


public class RelativeDateTimeFormatter_RelativeUnit <: Enum<RelativeDateTimeFormatter_RelativeUnit> {
    public static let SECONDS = RelativeDateTimeFormatter_RelativeUnit("SECONDS", 0)

    public static let MINUTES = RelativeDateTimeFormatter_RelativeUnit("MINUTES", 1)

    public static let HOURS = RelativeDateTimeFormatter_RelativeUnit("HOURS", 2)

    public static let DAYS = RelativeDateTimeFormatter_RelativeUnit("DAYS", 3)

    public static let WEEKS = RelativeDateTimeFormatter_RelativeUnit("WEEKS", 4)

    public static let MONTHS = RelativeDateTimeFormatter_RelativeUnit("MONTHS", 5)

    public static let YEARS = RelativeDateTimeFormatter_RelativeUnit("YEARS", 6)

    
    public static let QUARTERS = RelativeDateTimeFormatter_RelativeUnit("QUARTERS", 7)

    private static func _values(): Array<RelativeDateTimeFormatter_RelativeUnit> {
        return [RelativeDateTimeFormatter_RelativeUnit.SECONDS, RelativeDateTimeFormatter_RelativeUnit.MINUTES, RelativeDateTimeFormatter_RelativeUnit.HOURS, RelativeDateTimeFormatter_RelativeUnit.DAYS, RelativeDateTimeFormatter_RelativeUnit.WEEKS, RelativeDateTimeFormatter_RelativeUnit.MONTHS, RelativeDateTimeFormatter_RelativeUnit.YEARS, RelativeDateTimeFormatter_RelativeUnit.QUARTERS]
    }

    private static let _VALUES = RelativeDateTimeFormatter_RelativeUnit._values()

    public static func values(): Array<RelativeDateTimeFormatter_RelativeUnit> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): RelativeDateTimeFormatter_RelativeUnit {
        return (TypeInfo.of<RelativeDateTimeFormatter_RelativeUnit>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as RelativeDateTimeFormatter_RelativeUnit
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class RelativeDateTimeFormatter_AbsoluteUnit <: Enum<RelativeDateTimeFormatter_AbsoluteUnit> {
    public static let SUNDAY = RelativeDateTimeFormatter_AbsoluteUnit("SUNDAY", 0)

    public static let MONDAY = RelativeDateTimeFormatter_AbsoluteUnit("MONDAY", 1)

    public static let TUESDAY = RelativeDateTimeFormatter_AbsoluteUnit("TUESDAY", 2)

    public static let WEDNESDAY = RelativeDateTimeFormatter_AbsoluteUnit("WEDNESDAY", 3)

    public static let THURSDAY = RelativeDateTimeFormatter_AbsoluteUnit("THURSDAY", 4)

    public static let FRIDAY = RelativeDateTimeFormatter_AbsoluteUnit("FRIDAY", 5)

    public static let SATURDAY = RelativeDateTimeFormatter_AbsoluteUnit("SATURDAY", 6)

    public static let DAY = RelativeDateTimeFormatter_AbsoluteUnit("DAY", 7)

    public static let WEEK = RelativeDateTimeFormatter_AbsoluteUnit("WEEK", 8)

    public static let MONTH = RelativeDateTimeFormatter_AbsoluteUnit("MONTH", 9)

    public static let YEAR = RelativeDateTimeFormatter_AbsoluteUnit("YEAR", 10)

    public static let NOW = RelativeDateTimeFormatter_AbsoluteUnit("NOW", 11)

    public static let QUARTER = RelativeDateTimeFormatter_AbsoluteUnit("QUARTER", 12)

    public static let HOUR = RelativeDateTimeFormatter_AbsoluteUnit("HOUR", 13)

    public static let MINUTE = RelativeDateTimeFormatter_AbsoluteUnit("MINUTE", 14)

    private static func _values(): Array<RelativeDateTimeFormatter_AbsoluteUnit> {
        return [RelativeDateTimeFormatter_AbsoluteUnit.SUNDAY, RelativeDateTimeFormatter_AbsoluteUnit.MONDAY, RelativeDateTimeFormatter_AbsoluteUnit.TUESDAY, RelativeDateTimeFormatter_AbsoluteUnit.WEDNESDAY, RelativeDateTimeFormatter_AbsoluteUnit.THURSDAY, RelativeDateTimeFormatter_AbsoluteUnit.FRIDAY, RelativeDateTimeFormatter_AbsoluteUnit.SATURDAY, RelativeDateTimeFormatter_AbsoluteUnit.DAY, RelativeDateTimeFormatter_AbsoluteUnit.WEEK, RelativeDateTimeFormatter_AbsoluteUnit.MONTH, RelativeDateTimeFormatter_AbsoluteUnit.YEAR, RelativeDateTimeFormatter_AbsoluteUnit.NOW, RelativeDateTimeFormatter_AbsoluteUnit.QUARTER, RelativeDateTimeFormatter_AbsoluteUnit.HOUR, RelativeDateTimeFormatter_AbsoluteUnit.MINUTE]
    }

    private static let _VALUES = RelativeDateTimeFormatter_AbsoluteUnit._values()

    public static func values(): Array<RelativeDateTimeFormatter_AbsoluteUnit> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): RelativeDateTimeFormatter_AbsoluteUnit {
        return (TypeInfo.of<RelativeDateTimeFormatter_AbsoluteUnit>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as RelativeDateTimeFormatter_AbsoluteUnit
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class RelativeDateTimeFormatter_Direction <: Enum<RelativeDateTimeFormatter_Direction> {
    public static let LAST_2 = RelativeDateTimeFormatter_Direction("LAST_2", 0)

    public static let LAST = RelativeDateTimeFormatter_Direction("LAST", 1)

    public static let THIS = RelativeDateTimeFormatter_Direction("THIS", 2)

    public static let NEXT = RelativeDateTimeFormatter_Direction("NEXT", 3)

    public static let NEXT_2 = RelativeDateTimeFormatter_Direction("NEXT_2", 4)

    public static let PLAIN = RelativeDateTimeFormatter_Direction("PLAIN", 5)

    private static func _values(): Array<RelativeDateTimeFormatter_Direction> {
        return [RelativeDateTimeFormatter_Direction.LAST_2, RelativeDateTimeFormatter_Direction.LAST, RelativeDateTimeFormatter_Direction.THIS, RelativeDateTimeFormatter_Direction.NEXT, RelativeDateTimeFormatter_Direction.NEXT_2, RelativeDateTimeFormatter_Direction.PLAIN]
    }

    private static let _VALUES = RelativeDateTimeFormatter_Direction._values()

    public static func values(): Array<RelativeDateTimeFormatter_Direction> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): RelativeDateTimeFormatter_Direction {
        return (TypeInfo.of<RelativeDateTimeFormatter_Direction>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as RelativeDateTimeFormatter_Direction
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class RelativeDateTimeFormatter_RelativeDateTimeUnit <: Enum<RelativeDateTimeFormatter_RelativeDateTimeUnit> {
    public static let YEAR = RelativeDateTimeFormatter_RelativeDateTimeUnit("YEAR", 0)

    public static let QUARTER = RelativeDateTimeFormatter_RelativeDateTimeUnit("QUARTER", 1)

    public static let MONTH = RelativeDateTimeFormatter_RelativeDateTimeUnit("MONTH", 2)

    public static let WEEK = RelativeDateTimeFormatter_RelativeDateTimeUnit("WEEK", 3)

    public static let DAY = RelativeDateTimeFormatter_RelativeDateTimeUnit("DAY", 4)

    public static let HOUR = RelativeDateTimeFormatter_RelativeDateTimeUnit("HOUR", 5)

    public static let MINUTE = RelativeDateTimeFormatter_RelativeDateTimeUnit("MINUTE", 6)

    public static let SECOND = RelativeDateTimeFormatter_RelativeDateTimeUnit("SECOND", 7)

    public static let SUNDAY = RelativeDateTimeFormatter_RelativeDateTimeUnit("SUNDAY", 8)

    public static let MONDAY = RelativeDateTimeFormatter_RelativeDateTimeUnit("MONDAY", 9)

    public static let TUESDAY = RelativeDateTimeFormatter_RelativeDateTimeUnit("TUESDAY", 10)

    public static let WEDNESDAY = RelativeDateTimeFormatter_RelativeDateTimeUnit("WEDNESDAY", 11)

    public static let THURSDAY = RelativeDateTimeFormatter_RelativeDateTimeUnit("THURSDAY", 12)

    public static let FRIDAY = RelativeDateTimeFormatter_RelativeDateTimeUnit("FRIDAY", 13)

    public static let SATURDAY = RelativeDateTimeFormatter_RelativeDateTimeUnit("SATURDAY", 14)

    private static func _values(): Array<RelativeDateTimeFormatter_RelativeDateTimeUnit> {
        return [RelativeDateTimeFormatter_RelativeDateTimeUnit.YEAR, RelativeDateTimeFormatter_RelativeDateTimeUnit.QUARTER, RelativeDateTimeFormatter_RelativeDateTimeUnit.MONTH, RelativeDateTimeFormatter_RelativeDateTimeUnit.WEEK, RelativeDateTimeFormatter_RelativeDateTimeUnit.DAY, RelativeDateTimeFormatter_RelativeDateTimeUnit.HOUR, RelativeDateTimeFormatter_RelativeDateTimeUnit.MINUTE, RelativeDateTimeFormatter_RelativeDateTimeUnit.SECOND, RelativeDateTimeFormatter_RelativeDateTimeUnit.SUNDAY, RelativeDateTimeFormatter_RelativeDateTimeUnit.MONDAY, RelativeDateTimeFormatter_RelativeDateTimeUnit.TUESDAY, RelativeDateTimeFormatter_RelativeDateTimeUnit.WEDNESDAY, RelativeDateTimeFormatter_RelativeDateTimeUnit.THURSDAY, RelativeDateTimeFormatter_RelativeDateTimeUnit.FRIDAY, RelativeDateTimeFormatter_RelativeDateTimeUnit.SATURDAY]
    }

    private static let _VALUES = RelativeDateTimeFormatter_RelativeDateTimeUnit._values()

    public static func values(): Array<RelativeDateTimeFormatter_RelativeDateTimeUnit> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): RelativeDateTimeFormatter_RelativeDateTimeUnit {
        return (TypeInfo.of<RelativeDateTimeFormatter_RelativeDateTimeUnit>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as RelativeDateTimeFormatter_RelativeDateTimeUnit
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class RelativeDateTimeFormatter_Field <: Format_Field {
    private static let serialVersionUID = -5327685528663492325

    public static let LITERAL = RelativeDateTimeFormatter_Field("literal")

    public static let NUMERIC = RelativeDateTimeFormatter_Field("numeric")

    private init(fieldName: String) {
        Format_Field(fieldName)
    }

    
    override protected func readResolve(): Object {
        if (this.getName().equals(LITERAL.getName())) {
            return LITERAL
        }
        if (this.getName().equals(NUMERIC.getName())) {
            return NUMERIC
        }
        throw InvalidObjectException("An invalid object.")
    }
}


public class RelativeDateTimeFormatter_FormattedRelativeDateTime <: FormattedValue {
    private let string: FormattedStringBuilder

    init(string: FormattedStringBuilder) {
        this.string = string
    }

    public override func toString(): String {
        return string.toString()
    }

    public override func length(): Int32 {
        return string.lengthMethod()
    }

    public override func charAt(index: Int32): Char {
        return string.toRuneArray()[index]
    }

    public override func subSequence(start: Int32, end: Int32): String {
        return string.subString(start, end)
    }

    public override func appendTo<A>(appendable: A): A {
        return Utility.appendTo(string, appendable)
    }

    public override func nextPosition(cfpos: ConstrainedFieldPosition): Bool {
        return FormattedValueStringBuilderImpl.nextPosition(string, cfpos, RelativeDateTimeFormatter_Field.NUMERIC)
    }

    public override func toCharacterIterator(): AttributedCharacterIterator {
        return FormattedValueStringBuilderImpl.toCharacterIterator(string, RelativeDateTimeFormatter_Field.NUMERIC)
    }
}


class RelativeDateTimeFormatter_RelativeDateTimeFormatterData {
    public init(qualitativeUnitMap: EnumMap, relUnitPatternMap: EnumMap, dateTimePattern: String) {
        this.qualitativeUnitMap = qualitativeUnitMap
        this.relUnitPatternMap = relUnitPatternMap
        this.dateTimePattern = dateTimePattern
    }

    public let qualitativeUnitMap: EnumMap

    var relUnitPatternMap: EnumMap = None

    public let dateTimePattern: String
}


class RelativeDateTimeFormatter_Cache {

    private let cache: CacheBase<String, RelativeDateTimeFormatter_RelativeDateTimeFormatterData, ULocale> = RelativeDateTimeFormatter_Cache_1(this)

    public func get(locale: ULocale): RelativeDateTimeFormatter_RelativeDateTimeFormatterData {
        let key: String = locale.toString()
        return cache.getInstance(key, locale)
    }
}


class RelativeDateTimeFormatter_Cache_1 <: SoftCache<String, RelativeDateTimeFormatter_RelativeDateTimeFormatterData, ULocale> {
    init(this_0: RelativeDateTimeFormatter_Cache) {
        super()
    }

    override protected func createInstance(key: String, locale: ULocale): RelativeDateTimeFormatter_RelativeDateTimeFormatterData {
        return RelativeDateTimeFormatter_Loader(locale).load()
    }
}


class RelativeDateTimeFormatter_RelDateTimeDataSink <: UResource_Sink {
    var qualitativeUnitMap: EnumMap = EnumMap(TypeInfo.of<RelativeDateTimeFormatter_Style>() as ClassTypeInfo)

    var styleRelUnitPatterns: EnumMap = EnumMap(TypeInfo.of<RelativeDateTimeFormatter_Style>() as ClassTypeInfo)

    var sb: StringBuilder = StringBuilder()

    var pastFutureIndex: Int32 = 0

    var style: RelativeDateTimeFormatter_Style

    var unit: RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit

    private func styleFromKey(key: UResource_Key): RelativeDateTimeFormatter_Style {
        if (key.endsWith("-short")) {
            return RelativeDateTimeFormatter_Style.SHORT
        } else if (key.endsWith("-narrow")) {
            return RelativeDateTimeFormatter_Style.NARROW
        } else {
            return RelativeDateTimeFormatter_Style.LONG
        }
    }

    private func styleFromAlias(value: UResource_Value): RelativeDateTimeFormatter_Style {
        let s = value.getAliasString()
        if (s.endsWith("-short")) {
            return RelativeDateTimeFormatter_Style.SHORT
        } else if (s.endsWith("-narrow")) {
            return RelativeDateTimeFormatter_Style.NARROW
        } else {
            return RelativeDateTimeFormatter_Style.LONG
        }
    }

    private static func styleSuffixLength(style: RelativeDateTimeFormatter_Style): Int32 {
        match (style) {
            case RelativeDateTimeFormatter_Style.SHORT => return 6
            case RelativeDateTimeFormatter_Style.NARROW => return 7
            case _ => return 0
        }
    }

    public func consumeTableRelative(key: UResource_Key, value: UResource_Value): Unit {
        let unitTypesTable = value.getTable()
        var i = 0
        while (unitTypesTable.getKeyAndValue(i, key, value)) {
            if (value.getType() == ICUResourceBundle.STRING) {
                let valueString = value.getString()
                var absMap = qualitativeUnitMap.get(style)
                if (refEq(unit.relUnit, RelativeDateTimeFormatter_RelativeUnit.SECONDS)) {
                    if (key.contentEquals("0")) {
                        var unitStrings = absMap.get(RelativeDateTimeFormatter_AbsoluteUnit.NOW)
                        if (unitStrings.isNone()) {
                            unitStrings = EnumMap(TypeInfo.of<RelativeDateTimeFormatter_Direction>() as ClassTypeInfo)
                            absMap.put(RelativeDateTimeFormatter_AbsoluteUnit.NOW, unitStrings)
                        }
                        if (unitStrings.get(RelativeDateTimeFormatter_Direction.PLAIN).isNone()) {
                            unitStrings.put(RelativeDateTimeFormatter_Direction.PLAIN, valueString)
                        }
                        continue
                    }
                }
                let keyDirection = RelativeDateTimeFormatter.keyToDirection(key)
                if (keyDirection.isNone()) {
                    continue
                }
                let absUnit = unit.absUnit
                if (absUnit.isNone()) {
                    continue
                }
                if (absMap.isNone()) {
                    absMap = EnumMap(TypeInfo.of<RelativeDateTimeFormatter_AbsoluteUnit>() as ClassTypeInfo)
                    qualitativeUnitMap.put(style, absMap)
                }
                var dirMap = absMap.get(absUnit)
                if (dirMap.isNone()) {
                    dirMap = EnumMap(TypeInfo.of<RelativeDateTimeFormatter_Direction>() as ClassTypeInfo)
                    absMap.put(absUnit, dirMap)
                }
                if (dirMap.get(keyDirection).isNone()) {
                    dirMap.put(keyDirection, value.getString())
                }
            }
            i++
        }
    }

    public func consumeTableRelativeTime(key: UResource_Key, value: UResource_Value): Unit {
        if (unit.relUnit.isNone()) {
            return
        }
        let unitTypesTable = value.getTable()
        var i = 0
        while (unitTypesTable.getKeyAndValue(i, key, value)) {
            if (key.contentEquals("past")) {
                pastFutureIndex = 0
            } else if (key.contentEquals("future")) {
                pastFutureIndex = 1
            } else {
                continue
            }
            consumeTimeDetail(key, value)
            i++
        }
    }

    public func consumeTimeDetail(key: UResource_Key, value: UResource_Value): Unit {
        let unitTypesTable = value.getTable()
        var unitPatterns = styleRelUnitPatterns.get(style)
        if (unitPatterns.isNone()) {
            unitPatterns = EnumMap(TypeInfo.of<RelativeDateTimeFormatter_RelativeUnit>() as ClassTypeInfo)
            styleRelUnitPatterns.put(style, unitPatterns)
        }
        var patterns = unitPatterns.get(unit.relUnit)
        if (patterns.isNone()) {
            let array_dim_generated_0 = StandardPlural.COUNT
            patterns = Array<Array<String>>(2) { _ => Array<String>(Int64(array_dim_generated_0)) }
            unitPatterns.put(unit.relUnit, patterns)
        }
        var i = 0
        while (unitTypesTable.getKeyAndValue(i, key, value)) {
            if (value.getType() == ICUResourceBundle.STRING) {
                let pluralIndex = StandardPlural.indexFromString(key.toString())
                if (patterns[Int64(pastFutureIndex)][Int64(pluralIndex)].isNone()) {
                    patterns[Int64(pastFutureIndex)][Int64(pluralIndex)] = SimpleFormatterImpl.compileToStringMinMaxArguments(value.getString(), sb, 0, 1)
                }
            }
            i++
        }
    }

    private func handlePlainDirection(key: UResource_Key, value: UResource_Value): Unit {
        let absUnit = unit.absUnit
        if (absUnit.isNone()) {
            return
        }
        var unitMap = qualitativeUnitMap.get(style)
        if (unitMap.isNone()) {
            unitMap = EnumMap(TypeInfo.of<RelativeDateTimeFormatter_AbsoluteUnit>() as ClassTypeInfo)
            qualitativeUnitMap.put(style, unitMap)
        }
        var dirMap = unitMap.get(absUnit)
        if (dirMap.isNone()) {
            dirMap = EnumMap(TypeInfo.of<RelativeDateTimeFormatter_Direction>() as ClassTypeInfo)
            unitMap.put(absUnit, dirMap)
        }
        if (dirMap.get(RelativeDateTimeFormatter_Direction.PLAIN).isNone()) {
            dirMap.put(RelativeDateTimeFormatter_Direction.PLAIN, value.toString())
        }
    }

    public func consumeTimeUnit(key: UResource_Key, value: UResource_Value): Unit {
        let unitTypesTable = value.getTable()
        var i = 0
        while (unitTypesTable.getKeyAndValue(i, key, value)) {
            if (key.contentEquals("dn") && value.getType() == ICUResourceBundle.STRING) {
                handlePlainDirection(key, value)
            }
            if (value.getType() == ICUResourceBundle.TABLE) {
                if (key.contentEquals("relative")) {
                    consumeTableRelative(key, value)
                } else if (key.contentEquals("relativeTime")) {
                    consumeTableRelativeTime(key, value)
                }
            }
            i++
        }
    }

    private func handleAlias(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let sourceStyle = styleFromKey(key)
        let limit = key.lengthMethod() - styleSuffixLength(sourceStyle)
        let unit = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.orNullFromString(key.substring(0, limit))
        if (unit.isSome()) {
            let targetStyle = styleFromAlias(value)
            if (refEq(sourceStyle, targetStyle)) {
                throw ICUException("Invalid style fallback from " + sourceStyle.asString() + " to itself")
            }
            if (RelativeDateTimeFormatter.fallbackCache[Int64(sourceStyle.ordinal)].isNone()) {
                RelativeDateTimeFormatter.fallbackCache[Int64(sourceStyle.ordinal)] = targetStyle
            } else if (!refEq(RelativeDateTimeFormatter.fallbackCache[Int64(sourceStyle.ordinal)], targetStyle)) {
                throw ICUException("Inconsistent style fallback for style " + sourceStyle.asString() + " to " + targetStyle.asString())
            }
            return
        }
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        if (value.getType() == ICUResourceBundle.ALIAS) {
            return
        }
        let table = value.getTable()
        var i = 0
        while (table.getKeyAndValue(i, key, value)) {
            if (value.getType() == ICUResourceBundle.ALIAS) {
                handleAlias(key, value, noFallback)
            } else {
                style = styleFromKey(key)
                let limit = key.lengthMethod() - styleSuffixLength(style)
                unit = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.orNullFromString(key.substring(0, limit))
                if (unit.isSome()) {
                    consumeTimeUnit(key, value)
                }
            }
            i++
        }
    }

    init() {
        super()
    }
}


class RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit <: Enum<RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit> {
    public static let SECOND = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("SECOND", 0, RelativeDateTimeFormatter_RelativeUnit.SECONDS, None)

    public static let MINUTE = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("MINUTE", 1, RelativeDateTimeFormatter_RelativeUnit.MINUTES, RelativeDateTimeFormatter_AbsoluteUnit.MINUTE)

    public static let HOUR = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("HOUR", 2, RelativeDateTimeFormatter_RelativeUnit.HOURS, RelativeDateTimeFormatter_AbsoluteUnit.HOUR)

    public static let DAY = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("DAY", 3, RelativeDateTimeFormatter_RelativeUnit.DAYS, RelativeDateTimeFormatter_AbsoluteUnit.DAY)

    public static let WEEK = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("WEEK", 4, RelativeDateTimeFormatter_RelativeUnit.WEEKS, RelativeDateTimeFormatter_AbsoluteUnit.WEEK)

    public static let MONTH = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("MONTH", 5, RelativeDateTimeFormatter_RelativeUnit.MONTHS, RelativeDateTimeFormatter_AbsoluteUnit.MONTH)

    public static let QUARTER = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("QUARTER", 6, RelativeDateTimeFormatter_RelativeUnit.QUARTERS, RelativeDateTimeFormatter_AbsoluteUnit.QUARTER)

    public static let YEAR = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("YEAR", 7, RelativeDateTimeFormatter_RelativeUnit.YEARS, RelativeDateTimeFormatter_AbsoluteUnit.YEAR)

    public static let SUNDAY = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("SUNDAY", 8, None, RelativeDateTimeFormatter_AbsoluteUnit.SUNDAY)

    public static let MONDAY = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("MONDAY", 9, None, RelativeDateTimeFormatter_AbsoluteUnit.MONDAY)

    public static let TUESDAY = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("TUESDAY", 10, None, RelativeDateTimeFormatter_AbsoluteUnit.TUESDAY)

    public static let WEDNESDAY = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("WEDNESDAY", 11, None, RelativeDateTimeFormatter_AbsoluteUnit.WEDNESDAY)

    public static let THURSDAY = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("THURSDAY", 12, None, RelativeDateTimeFormatter_AbsoluteUnit.THURSDAY)

    public static let FRIDAY = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("FRIDAY", 13, None, RelativeDateTimeFormatter_AbsoluteUnit.FRIDAY)

    public static let SATURDAY = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit("SATURDAY", 14, None, RelativeDateTimeFormatter_AbsoluteUnit.SATURDAY)

    private static func _values(): Array<RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit> {
        return [RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.SECOND, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.MINUTE, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.HOUR, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.DAY, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.WEEK, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.MONTH, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.QUARTER, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.YEAR, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.SUNDAY, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.MONDAY, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.TUESDAY, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.WEDNESDAY, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.THURSDAY, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.FRIDAY, RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit.SATURDAY]
    }

    private static let _VALUES = RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit._values()

    public static func values(): Array<RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit {
        return (TypeInfo.of<RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit
    }

    var relUnit: RelativeDateTimeFormatter_RelativeUnit

    var absUnit: RelativeDateTimeFormatter_AbsoluteUnit

    init(_enum_name: String, _enum_ordinal: Int32, relUnit: RelativeDateTimeFormatter_RelativeUnit, absUnit: RelativeDateTimeFormatter_AbsoluteUnit) {
        super(_enum_name, _enum_ordinal)
        this.relUnit = relUnit
        this.absUnit = absUnit
    }

    static func orNullFromString(keyword: String): RelativeDateTimeFormatter_RelDateTimeDataSink_DateTimeUnit {
        match (keyword.size) {
            case 3 => if ("day".contentEquals(keyword)) {
                return DAY
            } else if ("sun".contentEquals(keyword)) {
                return SUNDAY
            } else if ("mon".contentEquals(keyword)) {
                return MONDAY
            } else if ("tue".contentEquals(keyword)) {
                return TUESDAY
            } else if ("wed".contentEquals(keyword)) {
                return WEDNESDAY
            } else if ("thu".contentEquals(keyword)) {
                return THURSDAY
            } else if ("fri".contentEquals(keyword)) {
                return FRIDAY
            } else if ("sat".contentEquals(keyword)) {
                return SATURDAY
            }
            case 4 => if ("hour".contentEquals(keyword)) {
                return HOUR
            } else if ("week".contentEquals(keyword)) {
                return WEEK
            } else if ("year".contentEquals(keyword)) {
                return YEAR
            }
            case 5 => if ("month".contentEquals(keyword)) {
                return MONTH
            }
            case 6 => if ("minute".contentEquals(keyword)) {
                return MINUTE
            } else if ("second".contentEquals(keyword)) {
                return SECOND
            }
            case 7 => if ("quarter".contentEquals(keyword)) {
                return QUARTER
            }
            case _ => ()
        }
        return None
    }
}


class RelativeDateTimeFormatter_Loader {
    private let ulocale: ULocale

    public init(ulocale: ULocale) {
        this.ulocale = ulocale
    }

    private func getDateTimePattern(): String {
        let cal = Calendar.getInstance(ulocale)
        return Calendar.getDateAtTimePattern(cal, ulocale, DateFormat.MEDIUM)
    }

    public func load(): RelativeDateTimeFormatter_RelativeDateTimeFormatterData {
        let sink = RelativeDateTimeFormatter_RelDateTimeDataSink()
        let r = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, ulocale)
        r.getAllItemsWithFallback("fields", sink)
        for (testStyle in RelativeDateTimeFormatter_Style.values()) {
            let newStyle1 = RelativeDateTimeFormatter.fallbackCache[Int64(testStyle.ordinal)]
            if (newStyle1.isSome()) {
                let newStyle2 = RelativeDateTimeFormatter.fallbackCache[Int64(newStyle1.ordinal)]
                if (newStyle2.isSome()) {
                    if (RelativeDateTimeFormatter.fallbackCache[Int64(newStyle2.ordinal)].isSome()) {
                        throw Exception("Style fallback too deep")
                    }
                }
            }
        }
        return RelativeDateTimeFormatter_RelativeDateTimeFormatterData(sink.qualitativeUnitMap, sink.styleRelUnitPatterns, getDateTimePattern())
    }
}
