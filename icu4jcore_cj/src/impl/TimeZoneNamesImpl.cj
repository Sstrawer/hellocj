package icu4cj.impl


public class TimeZoneNamesImpl <: TimeZoneNames & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private static let serialVersionUID = -2179814848495897472

    private static let ZONE_STRINGS_BUNDLE = "zoneStrings"

    static let MZ_PREFIX = "meta:"

     private static var METAZONE_IDS: Set<String>

    private static let TZ_TO_MZS_CACHE = TimeZoneNamesImpl_TZ2MZsCache()

    private static let MZ_TO_TZS_CACHE = TimeZoneNamesImpl_MZ2TZsCache()

     var _zoneStrings: ICUResourceBundle

     var _mzNamesMap: ConcurrentHashMap = None

     var _tzNamesMap: ConcurrentHashMap = None

     private var _namesFullyLoaded: Bool = false

     private var _namesTrie: TextTrieMap<TimeZoneNamesImpl_NameInfo>

     private var _namesTrieFullyLoaded: Bool = false

    public init(locale: ULocale) {
        super()
        initialize(locale)
    }

    public override func getAvailableMetaZoneIDs(): Set<String> {
        return _getAvailableMetaZoneIDs()
    }

    static func _getAvailableMetaZoneIDs(): Set<String> {
        if (METAZONE_IDS.isNone()) {
            synchronized (getMonitorByObject(TypeInfo.of<TimeZoneNamesImpl>())) {
                if (METAZONE_IDS.isNone()) {
                    let bundle = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "metaZones")
                    let mapTimezones = bundle.get("mapTimezones")
                    let keys = mapTimezones.keySet()
                    METAZONE_IDS = Collections.unmodifiableSet(keys)
                }
            }
        }
        return METAZONE_IDS
    }

    public override func getAvailableMetaZoneIDs(tzID: String): Set<String> {
        return _getAvailableMetaZoneIDs(tzID)
    }

    static func _getAvailableMetaZoneIDs(tzID: String): Set<String> {
        if (tzID.isNone() || Int32(tzID.size) == 0) {
            return Collections.emptySet<<--> -->()
        }
        let maps = TZ_TO_MZS_CACHE.getInstance(tzID, tzID)
        if (maps.isEmpty()) {
            return Collections.emptySet<<--> -->()
        }
        let mzIDs: Set<String> = HashSet<String>(maps.size)
        for (map in maps) {
            mzIDs.put(map.mzID())
        }
        return Collections.unmodifiableSet(mzIDs as Set<T>)
    }

    public override func getMetaZoneID(tzID: String, date: Int64): String {
        return _getMetaZoneID(tzID, date)
    }

    static func _getMetaZoneID(tzID: String, date: Int64): String {
        if (tzID.isNone() || Int32(tzID.size) == 0) {
            return None
        }
        var mzID: String
        let maps = TZ_TO_MZS_CACHE.getInstance(tzID, tzID)
        for (map in maps) {
            if (date >= map.comefrom() && date < map.to()) {
                mzID = map.mzID()
                break
            }
        }
        return mzID
    }

    public override func getReferenceZoneID(mzID: String, region: String): String {
        return _getReferenceZoneID(mzID, region)
    }

    static func _getReferenceZoneID(mzID: String, region: String): String {
        if (mzID.isNone() || Int32(mzID.size) == 0) {
            return None
        }
        var refID: String
        let regionTzMap = MZ_TO_TZS_CACHE.getInstance(mzID, mzID)
        if (!regionTzMap.isEmpty()) {
            refID = regionTzMap.get(region)
            if (refID.isNone()) {
                refID = regionTzMap.get("001")
            }
        }
        return refID
    }

    public override func getMetaZoneDisplayName(mzID: String, Type: TimeZoneNames_NameType): String {
        if (mzID.isNone() || Int32(mzID.size) == 0) {
            return None
        }
        return loadMetaZoneNames(mzID).getName(Type)
    }

    public override func getTimeZoneDisplayName(tzID: String, Type: TimeZoneNames_NameType): String {
        if (tzID.isNone() || Int32(tzID.size) == 0) {
            return None
        }
        return loadTimeZoneNames(tzID).getName(Type)
    }

    public override func getExemplarLocationName(tzID: String): String {
        if (tzID.isNone() || Int32(tzID.size) == 0) {
            return None
        }
        let locName = loadTimeZoneNames(tzID).getName(TimeZoneNames_NameType.EXEMPLAR_LOCATION)
        return locName
    }

    public override func find(text: String, start: Int32, nameTypes: EnumSet): Collection<TimeZoneNames_MatchInfo> {
        synchronized (GeneratedLockObject) {
            if (text.isNone() || text.size == 0 || start < 0 || start >= text.size) {
                throw IllegalArgumentException("bad input text or range")
            }
            let handler = TimeZoneNamesImpl_NameSearchHandler(nameTypes)
            var matches: Collection<TimeZoneNames_MatchInfo>
            matches = doFind(handler, text, start)
            if (matches.isSome()) {
                return matches
            }
            addAllNamesIntoTrie()
            matches = doFind(handler, text, start)
            if (matches.isSome()) {
                return matches
            }
            internalLoadAllDisplayNames()
            let tzIDs = TimeZone.getAvailableIDs(TimeZone_SystemTimeZoneType.CANONICAL, None, None)
            for (tzID in tzIDs) {
                if (!_tzNamesMap.contains(tzID)) {
                    TimeZoneNamesImpl_ZNames.createTimeZoneAndPutInCache(_tzNamesMap, None, tzID)
                }
            }
            addAllNamesIntoTrie()
            _namesTrieFullyLoaded = true
            return doFind(handler, text, start)
        }
    }

    private func doFind(handler: TimeZoneNamesImpl_NameSearchHandler, text: String, start: Int32): Collection<TimeZoneNames_MatchInfo> {
        handler.resetResults()
        _namesTrie.find(text, start, handler)
        if (handler.getMaxMatchLen() == (text.size - start) || _namesTrieFullyLoaded) {
            return handler.getMatches()
        }
        return None
    }

    public override func loadAllDisplayNames(): Unit {
        synchronized (GeneratedLockObject) {
            internalLoadAllDisplayNames()
        }
    }

    public override func getDisplayNames(tzID: String, types: Array<TimeZoneNames_NameType>, date: Int64, dest: Array<String>, destOffset: Int32): Unit {
        if (tzID.isNone() || Int32(tzID.size) == 0) {
            return
        }
        let tzNames = loadTimeZoneNames(tzID)
        var mzNames: TimeZoneNamesImpl_ZNames
        var i = 0
        while (i < Int32(types.size)) {
            let Type = types[Int64(i)]
            var name = tzNames.getName(Type)
            if (name.isNone()) {
                if (mzNames.isNone()) {
                    let mzID = getMetaZoneID(tzID, date)
                    if (mzID.isNone() || Int32(mzID.size) == 0) {
                        mzNames = TimeZoneNamesImpl_ZNames.EMPTY_ZNAMES
                    } else {
                        mzNames = loadMetaZoneNames(mzID)
                    }
                }
                name = mzNames.getName(Type)
            }
            dest[Int64(destOffset + i)] = name
            i++
        }
    }

    private func internalLoadAllDisplayNames(): Unit {
        if (!_namesFullyLoaded) {
            _namesFullyLoaded = true
            TimeZoneNamesImpl_ZoneStringsLoader(this).load()
        }
    }

    private func addAllNamesIntoTrie(): Unit {
        for (entry in _tzNamesMap.entrySet()) {
            entry.getValue().addAsTimeZoneIntoTrie(entry.getKey(), _namesTrie)
        }
        for (entry in _mzNamesMap.entrySet()) {
            entry.getValue().addAsMetaZoneIntoTrie(entry.getKey(), _namesTrie)
        }
    }

    private func initialize(locale: ULocale): Unit {
        let bundle = ICUResourceBundle.getBundleInstance(ICUData.ICU_ZONE_BASE_NAME, locale)
        _zoneStrings = bundle.get(ZONE_STRINGS_BUNDLE)
        _tzNamesMap = ConcurrentHashMap()
        _mzNamesMap = ConcurrentHashMap()
        _namesFullyLoaded = false
        _namesTrie = TextTrieMap<TimeZoneNamesImpl_NameInfo>(true)
        _namesTrieFullyLoaded = false
        let tz = TimeZone.getDefault()
        let tzCanonicalID = ZoneMeta.getCanonicalCLDRID(tz)
        if (tzCanonicalID.isSome()) {
            loadStrings(tzCanonicalID)
        }
    }

    private func loadStrings(tzCanonicalID: String): Unit {
        synchronized (GeneratedLockObject) {
            if (tzCanonicalID.isNone() || Int32(tzCanonicalID.size) == 0) {
                return
            }
            loadTimeZoneNames(tzCanonicalID)
            let mzIDs = getAvailableMetaZoneIDs(tzCanonicalID)
            for (mzID in mzIDs) {
                loadMetaZoneNames(mzID)
            }
        }
    }

    private func writeObject(out: ObjectOutputStream): Unit {
        let locale = _zoneStrings.getULocale()
        out.writeObject(locale)
    }

    private func readObject(input: ObjectInputStream): Unit {
        let locale = input.readObject()
        initialize(locale)
    }

    private func loadMetaZoneNames(mzID: String): TimeZoneNamesImpl_ZNames {
        synchronized (GeneratedLockObject) {
            var mznames = _mzNamesMap.get(mzID)
            if (mznames.isNone()) {
                let loader = TimeZoneNamesImpl_ZNamesLoader()
                loader.loadMetaZone(_zoneStrings, mzID)
                mznames = TimeZoneNamesImpl_ZNames.createMetaZoneAndPutInCache(_mzNamesMap, loader.getNames(), mzID)
            }
            return mznames
        }
    }

    private func loadTimeZoneNames(tzID: String): TimeZoneNamesImpl_ZNames {
        synchronized (GeneratedLockObject) {
            var tznames = _tzNamesMap.get(tzID)
            if (tznames.isNone()) {
                let loader = TimeZoneNamesImpl_ZNamesLoader()
                loader.loadTimeZone(_zoneStrings, tzID)
                tznames = TimeZoneNamesImpl_ZNames.createTimeZoneAndPutInCache(_tzNamesMap, loader.getNames(), tzID)
            }
            return tznames
        }
    }

    private static let LOC_EXCLUSION_PATTERN = Pattern.compile("Etc/.*|SystemV/.*|.*/Riyadh8[7-9]")

    public static func getDefaultExemplarLocationName(tzID: String): String {
        if (tzID.isNone() || Int32(tzID.size) == 0 || LOC_EXCLUSION_PATTERN.matcher(tzID).matches()) {
            return None
        }
        var location: String
        let sep = indexOfWrap(tzID.lastIndexOf(UInt8(UInt32('/'))))
        if (sep > 0 && sep + 1 < Int32(tzID.size)) {
            location = tzID[Int64(sep + 1)..].replace('_'.toString(), ' '.toString())
        }
        return location
    }
}


