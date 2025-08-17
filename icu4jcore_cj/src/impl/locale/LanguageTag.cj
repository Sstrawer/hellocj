package icu4cj.impl.locale


public class LanguageTag {
    private static let JDKIMPL = false

    public static let SEP = "-"

    public static let PRIVATEUSE = "x"

    public static var UNDETERMINED: String = "und"

    public static let PRIVUSE_VARIANT_PREFIX = "lvariant"

    private var _language: String = ""

    private var _script: String = ""

    private var _region: String = ""

    private var _privateuse: String = ""

    private var _extlangs = Array<String>(0, { _ => "" })

    private var _variants = Array<String>(0, { _ => "" })

    private var _extensions = Array<String>(0, { _ => "" })

    private static let LEGACY: Map<AsciiUtil_CaseInsensitiveKey, Array<String>> = HashMap<AsciiUtil_CaseInsensitiveKey, Array<String>>()



    public static func parse(languageTag: String, sts: ParseStatus): LanguageTag {
        var tempsts = sts
        if (tempsts.isNone()) {
            tempsts = ParseStatus()
        } else {
            tempsts.reset()
        }
        let itr: StringTokenIterator
        var isLegacy = false
        var gfmap = LEGACY.get(AsciiUtil_CaseInsensitiveKey(languageTag))
        var dash = 2
        while (gfmap.isNone() && (match (0) { case _ => dash = indexOfWrap(languageTag.indexOf(UInt8(UInt32('-')), Int64(dash + 1))); dash }) != -1) {
            gfmap = LEGACY.get(AsciiUtil_CaseInsensitiveKey(languageTag[0..Int64(dash)]))
        }
        if (gfmap.isSome()) {
            if (Int32(gfmap[0].size) == Int32(languageTag.size)) {
                itr = StringTokenIterator(gfmap[1], SEP)
            } else {
                itr = StringTokenIterator((gfmap[1]) + languageTag[Int64(dash)..], SEP)
            }
            isLegacy = true
        } else {
            itr = StringTokenIterator(languageTag, SEP)
        }
        let tag = LanguageTag()
        if (tag.parseLanguage(itr, tempsts)) {
            if (Int32(tag._language.size) <= 3) {
                tag.parseExtlangs(itr, tempsts)
            }
            tag.parseScript(itr, tempsts)
            tag.parseRegion(itr, tempsts)
            tag.parseVariants(itr, tempsts)
            tag.parseExtensions(itr, tempsts)
        }
        tag.parsePrivateuse(itr, tempsts)
        if (isLegacy) {
            if (!(itr.isDone())) {
                throw AssertionError()
            }
            if (!(!tempsts.isError())) {
                throw AssertionError()
            }
            tempsts._parseLength = Int32(languageTag.size)
        } else if (!itr.isDone() && !tempsts.isError()) {
            let s = itr.current()
            tempsts._errorIndex = itr.currentStart()
            if (Int32(s.size) == 0) {
                tempsts._errorMsg = "Empty subtag"
            } else {
                tempsts._errorMsg = "Invalid subtag: " + (s)
            }
        }
        return tag
    }

    private func parseLanguage(itr: StringTokenIterator, sts: ParseStatus): Bool {
        if (itr.isDone() || sts.isError()) {
            return false
        }
        var found = false
        let s = itr.current()
        if (isLanguage(s)) {
            found = true
            _language = s
            sts._parseLength = itr.currentEnd()
            itr.next()
        }
        return found
    }

    private func parseExtlangs(itr: StringTokenIterator, sts: ParseStatus): Bool {
        if (itr.isDone() || sts.isError()) {
            return false
        }
        var found = false
        while (!itr.isDone()) {
            let s = itr.current()
            if (!isExtlang(s)) {
                break
            }
            found = true
            if (_extlangs.isEmpty()) {
                _extlangs = ArrayList<String>(3)
            }
            _extlangs.append(s)
            sts._parseLength = itr.currentEnd()
            itr.next()
            if (Int32(_extlangs.size) == 3) {
                break
            }
        }
        return found
    }

