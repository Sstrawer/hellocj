package icu4cj.util

abstract class CECalendar <: Calendar {
    private static let serialVersionUID = -999547623066414271

    private static let LIMITS: Array<Array<Int32>> = [[0, 0, 1, 1], [1, 1, 5000000, 5000000], [0, 0, 12, 12], [1, 1, 52, 53], [0], [1, 1, 5, 30], [1, 1, 365, 366], [0], [-1, -1, 1, 5], [0], [0], [0], [0], [0], [0], [0], [0], [-5000000, -5000000, 5000000, 5000000], [0], [-5000000, -5000000, 5000000, 5000000], [0], [0], [0], [0, 0, 12, 12]]

    protected init() {
        this(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
    }

    protected init(zone: TimeZone) {
        this(zone, ULocale.getDefault(ULocale_Category.FORMAT))
    }

    protected init(aLocale: Locale) {
        this(TimeZone.forLocaleOrDefault(aLocale), aLocale)
    }

    protected init(locale: ULocale) {
        this(TimeZone.forULocaleOrDefault(locale), locale)
    }

    protected init(zone: TimeZone, aLocale: Locale) {
        super(zone, aLocale)
        setTimeInMillis(DateTime.now().toUnixTimeStamp().toMilliseconds())
    }

    protected init(zone: TimeZone, locale: ULocale) {
        super(zone, locale)
        setTimeInMillis(DateTime.now().toUnixTimeStamp().toMilliseconds())
    }

    protected init(year: Int32, month: Int32, date: Int32) {
        super(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
        this.set(year, month, date)
    }

    protected init(date: DateTime) {
        super(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
        this.setTime(date)
    }

    protected init(year: Int32, month: Int32, date: Int32, hour: Int32, minute: Int32, second: Int32) {
        super(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
        this.set(year, month, date, hour, minute, second)
    }

    protected func getJDEpochOffset(): Int32

    override protected func handleComputeMonthStart(eyear: Int32, emonth: Int32, useMonth: Bool): Int32 {
        return ceToJD(Int64(eyear), emonth, 0, getJDEpochOffset())
    }

    override protected func handleGetLimit(field: Int32, limitType: Int32): Int32 {
        return LIMITS[Int64(field)][Int64(limitType)]
    }

    override protected func handleGetMonthLength(extendedYear: Int32, month: Int32): Int32 {
        if ((month + 1) % 13 != 0) {
            return 30
        } else {
            return ((extendedYear % 4) / 3) + 5
        }
    }

    public static func ceToJD(year: Int64, month: Int32, day: Int32, jdEpochOffset: Int32): Int32 {
        var tempyear = year
        var tempmonth = month
        if (tempmonth >= 0) {
            tempyear += Int64(tempmonth / 13)
            tempmonth %= 13
        } else {
            tempmonth++
            tempyear += Int64(tempmonth / 13 - 1)
            tempmonth = tempmonth % 13 + 12
        }
        return Int32(Int64(jdEpochOffset) + 365 * tempyear + floorDivide(tempyear, 4) + Int64(30 * tempmonth) + Int64(day) - 1)
    }

    public static func jdToCE(julianDay: Int32, jdEpochOffset: Int32, fields: Array<Int32>): Unit {
        let c4: Int32
        let r4 = Array<Int32>(1) { _ => 0 }
        c4 = floorDivide(julianDay - jdEpochOffset, 1461, r4)
        fields[0] = 4 * c4 + (r4[0] / 365 - r4[0] / 1460)
        let doy = if (r4[0] == 1460) { 365 } else { (r4[0] % 365) }
        fields[1] = doy / 30
        fields[2] = (doy % 30) + 1
    }

    public override func getTemporalMonthCode(): String {
        if (get(MONTH) == 12) {
            return "M13"
        }
        return super.getTemporalMonthCode()
    }

    public override func setTemporalMonthCode(temporalMonth: String): Unit {
        if (temporalMonth == "M13") {
            set(MONTH, 12)
            set(IS_LEAP_MONTH, 0)
            return
        }
        super.setTemporalMonthCode(temporalMonth)
    }
}
