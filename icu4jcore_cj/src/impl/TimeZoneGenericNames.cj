package icu4cj.impl


public class TimeZoneGenericNames <: Serializable & Freezable<TimeZoneGenericNames> & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private static let serialVersionUID = 2729910342063468417

    private let _locale: ULocale

    private var _tznames: TimeZoneNames

      private var _frozen: Bool = false

     private var _region: String

     private var _localeDisplayNamesRef: WeakReference = None

     private var _patternFormatters: Array<MessageFormat> = None

     private var _genericLocationNamesMap: ConcurrentHashMap = None

     private var _genericPartialLocationNamesMap: ConcurrentHashMap = None

     private var _gnamesTrie: TextTrieMap<TimeZoneGenericNames_NameInfo>

     private var _gnamesTrieFullyLoaded: Bool = false

    private static var GENERIC_NAMES_CACHE: TimeZoneGenericNames_Cache = TimeZoneGenericNames_Cache()

    private static let DST_CHECK_RANGE = 184 * (Int64(24 * 60 * 60 * 1000))

    private static let GENERIC_NON_LOCATION_TYPES: Array<TimeZoneNames_NameType> = [TimeZoneNames_NameType.LONG_GENERIC, TimeZoneNames_NameType.SHORT_GENERIC]

    public init(locale: ULocale, tznames: TimeZoneNames) {
        _locale = locale
        _tznames = tznames
        initself()
    }

    private func initself(): Unit {
        if (_tznames.isNone()) {
            _tznames = TimeZoneNames.getInstance(_locale)
        }
        _genericLocationNamesMap = ConcurrentHashMap()
        _genericPartialLocationNamesMap = ConcurrentHashMap()
        _gnamesTrie = TextTrieMap<TimeZoneGenericNames_NameInfo>(true)
        _gnamesTrieFullyLoaded = false
        let tz = TimeZone.getDefault()
        let tzCanonicalID = ZoneMeta.getCanonicalCLDRID(tz)
        if (tzCanonicalID.isSome()) {
            loadStrings(tzCanonicalID)
        }
    }

    init(locale: ULocale) {
        this(locale, None)
    }

    public static func getInstance(locale: ULocale): TimeZoneGenericNames {
        let key = locale.getBaseName()
        return GENERIC_NAMES_CACHE.getInstance(key, locale)
    }

    public func getDisplayName(tz: TimeZone, Type: TimeZoneGenericNames_GenericNameType, date: Int64): String {
        var name: String
        var tzCanonicalID: String
        match (Type) {
            case TimeZoneGenericNames_GenericNameType.LOCATION =>
                tzCanonicalID = ZoneMeta.getCanonicalCLDRID(tz)
                if (tzCanonicalID.isSome()) {
                    name = getGenericLocationName(tzCanonicalID)
                }
            case TimeZoneGenericNames_GenericNameType.LONG | TimeZoneGenericNames_GenericNameType.SHORT =>
                name = formatGenericNonLocationName(tz, Type, date)
                if (name.isNone()) {
                    tzCanonicalID = ZoneMeta.getCanonicalCLDRID(tz)
                    if (tzCanonicalID.isSome()) {
                        name = getGenericLocationName(tzCanonicalID)
                    }
                }
            case _ => ()
        }
        return name
    }

    public func getGenericLocationName(canonicalTzID: String): String {
        var tempcanonicalTzID = canonicalTzID
        if (tempcanonicalTzID.isNone() || Int32(tempcanonicalTzID.size) == 0) {
            return None
        }
        var name = _genericLocationNamesMap.get(tempcanonicalTzID)
        if (name.isSome()) {
            if (Int32(name.size) == 0) {
                return None
            }
            return name
        }
        let isPrimary = Output<Bool>()
        let countryCode = ZoneMeta.getCanonicalCountry(tempcanonicalTzID, isPrimary)
        if (countryCode.isSome()) {
            if (isPrimary.value) {
                let country = getLocaleDisplayNames().regionDisplayName(countryCode)
                name = formatPattern(TimeZoneGenericNames_Pattern.REGION_FORMAT, [country])
            } else {
                let city = _tznames.getExemplarLocationName(tempcanonicalTzID)
                name = formatPattern(TimeZoneGenericNames_Pattern.REGION_FORMAT, [city])
            }
        }
        if (name.isNone()) {
            _genericLocationNamesMap.putIfAbsent(tempcanonicalTzID.intern(), "")
        } else {
            synchronized (getMonitorByObject(this)) {
                tempcanonicalTzID = tempcanonicalTzID.intern()
                let tmp = _genericLocationNamesMap.putIfAbsent(tempcanonicalTzID, name.intern())
                if (tmp.isNone()) {
                    let info = TimeZoneGenericNames_NameInfo(tempcanonicalTzID, TimeZoneGenericNames_GenericNameType.LOCATION)
                    _gnamesTrie.put(name, info)
                } else {
                    name = tmp
                }
            }
        }
        return name
    }

    public func setFormatPattern(patType: TimeZoneGenericNames_Pattern, patStr: String): TimeZoneGenericNames {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify frozen object")
        }
        if (!_genericLocationNamesMap.isEmpty()) {
            _genericLocationNamesMap = ConcurrentHashMap()
        }
        if (!_genericPartialLocationNamesMap.isEmpty()) {
            _genericPartialLocationNamesMap = ConcurrentHashMap()
        }
        _gnamesTrie = None
        _gnamesTrieFullyLoaded = false
        if (_patternFormatters.isNone()) {
            _patternFormatters = Array<MessageFormat>(TimeZoneGenericNames_Pattern.values().size)
        }
        _patternFormatters[Int64(patType.ordinal)] = MessageFormat(patStr)
        return this
    }

    private func formatGenericNonLocationName(tz: TimeZone, Type: TimeZoneGenericNames_GenericNameType, date: Int64): String {
        if (!(refEq(Type, TimeZoneGenericNames_GenericNameType.LONG) || refEq(Type, TimeZoneGenericNames_GenericNameType.SHORT))) {
            throw AssertionError()
        }
        let tzID = ZoneMeta.getCanonicalCLDRID(tz)
        if (tzID.isNone()) {
            return None
        }
        let nameType: TimeZoneNames_NameType = if (refEq(Type, TimeZoneGenericNames_GenericNameType.LONG)) { TimeZoneNames_NameType.LONG_GENERIC } else { TimeZoneNames_NameType.SHORT_GENERIC }
        var name = _tznames.getTimeZoneDisplayName(tzID, nameType)
        if (name.isSome()) {
            return name
        }
        let mzID = _tznames.getMetaZoneID(tzID, date)
        if (mzID.isSome()) {
            var useStandard = false
            let offsets = [0, 0]
            tz.getOffset(date, false, offsets)
            if (offsets[1] == 0) {
                useStandard = true
                if (checkOptionalIs<BasicTimeZone, TimeZone>(tz)) {
                    let btz = tz
                    let before = btz.getPreviousTransition(date, true)
                    if (before.isSome() && (date - before.getTime() < DST_CHECK_RANGE) && before.getFrom().getDSTSavings() != 0) {
                        useStandard = false
                    } else {
                        let after = btz.getNextTransition(date, false)
                        if (after.isSome() && (after.getTime() - date < DST_CHECK_RANGE) && after.getTo().getDSTSavings() != 0) {
                            useStandard = false
                        }
                    }
                } else {
                    let tmpOffsets = Array<Int32>(2) { _ => 0 }
                    tz.getOffset(date - DST_CHECK_RANGE, false, tmpOffsets)
                    if (tmpOffsets[1] != 0) {
                        useStandard = false
                    } else {
                        tz.getOffset(date + DST_CHECK_RANGE, false, tmpOffsets)
                        if (tmpOffsets[1] != 0) {
                            useStandard = false
                        }
                    }
                }
            }
            if (useStandard) {
                let stdNameType: TimeZoneNames_NameType = if (refEq(nameType, TimeZoneNames_NameType.LONG_GENERIC)) { TimeZoneNames_NameType.LONG_STANDARD } else { TimeZoneNames_NameType.SHORT_STANDARD }
                let stdName = _tznames.getDisplayName(tzID, stdNameType, date)
                if (stdName.isSome()) {
                    name = stdName
                    let mzGenericName = _tznames.getMetaZoneDisplayName(mzID, nameType)
                    if (stdName.equalsIgnoreCase(mzGenericName)) {
                        name = None
                    }
                }
            }
            if (name.isNone()) {
                let mzName = _tznames.getMetaZoneDisplayName(mzID, nameType)
                if (mzName.isSome()) {
                    let goldenID = _tznames.getReferenceZoneID(mzID, getTargetRegion())
                    if (goldenID.isSome() && !goldenID.equals(tzID)) {
                        let goldenZone = TimeZone.getFrozenTimeZone(goldenID)
                        let offsets1 = [0, 0]
                        goldenZone.getOffset(date + Int64(offsets[0]) + Int64(offsets[1]), true, offsets1)
                        if (offsets[0] != offsets1[0] || offsets[1] != offsets1[1]) {
                            name = getPartialLocationName(tzID, mzID, (refEq(nameType, TimeZoneNames_NameType.LONG_GENERIC)), mzName)
                        } else {
                            name = mzName
                        }
                    } else {
                        name = mzName
                    }
                }
            }
        }
        return name
    }

    private func formatPattern(pat: TimeZoneGenericNames_Pattern, args: Array<String>): String {
        synchronized (GeneratedLockObject) {
            if (_patternFormatters.isNone()) {
                _patternFormatters = Array<MessageFormat>(TimeZoneGenericNames_Pattern.values().size)
            }
            let idx = pat.ordinal
            if (_patternFormatters[Int64(idx)].isNone()) {
                var patText: String
                try {
                    let bundle = ICUResourceBundle.getBundleInstance(ICUData.ICU_ZONE_BASE_NAME, _locale)
                    patText = bundle.getStringWithFallback("zoneStrings/" + (pat.key()))
                } catch (e: MissingResourceException) {
                    patText = pat.defaultValue()
                }
                _patternFormatters[Int64(idx)] = MessageFormat(patText)
            }
            return _patternFormatters[Int64(idx)].format(args)
        }
    }

    private func getLocaleDisplayNames(): LocaleDisplayNames {
        synchronized (GeneratedLockObject) {
            var locNames: LocaleDisplayNames
            if (_localeDisplayNamesRef.isSome()) {
                locNames = _localeDisplayNamesRef.get()
            }
            if (locNames.isNone()) {
                locNames = LocaleDisplayNames.getInstance(_locale)
                _localeDisplayNamesRef = WeakReference(locNames)
            }
            return locNames
        }
    }

    private func loadStrings(tzCanonicalID: String): Unit {
        synchronized (GeneratedLockObject) {
            if (tzCanonicalID.isNone() || Int32(tzCanonicalID.size) == 0) {
                return
            }
            getGenericLocationName(tzCanonicalID)
            let mzIDs = _tznames.getAvailableMetaZoneIDs(tzCanonicalID)
            for (mzID in mzIDs) {
                let goldenID = _tznames.getReferenceZoneID(mzID, getTargetRegion())
                if (!tzCanonicalID.equals(goldenID)) {
                    for (genNonLocType in GENERIC_NON_LOCATION_TYPES) {
                        let mzGenName = _tznames.getMetaZoneDisplayName(mzID, genNonLocType)
                        if (mzGenName.isSome()) {
                            getPartialLocationName(tzCanonicalID, mzID, (refEq(genNonLocType, TimeZoneNames_NameType.LONG_GENERIC)), mzGenName)
                        }
                    }
                }
            }
        }
    }

    private func getTargetRegion(): String {
        synchronized (GeneratedLockObject) {
            if (_region.isNone()) {
                _region = _locale.getCountry()
                if (Int32(_region.size) == 0) {
                    let tmp = ULocale.addLikelySubtags(_locale)
                    _region = tmp.getCountry()
                    if (Int32(_region.size) == 0) {
                        _region = "001"
                    }
                }
            }
            return _region
        }
    }

    private func getPartialLocationName(tzID: String, mzID: String, isLong: Bool, mzDisplayName: String): String {
        let letter: String = if (isLong) { "L" } else { "S" }
        let key: String = (tzID) + "&" + (mzID) + "#" + (letter)
        var name = _genericPartialLocationNamesMap.get(key)
        if (name.isSome()) {
            return name
        }
        var location: String
        let countryCode = ZoneMeta.getCanonicalCountry(tzID)
        if (countryCode.isSome()) {
            let regionalGolden = _tznames.getReferenceZoneID(mzID, countryCode)
            if (tzID.equals(regionalGolden)) {
                location = getLocaleDisplayNames().regionDisplayName(countryCode)
            } else {
                location = _tznames.getExemplarLocationName(tzID)
            }
        } else {
            location = _tznames.getExemplarLocationName(tzID)
            if (location.isNone()) {
                location = tzID
            }
        }
        name = formatPattern(TimeZoneGenericNames_Pattern.FALLBACK_FORMAT, [location, mzDisplayName])
        synchronized (getMonitorByObject(this)) {
            let tmp = _genericPartialLocationNamesMap.putIfAbsent(key.intern(), name.intern())
            if (tmp.isNone()) {
                let info = TimeZoneGenericNames_NameInfo(tzID.intern(), if (isLong) { TimeZoneGenericNames_GenericNameType.LONG } else { TimeZoneGenericNames_GenericNameType.SHORT })
                _gnamesTrie.put(name, info)
            } else {
                name = tmp
            }
        }
        return name
    }

    public func findBestMatch(text: String, start: Int32, genericTypes: EnumSet): TimeZoneGenericNames_GenericMatchInfo {
        if (text.isNone() || Int32(text.size) == 0 || start < 0 || start >= Int32(text.size)) {
            throw IllegalArgumentException("bad input text or range")
        }
        var bestMatch: TimeZoneGenericNames_GenericMatchInfo
        let tznamesMatches = findTimeZoneNames(text, start, genericTypes)
        if (tznamesMatches.isSome()) {
            var longestMatch: TimeZoneNames_MatchInfo
            for (match in tznamesMatches) {
                if (longestMatch.isNone() || match.matchLength() > longestMatch.matchLength()) {
                    longestMatch = match
                }
            }
            if (longestMatch.isSome()) {
                bestMatch = createGenericMatchInfo(longestMatch)
                if (bestMatch.matchLengthMethod() == (Int32(text.size) - start)) {
                    if (!refEq(bestMatch.timeType, TimeZoneFormat_TimeType.STANDARD)) {
                        return bestMatch
                    }
                }
            }
        }
        let localMatches = findLocal(text, start, genericTypes)
        if (localMatches.isSome()) {
            for (match in localMatches) {
                if (bestMatch.isNone() || match.matchLengthMethod() >= bestMatch.matchLengthMethod()) {
                    bestMatch = match
                }
            }
        }
        return bestMatch
    }

    public func find(text: String, start: Int32, genericTypes: EnumSet): Collection<TimeZoneGenericNames_GenericMatchInfo> {
        if (text.isNone() || Int32(text.size) == 0 || start < 0 || start >= Int32(text.size)) {
            throw IllegalArgumentException("bad input text or range")
        }
        var results = findLocal(text, start, genericTypes)
        let tznamesMatches = findTimeZoneNames(text, start, genericTypes)
        if (tznamesMatches.isSome()) {
            for (match in tznamesMatches) {
                if (results.isNone()) {
                    results = LinkedList<TimeZoneGenericNames_GenericMatchInfo>()
                }
                results.add(createGenericMatchInfo(match))
            }
        }
        return results
    }

    private func createGenericMatchInfo(matchInfo: TimeZoneNames_MatchInfo): TimeZoneGenericNames_GenericMatchInfo {
        var nameType: TimeZoneGenericNames_GenericNameType
        var timeType: TimeZoneFormat_TimeType = TimeZoneFormat_TimeType.UNKNOWN
        match (matchInfo.nameType()) {
            case TimeZoneNames_NameType.LONG_STANDARD =>
                nameType = TimeZoneGenericNames_GenericNameType.LONG
                timeType = TimeZoneFormat_TimeType.STANDARD
            case TimeZoneNames_NameType.LONG_GENERIC => nameType = TimeZoneGenericNames_GenericNameType.LONG
            case TimeZoneNames_NameType.SHORT_STANDARD =>
                nameType = TimeZoneGenericNames_GenericNameType.SHORT
                timeType = TimeZoneFormat_TimeType.STANDARD
            case TimeZoneNames_NameType.SHORT_GENERIC => nameType = TimeZoneGenericNames_GenericNameType.SHORT
            case _ => throw IllegalArgumentException("Unexpected MatchInfo name type - " + matchInfo.nameType().asString())
        }
        var tzID = matchInfo.tzID()
        if (tzID.isNone()) {
            let mzID = matchInfo.mzID()
            if (!(mzID.isSome())) {
                throw AssertionError()
            }
            tzID = _tznames.getReferenceZoneID(mzID, getTargetRegion())
        }
        if (!(tzID.isSome())) {
            throw AssertionError()
        }
        let gmatch = TimeZoneGenericNames_GenericMatchInfo(nameType, tzID, matchInfo.matchLength(), timeType)
        return gmatch
    }

    private func findTimeZoneNames(text: String, start: Int32, types: EnumSet): Collection<TimeZoneNames_MatchInfo> {
        var tznamesMatches: Collection<TimeZoneNames_MatchInfo>
        let nameTypes = EnumSet.noneOf(TypeInfo.of<TimeZoneNames_NameType>() as ClassTypeInfo)
        if (types.contains(TimeZoneGenericNames_GenericNameType.LONG)) {
            nameTypes.add(TimeZoneNames_NameType.LONG_GENERIC)
            nameTypes.add(TimeZoneNames_NameType.LONG_STANDARD)
        }
        if (types.contains(TimeZoneGenericNames_GenericNameType.SHORT)) {
            nameTypes.add(TimeZoneNames_NameType.SHORT_GENERIC)
            nameTypes.add(TimeZoneNames_NameType.SHORT_STANDARD)
        }
        if (!nameTypes.isEmpty()) {
            tznamesMatches = _tznames.find(text, start, nameTypes)
        }
        return tznamesMatches
    }

    private func findLocal(text: String, start: Int32, types: EnumSet): Collection<TimeZoneGenericNames_GenericMatchInfo> {
        synchronized (GeneratedLockObject) {
            let handler = TimeZoneGenericNames_GenericNameSearchHandler(types)
            _gnamesTrie.find(text, start, handler)
            if (handler.getMaxMatchLen() == (Int32(text.size) - start) || _gnamesTrieFullyLoaded) {
                return handler.getMatches()
            }
            let tzIDs = TimeZone.getAvailableIDs(TimeZone_SystemTimeZoneType.CANONICAL, None, None)
            for (tzID in tzIDs) {
                loadStrings(tzID)
            }
            _gnamesTrieFullyLoaded = true
            handler.resetResults()
            _gnamesTrie.find(text, start, handler)
            return handler.getMatches()
        }
    }

    private func readObject(input: ObjectInputStream): Unit {
        input.defaultReadObject()
        initself()
    }

    public override func isFrozen(): Bool {
        return _frozen
    }

    public override func freeze(): TimeZoneGenericNames {
        _frozen = true
        return this
    }

    public override func cloneAsThawed(): TimeZoneGenericNames {
        var copy: TimeZoneGenericNames
        try {
            copy = super.toString()
            copy._frozen = false
        } catch (t: Exception) { }
        return copy
    }
}