class TimeZoneNamesImpl_ZoneStringsLoader <: UResource_Sink {
    let this_0: TimeZoneNamesImpl

    init(this_0: TimeZoneNamesImpl) {
        super()
        this.this_0 = this_0
    }

    private static let INITIAL_NUM_ZONES = 300

    private var keyToLoader: HashMap<UResource_Key, TimeZoneNamesImpl_ZNamesLoader> = HashMap<UResource_Key, TimeZoneNamesImpl_ZNamesLoader>(Int64(INITIAL_NUM_ZONES))

    private var sb: StringBuilder = StringBuilder()

    public func load(): Unit {
        this_0._zoneStrings.getAllItemsWithFallback("", this)
        for (entry in keyToLoader.entrySet()) {
            let loader = entry.getValue()
            if (refEq(loader, TimeZoneNamesImpl_ZNamesLoader.DUMMY_LOADER)) {
                continue
            }
            let key = entry.getKey()
            if (isMetaZone(key)) {
                let mzID = mzIDFromKey(key)
                TimeZoneNamesImpl_ZNames.createMetaZoneAndPutInCache(this_0._mzNamesMap, loader.getNames(), mzID)
            } else {
                let tzID = tzIDFromKey(key)
                TimeZoneNamesImpl_ZNames.createTimeZoneAndPutInCache(this_0._tzNamesMap, loader.getNames(), tzID)
            }
        }
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let timeZonesTable = value.getTable()
        var j = 0
        while (timeZonesTable.getKeyAndValue(j, key, value)) {
            if (!(!value.isNoInheritanceMarker())) {
                throw AssertionError()
            }
            if (value.getType() == UResourceBundle.TABLE) {
                consumeNamesTable(key, value, noFallback)
            } else { }
            j++
        }
    }

