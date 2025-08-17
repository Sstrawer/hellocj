package icu4cj.impl.data

public class HolidayBundle_fr_CA <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fHolidays: Array<Holiday> = [SimpleHoliday(Calendar.JANUARY, 1, 0, "New Year's Day"), SimpleHoliday(Calendar.MAY, 19, 0, "Victoria Day"), SimpleHoliday(Calendar.JUNE, 24, 0, "National Day"), SimpleHoliday(Calendar.JULY, 1, 0, "Canada Day"), SimpleHoliday(Calendar.AUGUST, 1, Calendar.MONDAY, "Civic Holiday"), SimpleHoliday(Calendar.SEPTEMBER, 1, Calendar.MONDAY, "Labour Day"), SimpleHoliday(Calendar.OCTOBER, 8, Calendar.MONDAY, "Thanksgiving"), SimpleHoliday(Calendar.NOVEMBER, 11, 0, "Remembrance Day"), SimpleHoliday.CHRISTMAS, SimpleHoliday.BOXING_DAY, SimpleHoliday.NEW_YEARS_EVE, EasterHoliday.GOOD_FRIDAY, EasterHoliday.EASTER_SUNDAY, EasterHoliday.EASTER_MONDAY]

    private static let fContents: Array<Array<Object>> = [["holidays", fHolidays]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