    private func parseScript(itr: StringTokenIterator, sts: ParseStatus): Bool {
        if (itr.isDone() || sts.isError()) {
            return false
        }
        var found = false
        let s = itr.current()
        if (isScript(s)) {
            found = true
            _script = s
            sts._parseLength = itr.currentEnd()
            itr.next()
        }
        return found
    }

    private func parseRegion(itr: StringTokenIterator, sts: ParseStatus): Bool {
        if (itr.isDone() || sts.isError()) {
            return false
        }
        var found = false
        let s = itr.current()
        if (isRegion(s)) {
            found = true
            _region = s
            sts._parseLength = itr.currentEnd()
            itr.next()
        }
        return found
    }

    private func parseVariants(itr: StringTokenIterator, sts: ParseStatus): Bool {
        if (itr.isDone() || sts.isError()) {
            return false
        }
        var found = false
        while (!itr.isDone()) {
            var s = itr.current()
            if (!isVariant(s)) {
                break
            }
            found = true
            if (_variants.isEmpty()) {
                _variants = ArrayList<String>(3)
            }
            s = s.toUpper()
            if (!_variants.contains(s)) {
                _variants.append(s)
            }
            sts._parseLength = itr.currentEnd()
            itr.next()
        }
        return found
    }

    private func parseExtensions(itr: StringTokenIterator, sts: ParseStatus): Bool {
        if (itr.isDone() || sts.isError()) {
            return false
        }
        var found = false
        while (!itr.isDone()) {
            var s = itr.current()
            if (isExtensionSingleton(s)) {
                let start = itr.currentStart()
                let singleton = s.toLower()
                let sb = StringBuilder(singleton)
                itr.next()
                while (!itr.isDone()) {
                    s = itr.current()
                    if (isExtensionSubtag(s)) {
                        sb.append(SEP).append(s)
                        sts._parseLength = itr.currentEnd()
                    } else {
                        break
                    }
                    itr.next()
                }
                if (sts._parseLength <= start) {
                    sts._errorIndex = start
                    sts._errorMsg = "Incomplete extension '" + singleton + "'"
                    break
                }
                if (Int32(_extensions.size) == 0) {
                    _extensions = ArrayList<String>(4)
                }
                var alreadyHas = false
                for (extension in _extensions) {
                    alreadyHas |= Char(extension[0]) == sb.get(0)
                }
                if (!alreadyHas) {
                    _extensions.append(sb.toString())
                }
                found = true
            } else {
                break
            }
        }
        return found
    }

    private func parsePrivateuse(itr: StringTokenIterator, sts: ParseStatus): Bool {
        if (itr.isDone() || sts.isError()) {
            return false
        }
        var found = false
        var s = itr.current()
        if (isPrivateusePrefix(s)) {
            let start = itr.currentStart()
            let sb = StringBuilder(s)
            itr.next()
            while (!itr.isDone()) {
                s = itr.current()
                if (!isPrivateuseSubtag(s)) {
                    break
                }
                sb.append(SEP).append(s)
                sts._parseLength = itr.currentEnd()
                itr.next()
            }
            if (sts._parseLength <= start) {
                sts._errorIndex = start
                sts._errorMsg = "Incomplete privateuse"
            } else {
                _privateuse = sb.toString()
                found = true
            }
        }
        return found
    }

