package icu4cj.impl.number


public class CustomSymbolCurrency <: Currency {
    private static let serialVersionUID = 2497493016770137670

    private var symbol1: String

    private var symbol2: String

    public static func resolve(currency: Currency, locale: ULocale, symbols: DecimalFormatSymbols): Currency {
        var tempcurrency = currency
        if (tempcurrency.isNone()) {
            tempcurrency = symbols.getCurrency()
        }
        if (tempcurrency.isNone()) {
            return Currency.getInstance("XXX")
        }
        if (!tempcurrency.equals(symbols.getCurrency())) {
            return tempcurrency
        }
        let currency1Sym = symbols.getCurrencySymbol()
        let currency2Sym = symbols.getInternationalCurrencySymbol()
        let currency1 = tempcurrency.getName(symbols.getULocale(), Currency.SYMBOL_NAME, None)
        let currency2 = tempcurrency.getCurrencyCode()
        if (!currency1.equals(currency1Sym) || !currency2.equals(currency2Sym)) {
            return CustomSymbolCurrency(currency2, currency1Sym, currency2Sym)
        }
        return tempcurrency
    }

    public init(isoCode: String, currency1Sym: String, currency2Sym: String) {
        super(isoCode)
        this.symbol1 = currency1Sym
        this.symbol2 = currency2Sym
    }

    public override func getName(locale: ULocale, nameStyle: Int32, isChoiceFormat: Array<Bool>): String {
        if (nameStyle == SYMBOL_NAME) {
            if (isChoiceFormat.isSome()) {
                isChoiceFormat[0] = false
            }
            return symbol1
        }
        return super.getName(locale, nameStyle, isChoiceFormat)
    }

    public override func getName(locale: ULocale, nameStyle: Int32, pluralCount: String, isChoiceFormat: Array<Bool>): String {
        return super.getName(locale, nameStyle, pluralCount, isChoiceFormat)
    }

    public override func getCurrencyCode(): String {
        return symbol2
    }

    public override func hashCode(): Int64 {
        return Int64(Int32(super.hashCode()) ^ Int32(symbol1.hashCode()) ^ Int32(symbol2.hashCode()))
    }

    public override func equals(other: Object): Bool {
        return super.equals(other) && other.symbol1.equals(symbol1) && other.symbol2.equals(symbol2)
    }
}
