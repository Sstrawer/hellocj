package icu4cj.impl.duration

public interface PeriodFormatterService {
    func newDurationFormatterFactory(): DurationFormatterFactory

    func newPeriodFormatterFactory(): PeriodFormatterFactory

    func newPeriodBuilderFactory(): PeriodBuilderFactory

    func getAvailableLocaleNames(): Collection<String>
}