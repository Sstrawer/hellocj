package icu4cj.impl.duration


public interface DateFormatter {
    func format(date: DateTime): String

    func format(date: Int64): String

    func withLocale(localeName: String): DateFormatter

    func withTimeZone(tz: TimeZone): DateFormatter
}