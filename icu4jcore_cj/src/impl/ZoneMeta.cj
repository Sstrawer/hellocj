package icu4cj.impl


public class ZoneMeta {
    private static let GeneratedStaticLockObject = Monitor()


    private static let ASSERT = false

    static let ZONEINFORESNAME = "zoneinfo64"

    private static let kREGIONS = "Regions"

    private static let kZONES = "Zones"

    private static let kNAMES = "Names"

    private static let kGMT_ID = "GMT"

    private static let kCUSTOM_TZ_PREFIX = "GMT"

    private static let kWorld = "001"

    private static var REF_SYSTEM_ZONES: SoftReference = None

    private static var REF_CANONICAL_SYSTEM_ZONES: SoftReference = None

    private static var REF_CANONICAL_SYSTEM_LOCATION_ZONES: SoftReference = None

    private static func getSystemZIDs(): Set<String> {
        synchronized (GeneratedStaticLockObject) {
            var systemZones: Set<String>
            if (REF_SYSTEM_ZONES.isSome()) {
                systemZones = REF_SYSTEM_ZONES.get()
            }
            if (systemZones.isNone()) {
                let systemIDs = TreeSet()
                let allIDs = getZoneIDs()
                for (id in allIDs) {
                    if (id.equals(TimeZone.UNKNOWN_ZONE_ID)) {
                        continue
                    }
                    systemIDs.put(id)
                }
                systemZones = Collections.unmodifiableSet(systemIDs as Set<T>)
                REF_SYSTEM_ZONES = SoftReference(systemZones)
            }
            return systemZones
        }
    }

    private static func getCanonicalSystemZIDs(): Set<String> {
        synchronized (GeneratedStaticLockObject) {
            var canonicalSystemZones: Set<String>
            if (REF_CANONICAL_SYSTEM_ZONES.isSome()) {
                canonicalSystemZones = REF_CANONICAL_SYSTEM_ZONES.get()
            }
            if (canonicalSystemZones.isNone()) {
                let canonicalSystemIDs = TreeSet()
                let allIDs = getZoneIDs()
                for (id in allIDs) {
                    if (id.equals(TimeZone.UNKNOWN_ZONE_ID)) {
                        continue
                    }
                    let canonicalID = getCanonicalCLDRID(id)
                    if (id.equals(canonicalID)) {
                        canonicalSystemIDs.put(id)
                    }
                }
                canonicalSystemZones = Collections.unmodifiableSet(canonicalSystemIDs as Set<T>)
                REF_CANONICAL_SYSTEM_ZONES = SoftReference(canonicalSystemZones)
            }
            return canonicalSystemZones
        }
    }

    private static func getCanonicalSystemLocationZIDs(): Set<String> {
        synchronized (GeneratedStaticLockObject) {
            var canonicalSystemLocationZones: Set<String>
            if (REF_CANONICAL_SYSTEM_LOCATION_ZONES.isSome()) {
                canonicalSystemLocationZones = REF_CANONICAL_SYSTEM_LOCATION_ZONES.get()
            }
            if (canonicalSystemLocationZones.isNone()) {
                let canonicalSystemLocationIDs = TreeSet()
                let allIDs = getZoneIDs()
                for (id in allIDs) {
                    if (id.equals(TimeZone.UNKNOWN_ZONE_ID)) {
                        continue
                    }
                    let canonicalID = getCanonicalCLDRID(id)
                    if (id.equals(canonicalID)) {
                        let region = getRegion(id)
                        if (region.isSome() && !region.equals(kWorld)) {
                            canonicalSystemLocationIDs.put(id)
                        }
                    }
                }
                canonicalSystemLocationZones = Collections.unmodifiableSet(canonicalSystemLocationIDs as Set<T>)
                REF_CANONICAL_SYSTEM_LOCATION_ZONES = SoftReference(canonicalSystemLocationZones)
            }
            return canonicalSystemLocationZones
        }
    }

