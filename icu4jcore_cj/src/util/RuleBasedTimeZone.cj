package icu4cj.util

public class RuleBasedTimeZone <: BasicTimeZone {
    private static let serialVersionUID = 7580833058949327935

    private let initialRule: InitialTimeZoneRule

    private var historicRules: ArrayList<TimeZoneRule>

    private var finalRules: Array<AnnualTimeZoneRule>

     private var historicTransitions: ArrayList<TimeZoneTransition>

     private var upToDate: Bool = false

    public init(id: String, initialRule: InitialTimeZoneRule) {
        super(id)
        this.initialRule = initialRule
    }

    public func addTransitionRule(rule: TimeZoneRule): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen RuleBasedTimeZone instance.")
        }
        if (!rule.isTransitionRule()) {
            throw IllegalArgumentException("Rule must be a transition rule")
        }
        if (checkOptionalIs<AnnualTimeZoneRule, TimeZoneRule>(rule) && rule.getEndYear() == AnnualTimeZoneRule.MAX_YEAR) {
            if (finalRules.isNone()) {
                finalRules = Array<AnnualTimeZoneRule>(2)
                finalRules[0] = rule
            } else if (finalRules[1].isNone()) {
                finalRules[1] = rule
            } else {
                throw Exception("Too many final rules")
            }
        } else {
            if (historicRules.isNone()) {
                historicRules = ArrayList<TimeZoneRule>()
            }
            historicRules.append(rule)
        }
        upToDate = false
    }

    public override func getOffset(era: Int32, year: Int32, month: Int32, day: Int32, dayOfWeek: Int32, milliseconds: Int32): Int32 {
        var tempyear = year
        if (era == GregorianCalendar.BC) {
            tempyear = 1 - tempyear
        }
        let time = Grego.fieldsToDay(tempyear, month, day) * Int64(Grego.MILLIS_PER_DAY) + Int64(milliseconds)
        let offsets = Array<Int32>(2) { _ => 0 }
        getOffset(time, true, LOCAL_DST, LOCAL_STD, offsets)
        return (offsets[0] + offsets[1])
    }

    public override func getOffset(time: Int64, local: Bool, offsets: Array<Int32>): Unit {
        getOffset(time, local, LOCAL_FORMER, LOCAL_LATTER, offsets)
    }

    public override func getOffsetFromLocal(date: Int64, nonExistingTimeOpt: BasicTimeZone_LocalOption, duplicatedTimeOpt: BasicTimeZone_LocalOption, offsets: Array<Int32>): Unit {
        let nonExistingTimeOptVal = getLocalOptionValue(nonExistingTimeOpt)
        let duplicatedTimeOptVal = getLocalOptionValue(duplicatedTimeOpt)
        getOffset(date, true, nonExistingTimeOptVal, duplicatedTimeOptVal, offsets)
    }

    public override func getRawOffset(): Int32 {
        let now = DateTime.now().toUnixTimeStamp().toMilliseconds()
        let offsets = Array<Int32>(2) { _ => 0 }
        getOffset(now, false, offsets)
        return offsets[0]
    }

    public override func inDaylightTime(date: DateTime): Bool {
        let offsets = Array<Int32>(2) { _ => 0 }
        getOffset(date.getTime(), false, offsets)
        return (offsets[1] != 0)
    }

    public override func setRawOffset(offsetMillis: Int32): Unit {
        throw UnsupportedOperationException("setRawOffset in RuleBasedTimeZone is not supported.")
    }

    public override func useDaylightTime(): Bool {
        let now = DateTime.now().toUnixTimeStamp().toMilliseconds()
        let offsets = Array<Int32>(2) { _ => 0 }
        getOffset(now, false, offsets)
        if (offsets[1] != 0) {
            return true
        }
        let tt = getNextTransition(now, false)
        if (tt.isSome() && tt.getTo().getDSTSavings() != 0) {
            return true
        }
        return false
    }

    public override func observesDaylightTime(): Bool {
        var time = DateTime.now().toUnixTimeStamp().toMilliseconds()
        let offsets = Array<Int32>(2) { _ => 0 }
        getOffset(time, false, offsets)
        if (offsets[1] != 0) {
            return true
        }
        let checkFinals: BitSet = if (finalRules.isNone()) { None } else { BitSet(Int32(finalRules.size)) }
        while (true) {
            let tt = getNextTransition(time, false)
            if (tt.isNone()) {
                break
            }
            let toRule = tt.getTo()
            if (toRule.getDSTSavings() != 0) {
                return true
            }
            if (checkFinals.isSome()) {
                var i = 0
                while (i < Int32(finalRules.size)) {
                    if (refEq(finalRules[Int64(i)], toRule)) {
                        checkFinals.set(i)
                    }
                    i++
                }
                if (checkFinals.cardinality() == Int32(finalRules.size)) {
                    break
                }
            }
            time = tt.getTime()
        }
        return false
    }

    public override func hasSameRules(other: TimeZone): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (!(checkOptionalIs<RuleBasedTimeZone, TimeZone>(other))) {
            return false
        }
        let otherRBTZ = other
        if (!initialRule.isEquivalentTo(otherRBTZ.initialRule)) {
            return false
        }
        if (finalRules.isSome() && otherRBTZ.finalRules.isSome()) {
            var i = 0
            while (i < Int32(finalRules.size)) {
                if (finalRules[Int64(i)].isNone() && otherRBTZ.finalRules[Int64(i)].isNone()) {
                    continue
                }
                if (finalRules[Int64(i)].isSome() && otherRBTZ.finalRules[Int64(i)].isSome() && finalRules[Int64(i)].isEquivalentTo(otherRBTZ.finalRules[Int64(i)])) {
                    continue
                }
                return false
                i++
            }
        } else if (finalRules.isSome() || otherRBTZ.finalRules.isSome()) {
            return false
        }
        if (historicRules.isSome() && otherRBTZ.historicRules.isSome()) {
            if (Int32(historicRules.size) != Int32(otherRBTZ.historicRules.size)) {
                return false
            }
            for (rule in historicRules) {
                var foundSameRule = false
                for (orule in otherRBTZ.historicRules) {
                    if (rule.isEquivalentTo(orule)) {
                        foundSameRule = true
                        break
                    }
                }
                if (!foundSameRule) {
                    return false
                }
            }
        } else if (historicRules.isSome() || otherRBTZ.historicRules.isSome()) {
            return false
        }
        return true
    }

    public override func getTimeZoneRules(): Array<TimeZoneRule> {
        var size = 1
        if (historicRules.isSome()) {
            size += Int32(historicRules.size)
        }
        if (finalRules.isSome()) {
            if (finalRules[1].isSome()) {
                size += 2
            } else {
                size++
            }
        }
        let rules = Array<TimeZoneRule>(Int64(size))
        rules[0] = initialRule
        var idx = 1
        if (historicRules.isSome()) {
            while (idx < Int32(historicRules.size) + 1) {
                rules[Int64(idx)] = historicRules[Int64(idx - 1)]
                idx++
            }
        }
        if (finalRules.isSome()) {
            rules[Int64(match (0) { case _ => idx++; idx - 1 })] = finalRules[0]
            if (finalRules[1].isSome()) {
                rules[Int64(idx)] = finalRules[1]
            }
        }
        return rules
    }

    public override func getNextTransition(base: Int64, inclusive: Bool): TimeZoneTransition {
        complete()
        if (historicTransitions.isNone()) {
            return None
        }
        var isFinal = false
        var result: TimeZoneTransition
        var tzt = historicTransitions[0]
        var tt = tzt.getTime()
        if (tt > base || (inclusive && tt == base)) {
            result = tzt
        } else {
            var idx = Int32(historicTransitions.size) - 1
            tzt = historicTransitions[Int64(idx)]
            tt = tzt.getTime()
            if (inclusive && tt == base) {
                result = tzt
            } else if (tt <= base) {
                if (finalRules.isSome()) {
                    let start0 = finalRules[0].getNextStart(base, finalRules[1].getRawOffset(), finalRules[1].getDSTSavings(), inclusive)
                    let start1 = finalRules[1].getNextStart(base, finalRules[0].getRawOffset(), finalRules[0].getDSTSavings(), inclusive)
                    if (start1.after(start0)) {
                        tzt = TimeZoneTransition(start0.getTime(), finalRules[1], finalRules[0])
                    } else {
                        tzt = TimeZoneTransition(start1.getTime(), finalRules[0], finalRules[1])
                    }
                    result = tzt
                    isFinal = true
                } else {
                    return None
                }
            } else {
                idx--
                var prev = tzt
                while (idx > 0) {
                    tzt = historicTransitions[Int64(idx)]
                    tt = tzt.getTime()
                    if (tt < base || (!inclusive && tt == base)) {
                        break
                    }
                    idx--
                    prev = tzt
                }
                result = prev
            }
        }
        let comefrom = result.getFrom()
        let to = result.getTo()
        if (comefrom.getRawOffset() == to.getRawOffset() && comefrom.getDSTSavings() == to.getDSTSavings()) {
            if (isFinal) {
                return None
            } else {
                result = getNextTransition(result.getTime(), false)
            }
        }
        return result
    }

    public override func getPreviousTransition(base: Int64, inclusive: Bool): TimeZoneTransition {
        complete()
        if (historicTransitions.isNone()) {
            return None
        }
        var result: TimeZoneTransition
        var tzt = historicTransitions[0]
        var tt = tzt.getTime()
        if (inclusive && tt == base) {
            result = tzt
        } else if (tt >= base) {
            return None
        } else {
            var idx = Int32(historicTransitions.size) - 1
            tzt = historicTransitions[Int64(idx)]
            tt = tzt.getTime()
            if (inclusive && tt == base) {
                result = tzt
            } else if (tt < base) {
                if (finalRules.isSome()) {
                    let start0 = finalRules[0].getPreviousStart(base, finalRules[1].getRawOffset(), finalRules[1].getDSTSavings(), inclusive)
                    let start1 = finalRules[1].getPreviousStart(base, finalRules[0].getRawOffset(), finalRules[0].getDSTSavings(), inclusive)
                    if (start1.before(start0)) {
                        tzt = TimeZoneTransition(start0.getTime(), finalRules[1], finalRules[0])
                    } else {
                        tzt = TimeZoneTransition(start1.getTime(), finalRules[0], finalRules[1])
                    }
                }
                result = tzt
            } else {
                idx--
                while (idx >= 0) {
                    tzt = historicTransitions[Int64(idx)]
                    tt = tzt.getTime()
                    if (tt < base || (inclusive && tt == base)) {
                        break
                    }
                    idx--
                }
                result = tzt
            }
        }
        let comefrom = result.getFrom()
        let to = result.getTo()
        if (comefrom.getRawOffset() == to.getRawOffset() && comefrom.getDSTSavings() == to.getDSTSavings()) {
            result = getPreviousTransition(result.getTime(), false)
        }
        return result
    }

    public override func clone(): Object {
        if (isFrozenMethod()) {
            return this
        }
        return cloneAsThawed()
    }

    private func complete(): Unit {
        if (upToDate) {
            return
        }
        if (finalRules.isSome() && finalRules[1].isNone()) {
            throw Exception("Incomplete final rules")
        }
        if (historicRules.isSome() || finalRules.isSome()) {
            var curRule = initialRule
            var lastTransitionTime = Grego.MIN_MILLIS
            if (historicRules.isSome()) {
                let done = BitSet(Int32(historicRules.size))
                while (true) {
                    let curStdOffset = curRule.getRawOffset()
                    let curDstSavings = curRule.getDSTSavings()
                    var nextTransitionTime = Grego.MAX_MILLIS
                    var nextRule: TimeZoneRule
                    var d: DateTime = None
                    var tt: Int64 = 0
                            let r = historicRules[Int64(i)]
                            d = r.getNextStart(lastTransitionTime, curStdOffset, curDstSavings, false)
                            if (d.isNone()) {
                                done.set(i)
                            } else {
                                if (refEq(r, curRule) || (r.getName().equals(curRule.getName()) && r.getRawOffset() == curRule.getRawOffset() && r.getDSTSavings() == curRule.getDSTSavings())) {
                                    continue
                                }
                                tt = d.getTime()
                                if (tt < nextTransitionTime) {
                                    nextTransitionTime = tt
                                    nextRule = r
                                }
                            }
                            i++
                        }
                    } while (false)
                    if (nextRule.isNone()) {
                        var bDoneAll = true
                        var j = 0
                        while (j < Int32(historicRules.size)) {
                            if (!done.get(j)) {
                                bDoneAll = false
                                break
                            }
                            j++
                        }
                        if (bDoneAll) {
                            break
                        }
                    }
                    if (finalRules.isSome()) {
                                d = finalRules[Int64(i)].getNextStart(lastTransitionTime, curStdOffset, curDstSavings, false)
                                if (d.isSome()) {
                                    tt = d.getTime()
                                    if (tt < nextTransitionTime) {
                                        nextTransitionTime = tt
                                        nextRule = finalRules[Int64(i)]
                                    }
                                }
                                i++
                            }
                        } while (false)
                    }
                    if (nextRule.isNone()) {
                        break
                    }
                    if (historicTransitions.isNone()) {
                        historicTransitions = ArrayList<TimeZoneTransition>()
                    }
                    historicTransitions.append(TimeZoneTransition(nextTransitionTime, curRule, nextRule))
                    lastTransitionTime = nextTransitionTime
                    curRule = nextRule
                }
            }
            if (finalRules.isSome()) {
                if (historicTransitions.isNone()) {
                    historicTransitions = ArrayList<TimeZoneTransition>()
                }
                var d0 = finalRules[0].getNextStart(lastTransitionTime, curRule.getRawOffset(), curRule.getDSTSavings(), false)
                var d1 = finalRules[1].getNextStart(lastTransitionTime, curRule.getRawOffset(), curRule.getDSTSavings(), false)
                if (d1.after(d0)) {
                    historicTransitions.append(TimeZoneTransition(d0.getTime(), curRule, finalRules[0]))
                    d1 = finalRules[1].getNextStart(d0.getTime(), finalRules[0].getRawOffset(), finalRules[0].getDSTSavings(), false)
                    historicTransitions.append(TimeZoneTransition(d1.getTime(), finalRules[0], finalRules[1]))
                } else {
                    historicTransitions.append(TimeZoneTransition(d1.getTime(), curRule, finalRules[1]))
                    d0 = finalRules[0].getNextStart(d1.getTime(), finalRules[1].getRawOffset(), finalRules[1].getDSTSavings(), false)
                    historicTransitions.append(TimeZoneTransition(d0.getTime(), finalRules[1], finalRules[0]))
                }
            }
        }
        upToDate = true
    }

    private func getOffset(time: Int64, local: Bool, NonExistingTimeOpt: Int32, DuplicatedTimeOpt: Int32, offsets: Array<Int32>): Unit {
        complete()
        var rule: TimeZoneRule
        if (historicTransitions.isNone()) {
            rule = initialRule
        } else {
            let tstart = getTransitionTime(historicTransitions[0], local, NonExistingTimeOpt, DuplicatedTimeOpt)
            if (time < tstart) {
                rule = initialRule
            } else {
                var idx = Int32(historicTransitions.size) - 1
                let tend = getTransitionTime(historicTransitions[Int64(idx)], local, NonExistingTimeOpt, DuplicatedTimeOpt)
                if (time > tend) {
                    if (finalRules.isSome()) {
                        rule = findRuleInFinal(time, local, NonExistingTimeOpt, DuplicatedTimeOpt)
                    }
                    if (rule.isNone()) {
                        rule = (historicTransitions[Int64(idx)]).getTo()
                    }
                } else {
                    while (idx >= 0) {
                        if (time >= getTransitionTime(historicTransitions[Int64(idx)], local, NonExistingTimeOpt, DuplicatedTimeOpt)) {
                            break
                        }
                        idx--
                    }
                    rule = (historicTransitions[Int64(idx)]).getTo()
                }
            }
        }
        offsets[0] = rule.getRawOffset()
        offsets[1] = rule.getDSTSavings()
    }

    private func findRuleInFinal(time: Int64, local: Bool, NonExistingTimeOpt: Int32, DuplicatedTimeOpt: Int32): TimeZoneRule {
        if (finalRules.isNone() || Int32(finalRules.size) != 2 || finalRules[0].isNone() || finalRules[1].isNone()) {
            return None
        }
        let start0: DateTime
        let start1: DateTime
        var base: Int64 = 0
        var localDelta: Int32 = 0
        base = time
        if (local) {
            localDelta = getLocalDelta(finalRules[1].getRawOffset(), finalRules[1].getDSTSavings(), finalRules[0].getRawOffset(), finalRules[0].getDSTSavings(), NonExistingTimeOpt, DuplicatedTimeOpt)
            base -= Int64(localDelta)
        }
        start0 = finalRules[0].getPreviousStart(base, finalRules[1].getRawOffset(), finalRules[1].getDSTSavings(), true)
        base = time
        if (local) {
            localDelta = getLocalDelta(finalRules[0].getRawOffset(), finalRules[0].getDSTSavings(), finalRules[1].getRawOffset(), finalRules[1].getDSTSavings(), NonExistingTimeOpt, DuplicatedTimeOpt)
            base -= Int64(localDelta)
        }
        start1 = finalRules[1].getPreviousStart(base, finalRules[0].getRawOffset(), finalRules[0].getDSTSavings(), true)
        if (start0.isNone() || start1.isNone()) {
            if (start0.isSome()) {
                return finalRules[0]
            } else if (start1.isSome()) {
                return finalRules[1]
            }
            return None
        }
        return if (start0.after(start1)) { finalRules[0] } else { finalRules[1] }
    }

    private static func getTransitionTime(tzt: TimeZoneTransition, local: Bool, NonExistingTimeOpt: Int32, DuplicatedTimeOpt: Int32): Int64 {
        var time = tzt.getTime()
        if (local) {
            time += Int64(getLocalDelta(tzt.getFrom().getRawOffset(), tzt.getFrom().getDSTSavings(), tzt.getTo().getRawOffset(), tzt.getTo().getDSTSavings(), NonExistingTimeOpt, DuplicatedTimeOpt))
        }
        return time
    }

    private static func getLocalDelta(rawBefore: Int32, dstBefore: Int32, rawAfter: Int32, dstAfter: Int32, NonExistingTimeOpt: Int32, DuplicatedTimeOpt: Int32): Int32 {
        var delta = 0
        let offsetBefore = rawBefore + dstBefore
        let offsetAfter = rawAfter + dstAfter
        let dstToStd = (dstBefore != 0) && (dstAfter == 0)
        let stdToDst = (dstBefore == 0) && (dstAfter != 0)
        if (offsetAfter - offsetBefore >= 0) {
            if (((NonExistingTimeOpt & STD_DST_MASK) == LOCAL_STD && dstToStd) || ((NonExistingTimeOpt & STD_DST_MASK) == LOCAL_DST && stdToDst)) {
                delta = offsetBefore
            } else if (((NonExistingTimeOpt & STD_DST_MASK) == LOCAL_STD && stdToDst) || ((NonExistingTimeOpt & STD_DST_MASK) == LOCAL_DST && dstToStd)) {
                delta = offsetAfter
            } else if ((NonExistingTimeOpt & FORMER_LATTER_MASK) == LOCAL_LATTER) {
                delta = offsetBefore
            } else {
                delta = offsetAfter
            }
        } else {
            if (((DuplicatedTimeOpt & STD_DST_MASK) == LOCAL_STD && dstToStd) || ((DuplicatedTimeOpt & STD_DST_MASK) == LOCAL_DST && stdToDst)) {
                delta = offsetAfter
            } else if (((DuplicatedTimeOpt & STD_DST_MASK) == LOCAL_STD && stdToDst) || ((DuplicatedTimeOpt & STD_DST_MASK) == LOCAL_DST && dstToStd)) {
                delta = offsetBefore
            } else if ((DuplicatedTimeOpt & FORMER_LATTER_MASK) == LOCAL_FORMER) {
                delta = offsetBefore
            } else {
                delta = offsetAfter
            }
        }
        return delta
    }

      private var isFrozen = false

    public override func isFrozenMethod(): Bool {
        return isFrozen
    }

    public override func freeze(): TimeZone {
        complete()
        isFrozen = true
        return this
    }

    public override func cloneAsThawed(): TimeZone {
        let tz = super.cloneAsThawed()
        if (historicRules.isSome()) {
            tz.historicRules = ArrayList<TimeZoneRule>(historicRules)
        }
        if (finalRules.isSome()) {
            tz.finalRules = finalRules.clone()
        }
        tz.isFrozen = false
        return tz
    }
}
