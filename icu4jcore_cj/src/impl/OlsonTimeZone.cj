package icu4cj.impl


public class OlsonTimeZone <: BasicTimeZone & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    static let serialVersionUID = -6281977362477515376

    public override func getOffset(era: Int32, year: Int32, month: Int32, day: Int32, dayOfWeek: Int32, milliseconds: Int32): Int32 {
        if (month < Calendar.JANUARY || month > Calendar.DECEMBER) {
            throw IllegalArgumentException("Month is not in the legal range: " + month.toString())
        } else {
            return getOffset(era, year, month, day, dayOfWeek, milliseconds, Grego.monthLength(year, month))
        }
    }

    public func getOffset(era: Int32, year: Int32, month: Int32, dom: Int32, dow: Int32, millis: Int32, monthLength: Int32): Int32 {
        var tempyear = year
        if ((era != GregorianCalendar.AD && era != GregorianCalendar.BC) || month < Calendar.JANUARY || month > Calendar.DECEMBER || dom < 1 || dom > monthLength || dow < Calendar.SUNDAY || dow > Calendar.SATURDAY || millis < 0 || millis >= Grego.MILLIS_PER_DAY || monthLength < 28 || monthLength > 31) {
            throw IllegalArgumentException()
        }
        if (era == GregorianCalendar.BC) {
            tempyear = -tempyear
        }
        if (finalZone.isSome() && tempyear >= finalStartYear) {
            return finalZone.getOffset(era, tempyear, month, dom, dow, millis)
        }
        let time = Grego.fieldsToDay(tempyear, month, dom) * Int64(Grego.MILLIS_PER_DAY) + Int64(millis)
        let offsets = Array<Int32>(2) { _ => 0 }
        getHistoricalOffset(time, true, LOCAL_DST, LOCAL_STD, offsets)
        return offsets[0] + offsets[1]
    }

    public override func setRawOffset(offsetMillis: Int32): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen OlsonTimeZone instance.")
        }
        if (getRawOffset() == offsetMillis) {
            return
        }
        let current = DateTime.now().toUnixTimeStamp().toMilliseconds()
        if (Float64(current) < finalStartMillis) {
            let stz = SimpleTimeZone(offsetMillis, getID())
            let bDst = useDaylightTime()
            if (bDst) {
                var currentRules = getSimpleTimeZoneRulesNear(current)
                if (Int32(currentRules.size) != 3) {
                    let tzt = getPreviousTransition(current, false)
                    if (tzt.isSome()) {
                        currentRules = getSimpleTimeZoneRulesNear(tzt.getTime() - 1)
                    }
                }
                if (Int32(currentRules.size) == 3 && (checkOptionalIs<AnnualTimeZoneRule, TimeZoneRule>(currentRules[1])) && (checkOptionalIs<AnnualTimeZoneRule, TimeZoneRule>(currentRules[2]))) {
                    let r1 = currentRules[1]
                    let r2 = currentRules[2]
                    let start: DateTimeRule
                    let end: DateTimeRule
                    let offset1 = r1.getRawOffset() + r1.getDSTSavings()
                    let offset2 = r2.getRawOffset() + r2.getDSTSavings()
                    let sav: Int32
                    if (offset1 > offset2) {
                        start = r1.getRule()
                        end = r2.getRule()
                        sav = offset1 - offset2
                    } else {
                        start = r2.getRule()
                        end = r1.getRule()
                        sav = offset2 - offset1
                    }
                    stz.setStartRule(start.getRuleMonth(), start.getRuleWeekInMonth(), start.getRuleDayOfWeek(), start.getRuleMillisInDay())
                    stz.setEndRule(end.getRuleMonth(), end.getRuleWeekInMonth(), end.getRuleDayOfWeek(), end.getRuleMillisInDay())
                    stz.setDSTSavings(sav)
                } else {
                    stz.setStartRule(0, 1, 0)
                    stz.setEndRule(11, 31, Grego.MILLIS_PER_DAY - 1)
                }
            }
            let fields = Grego.timeToFields(current, None)
            finalStartYear = fields[0]
            finalStartMillis = Float64(Grego.fieldsToDay(fields[0], 0, 1))
            if (bDst) {
                stz.setStartYear(finalStartYear)
            }
            finalZone = stz
        } else {
            finalZone.setRawOffset(offsetMillis)
        }
        transitionRulesInitialized = false
    }

    public override func clone(): Object {
        if (isFrozenMethod()) {
            return this
        }
        return cloneAsThawed()
    }

    public override func getOffset(date: Int64, local: Bool, offsets: Array<Int32>): Unit {
        if (finalZone.isSome() && Float64(date) >= finalStartMillis) {
            finalZone.getOffset(date, local, offsets)
        } else {
            getHistoricalOffset(date, local, LOCAL_FORMER, LOCAL_LATTER, offsets)
        }
    }

    public override func getOffsetFromLocal(date: Int64, nonExistingTimeOpt: BasicTimeZone_LocalOption, duplicatedTimeOpt: BasicTimeZone_LocalOption, offsets: Array<Int32>): Unit {
        if (finalZone.isSome() && Float64(date) >= finalStartMillis) {
            finalZone.getOffsetFromLocal(date, nonExistingTimeOpt, duplicatedTimeOpt, offsets)
        } else {
            getHistoricalOffset(date, true, getLocalOptionValue(nonExistingTimeOpt), getLocalOptionValue(duplicatedTimeOpt), offsets)
        }
    }

    public override func getRawOffset(): Int32 {
        let ret = Array<Int32>(2) { _ => 0 }
        getOffset(DateTime.now().toUnixTimeStamp().toMilliseconds(), false, ret)
        return ret[0]
    }

    public override func useDaylightTime(): Bool {
        let current = DateTime.now().toUnixTimeStamp().toMilliseconds()
        if (finalZone.isSome() && Float64(current) >= finalStartMillis) {
            return (finalZone.isSome() && finalZone.useDaylightTime())
        }
        let fields = Grego.timeToFields(current, None)
        let start = Grego.fieldsToDay(fields[0], 0, 1) * Int64(SECONDS_PER_DAY)
        let limit = Grego.fieldsToDay(fields[0] + 1, 0, 1) * Int64(SECONDS_PER_DAY)
        var i = 0
        while (i < transitionCount) {
            if (transitionTimes64[Int64(i)] >= limit) {
                break
            }
            if ((transitionTimes64[Int64(i)] >= start && dstOffsetAt(i) != 0) || (transitionTimes64[Int64(i)] > start && i > 0 && dstOffsetAt(i - 1) != 0)) {
                return true
            }
            i++
        }
        return false
    }

    public override func observesDaylightTime(): Bool {
        let current = DateTime.now().toUnixTimeStamp().toMilliseconds()
        if (finalZone.isSome()) {
            if (finalZone.useDaylightTime()) {
                return true
            } else if (Float64(current) >= finalStartMillis) {
                return false
            }
        }
        let currentSec = Grego.floorDivide(current, Int64(Grego.MILLIS_PER_SECOND))
        var trsIdx = transitionCount - 1
        if (dstOffsetAt(trsIdx) != 0) {
            return true
        }
        while (trsIdx >= 0) {
            if (transitionTimes64[Int64(trsIdx)] <= currentSec) {
                break
            }
            if (dstOffsetAt(trsIdx - 1) != 0) {
                return true
            }
            trsIdx--
        }
        return false
    }

    public override func getDSTSavings(): Int32 {
        if (finalZone.isSome()) {
            return finalZone.getDSTSavings()
        }
        return super.getDSTSavings()
    }

    public override func inDaylightTime(date: DateTime): Bool {
        let temp = Array<Int32>(2) { _ => 0 }
        getOffset(date.getTime(), false, temp)
        return temp[1] != 0
    }

    public override func hasSameRules(other: TimeZone): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (!super.hasSameRules(other)) {
            return false
        }
        if (!(checkOptionalIs<OlsonTimeZone, TimeZone>(other))) {
            return false
        }
        let o = other
        if (finalZone.isNone()) {
            if (o.finalZone.isSome()) {
                return false
            }
        } else {
            if (o.finalZone.isNone() || finalStartYear != o.finalStartYear || !(finalZone.hasSameRules(o.finalZone))) {
                return false
            }
        }
        if (transitionCount != o.transitionCount || !transitionTimes64 == o.transitionTimes64 || typeCount != o.typeCount || !typeMapData == o.typeMapData || !typeOffsets == o.typeOffsets) {
            return false
        }
        return true
    }

    public func getCanonicalID(): String {
        if (canonicalID.isNone()) {
            synchronized (getMonitorByObject(this)) {
                if (canonicalID.isNone()) {
                    canonicalID = getCanonicalID(getID())
                    if (!(canonicalID.isSome())) {
                        throw AssertionError()
                    }
                    if (canonicalID.isNone()) {
                        canonicalID = getID()
                    }
                }
            }
        }
        return canonicalID
    }

    private func constructEmpty(): Unit {
        transitionCount = 0
        transitionTimes64 = None
        typeMapData = None
        typeCount = 1
        typeOffsets = [0, 0]
        finalZone = None
        finalStartYear = Int32.Max
        finalStartMillis = Float64.Max
        transitionRulesInitialized = false
    }

    public init(top: UResourceBundle, res: UResourceBundle, id: String) {
        super(id)
        construct(top, res, id)
    }

    private func construct(top: UResourceBundle, res: UResourceBundle, id: String): Unit {
        if (top.isNone() || res.isNone()) {
            throw IllegalArgumentException()
        }
        if (DEBUG) {
            println("OlsonTimeZone(" + (res.getKey()) + ")")
        }
        var r: UResourceBundle
        var transPre32: Array<Int32>
        var trans32: Array<Int32>
        var transPost32: Array<Int32>
        transPre32 = match (0) { case _ => trans32 = match (0) { case _ => transPost32 = None; transPost32 }; trans32 }
        transitionCount = 0
        try {
            r = res.get("transPre32")
            transPre32 = r.getIntVector()
            if (Int32(transPre32.size) % 2 != 0) {
                throw IllegalArgumentException("Invalid Format")
            }
            transitionCount += Int32(transPre32.size) / 2
        } catch (e: MissingResourceException) { }
        try {
            r = res.get("trans")
            trans32 = r.getIntVector()
            transitionCount += Int32(trans32.size)
        } catch (e: MissingResourceException) { }
        try {
            r = res.get("transPost32")
            transPost32 = r.getIntVector()
            if (Int32(transPost32.size) % 2 != 0) {
                throw IllegalArgumentException("Invalid Format")
            }
            transitionCount += Int32(transPost32.size) / 2
        } catch (e: MissingResourceException) { }
        if (transitionCount > 0) {
            transitionTimes64 = Array<Int64>(Int64(transitionCount)) { _ => 0 }
            var idx = 0
            if (transPre32.isSome()) {
                } while (false)
            }
            if (trans32.isSome()) {
                } while (false)
            }
            if (transPost32.isSome()) {
                } while (false)
            }
        } else {
            transitionTimes64 = None
        }
        r = res.get("typeOffsets")
        typeOffsets = r.getIntVector()
        if (Int32(typeOffsets.size) < 2 || Int32(typeOffsets.size) > 32766 || Int32(typeOffsets.size) % 2 != 0) {
            throw IllegalArgumentException("Invalid Format")
        }
        typeCount = Int32(typeOffsets.size) / 2
        if (transitionCount > 0) {
            r = res.get("typeMap")
            typeMapData = r.getBinary(None)
            if (typeMapData.isNone() || Int32(typeMapData.size) != transitionCount) {
                throw IllegalArgumentException("Invalid Format")
            }
        } else {
            typeMapData = None
        }
        finalZone = None
        finalStartYear = Int32.Max
        finalStartMillis = Float64.Max
        var ruleID: String
        try {
            ruleID = res.getString("finalRule")
            r = res.get("finalRaw")
            let ruleRaw = r.getInt() * Grego.MILLIS_PER_SECOND
            r = loadRule(top, ruleID)
            let ruleData = r.getIntVector()
            if (ruleData.isNone() || Int32(ruleData.size) != 11) {
                throw IllegalArgumentException("Invalid Format")
            }
            finalZone = SimpleTimeZone(ruleRaw, id, ruleData[0], ruleData[1], ruleData[2], ruleData[3] * Grego.MILLIS_PER_SECOND, ruleData[4], ruleData[5], ruleData[6], ruleData[7], ruleData[8] * Grego.MILLIS_PER_SECOND, ruleData[9], ruleData[10] * Grego.MILLIS_PER_SECOND)
            r = res.get("finalYear")
            finalStartYear = r.getInt()
            finalStartMillis = Float64(Grego.fieldsToDay(finalStartYear, 0, 1) * Int64(Grego.MILLIS_PER_DAY))
        } catch (e: MissingResourceException) {
            if (ruleID.isSome()) {
                throw IllegalArgumentException("Invalid Format")
            }
        }
    }

    public init(id: String) {
        super(id)
        let top = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, ZONEINFORES, ICUResourceBundle.ICU_DATA_CLASS_LOADER)
        let res = ZoneMeta.openOlsonResource(top, id)
        construct(top, res, id)
    }

    public override func setID(id: String): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen OlsonTimeZone instance.")
        }
        if (canonicalID.isNone()) {
            canonicalID = getCanonicalID(getID())
            if (!(canonicalID.isSome())) {
                throw AssertionError()
            }
            if (canonicalID.isNone()) {
                canonicalID = getID()
            }
        }
        if (finalZone.isSome()) {
            finalZone.setID(id)
        }
        super.setID(id)
        transitionRulesInitialized = false
    }

    private static let MAX_OFFSET_SECONDS = 86400

    private func getHistoricalOffset(date: Int64, local: Bool, NonExistingTimeOpt: Int32, DuplicatedTimeOpt: Int32, offsets: Array<Int32>): Unit {
        if (transitionCount != 0) {
            let sec = Grego.floorDivide(date, Int64(Grego.MILLIS_PER_SECOND))
            if (!local && sec < transitionTimes64[0]) {
                offsets[0] = initialRawOffset() * Grego.MILLIS_PER_SECOND
                offsets[1] = initialDstOffset() * Grego.MILLIS_PER_SECOND
            } else {
                var transIdx: Int32 = 0
                transIdx = transitionCount - 1
                while (transIdx >= 0) {
                    var transition = transitionTimes64[Int64(transIdx)]
                    if (local && (sec >= (transition - Int64(MAX_OFFSET_SECONDS)))) {
                        let offsetBefore = zoneOffsetAt(transIdx - 1)
                        let dstBefore = dstOffsetAt(transIdx - 1) != 0
                        let offsetAfter = zoneOffsetAt(transIdx)
                        let dstAfter = dstOffsetAt(transIdx) != 0
                        let dstToStd = dstBefore && !dstAfter
                        let stdToDst = !dstBefore && dstAfter
                        if (offsetAfter - offsetBefore >= 0) {
                            if (((NonExistingTimeOpt & STD_DST_MASK) == LOCAL_STD && dstToStd) || ((NonExistingTimeOpt & STD_DST_MASK) == LOCAL_DST && stdToDst)) {
                                transition += Int64(offsetBefore)
                            } else if (((NonExistingTimeOpt & STD_DST_MASK) == LOCAL_STD && stdToDst) || ((NonExistingTimeOpt & STD_DST_MASK) == LOCAL_DST && dstToStd)) {
                                transition += Int64(offsetAfter)
                            } else if ((NonExistingTimeOpt & FORMER_LATTER_MASK) == LOCAL_LATTER) {
                                transition += Int64(offsetBefore)
                            } else {
                                transition += Int64(offsetAfter)
                            }
                        } else {
                            if (((DuplicatedTimeOpt & STD_DST_MASK) == LOCAL_STD && dstToStd) || ((DuplicatedTimeOpt & STD_DST_MASK) == LOCAL_DST && stdToDst)) {
                                transition += Int64(offsetAfter)
                            } else if (((DuplicatedTimeOpt & STD_DST_MASK) == LOCAL_STD && stdToDst) || ((DuplicatedTimeOpt & STD_DST_MASK) == LOCAL_DST && dstToStd)) {
                                transition += Int64(offsetBefore)
                            } else if ((DuplicatedTimeOpt & FORMER_LATTER_MASK) == LOCAL_FORMER) {
                                transition += Int64(offsetBefore)
                            } else {
                                transition += Int64(offsetAfter)
                            }
                        }
                    }
                    if (sec >= transition) {
                        break
                    }
                    transIdx--
                }
                offsets[0] = rawOffsetAt(transIdx) * Grego.MILLIS_PER_SECOND
                offsets[1] = dstOffsetAt(transIdx) * Grego.MILLIS_PER_SECOND
            }
        } else {
            offsets[0] = initialRawOffset() * Grego.MILLIS_PER_SECOND
            offsets[1] = initialDstOffset() * Grego.MILLIS_PER_SECOND
        }
    }

    private func getInt(val: UInt8): Int32 {
        return Int32(val) & 255
    }

    private func zoneOffsetAt(transIdx: Int32): Int32 {
        let typeIdx = if (transIdx >= 0) { getInt(typeMapData[Int64(transIdx)]) * 2 } else { 0 }
        return typeOffsets[Int64(typeIdx)] + typeOffsets[Int64(typeIdx + 1)]
    }

    private func rawOffsetAt(transIdx: Int32): Int32 {
        let typeIdx = if (transIdx >= 0) { getInt(typeMapData[Int64(transIdx)]) * 2 } else { 0 }
        return typeOffsets[Int64(typeIdx)]
    }

    private func dstOffsetAt(transIdx: Int32): Int32 {
        let typeIdx = if (transIdx >= 0) { getInt(typeMapData[Int64(transIdx)]) * 2 } else { 0 }
        return typeOffsets[Int64(typeIdx + 1)]
    }

    private func initialRawOffset(): Int32 {
        return typeOffsets[0]
    }

    private func initialDstOffset(): Int32 {
        return typeOffsets[1]
    }

    public override func toString(): String {
        let buf = StringBuilder()
        buf.append(toString(super))
        buf.append('[')
        buf.append("transitionCount=" + transitionCount.toString())
        buf.append(",typeCount=" + typeCount.toString())
        buf.append(",transitionTimes=")
        if (transitionTimes64.isSome()) {
            buf.append('[')
                    buf.append(transitionTimes64[Int64(i)].toString())
                    i++
                }
            } while (false)
            buf.append(']')
        } else {
            buf.append("null")
        }
        buf.append(",typeOffsets=")
        if (typeOffsets.isSome()) {
            buf.append('[')
                    buf.append(typeOffsets[Int64(i)].toString())
                    i++
                }
            } while (false)
            buf.append(']')
        } else {
            buf.append("null")
        }
        buf.append(",typeMapData=")
        if (typeMapData.isSome()) {
            buf.append('[')
                    buf.append(Int8(typeMapData[Int64(i)]).toString())
                    i++
                }
            } while (false)
        } else {
            buf.append("null")
        }
        buf.append(",finalStartYear=" + finalStartYear.toString())
        buf.append(",finalStartMillis=" + finalStartMillis.toString())
        buf.append(",finalZone=" + finalZone.asString())
        buf.append(']')
        return buf.toString()
    }

    private var transitionCount: Int32 = 0

    private var typeCount: Int32 = 0

    private var transitionTimes64: Array<Int64>

    private var typeOffsets: Array<Int32>

    private var typeMapData: Array<UInt8>

    private var finalStartYear = Int32.Max

    private var finalStartMillis = Float64.Max

    private var finalZone: SimpleTimeZone

     private var canonicalID: String

    private static let ZONEINFORES = "zoneinfo64"

    private static let DEBUG = ICUDebug.enabled("olson")

    private static let SECONDS_PER_DAY = 24 * 60 * 60

    private static func loadRule(top: UResourceBundle, ruleid: String): UResourceBundle {
        var r = top.get("Rules")
        r = r.get(ruleid)
        return r
    }

    public override func equals(obj: Object): Bool {
        if (!super.equals(obj)) {
            return false
        }
        let z = obj
        return (Utility.arrayEquals(typeMapData, z.typeMapData) || (finalStartYear == z.finalStartYear && ((finalZone.isNone() && z.finalZone.isNone()) || (finalZone.isSome() && z.finalZone.isSome() && finalZone.equals(z.finalZone)) && transitionCount == z.transitionCount && typeCount == z.typeCount && Utility.arrayEquals(transitionTimes64, z.transitionTimes64) && Utility.arrayEquals(typeOffsets, z.typeOffsets) && Utility.arrayEquals(typeMapData, z.typeMapData))))
    }

    public override func hashCode(): Int64 {
        var ret = Int32(Int64(finalStartYear ^ (ushr(finalStartYear, 4)) + transitionCount ^ (ushr(transitionCount, 6)) + typeCount) ^ (Int64(ushr(typeCount, 8))) + Float64.doubleToLongBits(finalStartMillis) + (if (finalZone.isNone()) { 0 } else { finalZone.hashCode() }) + super.hashCode())
        if (transitionTimes64.isSome()) {
            } while (false)
        }
        } while (false)
        if (typeMapData.isSome()) {
            } while (false)
        }
        return Int64(ret)
    }

    public override func getNextTransition(base: Int64, inclusive: Bool): TimeZoneTransition {
        initTransitionRules()
        if (finalZone.isSome()) {
            if (inclusive && base == firstFinalTZTransition.getTime()) {
                return firstFinalTZTransition
            } else if (base >= firstFinalTZTransition.getTime()) {
                if (finalZone.useDaylightTime()) {
                    return finalZoneWithStartYear.getNextTransition(base, inclusive)
                } else {
                    return None
                }
            }
        }
        if (historicRules.isSome()) {
            var ttidx = transitionCount - 1
            while (ttidx >= firstTZTransitionIdx) {
                let t = transitionTimes64[Int64(ttidx)] * Int64(Grego.MILLIS_PER_SECOND)
                if (base > t || (!inclusive && base == t)) {
                    break
                }
                ttidx--
            }
            if (ttidx == transitionCount - 1) {
                return firstFinalTZTransition
            } else if (ttidx < firstTZTransitionIdx) {
                return firstTZTransition
            } else {
                let to = historicRules[Int64(getInt(typeMapData[Int64(ttidx + 1)]))]
                let comefrom = historicRules[Int64(getInt(typeMapData[Int64(ttidx)]))]
                let startTime = transitionTimes64[Int64(ttidx + 1)] * Int64(Grego.MILLIS_PER_SECOND)
                if (comefrom.getName().equals(to.getName()) && comefrom.getRawOffset() == to.getRawOffset() && comefrom.getDSTSavings() == to.getDSTSavings()) {
                    return getNextTransition(startTime, false)
                }
                return TimeZoneTransition(startTime, comefrom, to)
            }
        }
        return None
    }

    public override func getPreviousTransition(base: Int64, inclusive: Bool): TimeZoneTransition {
        initTransitionRules()
        if (finalZone.isSome()) {
            if (inclusive && base == firstFinalTZTransition.getTime()) {
                return firstFinalTZTransition
            } else if (base > firstFinalTZTransition.getTime()) {
                if (finalZone.useDaylightTime()) {
                    return finalZoneWithStartYear.getPreviousTransition(base, inclusive)
                } else {
                    return firstFinalTZTransition
                }
            }
        }
        if (historicRules.isSome()) {
            var ttidx = transitionCount - 1
            while (ttidx >= firstTZTransitionIdx) {
                let t = transitionTimes64[Int64(ttidx)] * Int64(Grego.MILLIS_PER_SECOND)
                if (base > t || (inclusive && base == t)) {
                    break
                }
                ttidx--
            }
            if (ttidx < firstTZTransitionIdx) {
                return None
            } else if (ttidx == firstTZTransitionIdx) {
                return firstTZTransition
            } else {
                let to = historicRules[Int64(getInt(typeMapData[Int64(ttidx)]))]
                let comefrom = historicRules[Int64(getInt(typeMapData[Int64(ttidx - 1)]))]
                let startTime = transitionTimes64[Int64(ttidx)] * Int64(Grego.MILLIS_PER_SECOND)
                if (comefrom.getName().equals(to.getName()) && comefrom.getRawOffset() == to.getRawOffset() && comefrom.getDSTSavings() == to.getDSTSavings()) {
                    return getPreviousTransition(startTime, false)
                }
                return TimeZoneTransition(startTime, comefrom, to)
            }
        }
        return None
    }

    public override func getTimeZoneRules(): Array<TimeZoneRule> {
        initTransitionRules()
        var size = 1
        if (historicRules.isSome()) {
                    i++
                }
            } while (false)
        }
        if (finalZone.isSome()) {
            if (finalZone.useDaylightTime()) {
                size += 2
            } else {
                size++
            }
        }
        let rules = Array<TimeZoneRule>(Int64(size))
        var idx = 0
        rules[Int64(match (0) { case _ => idx++; idx - 1 })] = initialRule
        if (historicRules.isSome()) {
                    i++
                }
            } while (false)
        }
        if (finalZone.isSome()) {
            if (finalZone.useDaylightTime()) {
                let stzr = finalZoneWithStartYear.getTimeZoneRules()
                rules[Int64(match (0) { case _ => idx++; idx - 1 })] = stzr[1]
                rules[Int64(match (0) { case _ => idx++; idx - 1 })] = stzr[2]
            } else {
                rules[Int64(match (0) { case _ => idx++; idx - 1 })] = TimeArrayTimeZoneRule((getID()) + "(STD)", finalZone.getRawOffset(), 0, [Int64(finalStartMillis)], DateTimeRule.UTC_TIME)
            }
        }
        return rules
    }

     private var initialRule: InitialTimeZoneRule

     private var firstTZTransition: TimeZoneTransition

     private var firstTZTransitionIdx: Int32 = 0

     private var firstFinalTZTransition: TimeZoneTransition

     private var historicRules: Array<TimeArrayTimeZoneRule>

     private var finalZoneWithStartYear: SimpleTimeZone

     private var transitionRulesInitialized: Bool = false

    private func initTransitionRules(): Unit {
        synchronized (GeneratedLockObject) {
            if (transitionRulesInitialized) {
                return
            }
            initialRule = None
            firstTZTransition = None
            firstFinalTZTransition = None
            historicRules = None
            firstTZTransitionIdx = 0
            finalZoneWithStartYear = None
            let stdName: String = (getID()) + "(STD)"
            let dstName: String = (getID()) + "(DST)"
            var raw: Int32 = 0
            var dst: Int32 = 0
            raw = initialRawOffset() * Grego.MILLIS_PER_SECOND
            dst = initialDstOffset() * Grego.MILLIS_PER_SECOND
            initialRule = InitialTimeZoneRule((if (dst == 0) { stdName } else { dstName }), raw, dst)
            if (transitionCount > 0) {
                var transitionIdx: Int32 = 0
                var typeIdx: Int32 = 0
                transitionIdx = 0
                while (transitionIdx < transitionCount) {
                    if (getInt(typeMapData[Int64(transitionIdx)]) != 0) {
                        break
                    }
                    firstTZTransitionIdx++
                    transitionIdx++
                }
                if (transitionIdx == transitionCount) { } else {
                    let times = Array<Int64>(Int64(transitionCount)) { _ => 0 }
                    typeIdx = 0
                    while (typeIdx < typeCount) {
                        var nTimes = 0
                        transitionIdx = firstTZTransitionIdx
                        while (transitionIdx < transitionCount) {
                            if (typeIdx == getInt(typeMapData[Int64(transitionIdx)])) {
                                let tt = transitionTimes64[Int64(transitionIdx)] * Int64(Grego.MILLIS_PER_SECOND)
                                if (Float64(tt) < finalStartMillis) {
                                    times[Int64(match (0) { case _ => nTimes++; nTimes - 1 })] = tt
                                }
                            }
                            transitionIdx++
                        }
                        if (nTimes > 0) {
                            let startTimes = Array<Int64>(Int64(nTimes)) { _ => 0 }
                            arraycopy(times, 0, startTimes, 0, Int64(nTimes))
                            raw = typeOffsets[Int64(typeIdx * 2)] * Grego.MILLIS_PER_SECOND
                            dst = typeOffsets[Int64(typeIdx * 2 + 1)] * Grego.MILLIS_PER_SECOND
                            if (historicRules.isNone()) {
                                historicRules = Array<TimeArrayTimeZoneRule>(Int64(typeCount))
                            }
                            historicRules[Int64(typeIdx)] = TimeArrayTimeZoneRule((if (dst == 0) { stdName } else { dstName }), raw, dst, startTimes, DateTimeRule.UTC_TIME)
                        }
                        typeIdx++
                    }
                    typeIdx = getInt(typeMapData[Int64(firstTZTransitionIdx)])
                    firstTZTransition = TimeZoneTransition(transitionTimes64[Int64(firstTZTransitionIdx)] * Int64(Grego.MILLIS_PER_SECOND), initialRule, historicRules[Int64(typeIdx)])
                }
            }
            if (finalZone.isSome()) {
                var startTime = Int64(finalStartMillis)
                let firstFinalRule: TimeZoneRule
                if (finalZone.useDaylightTime()) {
                    finalZoneWithStartYear = finalZone.clone()
                    finalZoneWithStartYear.setStartYear(finalStartYear)
                    let tzt = finalZoneWithStartYear.getNextTransition(startTime, false)
                    firstFinalRule = tzt.getTo()
                    startTime = tzt.getTime()
                } else {
                    finalZoneWithStartYear = finalZone
                    firstFinalRule = TimeArrayTimeZoneRule(finalZone.getID(), finalZone.getRawOffset(), 0, [startTime], DateTimeRule.UTC_TIME)
                }
                var prevRule: TimeZoneRule
                if (transitionCount > 0) {
                    prevRule = historicRules[Int64(getInt(typeMapData[Int64(transitionCount - 1)]))]
                }
                if (prevRule.isNone()) {
                    prevRule = initialRule
                }
                firstFinalTZTransition = TimeZoneTransition(startTime, prevRule, firstFinalRule)
            }
            transitionRulesInitialized = true
        }
    }

    private static let currentSerialVersion = 1

    private var serialVersionOnStream = currentSerialVersion

    private func readObject(stream: ObjectInputStream): Unit {
        stream.defaultReadObject()
        if (serialVersionOnStream < 1) {
            var initialized = false
            let tzid = getID()
            if (tzid.isSome()) {
                try {
                    let top = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, ZONEINFORES, ICUResourceBundle.ICU_DATA_CLASS_LOADER)
                    let res = ZoneMeta.openOlsonResource(top, tzid)
                    construct(top, res, tzid)
                    initialized = true
                } catch (ignored: Exception) { }
            }
            if (!initialized) {
                constructEmpty()
            }
        }
        transitionRulesInitialized = false
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
        if (finalZone.isSome()) {
            tz.finalZone = finalZone.clone()
        }
        tz.isFrozen = false
        return tz
    }
}
