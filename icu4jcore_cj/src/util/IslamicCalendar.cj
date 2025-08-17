package icu4cj.util


public class IslamicCalendar <: Calendar {
    private static let serialVersionUID = -6253365474073869325

    public static let MUHARRAM = 0

    public static let SAFAR = 1

    public static let RABI_1 = 2

    public static let RABI_2 = 3

    public static let JUMADA_1 = 4

    public static let JUMADA_2 = 5

    public static let RAJAB = 6

    public static let SHABAN = 7

    public static let RAMADAN = 8

    public static let SHAWWAL = 9

    public static let DHU_AL_QIDAH = 10

    public static let DHU_AL_HIJJAH = 11

    private static let HIJRA_MILLIS = -42521587200000

    static let CIVIL_EPOCH = 1948440

    static let ASTRONOMICAL_EPOCH = 1948439

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
        this(zone, ULocale.forLocale(aLocale))
    }

    public init(zone: TimeZone, locale: ULocale) {
        super(zone, locale)
        setCalcTypeForLocale(locale)
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

    private static var ISLAMIC_ALGORITHM: IslamicCalendar_Algorithm

    static var CIVIL_ALGORITHM: IslamicCalendar_Algorithm

    private static var TBLA_ALGORITHM: IslamicCalendar_Algorithm

    private static var UMALQURA_ALGORITHM: IslamicCalendar_Algorithm


    public func setCivil(beCivil: Bool): Unit {
        if (beCivil && !refEq(cType, IslamicCalendar_CalculationType.ISLAMIC_CIVIL)) {
            let m = getTimeInMillis()
            cType = IslamicCalendar_CalculationType.ISLAMIC_CIVIL
            algorithm = CIVIL_ALGORITHM
            clear()
            setTimeInMillis(m)
        } else if (!beCivil && !refEq(cType, IslamicCalendar_CalculationType.ISLAMIC)) {
            let m = getTimeInMillis()
            cType = IslamicCalendar_CalculationType.ISLAMIC
            algorithm = ISLAMIC_ALGORITHM
            clear()
            setTimeInMillis(m)
        }
        civil = algorithm.isCivil()
    }

    public func isCivil(): Bool {
        return algorithm.isCivil()
    }

    private static let LIMITS: Array<Array<Int32>> = [[0, 0, 0, 0], [1, 1, 5000000, 5000000], [0, 0, 11, 11], [1, 1, 50, 51], [0], [1, 1, 29, 30], [1, 1, 354, 355], [0], [-1, -1, 5, 5], [0], [0], [0], [0], [0], [0], [0], [0], [1, 1, 5000000, 5000000], [0], [1, 1, 5000000, 5000000], [0], [0], [0], [0, 0, 11, 11]]

    static let UMALQURA_MONTHLENGTH = [2730, 3412, 3785, 1748, 1770, 876, 2733, 1365, 1705, 1938, 2985, 1492, 2778, 1372, 3373, 1685, 1866, 2900, 2922, 1453, 1198, 2639, 1303, 1675, 1701, 2773, 726, 2395, 1181, 2637, 3366, 3477, 1452, 2486, 698, 2651, 1323, 2709, 1738, 2793, 756, 2422, 694, 2390, 2762, 2980, 3026, 1497, 732, 2413, 1357, 2725, 2898, 2981, 1460, 2486, 1367, 663, 1355, 1699, 1874, 2917, 1386, 2731, 1323, 3221, 3402, 3493, 1482, 2774, 2391, 1195, 2379, 2725, 2898, 2922, 1397, 630, 2231, 1115, 1365, 1449, 1460, 2522, 1245, 622, 2358, 2730, 3412, 3506, 1493, 730, 2395, 1195, 2645, 2889, 2916, 2929, 1460, 2741, 2645, 3365, 3730, 3785, 1748, 2793, 2411, 1195, 2707, 3401, 3492, 3506, 2745, 1210, 2651, 1323, 2709, 2858, 2901, 1372, 1213, 573, 2333, 2709, 2890, 2906, 1389, 694, 2363, 1179, 1621, 1705, 1876, 2922, 1388, 2733, 1365, 2857, 2962, 2985, 1492, 2778, 1370, 2731, 1429, 1865, 1892, 2986, 1461, 694, 2646, 3661, 2853, 2898, 2922, 1453, 686, 2351, 1175, 1611, 1701, 1708, 2774, 1373, 1181, 2637, 3350, 3477, 1450, 1461, 730, 2395, 1197, 1429, 1738, 1764, 2794, 1269, 694, 2390, 2730, 2900, 3026, 1497, 746, 2413, 1197, 2709, 2890, 2981, 1458, 2485, 1238, 2711, 1351, 1683, 1865, 2901, 1386, 2667, 1323, 2699, 3398, 3491, 1482, 2774, 1243, 619, 2379, 2725, 2898, 2921, 1397, 374, 2231, 603, 1323, 1381, 1460, 2522, 1261, 365, 2230, 2726, 3410, 3497, 1492, 2778, 2395, 1195, 1619, 1833, 1890, 2985, 1458, 2741, 1365, 2853, 3474, 3785, 1746, 2793, 1387, 1195, 2645, 3369, 3412, 3498, 2485, 1210, 2619, 1179, 2637, 2730, 2773, 730, 2397, 1118, 2606, 3226, 3413, 1714, 1721, 1210, 2653, 1325, 2709, 2898, 2984, 2996, 1465, 730, 2394, 2890, 3492, 3793, 1768, 2922, 1389, 1333, 1685, 3402, 3496, 3540, 1754, 1371, 669, 1579, 2837, 2890, 2965, 1450, 2734, 2350, 3215, 1319, 1685, 1706, 2774, 1373, 669]

    static let UMALQURA_YEAR_START = 1300

    static let UMALQURA_YEAR_END = 1600

    override protected func handleGetLimit(field: Int32, limitType: Int32): Int32 {
        return LIMITS[Int64(field)][Int64(limitType)]
    }

    static let UMALQURA_YEAR_START_ESTIMATE_FIX: Array<UInt8> = [0, 0, 255, 0, 255, 0, 0, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 255, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 255, 255, 0, 0, 0, 1, 0, 0, 255, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0, 0, 0, 1, 1, 0, 0, 255, 0, 1, 0, 1, 1, 0, 0, 255, 0, 1, 0, 0, 0, 255, 0, 1, 0, 1, 0, 0, 0, 255, 0, 0, 0, 0, 255, 255, 0, 255, 0, 1, 0, 0, 0, 255, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 255, 255, 0, 0, 0, 1, 0, 0, 255, 255, 0, 255, 0, 0, 255, 255, 0, 255, 0, 255, 0, 0, 255, 255, 0, 0, 0, 0, 0, 0, 255, 0, 1, 0, 1, 1, 0, 0, 255, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 255, 0, 1, 0, 0, 255, 255, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 255, 0, 0, 0, 1, 1, 0, 0, 255, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 255, 0, 0, 0, 1, 0, 0, 0, 255, 0, 0, 0, 0, 0, 255, 0, 255, 0, 1, 0, 0, 0, 255, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 255, 0, 0, 0, 0, 1, 0, 0, 0, 255, 0, 0, 0, 0, 255, 255, 0, 255, 0, 1, 0, 0, 255, 255, 0, 0, 1, 1, 0, 0, 255, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]

    static func civilLeapYear(year: Int32): Bool {
        return (14 + 11 * year) % 30 < 11
    }

    private func yearStart(year: Int32): Int64 {
        return algorithm.yearStart(year)
    }

    static func trueMonthStart(month: Int64): Int64 {
        var start = cache.get(month)
        if (start == CalendarCache.EMPTY) {
            var origin = HIJRA_MILLIS + Int64(floor(Float64(month) * CalendarAstronomer.SYNODIC_MONTH)) * ONE_DAY
            var age = moonAge(origin)
            if (moonAge(origin) >= 0.0) {
            } else {
            }
            start = (origin - HIJRA_MILLIS) / ONE_DAY + 1
            cache.put(month, start)
        }
        return start
    }

    static func moonAge(time: Int64): Float64 {
        var age = (CalendarAstronomer(time)).getMoonAge()
        age = age * 180.0 / Math.PI
        if (age > 180.0) {
            age = age - 360.0
        }
        return age
    }

    private static var cache: CalendarCache = CalendarCache()

    private var civil = true

    private var cType: IslamicCalendar_CalculationType = IslamicCalendar_CalculationType.ISLAMIC_CIVIL

     private var algorithm = CIVIL_ALGORITHM

    override protected func handleGetMonthLength(extendedYear: Int32, month: Int32): Int32 {
        return algorithm.monthLength(extendedYear, month)
    }

    override protected func handleGetYearLength(extendedYear: Int32): Int32 {
        return algorithm.yearLength(extendedYear)
    }

    override protected func handleComputeMonthStart(eyear: Int32, month: Int32, useMonth: Bool): Int32 {
        return Int32(algorithm.monthStart(eyear, month) + algorithm.epoch() - 1)
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
        algorithm.compute(Int64(julianDay), internalGetTimeInMillis(), <-- Unimplemented feature LAMBDA_EXPRESSION: (year)->{
            internalSet(ERA, 0);
            internalSet(YEAR, year);
            internalSet(EXTENDED_YEAR, year);
        } -->, <-- Unimplemented feature LAMBDA_EXPRESSION: (month)->{
            internalSet(MONTH, month);
            internalSet(ORDINAL_MONTH, month);
        } -->, <-- Unimplemented feature LAMBDA_EXPRESSION: (dayOfMonth)->{
            internalSet(DAY_OF_MONTH, dayOfMonth);
        } -->, <-- Unimplemented feature LAMBDA_EXPRESSION: (dayOfYear)->{
            internalSet(DAY_OF_YEAR, dayOfYear);
        } -->)
    }

    public func setCalculationType(Type: IslamicCalendar_CalculationType): Unit {
        cType = Type
        match (cType) {
            case IslamicCalendar_CalculationType.ISLAMIC_UMALQURA => algorithm = UMALQURA_ALGORITHM
            case IslamicCalendar_CalculationType.ISLAMIC => algorithm = ISLAMIC_ALGORITHM
            case IslamicCalendar_CalculationType.ISLAMIC_TBLA => algorithm = TBLA_ALGORITHM
            case IslamicCalendar_CalculationType.ISLAMIC_CIVIL => algorithm = CIVIL_ALGORITHM
            case _ => algorithm = CIVIL_ALGORITHM
        }
        civil = algorithm.isCivil()
    }

    public func getCalculationType(): IslamicCalendar_CalculationType {
        return algorithm.getType()
    }

    private func setCalcTypeForLocale(locale: ULocale): Unit {
        let localeCalType = CalendarUtil.getCalendarType(locale)
        if ("islamic-civil".equals(localeCalType)) {
            setCalculationType(IslamicCalendar_CalculationType.ISLAMIC_CIVIL)
        } else if ("islamic-umalqura".equals(localeCalType)) {
            setCalculationType(IslamicCalendar_CalculationType.ISLAMIC_UMALQURA)
        } else if ("islamic-tbla".equals(localeCalType)) {
            setCalculationType(IslamicCalendar_CalculationType.ISLAMIC_TBLA)
        } else if (localeCalType.startsWith("islamic")) {
            setCalculationType(IslamicCalendar_CalculationType.ISLAMIC)
        } else {
            setCalculationType(IslamicCalendar_CalculationType.ISLAMIC_CIVIL)
        }
    }

    public override func getType(): String {
        return algorithm.getType().bcpTypeMethod()
    }

    private func readObject(input: ObjectInputStream): Unit {
        input.defaultReadObject()
        if (cType.isNone()) {
            cType = if (civil) { IslamicCalendar_CalculationType.ISLAMIC_CIVIL } else { IslamicCalendar_CalculationType.ISLAMIC }
        }
        setCalculationType(cType)
    }

    public override func inTemporalLeapYear(): Bool {
        return getActualMaximum(DAY_OF_YEAR) == 355
    }
}


