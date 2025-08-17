package icu4cj.util

public class AnnualTimeZoneRule <: TimeZoneRule {
    private static let serialVersionUID = -8870666707791230688

    public static let MAX_YEAR = Int32.Max

    private let dateTimeRule: DateTimeRule

    private let startYear: Int32

    private let endYear: Int32

    public init(name: String, rawOffset: Int32, dstSavings: Int32, dateTimeRule: DateTimeRule, startYear: Int32, endYear: Int32) {
        super(name, rawOffset, dstSavings)
        this.dateTimeRule = dateTimeRule
        this.startYear = startYear
        this.endYear = endYear
    }

    public func getRule(): DateTimeRule {
        return dateTimeRule
    }

    public func getStartYear(): Int32 {
        return startYear
    }

    public func getEndYear(): Int32 {
        return endYear
    }

    public func getStartInYear(year: Int32, prevRawOffset: Int32, prevDSTSavings: Int32): DateTime {
        if (year < startYear || year > endYear) {
            return None
        }
        var ruleDay: Int64 = 0
        let Type = dateTimeRule.getDateRuleType()
        if (Type == DateTimeRule.DOM) {
            ruleDay = Grego.fieldsToDay(year, dateTimeRule.getRuleMonth(), dateTimeRule.getRuleDayOfMonth())
        } else {
            var after = true
            if (Type == DateTimeRule.DOW) {
                let weeks = dateTimeRule.getRuleWeekInMonth()
                if (weeks > 0) {
                    ruleDay = Grego.fieldsToDay(year, dateTimeRule.getRuleMonth(), 1)
                    ruleDay += Int64(7 * (weeks - 1))
                } else {
                    after = false
                    ruleDay = Grego.fieldsToDay(year, dateTimeRule.getRuleMonth(), Grego.monthLength(year, dateTimeRule.getRuleMonth()))
                    ruleDay += Int64(7 * (weeks + 1))
                }
            } else {
                let month = dateTimeRule.getRuleMonth()
                var dom = dateTimeRule.getRuleDayOfMonth()
                if (Type == DateTimeRule.DOW_LEQ_DOM) {
                    after = false
                    if (month == Calendar.FEBRUARY && dom == 29 && !Grego.isLeapYear(year)) {
                        dom--
                    }
                }
                ruleDay = Grego.fieldsToDay(year, month, dom)
            }
            let dow = Grego.dayOfWeek(ruleDay)
            var delta = dateTimeRule.getRuleDayOfWeek() - dow
            if (after) {
                delta = if (delta < 0) { delta + 7 } else { delta }
            } else {
                delta = if (delta > 0) { delta - 7 } else { delta }
            }
            ruleDay += Int64(delta)
        }
        var ruleTime = ruleDay * Int64(Grego.MILLIS_PER_DAY) + Int64(dateTimeRule.getRuleMillisInDay())
        if (dateTimeRule.getTimeRuleType() != DateTimeRule.UTC_TIME) {
            ruleTime -= Int64(prevRawOffset)
        }
        if (dateTimeRule.getTimeRuleType() == DateTimeRule.WALL_TIME) {
            ruleTime -= Int64(prevDSTSavings)
        }
        return Date(ruleTime)
    }

    public override func getFirstStart(prevRawOffset: Int32, prevDSTSavings: Int32): DateTime {
        return getStartInYear(startYear, prevRawOffset, prevDSTSavings)
    }

    public override func getFinalStart(prevRawOffset: Int32, prevDSTSavings: Int32): DateTime {
        if (endYear == MAX_YEAR) {
            return None
        }
        return getStartInYear(endYear, prevRawOffset, prevDSTSavings)
    }

    public override func getNextStart(base: Int64, prevRawOffset: Int32, prevDSTSavings: Int32, inclusive: Bool): DateTime {
        let fields = Grego.timeToFields(base, None)
        let year = fields[0]
        if (year < startYear) {
            return getFirstStart(prevRawOffset, prevDSTSavings)
        }
        var d = getStartInYear(year, prevRawOffset, prevDSTSavings)
        if (d.isSome() && (d.getTime() < base || (!inclusive && (d.getTime() == base)))) {
            d = getStartInYear(year + 1, prevRawOffset, prevDSTSavings)
        }
        return d
    }

    public override func getPreviousStart(base: Int64, prevRawOffset: Int32, prevDSTSavings: Int32, inclusive: Bool): DateTime {
        let fields = Grego.timeToFields(base, None)
        let year = fields[0]
        if (year > endYear) {
            return getFinalStart(prevRawOffset, prevDSTSavings)
        }
        var d = getStartInYear(year, prevRawOffset, prevDSTSavings)
        if (d.isSome() && (d.getTime() > base || (!inclusive && (d.getTime() == base)))) {
            d = getStartInYear(year - 1, prevRawOffset, prevDSTSavings)
        }
        return d
    }

    public override func isEquivalentTo(other: TimeZoneRule): Bool {
        if (!(checkOptionalIs<AnnualTimeZoneRule, TimeZoneRule>(other))) {
            return false
        }
        let otherRule = other
        if (startYear == otherRule.startYear && endYear == otherRule.endYear && refEq(dateTimeRule, otherRule.dateTimeRule)) {
            return super.isEquivalentTo(other)
        }
        return false
    }

    public override func isTransitionRule(): Bool {
        return true
    }

    public override func toString(): String {
        let buf = StringBuilder()
        buf.append(super.toString())
        buf.append(", rule={" + dateTimeRule.asString() + "}")
        buf.append(", startYear=" + startYear.toString())
        buf.append(", endYear=")
        if (endYear == MAX_YEAR) {
            buf.append("max")
        } else {
            buf.append(endYear)
        }
        return buf.toString()
    }
}