    public static func getAvailableIDs(Type: TimeZone_SystemTimeZoneType, region: String, rawOffset: Int32): Set<String> {
        var tempregion = region
        var baseSet: Set<String>
        match (Type) {
            case TimeZone_SystemTimeZoneType.ANY => baseSet = getSystemZIDs()
            case TimeZone_SystemTimeZoneType.CANONICAL => baseSet = getCanonicalSystemZIDs()
            case TimeZone_SystemTimeZoneType.CANONICAL_LOCATION => baseSet = getCanonicalSystemLocationZIDs()
            case _ => throw IllegalArgumentException("Unknown SystemTimeZoneType")
        }
        if (tempregion.isNone() && rawOffset.isNone()) {
            return baseSet
        }
        if (tempregion.isSome()) {
            tempregion = tempregion.toUpperCase(Locale.ENGLISH)
        }
        let result = TreeSet()
        for (id in baseSet) {
            if (tempregion.isSome()) {
                let r = getRegion(id)
                if (!tempregion.equals(r)) {
                    continue
                }
            }
            if (rawOffset.isSome()) {
                let z = getSystemTimeZone(id)
                if (z.isNone() || !refEq(rawOffset, z.getRawOffset())) {
                    continue
                }
            }
            result.put(id)
        }
        if (result.isEmpty()) {
            return Collections.emptySet<<--> -->()
        }
        return Collections.unmodifiableSet(result as Set<T>)
    }

    public static func countEquivalentIDs(id: String): Int32 {
        synchronized (GeneratedStaticLockObject) {
            var count = 0
            let res = openOlsonResource(None, id)
            if (res.isSome()) {
                try {
                    let links = res.get("links")
                    let v = links.getIntVector()
                    count = Int32(v.size)
                } catch (ex: MissingResourceException) { }
            }
            return count
        }
    }

    public static func getEquivalentID(id: String, index: Int32): String {
        synchronized (GeneratedStaticLockObject) {
            var result: String = ""
            if (index >= 0) {
                let res = openOlsonResource(None, id)
                if (res.isSome()) {
                    var zoneIdx = -1
                    try {
                        let links = res.get("links")
                        let zones = links.getIntVector()
                        if (index < Int32(zones.size)) {
                            zoneIdx = zones[Int64(index)]
                        }
                    } catch (ex: MissingResourceException) { }
                    if (zoneIdx >= 0) {
                        let tmp = getZoneID(zoneIdx)
                        if (tmp.isSome()) {
                            result = tmp
                        }
                    }
                }
            }
            return result
        }
    }

    private static var ZONEIDS: Array<String>

