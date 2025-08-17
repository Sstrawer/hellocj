package icu4cj.impl.data

public class HolidayBundle_en_US <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fHolidays: Array<Holiday> = [SimpleHoliday.NEW_YEARS_DAY, SimpleHoliday(Calendar.JANUARY, 15, Calendar.MONDAY, "Martin Luther King Day", 1986), SimpleHoliday(Calendar.FEBRUARY, 15, Calendar.MONDAY, "Presidents' Day", 1976), SimpleHoliday(Calendar.FEBRUARY, 22, "Washington's Birthday", 1776, 1975), EasterHoliday.GOOD_FRIDAY, EasterHoliday.EASTER_SUNDAY, SimpleHoliday(Calendar.MAY, 8, Calendar.SUNDAY, "Mother's Day", 1914), SimpleHoliday(Calendar.MAY, 31, -Calendar.MONDAY, "Memorial Day", 1971), SimpleHoliday(Calendar.MAY, 30, "Memorial Day", 1868, 1970), SimpleHoliday(Calendar.JUNE, 15, Calendar.SUNDAY, "Father's Day", 1956), SimpleHoliday(Calendar.JULY, 4, "Independence Day", 1776), SimpleHoliday(Calendar.SEPTEMBER, 1, Calendar.MONDAY, "Labor Day", 1894), SimpleHoliday(Calendar.NOVEMBER, 2, Calendar.TUESDAY, "Election Day"), SimpleHoliday(Calendar.OCTOBER, 8, Calendar.MONDAY, "Columbus Day", 1971), SimpleHoliday(Calendar.OCTOBER, 31, "Halloween"), SimpleHoliday(Calendar.NOVEMBER, 11, "Veterans' Day", 1918), SimpleHoliday(Calendar.NOVEMBER, 22, Calendar.THURSDAY, "Thanksgiving", 1863), SimpleHoliday.CHRISTMAS]

    private static let fContents: Array<Array<Object>> = [["holidays", fHolidays]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