    private func consumeNamesTable(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        var loader = keyToLoader.get(key)
        if (loader.isNone()) {
            if (isMetaZone(key)) {
                let mzID = mzIDFromKey(key)
                if (this_0._mzNamesMap.contains(mzID)) {
                    loader = TimeZoneNamesImpl_ZNamesLoader.DUMMY_LOADER
                } else {
                    loader = TimeZoneNamesImpl_ZNamesLoader()
                }
            } else {
                let tzID = tzIDFromKey(key)
                if (this_0._tzNamesMap.contains(tzID)) {
                    loader = TimeZoneNamesImpl_ZNamesLoader.DUMMY_LOADER
                } else {
                    loader = TimeZoneNamesImpl_ZNamesLoader()
                }
            }
            let newKey = createKey(key)
            keyToLoader.put(newKey, loader)
        }
        if (!refEq(loader, TimeZoneNamesImpl_ZNamesLoader.DUMMY_LOADER)) {
            loader.put(key, value, noFallback)
        }
    }

    public func createKey(key: UResource_Key): UResource_Key {
        return key.clone()
    }

    public func isMetaZone(key: UResource_Key): Bool {
        return key.startsWith(TimeZoneNamesImpl.MZ_PREFIX)
    }

    private func mzIDFromKey(key: UResource_Key): String {
        sb.setLength(0)
        var i = Int32(TimeZoneNamesImpl.MZ_PREFIX.size)
        while (i < key.lengthMethod()) {
            sb.append(key.toRuneArray()[i])
            i++
        }
        return sb.toString()
    }

