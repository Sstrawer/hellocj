package icu4cj.text


public class DateFormatSymbols <: Serializable & Cloneable {
    public static let FORMAT = 0

    public static let STANDALONE = 1

    
    public static let NUMERIC = 2

    
    public static let DT_CONTEXT_COUNT = 3

    public static let ABBREVIATED = 0

    public static let WIDE = 1

    public static let NARROW = 2

    public static let SHORT = 3

    
    public static let DT_WIDTH_COUNT = 4

    static let DT_LEAP_MONTH_PATTERN_FORMAT_WIDE = 0

    static let DT_LEAP_MONTH_PATTERN_FORMAT_ABBREV = 1

    static let DT_LEAP_MONTH_PATTERN_FORMAT_NARROW = 2

    static let DT_LEAP_MONTH_PATTERN_STANDALONE_WIDE = 3

    static let DT_LEAP_MONTH_PATTERN_STANDALONE_ABBREV = 4

    static let DT_LEAP_MONTH_PATTERN_STANDALONE_NARROW = 5

    static let DT_LEAP_MONTH_PATTERN_NUMERIC = 6

    static let DT_MONTH_PATTERN_COUNT = 7

    static let DEFAULT_TIME_SEPARATOR = ":"

    static let ALTERNATE_TIME_SEPARATOR = "."

