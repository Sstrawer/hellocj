package icu4cj.impl.locale


public class InternalLocaleBuilder {
    private static let JDKIMPL = false

    private var _language: String = ""

    private var _script: String = ""

    private var _region: String = ""

    private var _variant: String = ""

    private static let PRIVUSE_KEY = InternalLocaleBuilder_CaseInsensitiveChar(Char(LanguageTag.PRIVATEUSE[0]))

    private var _extensions: HashMap<InternalLocaleBuilder_CaseInsensitiveChar, String> = None

    private var _uattributes: HashSet<InternalLocaleBuilder_CaseInsensitiveString>

    private var _ukeywords: HashMap<InternalLocaleBuilder_CaseInsensitiveString, String> = None


    public func setLanguage(language: String): InternalLocaleBuilder {
        if (language.isNone() || Int32(language.size) == 0) {
            _language = ""
        } else {
            if (!LanguageTag.isLanguage(language)) {
                throw LocaleSyntaxException("Ill-formed language: " + (language), 0)
            }
            _language = language
        }
        return this
    }

    public func setScript(script: String): InternalLocaleBuilder {
        if (script.isNone() || Int32(script.size) == 0) {
            _script = ""
        } else {
            if (!LanguageTag.isScript(script)) {
                throw LocaleSyntaxException("Ill-formed script: " + (script), 0)
            }
            _script = script
        }
        return this
    }

    public func setRegion(region: String): InternalLocaleBuilder {
        if (region.isNone() || Int32(region.size) == 0) {
            _region = ""
        } else {
            if (!LanguageTag.isRegion(region)) {
                throw LocaleSyntaxException("Ill-formed region: " + (region), 0)
            }
            _region = region
        }
        return this
    }

    public func setVariant(variant: String): InternalLocaleBuilder {
        if (variant.isNone() || Int32(variant.size) == 0) {
            _variant = ""
        } else {
            let variant = variant.replaceAll(LanguageTag.SEP, BaseLocale.SEP)
            let errIdx = checkVariants(var, BaseLocale.SEP)
            if (errIdx != -1) {
                throw LocaleSyntaxException("Ill-formed variant: " + (variant), errIdx)
            }
            _variant = var
        }
        return this
    }

    public func addUnicodeLocaleAttribute(attribute: String): InternalLocaleBuilder {
        if (attribute.isNone() || !UnicodeLocaleExtension.isAttribute(attribute)) {
            throw LocaleSyntaxException("Ill-formed Unicode locale attribute: " + (attribute))
        }
        if (_uattributes.isNone()) {
            _uattributes = HashSet<InternalLocaleBuilder_CaseInsensitiveString>(4)
        }
        _uattributes.put(InternalLocaleBuilder_CaseInsensitiveString(attribute))
        return this
    }

    public func removeUnicodeLocaleAttribute(attribute: String): InternalLocaleBuilder {
        if (attribute.isNone() || !UnicodeLocaleExtension.isAttribute(attribute)) {
            throw LocaleSyntaxException("Ill-formed Unicode locale attribute: " + (attribute))
        }
        if (_uattributes.isSome()) {
            _uattributes.remove(InternalLocaleBuilder_CaseInsensitiveString(attribute))
        }
        return this
    }

    public func setUnicodeLocaleKeyword(key: String, Type: String): InternalLocaleBuilder {
        if (!UnicodeLocaleExtension.isKey(key)) {
            throw LocaleSyntaxException("Ill-formed Unicode locale keyword key: " + (key))
        }
        let cikey = InternalLocaleBuilder_CaseInsensitiveString(key)
        if (Type.isNone()) {
            if (_ukeywords.isSome()) {
                _ukeywords.remove(cikey)
            }
        } else {
            if (Int32(Type.size) != 0) {
                let tp = Type.replaceAll(BaseLocale.SEP, LanguageTag.SEP)
                let itr = StringTokenIterator(tp, LanguageTag.SEP)
                while (!itr.isDone()) {
                    let s = itr.current()
                    if (!UnicodeLocaleExtension.isTypeSubtag(s)) {
                        throw LocaleSyntaxException("Ill-formed Unicode locale keyword type: " + (Type), itr.currentStart())
                    }
                    itr.next()
                }
            }
            if (_ukeywords.isNone()) {
                _ukeywords = HashMap<InternalLocaleBuilder_CaseInsensitiveString, String>(4)
            }
            _ukeywords.put(cikey, Type)
        }
        return this
    }