interface IslamicCalendar_Algorithm {
    public func isCivil(): Bool

    public func getType(): IslamicCalendar_CalculationType

    public func epoch(): Int64

    public func yearStart(year: Int32): Int64

    public func monthStart(year: Int32, month: Int32): Int64

    public func monthLength(year: Int32, month: Int32): Int32

    public func yearLength(year: Int32): Int32

    public func compute(julianDays: Int64, current: Int64, yearConsumer: IntConsumer, monthConsumer: IntConsumer, dayOfMonthConsumer: IntConsumer, dayOfYearConsumer: IntConsumer): Unit
}

class IslamicCalendar_IslamicAlgorithm <: IslamicCalendar_Algorithm {

    public override func isCivil(): Bool {
        return false
    }

    public override func getType(): IslamicCalendar_CalculationType {
        return IslamicCalendar_CalculationType.ISLAMIC
    }

    public override func epoch(): Int64 {
        return IslamicCalendar.CIVIL_EPOCH
    }

    public override func yearStart(year: Int32): Int64 {
        return monthStart(year, 0)
    }

    public override func monthStart(year: Int32, month: Int32): Int64 {
        return IslamicCalendar.trueMonthStart(Int64(12 * ((year + month / 12) - 1) + (month % 12)))
    }

    public override func monthLength(year: Int32, month: Int32): Int32 {
        var tempmonth = month
        tempmonth += 12 * (year - 1)
        return Int32(IslamicCalendar.trueMonthStart(Int64(tempmonth + 1)) - IslamicCalendar.trueMonthStart(Int64(tempmonth)))
    }

