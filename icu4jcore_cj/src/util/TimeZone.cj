package icu4cj.util


public abstract class TimeZone <: Serializable & Cloneable & Freezable<TimeZone> {
    private static let GeneratedStaticLockObject = Monitor()

    private static let LOGGER = Logger.getLogger("com.ibm.icu.util.TimeZone")

    private static let serialVersionUID = -744942128318337471


    
    protected init(ID: String) {
        if (ID.isNone()) {
            throw NoneValueException()
        }
        this.ID = ID
    }

    public static let TIMEZONE_ICU = 0

    public static let TIMEZONE_JDK = 1

    public static let SHORT = 0

    public static let LONG = 1

    public static let SHORT_GENERIC = 2

    public static let LONG_GENERIC = 3

    public static let SHORT_GMT = 4

    public static let LONG_GMT = 5

    public static let SHORT_COMMONLY_USED = 6

    public static let GENERIC_LOCATION = 7

    public static let UNKNOWN_ZONE_ID = "Etc/Unknown"

    static let GMT_ZONE_ID = "Etc/GMT"

    public static let UNKNOWN_ZONE = TimeZone_ConstantZone(0, UNKNOWN_ZONE_ID).freeze()

    public static let GMT_ZONE = TimeZone_ConstantZone(0, GMT_ZONE_ID).freeze()

    public func getOffset(era: Int32, year: Int32, month: Int32, day: Int32, dayOfWeek: Int32, milliseconds: Int32): Int32

    public func getOffset(date: Int64): Int32 {
        let result = Array<Int32>(2) { _ => 0 }
        getOffset(date, false, result)
        return result[0] + result[1]
    }

    public func getOffset(date: Int64, local: Bool, offsets: Array<Int32>): Unit {
        var tempdate = date
        offsets[0] = getRawOffset()
        if (!local) {
            tempdate += Int64(offsets[0])
        }
        let fields = Array<Int32>(6) { _ => 0 }
        var pass = 0
        while (true) {
            Grego.timeToFields(tempdate, fields)
            offsets[1] = getOffset(GregorianCalendar.AD, fields[0], fields[1], fields[2], fields[3], fields[5]) - offsets[0]
            if (pass != 0 || !local || offsets[1] == 0) {
                break
            }
            tempdate -= Int64(offsets[1])
            pass++
        }
    }

    public func setRawOffset(offsetMillis: Int32): Unit

    public func getRawOffset(): Int32

    public func getID(): String {
        return ID
    }

