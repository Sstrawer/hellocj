package icu4cj.impl

public class TZDBTimeZoneNames <: TimeZoneNames {
    private static let serialVersionUID = 1

    private static let TZDB_NAMES_MAP = ConcurrentHashMap()

     private static var TZDB_NAMES_TRIE: TextTrieMap<TZDBTimeZoneNames_TZDBNameInfo>

    private static let ZONESTRINGS: ICUResourceBundle


    private var _locale: ULocale

      private var _region: String

    public init(loc: ULocale) {
        super()
        _locale = loc
    }

    public override func getAvailableMetaZoneIDs(): Set<String> {
        return TimeZoneNamesImpl._getAvailableMetaZoneIDs()
    }

    public override func getAvailableMetaZoneIDs(tzID: String): Set<String> {
        return TimeZoneNamesImpl._getAvailableMetaZoneIDs(tzID)
    }

    public override func getMetaZoneID(tzID: String, date: Int64): String {
        return TimeZoneNamesImpl._getMetaZoneID(tzID, date)
    }

    public override func getReferenceZoneID(mzID: String, region: String): String {
        return TimeZoneNamesImpl._getReferenceZoneID(mzID, region)
    }

    public override func getMetaZoneDisplayName(mzID: String, Type: TimeZoneNames_NameType): String {
        if (mzID.isNone() || Int32(mzID.size) == 0 || (!refEq(Type, TimeZoneNames_NameType.SHORT_STANDARD) && !refEq(Type, TimeZoneNames_NameType.SHORT_DAYLIGHT))) {
            return None
        }
        return getMetaZoneNames(mzID).getName(Type)
    }

    public override func getTimeZoneDisplayName(tzID: String, Type: TimeZoneNames_NameType): String {
        return None
    }

    public override func find(text: String, start: Int32, nameTypes: EnumSet): Collection<TimeZoneNames_MatchInfo> {
        if (text.isNone() || text.size == 0 || start < 0 || start >= text.size) {
            throw IllegalArgumentException("bad input text or range")
        }
        prepareFind()
        let handler = TZDBTimeZoneNames_TZDBNameSearchHandler(nameTypes, getTargetRegion())
        TZDB_NAMES_TRIE.find(text, start, handler)
        return handler.getMatches()
    }

    private static func getMetaZoneNames(mzID: String): TZDBTimeZoneNames_TZDBNames {
        var tempmzID = mzID
        var names = TZDB_NAMES_MAP.get(tempmzID)
        if (names.isNone()) {
            names = TZDBTimeZoneNames_TZDBNames.getInstance(ZONESTRINGS, "meta:" + (tempmzID))
            tempmzID = tempmzID.intern()
            let tmpNames = TZDB_NAMES_MAP.putIfAbsent(tempmzID, names)
            names = if (tmpNames.isNone()) { names } else { tmpNames }
        }
        return names
    }

    private static func prepareFind(): Unit {
        if (TZDB_NAMES_TRIE.isNone()) {
            synchronized (getMonitorByObject(TypeInfo.of<TZDBTimeZoneNames>())) {
                if (TZDB_NAMES_TRIE.isNone()) {
                    let trie = TextTrieMap<TZDBTimeZoneNames_TZDBNameInfo>(true)
                    let mzIDs = TimeZoneNamesImpl._getAvailableMetaZoneIDs()
                    for (mzID in mzIDs) {
                        let names = getMetaZoneNames(mzID)
                        let std = names.getName(TimeZoneNames_NameType.SHORT_STANDARD)
                        let dst = names.getName(TimeZoneNames_NameType.SHORT_DAYLIGHT)
                        if (std.isNone() && dst.isNone()) {
                            continue
                        }
                        let parseRegions = names.getParseRegions()
                        mzID = mzID.intern()
                        let ambiguousType = (std.isSome() && dst.isSome() && std.equals(dst))
                        if (std.isSome()) {
                            let stdInf = TZDBTimeZoneNames_TZDBNameInfo(mzID, TimeZoneNames_NameType.SHORT_STANDARD, ambiguousType, parseRegions)
                            trie.put(std, stdInf)
                        }
                        if (dst.isSome()) {
                            let dstInf = TZDBTimeZoneNames_TZDBNameInfo(mzID, TimeZoneNames_NameType.SHORT_DAYLIGHT, ambiguousType, parseRegions)
                            trie.put(dst, dstInf)
                        }
                    }
                    TZDB_NAMES_TRIE = trie
                }
            }
        }
    }

    private func getTargetRegion(): String {
        if (_region.isNone()) {
            var region = _locale.getCountry()
            if (Int32(region.size) == 0) {
                let tmp = ULocale.addLikelySubtags(_locale)
                region = tmp.getCountry()
                if (Int32(region.size) == 0) {
                    region = "001"
                }
            }
            _region = region
        }
        return _region
    }
}


class TZDBTimeZoneNames_TZDBNames {
    public static let EMPTY_TZDBNAMES = TZDBTimeZoneNames_TZDBNames(None, None)

