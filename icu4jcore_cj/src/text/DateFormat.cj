package icu4cj.text


public abstract class DateFormat <: UFormat {
    protected var calendar: Calendar

    protected var numberFormat: NumberFormat

    public static let ERA_FIELD = 0

    public static let YEAR_FIELD = 1

    public static let MONTH_FIELD = 2

    public static let DATE_FIELD = 3

    public static let HOUR_OF_DAY1_FIELD = 4

    public static let HOUR_OF_DAY0_FIELD = 5

    public static let MINUTE_FIELD = 6

    public static let SECOND_FIELD = 7

    public static let FRACTIONAL_SECOND_FIELD = 8

    public static let MILLISECOND_FIELD = FRACTIONAL_SECOND_FIELD

    public static let DAY_OF_WEEK_FIELD = 9

    public static let DAY_OF_YEAR_FIELD = 10

    public static let DAY_OF_WEEK_IN_MONTH_FIELD = 11

    public static let WEEK_OF_YEAR_FIELD = 12

    public static let WEEK_OF_MONTH_FIELD = 13

    public static let AM_PM_FIELD = 14

    public static let HOUR1_FIELD = 15

    public static let HOUR0_FIELD = 16

    public static let TIMEZONE_FIELD = 17

    public static let YEAR_WOY_FIELD = 18

    public static let DOW_LOCAL_FIELD = 19

    public static let EXTENDED_YEAR_FIELD = 20

    public static let JULIAN_DAY_FIELD = 21

    public static let MILLISECONDS_IN_DAY_FIELD = 22

    public static let TIMEZONE_RFC_FIELD = 23

    public static let TIMEZONE_GENERIC_FIELD = 24

    public static let STANDALONE_DAY_FIELD = 25

    public static let STANDALONE_MONTH_FIELD = 26

    public static let QUARTER_FIELD = 27

    public static let STANDALONE_QUARTER_FIELD = 28

    public static let TIMEZONE_SPECIAL_FIELD = 29

    public static let YEAR_NAME_FIELD = 30

    public static let TIMEZONE_LOCALIZED_GMT_OFFSET_FIELD = 31

    public static let TIMEZONE_ISO_FIELD = 32

    public static let TIMEZONE_ISO_LOCAL_FIELD = 33

    
    static let RELATED_YEAR = 34

    public static let AM_PM_MIDNIGHT_NOON_FIELD = 35

    public static let FLEXIBLE_DAY_PERIOD_FIELD = 36

    
    public static let TIME_SEPARATOR = 37

    
    public static let FIELD_COUNT = 38

    private var booleanAttributes = EnumSet.allOf(TypeInfo.of<DateFormat_BoolAttribute>() as ClassTypeInfo)

    private var capitalizationSetting: DisplayContext = DisplayContext.CAPITALIZATION_NONE

    static let currentSerialVersion = 1

    private var serialVersionOnStream = currentSerialVersion

    private static let serialVersionUID = 7218322306649953788

    public override func format(obj: Object, toAppendTo: StringBuffer, fieldPosition: FieldPosition): StringBuffer {
        if (checkOptionalIs<Calendar, Object>(obj)) {
            return format(obj, toAppendTo, fieldPosition)
        } else if (checkOptionalIs<Date, Object>(obj)) {
            return format(obj, toAppendTo, fieldPosition)
        } else if (checkOptionalIs<Number, Object>(obj)) {
            return format(Date(obj.longValue()), toAppendTo, fieldPosition)
        } else {
            throw IllegalArgumentException("Cannot format given Object (" + TypeInfo.of(obj).name + ") as a Date")
        }
    }

    public func format(cal: Calendar, toAppendTo: StringBuffer, fieldPosition: FieldPosition): StringBuffer

    public func format(date: DateTime, toAppendTo: StringBuffer, fieldPosition: FieldPosition): StringBuffer {
        calendar.setTime(date)
        return format(calendar, toAppendTo, fieldPosition)
    }

    public func format(date: DateTime): String {
        return toString(format(date, StringBuffer(64), FieldPosition(0)))
    }

    public func parse(text: String): DateTime {
        let pos = ParsePosition(0)
        let result = parse(text, pos)
        if (pos.getIndex() == 0) {
            throw ParseException("Unparseable date: \"" + (text) + "\"", pos.getErrorIndex())
        }
        return result
    }