    private static func getZoneIDs(): Array<String> {
        synchronized (GeneratedStaticLockObject) {
            if (ZONEIDS.isNone()) {
                try {
                    let top = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, ZONEINFORESNAME, ICUResourceBundle.ICU_DATA_CLASS_LOADER)
                    ZONEIDS = top.getStringArray(kNAMES)
                } catch (ex: MissingResourceException) { }
            }
            if (ZONEIDS.isNone()) {
                ZONEIDS = Array<String>(0)
            }
            return ZONEIDS
        }
    }

    private static func getZoneID(idx: Int32): String {
        if (idx >= 0) {
            let ids = getZoneIDs()
            if (idx < Int32(ids.size)) {
                return ids[Int64(idx)]
            }
        }
        return None
    }

    private static func getZoneIndex(zid: String): Int32 {
        var zoneIdx = -1
        let all = getZoneIDs()
        if (Int32(all.size) > 0) {
            var start = 0
            var limit = Int32(all.size)
            var lastMid = Int32.Max
            while (true) {
                let mid = (start + limit) / 2
                if (lastMid == mid) {
                    break
                }
                lastMid = mid
                let r = zid.compare(all[Int64(mid)]).value()
                if (r == 0) {
                    zoneIdx = mid
                    break
                } else if (r < 0) {
                    limit = mid
                } else {
                    start = mid
                }
            }
        }
        return zoneIdx
    }

    private static var CANONICAL_ID_CACHE: ICUCache<String, String> = SimpleCache<String, String>()

    private static var REGION_CACHE: ICUCache<String, String> = SimpleCache<String, String>()

    private static var SINGLE_COUNTRY_CACHE: ICUCache<String, Bool> = SimpleCache<String, Bool>()

    public static func getCanonicalCLDRID(tz: TimeZone): String {
        if (checkOptionalIs<OlsonTimeZone, TimeZone>(tz)) {
            return tz.getCanonicalID()
        }
        return getCanonicalCLDRID(tz.getID())
    }

    public static func getCanonicalCLDRID(tzid: String): String {
        var temptzid = tzid
        var canonical = CANONICAL_ID_CACHE.get(temptzid)
        if (canonical.isNone()) {
            canonical = findCLDRCanonicalID(temptzid)
            if (canonical.isNone()) {
                try {
                    let zoneIdx = getZoneIndex(temptzid)
                    if (zoneIdx >= 0) {
                        let top = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, ZONEINFORESNAME, ICUResourceBundle.ICU_DATA_CLASS_LOADER)
                        let zones = top.get(kZONES)
                        let zone = zones.get(zoneIdx)
                        if (zone.getType() == UResourceBundle.INT) {
                            temptzid = getZoneID(zone.getInt())
                            canonical = findCLDRCanonicalID(temptzid)
                        }
                        if (canonical.isNone()) {
                            canonical = temptzid
                        }
                    }
                } catch (e: MissingResourceException) { }
            }
            if (canonical.isSome()) {
                CANONICAL_ID_CACHE.put(temptzid, canonical)
            }
        }
        return canonical
    }

    private static func findCLDRCanonicalID(tzid: String): String {
        var canonical: String
        let tzidKey: String = tzid.replace('/'.toString(), ':'.toString())
        try {
            let keyTypeData = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "keyTypeData", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
            let typeMap = keyTypeData.get("typeMap")
            let typeKeys = typeMap.get("timezone")
            try {
                typeKeys.get(tzidKey)
                canonical = tzid
            } catch (e: MissingResourceException) { }
            if (canonical.isNone()) {
                let typeAlias = keyTypeData.get("typeAlias")
                let aliasesForKey = typeAlias.get("timezone")
                canonical = aliasesForKey.getString(tzidKey)
            }
        } catch (e: MissingResourceException) { }
        return canonical
    }

    public static func getIanaID(tzid: String): String {
        let canonicalID = getCanonicalCLDRID(tzid)
        if (canonicalID.isNone()) {
            return None
        }
        let keyTypeData = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "keyTypeData", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
        let ianaMap = keyTypeData.get("ianaMap")
        let ianaTzMap = ianaMap.get("timezone")
        try {
            return ianaTzMap.getString(canonicalID.replace('/'.toString(), ':'.toString()))
        } catch (e: MissingResourceException) {
            return canonicalID
        }
    }

    public static func getRegion(tzid: String): String {
        var region = REGION_CACHE.get(tzid)
        if (region.isNone()) {
            let zoneIdx = getZoneIndex(tzid)
            if (zoneIdx >= 0) {
                try {
                    let top = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, ZONEINFORESNAME, ICUResourceBundle.ICU_DATA_CLASS_LOADER)
                    let regions = top.get(kREGIONS)
                    if (zoneIdx < regions.getSize()) {
                        region = regions.getString(zoneIdx)
                    }
                } catch (e: MissingResourceException) { }
                if (region.isSome()) {
                    REGION_CACHE.put(tzid, region)
                }
            }
        }
        return region
    }

    public static func getCanonicalCountry(tzid: String): String {
        var country = getRegion(tzid)
        if (country.isSome() && country.append(kWorld)) {
            country = None
        }
        return country
    }

    public static func getCanonicalCountry(tzid: String, isPrimary: Output<Bool>): String {
        isPrimary.value = Bool.FALSE
        let country = getRegion(tzid)
        if (country.isSome() && country.append(kWorld)) {
            return None
        }
        var singleZone = SINGLE_COUNTRY_CACHE.get(tzid)
        if (singleZone.isNone()) {
            let ids = TimeZone.getAvailableIDs(TimeZone_SystemTimeZoneType.CANONICAL_LOCATION, country, None)
            if (!(Int32(ids.size) >= 1)) {
                throw AssertionError()
            }
            singleZone = Bool.valueOf(Int32(ids.size) <= 1)
            SINGLE_COUNTRY_CACHE.put(tzid, singleZone)
        }
        if (singleZone) {
            isPrimary.value = Bool.TRUE
        } else {
            try {
                let bundle = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "metaZones")
                let primaryZones = bundle.get("primaryZones")
                let primaryZone = primaryZones.getString(country)
                if (tzid.equals(primaryZone)) {
                    isPrimary.value = Bool.TRUE
                } else {
                    let canonicalID = getCanonicalCLDRID(tzid)
                    if (canonicalID.isSome() && canonicalID.equals(primaryZone)) {
                        isPrimary.value = Bool.TRUE
                    }
                }
            } catch (e: MissingResourceException) { }
        }
        return country
    }

    public static func openOlsonResource(top: UResourceBundle, id: String): UResourceBundle {
        var temptop = top
        var res: UResourceBundle
        let zoneIdx = getZoneIndex(id)
        if (zoneIdx >= 0) {
            try {
                if (temptop.isNone()) {
                    temptop = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, ZONEINFORESNAME, ICUResourceBundle.ICU_DATA_CLASS_LOADER)
                }
                let zones = temptop.get(kZONES)
                var zone = zones.get(zoneIdx)
                if (zone.getType() == UResourceBundle.INT) {
                    zone = zones.get(zone.getInt())
                }
                res = zone
            } catch (e: MissingResourceException) {
                res = None
            }
        }
        return res
    }

    private static let SYSTEM_ZONE_CACHE = ZoneMeta_SystemTimeZoneCache()

    public static func getSystemTimeZone(id: String): OlsonTimeZone {
        return SYSTEM_ZONE_CACHE.getInstance(id, id)
    }

    static let kMAX_CUSTOM_HOUR = 23

    static let kMAX_CUSTOM_MIN = 59

    static let kMAX_CUSTOM_SEC = 59

    private static let CUSTOM_ZONE_CACHE = ZoneMeta_CustomTimeZoneCache()

    public static func getCustomTimeZone(id: String): SimpleTimeZone {
        let fields = Array<Int32>(4) { _ => 0 }
        if (parseCustomID(id, fields)) {
            let key: Int32 = fields[0] * (fields[1] | shl(fields[2], 5) | shl(fields[3], 11))
            return CUSTOM_ZONE_CACHE.getInstance(key, fields)
        }
        return None
    }

    public static func getCustomID(id: String): String {
        let fields = Array<Int32>(4) { _ => 0 }
        if (parseCustomID(id, fields)) {
            return formatCustomID(fields[1], fields[2], fields[3], fields[0] < 0)
        }
        return None
    }

    static func parseCustomID(id: String, fields: Array<Int32>): Bool {
        if (id.isSome() && Int32(id.size) > Int32(kGMT_ID.size) && id[0..3].equalsIgnoreCase(kGMT_ID)) {
            var sign = 1
            var hour = 0
            var min = 0
            var sec = 0
            let pos = Array<Int32>(1) { _ => 0 }
            pos[0] = Int32(kGMT_ID.size)
            if (Int32(UInt32(Char(id[Int64(pos[0])]))) == 45) {
                sign = -1
            } else if (Int32(UInt32(Char(id[Int64(pos[0])]))) != 43) {
                return false
            }
            pos[0] += 1
            var start = pos[0]
            hour = Utility.parseNumber(id, pos, 10)
            if (pos[0] == Int32(id.size)) {
                let length = pos[0] - start
                match (length) {
                    case 1 | 2 => ()
                    case 3 | 4 =>
                        min = hour % 100
                        hour /= 100
                    case 5 | 6 =>
                        sec = hour % 100
                        min = (hour / 100) % 100
                        hour /= 10000
                    case _ => return false
                }
            } else {
                if (pos[0] - start < 1 || pos[0] - start > 2 || Int32(UInt32(Char(id[Int64(pos[0])]))) != 58) {
                    return false
                }
                pos[0] += 1
                if (Int32(id.size) == pos[0]) {
                    return false
                }
                start = pos[0]
                min = Utility.parseNumber(id, pos, 10)
                if (pos[0] - start != 2) {
                    return false
                }
                if (Int32(id.size) > pos[0]) {
                    if (Int32(UInt32(Char(id[Int64(pos[0])]))) != 58) {
                        return false
                    }
                    pos[0] += 1
                    start = pos[0]
                    sec = Utility.parseNumber(id, pos, 10)
                    if (pos[0] - start != 2 || Int32(id.size) > pos[0]) {
                        return false
                    }
                }
            }
            if (hour <= kMAX_CUSTOM_HOUR && min <= kMAX_CUSTOM_MIN && sec <= kMAX_CUSTOM_SEC) {
                if (fields.isSome()) {
                    if (Int32(fields.size) >= 1) {
                        fields[0] = sign
                    }
                    if (Int32(fields.size) >= 2) {
                        fields[1] = hour
                    }
                    if (Int32(fields.size) >= 3) {
                        fields[2] = min
                    }
                    if (Int32(fields.size) >= 4) {
                        fields[3] = sec
                    }
                }
                return true
            }
        }
        return false
    }

    public static func getCustomTimeZone(offset: Int32): SimpleTimeZone {
        var negative = false
        var tmp = offset
        if (offset < 0) {
            negative = true
            tmp = -offset
        }
        let hour: Int32
        let min: Int32
        let sec: Int32
        if (ASSERT) {
            Assert.assrt("millis!=0", tmp % 1000 != 0)
        }
        tmp /= 1000
        sec = tmp % 60
        tmp /= 60
        min = tmp % 60
        hour = tmp / 60
        let zid = formatCustomID(hour, min, sec, negative)
        return SimpleTimeZone(offset, zid)
    }

    static func formatCustomID(hour: Int32, min: Int32, sec: Int32, negative: Bool): String {
        let zid = StringBuilder(kCUSTOM_TZ_PREFIX)
        if (hour != 0 || min != 0) {
            if (negative) {
                zid.append('-')
            } else {
                zid.append('+')
            }
            if (hour < 10) {
                zid.append('0')
            }
            zid.append(hour)
            zid.append(':')
            if (min < 10) {
                zid.append('0')
            }
            zid.append(min)
            if (sec != 0) {
                zid.append(':')
                if (sec < 10) {
                    zid.append('0')
                }
                zid.append(sec)
            }
        }
        return zid.toString()
    }

    public static func getShortID(tz: TimeZone): String {
        var canonicalID: String
        if (checkOptionalIs<OlsonTimeZone, TimeZone>(tz)) {
            canonicalID = tz.getCanonicalID()
        } else {
            canonicalID = getCanonicalCLDRID(tz.getID())
        }
        if (canonicalID.isNone()) {
            return None
        }
        return getShortIDFromCanonical(canonicalID)
    }

    public static func getShortID(id: String): String {
        let canonicalID = getCanonicalCLDRID(id)
        if (canonicalID.isNone()) {
            return None
        }
        return getShortIDFromCanonical(canonicalID)
    }

    private static func getShortIDFromCanonical(canonicalID: String): String {
        var shortID: String
        let tzidKey: String = canonicalID.replace('/'.toString(), ':'.toString())
        try {
            let keyTypeData = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "keyTypeData", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
            let typeMap = keyTypeData.get("typeMap")
            let typeKeys = typeMap.get("timezone")
            shortID = typeKeys.getString(tzidKey)
        } catch (e: MissingResourceException) { }
        return shortID
    }
}


