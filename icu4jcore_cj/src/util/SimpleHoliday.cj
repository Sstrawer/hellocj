package icu4cj.util

public class SimpleHoliday <: Holiday {
    public init(month: Int32, dayOfMonth: Int32, name: String) {
        super(name, SimpleDateRule(month, dayOfMonth))
    }

    public init(month: Int32, dayOfMonth: Int32, name: String, startYear: Int32) {
        super(name, rangeRule(startYear, 0, SimpleDateRule(month, dayOfMonth)))
    }

    public init(month: Int32, dayOfMonth: Int32, name: String, startYear: Int32, endYear: Int32) {
        super(name, rangeRule(startYear, endYear, SimpleDateRule(month, dayOfMonth)))
    }

    public init(month: Int32, dayOfMonth: Int32, dayOfWeek: Int32, name: String) {
        super(name, SimpleDateRule(month, dayOfMonth, if (dayOfWeek > 0) { dayOfWeek } else { -dayOfWeek }, dayOfWeek > 0))
    }

    public init(month: Int32, dayOfMonth: Int32, dayOfWeek: Int32, name: String, startYear: Int32) {
        super(name, rangeRule(startYear, 0, SimpleDateRule(month, dayOfMonth, if (dayOfWeek > 0) { dayOfWeek } else { -dayOfWeek }, dayOfWeek > 0)))
    }

    public init(month: Int32, dayOfMonth: Int32, dayOfWeek: Int32, name: String, startYear: Int32, endYear: Int32) {
        super(name, rangeRule(startYear, endYear, SimpleDateRule(month, dayOfMonth, if (dayOfWeek > 0) { dayOfWeek } else { -dayOfWeek }, dayOfWeek > 0)))
    }

    private static func rangeRule(startYear: Int32, endYear: Int32, rule: DateRule): DateRule {
        if (startYear == 0 && endYear == 0) {
            return rule
        }
        let rangeRule = RangeDateRule()
        if (startYear != 0) {
            let start: Calendar = GregorianCalendar(startYear, Calendar.JANUARY, 1)
            rangeRule.add(start.getTime(), rule)
        } else {
            rangeRule.add(rule)
        }
        if (endYear != 0) {
            let end = GregorianCalendar(endYear, Calendar.DECEMBER, 31).getTime()
            rangeRule.add(end, None)
        }
        return rangeRule
    }

    public static let NEW_YEARS_DAY = SimpleHoliday(Calendar.JANUARY, 1, "New Year's Day")

    public static let EPIPHANY = SimpleHoliday(Calendar.JANUARY, 6, "Epiphany")

    public static let MAY_DAY = SimpleHoliday(Calendar.MAY, 1, "May Day")

    public static let ASSUMPTION = SimpleHoliday(Calendar.AUGUST, 15, "Assumption")

    public static let ALL_SAINTS_DAY = SimpleHoliday(Calendar.NOVEMBER, 1, "All Saints' Day")

    public static let ALL_SOULS_DAY = SimpleHoliday(Calendar.NOVEMBER, 2, "All Souls' Day")

    public static let IMMACULATE_CONCEPTION = SimpleHoliday(Calendar.DECEMBER, 8, "Immaculate Conception")

    public static let CHRISTMAS_EVE = SimpleHoliday(Calendar.DECEMBER, 24, "Christmas Eve")

    public static let CHRISTMAS = SimpleHoliday(Calendar.DECEMBER, 25, "Christmas")

    public static let BOXING_DAY = SimpleHoliday(Calendar.DECEMBER, 26, "Boxing Day")

    public static let ST_STEPHENS_DAY = SimpleHoliday(Calendar.DECEMBER, 26, "St. Stephen's Day")

    public static let NEW_YEARS_EVE = SimpleHoliday(Calendar.DECEMBER, 31, "New Year's Eve")
}