public class TimeZoneGenericNames_GenericNameType <: Enum<TimeZoneGenericNames_GenericNameType> {
    public static let LOCATION = TimeZoneGenericNames_GenericNameType("LOCATION", 0, ["LONG", "SHORT"])

    public static let LONG = TimeZoneGenericNames_GenericNameType("LONG", 1, [0])

    public static let SHORT = TimeZoneGenericNames_GenericNameType("SHORT", 2, [0])

    private static func _values(): Array<TimeZoneGenericNames_GenericNameType> {
        return [TimeZoneGenericNames_GenericNameType.LOCATION, TimeZoneGenericNames_GenericNameType.LONG, TimeZoneGenericNames_GenericNameType.SHORT]
    }

    private static let _VALUES = TimeZoneGenericNames_GenericNameType._values()

    public static func values(): Array<TimeZoneGenericNames_GenericNameType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): TimeZoneGenericNames_GenericNameType {
        return (TypeInfo.of<TimeZoneGenericNames_GenericNameType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as TimeZoneGenericNames_GenericNameType
    }

    var _fallbackTypeOf: Array<String>

    init(_enum_name: String, _enum_ordinal: Int32, fallbackTypeOf: Array<String>) {
        super(_enum_name, _enum_ordinal)
        _fallbackTypeOf = fallbackTypeOf
    }

    public func isFallbackTypeOf(Type: TimeZoneGenericNames_GenericNameType): Bool {
        let typeStr: String = Type.toString()
        for (t in _fallbackTypeOf) {
            if (t.equals(typeStr)) {
                return true
            }
        }
        return false
    }
}