    public override func yearLength(year: Int32): Int32 {
        let month = 12 * (year - 1)
        return Int32(IslamicCalendar.trueMonthStart(Int64(month + 12)) - IslamicCalendar.trueMonthStart(Int64(month)))
    }

    public override func compute(julianDays: Int64, current: Int64, yearConsumer: IntConsumer, monthConsumer: IntConsumer, dayOfMonthConsumer: IntConsumer, dayOfYearConsumer: IntConsumer): Unit {
        let days = julianDays - epoch()
        var month = Int32(floor(Float64(days) / CalendarAstronomer.SYNODIC_MONTH))
        var monthStart = Int64(floor(Float64(month) * CalendarAstronomer.SYNODIC_MONTH - 1.0))
        if (days - monthStart >= 25 && IslamicCalendar.moonAge(current) > 0.0) {
            month++
        }
        while ((match (0) { case _ => monthStart = IslamicCalendar.trueMonthStart(Int64(month)); monthStart }) > days) {
            month--
        }
        let year = if (month >= 0) { ((month / 12) + 1) } else { ((month + 1) / 12) }
        month = ((month % 12) + 12) % 12
        yearConsumer.accept(year)
        monthConsumer.accept(month)
        dayOfMonthConsumer.accept(Int32(days - monthStart(year, month)) + 1)
        dayOfYearConsumer.accept(Int32(days - yearStart(year) + 1))
    }
}


