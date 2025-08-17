package icu4cj.util


public class ULocale <: Serializable & Comparable<ULocale> {
    private static let GeneratedStaticLockObject = Monitor()

    private static let serialVersionUID = 3715177670352309217

    private static var nameCache: CacheBase<String, String, Void> = ULocale_1()

    public static let ENGLISH = ULocale("en", Locale.ENGLISH)

    public static let FRENCH = ULocale("fr", Locale.FRENCH)

    public static let GERMAN = ULocale("de", Locale.GERMAN)

    public static let ITALIAN = ULocale("it", Locale.ITALIAN)

    public static let JAPANESE = ULocale("ja", Locale.JAPANESE)

    public static let KOREAN = ULocale("ko", Locale.KOREAN)

    public static let CHINESE = ULocale("zh", Locale.CHINESE)

    public static let SIMPLIFIED_CHINESE = ULocale("zh_Hans")

    public static let TRADITIONAL_CHINESE = ULocale("zh_Hant")

    public static let FRANCE = ULocale("fr_FR", Locale.FRANCE)

    public static let GERMANY = ULocale("de_DE", Locale.GERMANY)

    public static let ITALY = ULocale("it_IT", Locale.ITALY)

    public static let JAPAN = ULocale("ja_JP", Locale.JAPAN)

    public static let KOREA = ULocale("ko_KR", Locale.KOREA)

    public static let CHINA = ULocale("zh_Hans_CN")

    public static let PRC = CHINA

    public static let TAIWAN = ULocale("zh_Hant_TW")

    public static let UK = ULocale("en_GB", Locale.UK)

    public static let US = ULocale("en_US", Locale.US)

    public static let CANADA = ULocale("en_CA", Locale.CANADA)

    public static let CANADA_FRENCH = ULocale("fr_CA", Locale.CANADA_FRENCH)

    private static let EMPTY_STRING = ""

    static let UNDERSCORE = '_'

    private static let EMPTY_LOCALE = Locale("", "")

    static let LOCALE_ATTRIBUTE_KEY = "attribute"

    public static let ROOT = ULocale("", EMPTY_LOCALE)

    private static let CACHE: SoftCache<Locale, ULocale, Void> = ULocale_2()

      private var locale: Locale = None

    private var localeID: String

      private var baseLocale: BaseLocale

      private var extensions: LocaleExtensions

    private static var CANONICALIZE_MAP: Array<Array<String>> = [["art__LOJBAN", "jbo"], ["cel__GAULISH", "cel__GAULISH"], ["de__1901", "de__1901"], ["de__1906", "de__1906"], ["en__BOONT", "en__BOONT"], ["en__SCOUSE", "en__SCOUSE"], ["hy__AREVELA", "hy", None, None], ["hy__AREVMDA", "hyw", None, None], ["sl__ROZAJ", "sl__ROZAJ"], ["zh__GUOYU", "zh"], ["zh__HAKKA", "hak"], ["zh__XIANG", "hsn"], ["zh_GAN", "gan"], ["zh_MIN", "zh__MIN"], ["zh_MIN_NAN", "nan"], ["zh_WUU", "wuu"], ["zh_YUE", "yue"]]

    init(localeID: String, locale: Locale) {
        this.localeID = localeID
        this.locale = locale
    }

    public static func forLocale(loc: Locale): ULocale {
        if (loc.isNone()) {
            return None
        }
        return CACHE.getInstance(loc, None)
    }

    public init(localeID: String) {
        this.localeID = getNameStatic(localeID)
    }

    public init(a: String, b: String) {
        this(a, b, None)
    }

    public init(a: String, b: String, c: String) {
        localeID = getNameStatic(lscvToID(a, b, c, EMPTY_STRING))
    }

    public static func createCanonical(nonCanonicalID: String): ULocale {
        return ULocale(canonicalize(nonCanonicalID), None)
    }

    public static func createCanonical(locale: ULocale): ULocale {
        return createCanonical(locale.getName())
    }

    static func lscvToID(lang: String, script: String, country: String, variant: String): String {
        let buf = StringBuilder()
        if (lang.isSome() && Int32(lang.size) > 0) {
            buf.append(lang)
        }
        if (script.isSome() && Int32(script.size) > 0) {
            buf.append(UNDERSCORE)
            buf.append(script)
        }
        if (country.isSome() && Int32(country.size) > 0) {
            buf.append(UNDERSCORE)
            buf.append(country)
        }
        if (variant.isSome() && Int32(variant.size) > 0) {
            if (country.isNone() || Int32(country.size) == 0) {
                buf.append(UNDERSCORE)
            }
            buf.append(UNDERSCORE)
            buf.append(variant)
        }
        return buf.toString()
    }

    public func toLocale(): Locale {
        if (locale.isNone()) {
            locale = ULocale_JDKLocaleHelper.toLocale(this)
        }
        return locale
    }

     private static var defaultULocale: ULocale

    private static var defaultCategoryLocales: Array<Locale> = Array<Locale>(ULocale_Category.values().size)

    private static var defaultCategoryULocales: Array<ULocale> = Array<ULocale>(ULocale_Category.values().size)


    public static func getDefault(): ULocale {
        var currentDefaultULocale = defaultULocale
        if (currentDefaultULocale.isNone()) {
            return ULocale.ROOT
        } else if (refEq(currentDefaultULocale.locale, Locale.getDefault())) {
            return currentDefaultULocale
        }
        synchronized (getMonitorByObject(TypeInfo.of<ULocale>())) {
            let currentDefault = Locale.getDefault()
            if (!currentDefault.isSome()) {
                throw AssertionError()
            }
            currentDefaultULocale = defaultULocale
            if (!currentDefaultULocale.isSome()) {
                throw AssertionError()
            }
            if (refEq(currentDefaultULocale.locale, currentDefault)) {
                return currentDefaultULocale
            }
            let nextULocale = forLocale(currentDefault)
            if (!nextULocale.isSome()) {
                throw AssertionError()
            }
            if (!ULocale_JDKLocaleHelper.hasLocaleCategoriesStatic()) {
                for (cat in ULocale_Category.values()) {
                    let idx = cat.ordinal
                    defaultCategoryLocales[Int64(idx)] = currentDefault
                    defaultCategoryULocales[Int64(idx)] = nextULocale
                }
            }
            return match (0) { case _ => defaultULocale = nextULocale; defaultULocale }
        }
    }

    public static func setDefault(newLocale: ULocale): Unit {
        synchronized (GeneratedStaticLockObject) {
            Locale.setDefault(newLocale.toLocale())
            defaultULocale = newLocale
            for (cat in ULocale_Category.values()) {
                setDefault(cat, newLocale)
            }
        }
    }

    public static func getDefault(category: ULocale_Category): ULocale {
        synchronized (getMonitorByObject(TypeInfo.of<ULocale>())) {
            let idx = category.ordinal
            if (defaultCategoryULocales[Int64(idx)].isNone()) {
                return ULocale.ROOT
            }
            if (ULocale_JDKLocaleHelper.hasLocaleCategoriesStatic()) {
                let currentCategoryDefault = ULocale_JDKLocaleHelper.getDefault(category)
                if (!refEq(defaultCategoryLocales[Int64(idx)], currentCategoryDefault)) {
                    defaultCategoryLocales[Int64(idx)] = currentCategoryDefault
                    defaultCategoryULocales[Int64(idx)] = forLocale(currentCategoryDefault)
                }
            } else {
                let currentDefault = Locale.getDefault()
                if (!refEq(defaultULocale.locale, currentDefault)) {
                    defaultULocale = forLocale(currentDefault)
                    for (cat in ULocale_Category.values()) {
                        let tmpIdx = cat.ordinal
                        defaultCategoryLocales[Int64(tmpIdx)] = currentDefault
                        defaultCategoryULocales[Int64(tmpIdx)] = forLocale(currentDefault)
                    }
                }
            }
            return defaultCategoryULocales[Int64(idx)]
        }
    }

    public static func setDefault(category: ULocale_Category, newLocale: ULocale): Unit {
        synchronized (GeneratedStaticLockObject) {
            let newJavaDefault = newLocale.toLocale()
            let idx = category.ordinal
            defaultCategoryULocales[Int64(idx)] = newLocale
            defaultCategoryLocales[Int64(idx)] = newJavaDefault
            ULocale_JDKLocaleHelper.setDefault(category, newJavaDefault)
        }
    }

    public override func clone(): Object {
        return this
    }

    public override func hashCode(): Int64 {
        return localeID.hashCode()
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (checkOptionalIs<ULocale, Object>(obj)) {
            return localeID.equals(obj.localeID)
        }
        return false
    }

