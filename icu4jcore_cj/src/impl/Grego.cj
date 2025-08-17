package icu4cj.impl

public class Grego {

    public static let MIN_MILLIS = -184303902528000000

    public static let MAX_MILLIS = 183882168921600000

    public static let MILLIS_PER_SECOND = 1000

    public static let MILLIS_PER_MINUTE = 60 * MILLIS_PER_SECOND

    public static let MILLIS_PER_HOUR = 60 * MILLIS_PER_MINUTE

    public static let MILLIS_PER_DAY = 24 * MILLIS_PER_HOUR

    private static let JULIAN_1_CE = 1721426

    private static let JULIAN_1970_CE = 2440588

    private static let MONTH_LENGTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    private static let DAYS_BEFORE = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335]

    public static func isLeapYear(year: Int32): Bool {
        return ((year & 3) == 0) && ((year % 100 != 0) || (year % 400 == 0))
    }

    public static func monthLength(year: Int32, month: Int32): Int32 {
        return MONTH_LENGTH[Int64(month + (if (isLeapYear(year)) { 12 } else { 0 }))]
    }

    public static func previousMonthLength(year: Int32, month: Int32): Int32 {
        return if (month > 0) { monthLength(year, month - 1) } else { 31 }
    }

    public static func fieldsToDay(year: Int32, month: Int32, dom: Int32): Int64 {
        let y = year - 1
        let julian = Int64(365 * y) + floorDivide(Int64(y), 4) + (Int64(JULIAN_1_CE - 3)) + floorDivide(Int64(y), 400) - floorDivide(Int64(y), 100) + 2 + Int64(DAYS_BEFORE[Int64(month + (if (isLeapYear(year)) { 12 } else { 0 }))]) + Int64(dom)
        return julian - Int64(JULIAN_1970_CE)
    }

    public static func dayOfWeek(day: Int64): Int32 {
        let remainder = Array<Int64>(1) { _ => 0 }
        floorDivide(day + 5, 7, remainder)
        var dayOfWeek = Int32(remainder[0])
        dayOfWeek = if (dayOfWeek == 0) { 7 } else { dayOfWeek }
        return dayOfWeek
    }

    public static func dayToFields(day: Int64, fields: Array<Int32>): Array<Int32> {
        var tempfields = fields
        var tempday = day
        if (tempfields.isNone() || Int32(tempfields.size) < 5) {
            tempfields = Array<Int32>(5) { _ => 0 }
        }
        tempday += Int64(JULIAN_1970_CE - JULIAN_1_CE)
        let rem = Array<Int64>(1) { _ => 0 }
        let n400 = floorDivide(tempday, 146097, rem)
        let n100 = floorDivide(rem[0], 36524, rem)
        let n4 = floorDivide(rem[0], 1461, rem)
        let n1 = floorDivide(rem[0], 365, rem)
        var year = Int32(400 * n400 + 100 * n100 + 4 * n4 + n1)
        var dayOfYear = Int32(rem[0])
        if (n100 == 4 || n1 == 4) {
            dayOfYear = 365
        } else {
            year++
        }
        let isLeap = isLeapYear(year)
        var correction = 0
        let march1 = if (isLeap) { 60 } else { 59 }
        if (dayOfYear >= march1) {
            correction = if (isLeap) { 1 } else { 2 }
        }
        let month = (12 * (dayOfYear + correction) + 6) / 367
        let dayOfMonth = dayOfYear - DAYS_BEFORE[if (isLeap) { Int64(month + 12) } else { Int64(month) }] + 1
        var dayOfWeek = Int32((tempday + 2) % 7)
        if (dayOfWeek < 1) {
            dayOfWeek += 7
        }
        dayOfYear++
        tempfields[0] = year
        tempfields[1] = month
        tempfields[2] = dayOfMonth
        tempfields[3] = dayOfWeek
        tempfields[4] = dayOfYear
        return tempfields
    }

    public static func timeToFields(time: Int64, fields: Array<Int32>): Array<Int32> {
        var tempfields = fields
        if (tempfields.isNone() || Int32(tempfields.size) < 6) {
            tempfields = Array<Int32>(6) { _ => 0 }
        }
        let remainder = Array<Int64>(1) { _ => 0 }
        let day = floorDivide(time, Int64(24 * 60 * 60 * 1000), remainder)
        dayToFields(day, tempfields)
        tempfields[5] = Int32(remainder[0])
        return tempfields
    }

    public static func floorDivide(numerator: Int64, denominator: Int64): Int64 {
        return if (numerator >= 0) { numerator / denominator } else { ((numerator + 1) / denominator) - 1 }
    }

    private static func floorDivide(numerator: Int64, denominator: Int64, remainder: Array<Int64>): Int64 {
        if (numerator >= 0) {
            remainder[0] = numerator % denominator
            return numerator / denominator
        }
        let quotient = ((numerator + 1) / denominator) - 1
        remainder[0] = numerator - (quotient * denominator)
        return quotient
    }

    public static func getDayOfWeekInMonth(year: Int32, month: Int32, dayOfMonth: Int32): Int32 {
        var weekInMonth = (dayOfMonth + 6) / 7
        if (weekInMonth == 4) {
            if (dayOfMonth + 7 > monthLength(year, month)) {
                weekInMonth = -1
            }
        } else if (weekInMonth == 5) {
            weekInMonth = -1
        }
        return weekInMonth
    }

    public static func timeToString(time: Int64): String {
        let fields = timeToFields(time, None)
        var millis = fields[5]
        let hour = millis / MILLIS_PER_HOUR
        millis = millis % MILLIS_PER_HOUR
        let min = millis / MILLIS_PER_MINUTE
        millis = millis % MILLIS_PER_MINUTE
        let sec = millis / MILLIS_PER_SECOND
        millis = millis % MILLIS_PER_SECOND
        return String.format(None, "%04d-%02d-%02dT%02d:%02d:%02d.%03dZ", [fields[0], fields[1] + 1, fields[2], hour, min, sec, millis])
    }
}
