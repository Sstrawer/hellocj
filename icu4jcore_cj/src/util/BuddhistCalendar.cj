package icu4cj.util

public class BuddhistCalendar <: GregorianCalendar {
    private static let serialVersionUID = 2583005278132380631

    public static let BE = 0

    public init() {
        super()
    }

    public init(zone: TimeZone) {
        super(zone)
    }

    public init(aLocale: Locale) {
        super(aLocale)
    }

    public init(locale: ULocale) {
        super(locale)
    }

    public init(zone: TimeZone, aLocale: Locale) {
        super(zone, aLocale)
    }

    public init(zone: TimeZone, locale: ULocale) {
        super(zone, locale)
    }

    public init(date: DateTime) {
        this()
        setTime(date)
    }

    public init(year: Int32, month: Int32, date: Int32) {
        super(year, month, date)
    }

    public init(year: Int32, month: Int32, date: Int32, hour: Int32, minute: Int32, second: Int32) {
        super(year, month, date, hour, minute, second)
    }

    private static let BUDDHIST_ERA_START = -543

    private static let GREGORIAN_EPOCH = 1970

    override protected func handleGetExtendedYear(): Int32 {
        let year: Int32
        if (newerField(EXTENDED_YEAR, YEAR) == EXTENDED_YEAR) {
            year = internalGet(EXTENDED_YEAR, GREGORIAN_EPOCH)
        } else {
            year = internalGet(YEAR, GREGORIAN_EPOCH - BUDDHIST_ERA_START) + BUDDHIST_ERA_START
        }
        return year
    }

    override protected func handleComputeMonthStart(eyear: Int32, month: Int32, useMonth: Bool): Int32 {
        return super.handleComputeMonthStart(eyear, month, useMonth)
    }

    override protected func handleComputeFields(julianDay: Int32): Unit {
        super.handleComputeFields(julianDay)
        let y = internalGet(EXTENDED_YEAR) - BUDDHIST_ERA_START
        internalSet(ERA, 0)
        internalSet(YEAR, y)
    }

    override protected func handleGetLimit(field: Int32, limitType: Int32): Int32 {
        if (field == ERA) {
            return BE
        }
        return super.handleGetLimit(field, limitType)
    }

    public override func getType(): String {
        return "buddhist"
    }

    
    override protected func isEra0CountingBackward(): Bool {
        return false
    }
}
