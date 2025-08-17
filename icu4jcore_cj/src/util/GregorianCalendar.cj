package icu4cj.util

public class GregorianCalendar <: Calendar {
    private static let serialVersionUID = 9199388694351062137

    public static let BC = 0

    public static let AD = 1

    private static let EPOCH_YEAR = 1970

    private static let MONTH_COUNT = [[31, 31, 0, 0], [28, 29, 31, 31], [31, 31, 59, 60], [30, 30, 90, 91], [31, 31, 120, 121], [30, 30, 151, 152], [31, 31, 181, 182], [31, 31, 212, 213], [30, 30, 243, 244], [31, 31, 273, 274], [30, 30, 304, 305], [31, 31, 334, 335]]

    private static let LIMITS: Array<Array<Int32>> = [[0, 0, 1, 1], [1, 1, 5828963, 5838270], [0, 0, 11, 11], [1, 1, 52, 53], [0], [1, 1, 28, 31], [1, 1, 365, 366], [0], [-1, -1, 4, 5], [0], [0], [0], [0], [0], [0], [0], [0], [-5838270, -5838270, 5828964, 5838271], [0], [-5838269, -5838269, 5828963, 5838270], [0], [0], [0], [0, 0, 11, 11]]

    override protected func handleGetLimit(field: Int32, limitType: Int32): Int32 {
        return LIMITS[Int64(field)][Int64(limitType)]
    }

    private var gregorianCutover = -12219292800000

     private var cutoverJulianDay = 2299161

     private var gregorianCutoverYear = 1582

     protected var isGregorian: Bool = false

     protected var invertGregorian: Bool = false

