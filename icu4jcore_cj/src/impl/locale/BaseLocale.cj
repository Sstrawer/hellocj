package icu4cj.impl.locale


public class BaseLocale {
    static let JDKIMPL = false

    public static let SEP = "_"

    private static let CACHE = BaseLocale_Cache()

    public static let ROOT = BaseLocale.getInstance("", "", "", "")

    private var _language: String = ""

    private var _script: String = ""

    private var _region: String = ""

    private var _variant: String = ""

      private var _hash = 0

    init(language: String, script: String, region: String, variant: String) {
        if (language.isSome()) {
            _language = AsciiUtil.toLowerString(language).intern()
        }
        if (script.isSome()) {
            _script = AsciiUtil.toTitleString(script).intern()
        }
        if (region.isSome()) {
            _region = AsciiUtil.toUpperString(region).intern()
        }
        if (variant.isSome()) {
            if (JDKIMPL) {
                _variant = variant.intern()
            } else {
                _variant = AsciiUtil.toUpperString(variant).intern()
            }
        }
    }

    public static func getInstance(language: String, script: String, region: String, variant: String): BaseLocale {
        var templanguage = language
        if (JDKIMPL) {
            if (AsciiUtil.caseIgnoreMatch(templanguage, "he")) {
                templanguage = "iw"
            } else if (AsciiUtil.caseIgnoreMatch(templanguage, "yi")) {
                templanguage = "ji"
            } else if (AsciiUtil.caseIgnoreMatch(templanguage, "id")) {
                templanguage = "in"
            }
        }
        let key = BaseLocale_Key(templanguage, script, region, variant)
        let baseLocale = CACHE.get(key)
        return baseLocale
    }

    public func getLanguage(): String {
        return _language
    }

    public func getScript(): String {
        return _script
    }

    public func getRegion(): String {
        return _region
    }

    public func getVariant(): String {
        return _variant
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (!(checkOptionalIs<BaseLocale, Object>(obj))) {
            return false
        }
        let other = obj
        return Int32(hashCode()) == Int32(other.hashCode()) && _language.equals(other._language) && _script.equals(other._script) && _region.equals(other._region) && _variant.equals(other._variant)
    }

    public override func toString(): String {
        let buf = StringBuilder()
        if (Int32(_language.size) > 0) {
            buf.append("language=")
            buf.append(_language)
        }
        if (Int32(_script.size) > 0) {
            if (Int32(buf.size) > 0) {
                buf.append(", ")
            }
            buf.append("script=")
            buf.append(_script)
        }
        if (Int32(_region.size) > 0) {
            if (Int32(buf.size) > 0) {
                buf.append(", ")
            }
            buf.append("region=")
            buf.append(_region)
        }
        if (Int32(_variant.size) > 0) {
            if (Int32(buf.size) > 0) {
                buf.append(", ")
            }
            buf.append("variant=")
            buf.append(_variant)
        }
        return buf.toString()
    }

    public override func hashCode(): Int64 {
        var h = _hash
        if (h == 0) {
            } while (false)
            } while (false)
            } while (false)
            } while (false)
            _hash = h
        }
        return Int64(h)
    }
}


class BaseLocale_Key <: Comparable<BaseLocale_Key> {
    var _lang: String = ""

    var _scrt: String = ""

    var _regn: String = ""

    var _vart: String = ""

     private var _hash: Int32 = 0

    public init(language: String, script: String, region: String, variant: String) {
        if (language.isSome()) {
            _lang = language
        }
        if (script.isSome()) {
            _scrt = script
        }
        if (region.isSome()) {
            _regn = region
        }
        if (variant.isSome()) {
            _vart = variant
        }
    }

    public override func equals(obj: Object): Bool {
        if (BaseLocale.JDKIMPL) {
            return (refEq(this, obj)) || (checkOptionalIs<BaseLocale_Key, Object>(obj)) && AsciiUtil.caseIgnoreMatch(obj._lang, this._lang) && AsciiUtil.caseIgnoreMatch(obj._scrt, this._scrt) && AsciiUtil.caseIgnoreMatch(obj._regn, this._regn) && obj._vart.equals(_vart)
        }
        return (refEq(this, obj)) || (checkOptionalIs<BaseLocale_Key, Object>(obj)) && AsciiUtil.caseIgnoreMatch(obj._lang, this._lang) && AsciiUtil.caseIgnoreMatch(obj._scrt, this._scrt) && AsciiUtil.caseIgnoreMatch(obj._regn, this._regn) && AsciiUtil.caseIgnoreMatch(obj._vart, this._vart)
    }

    public override func compareTo(other: BaseLocale_Key): Int32 {
        var res = AsciiUtil.caseIgnoreCompare(this._lang, other._lang)
        if (res == 0) {
            res = AsciiUtil.caseIgnoreCompare(this._scrt, other._scrt)
            if (res == 0) {
                res = AsciiUtil.caseIgnoreCompare(this._regn, other._regn)
                if (res == 0) {
                    if (BaseLocale.JDKIMPL) {
                        res = this._vart.compare(other._vart).value()
                    } else {
                        res = AsciiUtil.caseIgnoreCompare(this._vart, other._vart)
                    }
                }
            }
        }
        return res
    }

    public override func hashCode(): Int64 {
        var h = _hash
        if (h == 0) {
            } while (false)
            } while (false)
            } while (false)
                        h = 31 * h + Int32(UInt32(AsciiUtil.toLower(Char(_vart[Int64(i)]))))
                    }
                    i++
                }
            } while (false)
            _hash = h
        }
        return Int64(h)
    }

    public static func normalize(key: BaseLocale_Key): BaseLocale_Key {
        let lang = AsciiUtil.toLowerString(key._lang).intern()
        let scrt = AsciiUtil.toTitleString(key._scrt).intern()
        let regn = AsciiUtil.toUpperString(key._regn).intern()
        let vart: String
        if (BaseLocale.JDKIMPL) {
            vart = key._vart.intern()
        } else {
            vart = AsciiUtil.toUpperString(key._vart).intern()
        }
        return BaseLocale_Key(lang, scrt, regn, vart)
    }
}


class BaseLocale_Cache <: LocaleObjectCache<BaseLocale_Key, BaseLocale> {
    public init() {
        super()
    }

    override protected func normalizeKey(key: BaseLocale_Key): BaseLocale_Key {
        return BaseLocale_Key.normalize(key)
    }

    override protected func createObject(key: BaseLocale_Key): BaseLocale {
        return BaseLocale(key._lang, key._scrt, key._regn, key._vart)
    }
}