    private func tzIDFromKey(key: UResource_Key): String {
        sb.setLength(0)
        var i = 0
        while (i < key.lengthMethod()) {
            var c = key.toRuneArray()[i]
            if (c == ':') {
                c = '/'
            }
            sb.append(c)
            i++
        }
        return sb.toString()
    }
}


class TimeZoneNamesImpl_NameInfo {

    var tzID: String

    var mzID: String

    var Type: TimeZoneNames_NameType
}


class TimeZoneNamesImpl_NameSearchHandler <: TextTrieMap_ResultHandler<TimeZoneNamesImpl_NameInfo> {
    private var _nameTypes: EnumSet = None

    private var _matches: Collection<TimeZoneNames_MatchInfo>

    private var _maxMatchLen: Int32 = 0

    init(nameTypes: EnumSet) {
        _nameTypes = nameTypes
    }

    public override func handlePrefixMatch(matchLength: Int32, values: Iterator<TimeZoneNamesImpl_NameInfo>): Bool {
        while (values.hasNext()) {
            let ninfo = values.next()
            if (_nameTypes.isSome() && !_nameTypes.contains(ninfo.Type)) {
                continue
            }
            let minfo: TimeZoneNames_MatchInfo
            if (ninfo.tzID.isSome()) {
                minfo = TimeZoneNames_MatchInfo(ninfo.Type, ninfo.tzID, None, matchLength)
            } else {
                if (!(ninfo.mzID.isSome())) {
                    throw AssertionError()
                }
                minfo = TimeZoneNames_MatchInfo(ninfo.Type, None, ninfo.mzID, matchLength)
            }
            if (_matches.isNone()) {
                _matches = LinkedList<TimeZoneNames_MatchInfo>()
            }
            _matches.add(minfo)
            if (matchLength > _maxMatchLen) {
                _maxMatchLen = matchLength
            }
        }
        return true
    }

    public func getMatches(): Collection<TimeZoneNames_MatchInfo> {
        if (_matches.isNone()) {
            return Array<String>(0, { _ => "" })
        }
        return _matches
    }

    public func getMaxMatchLen(): Int32 {
        return _maxMatchLen
    }

    public func resetResults(): Unit {
        _matches = None
        _maxMatchLen = 0
    }
}