    public init() {
        this(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public init(zone: TimeZone) {
        this(zone, ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public init(aLocale: Locale) {
        this(TimeZone.forLocaleOrDefault(aLocale), aLocale)
    }

    public init(locale: ULocale) {
        this(TimeZone.forULocaleOrDefault(locale), locale)
    }

    public init(zone: TimeZone, aLocale: Locale) {
        super(zone, aLocale)
        setTimeInMillis(DateTime.now().toUnixTimeStamp().toMilliseconds())
    }

    public init(zone: TimeZone, locale: ULocale) {
        super(zone, locale)
        setTimeInMillis(DateTime.now().toUnixTimeStamp().toMilliseconds())
    }

    public init(year: Int32, month: Int32, date: Int32) {
        super(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
        set(ERA, AD)
        set(YEAR, year)
        set(MONTH, month)
        set(DATE, date)
    }

    public init(year: Int32, month: Int32, date: Int32, hour: Int32, minute: Int32) {
        super(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
        set(ERA, AD)
        set(YEAR, year)
        set(MONTH, month)
        set(DATE, date)
        set(HOUR_OF_DAY, hour)
        set(MINUTE, minute)
    }

    public init(year: Int32, month: Int32, date: Int32, hour: Int32, minute: Int32, second: Int32) {
        super(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
        set(ERA, AD)
        set(YEAR, year)
        set(MONTH, month)
        set(DATE, date)
        set(HOUR_OF_DAY, hour)
        set(MINUTE, minute)
        set(SECOND, second)
    }

    public func setGregorianChange(date: DateTime): Unit {
        gregorianCutover = date.getTime()
        if (gregorianCutover <= MIN_MILLIS) {
            gregorianCutoverYear = match (0) { case _ => cutoverJulianDay = Int32.Min; cutoverJulianDay }
        } else if (gregorianCutover >= MAX_MILLIS) {
            gregorianCutoverYear = match (0) { case _ => cutoverJulianDay = Int32.Max; cutoverJulianDay }
        } else {
            cutoverJulianDay = Int32(floorDivide(gregorianCutover, ONE_DAY))
            let cal = GregorianCalendar(getTimeZone())
            cal.setTime(date)
            gregorianCutoverYear = cal.get(EXTENDED_YEAR)
        }
    }

    public func getGregorianChange(): DateTime {
        return Date(gregorianCutover)
    }

    public func isLeapYear(year: Int32): Bool {
        return if (year >= gregorianCutoverYear) { ((year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0))) } else { (year % 4 == 0) }
    }

    public override func isEquivalentTo(other: Calendar): Bool {
        return super.isEquivalentTo(other) && gregorianCutover == other.gregorianCutover
    }

    public override func hashCode(): Int64 {
        return Int64(Int32(super.hashCode()) ^ Int32(gregorianCutover))
    }

    public override func roll(field: Int32, amount: Int32): Unit {
        match (field) {
            case 3 =>
                var woy = get(WEEK_OF_YEAR)
                let isoYear = get(YEAR_WOY)
                var isoDoy = internalGet(DAY_OF_YEAR)
                if (internalGetMonth() == Calendar.JANUARY) {
                    if (woy >= 52) {
                        isoDoy += handleGetYearLength(isoYear)
                    }
                } else {
                    if (woy == 1) {
                        isoDoy -= handleGetYearLength(isoYear - 1)
                    }
                }
                woy += amount
                if (woy < 1 || woy > 52) {
                    var lastDoy = handleGetYearLength(isoYear)
                    var lastRelDow = (lastDoy - isoDoy + internalGet(DAY_OF_WEEK) - getFirstDayOfWeek()) % 7
                    if (lastRelDow < 0) {
                        lastRelDow += 7
                    }
                    if ((6 - lastRelDow) >= getMinimalDaysInFirstWeek()) {
                        lastDoy -= 7
                    }
                    let lastWoy = weekNumber(lastDoy, lastRelDow + 1)
                    woy = ((woy + lastWoy - 1) % lastWoy) + 1
                }
                set(WEEK_OF_YEAR, woy)
                set(YEAR, isoYear)
                return
            case _ =>
                super.roll(field, amount)
                return
        }
    }

    public override func getActualMinimum(field: Int32): Int32 {
        return getMinimum(field)
    }

    public override func getActualMaximum(field: Int32): Int32 {
        match (field) {
            case 1 =>
                let cal = clone()
                cal.setLenient(true)
                let era = cal.get(ERA)
                let d = cal.getTime()
                var lowGood = LIMITS[Int64(YEAR)][1]
                var highBad = LIMITS[Int64(YEAR)][2] + 1
                while ((lowGood + 1) < highBad) {
                    let y = (lowGood + highBad) / 2
                    cal.set(YEAR, y)
                    if (cal.get(YEAR) == y && cal.get(ERA) == era) {
                        lowGood = y
                    } else {
                        highBad = y
                        cal.setTime(d)
                    }
                }
                return lowGood
            case _ => return super.getActualMaximum(field)
        }
    }

    public func inDaylightTime(): Bool {
        if (!getTimeZone().useDaylightTime()) {
            return false
        }
        complete()
        return internalGet(DST_OFFSET) != 0
    }

    override protected func handleGetMonthLength(extendedYear: Int32, month: Int32): Int32 {
        var tempextendedYear = extendedYear
        var tempmonth = month
        if (tempmonth < 0 || tempmonth > 11) {
            let rem = Array<Int32>(1) { _ => 0 }
            tempextendedYear += floorDivide(tempmonth, 12, rem)
            tempmonth = rem[0]
        }
        return MONTH_COUNT[Int64(tempmonth)][if (isLeapYear(tempextendedYear)) { 1 } else { 0 }]
    }

    override protected func handleGetYearLength(eyear: Int32): Int32 {
        return if (isLeapYear(eyear)) { 366 } else { 365 }
    }

    override protected func handleComputeFields(julianDay: Int32): Unit {
        var eyear: Int32 = 0
        let month: Int32
        let dayOfMonth: Int32
        var dayOfYear: Int32 = 0
        if (julianDay >= cutoverJulianDay) {
            month = getGregorianMonth()
            dayOfMonth = getGregorianDayOfMonth()
            dayOfYear = getGregorianDayOfYear()
            eyear = getGregorianYear()
        } else {
            let julianEpochDay = Int64(julianDay - (JAN_1_1_JULIAN_DAY - 2))
            eyear = Int32(floorDivide(4 * julianEpochDay + 1464, 1461))
            let january1 = 365 * (Int64(eyear) - 1) + floorDivide(Int64(eyear) - 1, 4)
            dayOfYear = Int32(julianEpochDay - january1)
            let isLeap = ((eyear & 3) == 0)
            var correction = 0
            let march1 = if (isLeap) { 60 } else { 59 }
            if (dayOfYear >= march1) {
                correction = if (isLeap) { 1 } else { 2 }
            }
            month = (12 * (dayOfYear + correction) + 6) / 367
            dayOfMonth = dayOfYear - MONTH_COUNT[Int64(month)][if (isLeap) { 3 } else { 2 }] + 1
            dayOfYear++
        }
        internalSet(MONTH, month)
        internalSet(ORDINAL_MONTH, month)
        internalSet(DAY_OF_MONTH, dayOfMonth)
        internalSet(DAY_OF_YEAR, dayOfYear)
        internalSet(EXTENDED_YEAR, eyear)
        var era = AD
        if (eyear < 1) {
            era = BC
            eyear = 1 - eyear
        }
        internalSet(ERA, era)
        internalSet(YEAR, eyear)
    }

    override protected func handleGetExtendedYear(): Int32 {
        let year: Int32
        if (newerField(EXTENDED_YEAR, YEAR) == EXTENDED_YEAR) {
            year = internalGet(EXTENDED_YEAR, EPOCH_YEAR)
        } else {
            let era = internalGet(ERA, AD)
            if (era == BC) {
                year = 1 - internalGet(YEAR, 1)
            } else {
                year = internalGet(YEAR, EPOCH_YEAR)
            }
        }
        return year
    }

    override protected func handleComputeJulianDay(bestField: Int32): Int32 {
        invertGregorian = false
        var jd = super.handleComputeJulianDay(bestField)
        if (isGregorian != (jd >= cutoverJulianDay)) {
            invertGregorian = true
            jd = super.handleComputeJulianDay(bestField)
        }
        return jd
    }

    override protected func handleComputeMonthStart(eyear: Int32, month: Int32, useMonth: Bool): Int32 {
        var tempeyear = eyear
        var tempmonth = month
        if (tempmonth < 0 || tempmonth > 11) {
            let rem = Array<Int32>(1) { _ => 0 }
            tempeyear += floorDivide(tempmonth, 12, rem)
            tempmonth = rem[0]
        }
        var isLeap = tempeyear % 4 == 0
        let y = tempeyear - 1
        var julianDay = 365 * y + floorDivide(y, 4) + (JAN_1_1_JULIAN_DAY - 3)
        isGregorian = (tempeyear >= gregorianCutoverYear)
        if (invertGregorian) {
            isGregorian = !isGregorian
        }
        if (isGregorian) {
            isLeap = isLeap && ((tempeyear % 100 != 0) || (tempeyear % 400 == 0))
            julianDay += floorDivide(y, 400) - floorDivide(y, 100) + 2
        }
        if (tempmonth != 0) {
            julianDay += MONTH_COUNT[Int64(tempmonth)][if (isLeap) { 3 } else { 2 }]
        }
        return julianDay
    }

    public override func getType(): String {
        return "gregorian"
    }

    
    override protected func isEra0CountingBackward(): Bool {
        return true
    }
}
