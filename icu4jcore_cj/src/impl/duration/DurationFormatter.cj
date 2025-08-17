package icu4cj.impl.duration

public interface DurationFormatter {
    func formatDurationFromNowTo(targetDate: DateTime): String

    func formatDurationFromNow(duration: Int64): String

    func formatDurationFrom(duration: Int64, referenceDate: Int64): String

    func withLocale(localeName: String): DurationFormatter

    func withTimeZone(tz: TimeZone): DurationFormatter
}