package icu4cj.util

public class SimpleDateRule <: DateRule {
    public init(month: Int32, dayOfMonth: Int32) {
        this.month = month
        this.dayOfMonth = dayOfMonth
        this.dayOfWeek = 0
    }

    init(month: Int32, dayOfMonth: Int32, cal: Calendar) {
        this.month = month
        this.dayOfMonth = dayOfMonth
        this.dayOfWeek = 0
        this.calendar = cal
    }

    public init(month: Int32, dayOfMonth: Int32, dayOfWeek: Int32, after: Bool) {
        this.month = month
        this.dayOfMonth = dayOfMonth
        this.dayOfWeek = if (after) { dayOfWeek } else { -dayOfWeek }
    }

    public override func firstAfter(start: DateTime): DateTime {
        return doFirstBetween(start, None)
    }

    public override func firstBetween(start: DateTime, end: DateTime): DateTime {
        return doFirstBetween(start, end)
    }

    public override func isOn(date: DateTime): Bool {
        let c = calendar
        synchronized (getMonitorByObject(c)) {
            c.setTime(date)
            let dayOfYear = c.get(Calendar.DAY_OF_YEAR)
            c.setTime(computeInYear(c.get(Calendar.YEAR), c))
            return c.get(Calendar.DAY_OF_YEAR) == dayOfYear
        }
    }

    public override func isBetween(start: DateTime, end: DateTime): Bool {
        return firstBetween(start, end).isSome()
    }

    private func doFirstBetween(start: DateTime, end: DateTime): DateTime {
        let c = calendar
        synchronized (getMonitorByObject(c)) {
            c.setTime(start)
            var year = c.get(Calendar.YEAR)
            let mon = c.get(Calendar.MONTH)
            if (mon > this.month) {
                year++
            }
            var result = computeInYear(year, c)
            if (mon == this.month && result.before(start)) {
                result = computeInYear(year + 1, c)
            }
            if (end.isSome() && result.after(end)) {
                return None
            }
            return result
        }
    }

    private func computeInYear(year: Int32, c: Calendar): DateTime {
        synchronized (getMonitorByObject(c)) {
            c.clear()
            c.set(Calendar.ERA, c.getMaximum(Calendar.ERA))
            c.set(Calendar.YEAR, year)
            c.set(Calendar.MONTH, month)
            c.set(Calendar.DATE, dayOfMonth)
            if (dayOfWeek != 0) {
                c.setTime(c.getTime())
                let weekday = c.get(Calendar.DAY_OF_WEEK)
                var delta = 0
                if (dayOfWeek > 0) {
                    delta = (dayOfWeek - weekday + 7) % 7
                } else {
                    delta = -((dayOfWeek + weekday + 7) % 7)
                }
                c.add(Calendar.DATE, delta)
            }
            return c.getTime()
        }
    }

    private var calendar: Calendar = GregorianCalendar()

    private var month: Int32 = 0

    private var dayOfMonth: Int32 = 0

    private var dayOfWeek: Int32 = 0
}
