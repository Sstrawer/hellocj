package icu4cj.util


public abstract class Calendar <: Serializable & Cloneable & Comparable<Calendar> {
    public static let ERA = 0

    public static let YEAR = 1

    public static let MONTH = 2

    public static let WEEK_OF_YEAR = 3

    public static let WEEK_OF_MONTH = 4

    public static let DATE = 5

    public static let DAY_OF_MONTH = 5

    public static let DAY_OF_YEAR = 6

    public static let DAY_OF_WEEK = 7

    public static let DAY_OF_WEEK_IN_MONTH = 8

    public static let AM_PM = 9

    public static let HOUR = 10

    public static let HOUR_OF_DAY = 11

    public static let MINUTE = 12

    public static let SECOND = 13

    public static let MILLISECOND = 14

    public static let ZONE_OFFSET = 15

    public static let DST_OFFSET = 16

    public static let YEAR_WOY = 17

    public static let DOW_LOCAL = 18

    public static let EXTENDED_YEAR = 19

    public static let JULIAN_DAY = 20

    public static let MILLISECONDS_IN_DAY = 21

    public static let IS_LEAP_MONTH = 22

    public static let ORDINAL_MONTH = 23

    
    protected static let BASE_FIELD_COUNT = 24

    
    protected static let MAX_FIELD_COUNT = 32

    public static let SUNDAY = 1

    public static let MONDAY = 2

    public static let TUESDAY = 3

    public static let WEDNESDAY = 4

    public static let THURSDAY = 5

    public static let FRIDAY = 6

    public static let SATURDAY = 7

    public static let JANUARY = 0

    public static let FEBRUARY = 1

    public static let MARCH = 2

    public static let APRIL = 3

    public static let MAY = 4

    public static let JUNE = 5

    public static let JULY = 6

    public static let AUGUST = 7

    public static let SEPTEMBER = 8

    public static let OCTOBER = 9

    public static let NOVEMBER = 10

    public static let DECEMBER = 11

    public static let UNDECIMBER = 12

    public static let AM = 0

    public static let PM = 1

    
    public static let WEEKDAY = 0

    
    public static let WEEKEND = 1

    
    public static let WEEKEND_ONSET = 2

    
    public static let WEEKEND_CEASE = 3

    public static let WALLTIME_LAST = 0

    public static let WALLTIME_FIRST = 1

    public static let WALLTIME_NEXT_VALID = 2

    protected static let ONE_SECOND = 1000

    protected static let ONE_MINUTE = 60 * ONE_SECOND

    protected static let ONE_HOUR = 60 * ONE_MINUTE

    protected static let ONE_DAY = Int64(24 * ONE_HOUR)

    protected static let ONE_WEEK = 7 * ONE_DAY

    protected static let JAN_1_1_JULIAN_DAY = 1721426

    protected static let EPOCH_JULIAN_DAY = 2440588

    protected static let MIN_JULIAN = -2130706432

    protected static let MIN_MILLIS = -184303902528000000

    protected static let MIN_DATE = Date(MIN_MILLIS)

    protected static let MAX_JULIAN = // Unary numeric promotion is not supported: +2130706432

    protected static let MAX_MILLIS = (Int64(MAX_JULIAN - EPOCH_JULIAN_DAY)) * ONE_DAY

    protected static let MAX_DATE = Date(MAX_MILLIS)

    private static let MAX_HOURS = 548

     private var fields: Array<Int32>

     private var stamp: Array<Int32>

    private var time: Int64 = 0

     private var isTimeSet: Bool = false

     private var areFieldsSet: Bool = false

     private var areAllFieldsSet: Bool = false

     private var areFieldsVirtuallySet: Bool = false

    private var lenient = true

    private var zone: TimeZone

    private var firstDayOfWeek: Int32 = 0

    private var minimalDaysInFirstWeek: Int32 = 0

    private var weekendOnset: Int32 = 0

    private var weekendOnsetMillis: Int32 = 0

    private var weekendCease: Int32 = 0

    private var weekendCeaseMillis: Int32 = 0

    private var repeatedWallTime = WALLTIME_LAST

    private var skippedWallTime = WALLTIME_LAST

    protected static let UNSET = 0

    protected static let INTERNALLY_SET = 1

    protected static let MINIMUM_USER_STAMP = 2

     private var nextStamp = MINIMUM_USER_STAMP

    private static var STAMP_MAX = 10000

    private static let serialVersionUID = 6222646104888790989

     private var internalSetMask: Int32 = 0

     private var gregorianYear: Int32 = 0

     private var gregorianMonth: Int32 = 0

     private var gregorianDayOfYear: Int32 = 0

     private var gregorianDayOfMonth: Int32 = 0