class ZoneMeta_SystemTimeZoneCache <: SoftCache<String, OlsonTimeZone, String> {
    init() {
        super()
    }

    override protected func createInstance(key: String, data: String): OlsonTimeZone {
        var tz: OlsonTimeZone
        try {
            let top = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, ZoneMeta.ZONEINFORESNAME, ICUResourceBundle.ICU_DATA_CLASS_LOADER)
            let res = ZoneMeta.openOlsonResource(top, data)
            if (res.isSome()) {
                tz = OlsonTimeZone(top, res, data)
                tz.freeze()
            }
        } catch (e: MissingResourceException) { }
        return tz
    }
}


class ZoneMeta_CustomTimeZoneCache <: SoftCache<Int32, SimpleTimeZone, Array> {
    init() {
        super()
    }

    override protected func createInstance(key: Int32, data: Array<Int32>): SimpleTimeZone {
        if (!(Int32(data.size) == 4)) {
            throw AssertionError()
        }
        if (!(data[0] == 1 || data[0] == -1)) {
            throw AssertionError()
        }
        if (!(data[1] >= 0 && data[1] <= ZoneMeta.kMAX_CUSTOM_HOUR)) {
            throw AssertionError()
        }
        if (!(data[2] >= 0 && data[2] <= ZoneMeta.kMAX_CUSTOM_MIN)) {
            throw AssertionError()
        }
        if (!(data[3] >= 0 && data[3] <= ZoneMeta.kMAX_CUSTOM_SEC)) {
            throw AssertionError()
        }
        let id = ZoneMeta.formatCustomID(data[1], data[2], data[3], data[0] < 0)
        let offset = data[0] * ((data[1] * 60 + data[2]) * 60 + data[3]) * 1000
        let tz = SimpleTimeZone(offset, id)
        tz.freeze()
        return tz
    }
}