    public override func compareTo(other: ULocale): Int32 {
        if (refEq(this, other)) {
            return 0
        }
        var cmp = 0
        cmp = getLanguage().compare(other.getLanguage()).value()
        if (cmp == 0) {
            cmp = getScript().compare(other.getScript()).value()
            if (cmp == 0) {
                cmp = getCountry().compare(other.getCountry()).value()
                if (cmp == 0) {
                    cmp = getVariant().compare(other.getVariant()).value()
                    if (cmp == 0) {
                        let thisKwdItr = getKeywords()
                        let otherKwdItr = other.getKeywords()
                        if (thisKwdItr.isNone()) {
                            cmp = if (otherKwdItr.isNone()) { 0 } else { -1 }
                        } else if (otherKwdItr.isNone()) {
                            cmp = 1
                        } else {
                            while (cmp == 0 && thisKwdItr.hasNext()) {
                                if (!otherKwdItr.hasNext()) {
                                    cmp = 1
                                    break
                                }
                                let thisKey = thisKwdItr.next()
                                let otherKey = otherKwdItr.next()
                                cmp = thisKey.compare(otherKey).value()
                                if (cmp == 0) {
                                    let thisVal = getKeywordValue(thisKey)
                                    let otherVal = other.getKeywordValue(otherKey)
                                    if (thisVal.isNone()) {
                                        cmp = if (otherVal.isNone()) { 0 } else { -1 }
                                    } else if (otherVal.isNone()) {
                                        cmp = 1
                                    } else {
                                        cmp = thisVal.compare(otherVal).value()
                                    }
                                }
                            }
                            if (cmp == 0 && otherKwdItr.hasNext()) {
                                cmp = -1
                            }
                        }
                    }
                }
            }
        }
        return if (cmp < 0) { -1 } else { (if (cmp > 0) { 1 } else { 0 }) }
    }

    public static func getAvailableLocales(): Array<ULocale> {
        return ICUResourceBundle.getAvailableULocales().clone()
    }

    public static func getAvailableLocalesByType(Type: ULocale_AvailableType): Collection<ULocale> {
        if (Type.isNone()) {
            throw IllegalArgumentException()
        }
        let result: ArrayList<ULocale>
        if (refEq(Type, ULocale_AvailableType.WITH_LEGACY_ALIASES)) {
            result = ArrayList<ULocale>()
            Collections.addAll(result, ICUResourceBundle.getAvailableULocales(ULocale_AvailableType.DEFAULT))
            Collections.addAll(result, ICUResourceBundle.getAvailableULocales(ULocale_AvailableType.ONLY_LEGACY_ALIASES))
        } else {
            result = ArrayList(getAvailableULocales(Type))
        }
        return Collections.unmodifiableList(result)
    }

    public static func getISOCountries(): Array<String> {
        return LocaleIDs.getISOCountries()
    }

    public static func getISOLanguages(): Array<String> {
        return LocaleIDs.getISOLanguages()
    }

    public func getLanguage(): String {
        return base().getLanguage()
    }

    public static func getLanguageStatic(localeID: String): String {
        return LocaleIDParser(localeID).getLanguage()
    }

    public func getScript(): String {
        return base().getScript()
    }

    public static func getScriptStatic(localeID: String): String {
        return LocaleIDParser(localeID).getScript()
    }

    public func getCountry(): String {
        return base().getRegion()
    }

    public static func getCountryStatic(localeID: String): String {
        return LocaleIDParser(localeID).getCountry()
    }

    private static func getRegionFromKey(locale: ULocale, key: String): String {
        let region = locale.getKeywordValue(key)
        if (region.isSome() && Int32(region.size) >= 3 && Int32(region.size) <= 7) {
            if ((Char(region[0])).isLetter()) {
                return AsciiUtil.toUpperString(region[0..2])
            } else {
                return region[0..3]
            }
        }
        return None
    }

    
    public static func getRegionForSupplementalData(locale: ULocale, inferRegion: Bool): String {
        var region = getRegionFromKey(locale, "rg")
        if (region.isSome()) {
            return region
        }
        region = locale.getCountry()
        if (Int32(region.size) == 0 && inferRegion) {
            region = getRegionFromKey(locale, "sd")
            if (region.isSome()) {
                return region
            }
            let maximized = addLikelySubtags(locale)
            region = maximized.getCountry()
        }
        return region
    }

    public func getVariant(): String {
        return base().getVariant()
    }

    public static func getVariantStatic(localeID: String): String {
        return LocaleIDParser(localeID).getVariant()
    }

    public static func getFallbackStatic(localeID: String): String {
        return getFallbackString(getNameStatic(localeID))
    }

    public func getFallback(): ULocale {
        if (Int32(localeID.size) == 0 || Char(localeID[0]) == '@') {
            return None
        }
        return ULocale(getFallbackString(localeID), None)
    }

    private static func getFallbackString(fallback: String): String {
        var extStart = indexOfWrap(fallback.indexOf(UInt8(UInt32('@'))))
        if (extStart == -1) {
            extStart = Int32(fallback.size)
        }
        var last = indexOfWrap(fallback.lastIndexOf(UInt8(UInt32('_')), Int64(extStart)))
        if (last == -1) {
            last = 0
        } else {
            while (last > 0) {
                if (Char(fallback[Int64(last - 1)]) != '_') {
                    break
                }
                last--
            }
        }
        return fallback[0..Int64(last)] + fallback[Int64(extStart)..]
    }

    public func getBaseName(): String {
        return getBaseNameStatic(localeID)
    }

    public static func getBaseNameStatic(localeID: String): String {
        if (indexOfWrap(localeID.indexOf(UInt8(UInt32('@')))) == -1) {
            return localeID
        }
        return LocaleIDParser(localeID).getBaseName()
    }

    public func getName(): String {
        return localeID
    }

    private static func getShortestSubtagLength(localeID: String): Int32 {
        let localeIDLength = Int32(localeID.size)
        var length = localeIDLength
        var reset = true
        var tmpLength = 0
        var i = 0
        while (i < localeIDLength) {
            if (Char(localeID[Int64(i)]) != '_' && Char(localeID[Int64(i)]) != '-') {
                if (reset) {
                    reset = false
                    tmpLength = 0
                }
                tmpLength++
            } else {
                if (tmpLength != 0 && tmpLength < length) {
                    length = tmpLength
                }
                reset = true
            }
            i++
        }
        return length
    }

    public static func getNameStatic(localeID: String): String {
        var tmpLocaleID = localeID
        if (localeID.isSome() && !localeID.contains("@") && getShortestSubtagLength(localeID) == 1) {
            if (indexOfWrap(localeID.indexOf(UInt8(UInt32('_')))) >= 0 && Char(localeID[1]) != '_' && Char(localeID[1]) != '-') {
                tmpLocaleID = localeID.replace('_'.toString(), '-'.toString())
            }
            tmpLocaleID = forLanguageTag(tmpLocaleID).getName()
            if (Int32(tmpLocaleID.size) == 0) {
                tmpLocaleID = localeID
            }
        } else if ("root".equalsIgnoreCase(localeID)) {
            tmpLocaleID = EMPTY_STRING
        } else {
            tmpLocaleID = stripLeadingUnd(localeID)
        }
        return nameCache.getInstance(tmpLocaleID, None)
    }

    private static func stripLeadingUnd(localeID: String): String {
        let length = Int32(localeID.size)
        if (length < 3) {
            return localeID
        }
        if (!localeID.regionMatches(true, 0, "und", 0, 3)) {
            return localeID
        }
        if (length == 3) {
            return EMPTY_STRING
        }
        let separator = Char(localeID[3])
        if (separator == '-' || separator == '_') {
            return localeID[3..]
        }
        return localeID
    }

    public override func toString(): String {
        return localeID
    }

    public func getKeywords(): Iterator<String> {
        return getKeywordsStatic(localeID)
    }

    public static func getKeywordsStatic(localeID: String): Iterator<String> {
        return LocaleIDParser(localeID).getKeywords()
    }

    public func getKeywordValue(keywordName: String): String {
        return getKeywordValueStatic(localeID, keywordName)
    }

    public static func getKeywordValueStatic(localeID: String, keywordName: String): String {
        return LocaleIDParser(localeID).getKeywordValue(keywordName)
    }

    public static func canonicalize(localeID: String): String {
        var parser: LocaleIDParser = LocaleIDParser(localeID, true)
        let baseName = parser.getBaseName()
        var foundVariant = false
        if (localeID == "") {
            return ""
        }
        var i = 0
        while (i < Int32(CANONICALIZE_MAP.size)) {
            let vals: Array<String> = CANONICALIZE_MAP[Int64(i)]
            if (vals[0].equals(baseName)) {
                foundVariant = true
                parser.setBaseName(vals[1])
                break
            }
            i++
        }
        if (!foundVariant) {
            if (parser.getLanguage() == "nb" && parser.getVariant() == "NY") {
                parser.setBaseName(lscvToID("nn", parser.getScript(), parser.getCountry(), None))
            }
        }
        let name = parser.getName()
        if (!isKnownCanonicalizedLocale(name)) {
            let replacer = ULocale_AliasReplacer(parser.getLanguage(), parser.getScript(), parser.getCountry(), AsciiUtil.toLowerString(parser.getVariant()), parser.getName()[parser.getBaseName().size..])
            let replaced = replacer.replace()
            if (replaced.isSome()) {
                parser = LocaleIDParser(replaced)
            }
        }
        return parser.getName()
    }