    private var _names: Array<String>

    private var _parseRegions: Array<String>

    private static let KEYS: Array<String> = ["ss", "sd"]

    private init(names: Array<String>, parseRegions: Array<String>) {
        _names = names
        _parseRegions = parseRegions
    }

    static func getInstance(zoneStrings: ICUResourceBundle, key: String): TZDBTimeZoneNames_TZDBNames {
        if (zoneStrings.isNone() || key.isNone() || Int32(key.size) == 0) {
            return EMPTY_TZDBNAMES
        }
        var table: ICUResourceBundle
        try {
            table = zoneStrings.get(key)
        } catch (e: MissingResourceException) {
            return EMPTY_TZDBNAMES
        }
        var isEmpty = true
        let names = Array<String>(KEYS.size)
        var i = 0
        while (i < Int32(names.size)) {
            try {
                names[Int64(i)] = table.getString(KEYS[Int64(i)])
                isEmpty = false
            } catch (e: MissingResourceException) {
                names[Int64(i)] = None
            }
            i++
        }
        if (isEmpty) {
            return EMPTY_TZDBNAMES
        }
        var parseRegions: Array<String>
        try {
            let regionsRes = table.get("parseRegions")
            if (regionsRes.getType() == UResourceBundle.STRING) {
                parseRegions = Array<String>(1)
                parseRegions[0] = regionsRes.getString()
            } else if (regionsRes.getType() == UResourceBundle.ARRAY) {
                parseRegions = regionsRes.getStringArray()
            }
        } catch (e: MissingResourceException) { }
        return TZDBTimeZoneNames_TZDBNames(names, parseRegions)
    }

    public func getName(Type: TimeZoneNames_NameType): String {
        if (_names.isNone()) {
            return None
        }
        var name: String
        match (Type) {
            case TimeZoneNames_NameType.SHORT_STANDARD => name = _names[0]
            case TimeZoneNames_NameType.SHORT_DAYLIGHT => name = _names[1]
            case _ => ()
        }
        return name
    }

    public func getParseRegions(): Array<String> {
        return _parseRegions
    }
}


class TZDBTimeZoneNames_TZDBNameInfo {
    let mzID: String

    let Type: TimeZoneNames_NameType

    let ambiguousType: Bool

    let parseRegions: Array<String>

    init(mzID: String, Type: TimeZoneNames_NameType, ambiguousType: Bool, parseRegions: Array<String>) {
        this.mzID = mzID
        this.Type = Type
        this.ambiguousType = ambiguousType
        this.parseRegions = parseRegions
    }
}


class TZDBTimeZoneNames_TZDBNameSearchHandler <: TextTrieMap_ResultHandler<TZDBTimeZoneNames_TZDBNameInfo> {
    private var _nameTypes: EnumSet = None

    private var _matches: Collection<TimeZoneNames_MatchInfo>

    private var _region: String

    init(nameTypes: EnumSet, region: String) {
        _nameTypes = nameTypes
        if (!region.isSome()) {
            throw AssertionError()
        }
        _region = region
    }

    public override func handlePrefixMatch(matchLength: Int32, values: Iterator<TZDBTimeZoneNames_TZDBNameInfo>): Bool {
        var match: TZDBTimeZoneNames_TZDBNameInfo
        var defaultRegionMatch: TZDBTimeZoneNames_TZDBNameInfo
        while (values.hasNext()) {
            let ninfo = values.next()
            if (_nameTypes.isSome() && !_nameTypes.contains(ninfo.Type)) {
                continue
            }
            if (ninfo.parseRegions.isNone()) {
                if (defaultRegionMatch.isNone()) {
                    match = match (0) { case _ => defaultRegionMatch = ninfo; defaultRegionMatch }
                }
            } else {
                var matchRegion = false
                for (region in ninfo.parseRegions) {
                    if (_region.equals(region)) {
                        match = ninfo
                        matchRegion = true
                        break
                    }
                }
                if (matchRegion) {
                    break
                }
                if (match.isNone()) {
                    match = ninfo
                }
            }
        }
        if (match.isSome()) {
            var ntype = match.Type
            if (match.ambiguousType && (refEq(ntype, TimeZoneNames_NameType.SHORT_STANDARD) || refEq(ntype, TimeZoneNames_NameType.SHORT_DAYLIGHT)) && _nameTypes.contains(TimeZoneNames_NameType.SHORT_STANDARD) && _nameTypes.contains(TimeZoneNames_NameType.SHORT_DAYLIGHT)) {
                ntype = TimeZoneNames_NameType.SHORT_GENERIC
            }
            let minfo = TimeZoneNames_MatchInfo(ntype, None, match.mzID, matchLength)
            if (_matches.isNone()) {
                _matches = LinkedList<TimeZoneNames_MatchInfo>()
            }
            _matches.add(minfo)
        }
        return true
    }

    public func getMatches(): Collection<TimeZoneNames_MatchInfo> {
        if (_matches.isNone()) {
            return Array<String>(0, { _ => "" })
        }
        return _matches
    }
}