    protected init() {
        this(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
    }

    protected init(zone: TimeZone, aLocale: Locale) {
        this(zone, ULocale.forLocale(aLocale))
    }

    protected init(zone: TimeZone, locale: ULocale) {
        this.zone = zone
        setWeekData(getRegionForCalendar(locale))
        let fw = locale.getKeywordValue("fw")
        if (fw.isSome()) {
            let fwOverride: Int32
            match (fw) {
                case "sun" => fwOverride = SUNDAY
                case "mon" => fwOverride = MONDAY
                case "tue" => fwOverride = TUESDAY
                case "wed" => fwOverride = WEDNESDAY
                case "thu" => fwOverride = THURSDAY
                case "fri" => fwOverride = FRIDAY
                case "sat" => fwOverride = SATURDAY
                case _ => fwOverride = -1
            }
            if (fwOverride != -1) {
                setFirstDayOfWeek(fwOverride)
            }
        }
        setCalendarLocale(locale)
        initInternal()
    }

    private func setCalendarLocale(locale: ULocale): Unit {
        var calLocale = locale
        if (Int32(locale.getVariant().size) != 0 || locale.getKeywords().isSome()) {
            let buf = StringBuilder()
            buf.append(locale.getLanguage())
            let script = locale.getScript()
            if (Int32(script.size) > 0) {
                buf.append("_").append(script)
            }
            let region = locale.getCountry()
            if (Int32(region.size) > 0) {
                buf.append("_").append(region)
            }
            let calType = locale.getKeywordValue("calendar")
            if (calType.isSome()) {
                buf.append("@calendar=").append(calType)
            }
            calLocale = ULocale(buf.toString())
        }
        setLocale(calLocale, calLocale)
    }

    private func recalculateStamp(): Unit {
        var index: Int32 = 0
        var currentValue: Int32 = 0
        var j: Int32 = 0
        var i: Int32 = 0
        nextStamp = 1
        j = 0
        while (j < Int32(stamp.size)) {
            currentValue = STAMP_MAX
            index = -1
            i = 0
            while (i < Int32(stamp.size)) {
                if (stamp[Int64(i)] > nextStamp && stamp[Int64(i)] < currentValue) {
                    currentValue = stamp[Int64(i)]
                    index = i
                }
                i++
            }
            if (index >= 0) {
                stamp[Int64(index)] = match (0) { case _ => nextStamp++; nextStamp }
            } else {
                break
            }
            j++
        }
        nextStamp++
    }

    private func initInternal(): Unit {
        fields = handleCreateFields()
        if (fields.isNone() || Int32(fields.size) < BASE_FIELD_COUNT || Int32(fields.size) > MAX_FIELD_COUNT) {
            throw Exception("Invalid fields[0]")
        }
        stamp = Array<Int32>(fields.size) { _ => 0 }
        var mask = (shl(1, ERA)) | (shl(1, YEAR)) | (shl(1, MONTH)) | (shl(1, DAY_OF_MONTH)) | (shl(1, DAY_OF_YEAR)) | (shl(1, EXTENDED_YEAR)) | (shl(1, IS_LEAP_MONTH)) | (shl(1, ORDINAL_MONTH))
        var i = BASE_FIELD_COUNT
        while (i < Int32(fields.size)) {
            mask |= (shl(1, i))
            i++
        }
        internalSetMask = mask
    }

    public static func getInstance(): Calendar {
        return getInstanceInternal(None, None)
    }

    public static func getInstance(zone: TimeZone): Calendar {
        return getInstanceInternal(zone, None)
    }

    public static func getInstance(aLocale: Locale): Calendar {
        return getInstanceInternal(None, ULocale.forLocale(aLocale))
    }

    public static func getInstance(locale: ULocale): Calendar {
        return getInstanceInternal(None, locale)
    }

    public static func getInstance(zone: TimeZone, aLocale: Locale): Calendar {
        return getInstanceInternal(zone, ULocale.forLocale(aLocale))
    }

    public static func getInstance(zone: TimeZone, locale: ULocale): Calendar {
        return getInstanceInternal(zone, locale)
    }

    private static func getInstanceInternal(tz: TimeZone, locale: ULocale): Calendar {
        var templocale = locale
        var temptz = tz
        if (templocale.isNone()) {
            templocale = ULocale.getDefault(ULocale_Category.FORMAT)
        }
        if (temptz.isNone()) {
            temptz = TimeZone.forULocaleOrDefault(templocale)
        }
        let cal = createInstance(templocale)
        cal.setTimeZone(temptz)
        cal.setTimeInMillis(DateTime.now().toUnixTimeStamp().toMilliseconds())
        return cal
    }

    private static func getRegionForCalendar(loc: ULocale): String {
        var region = ULocale.getRegionForSupplementalData(loc, true)
        if (Int32(region.size) == 0) {
            region = "001"
        }
        return region
    }

    private static func getCalendarTypeForLocale(l: ULocale): CalType {
        var s = CalendarUtil.getCalendarType(l)
        if (s.isSome()) {
            s = s.toLowerCase(Locale.ENGLISH)
            for (Type in CalType.values()) {
                if (s.equals(Type.getId())) {
                    return Type
                }
            }
        }
        return None
    }

    private static func createInstance(locale: ULocale): Calendar {
        var cal: Calendar
        let zone = TimeZone.forULocaleOrDefault(locale)
        var calType = getCalendarTypeForLocale(locale)
        if (calType.isNone()) {
            calType = CalType.GREGORIAN
        }
        match (calType) {
            case CalType.GREGORIAN => cal = GregorianCalendar(zone, locale)
            case CalType.ISO8601 =>
                cal = GregorianCalendar(zone, locale)
                if (locale.getUnicodeLocaleType("fw").isNone() && locale.getUnicodeLocaleType("rg").isNone()) {
                    cal.setFirstDayOfWeek(MONDAY)
                }
                cal.setMinimalDaysInFirstWeek(4)
            case CalType.BUDDHIST => cal = BuddhistCalendar(zone, locale)
            case CalType.CHINESE => cal = ChineseCalendar(zone, locale)
            case CalType.COPTIC => cal = CopticCalendar(zone, locale)
            case CalType.DANGI => cal = DangiCalendar(zone, locale)
            case CalType.ETHIOPIC => cal = EthiopicCalendar(zone, locale)
            case CalType.ETHIOPIC_AMETE_ALEM =>
                cal = EthiopicCalendar(zone, locale)
                cal.setAmeteAlemEra(true)
            case CalType.HEBREW => cal = HebrewCalendar(zone, locale)
            case CalType.INDIAN => cal = IndianCalendar(zone, locale)
            case CalType.ISLAMIC_CIVIL | CalType.ISLAMIC_UMALQURA | CalType.ISLAMIC_TBLA | CalType.ISLAMIC_RGSA | CalType.ISLAMIC => cal = IslamicCalendar(zone, locale)
            case CalType.JAPANESE => cal = JapaneseCalendar(zone, locale)
            case CalType.PERSIAN => cal = PersianCalendar(zone, locale)
            case CalType.ROC => cal = TaiwanCalendar(zone, locale)
            case _ => throw IllegalArgumentException("Unknown calendar type")
        }
        return cal
    }

    public static func getAvailableLocales(): Array<Locale> {
        return ICUResourceBundle.getAvailableLocales()
    }

    public static func getAvailableULocales(): Array<ULocale> {
        return ICUResourceBundle.getAvailableULocales()
    }

    public static func getKeywordValuesForLocale(key: String, locale: ULocale, commonlyUsed: Bool): Array<String> {
        let prefRegion = ULocale.getRegionForSupplementalData(locale, true)
        let values = ArrayList<String>()
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "supplementalData", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
        let calPref = rb.get("calendarPreferenceData")
        var order: UResourceBundle
        @AssertThrows[IllegalArgumentException]({
            order = calPref.get(prefRegion)
        } catch (mre: MissingResourceException) {
            order = calPref.get("001")
        }
        let caltypes = order.getStringArray()
        if (commonlyUsed) {
            return caltypes
        }
        var i = 0
        while (i < Int32(caltypes.size)) {
            values.append(caltypes[Int64(i)])
            i++
        }
        for (t in CalType.values()) {
            if (!values.contains(t.getId())) {
                values.append(t.getId())
            }
        }
        return values.toArray(size))
    }

    public func getTime(): DateTime {
        return Date(getTimeInMillis())
    }

    public func setTime(date: DateTime): Unit {
        setTimeInMillis(date.getTime())
    }

    public func getTimeInMillis(): Int64 {
        if (!isTimeSet) {
            updateTime()
        }
        return time
    }

    public func setTimeInMillis(millis: Int64): Unit {
        var tempmillis = millis
        if (tempmillis > MAX_MILLIS) {
            if (isLenient()) {
                tempmillis = MAX_MILLIS
            } else {
                throw IllegalArgumentException("millis value greater than upper bounds for a Calendar : " + tempmillis.toString())
            }
        } else if (tempmillis < MIN_MILLIS) {
            if (isLenient()) {
                tempmillis = MIN_MILLIS
            } else {
                throw IllegalArgumentException("millis value less than lower bounds for a Calendar : " + tempmillis.toString())
            }
        }
        time = tempmillis
        areFieldsSet = match (0) { case _ => areAllFieldsSet = false; areAllFieldsSet }
        isTimeSet = match (0) { case _ => areFieldsVirtuallySet = true; areFieldsVirtuallySet }
        var i = 0
        while (i < Int32(fields.size)) {
            fields[Int64(i)] = match (0) { case _ => stamp[Int64(i)] = 0; stamp[Int64(i)] }
            i++
        }
    }

    public func inTemporalLeapYear(): Bool {
        return getActualMaximum(DAY_OF_YEAR) == 366
    }

    private static var gTemporalMonthCodes: Array<String> = ["M01", "M02", "M03", "M04", "M05", "M06", "M07", "M08", "M09", "M10", "M11", "M12"]

    public func getTemporalMonthCode(): String {
        let month = get(MONTH)
        if (!(month < 12)) {
            throw AssertionError()
        }
        if (!(internalGet(IS_LEAP_MONTH) == 0)) {
            throw AssertionError()
        }
        return gTemporalMonthCodes[Int64(month)]
    }

    public func setTemporalMonthCode(temporalMonth: String): Unit {
        if (Int32(temporalMonth.size) == 3 && Char(temporalMonth[0]) == 'M') {
            var m = 0
            while (m < Int32(gTemporalMonthCodes.size)) {
                if (temporalMonth.equals(gTemporalMonthCodes[Int64(m)])) {
                    set(MONTH, m)
                    set(IS_LEAP_MONTH, 0)
                    return
                }
                m++
            }
        }
        throw IllegalArgumentException("Incorrect temporal Month code: " + (temporalMonth))
    }

    public func get(field: Int32): Int32 {
        complete()
        return fields[Int64(field)]
    }

    protected func internalGet(field: Int32): Int32 {
        return fields[Int64(field)]
    }

    protected func internalGet(field: Int32, defaultValue: Int32): Int32 {
        return if (stamp[Int64(field)] > UNSET) { fields[Int64(field)] } else { defaultValue }
    }

    
    protected func internalGetMonth(): Int32 {
        if (resolveFields(MONTH_PRECEDENCE) == MONTH) {
            return internalGet(MONTH)
        }
        return internalGet(ORDINAL_MONTH)
    }

    
    protected func internalGetMonth(defaultValue: Int32): Int32 {
        if (resolveFields(MONTH_PRECEDENCE) == MONTH) {
            return internalGet(MONTH, defaultValue)
        }
        return internalGet(ORDINAL_MONTH, defaultValue)
    }

    public func set(field: Int32, value: Int32): Unit {
        if (areFieldsVirtuallySet) {
            computeFields()
        }
        fields[Int64(field)] = value
        if (nextStamp == STAMP_MAX) {
            recalculateStamp()
        }
        stamp[Int64(field)] = match (0) { case _ => nextStamp++; nextStamp - 1 }
        isTimeSet = match (0) { case _ => areFieldsSet = match (0) { case _ => areFieldsVirtuallySet = false; areFieldsVirtuallySet }; areFieldsSet }
    }

    public func set(year: Int32, month: Int32, date: Int32): Unit {
        set(YEAR, year)
        set(MONTH, month)
        set(DATE, date)
    }

    public func set(year: Int32, month: Int32, date: Int32, hour: Int32, minute: Int32): Unit {
        set(YEAR, year)
        set(MONTH, month)
        set(DATE, date)
        set(HOUR_OF_DAY, hour)
        set(MINUTE, minute)
    }

    public func set(year: Int32, month: Int32, date: Int32, hour: Int32, minute: Int32, second: Int32): Unit {
        set(YEAR, year)
        set(MONTH, month)
        set(DATE, date)
        set(HOUR_OF_DAY, hour)
        set(MINUTE, minute)
        set(SECOND, second)
    }

    private static func gregoYearFromIslamicStart(year: Int32): Int32 {
        let cycle: Int32
        let offset: Int32
        var shift = 0
        if (year >= 1397) {
            cycle = (year - 1397) / 67
            offset = (year - 1397) % 67
            shift = 2 * cycle + (if (offset >= 33) { 1 } else { 0 })
        } else {
            cycle = (year - 1396) / 67 - 1
            offset = -(year - 1396) % 67
            shift = 2 * cycle + (if (offset <= 33) { 1 } else { 0 })
        }
        return year + 579 - shift
    }

    
    public func getRelatedYear(): Int32 {
        var year = get(EXTENDED_YEAR)
        var Type: CalType = CalType.GREGORIAN
        let typeString = getType()
        for (testType in CalType.values()) {
            if (typeString.equals(testType.getId())) {
                Type = testType
                break
            }
        }
        match (Type) {
            case CalType.PERSIAN => year += 622
            case CalType.HEBREW => year -= 3760
            case CalType.CHINESE => year -= 2637
            case CalType.INDIAN => year += 79
            case CalType.COPTIC => year += 284
            case CalType.ETHIOPIC => year += 8
            case CalType.ETHIOPIC_AMETE_ALEM => year -= 5492
            case CalType.DANGI => year -= 2333
            case CalType.ISLAMIC_CIVIL | CalType.ISLAMIC | CalType.ISLAMIC_UMALQURA | CalType.ISLAMIC_TBLA | CalType.ISLAMIC_RGSA => year = gregoYearFromIslamicStart(year)
            case _ => ()
        }
        return year
    }

    private static func firstIslamicStartYearFromGrego(year: Int32): Int32 {
        let cycle: Int32
        let offset: Int32
        var shift = 0
        if (year >= 1977) {
            cycle = (year - 1977) / 65
            offset = (year - 1977) % 65
            shift = 2 * cycle + (if (offset >= 32) { 1 } else { 0 })
        } else {
            cycle = (year - 1976) / 65 - 1
            offset = -(year - 1976) % 65
            shift = 2 * cycle + (if (offset <= 32) { 1 } else { 0 })
        }
        return year - 579 + shift
    }

    
    public func setRelatedYear(year: Int32): Unit {
        var tempyear = year
        var Type: CalType = CalType.GREGORIAN
        let typeString = getType()
        for (testType in CalType.values()) {
            if (typeString.equals(testType.getId())) {
                Type = testType
                break
            }
        }
        match (Type) {
            case CalType.PERSIAN => tempyear -= 622
            case CalType.HEBREW => tempyear += 3760
            case CalType.CHINESE => tempyear += 2637
            case CalType.INDIAN => tempyear -= 79
            case CalType.COPTIC => tempyear -= 284
            case CalType.ETHIOPIC => tempyear -= 8
            case CalType.ETHIOPIC_AMETE_ALEM => tempyear += 5492
            case CalType.DANGI => tempyear += 2333
            case CalType.ISLAMIC_CIVIL | CalType.ISLAMIC | CalType.ISLAMIC_UMALQURA | CalType.ISLAMIC_TBLA | CalType.ISLAMIC_RGSA => tempyear = firstIslamicStartYearFromGrego(tempyear)
            case _ => ()
        }
        set(EXTENDED_YEAR, tempyear)
    }

    public func clear(): Unit {
        var i = 0
        while (i < Int32(fields.size)) {
            fields[Int64(i)] = match (0) { case _ => stamp[Int64(i)] = 0; stamp[Int64(i)] }
            i++
        }
        isTimeSet = match (0) { case _ => areFieldsSet = match (0) { case _ => areAllFieldsSet = match (0) { case _ => areFieldsVirtuallySet = false; areFieldsVirtuallySet }; areAllFieldsSet }; areFieldsSet }
    }

    public func clear(field: Int32): Unit {
        if (areFieldsVirtuallySet) {
            computeFields()
        }
        fields[Int64(field)] = 0
        stamp[Int64(field)] = UNSET
        if (field == MONTH) {
            fields[Int64(ORDINAL_MONTH)] = 0
            stamp[Int64(ORDINAL_MONTH)] = UNSET
        }
        if (field == ORDINAL_MONTH) {
            fields[Int64(MONTH)] = 0
            stamp[Int64(MONTH)] = UNSET
        }
        isTimeSet = match (0) { case _ => areFieldsSet = match (0) { case _ => areAllFieldsSet = match (0) { case _ => areFieldsVirtuallySet = false; areFieldsVirtuallySet }; areAllFieldsSet }; areFieldsSet }
    }

    public func isSet(field: Int32): Bool {
        return areFieldsVirtuallySet || (stamp[Int64(field)] != UNSET)
    }

    protected func complete(): Unit {
        if (!isTimeSet) {
            updateTime()
        }
        if (!areFieldsSet) {
            computeFields()
            areFieldsSet = true
            areAllFieldsSet = true
        }
    }

    public override func equals(obj: Object): Bool {
        if (obj.isNone()) {
            return false
        }
        if (refEq(this, obj)) {
            return true
        }
        if (!refEq(TypeInfo.of(this), TypeInfo.of(obj))) {
            return false
        }
        let that = obj
        return isEquivalentTo(that) && getTimeInMillis() == that.getTime().getTime()
    }

    public func isEquivalentTo(other: Calendar): Bool {
        return refEq(TypeInfo.of(this), TypeInfo.of(other)) && isLenient() == other.isLenient() && getFirstDayOfWeek() == other.getFirstDayOfWeek() && getMinimalDaysInFirstWeek() == other.getMinimalDaysInFirstWeek() && getTimeZone().equals(other.getTimeZone()) && getRepeatedWallTimeOption() == other.getRepeatedWallTimeOption() && getSkippedWallTimeOption() == other.getSkippedWallTimeOption()
    }

    public override func hashCode(): Int64 {
        return Int64((if (lenient) { 1 } else { 0 }) | (shl(firstDayOfWeek, 1)) | (shl(minimalDaysInFirstWeek, 4)) | (shl(repeatedWallTime, 7)) | (shl(skippedWallTime, 9)) | (shl(Int32(zone.hashCode()), 11)))
    }

    private func compare(that: Object): Int64 {
        let thatMs: Int64
        if (checkOptionalIs<Calendar, Object>(that)) {
            thatMs = that.getTimeInMillis()
        } else if (checkOptionalIs<Date, Object>(that)) {
            thatMs = that.getTime()
        } else {
            throw IllegalArgumentException(toString(that) + "is not a Calendar or Date")
        }
        return getTimeInMillis() - thatMs
    }

    public func before(when: Object): Bool {
        return compare(when) < 0
    }

    public func after(when: Object): Bool {
        return compare(when) > 0
    }

    public func getActualMaximum(field: Int32): Int32 {
        let result: Int32
        match (field) {
            case 5 =>
                let cal = clone()
                cal.setLenient(true)
                cal.prepareGetActual(field, false)
                result = handleGetMonthLength(cal.get(EXTENDED_YEAR), cal.get(MONTH))
            case 6 =>
                let cal = clone()
                cal.setLenient(true)
                cal.prepareGetActual(field, false)
                result = handleGetYearLength(cal.get(EXTENDED_YEAR))
            case 0 | 7 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 18 | 20 | 21 => result = getMaximum(field)
            case 23 => result = if (inTemporalLeapYear()) { getMaximum(ORDINAL_MONTH) } else { getLeastMaximum(ORDINAL_MONTH) }
            case _ => result = getActualHelper(field, getLeastMaximum(field), getMaximum(field))
        }
        return result
    }

    public func getActualMinimum(field: Int32): Int32 {
        let result: Int32
        match (field) {
            case 7 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 18 | 20 | 21 => result = getMinimum(field)
            case _ => result = getActualHelper(field, getGreatestMinimum(field), getMinimum(field))
        }
        return result
    }

    protected func prepareGetActual(field: Int32, isMinimum: Bool): Unit {
        set(MILLISECONDS_IN_DAY, 0)
        match (field) {
            case 1 | 19 => set(DAY_OF_YEAR, getGreatestMinimum(DAY_OF_YEAR))
            case 17 => set(WEEK_OF_YEAR, getGreatestMinimum(WEEK_OF_YEAR))
            case 2 => set(DAY_OF_MONTH, getGreatestMinimum(DAY_OF_MONTH))
            case 8 =>
                set(DAY_OF_MONTH, 1)
                set(DAY_OF_WEEK, get(DAY_OF_WEEK))
            case 4 | 3 =>
                var dow = firstDayOfWeek
                if (isMinimum) {
                    dow = (dow + 6) % 7
                    if (dow < SUNDAY) {
                        dow += 7
                    }
                }
                set(DAY_OF_WEEK, dow)
            case _ => ()
        }
        set(field, getGreatestMinimum(field))
    }

    private func getActualHelper(field: Int32, startValue: Int32, endValue: Int32): Int32 {
        var tempstartValue = startValue
        if (tempstartValue == endValue) {
            return tempstartValue
        }
        let delta = if (endValue > tempstartValue) { 1 } else { -1 }
        let work = clone()
        work.complete()
        work.setLenient(true)
        work.prepareGetActual(field, delta < 0)
        work.set(field, tempstartValue)
        if (work.get(field) != tempstartValue && field != WEEK_OF_MONTH && delta > 0) {
            return tempstartValue
        }
        var result = tempstartValue
            result = tempstartValue
        } while (tempstartValue != endValue)
        return result
    }

