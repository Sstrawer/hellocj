package icu4cj.impl.locale

public class UnicodeLocaleExtension <: Extension {
    public static let SINGLETON = 'u'

    private static let EMPTY_SORTED_SET: SortedSet = TreeSet()

    private static let EMPTY_SORTED_MAP: SortedMap = TreeMap()

    private var _attributes: SortedSet = EMPTY_SORTED_SET

    private var _keywords: SortedMap = EMPTY_SORTED_MAP

    public static let CA_JAPANESE: UnicodeLocaleExtension

    public static let NU_THAI: UnicodeLocaleExtension


    private init() {
        super(SINGLETON)
    }

    init(attributes: SortedSet, keywords: SortedMap) {
        this()
        if (attributes.isSome() && Int32(attributes.size) > 0) {
            _attributes = attributes
        }
        if (keywords.isSome() && Int32(keywords.size) > 0) {
            _keywords = keywords
        }
        if (Int32(_attributes.size) > 0 || Int32(_keywords.size) > 0) {
            let sb = StringBuilder()
            for (attribute in _attributes) {
                sb.append(LanguageTag.SEP).append(attribute)
            }
            for (keyword in _keywords.entrySet()) {
                let key = keyword.getKey()
                let value = keyword.getValue()
                sb.append(LanguageTag.SEP).append(key)
                if (Int32(value.size) > 0) {
                    sb.append(LanguageTag.SEP).append(value)
                }
            }
            _value = sb.substring(1)
        }
    }

    public func getUnicodeLocaleAttributes(): Set<String> {
        return Collections.unmodifiableSet(_attributes)
    }

    public func getUnicodeLocaleKeys(): Set<String> {
        return Collections.unmodifiableSet(SetCollectionView<String>(_keywords.keys()) as Set<T>)
    }

    public func getUnicodeLocaleType(unicodeLocaleKey: String): String {
        return _keywords.get(unicodeLocaleKey)
    }

    public static func isSingletonChar(c: Char): Bool {
        return (SINGLETON == AsciiUtil.toLower(c))
    }

    public static func isAttribute(s: String): Bool {
        return (Int32(s.size) >= 3) && (Int32(s.size) <= 8) && AsciiUtil.isAlphaNumericString(s)
    }

    public static func isKey(s: String): Bool {
        return (Int32(s.size) == 2) && AsciiUtil.isAlphaNumeric(Char(s[0])) && AsciiUtil.isAlpha(Char(s[1]))
    }

    public static func isTypeSubtag(s: String): Bool {
        return (Int32(s.size) >= 3) && (Int32(s.size) <= 8) && AsciiUtil.isAlphaNumericString(s)
    }

    public static func isType(s: String): Bool {
        var startIdx = 0
        var sawSubtag = false
        while (true) {
            let idx = indexOfWrap(s.indexOf(LanguageTag.SEP, Int64(startIdx)))
            let subtag: String = if (idx < 0) { s[Int64(startIdx)..] } else { s[Int64(startIdx)..Int64(idx)] }
            if (!isTypeSubtag(subtag)) {
                return false
            }
            sawSubtag = true
            if (idx < 0) {
                break
            }
            startIdx = idx + 1
        }
        return sawSubtag && startIdx < Int32(s.size)
    }
}
