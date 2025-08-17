package icu4cj.util


public abstract class BasicTimeZone <: TimeZone {
    private static let serialVersionUID = -3204278532246180932

    private static let MILLIS_PER_YEAR = Int64(365 * 24 * 60 * 60) * 1000

    public func getNextTransition(base: Int64, inclusive: Bool): TimeZoneTransition

    public func getPreviousTransition(base: Int64, inclusive: Bool): TimeZoneTransition

    public func hasEquivalentTransitions(tz: TimeZone, start: Int64, end: Int64): Bool {
        return hasEquivalentTransitions(tz, start, end, false)
    }

    public func hasEquivalentTransitions(tz: TimeZone, start: Int64, end: Int64, ignoreDstAmount: Bool): Bool {
        if (refEq(this, tz)) {
            return true
        }
        if (!(checkOptionalIs<BasicTimeZone, TimeZone>(tz))) {
            return false
        }
        let offsets1 = Array<Int32>(2) { _ => 0 }
        let offsets2 = Array<Int32>(2) { _ => 0 }
        getOffset(start, false, offsets1)
        tz.getOffset(start, false, offsets2)
        if (ignoreDstAmount) {
            if ((offsets1[0] + offsets1[1] != offsets2[0] + offsets2[1]) || (offsets1[1] != 0 && offsets2[1] == 0) || (offsets1[1] == 0 && offsets2[1] != 0)) {
                return false
            }
        } else {
            if (offsets1[0] != offsets2[0] || offsets1[1] != offsets2[1]) {
                return false
            }
        }
        var time = start
        while (true) {
            var tr1 = getNextTransition(time, false)
            var tr2 = tz.getNextTransition(time, false)
            if (ignoreDstAmount) {
                while (true) {
                    if (tr1.isSome() && tr1.getTime() <= end && (tr1.getFrom().getRawOffset() + tr1.getFrom().getDSTSavings() == tr1.getTo().getRawOffset() + tr1.getTo().getDSTSavings()) && (tr1.getFrom().getDSTSavings() != 0 && tr1.getTo().getDSTSavings() != 0)) {
                        tr1 = getNextTransition(tr1.getTime(), false)
                    } else {
                        break
                    }
                }
                while (true) {
                    if (tr2.isSome() && tr2.getTime() <= end && (tr2.getFrom().getRawOffset() + tr2.getFrom().getDSTSavings() == tr2.getTo().getRawOffset() + tr2.getTo().getDSTSavings()) && (tr2.getFrom().getDSTSavings() != 0 && tr2.getTo().getDSTSavings() != 0)) {
                        tr2 = tz.getNextTransition(tr2.getTime(), false)
                    } else {
                        break
                    }
                }
            }
            var inRange1 = false
            var inRange2 = false
            if (tr1.isSome()) {
                if (tr1.getTime() <= end) {
                    inRange1 = true
                }
            }
            if (tr2.isSome()) {
                if (tr2.getTime() <= end) {
                    inRange2 = true
                }
            }
            if (!inRange1 && !inRange2) {
                break
            }
            if (!inRange1 || !inRange2) {
                return false
            }
            if (tr1.getTime() != tr2.getTime()) {
                return false
            }
            if (ignoreDstAmount) {
                if (tr1.getTo().getRawOffset() + tr1.getTo().getDSTSavings() != tr2.getTo().getRawOffset() + tr2.getTo().getDSTSavings() || tr1.getTo().getDSTSavings() != 0 && tr2.getTo().getDSTSavings() == 0 || tr1.getTo().getDSTSavings() == 0 && tr2.getTo().getDSTSavings() != 0) {
                    return false
                }
            } else {
                if (tr1.getTo().getRawOffset() != tr2.getTo().getRawOffset() || tr1.getTo().getDSTSavings() != tr2.getTo().getDSTSavings()) {
                    return false
                }
            }
            time = tr1.getTime()
        }
        return true
    }

    public func getTimeZoneRules(): Array<TimeZoneRule>

