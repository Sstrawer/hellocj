package icu4cj.impl.data

public class HolidayBundle_en_GB <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fHolidays: Array<Holiday> = [SimpleHoliday.NEW_YEARS_DAY, SimpleHoliday.MAY_DAY, SimpleHoliday(Calendar.MAY, 31, -Calendar.MONDAY, "Spring Holiday"), SimpleHoliday(Calendar.AUGUST, 31, -Calendar.MONDAY, "Summer Bank Holiday"), SimpleHoliday.CHRISTMAS, SimpleHoliday.BOXING_DAY, SimpleHoliday(Calendar.DECEMBER, 31, -Calendar.MONDAY, "Christmas Holiday"), EasterHoliday.GOOD_FRIDAY, EasterHoliday.EASTER_SUNDAY, EasterHoliday.EASTER_MONDAY]

    private static let fContents: Array<Array<Object>> = [["holidays", fHolidays], ["Labor Day", "Labour Day"]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
