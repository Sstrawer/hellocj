package icu4cj.impl.duration

public interface PeriodBuilder {
    func create(duration: Int64): Period

    func createWithReferenceDate(duration: Int64, referenceDate: Int64): Period

    func withLocale(localeName: String): PeriodBuilder

    func withTimeZone(tz: TimeZone): PeriodBuilder
}