    public init() {
        this(ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public init(locale: Locale) {
        this(ULocale.forLocale(locale))
    }

    public init(locale: ULocale) {
        initializeData(locale, CalendarUtil.getCalendarType(locale))
    }

    public static func getInstance(): DateFormatSymbols {
        return DateFormatSymbols()
    }

    public static func getInstance(locale: Locale): DateFormatSymbols {
        return DateFormatSymbols(locale)
    }

    public static func getInstance(locale: ULocale): DateFormatSymbols {
        return DateFormatSymbols(locale)
    }

    public static func getAvailableLocales(): Array<Locale> {
        return ICUResourceBundle.getAvailableLocales()
    }

    public static func getAvailableULocales(): Array<ULocale> {
        return ICUResourceBundle.getAvailableULocales()
    }

    var eras: Array<String>

    var eraNames: Array<String>

    var narrowEras: Array<String>

    var months: Array<String>

    var shortMonths: Array<String>

    var narrowMonths: Array<String>

    var standaloneMonths: Array<String>

    var standaloneShortMonths: Array<String>

    var standaloneNarrowMonths: Array<String>

    var weekdays: Array<String>

    var shortWeekdays: Array<String>

    var shorterWeekdays: Array<String>

    var narrowWeekdays: Array<String>

    var standaloneWeekdays: Array<String>

    var standaloneShortWeekdays: Array<String>

    var standaloneShorterWeekdays: Array<String>

    var standaloneNarrowWeekdays: Array<String>

    var ampms: Array<String>

    var ampmsNarrow: Array<String>

    private var timeSeparator: String

    var shortQuarters: Array<String>

    var narrowQuarters: Array<String>

    var quarters: Array<String>

    var standaloneShortQuarters: Array<String>

    var standaloneNarrowQuarters: Array<String>

    var standaloneQuarters: Array<String>

    var leapMonthPatterns: Array<String>

    var shortYearNames: Array<String>

    var shortZodiacNames: Array<String>

    private var zoneStrings: Array<Array<String>>

    static let patternChars = "GyMdkHmsSEDFwWahKzYeugAZvcLQqVUOXxrbB"

    var localPatternChars: String

    var abbreviatedDayPeriods: Array<String>

    var wideDayPeriods: Array<String>

    var narrowDayPeriods: Array<String>

    var standaloneAbbreviatedDayPeriods: Array<String>

    var standaloneWideDayPeriods: Array<String>

    var standaloneNarrowDayPeriods: Array<String>

    private static let serialVersionUID = -5987973545549424702

    private static let CALENDAR_CLASSES: Array<Array<String>> = [["GregorianCalendar", "gregorian"], ["JapaneseCalendar", "japanese"], ["BuddhistCalendar", "buddhist"], ["TaiwanCalendar", "roc"], ["PersianCalendar", "persian"], ["IslamicCalendar", "islamic"], ["HebrewCalendar", "hebrew"], ["ChineseCalendar", "chinese"], ["IndianCalendar", "indian"], ["CopticCalendar", "coptic"], ["EthiopicCalendar", "ethiopic"]]

    private static let contextUsageTypeMap: Map<String, DateFormatSymbols_CapitalizationContextUsage>


    var capitalization: Map<DateFormatSymbols_CapitalizationContextUsage, Array<Bool>> = None

    public func getEras(): Array<String> {
        return duplicate(eras)
    }

    public func setEras(newEras: Array<String>): Unit {
        eras = duplicate(newEras)
    }

    public func getEraNames(): Array<String> {
        return duplicate(eraNames)
    }

    public func setEraNames(newEraNames: Array<String>): Unit {
        eraNames = duplicate(newEraNames)
    }

    public func getNarrowEras(): Array<String> {
        return duplicate(narrowEras)
    }

    public func setNarrowEras(newNarrowEras: Array<String>): Unit {
        narrowEras = duplicate(newNarrowEras)
    }

    public func getMonths(): Array<String> {
        return duplicate(months)
    }

    public func getMonths(context: Int32, width: Int32): Array<String> {
        var returnValue: Array<String>
        match (context) {
            case 0 => match (width) {
                case 1 => returnValue = months
                case 0 | 3 => returnValue = shortMonths
                case 2 => returnValue = narrowMonths
                case _ => ()
            }
            case 1 => match (width) {
                case 1 => returnValue = standaloneMonths
                case 0 | 3 => returnValue = standaloneShortMonths
                case 2 => returnValue = standaloneNarrowMonths
                case _ => ()
            }
            case _ => ()
        }
        if (returnValue.isNone()) {
            throw IllegalArgumentException("Bad context or width argument")
        }
        return duplicate(returnValue)
    }

    public func setMonths(newMonths: Array<String>): Unit {
        months = duplicate(newMonths)
    }

    public func setMonths(newMonths: Array<String>, context: Int32, width: Int32): Unit {
        match (context) {
            case 0 => match (width) {
                case 1 => months = duplicate(newMonths)
                case 0 => shortMonths = duplicate(newMonths)
                case 2 => narrowMonths = duplicate(newMonths)
                case _ => ()
            }
            case 1 => match (width) {
                case 1 => standaloneMonths = duplicate(newMonths)
                case 0 => standaloneShortMonths = duplicate(newMonths)
                case 2 => standaloneNarrowMonths = duplicate(newMonths)
                case _ => ()
            }
            case _ => ()
        }
    }

    public func getShortMonths(): Array<String> {
        return duplicate(shortMonths)
    }

    public func setShortMonths(newShortMonths: Array<String>): Unit {
        shortMonths = duplicate(newShortMonths)
    }

    public func getWeekdays(): Array<String> {
        return duplicate(weekdays)
    }

    public func getWeekdays(context: Int32, width: Int32): Array<String> {
        var returnValue: Array<String>
        match (context) {
            case 0 => match (width) {
                case 1 => returnValue = weekdays
                case 0 => returnValue = shortWeekdays
                case 3 => returnValue = if (shorterWeekdays.isSome()) { shorterWeekdays } else { shortWeekdays }
                case 2 => returnValue = narrowWeekdays
                case _ => ()
            }
            case 1 => match (width) {
                case 1 => returnValue = standaloneWeekdays
                case 0 => returnValue = standaloneShortWeekdays
                case 3 => returnValue = if (standaloneShorterWeekdays.isSome()) { standaloneShorterWeekdays } else { standaloneShortWeekdays }
                case 2 => returnValue = standaloneNarrowWeekdays
                case _ => ()
            }
            case _ => ()
        }
        if (returnValue.isNone()) {
            throw IllegalArgumentException("Bad context or width argument")
        }
        return duplicate(returnValue)
    }

    public func setWeekdays(newWeekdays: Array<String>, context: Int32, width: Int32): Unit {
        match (context) {
            case 0 => match (width) {
                case 1 => weekdays = duplicate(newWeekdays)
                case 0 => shortWeekdays = duplicate(newWeekdays)
                case 3 => shorterWeekdays = duplicate(newWeekdays)
                case 2 => narrowWeekdays = duplicate(newWeekdays)
                case _ => ()
            }
            case 1 => match (width) {
                case 1 => standaloneWeekdays = duplicate(newWeekdays)
                case 0 => standaloneShortWeekdays = duplicate(newWeekdays)
                case 3 => standaloneShorterWeekdays = duplicate(newWeekdays)
                case 2 => standaloneNarrowWeekdays = duplicate(newWeekdays)
                case _ => ()
            }
            case _ => ()
        }
    }

    public func setWeekdays(newWeekdays: Array<String>): Unit {
        weekdays = duplicate(newWeekdays)
    }

    public func getShortWeekdays(): Array<String> {
        return duplicate(shortWeekdays)
    }

    public func setShortWeekdays(newAbbrevWeekdays: Array<String>): Unit {
        shortWeekdays = duplicate(newAbbrevWeekdays)
    }

    public func getQuarters(context: Int32, width: Int32): Array<String> {
        var returnValue: Array<String>
        match (context) {
            case 0 => match (width) {
                case 1 => returnValue = quarters
                case 0 | 3 => returnValue = shortQuarters
                case 2 => returnValue = narrowQuarters
                case _ => ()
            }
            case 1 => match (width) {
                case 1 => returnValue = standaloneQuarters
                case 0 | 3 => returnValue = standaloneShortQuarters
                case 2 => returnValue = standaloneNarrowQuarters
                case _ => ()
            }
            case _ => ()
        }
        if (returnValue.isNone()) {
            throw IllegalArgumentException("Bad context or width argument")
        }
        return duplicate(returnValue)
    }

    public func setQuarters(newQuarters: Array<String>, context: Int32, width: Int32): Unit {
        match (context) {
            case 0 => match (width) {
                case 1 => quarters = duplicate(newQuarters)
                case 0 => shortQuarters = duplicate(newQuarters)
                case 2 => narrowQuarters = duplicate(newQuarters)
                case _ => ()
            }
            case 1 => match (width) {
                case 1 => standaloneQuarters = duplicate(newQuarters)
                case 0 => standaloneShortQuarters = duplicate(newQuarters)
                case 2 => standaloneNarrowQuarters = duplicate(newQuarters)
                case _ => ()
            }
            case _ => ()
        }
    }

    public func getYearNames(context: Int32, width: Int32): Array<String> {
        if (shortYearNames.isSome()) {
            return duplicate(shortYearNames)
        }
        return None
    }

    public func setYearNames(yearNames: Array<String>, context: Int32, width: Int32): Unit {
        if (context == FORMAT && width == ABBREVIATED) {
            shortYearNames = duplicate(yearNames)
        }
    }

    public func getZodiacNames(context: Int32, width: Int32): Array<String> {
        if (shortZodiacNames.isSome()) {
            return duplicate(shortZodiacNames)
        }
        return None
    }

    public func setZodiacNames(zodiacNames: Array<String>, context: Int32, width: Int32): Unit {
        if (context == FORMAT && width == ABBREVIATED) {
            shortZodiacNames = duplicate(zodiacNames)
        }
    }

    
    public func getLeapMonthPattern(context: Int32, width: Int32): String {
        if (leapMonthPatterns.isSome()) {
            var leapMonthPatternIndex = -1
            match (context) {
                case 0 => match (width) {
                    case 1 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_FORMAT_WIDE
                    case 0 | 3 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_FORMAT_ABBREV
                    case 2 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_FORMAT_NARROW
                    case _ => ()
                }
                case 1 => match (width) {
                    case 1 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_STANDALONE_WIDE
                    case 0 | 3 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_FORMAT_ABBREV
                    case 2 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_STANDALONE_NARROW
                    case _ => ()
                }
                case 2 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_NUMERIC
                case _ => ()
            }
            if (leapMonthPatternIndex < 0) {
                throw IllegalArgumentException("Bad context or width argument")
            }
            return leapMonthPatterns[Int64(leapMonthPatternIndex)]
        }
        return None
    }

    
    public func setLeapMonthPattern(leapMonthPattern: String, context: Int32, width: Int32): Unit {
        if (leapMonthPatterns.isSome()) {
            var leapMonthPatternIndex = -1
            match (context) {
                case 0 => match (width) {
                    case 1 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_FORMAT_WIDE
                    case 0 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_FORMAT_ABBREV
                    case 2 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_FORMAT_NARROW
                    case _ => ()
                }
                case 1 => match (width) {
                    case 1 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_STANDALONE_WIDE
                    case 0 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_FORMAT_ABBREV
                    case 2 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_STANDALONE_NARROW
                    case _ => ()
                }
                case 2 => leapMonthPatternIndex = DT_LEAP_MONTH_PATTERN_NUMERIC
                case _ => ()
            }
            if (leapMonthPatternIndex >= 0) {
                leapMonthPatterns[Int64(leapMonthPatternIndex)] = leapMonthPattern
            }
        }
    }

    public func getAmPmStrings(): Array<String> {
        return duplicate(ampms)
    }

    public func setAmPmStrings(newAmpms: Array<String>): Unit {
        ampms = duplicate(newAmpms)
    }

    
    public func getTimeSeparatorString(): String {
        return timeSeparator
    }

    
    public func setTimeSeparatorString(newTimeSeparator: String): Unit {
        timeSeparator = newTimeSeparator
    }

    public func getZoneStrings(): Array<Array<String>> {
        if (zoneStrings.isSome()) {
            return duplicate(zoneStrings)
        }
        let tzIDs = TimeZone.getAvailableIDs()
        let tznames = TimeZoneNames.getInstance(validLocale)
        tznames.loadAllDisplayNames()
        let types: Array<TimeZoneNames_NameType> = [TimeZoneNames_NameType.LONG_STANDARD, TimeZoneNames_NameType.SHORT_STANDARD, TimeZoneNames_NameType.LONG_DAYLIGHT, TimeZoneNames_NameType.SHORT_DAYLIGHT]
        let now = DateTime.now().toUnixTimeStamp().toMilliseconds()
        let array = Array<Array<String>>(tzIDs.size) { _ => Array<String>(5) }
        var i = 0
        while (i < Int32(tzIDs.size)) {
            var canonicalID = TimeZone.getCanonicalID(tzIDs[Int64(i)])
            if (canonicalID.isNone()) {
                canonicalID = tzIDs[Int64(i)]
            }
            array[Int64(i)][0] = tzIDs[Int64(i)]
            tznames.getDisplayNames(canonicalID, types, now, array[Int64(i)], 1)
            i++
        }
        zoneStrings = array
        return zoneStrings
    }

    public func setZoneStrings(newZoneStrings: Array<Array<String>>): Unit {
        zoneStrings = duplicate(newZoneStrings)
    }

    public func getLocalPatternChars(): String {
        return localPatternChars
    }

    public func setLocalPatternChars(newLocalPatternChars: String): Unit {
        localPatternChars = newLocalPatternChars
    }

    public override func clone(): Object {
        try {
            let other = super.toString()
            return other
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException(e as Exception)
        }
    }

    public override func hashCode(): Int64 {
        return requestedLocale.toString().hashCode()
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (obj.isNone() || !refEq(TypeInfo.of(this), TypeInfo.of(obj))) {
            return false
        }
        let that = obj
        return (Utility.arrayEquals(eras, that.eras) && Utility.arrayEquals(eraNames, that.eraNames) && Utility.arrayEquals(narrowEras, that.narrowEras) && Utility.arrayEquals(months, that.months) && Utility.arrayEquals(shortMonths, that.shortMonths) && Utility.arrayEquals(narrowMonths, that.narrowMonths) && Utility.arrayEquals(standaloneMonths, that.standaloneMonths) && Utility.arrayEquals(standaloneShortMonths, that.standaloneShortMonths) && Utility.arrayEquals(standaloneNarrowMonths, that.standaloneNarrowMonths) && Utility.arrayEquals(weekdays, that.weekdays) && Utility.arrayEquals(shortWeekdays, that.shortWeekdays) && Utility.arrayEquals(shorterWeekdays, that.shorterWeekdays) && Utility.arrayEquals(narrowWeekdays, that.narrowWeekdays) && Utility.arrayEquals(standaloneWeekdays, that.standaloneWeekdays) && Utility.arrayEquals(standaloneShortWeekdays, that.standaloneShortWeekdays) && Utility.arrayEquals(standaloneShorterWeekdays, that.standaloneShorterWeekdays) && Utility.arrayEquals(standaloneNarrowWeekdays, that.standaloneNarrowWeekdays) && Utility.arrayEquals(ampms, that.ampms) && Utility.arrayEquals(ampmsNarrow, that.ampmsNarrow) && Utility.arrayEquals(abbreviatedDayPeriods, that.abbreviatedDayPeriods) && Utility.arrayEquals(wideDayPeriods, that.wideDayPeriods) && Utility.arrayEquals(narrowDayPeriods, that.narrowDayPeriods) && Utility.arrayEquals(standaloneAbbreviatedDayPeriods, that.standaloneAbbreviatedDayPeriods) && Utility.arrayEquals(standaloneWideDayPeriods, that.standaloneWideDayPeriods) && Utility.arrayEquals(standaloneNarrowDayPeriods, that.standaloneNarrowDayPeriods) && Utility.arrayEquals(timeSeparator, that.timeSeparator) && arrayOfArrayEquals(zoneStrings, that.zoneStrings) && requestedLocale.getDisplayName().equals(that.requestedLocale.getDisplayName()) && Utility.arrayEquals(localPatternChars, that.localPatternChars))
    }

    static let millisPerHour = 60 * 60 * 1000

    private static var DFSCACHE: CacheBase<String, DateFormatSymbols, ULocale> = DateFormatSymbols_1()

    protected func initializeData(desiredLocale: ULocale, Type: String): Unit {
        var key: String = (desiredLocale.getBaseName()) + '+'.toString() + (Type)
        let ns = desiredLocale.getKeywordValue("numbers")
        if (ns.isSome() && Int32(ns.size) > 0) {
            key += '+'.toString() + (ns)
        }
        let dfs = DFSCACHE.getInstance(key, desiredLocale)
        initializeData(dfs)
    }

    public func initializeData(dfs: DateFormatSymbols): Unit {
        this.eras = dfs.eras
        this.eraNames = dfs.eraNames
        this.narrowEras = dfs.narrowEras
        this.months = dfs.months
        this.shortMonths = dfs.shortMonths
        this.narrowMonths = dfs.narrowMonths
        this.standaloneMonths = dfs.standaloneMonths
        this.standaloneShortMonths = dfs.standaloneShortMonths
        this.standaloneNarrowMonths = dfs.standaloneNarrowMonths
        this.weekdays = dfs.weekdays
        this.shortWeekdays = dfs.shortWeekdays
        this.shorterWeekdays = dfs.shorterWeekdays
        this.narrowWeekdays = dfs.narrowWeekdays
        this.standaloneWeekdays = dfs.standaloneWeekdays
        this.standaloneShortWeekdays = dfs.standaloneShortWeekdays
        this.standaloneShorterWeekdays = dfs.standaloneShorterWeekdays
        this.standaloneNarrowWeekdays = dfs.standaloneNarrowWeekdays
        this.ampms = dfs.ampms
        this.ampmsNarrow = dfs.ampmsNarrow
        this.timeSeparator = dfs.timeSeparator
        this.shortQuarters = dfs.shortQuarters
        this.narrowQuarters = dfs.narrowQuarters
        this.quarters = dfs.quarters
        this.standaloneShortQuarters = dfs.standaloneShortQuarters
        this.standaloneNarrowQuarters = dfs.standaloneNarrowQuarters
        this.standaloneQuarters = dfs.standaloneQuarters
        this.leapMonthPatterns = dfs.leapMonthPatterns
        this.shortYearNames = dfs.shortYearNames
        this.shortZodiacNames = dfs.shortZodiacNames
        this.abbreviatedDayPeriods = dfs.abbreviatedDayPeriods
        this.wideDayPeriods = dfs.wideDayPeriods
        this.narrowDayPeriods = dfs.narrowDayPeriods
        this.standaloneAbbreviatedDayPeriods = dfs.standaloneAbbreviatedDayPeriods
        this.standaloneWideDayPeriods = dfs.standaloneWideDayPeriods
        this.standaloneNarrowDayPeriods = dfs.standaloneNarrowDayPeriods
        this.zoneStrings = dfs.zoneStrings
        this.localPatternChars = dfs.localPatternChars
        this.capitalization = dfs.capitalization
        this.actualLocale = dfs.actualLocale
        this.validLocale = dfs.validLocale
        this.requestedLocale = dfs.requestedLocale
    }

    init(desiredLocale: ULocale, b: ICUResourceBundle, calendarType: String) {
        initializeData(desiredLocale, b, calendarType)
    }

    
    protected func initializeData(desiredLocale: ULocale, b: ICUResourceBundle, calendarType: String): Unit {
        var tempb = b
        var tempcalendarType = calendarType
        let calendarSink = DateFormatSymbols_CalendarDataSink()
        if (tempb.isNone()) {
            tempb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, desiredLocale)
        }
        while (tempcalendarType.isSome()) {
            let dataForType = tempb.findWithFallback("calendar/" + (tempcalendarType))
            if (dataForType.isNone()) {
                if (!"gregorian".equals(tempcalendarType)) {
                    tempcalendarType = "gregorian"
                    calendarSink.visitAllResources()
                    continue
                }
                throw MissingResourceException("The 'gregorian' calendar type wasn't found for the locale: " + (desiredLocale.getBaseName()), TypeInfo.of(this).name, "gregorian")
            }
            calendarSink.preEnumerate(tempcalendarType)
            dataForType.getAllItemsWithFallback("", calendarSink)
            if (tempcalendarType == "gregorian") {
                break
            }
            tempcalendarType = calendarSink.nextCalendarType
            if (tempcalendarType.isNone()) {
                tempcalendarType = "gregorian"
                calendarSink.visitAllResources()
            }
        }
        let arrays = calendarSink.arrays
        let maps = calendarSink.maps
        eras = arrays.get("eras/abbreviated")
        eraNames = arrays.get("eras/wide")
        narrowEras = arrays.get("eras/narrow")
        months = arrays.get("monthNames/format/wide")
        shortMonths = arrays.get("monthNames/format/abbreviated")
        narrowMonths = arrays.get("monthNames/format/narrow")
        standaloneMonths = arrays.get("monthNames/stand-alone/wide")
        standaloneShortMonths = arrays.get("monthNames/stand-alone/abbreviated")
        standaloneNarrowMonths = arrays.get("monthNames/stand-alone/narrow")
        let lWeekdays = arrays.get("dayNames/format/wide")
        weekdays = Array<String>(8)
        weekdays[0] = ""
        arraycopy(lWeekdays, 0, weekdays, 1, lWeekdays.size)
        let aWeekdays = arrays.get("dayNames/format/abbreviated")
        shortWeekdays = Array<String>(8)
        shortWeekdays[0] = ""
        arraycopy(aWeekdays, 0, shortWeekdays, 1, aWeekdays.size)
        let sWeekdays = arrays.get("dayNames/format/short")
        shorterWeekdays = Array<String>(8)
        shorterWeekdays[0] = ""
        arraycopy(sWeekdays, 0, shorterWeekdays, 1, sWeekdays.size)
        var nWeekdays = arrays.get("dayNames/format/narrow")
        if (nWeekdays.isNone()) {
            nWeekdays = arrays.get("dayNames/stand-alone/narrow")
            if (nWeekdays.isNone()) {
                nWeekdays = arrays.get("dayNames/format/abbreviated")
                if (nWeekdays.isNone()) {
                    throw MissingResourceException("Resource not found", TypeInfo.of(this).name, "dayNames/format/abbreviated")
                }
            }
        }
        narrowWeekdays = Array<String>(8)
        narrowWeekdays[0] = ""
        arraycopy(nWeekdays, 0, narrowWeekdays, 1, nWeekdays.size)
        var swWeekdays: Array<String>
        swWeekdays = arrays.get("dayNames/stand-alone/wide")
        standaloneWeekdays = Array<String>(8)
        standaloneWeekdays[0] = ""
        arraycopy(swWeekdays, 0, standaloneWeekdays, 1, swWeekdays.size)
        var saWeekdays: Array<String>
        saWeekdays = arrays.get("dayNames/stand-alone/abbreviated")
        standaloneShortWeekdays = Array<String>(8)
        standaloneShortWeekdays[0] = ""
        arraycopy(saWeekdays, 0, standaloneShortWeekdays, 1, saWeekdays.size)
        var ssWeekdays: Array<String>
        ssWeekdays = arrays.get("dayNames/stand-alone/short")
        standaloneShorterWeekdays = Array<String>(8)
        standaloneShorterWeekdays[0] = ""
        arraycopy(ssWeekdays, 0, standaloneShorterWeekdays, 1, ssWeekdays.size)
        var snWeekdays: Array<String>
        snWeekdays = arrays.get("dayNames/stand-alone/narrow")
        standaloneNarrowWeekdays = Array<String>(8)
        standaloneNarrowWeekdays[0] = ""
        arraycopy(snWeekdays, 0, standaloneNarrowWeekdays, 1, snWeekdays.size)
        ampms = arrays.get("AmPmMarkers")
        ampmsNarrow = arrays.get("AmPmMarkersNarrow")
        quarters = arrays.get("quarters/format/wide")
        shortQuarters = arrays.get("quarters/format/abbreviated")
        narrowQuarters = arrays.get("quarters/format/narrow")
        standaloneQuarters = arrays.get("quarters/stand-alone/wide")
        standaloneShortQuarters = arrays.get("quarters/stand-alone/abbreviated")
        standaloneNarrowQuarters = arrays.get("quarters/stand-alone/narrow")
        abbreviatedDayPeriods = loadDayPeriodStrings(maps.get("dayPeriod/format/abbreviated"), None)
        wideDayPeriods = loadDayPeriodStrings(maps.get("dayPeriod/format/wide"), abbreviatedDayPeriods)
        narrowDayPeriods = loadDayPeriodStrings(maps.get("dayPeriod/format/narrow"), abbreviatedDayPeriods)
        standaloneAbbreviatedDayPeriods = loadDayPeriodStrings(maps.get("dayPeriod/stand-alone/abbreviated"), abbreviatedDayPeriods)
        standaloneWideDayPeriods = loadDayPeriodStrings(maps.get("dayPeriod/stand-alone/wide"), standaloneAbbreviatedDayPeriods)
        standaloneNarrowDayPeriods = loadDayPeriodStrings(maps.get("dayPeriod/stand-alone/narrow"), standaloneAbbreviatedDayPeriods)
        var i = 0
        while (i < DT_MONTH_PATTERN_COUNT) {
            let monthPatternPath = LEAP_MONTH_PATTERNS_PATHS[Int64(i)]
            if (monthPatternPath.isSome()) {
                let monthPatternMap = maps.get(monthPatternPath)
                if (monthPatternMap.isSome()) {
                    let leapMonthPattern = monthPatternMap.get("leap")
                    if (leapMonthPattern.isSome()) {
                        if (leapMonthPatterns.isNone()) {
                            leapMonthPatterns = Array<String>(Int64(DT_MONTH_PATTERN_COUNT))
                        }
                        leapMonthPatterns[Int64(i)] = leapMonthPattern
                    }
                }
            }
            i++
        }
        shortYearNames = arrays.get("cyclicNameSets/years/format/abbreviated")
        shortZodiacNames = arrays.get("cyclicNameSets/zodiacs/format/abbreviated")
        requestedLocale = desiredLocale
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, desiredLocale)
        localPatternChars = patternChars
        let uloc = rb.getULocale()
        setLocale(uloc, uloc)
        capitalization = HashMap<DateFormatSymbols_CapitalizationContextUsage, Array<Bool>>()
        let noTransforms = Array<Bool>(2) { _ => false }
        noTransforms[0] = false
        noTransforms[1] = false
        let allUsages = DateFormatSymbols_CapitalizationContextUsage.values()
        for (usage in allUsages) {
            capitalization.put(usage, noTransforms)
        }
        var contextTransformsBundle: UResourceBundle
        try {
            contextTransformsBundle = rb.getWithFallback("contextTransforms")
        } catch (e: MissingResourceException) {
            contextTransformsBundle = None
        }
        if (contextTransformsBundle.isSome()) {
            let ctIterator = contextTransformsBundle.getIterator()
            while (ctIterator.hasNext()) {
                let contextTransformUsage = ctIterator.next()
                let intVector = contextTransformUsage.getIntVector()
                if (Int32(intVector.size) >= 2) {
                    let usageKey = contextTransformUsage.getKey()
                    let usage = contextUsageTypeMap.get(usageKey)
                    if (usage.isSome()) {
                        let transforms = Array<Bool>(2) { _ => false }
                        transforms[0] = (intVector[0] != 0)
                        transforms[1] = (intVector[1] != 0)
                        capitalization.put(usage, transforms)
                    }
                }
            }
        }
        let ns = NumberingSystem.getInstance(desiredLocale)
        let nsName = if (ns.isNone()) { Some("latn") } else { ns.getName() }
        let tsPath: String = "NumberElements/" + (nsName) + "/symbols/timeSeparator"
        try {
            setTimeSeparatorString(rb.getStringWithFallback(tsPath))
        } catch (e: MissingResourceException) {
            setTimeSeparatorString(DEFAULT_TIME_SEPARATOR)
        }
    }

