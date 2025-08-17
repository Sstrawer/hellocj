package icu4cj.impl.duration

public interface DurationFormatterFactory {
    public func setPeriodFormatter(formatter: PeriodFormatter): DurationFormatterFactory

    public func setPeriodBuilder(builder: PeriodBuilder): DurationFormatterFactory

    public func setFallback(fallback: DateFormatter): DurationFormatterFactory

    public func setFallbackLimit(fallbackLimit: Int64): DurationFormatterFactory

    public func setLocale(localeName: String): DurationFormatterFactory

    public func setTimeZone(timeZone: TimeZone): DurationFormatterFactory

    public func getFormatter(): DurationFormatter
}