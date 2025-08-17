package icu4cj.util

public class TimeArrayTimeZoneRule <: TimeZoneRule {
    private static let serialVersionUID = -1117109130077415245

    private let startTimes: Array<Int64>

    private let timeType: Int32

    public init(name: String, rawOffset: Int32, dstSavings: Int32, startTimes: Array<Int64>, timeType: Int32) {
        super(name, rawOffset, dstSavings)
        if (startTimes.isNone() || Int32(startTimes.size) == 0) {
            throw IllegalArgumentException("No start times are specified.")
        } else {
            this.startTimes = startTimes.clone()
            stableSort(this.startTimes)
        }
        this.timeType = timeType
    }

    public func getStartTimes(): Array<Int64> {
        return startTimes.clone()
    }

    public func getTimeType(): Int32 {
        return timeType
    }

    public override func getFirstStart(prevRawOffset: Int32, prevDSTSavings: Int32): DateTime {
        return Date(getUTC(startTimes[0], prevRawOffset, prevDSTSavings))
    }

    public override func getFinalStart(prevRawOffset: Int32, prevDSTSavings: Int32): DateTime {
        return Date(getUTC(startTimes[Int64(Int32(startTimes.size) - 1)], prevRawOffset, prevDSTSavings))
    }

    public override func getNextStart(base: Int64, prevOffset: Int32, prevDSTSavings: Int32, inclusive: Bool): DateTime {
        var i = Int32(startTimes.size) - 1
        while (i >= 0) {
            let time = getUTC(startTimes[Int64(i)], prevOffset, prevDSTSavings)
            if (time < base || (!inclusive && time == base)) {
                break
            }
            i--
        }
        if (i == Int32(startTimes.size) - 1) {
            return None
        }
        return Date(getUTC(startTimes[Int64(i + 1)], prevOffset, prevDSTSavings))
    }

    public override func getPreviousStart(base: Int64, prevOffset: Int32, prevDSTSavings: Int32, inclusive: Bool): DateTime {
        var i = Int32(startTimes.size) - 1
        while (i >= 0) {
            let time = getUTC(startTimes[Int64(i)], prevOffset, prevDSTSavings)
            if (time < base || (inclusive && time == base)) {
                return Date(time)
            }
            i--
        }
        return None
    }

    public override func isEquivalentTo(other: TimeZoneRule): Bool {
        if (!(checkOptionalIs<TimeArrayTimeZoneRule, TimeZoneRule>(other))) {
            return false
        }
        if (timeType == other.timeType && startTimes == other.startTimes) {
            return super.isEquivalentTo(other)
        }
        return false
    }

    public override func isTransitionRule(): Bool {
        return true
    }

    private func getUTC(time: Int64, raw: Int32, dst: Int32): Int64 {
        var temptime = time
        if (timeType != DateTimeRule.UTC_TIME) {
            temptime -= Int64(raw)
        }
        if (timeType == DateTimeRule.WALL_TIME) {
            temptime -= Int64(dst)
        }
        return temptime
    }

    public override func toString(): String {
        let buf = StringBuilder()
        buf.append(super.toString())
        buf.append(", timeType=")
        buf.append(timeType)
        buf.append(", startTimes=[")
        var i = 0
        while (i < Int32(startTimes.size)) {
            if (i != 0) {
                buf.append(", ")
            }
            buf.append(startTimes[Int64(i)].toString())
            i++
        }
        buf.append("]")
        return buf.toString()
    }
}
