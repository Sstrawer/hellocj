package icu4cj.impl.duration

public interface PeriodFormatter {
    func format(period: Period): String

    func withLocale(localeName: String): PeriodFormatter
}