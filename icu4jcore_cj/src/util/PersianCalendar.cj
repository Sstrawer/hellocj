package icu4cj.util


public class PersianCalendar <: Calendar {
    private static let serialVersionUID = -6727306982975111643

    private static let MONTH_COUNT = [[31, 31, 0], [31, 31, 31], [31, 31, 62], [31, 31, 93], [31, 31, 124], [31, 31, 155], [30, 30, 186], [30, 30, 216], [30, 30, 246], [30, 30, 276], [30, 30, 306], [29, 30, 336]]

    private static let PERSIAN_EPOCH = 1948320

    
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

    
    public init(date: DateTime) {
        super(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
        this.setTime(date)
    }

    
    public init(year: Int32, month: Int32, date: Int32) {
        super(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
        this.set(Calendar.YEAR, year)
        this.set(Calendar.MONTH, month)
        this.set(Calendar.DATE, date)
    }

    
    public init(year: Int32, month: Int32, date: Int32, hour: Int32, minute: Int32, second: Int32) {
        super(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
        this.set(Calendar.YEAR, year)
        this.set(Calendar.MONTH, month)
        this.set(Calendar.DATE, date)
        this.set(Calendar.HOUR_OF_DAY, hour)
        this.set(Calendar.MINUTE, minute)
        this.set(Calendar.SECOND, second)
    }

    private static let LIMITS: Array<Array<Int32>> = [[0, 0, 0, 0], [-5000000, -5000000, 5000000, 5000000], [0, 0, 11, 11], [1, 1, 52, 53], [0], [1, 1, 29, 31], [1, 1, 365, 366], [0], [-1, -1, 5, 5], [0], [0], [0], [0], [0], [0], [0], [0], [-5000000, -5000000, 5000000, 5000000], [0], [-5000000, -5000000, 5000000, 5000000], [0], [0], [0], [0, 0, 11, 11]]

    
    override protected func handleGetLimit(field: Int32, limitType: Int32): Int32 {
        return LIMITS[Int64(field)][Int64(limitType)]
    }

    private static func isLeapYear(year: Int32): Bool {
        let remainder = Array<Int32>(1) { _ => 0 }
        floorDivide(25 * year + 11, 33, remainder)
        return remainder[0] < 8
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

    
    override protected func handleGetYearLength(extendedYear: Int32): Int32 {
        return if (isLeapYear(extendedYear)) { 366 } else { 365 }
    }

    
    override protected func handleComputeMonthStart(eyear: Int32, month: Int32, useMonth: Bool): Int32 {
        var tempeyear = eyear
        var tempmonth = month
        if (tempmonth < 0 || tempmonth > 11) {
            let rem = Array<Int32>(1) { _ => 0 }
            tempeyear += floorDivide(tempmonth, 12, rem)
            tempmonth = rem[0]
        }
        var julianDay = PERSIAN_EPOCH - 1 + 365 * (tempeyear - 1) + floorDivide(8 * tempeyear + 21, 33)
        if (tempmonth != 0) {
            julianDay += MONTH_COUNT[Int64(tempmonth)][2]
        }
        return julianDay
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

    
    override protected func handleComputeFields(julianDay: Int32): Unit {
        let year: Int32
        let month: Int32
        let dayOfMonth: Int32
        var dayOfYear: Int32 = 0
        let daysSinceEpoch = Int64(julianDay - PERSIAN_EPOCH)
        year = 1 + Int32(floorDivide(33 * daysSinceEpoch + 3, 12053))
        let farvardin1 = 365 * (Int64(year) - 1) + floorDivide(8 * Int64(year) + 21, 33)
        dayOfYear = Int32(daysSinceEpoch - farvardin1)
        if (dayOfYear < 216) {
            month = dayOfYear / 31
        } else {
            month = (dayOfYear - 6) / 30
        }
        dayOfMonth = dayOfYear - MONTH_COUNT[Int64(month)][2] + 1
        dayOfYear++
        internalSet(ERA, 0)
        internalSet(YEAR, year)
        internalSet(EXTENDED_YEAR, year)
        internalSet(MONTH, month)
        internalSet(ORDINAL_MONTH, month)
        internalSet(DAY_OF_MONTH, dayOfMonth)
        internalSet(DAY_OF_YEAR, dayOfYear)
    }

    
    public override func getType(): String {
        return "persian"
    }
}
