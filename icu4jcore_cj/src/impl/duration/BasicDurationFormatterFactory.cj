package icu4cj.impl.duration


class BasicDurationFormatterFactory <: DurationFormatterFactory {
    private var ps: BasicPeriodFormatterService

    private var formatter: PeriodFormatter

    private var builder: PeriodBuilder

    private var fallback: DateFormatter

    private var fallbackLimit: Int64 = 0

    private var localeName: String

    private var timeZone: TimeZone = None

    private var f: BasicDurationFormatter

    init(ps: BasicPeriodFormatterService) {
        this.ps = ps
        this.localeName = toString(Locale.getDefault())
        this.timeZone = TimeZone.getDefault()
    }

    public override func setPeriodFormatter(formatter: PeriodFormatter): DurationFormatterFactory {
        if (!refEq(formatter, this.formatter)) {
            this.formatter = formatter
            reset()
        }
        return this
    }

    public override func setPeriodBuilder(builder: PeriodBuilder): DurationFormatterFactory {
        if (!refEq(builder, this.builder)) {
            this.builder = builder
            reset()
        }
        return this
    }

    public override func setFallback(fallback: DateFormatter): DurationFormatterFactory {
        let doReset = if (fallback.isNone()) { this.fallback.isSome() } else { !refEq(fallback, this.fallback) }
        if (doReset) {
            this.fallback = fallback
            reset()
        }
        return this
    }

    public override func setFallbackLimit(fallbackLimit: Int64): DurationFormatterFactory {
        var tempfallbackLimit = fallbackLimit
        if (tempfallbackLimit < 0) {
            tempfallbackLimit = 0
        }
        if (tempfallbackLimit != this.fallbackLimit) {
            this.fallbackLimit = tempfallbackLimit
            reset()
        }
        return this
    }

    public override func setLocale(localeName: String): DurationFormatterFactory {
        if (!localeName.equals(this.localeName)) {
            this.localeName = localeName
            if (builder.isSome()) {
                builder = builder.withLocale(localeName)
            }
            if (formatter.isSome()) {
                formatter = formatter.withLocale(localeName)
            }
            reset()
        }
        return this
    }

    public override func setTimeZone(timeZone: TimeZone): DurationFormatterFactory {
        if (!refEq(timeZone, this.timeZone)) {
            this.timeZone = timeZone
            if (builder.isSome()) {
                builder = builder.withTimeZone(timeZone)
            }
            reset()
        }
        return this
    }

    public override func getFormatter(): DurationFormatter {
        if (f.isNone()) {
            if (fallback.isSome()) {
                fallback = fallback.withLocale(localeName).withTimeZone(timeZone)
            }
            formatter = getPeriodFormatter()
            builder = getPeriodBuilder()
            f = createFormatter()
        }
        return f
    }

    public func getPeriodFormatter(): PeriodFormatter {
        if (formatter.isNone()) {
            formatter = ps.newPeriodFormatterFactory().setLocale(localeName).getFormatter()
        }
        return formatter
    }

    public func getPeriodBuilder(): PeriodBuilder {
        if (builder.isNone()) {
            builder = ps.newPeriodBuilderFactory().setLocale(localeName).setTimeZone(timeZone).getSingleUnitBuilder()
        }
        return builder
    }

    public func getFallback(): DateFormatter {
        return fallback
    }

    public func getFallbackLimit(): Int64 {
        return if (fallback.isNone()) { 0 } else { fallbackLimit }
    }

    public func getLocaleName(): String {
        return localeName
    }

    public func getTimeZone(): TimeZone {
        return timeZone
    }

    protected func createFormatter(): BasicDurationFormatter {
        return BasicDurationFormatter(formatter, builder, fallback, fallbackLimit, localeName, timeZone)
    }

    protected func reset(): Unit {
        f = None
    }
}