    private static let LEAP_MONTH_PATTERNS_PATHS = Array<String>(Int64(DT_MONTH_PATTERN_COUNT))


    private static func arrayOfArrayEquals(aa1: Array<Array<Object>>, aa2: Array<Array<Object>>): Bool {
        if (refEq(aa1, aa2)) {
            return true
        }
        if (aa1.isNone() || aa2.isNone()) {
            return false
        }
        if (Int32(aa1.size) != Int32(aa2.size)) {
            return false
        }
        var equal = true
        var i = 0
        while (i < Int32(aa1.size)) {
            equal = Utility.arrayEquals(aa1[Int64(i)], aa2[Int64(i)])
            if (!equal) {
                break
            }
            i++
        }
        return equal
    }

    private static let DAY_PERIOD_KEYS: Array<String> = ["midnight", "noon", "morning1", "afternoon1", "evening1", "night1", "morning2", "afternoon2", "evening2", "night2"]

    private func loadDayPeriodStrings(resourceMap: Map<String, String>, copyFrom: Array<String>): Array<String> {
        if (resourceMap.isNone() && copyFrom.isSome()) {
            return copyFrom
        } else {
            let strings = Array<String>(DAY_PERIOD_KEYS.size)
            if (resourceMap.isSome()) {
                var i = 0
                while (i < Int32(DAY_PERIOD_KEYS.size)) {
                    strings[Int64(i)] = resourceMap.get(DAY_PERIOD_KEYS[Int64(i)])
                    if (strings[Int64(i)].isNone() && copyFrom.isSome()) {
                        strings[Int64(i)] = copyFrom[Int64(i)]
                    }
                    i++
                }
            }
            return strings
        }
    }

