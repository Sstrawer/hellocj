package icu4cj.impl


public class TimeZoneNamesFactoryImpl <: TimeZoneNames_Factory {
    public init() {
        super()
    }

    public override func getTimeZoneNames(locale: ULocale): TimeZoneNames {
        return TimeZoneNamesImpl(locale)
    }
}
