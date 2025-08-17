package icu4cj.util

public class HebrewCalendar <: Calendar {
    private static let serialVersionUID = -1952524560588825816

    public static let TISHRI = 0

    public static let HESHVAN = 1

    public static let KISLEV = 2

    public static let TEVET = 3

    public static let SHEVAT = 4

    public static let ADAR_1 = 5

    public static let ADAR = 6

    public static let NISAN = 7

    public static let IYAR = 8

    public static let SIVAN = 9

    public static let TAMUZ = 10

    public static let AV = 11

    public static let ELUL = 12

    private static let LIMITS: Array<Array<Int32>> = [[0, 0, 0, 0], [-5000000, -5000000, 5000000, 5000000], [0, 0, 12, 12], [1, 1, 51, 56], [0], [1, 1, 29, 30], [1, 1, 353, 385], [0], [-1, -1, 5, 5], [0], [0], [0], [0], [0], [0], [0], [0], [-5000000, -5000000, 5000000, 5000000], [0], [-5000000, -5000000, 5000000, 5000000], [0], [0], [0], [0, 0, 11, 12]]

    private static let MONTH_LENGTH = [[30, 30, 30], [29, 29, 30], [29, 30, 30], [29, 29, 29], [30, 30, 30], [30, 30, 30], [29, 29, 29], [30, 30, 30], [29, 29, 29], [30, 30, 30], [29, 29, 29], [30, 30, 30], [29, 29, 29]]

    private static let MONTH_START = [[0, 0, 0], [30, 30, 30], [59, 59, 60], [88, 89, 90], [117, 118, 119], [147, 148, 149], [147, 148, 149], [176, 177, 178], [206, 207, 208], [235, 236, 237], [265, 266, 267], [294, 295, 296], [324, 325, 326], [353, 354, 355]]

    private static let LEAP_MONTH_START = [[0, 0, 0], [30, 30, 30], [59, 59, 60], [88, 89, 90], [117, 118, 119], [147, 148, 149], [177, 178, 179], [206, 207, 208], [236, 237, 238], [265, 266, 267], [295, 296, 297], [324, 325, 326], [354, 355, 356], [383, 384, 385]]

    private static let MONTHS_IN_CYCLE = 235

    private static let YEARS_IN_CYCLE = 19