public class TimeZoneGenericNames_Pattern <: Enum<TimeZoneGenericNames_Pattern> {
    public static let REGION_FORMAT = TimeZoneGenericNames_Pattern("REGION_FORMAT", 0, "regionFormat", "({0})")

    public static let FALLBACK_FORMAT = TimeZoneGenericNames_Pattern("FALLBACK_FORMAT", 1, "fallbackFormat", "{1} ({0})")

    private static func _values(): Array<TimeZoneGenericNames_Pattern> {
        return [TimeZoneGenericNames_Pattern.REGION_FORMAT, TimeZoneGenericNames_Pattern.FALLBACK_FORMAT]
    }

    private static let _VALUES = TimeZoneGenericNames_Pattern._values()

    public static func values(): Array<TimeZoneGenericNames_Pattern> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): TimeZoneGenericNames_Pattern {
        return (TypeInfo.of<TimeZoneGenericNames_Pattern>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as TimeZoneGenericNames_Pattern
    }

    var _key: String

    var _defaultVal: String

    init(_enum_name: String, _enum_ordinal: Int32, key: String, defaultVal: String) {
        super(_enum_name, _enum_ordinal)
        _key = key
        _defaultVal = defaultVal
    }

    public func key(): String {
        return _key
    }

    public func defaultValue(): String {
        return _defaultVal
    }
}


