package icu4cj.impl.data

public class HolidayBundle_el_GR <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fHolidays: Array<Holiday> = [SimpleHoliday.NEW_YEARS_DAY, SimpleHoliday.EPIPHANY, SimpleHoliday(Calendar.MARCH, 25, 0, "Independence Day"), SimpleHoliday.MAY_DAY, SimpleHoliday.ASSUMPTION, SimpleHoliday(Calendar.OCTOBER, 28, 0, "Ochi Day"), SimpleHoliday.CHRISTMAS, SimpleHoliday.BOXING_DAY, EasterHoliday(-2, true, "Good Friday"), EasterHoliday(0, true, "Easter Sunday"), EasterHoliday(1, true, "Easter Monday"), EasterHoliday(50, true, "Whit Monday")]

    private static let fContents: Array<Array<Object>> = [["holidays", fHolidays]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