    private var requestedLocale: ULocale

    private func duplicate(srcArray: Array<String>): Array<String> {
        return srcArray.clone()
    }

    private func duplicate(srcArray: Array<Array<String>>): Array<Array<String>> {
        let aCopy = Array<Array<String>>(srcArray.size) { _ => Array<String>(0) }
        var i = 0
        while (i < Int32(srcArray.size)) {
            aCopy[Int64(i)] = duplicate(srcArray[Int64(i)])
            i++
        }
        return aCopy
    }

    public init(cal: Calendar, locale: Locale) {
        initializeData(ULocale.forLocale(locale), cal.getType())
    }

    public init(cal: Calendar, locale: ULocale) {
        initializeData(locale, cal.getType())
    }

    public init(calendarClass: ClassTypeInfo, locale: Locale) {
        this(calendarClass, ULocale.forLocale(locale))
    }

    public init(calendarClass: ClassTypeInfo, locale: ULocale) {
        let fullName: String = calendarClass.name
        let lastDot = indexOfWrap(fullName.lastIndexOf(UInt8(UInt32('.'))))
        let className: String = fullName[Int64(lastDot + 1)..]
        var calType: String
        for (calClassInfo in CALENDAR_CLASSES) {
            if (calClassInfo[0].equals(className)) {
                calType = calClassInfo[1]
                break
            }
        }
        if (calType.isNone()) {
            calType = className.replaceAll("Calendar", "").toLowerCase(Locale.ENGLISH)
        }
        initializeData(locale, calType)
    }

