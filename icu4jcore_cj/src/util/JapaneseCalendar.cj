package icu4cj.util


public class JapaneseCalendar <: GregorianCalendar {
    private static let serialVersionUID = -2977189902603704691

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

    public init(era: Int32, year: Int32, month: Int32, date: Int32) {
        super(year, month, date)
        set(ERA, era)
    }

    public init(year: Int32, month: Int32, date: Int32) {
        super(year, month, date)
        set(ERA, CURRENT_ERA)
    }

    public init(year: Int32, month: Int32, date: Int32, hour: Int32, minute: Int32, second: Int32) {
        super(year, month, date, hour, minute, second)
        set(ERA, CURRENT_ERA)
    }

    private static let GREGORIAN_EPOCH = 1970

    private static let ERA_RULES: EraRules


    
    public static func enableTentativeEra(): Bool {
        var includeTentativeEra = false
        let VAR_NAME = "ICU_ENABLE_TENTATIVE_ERA"
        var eraConf = System.getProperty(VAR_NAME)
        if (eraConf.isNone()) {
            eraConf = System.getenv(VAR_NAME)
        }
        if (eraConf.isSome()) {
            includeTentativeEra = eraConf.equalsIgnoreCase("true")
        } else {
            let jdkEraConf = System.getProperty("jdk.calendar.japanese.supplemental.era")
            includeTentativeEra = jdkEraConf.isSome()
        }
        return includeTentativeEra
    }

    override protected func handleGetExtendedYear(): Int32 {
        let year: Int32
        if (newerField(EXTENDED_YEAR, YEAR) == EXTENDED_YEAR && newerField(EXTENDED_YEAR, ERA) == EXTENDED_YEAR) {
            year = internalGet(EXTENDED_YEAR, GREGORIAN_EPOCH)
        } else {
            year = internalGet(YEAR, 1) + ERA_RULES.getStartYear(internalGet(ERA, CURRENT_ERA)) - 1
        }
        return year
    }

    override protected func getDefaultMonthInYear(extendedYear: Int32): Int32 {
        let era = internalGet(ERA, CURRENT_ERA)
        let eraStart = ERA_RULES.getStartDate(era, None)
        if (extendedYear == eraStart[0]) {
            return eraStart[1] - 1
        } else {
            return super.getDefaultMonthInYear(extendedYear)
        }
    }

    override protected func getDefaultDayInMonth(extendedYear: Int32, month: Int32): Int32 {
        let era = internalGet(ERA, CURRENT_ERA)
        let eraStart = ERA_RULES.getStartDate(era, None)
        if (extendedYear == eraStart[0]) {
            if (month == (eraStart[1] - 1)) {
                return eraStart[2]
            }
        }
        return super.getDefaultDayInMonth(extendedYear, month)
    }

    override protected func handleComputeFields(julianDay: Int32): Unit {
        super.handleComputeFields(julianDay)
        let year = internalGet(EXTENDED_YEAR)
        let eraIdx = ERA_RULES.getEraIndex(year, internalGet(MONTH) + 1, internalGet(DAY_OF_MONTH))
        internalSet(ERA, eraIdx)
        internalSet(YEAR, year - ERA_RULES.getStartYear(eraIdx) + 1)
    }

    public static let CURRENT_ERA: Int32

    public static let MEIJI: Int32

    public static let TAISHO: Int32

    public static let SHOWA: Int32

    public static let HEISEI: Int32

    public static let REIWA: Int32


    override protected func handleGetLimit(field: Int32, limitType: Int32): Int32 {
        match (field) {
            case 0 =>
                if (limitType == MINIMUM || limitType == GREATEST_MINIMUM) {
                    return 0
                }
                return ERA_RULES.getNumberOfEras() - 1
            case 1 => match (limitType) {
                case 0 | 1 => return 1
                case 2 => return 1
                case 3 => return super.handleGetLimit(field, MAXIMUM) - ERA_RULES.getStartYear(CURRENT_ERA)
                case _ => ()
            }
            case _ => return super.handleGetLimit(field, limitType)
        }
    }

    public override func getType(): String {
        return "japanese"
    }

    
    public override func haveDefaultCentury(): Bool {
        return false
    }

    public override func getActualMaximum(field: Int32): Int32 {
        if (field == YEAR) {
            let era = get(Calendar.ERA)
            if (era == ERA_RULES.getNumberOfEras() - 1) {
                return handleGetLimit(YEAR, MAXIMUM)
            } else {
                let nextEraStart = ERA_RULES.getStartDate(era + 1, None)
                let nextEraYear = nextEraStart[0]
                let nextEraMonth = nextEraStart[1]
                let nextEraDate = nextEraStart[2]
                var maxYear = nextEraYear - ERA_RULES.getStartYear(era) + 1
                if (nextEraMonth == 1 && nextEraDate == 1) {
                    maxYear--
                }
                return maxYear
            }
        }
        return super.getActualMaximum(field)
    }

    
    override protected func isEra0CountingBackward(): Bool {
        return false
    }
}