class TimeZoneNamesImpl_ZNamesLoader <: UResource_Sink {
    init() {
        super()
    }

    private var names: Array<String>

    static var DUMMY_LOADER: TimeZoneNamesImpl_ZNamesLoader = TimeZoneNamesImpl_ZNamesLoader()

    public func loadMetaZone(zoneStrings: ICUResourceBundle, mzID: String): Unit {
        let key: String = TimeZoneNamesImpl.MZ_PREFIX + (mzID)
        loadNames(zoneStrings, key)
    }

    public func loadTimeZone(zoneStrings: ICUResourceBundle, tzID: String): Unit {
        let key: String = tzID.replace('/'.toString(), ':'.toString())
        loadNames(zoneStrings, key)
    }

    public func loadNames(zoneStrings: ICUResourceBundle, key: String): Unit {
        if (!zoneStrings.isSome()) {
            throw AssertionError()
        }
        if (!key.isSome()) {
            throw AssertionError()
        }
        if (!(Int32(key.size) > 0)) {
            throw AssertionError()
        }
        names = None
        try {
            zoneStrings.getAllItemsWithFallback(key, this)
        } catch (e: MissingResourceException) { }
    }

    private static func nameTypeIndexFromKey(key: UResource_Key): TimeZoneNamesImpl_ZNames_NameTypeIndex {
        if (key.lengthMethod() != 2) {
            return None
        }
        let c0 = key.toRuneArray()[0]
        let c1 = key.toRuneArray()[1]
        if (c0 == 'l') {
            return if (c1 == 'g') { TimeZoneNamesImpl_ZNames_NameTypeIndex.LONG_GENERIC } else { if (c1 == 's') { TimeZoneNamesImpl_ZNames_NameTypeIndex.LONG_STANDARD } else { if (c1 == 'd') { TimeZoneNamesImpl_ZNames_NameTypeIndex.LONG_DAYLIGHT } else { None } } }
        } else if (c0 == 's') {
            return if (c1 == 'g') { TimeZoneNamesImpl_ZNames_NameTypeIndex.SHORT_GENERIC } else { if (c1 == 's') { TimeZoneNamesImpl_ZNames_NameTypeIndex.SHORT_STANDARD } else { if (c1 == 'd') { TimeZoneNamesImpl_ZNames_NameTypeIndex.SHORT_DAYLIGHT } else { None } } }
        } else if (c0 == 'e' && c1 == 'c') {
            return TimeZoneNamesImpl_ZNames_NameTypeIndex.EXEMPLAR_LOCATION
        }
        return None
    }

    private func setNameIfEmpty(key: UResource_Key, value: UResource_Value): Unit {
        if (names.isNone()) {
            names = Array<String>(Int64(TimeZoneNamesImpl_ZNames.NUM_NAME_TYPES))
        }
        let index = nameTypeIndexFromKey(key)
        if (index.isNone()) {
            return
        }
        if (!(index.ordinal < TimeZoneNamesImpl_ZNames.NUM_NAME_TYPES)) {
            throw AssertionError()
        }
        if (names[Int64(index.ordinal)].isNone()) {
            names[Int64(index.ordinal)] = value.getString()
        }
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let namesTable = value.getTable()
        var i = 0
        while (namesTable.getKeyAndValue(i, key, value)) {
            if (!(value.getType() == UResourceBundle.STRING)) {
                throw AssertionError()
            }
            setNameIfEmpty(key, value)
            i++
        }
    }

    public func getNames(): Array<String> {
        if (Utility.sameObjects(names, None)) {
            return None
        }
        var length = 0
        var i = 0
        while (i < TimeZoneNamesImpl_ZNames.NUM_NAME_TYPES) {
            let name = names[Int64(i)]
            if (name.isSome()) {
                if (name.equals(ICUResourceBundle.NO_INHERITANCE_MARKER)) {
                    names[Int64(i)] = None
                } else {
                    length = i + 1
                }
            }
            i++
        }
        let result: Array<String>
        if (length == TimeZoneNamesImpl_ZNames.NUM_NAME_TYPES) {
            result = names
        } else if (length == 0) {
            result = None
        } else {
            result = names.clone(0..length)
        }
        return result
    }
}


