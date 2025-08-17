package icu4cj.impl.duration

public interface PeriodFormatterFactory {
    public func setLocale(localeName: String): PeriodFormatterFactory

    public func setDisplayLimit(display: Bool): PeriodFormatterFactory

    public func setDisplayPastFuture(display: Bool): PeriodFormatterFactory

    public func setSeparatorVariant(variant: Int32): PeriodFormatterFactory

    public func setUnitVariant(variant: Int32): PeriodFormatterFactory

    public func setCountVariant(variant: Int32): PeriodFormatterFactory

    public func getFormatter(): PeriodFormatter
}