    public func setID(ID: String): Unit {
        if (ID.isNone()) {
            throw NoneValueException()
        }
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify a frozen TimeZone instance.")
        }
        this.ID = ID
    }

    public func getDisplayName(): String {
        return _getDisplayName(LONG_GENERIC, false, ULocale.getDefault(ULocale_Category.DISPLAY))
    }

    public func getDisplayName(locale: Locale): String {
        return _getDisplayName(LONG_GENERIC, false, ULocale.forLocale(locale))
    }

    public func getDisplayName(locale: ULocale): String {
        return _getDisplayName(LONG_GENERIC, false, locale)
    }

    public func getDisplayName(daylight: Bool, style: Int32): String {
        return getDisplayName(daylight, style, ULocale.getDefault(ULocale_Category.DISPLAY))
    }

    public func getDisplayName(daylight: Bool, style: Int32, locale: Locale): String {
        return getDisplayName(daylight, style, ULocale.forLocale(locale))
    }

    public func getDisplayName(daylight: Bool, style: Int32, locale: ULocale): String {
        if (style < SHORT || style > GENERIC_LOCATION) {
            throw IllegalArgumentException("Illegal style: " + style.toString())
        }
        return _getDisplayName(style, daylight, locale)
    }

    private func _getDisplayName(style: Int32, daylight: Bool, locale: ULocale): String {
        if (locale.isNone()) {
            throw NoneValueException("locale is null")
        }
        var result: String
        if (style == GENERIC_LOCATION || style == LONG_GENERIC || style == SHORT_GENERIC) {
            let tzfmt = TimeZoneFormat.getInstance(locale)
            let date = DateTime.now().toUnixTimeStamp().toMilliseconds()
            let timeType = Output<TimeZoneFormat_TimeType>(TimeZoneFormat_TimeType.UNKNOWN)
            match (style) {
                case 7 => result = tzfmt.format(TimeZoneFormat_Style.GENERIC_LOCATION, this, date, timeType)
                case 3 => result = tzfmt.format(TimeZoneFormat_Style.GENERIC_LONG, this, date, timeType)
                case 2 => result = tzfmt.format(TimeZoneFormat_Style.GENERIC_SHORT, this, date, timeType)
                case _ => ()
            }
            if (daylight && refEq(timeType.value, TimeZoneFormat_TimeType.STANDARD) || !daylight && refEq(timeType.value, TimeZoneFormat_TimeType.DAYLIGHT)) {
                let offset = if (daylight) { getRawOffset() + getDSTSavings() } else { getRawOffset() }
                result = if (style == SHORT_GENERIC) { tzfmt.formatOffsetShortLocalizedGMT(offset) } else { tzfmt.formatOffsetLocalizedGMT(offset) }
            }
        } else if (style == LONG_GMT || style == SHORT_GMT) {
            let tzfmt = TimeZoneFormat.getInstance(locale)
            let offset = if (daylight && useDaylightTime()) { getRawOffset() + getDSTSavings() } else { getRawOffset() }
            match (style) {
                case 5 => result = tzfmt.formatOffsetLocalizedGMT(offset)
                case 4 => result = tzfmt.formatOffsetISO8601Basic(offset, false, false, false)
                case _ => ()
            }
        } else {
            if (!(style == LONG || style == SHORT || style == SHORT_COMMONLY_USED)) {
                throw AssertionError()
            }
            let date = DateTime.now().toUnixTimeStamp().toMilliseconds()
            let tznames = TimeZoneNames.getInstance(locale)
            var nameType: TimeZoneNames_NameType
            match (style) {
                case 1 => nameType = if (daylight) { TimeZoneNames_NameType.LONG_DAYLIGHT } else { TimeZoneNames_NameType.LONG_STANDARD }
                case 0 | 6 => nameType = if (daylight) { TimeZoneNames_NameType.SHORT_DAYLIGHT } else { TimeZoneNames_NameType.SHORT_STANDARD }
                case _ => ()
            }
            result = tznames.getDisplayName(ZoneMeta.getCanonicalCLDRID(this), nameType, date)
            if (result.isNone()) {
                let tzfmt = TimeZoneFormat.getInstance(locale)
                let offset = if (daylight && useDaylightTime()) { getRawOffset() + getDSTSavings() } else { getRawOffset() }
                result = if (style == LONG) { tzfmt.formatOffsetLocalizedGMT(offset) } else { tzfmt.formatOffsetShortLocalizedGMT(offset) }
            }
        }
        if (!(result.isSome())) {
            throw AssertionError()
        }
        return result
    }

    public func getDSTSavings(): Int32 {
        if (useDaylightTime()) {
            return 3600000
        }
        return 0
    }

    public func useDaylightTime(): Bool

    public func observesDaylightTime(): Bool {
        return useDaylightTime() || inDaylightTime(Date())
    }

    public func inDaylightTime(date: DateTime): Bool

    public static func getTimeZone(ID: String): TimeZone {
        return getTimeZone(ID, TZ_IMPL, false)
    }

    public static func getFrozenTimeZone(ID: String): TimeZone {
        return getTimeZone(ID, TZ_IMPL, true)
    }

    public static func getTimeZone(ID: String, Type: Int32): TimeZone {
        return getTimeZone(ID, Type, false)
    }

    private static func getTimeZone(id: String, Type: Int32, frozen: Bool): TimeZone {
        var result: TimeZone
        if (Type == TIMEZONE_JDK) {
            result = JavaTimeZone.createTimeZone(id)
            if (result.isSome()) {
                return if (frozen) { result.freeze() } else { result }
            }
            result = getFrozenICUTimeZone(id, false)
        } else {
            result = getFrozenICUTimeZone(id, true)
        }
        if (result.isNone()) {
            LOGGER.fine("\"" + (id) + "\" is a bogus id so timezone is falling back to Etc/Unknown(GMT).")
            result = UNKNOWN_ZONE
        }
        return if (frozen) { result } else { result.cloneAsThawed() }
    }

    static func getFrozenICUTimeZone(id: String, trySystem: Bool): BasicTimeZone {
        var result: BasicTimeZone
        if (trySystem) {
            result = ZoneMeta.getSystemTimeZone(id)
        }
        if (result.isNone()) {
            result = ZoneMeta.getCustomTimeZone(id)
        }
        return result
    }

    public static func setDefaultTimeZoneType(Type: Int32): Unit {
        synchronized (GeneratedStaticLockObject) {
            if (Type != TIMEZONE_ICU && Type != TIMEZONE_JDK) {
                throw IllegalArgumentException("Invalid timezone type")
            }
            TZ_IMPL = Type
        }
    }

    public static func getDefaultTimeZoneType(): Int32 {
        return TZ_IMPL
    }

    public static func getAvailableIDs(zoneType: TimeZone_SystemTimeZoneType, region: String, rawOffset: Int32): Set<String> {
        return ZoneMeta.getAvailableIDs(zoneType, region, rawOffset)
    }

    public static func getAvailableIDs(rawOffset: Int32): Array<String> {
        let ids = getAvailableIDs(TimeZone_SystemTimeZoneType.ANY, None, rawOffset)
        return ids.toArray(Array<String>(0))
    }

    public static func getAvailableIDs(country: String): Array<String> {
        let ids = getAvailableIDs(TimeZone_SystemTimeZoneType.ANY, country, None)
        return ids.toArray(Array<String>(0))
    }

    public static func getAvailableIDs(): Array<String> {
        let ids = getAvailableIDs(TimeZone_SystemTimeZoneType.ANY, None, None)
        return ids.toArray(Array<String>(0))
    }

    public static func countEquivalentIDs(id: String): Int32 {
        return ZoneMeta.countEquivalentIDs(id)
    }

    public static func getEquivalentID(id: String, index: Int32): String {
        return ZoneMeta.getEquivalentID(id, index)
    }

    
    public static func forULocaleOrDefault(locale: ULocale): TimeZone {
        let tz = locale.getKeywordValue("timezone")
        return if (tz.isNone()) { getDefault() } else { getTimeZone(tz) }
    }

    
    public static func forLocaleOrDefault(locale: Locale): TimeZone {
        return forULocaleOrDefault(ULocale.forLocale(locale))
    }

    public static func getDefault(): TimeZone {
        var tmpDefaultZone = defaultZone
        if (tmpDefaultZone.isNone()) {
            synchronized (getMonitorByObject(TypeInfo.of<TimeZone>())) {
                synchronized (getMonitorByObject(TypeInfo.of<TimeZone>())) {
                    tmpDefaultZone = defaultZone
                    if (tmpDefaultZone.isNone()) {
                        if (TZ_IMPL == TIMEZONE_JDK) {
                            tmpDefaultZone = JavaTimeZone()
                        } else {
                            let temp = TimeZone.getDefault()
                            tmpDefaultZone = getFrozenTimeZone(temp.getID())
                        }
                        defaultZone = tmpDefaultZone
                    }
                }
            }
        }
        return tmpDefaultZone.cloneAsThawed()
    }

    public static func setDefault(tz: TimeZone): Unit {
        synchronized (GeneratedStaticLockObject) {
            setICUDefault(tz)
            if (tz.isSome()) {
                var jdkZone: TimeZone = None
                if (checkOptionalIs<JavaTimeZone, TimeZone>(tz)) {
                    jdkZone = tz.unwrap()
                } else if (checkOptionalIs<OlsonTimeZone, TimeZone>(tz)) {
                    var icuID = tz.getID()
                    jdkZone = TimeZone.getTimeZone(icuID)
                    if (!icuID.equals(jdkZone.getID())) {
                        icuID = getCanonicalID(icuID)
                        jdkZone = TimeZone.getTimeZone(icuID)
                        if (!icuID.equals(jdkZone.getID())) {
                            jdkZone = None
                        }
                    }
                }
                if (jdkZone.isNone()) {
                    jdkZone = TimeZoneAdapter.wrap(tz)
                }
                TimeZone.setDefault(jdkZone)
            }
        }
    }

    
    public static func setICUDefault(tz: TimeZone): Unit {
        synchronized (GeneratedStaticLockObject) {
            if (tz.isNone()) {
                defaultZone = None
            } else if (tz.isFrozen()) {
                defaultZone = tz
            } else {
                defaultZone = tz.clone().freeze()
            }
        }
    }

    public func hasSameRules(other: TimeZone): Bool {
        return other.isSome() && getRawOffset() == other.getRawOffset() && useDaylightTime() == other.useDaylightTime()
    }

    public override func clone(): Object {
        if (isFrozen()) {
            return this
        }
        return cloneAsThawed()
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (obj.isNone() || !refEq(TypeInfo.of(this), TypeInfo.of(obj))) {
            return false
        }
        return (ID.equals(obj.ID))
    }

    public override func hashCode(): Int64 {
        return ID.hashCode()
    }

    public static func getTZDataVersion(): String {
        return VersionInfo.getTZDataVersion()
    }

    public static func getCanonicalID(id: String): String {
        return getCanonicalID(id, None)
    }

    public static func getCanonicalID(id: String, isSystemID: Array<Bool>): String {
        var canonicalID: String
        var systemTzid = false
        if (id.isSome() && Int32(id.size) != 0) {
            if (id.equals(TimeZone.UNKNOWN_ZONE_ID)) {
                canonicalID = TimeZone.UNKNOWN_ZONE_ID
                systemTzid = false
            } else {
                canonicalID = ZoneMeta.getCanonicalCLDRID(id)
                if (canonicalID.isSome()) {
                    systemTzid = true
                } else {
                    canonicalID = ZoneMeta.getCustomID(id)
                }
            }
        }
        if (isSystemID.isSome()) {
            isSystemID[0] = systemTzid
        }
        return canonicalID
    }

    public static func getIanaID(id: String): String {
        var ianaId: String = TimeZone.UNKNOWN_ZONE_ID
        if (id.isNone() || Int32(id.size) == 0 || id.append(TimeZone.UNKNOWN_ZONE)) {
            return ianaId
        }
        let tmpIanaId = ZoneMeta.getIanaID(id)
        if (tmpIanaId.isSome()) {
            ianaId = tmpIanaId
        }
        return ianaId
    }

    public static func getRegion(id: String): String {
        var region: String
        if (!id.equals(UNKNOWN_ZONE_ID)) {
            region = ZoneMeta.getRegion(id)
        }
        if (region.isNone()) {
            throw IllegalArgumentException("Unknown system zone id: " + (id))
        }
        return region
    }

    public static func getWindowsID(id: String): String {
        var tempid = id
        let isSystemID = [false]
        tempid = getCanonicalID(tempid, isSystemID)
        if (!isSystemID[0]) {
            return None
        }
        let top = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "windowsZones", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
        let mapTimezones = top.get("mapTimezones")
        let resitr = mapTimezones.getIterator()
        while (resitr.hasNext()) {
            let winzone = resitr.next()
            if (winzone.getType() != UResourceBundle.TABLE) {
                continue
            }
            let rgitr = winzone.getIterator()
            while (rgitr.hasNext()) {
                let regionalData = rgitr.next()
                if (regionalData.getType() != UResourceBundle.STRING) {
                    continue
                }
                let tzids = regionalData.getString().split(" ")
                for (tzid in tzids) {
                    if (tzid.equals(tempid)) {
                        return winzone.getKey()
                    }
                }
            }
        }
        return None
    }

    public static func getIDForWindowsID(winid: String, region: String): String {
        var id: String
        let top = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "windowsZones", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
        let mapTimezones = top.get("mapTimezones")
        try {
            let zones = mapTimezones.get(winid)
            if (region.isSome()) {
                try {
                    id = zones.getString(region)
                    if (id.isSome()) {
                        let endIdx = indexOfWrap(id.indexOf(UInt8(UInt32(' '))))
                        if (endIdx > 0) {
                            id = id[0..Int64(endIdx)]
                        }
                    }
                } catch (e: MissingResourceException) { }
            }
            if (id.isNone()) {
                id = zones.getString("001")
            }
        } catch (e: MissingResourceException) { }
        return id
    }

    public override func isFrozen(): Bool {
        return false
    }

    public override func freeze(): TimeZone {
        throw UnsupportedOperationException("Needs to be implemented by the subclass.")
    }

    public override func cloneAsThawed(): TimeZone {
        try {
            let other = super.toString()
            return other
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException(e as Exception)
        }
    }

    private var ID: String

     private static var defaultZone: TimeZone

    private static var TZ_IMPL = TIMEZONE_ICU

    private static let TZIMPL_CONFIG_KEY = "com.ibm.icu.util.TimeZone.DefaultTimeZoneType"

    private static let TZIMPL_CONFIG_ICU = "ICU"

    private static let TZIMPL_CONFIG_JDK = "JDK"

}