class IslamicCalendar_CivilAlgorithm <: IslamicCalendar_Algorithm {

    public override func isCivil(): Bool {
        return true
    }

    public override func getType(): IslamicCalendar_CalculationType {
        return IslamicCalendar_CalculationType.ISLAMIC_CIVIL
    }

    public override func epoch(): Int64 {
        return IslamicCalendar.CIVIL_EPOCH
    }

    public override func yearStart(year: Int32): Int64 {
        return Int64((year - 1) * 354) + Int64(floor((Float64(3 + 11 * year)) / 30.0))
    }

    public override func monthStart(year: Int32, month: Int32): Int64 {
        return Int64(ceil(29.5 * (Float64(month % 12)))) + yearStart(year + month / 12)
    }

    public override func monthLength(year: Int32, month: Int32): Int32 {
        var length = 29
        if (month % 2 == 0) {
            length++
        }
        if (month == IslamicCalendar.DHU_AL_HIJJAH && IslamicCalendar.civilLeapYear(year)) {
            length++
        }
        return length
    }

    public override func yearLength(year: Int32): Int32 {
        return 354 + (if (IslamicCalendar.civilLeapYear(year)) { 1 } else { 0 })
    }

    public override func compute(julianDays: Int64, current: Int64, yearConsumer: IntConsumer, monthConsumer: IntConsumer, dayOfMonthConsumer: IntConsumer, dayOfYearConsumer: IntConsumer): Unit {
        let days = julianDays - epoch()
        let year = Int32(floor((Float64(30 * days + 10646)) / 10631.0))
        var month = Int32(ceil((Float64(days - 29 - yearStart(year))) / 29.5))
        month = min(month, 11)
        yearConsumer.accept(year)
        monthConsumer.accept(month)
        dayOfMonthConsumer.accept(Int32(days - monthStart(year, month)) + 1)
        dayOfYearConsumer.accept(Int32(days - yearStart(year) + 1))
    }
}


