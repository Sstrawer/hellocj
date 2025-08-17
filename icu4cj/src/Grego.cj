package icu4cj

/**
 * Grego utility class for Cangjie
 * A utility class providing proleptic Gregorian calendar functions
 * used by time zone and calendar code. Do not instantiate.
 * Translated from Java to Cangjie
 */
class Grego {
    // Max/min milliseconds
    public static let MIN_MILLIS: Int64 = -184303902528000000
    public static let MAX_MILLIS: Int64 = 183882168921600000
    
    public static let MILLIS_PER_SECOND: Int64 = 1000
    public static let MILLIS_PER_MINUTE: Int64 = 60 * MILLIS_PER_SECOND
    public static let MILLIS_PER_HOUR: Int64 = 60 * MILLIS_PER_MINUTE
    public static let MILLIS_PER_DAY: Int64 = 24 * MILLIS_PER_HOUR
    
    // January 1, 1 CE Gregorian
    private static let JULIAN_1_CE: Int64 = 1721426
    
    // January 1, 1970 CE Gregorian
    private static let JULIAN_1970_CE: Int64 = 2440588
    
    private static let MONTH_LENGTH: VArray<Int64, $24> = [
        31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,  // Non-leap year
        31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31   // Leap year
    ]
    
    private static let DAYS_BEFORE: VArray<Int64, $24> = [
        0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334,   // Non-leap year
        0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335    // Leap year
    ]
    
    /**
     * Return true if the given year is a leap year.
     * @param year Gregorian year, with 0 == 1 BCE, -1 == 2 BCE, etc.
     * @return true if the year is a leap year
     */
    public static func isLeapYear(year: Int64): Bool {
        // year&0x3 == year%4
        return ((year & 0x3) == 0) && ((year % 100 != 0) || (year % 400 == 0))
    }
    
    /**
     * Return the number of days in the given month.
     * @param year Gregorian year, with 0 == 1 BCE, -1 == 2 BCE, etc.
     * @param month 0-based month, with 0==Jan
     * @return the number of days in the given month
     */
    public static func monthLength(year: Int64, month: Int64): Int64 {
        let index: Int64
        if (isLeapYear(year)) {
            index = month + 12
        } else {
            index = month
        }
        return MONTH_LENGTH[index]
    }
    
    /**
     * Return the length of a previous month of the Gregorian calendar.
     * @param year Gregorian year, with 0 == 1 BCE, -1 == 2 BCE, etc.
     * @param month 0-based month, with 0==Jan
     * @return the number of days in the month previous to the given month
     */
    public static func previousMonthLength(year: Int64, month: Int64): Int64 {
        if (month > 0) {
            return monthLength(year, month - 1)
        } else {
            return 31
        }
    }
    
    /**
     * Convert a year, month, and day-of-month, given in the proleptic
     * Gregorian calendar, to 1970 epoch days.
     * @param year Gregorian year, with 0 == 1 BCE, -1 == 2 BCE, etc.
     * @param month 0-based month, with 0==Jan
     * @param dom 1-based day of month
     * @return the day number, with day 0 == Jan 1 1970
     */
    public static func fieldsToDay(year: Int64, month: Int64, dom: Int64): Int64 {
        let y = year - 1
        let monthIndex: Int64
        if (isLeapYear(year)) {
            monthIndex = month + 12
        } else {
            monthIndex = month
        }
        let julian = 365 * y + floorDivide(y, 4) + (JULIAN_1_CE - 3) +    // Julian cal
                     floorDivide(y, 400) - floorDivide(y, 100) + 2 +       // => Gregorian cal
                     DAYS_BEFORE[monthIndex] + dom // => month/dom
        
        return julian - JULIAN_1970_CE
    }
    
    /**
     * Convert 1970 epoch days to a year, month, and day-of-month.
     * @param day 1970 epoch day (integral value)
     * @return array of [year, month, day-of-month]
     */
    public static func dayToFields(day: Int64): VArray<Int64, $3> {
        let julian = day + JULIAN_1970_CE
        
        // Find year
        let y400 = floorDivide(julian - JULIAN_1_CE, 146097)
        let d400 = julian - JULIAN_1_CE - 146097 * y400
        let y100 = floorDivide(d400, 36524)
        let d100 = d400 - 36524 * y100
        let y4 = floorDivide(d100, 1461)
        let d4 = d100 - 1461 * y4
        let y1 = floorDivide(d4, 365)
        let d1 = d4 - 365 * y1
        let year = 400 * y400 + 100 * y100 + 4 * y4 + y1 + 1
        
        // Find month and day
        let leap = isLeapYear(year)
        var month: Int64 = 0
        var dayOfYear: Int64 = d1 + 1
        
        var m = 0
        while (m < 12) {
            let monthIndex: Int64
            if (leap) {
                monthIndex = m + 12
            } else {
                monthIndex = m
            }
            let monthLen = MONTH_LENGTH[monthIndex]
            if (dayOfYear <= monthLen) {
                month = m
                break
            }
            dayOfYear = dayOfYear - monthLen
            m = m + 1
        }
        
        return [year, month, dayOfYear]
    }
    
    /**
     * Floor division helper function
     */
    private static func floorDivide(numerator: Int64, denominator: Int64): Int64 {
        if (numerator >= 0) {
            return numerator / denominator
        } else {
            return (numerator - denominator + 1) / denominator
        }
    }
    
    /**
     * Get the day of week for a given date
     * @param year Gregorian year
     * @param month 0-based month (0=Jan)
     * @param day 1-based day of month
     * @return day of week (1=Sunday, 2=Monday, ..., 7=Saturday)
     */
    public static func dayOfWeek(year: Int64, month: Int64, day: Int64): Int64 {
        let dayNum = fieldsToDay(year, month, day)
        let dayOfWeek = (dayNum + 4) % 7  // Jan 1, 1970 was a Thursday (4)
        return dayOfWeek + 1  // Convert to 1-based
    }
    
    /**
     * Get the number of days in a year
     */
    public static func daysInYear(year: Int64): Int64 {
        if (isLeapYear(year)) {
            return 366
        } else {
            return 365
        }
    }
    
    /**
     * Check if a date is valid
     */
    public static func isValidDate(year: Int64, month: Int64, day: Int64): Bool {
        if (month < 0 || month > 11) {
            return false
        }
        if (day < 1 || day > monthLength(year, month)) {
            return false
        }
        return true
    }
}