    public func parse(text: String, cal: Calendar, pos: ParsePosition): Unit

    public func parse(text: String, pos: ParsePosition): DateTime {
        var result: DateTime = None
        let start = pos.getIndex()
        let tzsav = calendar.getTimeZone()
        calendar.clear()
        parse(text, calendar, pos)
        if (pos.getIndex() != start) {
            try {
                result = calendar.getTime()
            } catch (e: IllegalArgumentException) {
                pos.setIndex(start)
                pos.setErrorIndex(start)
            }
        }
        calendar.setTimeZone(tzsav)
        return result
    }

    public override func parseObject(source: String, pos: ParsePosition): Object {
        return parse(source, pos)
    }

    public static let NONE = -1

    public static let FULL = 0

    public static let LONG = 1

    public static let MEDIUM = 2

    public static let SHORT = 3

    public static let DEFAULT = MEDIUM

    public static let RELATIVE = (shl(1, 7))

    public static let RELATIVE_FULL = RELATIVE | FULL

    public static let RELATIVE_LONG = RELATIVE | LONG

    public static let RELATIVE_MEDIUM = RELATIVE | MEDIUM

    public static let RELATIVE_SHORT = RELATIVE | SHORT

    public static let RELATIVE_DEFAULT = RELATIVE | DEFAULT

    public static let YEAR = "y"

    public static let QUARTER = "QQQQ"

    public static let ABBR_QUARTER = "QQQ"

    public static let YEAR_QUARTER = "yQQQQ"

    public static let YEAR_ABBR_QUARTER = "yQQQ"

    public static let MONTH = "MMMM"

    public static let ABBR_MONTH = "MMM"

    public static let NUM_MONTH = "M"

    public static let YEAR_MONTH = "yMMMM"

    public static let YEAR_ABBR_MONTH = "yMMM"

    public static let YEAR_NUM_MONTH = "yM"

    public static let DAY = "d"

    public static let YEAR_MONTH_DAY = "yMMMMd"

    public static let YEAR_ABBR_MONTH_DAY = "yMMMd"

    public static let YEAR_NUM_MONTH_DAY = "yMd"

    public static let WEEKDAY = "EEEE"

    public static let ABBR_WEEKDAY = "E"

    public static let YEAR_MONTH_WEEKDAY_DAY = "yMMMMEEEEd"

    public static let YEAR_ABBR_MONTH_WEEKDAY_DAY = "yMMMEd"

    public static let YEAR_NUM_MONTH_WEEKDAY_DAY = "yMEd"

    public static let MONTH_DAY = "MMMMd"

    public static let ABBR_MONTH_DAY = "MMMd"

    public static let NUM_MONTH_DAY = "Md"

    public static let MONTH_WEEKDAY_DAY = "MMMMEEEEd"

    public static let ABBR_MONTH_WEEKDAY_DAY = "MMMEd"

    public static let NUM_MONTH_WEEKDAY_DAY = "MEd"

    
    public static let DATE_SKELETONS = ArrayList<String>([YEAR, QUARTER, ABBR_QUARTER, YEAR_QUARTER, YEAR_ABBR_QUARTER, MONTH, ABBR_MONTH, NUM_MONTH, YEAR_MONTH, YEAR_ABBR_MONTH, YEAR_NUM_MONTH, DAY, YEAR_MONTH_DAY, YEAR_ABBR_MONTH_DAY, YEAR_NUM_MONTH_DAY, WEEKDAY, ABBR_WEEKDAY, YEAR_MONTH_WEEKDAY_DAY, YEAR_ABBR_MONTH_WEEKDAY_DAY, YEAR_NUM_MONTH_WEEKDAY_DAY, MONTH_DAY, ABBR_MONTH_DAY, NUM_MONTH_DAY, MONTH_WEEKDAY_DAY, ABBR_MONTH_WEEKDAY_DAY, NUM_MONTH_WEEKDAY_DAY])

    public static let HOUR = "j"

    public static let HOUR24 = "H"

    public static let MINUTE = "m"

    public static let HOUR_MINUTE = "jm"

    public static let HOUR24_MINUTE = "Hm"