    public init(bundle: ResourceBundle, locale: Locale) {
        this(bundle, ULocale.forLocale(locale))
    }

    public init(bundle: ResourceBundle, locale: ULocale) {
        initializeData(locale, bundle, CalendarUtil.getCalendarType(locale))
    }

    
    public static func getDateFormatBundle(calendarClass: ClassTypeInfo, locale: Locale): ResourceBundle {
        return None
    }

    
    public static func getDateFormatBundle(calendarClass: ClassTypeInfo, locale: ULocale): ResourceBundle {
        return None
    }

    
    public static func getDateFormatBundle(cal: Calendar, locale: Locale): ResourceBundle {
        return None
    }

    
    public static func getDateFormatBundle(cal: Calendar, locale: ULocale): ResourceBundle {
        return None
    }

    public func getLocale(Type: ULocale_Type): ULocale {
        return if (refEq(Type, ULocale.ACTUAL_LOCALE)) { this.actualLocale } else { this.validLocale }
    }

    func setLocale(valid: ULocale, actual: ULocale): Unit {
        if ((valid.isNone()) != (actual.isNone())) {
            throw IllegalArgumentException()
        }
        this.validLocale = valid
        this.actualLocale = actual
    }

    private var validLocale: ULocale

    private var actualLocale: ULocale

