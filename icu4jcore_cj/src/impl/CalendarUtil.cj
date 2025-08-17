package icu4cj.impl

public class CalendarUtil {

    private static let CALKEY = "calendar"

    static let DEFCAL = "gregorian"

    public static func getCalendarType(loc: ULocale): String {
        var calType = loc.getKeywordValue(CALKEY)
        if (calType.isSome()) {
            return calType.toLowerCase(Locale.ROOT)
        }
        let canonical = ULocale.createCanonical(loc.toString())
        calType = canonical.getKeywordValue(CALKEY)
        if (calType.isSome()) {
            return calType
        }
        let region = ULocale.getRegionForSupplementalData(canonical, true)
        return CalendarUtil_CalendarPreferences.INSTANCE.getCalendarTypeForRegion(region)
    }
}


class CalendarUtil_CalendarPreferences <: UResource_Sink {
    static let INSTANCE = CalendarUtil_CalendarPreferences()

    var prefs: Map<String, String> = TreeMap() as Map<String, String>

    init() {
        super()
        try {
            let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "supplementalData")
            rb.getAllItemsWithFallback("calendarPreferenceData", this)
        } catch (mre: MissingResourceException) { }
    }

    public func getCalendarTypeForRegion(region: String): String {
        let Type = prefs.get(region)
        return if (Type.isNone()) { CalendarUtil.DEFCAL } else { Type }
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let calendarPreferenceData = value.getTable()
        var i = 0
        while (calendarPreferenceData.getKeyAndValue(i, key, value)) {
            let types = value.getArray()
            if (types.getValue(0, value)) {
                let Type = value.getString()
                if (!Type.equals(CalendarUtil.DEFCAL)) {
                    prefs.put(key.toString(), Type)
                }
            }
            i++
        }
    }
}
