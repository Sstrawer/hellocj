package icu4cj.impl.duration


class BasicDurationFormatter <: DurationFormatter {
    private var formatter: PeriodFormatter

    private var builder: PeriodBuilder

    private var fallback: DateFormatter

    private var fallbackLimit: Int64 = 0

    private var localeName: String

    private var timeZone: TimeZone = None

    public init(formatter: PeriodFormatter, builder: PeriodBuilder, fallback: DateFormatter, fallbackLimit: Int64) {
        this.formatter = formatter
        this.builder = builder
        this.fallback = fallback
        this.fallbackLimit = if (fallbackLimit < 0) { 0 } else { fallbackLimit }
    }

    protected init(formatter: PeriodFormatter, builder: PeriodBuilder, fallback: DateFormatter, fallbackLimit: Int64, localeName: String, timeZone: TimeZone) {
        this.formatter = formatter
        this.builder = builder
        this.fallback = fallback
        this.fallbackLimit = fallbackLimit
        this.localeName = localeName
        this.timeZone = timeZone
    }

    public override func formatDurationFromNowTo(targetDate: DateTime): String {
        let now = DateTime.now().toUnixTimeStamp().toMilliseconds()
        let duration = targetDate.getTime() - now
        return formatDurationFrom(duration, now)
    }

    public override func formatDurationFromNow(duration: Int64): String {
        return formatDurationFrom(duration, DateTime.now().toUnixTimeStamp().toMilliseconds())
    }

    public override func formatDurationFrom(duration: Int64, referenceDate: Int64): String {
        var s = doFallback(duration, referenceDate)
        if (s.isNone()) {
            let p = doBuild(duration, referenceDate)
            s = doFormat(p)
        }
        return s
    }

    public override func withLocale(locName: String): DurationFormatter {
        if (!locName.equals(localeName)) {
            let newFormatter = formatter.withLocale(locName)
            let newBuilder = builder.withLocale(locName)
            let newFallback: DateFormatter = if (fallback.isNone()) { None } else { fallback.withLocale(locName) }
            return BasicDurationFormatter(newFormatter, newBuilder, newFallback, fallbackLimit, locName, timeZone)
        }
        return this
    }

    public override func withTimeZone(tz: TimeZone): DurationFormatter {
        if (!refEq(tz, timeZone)) {
            let newBuilder = builder.withTimeZone(tz)
            let newFallback: DateFormatter = if (fallback.isNone()) { None } else { fallback.withTimeZone(tz) }
            return BasicDurationFormatter(formatter, newBuilder, newFallback, fallbackLimit, localeName, tz)
        }
        return this
    }

    protected func doFallback(duration: Int64, referenceDate: Int64): String {
        if (fallback.isSome() && fallbackLimit > 0 && abs(duration) >= fallbackLimit) {
            return fallback.format(referenceDate + duration)
        }
        return None
    }

    protected func doBuild(duration: Int64, referenceDate: Int64): Period {
        return builder.createWithReferenceDate(duration, referenceDate)
    }

    protected func doFormat(period: Period): String {
        if (!period.isSet()) {
            throw IllegalArgumentException("period is not set")
        }
        return formatter.format(period)
    }
}