    public static let SECOND = "s"

    public static let HOUR_MINUTE_SECOND = "jms"

    public static let HOUR24_MINUTE_SECOND = "Hms"

    public static let MINUTE_SECOND = "ms"

    
    public static let TIME_SKELETONS = ArrayList<String>([HOUR, HOUR24, MINUTE, HOUR_MINUTE, HOUR24_MINUTE, SECOND, HOUR_MINUTE_SECOND, HOUR24_MINUTE_SECOND, MINUTE_SECOND])

    public static let LOCATION_TZ = "VVVV"

    public static let GENERIC_TZ = "vvvv"

    public static let ABBR_GENERIC_TZ = "v"

    public static let SPECIFIC_TZ = "zzzz"

    public static let ABBR_SPECIFIC_TZ = "z"

    public static let ABBR_UTC_TZ = "ZZZZ"

    
    public static let ZONE_SKELETONS = ArrayList<String>([LOCATION_TZ, GENERIC_TZ, ABBR_GENERIC_TZ, SPECIFIC_TZ, ABBR_SPECIFIC_TZ, ABBR_UTC_TZ])

    
    public static let STANDALONE_MONTH = "LLLL"

    
    public static let ABBR_STANDALONE_MONTH = "LLL"

    
    public static let HOUR_MINUTE_GENERIC_TZ = "jmv"

    
    public static let HOUR_MINUTE_TZ = "jmz"

    
    public static let HOUR_GENERIC_TZ = "jv"

    
    public static let HOUR_TZ = "jz"

    
    public static let JP_ERA_2019_ROOT = "Reiwa"

    
    public static let JP_ERA_2019_JA = "\u{4ee4}\u{548c}"

    
    public static let JP_ERA_2019_NARROW = "R"

    public static func getTimeInstance(): DateFormat {
        return get(-1, DEFAULT, ULocale.getDefault(ULocale_Category.FORMAT), None)
    }

    public static func getTimeInstance(style: Int32): DateFormat {
        return get(-1, style, ULocale.getDefault(ULocale_Category.FORMAT), None)
    }

    public static func getTimeInstance(style: Int32, aLocale: Locale): DateFormat {
        return get(-1, style, ULocale.forLocale(aLocale), None)
    }

    public static func getTimeInstance(style: Int32, locale: ULocale): DateFormat {
        return get(-1, style, locale, None)
    }

    public static func getDateInstance(): DateFormat {
        return get(DEFAULT, -1, ULocale.getDefault(ULocale_Category.FORMAT), None)
    }

    public static func getDateInstance(style: Int32): DateFormat {
        return get(style, -1, ULocale.getDefault(ULocale_Category.FORMAT), None)
    }

    public static func getDateInstance(style: Int32, aLocale: Locale): DateFormat {
        return get(style, -1, ULocale.forLocale(aLocale), None)
    }

    public static func getDateInstance(style: Int32, locale: ULocale): DateFormat {
        return get(style, -1, locale, None)
    }

    public static func getDateTimeInstance(): DateFormat {
        return get(DEFAULT, DEFAULT, ULocale.getDefault(ULocale_Category.FORMAT), None)
    }

    public static func getDateTimeInstance(dateStyle: Int32, timeStyle: Int32): DateFormat {
        return get(dateStyle, timeStyle, ULocale.getDefault(ULocale_Category.FORMAT), None)
    }

    public static func getDateTimeInstance(dateStyle: Int32, timeStyle: Int32, aLocale: Locale): DateFormat {
        return get(dateStyle, timeStyle, ULocale.forLocale(aLocale), None)
    }

    public static func getDateTimeInstance(dateStyle: Int32, timeStyle: Int32, locale: ULocale): DateFormat {
        return get(dateStyle, timeStyle, locale, None)
    }

    public static func getInstance(): DateFormat {
        return getDateTimeInstance(SHORT, SHORT)
    }

    public static func getAvailableLocales(): Array<Locale> {
        return ICUResourceBundle.getAvailableLocales()
    }

    public static func getAvailableULocales(): Array<ULocale> {
        return ICUResourceBundle.getAvailableULocales()
    }

    public func setCalendar(newCalendar: Calendar): Unit {
        this.calendar = newCalendar
    }

