package icu4cj.impl.duration.impl

public abstract class PeriodFormatterDataService {

    public func get(localeName: String): PeriodFormatterData

    public func getAvailableLocales(): Collection<String>
}