class IslamicCalendar_TBLAAlgorithm <: IslamicCalendar_CivilAlgorithm {
    init() {
        super()
    }

    public override func isCivil(): Bool {
        return false
    }

    public override func getType(): IslamicCalendar_CalculationType {
        return IslamicCalendar_CalculationType.ISLAMIC_TBLA
    }

    public override func epoch(): Int64 {
        return IslamicCalendar.ASTRONOMICAL_EPOCH
    }
}


class IslamicCalendar_UmalquraAlgorithm <: IslamicCalendar_Algorithm {

    public override func isCivil(): Bool {
        return false
    }

    public override func getType(): IslamicCalendar_CalculationType {
        return IslamicCalendar_CalculationType.ISLAMIC_UMALQURA
    }

    public override func epoch(): Int64 {
        return IslamicCalendar.CIVIL_EPOCH
    }

    public override func yearStart(year: Int32): Int64 {
        if (year < IslamicCalendar.UMALQURA_YEAR_START || year > IslamicCalendar.UMALQURA_YEAR_END) {
            return IslamicCalendar.CIVIL_ALGORITHM.yearStart(year)
        }
        let index = year - IslamicCalendar.UMALQURA_YEAR_START
        let yrStartLinearEstimate = Int32((354.3672 * Float64(index)) + 460322.05 + 0.5)
        return Int64(yrStartLinearEstimate + Int32(IslamicCalendar.UMALQURA_YEAR_START_ESTIMATE_FIX[Int64(index)]))
    }

    public override func monthStart(year: Int32, month: Int32): Int64 {
        var tempyear = year
        var tempmonth = month
        tempyear += tempmonth / 12
        tempmonth %= 12
        if (tempyear < IslamicCalendar.UMALQURA_YEAR_START) {
            return IslamicCalendar.CIVIL_ALGORITHM.monthStart(tempyear, tempmonth)
        }
        var ms = yearStart(tempyear)
        var i = 0
        while (i < tempmonth) {
            ms += Int64(monthLength(tempyear, i))
            i++
        }
        return ms
    }