    public func setExtension(singleton: Char, value: String): InternalLocaleBuilder {
        let isBcpPrivateuse = LanguageTag.isPrivateusePrefixChar(singleton)
        if (!isBcpPrivateuse && !LanguageTag.isExtensionSingletonChar(singleton)) {
            throw LocaleSyntaxException("Ill-formed extension key: " + singleton.toString())
        }
        let remove = (value.isNone() || Int32(value.size) == 0)
        let key = InternalLocaleBuilder_CaseInsensitiveChar(singleton)
        if (remove) {
            if (UnicodeLocaleExtension.isSingletonChar(key.value())) {
                if (_uattributes.isSome()) {
                    _uattributes.clear()
                }
                if (_ukeywords.isSome()) {
                    _ukeywords.clear()
                }
            } else {
                if (_extensions.isSome() && _extensions.contains(key)) {
                    _extensions.remove(key)
                }
            }
        } else {
            let val = value.replaceAll(BaseLocale.SEP, LanguageTag.SEP)
            let itr = StringTokenIterator(val, LanguageTag.SEP)
            while (!itr.isDone()) {
                let s = itr.current()
                let validSubtag: Bool
                if (isBcpPrivateuse) {
                    validSubtag = LanguageTag.isPrivateuseSubtag(s)
                } else {
                    validSubtag = LanguageTag.isExtensionSubtag(s)
                }
                if (!validSubtag) {
                    throw LocaleSyntaxException("Ill-formed extension value: " + (s), itr.currentStart())
                }
                itr.next()
            }
            if (UnicodeLocaleExtension.isSingletonChar(key.value())) {
                setUnicodeLocaleExtension(val)
            } else {
                if (_extensions.isNone()) {
                    _extensions = HashMap<InternalLocaleBuilder_CaseInsensitiveChar, String>(4)
                }
                _extensions.put(key, val)
            }
        }
        return this
    }

    public func setExtensions(subtags: String): InternalLocaleBuilder {
        var tempsubtags = subtags
        if (tempsubtags.isNone() || Int32(tempsubtags.size) == 0) {
            clearExtensions()
            return this
        }
        tempsubtags = tempsubtags.replaceAll(BaseLocale.SEP, LanguageTag.SEP)
        let itr = StringTokenIterator(tempsubtags, LanguageTag.SEP)
        var extensions: ArrayList<String>
        var privateuse: String
        var parsed = 0
        var start: Int32 = 0
        while (!itr.isDone()) {
            var s = itr.current()
            if (LanguageTag.isExtensionSingleton(s)) {
                start = itr.currentStart()
                let singleton = s
                let sb = StringBuilder(singleton)
                itr.next()
                while (!itr.isDone()) {
                    s = itr.current()
                    if (LanguageTag.isExtensionSubtag(s)) {
                        sb.append(LanguageTag.SEP).append(s)
                        parsed = itr.currentEnd()
                    } else {
                        break
                    }
                    itr.next()
                }
                if (parsed < start) {
                    throw LocaleSyntaxException("Incomplete extension '" + (singleton) + "'", start)
                }
                if (extensions.isNone()) {
                    extensions = ArrayList<String>(4)
                }
                extensions.append(sb.toString())
            } else {
                break
            }
        }
        if (!itr.isDone()) {
            var s = itr.current()
            if (LanguageTag.isPrivateusePrefix(s)) {
                start = itr.currentStart()
                let sb = StringBuilder(s)
                itr.next()
                while (!itr.isDone()) {
                    s = itr.current()
                    if (!LanguageTag.isPrivateuseSubtag(s)) {
                        break
                    }
                    sb.append(LanguageTag.SEP).append(s)
                    parsed = itr.currentEnd()
                    itr.next()
                }
                if (parsed <= start) {
                    throw LocaleSyntaxException("Incomplete privateuse:" + tempsubtags[Int64(start)..], start)
                } else {
                    privateuse = sb.toString()
                }
            }
        }
        if (!itr.isDone()) {
            throw LocaleSyntaxException("Ill-formed extension subtags:" + tempsubtags[Int64(itr.currentStart())..], itr.currentStart())
        }
        return setExtensions(extensions, privateuse)
    }

