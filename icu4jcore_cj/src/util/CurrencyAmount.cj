package icu4cj.util


public class CurrencyAmount <: Measure {
    public init(number: Number, currency: Currency) {
        super(number, currency)
    }

    public init(number: Float64, currency: Currency) {
        super(number, currency)
    }

    public init(number: Number, currency: Currency) {
        this(number, Currency.fromJavaCurrency(currency))
    }

    public init(number: Float64, currency: Currency) {
        this(number, Currency.fromJavaCurrency(currency))
    }

    public func getCurrency(): Currency {
        return getUnit()
    }
}
