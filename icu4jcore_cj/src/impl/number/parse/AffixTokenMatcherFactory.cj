package icu4cj.impl.number.parse

public class AffixTokenMatcherFactory {

    public var currency: Currency

    public var symbols: DecimalFormatSymbols

    public var ignorables: IgnorablesMatcher

    public var locale: ULocale

    public var parseFlags: Int32 = 0

    public func minusSign(): MinusSignMatcher {
        return MinusSignMatcher.getInstance(symbols, true)
    }

    public func plusSign(): PlusSignMatcher {
        return PlusSignMatcher.getInstance(symbols, true)
    }

    public func percent(): PercentMatcher {
        return PercentMatcher.getInstance(symbols)
    }

    public func permille(): PermilleMatcher {
        return PermilleMatcher.getInstance(symbols)
    }

    public func currencyMethod(): CombinedCurrencyMatcher {
        return CombinedCurrencyMatcher.getInstance(currency, symbols, parseFlags)
    }

    public func ignorablesMethod(): IgnorablesMatcher {
        return ignorables
    }
}