class TimeZoneNamesImpl_ZNames {
    public static let NUM_NAME_TYPES = 7

    private static func getNameTypeIndex(Type: TimeZoneNames_NameType): Int32 {
        match (Type) {
            case TimeZoneNames_NameType.EXEMPLAR_LOCATION => return TimeZoneNamesImpl_ZNames_NameTypeIndex.EXEMPLAR_LOCATION.ordinal
            case TimeZoneNames_NameType.LONG_GENERIC => return TimeZoneNamesImpl_ZNames_NameTypeIndex.LONG_GENERIC.ordinal
            case TimeZoneNames_NameType.LONG_STANDARD => return TimeZoneNamesImpl_ZNames_NameTypeIndex.LONG_STANDARD.ordinal
            case TimeZoneNames_NameType.LONG_DAYLIGHT => return TimeZoneNamesImpl_ZNames_NameTypeIndex.LONG_DAYLIGHT.ordinal
            case TimeZoneNames_NameType.SHORT_GENERIC => return TimeZoneNamesImpl_ZNames_NameTypeIndex.SHORT_GENERIC.ordinal
            case TimeZoneNames_NameType.SHORT_STANDARD => return TimeZoneNamesImpl_ZNames_NameTypeIndex.SHORT_STANDARD.ordinal
            case TimeZoneNames_NameType.SHORT_DAYLIGHT => return TimeZoneNamesImpl_ZNames_NameTypeIndex.SHORT_DAYLIGHT.ordinal
            case _ => throw Exception("No NameTypeIndex match for " + Type.asString())
        }
    }

    private static func getNameType(index: Int32): TimeZoneNames_NameType {
        match (TimeZoneNamesImpl_ZNames_NameTypeIndex.values[Int64(index)]) {
            case TimeZoneNamesImpl_ZNames_NameTypeIndex.EXEMPLAR_LOCATION => return TimeZoneNames_NameType.EXEMPLAR_LOCATION
            case TimeZoneNamesImpl_ZNames_NameTypeIndex.LONG_GENERIC => return TimeZoneNames_NameType.LONG_GENERIC
            case TimeZoneNamesImpl_ZNames_NameTypeIndex.LONG_STANDARD => return TimeZoneNames_NameType.LONG_STANDARD
            case TimeZoneNamesImpl_ZNames_NameTypeIndex.LONG_DAYLIGHT => return TimeZoneNames_NameType.LONG_DAYLIGHT
            case TimeZoneNamesImpl_ZNames_NameTypeIndex.SHORT_GENERIC => return TimeZoneNames_NameType.SHORT_GENERIC
            case TimeZoneNamesImpl_ZNames_NameTypeIndex.SHORT_STANDARD => return TimeZoneNames_NameType.SHORT_STANDARD
            case TimeZoneNamesImpl_ZNames_NameTypeIndex.SHORT_DAYLIGHT => return TimeZoneNames_NameType.SHORT_DAYLIGHT
            case _ => throw Exception("No NameType match for " + index.toString())
        }
    }

    static let EMPTY_ZNAMES = TimeZoneNamesImpl_ZNames(None)

    private static let EX_LOC_INDEX = TimeZoneNamesImpl_ZNames_NameTypeIndex.EXEMPLAR_LOCATION.ordinal

    private var _names: Array<String>

    private var didAddIntoTrie: Bool = false

    protected init(names: Array<String>) {
        _names = names
        didAddIntoTrie = names.isNone()
    }

    public static func createMetaZoneAndPutInCache(cache: Map<String, TimeZoneNamesImpl_ZNames>, names: Array<String>, mzID: String): TimeZoneNamesImpl_ZNames {
        let key = mzID.intern()
        let value: TimeZoneNamesImpl_ZNames
        if (names.isNone()) {
            value = EMPTY_ZNAMES
        } else {
            value = TimeZoneNamesImpl_ZNames(names)
        }
        cache.put(key, value)
        return value
    }