    private func setExtensions(bcpExtensions: ArrayList<String>, privateuse: String): InternalLocaleBuilder {
        clearExtensions()
        if (bcpExtensions.isSome() && Int32(bcpExtensions.size) > 0) {
            let processedExtensions = HashSet<InternalLocaleBuilder_CaseInsensitiveChar>(bcpExtensions.size)
            for (bcpExt in bcpExtensions) {
                let key = InternalLocaleBuilder_CaseInsensitiveChar(Char(bcpExt[0]))
                if (!processedExtensions.contains(key)) {
                    if (UnicodeLocaleExtension.isSingletonChar(key.value())) {
                        setUnicodeLocaleExtension(bcpExt[2..])
                    } else {
                        if (_extensions.isNone()) {
                            _extensions = HashMap<InternalLocaleBuilder_CaseInsensitiveChar, String>(4)
                        }
                        _extensions.put(key, bcpExt[2..])
                    }
                }
            }
        }
        if (privateuse.isSome() && Int32(privateuse.size) > 0) {
            if (_extensions.isNone()) {
                _extensions = HashMap<InternalLocaleBuilder_CaseInsensitiveChar, String>(1)
            }
            _extensions.put(InternalLocaleBuilder_CaseInsensitiveChar(Char(privateuse[0])), privateuse[2..])
        }
        return this
    }

    public func setLanguageTag(langtag: LanguageTag): InternalLocaleBuilder {
        clear()
        if (Int32(langtag.getExtlangs().size) > 0) {
            _language = langtag.getExtlangs()[0]
        } else {
            let language = langtag.getLanguage()
            if (!language.equals(LanguageTag.UNDETERMINED)) {
                _language = language
            }
        }
        _script = langtag.getScript()
        _region = langtag.getRegion()
        let bcpVariants = ArrayList<String>(langtag.getVariants())
        Collections.sort(bcpVariants)
        if (Int32(bcpVariants.size) > 0) {
            let variant = StringBuilder(bcpVariants[0])
            var i = 1
            while (i < Int32(bcpVariants.size)) {
                var.append(BaseLocale.SEP).append(bcpVariants[Int64(i)])
                i++
            }
            _variant = var.toString()
        }
        setExtensions(langtag.getExtensions(), langtag.getPrivateuse())
        return this
    }

    public func setLocale(base: BaseLocale, extensions: LocaleExtensions): InternalLocaleBuilder {
        let language = base.getLanguage()
        let script = base.getScript()
        let region = base.getRegion()
        let variant = base.getVariant()
        if (JDKIMPL) {
            if (language == "ja" && region == "JP" && variant == "JP") {
                if (!("japanese".equals(extensions.getUnicodeLocaleType("ca")))) {
                    throw AssertionError()
                }
                variant = ""
            } else if (language == "th" && region == "TH" && variant == "TH") {
                if (!("thai".equals(extensions.getUnicodeLocaleType("nu")))) {
                    throw AssertionError()
                }
                variant = ""
            } else if (language == "no" && region == "NO" && variant == "NY") {
                language = "nn"
                variant = ""
            }
        }
        if (Int32(language.size) > 0 && !LanguageTag.isLanguage(language)) {
            throw LocaleSyntaxException("Ill-formed language: " + (language))
        }
        if (Int32(script.size) > 0 && !LanguageTag.isScript(script)) {
            throw LocaleSyntaxException("Ill-formed script: " + (script))
        }
        if (Int32(region.size) > 0 && !LanguageTag.isRegion(region)) {
            throw LocaleSyntaxException("Ill-formed region: " + (region))
        }
        if (Int32(variant.size) > 0) {
            let errIdx = checkVariants(variant, BaseLocale.SEP)
            if (errIdx != -1) {
                throw LocaleSyntaxException("Ill-formed variant: " + (variant), errIdx)
            }
        }
        _language = language
        _script = script
        _region = region
        _variant = variant
        clearExtensions()
        let extKeys: Set<Character> = if (extensions.isNone()) { None } else { extensions.getKeys() }
        if (extKeys.isSome()) {
            for (key in extKeys) {
                let e = extensions.getExtension(key)
                if (checkOptionalIs<UnicodeLocaleExtension, Extension>(e)) {
                    let ue = e
                    for (uatr in ue.getUnicodeLocaleAttributes()) {
                        if (_uattributes.isNone()) {
                            _uattributes = HashSet<InternalLocaleBuilder_CaseInsensitiveString>(4)
                        }
                        _uattributes.put(InternalLocaleBuilder_CaseInsensitiveString(uatr))
                    }
                    for (ukey in ue.getUnicodeLocaleKeys()) {
                        if (_ukeywords.isNone()) {
                            _ukeywords = HashMap<InternalLocaleBuilder_CaseInsensitiveString, String>(4)
                        }
                        _ukeywords.put(InternalLocaleBuilder_CaseInsensitiveString(ukey), ue.getUnicodeLocaleType(ukey))
                    }
                } else {
                    if (_extensions.isNone()) {
                        _extensions = HashMap<InternalLocaleBuilder_CaseInsensitiveChar, String>(4)
                    }
                    _extensions.put(InternalLocaleBuilder_CaseInsensitiveChar(key.charValue()), e.getValue())
                }
            }
        }
        return this
    }

