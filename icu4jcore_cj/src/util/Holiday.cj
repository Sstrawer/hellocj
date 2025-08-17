package icu4cj.util

public abstract class Holiday <: DateRule {
    public static func getHolidays(): Array<Holiday> {
        return getHolidays(ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public static func getHolidays(locale: Locale): Array<Holiday> {
        return getHolidays(ULocale.forLocale(locale))
    }

    public static func getHolidays(locale: ULocale): Array<Holiday> {
        var result = noHolidays
        try {
            let bundle = UResourceBundle.getBundleInstance("com.ibm.icu.impl.data.HolidayBundle", locale)
            result = bundle.getObject("holidays")
        } catch (e: MissingResourceException) { }
        return result
    }

    public override func firstAfter(start: DateTime): DateTime {
        return rule.firstAfter(start)
    }

    public override func firstBetween(start: DateTime, end: DateTime): DateTime {
        return rule.firstBetween(start, end)
    }

    public override func isOn(date: DateTime): Bool {
        return rule.isOn(date)
    }

    public override func isBetween(start: DateTime, end: DateTime): Bool {
        return rule.isBetween(start, end)
    }

    protected init(name: String, rule: DateRule) {
        this.name = name
        this.rule = rule
    }

    public func getDisplayName(): String {
        return getDisplayName(ULocale.getDefault(ULocale_Category.DISPLAY))
    }

    public func getDisplayName(locale: Locale): String {
        return getDisplayName(ULocale.forLocale(locale))
    }

    public func getDisplayName(locale: ULocale): String {
        var dispName = name
        try {
            let bundle = UResourceBundle.getBundleInstance("com.ibm.icu.impl.data.HolidayBundle", locale)
            dispName = bundle.getString(name)
        } catch (e: MissingResourceException) { }
        return dispName
    }

    public func getRule(): DateRule {
        return rule
    }

    public func setRule(rule: DateRule): Unit {
        this.rule = rule
    }

    private var name: String

    private var rule: DateRule

    private static var noHolidays: Array<Holiday> = [0]
}
