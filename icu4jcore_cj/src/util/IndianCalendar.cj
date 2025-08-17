package icu4cj.util

public class IndianCalendar <: Calendar {
    private static let serialVersionUID = 3617859668165014834

    public static let CHAITRA = 0

    public static let VAISAKHA = 1

    public static let JYAISTHA = 2

    public static let ASADHA = 3

    public static let SRAVANA = 4

    public static let BHADRA = 5

    public static let ASVINA = 6

    public static let KARTIKA = 7

    public static let AGRAHAYANA = 8

    public static let PAUSA = 9

    public static let MAGHA = 10

    public static let PHALGUNA = 11

    public static let IE = 0

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

    private static let INDIAN_ERA_START = 78

    private static let INDIAN_YEAR_START = 80

    override protected func handleGetExtendedYear(): Int32 {
        let year: Int32
        if (newerField(EXTENDED_YEAR, YEAR) == EXTENDED_YEAR) {
            year = internalGet(EXTENDED_YEAR, 1)
        } else {
            year = internalGet(YEAR, 1)
        }
        return year
    }

    override protected func handleGetYearLength(extendedYear: Int32): Int32 {
        return super.handleGetYearLength(extendedYear)
    }

    override protected func handleGetMonthLength(extendedYear: Int32, month: Int32): Int32 {
        var tempextendedYear = extendedYear
        var tempmonth = month
        if (tempmonth < 0 || tempmonth > 11) {
            let remainder = Array<Int32>(1) { _ => 0 }
            tempextendedYear += floorDivide(tempmonth, 12, remainder)
            tempmonth = remainder[0]
        }
        if (isGregorianLeapYear(tempextendedYear + INDIAN_ERA_START) && tempmonth == 0) {
            return 31
        }
        if (tempmonth >= 1 && tempmonth <= 5) {
            return 31
        }
        return 30
    }

    override protected func handleComputeFields(julianDay: Int32): Unit {
        let jdAtStartOfGregYear: Float64
        let leapMonth: Int32
        var IndianYear: Int32 = 0
        var yday: Int32 = 0
        let IndianMonth: Int32
        let IndianDayOfMonth: Int32
        var mday: Int32 = 0
        computeGregorianFields(julianDay)
        let gregorianYear = getGregorianYear()
        IndianYear = gregorianYear - INDIAN_ERA_START
        jdAtStartOfGregYear = gregorianToJD(gregorianYear, 0, 1)
        yday = Int32(Float64(julianDay) - jdAtStartOfGregYear)
        if (yday < INDIAN_YEAR_START) {
            IndianYear -= 1
            leapMonth = if (isGregorianLeapYear(gregorianYear - 1)) { 31 } else { 30 }
            yday += leapMonth + (31 * 5) + (30 * 3) + 10
        } else {
            leapMonth = if (isGregorianLeapYear(gregorianYear)) { 31 } else { 30 }
            yday -= INDIAN_YEAR_START
        }
        if (yday < leapMonth) {
            IndianMonth = 0
            IndianDayOfMonth = yday + 1
        } else {
            mday = yday - leapMonth
            if (mday < (31 * 5)) {
                IndianMonth = mday / 31 + 1
                IndianDayOfMonth = (mday % 31) + 1
            } else {
                mday -= 31 * 5
                IndianMonth = mday / 30 + 6
                IndianDayOfMonth = (mday % 30) + 1
            }
        }
        internalSet(ERA, 0)
        internalSet(EXTENDED_YEAR, IndianYear)
        internalSet(YEAR, IndianYear)
        internalSet(MONTH, IndianMonth)
        internalSet(ORDINAL_MONTH, IndianMonth)
        internalSet(DAY_OF_MONTH, IndianDayOfMonth)
        internalSet(DAY_OF_YEAR, yday + 1)
    }

    private static let LIMITS: Array<Array<Int32>> = [[0, 0, 0, 0], [-5000000, -5000000, 5000000, 5000000], [0, 0, 11, 11], [1, 1, 52, 53], [0], [1, 1, 30, 31], [1, 1, 365, 366], [0], [-1, -1, 5, 5], [0], [0], [0], [0], [0], [0], [0], [0], [-5000000, -5000000, 5000000, 5000000], [0], [-5000000, -5000000, 5000000, 5000000], [0], [0], [0], [0, 0, 11, 11]]

    override protected func handleGetLimit(field: Int32, limitType: Int32): Int32 {
        return LIMITS[Int64(field)][Int64(limitType)]
    }

    override protected func handleComputeMonthStart(year: Int32, month: Int32, useMonth: Bool): Int32 {
        var tempyear = year
        var tempmonth = month
        let imonth: Int32
        if (tempmonth < 0 || tempmonth > 11) {
            tempyear += tempmonth / 12
            tempmonth %= 12
        }
        imonth = tempmonth + 1
        let jd = IndianToJD(tempyear, imonth, 1)
        return Int32(jd)
    }

    private func IndianToJD(year: Int32, month: Int32, date: Int32): Float64 {
        let leapMonth: Int32
        let gyear: Int32
        var m: Int32 = 0
        let start: Float64
        var jd: Float64 = 0.0
        gyear = year + INDIAN_ERA_START
        if (isGregorianLeapYear(gyear)) {
            leapMonth = 31
            start = gregorianToJD(gyear, 2, 21)
        } else {
            leapMonth = 30
            start = gregorianToJD(gyear, 2, 22)
        }
        if (month == 1) {
            jd = start + (Float64(date - 1))
        } else {
            jd = start + Float64(leapMonth)
            m = month - 2
            m = min(m, 5)
            jd += Float64(m * 31)
            if (month >= 8) {
                m = month - 7
                jd += Float64(m * 30)
            }
            jd += Float64(date - 1)
        }
        return jd
    }

    private func gregorianToJD(year: Int32, month: Int32, date: Int32): Float64 {
        return Float64(computeGregorianMonthStart(year, month) + date) - 0.5
    }

    public override func getType(): String {
        return "indian"
    }
}