    public static func createTimeZoneAndPutInCache(cache: Map<String, TimeZoneNamesImpl_ZNames>, names: Array<String>, tzID: String): TimeZoneNamesImpl_ZNames {
        var tempnames = names
        tempnames = if (tempnames.isNone()) { Array<String>(Int64(EX_LOC_INDEX + 1)) } else { tempnames }
        if (tempnames[Int64(EX_LOC_INDEX)].isNone()) {
            tempnames[Int64(EX_LOC_INDEX)] = TimeZoneNamesImpl.getDefaultExemplarLocationName(tzID)
        }
        let key = tzID.intern()
        let value = TimeZoneNamesImpl_ZNames(tempnames)
        cache.put(key, value)
        return value
    }

    public func getName(Type: TimeZoneNames_NameType): String {
        let index = getNameTypeIndex(Type)
        if (_names.isSome() && index < Int32(_names.size)) {
            return _names[Int64(index)]
        } else {
            return None
        }
    }

    public func addAsMetaZoneIntoTrie(mzID: String, trie: TextTrieMap<TimeZoneNamesImpl_NameInfo>): Unit {
        addNamesIntoTrie(mzID, None, trie)
    }

    public func addAsTimeZoneIntoTrie(tzID: String, trie: TextTrieMap<TimeZoneNamesImpl_NameInfo>): Unit {
        addNamesIntoTrie(None, tzID, trie)
    }

    private func addNamesIntoTrie(mzID: String, tzID: String, trie: TextTrieMap<TimeZoneNamesImpl_NameInfo>): Unit {
        if (_names.isNone() || didAddIntoTrie) {
            return
        }
        didAddIntoTrie = true
        var i = 0
        while (i < Int32(_names.size)) {
            let name = _names[Int64(i)]
            if (name.isSome()) {
                let info = TimeZoneNamesImpl_NameInfo()
                info.mzID = mzID
                info.tzID = tzID
                info.Type = getNameType(i)
                trie.put(name, info)
            }
            i++
        }
    }
}


class TimeZoneNamesImpl_ZNames_NameTypeIndex <: Enum<TimeZoneNamesImpl_ZNames_NameTypeIndex> {
    public static let EXEMPLAR_LOCATION = TimeZoneNamesImpl_ZNames_NameTypeIndex("EXEMPLAR_LOCATION", 0)

    public static let LONG_GENERIC = TimeZoneNamesImpl_ZNames_NameTypeIndex("LONG_GENERIC", 1)

    public static let LONG_STANDARD = TimeZoneNamesImpl_ZNames_NameTypeIndex("LONG_STANDARD", 2)

    public static let LONG_DAYLIGHT = TimeZoneNamesImpl_ZNames_NameTypeIndex("LONG_DAYLIGHT", 3)

    public static let SHORT_GENERIC = TimeZoneNamesImpl_ZNames_NameTypeIndex("SHORT_GENERIC", 4)

    public static let SHORT_STANDARD = TimeZoneNamesImpl_ZNames_NameTypeIndex("SHORT_STANDARD", 5)

    public static let SHORT_DAYLIGHT = TimeZoneNamesImpl_ZNames_NameTypeIndex("SHORT_DAYLIGHT", 6)

    private static func _values(): Array<TimeZoneNamesImpl_ZNames_NameTypeIndex> {
        return [TimeZoneNamesImpl_ZNames_NameTypeIndex.EXEMPLAR_LOCATION, TimeZoneNamesImpl_ZNames_NameTypeIndex.LONG_GENERIC, TimeZoneNamesImpl_ZNames_NameTypeIndex.LONG_STANDARD, TimeZoneNamesImpl_ZNames_NameTypeIndex.LONG_DAYLIGHT, TimeZoneNamesImpl_ZNames_NameTypeIndex.SHORT_GENERIC, TimeZoneNamesImpl_ZNames_NameTypeIndex.SHORT_STANDARD, TimeZoneNamesImpl_ZNames_NameTypeIndex.SHORT_DAYLIGHT]
    }

    private static let _VALUES = TimeZoneNamesImpl_ZNames_NameTypeIndex._values()

