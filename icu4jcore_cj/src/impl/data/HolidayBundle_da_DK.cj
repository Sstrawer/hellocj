package icu4cj.impl.data

public class HolidayBundle_da_DK <: ListResourceBundle & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init() {
        ListResourceBundle()
    }

    private static let fHolidays: Array<Holiday> = [SimpleHoliday.NEW_YEARS_DAY, SimpleHoliday(Calendar.APRIL, 30, -Calendar.FRIDAY, "General Prayer Day"), SimpleHoliday(Calendar.JUNE, 5, "Constitution Day"), SimpleHoliday.CHRISTMAS_EVE, SimpleHoliday.CHRISTMAS, SimpleHoliday.BOXING_DAY, SimpleHoliday.NEW_YEARS_EVE, EasterHoliday.MAUNDY_THURSDAY, EasterHoliday.GOOD_FRIDAY, EasterHoliday.EASTER_SUNDAY, EasterHoliday.EASTER_MONDAY, EasterHoliday.ASCENSION, EasterHoliday.WHIT_MONDAY]

    private static let fContents: Array<Array<Object>> = [["holidays", fHolidays]]

    public override func getContents(): Array<Array<Object>> {
        synchronized (GeneratedLockObject) {
            return fContents
        }
    }
}