    private static var cache: CalendarCache = CalendarCache()

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
        this.set(YEAR, year)
        this.set(MONTH, month)
        this.set(DATE, date)
    }

    public init(date: DateTime) {
        super(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
        this.setTime(date)
    }

    public init(year: Int32, month: Int32, date: Int32, hour: Int32, minute: Int32, second: Int32) {
        super(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
        this.set(YEAR, year)
        this.set(MONTH, month)
        this.set(DATE, date)
        this.set(HOUR_OF_DAY, hour)
        this.set(MINUTE, minute)
        this.set(SECOND, second)
    }

    public override func add(field: Int32, amount: Int32): Unit {
        match (field) {
            case 2 | 23 =>
                var month = get(MONTH)
                var year = get(YEAR)
                var acrossAdar1: Bool = false
                if (amount > 0) {
                    acrossAdar1 = (month < ADAR_1)
                    month += amount
                    while (true) {
                        if (acrossAdar1 && month >= ADAR_1 && !isLeapYear(year)) {
                            month++
                        }
                        if (month <= ELUL) {
                            break
                        }
                        month -= ELUL + 1
                        year++
                        acrossAdar1 = true
                    }
                } else {
                    acrossAdar1 = (month > ADAR_1)
                    month += amount
                    while (true) {
                        if (acrossAdar1 && month <= ADAR_1 && !isLeapYear(year)) {
                            month--
                        }
                        if (month >= 0) {
                            break
                        }
                        month += ELUL + 1
                        year--
                        acrossAdar1 = true
                    }
                }
                set(MONTH, month)
                set(YEAR, year)
                pinField(DAY_OF_MONTH)
                break
            case _ => super.add(field, amount)
        }
    }

    public override func roll(field: Int32, amount: Int32): Unit {
        match (field) {
            case 2 | 23 =>
                let month = get(MONTH)
                let year = get(YEAR)
                let leapYear = isLeapYear(year)
                let yearLength = monthsInYear(year)
                var newMonth = month + (amount % yearLength)
                if (!leapYear) {
                    if (amount > 0 && month < ADAR_1 && newMonth >= ADAR_1) {
                        newMonth++
                    } else if (amount < 0 && month > ADAR_1 && newMonth <= ADAR_1) {
                        newMonth--
                    }
                }
                set(MONTH, (newMonth + 13) % 13)
                pinField(DAY_OF_MONTH)
                return
            case _ => super.roll(field, amount)
        }
    }

    private static let HOUR_PARTS = 1080

    private static let DAY_PARTS = 24 * HOUR_PARTS

    private static let MONTH_DAYS = 29

    private static let MONTH_FRACT = 12 * HOUR_PARTS + 793

    private static let MONTH_PARTS = Int64(MONTH_DAYS) * DAY_PARTS + MONTH_FRACT

    private static let BAHARAD = 11 * HOUR_PARTS + 204

    private static func startOfYear(year: Int32): Int64 {
        var day = cache.get(Int64(year))
        if (day == CalendarCache.EMPTY) {
            let months = Int32(floorDivide((Int64(MONTHS_IN_CYCLE) * Int64(year) - (Int64(MONTHS_IN_CYCLE - 1))), Int64(YEARS_IN_CYCLE)))
            var frac = Int64(months) * MONTH_FRACT + BAHARAD
            day = Int64(months * 29) + (frac / DAY_PARTS)
            frac = frac % DAY_PARTS
            var wd = Int32(day % 7)
            if (wd == 2 || wd == 4 || wd == 6) {
                day += 1
                wd = Int32(day % 7)
            }
            if (wd == 1 && frac > 15 * HOUR_PARTS + 204 && !isLeapYear(year)) {
                day += 2
            } else if (wd == 0 && frac > 21 * HOUR_PARTS + 589 && isLeapYear(year - 1)) {
                day += 1
            }
            cache.put(Int64(year), day)
        }
        return day
    }

    private func yearType(year: Int32): Int32 {
        var yearLength = handleGetYearLength(year)
        if (yearLength > 380) {
            yearLength -= 30
        }
        var Type = 0
        match (yearLength) {
            case 353 => Type = 0
            case 354 => Type = 1
            case 355 => Type = 2
            case _ => throw IllegalArgumentException("Illegal year length " + yearLength.toString() + " in year " + year.toString())
        }
        return Type
    }

    
    public static func isLeapYear(year: Int32): Bool {
        let x = (year * 12 + 17) % YEARS_IN_CYCLE
        return x >= (if (x < 0) { -7 } else { 12 })
    }

    private static func monthsInYear(year: Int32): Int32 {
        return if (isLeapYear(year)) { 13 } else { 12 }
    }

    override protected func handleGetLimit(field: Int32, limitType: Int32): Int32 {
        return LIMITS[Int64(field)][Int64(limitType)]
    }

    override protected func handleGetMonthLength(extendedYear: Int32, month: Int32): Int32 {
        var tempextendedYear = extendedYear
        var tempmonth = month
        if (tempmonth <= -MONTHS_IN_CYCLE || MONTHS_IN_CYCLE <= tempmonth) {
            tempextendedYear += (tempmonth / MONTHS_IN_CYCLE) * YEARS_IN_CYCLE
            tempmonth = tempmonth % MONTHS_IN_CYCLE
        }
        while (tempmonth < 0) {
            tempmonth += monthsInYear(match (0) { case _ => tempextendedYear--; tempextendedYear })
        }
        while (tempmonth > 12) {
            tempmonth -= monthsInYear(match (0) { case _ => tempextendedYear++; tempextendedYear - 1 })
        }
        match (tempmonth) {
            case 1 | 2 => return MONTH_LENGTH[Int64(tempmonth)][Int64(yearType(tempextendedYear))]
            case _ => return MONTH_LENGTH[Int64(tempmonth)][0]
        }
    }

    override protected func handleGetYearLength(eyear: Int32): Int32 {
        return Int32(startOfYear(eyear + 1) - startOfYear(eyear))
    }

    
    override protected func validateField(field: Int32): Unit {
        if ((field == MONTH || field == ORDINAL_MONTH) && !isLeapYear(handleGetExtendedYear()) && internalGetMonth() == ADAR_1) {
            throw IllegalArgumentException("MONTH cannot be ADAR_1(5) except leap years")
        }
        super.validateField(field)
    }

    override protected func handleComputeFields(julianDay: Int32): Unit {
        let d = Int64(julianDay - 347997)
        let m = floorDivide((d * DAY_PARTS), MONTH_PARTS)
        var year = Int32(floorDivide((Int64(YEARS_IN_CYCLE) * m + (Int64(MONTHS_IN_CYCLE - 1))), Int64(MONTHS_IN_CYCLE)) + 1)
        var ys = startOfYear(year)
        var dayOfYear = Int32(d - ys)
        while (dayOfYear < 1) {
            year--
            ys = startOfYear(year)
            dayOfYear = Int32(d - ys)
        }
        let yearType = yearType(year)
        let isLeap = isLeapYear(year)
        let monthStart: Array<Array<Int32>> = if (isLeap) { LEAP_MONTH_START } else { MONTH_START }
        var month = 0
        while (dayOfYear > monthStart[Int64(month)][Int64(yearType)]) {
            month++
        }
        month--
        let dayOfMonth = dayOfYear - monthStart[Int64(month)][Int64(yearType)]
        internalSet(ERA, 0)
        internalSet(YEAR, year)
        internalSet(EXTENDED_YEAR, year)
        var ordinal_month = month
        if (!isLeap && ordinal_month > ADAR_1) {
            ordinal_month--
        }
        internalSet(ORDINAL_MONTH, ordinal_month)
        internalSet(MONTH, month)
        internalSet(DAY_OF_MONTH, dayOfMonth)
        internalSet(DAY_OF_YEAR, dayOfYear)
    }

    override protected func handleGetExtendedYear(): Int32 {
        let year: Int32
        if (newerField(EXTENDED_YEAR, YEAR) == EXTENDED_YEAR) {
            year = internalGet(EXTENDED_YEAR, 1)
        } else {
            year = internalGet(YEAR, 1)
        }
        return year
    }

    override protected func handleComputeMonthStart(eyear: Int32, month: Int32, useMonth: Bool): Int32 {
        var tempeyear = eyear
        var tempmonth = month
        if (tempmonth <= -MONTHS_IN_CYCLE || MONTHS_IN_CYCLE <= tempmonth) {
            tempeyear += (tempmonth / MONTHS_IN_CYCLE) * YEARS_IN_CYCLE
            tempmonth = tempmonth % MONTHS_IN_CYCLE
        }
        while (tempmonth < 0) {
            tempmonth += monthsInYear(match (0) { case _ => tempeyear--; tempeyear })
        }
        while (tempmonth > 12) {
            tempmonth -= monthsInYear(match (0) { case _ => tempeyear++; tempeyear - 1 })
        }
        var day = startOfYear(tempeyear)
        if (tempmonth != 0) {
            if (isLeapYear(tempeyear)) {
                day += Int64(LEAP_MONTH_START[Int64(tempmonth)][Int64(yearType(tempeyear))])
            } else {
                day += Int64(MONTH_START[Int64(tempmonth)][Int64(yearType(tempeyear))])
            }
        }
        return Int32(day + 347997)
    }

    public override func getType(): String {
        return "hebrew"
    }

    public override func inTemporalLeapYear(): Bool {
        return isLeapYear(get(EXTENDED_YEAR))
    }

    private static var gTemporalMonthCodesForHebrew: Array<String> = ["M01", "M02", "M03", "M04", "M05", "M05", "M06", "M07", "M08", "M09", "M10", "M11", "M12"]

    public override func getTemporalMonthCode(): String {
        return gTemporalMonthCodesForHebrew[Int64(get(MONTH))]
    }

    public override func setTemporalMonthCode(temporalMonth: String): Unit {
        if (Int32(temporalMonth.size) == 3 || Int32(temporalMonth.size) == 4) {
            var m = 0
            while (m < Int32(gTemporalMonthCodesForHebrew.size)) {
                if (temporalMonth.equals(gTemporalMonthCodesForHebrew[Int64(m)])) {
                    set(MONTH, m)
                    return
                }
                m++
            }
        }
        throw IllegalArgumentException("Incorrect temporal Month code: " + (temporalMonth))
    }

    
    override protected func internalGetMonth(): Int32 {
        if (resolveFields(MONTH_PRECEDENCE) == ORDINAL_MONTH) {
            let ordinalMonth = internalGet(ORDINAL_MONTH)
            let year = handleGetExtendedYear()
            return ordinalMonth + (if ((!isLeapYear(year)) && (ordinalMonth > ADAR_1)) { 1 } else { 0 })
        }
        return super.internalGetMonth()
    }
}
