package icu4cj.util

public class CopticCalendar <: CECalendar {
    private static let serialVersionUID = 5903818751846742911

    public static let TOUT = 0

    public static let BABA = 1

    public static let HATOR = 2

    public static let KIAHK = 3

    public static let TOBA = 4

    public static let AMSHIR = 5

    public static let BARAMHAT = 6

    public static let BARAMOUDA = 7

    public static let BASHANS = 8

    public static let PAONA = 9

    public static let EPEP = 10

    public static let MESRA = 11

    public static let NASIE = 12

    private static let JD_EPOCH_OFFSET = 1824665

    private static let BCE = 0

    private static let CE = 1

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

    public init(year: Int32, month: Int32, date: Int32) {
        super(year, month, date)
    }

    public init(date: DateTime) {
        super(date)
    }

    public init(year: Int32, month: Int32, date: Int32, hour: Int32, minute: Int32, second: Int32) {
        super(year, month, date, hour, minute, second)
    }

    public override func getType(): String {
        return "coptic"
    }

    
    override protected func isEra0CountingBackward(): Bool {
        return true
    }

    
    override protected func handleGetExtendedYear(): Int32 {
        let eyear: Int32
        if (newerField(EXTENDED_YEAR, YEAR) == EXTENDED_YEAR) {
            eyear = internalGet(EXTENDED_YEAR, 1)
        } else {
            let era = internalGet(ERA, CE)
            if (era == BCE) {
                eyear = 1 - internalGet(YEAR, 1)
            } else {
                eyear = internalGet(YEAR, 1)
            }
        }
        return eyear
    }

    
    override protected func handleComputeFields(julianDay: Int32): Unit {
        let era: Int32
        let year: Int32
        let fields = Array<Int32>(3) { _ => 0 }
        jdToCE(julianDay, getJDEpochOffset(), fields)
        if (fields[0] <= 0) {
            era = BCE
            year = 1 - fields[0]
        } else {
            era = CE
            year = fields[0]
        }
        internalSet(EXTENDED_YEAR, fields[0])
        internalSet(ERA, era)
        internalSet(YEAR, year)
        internalSet(MONTH, fields[1])
        internalSet(ORDINAL_MONTH, fields[1])
        internalSet(DAY_OF_MONTH, fields[2])
        internalSet(DAY_OF_YEAR, (30 * fields[1]) + fields[2])
    }

    
    override protected func getJDEpochOffset(): Int32 {
        return JD_EPOCH_OFFSET
    }

    public static func copticToJD(year: Int64, month: Int32, date: Int32): Int32 {
        return ceToJD(year, month, date, JD_EPOCH_OFFSET)
    }
}