    private func readObject(stream: ObjectInputStream): Unit {
        stream.defaultReadObject()
    }
}


class DateFormatSymbols_CapitalizationContextUsage <: Enum<DateFormatSymbols_CapitalizationContextUsage> {
    public static let OTHER = DateFormatSymbols_CapitalizationContextUsage("OTHER", 0)

    public static let MONTH_FORMAT = DateFormatSymbols_CapitalizationContextUsage("MONTH_FORMAT", 1)

    public static let MONTH_STANDALONE = DateFormatSymbols_CapitalizationContextUsage("MONTH_STANDALONE", 2)

    public static let MONTH_NARROW = DateFormatSymbols_CapitalizationContextUsage("MONTH_NARROW", 3)

    public static let DAY_FORMAT = DateFormatSymbols_CapitalizationContextUsage("DAY_FORMAT", 4)

    public static let DAY_STANDALONE = DateFormatSymbols_CapitalizationContextUsage("DAY_STANDALONE", 5)

    public static let DAY_NARROW = DateFormatSymbols_CapitalizationContextUsage("DAY_NARROW", 6)

    public static let ERA_WIDE = DateFormatSymbols_CapitalizationContextUsage("ERA_WIDE", 7)

    public static let ERA_ABBREV = DateFormatSymbols_CapitalizationContextUsage("ERA_ABBREV", 8)

