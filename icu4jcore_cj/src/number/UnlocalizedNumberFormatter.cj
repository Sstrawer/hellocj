package icu4cj.number

public class UnlocalizedNumberFormatter <: NumberFormatterSettings<UnlocalizedNumberFormatter> {
    init() {
        super(null, KEY_THRESHOLD, Int64(3))
    }

    <-- Internal error: 
    <init>(NumberFormatterSettings<> parent, int key, Object value) {
        super(parent, key, value);
    } -->

    public func locale(locale: Locale): LocalizedNumberFormatter {
        return LocalizedNumberFormatter(this, KEY_LOCALE, ULocale.forLocale(locale))
    }

    public func locale(locale: ULocale): LocalizedNumberFormatter {
        return LocalizedNumberFormatter(this, KEY_LOCALE, locale)
    }

    public override func create(key: Int32, value: Object): UnlocalizedNumberFormatter {
        return UnlocalizedNumberFormatter(this, key, value)
    }
}