    public static func parseLocale(baseLocale: BaseLocale, localeExtensions: LocaleExtensions): LanguageTag {
        let tag = LanguageTag()
        var language = baseLocale.getLanguage()
        let script = baseLocale.getScript()
        let region = baseLocale.getRegion()
        let variant = baseLocale.getVariant()
        var hasSubtag = false
        var privuseVar: String
        if (Int32(language.size) > 0 && isLanguage(language)) {
            if (language == "iw") {
                language = "he"
            } else if (language == "ji") {
                language = "yi"
            } else if (language == "in") {
                language = "id"
            }
            tag._language = language
        }
        if (Int32(script.size) > 0 && isScript(script)) {
            tag._script = canonicalizeScript(script)
            hasSubtag = true
        }
        if (Int32(region.size) > 0 && isRegion(region)) {
            tag._region = canonicalizeRegion(region)
            hasSubtag = true
        }
        if (JDKIMPL) {
            if (tag._language == "no" && tag._region == "NO" && variant == "NY") {
                tag._language = "nn"
                variant = ""
            }
        }
        if (Int32(variant.size) > 0) {
            var variants: ArrayList<String>
            let varitr = StringTokenIterator(variant, BaseLocale.SEP)
            while (!varitr.isDone()) {
                let variant = varitr.current()
                if (!isVariant(var)) {
                    break
                }
                if (variants.isNone()) {
                    variants = ArrayList<String>()
                }
                if (JDKIMPL) {
                    variants.append(var)
                } else {
                    variants.append(canonicalizeVariant(var))
                }
                varitr.next()
            }
            if (variants.isSome()) {
                tag._variants = variants
                hasSubtag = true
            }
            if (!varitr.isDone()) {
                let buf = StringBuilder()
                while (!varitr.isDone()) {
                    var prvv = varitr.current()
                    if (!isPrivateuseSubtag(prvv)) {
                        break
                    }
                    if (Int32(buf.size) > 0) {
                        buf.append(SEP)
                    }
                    if (!JDKIMPL) {
                        prvv = AsciiUtil.toLowerString(prvv)
                    }
                    buf.append(prvv)
                    varitr.next()
                }
                if (Int32(buf.size) > 0) {
                    privuseVar = buf.toString()
                }
            }
        }
        var extensions: ArrayList<String>
        var privateuse: String
        let locextKeys = localeExtensions.getKeys()
        for (locextKey in locextKeys) {
            let ext = localeExtensions.getExtension(locextKey)
            if (isPrivateusePrefixChar(locextKey.charValue())) {
                privateuse = ext.getValue()
            } else {
                if (extensions.isNone()) {
                    extensions = ArrayList<String>()
                }
                extensions.append(toString(locextKey) + SEP + (ext.getValue()))
            }
        }
        if (extensions.isSome()) {
            tag._extensions = extensions
            hasSubtag = true
        }
        if (privuseVar.isSome()) {
            if (privateuse.isNone()) {
                privateuse = PRIVUSE_VARIANT_PREFIX + SEP + (privuseVar)
            } else {
                privateuse = (privateuse) + SEP + PRIVUSE_VARIANT_PREFIX + SEP + privuseVar.replace(BaseLocale.SEP, SEP)
            }
        }
        if (privateuse.isSome()) {
            tag._privateuse = privateuse
        }
        if (Int32(tag._language.size) == 0 && (hasSubtag || privateuse.isNone())) {
            tag._language = UNDETERMINED
        }
        return tag
    }

    public func getLanguage(): String {
        return _language
    }

    public func getExtlangs(): ArrayList<String> {
        return Collections.unmodifiableList(_extlangs)
    }

    public func getScript(): String {
        return _script
    }

    public func getRegion(): String {
        return _region
    }

    public func getVariants(): ArrayList<String> {
        return Collections.unmodifiableList(_variants)
    }

    public func getExtensions(): ArrayList<String> {
        return Collections.unmodifiableList(_extensions)
    }

    public func getPrivateuse(): String {
        return _privateuse
    }

    public static func isLanguage(s: String): Bool {
        return (Int32(s.size) >= 2) && (Int32(s.size) <= 8) && AsciiUtil.isAlphaString(s)
    }

    public static func isExtlang(s: String): Bool {
        return (Int32(s.size) == 3) && AsciiUtil.isAlphaString(s)
    }

    public static func isScript(s: String): Bool {
        return (Int32(s.size) == 4) && AsciiUtil.isAlphaString(s)
    }

    public static func isRegion(s: String): Bool {
        return ((Int32(s.size) == 2) && AsciiUtil.isAlphaString(s)) || ((Int32(s.size) == 3) && AsciiUtil.isNumericString(s))
    }

    public static func isVariant(s: String): Bool {
        let len = Int32(s.size)
        if (len >= 5 && len <= 8) {
            return AsciiUtil.isAlphaNumericString(s)
        }
        if (len == 4) {
            return AsciiUtil.isNumeric(Char(s[0])) && AsciiUtil.isAlphaNumeric(Char(s[1])) && AsciiUtil.isAlphaNumeric(Char(s[2])) && AsciiUtil.isAlphaNumeric(Char(s[3]))
        }
        return false
    }

