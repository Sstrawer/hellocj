package icu4cj.impl.locale


public class LocaleExtensions {
    private var _map: SortedMap = None

    private var _id: String

    private static let EMPTY_MAP = Collections.unmodifiableSortedMap(TreeMap() as SortedMap)

    public static let EMPTY_EXTENSIONS: LocaleExtensions

    public static let CALENDAR_JAPANESE: LocaleExtensions

    public static let NUMBER_THAI: LocaleExtensions



    init(extensions: Map<InternalLocaleBuilder_CaseInsensitiveChar, String>, uattributes: Set<InternalLocaleBuilder_CaseInsensitiveString>, ukeywords: Map<InternalLocaleBuilder_CaseInsensitiveString, String>) {
        let hasExtension = (extensions.isSome() && Int32(extensions.size) > 0)
        let hasUAttributes = (uattributes.isSome() && Int32(uattributes.size) > 0)
        let hasUKeywords = (ukeywords.isSome() && Int32(ukeywords.size) > 0)
        if (!hasExtension && !hasUAttributes && !hasUKeywords) {
            _map = EMPTY_MAP
            _id = ""
            return
        }
        _map = TreeMap()
        if (hasExtension) {
            for (ext in extensions.entrySet()) {
                let key = AsciiUtil.toLower(ext.getKey().value())
                var value = ext.getValue()
                if (LanguageTag.isPrivateusePrefixChar(key)) {
                    value = InternalLocaleBuilder.removePrivateuseVariant(value)
                    if (value.isNone()) {
                        continue
                    }
                }
                let e = Extension(key, AsciiUtil.toLowerString(value))
                _map.put(Character.valueOf(key), e)
            }
        }
        if (hasUAttributes || hasUKeywords) {
            var uaset: TreeSet = None
            var ukmap: TreeMap = None
            if (hasUAttributes) {
                uaset = TreeSet()
                for (cis in uattributes) {
                    uaset.put(AsciiUtil.toLowerString(cis.value()))
                }
            }
            if (hasUKeywords) {
                ukmap = TreeMap()
                for (kwd in ukeywords.entrySet()) {
                    let key = AsciiUtil.toLowerString(kwd.getKey().value())
                    let Type = AsciiUtil.toLowerString(kwd.getValue())
                    ukmap.put(key, Type)
                }
            }
            let ule = UnicodeLocaleExtension(uaset, ukmap)
            _map.put(Character.valueOf(UnicodeLocaleExtension.SINGLETON), ule)
        }
        if (Int32(_map.size) == 0) {
            _map = EMPTY_MAP
            _id = ""
        } else {
            _id = toID(_map)
        }
    }

    public func getKeys(): Set<Character> {
        return Collections.unmodifiableSet(// Мapping is present but failed: SetCollectionView<Character>(_map.keys()) as Set<T>)
    }

    public func getExtension(key: Character): Extension {
        return _map.get(Character.valueOf(AsciiUtil.toLower(key.charValue())))
    }

    public func getExtensionValue(key: Character): String {
        let ext = _map.get(Character.valueOf(AsciiUtil.toLower(key.charValue())))
        if (ext.isNone()) {
            return None
        }
        return ext.getValue()
    }

    public func getUnicodeLocaleAttributes(): Set<String> {
        let ext = _map.get(Character.valueOf(UnicodeLocaleExtension.SINGLETON))
        if (ext.isNone()) {
            return Collections.emptySet<<--> -->()
        }
        if (!(checkOptionalIs<UnicodeLocaleExtension, Extension>(ext))) {
            throw AssertionError()
        }
        return ext.getUnicodeLocaleAttributes()
    }

    public func getUnicodeLocaleKeys(): Set<String> {
        let ext = _map.get(Character.valueOf(UnicodeLocaleExtension.SINGLETON))
        if (ext.isNone()) {
            return Collections.emptySet<<--> -->()
        }
        if (!(checkOptionalIs<UnicodeLocaleExtension, Extension>(ext))) {
            throw AssertionError()
        }
        return ext.getUnicodeLocaleKeys()
    }

    public func getUnicodeLocaleType(unicodeLocaleKey: String): String {
        let ext = _map.get(Character.valueOf(UnicodeLocaleExtension.SINGLETON))
        if (ext.isNone()) {
            return None
        }
        if (!(checkOptionalIs<UnicodeLocaleExtension, Extension>(ext))) {
            throw AssertionError()
        }
        return ext.getUnicodeLocaleType(AsciiUtil.toLowerString(unicodeLocaleKey))
    }

    public func isEmpty(): Bool {
        return _map.isEmpty()
    }

    public static func isValidKey(c: Char): Bool {
        return LanguageTag.isExtensionSingletonChar(c) || LanguageTag.isPrivateusePrefixChar(c)
    }

    public static func isValidUnicodeLocaleKey(ukey: String): Bool {
        return UnicodeLocaleExtension.isKey(ukey)
    }

    private static func toID(map: SortedMap): String {
        let buf = StringBuilder()
        var privuse: Extension
        for (entry in map.entrySet()) {
            let singleton = entry.getKey().charValue()
            let extension = entry.getValue()
            if (LanguageTag.isPrivateusePrefixChar(singleton)) {
                privuse = extension
            } else {
                if (Int32(buf.size) > 0) {
                    buf.append(LanguageTag.SEP)
                }
                buf.append(extension.asString())
            }
        }
        if (privuse.isSome()) {
            if (Int32(buf.size) > 0) {
                buf.append(LanguageTag.SEP)
            }
            buf.append(privuse.asString())
        }
        return buf.toString()
    }

    public override func toString(): String {
        return _id
    }

    public func getID(): String {
        return _id
    }

    public override func hashCode(): Int64 {
        return _id.hashCode()
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (!(checkOptionalIs<LocaleExtensions, Object>(other))) {
            return false
        }
        return this._id.equals(other._id)
    }
}
