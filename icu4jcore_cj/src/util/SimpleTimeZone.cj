package icu4cj.util


public class SimpleTimeZone <: BasicTimeZone & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private static let serialVersionUID = -7034676239311322769

    public static let WALL_TIME = 0

    public static let STANDARD_TIME = 1

    public static let UTC_TIME = 2

    public init(rawOffset: Int32, ID: String) {
        super(ID)
        construct(rawOffset, 0, 0, 0, 0, WALL_TIME, 0, 0, 0, 0, WALL_TIME, Grego.MILLIS_PER_HOUR)
    }

    public init(rawOffset: Int32, ID: String, startMonth: Int32, startDay: Int32, startDayOfWeek: Int32, startTime: Int32, endMonth: Int32, endDay: Int32, endDayOfWeek: Int32, endTime: Int32) {
        super(ID)
        construct(rawOffset, startMonth, startDay, startDayOfWeek, startTime, WALL_TIME, endMonth, endDay, endDayOfWeek, endTime, WALL_TIME, Grego.MILLIS_PER_HOUR)
    }

    public init(rawOffset: Int32, ID: String, startMonth: Int32, startDay: Int32, startDayOfWeek: Int32, startTime: Int32, startTimeMode: Int32, endMonth: Int32, endDay: Int32, endDayOfWeek: Int32, endTime: Int32, endTimeMode: Int32, dstSavings: Int32) {
        super(ID)
        construct(rawOffset, startMonth, startDay, startDayOfWeek, startTime, startTimeMode, endMonth, endDay, endDayOfWeek, endTime, endTimeMode, dstSavings)
    }

    public init(rawOffset: Int32, ID: String, startMonth: Int32, startDay: Int32, startDayOfWeek: Int32, startTime: Int32, endMonth: Int32, endDay: Int32, endDayOfWeek: Int32, endTime: Int32, dstSavings: Int32) {
        super(ID)
        construct(rawOffset, startMonth, startDay, startDayOfWeek, startTime, WALL_TIME, endMonth, endDay, endDayOfWeek, endTime, WALL_TIME, dstSavings)
    }

    public override func setID(ID: String): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen SimpleTimeZone instance.")
        }
        super.setID(ID)
        transitionRulesInitialized = false
    }

    public override func setRawOffset(offsetMillis: Int32): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen SimpleTimeZone instance.")
        }
        raw = offsetMillis
        transitionRulesInitialized = false
    }

    public override func getRawOffset(): Int32 {
        return raw
    }

    public func setStartYear(year: Int32): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen SimpleTimeZone instance.")
        }
        getSTZInfo().sy = year
        this.startYear = year
        transitionRulesInitialized = false
    }

    public func setStartRule(month: Int32, dayOfWeekInMonth: Int32, dayOfWeek: Int32, time: Int32): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen SimpleTimeZone instance.")
        }
        getSTZInfo().setStart(month, dayOfWeekInMonth, dayOfWeek, time, -1, false)
        setStartRule(month, dayOfWeekInMonth, dayOfWeek, time, WALL_TIME)
    }

    private func setStartRule(month: Int32, dayOfWeekInMonth: Int32, dayOfWeek: Int32, time: Int32, mode: Int32): Unit {
        if (!(!isFrozenMethod())) {
            throw AssertionError()
        }
        startMonth = month
        startDay = dayOfWeekInMonth
        startDayOfWeek = dayOfWeek
        startTime = time
        startTimeMode = mode
        decodeStartRule()
        transitionRulesInitialized = false
    }

    public func setStartRule(month: Int32, dayOfMonth: Int32, time: Int32): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen SimpleTimeZone instance.")
        }
        getSTZInfo().setStart(month, -1, -1, time, dayOfMonth, false)
        setStartRule(month, dayOfMonth, 0, time, WALL_TIME)
    }

    public func setStartRule(month: Int32, dayOfMonth: Int32, dayOfWeek: Int32, time: Int32, after: Bool): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen SimpleTimeZone instance.")
        }
        getSTZInfo().setStart(month, -1, dayOfWeek, time, dayOfMonth, after)
        setStartRule(month, if (after) { dayOfMonth } else { -dayOfMonth }, -dayOfWeek, time, WALL_TIME)
    }

    public func setEndRule(month: Int32, dayOfWeekInMonth: Int32, dayOfWeek: Int32, time: Int32): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen SimpleTimeZone instance.")
        }
        getSTZInfo().setEnd(month, dayOfWeekInMonth, dayOfWeek, time, -1, false)
        setEndRule(month, dayOfWeekInMonth, dayOfWeek, time, WALL_TIME)
    }

    public func setEndRule(month: Int32, dayOfMonth: Int32, time: Int32): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen SimpleTimeZone instance.")
        }
        getSTZInfo().setEnd(month, -1, -1, time, dayOfMonth, false)
        setEndRule(month, dayOfMonth, WALL_TIME, time)
    }

    public func setEndRule(month: Int32, dayOfMonth: Int32, dayOfWeek: Int32, time: Int32, after: Bool): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen SimpleTimeZone instance.")
        }
        getSTZInfo().setEnd(month, -1, dayOfWeek, time, dayOfMonth, after)
        setEndRule(month, dayOfMonth, dayOfWeek, time, WALL_TIME, after)
    }

    private func setEndRule(month: Int32, dayOfMonth: Int32, dayOfWeek: Int32, time: Int32, mode: Int32, after: Bool): Unit {
        if (!(!isFrozenMethod())) {
            throw AssertionError()
        }
        setEndRule(month, if (after) { dayOfMonth } else { -dayOfMonth }, -dayOfWeek, time, mode)
    }

    private func setEndRule(month: Int32, dayOfWeekInMonth: Int32, dayOfWeek: Int32, time: Int32, mode: Int32): Unit {
        if (!(!isFrozenMethod())) {
            throw AssertionError()
        }
        endMonth = month
        endDay = dayOfWeekInMonth
        endDayOfWeek = dayOfWeek
        endTime = time
        endTimeMode = mode
        decodeEndRule()
        transitionRulesInitialized = false
    }

    public func setDSTSavings(millisSavedDuringDST: Int32): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen SimpleTimeZone instance.")
        }
        if (millisSavedDuringDST == 0) {
            throw IllegalArgumentException()
        }
        dst = millisSavedDuringDST
        transitionRulesInitialized = false
    }

    public override func getDSTSavings(): Int32 {
        return dst
    }

    private func readObject(input: ObjectInputStream): Unit {
        input.defaultReadObject()
        if (xinfo.isSome()) {
            xinfo.applyTo(this)
        }
    }

    public override func toString(): String {
        return "SimpleTimeZone: " + (getID())
    }

    private func getSTZInfo(): STZInfo {
        if (xinfo.isNone()) {
            xinfo = STZInfo()
        }
        return xinfo
    }

    private static let staticMonthLength: Array<UInt8> = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    public override func getOffset(era: Int32, year: Int32, month: Int32, day: Int32, dayOfWeek: Int32, millis: Int32): Int32 {
        if (month < Calendar.JANUARY || month > Calendar.DECEMBER) {
            throw IllegalArgumentException()
        }
        return getOffset(era, year, month, day, dayOfWeek, millis, Grego.monthLength(year, month))
    }

    
    public func getOffset(era: Int32, year: Int32, month: Int32, day: Int32, dayOfWeek: Int32, millis: Int32, monthLength: Int32): Int32 {
        if (month < Calendar.JANUARY || month > Calendar.DECEMBER) {
            throw IllegalArgumentException()
        }
        return getOffset(era, year, month, day, dayOfWeek, millis, Grego.monthLength(year, month), Grego.previousMonthLength(year, month))
    }

    private func getOffset(era: Int32, year: Int32, month: Int32, day: Int32, dayOfWeek: Int32, millis: Int32, monthLength: Int32, prevMonthLength: Int32): Int32 {
        if (true) {
            if ((era != GregorianCalendar.AD && era != GregorianCalendar.BC) || month < Calendar.JANUARY || month > Calendar.DECEMBER || day < 1 || day > monthLength || dayOfWeek < Calendar.SUNDAY || dayOfWeek > Calendar.SATURDAY || millis < 0 || millis >= Grego.MILLIS_PER_DAY || monthLength < 28 || monthLength > 31 || prevMonthLength < 28 || prevMonthLength > 31) {
                throw IllegalArgumentException()
            }
        }
        var result = raw
        if (!useDaylight || year < startYear || era != GregorianCalendar.AD) {
            return result
        }
        let southern = (startMonth > endMonth)
        let startCompare = compareToRule(month, monthLength, prevMonthLength, day, dayOfWeek, millis, if (startTimeMode == UTC_TIME) { -raw } else { 0 }, startMode, startMonth, startDayOfWeek, startDay, startTime)
        var endCompare = 0
        if (southern != (startCompare >= 0)) {
            endCompare = compareToRule(month, monthLength, prevMonthLength, day, dayOfWeek, millis, if (endTimeMode == WALL_TIME) { dst } else { (if (endTimeMode == UTC_TIME) { -raw } else { 0 }) }, endMode, endMonth, endDayOfWeek, endDay, endTime)
        }
        if ((!southern && (startCompare >= 0 && endCompare < 0)) || (southern && (startCompare >= 0 || endCompare < 0))) {
            result += dst
        }
        return result
    }

    public override func getOffsetFromLocal(date: Int64, nonExistingTimeOpt: BasicTimeZone_LocalOption, duplicatedTimeOpt: BasicTimeZone_LocalOption, offsets: Array<Int32>): Unit {
        var tempdate = date
        let nonExistingTimeOptVal = getLocalOptionValue(nonExistingTimeOpt)
        let duplicatedTimeOptVal = getLocalOptionValue(duplicatedTimeOpt)
        offsets[0] = getRawOffset()
        let fields = Array<Int32>(6) { _ => 0 }
        Grego.timeToFields(tempdate, fields)
        offsets[1] = getOffset(GregorianCalendar.AD, fields[0], fields[1], fields[2], fields[3], fields[5]) - offsets[0]
        var recalc = false
        if (offsets[1] > 0) {
            if ((nonExistingTimeOptVal & STD_DST_MASK) == LOCAL_STD || (nonExistingTimeOptVal & STD_DST_MASK) != LOCAL_DST && (nonExistingTimeOptVal & FORMER_LATTER_MASK) != LOCAL_LATTER) {
                tempdate -= Int64(getDSTSavings())
                recalc = true
            }
        } else {
            if ((duplicatedTimeOptVal & STD_DST_MASK) == LOCAL_DST || (duplicatedTimeOptVal & STD_DST_MASK) != LOCAL_STD && (duplicatedTimeOptVal & FORMER_LATTER_MASK) == LOCAL_FORMER) {
                tempdate -= Int64(getDSTSavings())
                recalc = true
            }
        }
        if (recalc) {
            Grego.timeToFields(tempdate, fields)
            offsets[1] = getOffset(GregorianCalendar.AD, fields[0], fields[1], fields[2], fields[3], fields[5]) - offsets[0]
        }
    }

    private static let DOM_MODE = 1

    private static let DOW_IN_MONTH_MODE = 2

    private static let DOW_GE_DOM_MODE = 3

    private static let DOW_LE_DOM_MODE = 4

    private func compareToRule(month: Int32, monthLen: Int32, prevMonthLen: Int32, dayOfMonth: Int32, dayOfWeek: Int32, millis: Int32, millisDelta: Int32, ruleMode: Int32, ruleMonth: Int32, ruleDayOfWeek: Int32, ruleDay: Int32, ruleMillis: Int32): Int32 {
        var tempmillis = millis
        var tempdayOfMonth = dayOfMonth
        var tempdayOfWeek = dayOfWeek
        var tempmonth = month
        var tempruleDay = ruleDay
        tempmillis += millisDelta
        while (tempmillis >= Grego.MILLIS_PER_DAY) {
            tempmillis -= Grego.MILLIS_PER_DAY
            tempdayOfMonth++
            tempdayOfWeek = 1 + (tempdayOfWeek % 7)
            if (tempdayOfMonth > monthLen) {
                tempdayOfMonth = 1
                tempmonth++
            }
        }
        while (tempmillis < 0) {
            tempdayOfMonth--
            tempdayOfWeek = 1 + ((tempdayOfWeek + 5) % 7)
            if (tempdayOfMonth < 1) {
                tempdayOfMonth = prevMonthLen
                tempmonth--
            }
            tempmillis += Grego.MILLIS_PER_DAY
        }
        if (tempmonth < ruleMonth) {
            return -1
        } else if (tempmonth > ruleMonth) {
            return 1
        }
        var ruleDayOfMonth = 0
        if (tempruleDay > monthLen) {
            tempruleDay = monthLen
        }
        match (ruleMode) {
            case 1 => ruleDayOfMonth = tempruleDay
            case 2 => if (tempruleDay > 0) {
                ruleDayOfMonth = 1 + (tempruleDay - 1) * 7 + (7 + ruleDayOfWeek - (tempdayOfWeek - tempdayOfMonth + 1)) % 7
            } else {
                ruleDayOfMonth = monthLen + (tempruleDay + 1) * 7 - (7 + (tempdayOfWeek + monthLen - tempdayOfMonth) - ruleDayOfWeek) % 7
            }
            case 3 => ruleDayOfMonth = tempruleDay + (49 + ruleDayOfWeek - tempruleDay - tempdayOfWeek + tempdayOfMonth) % 7
            case 4 => ruleDayOfMonth = tempruleDay - (49 - ruleDayOfWeek + tempruleDay + tempdayOfWeek - tempdayOfMonth) % 7
            case _ => ()
        }
        if (tempdayOfMonth < ruleDayOfMonth) {
            return -1
        } else if (tempdayOfMonth > ruleDayOfMonth) {
            return 1
        }
        if (tempmillis < ruleMillis) {
            return -1
        } else if (tempmillis > ruleMillis) {
            return 1
        } else {
            return 0
        }
    }

    private var raw: Int32 = 0

    private var dst = 3600000

    private var xinfo: STZInfo

    private var startMonth: Int32 = 0

    private var startDay: Int32 = 0

    private var startDayOfWeek: Int32 = 0

    private var startTime: Int32 = 0

    private var startTimeMode: Int32 = 0

    private var endTimeMode: Int32 = 0

    private var endMonth: Int32 = 0

    private var endDay: Int32 = 0

    private var endDayOfWeek: Int32 = 0

    private var endTime: Int32 = 0

    private var startYear: Int32 = 0

    private var useDaylight: Bool = false

    private var startMode: Int32 = 0

    private var endMode: Int32 = 0

    public override func useDaylightTime(): Bool {
        return useDaylight
    }

    public override func observesDaylightTime(): Bool {
        return useDaylight
    }

    public override func inDaylightTime(date: DateTime): Bool {
        let gc = GregorianCalendar(this)
        gc.setTime(date)
        return gc.inDaylightTime()
    }

    private func construct(_raw: Int32, _startMonth: Int32, _startDay: Int32, _startDayOfWeek: Int32, _startTime: Int32, _startTimeMode: Int32, _endMonth: Int32, _endDay: Int32, _endDayOfWeek: Int32, _endTime: Int32, _endTimeMode: Int32, _dst: Int32): Unit {
        raw = _raw
        startMonth = _startMonth
        startDay = _startDay
        startDayOfWeek = _startDayOfWeek
        startTime = _startTime
        startTimeMode = _startTimeMode
        endMonth = _endMonth
        endDay = _endDay
        endDayOfWeek = _endDayOfWeek
        endTime = _endTime
        endTimeMode = _endTimeMode
        dst = _dst
        startYear = 0
        startMode = DOM_MODE
        endMode = DOM_MODE
        decodeRules()
        if (_dst == 0) {
            throw IllegalArgumentException()
        }
    }

    private func decodeRules(): Unit {
        decodeStartRule()
        decodeEndRule()
    }

    private func decodeStartRule(): Unit {
        useDaylight = (startDay != 0) && (endDay != 0)
        if (useDaylight && dst == 0) {
            dst = Grego.MILLIS_PER_DAY
        }
        if (startDay != 0) {
            if (startMonth < Calendar.JANUARY || startMonth > Calendar.DECEMBER) {
                throw IllegalArgumentException()
            }
            if (startTime < 0 || startTime > Grego.MILLIS_PER_DAY || startTimeMode < WALL_TIME || startTimeMode > UTC_TIME) {
                throw IllegalArgumentException()
            }
            if (startDayOfWeek == 0) {
                startMode = DOM_MODE
            } else {
                if (startDayOfWeek > 0) {
                    startMode = DOW_IN_MONTH_MODE
                } else {
                    startDayOfWeek = -startDayOfWeek
                    if (startDay > 0) {
                        startMode = DOW_GE_DOM_MODE
                    } else {
                        startDay = -startDay
                        startMode = DOW_LE_DOM_MODE
                    }
                }
                if (startDayOfWeek > Calendar.SATURDAY) {
                    throw IllegalArgumentException()
                }
            }
            if (startMode == DOW_IN_MONTH_MODE) {
                if (startDay < -5 || startDay > 5) {
                    throw IllegalArgumentException()
                }
            } else if (startDay < 1 || startDay > Int32(staticMonthLength[Int64(startMonth)])) {
                throw IllegalArgumentException()
            }
        }
    }

    private func decodeEndRule(): Unit {
        useDaylight = (startDay != 0) && (endDay != 0)
        if (useDaylight && dst == 0) {
            dst = Grego.MILLIS_PER_DAY
        }
        if (endDay != 0) {
            if (endMonth < Calendar.JANUARY || endMonth > Calendar.DECEMBER) {
                throw IllegalArgumentException()
            }
            if (endTime < 0 || endTime > Grego.MILLIS_PER_DAY || endTimeMode < WALL_TIME || endTimeMode > UTC_TIME) {
                throw IllegalArgumentException()
            }
            if (endDayOfWeek == 0) {
                endMode = DOM_MODE
            } else {
                if (endDayOfWeek > 0) {
                    endMode = DOW_IN_MONTH_MODE
                } else {
                    endDayOfWeek = -endDayOfWeek
                    if (endDay > 0) {
                        endMode = DOW_GE_DOM_MODE
                    } else {
                        endDay = -endDay
                        endMode = DOW_LE_DOM_MODE
                    }
                }
                if (endDayOfWeek > Calendar.SATURDAY) {
                    throw IllegalArgumentException()
                }
            }
            if (endMode == DOW_IN_MONTH_MODE) {
                if (endDay < -5 || endDay > 5) {
                    throw IllegalArgumentException()
                }
            } else if (endDay < 1 || endDay > Int32(staticMonthLength[Int64(endMonth)])) {
                throw IllegalArgumentException()
            }
        }
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (obj.isNone() || !refEq(TypeInfo.of(this), TypeInfo.of(obj))) {
            return false
        }
        let that = obj
        return raw == that.raw && useDaylight == that.useDaylight && idEquals(getID(), that.getID()) && (!useDaylight || (dst == that.dst && startMode == that.startMode && startMonth == that.startMonth && startDay == that.startDay && startDayOfWeek == that.startDayOfWeek && startTime == that.startTime && startTimeMode == that.startTimeMode && endMode == that.endMode && endMonth == that.endMonth && endDay == that.endDay && endDayOfWeek == that.endDayOfWeek && endTime == that.endTime && endTimeMode == that.endTimeMode && startYear == that.startYear))
    }

    private func idEquals(id1: String, id2: String): Bool {
        if (id1.isNone() && id2.isNone()) {
            return true
        }
        if (id1.isSome() && id2.isSome()) {
            return id1.equals(id2)
        }
        return false
    }

    public override func hashCode(): Int64 {
        var ret = Int32(super.hashCode()) + raw ^ (ushr(raw, 8)) + (if (useDaylight) { 0 } else { 1 })
        if (!useDaylight) {
            ret += dst ^ (ushr(dst, 10)) + startMode ^ (ushr(startMode, 11)) + startMonth ^ (ushr(startMonth, 12)) + startDay ^ (ushr(startDay, 13)) + startDayOfWeek ^ (ushr(startDayOfWeek, 14)) + startTime ^ (ushr(startTime, 15)) + startTimeMode ^ (ushr(startTimeMode, 16)) + endMode ^ (ushr(endMode, 17)) + endMonth ^ (ushr(endMonth, 18)) + endDay ^ (ushr(endDay, 19)) + endDayOfWeek ^ (ushr(endDayOfWeek, 20)) + endTime ^ (ushr(endTime, 21)) + endTimeMode ^ (ushr(endTimeMode, 22)) + startYear ^ (ushr(startYear, 23))
        }
        return Int64(ret)
    }

    public override func clone(): Object {
        if (isFrozenMethod()) {
            return this
        }
        return cloneAsThawed()
    }

    public override func hasSameRules(othr: TimeZone): Bool {
        if (refEq(this, othr)) {
            return true
        }
        if (!(checkOptionalIs<SimpleTimeZone, TimeZone>(othr))) {
            return false
        }
        let other = othr
        return other.isSome() && raw == other.raw && useDaylight == other.useDaylight && (!useDaylight || (dst == other.dst && startMode == other.startMode && startMonth == other.startMonth && startDay == other.startDay && startDayOfWeek == other.startDayOfWeek && startTime == other.startTime && startTimeMode == other.startTimeMode && endMode == other.endMode && endMonth == other.endMonth && endDay == other.endDay && endDayOfWeek == other.endDayOfWeek && endTime == other.endTime && endTimeMode == other.endTimeMode && startYear == other.startYear))
    }

    public override func getNextTransition(base: Int64, inclusive: Bool): TimeZoneTransition {
        if (!useDaylight) {
            return None
        }
        initTransitionRules()
        let firstTransitionTime = firstTransition.getTime()
        if (base < firstTransitionTime || (inclusive && base == firstTransitionTime)) {
            return firstTransition
        }
        let stdDate = stdRule.getNextStart(base, dstRule.getRawOffset(), dstRule.getDSTSavings(), inclusive)
        let dstDate = dstRule.getNextStart(base, stdRule.getRawOffset(), stdRule.getDSTSavings(), inclusive)
        if (stdDate.isSome() && (dstDate.isNone() || stdDate.before(dstDate))) {
            return TimeZoneTransition(stdDate.getTime(), dstRule, stdRule)
        }
        if (dstDate.isSome() && (stdDate.isNone() || dstDate.before(stdDate))) {
            return TimeZoneTransition(dstDate.getTime(), stdRule, dstRule)
        }
        return None
    }

    public override func getPreviousTransition(base: Int64, inclusive: Bool): TimeZoneTransition {
        if (!useDaylight) {
            return None
        }
        initTransitionRules()
        let firstTransitionTime = firstTransition.getTime()
        if (base < firstTransitionTime || (!inclusive && base == firstTransitionTime)) {
            return None
        }
        let stdDate = stdRule.getPreviousStart(base, dstRule.getRawOffset(), dstRule.getDSTSavings(), inclusive)
        let dstDate = dstRule.getPreviousStart(base, stdRule.getRawOffset(), stdRule.getDSTSavings(), inclusive)
        if (stdDate.isSome() && (dstDate.isNone() || stdDate.after(dstDate))) {
            return TimeZoneTransition(stdDate.getTime(), dstRule, stdRule)
        }
        if (dstDate.isSome() && (stdDate.isNone() || dstDate.after(stdDate))) {
            return TimeZoneTransition(dstDate.getTime(), stdRule, dstRule)
        }
        return None
    }

    public override func getTimeZoneRules(): Array<TimeZoneRule> {
        initTransitionRules()
        let size = if (useDaylight) { 3 } else { 1 }
        let rules = Array<TimeZoneRule>(Int64(size))
        rules[0] = initialRule
        if (useDaylight) {
            rules[1] = stdRule
            rules[2] = dstRule
        }
        return rules
    }

     private var transitionRulesInitialized: Bool = false

     private var initialRule: InitialTimeZoneRule

     private var firstTransition: TimeZoneTransition

     private var stdRule: AnnualTimeZoneRule

     private var dstRule: AnnualTimeZoneRule

    private func initTransitionRules(): Unit {
        synchronized (GeneratedLockObject) {
            if (transitionRulesInitialized) {
                return
            }
            if (useDaylight) {
                var dtRule: DateTimeRule
                var timeRuleType: Int32 = 0
                let firstStdStart: Int64
                let firstDstStart: Int64
                timeRuleType = if (startTimeMode == STANDARD_TIME) { DateTimeRule.STANDARD_TIME } else { (if (startTimeMode == UTC_TIME) { DateTimeRule.UTC_TIME } else { DateTimeRule.WALL_TIME }) }
                match (startMode) {
                    case 1 => dtRule = DateTimeRule(startMonth, startDay, startTime, timeRuleType)
                    case 2 => dtRule = DateTimeRule(startMonth, startDay, startDayOfWeek, startTime, timeRuleType)
                    case 3 => dtRule = DateTimeRule(startMonth, startDay, startDayOfWeek, true, startTime, timeRuleType)
                    case 4 => dtRule = DateTimeRule(startMonth, startDay, startDayOfWeek, false, startTime, timeRuleType)
                    case _ => ()
                }
                dstRule = AnnualTimeZoneRule((getID()) + "(DST)", getRawOffset(), getDSTSavings(), dtRule, startYear, AnnualTimeZoneRule.MAX_YEAR)
                firstDstStart = dstRule.getFirstStart(getRawOffset(), 0).getTime()
                timeRuleType = if (endTimeMode == STANDARD_TIME) { DateTimeRule.STANDARD_TIME } else { (if (endTimeMode == UTC_TIME) { DateTimeRule.UTC_TIME } else { DateTimeRule.WALL_TIME }) }
                match (endMode) {
                    case 1 => dtRule = DateTimeRule(endMonth, endDay, endTime, timeRuleType)
                    case 2 => dtRule = DateTimeRule(endMonth, endDay, endDayOfWeek, endTime, timeRuleType)
                    case 3 => dtRule = DateTimeRule(endMonth, endDay, endDayOfWeek, true, endTime, timeRuleType)
                    case 4 => dtRule = DateTimeRule(endMonth, endDay, endDayOfWeek, false, endTime, timeRuleType)
                    case _ => ()
                }
                stdRule = AnnualTimeZoneRule((getID()) + "(STD)", getRawOffset(), 0, dtRule, startYear, AnnualTimeZoneRule.MAX_YEAR)
                firstStdStart = stdRule.getFirstStart(getRawOffset(), dstRule.getDSTSavings()).getTime()
                if (firstStdStart < firstDstStart) {
                    initialRule = InitialTimeZoneRule((getID()) + "(DST)", getRawOffset(), dstRule.getDSTSavings())
                    firstTransition = TimeZoneTransition(firstStdStart, initialRule, stdRule)
                } else {
                    initialRule = InitialTimeZoneRule((getID()) + "(STD)", getRawOffset(), 0)
                    firstTransition = TimeZoneTransition(firstDstStart, initialRule, dstRule)
                }
            } else {
                initialRule = InitialTimeZoneRule(getID(), getRawOffset(), 0)
            }
            transitionRulesInitialized = true
        }
    }

      private var isFrozen = false

    public override func isFrozenMethod(): Bool {
        return isFrozen
    }

    public override func freeze(): TimeZone {
        isFrozen = true
        return this
    }

    public override func cloneAsThawed(): TimeZone {
        let tz = super.cloneAsThawed()
        tz.isFrozen = false
        return tz
    }
}
