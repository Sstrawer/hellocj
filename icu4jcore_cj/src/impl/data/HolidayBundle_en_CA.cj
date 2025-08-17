package icu4cj.impl.data

public class HolidayBundle_en_CA <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fHolidays: Array<Holiday> = [SimpleHoliday.NEW_YEARS_DAY, SimpleHoliday(Calendar.MAY, 19, 0, "Victoria Day"), SimpleHoliday(Calendar.JULY, 1, 0, "Canada Day"), SimpleHoliday(Calendar.AUGUST, 1, Calendar.MONDAY, "Civic Holiday"), SimpleHoliday(Calendar.SEPTEMBER, 1, Calendar.MONDAY, "Labor Day"), SimpleHoliday(Calendar.OCTOBER, 8, Calendar.MONDAY, "Thanksgiving"), SimpleHoliday(Calendar.NOVEMBER, 11, 0, "Remembrance Day"), SimpleHoliday.CHRISTMAS, SimpleHoliday.BOXING_DAY, SimpleHoliday.NEW_YEARS_EVE]

    private static let fContents: Array<Array<Object>> = [["holidays", fHolidays], ["Labor Day", "Labour Day"]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
