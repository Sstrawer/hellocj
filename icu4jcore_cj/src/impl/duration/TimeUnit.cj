package icu4cj.impl.duration


public class TimeUnit {
    let name: String

    let ordinal: UInt8

    private init(name: String, ordinal: Int32) {
        this.name = name
        this.ordinal = UInt8(ordinal)
    }

    public override func toString(): String {
        return name
    }

    public static let YEAR = TimeUnit("year", 0)

    public static let MONTH = TimeUnit("month", 1)

    public static let WEEK = TimeUnit("week", 2)

    public static let DAY = TimeUnit("day", 3)

    public static let HOUR = TimeUnit("hour", 4)

    public static let MINUTE = TimeUnit("minute", 5)

    public static let SECOND = TimeUnit("second", 6)

    public static let MILLISECOND = TimeUnit("millisecond", 7)

    public func larger(): TimeUnit {
        return if (Int32(ordinal) == 0) { None } else { units[Int64(Int32(ordinal) - 1)] }
    }

    public func smaller(): TimeUnit {
        return if (Int32(ordinal) == Int32(units.size) - 1) { None } else { units[Int64(Int32(ordinal) + 1)] }
    }

    static let units: Array<TimeUnit> = [YEAR, MONTH, WEEK, DAY, HOUR, MINUTE, SECOND, MILLISECOND]

    public func ordinalMethod(): Int32 {
        return Int32(ordinal)
    }

    static let approxDurations = [36525 * 24 * 60 * 60 * 10, Int64(3045 * 24 * 60 * 60) * 10, Int64(7 * 24 * 60 * 60) * 1000, Int64(24 * 60 * 60) * 1000, Int64(60 * 60) * 1000, 60 * 1000, 1000, 1]
}
