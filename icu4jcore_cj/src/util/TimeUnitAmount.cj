package icu4cj.util

public class TimeUnitAmount <: Measure {
    public init(number: Number, unit: TimeUnit) {
        super(number, unit)
    }

    public init(number: Float64, unit: TimeUnit) {
        super(number, unit)
    }

    public func getTimeUnit(): TimeUnit {
        return getUnit()
    }
}