    public func getTimeZoneRules(start: Int64): Array<TimeZoneRule> {
        let all = getTimeZoneRules()
        var tzt = getPreviousTransition(start, true)
        if (tzt.isNone()) {
            return all
        }
        let isProcessed = BitSet(Int32(all.size))
        let filteredRules = LinkedList<TimeZoneRule>()
        let initial: TimeZoneRule = InitialTimeZoneRule(tzt.getTo().getName(), tzt.getTo().getRawOffset(), tzt.getTo().getDSTSavings())
        filteredRules.append(initial)
        isProcessed.set(0)
        var i = 1
        while (i < Int32(all.size)) {
            let d = all[Int64(i)].getNextStart(start, initial.getRawOffset(), initial.getDSTSavings(), false)
            if (d.isNone()) {
                isProcessed.set(i)
            }
            i++
        }
        var time = start
        var bFinalStd = false
        var bFinalDst = false
        while (!bFinalStd || !bFinalDst) {
            tzt = getNextTransition(time, false)
            if (tzt.isNone()) {
                break
            }
            time = tzt.getTime()
            let toRule = tzt.getTo()
            var ruleIdx = 1
            while (ruleIdx < Int32(all.size)) {
                if (refEq(all[Int64(ruleIdx)], toRule)) {
                    break
                }
                ruleIdx++
            }
            if (ruleIdx >= Int32(all.size)) {
                throw Exception("The rule was not found")
            }
            if (isProcessed.get(ruleIdx)) {
                continue
            }
            if (checkOptionalIs<TimeArrayTimeZoneRule, TimeZoneRule>(toRule)) {
                let tar = toRule
                var t = start
                while (true) {
                    tzt = getNextTransition(t, false)
                    if (tzt.isNone()) {
                        break
                    }
                    if (refEq(tzt.getTo(), tar)) {
                        break
                    }
                    t = tzt.getTime()
                }
                if (tzt.isSome()) {
                    let firstStart = tar.getFirstStart(tzt.getFrom().getRawOffset(), tzt.getFrom().getDSTSavings())
                    if (firstStart.getTime() > start) {
                        filteredRules.append(tar)
                    } else {
                        let times = tar.getStartTimes()
                        let timeType = tar.getTimeType()
                        var idx: Int32 = 0
                        idx = 0
                        while (idx < Int32(times.size)) {
                            t = times[Int64(idx)]
                            if (timeType == DateTimeRule.STANDARD_TIME) {
                                t -= Int64(tzt.getFrom().getRawOffset())
                            }
                            if (timeType == DateTimeRule.WALL_TIME) {
                                t -= Int64(tzt.getFrom().getDSTSavings())
                            }
                            if (t > start) {
                                break
                            }
                            idx++
                        }
                        let asize = Int32(times.size) - idx
                        if (asize > 0) {
                            let newtimes = Array<Int64>(Int64(asize)) { _ => 0 }
                            arraycopy(times, Int64(idx), newtimes, 0, Int64(asize))
                            let newtar = TimeArrayTimeZoneRule(tar.getName(), tar.getRawOffset(), tar.getDSTSavings(), newtimes, tar.getTimeType())
                            filteredRules.append(newtar)
                        }
                    }
                }
            } else if (checkOptionalIs<AnnualTimeZoneRule, TimeZoneRule>(toRule)) {
                let ar = toRule
                let firstStart = ar.getFirstStart(tzt.getFrom().getRawOffset(), tzt.getFrom().getDSTSavings())
                if (firstStart.getTime() == tzt.getTime()) {
                    filteredRules.append(ar)
                } else {
                    let dfields = Array<Int32>(6) { _ => 0 }
                    Grego.timeToFields(tzt.getTime(), dfields)
                    let newar = AnnualTimeZoneRule(ar.getName(), ar.getRawOffset(), ar.getDSTSavings(), ar.getRule(), dfields[0], ar.getEndYear())
                    filteredRules.append(newar)
                }
                if (ar.getEndYear() == AnnualTimeZoneRule.MAX_YEAR) {
                    if (ar.getDSTSavings() == 0) {
                        bFinalStd = true
                    } else {
                        bFinalDst = true
                    }
                }
            }
            isProcessed.set(ruleIdx)
        }
        let rules = filteredRules.toArray(size))
        return rules
    }

    public func getSimpleTimeZoneRulesNear(date: Int64): Array<TimeZoneRule> {
        var annualRules: Array<AnnualTimeZoneRule>
        var initialRule: TimeZoneRule
        var tr = getNextTransition(date, false)
        if (tr.isSome()) {
            var initialName = tr.getFrom().getName()
            var initialRaw = tr.getFrom().getRawOffset()
            var initialDst = tr.getFrom().getDSTSavings()
            let nextTransitionTime = tr.getTime()
            if (((tr.getFrom().getDSTSavings() == 0 && tr.getTo().getDSTSavings() != 0) || (tr.getFrom().getDSTSavings() != 0 && tr.getTo().getDSTSavings() == 0)) && date + MILLIS_PER_YEAR > nextTransitionTime) {
                annualRules = Array<AnnualTimeZoneRule>(2)
                var dtfields = Grego.timeToFields(nextTransitionTime + Int64(tr.getFrom().getRawOffset()) + Int64(tr.getFrom().getDSTSavings()), None)
                var weekInMonth = Grego.getDayOfWeekInMonth(dtfields[0], dtfields[1], dtfields[2])
                var dtr: DateTimeRule = DateTimeRule(dtfields[1], weekInMonth, dtfields[3], dtfields[5], DateTimeRule.WALL_TIME)
                var secondRule: AnnualTimeZoneRule
                annualRules[0] = AnnualTimeZoneRule(tr.getTo().getName(), initialRaw, tr.getTo().getDSTSavings(), dtr, dtfields[0], AnnualTimeZoneRule.MAX_YEAR)
                if (tr.getTo().getRawOffset() == initialRaw) {
                    tr = getNextTransition(nextTransitionTime, false)
                    if (tr.isSome()) {
                        if (((tr.getFrom().getDSTSavings() == 0 && tr.getTo().getDSTSavings() != 0) || (tr.getFrom().getDSTSavings() != 0 && tr.getTo().getDSTSavings() == 0)) && nextTransitionTime + MILLIS_PER_YEAR > tr.getTime()) {
                            dtfields = Grego.timeToFields(tr.getTime() + Int64(tr.getFrom().getRawOffset()) + Int64(tr.getFrom().getDSTSavings()), dtfields)
                            weekInMonth = Grego.getDayOfWeekInMonth(dtfields[0], dtfields[1], dtfields[2])
                            dtr = DateTimeRule(dtfields[1], weekInMonth, dtfields[3], dtfields[5], DateTimeRule.WALL_TIME)
                            secondRule = AnnualTimeZoneRule(tr.getTo().getName(), tr.getTo().getRawOffset(), tr.getTo().getDSTSavings(), dtr, dtfields[0] - 1, AnnualTimeZoneRule.MAX_YEAR)
                            let d = secondRule.getPreviousStart(date, tr.getFrom().getRawOffset(), tr.getFrom().getDSTSavings(), true)
                            if (d.isSome() && d.getTime() <= date && initialRaw == tr.getTo().getRawOffset() && initialDst == tr.getTo().getDSTSavings()) {
                                annualRules[1] = secondRule
                            }
                        }
                    }
                }
                if (annualRules[1].isNone()) {
                    tr = getPreviousTransition(date, true)
                    if (tr.isSome()) {
                        if ((tr.getFrom().getDSTSavings() == 0 && tr.getTo().getDSTSavings() != 0) || (tr.getFrom().getDSTSavings() != 0 && tr.getTo().getDSTSavings() == 0)) {
                            dtfields = Grego.timeToFields(tr.getTime() + Int64(tr.getFrom().getRawOffset()) + Int64(tr.getFrom().getDSTSavings()), dtfields)
                            weekInMonth = Grego.getDayOfWeekInMonth(dtfields[0], dtfields[1], dtfields[2])
                            dtr = DateTimeRule(dtfields[1], weekInMonth, dtfields[3], dtfields[5], DateTimeRule.WALL_TIME)
                            secondRule = AnnualTimeZoneRule(tr.getTo().getName(), initialRaw, initialDst, dtr, annualRules[0].getStartYear() - 1, AnnualTimeZoneRule.MAX_YEAR)
                            let d = secondRule.getNextStart(date, tr.getFrom().getRawOffset(), tr.getFrom().getDSTSavings(), false)
                            if (d.getTime() > nextTransitionTime) {
                                annualRules[1] = secondRule
                            }
                        }
                    }
                }
                if (annualRules[1].isNone()) {
                    annualRules = None
                } else {
                    initialName = annualRules[0].getName()
                    initialRaw = annualRules[0].getRawOffset()
                    initialDst = annualRules[0].getDSTSavings()
                }
            }
            initialRule = InitialTimeZoneRule(initialName, initialRaw, initialDst)
        } else {
            tr = getPreviousTransition(date, true)
            if (tr.isSome()) {
                initialRule = InitialTimeZoneRule(tr.getTo().getName(), tr.getTo().getRawOffset(), tr.getTo().getDSTSavings())
            } else {
                let offsets = Array<Int32>(2) { _ => 0 }
                getOffset(date, false, offsets)
                initialRule = InitialTimeZoneRule(getID(), offsets[0], offsets[1])
            }
        }
        var result: Array<TimeZoneRule>
        if (annualRules.isNone()) {
            result = Array<TimeZoneRule>(1)
            result[0] = initialRule
        } else {
            result = Array<TimeZoneRule>(3)
            result[0] = initialRule
            result[1] = annualRules[0]
            result[2] = annualRules[1]
        }
        return result
    }

    
    protected static func getLocalOptionValue(locOpt: BasicTimeZone_LocalOption): Int32 {
        return locOpt.flagVal
    }

    
    protected static let LOCAL_STD = 1

    
    protected static let LOCAL_DST = 3

    
    protected static let LOCAL_FORMER = 4

    
    protected static let LOCAL_LATTER = 12

    
    protected static let STD_DST_MASK = 3

    
    protected static let FORMER_LATTER_MASK = 12

    public func getOffsetFromLocal(date: Int64, nonExistingTimeOpt: BasicTimeZone_LocalOption, duplicatedTimeOpt: BasicTimeZone_LocalOption, offsets: Array<Int32>): Unit {
        throw Exception("Not implemented")
    }

    protected init() {
        super()
    }

    
    protected init(ID: String) {
        super(ID)
    }
}