    public static func valuesStatic(): Array<TimeZoneNamesImpl_ZNames_NameTypeIndex> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): TimeZoneNamesImpl_ZNames_NameTypeIndex {
        return (TypeInfo.of<TimeZoneNamesImpl_ZNames_NameTypeIndex>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as TimeZoneNamesImpl_ZNames_NameTypeIndex
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    static let values = valuesStatic()
}


class TimeZoneNamesImpl_MZMapEntry {
    private var _mzID: String

    private var _from: Int64 = 0

    private var _to: Int64 = 0

    init(mzID: String, comefrom: Int64, to: Int64) {
        _mzID = mzID
        _from = comefrom
        _to = to
    }

    public func mzID(): String {
        return _mzID
    }

    public func comefrom(): Int64 {
        return _from
    }

    public func to(): Int64 {
        return _to
    }
}


class TimeZoneNamesImpl_TZ2MZsCache {
    init() {
        super()
    }

    override protected func createInstance(key: String, data: String): ArrayList<TimeZoneNamesImpl_MZMapEntry> {
        var mzMaps: ArrayList<TimeZoneNamesImpl_MZMapEntry>
        let bundle = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "metaZones")
        let metazoneInfoBundle = bundle.get("metazoneInfo")
        let tzkey: String = data.replace('/'.toString(), ':'.toString())
        try {
            let zoneBundle = metazoneInfoBundle.get(tzkey)
            mzMaps = ArrayList<TimeZoneNamesImpl_MZMapEntry>(Int64(zoneBundle.getSize()))
            var idx = 0
            while (idx < zoneBundle.getSize()) {
                let mz = zoneBundle.get(idx)
                let mzid = mz.getString(0)
                var fromStr: String = "1970-01-01 00:00"
                var toStr: String = "9999-12-31 23:59"
                if (mz.getSize() == 3) {
                    fromStr = mz.getString(1)
                    toStr = mz.getString(2)
                }
                let comefrom: Int64
                let to: Int64
                comefrom = parseDate(fromStr)
                to = parseDate(toStr)
                mzMaps.append(TimeZoneNamesImpl_MZMapEntry(mzid, comefrom, to))
                idx++
            }
        } catch (mre: MissingResourceException) {
            mzMaps = Array<String>(0, { _ => "" })
        }
        return mzMaps
    }

    private static func parseDate(text: String): Int64 {
        var year = 0
        var month = 0
        var day = 0
        var hour = 0
        var min = 0
        var idx: Int32 = 0
        var n: Int32 = 0
        idx = 0
        while (idx <= 3) {
            n = 
            if (n >= 0 && n < 10) {
                year = 10 * year + n
            } else {
                throw IllegalArgumentException("Bad year")
            }
            idx++
        }
        idx = 5
        while (idx <= 6) {
            n = 
            if (n >= 0 && n < 10) {
                month = 10 * month + n
            } else {
                throw IllegalArgumentException("Bad month")
            }
            idx++
        }
        idx = 8
        while (idx <= 9) {
            n = 
            if (n >= 0 && n < 10) {
                day = 10 * day + n
            } else {
                throw IllegalArgumentException("Bad day")
            }
            idx++
        }
        idx = 11
        while (idx <= 12) {
            n = 
            if (n >= 0 && n < 10) {
                hour = 10 * hour + n
            } else {
                throw IllegalArgumentException("Bad hour")
            }
            idx++
        }
        idx = 14
        while (idx <= 15) {
            n = 
            if (n >= 0 && n < 10) {
                min = 10 * min + n
            } else {
                throw IllegalArgumentException("Bad minute")
            }
            idx++
        }
        let date = Grego.fieldsToDay(year, month - 1, day) * Int64(Grego.MILLIS_PER_DAY) + Int64(hour) * Int64(Grego.MILLIS_PER_HOUR) + Int64(min) * Int64(Grego.MILLIS_PER_MINUTE)
        return date
    }
}


class TimeZoneNamesImpl_MZ2TZsCache {
    init() {
        super()
    }

    override protected func createInstance(key: String, data: String): Map<String, String> {
        var map: Map<String, String> = None
        let bundle = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "metaZones")
        let mapTimezones = bundle.get("mapTimezones")
        try {
            let regionMap = mapTimezones.get(key)
            let regions = regionMap.keySet()
            map = HashMap<String, String>(regions.size)
            for (region in regions) {
                let tzID = regionMap.getString(region).intern()
                map.put(region.intern(), tzID)
            }
        } catch (e: MissingResourceException) {
            map = Collections.emptyMap<<--, // Cannot infer type argument: V -->>()
        }
        return map
    }
}
