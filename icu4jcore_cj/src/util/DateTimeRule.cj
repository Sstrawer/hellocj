package icu4cj.util

public class DateTimeRule <: Serializable {
    private static let serialVersionUID = 2183055795738051443

    public static let DOM = 0

    public static let DOW = 1

    public static let DOW_GEQ_DOM = 2

    public static let DOW_LEQ_DOM = 3

    public static let WALL_TIME = 0

    public static let STANDARD_TIME = 1

    public static let UTC_TIME = 2

    private let dateRuleType: Int32

    private let month: Int32

    private let dayOfMonth: Int32

    private let dayOfWeek: Int32

    private let weekInMonth: Int32

    private let timeRuleType: Int32

    private let millisInDay: Int32

    public init(month: Int32, dayOfMonth: Int32, millisInDay: Int32, timeType: Int32) {
        dateRuleType = DOM
        this.month = month
        this.dayOfMonth = dayOfMonth
        this.millisInDay = millisInDay
        this.timeRuleType = timeType
        this.dayOfWeek = 0
        this.weekInMonth = 0
    }

    public init(month: Int32, weekInMonth: Int32, dayOfWeek: Int32, millisInDay: Int32, timeType: Int32) {
        dateRuleType = DOW
        this.month = month
        this.weekInMonth = weekInMonth
        this.dayOfWeek = dayOfWeek
        this.millisInDay = millisInDay
        this.timeRuleType = timeType
        this.dayOfMonth = 0
    }

    public init(month: Int32, dayOfMonth: Int32, dayOfWeek: Int32, after: Bool, millisInDay: Int32, timeType: Int32) {
        this.dateRuleType = if (after) { DOW_GEQ_DOM } else { DOW_LEQ_DOM }
        this.month = month
        this.dayOfMonth = dayOfMonth
        this.dayOfWeek = dayOfWeek
        this.millisInDay = millisInDay
        this.timeRuleType = timeType
        this.weekInMonth = 0
    }

    public func getDateRuleType(): Int32 {
        return dateRuleType
    }

    public func getRuleMonth(): Int32 {
        return month
    }

    public func getRuleDayOfMonth(): Int32 {
        return dayOfMonth
    }

    public func getRuleDayOfWeek(): Int32 {
        return dayOfWeek
    }

    public func getRuleWeekInMonth(): Int32 {
        return weekInMonth
    }

    public func getTimeRuleType(): Int32 {
        return timeRuleType
    }

    public func getRuleMillisInDay(): Int32 {
        return millisInDay
    }

    private static let DOWSTR: Array<String> = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    private static let MONSTR: Array<String> = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

    public override func toString(): String {
        var sDate: String
        var sTimeRuleType: String
        match (dateRuleType) {
            case 0 => sDate = dayOfMonth.toString()
            case 1 => sDate = weekInMonth.toString() + (DOWSTR[Int64(dayOfWeek)])
            case 2 => sDate = (DOWSTR[Int64(dayOfWeek)]) + ">=" + dayOfMonth.toString()
            case 3 => sDate = (DOWSTR[Int64(dayOfWeek)]) + "<=" + dayOfMonth.toString()
            case _ => ()
        }
        match (timeRuleType) {
            case 0 => sTimeRuleType = "WALL"
            case 1 => sTimeRuleType = "STD"
            case 2 => sTimeRuleType = "UTC"
            case _ => ()
        }
        var time = millisInDay
        let millis = time % 1000
        time /= 1000
        let secs = time % 60
        time /= 60
        let mins = time % 60
        let hours = time / 60
        let buf = StringBuilder()
        buf.append("month=")
        buf.append(MONSTR[Int64(month)])
        buf.append(", date=")
        buf.append(sDate)
        buf.append(", time=")
        buf.append(hours)
        buf.append(":")
        buf.append(mins / 10)
        buf.append(mins % 10)
        buf.append(":")
        buf.append(secs / 10)
        buf.append(secs % 10)
        buf.append(".")
        buf.append(millis / 100)
        buf.append((millis / 10) % 10)
        buf.append(millis % 10)
        buf.append("(")
        buf.append(sTimeRuleType)
        buf.append(")")
        return buf.toString()
    }
}