public class TimeZone_SystemTimeZoneType <: Enum<TimeZone_SystemTimeZoneType> {
    public static let ANY = TimeZone_SystemTimeZoneType("ANY", 0)

    public static let CANONICAL = TimeZone_SystemTimeZoneType("CANONICAL", 1)

    public static let CANONICAL_LOCATION = TimeZone_SystemTimeZoneType("CANONICAL_LOCATION", 2)

    private static func _values(): Array<TimeZone_SystemTimeZoneType> {
        return [TimeZone_SystemTimeZoneType.ANY, TimeZone_SystemTimeZoneType.CANONICAL, TimeZone_SystemTimeZoneType.CANONICAL_LOCATION]
    }

    private static let _VALUES = TimeZone_SystemTimeZoneType._values()

    public static func values(): Array<TimeZone_SystemTimeZoneType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): TimeZone_SystemTimeZoneType {
        return (TypeInfo.of<TimeZone_SystemTimeZoneType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as TimeZone_SystemTimeZoneType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class TimeZone_ConstantZone <: TimeZone {
    private static let serialVersionUID = 1

    private var rawOffset: Int32 = 0

    init(rawOffset: Int32, ID: String) {
        super(ID)
        this.rawOffset = rawOffset
    }

    public override func getOffset(era: Int32, year: Int32, month: Int32, day: Int32, dayOfWeek: Int32, milliseconds: Int32): Int32 {
        return rawOffset
    }

    public override func setRawOffset(offsetMillis: Int32): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen TimeZone instance.")
        }
        rawOffset = offsetMillis
    }

    public override func getRawOffset(): Int32 {
        return rawOffset
    }

    public override func useDaylightTime(): Bool {
        return false
    }

    public override func inDaylightTime(date: DateTime): Bool {
        return false
    }

      private var isFrozen = false

    public override func isFrozenMethod(): Bool {
        return isFrozen
    }

    public override func freeze(): TimeZone {
        isFrozen = true
        return this
    }

    public override func cloneAsThawed(): TimeZone {
        let tz = super.cloneAsThawed()
        tz.isFrozen = false
        return tz
    }
}