class TimeZoneGenericNames_NameInfo {
    let tzID: String

    let Type: TimeZoneGenericNames_GenericNameType

    init(tzID: String, Type: TimeZoneGenericNames_GenericNameType) {
        this.tzID = tzID
        this.Type = Type
    }
}


public class TimeZoneGenericNames_GenericMatchInfo {
    let nameType: TimeZoneGenericNames_GenericNameType

    let tzID: String

    let matchLength: Int32

    let timeType: TimeZoneFormat_TimeType

    init(nameType: TimeZoneGenericNames_GenericNameType, tzID: String, matchLength: Int32) {
        this(nameType, tzID, matchLength, TimeZoneFormat_TimeType.UNKNOWN)
    }

    init(nameType: TimeZoneGenericNames_GenericNameType, tzID: String, matchLength: Int32, timeType: TimeZoneFormat_TimeType) {
        this.nameType = nameType
        this.tzID = tzID
        this.matchLength = matchLength
        this.timeType = timeType
    }

    public func nameTypeMethod(): TimeZoneGenericNames_GenericNameType {
        return nameType
    }

    public func tzIDMethod(): String {
        return tzID
    }

    public func timeTypeMethod(): TimeZoneFormat_TimeType {
        return timeType
    }

    public func matchLengthMethod(): Int32 {
        return matchLength
    }
}