    public func roll(field: Int32, up: Bool): Unit {
        roll(field, if (up) { // Unary numeric promotion is not supported: +1 } else { -1 })
    }

    public func roll(field: Int32, amount: Int32): Unit {
        var tempamount = amount
        if (tempamount == 0) {
            return
        }
        complete()
        match (field) {
            case 5 | 9 | 12 | 13 | 14 | 21 | 0 =>
                let min = getActualMinimum(field)
                let max = getActualMaximum(field)
                let gap = max - min + 1
                var value = internalGet(field) + tempamount
                value = (value - min) % gap
                if (value < 0) {
                    value += gap
                }
                value += min
                set(field, value)
                return
            case 10 | 11 =>
                let start = getTimeInMillis()
                let oldHour = internalGet(field)
                let max = getMaximum(field)
                var newHour = (oldHour + tempamount) % (max + 1)
                if (newHour < 0) {
                    newHour += max + 1
                }
                setTimeInMillis(start + Int64(ONE_HOUR) * (Int64(newHour) - Int64(oldHour)))
                return
            case 2 | 23 =>
                let max = getActualMaximum(MONTH)
                var mon = (internalGetMonth() + tempamount) % (max + 1)
                if (mon < 0) {
                    mon += (max + 1)
                }
                set(MONTH, mon)
                pinField(DAY_OF_MONTH)
                return
            case 1 | 17 =>
                let era = get(ERA)
                if (era == 0 && isEra0CountingBackward()) {
                    tempamount = -tempamount
                }
                var newYear = internalGet(field) + tempamount
                if (era > 0 || newYear >= 1) {
                    let maxYear = getActualMaximum(field)
                    if (maxYear < 32768) {
                        if (newYear < 1) {
                            newYear = maxYear - ((-newYear) % maxYear)
                        } else if (newYear > maxYear) {
                            newYear = ((newYear - 1) % maxYear) + 1
                        }
                    } else if (newYear < 1) {
                        newYear = 1
                    }
                } else if (era == 0 && isEra0CountingBackward()) {
                    newYear = 1
                }
                set(field, newYear)
                pinField(MONTH)
                pinField(DAY_OF_MONTH)
                return
            case 19 =>
                set(field, internalGet(field) + tempamount)
                pinField(MONTH)
                pinField(DAY_OF_MONTH)
                return
            case 4 =>
                var dow = internalGet(DAY_OF_WEEK) - getFirstDayOfWeek()
                if (dow < 0) {
                    dow += 7
                }
                var fdm = (dow - internalGet(DAY_OF_MONTH) + 1) % 7
                if (fdm < 0) {
                    fdm += 7
                }
                let start: Int32
                if ((7 - fdm) < getMinimalDaysInFirstWeek()) {
                    start = 8 - fdm
                } else {
                    start = 1 - fdm
                }
                let monthLen = getActualMaximum(DAY_OF_MONTH)
                let ldm = (monthLen - internalGet(DAY_OF_MONTH) + dow) % 7
                let limit = monthLen + 7 - ldm
                let gap = limit - start
                var day_of_month = (internalGet(DAY_OF_MONTH) + tempamount * 7 - start) % gap
                if (day_of_month < 0) {
                    day_of_month += gap
                }
                day_of_month += start
                if (day_of_month < 1) {
                    day_of_month = 1
                }
                if (day_of_month > monthLen) {
                    day_of_month = monthLen
                }
                set(DAY_OF_MONTH, day_of_month)
                return
            case 3 =>
                var dow = internalGet(DAY_OF_WEEK) - getFirstDayOfWeek()
                if (dow < 0) {
                    dow += 7
                }
                var fdy = (dow - internalGet(DAY_OF_YEAR) + 1) % 7
                if (fdy < 0) {
                    fdy += 7
                }
                let start: Int32
                if ((7 - fdy) < getMinimalDaysInFirstWeek()) {
                    start = 8 - fdy
                } else {
                    start = 1 - fdy
                }
                let yearLen = getActualMaximum(DAY_OF_YEAR)
                let ldy = (yearLen - internalGet(DAY_OF_YEAR) + dow) % 7
                let limit = yearLen + 7 - ldy
                let gap = limit - start
                var day_of_year = (internalGet(DAY_OF_YEAR) + tempamount * 7 - start) % gap
                if (day_of_year < 0) {
                    day_of_year += gap
                }
                day_of_year += start
                if (day_of_year < 1) {
                    day_of_year = 1
                }
                if (day_of_year > yearLen) {
                    day_of_year = yearLen
                }
                set(DAY_OF_YEAR, day_of_year)
                clear(MONTH)
                clear(ORDINAL_MONTH)
                return
            case 6 =>
                let delta = Int64(tempamount) * ONE_DAY
                let min2 = time - (Int64(internalGet(DAY_OF_YEAR) - 1)) * ONE_DAY
                let yearLength = getActualMaximum(DAY_OF_YEAR)
                time = (time + delta - min2) % (Int64(yearLength) * ONE_DAY)
                if (time < 0) {
                    time += Int64(yearLength) * ONE_DAY
                }
                setTimeInMillis(time + min2)
                return
            case 7 | 18 =>
                let delta = Int64(tempamount) * ONE_DAY
                var leadDays = internalGet(field)
                leadDays -= if (field == DAY_OF_WEEK) { getFirstDayOfWeek() } else { 1 }
                if (leadDays < 0) {
                    leadDays += 7
                }
                let min2 = time - Int64(leadDays) * ONE_DAY
                time = (time + delta - min2) % ONE_WEEK
                if (time < 0) {
                    time += ONE_WEEK
                }
                setTimeInMillis(time + min2)
                return
            case 8 =>
                let delta = Int64(tempamount) * ONE_WEEK
                let preWeeks = (internalGet(DAY_OF_MONTH) - 1) / 7
                let postWeeks = (getActualMaximum(DAY_OF_MONTH) - internalGet(DAY_OF_MONTH)) / 7
                let min2 = time - Int64(preWeeks) * ONE_WEEK
                let gap2 = ONE_WEEK * (Int64(preWeeks + postWeeks + 1))
                time = (time + delta - min2) % gap2
                if (time < 0) {
                    time += gap2
                }
                setTimeInMillis(time + min2)
                return
            case 20 =>
                set(field, internalGet(field) + tempamount)
                return
            case _ => throw IllegalArgumentException("Calendar.roll(" + (fieldName(field)) + ") not supported")
        }
    }

    public func add(field: Int32, amount: Int32): Unit {
        var tempamount = amount
        if (tempamount == 0) {
            return
        }
        var delta = Int64(tempamount)
        var keepWallTimeInvariant = true
        match (field) {
            case 0 =>
                set(field, get(field) + tempamount)
                pinField(ERA)
                return
            case 1 | 17 =>
                let era = get(ERA)
                if (era == 0 && isEra0CountingBackward()) {
                    tempamount = -tempamount
                }
            case 19 | 2 | 23 =>
                {
                    let oldLenient = isLenient()
                    setLenient(true)
                    set(field, get(field) + tempamount)
                    pinField(DAY_OF_MONTH)
                    if (oldLenient == false) {
                        complete()
                        setLenient(oldLenient)
                    }
                }
                return
            case 3 | 4 | 8 => delta *= ONE_WEEK
            case 9 => delta *= Int64(12 * ONE_HOUR)
            case 5 | 6 | 7 | 18 | 20 => delta *= ONE_DAY
            case 11 | 10 =>
                delta *= Int64(ONE_HOUR)
                keepWallTimeInvariant = false
            case 12 =>
                delta *= Int64(ONE_MINUTE)
                keepWallTimeInvariant = false
            case 13 =>
                delta *= Int64(ONE_SECOND)
                keepWallTimeInvariant = false
            case 14 | 21 => keepWallTimeInvariant = false
            case _ => throw IllegalArgumentException("Calendar.add(" + (fieldName(field)) + ") not supported")
        }
        var prevOffset = 0
        var prevWallTime = 0
        if (keepWallTimeInvariant) {
            prevOffset = get(DST_OFFSET) + get(ZONE_OFFSET)
            prevWallTime = get(MILLISECONDS_IN_DAY)
        }
        setTimeInMillis(getTimeInMillis() + delta)
        if (keepWallTimeInvariant) {
            var newWallTime = get(MILLISECONDS_IN_DAY)
            if (newWallTime != prevWallTime) {
                let t = internalGetTimeInMillis()
                let newOffset = get(DST_OFFSET) + get(ZONE_OFFSET)
                if (newOffset != prevOffset) {
                    let adjAmount = (Int64(prevOffset - newOffset)) % ONE_DAY
                    if (adjAmount != 0) {
                        setTimeInMillis(t + adjAmount)
                        newWallTime = get(MILLISECONDS_IN_DAY)
                    }
                    if (newWallTime != prevWallTime) {
                        match (skippedWallTime) {
                            case 1 => if (adjAmount > 0) {
                                setTimeInMillis(t)
                            }
                            case 0 => if (adjAmount < 0) {
                                setTimeInMillis(t)
                            }
                            case 2 =>
                                let tmpT = if (adjAmount > 0) { internalGetTimeInMillis() } else { t }
                                let immediatePrevTrans = getImmediatePreviousZoneTransition(tmpT)
                                if (immediatePrevTrans.isSome()) {
                                    setTimeInMillis(immediatePrevTrans)
                                } else {
                                    throw Exception("Could not locate a time zone transition before " + tmpT.toString())
                                }
                            case _ => ()
                        }
                    }
                }
            }
        }
    }

    public func getDisplayName(loc: Locale): String {
        return TypeInfo.of(this).name
    }

    public func getDisplayName(loc: ULocale): String {
        return TypeInfo.of(this).name
    }

    public override func compareTo(that: Calendar): Int32 {
        let v = getTimeInMillis() - that.getTimeInMillis()
        return if (v < 0) { -1 } else { (if (v > 0) { 1 } else { 0 }) }
    }

    public func getDateTimeFormat(dateStyle: Int32, timeStyle: Int32, loc: Locale): DateFormat {
        return formatHelper(this, ULocale.forLocale(loc), dateStyle, timeStyle)
    }

    public func getDateTimeFormat(dateStyle: Int32, timeStyle: Int32, loc: ULocale): DateFormat {
        return formatHelper(this, loc, dateStyle, timeStyle)
    }

    protected func handleGetDateFormat(pattern: String, locale: Locale): DateFormat {
        return handleGetDateFormat(pattern, None, ULocale.forLocale(locale))
    }

    protected func handleGetDateFormat(pattern: String, override: String, locale: Locale): DateFormat {
        return handleGetDateFormat(pattern, override, ULocale.forLocale(locale))
    }

    protected func handleGetDateFormat(pattern: String, locale: ULocale): DateFormat {
        return handleGetDateFormat(pattern, None, locale)
    }

    protected func handleGetDateFormat(pattern: String, override: String, locale: ULocale): DateFormat {
        let fmtConfig = Calendar_FormatConfiguration()
        fmtConfig.pattern = pattern
        fmtConfig.override = override
        fmtConfig.formatData = DateFormatSymbols(this, locale)
        fmtConfig.loc = locale
        fmtConfig.cal = this
        return SimpleDateFormat.getInstance(fmtConfig)
    }

    static let PATTERN_CACHE: ICUCache<String, Calendar_PatternData> = SimpleCache<String, Calendar_PatternData>()

    static let DEFAULT_PATTERNS: Array<String> = ["HH:mm:ss z", "HH:mm:ss z", "HH:mm:ss", "HH:mm", "y MMMM d, EEEE", "y MMMM d", "y MMM d", "y-MM-dd", "{1} {0}", "{1} {0}", "{1} {0}", "{1} {0}", "{1} {0}"]

    static let DEFAULT_ATTIME_PATTERNS: Array<String> = ["{1} {0}", "{1} {0}", "{1} {0}", "{1} {0}"]

    private static let TIME_SKELETONS: Array<String> = ["jmmsszzzz", "jmmssz", "jmmss", "jmm"]

    private static func formatHelper(cal: Calendar, loc: ULocale, dateStyle: Int32, timeStyle: Int32): DateFormat {
        if (timeStyle < DateFormat.NONE || timeStyle > DateFormat.SHORT) {
            throw IllegalArgumentException("Illegal time style " + timeStyle.toString())
        }
        if (dateStyle < DateFormat.NONE || dateStyle > DateFormat.SHORT) {
            throw IllegalArgumentException("Illegal date style " + dateStyle.toString())
        }
        let patternData = Calendar_PatternData.make(cal, loc)
        var override: String
        var pattern: String
        if ((timeStyle >= 0) && (dateStyle >= 0)) {
            pattern = SimpleFormatterImpl.formatRawPattern(patternData.getDateAtTimePattern(dateStyle), 2, 2, [patternData.patterns[Int64(timeStyle)], patternData.patterns[Int64(dateStyle + 4)]])
            if (patternData.overrides.isSome()) {
                let dateOverride = patternData.overrides[Int64(dateStyle + 4)]
                let timeOverride = patternData.overrides[Int64(timeStyle)]
                override = mergeOverrideStrings(patternData.patterns[Int64(dateStyle + 4)], patternData.patterns[Int64(timeStyle)], dateOverride, timeOverride)
            }
        } else if (timeStyle >= 0) {
            pattern = patternData.patterns[Int64(timeStyle)]
            if (patternData.overrides.isSome()) {
                override = patternData.overrides[Int64(timeStyle)]
            }
        } else if (dateStyle >= 0) {
            pattern = patternData.patterns[Int64(dateStyle + 4)]
            if (patternData.overrides.isSome()) {
                override = patternData.overrides[Int64(dateStyle + 4)]
            }
        } else {
            throw IllegalArgumentException("No date or time style specified")
        }
        let result = cal.handleGetDateFormat(pattern, override, loc)
        result.setCalendar(cal)
        return result
    }

    static func getPatternData(locale: ULocale, calType: String): Calendar_PatternData {
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, locale)
        var dtPatternsRb = rb.findWithFallback("calendar/" + (calType) + "/DateTimePatterns")
        if (dtPatternsRb.isNone()) {
            dtPatternsRb = rb.getWithFallback("calendar/gregorian/DateTimePatterns")
        }
        var patternsSize = dtPatternsRb.getSize()
        let dateTimePatterns = Array<String>(Int64(patternsSize))
        let dateTimePatternsOverrides = Array<String>(Int64(patternsSize))
        var i = 0
        var useDTPG = false
        if (locale.getKeywordValue("rg").isSome() || locale.getKeywordValue("hours").isSome()) {
            useDTPG = true
        } else {
            let baseLocID = locale.getBaseName()
            if (!baseLocID.isEmpty() && !(baseLocID == "und")) {
                let baseLoc = ULocale(baseLocID)
                let validLoc = ULocale.addLikelySubtags(dtPatternsRb.getULocale())
                if (!refEq(validLoc, baseLoc)) {
                    let baseReg = baseLoc.getCountry()
                    if ((!baseReg.isEmpty() && !baseReg.equals(validLoc.getCountry())) || !baseLoc.getLanguage().equals(validLoc.getLanguage())) {
                        useDTPG = true
                    }
                }
            }
        }
        if (useDTPG) {
            let dtpg = DateTimePatternGenerator.getInstanceNoStdPat(locale)
            while (i < Int32(TIME_SKELETONS.size)) {
                dateTimePatterns[Int64(i)] = dtpg.getBestPattern(TIME_SKELETONS[Int64(i)])
                i++
            }
        }
        while (i < patternsSize) {
            let concatenationPatternRb = dtPatternsRb.get(i)
            match (concatenationPatternRb.getType()) {
                case 0 => dateTimePatterns[Int64(i)] = concatenationPatternRb.getString()
                case 8 =>
                    dateTimePatterns[Int64(i)] = concatenationPatternRb.getString(0)
                    dateTimePatternsOverrides[Int64(i)] = concatenationPatternRb.getString(1)
                case _ => ()
            }
            i++
        }
        dtPatternsRb = rb.findWithFallback("calendar/" + (calType) + "/DateTimePatterns%atTime")
        if (dtPatternsRb.isNone()) {
            dtPatternsRb = rb.findWithFallback("calendar/gregorian/DateTimePatterns%atTime")
        }
        var atTimePatterns: Array<String>
        if (dtPatternsRb.isSome()) {
            patternsSize = dtPatternsRb.getSize()
            atTimePatterns = Array<String>(Int64(patternsSize))
            if (patternsSize >= 4) {
                i = 0
                while (i < 4) {
                    let concatenationPatternRb = dtPatternsRb.get(i)
                    if (concatenationPatternRb.getType() == UResourceBundle.STRING) {
                        atTimePatterns[Int64(i)] = concatenationPatternRb.getString()
                    }
                    i++
                }
            }
        }
        return Calendar_PatternData(dateTimePatterns, dateTimePatternsOverrides, atTimePatterns)
    }

    
    public static func getDateTimePattern(cal: Calendar, uLocale: ULocale, dateStyle: Int32): String {
        let patternData = Calendar_PatternData.make(cal, uLocale)
        return patternData.getDateTimePattern(dateStyle)
    }

    
    public static func getDateAtTimePattern(cal: Calendar, uLocale: ULocale, dateStyle: Int32): String {
        let patternData = Calendar_PatternData.make(cal, uLocale)
        return patternData.getDateAtTimePattern(dateStyle)
    }

    private static func mergeOverrideStrings(datePattern: String, timePattern: String, dateOverride: String, timeOverride: String): String {
        if (dateOverride.isNone() && timeOverride.isNone()) {
            return None
        }
        if (dateOverride.isNone()) {
            return expandOverride(timePattern, timeOverride)
        }
        if (timeOverride.isNone()) {
            return expandOverride(datePattern, dateOverride)
        }
        if (dateOverride.equals(timeOverride)) {
            return dateOverride
        }
        return (Some((expandOverride(datePattern, dateOverride)) + ";" + (expandOverride(timePattern, timeOverride))))
    }

    private static let QUOTE = '''

    private static func expandOverride(pattern: String, override: String): String {
        if (indexOfWrap(override.indexOf(UInt8(UInt32('=')))) >= 0) {
            return override
        }
        var inQuotes = false
        var prevChar = ' '
        let result = StringBuilder()
        let it = StringCharacterIterator(pattern)
        var c = it.first()
        while (c != StringCharacterIterator.DONE) {
            if (c == QUOTE) {
                inQuotes = !inQuotes
                prevChar = c
                continue
            }
            if (!inQuotes && c != prevChar) {
                if (Int32(result.size) > 0) {
                    result.append(";")
                }
                result.append(c)
                result.append("=")
                result.append(override)
            }
            prevChar = c
            c = it.next()
        }
        return result.toString()
    }

    protected func pinField(field: Int32): Unit {
        let max = getActualMaximum(field)
        let min = getActualMinimum(field)
        if (fields[Int64(field)] > max) {
            set(field, max)
        } else if (fields[Int64(field)] < min) {
            set(field, min)
        }
    }

    
    protected func isEra0CountingBackward(): Bool {
        return false
    }

    protected func weekNumber(desiredDay: Int32, dayOfPeriod: Int32, dayOfWeek: Int32): Int32 {
        var periodStartDayOfWeek = (dayOfWeek - getFirstDayOfWeek() - dayOfPeriod + 1) % 7
        if (periodStartDayOfWeek < 0) {
            periodStartDayOfWeek += 7
        }
        var weekNo = (desiredDay + periodStartDayOfWeek - 1) / 7
        if ((7 - periodStartDayOfWeek) >= getMinimalDaysInFirstWeek()) {
            weekNo++
        }
        return weekNo
    }

    protected func weekNumber(dayOfPeriod: Int32, dayOfWeek: Int32): Int32 {
        return weekNumber(dayOfPeriod, dayOfPeriod, dayOfWeek)
    }

    private static let FIELD_DIFF_MAX_INT = Int32.Max

    public func fieldDifference(when: DateTime, field: Int32): Int32 {
        var min = 0
        let startMs = getTimeInMillis()
        let targetMs = when.getTime()
        if (startMs < targetMs) {
            var max = 1
            while (true) {
                setTimeInMillis(startMs)
                add(field, max)
                let ms = getTimeInMillis()
                if (ms == targetMs) {
                    return max
                } else if (ms > targetMs) {
                    break
                } else if (max < FIELD_DIFF_MAX_INT) {
                    min = max
                    max <<= 1
                    if (max < 0) {
                        max = FIELD_DIFF_MAX_INT
                    }
                } else {
                    throw Exception()
                }
            }
            while ((max - min) > 1) {
                let t = min + (max - min) / 2
                setTimeInMillis(startMs)
                add(field, t)
                let ms = getTimeInMillis()
                if (ms == targetMs) {
                    return t
                } else if (ms > targetMs) {
                    max = t
                } else {
                    min = t
                }
            }
        } else if (startMs > targetMs) {
            var max = -1
            while (true) {
                setTimeInMillis(startMs)
                add(field, max)
                let ms = getTimeInMillis()
                if (ms == targetMs) {
                    return max
                } else if (ms < targetMs) {
                    break
                } else {
                    min = max
                    max <<= 1
                    if (max == 0) {
                        throw Exception()
                    }
                }
            }
            while ((min - max) > 1) {
                let t = min + (max - min) / 2
                setTimeInMillis(startMs)
                add(field, t)
                let ms = getTimeInMillis()
                if (ms == targetMs) {
                    return t
                } else if (ms < targetMs) {
                    max = t
                } else {
                    min = t
                }
            }
        }
        setTimeInMillis(startMs)
        add(field, min)
        return min
    }

    public func setTimeZone(value: TimeZone): Unit {
        zone = value
        areFieldsSet = false
    }

    public func getTimeZone(): TimeZone {
        return zone
    }

    public func setLenient(lenient: Bool): Unit {
        this.lenient = lenient
    }

    public func isLenient(): Bool {
        return lenient
    }

    public func setRepeatedWallTimeOption(option: Int32): Unit {
        if (option != WALLTIME_LAST && option != WALLTIME_FIRST) {
            throw IllegalArgumentException("Illegal repeated wall time option - " + option.toString())
        }
        repeatedWallTime = option
    }

    public func getRepeatedWallTimeOption(): Int32 {
        return repeatedWallTime
    }

    public func setSkippedWallTimeOption(option: Int32): Unit {
        if (option != WALLTIME_LAST && option != WALLTIME_FIRST && option != WALLTIME_NEXT_VALID) {
            throw IllegalArgumentException("Illegal skipped wall time option - " + option.toString())
        }
        skippedWallTime = option
    }

    public func getSkippedWallTimeOption(): Int32 {
        return skippedWallTime
    }

    public func setFirstDayOfWeek(value: Int32): Unit {
        if (firstDayOfWeek != value) {
            if (value < SUNDAY || value > SATURDAY) {
                throw IllegalArgumentException("Invalid day of week")
            }
            firstDayOfWeek = value
            areFieldsSet = false
        }
    }

    public func getFirstDayOfWeek(): Int32 {
        return firstDayOfWeek
    }

    public func setMinimalDaysInFirstWeek(value: Int32): Unit {
        var tempvalue = value
        if (tempvalue < 1) {
            tempvalue = 1
        } else if (tempvalue > 7) {
            tempvalue = 7
        }
        if (minimalDaysInFirstWeek != tempvalue) {
            minimalDaysInFirstWeek = tempvalue
            areFieldsSet = false
        }
    }

    public func getMinimalDaysInFirstWeek(): Int32 {
        return minimalDaysInFirstWeek
    }

    private static let LIMITS: Array<Array<Int32>> = [[0], [0], [0], [0], [0], [0], [0], [1, 1, 7, 7], [0], [0, 0, 1, 1], [0, 0, 11, 11], [0, 0, 23, 23], [0, 0, 59, 59], [0, 0, 59, 59], [0, 0, 999, 999], [-24 * ONE_HOUR, -16 * ONE_HOUR, 12 * ONE_HOUR, 30 * ONE_HOUR], [0, 0, 2 * ONE_HOUR, 2 * ONE_HOUR], [0], [1, 1, 7, 7], [0], [-2130706432, -2130706432, 2130706432, 2130706432], [0, 0, 24 * ONE_HOUR - 1, 24 * ONE_HOUR - 1], [0, 0, 1, 1], [0, 0, 12, 12]]

    protected func handleGetLimit(field: Int32, limitType: Int32): Int32

    protected func getLimit(field: Int32, limitType: Int32): Int32 {
        match (field) {
            case 7 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 18 | 20 | 21 | 22 => return LIMITS[Int64(field)][Int64(limitType)]
            case 4 =>
                let limit: Int32
                if (limitType == MINIMUM) {
                    limit = if (getMinimalDaysInFirstWeek() == 1) { 1 } else { 0 }
                } else if (limitType == GREATEST_MINIMUM) {
                    limit = 1
                } else {
                    let minDaysInFirst = getMinimalDaysInFirstWeek()
                    let daysInMonth = handleGetLimit(DAY_OF_MONTH, limitType)
                    if (limitType == LEAST_MAXIMUM) {
                        limit = (daysInMonth + (7 - minDaysInFirst)) / 7
                    } else {
                        limit = (daysInMonth + 6 + (7 - minDaysInFirst)) / 7
                    }
                }
                return limit
            case _ => ()
        }
        return handleGetLimit(field, limitType)
    }

    protected static let MINIMUM = 0

    protected static let GREATEST_MINIMUM = 1

    protected static let LEAST_MAXIMUM = 2

    protected static let MAXIMUM = 3

    public func getMinimum(field: Int32): Int32 {
        return getLimit(field, MINIMUM)
    }

    public func getMaximum(field: Int32): Int32 {
        return getLimit(field, MAXIMUM)
    }

    public func getGreatestMinimum(field: Int32): Int32 {
        return getLimit(field, GREATEST_MINIMUM)
    }

    public func getLeastMaximum(field: Int32): Int32 {
        return getLimit(field, LEAST_MAXIMUM)
    }

    
    public func getDayOfWeekType(dayOfWeek: Int32): Int32 {
        if (dayOfWeek < SUNDAY || dayOfWeek > SATURDAY) {
            throw IllegalArgumentException("Invalid day of week")
        }
        if (weekendOnset == weekendCease) {
            if (dayOfWeek != weekendOnset) {
                return WEEKDAY
            }
            return if (weekendOnsetMillis == 0) { WEEKEND } else { WEEKEND_ONSET }
        }
        if (weekendOnset < weekendCease) {
            if (dayOfWeek < weekendOnset || dayOfWeek > weekendCease) {
                return WEEKDAY
            }
        } else {
            if (dayOfWeek > weekendCease && dayOfWeek < weekendOnset) {
                return WEEKDAY
            }
        }
        if (dayOfWeek == weekendOnset) {
            return if (weekendOnsetMillis == 0) { WEEKEND } else { WEEKEND_ONSET }
        }
        if (dayOfWeek == weekendCease) {
            return if (weekendCeaseMillis >= 86400000) { WEEKEND } else { WEEKEND_CEASE }
        }
        return WEEKEND
    }

    
    public func getWeekendTransition(dayOfWeek: Int32): Int32 {
        if (dayOfWeek == weekendOnset) {
            return weekendOnsetMillis
        } else if (dayOfWeek == weekendCease) {
            return weekendCeaseMillis
        }
        throw IllegalArgumentException("Not weekend transition day")
    }

    public func isWeekend(date: DateTime): Bool {
        setTime(date)
        return isWeekend()
    }

    public func isWeekend(): Bool {
        let dow = get(DAY_OF_WEEK)
        let dowt = getDayOfWeekType(dow)
        match (dowt) {
            case 0 => return false
            case 1 => return true
            case _ =>
                let millisInDay = internalGet(MILLISECOND) + 1000 * (internalGet(SECOND) + 60 * (internalGet(MINUTE) + 60 * internalGet(HOUR_OF_DAY)))
                let transition = getWeekendTransition(dow)
                return if (dowt == WEEKEND_ONSET) { (millisInDay >= transition) } else { (millisInDay < transition) }
        }
    }

    public override func clone(): Object {
        try {
            let other = super.toString()
            other.fields = Array<Int32>(fields.size) { _ => 0 }
            other.stamp = Array<Int32>(fields.size) { _ => 0 }
            arraycopy(this.fields, 0, other.fields, 0, fields.size)
            arraycopy(this.stamp, 0, other.stamp, 0, fields.size)
            other.zone = zone.clone()
            return other
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException(e as Exception)
        }
    }

    public override func toString(): String {
        let buffer = StringBuilder()
        buffer.append(TypeInfo.of(this).name)
        buffer.append("[time=")
        buffer.append(if (isTimeSet) { time.toString() } else { '?' })
        buffer.append(",areFieldsSet=")
        buffer.append(areFieldsSet)
        buffer.append(",areAllFieldsSet=")
        buffer.append(areAllFieldsSet)
        buffer.append(",lenient=")
        buffer.append(lenient)
        buffer.append(",zone=")
        buffer.append(zone.asString())
        buffer.append(",firstDayOfWeek=")
        buffer.append(firstDayOfWeek)
        buffer.append(",minimalDaysInFirstWeek=")
        buffer.append(minimalDaysInFirstWeek)
        buffer.append(",repeatedWallTime=")
        buffer.append(repeatedWallTime)
        buffer.append(",skippedWallTime=")
        buffer.append(skippedWallTime)
        var i = 0
        while (i < Int32(fields.size)) {
            buffer.append(',').append(fieldName(i)).append('=')
            buffer.append(if (isSet(i)) { fields[Int64(i)].toString() } else { '?' })
            i++
        }
        buffer.append(']')
        return buffer.toString()
    }

    public static func getWeekDataForRegion(region: String): Calendar_WeekData {
        return WEEK_DATA_CACHE.createInstance(region, region)
    }

    public func getWeekData(): Calendar_WeekData {
        return Calendar_WeekData(firstDayOfWeek, minimalDaysInFirstWeek, weekendOnset, weekendOnsetMillis, weekendCease, weekendCeaseMillis)
    }

    public func setWeekData(wdata: Calendar_WeekData): Calendar {
        setFirstDayOfWeek(wdata.firstDayOfWeek)
        setMinimalDaysInFirstWeek(wdata.minimalDaysInFirstWeek)
        weekendOnset = wdata.weekendOnset
        weekendOnsetMillis = wdata.weekendOnsetMillis
        weekendCease = wdata.weekendCease
        weekendCeaseMillis = wdata.weekendCeaseMillis
        return this
    }

    static func getWeekDataForRegionInternal(region: String): Calendar_WeekData {
        var tempregion = region
        if (tempregion.isNone()) {
            tempregion = "001"
        }
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "supplementalData", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
        let weekDataInfo = rb.get("weekData")
        var weekDataBundle: UResourceBundle
        try {
            weekDataBundle = weekDataInfo.get(tempregion)
        } catch (mre: MissingResourceException) {
            if (!(tempregion == "001")) {
                weekDataBundle = weekDataInfo.get("001")
            } else {
                throw mre
            }
        }
        let wdi = weekDataBundle.getIntVector()
        return Calendar_WeekData(wdi[0], wdi[1], wdi[2], wdi[3], wdi[4], wdi[5])
    }

    private static let WEEK_DATA_CACHE = Calendar_WeekDataCache()

    private func setWeekData(region: String): Unit {
        var tempregion = region
        if (tempregion.isNone()) {
            tempregion = "001"
        }
        let wdata = WEEK_DATA_CACHE.getInstance(tempregion, tempregion)
        setWeekData(wdata)
    }

    private func updateTime(): Unit {
        computeTime()
        if (isLenient() || !areAllFieldsSet) {
            areFieldsSet = false
        }
        isTimeSet = true
        areFieldsVirtuallySet = false
    }

    private func writeObject(stream: ObjectOutputStream): Unit {
        if (!isTimeSet) {
            try {
                updateTime()
            })
        }
        stream.defaultWriteObject()
    }

    private func readObject(stream: ObjectInputStream): Unit {
        stream.defaultReadObject()
        initInternal()
        isTimeSet = true
        areFieldsSet = match (0) { case _ => areAllFieldsSet = false; areAllFieldsSet }
        areFieldsVirtuallySet = true
        nextStamp = MINIMUM_USER_STAMP
    }

    protected func computeFields(): Unit {
        let offsets = Array<Int32>(2) { _ => 0 }
        getTimeZone().getOffset(time, false, offsets)
        let localMillis = time + Int64(offsets[0]) + Int64(offsets[1])
        var mask = internalSetMask
        var i = 0
        while (i < Int32(fields.size)) {
            if ((mask & 1) == 0) {
                stamp[Int64(i)] = INTERNALLY_SET
            } else {
                stamp[Int64(i)] = UNSET
            }
            mask >>= 1
            i++
        }
        let days = floorDivide(localMillis, ONE_DAY)
        fields[Int64(JULIAN_DAY)] = Int32(days) + EPOCH_JULIAN_DAY
        computeGregorianAndDOWFields(fields[Int64(JULIAN_DAY)])
        handleComputeFields(fields[Int64(JULIAN_DAY)])
        computeWeekFields()
        var millisInDay = Int32(localMillis - (days * ONE_DAY))
        fields[Int64(MILLISECONDS_IN_DAY)] = millisInDay
        fields[Int64(MILLISECOND)] = millisInDay % 1000
        millisInDay /= 1000
        fields[Int64(SECOND)] = millisInDay % 60
        millisInDay /= 60
        fields[Int64(MINUTE)] = millisInDay % 60
        millisInDay /= 60
        fields[Int64(HOUR_OF_DAY)] = millisInDay
        fields[Int64(AM_PM)] = millisInDay / 12
        fields[Int64(HOUR)] = millisInDay % 12
        fields[Int64(ZONE_OFFSET)] = offsets[0]
        fields[Int64(DST_OFFSET)] = offsets[1]
    }

    private func computeGregorianAndDOWFields(julianDay: Int32): Unit {
        computeGregorianFields(julianDay)
        let dow = match (0) { case _ => fields[Int64(DAY_OF_WEEK)] = julianDayToDayOfWeek(julianDay); fields[Int64(DAY_OF_WEEK)] }
        var dowLocal = dow - getFirstDayOfWeek() + 1
        if (dowLocal < 1) {
            dowLocal += 7
        }
        fields[Int64(DOW_LOCAL)] = dowLocal
    }

    protected func computeGregorianFields(julianDay: Int32): Unit {
        var year: Int32 = 0
        let month: Int32
        let dayOfMonth: Int32
        var dayOfYear: Int32 = 0
        let gregorianEpochDay = Int64(julianDay - JAN_1_1_JULIAN_DAY)
        let rem = Array<Int32>(1) { _ => 0 }
        let n400 = floorDivide(gregorianEpochDay, 146097, rem)
        let n100 = floorDivide(rem[0], 36524, rem)
        let n4 = floorDivide(rem[0], 1461, rem)
        let n1 = floorDivide(rem[0], 365, rem)
        year = 400 * n400 + 100 * n100 + 4 * n4 + n1
        dayOfYear = rem[0]
        if (n100 == 4 || n1 == 4) {
            dayOfYear = 365
        } else {
            year++
        }
        let isLeap = ((year & 3) == 0) && (year % 100 != 0 || year % 400 == 0)
        var correction = 0
        let march1 = if (isLeap) { 60 } else { 59 }
        if (dayOfYear >= march1) {
            correction = if (isLeap) { 1 } else { 2 }
        }
        month = (12 * (dayOfYear + correction) + 6) / 367
        dayOfMonth = dayOfYear - GREGORIAN_MONTH_COUNT[Int64(month)][if (isLeap) { 3 } else { 2 }] + 1
        gregorianYear = year
        gregorianMonth = month
        gregorianDayOfMonth = dayOfMonth
        gregorianDayOfYear = dayOfYear + 1
    }

    private func computeWeekFields(): Unit {
        let eyear = fields[Int64(EXTENDED_YEAR)]
        let dayOfWeek = fields[Int64(DAY_OF_WEEK)]
        let dayOfYear = fields[Int64(DAY_OF_YEAR)]
        var yearOfWeekOfYear = eyear
        let relDow = (dayOfWeek + 7 - getFirstDayOfWeek()) % 7
        let relDowJan1 = (dayOfWeek - dayOfYear + 7001 - getFirstDayOfWeek()) % 7
        var woy = (dayOfYear - 1 + relDowJan1) / 7
        if ((7 - relDowJan1) >= getMinimalDaysInFirstWeek()) {
            woy++
        }
        if (woy == 0) {
            let prevDoy = dayOfYear + handleGetYearLength(eyear - 1)
            woy = weekNumber(prevDoy, dayOfWeek)
            yearOfWeekOfYear--
        } else {
            let lastDoy = handleGetYearLength(eyear)
            if (dayOfYear >= (lastDoy - 5)) {
                var lastRelDow = (relDow + lastDoy - dayOfYear) % 7
                if (lastRelDow < 0) {
                    lastRelDow += 7
                }
                if (((6 - lastRelDow) >= getMinimalDaysInFirstWeek()) && ((dayOfYear + 7 - relDow) > lastDoy)) {
                    woy = 1
                    yearOfWeekOfYear++
                }
            }
        }
        fields[Int64(WEEK_OF_YEAR)] = woy
        fields[Int64(YEAR_WOY)] = yearOfWeekOfYear
        let dayOfMonth = fields[Int64(DAY_OF_MONTH)]
        fields[Int64(WEEK_OF_MONTH)] = weekNumber(dayOfMonth, dayOfWeek)
        fields[Int64(DAY_OF_WEEK_IN_MONTH)] = (dayOfMonth - 1) / 7 + 1
    }

    protected static let RESOLVE_REMAP = 32

    static let DATE_PRECEDENCE = [[[DAY_OF_MONTH], [WEEK_OF_YEAR, DAY_OF_WEEK], [WEEK_OF_MONTH, DAY_OF_WEEK], [DAY_OF_WEEK_IN_MONTH, DAY_OF_WEEK], [WEEK_OF_YEAR, DOW_LOCAL], [WEEK_OF_MONTH, DOW_LOCAL], [DAY_OF_WEEK_IN_MONTH, DOW_LOCAL], [DAY_OF_YEAR], [RESOLVE_REMAP | DAY_OF_MONTH, YEAR], [RESOLVE_REMAP | WEEK_OF_YEAR, YEAR_WOY]], [[WEEK_OF_YEAR], [WEEK_OF_MONTH], [DAY_OF_WEEK_IN_MONTH], [RESOLVE_REMAP | DAY_OF_WEEK_IN_MONTH, DAY_OF_WEEK], [RESOLVE_REMAP | DAY_OF_WEEK_IN_MONTH, DOW_LOCAL]]]

    static let DOW_PRECEDENCE = [[[DAY_OF_WEEK], [DOW_LOCAL]]]

    static let MONTH_PRECEDENCE = [[[MONTH], [ORDINAL_MONTH]]]

    protected func resolveFields(precedenceTable: Array<Array<Array<Int32>>>): Int32 {
        var bestField = -1
        var tempBestField: Int32 = 0
        var g = 0
        while (g < Int32(precedenceTable.size) && bestField < 0) {
            let group: Array<Array<Int32>> = precedenceTable[Int64(g)]
            var bestStamp = UNSET
    protected func newestStamp(first: Int32, last: Int32, bestStampSoFar: Int32): Int32 {
        var bestStamp = bestStampSoFar
        var i = first
        while (i <= last) {
            if (stamp[Int64(i)] > bestStamp) {
                bestStamp = stamp[Int64(i)]
            }
            i++
        }
        return bestStamp
    }

    protected func getStamp(field: Int32): Int32 {
        return stamp[Int64(field)]
    }

    protected func newerField(defaultField: Int32, alternateField: Int32): Int32 {
        if (stamp[Int64(alternateField)] > stamp[Int64(defaultField)]) {
            return alternateField
        }
        return defaultField
    }

    protected func validateFields(): Unit {
        var field = 0
        while (field < Int32(fields.size)) {
            if (stamp[Int64(field)] >= MINIMUM_USER_STAMP) {
                validateField(field)
            }
            field++
        }
    }

    protected func validateField(field: Int32): Unit {
        let y: Int32
        match (field) {
            case 5 =>
                y = handleGetExtendedYear()
                validateField(field, 1, handleGetMonthLength(y, internalGetMonth()))
            case 6 =>
                y = handleGetExtendedYear()
                validateField(field, 1, handleGetYearLength(y))
            case 8 =>
                if (internalGet(field) == 0) {
                    throw IllegalArgumentException("DAY_OF_WEEK_IN_MONTH cannot be zero")
                }
                validateField(field, getMinimum(field), getMaximum(field))
            case _ => validateField(field, getMinimum(field), getMaximum(field))
        }
    }

    protected func validateField(field: Int32, min: Int32, max: Int32): Unit {
        let value = fields[Int64(field)]
        if (value < min || value > max) {
            throw IllegalArgumentException((fieldName(field)) + '='.toString() + value.toString() + ", valid range=" + min.toString() + ".." + max.toString())
        }
    }

    protected func computeTime(): Unit {
        if (!isLenient()) {
            validateFields()
        }
        let julianDay = computeJulianDay()
        let millis = julianDayToMillis(julianDay)
        let millisInDay: Int64
        if (stamp[Int64(MILLISECONDS_IN_DAY)] >= MINIMUM_USER_STAMP && newestStamp(AM_PM, MILLISECOND, UNSET) <= stamp[Int64(MILLISECONDS_IN_DAY)]) {
            millisInDay = Int64(internalGet(MILLISECONDS_IN_DAY))
        } else {
            var hour = abs(internalGet(HOUR_OF_DAY))
            hour = max(hour, abs(internalGet(HOUR)))
            if (hour > MAX_HOURS) {
                millisInDay = computeMillisInDayLong()
            } else {
                millisInDay = Int64(computeMillisInDay())
            }
        }
        if (stamp[Int64(ZONE_OFFSET)] >= MINIMUM_USER_STAMP || stamp[Int64(DST_OFFSET)] >= MINIMUM_USER_STAMP) {
            time = millis + millisInDay - (Int64(internalGet(ZONE_OFFSET) + internalGet(DST_OFFSET)))
        } else {
            if (!lenient || skippedWallTime == WALLTIME_NEXT_VALID) {
                let zoneOffset = computeZoneOffset(millis, millisInDay)
                let tmpTime = millis + millisInDay - Int64(zoneOffset)
                let zoneOffset1 = zone.getOffset(tmpTime)
                if (zoneOffset != zoneOffset1) {
                    if (!lenient) {
                        throw IllegalArgumentException("The specified wall time does not exist due to time zone offset transition.")
                    }
                    if (!(skippedWallTime == WALLTIME_NEXT_VALID)) {
                        throw AssertionError(skippedWallTime)
                    }
                    let immediatePrevTransition = getImmediatePreviousZoneTransition(tmpTime)
                    if (immediatePrevTransition.isNone()) {
                        throw Exception("Could not locate a time zone transition before " + tmpTime.toString())
                    }
                    time = immediatePrevTransition
                } else {
                    time = tmpTime
                }
            } else {
                time = millis + millisInDay - Int64(computeZoneOffset(millis, millisInDay))
            }
        }
    }

    private func getImmediatePreviousZoneTransition(base: Int64): Int64 {
        var transitionTime: Int64
        if (checkOptionalIs<BasicTimeZone, TimeZone>(zone)) {
            let transition = zone.getPreviousTransition(base, true)
            if (transition.isSome()) {
                transitionTime = transition.getTime()
            }
        } else {
            transitionTime = getPreviousZoneTransitionTime(zone, base, Int64(2 * 60 * 60 * 1000))
            if (transitionTime.isNone()) {
                transitionTime = getPreviousZoneTransitionTime(zone, base, Int64(30 * 60 * 60 * 1000))
            }
        }
        return transitionTime
    }

    private static func getPreviousZoneTransitionTime(tz: TimeZone, base: Int64, duration: Int64): Int64 {
        if (!(duration > 0)) {
            throw AssertionError()
        }
        let upper = base
        let lower = base - duration - 1
        let offsetU = tz.getOffset(upper)
        let offsetL = tz.getOffset(lower)
        if (offsetU == offsetL) {
            return None
        }
        return findPreviousZoneTransitionTime(tz, offsetU, upper, lower)
    }

    private static let FIND_ZONE_TRANSITION_TIME_UNITS = [60 * 60 * 1000, 30 * 60 * 1000, 60 * 1000, 1000]

    private static func findPreviousZoneTransitionTime(tz: TimeZone, upperOffset: Int32, upper: Int64, lower: Int64): Int64 {
        var tempupper = upper
        var onUnitTime = false
        var mid = 0
        for (unit in FIND_ZONE_TRANSITION_TIME_UNITS) {
            let lunits = lower / Int64(unit)
            let uunits = tempupper / Int64(unit)
            if (uunits > lunits) {
                mid = (ushr((lunits + uunits + 1), 1)) * Int64(unit)
                onUnitTime = true
                break
            }
        }
        var midOffset: Int32 = 0
        if (!onUnitTime) {
            mid = ushr((tempupper + lower), 1)
        }
        if (onUnitTime) {
            if (mid != tempupper) {
                midOffset = tz.getOffset(mid)
                if (midOffset != upperOffset) {
                    return findPreviousZoneTransitionTime(tz, upperOffset, tempupper, mid)
                }
                tempupper = mid
            }
            mid--
        } else {
            mid = ushr((tempupper + lower), 1)
        }
        if (mid == lower) {
            return tempupper
        }
        midOffset = tz.getOffset(mid)
        if (midOffset != upperOffset) {
            if (onUnitTime) {
                return tempupper
            }
            return findPreviousZoneTransitionTime(tz, upperOffset, tempupper, mid)
        }
        return findPreviousZoneTransitionTime(tz, upperOffset, mid, lower)
    }

    
    protected func computeMillisInDay(): Int32 {
        var millisInDay = 0
        let hourOfDayStamp = stamp[Int64(HOUR_OF_DAY)]
        let hourStamp = max(stamp[Int64(HOUR)], stamp[Int64(AM_PM)])
        let bestStamp = if (hourStamp > hourOfDayStamp) { hourStamp } else { hourOfDayStamp }
        if (bestStamp != UNSET) {
            if (bestStamp == hourOfDayStamp) {
                millisInDay += internalGet(HOUR_OF_DAY)
            } else {
                millisInDay += internalGet(HOUR)
                millisInDay += 12 * internalGet(AM_PM)
            }
        }
        millisInDay *= 60
        millisInDay += internalGet(MINUTE)
        millisInDay *= 60
        millisInDay += internalGet(SECOND)
        millisInDay *= 1000
        millisInDay += internalGet(MILLISECOND)
        return millisInDay
    }

    
    protected func computeMillisInDayLong(): Int64 {
        var millisInDay = 0
        let hourOfDayStamp = stamp[Int64(HOUR_OF_DAY)]
        let hourStamp = max(stamp[Int64(HOUR)], stamp[Int64(AM_PM)])
        let bestStamp = if (hourStamp > hourOfDayStamp) { hourStamp } else { hourOfDayStamp }
        if (bestStamp != UNSET) {
            if (bestStamp == hourOfDayStamp) {
                millisInDay += Int64(internalGet(HOUR_OF_DAY))
            } else {
                millisInDay += Int64(internalGet(HOUR))
                millisInDay += Int64(12 * internalGet(AM_PM))
            }
        }
        millisInDay *= 60
        millisInDay += Int64(internalGet(MINUTE))
        millisInDay *= 60
        millisInDay += Int64(internalGet(SECOND))
        millisInDay *= 1000
        millisInDay += Int64(internalGet(MILLISECOND))
        return millisInDay
    }

    
    protected func computeZoneOffset(millis: Int64, millisInDay: Int32): Int32 {
        let offsets = Array<Int32>(2) { _ => 0 }
        let wall = millis + Int64(millisInDay)
        if (checkOptionalIs<BasicTimeZone, TimeZone>(zone)) {
            let nonExistingTimeOpt: BasicTimeZone_LocalOption = if (skippedWallTime == WALLTIME_FIRST) { BasicTimeZone_LocalOption.LATTER } else { BasicTimeZone_LocalOption.FORMER }
            let duplicatedTimeOpt: BasicTimeZone_LocalOption = if (repeatedWallTime == WALLTIME_FIRST) { BasicTimeZone_LocalOption.FORMER } else { BasicTimeZone_LocalOption.LATTER }
            zone.getOffsetFromLocal(wall, nonExistingTimeOpt, duplicatedTimeOpt, offsets)
        } else {
            zone.getOffset(wall, true, offsets)
            var sawRecentNegativeShift = false
            if (repeatedWallTime == WALLTIME_FIRST) {
                let tgmt = wall - (Int64(offsets[0] + offsets[1]))
                let offsetBefore6 = zone.getOffset(tgmt - Int64(6 * 60 * 60 * 1000))
                let offsetDelta = (offsets[0] + offsets[1]) - offsetBefore6
                if (!(offsetDelta > -6 * 60 * 60 * 1000)) {
                    throw AssertionError(offsetDelta)
                }
                if (offsetDelta < 0) {
                    sawRecentNegativeShift = true
                    zone.getOffset(wall + Int64(offsetDelta), true, offsets)
                }
            }
            if (!sawRecentNegativeShift && skippedWallTime == WALLTIME_FIRST) {
                let tgmt = wall - (Int64(offsets[0] + offsets[1]))
                zone.getOffset(tgmt, false, offsets)
            }
        }
        return offsets[0] + offsets[1]
    }

    
    protected func computeZoneOffset(millis: Int64, millisInDay: Int64): Int32 {
        let offsets = Array<Int32>(2) { _ => 0 }
        let wall = millis + millisInDay
        if (checkOptionalIs<BasicTimeZone, TimeZone>(zone)) {
            let nonExistingTimeOpt: BasicTimeZone_LocalOption = if (skippedWallTime == WALLTIME_FIRST) { BasicTimeZone_LocalOption.LATTER } else { BasicTimeZone_LocalOption.FORMER }
            let duplicatedTimeOpt: BasicTimeZone_LocalOption = if (repeatedWallTime == WALLTIME_FIRST) { BasicTimeZone_LocalOption.FORMER } else { BasicTimeZone_LocalOption.LATTER }
            zone.getOffsetFromLocal(wall, nonExistingTimeOpt, duplicatedTimeOpt, offsets)
        } else {
            zone.getOffset(wall, true, offsets)
            var sawRecentNegativeShift = false
            if (repeatedWallTime == WALLTIME_FIRST) {
                let tgmt = wall - (Int64(offsets[0] + offsets[1]))
                let offsetBefore6 = zone.getOffset(tgmt - Int64(6 * 60 * 60 * 1000))
                let offsetDelta = (offsets[0] + offsets[1]) - offsetBefore6
                if (!(offsetDelta > -6 * 60 * 60 * 1000)) {
                    throw AssertionError(offsetDelta)
                }
                if (offsetDelta < 0) {
                    sawRecentNegativeShift = true
                    zone.getOffset(wall + Int64(offsetDelta), true, offsets)
                }
            }
            if (!sawRecentNegativeShift && skippedWallTime == WALLTIME_FIRST) {
                let tgmt = wall - (Int64(offsets[0] + offsets[1]))
                zone.getOffset(tgmt, false, offsets)
            }
        }
        return offsets[0] + offsets[1]
    }

    protected func computeJulianDay(): Int32 {
        if (stamp[Int64(JULIAN_DAY)] >= MINIMUM_USER_STAMP) {
            var bestStamp = newestStamp(ERA, DAY_OF_WEEK_IN_MONTH, UNSET)
            bestStamp = newestStamp(YEAR_WOY, EXTENDED_YEAR, bestStamp)
            bestStamp = newestStamp(ORDINAL_MONTH, ORDINAL_MONTH, bestStamp)
            if (bestStamp <= stamp[Int64(JULIAN_DAY)]) {
                return internalGet(JULIAN_DAY)
            }
        }
        var bestField = resolveFields(getFieldResolutionTable())
        if (bestField < 0) {
            bestField = DAY_OF_MONTH
        }
        return handleComputeJulianDay(bestField)
    }

    protected func getFieldResolutionTable(): Array<Array<Array<Int32>>> {
        return DATE_PRECEDENCE
    }

    protected func handleComputeMonthStart(eyear: Int32, month: Int32, useMonth: Bool): Int32

    protected func handleGetExtendedYear(): Int32

    protected func handleGetMonthLength(extendedYear: Int32, month: Int32): Int32 {
        return handleComputeMonthStart(extendedYear, month + 1, true) - handleComputeMonthStart(extendedYear, month, true)
    }

    protected func handleGetYearLength(eyear: Int32): Int32 {
        return handleComputeMonthStart(eyear + 1, 0, false) - handleComputeMonthStart(eyear, 0, false)
    }

    protected func handleCreateFields(): Array<Int32> {
        return Array<Int32>(Int64(BASE_FIELD_COUNT)) { _ => 0 }
    }

    protected func getDefaultMonthInYear(extendedYear: Int32): Int32 {
        return Calendar.JANUARY
    }

    protected func getDefaultDayInMonth(extendedYear: Int32, month: Int32): Int32 {
        return 1
    }

    protected func handleComputeJulianDay(bestField: Int32): Int32 {
        let useMonth = (bestField == DAY_OF_MONTH || bestField == WEEK_OF_MONTH || bestField == DAY_OF_WEEK_IN_MONTH)
        let year: Int32
        if (bestField == WEEK_OF_YEAR && newerField(YEAR_WOY, YEAR) == YEAR_WOY) {
            year = internalGet(YEAR_WOY)
        } else {
            year = handleGetExtendedYear()
        }
        internalSet(EXTENDED_YEAR, year)
        if (Int64(year) > Int64.Max / 400) {
            throw IllegalArgumentException("year is too large")
        }
        let month = if (useMonth) { internalGetMonth(getDefaultMonthInYear(year)) } else { 0 }
        let julianDay = handleComputeMonthStart(year, month, useMonth)
        if (bestField == DAY_OF_MONTH) {
            if (isSet(DAY_OF_MONTH)) {
                return julianDay + internalGet(DAY_OF_MONTH, getDefaultDayInMonth(year, month))
            } else {
                return julianDay + getDefaultDayInMonth(year, month)
            }
        }
        if (bestField == DAY_OF_YEAR) {
            return julianDay + internalGet(DAY_OF_YEAR)
        }
        let firstDOW = getFirstDayOfWeek()
        var first = julianDayToDayOfWeek(julianDay + 1) - firstDOW
        if (first < 0) {
            first += 7
        }
        var dowLocal = 0
        match (resolveFields(DOW_PRECEDENCE)) {
            case 7 => dowLocal = internalGet(DAY_OF_WEEK) - firstDOW
            case 18 => dowLocal = internalGet(DOW_LOCAL) - 1
            case _ => ()
        }
        dowLocal = dowLocal % 7
        if (dowLocal < 0) {
            dowLocal += 7
        }
        var date = 1 - first + dowLocal
        if (bestField == DAY_OF_WEEK_IN_MONTH) {
            if (date < 1) {
                date += 7
            }
            let dim = internalGet(DAY_OF_WEEK_IN_MONTH, 1)
            if (dim >= 0) {
                date += 7 * (dim - 1)
            } else {
                let m = internalGetMonth(JANUARY)
                let monthLength = handleGetMonthLength(year, m)
                date += ((monthLength - date) / 7 + dim + 1) * 7
            }
        } else {
            if ((7 - first) < getMinimalDaysInFirstWeek()) {
                date += 7
            }
            date += 7 * (internalGet(bestField) - 1)
        }
        return julianDay + date
    }

    protected func computeGregorianMonthStart(year: Int32, month: Int32): Int32 {
        var tempyear = year
        var tempmonth = month
        if (tempmonth < 0 || tempmonth > 11) {
            let rem = Array<Int32>(1) { _ => 0 }
            tempyear += floorDivide(tempmonth, 12, rem)
            tempmonth = rem[0]
        }
        let isLeap = (tempyear % 4 == 0) && ((tempyear % 100 != 0) || (tempyear % 400 == 0))
        let y = tempyear - 1
        var julianDay = 365 * y + floorDivide(y, 4) - floorDivide(y, 100) + floorDivide(y, 400) + JAN_1_1_JULIAN_DAY - 1
        if (tempmonth != 0) {
            julianDay += GREGORIAN_MONTH_COUNT[Int64(tempmonth)][if (isLeap) { 3 } else { 2 }]
        }
        return julianDay
    }

    protected func handleComputeFields(julianDay: Int32): Unit {
        let gmonth = getGregorianMonth()
        internalSet(MONTH, gmonth)
        internalSet(ORDINAL_MONTH, gmonth)
        internalSet(DAY_OF_MONTH, getGregorianDayOfMonth())
        internalSet(DAY_OF_YEAR, getGregorianDayOfYear())
        var eyear = getGregorianYear()
        internalSet(EXTENDED_YEAR, eyear)
        var era = GregorianCalendar.AD
        if (eyear < 1) {
            era = GregorianCalendar.BC
            eyear = 1 - eyear
        }
        internalSet(ERA, era)
        internalSet(YEAR, eyear)
    }

    protected func getGregorianYear(): Int32 {
        return gregorianYear
    }

    protected func getGregorianMonth(): Int32 {
        return gregorianMonth
    }

    protected func getGregorianDayOfYear(): Int32 {
        return gregorianDayOfYear
    }

    protected func getGregorianDayOfMonth(): Int32 {
        return gregorianDayOfMonth
    }

    public func getFieldCount(): Int32 {
        return Int32(fields.size)
    }

    protected func internalSet(field: Int32, value: Int32): Unit {
        if (((shl(1, field)) & internalSetMask) == 0) {
            throw Exception("Subclass cannot set " + (fieldName(field)))
        }
        fields[Int64(field)] = value
        stamp[Int64(field)] = INTERNALLY_SET
    }

    private static let GREGORIAN_MONTH_COUNT = [[31, 31, 0, 0], [28, 29, 31, 31], [31, 31, 59, 60], [30, 30, 90, 91], [31, 31, 120, 121], [30, 30, 151, 152], [31, 31, 181, 182], [31, 31, 212, 213], [30, 30, 243, 244], [31, 31, 273, 274], [30, 30, 304, 305], [31, 31, 334, 335]]

    protected static func isGregorianLeapYear(year: Int32): Bool {
        return (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0))
    }

    protected static func gregorianMonthLength(y: Int32, m: Int32): Int32 {
        return GREGORIAN_MONTH_COUNT[Int64(m)][if (isGregorianLeapYear(y)) { 1 } else { 0 }]
    }

    protected static func gregorianPreviousMonthLength(y: Int32, m: Int32): Int32 {
        return if (m > 0) { gregorianMonthLength(y, m - 1) } else { 31 }
    }

    protected static func floorDivide(numerator: Int64, denominator: Int64): Int64 {
        return if (numerator >= 0) { numerator / denominator } else { ((numerator + 1) / denominator) - 1 }
    }

    protected static func floorDivide(numerator: Int32, denominator: Int32): Int32 {
        return if (numerator >= 0) { numerator / denominator } else { ((numerator + 1) / denominator) - 1 }
    }

    protected static func floorDivide(numerator: Int32, denominator: Int32, remainder: Array<Int32>): Int32 {
        if (numerator >= 0) {
            remainder[0] = numerator % denominator
            return numerator / denominator
        }
        let quotient = ((numerator + 1) / denominator) - 1
        remainder[0] = numerator - (quotient * denominator)
        return quotient
    }

    protected static func floorDivide(numerator: Int64, denominator: Int32, remainder: Array<Int32>): Int32 {
        if (numerator >= 0) {
            remainder[0] = Int32(numerator % Int64(denominator))
            return Int32(numerator / Int64(denominator))
        }
        let quotient = Int32(((numerator + 1) / Int64(denominator)) - 1)
        remainder[0] = Int32(numerator - (Int64(quotient) * Int64(denominator)))
        return quotient
    }

    private static let FIELD_NAME: Array<String> = ["ERA", "YEAR", "MONTH", "WEEK_OF_YEAR", "WEEK_OF_MONTH", "DAY_OF_MONTH", "DAY_OF_YEAR", "DAY_OF_WEEK", "DAY_OF_WEEK_IN_MONTH", "AM_PM", "HOUR", "HOUR_OF_DAY", "MINUTE", "SECOND", "MILLISECOND", "ZONE_OFFSET", "DST_OFFSET", "YEAR_WOY", "DOW_LOCAL", "EXTENDED_YEAR", "JULIAN_DAY", "MILLISECONDS_IN_DAY", "IS_LEAP_MONTH", "ORDINAL_MONTH"]

    protected func fieldName(field: Int32): String {
        try {
            return FIELD_NAME[Int64(field)]
        } catch (e: IndexOutOfBoundsException) {
            return "Field " + field.toString()
        }
    }

    protected static func millisToJulianDay(millis: Int64): Int32 {
        return Int32(Int64(EPOCH_JULIAN_DAY) + floorDivide(millis, ONE_DAY))
    }

    protected static func julianDayToMillis(julian: Int32): Int64 {
        return (Int64(julian - EPOCH_JULIAN_DAY)) * ONE_DAY
    }

    protected static func julianDayToDayOfWeek(julian: Int32): Int32 {
        var dayOfWeek = (julian + MONDAY) % 7
        if (dayOfWeek < SUNDAY) {
            dayOfWeek += 7
        }
        return dayOfWeek
    }

    protected func internalGetTimeInMillis(): Int64 {
        return time
    }

    public func getType(): String {
        return "unknown"
    }

    
    public func haveDefaultCentury(): Bool {
        return true
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
}


class Calendar_PatternData {
    var patterns: Array<String>

    var overrides: Array<String>

    private var atTimePatterns: Array<String>

    public init(patterns: Array<String>, overrides: Array<String>, atTimePatterns: Array<String>) {
        this.patterns = patterns
        this.overrides = overrides
        this.atTimePatterns = atTimePatterns
    }

    public func getDateTimePattern(dateStyle: Int32): String {
        var glueIndex = 8
        if (Int32(patterns.size) >= 13) {
            glueIndex += (dateStyle + 1)
        }
        let dateTimePattern = patterns[Int64(glueIndex)]
        return dateTimePattern
    }

    public func getDateAtTimePattern(dateStyle: Int32): String {
        if (atTimePatterns.isSome() && Int32(atTimePatterns.size) >= 4) {
            let dateTimePattern = atTimePatterns[Int64(dateStyle)]
            return dateTimePattern
        } else {
            return getDateTimePattern(dateStyle)
        }
    }

    static func make(cal: Calendar, loc: ULocale): Calendar_PatternData {
        let calType = cal.getType()
        let key: String = (loc.getBaseName()) + "+" + (calType)
        var patternData: Calendar_PatternData
        let hasHourCycleKeywords = loc.getKeywordValue("rg").isSome() || loc.getKeywordValue("hours").isSome()
        if (!hasHourCycleKeywords) {
            patternData = Calendar.PATTERN_CACHE.get(key)
        }
        if (patternData.isNone()) {
            try {
                patternData = Calendar.getPatternData(loc, calType)
            } catch (e: MissingResourceException) {
                patternData = Calendar_PatternData(Calendar.DEFAULT_PATTERNS, None, Calendar.DEFAULT_ATTIME_PATTERNS)
            }
            if (!hasHourCycleKeywords) {
                Calendar.PATTERN_CACHE.put(key, patternData)
            }
        }
        return patternData
    }
}



public class Calendar_FormatConfiguration {
    var pattern: String

    var override: String

    var formatData: DateFormatSymbols

    var cal: Calendar

    var loc: ULocale


    
    public func getPatternString(): String {
        return pattern
    }

    
    public func getOverrideString(): String {
        return override
    }

    
    public func getCalendar(): Calendar {
        return cal
    }

    
    public func getLocale(): ULocale {
        return loc
    }

    
    public func getDateFormatSymbols(): DateFormatSymbols {
        return formatData
    }
}


public class Calendar_WeekData {
    public let firstDayOfWeek: Int32

    public let minimalDaysInFirstWeek: Int32

    public let weekendOnset: Int32

    public let weekendOnsetMillis: Int32

    public let weekendCease: Int32

    public let weekendCeaseMillis: Int32

    public init(fdow: Int32, mdifw: Int32, weekendOnset: Int32, weekendOnsetMillis: Int32, weekendCease: Int32, weekendCeaseMillis: Int32) {
        this.firstDayOfWeek = fdow
        this.minimalDaysInFirstWeek = mdifw
        this.weekendOnset = weekendOnset
        this.weekendOnsetMillis = weekendOnsetMillis
        this.weekendCease = weekendCease
        this.weekendCeaseMillis = weekendCeaseMillis
    }

    public override func hashCode(): Int64 {
        return Int64(((((firstDayOfWeek * 37 + minimalDaysInFirstWeek) * 37 + weekendOnset) * 37 + weekendOnsetMillis) * 37 + weekendCease) * 37 + weekendCeaseMillis)
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (!(checkOptionalIs<Calendar_WeekData, Object>(other))) {
            return false
        }
        let that = other
        return firstDayOfWeek == that.firstDayOfWeek && minimalDaysInFirstWeek == that.minimalDaysInFirstWeek && weekendOnset == that.weekendOnset && weekendOnsetMillis == that.weekendOnsetMillis && weekendCease == that.weekendCease && weekendCeaseMillis == that.weekendCeaseMillis
    }

    public override func toString(): String {
        return "{" + firstDayOfWeek.toString() + ", " + minimalDaysInFirstWeek.toString() + ", " + weekendOnset.toString() + ", " + weekendOnsetMillis.toString() + ", " + weekendCease.toString() + ", " + weekendCeaseMillis.toString() + "}"
    }
}


class Calendar_WeekDataCache <: SoftCache<String, Calendar_WeekData, String> {
    init() {
        super()
    }

    override protected func createInstance(key: String, data: String): Calendar_WeekData {
        return Calendar.getWeekDataForRegionInternal(key)
    }
}
