package icu4cj.impl

public class DayPeriodRules {
    private static let DATA = loadData()

    var hasMidnight: Bool = false

    var hasNoon: Bool = false

    var dayPeriodForHour: Array<DayPeriodRules_DayPeriod>

    init() {
        hasMidnight = false
        hasNoon = false
        dayPeriodForHour = Array<DayPeriodRules_DayPeriod>(24)
    }

    public static func getInstance(locale: ULocale): DayPeriodRules {
        var localeCode = locale.getBaseName()
        if (localeCode.isEmpty()) {
            localeCode = "root"
        }
        var ruleSetNum: Int32
        while (ruleSetNum.isNone()) {
            ruleSetNum = DATA.localesToRuleSetNumMap.get(localeCode)
            if (ruleSetNum.isNone()) {
                localeCode = ULocale.getFallbackStatic(localeCode)
                if (localeCode.isEmpty()) {
                    break
                }
            } else {
                break
            }
        }
        if (ruleSetNum.isNone() || DATA.rules[Int64(ruleSetNum)].isNone()) {
            return None
        }
        return DATA.rules[Int64(ruleSetNum)]
    }

    public func getMidPointForDayPeriod(dayPeriod: DayPeriodRules_DayPeriod): Float64 {
        let startHour = getStartHourForDayPeriod(dayPeriod)
        let endHour = getEndHourForDayPeriod(dayPeriod)
        var midPoint = (Float64(startHour + endHour)) / 2.0
        if (startHour > endHour) {
            midPoint += 12.0
            if (midPoint >= 24.0) {
                midPoint -= 24.0
            }
        }
        return midPoint
    }

    private static func loadData(): DayPeriodRules_DayPeriodRulesData {
        let data = DayPeriodRules_DayPeriodRulesData()
        let rb = ICUResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "dayPeriods", ICUResourceBundle.ICU_DATA_CLASS_LOADER, true)
        let countSink = DayPeriodRules_DayPeriodRulesCountSink(data)
        rb.getAllItemsWithFallback("rules", countSink)
        data.rules = Array<DayPeriodRules>(Int64(data.maxRuleSetNum + 1))
        let sink = DayPeriodRules_DayPeriodRulesDataSink(data)
        rb.getAllItemsWithFallback("", sink)
        return data
    }

    private func getStartHourForDayPeriod(dayPeriod: DayPeriodRules_DayPeriod): Int32 {
        if (refEq(dayPeriod, DayPeriodRules_DayPeriod.MIDNIGHT)) {
            return 0
        }
        if (refEq(dayPeriod, DayPeriodRules_DayPeriod.NOON)) {
            return 12
        }
        if (refEq(dayPeriodForHour[0], dayPeriod) && refEq(dayPeriodForHour[23], dayPeriod)) {
                    i--
                }
            } while (false)
        } else {
                    i++
                }
            } while (false)
        }
        throw IllegalArgumentException()
    }

    private func getEndHourForDayPeriod(dayPeriod: DayPeriodRules_DayPeriod): Int32 {
        if (refEq(dayPeriod, DayPeriodRules_DayPeriod.MIDNIGHT)) {
            return 0
        }
        if (refEq(dayPeriod, DayPeriodRules_DayPeriod.NOON)) {
            return 12
        }
        if (refEq(dayPeriodForHour[0], dayPeriod) && refEq(dayPeriodForHour[23], dayPeriod)) {
                    i++
                }
            } while (false)
        } else {
                    i--
                }
            } while (false)
        }
        throw IllegalArgumentException()
    }

    public func hasMidnightMethod(): Bool {
        return hasMidnight
    }

    public func hasNoonMethod(): Bool {
        return hasNoon
    }

    public func getDayPeriodForHour(hour: Int32): DayPeriodRules_DayPeriod {
        return dayPeriodForHour[Int64(hour)]
    }

    public func add(startHour: Int32, limitHour: Int32, period: DayPeriodRules_DayPeriod): Unit {
        var i = startHour
        while (i != limitHour) {
            if (i == 24) {
                i = 0
            }
            dayPeriodForHour[Int64(i)] = period
            i++
        }
    }

    static func parseSetNum(setNumStr: String): Int32 {
        if (!setNumStr.startsWith("set")) {
            throw ICUException("Set number should start with \"set\".")
        }
        let numStr: String = setNumStr[3..]
        return parse<Int32>(numStr)
    }
}


public class DayPeriodRules_DayPeriod <: Enum<DayPeriodRules_DayPeriod> {
    public static let MIDNIGHT = DayPeriodRules_DayPeriod("MIDNIGHT", 0)

    public static let NOON = DayPeriodRules_DayPeriod("NOON", 1)

    public static let MORNING1 = DayPeriodRules_DayPeriod("MORNING1", 2)

    public static let AFTERNOON1 = DayPeriodRules_DayPeriod("AFTERNOON1", 3)

    public static let EVENING1 = DayPeriodRules_DayPeriod("EVENING1", 4)

    public static let NIGHT1 = DayPeriodRules_DayPeriod("NIGHT1", 5)

