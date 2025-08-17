package icu4cj.util

public class TimeZoneTransition {
    private let comefrom: TimeZoneRule

    private let to: TimeZoneRule

    private let time: Int64

    public init(time: Int64, comefrom: TimeZoneRule, to: TimeZoneRule) {
        this.time = time
        this.comefrom = comefrom
        this.to = to
    }

    public func getTime(): Int64 {
        return time
    }

    public func getTo(): TimeZoneRule {
        return to
    }

    public func getFrom(): TimeZoneRule {
        return comefrom
    }

    public override func toString(): String {
        let buf = StringBuilder()
        buf.append("time=" + time.toString())
        buf.append(", from={" + comefrom.asString() + "}")
        buf.append(", to={" + to.asString() + "}")
        return buf.toString()
    }
}
