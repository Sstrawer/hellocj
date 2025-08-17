package icu4cj.util

public class EasterHoliday <: Holiday {
    public init(name: String) {
        super(name, EasterRule(0, false))
    }

    public init(daysAfter: Int32, name: String) {
        super(name, EasterRule(daysAfter, false))
    }

    public init(daysAfter: Int32, orthodox: Bool, name: String) {
        super(name, EasterRule(daysAfter, orthodox))
    }

    public static let SHROVE_TUESDAY = EasterHoliday(-48, "Shrove Tuesday")

    public static let ASH_WEDNESDAY = EasterHoliday(-47, "Ash Wednesday")

    public static let PALM_SUNDAY = EasterHoliday(-7, "Palm Sunday")

    public static let MAUNDY_THURSDAY = EasterHoliday(-3, "Maundy Thursday")

    public static let GOOD_FRIDAY = EasterHoliday(-2, "Good Friday")

    public static let EASTER_SUNDAY = EasterHoliday(0, "Easter Sunday")

    public static let EASTER_MONDAY = EasterHoliday(1, "Easter Monday")

    public static let ASCENSION = EasterHoliday(39, "Ascension")

    public static let PENTECOST = EasterHoliday(49, "Pentecost")

    public static let WHIT_SUNDAY = EasterHoliday(49, "Whit Sunday")

    public static let WHIT_MONDAY = EasterHoliday(50, "Whit Monday")

    public static let CORPUS_CHRISTI = EasterHoliday(60, "Corpus Christi")
}


class EasterRule <: DateRule {
    public init(daysAfterEaster: Int32, isOrthodox: Bool) {
        this.daysAfterEaster = daysAfterEaster
        if (isOrthodox) {
            calendar.setGregorianChange(Date(Int64.Max))
        }
    }

    public override func firstAfter(start: DateTime): DateTime {
        return doFirstBetween(start, None)
    }

    public override func firstBetween(start: DateTime, end: DateTime): DateTime {
        return doFirstBetween(start, end)
    }

    public override func isOn(date: DateTime): Bool {
        synchronized (getMonitorByObject(calendar)) {
            calendar.setTime(date)
            let dayOfYear = calendar.get(Calendar.DAY_OF_YEAR)
            calendar.setTime(computeInYear(calendar.getTime(), calendar))
            return calendar.get(Calendar.DAY_OF_YEAR) == dayOfYear
        }
    }

    public override func isBetween(start: DateTime, end: DateTime): Bool {
        return firstBetween(start, end).isSome()
    }

    private func doFirstBetween(start: DateTime, end: DateTime): DateTime {
        synchronized (getMonitorByObject(calendar)) {
            var result = computeInYear(start, calendar)
            if (result.before(start)) {
                calendar.setTime(start)
                calendar.get(Calendar.YEAR)
                calendar.add(Calendar.YEAR, 1)
                result = computeInYear(calendar.getTime(), calendar)
            }
            if (end.isSome() && !result.before(end)) {
                return None
            }
            return result
        }
    }

    private func computeInYear(date: DateTime, cal: GregorianCalendar): DateTime {
        var tempcal = cal
        if (tempcal.isNone()) {
            tempcal = calendar
        }
        synchronized (getMonitorByObject(tempcal)) {
            tempcal.setTime(date)
            let year = tempcal.get(Calendar.YEAR)
            let g = year % 19
            var i = 0
            var j = 0
            if (tempcal.getTime().after(tempcal.getGregorianChange())) {
                let c = year / 100
                let h = (c - c / 4 - (8 * c + 13) / 25 + 19 * g + 15) % 30
                i = h - (h / 28) * (1 - (h / 28) * (29 / (h + 1)) * ((21 - g) / 11))
                j = (year + year / 4 + i + 2 - c + c / 4) % 7
            } else {
                i = (19 * g + 15) % 30
                j = (year + year / 4 + i) % 7
            }
            let l = i - j
            let m = 3 + (l + 40) / 44
            let d = l + 28 - 31 * (m / 4)
            tempcal.clear()
            tempcal.set(Calendar.ERA, GregorianCalendar.AD)
            tempcal.set(Calendar.YEAR, year)
            tempcal.set(Calendar.MONTH, m - 1)
            tempcal.set(Calendar.DATE, d)
            tempcal.getTime()
            tempcal.add(Calendar.DATE, daysAfterEaster)
            return tempcal.getTime()
        }
    }

    private var daysAfterEaster: Int32 = 0

    private var calendar: GregorianCalendar = GregorianCalendar()
}