    private static func isKnownCanonicalizedLocale(name: String): Bool {
        synchronized (GeneratedStaticLockObject) {
            if (name == "c" || name == "en" || name == "en_US") {
                return true
            }
            if (gKnownCanonicalizedCases.isNone()) {
                let items = ArrayList<String>(["af", "af_ZA", "am", "am_ET", "ar", "ar_001", "as", "as_IN", "az", "az_AZ", "be", "be_BY", "bg", "bg_BG", "bn", "bn_IN", "bs", "bs_BA", "ca", "ca_ES", "cs", "cs_CZ", "cy", "cy_GB", "da", "da_DK", "de", "de_DE", "el", "el_GR", "en", "en_GB", "en_US", "es", "es_419", "es_ES", "et", "et_EE", "eu", "eu_ES", "fa", "fa_IR", "fi", "fi_FI", "fil", "fil_PH", "fr", "fr_FR", "ga", "ga_IE", "gl", "gl_ES", "gu", "gu_IN", "he", "he_IL", "hi", "hi_IN", "hr", "hr_HR", "hu", "hu_HU", "hy", "hy_AM", "id", "id_ID", "is", "is_IS", "it", "it_IT", "ja", "ja_JP", "jv", "jv_ID", "ka", "ka_GE", "kk", "kk_KZ", "km", "km_KH", "kn", "kn_IN", "ko", "ko_KR", "ky", "ky_KG", "lo", "lo_LA", "lt", "lt_LT", "lv", "lv_LV", "mk", "mk_MK", "ml", "ml_IN", "mn", "mn_MN", "mr", "mr_IN", "ms", "ms_MY", "my", "my_MM", "nb", "nb_NO", "ne", "ne_NP", "nl", "nl_NL", "no", "or", "or_IN", "pa", "pa_IN", "pl", "pl_PL", "ps", "ps_AF", "pt", "pt_BR", "pt_PT", "ro", "ro_RO", "ru", "ru_RU", "sd", "sd_IN", "si", "si_LK", "sk", "sk_SK", "sl", "sl_SI", "so", "so_SO", "sq", "sq_AL", "sr", "sr_Cyrl_RS", "sr_Latn", "sr_RS", "sv", "sv_SE", "sw", "sw_TZ", "ta", "ta_IN", "te", "te_IN", "th", "th_TH", "tk", "tk_TM", "tr", "tr_TR", "uk", "uk_UA", "ur", "ur_PK", "uz", "uz_UZ", "vi", "vi_VN", "yue", "yue_Hant", "yue_Hant_HK", "yue_HK", "zh", "zh_CN", "zh_Hans", "zh_Hans_CN", "zh_Hant", "zh_Hant_TW", "zh_TW", "zu", "zu_ZA"])
                gKnownCanonicalizedCases = HashSet<String>(items)
            }
            return gKnownCanonicalizedCases.contains(name)
        }
    }

    private static var gKnownCanonicalizedCases: Set<String>

    public func setKeywordValue(keyword: String, value: String): ULocale {
        return ULocale(setKeywordValueStatic(localeID, keyword, value), None)
    }

    public static func setKeywordValueStatic(localeID: String, keyword: String, value: String): String {
        let parser = LocaleIDParser(localeID)
        parser.setKeywordValue(keyword, value)
        return parser.getName()
    }

    public func getISO3anguage(): String {
        return getISO3anguageStatic(localeID)
    }

    public static func getISO3anguageStatic(localeID: String): String {
        return LocaleIDs.getISO3anguage(getLanguageStatic(localeID))
    }

    public func getISO3Country(): String {
        return getISO3CountryStatic(localeID)
    }

    public static func getISO3CountryStatic(localeID: String): String {
        return LocaleIDs.getISO3Country(getCountryStatic(localeID))
    }

    private static let LANG_DIR_STRING = "root-en-es-pt-zh-ja-ko-de-fr-it-ar+he+fa+ru-nl-pl-th-tr-"

    public func isRightToLeft(): Bool {
        var script = getScript()
        if (Int32(script.size) == 0) {
            let lang = getLanguage()
            if (!lang.isEmpty()) {
                let langIndex = indexOfWrap(LANG_DIR_STRING.indexOf(lang))
                if (langIndex >= 0) {
                    match (Char(LANG_DIR_STRING[Int64(langIndex + Int32(lang.size))])) {
                        case '-' => return false
                        case '+' => return true
                        case _ => ()
                    }
                }
            }
            let likely = addLikelySubtags(this)
            script = likely.getScript()
            if (Int32(script.size) == 0) {
                return false
            }
        }
        let scriptCode = UScript.getCodeFromName(script)
        return UScript.isRightToLeft(scriptCode)
    }

    public func getDisplayLanguage(): String {
        return getDisplayLanguageInternal(this, getDefault(ULocale_Category.DISPLAY), false)
    }

    public func getDisplayLanguage(displayLocale: ULocale): String {
        return getDisplayLanguageInternal(this, displayLocale, false)
    }

    public static func getDisplayLanguageStatic(localeID: String, displayLocaleID: String): String {
        return getDisplayLanguageInternal(ULocale(localeID), ULocale(displayLocaleID), false)
    }

    public static func getDisplayLanguageStatic(localeID: String, displayLocale: ULocale): String {
        return getDisplayLanguageInternal(ULocale(localeID), displayLocale, false)
    }

    public func getDisplayLanguageWithDialect(): String {
        return getDisplayLanguageInternal(this, getDefault(ULocale_Category.DISPLAY), true)
    }

    public func getDisplayLanguageWithDialect(displayLocale: ULocale): String {
        return getDisplayLanguageInternal(this, displayLocale, true)
    }

    public static func getDisplayLanguageWithDialectStatic(localeID: String, displayLocaleID: String): String {
        return getDisplayLanguageInternal(ULocale(localeID), ULocale(displayLocaleID), true)
    }

    public static func getDisplayLanguageWithDialectStatic(localeID: String, displayLocale: ULocale): String {
        return getDisplayLanguageInternal(ULocale(localeID), displayLocale, true)
    }

    private static func getDisplayLanguageInternal(locale: ULocale, displayLocale: ULocale, useDialect: Bool): String {
        let lang = if (useDialect) { locale.getBaseName() } else { locale.getLanguage() }
        return LocaleDisplayNames.getInstance(displayLocale).languageDisplayName(lang)
    }

    public func getDisplayScript(): String {
        return getDisplayScriptInternal(this, getDefault(ULocale_Category.DISPLAY))
    }

    
    public func getDisplayScriptInContext(): String {
        return getDisplayScriptInContextInternal(this, getDefault(ULocale_Category.DISPLAY))
    }

    public func getDisplayScript(displayLocale: ULocale): String {
        return getDisplayScriptInternal(this, displayLocale)
    }

    
    public func getDisplayScriptInContext(displayLocale: ULocale): String {
        return getDisplayScriptInContextInternal(this, displayLocale)
    }

    public static func getDisplayScriptStatic(localeID: String, displayLocaleID: String): String {
        return getDisplayScriptInternal(ULocale(localeID), ULocale(displayLocaleID))
    }

    
    public static func getDisplayScriptInContextStatic(localeID: String, displayLocaleID: String): String {
        return getDisplayScriptInContextInternal(ULocale(localeID), ULocale(displayLocaleID))
    }

    public static func getDisplayScriptStatic(localeID: String, displayLocale: ULocale): String {
        return getDisplayScriptInternal(ULocale(localeID), displayLocale)
    }

    
    public static func getDisplayScriptInContextStatic(localeID: String, displayLocale: ULocale): String {
        return getDisplayScriptInContextInternal(ULocale(localeID), displayLocale)
    }

    private static func getDisplayScriptInternal(locale: ULocale, displayLocale: ULocale): String {
        return LocaleDisplayNames.getInstance(displayLocale).scriptDisplayName(locale.getScript())
    }

    private static func getDisplayScriptInContextInternal(locale: ULocale, displayLocale: ULocale): String {
        return LocaleDisplayNames.getInstance(displayLocale).scriptDisplayNameInContext(locale.getScript())
    }

    public func getDisplayCountry(): String {
        return getDisplayCountryInternal(this, getDefault(ULocale_Category.DISPLAY))
    }

    public func getDisplayCountry(displayLocale: ULocale): String {
        return getDisplayCountryInternal(this, displayLocale)
    }

    public static func getDisplayCountryStatic(localeID: String, displayLocaleID: String): String {
        return getDisplayCountryInternal(ULocale(localeID), ULocale(displayLocaleID))
    }

    public static func getDisplayCountryStatic(localeID: String, displayLocale: ULocale): String {
        return getDisplayCountryInternal(ULocale(localeID), displayLocale)
    }

    private static func getDisplayCountryInternal(locale: ULocale, displayLocale: ULocale): String {
        return LocaleDisplayNames.getInstance(displayLocale).regionDisplayName(locale.getCountry())
    }

