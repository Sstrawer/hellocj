package icu4cj.impl.data

public class HolidayBundle_es_MX <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fHolidays: Array<Holiday> = [SimpleHoliday.NEW_YEARS_DAY, SimpleHoliday(Calendar.FEBRUARY, 5, 0, "Constitution Day"), SimpleHoliday(Calendar.MARCH, 21, 0, "Benito Ju\u{00e1}rez Day"), SimpleHoliday.MAY_DAY, SimpleHoliday(Calendar.MAY, 5, 0, "Cinco de Mayo"), SimpleHoliday(Calendar.JUNE, 1, 0, "Navy Day"), SimpleHoliday(Calendar.SEPTEMBER, 16, 0, "Independence Day"), SimpleHoliday(Calendar.OCTOBER, 12, 0, "D\u{00ed}a de la Raza"), SimpleHoliday.ALL_SAINTS_DAY, SimpleHoliday(Calendar.NOVEMBER, 2, 0, "Day of the Dead"), SimpleHoliday(Calendar.NOVEMBER, 20, 0, "Revolution Day"), SimpleHoliday(Calendar.DECEMBER, 12, 0, "Flag Day"), SimpleHoliday.CHRISTMAS]

    private static let fContents: Array<Array<Object>> = [["holidays", fHolidays]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
