package icu4cj.text


public abstract class TimeZoneNames <: Serializable {
    private static let serialVersionUID = -9180227029248969153

    private static var TZNAMES_CACHE: TimeZoneNames_Cache = TimeZoneNames_Cache()

    static let TZNAMES_FACTORY: TimeZoneNames_Factory

    private static let FACTORY_NAME_PROP = "com.ibm.icu.text.TimeZoneNames.Factory.impl"

    private static let DEFAULT_FACTORY_CLASS = "com.ibm.icu.impl.TimeZoneNamesFactoryImpl"


    public static func getInstance(locale: ULocale): TimeZoneNames {
        let key = locale.getBaseName()
        return TZNAMES_CACHE.getInstance(key, locale)
    }

    public static func getInstance(locale: Locale): TimeZoneNames {
        return getInstance(ULocale.forLocale(locale))
    }

    public static func getTZDBInstance(locale: ULocale): TimeZoneNames {
        return TZDBTimeZoneNames(locale)
    }

    public func getAvailableMetaZoneIDs(): Set<String>

    public func getAvailableMetaZoneIDs(tzID: String): Set<String>

    public func getMetaZoneID(tzID: String, date: Int64): String

    public func getReferenceZoneID(mzID: String, region: String): String

    public func getMetaZoneDisplayName(mzID: String, Type: TimeZoneNames_NameType): String

    public func getDisplayName(tzID: String, Type: TimeZoneNames_NameType, date: Int64): String {
        var name = getTimeZoneDisplayName(tzID, Type)
        if (name.isNone()) {
            let mzID = getMetaZoneID(tzID, date)
            name = getMetaZoneDisplayName(mzID, Type)
        }
        return name
    }

    public func getTimeZoneDisplayName(tzID: String, Type: TimeZoneNames_NameType): String

    public func getExemplarLocationName(tzID: String): String {
        return TimeZoneNamesImpl.getDefaultExemplarLocationName(tzID)
    }

    public func find(text: String, start: Int32, types: EnumSet): Collection<TimeZoneNames_MatchInfo> {
        throw UnsupportedOperationException("The method is not implemented in TimeZoneNames base class.")
    }

    
    public func loadAllDisplayNames(): Unit { }

    
    public func getDisplayNames(tzID: String, types: Array<TimeZoneNames_NameType>, date: Int64, dest: Array<String>, destOffset: Int32): Unit {
        if (tzID.isNone() || Int32(tzID.size) == 0) {
            return
        }
        var mzID: String
        var i = 0
        while (i < Int32(types.size)) {
            let Type = types[Int64(i)]
            var name = getTimeZoneDisplayName(tzID, Type)
            if (name.isNone()) {
                if (mzID.isNone()) {
                    mzID = getMetaZoneID(tzID, date)
                }
                name = getMetaZoneDisplayName(mzID, Type)
            }
            dest[Int64(destOffset + i)] = name
            i++
        }
    }

}


public class TimeZoneNames_NameType <: Enum<TimeZoneNames_NameType> {
    public static let LONG_GENERIC = TimeZoneNames_NameType("LONG_GENERIC", 0)

    public static let LONG_STANDARD = TimeZoneNames_NameType("LONG_STANDARD", 1)

    public static let LONG_DAYLIGHT = TimeZoneNames_NameType("LONG_DAYLIGHT", 2)

    public static let SHORT_GENERIC = TimeZoneNames_NameType("SHORT_GENERIC", 3)

    public static let SHORT_STANDARD = TimeZoneNames_NameType("SHORT_STANDARD", 4)

    public static let SHORT_DAYLIGHT = TimeZoneNames_NameType("SHORT_DAYLIGHT", 5)

    public static let EXEMPLAR_LOCATION = TimeZoneNames_NameType("EXEMPLAR_LOCATION", 6)

    private static func _values(): Array<TimeZoneNames_NameType> {
        return [TimeZoneNames_NameType.LONG_GENERIC, TimeZoneNames_NameType.LONG_STANDARD, TimeZoneNames_NameType.LONG_DAYLIGHT, TimeZoneNames_NameType.SHORT_GENERIC, TimeZoneNames_NameType.SHORT_STANDARD, TimeZoneNames_NameType.SHORT_DAYLIGHT, TimeZoneNames_NameType.EXEMPLAR_LOCATION]
    }

    private static let _VALUES = TimeZoneNames_NameType._values()

    public static func values(): Array<TimeZoneNames_NameType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): TimeZoneNames_NameType {
        return (TypeInfo.of<TimeZoneNames_NameType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as TimeZoneNames_NameType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class TimeZoneNames_MatchInfo {
    private var _nameType: TimeZoneNames_NameType

    private var _tzID: String

    private var _mzID: String

    private var _matchLength: Int32 = 0

    public init(nameType: TimeZoneNames_NameType, tzID: String, mzID: String, matchLength: Int32) {
        if (nameType.isNone()) {
            throw IllegalArgumentException("nameType is null")
        }
        if (tzID.isNone() && mzID.isNone()) {
            throw IllegalArgumentException("Either tzID or mzID must be available")
        }
        if (matchLength <= 0) {
            throw IllegalArgumentException("matchLength must be positive value")
        }
        _nameType = nameType
        _tzID = tzID
        _mzID = mzID
        _matchLength = matchLength
    }

    public func tzID(): String {
        return _tzID
    }

    public func mzID(): String {
        return _mzID
    }

    public func nameType(): TimeZoneNames_NameType {
        return _nameType
    }

    public func matchLength(): Int32 {
        return _matchLength
    }
}



public abstract class TimeZoneNames_Factory {
    
    public func getTimeZoneNames(locale: ULocale): TimeZoneNames

    
}


class TimeZoneNames_Cache <: SoftCache<String, TimeZoneNames, ULocale> {
    init() {
        super()
    }

    override protected func createInstance(key: String, data: ULocale): TimeZoneNames {
        return TimeZoneNames.TZNAMES_FACTORY.getTimeZoneNames(data)
    }
}


class TimeZoneNames_DefaultTimeZoneNames <: TimeZoneNames {
    private init() {
        super()
    }

    private static let serialVersionUID = -995672072494349071

    public static let INSTANCE = TimeZoneNames_DefaultTimeZoneNames()

    public override func getAvailableMetaZoneIDs(): Set<String> {
        return Collections.emptySet<<--> -->()
    }

    public override func getAvailableMetaZoneIDs(tzID: String): Set<String> {
        return Collections.emptySet<<--> -->()
    }

    public override func getMetaZoneID(tzID: String, date: Int64): String {
        return None
    }

    public override func getReferenceZoneID(mzID: String, region: String): String {
        return None
    }

    public override func getMetaZoneDisplayName(mzID: String, Type: TimeZoneNames_NameType): String {
        return None
    }

    public override func getTimeZoneDisplayName(tzID: String, Type: TimeZoneNames_NameType): String {
        return None
    }

    public override func find(text: String, start: Int32, nameTypes: EnumSet): Collection<TimeZoneNames_MatchInfo> {
        return Array<String>(0, { _ => "" })
    }
}


public class TimeZoneNames_DefaultTimeZoneNames_FactoryImpl <: TimeZoneNames_Factory {
    public init() {
        super()
    }

    public override func getTimeZoneNames(locale: ULocale): TimeZoneNames {
        return TimeZoneNames_DefaultTimeZoneNames.INSTANCE
    }
}