    public static func isTKey(s: String): Bool {
        return (Int32(s.size) == 2) && AsciiUtil.isAlpha(Char(s[0])) && AsciiUtil.isNumeric(Char(s[1]))
    }

    public static func isExtensionSingleton(s: String): Bool {
        return (Int32(s.size) == 1) && AsciiUtil.isAlphaNumericString(s) && !AsciiUtil.caseIgnoreMatch(PRIVATEUSE, s)
    }

    public static func isExtensionSingletonChar(c: Char): Bool {
        return isExtensionSingleton(c.toString())
    }

    public static func isExtensionSubtag(s: String): Bool {
        return (Int32(s.size) >= 2) && (Int32(s.size) <= 8) && AsciiUtil.isAlphaNumericString(s)
    }

    public static func isPrivateusePrefix(s: String): Bool {
        return (Int32(s.size) == 1) && AsciiUtil.caseIgnoreMatch(PRIVATEUSE, s)
    }

    public static func isPrivateusePrefixChar(c: Char): Bool {
        return (AsciiUtil.caseIgnoreMatch(PRIVATEUSE, c.toString()))
    }

    public static func isPrivateuseSubtag(s: String): Bool {
        return (Int32(s.size) >= 1) && (Int32(s.size) <= 8) && AsciiUtil.isAlphaNumericString(s)
    }

    public static func canonicalizeLanguage(s: String): String {
        return AsciiUtil.toLowerString(s)
    }

    public static func canonicalizeExtlang(s: String): String {
        return AsciiUtil.toLowerString(s)
    }

    public static func canonicalizeScript(s: String): String {
        return AsciiUtil.toTitleString(s)
    }

    public static func canonicalizeRegion(s: String): String {
        return AsciiUtil.toUpperString(s)
    }

    public static func canonicalizeVariant(s: String): String {
        return AsciiUtil.toLowerString(s)
    }

    public static func canonicalizeExtension(s: String): String {
        var temps = s
        temps = AsciiUtil.toLowerString(temps)
        if (temps.startsWith("u-")) {
            var found: Int32 = 0
            while (temps.endsWith("-true")) {
                temps = temps[0..Int64(Int32(temps.size) - 5)]
            }
            while ((match (0) { case _ => found = indexOfWrap(temps.indexOf("-true-")); found }) > 0) {
                temps = temps[0..Int64(found)] + temps[Int64(found + 5)..]
            }
            while (temps.endsWith("-yes")) {
                temps = temps[0..Int64(Int32(temps.size) - 4)]
            }
            while ((match (0) { case _ => found = indexOfWrap(temps.indexOf("-yes-")); found }) > 0) {
                temps = temps[0..Int64(found)] + temps[Int64(found + 4)..]
            }
        }
        return temps
    }

    public static func canonicalizeExtensionSingleton(s: String): String {
        return AsciiUtil.toLowerString(s)
    }

    public static func canonicalizeExtensionSubtag(s: String): String {
        return AsciiUtil.toLowerString(s)
    }

    public static func canonicalizePrivateuse(s: String): String {
        return AsciiUtil.toLowerString(s)
    }

    public static func canonicalizePrivateuseSubtag(s: String): String {
        return AsciiUtil.toLowerString(s)
    }

    public override func toString(): String {
        let sb = StringBuilder()
        if (Int32(_language.size) > 0) {
            sb.append(_language)
            for (extlang in _extlangs) {
                sb.append(SEP).append(extlang)
            }
            if (Int32(_script.size) > 0) {
                sb.append(SEP).append(_script)
            }
            if (Int32(_region.size) > 0) {
                sb.append(SEP).append(_region)
            }
            for (variant in _variants) {
                sb.append(SEP).append(variant)
            }
            for (extension in _extensions) {
                sb.append(SEP).append(extension)
            }
        }
        if (Int32(_privateuse.size) > 0) {
            if (Int32(sb.size) > 0) {
                sb.append(SEP)
            }
            sb.append(_privateuse)
        }
        return sb.toString()
    }
}