    public static let ERA_NARROW = DateFormatSymbols_CapitalizationContextUsage("ERA_NARROW", 9)

    public static let ZONE_LONG = DateFormatSymbols_CapitalizationContextUsage("ZONE_LONG", 10)

    public static let ZONE_SHORT = DateFormatSymbols_CapitalizationContextUsage("ZONE_SHORT", 11)

    public static let METAZONE_LONG = DateFormatSymbols_CapitalizationContextUsage("METAZONE_LONG", 12)

    public static let METAZONE_SHORT = DateFormatSymbols_CapitalizationContextUsage("METAZONE_SHORT", 13)

    private static func _values(): Array<DateFormatSymbols_CapitalizationContextUsage> {
        return [DateFormatSymbols_CapitalizationContextUsage.OTHER, DateFormatSymbols_CapitalizationContextUsage.MONTH_FORMAT, DateFormatSymbols_CapitalizationContextUsage.MONTH_STANDALONE, DateFormatSymbols_CapitalizationContextUsage.MONTH_NARROW, DateFormatSymbols_CapitalizationContextUsage.DAY_FORMAT, DateFormatSymbols_CapitalizationContextUsage.DAY_STANDALONE, DateFormatSymbols_CapitalizationContextUsage.DAY_NARROW, DateFormatSymbols_CapitalizationContextUsage.ERA_WIDE, DateFormatSymbols_CapitalizationContextUsage.ERA_ABBREV, DateFormatSymbols_CapitalizationContextUsage.ERA_NARROW, DateFormatSymbols_CapitalizationContextUsage.ZONE_LONG, DateFormatSymbols_CapitalizationContextUsage.ZONE_SHORT, DateFormatSymbols_CapitalizationContextUsage.METAZONE_LONG, DateFormatSymbols_CapitalizationContextUsage.METAZONE_SHORT]
    }

    private static let _VALUES = DateFormatSymbols_CapitalizationContextUsage._values()