    public func getCalendar(): Calendar {
        return calendar
    }

    public func setNumberFormat(newNumberFormat: NumberFormat): Unit {
        numberFormat = newNumberFormat.clone()
        fixNumberFormatForDates(numberFormat)
    }

    static func fixNumberFormatForDates(nf: NumberFormat): Unit {
        nf.setGroupingUsed(false)
        if (checkOptionalIs<DecimalFormat, NumberFormat>(nf)) {
            nf.setDecimalSeparatorAlwaysShown(false)
        }
        nf.setParseIntegerOnly(true)
        nf.setMinimumFractionDigits(0)
    }

    public func getNumberFormat(): NumberFormat {
        return numberFormat
    }

    public func setTimeZone(zone: TimeZone): Unit {
        calendar.setTimeZone(zone)
    }

    public func getTimeZone(): TimeZone {
        return calendar.getTimeZone()
    }

    public func setLenient(lenient: Bool): Unit {
        calendar.setLenient(lenient)
        setBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_NUMERIC, lenient)
        setBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_WHITESPACE, lenient)
    }

    public func isLenient(): Bool {
        return calendar.isLenient() && getBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_NUMERIC) && getBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_WHITESPACE)
    }

    public func setCalendarLenient(lenient: Bool): Unit {
        calendar.setLenient(lenient)
    }

    public func isCalendarLenient(): Bool {
        return calendar.isLenient()
    }

    public func setBoolAttribute(key: DateFormat_BoolAttribute, value: Bool): DateFormat {
        var tempkey = key
        if (refEq(tempkey, DateFormat_BoolAttribute.PARSE_PARTIAL_MATCH)) {
            tempkey = DateFormat_BoolAttribute.PARSE_PARTIAL_LITERAL_MATCH
        }
        if (value) {
            booleanAttributes.add(tempkey)
        } else {
            booleanAttributes.remove(tempkey)
        }
        return this
    }

    public func getBoolAttribute(key: DateFormat_BoolAttribute): Bool {
        var tempkey = key
        if (refEq(tempkey, DateFormat_BoolAttribute.PARSE_PARTIAL_MATCH)) {
            tempkey = DateFormat_BoolAttribute.PARSE_PARTIAL_LITERAL_MATCH
        }
        return booleanAttributes.contains(tempkey)
    }

    public func setContext(context: DisplayContext): Unit {
        if (refEq(context.typeMethod(), DisplayContext_Type.CAPITALIZATION)) {
            capitalizationSetting = context
        }
    }

    public func getContext(Type: DisplayContext_Type): DisplayContext {
        return if (refEq(Type, DisplayContext_Type.CAPITALIZATION) && capitalizationSetting.isSome()) { capitalizationSetting } else { DisplayContext.CAPITALIZATION_NONE }
    }

    public override func hashCode(): Int64 {
        return numberFormat.hashCode()
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (obj.isNone() || !refEq(TypeInfo.of(this), TypeInfo.of(obj))) {
            return false
        }
        let other = obj
        return (((calendar.isNone() && other.calendar.isNone()) || (calendar.isSome() && other.calendar.isSome() && calendar.isEquivalentTo(other.calendar))) && ((numberFormat.isNone() && other.numberFormat.isNone()) || (numberFormat.isSome() && other.numberFormat.isSome() && numberFormat.equals(other.numberFormat))) && refEq(capitalizationSetting, other.capitalizationSetting))
    }

    public override func clone(): Object {
        let other = super.clone()
        other.calendar = calendar.clone()
        if (numberFormat.isSome()) {
            other.numberFormat = numberFormat.clone()
        }
        return other
    }

    private static func get(dateStyle: Int32, timeStyle: Int32, loc: ULocale, cal: Calendar): DateFormat {
        var tempcal = cal
        if ((timeStyle != DateFormat.NONE && (timeStyle & RELATIVE) > 0) || (dateStyle != DateFormat.NONE && (dateStyle & RELATIVE) > 0)) {
            let r = RelativeDateFormat(timeStyle, dateStyle, loc, tempcal)
            return r
        }
        if (timeStyle < DateFormat.NONE || timeStyle > DateFormat.SHORT) {
            throw IllegalArgumentException("Illegal time style " + timeStyle.toString())
        }
        if (dateStyle < DateFormat.NONE || dateStyle > DateFormat.SHORT) {
            throw IllegalArgumentException("Illegal date style " + dateStyle.toString())
        }
        if (tempcal.isNone()) {
            tempcal = Calendar.getInstance(loc)
        }
        try {
            let result = tempcal.getDateTimeFormat(dateStyle, timeStyle, loc)
            result.setLocale(tempcal.getLocale(ULocale.VALID_LOCALE), tempcal.getLocale(ULocale.ACTUAL_LOCALE))
            return result
        } catch (e: MissingResourceException) {
            return SimpleDateFormat("M/d/yy h:mm a")
        }
    }

    private func readObject(stream: ObjectInputStream): Unit {
        stream.defaultReadObject()
        if (serialVersionOnStream < 1) {
            capitalizationSetting = DisplayContext.CAPITALIZATION_NONE
        }
        if (booleanAttributes.isNone()) {
            booleanAttributes = EnumSet.allOf(TypeInfo.of<DateFormat_BoolAttribute>() as ClassTypeInfo)
        }
        serialVersionOnStream = currentSerialVersion
    }

    protected init() {
        super()
    }

    public static func getDateInstance(cal: Calendar, dateStyle: Int32, locale: Locale): DateFormat {
        return getDateTimeInstance(cal, dateStyle, -1, ULocale.forLocale(locale))
    }

    public static func getDateInstance(cal: Calendar, dateStyle: Int32, locale: ULocale): DateFormat {
        return getDateTimeInstance(cal, dateStyle, -1, locale)
    }

    public static func getTimeInstance(cal: Calendar, timeStyle: Int32, locale: Locale): DateFormat {
        return getDateTimeInstance(cal, -1, timeStyle, ULocale.forLocale(locale))
    }

    public static func getTimeInstance(cal: Calendar, timeStyle: Int32, locale: ULocale): DateFormat {
        return getDateTimeInstance(cal, -1, timeStyle, locale)
    }

    public static func getDateTimeInstance(cal: Calendar, dateStyle: Int32, timeStyle: Int32, locale: Locale): DateFormat {
        return getDateTimeInstance(cal, dateStyle, timeStyle, ULocale.forLocale(locale))
    }

    public static func getDateTimeInstance(cal: Calendar, dateStyle: Int32, timeStyle: Int32, locale: ULocale): DateFormat {
        if (cal.isNone()) {
            throw IllegalArgumentException("Calendar must be supplied")
        }
        return get(dateStyle, timeStyle, locale, cal)
    }

    public static func getInstance(cal: Calendar, locale: Locale): DateFormat {
        return getDateTimeInstance(cal, SHORT, SHORT, ULocale.forLocale(locale))
    }

    public static func getInstance(cal: Calendar, locale: ULocale): DateFormat {
        return getDateTimeInstance(cal, SHORT, SHORT, locale)
    }

    public static func getInstance(cal: Calendar): DateFormat {
        return getInstance(cal, ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public static func getDateInstance(cal: Calendar, dateStyle: Int32): DateFormat {
        return getDateInstance(cal, dateStyle, ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public static func getTimeInstance(cal: Calendar, timeStyle: Int32): DateFormat {
        return getTimeInstance(cal, timeStyle, ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public static func getDateTimeInstance(cal: Calendar, dateStyle: Int32, timeStyle: Int32): DateFormat {
        return getDateTimeInstance(cal, dateStyle, timeStyle, ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public static func getInstanceForSkeleton(skeleton: String): DateFormat {
        return getPatternInstance(skeleton, ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public static func getInstanceForSkeleton(skeleton: String, locale: Locale): DateFormat {
        return getPatternInstance(skeleton, ULocale.forLocale(locale))
    }

    public static func getInstanceForSkeleton(skeleton: String, locale: ULocale): DateFormat {
        let generator = DateTimePatternGenerator.getInstance(locale)
        let bestPattern = generator.getBestPattern(skeleton)
        return SimpleDateFormat(bestPattern, locale)
    }

    public static func getInstanceForSkeleton(cal: Calendar, skeleton: String, locale: Locale): DateFormat {
        return getPatternInstance(cal, skeleton, ULocale.forLocale(locale))
    }

    public static func getInstanceForSkeleton(cal: Calendar, skeleton: String, locale: ULocale): DateFormat {
        var templocale = locale
        if (cal.isSome()) {
            templocale = templocale.setKeywordValue("calendar", cal.getType())
        }
        let generator = DateTimePatternGenerator.getInstance(templocale)
        let bestPattern = generator.getBestPattern(skeleton)
        let format = SimpleDateFormat(bestPattern, templocale)
        format.setCalendar(cal)
        return format
    }

    public static func getPatternInstance(skeleton: String): DateFormat {
        return getInstanceForSkeleton(skeleton)
    }

    public static func getPatternInstance(skeleton: String, locale: Locale): DateFormat {
        return getInstanceForSkeleton(skeleton, locale)
    }

    public static func getPatternInstance(skeleton: String, locale: ULocale): DateFormat {
        return getInstanceForSkeleton(skeleton, locale)
    }

    public static func getPatternInstance(cal: Calendar, skeleton: String, locale: Locale): DateFormat {
        return getInstanceForSkeleton(cal, skeleton, locale)
    }

    public static func getPatternInstance(cal: Calendar, skeleton: String, locale: ULocale): DateFormat {
        return getInstanceForSkeleton(cal, skeleton, locale)
    }
}


public class DateFormat_BoolAttribute <: Enum<DateFormat_BoolAttribute> {
    public static let PARSE_ALLOW_WHITESPACE = DateFormat_BoolAttribute("PARSE_ALLOW_WHITESPACE", 0)

    public static let PARSE_ALLOW_NUMERIC = DateFormat_BoolAttribute("PARSE_ALLOW_NUMERIC", 1)

    public static let PARSE_MULTIPLE_PATTERNS_FOR_MATCH = DateFormat_BoolAttribute("PARSE_MULTIPLE_PATTERNS_FOR_MATCH", 2)

    public static let PARSE_PARTIAL_LITERAL_MATCH = DateFormat_BoolAttribute("PARSE_PARTIAL_LITERAL_MATCH", 3)

    
    public static let PARSE_PARTIAL_MATCH = DateFormat_BoolAttribute("PARSE_PARTIAL_MATCH", 4)

    private static func _values(): Array<DateFormat_BoolAttribute> {
        return [DateFormat_BoolAttribute.PARSE_ALLOW_WHITESPACE, DateFormat_BoolAttribute.PARSE_ALLOW_NUMERIC, DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH, DateFormat_BoolAttribute.PARSE_PARTIAL_LITERAL_MATCH, DateFormat_BoolAttribute.PARSE_PARTIAL_MATCH]
    }

    private static let _VALUES = DateFormat_BoolAttribute._values()

    public static func values(): Array<DateFormat_BoolAttribute> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DateFormat_BoolAttribute {
        return (TypeInfo.of<DateFormat_BoolAttribute>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DateFormat_BoolAttribute
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class DateFormat_HourCycle <: Enum<DateFormat_HourCycle> {
    public static let HOUR_CYCLE_11 = DateFormat_HourCycle("HOUR_CYCLE_11", 0)

    public static let HOUR_CYCLE_12 = DateFormat_HourCycle("HOUR_CYCLE_12", 1)

    public static let HOUR_CYCLE_23 = DateFormat_HourCycle("HOUR_CYCLE_23", 2)

    public static let HOUR_CYCLE_24 = DateFormat_HourCycle("HOUR_CYCLE_24", 3)

    private static func _values(): Array<DateFormat_HourCycle> {
        return [DateFormat_HourCycle.HOUR_CYCLE_11, DateFormat_HourCycle.HOUR_CYCLE_12, DateFormat_HourCycle.HOUR_CYCLE_23, DateFormat_HourCycle.HOUR_CYCLE_24]
    }

    private static let _VALUES = DateFormat_HourCycle._values()

    public static func values(): Array<DateFormat_HourCycle> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DateFormat_HourCycle {
        return (TypeInfo.of<DateFormat_HourCycle>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DateFormat_HourCycle
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class DateFormat_Field <: Format_Field {
    private static let serialVersionUID = -3627456821000730829

    private static let CAL_FIELD_COUNT: Int32

    private static let CAL_FIELDS: Array<DateFormat_Field>

    private static let FIELD_NAME_MAP: Map<String, DateFormat_Field>


    public static let AM_PM = DateFormat_Field("am pm", Calendar.AM_PM)

    public static let DAY_OF_MONTH = DateFormat_Field("day of month", Calendar.DAY_OF_MONTH)

    public static let DAY_OF_WEEK = DateFormat_Field("day of week", Calendar.DAY_OF_WEEK)

    public static let DAY_OF_WEEK_IN_MONTH = DateFormat_Field("day of week in month", Calendar.DAY_OF_WEEK_IN_MONTH)

    public static let DAY_OF_YEAR = DateFormat_Field("day of year", Calendar.DAY_OF_YEAR)

    public static let ERA = DateFormat_Field("era", Calendar.ERA)

    public static let HOUR_OF_DAY0 = DateFormat_Field("hour of day", Calendar.HOUR_OF_DAY)

    public static let HOUR_OF_DAY1 = DateFormat_Field("hour of day 1", -1)

    public static let HOUR0 = DateFormat_Field("hour", Calendar.HOUR)

    public static let HOUR1 = DateFormat_Field("hour 1", -1)

    public static let MILLISECOND = DateFormat_Field("millisecond", Calendar.MILLISECOND)

    public static let MINUTE = DateFormat_Field("minute", Calendar.MINUTE)

    public static let MONTH = DateFormat_Field("month", Calendar.MONTH)

    public static let SECOND = DateFormat_Field("second", Calendar.SECOND)

    public static let TIME_ZONE = DateFormat_Field("time zone", -1)

    public static let WEEK_OF_MONTH = DateFormat_Field("week of month", Calendar.WEEK_OF_MONTH)

    public static let WEEK_OF_YEAR = DateFormat_Field("week of year", Calendar.WEEK_OF_YEAR)

    public static let YEAR = DateFormat_Field("year", Calendar.YEAR)

    public static let DOW_LOCAL = DateFormat_Field("local day of week", Calendar.DOW_LOCAL)

    public static let EXTENDED_YEAR = DateFormat_Field("extended year", Calendar.EXTENDED_YEAR)

    public static let JULIAN_DAY = DateFormat_Field("Julian day", Calendar.JULIAN_DAY)

    public static let MILLISECONDS_IN_DAY = DateFormat_Field("milliseconds in day", Calendar.MILLISECONDS_IN_DAY)

    public static let YEAR_WOY = DateFormat_Field("year for week of year", Calendar.YEAR_WOY)

    public static let QUARTER = DateFormat_Field("quarter", -1)

    
    public static let RELATED_YEAR = DateFormat_Field("related year", -1)

    public static let AM_PM_MIDNIGHT_NOON = DateFormat_Field("am/pm/midnight/noon", -1)

    public static let FLEXIBLE_DAY_PERIOD = DateFormat_Field("flexible day period", -1)

    
    public static let TIME_SEPARATOR = DateFormat_Field("time separator", -1)

    private let calendarField: Int32

    protected init(name: String, calendarField: Int32) {
        Format_Field(name)
        this.calendarField = calendarField
        if (refEq(TypeInfo.of(this), TypeInfo.of<DateFormat_Field>())) {
            FIELD_NAME_MAP.put(name, this)
            if (calendarField >= 0 && calendarField < CAL_FIELD_COUNT) {
                CAL_FIELDS[Int64(calendarField)] = this
            }
        }
    }

    public static func ofCalendarField(calendarField: Int32): DateFormat_Field {
        if (calendarField < 0 || calendarField >= CAL_FIELD_COUNT) {
            throw IllegalArgumentException("Calendar field number is out of range")
        }
        return CAL_FIELDS[Int64(calendarField)]
    }

    public func getCalendarField(): Int32 {
        return calendarField
    }

    override protected func readResolve(): Object {
        if (!refEq(TypeInfo.of(this), TypeInfo.of<DateFormat_Field>())) {
            throw InvalidObjectException("A subclass of DateFormat.Field must implement readResolve.")
        }
        let o = FIELD_NAME_MAP.get(this.getName())
        if (o.isNone()) {
            throw InvalidObjectException("Unknown attribute name.")
        }
        return o
    }
}