    public func getDisplayVariant(): String {
        return getDisplayVariantInternal(this, getDefault(ULocale_Category.DISPLAY))
    }

    public func getDisplayVariant(displayLocale: ULocale): String {
        return getDisplayVariantInternal(this, displayLocale)
    }

    public static func getDisplayVariantStatic(localeID: String, displayLocaleID: String): String {
        return getDisplayVariantInternal(ULocale(localeID), ULocale(displayLocaleID))
    }

    public static func getDisplayVariantStatic(localeID: String, displayLocale: ULocale): String {
        return getDisplayVariantInternal(ULocale(localeID), displayLocale)
    }

    private static func getDisplayVariantInternal(locale: ULocale, displayLocale: ULocale): String {
        return LocaleDisplayNames.getInstance(displayLocale).variantDisplayName(locale.getVariant())
    }

    public static func getDisplayKeyword(keyword: String): String {
        return getDisplayKeywordInternal(keyword, getDefault(ULocale_Category.DISPLAY))
    }

    public static func getDisplayKeyword(keyword: String, displayLocaleID: String): String {
        return getDisplayKeywordInternal(keyword, ULocale(displayLocaleID))
    }

    public static func getDisplayKeyword(keyword: String, displayLocale: ULocale): String {
        return getDisplayKeywordInternal(keyword, displayLocale)
    }

    private static func getDisplayKeywordInternal(keyword: String, displayLocale: ULocale): String {
        return LocaleDisplayNames.getInstance(displayLocale).keyDisplayName(keyword)
    }

    public func getDisplayKeywordValue(keyword: String): String {
        return getDisplayKeywordValueInternal(this, keyword, getDefault(ULocale_Category.DISPLAY))
    }

    public func getDisplayKeywordValue(keyword: String, displayLocale: ULocale): String {
        return getDisplayKeywordValueInternal(this, keyword, displayLocale)
    }

    public static func getDisplayKeywordValueStatic(localeID: String, keyword: String, displayLocaleID: String): String {
        return getDisplayKeywordValueInternal(ULocale(localeID), keyword, ULocale(displayLocaleID))
    }

    public static func getDisplayKeywordValueStatic(localeID: String, keyword: String, displayLocale: ULocale): String {
        return getDisplayKeywordValueInternal(ULocale(localeID), keyword, displayLocale)
    }

    private static func getDisplayKeywordValueInternal(locale: ULocale, keyword: String, displayLocale: ULocale): String {
        var tempkeyword = keyword
        tempkeyword = AsciiUtil.toLowerString(tempkeyword.trimAscii())
        let value = locale.getKeywordValue(tempkeyword)
        return LocaleDisplayNames.getInstance(displayLocale).keyValueDisplayName(tempkeyword, value)
    }

    public func getDisplayName(): String {
        return getDisplayNameInternal(this, getDefault(ULocale_Category.DISPLAY))
    }

    public func getDisplayName(displayLocale: ULocale): String {
        return getDisplayNameInternal(this, displayLocale)
    }

    public static func getDisplayNameStatic(localeID: String, displayLocaleID: String): String {
        return getDisplayNameInternal(ULocale(localeID), ULocale(displayLocaleID))
    }

    public static func getDisplayNameStatic(localeID: String, displayLocale: ULocale): String {
        return getDisplayNameInternal(ULocale(localeID), displayLocale)
    }

    private static func getDisplayNameInternal(locale: ULocale, displayLocale: ULocale): String {
        return LocaleDisplayNames.getInstance(displayLocale).localeDisplayName(locale)
    }

    public func getDisplayNameWithDialect(): String {
        return getDisplayNameWithDialectInternal(this, getDefault(ULocale_Category.DISPLAY))
    }

    public func getDisplayNameWithDialect(displayLocale: ULocale): String {
        return getDisplayNameWithDialectInternal(this, displayLocale)
    }

    public static func getDisplayNameWithDialectStatic(localeID: String, displayLocaleID: String): String {
        return getDisplayNameWithDialectInternal(ULocale(localeID), ULocale(displayLocaleID))
    }

    public static func getDisplayNameWithDialectStatic(localeID: String, displayLocale: ULocale): String {
        return getDisplayNameWithDialectInternal(ULocale(localeID), displayLocale)
    }

    private static func getDisplayNameWithDialectInternal(locale: ULocale, displayLocale: ULocale): String {
        return LocaleDisplayNames.getInstance(displayLocale, LocaleDisplayNames_DialectHandling.DIALECT_NAMES).localeDisplayName(locale)
    }

    public func getCharacterOrientation(): String {
        return ICUResourceTableAccess.getTableString(ICUData.ICU_BASE_NAME, this, "layout", "characters", "characters")
    }

    public func getLineOrientation(): String {
        return ICUResourceTableAccess.getTableString(ICUData.ICU_BASE_NAME, this, "layout", "lines", "lines")
    }

    public static var ACTUAL_LOCALE: ULocale_Type = ULocale_Type()

    public static var VALID_LOCALE: ULocale_Type = ULocale_Type()