    public static let MORNING2 = DayPeriodRules_DayPeriod("MORNING2", 6)

    public static let AFTERNOON2 = DayPeriodRules_DayPeriod("AFTERNOON2", 7)

    public static let EVENING2 = DayPeriodRules_DayPeriod("EVENING2", 8)

    public static let NIGHT2 = DayPeriodRules_DayPeriod("NIGHT2", 9)

    public static let AM = DayPeriodRules_DayPeriod("AM", 10)

    public static let PM = DayPeriodRules_DayPeriod("PM", 11)

    private static func _values(): Array<DayPeriodRules_DayPeriod> {
        return [DayPeriodRules_DayPeriod.MIDNIGHT, DayPeriodRules_DayPeriod.NOON, DayPeriodRules_DayPeriod.MORNING1, DayPeriodRules_DayPeriod.AFTERNOON1, DayPeriodRules_DayPeriod.EVENING1, DayPeriodRules_DayPeriod.NIGHT1, DayPeriodRules_DayPeriod.MORNING2, DayPeriodRules_DayPeriod.AFTERNOON2, DayPeriodRules_DayPeriod.EVENING2, DayPeriodRules_DayPeriod.NIGHT2, DayPeriodRules_DayPeriod.AM, DayPeriodRules_DayPeriod.PM]
    }

    private static let _VALUES = DayPeriodRules_DayPeriod._values()

    public static func values(): Array<DayPeriodRules_DayPeriod> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DayPeriodRules_DayPeriod {
        return (TypeInfo.of<DayPeriodRules_DayPeriod>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DayPeriodRules_DayPeriod
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public static var VALUES = DayPeriodRules_DayPeriod.values()

    static func fromStringOrNull(str: String): DayPeriodRules_DayPeriod {
        if ("midnight".contentEquals(str)) {
            return MIDNIGHT
        }
        if ("noon".contentEquals(str)) {
            return NOON
        }
        if ("morning1".contentEquals(str)) {
            return MORNING1
        }
        if ("afternoon1".contentEquals(str)) {
            return AFTERNOON1
        }
        if ("evening1".contentEquals(str)) {
            return EVENING1
        }
        if ("night1".contentEquals(str)) {
            return NIGHT1
        }
        if ("morning2".contentEquals(str)) {
            return MORNING2
        }
        if ("afternoon2".contentEquals(str)) {
            return AFTERNOON2
        }
        if ("evening2".contentEquals(str)) {
            return EVENING2
        }
        if ("night2".contentEquals(str)) {
            return NIGHT2
        }
        if ("am".contentEquals(str)) {
            return AM
        }
        if ("pm".contentEquals(str)) {
            return PM
        }
        return None
    }
}


class DayPeriodRules_CutoffType <: Enum<DayPeriodRules_CutoffType> {
    public static let BEFORE = DayPeriodRules_CutoffType("BEFORE", 0)

    public static let AFTER = DayPeriodRules_CutoffType("AFTER", 1)

    public static let FROM = DayPeriodRules_CutoffType("FROM", 2)

    public static let AT = DayPeriodRules_CutoffType("AT", 3)

    private static func _values(): Array<DayPeriodRules_CutoffType> {
        return [DayPeriodRules_CutoffType.BEFORE, DayPeriodRules_CutoffType.AFTER, DayPeriodRules_CutoffType.FROM, DayPeriodRules_CutoffType.AT]
    }

    private static let _VALUES = DayPeriodRules_CutoffType._values()

    public static func values(): Array<DayPeriodRules_CutoffType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DayPeriodRules_CutoffType {
        return (TypeInfo.of<DayPeriodRules_CutoffType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DayPeriodRules_CutoffType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    static func fromStringOrNull(str: String): DayPeriodRules_CutoffType {
        if ("from".contentEquals(str)) {
            return DayPeriodRules_CutoffType.FROM
        }
        if ("before".contentEquals(str)) {
            return DayPeriodRules_CutoffType.BEFORE
        }
        if ("after".contentEquals(str)) {
            return DayPeriodRules_CutoffType.AFTER
        }
        if ("at".contentEquals(str)) {
            return DayPeriodRules_CutoffType.AT
        }
        return None
    }
}


class DayPeriodRules_DayPeriodRulesData {

    var localesToRuleSetNumMap: Map<String, Int32> = HashMap<String, Int32>()

    var rules: Array<DayPeriodRules>

    var maxRuleSetNum = -1
}


class DayPeriodRules_DayPeriodRulesDataSink <: UResource_Sink {
    private var data: DayPeriodRules_DayPeriodRulesData

    init(data: DayPeriodRules_DayPeriodRulesData) {
        super()
        this.data = data
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let dayPeriodData = value.getTable()
        var i = 0
        while (dayPeriodData.getKeyAndValue(i, key, value)) {
            if (key.contentEquals("locales")) {
                let locales = value.getTable()
                var j = 0
                while (locales.getKeyAndValue(j, key, value)) {
                    let setNum = DayPeriodRules.parseSetNum(value.getString())
                    data.localesToRuleSetNumMap.put(key.toString(), setNum)
                    j++
                }
            } else if (key.contentEquals("rules")) {
                let rules = value.getTable()
                processRules(rules, key, value)
            }
            i++
        }
    }

    private func processRules(rules: UResource_Table, key: UResource_Key, value: UResource_Value): Unit {
        var i = 0
        while (rules.getKeyAndValue(i, key, value)) {
            ruleSetNum = DayPeriodRules.parseSetNum(key.toString())
            data.rules[Int64(ruleSetNum)] = DayPeriodRules()
            let ruleSet = value.getTable()
            var j = 0
            while (ruleSet.getKeyAndValue(j, key, value)) {
                period = DayPeriodRules_DayPeriod.fromStringOrNull(key)
                if (period.isNone()) {
                    throw ICUException("Unknown day period in data.")
                }
                let periodDefinition = value.getTable()
                            cutoffType = DayPeriodRules_CutoffType.fromStringOrNull(key)
                            let cutoffArray = value.getArray()
                            let length = cutoffArray.getSize()
                            var l = 0
                            while (l < length) {
                                cutoffArray.getValue(l, value)
                                addCutoff(cutoffType, value.getString())
                                l++
                            }
                        }
                        k++
                    }
                } while (false)
                setDayPeriodForHoursFromCutoffs()
                } while (false)
                j++
            }
            for (period in data.rules[Int64(ruleSetNum)].dayPeriodForHour) {
                if (period.isNone()) {
                    throw ICUException("Rules in data don't cover all 24 hours (they should).")
                }
            }
            i++
        }
    }

