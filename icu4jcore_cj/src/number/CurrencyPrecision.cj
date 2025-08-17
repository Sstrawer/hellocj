package icu4cj.number

public abstract class CurrencyPrecision <: Precision {
    init() {
        super()
    }

    public func withCurrency(currency: Currency): Precision {
        if (currency.isSome()) {
            let retval = constructFromCurrency(this, currency)
            retval.trailingZeroDisplay = trailingZeroDisplay
            return retval
        } else {
            throw IllegalArgumentException("Currency must not be null")
        }
    }
}