    public static func acceptLanguage(acceptLanguageList: String, availableLocales: Array<ULocale>, fallback: Array<Bool>): ULocale {
        if (fallback.isSome()) {
            fallback[0] = true
        }
        let desired: LocalePriorityList
        @AssertThrows[LocaleSyntaxException]({
            desired = LocalePriorityList.add(acceptLanguageList).build()
        } catch (e: IllegalArgumentException) {
            return None
        }
        let builder = LocaleMatcher.builder()
        for (locale in availableLocales) {
            builder.addSupportedULocale(locale)
        }
        let matcher = builder.build()
        let result = matcher.getBestMatchResult(desired)
        if (result.getDesiredIndex() >= 0) {
            if (fallback.isSome() && result.getDesiredULocale().equals(result.getSupportedULocale())) {
                fallback[0] = false
            }
            return result.getSupportedULocale()
        }
        return None
    }

    public static func acceptLanguage(acceptLanguageList: Array<ULocale>, availableLocales: Array<ULocale>, fallback: Array<Bool>): ULocale {
        if (fallback.isSome()) {
            fallback[0] = true
        }
        let builder = LocaleMatcher.builder()
        for (locale in availableLocales) {
            builder.addSupportedULocale(locale)
        }
        let matcher = builder.build()
        let result: LocaleMatcher_Result
        if (Int32(acceptLanguageList.size) == 1) {
            result = matcher.getBestMatchResult(acceptLanguageList[0])
        } else {
            result = matcher.getBestMatchResult(acceptLanguageList)
        }
        if (result.getDesiredIndex() >= 0) {
            if (fallback.isSome() && result.getDesiredULocale().equals(result.getSupportedULocale())) {
                fallback[0] = false
            }
            return result.getSupportedULocale()
        }
        return None
    }

    public static func acceptLanguage(acceptLanguageList: String, fallback: Array<Bool>): ULocale {
        return acceptLanguage(acceptLanguageList, ULocale.getAvailableLocales(), fallback)
    }

    public static func acceptLanguage(acceptLanguageList: Array<ULocale>, fallback: Array<Bool>): ULocale {
        return acceptLanguage(acceptLanguageList, ULocale.getAvailableLocales(), fallback)
    }

    static let UNDEFINED_LANGUAGE = "und"

    private static let UNDEFINED_SCRIPT = "Zzzz"

    private static let UNDEFINED_REGION = "ZZ"

    public static func addLikelySubtags(loc: ULocale): ULocale {
        let tags = Array<String>(3)
        var trailing: String
        let trailingIndex = parseTagString(loc.localeID, tags)
        if (trailingIndex < Int32(loc.localeID.size)) {
            trailing = loc.localeID[Int64(trailingIndex)..]
        }
        let max = LikelySubtags.INSTANCE.makeMaximizedLsrFrom(ULocale(loc.getLanguage(), loc.getScript(), loc.getCountry()), true)
        let newLocaleID = createTagString(max.language, max.script, max.region, trailing)
        return if (newLocaleID.isNone()) { loc } else { ULocale(newLocaleID) }
    }

    public static func minimizeSubtags(loc: ULocale): ULocale {
        return minimizeSubtags(loc, ULocale_Minimize.FAVOR_REGION)
    }

    
    public static func minimizeSubtags(loc: ULocale, fieldToFavor: ULocale_Minimize): ULocale {
        let tags = Array<String>(3)
        var trailing: String
        let trailingIndex = parseTagString(loc.localeID, tags)
        if (trailingIndex < Int32(loc.localeID.size)) {
            trailing = loc.localeID[Int64(trailingIndex)..]
        }
        let lsr = LikelySubtags.INSTANCE.minimizeSubtags(loc.getLanguage(), loc.getScript(), loc.getCountry(), fieldToFavor)
        let newLocaleID = createTagString(lsr.language, lsr.script, lsr.region, trailing)
        return if (newLocaleID.isNone()) { loc } else { ULocale(newLocaleID) }
    }

    private static func isEmptyString(string: String): Bool {
        return string.isNone() || Int32(string.size) == 0
    }

    private static func appendTag(tag: String, buffer: StringBuilder): Unit {
        if (Int32(buffer.size) != 0) {
            buffer.append(UNDERSCORE)
        }
        buffer.append(tag)
    }

    private static func createTagString(lang: String, script: String, region: String, trailing: String): String {
        let parser: LocaleIDParser = None
        let tag = StringBuilder()
        if (!isEmptyString(lang)) {
            appendTag(lang, tag)
        } else {
            appendTag(UNDEFINED_LANGUAGE, tag)
        }
        if (!isEmptyString(script)) {
            appendTag(script, tag)
        }
        if (!isEmptyString(region)) {
            appendTag(region, tag)
        }
        if (trailing.isSome() && Int32(trailing.size) > 1) {
            var separators = 0
            if (Char(trailing[0]) == UNDERSCORE) {
                if (Char(trailing[1]) == UNDERSCORE) {
                    separators = 2
                }
            } else {
                separators = 1
            }
            if (!isEmptyString(region)) {
                if (separators == 2) {
                    tag.append(trailing[1..])
                } else {
                    tag.append(trailing)
                }
            } else {
                if (separators == 1) {
                    tag.append(UNDERSCORE)
                }
                tag.append(trailing)
            }
        }
        return tag.toString()
    }

    private static func parseTagString(localeID: String, tags: Array<String>): Int32 {
        let parser = LocaleIDParser(localeID)
        let lang = parser.getLanguage()
        let script = parser.getScript()
        let region = parser.getCountry()
        if (isEmptyString(lang)) {
            tags[0] = UNDEFINED_LANGUAGE
        } else {
            tags[0] = lang
        }
        if (script.equals(UNDEFINED_SCRIPT)) {
            tags[1] = ""
        } else {
            tags[1] = script
        }
        if (region.equals(UNDEFINED_REGION)) {
            tags[2] = ""
        } else {
            tags[2] = region
        }
        let variant = parser.getVariant()
        if (!isEmptyString(variant)) {
            let index = indexOfWrap(localeID.indexOf(variant))
            return if (index > 0) { index - 1 } else { index }
        } else {
            let index = indexOfWrap(localeID.indexOf(UInt8(UInt32('@'))))
            return if (index == -1) { Int32(localeID.size) } else { index }
        }
    }

    public static let PRIVATE_USE_EXTENSION = 'x'

    public static let UNICODE_LOCALE_EXTENSION = 'u'

    public func getExtension(key: Char): String {
        if (!LocaleExtensions.isValidKey(key)) {
            throw IllegalArgumentException("Invalid extension key: " + key.toString())
        }
        return extensionsMethod().getExtensionValue(Character.valueOf(key))
    }

    public func getExtensionKeys(): Set<Character> {
        return extensionsMethod().getKeys()
    }

    public func getUnicodeLocaleAttributes(): Set<String> {
        return extensionsMethod().getUnicodeLocaleAttributes()
    }

    public func getUnicodeLocaleType(key: String): String {
        if (!LocaleExtensions.isValidUnicodeLocaleKey(key)) {
            throw IllegalArgumentException("Invalid Unicode locale key: " + (key))
        }
        return extensionsMethod().getUnicodeLocaleType(key)
    }

    public func getUnicodeLocaleKeys(): Set<String> {
        return extensionsMethod().getUnicodeLocaleKeys()
    }

    public func toLanguageTag(): String {
        var base = base()
        var exts = extensionsMethod()
        if (base.getVariant().equalsIgnoreCase("POSIX")) {
            base = BaseLocale.getInstance(base.getLanguage(), base.getScript(), base.getRegion(), "")
            if (exts.getUnicodeLocaleType("va").isNone()) {
                let ilocbld = InternalLocaleBuilder()
                try {
                    ilocbld.setLocale(BaseLocale.ROOT, exts)
                    ilocbld.setUnicodeLocaleKeyword("va", "posix")
                    exts = ilocbld.getLocaleExtensions()
                } catch (e: LocaleSyntaxException) {
                    throw Exception()
                }
            }
        }
        let tag = LanguageTag.parseLocale(base, exts)
        let buf = StringBuilder()
        var subtag = tag.getLanguage()
        if (Int32(subtag.size) > 0) {
            buf.append(LanguageTag.canonicalizeLanguage(subtag))
        }
        subtag = tag.getScript()
        if (Int32(subtag.size) > 0) {
            buf.append(LanguageTag.SEP)
            buf.append(LanguageTag.canonicalizeScript(subtag))
        }
        subtag = tag.getRegion()
        if (Int32(subtag.size) > 0) {
            buf.append(LanguageTag.SEP)
            buf.append(LanguageTag.canonicalizeRegion(subtag))
        }
        var subtags = tag.getVariants()
        let variants = ArrayList<String>(subtags)
        Collections.sort(variants)
        for (s in variants) {
            buf.append(LanguageTag.SEP)
            buf.append(LanguageTag.canonicalizeVariant(s))
        }
        subtags = tag.getExtensions()
        for (s in subtags) {
            buf.append(LanguageTag.SEP)
            buf.append(LanguageTag.canonicalizeExtension(s))
        }
        subtag = tag.getPrivateuse()
        if (Int32(subtag.size) > 0) {
            if (Int32(buf.size) == 0) {
                buf.append(UNDEFINED_LANGUAGE)
            }
            buf.append(LanguageTag.SEP)
            buf.append(LanguageTag.PRIVATEUSE).append(LanguageTag.SEP)
            buf.append(LanguageTag.canonicalizePrivateuse(subtag))
        }
        return buf.toString()
    }

    public static func forLanguageTag(languageTag: String): ULocale {
        let tag = LanguageTag.parse(languageTag, None)
        let bldr = InternalLocaleBuilder()
        bldr.setLanguageTag(tag)
        return getInstance(bldr.getBaseLocale(), bldr.getLocaleExtensions())
    }

    public static func toUnicodeLocaleKey(keyword: String): String {
        var bcpKey = KeyTypeData.toBcpKey(keyword)
        if (bcpKey.isNone() && UnicodeLocaleExtension.isKey(keyword)) {
            bcpKey = AsciiUtil.toLowerString(keyword)
        }
        return bcpKey
    }

    public static func toUnicodeLocaleType(keyword: String, value: String): String {
        var bcpType = KeyTypeData.toBcpType(keyword, value, None, None)
        if (bcpType.isNone() && UnicodeLocaleExtension.isType(value)) {
            bcpType = AsciiUtil.toLowerString(value)
        }
        return bcpType
    }

    public static func toLegacyKey(keyword: String): String {
        var legacyKey = KeyTypeData.toLegacyKey(keyword)
        if (legacyKey.isNone()) {
            if (keyword.matches("[0-9a-zA-Z]+")) {
                legacyKey = AsciiUtil.toLowerString(keyword)
            }
        }
        return legacyKey
    }

    public static func toLegacyType(keyword: String, value: String): String {
        var legacyType = KeyTypeData.toLegacyType(keyword, value, None, None)
        if (legacyType.isNone()) {
            if (value.matches("[0-9a-zA-Z]+([_/\\-][0-9a-zA-Z]+)*")) {
                legacyType = AsciiUtil.toLowerString(value)
            }
        }
        return legacyType
    }

    static func getInstance(base: BaseLocale, exts: LocaleExtensions): ULocale {
        var id = lscvToID(base.getLanguage(), base.getScript(), base.getRegion(), base.getVariant())
        let extKeys = exts.getKeys()
        if (!extKeys.isEmpty()) {
            let kwds = TreeMap()
            for (key in extKeys) {
                let ext = exts.getExtension(key)
                if (checkOptionalIs<UnicodeLocaleExtension, Extension>(ext)) {
                    let uext = ext
                    let ukeys = uext.getUnicodeLocaleKeys()
                    for (bcpKey in ukeys) {
                        let bcpType = uext.getUnicodeLocaleType(bcpKey)
                        let lkey = toLegacyKey(bcpKey)
                        let ltype = toLegacyType(bcpKey, (if (Int32(bcpType.size) == 0) { Some("yes") } else { bcpType }))
                        if (lkey == "va" && ltype == "posix" && Int32(base.getVariant().size) == 0) {
                            id = (id) + "_POSIX"
                        } else {
                            kwds.put(lkey, ltype)
                        }
                    }
                    let uattributes = uext.getUnicodeLocaleAttributes()
                    if (Int32(uattributes.size) > 0) {
                        let attrbuf = StringBuilder()
                        for (attr in uattributes) {
                            if (Int32(attrbuf.size) > 0) {
                                attrbuf.append('-')
                            }
                            attrbuf.append(attr)
                        }
                        kwds.put(LOCALE_ATTRIBUTE_KEY, attrbuf.toString())
                    }
                } else {
                    kwds.put(String.valueOf(key), ext.getValue())
                }
            }
            if (!kwds.isEmpty()) {
                let buf = StringBuilder(id)
                buf.append("@")
                let kset = kwds.entrySet()
                var insertSep = false
                for (kwd in kset) {
                    if (insertSep) {
                        buf.append(";")
                    } else {
                        insertSep = true
                    }
                    buf.append(kwd.getKey())
                    buf.append("=")
                    buf.append(kwd.getValue())
                }
                id = buf.toString()
            }
        }
        return ULocale(id)
    }

    public func base(): BaseLocale {
        if (baseLocale.isNone()) {
            var language: String
            var script: String
            var region: String
            var variant: String
            language = match (0) { case _ => script = match (0) { case _ => region = match (0) { case _ => variant = ""; variant }; region }; script }
            if (!equals(ULocale.ROOT)) {
                let lp = LocaleIDParser(localeID)
                language = lp.getLanguage()
                script = lp.getScript()
                region = lp.getCountry()
                variant = lp.getVariant()
            }
            baseLocale = BaseLocale.getInstance(language, script, region, variant)
        }
        return baseLocale
    }

    public func extensionsMethod(): LocaleExtensions {
        if (extensions.isNone()) {
            let kwitr = getKeywords()
            if (kwitr.isNone()) {
                extensions = LocaleExtensions.EMPTY_EXTENSIONS
            } else {
                let intbld = InternalLocaleBuilder()
                while (kwitr.hasNext()) {
                    let key = kwitr.next()
                    if (key.equals(LOCALE_ATTRIBUTE_KEY)) {
                        let uattributes = getKeywordValue(key).split("[-_]")
                        for (uattr in uattributes) {
                            try {
                                intbld.addUnicodeLocaleAttribute(uattr)
                            })
                        }
                    } else if (Int32(key.size) >= 2) {
                        let bcpKey = toUnicodeLocaleKey(key)
                        let bcpType = toUnicodeLocaleType(key, getKeywordValue(key))
                        if (bcpKey.isSome() && bcpType.isSome()) {
                            @AssertThrows[LocaleSyntaxException]({
                                intbld.setUnicodeLocaleKeyword(bcpKey, bcpType)
                            })
                        }
                    } else if (Int32(key.size) == 1 && (Char(key[0]) != UNICODE_LOCALE_EXTENSION)) {
                        @AssertThrows[LocaleSyntaxException]({
                            intbld.setExtension(Char(key[0]), getKeywordValue(key).replace("_", LanguageTag.SEP))
                        })
                    }
                }
                extensions = intbld.getLocaleExtensions()
            }
        }
        return extensions
    }
}


