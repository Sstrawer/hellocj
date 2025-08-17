package icu4cj.impl.data

public class HolidayBundle_de_DE <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fHolidays: Array<Holiday> = [SimpleHoliday.NEW_YEARS_DAY, SimpleHoliday.MAY_DAY, SimpleHoliday(Calendar.JUNE, 15, Calendar.WEDNESDAY, "Memorial Day"), SimpleHoliday(Calendar.OCTOBER, 3, 0, "Unity Day"), SimpleHoliday.ALL_SAINTS_DAY, SimpleHoliday(Calendar.NOVEMBER, 18, 0, "Day of Prayer and Repentance"), SimpleHoliday.CHRISTMAS, SimpleHoliday.BOXING_DAY, EasterHoliday.GOOD_FRIDAY, EasterHoliday.EASTER_SUNDAY, EasterHoliday.EASTER_MONDAY, EasterHoliday.ASCENSION, EasterHoliday.WHIT_SUNDAY, EasterHoliday.WHIT_MONDAY]

    private static let fContents: Array<Array<Object>> = [["holidays", fHolidays]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