    public func clear(): InternalLocaleBuilder {
        _language = ""
        _script = ""
        _region = ""
        _variant = ""
        clearExtensions()
        return this
    }

    public func clearExtensions(): InternalLocaleBuilder {
        if (_extensions.isSome()) {
            _extensions.clear()
        }
        if (_uattributes.isSome()) {
            _uattributes.clear()
        }
        if (_ukeywords.isSome()) {
            _ukeywords.clear()
        }
        return this
    }

    public func getBaseLocale(): BaseLocale {
        let language = _language
        let script = _script
        let region = _region
        var variant = _variant
        if (_extensions.isSome()) {
            let privuse = _extensions.get(PRIVUSE_KEY)
            if (privuse.isSome()) {
                let itr = StringTokenIterator(privuse, LanguageTag.SEP)
                var sawPrefix = false
                var privVarStart = -1
                while (!itr.isDone()) {
                    if (sawPrefix) {
                        privVarStart = itr.currentStart()
                        break
                    }
                    if (AsciiUtil.caseIgnoreMatch(itr.current(), LanguageTag.PRIVUSE_VARIANT_PREFIX)) {
                        sawPrefix = true
                    }
                    itr.next()
                }
                if (privVarStart != -1) {
                    let sb = StringBuilder(variant)
                    if (Int32(sb.size) != 0) {
                        sb.append(BaseLocale.SEP)
                    }
                    sb.append(privuse[Int64(privVarStart)..].replaceAll(LanguageTag.SEP, BaseLocale.SEP))
                    variant = sb.toString()
                }
            }
        }
        return BaseLocale.getInstance(language, script, region, variant)
    }

    public func getLocaleExtensions(): LocaleExtensions {
        if ((_extensions.isNone() || Int32(_extensions.size) == 0) && (_uattributes.isNone() || Int32(_uattributes.size) == 0) && (_ukeywords.isNone() || Int32(_ukeywords.size) == 0)) {
            return LocaleExtensions.EMPTY_EXTENSIONS
        }
        return LocaleExtensions(_extensions, _uattributes, _ukeywords)
    }

    static func removePrivateuseVariant(privuseVal: String): String {
        let itr = StringTokenIterator(privuseVal, LanguageTag.SEP)
        var prefixStart = -1
        var sawPrivuseVar = false
        while (!itr.isDone()) {
            if (prefixStart != -1) {
                sawPrivuseVar = true
                break
            }
            if (AsciiUtil.caseIgnoreMatch(itr.current(), LanguageTag.PRIVUSE_VARIANT_PREFIX)) {
                prefixStart = itr.currentStart()
            }
            itr.next()
        }
        if (!sawPrivuseVar) {
            return privuseVal
        }
        if (!(prefixStart == 0 || prefixStart > 1)) {
            throw AssertionError()
        }
        return if (prefixStart == 0) { None } else { privuseVal[0..Int64(prefixStart - 1)] }
    }