class ULocale_1 <: SoftCache<String, String, Void> {
    init() {
        super()
    }

    override protected func createInstance(tmpLocaleID: String, unused: Void): String {
        return LocaleIDParser(tmpLocaleID).getName()
    }
}


public class ULocale_AvailableType <: Enum<ULocale_AvailableType> {
    public static let DEFAULT = ULocale_AvailableType("DEFAULT", 0)

    public static let ONLY_LEGACY_ALIASES = ULocale_AvailableType("ONLY_LEGACY_ALIASES", 1)

    public static let WITH_LEGACY_ALIASES = ULocale_AvailableType("WITH_LEGACY_ALIASES", 2)

    private static func _values(): Array<ULocale_AvailableType> {
        return [ULocale_AvailableType.DEFAULT, ULocale_AvailableType.ONLY_LEGACY_ALIASES, ULocale_AvailableType.WITH_LEGACY_ALIASES]
    }

    private static let _VALUES = ULocale_AvailableType._values()

    public static func values(): Array<ULocale_AvailableType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): ULocale_AvailableType {
        return (TypeInfo.of<ULocale_AvailableType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as ULocale_AvailableType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class ULocale_Category <: Enum<ULocale_Category> {
    public static let DISPLAY = ULocale_Category("DISPLAY", 0)

    public static let FORMAT = ULocale_Category("FORMAT", 1)

    private static func _values(): Array<ULocale_Category> {
        return [ULocale_Category.DISPLAY, ULocale_Category.FORMAT]
    }

    private static let _VALUES = ULocale_Category._values()

    public static func values(): Array<ULocale_Category> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): ULocale_Category {
        return (TypeInfo.of<ULocale_Category>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as ULocale_Category
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class ULocale_2 <: SoftCache<Locale, ULocale, Void> {
    init() {
        super()
    }

    override protected func createInstance(key: Locale, unused: Void): ULocale {
        return ULocale_JDKLocaleHelper.toULocale(key)
    }
}


class ULocale_AliasReplacer {
    private static let GeneratedStaticLockObject = Monitor()

    public init(language: String, script: String, region: String, variants: String, extensions: String) {
        if (!language.isSome()) {
            throw AssertionError()
        }
        if (!script.isSome()) {
            throw AssertionError()
        }
        if (!region.isSome()) {
            throw AssertionError()
        }
        if (!variants.isSome()) {
            throw AssertionError()
        }
        if (!extensions.isSome()) {
            throw AssertionError()
        }
        this.language = language
        this.script = script
        this.region = region
        if (!variants.isEmpty()) {
            this.variants = ArrayList<String>(variants.split("_"))
        }
        this.extensions = extensions
    }

    private var language: String

    private var script: String

    private var region: String

    private var variants: ArrayList<String>

    private var extensions: String

    public func replace(): String {
        var changed = false
        loadAliasData()
        var count = 0
        while (true) {
            if (match (0) { case _ => count++; count - 1 } > 10) {
                throw IllegalArgumentException("Have problem to resolve locale alias of " + (ULocale.lscvToID(language, script, region, (if (variants.isNone()) { Some("") } else { Utility.joinStrings("_", variants) }))) + (extensions))
            }
            if (replaceLanguage(true, true, true) || replaceLanguage(true, true, false) || replaceLanguage(true, false, true) || replaceLanguage(true, false, false) || replaceLanguage(false, false, true) || replaceRegion() || replaceScript() || replaceVariant()) {
                changed = true
                continue
            }
            break
        }
        if (extensions.isNone() && !changed) {
            return None
        }
        var result = ULocale.lscvToID(language, script, region, (if (variants.isNone()) { Some("") } else { Utility.joinStrings("_", variants) }))
        if (extensions.isSome()) {
            var keywordChanged = false
            var temp: ULocale = ULocale((result) + (extensions))
            let keywords = temp.getKeywords()
            while (keywords.isSome() && keywords.hasNext()) {
                let key = keywords.next()
                if (key == "rg" || key == "sd" || key == "t") {
                    let value = temp.getKeywordValue(key)
                    let replacement = if (key == "t") { replaceTransformedExtensions(value) } else { replaceSubdivision(value) }
                    if (replacement.isSome()) {
                        temp = temp.setKeywordValue(key, replacement)
                        keywordChanged = true
                    }
                }
            }
            if (keywordChanged) {
                extensions = temp.getName()[temp.getBaseName().size..]
                changed = true
            }
            result += extensions
        }
        if (changed) {
            return result
        }
        return None
    }

    private static var aliasDataIsLoaded = false

    private static var languageAliasMap: Map<String, String> = None

    private static var scriptAliasMap: Map<String, String> = None

    private static var territoryAliasMap: Map<String, ArrayList<String>> = None

    private static var variantAliasMap: Map<String, String> = None

    private static var subdivisionAliasMap: Map<String, String> = None

    private static func loadAliasData(): Unit {
        synchronized (GeneratedStaticLockObject) {
            if (aliasDataIsLoaded) {
                return
            }
            languageAliasMap = HashMap<String, String>()
            scriptAliasMap = HashMap<String, String>()
            territoryAliasMap = HashMap<String, ArrayList<String>>()
            variantAliasMap = HashMap<String, String>()
            subdivisionAliasMap = HashMap<String, String>()
            let metadata = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "metadata", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
            let metadataAlias = metadata.get("alias")
            let languageAlias = metadataAlias.get("language")
            let scriptAlias = metadataAlias.get("script")
            let territoryAlias = metadataAlias.get("territory")
            let variantAlias = metadataAlias.get("variant")
            let subdivisionAlias = metadataAlias.get("subdivision")
                    languageAliasMap.put(aliasFrom, aliasTo)
                    i++
                }
            } while (false)
                    scriptAliasMap.put(aliasFrom, aliasTo)
                    i++
                }
            } while (false)
                    territoryAliasMap.put(aliasFrom, ArrayList<String>(aliasTo.split(" ")))
                    i++
                }
            } while (false)
                    if (Int32(aliasTo.size) < 4 || Int32(aliasTo.size) > 8 || (Int32(aliasTo.size) == 4 && (Char(aliasTo[0]) < '0' || Char(aliasTo[0]) > '9'))) {
                        throw IllegalArgumentException("Incorrect variant [" + (aliasTo) + "] for the key [" + (aliasFrom) + "] in alias:variant.")
                    }
                    variantAliasMap.put(aliasFrom, aliasTo)
                    i++
                }
            } while (false)
                    if (Int32(aliasTo.size) == 2) {
                        aliasTo += "zzzz"
                    } else if (Int32(aliasTo.size) < 2 || Int32(aliasTo.size) > 8) {
                        throw IllegalArgumentException("Incorrect value [" + (aliasTo) + "] in alias:territory.")
                    }
                    subdivisionAliasMap.put(aliasFrom, aliasTo)
                    i++
                }
            } while (false)
            aliasDataIsLoaded = true
        }
    }

    private static func generateKey(language: String, region: String, variant: String): String {
        if (!(variant.isNone() || Int32(variant.size) >= 4)) {
            throw AssertionError()
        }
        let buf = StringBuilder()
        buf.append(language)
        if (region.isSome() && !region.isEmpty()) {
            buf.append(ULocale.UNDERSCORE)
            buf.append(region)
        }
        if (variant.isSome() && !variant.isEmpty()) {
            buf.append(ULocale.UNDERSCORE)
            buf.append(variant)
        }
        return buf.toString()
    }

    private static func deleteOrReplace(input: String, Type: String, replacement: String): String {
        return if (replacement.isSome() && !replacement.isEmpty()) { (if (input.isNone() || input.isEmpty()) { replacement } else { input }) } else { (if (Type.isNone() || Type.isEmpty()) { input } else { None } as String) }
    }

    private func replaceLanguage(checkLanguage: Bool, checkRegion: Bool, checkVariants: Bool): Bool {
        if ((checkRegion && (region.isNone() || region.isEmpty())) || (checkVariants && (variants.isNone()))) {
            return false
        }
        let variantSize = if (checkVariants) { Int32(variants.size) } else { 1 }
        let searchLanguage = if (checkLanguage) { language } else { Some(ULocale.UNDEFINED_LANGUAGE) }
        let searchRegion: String = if (checkRegion) { region } else { None }
        var searchVariant: String
        var variantIndex = 0
        while (variantIndex < variantSize) {
            if (checkVariants) {
                searchVariant = variants[Int64(variantIndex)]
            }
            if (searchVariant.isSome() && Int32(searchVariant.size) < 4) {
                searchVariant = None
            }
            let typeKey = generateKey(searchLanguage, searchRegion, searchVariant)
            let replacement = languageAliasMap.get(typeKey)
            if (replacement.isNone()) {
                continue
            }
            var replacedScript: String
            var replacedRegion: String
            var replacedVariant: String
            var replacedExtensions: String
            var replacedLanguage: String
            if (indexOfWrap(replacement.indexOf(UInt8(UInt32('_')))) < 0) {
                replacedLanguage = if (replacement.equals(ULocale.UNDEFINED_LANGUAGE)) { language } else { replacement }
            } else {
                let replacementFields = replacement.split("_")
                replacedLanguage = replacementFields[0]
                var index = 1
                if (replacedLanguage.equals(ULocale.UNDEFINED_LANGUAGE)) {
                    replacedLanguage = language
                }
                var consumed = Int32(replacementFields[0].size) + 1
                while (Int32(replacementFields.size) > index) {
                    let field = replacementFields[Int64(index)]
                    let len = Int32(field.size)
                    if (1 == len) {
                        replacedExtensions = replacement[Int64(consumed)..]
                        break
                    } else if (len >= 2 && len <= 3) {
                        if (!replacedRegion.isNone()) {
                            throw AssertionError()
                        }
                        replacedRegion = field
                    } else if (len >= 5 && len <= 8) {
                        if (!replacedVariant.isNone()) {
                            throw AssertionError()
                        }
                        replacedVariant = field
                    } else if (len == 4) {
                        if (Char(field[0]) >= '0' && Char(field[0]) <= '9') {
                            if (!replacedVariant.isNone()) {
                                throw AssertionError()
                            }
                            replacedVariant = field
                        } else {
                            if (!replacedScript.isNone()) {
                                throw AssertionError()
                            }
                            replacedScript = field
                        }
                    }
                    index++
                    consumed += len + 1
                }
            }
            replacedScript = deleteOrReplace(script, None, replacedScript)
            replacedRegion = deleteOrReplace(region, searchRegion, replacedRegion)
            replacedVariant = deleteOrReplace(searchVariant, searchVariant, replacedVariant)
            if (this.language.equals(replacedLanguage) && this.script.equals(replacedScript) && this.region.equals(replacedRegion) && Objects.equals(searchVariant, replacedVariant) && replacedExtensions.isNone()) {
                continue
            }
            this.language = replacedLanguage
            this.script = replacedScript
            this.region = replacedRegion
            if (searchVariant.isSome() && !searchVariant.isEmpty()) {
                if (replacedVariant.isSome() && !replacedVariant.isEmpty()) {
                    this.variants.set(Int64(variantIndex), replacedVariant)
                } else {
                    this.variants.remove(Int64(variantIndex))
                    if (this.variants.isEmpty()) {
                        this.variants = None
                    }
                }
            }
            if (replacedExtensions.isSome() && !replacedExtensions.isEmpty()) { }
            return true
            variantIndex++
        }
        return false
    }

    private func replaceRegion(): Bool {
        if (region.isNone() || region.isEmpty()) {
            return false
        }
        let replacement = territoryAliasMap.get(region)
        if (replacement.isNone()) {
            return false
        }
        let replacedRegion: String
        if (Int32(replacement.size) > 1) {
            let regionOfLanguageAndScript = ULocale.addLikelySubtags(ULocale(this.language, this.script, None)).getCountry()
            replacedRegion = if (replacement.contains(regionOfLanguageAndScript)) { regionOfLanguageAndScript } else { replacement[0] }
        } else {
            replacedRegion = replacement[0]
        }
        if (!(!this.region.equals(replacedRegion))) {
            throw AssertionError()
        }
        this.region = replacedRegion
        return true
    }

    private func replaceScript(): Bool {
        if (script.isNone() || script.isEmpty()) {
            return false
        }
        let replacement = scriptAliasMap.get(script)
        if (replacement.isNone()) {
            return false
        }
        if (!(!this.script.equals(replacement))) {
            throw AssertionError()
        }
        this.script = replacement
        return true
    }

    private func replaceVariant(): Bool {
        if (variants.isNone()) {
            return false
        }
        var i = 0
        while (i < Int32(variants.size)) {
            let variant = variants[Int64(i)]
            let replacement = variantAliasMap.get(variant)
            if (replacement.isNone()) {
                continue
            }
            if (!(Int32(replacement.size) >= 4)) {
                throw AssertionError()
            }
            if (!(Int32(replacement.size) <= 8)) {
                throw AssertionError()
            }
            if (!(Int32(replacement.size) != 4 || (Char(replacement[0]) >= '0' && Char(replacement[0]) <= '9'))) {
                throw AssertionError()
            }
            if (!variant.equals(replacement)) {
                variants.set(Int64(i), replacement)
                if (variant == "heploc") {
                    variants.removeObject("hepburn")
                    if (variants.isEmpty()) {
                        variants = None
                    }
                }
                return true
            }
            i++
        }
        return false
    }

    private func replaceSubdivision(subdivision: String): String {
        return subdivisionAliasMap.get(subdivision)
    }

    private func replaceTransformedExtensions(extensions: String): String {
        let builder = StringBuilder()
        let subtags = ArrayList<String>(extensions.split(LanguageTag.SEP))
        let tfields = ArrayList<String>()
        var processedLength = 0
        var tlangLength = 0
        var tkey: String = ""
        for (subtag in subtags) {
            if (LanguageTag.isTKey(subtag)) {
                if (tlangLength == 0) {
                    tlangLength = processedLength - 1
                }
                if (Int32(builder.size) > 0) {
                    tfields.append(builder.toString())
                    builder.setLength(0)
                }
                tkey = subtag
                builder.append(subtag)
            } else {
                if (tlangLength != 0) {
                    builder.append(LanguageTag.SEP).append(ULocale.toUnicodeLocaleType(tkey, subtag))
                }
            }
            processedLength += Int32(subtag.size) + 1
        }
        if (Int32(builder.size) > 0) {
            tfields.append(builder.toString())
            builder.setLength(0)
        }
        let tlang = if (tlangLength > 0) { Some(extensions[0..Int64(tlangLength)]) } else { (if (Int32(tfields.size) == 0) { extensions } else { Some("") }) }
        if (Int32(tlang.size) > 0) {
            let canonicalized = ULocale.createCanonical(ULocale.forLanguageTag(extensions)).toLanguageTag()
            builder.append(AsciiUtil.toLowerString(canonicalized))
        }
        if (Int32(tfields.size) > 0) {
            if (Int32(builder.size) > 0) {
                builder.append(LanguageTag.SEP)
            }
            Collections.sort(tfields)
            builder.append(Utility.joinStrings(LanguageTag.SEP, tfields))
        }
        return builder.toString()
    }
}


