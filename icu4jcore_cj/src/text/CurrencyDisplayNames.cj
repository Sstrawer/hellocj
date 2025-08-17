package icu4cj.text

public abstract class CurrencyDisplayNames {
    public static func getInstance(locale: ULocale): CurrencyDisplayNames {
        return CurrencyData.provider.getInstance(locale, true)
    }

    public static func getInstance(locale: Locale): CurrencyDisplayNames {
        return getInstance(locale, false)
    }

    public static func getInstance(locale: ULocale, noSubstitute: Bool): CurrencyDisplayNames {
        return CurrencyData.provider.getInstance(locale, !noSubstitute)
    }

    public static func getInstance(locale: Locale, noSubstitute: Bool): CurrencyDisplayNames {
        return getInstance(ULocale.forLocale(locale), noSubstitute)
    }

    
    public static func hasData(): Bool {
        return CurrencyData.provider.hasData()
    }

    public func getULocale(): ULocale

    public func getSymbol(isoCode: String): String

    public func getNarrowSymbol(isoCode: String): String

    public func getFormalSymbol(isoCode: String): String

    public func getVariantSymbol(isoCode: String): String

    public func getName(isoCode: String): String

    public func getPluralName(isoCode: String, pluralKey: String): String

    public func symbolMap(): Map<String, String>

    public func nameMap(): Map<String, String>

    
}
