package icu4cj.impl.duration


public class BasicPeriodFormatterService <: PeriodFormatterService {
    private static var instance: BasicPeriodFormatterService

    private var ds: PeriodFormatterDataService

    public static func getInstance(): BasicPeriodFormatterService {
        if (instance.isNone()) {
            let ds = ResourceBasedPeriodFormatterDataService.getInstance()
            instance = BasicPeriodFormatterService(ds)
        }
        return instance
    }

    public init(ds: PeriodFormatterDataService) {
        this.ds = ds
    }

    public override func newDurationFormatterFactory(): DurationFormatterFactory {
        return BasicDurationFormatterFactory(this)
    }

    public override func newPeriodFormatterFactory(): PeriodFormatterFactory {
        return BasicPeriodFormatterFactory(ds)
    }

    public override func newPeriodBuilderFactory(): PeriodBuilderFactory {
        return BasicPeriodBuilderFactory(ds)
    }

    public override func getAvailableLocaleNames(): Collection<String> {
        return ds.getAvailableLocales()
    }
}