    public static func values(): Array<DateFormatSymbols_CapitalizationContextUsage> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DateFormatSymbols_CapitalizationContextUsage {
        return (TypeInfo.of<DateFormatSymbols_CapitalizationContextUsage>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DateFormatSymbols_CapitalizationContextUsage
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class DateFormatSymbols_1 <: SoftCache<String, DateFormatSymbols, ULocale> {
    init() {
        super()
    }

    override protected func createInstance(key: String, locale: ULocale): DateFormatSymbols {
        let typeStart = indexOfWrap(key.indexOf(UInt8(UInt32('+')))) + 1
        var typeLimit = indexOfWrap(key.indexOf(UInt8(UInt32('+')), Int64(typeStart)))
        if (typeLimit < 0) {
            typeLimit = Int32(key.size)
        }
        let Type: String = key[Int64(typeStart)..Int64(typeLimit)]
        return DateFormatSymbols(locale, None, Type)
    }
}


class DateFormatSymbols_CalendarDataSink <: UResource_Sink {
    var arrays: Map<String, Array<String>> = TreeMap() as Map<String, Array<String>>

    var maps: Map<String, Map<String, String>> = TreeMap() as Map<String, Map<String, String>>

    var aliasPathPairs: ArrayList<String> = ArrayList<String>()

    var currentCalendarType: String

    var nextCalendarType: String

    private var resourcesToVisit: Set<String>

    private var aliasRelativePath: String

    init() {
        super()
    }

    public func visitAllResources(): Unit {
        resourcesToVisit = None
    }

    public func preEnumerate(calendarType: String): Unit {
        currentCalendarType = calendarType
        nextCalendarType = None
        aliasPathPairs.clear()
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        if (!(currentCalendarType.isSome() && !currentCalendarType.isEmpty())) {
            throw AssertionError()
        }
        var resourcesToVisitNext: Set<String>
        let calendarData = value.getTable()
                    if (resourcesToVisitNext.isNone()) {
                        resourcesToVisitNext = HashSet<String>()
                    }
                    resourcesToVisitNext.put(aliasRelativePath)
                    continue
                } else if (refEq(aliasType, DateFormatSymbols_CalendarDataSink_AliasType.SAME_CALENDAR)) {
                    if (!arrays.contains(keyString) && !maps.contains(keyString)) {
                        aliasPathPairs.append(aliasRelativePath)
                        aliasPathPairs.append(keyString)
                    }
                    continue
                }
                if (resourcesToVisit.isSome() && !resourcesToVisit.isEmpty() && !resourcesToVisit.contains(keyString) && !(keyString == "AmPmMarkersAbbr")) {
                    continue
                }
                if (keyString.startsWith("AmPmMarkers")) {
                    if (!keyString.endsWith("%variant") && !arrays.contains(keyString)) {
                        let dataArray = value.getStringArray()
                        arrays.put(keyString, dataArray)
                    }
                } else if (keyString == "eras" || keyString == "dayNames" || keyString == "monthNames" || keyString == "quarters" || keyString == "dayPeriod" || keyString == "monthPatterns" || keyString == "cyclicNameSets") {
                    processResource(keyString, key, value)
                }
                i++
            }
        } while (false)
        var modified: Bool = false
                        maps.put(aliasPathPairs[Int64(i + 1)], maps.get(alias))
                        mod = true
                    }
                    if (mod) {
                        aliasPathPairs.remove(Int64(i + 1))
                        aliasPathPairs.remove(Int64(i))
                        modified = true
                    } else {
                        i += 2
                    }
                }
            } while (false)
        } while (modified && !aliasPathPairs.isEmpty())
        if (resourcesToVisitNext.isSome()) {
            resourcesToVisit = resourcesToVisitNext
        }
    }

    protected func processResource(path: String, key: UResource_Key, value: UResource_Value): Unit {
        let table = value.getTable()
        var stringMap: Map<String, String> = None
        var i = 0
        while (table.getKeyAndValue(i, key, value)) {
            if (key.endsWith("%variant")) {
                continue
            }
            let keyString: String = key.toString()
            if (value.getType() == ICUResourceBundle.STRING) {
                if (i == 0) {
                    stringMap = HashMap<String, String>()
                    maps.put(path, stringMap)
                }
                if (!stringMap.isSome()) {
                    throw AssertionError()
                }
                stringMap.put(keyString, value.getString())
                continue
            }
            if (!stringMap.isNone()) {
                throw AssertionError()
            }
            let currentPath: String = (path) + "/" + (keyString)
            if (currentPath.startsWith("cyclicNameSets")) {
                if (!"cyclicNameSets/years/format/abbreviated".startsWith(currentPath) && !"cyclicNameSets/zodiacs/format/abbreviated".startsWith(currentPath) && !"cyclicNameSets/dayParts/format/abbreviated".startsWith(currentPath)) {
                    continue
                }
            }
            if (arrays.contains(currentPath) || maps.contains(currentPath)) {
                continue
            }
            let aliasType = processAliasFromValue(currentPath, value)
            if (refEq(aliasType, DateFormatSymbols_CalendarDataSink_AliasType.SAME_CALENDAR)) {
                aliasPathPairs.append(aliasRelativePath)
                aliasPathPairs.append(currentPath)
                continue
            }
            if (!refEq(aliasType, DateFormatSymbols_CalendarDataSink_AliasType.NONE)) {
                throw AssertionError()
            }
            if (value.getType() == ICUResourceBundle.ARRAY) {
                let dataArray = value.getStringArray()
                arrays.put(currentPath, dataArray)
            } else if (value.getType() == ICUResourceBundle.TABLE) {
                processResource(currentPath, key, value)
            }
            i++
        }
    }

    private static let CALENDAR_ALIAS_PREFIX = "/LOCALE/calendar/"

    private func processAliasFromValue(currentRelativePath: String, value: UResource_Value): DateFormatSymbols_CalendarDataSink_AliasType {
        if (value.getType() == ICUResourceBundle.ALIAS) {
            let aliasPath = value.getAliasString()
            if (aliasPath.startsWith(CALENDAR_ALIAS_PREFIX) && Int32(aliasPath.size) > Int32(CALENDAR_ALIAS_PREFIX.size)) {
                let typeLimit = indexOfWrap(aliasPath.indexOf(UInt8(UInt32('/')), CALENDAR_ALIAS_PREFIX.size))
                if (typeLimit > Int32(CALENDAR_ALIAS_PREFIX.size)) {
                    let aliasCalendarType: String = aliasPath[CALENDAR_ALIAS_PREFIX.size..Int64(typeLimit)]
                    aliasRelativePath = aliasPath[Int64(typeLimit + 1)..]
                    if (currentCalendarType.equals(aliasCalendarType) && !currentRelativePath.equals(aliasRelativePath)) {
                        return DateFormatSymbols_CalendarDataSink_AliasType.SAME_CALENDAR
                    } else if (!currentCalendarType.equals(aliasCalendarType) && currentRelativePath.equals(aliasRelativePath)) {
                        if (aliasCalendarType == "gregorian") {
                            return DateFormatSymbols_CalendarDataSink_AliasType.GREGORIAN
                        } else if (nextCalendarType.isNone() || nextCalendarType.equals(aliasCalendarType)) {
                            nextCalendarType = aliasCalendarType
                            return DateFormatSymbols_CalendarDataSink_AliasType.DIFFERENT_CALENDAR
                        }
                    }
                }
            }
            throw ICUException("Malformed 'calendar' alias. Path: " + (aliasPath))
        }
        return DateFormatSymbols_CalendarDataSink_AliasType.NONE
    }
}


class DateFormatSymbols_CalendarDataSink_AliasType <: Enum<DateFormatSymbols_CalendarDataSink_AliasType> {
    public static let SAME_CALENDAR = DateFormatSymbols_CalendarDataSink_AliasType("SAME_CALENDAR", 0)

    public static let DIFFERENT_CALENDAR = DateFormatSymbols_CalendarDataSink_AliasType("DIFFERENT_CALENDAR", 1)

    public static let GREGORIAN = DateFormatSymbols_CalendarDataSink_AliasType("GREGORIAN", 2)

    public static let NONE = DateFormatSymbols_CalendarDataSink_AliasType("NONE", 3)

    private static func _values(): Array<DateFormatSymbols_CalendarDataSink_AliasType> {
        return [DateFormatSymbols_CalendarDataSink_AliasType.SAME_CALENDAR, DateFormatSymbols_CalendarDataSink_AliasType.DIFFERENT_CALENDAR, DateFormatSymbols_CalendarDataSink_AliasType.GREGORIAN, DateFormatSymbols_CalendarDataSink_AliasType.NONE]
    }

    private static let _VALUES = DateFormatSymbols_CalendarDataSink_AliasType._values()

    public static func values(): Array<DateFormatSymbols_CalendarDataSink_AliasType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DateFormatSymbols_CalendarDataSink_AliasType {
        return (TypeInfo.of<DateFormatSymbols_CalendarDataSink_AliasType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DateFormatSymbols_CalendarDataSink_AliasType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
