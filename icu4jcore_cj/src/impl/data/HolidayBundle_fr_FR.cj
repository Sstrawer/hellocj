package icu4cj.impl.data

public class HolidayBundle_fr_FR <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fHolidays: Array<Holiday> = [SimpleHoliday.NEW_YEARS_DAY, SimpleHoliday(Calendar.MAY, 1, 0, "Labor Day"), SimpleHoliday(Calendar.MAY, 8, 0, "Victory Day"), SimpleHoliday(Calendar.JULY, 14, 0, "Bastille Day"), SimpleHoliday.ASSUMPTION, SimpleHoliday.ALL_SAINTS_DAY, SimpleHoliday(Calendar.NOVEMBER, 11, 0, "Armistice Day"), SimpleHoliday.CHRISTMAS, EasterHoliday.EASTER_SUNDAY, EasterHoliday.EASTER_MONDAY, EasterHoliday.ASCENSION, EasterHoliday.WHIT_SUNDAY, EasterHoliday.WHIT_MONDAY]

    private static let fContents: Array<Array<Object>> = [["holidays", fHolidays]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