class TimeZoneGenericNames_GenericNameSearchHandler <: TextTrieMap_ResultHandler<TimeZoneGenericNames_NameInfo> {
    private var _types: EnumSet = None

    private var _matches: Collection<TimeZoneGenericNames_GenericMatchInfo>

    private var _maxMatchLen: Int32 = 0

    init(types: EnumSet) {
        _types = types
    }

    public override func handlePrefixMatch(matchLength: Int32, values: Iterator<TimeZoneGenericNames_NameInfo>): Bool {
        while (values.hasNext()) {
            let info = values.next()
            if (_types.isSome() && !_types.contains(info.Type)) {
                continue
            }
            let matchInfo = TimeZoneGenericNames_GenericMatchInfo(info.Type, info.tzID, matchLength)
            if (_matches.isNone()) {
                _matches = LinkedList<TimeZoneGenericNames_GenericMatchInfo>()
            }
            _matches.add(matchInfo)
            if (matchLength > _maxMatchLen) {
                _maxMatchLen = matchLength
            }
        }
        return true
    }

    public func getMatches(): Collection<TimeZoneGenericNames_GenericMatchInfo> {
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


class TimeZoneGenericNames_Cache <: SoftCache<String, TimeZoneGenericNames, ULocale> {
    init() {
        super()
    }

    override protected func createInstance(key: String, data: ULocale): TimeZoneGenericNames {
        return TimeZoneGenericNames(data).freeze()
    }
}
