package icu4cj.util

public class ChineseCalendar <: Calendar {
    private static let serialVersionUID = 7312110751940929420

    private var epochYear: Int32 = 0

    private var zoneAstro: TimeZone

     private var winterSolsticeCache: CalendarCache = CalendarCache()

     private var newYearCache: CalendarCache = CalendarCache()

     private var hasLeapMonthBetweenWinterSolstices: Bool = false

    public init() {
        this(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT), CHINESE_EPOCH_YEAR, CHINA_ZONE)
    }

    public init(date: DateTime) {
        this(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT), CHINESE_EPOCH_YEAR, CHINA_ZONE)
        setTime(date)
    }

    public init(year: Int32, month: Int32, isLeapMonth: Int32, date: Int32) {
        this(year, month, isLeapMonth, date, 0, 0, 0)
    }

    public init(year: Int32, month: Int32, isLeapMonth: Int32, date: Int32, hour: Int32, minute: Int32, second: Int32) {
        this(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT), CHINESE_EPOCH_YEAR, CHINA_ZONE)
        this.set(MILLISECOND, 0)
        this.set(YEAR, year)
        this.set(MONTH, month)
        this.set(IS_LEAP_MONTH, isLeapMonth)
        this.set(DATE, date)
        this.set(HOUR_OF_DAY, hour)
        this.set(MINUTE, minute)
        this.set(SECOND, second)
    }

    public init(era: Int32, year: Int32, month: Int32, isLeapMonth: Int32, date: Int32) {
        this(era, year, month, isLeapMonth, date, 0, 0, 0)
    }

    public init(era: Int32, year: Int32, month: Int32, isLeapMonth: Int32, date: Int32, hour: Int32, minute: Int32, second: Int32) {
        this(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT), CHINESE_EPOCH_YEAR, CHINA_ZONE)
        this.set(MILLISECOND, 0)
        this.set(ERA, era)
        this.set(YEAR, year)
        this.set(MONTH, month)
        this.set(IS_LEAP_MONTH, isLeapMonth)
        this.set(DATE, date)
        this.set(HOUR_OF_DAY, hour)
        this.set(MINUTE, minute)
        this.set(SECOND, second)
    }

    public init(aLocale: Locale) {
        this(TimeZone.forLocaleOrDefault(aLocale), ULocale.forLocale(aLocale), CHINESE_EPOCH_YEAR, CHINA_ZONE)
    }

    public init(zone: TimeZone) {
        this(zone, ULocale.getDefault(ULocale_Category.FORMAT), CHINESE_EPOCH_YEAR, CHINA_ZONE)
    }

    public init(zone: TimeZone, aLocale: Locale) {
        this(zone, ULocale.forLocale(aLocale), CHINESE_EPOCH_YEAR, CHINA_ZONE)
    }

    public init(locale: ULocale) {
        this(TimeZone.forULocaleOrDefault(locale), locale, CHINESE_EPOCH_YEAR, CHINA_ZONE)
    }

    public init(zone: TimeZone, locale: ULocale) {
        this(zone, locale, CHINESE_EPOCH_YEAR, CHINA_ZONE)
    }

    
    protected init(zone: TimeZone, locale: ULocale, epochYear: Int32, zoneAstroCalc: TimeZone) {
        super(zone, locale)
        this.epochYear = epochYear
        this.zoneAstro = zoneAstroCalc
        setTimeInMillis(DateTime.now().toUnixTimeStamp().toMilliseconds())
    }

    private static let LIMITS: Array<Array<Int32>> = [[1, 1, 83333, 83333], [1, 1, 60, 60], [0, 0, 11, 11], [1, 1, 50, 55], [0], [1, 1, 29, 30], [1, 1, 353, 385], [0], [-1, -1, 5, 5], [0], [0], [0], [0], [0], [0], [0], [0], [-5000000, -5000000, 5000000, 5000000], [0], [-5000000, -5000000, 5000000, 5000000], [0], [0], [0, 0, 1, 1], [0, 0, 11, 12]]

    override protected func handleGetLimit(field: Int32, limitType: Int32): Int32 {
        return LIMITS[Int64(field)][Int64(limitType)]
    }

    override protected func handleGetExtendedYear(): Int32 {
        let year: Int32
        if (newestStamp(ERA, YEAR, UNSET) <= getStamp(EXTENDED_YEAR)) {
            year = internalGet(EXTENDED_YEAR, 1)
        } else {
            let cycle = internalGet(ERA, 1) - 1
            year = cycle * 60 + internalGet(YEAR, 1) - (epochYear - CHINESE_EPOCH_YEAR)
        }
        return year
    }

    override protected func handleGetMonthLength(extendedYear: Int32, month: Int32): Int32 {
        let thisStart = handleComputeMonthStart(extendedYear, month, true) - EPOCH_JULIAN_DAY + 1
        let nextStart = newMoonNear(thisStart + SYNODIC_GAP, true)
        return nextStart - thisStart
    }

    override protected func handleGetDateFormat(pattern: String, override: String, locale: ULocale): DateFormat {
        return super.handleGetDateFormat(pattern, override, locale)
    }

    static let CHINESE_DATE_PRECEDENCE = [[[DAY_OF_MONTH], [WEEK_OF_YEAR, DAY_OF_WEEK], [WEEK_OF_MONTH, DAY_OF_WEEK], [DAY_OF_WEEK_IN_MONTH, DAY_OF_WEEK], [WEEK_OF_YEAR, DOW_LOCAL], [WEEK_OF_MONTH, DOW_LOCAL], [DAY_OF_WEEK_IN_MONTH, DOW_LOCAL], [DAY_OF_YEAR], [RESOLVE_REMAP | DAY_OF_MONTH, IS_LEAP_MONTH]], [[WEEK_OF_YEAR], [WEEK_OF_MONTH], [DAY_OF_WEEK_IN_MONTH], [RESOLVE_REMAP | DAY_OF_WEEK_IN_MONTH, DAY_OF_WEEK], [RESOLVE_REMAP | DAY_OF_WEEK_IN_MONTH, DOW_LOCAL]]]

    override protected func getFieldResolutionTable(): Array<Array<Array<Int32>>> {
        return CHINESE_DATE_PRECEDENCE
    }

    private func offsetMonth(newMoon: Int32, dom: Int32, delta: Int32): Unit {
        var tempnewMoon = newMoon
        tempnewMoon += Int32(CalendarAstronomer.SYNODIC_MONTH * (Float64(delta) - 0.5))
        tempnewMoon = newMoonNear(tempnewMoon, true)
        let jd = tempnewMoon + EPOCH_JULIAN_DAY - 1 + dom
        if (dom > 29) {
            set(JULIAN_DAY, jd - 1)
            complete()
            if (getActualMaximum(DAY_OF_MONTH) >= dom) {
                set(JULIAN_DAY, jd)
            }
        } else {
            set(JULIAN_DAY, jd)
        }
    }

    public override func add(field: Int32, amount: Int32): Unit {
        match (field) {
            case 2 | 23 => if (amount != 0) {
                let dom = get(DAY_OF_MONTH)
                let day = get(JULIAN_DAY) - EPOCH_JULIAN_DAY
                let moon = day - dom + 1
                offsetMonth(moon, dom, amount)
            }
            case _ => super.add(field, amount)
        }
    }

    public override func roll(field: Int32, amount: Int32): Unit {
        match (field) {
            case 2 | 23 => if (amount != 0) {
                let dom = get(DAY_OF_MONTH)
                let day = get(JULIAN_DAY) - EPOCH_JULIAN_DAY
                let moon = day - dom + 1
                var m = get(MONTH)
                if (hasLeapMonthBetweenWinterSolstices) {
                    if (get(IS_LEAP_MONTH) == 1) {
                        m++
                    } else {
                        var moon1 = moon - Int32(CalendarAstronomer.SYNODIC_MONTH * (Float64(m) - 0.5))
                        moon1 = newMoonNear(moon1, true)
                        if (isLeapMonthBetween(moon1, moon)) {
                            m++
                        }
                    }
                }
                let n = if (hasLeapMonthBetweenWinterSolstices) { 13 } else { 12 }
                var newM = (m + amount) % n
                if (newM < 0) {
                    newM += n
                }
                if (newM != m) {
                    offsetMonth(moon, dom, newM - m)
                }
            }
            case _ => super.roll(field, amount)
        }
    }

    private static let CHINESE_EPOCH_YEAR = -2636

    private static let CHINA_ZONE = SimpleTimeZone(8 * ONE_HOUR, "CHINA_ZONE").freeze()

    private static let SYNODIC_GAP = 25

    private func daysToMillis(days: Int32): Int64 {
        let millis = Int64(days) * ONE_DAY
        return millis - Int64(zoneAstro.getOffset(millis))
    }

    private func millisToDays(millis: Int64): Int32 {
        return Int32(floorDivide(millis + Int64(zoneAstro.getOffset(millis)), ONE_DAY))
    }

    private func winterSolstice(gyear: Int32): Int32 {
        var cacheValue = winterSolsticeCache.get(Int64(gyear))
        if (cacheValue == CalendarCache.EMPTY) {
            let ms = daysToMillis(computeGregorianMonthStart(gyear, DECEMBER) + 1 - EPOCH_JULIAN_DAY)
            let solarLong = (CalendarAstronomer(ms)).getSunTime(CalendarAstronomer.WINTER_SOLSTICE, true)
            cacheValue = Int64(millisToDays(solarLong))
            winterSolsticeCache.put(Int64(gyear), cacheValue)
        }
        return Int32(cacheValue)
    }

    private func newMoonNear(days: Int32, after: Bool): Int32 {
        let newMoon = (CalendarAstronomer(daysToMillis(days))).getMoonTime(CalendarAstronomer.NEW_MOON, after)
        return millisToDays(newMoon)
    }

    private func synodicMonthsBetween(day1: Int32, day2: Int32): Int32 {
        return Int32(Math.round((Float64(day2 - day1)) / CalendarAstronomer.SYNODIC_MONTH))
    }

    private func majorSolarTerm(days: Int32): Int32 {
        var term = (Int32(floor(6.0 * (CalendarAstronomer(daysToMillis(days))).getSunLongitude() / Math.PI)) + 2) % 12
        if (term < 1) {
            term += 12
        }
        return term
    }

    private func hasNoMajorSolarTerm(newMoon: Int32): Bool {
        let mst = majorSolarTerm(newMoon)
        let nmn = newMoonNear(newMoon + SYNODIC_GAP, true)
        let mstt = majorSolarTerm(nmn)
        return mst == mstt
    }

    private func isLeapMonthBetween(newMoon1: Int32, newMoon2: Int32): Bool {
        if (synodicMonthsBetween(newMoon1, newMoon2) >= 50) {
            throw IllegalArgumentException("isLeapMonthBetween(" + newMoon1.toString() + ", " + newMoon2.toString() + "): Invalid parameters")
        }
        return (newMoon2 >= newMoon1) && (isLeapMonthBetween(newMoon1, newMoonNear(newMoon2 - SYNODIC_GAP, false)) || hasNoMajorSolarTerm(newMoon2))
    }

    override protected func handleComputeFields(julianDay: Int32): Unit {
        computeChineseFields(julianDay - EPOCH_JULIAN_DAY, getGregorianYear(), getGregorianMonth(), true)
    }

    private func computeChineseFields(days: Int32, gyear: Int32, gmonth: Int32, setAllFields: Bool): Unit {
        let solsticeBefore: Int32
        var solsticeAfter = winterSolstice(gyear)
        if (days < solsticeAfter) {
            solsticeBefore = winterSolstice(gyear - 1)
        } else {
            solsticeBefore = solsticeAfter
            solsticeAfter = winterSolstice(gyear + 1)
        }
        let firstMoon = newMoonNear(solsticeBefore + 1, true)
        let lastMoon = newMoonNear(solsticeAfter + 1, false)
        let thisMoon = newMoonNear(days + 1, false)
        hasLeapMonthBetweenWinterSolstices = synodicMonthsBetween(firstMoon, lastMoon) == 12
        var month = synodicMonthsBetween(firstMoon, thisMoon)
        var theNewYear = newYear(gyear)
        if (days < theNewYear) {
            theNewYear = newYear(gyear - 1)
        }
        if (hasLeapMonthBetweenWinterSolstices && isLeapMonthBetween(firstMoon, thisMoon)) {
            month--
        }
        if (month < 1) {
            month += 12
        }
        var ordinalMonth = synodicMonthsBetween(theNewYear, thisMoon)
        if (ordinalMonth < 0) {
            ordinalMonth += 12
        }
        let isLeapMonth = hasLeapMonthBetweenWinterSolstices && hasNoMajorSolarTerm(thisMoon) && !isLeapMonthBetween(firstMoon, newMoonNear(thisMoon - SYNODIC_GAP, false))
        internalSet(MONTH, month - 1)
        internalSet(ORDINAL_MONTH, ordinalMonth)
        internalSet(IS_LEAP_MONTH, if (isLeapMonth) { 1 } else { 0 })
        if (setAllFields) {
            var extended_year = gyear - epochYear
            var cycle_year = gyear - CHINESE_EPOCH_YEAR
            if (month < 11 || gmonth >= JULY) {
                extended_year++
                cycle_year++
            }
            let dayOfMonth = days - thisMoon + 1
            internalSet(EXTENDED_YEAR, extended_year)
            let yearOfCycle = Array<Int32>(1) { _ => 0 }
            let cycle = floorDivide(cycle_year - 1, 60, yearOfCycle)
            internalSet(ERA, cycle + 1)
            internalSet(YEAR, yearOfCycle[0] + 1)
            internalSet(DAY_OF_MONTH, dayOfMonth)
            var newYear = newYear(gyear)
            if (days < newYear) {
                newYear = newYear(gyear - 1)
            }
            internalSet(DAY_OF_YEAR, days - newYear + 1)
        }
    }

    private func newYear(gyear: Int32): Int32 {
        var cacheValue = newYearCache.get(Int64(gyear))
        if (cacheValue == CalendarCache.EMPTY) {
            let solsticeBefore = winterSolstice(gyear - 1)
            let solsticeAfter = winterSolstice(gyear)
            let newMoon1 = newMoonNear(solsticeBefore + 1, true)
            let newMoon2 = newMoonNear(newMoon1 + SYNODIC_GAP, true)
            let newMoon11 = newMoonNear(solsticeAfter + 1, false)
            if (synodicMonthsBetween(newMoon1, newMoon11) == 12 && (hasNoMajorSolarTerm(newMoon1) || hasNoMajorSolarTerm(newMoon2))) {
                cacheValue = Int64(newMoonNear(newMoon2 + SYNODIC_GAP, true))
            } else {
                cacheValue = Int64(newMoon2)
            }
            newYearCache.put(Int64(gyear), cacheValue)
        }
        return Int32(cacheValue)
    }

    override protected func handleComputeMonthStart(eyear: Int32, month: Int32, useMonth: Bool): Int32 {
        var tempeyear = eyear
        var tempmonth = month
        if (tempmonth < 0 || tempmonth > 11) {
            let rem = Array<Int32>(1) { _ => 0 }
            tempeyear += floorDivide(tempmonth, 12, rem)
            tempmonth = rem[0]
        }
        let gyear = tempeyear + epochYear - 1
        let newYear = newYear(gyear)
        var newMoon = newMoonNear(newYear + tempmonth * 29, true)
        var julianDay = newMoon + EPOCH_JULIAN_DAY
        let saveMonth = internalGet(MONTH)
        let saveOrdinalMonth = internalGet(ORDINAL_MONTH)
        let saveIsLeapMonth = internalGet(IS_LEAP_MONTH)
        let isLeapMonth = if (useMonth) { saveIsLeapMonth } else { 0 }
        computeGregorianFields(julianDay)
        computeChineseFields(newMoon, getGregorianYear(), getGregorianMonth(), false)
        if (tempmonth != internalGet(MONTH) || isLeapMonth != internalGet(IS_LEAP_MONTH)) {
            newMoon = newMoonNear(newMoon + SYNODIC_GAP, true)
            julianDay = newMoon + EPOCH_JULIAN_DAY
        }
        internalSet(MONTH, saveMonth)
        internalSet(ORDINAL_MONTH, saveOrdinalMonth)
        internalSet(IS_LEAP_MONTH, saveIsLeapMonth)
        return julianDay - 1
    }

    public override func getType(): String {
        return "chinese"
    }

    
    public override func haveDefaultCentury(): Bool {
        return false
    }

    private func readObject(stream: ObjectInputStream): Unit {
        epochYear = CHINESE_EPOCH_YEAR
        zoneAstro = CHINA_ZONE
        stream.defaultReadObject()
        winterSolsticeCache = CalendarCache()
        newYearCache = CalendarCache()
    }

    public override func inTemporalLeapYear(): Bool {
        return getActualMaximum(DAY_OF_YEAR) > 360
    }

    private static var gTemporalLeapMonthCodes: Array<String> = ["M01", "M02", "M03", "M04", "M05", "M06", "M07", "M08", "M09", "M10", "M11", "M12"]

    public override func getTemporalMonthCode(): String {
        let is_leap = get(IS_LEAP_MONTH)
        if (is_leap != 0) {
            return gTemporalLeapMonthCodes[Int64(get(MONTH))]
        }
        return super.getTemporalMonthCode()
    }

    public override func setTemporalMonthCode(temporalMonth: String): Unit {
        if (Int32(temporalMonth.size) != 4 || Char(temporalMonth[0]) != 'M' || Char(temporalMonth[3]) != 'L') {
            set(IS_LEAP_MONTH, 0)
            super.setTemporalMonthCode(temporalMonth)
            return
        }
        var m = 0
        while (m < Int32(gTemporalLeapMonthCodes.size)) {
            if (temporalMonth.equals(gTemporalLeapMonthCodes[Int64(m)])) {
                set(MONTH, m)
                set(IS_LEAP_MONTH, 1)
                return
            }
            m++
        }
        throw IllegalArgumentException("Incorrect temporal Month code: " + (temporalMonth))
    }

    
    override protected func internalGetMonth(): Int32 {
        if (resolveFields(MONTH_PRECEDENCE) == MONTH) {
            return internalGet(MONTH)
        }
        let temp = clone()
        temp.set(Calendar.MONTH, 0)
        temp.set(Calendar.IS_LEAP_MONTH, 0)
        temp.set(Calendar.DATE, 1)
        temp.roll(Calendar.MONTH, internalGet(Calendar.ORDINAL_MONTH))
        internalSet(Calendar.IS_LEAP_MONTH, temp.get(Calendar.IS_LEAP_MONTH))
        let month = temp.get(Calendar.MONTH)
        internalSet(Calendar.MONTH, month)
        return month
    }

    
    override protected func internalGetMonth(defaultValue: Int32): Int32 {
        if (resolveFields(MONTH_PRECEDENCE) == MONTH) {
            return internalGet(MONTH, defaultValue)
        }
        return internalGetMonth()
    }
}
