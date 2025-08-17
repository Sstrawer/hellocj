package icu4cj.number

public class UnlocalizedNumberRangeFormatter <: NumberRangeFormatterSettings<UnlocalizedNumberRangeFormatter> {
    init() {
        super(null, KEY_MACROS, null)
    }

    <-- Internal error: 
    <init>(NumberRangeFormatterSettings<> parent, int key, Object value) {
        super(parent, key, value);
    } -->

    public func locale(locale: Locale): LocalizedNumberRangeFormatter {
        return LocalizedNumberRangeFormatter(this, KEY_LOCALE, ULocale.forLocale(locale))
    }

    public func locale(locale: ULocale): LocalizedNumberRangeFormatter {
        return LocalizedNumberRangeFormatter(this, KEY_LOCALE, locale)
    }

    public override func create(key: Int32, value: Object): UnlocalizedNumberRangeFormatter {
        return UnlocalizedNumberRangeFormatter(this, key, value)
    }
}
