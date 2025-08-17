package icu4cj.impl.duration


public interface PeriodBuilderFactory {
    func setAvailableUnitRange(minUnit: TimeUnit, maxUnit: TimeUnit): PeriodBuilderFactory

    func setUnitIsAvailable(unit: TimeUnit, available: Bool): PeriodBuilderFactory

    func setMaxLimit(maxLimit: Float32): PeriodBuilderFactory

    func setMinLimit(minLimit: Float32): PeriodBuilderFactory

    func setAllowZero(allow: Bool): PeriodBuilderFactory

    func setWeeksAloneOnly(aloneOnly: Bool): PeriodBuilderFactory

    func setAllowMilliseconds(allow: Bool): PeriodBuilderFactory

    func setLocale(localeName: String): PeriodBuilderFactory

    func setTimeZone(timeZone: TimeZone): PeriodBuilderFactory

    func getFixedUnitBuilder(unit: TimeUnit): PeriodBuilder

    func getSingleUnitBuilder(): PeriodBuilder

    func getOneOrTwoUnitBuilder(): PeriodBuilder

    func getMultiUnitBuilder(unitCount: Int32): PeriodBuilder
}