public class BasicTimeZone_LocalOption <: Enum<BasicTimeZone_LocalOption> {
    public static let FORMER = BasicTimeZone_LocalOption("FORMER", 0, 4)

    public static let LATTER = BasicTimeZone_LocalOption("LATTER", 1, 12)

    public static let STANDARD_FORMER = BasicTimeZone_LocalOption("STANDARD_FORMER", 2, 5)

    public static let STANDARD_LATTER = BasicTimeZone_LocalOption("STANDARD_LATTER", 3, 13)

    public static let DAYLIGHT_FORMER = BasicTimeZone_LocalOption("DAYLIGHT_FORMER", 4, 7)

    public static let DAYLIGHT_LATTER = BasicTimeZone_LocalOption("DAYLIGHT_LATTER", 5, 15)

    private static func _values(): Array<BasicTimeZone_LocalOption> {
        return [BasicTimeZone_LocalOption.FORMER, BasicTimeZone_LocalOption.LATTER, BasicTimeZone_LocalOption.STANDARD_FORMER, BasicTimeZone_LocalOption.STANDARD_LATTER, BasicTimeZone_LocalOption.DAYLIGHT_FORMER, BasicTimeZone_LocalOption.DAYLIGHT_LATTER]
    }

    private static let _VALUES = BasicTimeZone_LocalOption._values()

    public static func values(): Array<BasicTimeZone_LocalOption> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): BasicTimeZone_LocalOption {
        return (TypeInfo.of<BasicTimeZone_LocalOption>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as BasicTimeZone_LocalOption
    }

    var flagVal: Int32 = 0

    init(_enum_name: String, _enum_ordinal: Int32, flagVal: Int32) {
        super(_enum_name, _enum_ordinal)
        this.flagVal = flagVal
    }
}