    public override func monthLength(year: Int32, month: Int32): Int32 {
        if (year < IslamicCalendar.UMALQURA_YEAR_START || year > IslamicCalendar.UMALQURA_YEAR_END) {
            return IslamicCalendar.CIVIL_ALGORITHM.monthLength(year, month)
        }
        let index = (year - IslamicCalendar.UMALQURA_YEAR_START)
        let mask = (shl(1, (11 - month)))
        if ((IslamicCalendar.UMALQURA_MONTHLENGTH[Int64(index)] & mask) != 0) {
            return 30
        }
        return 29
    }

    public override func yearLength(year: Int32): Int32 {
        if (year < IslamicCalendar.UMALQURA_YEAR_START || year > IslamicCalendar.UMALQURA_YEAR_END) {
            return IslamicCalendar.CIVIL_ALGORITHM.yearLength(year)
        }
        var length = 0
        var i = 0
        while (i < 12) {
            length += monthLength(year, i)
            i++
        }
        return length
    }

    public override func compute(julianDays: Int64, current: Int64, yearConsumer: IntConsumer, monthConsumer: IntConsumer, dayOfMonthConsumer: IntConsumer, dayOfYearConsumer: IntConsumer): Unit {
        let days = julianDays - epoch()
        if (days < yearStart(IslamicCalendar.UMALQURA_YEAR_START)) {
            IslamicCalendar.CIVIL_ALGORITHM.compute(julianDays, current, yearConsumer, monthConsumer, dayOfMonthConsumer, dayOfYearConsumer)
            return
        }
        var year = Int32((Float64(days) - (460322.05 + 0.5)) / 354.3672) + IslamicCalendar.UMALQURA_YEAR_START - 1
        var month = 0
        let monthStart: Int64
        var d = 1
        while (d > 0) {
            year++
            d = days - yearStart(year) + 1
            let yearLength = yearLength(year)
            if (d == Int64(yearLength)) {
                month = 11
                break
            } else if (d < Int64(yearLength)) {
                var monthLen = monthLength(year, month)
                month = 0
                while (d > Int64(monthLen)) {
                    d -= Int64(monthLen)
                    monthLen = monthLength(year, match (0) { case _ => month++; month })
                }
                break
            }
        }
        yearConsumer.accept(year)
        monthConsumer.accept(month)
        dayOfMonthConsumer.accept(Int32(days - monthStart(year, month)) + 1)
        dayOfYearConsumer.accept(Int32(days - yearStart(year) + 1))
    }
}


public class IslamicCalendar_CalculationType <: Enum<IslamicCalendar_CalculationType> {
    public static let ISLAMIC = IslamicCalendar_CalculationType("ISLAMIC", 0, "islamic")

    public static let ISLAMIC_CIVIL = IslamicCalendar_CalculationType("ISLAMIC_CIVIL", 1, "islamic-civil")

    public static let ISLAMIC_UMALQURA = IslamicCalendar_CalculationType("ISLAMIC_UMALQURA", 2, "islamic-umalqura")

    public static let ISLAMIC_TBLA = IslamicCalendar_CalculationType("ISLAMIC_TBLA", 3, "islamic-tbla")

    private static func _values(): Array<IslamicCalendar_CalculationType> {
        return [IslamicCalendar_CalculationType.ISLAMIC, IslamicCalendar_CalculationType.ISLAMIC_CIVIL, IslamicCalendar_CalculationType.ISLAMIC_UMALQURA, IslamicCalendar_CalculationType.ISLAMIC_TBLA]
    }

    private static let _VALUES = IslamicCalendar_CalculationType._values()

    public static func values(): Array<IslamicCalendar_CalculationType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): IslamicCalendar_CalculationType {
        return (TypeInfo.of<IslamicCalendar_CalculationType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as IslamicCalendar_CalculationType
    }

    private var bcpType: String

    init(_enum_name: String, _enum_ordinal: Int32, bcpType: String) {
        super(_enum_name, _enum_ordinal)
        this.bcpType = bcpType
    }

    public func bcpTypeMethod(): String {
        return bcpType
    }
}
