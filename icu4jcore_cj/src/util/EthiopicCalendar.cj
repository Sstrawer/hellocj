package icu4cj.util

public class EthiopicCalendar <: CECalendar {
    private static let serialVersionUID = -2438495771339315608

    public static let MESKEREM = 0

    public static let TEKEMT = 1

    public static let HEDAR = 2

    public static let TAHSAS = 3

    public static let TER = 4

    public static let YEKATIT = 5

    public static let MEGABIT = 6

    public static let MIAZIA = 7

    public static let GENBOT = 8

    public static let SENE = 9

    public static let HAMLE = 10

    public static let NEHASSE = 11

    public static let PAGUMEN = 12

    private static let JD_EPOCH_OFFSET_AMETE_MIHRET = 1723856

    private static let AMETE_MIHRET_DELTA = 5500

    private static let AMETE_ALEM = 0

    private static let AMETE_MIHRET = 1

    private static let AMETE_MIHRET_ERA = 0

    private static let AMETE_ALEM_ERA = 1

    private var eraType = AMETE_MIHRET_ERA

    public init() {
        this(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public init(zone: TimeZone) {
        this(zone, ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public init(aLocale: Locale) {
        this(TimeZone.forLocaleOrDefault(aLocale), aLocale)
    }

    public init(locale: ULocale) {
        this(TimeZone.forULocaleOrDefault(locale), locale)
    }

    public init(zone: TimeZone, aLocale: Locale) {
        this(zone, ULocale.forLocale(aLocale))
    }

    public init(zone: TimeZone, locale: ULocale) {
        super(zone, locale)
        setCalcTypeForLocale(locale)
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
        if (isAmeteAlemEra()) {
            return "ethiopic-amete-alem"
        }
        return "ethiopic"
    }

    public func setAmeteAlemEra(onOff: Bool): Unit {
        eraType = if (onOff) { AMETE_ALEM_ERA } else { AMETE_MIHRET_ERA }
    }

    public func isAmeteAlemEra(): Bool {
        return (eraType == AMETE_ALEM_ERA)
    }

    
    override protected func handleGetExtendedYear(): Int32 {
        let eyear: Int32
        if (newerField(EXTENDED_YEAR, YEAR) == EXTENDED_YEAR) {
            eyear = internalGet(EXTENDED_YEAR, 1)
        } else if (isAmeteAlemEra()) {
            eyear = internalGet(YEAR, 1 + AMETE_MIHRET_DELTA) - AMETE_MIHRET_DELTA
        } else {
            let era = internalGet(ERA, AMETE_MIHRET)
            if (era == AMETE_MIHRET) {
                eyear = internalGet(YEAR, 1)
            } else {
                eyear = internalGet(YEAR, 1) - AMETE_MIHRET_DELTA
            }
        }
        return eyear
    }

    
    override protected func handleComputeFields(julianDay: Int32): Unit {
        let era: Int32
        let year: Int32
        let fields = Array<Int32>(3) { _ => 0 }
        jdToCE(julianDay, getJDEpochOffset(), fields)
        if (isAmeteAlemEra()) {
            era = AMETE_ALEM
            year = fields[0] + AMETE_MIHRET_DELTA
        } else {
            if (fields[0] > 0) {
                era = AMETE_MIHRET
                year = fields[0]
            } else {
                era = AMETE_ALEM
                year = fields[0] + AMETE_MIHRET_DELTA
            }
        }
        internalSet(EXTENDED_YEAR, fields[0])
        internalSet(ERA, era)
        internalSet(YEAR, year)
        internalSet(MONTH, fields[1])
        internalSet(ORDINAL_MONTH, fields[1])
        internalSet(DAY_OF_MONTH, fields[2])
        internalSet(DAY_OF_YEAR, (30 * fields[1]) + fields[2])
    }

    
    override protected func handleGetLimit(field: Int32, limitType: Int32): Int32 {
        if (isAmeteAlemEra() && field == ERA) {
            return 0
        }
        return super.handleGetLimit(field, limitType)
    }

    
    override protected func getJDEpochOffset(): Int32 {
        return JD_EPOCH_OFFSET_AMETE_MIHRET
    }

    public static func EthiopicToJD(year: Int64, month: Int32, date: Int32): Int32 {
        return ceToJD(year, month, date, JD_EPOCH_OFFSET_AMETE_MIHRET)
    }

    private func setCalcTypeForLocale(locale: ULocale): Unit {
        let localeCalType = CalendarUtil.getCalendarType(locale)
        if ("ethiopic-amete-alem".equals(localeCalType)) {
            setAmeteAlemEra(true)
        } else {
            setAmeteAlemEra(false)
        }
    }
}
