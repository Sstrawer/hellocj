package icu4cj.text


public class SimpleDateFormat <: DateFormat & Synchronizable {
    private static let GeneratedStaticLockObject = Monitor()

    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private static let serialVersionUID = 4774881970558875024

    static let currentSerialVersion = 2

    static var DelayedHebrewMonthCheck = false

    private static let CALENDAR_FIELD_TO_LEVEL = [0, 10, 20, 20, 30, 30, 20, 30, 30, 40, 50, 50, 60, 70, 80, 0, 0, 10, 30, 10, 0, 40, 0, 0]

    private static let PATTERN_CHAR_TO_LEVEL = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 40, -1, -1, 20, 30, 30, 0, 50, -1, -1, 50, 20, 20, -1, 0, -1, 20, -1, 80, -1, 10, 0, 30, 0, 10, 0, -1, -1, -1, -1, -1, -1, 40, -1, 30, 30, 30, -1, 0, 50, -1, -1, 50, -1, 60, -1, -1, -1, 20, 10, 70, -1, 10, 0, 20, 0, 10, 0, -1, -1, -1, -1, -1]

    private static func getLevelFromChar(ch: Char): Int32 {
        return if (Int32(UInt32(ch)) < Int32(PATTERN_CHAR_TO_LEVEL.size)) { PATTERN_CHAR_TO_LEVEL[Int64(Int32(UInt32(ch)) & 255)] } else { -1 }
    }

    private static let PATTERN_CHAR_IS_SYNTAX = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, false, false, false, false, false, false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, false, false, false, false, false]

    private static func isSyntaxChar(ch: Char): Bool {
        return if (Int32(UInt32(ch)) < Int32(PATTERN_CHAR_IS_SYNTAX.size)) { PATTERN_CHAR_IS_SYNTAX[Int64(Int32(UInt32(ch)) & 255)] } else { false }
    }

    private static let HEBREW_CAL_CUR_MILLENIUM_START_YEAR = 5000

    private static let HEBREW_CAL_CUR_MILLENIUM_END_YEAR = 6000

    private var serialVersionOnStream = currentSerialVersion

    private var pattern: String

    private var override: String

    private var numberFormatters: HashMap<String, NumberFormat> = None

    private var overrideMap: HashMap<Character, String> = None

    private var formatData: DateFormatSymbols

     private var locale: ULocale

    private var defaultCenturyStart: DateTime = None

     private var defaultCenturyStartYear: Int32 = 0

     private var defaultCenturyBase: Int64 = 0

    private static let millisPerHour = 60 * 60 * 1000

    private static let ISOSpecialEra = -32000

    private static let SUPPRESS_NEGATIVE_PREFIX = "\u{ab00}"

     private var useFastFormat: Bool = false

     private var tzFormat: TimeZoneFormat

     private var capitalizationBrkIter: BreakIterator

     private var hasMinute: Bool = false

     private var hasSecond: Bool = false

     private var hasHanYearChar: Bool = false

    public init() {
        this(getDefaultPattern(), None, None, None, None, true, None)
    }

    public init(pattern: String) {
        this(pattern, None, None, None, None, true, None)
    }

    public init(pattern: String, loc: Locale) {
        this(pattern, None, None, None, ULocale.forLocale(loc), true, None)
    }

    public init(pattern: String, loc: ULocale) {
        this(pattern, None, None, None, loc, true, None)
    }

    public init(pattern: String, override: String, loc: ULocale) {
        this(pattern, None, None, None, loc, false, override)
    }

    public init(pattern: String, formatData: DateFormatSymbols) {
        this(pattern, formatData.clone(), None, None, None, true, None)
    }

    
    public init(pattern: String, formatData: DateFormatSymbols, loc: ULocale) {
        this(pattern, formatData.clone(), None, None, loc, true, None)
    }

    init(pattern: String, formatData: DateFormatSymbols, calendar: Calendar, locale: ULocale, useFastFormat: Bool, override: String) {
        this(pattern, formatData.clone(), calendar.clone(), None, locale, useFastFormat, override)
    }

    private init(pattern: String, formatData: DateFormatSymbols, calendar: Calendar, numberFormat: NumberFormat, locale: ULocale, useFastFormat: Bool, override: String) {
        super()
        this.pattern = pattern
        this.formatData = formatData
        this.calendar = calendar
        this.numberFormat = numberFormat
        this.locale = locale
        this.useFastFormat = useFastFormat
        this.override = override
        initialize()
    }

    
    public static func getInstance(formatConfig: Calendar_FormatConfiguration): SimpleDateFormat {
        let ostr = formatConfig.getOverrideString()
        let useFast = (ostr.isSome() && Int32(ostr.size) > 0)
        return SimpleDateFormat(formatConfig.getPatternString(), formatConfig.getDateFormatSymbols(), formatConfig.getCalendar(), None, formatConfig.getLocale(), useFast, formatConfig.getOverrideString())
    }

    private func initialize(): Unit {
        if (locale.isNone()) {
            locale = ULocale.getDefault(ULocale_Category.FORMAT)
        }
        if (formatData.isNone()) {
            formatData = DateFormatSymbols(locale)
        }
        if (calendar.isNone()) {
            calendar = Calendar.getInstance(locale)
        }
        if (numberFormat.isNone()) {
            let ns = NumberingSystem.getInstance(locale)
            let digitString = ns.getDescription()
            if (ns.isAlgorithmic() || Int32(digitString.size) != 10) {
                numberFormat = NumberFormat.getInstance(locale)
            } else {
                let nsName = ns.getName()
                numberFormat = DateNumberFormat(locale, digitString, nsName)
            }
        }
        if (checkOptionalIs<DecimalFormat, NumberFormat>(numberFormat)) {
            fixNumberFormatForDates(numberFormat)
        }
        defaultCenturyBase = DateTime.now().toUnixTimeStamp().toMilliseconds()
        setLocale(calendar.getLocale(ULocale.VALID_LOCALE), calendar.getLocale(ULocale.ACTUAL_LOCALE))
        initLocalZeroPaddingNumberFormat()
        parsePattern()
        if (override.isNone() && hasHanYearChar && calendar.isSome() && calendar.getType() == "japanese" && locale.isSome() && locale.getLanguage() == "ja") {
            override = "y=jpanyear"
        }
        if (override.isSome()) {
            initNumberFormatters(locale)
        }
    }

    private func initializeTimeZoneFormat(bForceUpdate: Bool): Unit {
        synchronized (GeneratedLockObject) {
            if (bForceUpdate || tzFormat.isNone()) {
                tzFormat = TimeZoneFormat.getInstance(locale)
                var digits: String
                if (checkOptionalIs<DecimalFormat, NumberFormat>(numberFormat)) {
                    let decsym = numberFormat.getDecimalFormatSymbols()
                    let strDigits = decsym.getDigitStringsLocal()
                    let digitsBuf = StringBuilder()
                    for (digit in strDigits) {
                        digitsBuf.append(digit)
                    }
                    digits = digitsBuf.toString()
                } else if (checkOptionalIs<DateNumberFormat, NumberFormat>(numberFormat)) {
                    digits = String(numberFormat.getDigits())
                }
                if (digits.isSome()) {
                    if (!tzFormat.getGMTOffsetDigits().equals(digits)) {
                        if (tzFormat.isFrozen()) {
                            tzFormat = tzFormat.cloneAsThawed()
                        }
                        tzFormat.setGMTOffsetDigits(digits)
                    }
                }
            }
        }
    }

    private func tzFormatMethod(): TimeZoneFormat {
        if (tzFormat.isNone()) {
            initializeTimeZoneFormat(false)
        }
        return tzFormat
    }

    private static var cachedDefaultLocale: ULocale

    private static var cachedDefaultPattern: String

    private static let FALLBACKPATTERN = "yy/MM/dd HH:mm"

    private static func getDefaultPattern(): String {
        synchronized (GeneratedStaticLockObject) {
            let defaultLocale = ULocale.getDefault(ULocale_Category.FORMAT)
            if (!defaultLocale.equals(cachedDefaultLocale)) {
                cachedDefaultLocale = defaultLocale
                let cal = Calendar.getInstance(cachedDefaultLocale)
                try {
                    let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, cachedDefaultLocale)
                    let resourcePath: String = "calendar/" + (cal.getType()) + "/DateTimePatterns"
                    var patternsRb = rb.findWithFallback(resourcePath)
                    if (patternsRb.isNone()) {
                        patternsRb = rb.findWithFallback("calendar/gregorian/DateTimePatterns")
                    }
                    if (patternsRb.isNone() || patternsRb.getSize() < 9) {
                        cachedDefaultPattern = FALLBACKPATTERN
                    } else {
                        let basePattern = Calendar.getDateAtTimePattern(cal, cachedDefaultLocale, SHORT)
                        cachedDefaultPattern = SimpleFormatterImpl.formatRawPattern(basePattern, 2, 2, [patternsRb.getString(SHORT), patternsRb.getString(SHORT + 4)])
                    }
                } catch (e: MissingResourceException) {
                    cachedDefaultPattern = FALLBACKPATTERN
                }
            }
            return cachedDefaultPattern
        }
    }

    private func parseAmbiguousDatesAsAfter(startDate: DateTime): Unit {
        defaultCenturyStart = startDate
        calendar.setTime(startDate)
        defaultCenturyStartYear = calendar.get(Calendar.YEAR)
    }

    private func initializeDefaultCenturyStart(baseTime: Int64): Unit {
        defaultCenturyBase = baseTime
        let tmpCal = calendar.clone()
        tmpCal.setTimeInMillis(baseTime)
        tmpCal.add(Calendar.YEAR, -80)
        defaultCenturyStart = tmpCal.getTime()
        defaultCenturyStartYear = tmpCal.get(Calendar.YEAR)
    }

    private func getDefaultCenturyStart(): DateTime {
        if (defaultCenturyStart.isNone()) {
            initializeDefaultCenturyStart(defaultCenturyBase)
        }
        return defaultCenturyStart
    }

    private func getDefaultCenturyStartYear(): Int32 {
        if (defaultCenturyStart.isNone()) {
            initializeDefaultCenturyStart(defaultCenturyBase)
        }
        return defaultCenturyStartYear
    }

    public func set2DigitYearStart(startDate: DateTime): Unit {
        parseAmbiguousDatesAsAfter(startDate)
    }

    public func get2DigitYearStart(): DateTime {
        return getDefaultCenturyStart()
    }

    public override func setContext(context: DisplayContext): Unit {
        super.setContext(context)
        if (capitalizationBrkIter.isNone() && (refEq(context, DisplayContext.CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE) || refEq(context, DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU) || refEq(context, DisplayContext.CAPITALIZATION_FOR_STANDALONE))) {
            capitalizationBrkIter = BreakIterator.getSentenceInstance(locale)
        }
    }

    public override func format(cal: Calendar, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        return format(cal, toAppendTo, pos, None)
    }

    public func format(cal: Calendar, toAppendTo: StringBuffer, pos: FieldPosition, attributes: ArrayList<FieldPosition>): StringBuffer {
        var tempcal = cal
        var backupTZ: TimeZone
        if (!refEq(tempcal, calendar) && !tempcal.getType().equals(calendar.getType())) {
            calendar.setTimeInMillis(tempcal.getTimeInMillis())
            backupTZ = calendar.getTimeZone()
            calendar.setTimeZone(tempcal.getTimeZone())
            tempcal = calendar
        }
        let result = format(tempcal, getContext(DisplayContext_Type.CAPITALIZATION), toAppendTo, pos, attributes)
        if (backupTZ.isSome()) {
            calendar.setTimeZone(backupTZ)
        }
        return result
    }

    private func format(cal: Calendar, capitalizationContext: DisplayContext, toAppendTo: StringBuffer, pos: FieldPosition, attributes: ArrayList<FieldPosition>): StringBuffer {
        pos.setBeginIndex(0)
        pos.setEndIndex(0)
        let items = getPatternItems()
        var i = 0
        while (i < Int32(items.size)) {
            if (items[Int64(i)]) {
                toAppendTo.append(items[Int64(i)])
            } else {
                let item = items[Int64(i)]
                var start = 0
                if (attributes.isSome()) {
                    start = Int32(toAppendTo.size)
                }
                if (useFastFormat) {
                    subFormat(toAppendTo, item.Type, item.length, Int32(toAppendTo.size), i, capitalizationContext, pos, item.Type, cal)
                } else {
                    toAppendTo.append(subFormat(item.Type, item.length, Int32(toAppendTo.size), i, capitalizationContext, pos, item.Type, cal))
                }
                if (attributes.isSome()) {
                    let end = Int32(toAppendTo.size)
                    if (end - start > 0) {
                        let attr = patternCharToDateFormatField(item.Type)
                        let fp = FieldPosition(attr)
                        fp.setBeginIndex(start)
                        fp.setEndIndex(end)
                        attributes.append(fp)
                    }
                }
            }
            i++
        }
        return toAppendTo
    }

    private static let PATTERN_CHAR_TO_INDEX = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 22, 36, -1, 10, 9, 11, 0, 5, -1, -1, 16, 26, 2, -1, 31, -1, 27, -1, 8, -1, 30, 29, 13, 32, 18, 23, -1, -1, -1, -1, -1, -1, 14, 35, 25, 3, 19, -1, 21, 15, -1, -1, 4, -1, 6, -1, -1, -1, 28, 34, 7, -1, 20, 24, 12, 33, 1, 17, -1, -1, -1, -1, -1]

    private static func getIndexFromChar(ch: Char): Int32 {
        return if (Int32(UInt32(ch)) < Int32(PATTERN_CHAR_TO_INDEX.size)) { PATTERN_CHAR_TO_INDEX[Int64(Int32(UInt32(ch)) & 255)] } else { -1 }
    }

    private static let PATTERN_INDEX_TO_CALENDAR_FIELD = [Calendar.ERA, Calendar.YEAR, Calendar.MONTH, Calendar.DATE, Calendar.HOUR_OF_DAY, Calendar.HOUR_OF_DAY, Calendar.MINUTE, Calendar.SECOND, Calendar.MILLISECOND, Calendar.DAY_OF_WEEK, Calendar.DAY_OF_YEAR, Calendar.DAY_OF_WEEK_IN_MONTH, Calendar.WEEK_OF_YEAR, Calendar.WEEK_OF_MONTH, Calendar.AM_PM, Calendar.HOUR, Calendar.HOUR, Calendar.ZONE_OFFSET, Calendar.YEAR_WOY, Calendar.DOW_LOCAL, Calendar.EXTENDED_YEAR, Calendar.JULIAN_DAY, Calendar.MILLISECONDS_IN_DAY, Calendar.ZONE_OFFSET, Calendar.ZONE_OFFSET, Calendar.DOW_LOCAL, Calendar.MONTH, Calendar.MONTH, Calendar.MONTH, Calendar.ZONE_OFFSET, Calendar.YEAR, Calendar.ZONE_OFFSET, Calendar.ZONE_OFFSET, Calendar.ZONE_OFFSET, Calendar.EXTENDED_YEAR, -1, -1 - 1]

    private static let PATTERN_INDEX_TO_DATE_FORMAT_FIELD = [DateFormat.ERA_FIELD, DateFormat.YEAR_FIELD, DateFormat.MONTH_FIELD, DateFormat.DATE_FIELD, DateFormat.HOUR_OF_DAY1_FIELD, DateFormat.HOUR_OF_DAY0_FIELD, DateFormat.MINUTE_FIELD, DateFormat.SECOND_FIELD, DateFormat.FRACTIONAL_SECOND_FIELD, DateFormat.DAY_OF_WEEK_FIELD, DateFormat.DAY_OF_YEAR_FIELD, DateFormat.DAY_OF_WEEK_IN_MONTH_FIELD, DateFormat.WEEK_OF_YEAR_FIELD, DateFormat.WEEK_OF_MONTH_FIELD, DateFormat.AM_PM_FIELD, DateFormat.HOUR1_FIELD, DateFormat.HOUR0_FIELD, DateFormat.TIMEZONE_FIELD, DateFormat.YEAR_WOY_FIELD, DateFormat.DOW_LOCAL_FIELD, DateFormat.EXTENDED_YEAR_FIELD, DateFormat.JULIAN_DAY_FIELD, DateFormat.MILLISECONDS_IN_DAY_FIELD, DateFormat.TIMEZONE_RFC_FIELD, DateFormat.TIMEZONE_GENERIC_FIELD, DateFormat.STANDALONE_DAY_FIELD, DateFormat.STANDALONE_MONTH_FIELD, DateFormat.QUARTER_FIELD, DateFormat.STANDALONE_QUARTER_FIELD, DateFormat.TIMEZONE_SPECIAL_FIELD, DateFormat.YEAR_NAME_FIELD, DateFormat.TIMEZONE_LOCALIZED_GMT_OFFSET_FIELD, DateFormat.TIMEZONE_ISO_FIELD, DateFormat.TIMEZONE_ISO_LOCAL_FIELD, DateFormat.RELATED_YEAR, DateFormat.AM_PM_MIDNIGHT_NOON_FIELD, DateFormat.FLEXIBLE_DAY_PERIOD_FIELD, DateFormat.TIME_SEPARATOR]

    private static let PATTERN_INDEX_TO_DATE_FORMAT_ATTRIBUTE: Array<DateFormat_Field> = [DateFormat_Field.ERA, DateFormat_Field.YEAR, DateFormat_Field.MONTH, DateFormat_Field.DAY_OF_MONTH, DateFormat_Field.HOUR_OF_DAY1, DateFormat_Field.HOUR_OF_DAY0, DateFormat_Field.MINUTE, DateFormat_Field.SECOND, DateFormat_Field.MILLISECOND, DateFormat_Field.DAY_OF_WEEK, DateFormat_Field.DAY_OF_YEAR, DateFormat_Field.DAY_OF_WEEK_IN_MONTH, DateFormat_Field.WEEK_OF_YEAR, DateFormat_Field.WEEK_OF_MONTH, DateFormat_Field.AM_PM, DateFormat_Field.HOUR1, DateFormat_Field.HOUR0, DateFormat_Field.TIME_ZONE, DateFormat_Field.YEAR_WOY, DateFormat_Field.DOW_LOCAL, DateFormat_Field.EXTENDED_YEAR, DateFormat_Field.JULIAN_DAY, DateFormat_Field.MILLISECONDS_IN_DAY, DateFormat_Field.TIME_ZONE, DateFormat_Field.TIME_ZONE, DateFormat_Field.DAY_OF_WEEK, DateFormat_Field.MONTH, DateFormat_Field.QUARTER, DateFormat_Field.QUARTER, DateFormat_Field.TIME_ZONE, DateFormat_Field.YEAR, DateFormat_Field.TIME_ZONE, DateFormat_Field.TIME_ZONE, DateFormat_Field.TIME_ZONE, DateFormat_Field.RELATED_YEAR, DateFormat_Field.AM_PM_MIDNIGHT_NOON, DateFormat_Field.FLEXIBLE_DAY_PERIOD, DateFormat_Field.TIME_SEPARATOR]

    protected func patternCharToDateFormatField(ch: Char): DateFormat_Field {
        let patternCharIndex = getIndexFromChar(ch)
        if (patternCharIndex != -1) {
            return PATTERN_INDEX_TO_DATE_FORMAT_ATTRIBUTE[Int64(patternCharIndex)]
        }
        return None
    }

    protected func subFormat(ch: Char, count: Int32, beginOffset: Int32, pos: FieldPosition, fmtData: DateFormatSymbols, cal: Calendar): String {
        return subFormat(ch, count, beginOffset, 0, DisplayContext.CAPITALIZATION_NONE, pos, ch, cal)
    }

    
    protected func subFormat(ch: Char, count: Int32, beginOffset: Int32, fieldNum: Int32, capitalizationContext: DisplayContext, pos: FieldPosition, patternCharToOutput: Char, cal: Calendar): String {
        let buf = StringBuffer()
        subFormat(buf, ch, count, beginOffset, fieldNum, capitalizationContext, pos, patternCharToOutput, cal)
        return toString(buf)
    }

    
    protected func subFormat(buf: StringBuffer, ch: Char, count: Int32, beginOffset: Int32, fieldNum: Int32, capitalizationContext: DisplayContext, pos: FieldPosition, patternCharToOutput: Char, cal: Calendar): Unit {
        let maxIntCount = Int32.Max
        let bufstart = Int32(buf.size)
        let tz = cal.getTimeZone()
        let date = cal.getTimeInMillis()
        var result: String
        let patternCharIndex = getIndexFromChar(ch)
        if (patternCharIndex == -1) {
            if (ch == 'l') {
                return
            } else {
                throw IllegalArgumentException("Illegal pattern character '" + ch.toString() + "' in \"" + (pattern) + '\"'.toString())
            }
        }
        let field = PATTERN_INDEX_TO_CALENDAR_FIELD[Int64(patternCharIndex)]
        var value = 0
        if (field >= 0) {
            value = if (patternCharIndex != DateFormat.RELATED_YEAR) { cal.get(field) } else { cal.getRelatedYear() }
        }
        let currentNumberFormat = getNumberFormat(ch)
        var capContextUsageType: DateFormatSymbols_CapitalizationContextUsage = DateFormatSymbols_CapitalizationContextUsage.OTHER
        match (patternCharIndex) {
            case 0 => if (cal.getType() == "chinese" || cal.getType() == "dangi") {
                zeroPaddingNumber(currentNumberFormat, buf, value, 1, 9)
            } else {
                if (count == 5) {
                    safeAppend(formatData.narrowEras, value, buf)
                    capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.ERA_NARROW
                } else if (count == 4) {
                    safeAppend(formatData.eraNames, value, buf)
                    capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.ERA_WIDE
                } else {
                    safeAppend(formatData.eras, value, buf)
                    capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.ERA_ABBREV
                }
            }
            case 30 => if (formatData.shortYearNames.isSome() && value <= Int32(formatData.shortYearNames.size)) {
                safeAppend(formatData.shortYearNames, value - 1, buf)
                break
            }
            case 1 | 18 =>
                if (override.isSome() && (override.compare("hebr").value() == 0 || indexOfWrap(override.indexOf("y=hebr")) >= 0) && value > HEBREW_CAL_CUR_MILLENIUM_START_YEAR && value < HEBREW_CAL_CUR_MILLENIUM_END_YEAR) {
                    value -= HEBREW_CAL_CUR_MILLENIUM_START_YEAR
                }
                if (count == 2) {
                    zeroPaddingNumber(currentNumberFormat, buf, value, 2, 2)
                } else {
                    zeroPaddingNumber(currentNumberFormat, buf, value, count, maxIntCount)
                }
            case 2 | 26 =>
                if (cal.getType() == "hebrew") {
                    let isLeap = HebrewCalendar.isLeapYear(cal.get(Calendar.YEAR))
                    if (isLeap && value == 6 && count >= 3) {
                        value = 13
                    }
                    if (!isLeap && value >= 6 && count < 3) {
                        value--
                    }
                }
                let isLeapMonth = if (formatData.leapMonthPatterns.isSome() && Int32(formatData.leapMonthPatterns.size) >= DateFormatSymbols.DT_MONTH_PATTERN_COUNT) { cal.get(Calendar.IS_LEAP_MONTH) } else { 0 }
                if (count == 5) {
                    if (patternCharIndex == 2) {
                        safeAppendWithMonthPattern(formatData.narrowMonths, value, buf, if (isLeapMonth != 0) { formatData.leapMonthPatterns[Int64(DateFormatSymbols.DT_LEAP_MONTH_PATTERN_FORMAT_NARROW)] } else { None })
                    } else {
                        safeAppendWithMonthPattern(formatData.standaloneNarrowMonths, value, buf, if (isLeapMonth != 0) { formatData.leapMonthPatterns[Int64(DateFormatSymbols.DT_LEAP_MONTH_PATTERN_STANDALONE_NARROW)] } else { None })
                    }
                    capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.MONTH_NARROW
                } else if (count == 4) {
                    if (patternCharIndex == 2) {
                        safeAppendWithMonthPattern(formatData.months, value, buf, if (isLeapMonth != 0) { formatData.leapMonthPatterns[Int64(DateFormatSymbols.DT_LEAP_MONTH_PATTERN_FORMAT_WIDE)] } else { None })
                        capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.MONTH_FORMAT
                    } else {
                        safeAppendWithMonthPattern(formatData.standaloneMonths, value, buf, if (isLeapMonth != 0) { formatData.leapMonthPatterns[Int64(DateFormatSymbols.DT_LEAP_MONTH_PATTERN_STANDALONE_WIDE)] } else { None })
                        capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.MONTH_STANDALONE
                    }
                } else if (count == 3) {
                    if (patternCharIndex == 2) {
                        safeAppendWithMonthPattern(formatData.shortMonths, value, buf, if (isLeapMonth != 0) { formatData.leapMonthPatterns[Int64(DateFormatSymbols.DT_LEAP_MONTH_PATTERN_FORMAT_ABBREV)] } else { None })
                        capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.MONTH_FORMAT
                    } else {
                        safeAppendWithMonthPattern(formatData.standaloneShortMonths, value, buf, if (isLeapMonth != 0) { formatData.leapMonthPatterns[Int64(DateFormatSymbols.DT_LEAP_MONTH_PATTERN_STANDALONE_ABBREV)] } else { None })
                        capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.MONTH_STANDALONE
                    }
                } else {
                    let monthNumber = StringBuffer()
                    zeroPaddingNumber(currentNumberFormat, monthNumber, value + 1, count, maxIntCount)
                    let monthNumberStrings = Array<String>(1)
                    monthNumberStrings[0] = toString(monthNumber)
                    safeAppendWithMonthPattern(monthNumberStrings, 0, buf, if (isLeapMonth != 0) { formatData.leapMonthPatterns[Int64(DateFormatSymbols.DT_LEAP_MONTH_PATTERN_NUMERIC)] } else { None })
                }
            case 4 => if (value == 0) {
                zeroPaddingNumber(currentNumberFormat, buf, cal.getMaximum(Calendar.HOUR_OF_DAY) + 1, count, maxIntCount)
            } else {
                zeroPaddingNumber(currentNumberFormat, buf, value, count, maxIntCount)
            }
            case 8 =>
                numberFormat.setMinimumIntegerDigits(min(3, count))
                numberFormat.setMaximumIntegerDigits(maxIntCount)
                if (count == 1) {
                    value /= 100
                } else if (count == 2) {
                    value /= 10
                }
                let p = FieldPosition(-1)
                numberFormat.format(Int64(value), buf, p)
                if (count > 3) {
                    numberFormat.setMinimumIntegerDigits(count - 3)
                    numberFormat.format(0, buf, p)
                }
            case 19 =>
                if (count < 3) {
                    zeroPaddingNumber(currentNumberFormat, buf, value, count, maxIntCount)
                    break
                }
                value = cal.get(Calendar.DAY_OF_WEEK)
            case 9 => if (count == 5) {
                safeAppend(formatData.narrowWeekdays, value, buf)
                capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.DAY_NARROW
            } else if (count == 4) {
                safeAppend(formatData.weekdays, value, buf)
                capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.DAY_FORMAT
            } else if (count == 6 && formatData.shorterWeekdays.isSome()) {
                safeAppend(formatData.shorterWeekdays, value, buf)
                capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.DAY_FORMAT
            } else {
                safeAppend(formatData.shortWeekdays, value, buf)
                capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.DAY_FORMAT
            }
            case 14 => if (count < 5 || formatData.ampmsNarrow.isNone()) {
                safeAppend(formatData.ampms, value, buf)
            } else {
                safeAppend(formatData.ampmsNarrow, value, buf)
            }
            case 15 => if (value == 0) {
                zeroPaddingNumber(currentNumberFormat, buf, cal.getLeastMaximum(Calendar.HOUR) + 1, count, maxIntCount)
            } else {
                zeroPaddingNumber(currentNumberFormat, buf, value, count, maxIntCount)
            }
            case 17 =>
                if (count < 4) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.SPECIFIC_SHORT, tz, date)
                    capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.METAZONE_SHORT
                } else {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.SPECIFIC_LONG, tz, date)
                    capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.METAZONE_LONG
                }
                buf.append(result)
            case 23 =>
                if (count < 4) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ISO_BASIC_LOCAL_FULL, tz, date)
                } else if (count == 5) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ISO_EXTENDED_FULL, tz, date)
                } else {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.LOCALIZED_GMT, tz, date)
                }
                buf.append(result)
            case 24 =>
                if (count == 1) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.GENERIC_SHORT, tz, date)
                    capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.METAZONE_SHORT
                } else if (count == 4) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.GENERIC_LONG, tz, date)
                    capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.METAZONE_LONG
                }
                buf.append(result)
            case 29 =>
                if (count == 1) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ZONE_ID_SHORT, tz, date)
                } else if (count == 2) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ZONE_ID, tz, date)
                } else if (count == 3) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.EXEMPLAR_LOCATION, tz, date)
                } else if (count == 4) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.GENERIC_LOCATION, tz, date)
                    capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.ZONE_LONG
                }
                buf.append(result)
            case 31 =>
                if (count == 1) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.LOCALIZED_GMT_SHORT, tz, date)
                } else if (count == 4) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.LOCALIZED_GMT, tz, date)
                }
                buf.append(result)
            case 32 =>
                if (count == 1) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ISO_BASIC_SHORT, tz, date)
                } else if (count == 2) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ISO_BASIC_FIXED, tz, date)
                } else if (count == 3) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ISO_EXTENDED_FIXED, tz, date)
                } else if (count == 4) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ISO_BASIC_FULL, tz, date)
                } else if (count == 5) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ISO_EXTENDED_FULL, tz, date)
                }
                buf.append(result)
            case 33 =>
                if (count == 1) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ISO_BASIC_LOCAL_SHORT, tz, date)
                } else if (count == 2) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ISO_BASIC_LOCAL_FIXED, tz, date)
                } else if (count == 3) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ISO_EXTENDED_LOCAL_FIXED, tz, date)
                } else if (count == 4) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ISO_BASIC_LOCAL_FULL, tz, date)
                } else if (count == 5) {
                    result = tzFormatMethod().format(TimeZoneFormat_Style.ISO_EXTENDED_LOCAL_FULL, tz, date)
                }
                buf.append(result)
            case 25 =>
                if (count < 3) {
                    zeroPaddingNumber(currentNumberFormat, buf, value, 1, maxIntCount)
                    break
                }
                value = cal.get(Calendar.DAY_OF_WEEK)
                if (count == 5) {
                    safeAppend(formatData.standaloneNarrowWeekdays, value, buf)
                    capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.DAY_NARROW
                } else if (count == 4) {
                    safeAppend(formatData.standaloneWeekdays, value, buf)
                    capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.DAY_STANDALONE
                } else if (count == 6 && formatData.standaloneShorterWeekdays.isSome()) {
                    safeAppend(formatData.standaloneShorterWeekdays, value, buf)
                    capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.DAY_STANDALONE
                } else {
                    safeAppend(formatData.standaloneShortWeekdays, value, buf)
                    capContextUsageType = DateFormatSymbols_CapitalizationContextUsage.DAY_STANDALONE
                }
            case 27 => if (count >= 5) {
                safeAppend(formatData.narrowQuarters, value / 3, buf)
            } else if (count == 4) {
                safeAppend(formatData.quarters, value / 3, buf)
            } else if (count == 3) {
                safeAppend(formatData.shortQuarters, value / 3, buf)
            } else {
                zeroPaddingNumber(currentNumberFormat, buf, (value / 3) + 1, count, maxIntCount)
            }
            case 28 => if (count >= 5) {
                safeAppend(formatData.standaloneNarrowQuarters, value / 3, buf)
            } else if (count == 4) {
                safeAppend(formatData.standaloneQuarters, value / 3, buf)
            } else if (count == 3) {
                safeAppend(formatData.standaloneShortQuarters, value / 3, buf)
            } else {
                zeroPaddingNumber(currentNumberFormat, buf, (value / 3) + 1, count, maxIntCount)
            }
            case 35 =>
                let hour = cal.get(Calendar.HOUR_OF_DAY)
                var toAppend: String
                if ((hour == 12) && (!hasMinute || cal.get(Calendar.MINUTE) == 0) && (!hasSecond || cal.get(Calendar.SECOND) == 0)) {
                    value = cal.get(Calendar.AM_PM)
                    if (count <= 3) {
                        toAppend = formatData.abbreviatedDayPeriods[Int64(value)]
                    } else if (count == 4 || count > 5) {
                        toAppend = formatData.wideDayPeriods[Int64(value)]
                    } else {
                        toAppend = formatData.narrowDayPeriods[Int64(value)]
                    }
                }
                if (toAppend.isNone()) {
                    subFormat(buf, 'a', count, beginOffset, fieldNum, capitalizationContext, pos, 'b', cal)
                } else {
                    buf.append(toAppend)
                }
                break
            case 36 =>
                let ruleSet = DayPeriodRules.getInstance(getLocale())
                if (ruleSet.isNone()) {
                    subFormat(buf, 'a', count, beginOffset, fieldNum, capitalizationContext, pos, 'B', cal)
                    return
                }
                let hour = cal.get(Calendar.HOUR_OF_DAY)
                var minute = 0
                var second = 0
                if (hasMinute) {
                    minute = cal.get(Calendar.MINUTE)
                }
                if (hasSecond) {
                    second = cal.get(Calendar.SECOND)
                }
                var periodType: DayPeriodRules_DayPeriod
                if (hour == 0 && minute == 0 && second == 0 && ruleSet.hasMidnightMethod()) {
                    periodType = DayPeriodRules_DayPeriod.MIDNIGHT
                } else if (hour == 12 && minute == 0 && second == 0 && ruleSet.hasNoonMethod()) {
                    periodType = DayPeriodRules_DayPeriod.NOON
                } else {
                    periodType = ruleSet.getDayPeriodForHour(hour)
                }
                if (!(periodType.isSome())) {
                    throw AssertionError()
                }
                var toAppend: String
                var index: Int32 = 0
                if (!refEq(periodType, DayPeriodRules_DayPeriod.AM) && !refEq(periodType, DayPeriodRules_DayPeriod.PM) && !refEq(periodType, DayPeriodRules_DayPeriod.MIDNIGHT)) {
                    index = periodType.ordinal
                    if (count <= 3) {
                        toAppend = formatData.abbreviatedDayPeriods[Int64(index)]
                    } else if (count == 4 || count > 5) {
                        toAppend = formatData.wideDayPeriods[Int64(index)]
                    } else {
                        toAppend = formatData.narrowDayPeriods[Int64(index)]
                    }
                }
                if (toAppend.isNone() && (refEq(periodType, DayPeriodRules_DayPeriod.MIDNIGHT) || refEq(periodType, DayPeriodRules_DayPeriod.NOON))) {
                    periodType = ruleSet.getDayPeriodForHour(hour)
                    index = periodType.ordinal
                    if (count <= 3) {
                        toAppend = formatData.abbreviatedDayPeriods[Int64(index)]
                    } else if (count == 4 || count > 5) {
                        toAppend = formatData.wideDayPeriods[Int64(index)]
                    } else {
                        toAppend = formatData.narrowDayPeriods[Int64(index)]
                    }
                }
                if (refEq(periodType, DayPeriodRules_DayPeriod.AM) || refEq(periodType, DayPeriodRules_DayPeriod.PM) || toAppend.isNone()) {
                    subFormat(buf, 'a', count, beginOffset, fieldNum, capitalizationContext, pos, 'B', cal)
                    return
                } else {
                    buf.append(toAppend)
                }
                break
            case 37 => buf.append(formatData.getTimeSeparatorString())
            case _ => zeroPaddingNumber(currentNumberFormat, buf, value, count, maxIntCount)
        }
        if (fieldNum == 0 && capitalizationContext.isSome() && Int32(buf.size) > bufstart && UCharacter.isLowerCase(buf.codePointAt(bufstart))) {
            var titlecase = false
            match (capitalizationContext) {
                case DisplayContext.CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE => titlecase = true
                case DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU | DisplayContext.CAPITALIZATION_FOR_STANDALONE => if (formatData.capitalization.isSome()) {
                    let transforms = formatData.capitalization.get(capContextUsageType)
                    titlecase = if (refEq(capitalizationContext, DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU)) { transforms[0] } else { transforms[1] }
                }
                case _ => ()
            }
            if (titlecase) {
                if (capitalizationBrkIter.isNone()) {
                    capitalizationBrkIter = BreakIterator.getSentenceInstance(locale)
                }
                let mutableCapitalizationBrkIter = capitalizationBrkIter.clone()
                let firstField = buf.substring(bufstart)
                let firstFieldTitleCase = UCharacter.toTitleCase(locale, firstField, mutableCapitalizationBrkIter, UCharacter.TITLECASE_NO_LOWERCASE | UCharacter.TITLECASE_NO_BREAK_ADJUSTMENT)
                buf.replace(bufstart, Int32(buf.size), firstFieldTitleCase)
            }
        }
        let outputCharIndex = getIndexFromChar(patternCharToOutput)
        if (pos.getBeginIndex() == pos.getEndIndex()) {
            if (pos.getField() == PATTERN_INDEX_TO_DATE_FORMAT_FIELD[Int64(outputCharIndex)]) {
                pos.setBeginIndex(beginOffset)
                pos.setEndIndex(beginOffset + Int32(buf.size) - bufstart)
            } else if (refEq(pos.getFieldAttribute(), PATTERN_INDEX_TO_DATE_FORMAT_ATTRIBUTE[Int64(outputCharIndex)])) {
                pos.setBeginIndex(beginOffset)
                pos.setEndIndex(beginOffset + Int32(buf.size) - bufstart)
            }
        }
    }

    private static func safeAppend(array: Array<String>, value: Int32, appendTo: StringBuffer): Unit {
        if (array.isSome() && value >= 0 && value < Int32(array.size)) {
            appendTo.append(array[Int64(value)])
        }
    }

    private static func safeAppendWithMonthPattern(array: Array<String>, value: Int32, appendTo: StringBuffer, monthPattern: String): Unit {
        if (array.isSome() && value >= 0 && value < Int32(array.size)) {
            if (monthPattern.isNone()) {
                appendTo.append(array[Int64(value)])
            } else {
                let s = SimpleFormatterImpl.formatRawPattern(monthPattern, 1, 1, [array[Int64(value)]])
                appendTo.append(s)
            }
        }
    }

    private static var PARSED_PATTERN_CACHE: ICUCache<String, Array<Object>> = SimpleCache<String, Array<Object>>()

     private var patternItems: Array<Object>

    private func getPatternItems(): Array<Object> {
        if (patternItems.isSome()) {
            return patternItems
        }
        patternItems = PARSED_PATTERN_CACHE.get(pattern)
        if (patternItems.isSome()) {
            return patternItems
        }
        var isPrevQuote = false
        var inQuote = false
        let text = StringBuilder()
        var itemType = Char(0)
        var itemLength = 1
        let items = ArrayList<Object>()
        var i = 0
        while (i < Int32(pattern.size)) {
            let ch = Char(pattern[Int64(i)])
            if (ch == ''') {
                if (isPrevQuote) {
                    text.append(''')
                    isPrevQuote = false
                } else {
                    isPrevQuote = true
                    if (Int32(UInt32(itemType)) != 0) {
                        items.append(SimpleDateFormat_PatternItem(itemType, itemLength))
                        itemType = Char(0)
                    }
                }
                inQuote = !inQuote
            } else {
                isPrevQuote = false
                if (inQuote) {
                    text.append(ch)
                } else {
                    if (isSyntaxChar(ch)) {
                        if (ch == itemType) {
                            itemLength++
                        } else {
                            if (Int32(UInt32(itemType)) == 0) {
                                if (Int32(text.size) > 0) {
                                    items.append(text.toString())
                                    text.setLength(0)
                                }
                            } else {
                                items.append(SimpleDateFormat_PatternItem(itemType, itemLength))
                            }
                            itemType = ch
                            itemLength = 1
                        }
                    } else {
                        if (Int32(UInt32(itemType)) != 0) {
                            items.append(SimpleDateFormat_PatternItem(itemType, itemLength))
                            itemType = Char(0)
                        }
                        text.append(ch)
                    }
                }
            }
            i++
        }
        if (Int32(UInt32(itemType)) == 0) {
            if (Int32(text.size) > 0) {
                items.append(text.toString())
                text.setLength(0)
            }
        } else {
            items.append(SimpleDateFormat_PatternItem(itemType, itemLength))
        }
        patternItems = items.toArray(size))
        PARSED_PATTERN_CACHE.put(pattern, patternItems)
        return patternItems
    }

    
    protected func zeroPaddingNumber(nf: NumberFormat, buf: StringBuffer, value: Int32, minDigits: Int32, maxDigits: Int32): Unit {
        if (useLocalZeroPaddingNumberFormat && value >= 0) {
            fastZeroPaddingNumber(buf, value, minDigits, maxDigits)
        } else {
            nf.setMinimumIntegerDigits(minDigits)
            nf.setMaximumIntegerDigits(maxDigits)
            nf.format(Int64(value), buf, FieldPosition(-1))
        }
    }

    public override func setNumberFormat(newNumberFormat: NumberFormat): Unit {
        super.setNumberFormat(newNumberFormat)
        initLocalZeroPaddingNumberFormat()
        initializeTimeZoneFormat(true)
        if (numberFormatters.isSome()) {
            numberFormatters = None
        }
        if (overrideMap.isSome()) {
            overrideMap = None
        }
    }

    private func initLocalZeroPaddingNumberFormat(): Unit {
        if (checkOptionalIs<DecimalFormat, NumberFormat>(numberFormat)) {
            let tmpDecfs = numberFormat.getDecimalFormatSymbols()
            let tmpDigits = tmpDecfs.getDigitStringsLocal()
            useLocalZeroPaddingNumberFormat = true
            decDigits = Array<Char>(10) { _ => '\u{0000}' }
            var i = 0
            while (i < 10) {
                if (Int32(tmpDigits[Int64(i)].size) > 1) {
                    useLocalZeroPaddingNumberFormat = false
                    break
                }
                decDigits[Int64(i)] = Char(tmpDigits[Int64(i)][0])
                i++
            }
        } else if (checkOptionalIs<DateNumberFormat, NumberFormat>(numberFormat)) {
            decDigits = numberFormat.getDigits()
            useLocalZeroPaddingNumberFormat = true
        } else {
            useLocalZeroPaddingNumberFormat = false
        }
        if (useLocalZeroPaddingNumberFormat) {
            decimalBuf = Array<Char>(Int64(DECIMAL_BUF_SIZE)) { _ => '\u{0000}' }
        }
    }

     private var useLocalZeroPaddingNumberFormat: Bool = false

     private var decDigits: Array<Char>

     private var decimalBuf: Array<Char>

    private static let DECIMAL_BUF_SIZE = 10

    private func fastZeroPaddingNumber(buf: StringBuffer, value: Int32, minDigits: Int32, maxDigits: Int32): Unit {
        var tempvalue = value
        let limit = if (Int32(decimalBuf.size) < maxDigits) { Int32(decimalBuf.size) } else { maxDigits }
        var index = limit - 1
        while (true) {
            decimalBuf[Int64(index)] = decDigits[(Int64(tempvalue % 10))]
            tempvalue /= 10
            if (index == 0 || tempvalue == 0) {
                break
            }
            index--
        }
        var padding = minDigits - (limit - index)
        while (padding > 0 && index > 0) {
            decimalBuf[Int64(match (0) { case _ => index--; index })] = decDigits[0]
            padding--
        }
        while (padding > 0) {
            buf.append(decDigits[0])
            padding--
        }
        buf.append(decimalBuf, index, limit - index)
    }

    protected func zeroPaddingNumber(value: Int64, minDigits: Int32, maxDigits: Int32): String {
        numberFormat.setMinimumIntegerDigits(minDigits)
        numberFormat.setMaximumIntegerDigits(maxDigits)
        return numberFormat.format(value)
    }

    private static let NUMERIC_FORMAT_CHARS = "ADdFgHhKkmrSsuWwYy"

    private static let NUMERIC_FORMAT_CHARS2 = "ceLMQq"

    static func isNumeric(formatChar: Char, count: Int32): Bool {
        return indexOfWrap(NUMERIC_FORMAT_CHARS.indexOf(UInt8(UInt32(formatChar)))) >= 0 || (count <= 2 && indexOfWrap(NUMERIC_FORMAT_CHARS2.indexOf(UInt8(UInt32(formatChar)))) >= 0)
    }

    private static let MAX_DAYLIGHT_DETECTION_RANGE = Int64(30 * 365 * 24 * 60 * 60) * 1000

    public override func parse(text: String, cal: Calendar, parsePos: ParsePosition): Unit {
        var tempcal = cal
        var backupTZ: TimeZone
        var resultCal: Calendar
        if (!refEq(tempcal, calendar) && !tempcal.getType().equals(calendar.getType())) {
            calendar.setTimeInMillis(tempcal.getTimeInMillis())
            backupTZ = calendar.getTimeZone()
            calendar.setTimeZone(tempcal.getTimeZone())
            resultCal = tempcal
            tempcal = calendar
        }
        var pos = parsePos.getIndex()
        if (pos < 0) {
            parsePos.setErrorIndex(0)
            return
        }
        let start = pos
        let dayPeriod = Output<DayPeriodRules_DayPeriod>(None)
        let tzTimeType = Output<TimeZoneFormat_TimeType>(TimeZoneFormat_TimeType.UNKNOWN)
        let ambiguousYear = [false]
        var numericFieldStart = -1
        var numericFieldLength = 0
        var numericStartPos = 0
        var numericLeapMonthFormatter: MessageFormat
        if (formatData.leapMonthPatterns.isSome() && Int32(formatData.leapMonthPatterns.size) >= DateFormatSymbols.DT_MONTH_PATTERN_COUNT) {
            numericLeapMonthFormatter = MessageFormat(formatData.leapMonthPatterns[Int64(DateFormatSymbols.DT_LEAP_MONTH_PATTERN_NUMERIC)], locale)
        }
        let items = getPatternItems()
        var i = 0
        while (i < Int32(items.size)) {
            if (checkOptionalIs<SimpleDateFormat_PatternItem, Object>(items[Int64(i)])) {
                let field = items[Int64(i)]
                if (field.isNumeric) {
                    if (numericFieldStart == -1) {
                        if ((i + 1) < Int32(items.size) && (checkOptionalIs<SimpleDateFormat_PatternItem, Object>(items[Int64(i + 1)])) && items[Int64(i + 1)].isNumeric) {
                            numericFieldStart = i
                            numericFieldLength = field.length
                            numericStartPos = pos
                        }
                    }
                }
                if (numericFieldStart != -1) {
                    var len = field.length
                    if (numericFieldStart == i) {
                        len = numericFieldLength
                    }
                    pos = subParse(text, pos, field.Type, len, true, false, ambiguousYear, tempcal, numericLeapMonthFormatter, tzTimeType)
                    if (pos < 0) {
                        numericFieldLength--
                        if (numericFieldLength == 0) {
                            parsePos.setIndex(start)
                            parsePos.setErrorIndex(pos)
                            if (backupTZ.isSome()) {
                                calendar.setTimeZone(backupTZ)
                            }
                            return
                        }
                        i = numericFieldStart
                        pos = numericStartPos
                        continue
                    }
                } else if (field.Type != 'l') {
                    numericFieldStart = -1
                    let s = pos
                    pos = subParse(text, pos, field.Type, field.length, false, true, ambiguousYear, tempcal, numericLeapMonthFormatter, tzTimeType, dayPeriod)
                    if (pos < 0) {
                        if (pos == ISOSpecialEra) {
                            pos = s
                            if (i + 1 < Int32(items.size)) {
                                var patl: String
                                try {
                                    patl = items[Int64(i + 1)]
                                } catch (cce: ClassCastException) {
                                    parsePos.setIndex(start)
                                    parsePos.setErrorIndex(s)
                                    if (backupTZ.isSome()) {
                                        calendar.setTimeZone(backupTZ)
                                    }
                                    return
                                }
                                if (patl.isNone()) {
                                    patl = items[Int64(i + 1)]
                                }
                                let plen = Int32(patl.size)
                                var idx = 0
                                while (idx < plen) {
                                    let pch = Char(patl[Int64(idx)])
                                    if (PatternProps.isWhiteSpace(Int32(UInt32(pch))) || UCharacter.isUWhiteSpace(Int32(UInt32(pch)))) {
                                        idx++
                                    } else {
                                        break
                                    }
                                }
                                if (idx == plen) {
                                    i++
                                }
                            }
                        } else {
                            parsePos.setIndex(start)
                            parsePos.setErrorIndex(s)
                            if (backupTZ.isSome()) {
                                calendar.setTimeZone(backupTZ)
                            }
                            return
                        }
                    }
                }
            } else {
                numericFieldStart = -1
                let complete = Array<Bool>(1) { _ => false }
                pos = matchLiteral(text, pos, items, i, complete)
                if (!complete[0]) {
                    parsePos.setIndex(start)
                    parsePos.setErrorIndex(pos)
                    if (backupTZ.isSome()) {
                        calendar.setTimeZone(backupTZ)
                    }
                    return
                }
            }
            i++
        }
        if (pos < Int32(text.size)) {
            let extra = Char(text[Int64(pos)])
            if (extra == '.' && getBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_WHITESPACE) && Int32(items.size) != 0) {
                let lastItem = items[Int64(Int32(items.size) - 1)]
                if (checkOptionalIs<SimpleDateFormat_PatternItem, Object>(lastItem) && !lastItem.isNumeric) {
                    pos++
                }
            }
        }
        if (dayPeriod.value.isSome()) {
            let ruleSet = DayPeriodRules.getInstance(getLocale())
            if (!tempcal.isSet(Calendar.HOUR) && !tempcal.isSet(Calendar.HOUR_OF_DAY)) {
                let midPoint = ruleSet.getMidPointForDayPeriod(dayPeriod.value)
                let midPointHour = Int32(midPoint)
                let midPointMinute = if ((midPoint - Float64(midPointHour)) > 0.0) { 30 } else { 0 }
                tempcal.set(Calendar.HOUR_OF_DAY, midPointHour)
                tempcal.set(Calendar.MINUTE, midPointMinute)
            } else {
                var hourOfDay: Int32 = 0
                if (tempcal.isSet(Calendar.HOUR_OF_DAY)) {
                    hourOfDay = tempcal.get(Calendar.HOUR_OF_DAY)
                } else {
                    hourOfDay = tempcal.get(Calendar.HOUR)
                    if (hourOfDay == 0) {
                        hourOfDay = 12
                    }
                }
                if (!(0 <= hourOfDay && hourOfDay <= 23)) {
                    throw AssertionError()
                }
                if (hourOfDay == 0 || (13 <= hourOfDay && hourOfDay <= 23)) {
                    tempcal.set(Calendar.HOUR_OF_DAY, hourOfDay)
                } else {
                    if (hourOfDay == 12) {
                        hourOfDay = 0
                    }
                    let currentHour = Float64(hourOfDay) + Float64(tempcal.get(Calendar.MINUTE)) / 60.0
                    let midPointHour = ruleSet.getMidPointForDayPeriod(dayPeriod.value)
                    let hoursAheadMidPoint = currentHour - midPointHour
                    if (-6.0 <= hoursAheadMidPoint && hoursAheadMidPoint < 6.0) {
                        tempcal.set(Calendar.AM_PM, 0)
                    } else {
                        tempcal.set(Calendar.AM_PM, 1)
                    }
                }
            }
        }
        parsePos.setIndex(pos)
        try {
            let tztype = tzTimeType.value
            if (ambiguousYear[0] || !refEq(tztype, TimeZoneFormat_TimeType.UNKNOWN)) {
                var copy: Calendar
                if (ambiguousYear[0]) {
                    copy = tempcal.clone()
                    let parsedDate = copy.getTime()
                    if (parsedDate.before(getDefaultCenturyStart())) {
                        tempcal.set(Calendar.YEAR, getDefaultCenturyStartYear() + 100)
                    }
                }
                if (!refEq(tztype, TimeZoneFormat_TimeType.UNKNOWN)) {
                    copy = tempcal.clone()
                    let tz = copy.getTimeZone()
                    var btz: BasicTimeZone
                    if (checkOptionalIs<BasicTimeZone, TimeZone>(tz)) {
                        btz = tz
                    }
                    copy.set(Calendar.ZONE_OFFSET, 0)
                    copy.set(Calendar.DST_OFFSET, 0)
                    let localMillis = copy.getTimeInMillis()
                    let offsets = Array<Int32>(2) { _ => 0 }
                    if (btz.isSome()) {
                        if (refEq(tztype, TimeZoneFormat_TimeType.STANDARD)) {
                            btz.getOffsetFromLocal(localMillis, BasicTimeZone_LocalOption.STANDARD_FORMER, BasicTimeZone_LocalOption.STANDARD_LATTER, offsets)
                        } else {
                            btz.getOffsetFromLocal(localMillis, BasicTimeZone_LocalOption.DAYLIGHT_FORMER, BasicTimeZone_LocalOption.DAYLIGHT_LATTER, offsets)
                        }
                    } else {
                        tz.getOffset(localMillis, true, offsets)
                        if (refEq(tztype, TimeZoneFormat_TimeType.STANDARD) && offsets[1] != 0 || refEq(tztype, TimeZoneFormat_TimeType.DAYLIGHT) && offsets[1] == 0) {
                            tz.getOffset(localMillis - (Int64(24 * 60 * 60 * 1000)), true, offsets)
                        }
                    }
                    var resolvedSavings = offsets[1]
                    if (refEq(tztype, TimeZoneFormat_TimeType.STANDARD)) {
                        if (offsets[1] != 0) {
                            resolvedSavings = 0
                        }
                    } else {
                        if (offsets[1] == 0) {
                            if (btz.isSome()) {
                                let baseTime = localMillis + Int64(offsets[0])
                                var time = baseTime
                                var limit = baseTime + MAX_DAYLIGHT_DETECTION_RANGE
                                var trs: TimeZoneTransition
                                while (time < limit) {
                                    trs = btz.getNextTransition(time, false)
                                    if (trs.isNone()) {
                                        break
                                    }
                                    resolvedSavings = trs.getTo().getDSTSavings()
                                    if (resolvedSavings != 0) {
                                        break
                                    }
                                    time = trs.getTime()
                                }
                                if (resolvedSavings == 0) {
                                    time = baseTime
                                    limit = baseTime - MAX_DAYLIGHT_DETECTION_RANGE
                                    while (time > limit) {
                                        trs = btz.getPreviousTransition(time, true)
                                        if (trs.isNone()) {
                                            break
                                        }
                                        resolvedSavings = trs.getFrom().getDSTSavings()
                                        if (resolvedSavings != 0) {
                                            break
                                        }
                                        time = trs.getTime() - 1
                                    }
                                    if (resolvedSavings == 0) {
                                        resolvedSavings = btz.getDSTSavings()
                                    }
                                }
                            } else {
                                resolvedSavings = tz.getDSTSavings()
                            }
                            if (resolvedSavings == 0) {
                                resolvedSavings = millisPerHour
                            }
                        }
                    }
                    tempcal.set(Calendar.ZONE_OFFSET, offsets[0])
                    tempcal.set(Calendar.DST_OFFSET, resolvedSavings)
                }
            }
        } catch (e: IllegalArgumentException) {
            parsePos.setErrorIndex(pos)
            parsePos.setIndex(start)
            if (backupTZ.isSome()) {
                calendar.setTimeZone(backupTZ)
            }
            return
        }
        if (resultCal.isSome()) {
            resultCal.setTimeZone(tempcal.getTimeZone())
            resultCal.setTimeInMillis(tempcal.getTimeInMillis())
        }
        if (backupTZ.isSome()) {
            calendar.setTimeZone(backupTZ)
        }
    }

    private func matchLiteral(text: String, pos: Int32, items: Array<Object>, itemIndex: Int32, complete: Array<Bool>): Int32 {
        var temppos = pos
        let originalPos = temppos
        let patternLiteral = items[Int64(itemIndex)]
        let plen = Int32(patternLiteral.size)
        let tlen = Int32(text.size)
        var idx = 0
        while (idx < plen && temppos < tlen) {
            let pch = Char(patternLiteral[Int64(idx)])
            let ich = Char(text[Int64(temppos)])
            if ((PatternProps.isWhiteSpace(Int32(UInt32(pch))) || UCharacter.isUWhiteSpace(Int32(UInt32(pch)))) && (PatternProps.isWhiteSpace(Int32(UInt32(ich))) || UCharacter.isUWhiteSpace(Int32(UInt32(ich))))) {
                while ((idx + 1) < plen && (PatternProps.isWhiteSpace(Int32(UInt32(Char(patternLiteral[Int64(idx + 1)])))) || UCharacter.isUWhiteSpace(Int32(UInt32(Char(patternLiteral[Int64(idx + 1)])))))) {
                    idx++
                }
                while ((temppos + 1) < tlen && (PatternProps.isWhiteSpace(Int32(UInt32(Char(text[Int64(temppos + 1)])))) || UCharacter.isUWhiteSpace(Int32(UInt32(Char(text[Int64(temppos + 1)])))))) {
                    temppos++
                }
            } else if (pch != ich) {
                if (ich == '.' && temppos == originalPos && 0 < itemIndex && getBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_WHITESPACE)) {
                    let before = items[Int64(itemIndex - 1)]
                    if (checkOptionalIs<SimpleDateFormat_PatternItem, Object>(before)) {
                        let isNumeric = before.isNumeric
                        if (!isNumeric) {
                            temppos++
                            continue
                        }
                    }
                } else if ((pch == ' ' || pch == '.') && getBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_WHITESPACE)) {
                    idx++
                    continue
                } else if (temppos != originalPos && getBoolAttribute(DateFormat_BoolAttribute.PARSE_PARTIAL_LITERAL_MATCH)) {
                    idx++
                    continue
                }
                break
            }
            idx++
            temppos++
        }
        complete[0] = idx == plen
        if (complete[0] == false && getBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_WHITESPACE) && 0 < itemIndex && itemIndex < Int32(items.size) - 1) {
            if (originalPos < tlen) {
                let before = items[Int64(itemIndex - 1)]
                let after = items[Int64(itemIndex + 1)]
                if (checkOptionalIs<SimpleDateFormat_PatternItem, Object>(before) && checkOptionalIs<SimpleDateFormat_PatternItem, Object>(after)) {
                    let beforeType = before.Type
                    let afterType = after.Type
                    if (DATE_PATTERN_TYPE.contains(Int32(UInt32(beforeType))) != DATE_PATTERN_TYPE.contains(Int32(UInt32(afterType)))) {
                        var newPos = originalPos
                        while (newPos < tlen) {
                            let ich = Char(text[Int64(newPos)])
                            if (!PatternProps.isWhiteSpace(Int32(UInt32(ich)))) {
                                break
                            }
                            newPos++
                        }
                        complete[0] = newPos > originalPos
                        temppos = newPos
                    }
                }
            }
        }
        return temppos
    }

    static let DATE_PATTERN_TYPE = UnicodeSet("[GyYuUQqMLlwWd]").freeze()

    
    private func matchAlphaMonthStrings(text: String, start: Int32, wideData: Array<String>, shortData: Array<String>, cal: Calendar): Int32 {
        var i: Int32 = 0
        var bestMatchLength = 0
        var bestMatch = -1
        i = 0
        while (i < Int32(wideData.size)) {
            let length = Int32(wideData[Int64(i)].size)
            var matchLength = 0
            if (length > bestMatchLength && (match (0) { case _ => matchLength = regionMatchesWithOptionalDot(text, start, wideData[Int64(i)], length); matchLength }) >= 0) {
                bestMatch = i
                bestMatchLength = matchLength
            }
            i++
        }
        i = 0
        while (i < Int32(shortData.size)) {
            let length = Int32(shortData[Int64(i)].size)
            var matchLength = 0
            if (length > bestMatchLength && (match (0) { case _ => matchLength = regionMatchesWithOptionalDot(text, start, shortData[Int64(i)], length); matchLength }) >= 0) {
                bestMatch = i
                bestMatchLength = matchLength
            }
            i++
        }
        if (bestMatch >= 0) {
            cal.set(Calendar.MONTH, bestMatch)
            return start + bestMatchLength
        }
        return 
    }

    protected func matchString(text: String, start: Int32, field: Int32, data: Array<String>, cal: Calendar): Int32 {
        return matchString(text, start, field, data, None, cal)
    }

    
    private func matchString(text: String, start: Int32, field: Int32, data: Array<String>, monthPattern: String, cal: Calendar): Int32 {
        var i = 0
        let count = Int32(data.size)
        if (field == Calendar.DAY_OF_WEEK) {
            i = 1
        }
        var bestMatchLength = 0
        var bestMatch = -1
        var isLeapMonth = 0
        var matchLength = 0
        while (i < count) {
            var length = Int32(data[Int64(i)].size)
            if (length > bestMatchLength && (match (0) { case _ => matchLength = regionMatchesWithOptionalDot(text, start, data[Int64(i)], length); matchLength }) >= 0) {
                bestMatch = i
                bestMatchLength = matchLength
                isLeapMonth = 0
            }
            if (monthPattern.isSome()) {
                let leapMonthName = SimpleFormatterImpl.formatRawPattern(monthPattern, 1, 1, [data[Int64(i)]])
                length = Int32(leapMonthName.size)
                if (length > bestMatchLength && (match (0) { case _ => matchLength = regionMatchesWithOptionalDot(text, start, leapMonthName, length); matchLength }) >= 0) {
                    bestMatch = i
                    bestMatchLength = matchLength
                    isLeapMonth = 1
                }
            }
            i++
        }
        if (bestMatch >= 0) {
            if (field >= 0) {
                if (field == Calendar.YEAR) {
                    bestMatch++
                }
                cal.set(field, bestMatch)
                if (monthPattern.isSome()) {
                    cal.set(Calendar.IS_LEAP_MONTH, isLeapMonth)
                }
            }
            return start + bestMatchLength
        }
        return 
    }

    private func regionMatchesWithOptionalDot(text: String, start: Int32, data: String, length: Int32): Int32 {
        let matches = text.regionMatches(true, start, data, 0, length)
        if (matches) {
            return length
        }
        if (Int32(data.size) > 0 && Char(data[Int64(Int32(data.size) - 1)]) == '.') {
            if (text.regionMatches(true, start, data, 0, length - 1)) {
                return length - 1
            }
        }
        return -1
    }

    protected func matchQuarterString(text: String, start: Int32, field: Int32, data: Array<String>, cal: Calendar): Int32 {
        var i = 0
        let count = Int32(data.size)
        var bestMatchLength = 0
        var bestMatch = -1
        var matchLength = 0
        while (i < count) {
            let length = Int32(data[Int64(i)].size)
            if (length > bestMatchLength && (match (0) { case _ => matchLength = regionMatchesWithOptionalDot(text, start, data[Int64(i)], length); matchLength }) >= 0) {
                bestMatch = i
                bestMatchLength = matchLength
            }
            i++
        }
        if (bestMatch >= 0) {
            cal.set(field, bestMatch * 3)
            return start + bestMatchLength
        }
        return -start
    }

    private func matchDayPeriodString(text: String, start: Int32, data: Array<String>, dataLength: Int32, dayPeriod: Output<DayPeriodRules_DayPeriod>): Int32 {
        var bestMatchLength = 0
        var bestMatch = -1
        var matchLength = 0
        var i = 0
        while (i < dataLength) {
            if (data[Int64(i)].isSome()) {
                let length = Int32(data[Int64(i)].size)
                if (length > bestMatchLength && (match (0) { case _ => matchLength = regionMatchesWithOptionalDot(text, start, data[Int64(i)], length); matchLength }) >= 0) {
                    bestMatch = i
                    bestMatchLength = matchLength
                }
            }
            i++
        }
        if (bestMatch >= 0) {
            dayPeriod.value = DayPeriodRules_DayPeriod.VALUES[Int64(bestMatch)]
            return start + bestMatchLength
        }
        return -start
    }

    protected func subParse(text: String, start: Int32, ch: Char, count: Int32, obeyCount: Bool, allowNegative: Bool, ambiguousYear: Array<Bool>, cal: Calendar): Int32 {
        return subParse(text, start, ch, count, obeyCount, allowNegative, ambiguousYear, cal, None, None)
    }

    private func subParse(text: String, start: Int32, ch: Char, count: Int32, obeyCount: Bool, allowNegative: Bool, ambiguousYear: Array<Bool>, cal: Calendar, numericLeapMonthFormatter: MessageFormat, tzTimeType: Output<TimeZoneFormat_TimeType>): Int32 {
        return subParse(text, start, ch, count, obeyCount, allowNegative, ambiguousYear, cal, None, None, None)
    }

    
    private func subParse(text: String, start: Int32, ch: Char, count: Int32, obeyCount: Bool, allowNegative: Bool, ambiguousYear: Array<Bool>, cal: Calendar, numericLeapMonthFormatter: MessageFormat, tzTimeType: Output<TimeZoneFormat_TimeType>, dayPeriod: Output<DayPeriodRules_DayPeriod>): Int32 {
        var tempstart = start
        var number: Number = None
        var currentNumberFormat: NumberFormat
        var value = 0
        var i: Int32 = 0
        let pos = ParsePosition(0)
        let patternCharIndex = getIndexFromChar(ch)
        if (patternCharIndex == -1) {
            return 
        }
        currentNumberFormat = getNumberFormat(ch)
        let field = PATTERN_INDEX_TO_CALENDAR_FIELD[Int64(patternCharIndex)]
        if (numericLeapMonthFormatter.isSome()) {
            numericLeapMonthFormatter.setFormatByArgumentIndex(0, currentNumberFormat)
        }
        let isChineseCalendar = (cal.getType() == "chinese" || cal.getType() == "dangi")
        while (true) {
            if (tempstart >= Int32(text.size)) {
                return 
            }
            let c = UTF16.toRuneArray()[text, tempstart]
            if (!UCharacter.isUWhiteSpace(c) && !PatternProps.isWhiteSpace(c)) {
                break
            }
            tempstart += UTF16.getCharCount(c)
        }
        pos.setIndex(tempstart)
        if (patternCharIndex == 4 || patternCharIndex == 15 || (patternCharIndex == 2 && count <= 2) || patternCharIndex == 26 || patternCharIndex == 19 || patternCharIndex == 25 || patternCharIndex == 1 || patternCharIndex == 18 || patternCharIndex == 30 || (patternCharIndex == 0 && isChineseCalendar) || patternCharIndex == 27 || patternCharIndex == 28 || patternCharIndex == 8) {
            var parsedNumericLeapMonth = false
            if (numericLeapMonthFormatter.isSome() && (patternCharIndex == 2 || patternCharIndex == 26)) {
                let args = numericLeapMonthFormatter.parse(text, pos)
                if (args.isSome() && pos.getIndex() > tempstart && (checkOptionalIs<Number, Object>(args[0]))) {
                    parsedNumericLeapMonth = true
                    number = args[0]
                    cal.set(Calendar.IS_LEAP_MONTH, 1)
                } else {
                    pos.setIndex(tempstart)
                    cal.set(Calendar.IS_LEAP_MONTH, 0)
                }
            }
            if (!parsedNumericLeapMonth) {
                if (obeyCount) {
                    if ((tempstart + count) > Int32(text.size)) {
                        return 
                    }
                    number = parseInt(text, count, pos, allowNegative, currentNumberFormat)
                } else {
                    number = parseInt(text, pos, allowNegative, currentNumberFormat)
                }
                if (number.isNone() && !allowNumericFallback(patternCharIndex)) {
                    return 
                }
            }
            if (number.isSome()) {
                value = number.intValue()
            }
        }
        match (patternCharIndex) {
            case 0 =>
                if (isChineseCalendar) {
                    cal.set(Calendar.ERA, value)
                    return pos.getIndex()
                }
                var ps = 0
                if (count == 5) {
                    ps = matchString(text, tempstart, Calendar.ERA, formatData.narrowEras, None, cal)
                } else if (count == 4) {
                    ps = matchString(text, tempstart, Calendar.ERA, formatData.eraNames, None, cal)
                } else {
                    ps = matchString(text, tempstart, Calendar.ERA, formatData.eras, None, cal)
                }
                if (ps == ) {
                    ps = ISOSpecialEra
                }
                return ps
            case 1 | 18 =>
                if (override.isSome() && (override.compare("hebr").value() == 0 || indexOfWrap(override.indexOf("y=hebr")) >= 0) && value < 1000) {
                    value += HEBREW_CAL_CUR_MILLENIUM_START_YEAR
                } else if (count == 2 && countDigits(text, tempstart, pos.getIndex()) == 2 && cal.haveDefaultCentury()) {
                    let ambiguousTwoDigitYear = getDefaultCenturyStartYear() % 100
                    ambiguousYear[0] = value == ambiguousTwoDigitYear
                    value += (getDefaultCenturyStartYear() / 100) * 100 + (if (value < ambiguousTwoDigitYear) { 100 } else { 0 })
                }
                cal.set(field, value)
                if (DelayedHebrewMonthCheck) {
                    if (!HebrewCalendar.isLeapYear(value)) {
                        cal.add(Calendar.MONTH, 1)
                    }
                    DelayedHebrewMonthCheck = false
                }
                return pos.getIndex()
            case 30 =>
                if (formatData.shortYearNames.isSome()) {
                    let newStart = matchString(text, tempstart, Calendar.YEAR, formatData.shortYearNames, None, cal)
                    if (newStart > 0) {
                        return newStart
                    }
                }
                if (number.isSome() && (getBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_NUMERIC) || formatData.shortYearNames.isNone() || value > Int32(formatData.shortYearNames.size))) {
                    cal.set(Calendar.YEAR, value)
                    return pos.getIndex()
                }
                return 
            case 2 | 26 => if (count <= 2 || (number.isSome() && getBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_NUMERIC))) {
                cal.set(Calendar.MONTH, value - 1)
                if (cal.getType() == "hebrew" && value >= 6) {
                    if (cal.isSet(Calendar.YEAR)) {
                        if (!HebrewCalendar.isLeapYear(cal.get(Calendar.YEAR))) {
                            cal.set(Calendar.MONTH, value)
                        }
                    } else {
                        DelayedHebrewMonthCheck = true
                    }
                }
                return pos.getIndex()
            } else {
                let haveMonthPat = (formatData.leapMonthPatterns.isSome() && Int32(formatData.leapMonthPatterns.size) >= DateFormatSymbols.DT_MONTH_PATTERN_COUNT)
                var newStart = 0
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) && count >= 3 && count <= 4 && !haveMonthPat) {
                    newStart = if (patternCharIndex == 2) { matchAlphaMonthStrings(text, tempstart, formatData.months, formatData.shortMonths, cal) } else { matchAlphaMonthStrings(text, tempstart, formatData.standaloneMonths, formatData.standaloneShortMonths, cal) }
                    if (newStart > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 4) {
                    newStart = if (patternCharIndex == 2) { matchString(text, tempstart, Calendar.MONTH, formatData.months, if (haveMonthPat) { formatData.leapMonthPatterns[Int64(DateFormatSymbols.DT_LEAP_MONTH_PATTERN_FORMAT_WIDE)] } else { None }, cal) } else { matchString(text, tempstart, Calendar.MONTH, formatData.standaloneMonths, if (haveMonthPat) { formatData.leapMonthPatterns[Int64(DateFormatSymbols.DT_LEAP_MONTH_PATTERN_STANDALONE_WIDE)] } else { None }, cal) }
                    if (newStart > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 3) {
                    return if (patternCharIndex == 2) { matchString(text, tempstart, Calendar.MONTH, formatData.shortMonths, if (haveMonthPat) { formatData.leapMonthPatterns[Int64(DateFormatSymbols.DT_LEAP_MONTH_PATTERN_FORMAT_ABBREV)] } else { None }, cal) } else { matchString(text, tempstart, Calendar.MONTH, formatData.standaloneShortMonths, if (haveMonthPat) { formatData.leapMonthPatterns[Int64(DateFormatSymbols.DT_LEAP_MONTH_PATTERN_STANDALONE_ABBREV)] } else { None }, cal) }
                }
                return newStart
            }
            case 4 =>
                if (value == cal.getMaximum(Calendar.HOUR_OF_DAY) + 1) {
                    value = 0
                }
                cal.set(Calendar.HOUR_OF_DAY, value)
                return pos.getIndex()
            case 8 =>
                i = countDigits(text, tempstart, pos.getIndex())
                if (i < 3) {
                    while (i < 3) {
                        value *= 10
                        i++
                    }
                } else {
                    var a = 1
                    while (i > 3) {
                        a *= 10
                        i--
                    }
                    value /= a
                }
                cal.set(Calendar.MILLISECOND, value)
                return pos.getIndex()
            case 19 => if (count <= 2 || (number.isSome() && (getBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_NUMERIC)))) {
                cal.set(field, value)
                return pos.getIndex()
            }
            case 9 =>
                var newStart = 0
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 4) {
                    if ((match (0) { case _ => newStart = matchString(text, tempstart, Calendar.DAY_OF_WEEK, formatData.weekdays, None, cal); newStart }) > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 3) {
                    if ((match (0) { case _ => newStart = matchString(text, tempstart, Calendar.DAY_OF_WEEK, formatData.shortWeekdays, None, cal); newStart }) > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 6) {
                    if (formatData.shorterWeekdays.isSome()) {
                        if ((match (0) { case _ => newStart = matchString(text, tempstart, Calendar.DAY_OF_WEEK, formatData.shorterWeekdays, None, cal); newStart }) > 0) {
                            return newStart
                        }
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 5) {
                    if (formatData.narrowWeekdays.isSome()) {
                        if ((match (0) { case _ => newStart = matchString(text, tempstart, Calendar.DAY_OF_WEEK, formatData.narrowWeekdays, None, cal); newStart }) > 0) {
                            return newStart
                        }
                    }
                }
                return newStart
            case 25 =>
                if (count == 1 || (number.isSome() && (getBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_NUMERIC)))) {
                    cal.set(field, value)
                    return pos.getIndex()
                }
                var newStart = 0
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 4) {
                    if ((match (0) { case _ => newStart = matchString(text, tempstart, Calendar.DAY_OF_WEEK, formatData.standaloneWeekdays, None, cal); newStart }) > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 3) {
                    if ((match (0) { case _ => newStart = matchString(text, tempstart, Calendar.DAY_OF_WEEK, formatData.standaloneShortWeekdays, None, cal); newStart }) > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 6) {
                    if (formatData.standaloneShorterWeekdays.isSome()) {
                        return matchString(text, tempstart, Calendar.DAY_OF_WEEK, formatData.standaloneShorterWeekdays, None, cal)
                    }
                }
                return newStart
            case 14 =>
                var newStart = 0
                if (formatData.ampmsNarrow.isNone() || count < 5 || getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH)) {
                    if ((match (0) { case _ => newStart = matchString(text, tempstart, Calendar.AM_PM, formatData.ampms, None, cal); newStart }) > 0) {
                        return newStart
                    }
                }
                if (formatData.ampmsNarrow.isSome() && (count >= 5 || getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH))) {
                    if ((match (0) { case _ => newStart = matchString(text, tempstart, Calendar.AM_PM, formatData.ampmsNarrow, None, cal); newStart }) > 0) {
                        return newStart
                    }
                }
                return 
            case 15 =>
                if (value == cal.getLeastMaximum(Calendar.HOUR) + 1) {
                    value = 0
                }
                cal.set(Calendar.HOUR, value)
                return pos.getIndex()
            case 17 =>
                let style: TimeZoneFormat_Style = if (count < 4) { TimeZoneFormat_Style.SPECIFIC_SHORT } else { TimeZoneFormat_Style.SPECIFIC_LONG }
                let tz = tzFormatMethod().parse(style, text, pos, tzTimeType)
                if (tz.isSome()) {
                    cal.setTimeZone(tz)
                    return pos.getIndex()
                }
                return 
            case 23 =>
                let style = if (count < 4) { Some(TimeZoneFormat_Style.ISO_BASIC_LOCAL_FULL) } else { (if (count == 5) { Some(TimeZoneFormat_Style.ISO_EXTENDED_FULL) } else { Some(TimeZoneFormat_Style.LOCALIZED_GMT) }) }
                let tz = tzFormatMethod().parse(style, text, pos, tzTimeType)
                if (tz.isSome()) {
                    cal.setTimeZone(tz)
                    return pos.getIndex()
                }
                return 
            case 24 =>
                let style: TimeZoneFormat_Style = if (count < 4) { TimeZoneFormat_Style.GENERIC_SHORT } else { TimeZoneFormat_Style.GENERIC_LONG }
                let tz = tzFormatMethod().parse(style, text, pos, tzTimeType)
                if (tz.isSome()) {
                    cal.setTimeZone(tz)
                    return pos.getIndex()
                }
                return 
            case 29 =>
                var style: TimeZoneFormat_Style
                match (count) {
                    case 1 => style = TimeZoneFormat_Style.ZONE_ID_SHORT
                    case 2 => style = TimeZoneFormat_Style.ZONE_ID
                    case 3 => style = TimeZoneFormat_Style.EXEMPLAR_LOCATION
                    case _ => style = TimeZoneFormat_Style.GENERIC_LOCATION
                }
                let tz = tzFormatMethod().parse(style, text, pos, tzTimeType)
                if (tz.isSome()) {
                    cal.setTimeZone(tz)
                    return pos.getIndex()
                }
                return 
            case 31 =>
                let style: TimeZoneFormat_Style = if (count < 4) { TimeZoneFormat_Style.LOCALIZED_GMT_SHORT } else { TimeZoneFormat_Style.LOCALIZED_GMT }
                let tz = tzFormatMethod().parse(style, text, pos, tzTimeType)
                if (tz.isSome()) {
                    cal.setTimeZone(tz)
                    return pos.getIndex()
                }
                return 
            case 32 =>
                let style: TimeZoneFormat_Style
                match (count) {
                    case 1 => style = TimeZoneFormat_Style.ISO_BASIC_SHORT
                    case 2 => style = TimeZoneFormat_Style.ISO_BASIC_FIXED
                    case 3 => style = TimeZoneFormat_Style.ISO_EXTENDED_FIXED
                    case 4 => style = TimeZoneFormat_Style.ISO_BASIC_FULL
                    case _ => style = TimeZoneFormat_Style.ISO_EXTENDED_FULL
                }
                let tz = tzFormatMethod().parse(style, text, pos, tzTimeType)
                if (tz.isSome()) {
                    cal.setTimeZone(tz)
                    return pos.getIndex()
                }
                return 
            case 33 =>
                let style: TimeZoneFormat_Style
                match (count) {
                    case 1 => style = TimeZoneFormat_Style.ISO_BASIC_LOCAL_SHORT
                    case 2 => style = TimeZoneFormat_Style.ISO_BASIC_LOCAL_FIXED
                    case 3 => style = TimeZoneFormat_Style.ISO_EXTENDED_LOCAL_FIXED
                    case 4 => style = TimeZoneFormat_Style.ISO_BASIC_LOCAL_FULL
                    case _ => style = TimeZoneFormat_Style.ISO_EXTENDED_LOCAL_FULL
                }
                let tz = tzFormatMethod().parse(style, text, pos, tzTimeType)
                if (tz.isSome()) {
                    cal.setTimeZone(tz)
                    return pos.getIndex()
                }
                return 
            case 27 => if (count <= 2 && number.isSome()) {
                cal.set(Calendar.MONTH, (value - 1) * 3)
                return pos.getIndex()
            } else {
                var newStart = 0
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 4) {
                    if ((match (0) { case _ => newStart = matchQuarterString(text, tempstart, Calendar.MONTH, formatData.quarters, cal); newStart }) > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 3) {
                    if ((match (0) { case _ => newStart = matchQuarterString(text, tempstart, Calendar.MONTH, formatData.shortQuarters, cal); newStart }) > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 5) {
                    if ((match (0) { case _ => newStart = matchQuarterString(text, tempstart, Calendar.MONTH, formatData.narrowQuarters, cal); newStart }) > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_NUMERIC) && number.isSome()) {
                    cal.set(Calendar.MONTH, (value - 1) * 3)
                    return pos.getIndex()
                }
                return newStart
            }
            case 28 => if (count <= 2 && number.isSome()) {
                cal.set(Calendar.MONTH, (value - 1) * 3)
                return pos.getIndex()
            } else {
                var newStart = 0
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 4) {
                    if ((match (0) { case _ => newStart = matchQuarterString(text, tempstart, Calendar.MONTH, formatData.standaloneQuarters, cal); newStart }) > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 3) {
                    if ((match (0) { case _ => newStart = matchQuarterString(text, tempstart, Calendar.MONTH, formatData.standaloneShortQuarters, cal); newStart }) > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 5) {
                    if ((match (0) { case _ => newStart = matchQuarterString(text, tempstart, Calendar.MONTH, formatData.standaloneNarrowQuarters, cal); newStart }) > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_ALLOW_NUMERIC) && number.isSome()) {
                    cal.set(Calendar.MONTH, (value - 1) * 3)
                    return pos.getIndex()
                }
                return newStart
            }
            case 37 =>
                let data = ArrayList<String>(3)
                data.append(formatData.getTimeSeparatorString())
                if (!formatData.getTimeSeparatorString().equals(DateFormatSymbols.DEFAULT_TIME_SEPARATOR)) {
                    data.append(DateFormatSymbols.DEFAULT_TIME_SEPARATOR)
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_PARTIAL_LITERAL_MATCH) && !formatData.getTimeSeparatorString().equals(DateFormatSymbols.ALTERNATE_TIME_SEPARATOR)) {
                    data.append(DateFormatSymbols.ALTERNATE_TIME_SEPARATOR)
                }
                return matchString(text, tempstart, -1, data.toArray(Array<String>(0)), cal)
            case 35 =>
                let ampmStart = subParse(text, tempstart, 'a', count, obeyCount, allowNegative, ambiguousYear, cal, numericLeapMonthFormatter, tzTimeType, dayPeriod)
                if (ampmStart > 0) {
                    return ampmStart
                } else {
                    var newStart = 0
                    if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 3) {
                        if ((match (0) { case _ => newStart = matchDayPeriodString(text, tempstart, formatData.abbreviatedDayPeriods, 2, dayPeriod); newStart }) > 0) {
                            return newStart
                        }
                    }
                    if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 4) {
                        if ((match (0) { case _ => newStart = matchDayPeriodString(text, tempstart, formatData.wideDayPeriods, 2, dayPeriod); newStart }) > 0) {
                            return newStart
                        }
                    }
                    if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 4) {
                        if ((match (0) { case _ => newStart = matchDayPeriodString(text, tempstart, formatData.narrowDayPeriods, 2, dayPeriod); newStart }) > 0) {
                            return newStart
                        }
                    }
                    return newStart
                }
            case 36 =>
                var newStart = 0
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 3) {
                    if ((match (0) { case _ => newStart = matchDayPeriodString(text, tempstart, formatData.abbreviatedDayPeriods, Int32(formatData.abbreviatedDayPeriods.size), dayPeriod); newStart }) > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 4) {
                    if ((match (0) { case _ => newStart = matchDayPeriodString(text, tempstart, formatData.wideDayPeriods, Int32(formatData.wideDayPeriods.size), dayPeriod); newStart }) > 0) {
                        return newStart
                    }
                }
                if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_MULTIPLE_PATTERNS_FOR_MATCH) || count == 4) {
                    if ((match (0) { case _ => newStart = matchDayPeriodString(text, tempstart, formatData.narrowDayPeriods, Int32(formatData.narrowDayPeriods.size), dayPeriod); newStart }) > 0) {
                        return newStart
                    }
                }
                return newStart
            case _ =>
                if (obeyCount) {
                    if ((tempstart + count) > Int32(text.size)) {
                        return -tempstart
                    }
                    number = parseInt(text, count, pos, allowNegative, currentNumberFormat)
                } else {
                    number = parseInt(text, pos, allowNegative, currentNumberFormat)
                }
                if (obeyCount && !isLenient() && pos.getIndex() < tempstart + count) {
                    return -tempstart
                }
                if (number.isSome()) {
                    if (patternCharIndex != DateFormat.RELATED_YEAR) {
                        cal.set(field, number.intValue())
                    } else {
                        cal.setRelatedYear(number.intValue())
                    }
                    return pos.getIndex()
                }
                return 
        }
    }

    private func allowNumericFallback(patternCharIndex: Int32): Bool {
        if (patternCharIndex == 26 || patternCharIndex == 19 || patternCharIndex == 25 || patternCharIndex == 30 || patternCharIndex == 27 || patternCharIndex == 28) {
            return true
        }
        return false
    }

    private func parseInt(text: String, pos: ParsePosition, allowNegative: Bool, fmt: NumberFormat): Number {
        return parseInt(text, -1, pos, allowNegative, fmt)
    }

    private func parseInt(text: String, maxDigits: Int32, pos: ParsePosition, allowNegative: Bool, fmt: NumberFormat): Number {
        var number: Number = None
        let oldPos = pos.getIndex()
        if (allowNegative) {
            number = fmt.parse(text, pos)
        } else {
            if (checkOptionalIs<DecimalFormat, NumberFormat>(fmt)) {
                let oldPrefix = fmt.getNegativePrefix()
                fmt.setNegativePrefix(SUPPRESS_NEGATIVE_PREFIX)
                number = fmt.parse(text, pos)
                fmt.setNegativePrefix(oldPrefix)
            } else {
                let dateNumberFormat = (checkOptionalIs<DateNumberFormat, NumberFormat>(fmt))
                if (dateNumberFormat) {
                    fmt.setParsePositiveOnly(true)
                }
                number = fmt.parse(text, pos)
                if (dateNumberFormat) {
                    fmt.setParsePositiveOnly(false)
                }
            }
        }
        if (maxDigits > 0) {
            var nDigits = pos.getIndex() - oldPos
            if (nDigits > maxDigits) {
                var val = number.doubleValue()
                nDigits -= maxDigits
                while (nDigits > 0) {
                    val /= 10.0
                    nDigits--
                }
                pos.setIndex(oldPos + maxDigits)
                number = Int32(val)
            }
        }
        return number
    }

    private static func countDigits(text: String, start: Int32, end: Int32): Int32 {
        var numDigits = 0
        var idx = start
        while (idx < end) {
            let cp = text.codePointAt(idx)
            if (UCharacter.isDigit(cp)) {
                numDigits++
            }
            idx += UCharacter.charCount(cp)
        }
        return numDigits
    }

    private func translatePattern(pat: String, comefrom: String, to: String): String {
        let result = StringBuilder()
        var inQuote = false
        var i = 0
        while (i < Int32(pat.size)) {
            var c = Char(pat[Int64(i)])
            if (inQuote) {
                if (c == ''') {
                    inQuote = false
                }
            } else {
                if (c == ''') {
                    inQuote = true
                } else if (isSyntaxChar(c)) {
                    let ci = indexOfWrap(comefrom.indexOf(UInt8(UInt32(c))))
                    if (ci != -1) {
                        c = Char(to[Int64(ci)])
                    }
                }
            }
            result.append(c)
            i++
        }
        if (inQuote) {
            throw IllegalArgumentException("Unfinished quote in pattern")
        }
        return result.toString()
    }

    public func toPattern(): String {
        return pattern
    }

    public func toLocalizedPattern(): String {
        return translatePattern(pattern, DateFormatSymbols.patternChars, formatData.localPatternChars)
    }

    public func applyPattern(pat: String): Unit {
        this.pattern = pat
        parsePattern()
        setLocale(None, None)
        patternItems = None
        if (calendar.isSome() && calendar.getType() == "japanese" && locale.isSome() && locale.getLanguage() == "ja") {
            if (override.isSome() && override == "y=jpanyear" && !hasHanYearChar) {
                numberFormatters = None
                overrideMap = None
                override = None
            } else if (override.isNone() && hasHanYearChar) {
                numberFormatters = HashMap<String, NumberFormat>()
                overrideMap = HashMap<Character, String>()
                overrideMap.put(Character.valueOf('y'), "jpanyear")
                let ovrLoc = ULocale((locale.getBaseName()) + "@numbers=jpanyear")
                let nf = NumberFormat.createInstance(ovrLoc, NumberFormat.NUMBERSTYLE)
                nf.setGroupingUsed(false)
                useLocalZeroPaddingNumberFormat = false
                numberFormatters.put("jpanyear", nf)
                override = "y=jpanyear"
            }
        }
    }

    public func applyLocalizedPattern(pat: String): Unit {
        this.pattern = translatePattern(pat, formatData.localPatternChars, DateFormatSymbols.patternChars)
        setLocale(None, None)
    }

    public func getDateFormatSymbols(): DateFormatSymbols {
        return formatData.clone()
    }

    public func setDateFormatSymbols(newFormatSymbols: DateFormatSymbols): Unit {
        this.formatData = newFormatSymbols.clone()
    }

    protected func getSymbols(): DateFormatSymbols {
        return formatData
    }

    public func getTimeZoneFormat(): TimeZoneFormat {
        return tzFormatMethod().freeze()
    }

    public func setTimeZoneFormat(tzfmt: TimeZoneFormat): Unit {
        if (tzfmt.isFrozen()) {
            tzFormat = tzfmt
        } else {
            tzFormat = tzfmt.cloneAsThawed().freeze()
        }
    }

    public override func clone(): Object {
        let other = super.clone()
        other.formatData = formatData.clone()
        if (this.decimalBuf.isSome()) {
            other.decimalBuf = Array<Char>(Int64(DECIMAL_BUF_SIZE)) { _ => '\u{0000}' }
        }
        return other
    }

    public override func hashCode(): Int64 {
        return pattern.hashCode()
    }

    public override func equals(obj: Object): Bool {
        if (!super.equals(obj)) {
            return false
        }
        let that = obj
        return (pattern.equals(that.pattern) && formatData.equals(that.formatData))
    }

    private func writeObject(stream: ObjectOutputStream): Unit {
        if (defaultCenturyStart.isNone()) {
            initializeDefaultCenturyStart(defaultCenturyBase)
        }
        initializeTimeZoneFormat(false)
        stream.defaultWriteObject()
        stream.writeInt(getContext(DisplayContext_Type.CAPITALIZATION).valueMethod())
    }

    private func readObject(stream: ObjectInputStream): Unit {
        stream.defaultReadObject()
        let capitalizationSettingValue = if (serialVersionOnStream > 1) { stream.readInt() } else { -1 }
        if (serialVersionOnStream < 1) {
            defaultCenturyBase = DateTime.now().toUnixTimeStamp().toMilliseconds()
        } else {
            parseAmbiguousDatesAsAfter(defaultCenturyStart)
        }
        serialVersionOnStream = currentSerialVersion
        locale = getLocale(ULocale.VALID_LOCALE)
        if (locale.isNone()) {
            locale = ULocale.getDefault(ULocale_Category.FORMAT)
        }
        initLocalZeroPaddingNumberFormat()
        setContext(DisplayContext.CAPITALIZATION_NONE)
        if (capitalizationSettingValue >= 0) {
            for (context in DisplayContext.values()) {
                if (context.valueMethod() == capitalizationSettingValue) {
                    setContext(context)
                    break
                }
            }
        }
        if (getBoolAttribute(DateFormat_BoolAttribute.PARSE_PARTIAL_MATCH) == false) {
            setBoolAttribute(DateFormat_BoolAttribute.PARSE_PARTIAL_LITERAL_MATCH, false)
        }
        parsePattern()
    }

    public override func formatToCharacterIterator(obj: Object): AttributedCharacterIterator {
        var cal = calendar
        if (checkOptionalIs<Calendar, Object>(obj)) {
            cal = obj
        } else if (checkOptionalIs<Date, Object>(obj)) {
            calendar.setTime(obj)
        } else if (checkOptionalIs<Number, Object>(obj)) {
            calendar.setTimeInMillis(obj.longValue())
        } else {
            throw IllegalArgumentException("Cannot format given Object as a Date")
        }
        let toAppendTo = StringBuffer()
        let pos = FieldPosition(0)
        let attributes = ArrayList<FieldPosition>()
        format(cal, getContext(DisplayContext_Type.CAPITALIZATION), toAppendTo, pos, attributes)
        let `as` = AttributedString(toString(toAppendTo))
        var i = 0
        while (i < Int32(attributes.size)) {
            let fp = attributes[Int64(i)]
            let attribute = fp.getFieldAttribute()
            `as`.addAttribute(attribute, attribute, fp.getBeginIndex(), fp.getEndIndex())
            i++
        }
        return `as`.getIterator()
    }

    public func getLocale(): ULocale {
        return locale
    }

    public func isFieldUnitIgnored(field: Int32): Bool {
        return isFieldUnitIgnoredStatic(pattern, field)
    }

    static func isFieldUnitIgnoredStatic(pattern: String, field: Int32): Bool {
        let fieldLevel = CALENDAR_FIELD_TO_LEVEL[Int64(field)]
        var level: Int32 = 0
        var ch: Char = '\u{0000}'
        var inQuote = false
        var prevCh = Char(0)
        var count = 0
        var i = 0
        while (i < Int32(pattern.size)) {
            ch = Char(pattern[Int64(i)])
            if (ch != prevCh && count > 0) {
                level = getLevelFromChar(prevCh)
                if (fieldLevel <= level) {
                    return false
                }
                count = 0
            }
            if (ch == ''') {
                if ((i + 1) < Int32(pattern.size) && Char(pattern[Int64(i + 1)]) == ''') {
                    i++
                } else {
                    inQuote = !inQuote
                }
            } else if (!inQuote && isSyntaxChar(ch)) {
                prevCh = ch
                count++
            }
            i++
        }
        if (count > 0) {
            level = getLevelFromChar(prevCh)
            if (fieldLevel <= level) {
                return false
            }
        }
        return true
    }

    
    public func intervalFormatByAlgorithm(fromCalendar: Calendar, toCalendar: Calendar, appendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        if (!fromCalendar.isEquivalentTo(toCalendar)) {
            throw IllegalArgumentException("can not format on two different calendars")
        }
        let items = getPatternItems()
        var diffBegin = -1
        var diffEnd = -1
        try {
                    i++
                }
            } while (false)
            if (diffBegin == -1) {
                return format(fromCalendar, appendTo, pos)
            }
                    i--
                }
            } while (false)
        } catch (e: IllegalArgumentException) {
            throw IllegalArgumentException(e.toString())
        }
        if (diffBegin == 0 && diffEnd == Int32(items.size) - 1) {
            format(fromCalendar, appendTo, pos)
            appendTo.append(" \u{2013} ")
            format(toCalendar, appendTo, pos)
            return appendTo
        }
        var highestLevel = 1000
                let item = items[Int64(i)]
                let ch = item.Type
                let patternCharIndex = getIndexFromChar(ch)
                if (patternCharIndex == -1) {
                    throw IllegalArgumentException("Illegal pattern character '" + ch.toString() + "' in \"" + (pattern) + '\"'.toString())
                }
                if (patternCharIndex < highestLevel) {
                    highestLevel = patternCharIndex
                }
                i++
            }
        } while (false)
        try {
                    i++
                }
            } while (false)
                    i--
                }
            } while (false)
        } catch (e: IllegalArgumentException) {
            throw IllegalArgumentException(e.toString())
        }
        if (diffBegin == 0 && diffEnd == Int32(items.size) - 1) {
            format(fromCalendar, appendTo, pos)
            appendTo.append(" \u{2013} ")
            format(toCalendar, appendTo, pos)
            return appendTo
        }
        pos.setBeginIndex(0)
        pos.setEndIndex(0)
        let capSetting = getContext(DisplayContext_Type.CAPITALIZATION)
                    let item = items[Int64(i)]
                    if (useFastFormat) {
                        subFormat(appendTo, item.Type, item.length, Int32(appendTo.size), i, capSetting, pos, item.Type, fromCalendar)
                    } else {
                        appendTo.append(subFormat(item.Type, item.length, Int32(appendTo.size), i, capSetting, pos, item.Type, fromCalendar))
                    }
                }
                i++
            }
        } while (false)
        appendTo.append(" \u{2013} ")
                    let item = items[Int64(i)]
                    if (useFastFormat) {
                        subFormat(appendTo, item.Type, item.length, Int32(appendTo.size), i, capSetting, pos, item.Type, toCalendar)
                    } else {
                        appendTo.append(subFormat(item.Type, item.length, Int32(appendTo.size), i, capSetting, pos, item.Type, toCalendar))
                    }
                }
                i++
            }
        } while (false)
        return appendTo
    }

    private func diffCalFieldValue(fromCalendar: Calendar, toCalendar: Calendar, items: Array<Object>, i: Int32): Bool {
        if (items[Int64(i)]) {
            return false
        }
        let item = items[Int64(i)]
        let ch = item.Type
        let patternCharIndex = getIndexFromChar(ch)
        if (patternCharIndex == -1) {
            throw IllegalArgumentException("Illegal pattern character '" + ch.toString() + "' in \"" + (pattern) + '\"'.toString())
        }
        let field = PATTERN_INDEX_TO_CALENDAR_FIELD[Int64(patternCharIndex)]
        if (field >= 0) {
            let value = fromCalendar.get(field)
            let value_2 = toCalendar.get(field)
            if (value != value_2) {
                return true
            }
        }
        return false
    }

    private func lowerLevel(items: Array<Object>, i: Int32, level: Int32): Bool {
        if (items[Int64(i)]) {
            return false
        }
        let item = items[Int64(i)]
        let ch = item.Type
        let patternCharIndex = getLevelFromChar(ch)
        if (patternCharIndex == -1) {
            throw IllegalArgumentException("Illegal pattern character '" + ch.toString() + "' in \"" + (pattern) + '\"'.toString())
        }
        if (patternCharIndex >= level) {
            return true
        }
        return false
    }

    public func setNumberFormat(fields: String, overrideNF: NumberFormat): Unit {
        overrideNF.setGroupingUsed(false)
        let nsName: String = "$" + toString(UUID.randomUUID())
        if (numberFormatters.isNone()) {
            numberFormatters = HashMap<String, NumberFormat>()
        }
        if (overrideMap.isNone()) {
            overrideMap = HashMap<Character, String>()
        }
        var i = 0
        while (i < Int32(fields.size)) {
            let field = Char(fields[Int64(i)])
            if (indexOfWrap(DateFormatSymbols.patternChars.indexOf(UInt8(UInt32(field)))) == -1) {
                throw IllegalArgumentException("Illegal field character '" + field.toString() + "' in setNumberFormat.")
            }
            overrideMap.put(Character.valueOf(field), nsName)
            numberFormatters.put(nsName, overrideNF)
            i++
        }
        useLocalZeroPaddingNumberFormat = false
    }

    public func getNumberFormat(field: Char): NumberFormat {
        let ovrField = Character.valueOf(field)
        if (overrideMap.isSome() && overrideMap.contains(ovrField)) {
            let nsName: String = toString(overrideMap.get(ovrField))
            let nf = numberFormatters.get(nsName)
            return nf
        } else {
            return numberFormat
        }
    }

    private func initNumberFormatters(loc: ULocale): Unit {
        numberFormatters = HashMap<String, NumberFormat>()
        overrideMap = HashMap<Character, String>()
        processOverrideString(loc, override)
    }

    private func processOverrideString(loc: ULocale, str: String): Unit {
        if (str.isNone() || Int32(str.size) == 0) {
            return
        }
        var start = 0
        var end: Int32 = 0
        var nsName: String
        var ovrField: Character = None
        var moreToProcess = true
        var fullOverride: Bool = false
        while (moreToProcess) {
            let delimiterPosition = indexOfWrap(str.indexOf(";", Int64(start)))
            if (delimiterPosition == -1) {
                moreToProcess = false
                end = Int32(str.size)
            } else {
                end = delimiterPosition
            }
            let currentString: String = str[Int64(start)..Int64(end)]
            let equalSignPosition = indexOfWrap(currentString.indexOf("="))
            if (equalSignPosition == -1) {
                nsName = currentString
                fullOverride = true
            } else {
                nsName = currentString[Int64(equalSignPosition + 1)..]
                ovrField = Character.valueOf(Char(currentString[0]))
                overrideMap.put(ovrField, nsName)
                fullOverride = false
            }
            let ovrLoc = ULocale((loc.getBaseName()) + "@numbers=" + (nsName))
            let nf = NumberFormat.createInstance(ovrLoc, NumberFormat.NUMBERSTYLE)
            nf.setGroupingUsed(false)
            if (fullOverride) {
                setNumberFormat(nf)
            } else {
                useLocalZeroPaddingNumberFormat = false
            }
            if (!fullOverride && !numberFormatters.contains(nsName)) {
                numberFormatters.put(nsName, nf)
            }
            start = delimiterPosition + 1
        }
    }

    private func parsePattern(): Unit {
        hasMinute = false
        hasSecond = false
        hasHanYearChar = false
        var inQuote = false
        var i = 0
        while (i < Int32(pattern.size)) {
            let ch = Char(pattern[Int64(i)])
            if (ch == ''') {
                inQuote = !inQuote
            }
            if (ch == '\u{5e74}') {
                hasHanYearChar = true
            }
            if (!inQuote) {
                if (ch == 'm') {
                    hasMinute = true
                }
                if (ch == 's') {
                    hasSecond = true
                }
            }
            i++
        }
    }
}


class SimpleDateFormat_ContextValue <: Enum<SimpleDateFormat_ContextValue> {
    public static let UNKNOWN = SimpleDateFormat_ContextValue("UNKNOWN", 0)

    public static let CAPITALIZATION_FOR_MIDDLE_OF_SENTENCE = SimpleDateFormat_ContextValue("CAPITALIZATION_FOR_MIDDLE_OF_SENTENCE", 1)

    public static let CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE = SimpleDateFormat_ContextValue("CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE", 2)

    public static let CAPITALIZATION_FOR_UI_LIST_OR_MENU = SimpleDateFormat_ContextValue("CAPITALIZATION_FOR_UI_LIST_OR_MENU", 3)

    public static let CAPITALIZATION_FOR_STANDALONE = SimpleDateFormat_ContextValue("CAPITALIZATION_FOR_STANDALONE", 4)

    private static func _values(): Array<SimpleDateFormat_ContextValue> {
        return [SimpleDateFormat_ContextValue.UNKNOWN, SimpleDateFormat_ContextValue.CAPITALIZATION_FOR_MIDDLE_OF_SENTENCE, SimpleDateFormat_ContextValue.CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE, SimpleDateFormat_ContextValue.CAPITALIZATION_FOR_UI_LIST_OR_MENU, SimpleDateFormat_ContextValue.CAPITALIZATION_FOR_STANDALONE]
    }

    private static let _VALUES = SimpleDateFormat_ContextValue._values()

    public static func values(): Array<SimpleDateFormat_ContextValue> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): SimpleDateFormat_ContextValue {
        return (TypeInfo.of<SimpleDateFormat_ContextValue>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as SimpleDateFormat_ContextValue
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class SimpleDateFormat_PatternItem {
    let Type: Char

    let length: Int32

    let isNumeric: Bool

    init(Type: Char, length: Int32) {
        this.Type = Type
        this.length = length
        isNumeric = SimpleDateFormat.isNumeric(Type, length)
    }
}