public class ULocale_Type {
}



public class ULocale_Minimize <: Enum<ULocale_Minimize> {
    
    public static let FAVOR_SCRIPT = ULocale_Minimize("FAVOR_SCRIPT", 0)

    
    public static let FAVOR_REGION = ULocale_Minimize("FAVOR_REGION", 1)

    private static func _values(): Array<ULocale_Minimize> {
        return [ULocale_Minimize.FAVOR_SCRIPT, ULocale_Minimize.FAVOR_REGION]
    }

    private static let _VALUES = ULocale_Minimize._values()

    public static func values(): Array<ULocale_Minimize> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): ULocale_Minimize {
        return (TypeInfo.of<ULocale_Minimize>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as ULocale_Minimize
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class ULocale_Builder {
    private let _locbld: InternalLocaleBuilder

    public init() {
        _locbld = InternalLocaleBuilder()
    }

    public func setLocale(locale: ULocale): ULocale_Builder {
        try {
            _locbld.setLocale(locale.base(), locale.extensionsMethod())
        } catch (e: LocaleSyntaxException) {
            throw IllformedLocaleException(e.message, e.getErrorIndex())
        }
        return this
    }

    public func setLanguageTag(languageTag: String): ULocale_Builder {
        let sts = ParseStatus()
        let tag = LanguageTag.parse(languageTag, sts)
        if (sts.isError()) {
            throw IllformedLocaleException(sts.getErrorMessage(), sts.getErrorIndex())
        }
        _locbld.setLanguageTag(tag)
        return this
    }

    public func setLanguage(language: String): ULocale_Builder {
        try {
            _locbld.setLanguage(language)
        } catch (e: LocaleSyntaxException) {
            throw IllformedLocaleException(e.message, e.getErrorIndex())
        }
        return this
    }

    public func setScript(script: String): ULocale_Builder {
        try {
            _locbld.setScript(script)
        } catch (e: LocaleSyntaxException) {
            throw IllformedLocaleException(e.message, e.getErrorIndex())
        }
        return this
    }

    public func setRegion(region: String): ULocale_Builder {
        try {
            _locbld.setRegion(region)
        } catch (e: LocaleSyntaxException) {
            throw IllformedLocaleException(e.message, e.getErrorIndex())
        }
        return this
    }

    public func setVariant(variant: String): ULocale_Builder {
        try {
            _locbld.setVariant(variant)
        } catch (e: LocaleSyntaxException) {
            throw IllformedLocaleException(e.message, e.getErrorIndex())
        }
        return this
    }

    public func setExtension(key: Char, value: String): ULocale_Builder {
        try {
            _locbld.setExtension(key, value)
        } catch (e: LocaleSyntaxException) {
            throw IllformedLocaleException(e.message, e.getErrorIndex())
        }
        return this
    }

    public func setUnicodeLocaleKeyword(key: String, Type: String): ULocale_Builder {
        try {
            _locbld.setUnicodeLocaleKeyword(key, Type)
        } catch (e: LocaleSyntaxException) {
            throw IllformedLocaleException(e.message, e.getErrorIndex())
        }
        return this
    }

    public func addUnicodeLocaleAttribute(attribute: String): ULocale_Builder {
        try {
            _locbld.addUnicodeLocaleAttribute(attribute)
        } catch (e: LocaleSyntaxException) {
            throw IllformedLocaleException(e.message, e.getErrorIndex())
        }
        return this
    }

    public func removeUnicodeLocaleAttribute(attribute: String): ULocale_Builder {
        try {
            _locbld.removeUnicodeLocaleAttribute(attribute)
        } catch (e: LocaleSyntaxException) {
            throw IllformedLocaleException(e.message, e.getErrorIndex())
        }
        return this
    }

    public func clear(): ULocale_Builder {
        _locbld.clear()
        return this
    }

    public func clearExtensions(): ULocale_Builder {
        _locbld.clearExtensions()
        return this
    }

    public func build(): ULocale {
        return ULocale.getInstance(_locbld.getBaseLocale(), _locbld.getLocaleExtensions())
    }
}


class ULocale_JDKLocaleHelper {
    private static var hasLocaleCategories = false

    private static var mGetDefault: Method = None

    private static var mSetDefault: Method = None

    private static var eDISPLAY: Object

    private static var eFORMAT: Object



    public static func hasLocaleCategoriesStatic(): Bool {
        return hasLocaleCategories
    }

    public static func toULocale(loc: Locale): ULocale {
        var language = loc.getLanguage()
        var script: String = ""
        let coun@AssertThrows[IllegalArgumentException](= loc.getCountry()
        var variant = loc.getVariant()
        var attributes: Set<String>
        var keywords: Map<String, String> = None
        script = loc.getScript()
        let extKeys = loc.getExtensionKeys()
        if (!extKeys.isEmpty()) {
            for (extKey in extKeys) {
                if (extKey.charValue() == 'u') {
                    let uAttributes = loc.getUnicodeLocaleAttributes()
                    if (!uAttributes.isEmpty()) {
                        attributes = TreeSet() as Set<String>
                        for (attr in uAttributes) {
                            attributes.put(attr)
                        }
                    }
                    let uKeys = loc.getUnicodeLocaleKeys()
                    for (kwKey in uKeys) {
                        let kwVal = loc.getUnicodeLocaleType(kwKey)
                        if (kwVal.isSome()) {
                            if (kwKey == "va") {
                                variant = if (Int32(variant.size) == 0) { kwVal } else { (kwVal) + "_" + (variant) }
                            } else {
                                if (keywords.isNone()) {
                                    keywords = TreeMap() as Map<String, String>
                                }
                                keywords.put(kwKey, kwVal)
                            }
                        }
                    }
                } else {
                    let extVal = loc.getExtension(extKey.charValue())
                    if (extVal.isSome()) {
                        if (keywords.isNone()) {
                            keywords = TreeMap() as Map<String, String>
                        }
                        keywords.put(String.valueOf(extKey), extVal)
                    }
                }
            }
        }
        if (language == "no" && country == "NO" && variant == "NY") {
            language = "nn"
            variant = ""
        }
        let buf = StringBuilder(language)
        if (Int32(script.size) > 0) {
            buf.append('_')
            buf.append(script)
        }
        if (Int32(country.size) > 0) {
            buf.append('_')
            buf.append(country)
        }
        if (Int32(variant.size) > 0) {
            if (Int32(country.size) == 0) {
                buf.append('_')
            }
            buf.append('_')
            buf.append(variant)
        }
        if (attributes.isSome()) {
            let attrBuf = StringBuilder()
            for (attr in attributes) {
                if (Int32(attrBuf.size) != 0) {
                    attrBuf.append('-')
                }
                attrBuf.append(attr)
            }
            if (keywords.isNone()) {
                keywords = TreeMap() as Map<String, String>
            }
            keywords.put(ULocale.LOCALE_ATTRIBUTE_KEY, attrBuf.toString())
        }
        if (keywords.isSome()) {
            buf.append('@')
            var addSep = false
            for (kwEntry in keywords.entrySet()) {
                var kwKey = kwEntry.getKey()
                var kwVal = kwEntry.getValue()
                if (Int32(kwKey.size) != 1) {
                    kwKey = ULocale.toLegacyKey(kwKey)
                    kwVal = ULocale.toLegacyType(kwKey, (if (Int32(kwVal.size) == 0) { Some("yes") } else { kwVal }))
                }
                if (addSep) {
                    buf.append(';')
                } else {
                    addSep = true
                }
                buf.append(kwKey)
                buf.append('=')
                buf.append(kwVal)
            }
        }
        return ULocale(ULocale.getNameStatic(buf.toString()), loc)
    }

    public static func toLocale(uloc: ULocale): Locale {
        var loc: Locale = None
        let ulocStr = uloc.getName()
        if (Int32(uloc.getScript().size) > 0 || ulocStr.contains("@")) {
            var tag = uloc.toLanguageTag()
            tag = AsciiUtil.toUpperString(tag)
            loc = Locale.forLanguageTag(tag)
        }
        if (loc.isNone()) {
            loc = Locale(uloc.getLanguage(), uloc.getCountry(), uloc.getVariant())
        }
        return loc
    }

    public static func getDefault(category: ULocale_Category): Locale {
        if (hasLocaleCategories) {
            var cat: Object
            match (category) {
                case ULocale_Category.DISPLAY => cat = eDISPLAY
                case ULocale_Category.FORMAT => cat = eFORMAT
                case _ => ()
            }
            if (cat.isSome()) {
                try {
                    return mGetDefault.invoke(None, [cat])
                } catch (e: InvocationTargetException) { }) catch (e: IllegalAccessException) { }
            }
        }
        return Locale.getDefault()
    }

    public static func setDefault(category: ULocale_Category, newLocale: Locale): Unit {
        if (hasLocaleCategories) {
            var cat: Object
            match (category) {
                case ULocale_Category.DISPLAY => cat = eDISPLAY
                case ULocale_Category.FORMAT => cat = eFORMAT
                case _ => ()
            }
            if (cat.isSome()) {
                @AssertThrows[IllegalArgumentException]({
                    mSetDefault.invoke(None, [cat, newLocale])
                } catch (e: InvocationTargetException) { }) catch (e: IllegalAccessException) { }
            }
        }
    }
}