    private func checkVariants(variants: String, sep: String): Int32 {
        let itr = StringTokenIterator(variants, sep)
        while (!itr.isDone()) {
            let s = itr.current()
            if (!LanguageTag.isVariant(s)) {
                return itr.currentStart()
            }
            itr.next()
        }
        return -1
    }

    private func setUnicodeLocaleExtension(subtags: String): Unit {
        if (_uattributes.isSome()) {
            _uattributes.clear()
        }
        if (_ukeywords.isSome()) {
            _ukeywords.clear()
        }
        let itr = StringTokenIterator(subtags, LanguageTag.SEP)
        while (!itr.isDone()) {
            if (!UnicodeLocaleExtension.isAttribute(itr.current())) {
                break
            }
            if (_uattributes.isNone()) {
                _uattributes = HashSet<InternalLocaleBuilder_CaseInsensitiveString>(4)
            }
            _uattributes.put(InternalLocaleBuilder_CaseInsensitiveString(itr.current()))
            itr.next()
        }
        var key: InternalLocaleBuilder_CaseInsensitiveString
        var Type: String
        var typeStart = -1
        var typeEnd = -1
        while (!itr.isDone()) {
            if (key.isSome()) {
                if (UnicodeLocaleExtension.isKey(itr.current())) {
                    if (!(typeStart == -1 || typeEnd != -1)) {
                        throw AssertionError()
                    }
                    Type = if (typeStart == -1) { "" } else { subtags[Int64(typeStart)..Int64(typeEnd)] }
                    if (_ukeywords.isNone()) {
                        _ukeywords = HashMap<InternalLocaleBuilder_CaseInsensitiveString, String>(4)
                    }
                    _ukeywords.put(key, Type)
                    let tmpKey = InternalLocaleBuilder_CaseInsensitiveString(itr.current())
                    key = if (_ukeywords.contains(tmpKey)) { None } else { tmpKey }
                    typeStart = match (0) { case _ => typeEnd = -1; typeEnd }
                } else {
                    if (typeStart == -1) {
                        typeStart = itr.currentStart()
                    }
                    typeEnd = itr.currentEnd()
                }
            } else if (UnicodeLocaleExtension.isKey(itr.current())) {
                key = InternalLocaleBuilder_CaseInsensitiveString(itr.current())
                if (_ukeywords.isSome() && _ukeywords.contains(key)) {
                    key = None
                }
            }
            if (!itr.hasNext()) {
                if (key.isSome()) {
                    if (!(typeStart == -1 || typeEnd != -1)) {
                        throw AssertionError()
                    }
                    Type = if (typeStart == -1) { "" } else { subtags[Int64(typeStart)..Int64(typeEnd)] }
                    if (_ukeywords.isNone()) {
                        _ukeywords = HashMap<InternalLocaleBuilder_CaseInsensitiveString, String>(4)
                    }
                    _ukeywords.put(key, Type)
                }
                break
            }
            itr.next()
        }
    }
}


class InternalLocaleBuilder_CaseInsensitiveString {
    private var _s: String

    init(s: String) {
        _s = s
    }

    public func value(): String {
        return _s
    }

    public override func hashCode(): Int64 {
        return AsciiUtil.toLowerString(_s).hashCode()
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (!(checkOptionalIs<InternalLocaleBuilder_CaseInsensitiveString, Object>(obj))) {
            return false
        }
        return AsciiUtil.caseIgnoreMatch(_s, obj.value())
    }
}


class InternalLocaleBuilder_CaseInsensitiveChar {
    private var _c: Char = '\u{0000}'

    init(c: Char) {
        _c = c
    }

    public func value(): Char {
        return _c
    }

    public override func hashCode(): Int64 {
        return Int64(UInt32(AsciiUtil.toLower(_c)))
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (!(checkOptionalIs<InternalLocaleBuilder_CaseInsensitiveChar, Object>(obj))) {
            return false
        }
        return _c == AsciiUtil.toLower(obj.value())
    }
}