    private var cutoffs: Array<Int32> = Array<Int32>(25) { _ => 0 }

    private var ruleSetNum: Int32 = 0

    private var period: DayPeriodRules_DayPeriod

    private var cutoffType: DayPeriodRules_CutoffType

    private func addCutoff(Type: DayPeriodRules_CutoffType, hourStr: String): Unit {
        if (Type.isNone()) {
            throw ICUException("Cutoff type not recognized.")
        }
        let hour = parseHour(hourStr)
        cutoffs[Int64(hour)] |= shl(1, Type.ordinal)
    }

    private func setDayPeriodForHoursFromCutoffs(): Unit {
        let rule = data.rules[Int64(ruleSetNum)]
        var startHour = 0
        while (startHour <= 24) {
            if ((cutoffs[Int64(startHour)] & (shl(1, DayPeriodRules_CutoffType.AT.ordinal))) > 0) {
                if (startHour == 0 && refEq(period, DayPeriodRules_DayPeriod.MIDNIGHT)) {
                    rule.hasMidnight = true
                } else if (startHour == 12 && refEq(period, DayPeriodRules_DayPeriod.NOON)) {
                    rule.hasNoon = true
                } else {
                    throw ICUException("AT cutoff must only be set for 0:00 or 12:00.")
                }
            }
            if ((cutoffs[Int64(startHour)] & (shl(1, DayPeriodRules_CutoffType.FROM.ordinal))) > 0 || (cutoffs[Int64(startHour)] & (shl(1, DayPeriodRules_CutoffType.AFTER.ordinal))) > 0) {
                var hour = startHour + 1
                while (true) {
                    if (hour == startHour) {
                        throw ICUException("FROM/AFTER cutoffs must have a matching BEFORE cutoff.")
                    }
                    if (hour == 25) {
                        hour = 0
                    }
                    if ((cutoffs[Int64(hour)] & (shl(1, DayPeriodRules_CutoffType.BEFORE.ordinal))) > 0) {
                        rule.add(startHour, hour, period)
                        break
                    }
                    hour++
                }
            }
            startHour++
        }
    }

    private static func parseHour(str: String): Int32 {
        let firstColonPos = indexOfWrap(str.indexOf(UInt8(UInt32(':'))))
        if (firstColonPos < 0 || !(str[Int64(firstColonPos)..] == ":00")) {
            throw ICUException("Cutoff time must end in \":00\".")
        }
        let hourStr: String = str[0..Int64(firstColonPos)]
        if (firstColonPos != 1 && firstColonPos != 2) {
            throw ICUException("Cutoff time must begin with h: or hh:")
        }
        let hour = parse<Int32>(hourStr)
        if (hour < 0 || hour > 24) {
            throw ICUException("Cutoff hour must be between 0 and 24, inclusive.")
        }
        return hour
    }
}


class DayPeriodRules_DayPeriodRulesCountSink <: UResource_Sink {
    private var data: DayPeriodRules_DayPeriodRulesData

    init(data: DayPeriodRules_DayPeriodRulesData) {
        super()
        this.data = data
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let rules = value.getTable()
        var i = 0
        while (rules.getKeyAndValue(i, key, value)) {
            let setNum = DayPeriodRules.parseSetNum(key.toString())
            if (setNum > data.maxRuleSetNum) {
                data.maxRuleSetNum = setNum
            }
            i++
        }
    }
}
