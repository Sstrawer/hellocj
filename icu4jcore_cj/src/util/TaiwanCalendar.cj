package icu4cj.util

public class TaiwanCalendar <: GregorianCalendar {
    private static let serialVersionUID = 2583005278132380631

    public static let BEFORE_MINGUO = 0

    public static let MINGUO = 1

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

    private static let Taiwan_ERA_START = 1911

    private static let GREGORIAN_EPOCH = 1970

    override protected func handleGetExtendedYear(): Int32 {
        var year = GREGORIAN_EPOCH
        if (newerField(EXTENDED_YEAR, YEAR) == EXTENDED_YEAR && newerField(EXTENDED_YEAR, ERA) == EXTENDED_YEAR) {
            year = internalGet(EXTENDED_YEAR, GREGORIAN_EPOCH)
        } else {
            let era = internalGet(ERA, MINGUO)
            if (era == MINGUO) {
                year = internalGet(YEAR, 1) + Taiwan_ERA_START
            } else {
                year = 1 - internalGet(YEAR, 1) + Taiwan_ERA_START
            }
        }
        return year
    }

    override protected func handleComputeFields(julianDay: Int32): Unit {
        super.handleComputeFields(julianDay)
        let y = internalGet(EXTENDED_YEAR) - Taiwan_ERA_START
        if (y > 0) {
            internalSet(ERA, MINGUO)
            internalSet(YEAR, y)
        } else {
            internalSet(ERA, BEFORE_MINGUO)
            internalSet(YEAR, 1 - y)
        }
    }

    override protected func handleGetLimit(field: Int32, limitType: Int32): Int32 {
        if (field == ERA) {
            if (limitType == MINIMUM || limitType == GREATEST_MINIMUM) {
                return BEFORE_MINGUO
            } else {
                return MINGUO
            }
        }
        return super.handleGetLimit(field, limitType)
    }

    public override func getType(): String {
        return "roc"
    }
}
