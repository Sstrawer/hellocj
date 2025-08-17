package icu4cj.impl


public class LocaleDisplayNamesImpl <: LocaleDisplayNames & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private let locale: ULocale

    private let dialectHandling: LocaleDisplayNames_DialectHandling

    let capitalization: DisplayContext

    private let nameLength: DisplayContext

    private let substituteHandling: DisplayContext

    private let langData: LocaleDisplayNamesImpl_DataTable

    private let regionData: LocaleDisplayNamesImpl_DataTable

    private let separatorFormat: String

    private let format: String

    private let keyTypeFormat: String

    private let formatOpenParen: Char

    private let formatReplaceOpenParen: Char

    private let formatCloseParen: Char

    private let formatReplaceCloseParen: Char

    private let currencyDisplayInfo: CurrencyData_CurrencyDisplayInfo

    private static let cache = LocaleDisplayNamesImpl_Cache()

    var capitalizationUsage: Array<Bool>

    static let contextUsageTypeMap: Map<String, LocaleDisplayNamesImpl_CapitalizationContextUsage>


     private var capitalizationBrkIter: BreakIterator

    private static let TO_TITLE_WHOLE_STRING_NO_LOWERCASE = CaseMap.toTitle().wholeString().noLowercase()

    private static func toTitleWholeStringNoLowercase(locale: ULocale, s: String): String {
        return TO_TITLE_WHOLE_STRING_NO_LOWERCASE.apply(locale.toLocale(), None, s)
    }

    public static func getInstance(locale: ULocale, dialectHandling: LocaleDisplayNames_DialectHandling): LocaleDisplayNames {
        synchronized (getMonitorByObject(cache)) {
            return cache.get(locale, dialectHandling)
        }
    }

    public static func getInstance(locale: ULocale, contexts: Array<DisplayContext>): LocaleDisplayNames {
        synchronized (getMonitorByObject(cache)) {
            return cache.get(locale, contexts)
        }
    }

    public init(locale: ULocale, dialectHandling: LocaleDisplayNames_DialectHandling) {
        this(locale, [if (refEq(dialectHandling, LocaleDisplayNames_DialectHandling.STANDARD_NAMES)) { DisplayContext.STANDARD_NAMES } else { DisplayContext.DIALECT_NAMES }, DisplayContext.CAPITALIZATION_NONE])
    }

    public init(locale: ULocale, contexts: Array<DisplayContext>) {
        super()
        var dialectHandling: LocaleDisplayNames_DialectHandling = LocaleDisplayNames_DialectHandling.STANDARD_NAMES
        var capitalization: DisplayContext = DisplayContext.CAPITALIZATION_NONE
        var nameLength: DisplayContext = DisplayContext.LENGTH_FULL
        var substituteHandling: DisplayContext = DisplayContext.SUBSTITUTE
        for (contextItem in contexts) {
            match (contextItem.typeMethod()) {
                case DisplayContext_Type.DIALECT_HANDLING => dialectHandling = if (contextItem.valueMethod() == DisplayContext.STANDARD_NAMES.valueMethod()) { LocaleDisplayNames_DialectHandling.STANDARD_NAMES } else { LocaleDisplayNames_DialectHandling.DIALECT_NAMES }
                case DisplayContext_Type.CAPITALIZATION => capitalization = contextItem
                case DisplayContext_Type.DISPLAY_LENGTH => nameLength = contextItem
                case DisplayContext_Type.SUBSTITUTE_HANDLING => substituteHandling = contextItem
                case _ => ()
            }
        }
        this.dialectHandling = dialectHandling
        this.capitalization = capitalization
        this.nameLength = nameLength
        this.substituteHandling = substituteHandling
        this.langData = LocaleDisplayNamesImpl_LangDataTables.impl.get(locale, refEq(substituteHandling, DisplayContext.NO_SUBSTITUTE))
        this.regionData = LocaleDisplayNamesImpl_RegionDataTables.impl.get(locale, refEq(substituteHandling, DisplayContext.NO_SUBSTITUTE))
        this.locale = if (ULocale.ROOT.equals(langData.getLocale())) { regionData.getLocale() } else { langData.getLocale() }
        var sep = langData.get("localeDisplayPattern", "separator")
        if (sep.isNone() || "separator".equals(sep)) {
            sep = "{0}, {1}"
        }
        let sb = StringBuilder()
        this.separatorFormat = SimpleFormatterImpl.compileToStringMinMaxArguments(sep, sb, 2, 2)
        var pattern = langData.get("localeDisplayPattern", "pattern")
        if (pattern.isNone() || "pattern".equals(pattern)) {
            pattern = "{0} ({1})"
        }
        this.format = SimpleFormatterImpl.compileToStringMinMaxArguments(pattern, sb, 2, 2)
        if (pattern.contains("\u{ff08}")) {
            formatOpenParen = '\u{ff08}'
            formatCloseParen = '\u{ff09}'
            formatReplaceOpenParen = '\u{ff3b}'
            formatReplaceCloseParen = '\u{ff3d}'
        } else {
            formatOpenParen = '('
            formatCloseParen = ')'
            formatReplaceOpenParen = '['
            formatReplaceCloseParen = ']'
        }
        var keyTypePattern = langData.get("localeDisplayPattern", "keyTypePattern")
        if (keyTypePattern.isNone() || "keyTypePattern".equals(keyTypePattern)) {
            keyTypePattern = "{0}={1}"
        }
        this.keyTypeFormat = SimpleFormatterImpl.compileToStringMinMaxArguments(keyTypePattern, sb, 2, 2)
        var needBrkIter = false
        if (refEq(capitalization, DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU) || refEq(capitalization, DisplayContext.CAPITALIZATION_FOR_STANDALONE)) {
            capitalizationUsage = Array<Bool>(LocaleDisplayNamesImpl_CapitalizationContextUsage.values().size) { _ => false }
            let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, locale)
            let sink = LocaleDisplayNamesImpl_CapitalizationContextSink(this)
            try {
                rb.getAllItemsWithFallback("contextTransforms", sink)
            } catch (e: MissingResourceException) { }
            needBrkIter = sink.hasCapitalizationUsage
        }
        if (needBrkIter || refEq(capitalization, DisplayContext.CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE)) {
            capitalizationBrkIter = BreakIterator.getSentenceInstance(locale)
        }
        this.currencyDisplayInfo = CurrencyData.provider.getInstance(locale, false)
    }

    public override func getLocale(): ULocale {
        return locale
    }

    public override func getDialectHandling(): LocaleDisplayNames_DialectHandling {
        return dialectHandling
    }

    public override func getContext(Type: DisplayContext_Type): DisplayContext {
        let result: DisplayContext
        match (Type) {
            case DisplayContext_Type.DIALECT_HANDLING => result = if (refEq(dialectHandling, LocaleDisplayNames_DialectHandling.STANDARD_NAMES)) { DisplayContext.STANDARD_NAMES } else { DisplayContext.DIALECT_NAMES }
            case DisplayContext_Type.CAPITALIZATION => result = capitalization
            case DisplayContext_Type.DISPLAY_LENGTH => result = nameLength
            case DisplayContext_Type.SUBSTITUTE_HANDLING => result = substituteHandling
            case _ => result = DisplayContext.STANDARD_NAMES
        }
        return result
    }

    private func adjustForUsageAndContext(usage: LocaleDisplayNamesImpl_CapitalizationContextUsage, name: String): String {
        if (name.isSome() && Int32(name.size) > 0 && UCharacter.isLowerCase(name.codePointAt(0)) && (refEq(capitalization, DisplayContext.CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE) || (capitalizationUsage.isSome() && capitalizationUsage[Int64(usage.ordinal)]))) {
            synchronized (getMonitorByObject(this)) {
                if (capitalizationBrkIter.isNone()) {
                    capitalizationBrkIter = BreakIterator.getSentenceInstance(locale)
                }
                return UCharacter.toTitleCase(locale, name, capitalizationBrkIter, UCharacter.TITLECASE_NO_LOWERCASE | UCharacter.TITLECASE_NO_BREAK_ADJUSTMENT)
            }
        }
        return name
    }

    public override func localeDisplayName(locale: ULocale): String {
        return localeDisplayNameInternal(locale)
    }

    public override func localeDisplayName(locale: Locale): String {
        return localeDisplayNameInternal(ULocale.forLocale(locale))
    }

    public override func localeDisplayName(localeId: String): String {
        return localeDisplayNameInternal(ULocale(localeId))
    }

    private func localeDisplayNameInternal(locale: ULocale): String {
        var resultName: String
        var lang = locale.getLanguage()
        if (lang.isEmpty()) {
            lang = "und"
        }
        let script = locale.getScript()
        let country = locale.getCountry()
        let variant = locale.getVariant()
        var hasScript = Int32(script.size) > 0
        var hasCountry = Int32(country.size) > 0
        let hasVariant = Int32(variant.size) > 0
        if (refEq(dialectHandling, LocaleDisplayNames_DialectHandling.DIALECT_NAMES)) {
                }
                if (hasScript) {
                    let langScript: String = (lang) + '_'.toString() + (script)
                    let result = localeIdName(langScript)
                    if (result.isSome() && !result.equals(langScript)) {
                        resultName = result
                        hasScript = false
                        break
                    }
                }
                if (hasCountry) {
                    let langCountry: String = (lang) + '_'.toString() + (country)
                    let result = localeIdName(langCountry)
                    if (result.isSome() && !result.equals(langCountry)) {
                        resultName = result
                        hasCountry = false
                        break
                    }
                }
            } while (false)
        }
        if (resultName.isNone()) {
            let result = localeIdName(lang)
            if (result.isNone()) {
                return None
            }
            resultName = result.replace(formatOpenParen.toString(), formatReplaceOpenParen.toString()).replace(formatCloseParen.toString(), formatReplaceCloseParen.toString())
        }
        let buf = StringBuilder()
        if (hasScript) {
            let result = scriptDisplayNameInContext(script, true)
            if (result.isNone()) {
                return None
            }
            buf.append(result.replace(formatOpenParen.toString(), formatReplaceOpenParen.toString()).replace(formatCloseParen.toString(), formatReplaceCloseParen.toString()))
        }
        if (hasCountry) {
            let result = regionDisplayName(country, true)
            if (result.isNone()) {
                return None
            }
            appendWithSep(result.replace(formatOpenParen.toString(), formatReplaceOpenParen.toString()).replace(formatCloseParen.toString(), formatReplaceCloseParen.toString()), buf)
        }
        if (hasVariant) {
            let result = variantDisplayName(variant, true)
            if (result.isNone()) {
                return None
            }
            appendWithSep(result.replace(formatOpenParen.toString(), formatReplaceOpenParen.toString()).replace(formatCloseParen.toString(), formatReplaceCloseParen.toString()), buf)
        }
        let keys = locale.getKeywords()
        if (keys.isSome()) {
            while (keys.hasNext()) {
                let key = keys.next()
                let value = locale.getKeywordValue(key)
                var keyDisplayName = keyDisplayName(key, true)
                if (keyDisplayName.isNone()) {
                    return None
                }
                keyDisplayName = keyDisplayName.replace(formatOpenParen.toString(), formatReplaceOpenParen.toString()).replace(formatCloseParen.toString(), formatReplaceCloseParen.toString())
                var valueDisplayName = keyValueDisplayName(key, value, true)
                if (valueDisplayName.isNone()) {
                    return None
                }
                valueDisplayName = valueDisplayName.replace(formatOpenParen.toString(), formatReplaceOpenParen.toString()).replace(formatCloseParen.toString(), formatReplaceCloseParen.toString())
                if (!valueDisplayName.equals(value)) {
                    appendWithSep(valueDisplayName, buf)
                } else if (!key.equals(keyDisplayName)) {
                    let keyValue = SimpleFormatterImpl.formatCompiledPattern(keyTypeFormat, [keyDisplayName, valueDisplayName])
                    appendWithSep(keyValue, buf)
                } else {
                    appendWithSep(keyDisplayName, buf).append("=").append(valueDisplayName)
                }
            }
        }
        var resultRemainder: String
        if (Int32(buf.size) > 0) {
            resultRemainder = buf.toString()
        }
        if (resultRemainder.isSome()) {
            resultName = SimpleFormatterImpl.formatCompiledPattern(format, [resultName, resultRemainder])
        }
        return adjustForUsageAndContext(LocaleDisplayNamesImpl_CapitalizationContextUsage.LANGUAGE, resultName)
    }

    private func localeIdName(localeId: String): String {
        var locIdName: String
        if (refEq(nameLength, DisplayContext.LENGTH_SHORT)) {
            locIdName = langData.get("Languages%short", localeId)
            if (locIdName.isSome() && !locIdName.equals(localeId)) {
                return locIdName
            }
        }
        locIdName = langData.get("Languages", localeId)
        if ((locIdName.isNone() || locIdName.equals(localeId)) && indexOfWrap(localeId.indexOf(UInt8(UInt32('_')))) < 0) {
            let canonLocale = ULocale.createCanonical(localeId)
            let canonLocId = canonLocale.getName()
            if (refEq(nameLength, DisplayContext.LENGTH_SHORT)) {
                locIdName = langData.get("Languages%short", canonLocId)
                if (locIdName.isSome() && !locIdName.equals(canonLocId)) {
                    return locIdName
                }
            }
            locIdName = langData.get("Languages", canonLocId)
        }
        return locIdName
    }

    public override func languageDisplayName(lang: String): String {
        if (lang == "root" || indexOfWrap(lang.indexOf(UInt8(UInt32('_')))) != -1) {
            return if (refEq(substituteHandling, DisplayContext.SUBSTITUTE)) { lang } else { None }
        }
        var langName: String
        if (refEq(nameLength, DisplayContext.LENGTH_SHORT)) {
            langName = langData.get("Languages%short", lang)
            if (langName.isSome() && !langName.equals(lang)) {
                return adjustForUsageAndContext(LocaleDisplayNamesImpl_CapitalizationContextUsage.LANGUAGE, langName)
            }
        }
        langName = langData.get("Languages", lang)
        if (langName.isNone() || langName.equals(lang)) {
            let canonLocale = ULocale.createCanonical(lang)
            let canonLocId = canonLocale.getName()
            if (refEq(nameLength, DisplayContext.LENGTH_SHORT)) {
                langName = langData.get("Languages%short", canonLocId)
                if (langName.isSome() && !langName.equals(canonLocId)) {
                    return adjustForUsageAndContext(LocaleDisplayNamesImpl_CapitalizationContextUsage.LANGUAGE, langName)
                }
            }
            langName = langData.get("Languages", canonLocId)
        }
        return adjustForUsageAndContext(LocaleDisplayNamesImpl_CapitalizationContextUsage.LANGUAGE, langName)
    }

    public override func scriptDisplayName(script: String): String {
        var str = langData.get("Scripts%stand-alone", script)
        if (str.isNone() || str.equals(script)) {
            if (refEq(nameLength, DisplayContext.LENGTH_SHORT)) {
                str = langData.get("Scripts%short", script)
                if (str.isSome() && !str.equals(script)) {
                    return adjustForUsageAndContext(LocaleDisplayNamesImpl_CapitalizationContextUsage.SCRIPT, str)
                }
            }
            str = langData.get("Scripts", script)
        }
        return adjustForUsageAndContext(LocaleDisplayNamesImpl_CapitalizationContextUsage.SCRIPT, str)
    }

    private func scriptDisplayNameInContext(script: String, skipAdjust: Bool): String {
        if (refEq(nameLength, DisplayContext.LENGTH_SHORT)) {
            let scriptName = langData.get("Scripts%short", script)
            if (scriptName.isSome() && !scriptName.equals(script)) {
                return if (skipAdjust) { scriptName } else { adjustForUsageAndContext(LocaleDisplayNamesImpl_CapitalizationContextUsage.SCRIPT, scriptName) }
            }
        }
        let scriptName = langData.get("Scripts", script)
        return if (skipAdjust) { scriptName } else { adjustForUsageAndContext(LocaleDisplayNamesImpl_CapitalizationContextUsage.SCRIPT, scriptName) }
    }

    public override func scriptDisplayNameInContext(script: String): String {
        return scriptDisplayNameInContext(script, false)
    }

    public override func scriptDisplayName(scriptCode: Int32): String {
        return scriptDisplayName(UScript.getShortName(scriptCode))
    }

    private func regionDisplayName(region: String, skipAdjust: Bool): String {
        if (refEq(nameLength, DisplayContext.LENGTH_SHORT)) {
            let regionName = regionData.get("Countries%short", region)
            if (regionName.isSome() && !regionName.equals(region)) {
                return if (skipAdjust) { regionName } else { adjustForUsageAndContext(LocaleDisplayNamesImpl_CapitalizationContextUsage.TERRITORY, regionName) }
            }
        }
        let regionName = regionData.get("Countries", region)
        return if (skipAdjust) { regionName } else { adjustForUsageAndContext(LocaleDisplayNamesImpl_CapitalizationContextUsage.TERRITORY, regionName) }
    }

    public override func regionDisplayName(region: String): String {
        return regionDisplayName(region, false)
    }

    private func variantDisplayName(variant: String, skipAdjust: Bool): String {
        let variantName = langData.get("Variants", variant)
        return if (skipAdjust) { variantName } else { adjustForUsageAndContext(LocaleDisplayNamesImpl_CapitalizationContextUsage.VARIANT, variantName) }
    }

    public override func variantDisplayName(variant: String): String {
        return variantDisplayName(variant, false)
    }

    private func keyDisplayName(key: String, skipAdjust: Bool): String {
        let keyName = langData.get("Keys", key)
        return if (skipAdjust) { keyName } else { adjustForUsageAndContext(LocaleDisplayNamesImpl_CapitalizationContextUsage.KEY, keyName) }
    }

    public override func keyDisplayName(key: String): String {
        return keyDisplayName(key, false)
    }

    private func keyValueDisplayName(key: String, value: String, skipAdjust: Bool): String {
        var keyValueName: String
        if (key == "currency") {
            keyValueName = currencyDisplayInfo.getName(AsciiUtil.toUpperString(value))
            if (keyValueName.isNone()) {
                keyValueName = value
            }
        } else {
            if (refEq(nameLength, DisplayContext.LENGTH_SHORT)) {
                let tmp = langData.get("Types%short", key, value)
                if (tmp.isSome() && !tmp.equals(value)) {
                    keyValueName = tmp
                }
            }
            if (keyValueName.isNone()) {
                keyValueName = langData.get("Types", key, value)
            }
        }
        return if (skipAdjust) { keyValueName } else { adjustForUsageAndContext(LocaleDisplayNamesImpl_CapitalizationContextUsage.KEYVALUE, keyValueName) }
    }

    public override func keyValueDisplayName(key: String, value: String): String {
        return keyValueDisplayName(key, value, false)
    }

    public override func getUiListCompareWholeItems(localeSet: Set<ULocale>, comparator: Comparator): ArrayList<LocaleDisplayNames_UiListItem> {
        let capContext = getContext(DisplayContext_Type.CAPITALIZATION)
        let result = ArrayList<LocaleDisplayNames_UiListItem>()
        let baseToLocales: Map<ULocale, Set<ULocale>> = HashMap<ULocale, Set<ULocale>>()
        let builder = ULocale_Builder()
        for (locOriginal in localeSet) {
            builder.setLocale(locOriginal)
            let loc = ULocale.addLikelySubtags(locOriginal)
            let base = ULocale(loc.getLanguage())
            var locales = baseToLocales.get(base)
            if (locales.isNone()) {
                baseToLocales.put(base, match (0) { case _ => locales = HashSet<ULocale>(); locales })
            }
            locales.put(loc)
        }
        for (entry in baseToLocales.entrySet()) {
            let base = entry.getKey()
            let values = entry.getValue()
            if (Int32(values.size) == 1) {
                let locale = values.iterator().next()
                result.append(newRow(ULocale.minimizeSubtags(locale, ULocale_Minimize.FAVOR_SCRIPT), capContext))
            } else {
                let scripts: Set<String> = HashSet<String>()
                let regions: Set<String> = HashSet<String>()
                let maxBase = ULocale.addLikelySubtags(base)
                scripts.put(maxBase.getScript())
                regions.put(maxBase.getCountry())
                for (locale in values) {
                    scripts.put(locale.getScript())
                    regions.put(locale.getCountry())
                }
                let hasScripts = Int32(scripts.size) > 1
                let hasRegions = Int32(regions.size) > 1
                for (locale in values) {
                    let modified = builder.setLocale(locale)
                    if (!hasScripts) {
                        modified.setScript("")
                    }
                    if (!hasRegions) {
                        modified.setRegion("")
                    }
                    result.append(newRow(modified.build(), capContext))
                }
            }
        }
        Collections.sort(result, comparator)
        return result
    }

    private func newRow(modified: ULocale, capContext: DisplayContext): LocaleDisplayNames_UiListItem {
        let minimized = ULocale.minimizeSubtags(modified, ULocale_Minimize.FAVOR_SCRIPT)
        var tempName = modified.getDisplayName(locale)
        let titlecase = refEq(capContext, DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU)
        let nameInDisplayLocale = if (titlecase) { toTitleWholeStringNoLowercase(locale, tempName) } else { tempName }
        tempName = modified.getDisplayName(modified)
        let nameInSelf = if (refEq(capContext, DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU)) { toTitleWholeStringNoLowercase(modified, tempName) } else { tempName }
        return LocaleDisplayNames_UiListItem(minimized, modified, nameInDisplayLocale, nameInSelf)
    }

    public static func haveData(Type: LocaleDisplayNamesImpl_DataTableType): Bool {
        match (Type) {
            case LocaleDisplayNamesImpl_DataTableType.LANG => return checkOptionalIs<LocaleDisplayNamesImpl_ICUDataTables, LocaleDisplayNamesImpl_DataTables>(LocaleDisplayNamesImpl_LangDataTables.impl)
            case LocaleDisplayNamesImpl_DataTableType.REGION => return checkOptionalIs<LocaleDisplayNamesImpl_ICUDataTables, LocaleDisplayNamesImpl_DataTables>(LocaleDisplayNamesImpl_RegionDataTables.impl)
            case _ => throw IllegalArgumentException("unknown type: " + Type.asString())
        }
    }

    private func appendWithSep(s: String, b: StringBuilder): StringBuilder {
        if (Int32(b.size) == 0) {
            b.append(s)
        } else {
            SimpleFormatterImpl.formatAndReplace(separatorFormat, b, None, [b.asString(), s])
        }
        return b
    }
}


class LocaleDisplayNamesImpl_CapitalizationContextUsage <: Enum<LocaleDisplayNamesImpl_CapitalizationContextUsage> {
    public static let LANGUAGE = LocaleDisplayNamesImpl_CapitalizationContextUsage("LANGUAGE", 0)

    public static let SCRIPT = LocaleDisplayNamesImpl_CapitalizationContextUsage("SCRIPT", 1)

    public static let TERRITORY = LocaleDisplayNamesImpl_CapitalizationContextUsage("TERRITORY", 2)

    public static let VARIANT = LocaleDisplayNamesImpl_CapitalizationContextUsage("VARIANT", 3)

    public static let KEY = LocaleDisplayNamesImpl_CapitalizationContextUsage("KEY", 4)

    public static let KEYVALUE = LocaleDisplayNamesImpl_CapitalizationContextUsage("KEYVALUE", 5)

    private static func _values(): Array<LocaleDisplayNamesImpl_CapitalizationContextUsage> {
        return [LocaleDisplayNamesImpl_CapitalizationContextUsage.LANGUAGE, LocaleDisplayNamesImpl_CapitalizationContextUsage.SCRIPT, LocaleDisplayNamesImpl_CapitalizationContextUsage.TERRITORY, LocaleDisplayNamesImpl_CapitalizationContextUsage.VARIANT, LocaleDisplayNamesImpl_CapitalizationContextUsage.KEY, LocaleDisplayNamesImpl_CapitalizationContextUsage.KEYVALUE]
    }

    private static let _VALUES = LocaleDisplayNamesImpl_CapitalizationContextUsage._values()

    public static func values(): Array<LocaleDisplayNamesImpl_CapitalizationContextUsage> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): LocaleDisplayNamesImpl_CapitalizationContextUsage {
        return (TypeInfo.of<LocaleDisplayNamesImpl_CapitalizationContextUsage>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as LocaleDisplayNamesImpl_CapitalizationContextUsage
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class LocaleDisplayNamesImpl_CapitalizationContextSink <: UResource_Sink {
    let this_0: LocaleDisplayNamesImpl

    init(this_0: LocaleDisplayNamesImpl) {
        super()
        this.this_0 = this_0
    }

    var hasCapitalizationUsage = false

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let contextsTable = value.getTable()
        var i = 0
        while (contextsTable.getKeyAndValue(i, key, value)) {
            let usage = LocaleDisplayNamesImpl.contextUsageTypeMap.get(key.toString())
            if (usage.isNone()) {
                continue
            }
            let intVector = value.getIntVector()
            if (Int32(intVector.size) < 2) {
                continue
            }
            let titlecaseInt = if (refEq(this_0.capitalization, DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU)) { intVector[0] } else { intVector[1] }
            if (titlecaseInt == 0) {
                continue
            }
            this_0.capitalizationUsage[Int64(usage.ordinal)] = true
            hasCapitalizationUsage = true
            i++
        }
    }
}


public class LocaleDisplayNamesImpl_DataTable {
    let nullIfNotFound: Bool

    init(nullIfNotFound: Bool) {
        this.nullIfNotFound = nullIfNotFound
    }

    public func getLocale(): ULocale {
        return ULocale.ROOT
    }

    public func get(tableName: String, code: String): String {
        return get(tableName, None, code)
    }

    public func get(tableName: String, subTableName: String, code: String): String {
        return if (nullIfNotFound) { None } else { code }
    }
}


class LocaleDisplayNamesImpl_ICUDataTable <: LocaleDisplayNamesImpl_DataTable {
    private let bundle: ICUResourceBundle

    public init(path: String, locale: ULocale, nullIfNotFound: Bool) {
        super(nullIfNotFound)
        this.bundle = UResourceBundle.getBundleInstance(path, locale.getBaseName())
    }

    public override func getLocale(): ULocale {
        return bundle.getULocale()
    }

    public override func get(tableName: String, subTableName: String, code: String): String {
        return ICUResourceTableAccess.getTableString(bundle, tableName, subTableName, code, if (nullIfNotFound) { None } else { code })
    }
}


abstract class LocaleDisplayNamesImpl_DataTables {

    public func get(locale: ULocale, nullIfNotFound: Bool): LocaleDisplayNamesImpl_DataTable

    public static func load(className: String): LocaleDisplayNamesImpl_DataTables {
        try {
            return TypeInfo.get(className).construct([0]) as LocaleDisplayNamesImpl_DataTables
        } catch (t: Exception) {
            return LocaleDisplayNamesImpl_DataTables_1()
        }
    }
}


class LocaleDisplayNamesImpl_DataTables_1 <: LocaleDisplayNamesImpl_DataTables {
    init() {
        super()
    }

    public override func get(locale: ULocale, nullIfNotFound: Bool): LocaleDisplayNamesImpl_DataTable {
        return LocaleDisplayNamesImpl_DataTable(nullIfNotFound)
    }
}


abstract class LocaleDisplayNamesImpl_ICUDataTables <: LocaleDisplayNamesImpl_DataTables {
    private let path: String

    protected init(path: String) {
        super()
        this.path = path
    }

    public override func get(locale: ULocale, nullIfNotFound: Bool): LocaleDisplayNamesImpl_DataTable {
        return LocaleDisplayNamesImpl_ICUDataTable(path, locale, nullIfNotFound)
    }
}


class LocaleDisplayNamesImpl_LangDataTables {

    static let impl = LocaleDisplayNamesImpl_DataTables.load("com.ibm.icu.impl.ICULangDataTables")
}


class LocaleDisplayNamesImpl_RegionDataTables {

    static let impl = LocaleDisplayNamesImpl_DataTables.load("com.ibm.icu.impl.ICURegionDataTables")
}


public class LocaleDisplayNamesImpl_DataTableType <: Enum<LocaleDisplayNamesImpl_DataTableType> {
    public static let LANG = LocaleDisplayNamesImpl_DataTableType("LANG", 0)

    public static let REGION = LocaleDisplayNamesImpl_DataTableType("REGION", 1)

    private static func _values(): Array<LocaleDisplayNamesImpl_DataTableType> {
        return [LocaleDisplayNamesImpl_DataTableType.LANG, LocaleDisplayNamesImpl_DataTableType.REGION]
    }

    private static let _VALUES = LocaleDisplayNamesImpl_DataTableType._values()

    public static func values(): Array<LocaleDisplayNamesImpl_DataTableType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): LocaleDisplayNamesImpl_DataTableType {
        return (TypeInfo.of<LocaleDisplayNamesImpl_DataTableType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as LocaleDisplayNamesImpl_DataTableType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class LocaleDisplayNamesImpl_Cache {

    private var locale: ULocale

    private var dialectHandling: LocaleDisplayNames_DialectHandling

    private var capitalization: DisplayContext

    private var nameLength: DisplayContext

    private var substituteHandling: DisplayContext

    private var cache: LocaleDisplayNames

    public func get(locale: ULocale, dialectHandling: LocaleDisplayNames_DialectHandling): LocaleDisplayNames {
        if (!(refEq(dialectHandling, this.dialectHandling) && refEq(DisplayContext.CAPITALIZATION_NONE, this.capitalization) && refEq(DisplayContext.LENGTH_FULL, this.nameLength) && refEq(DisplayContext.SUBSTITUTE, this.substituteHandling) && locale.equals(this.locale))) {
            this.locale = locale
            this.dialectHandling = dialectHandling
            this.capitalization = DisplayContext.CAPITALIZATION_NONE
            this.nameLength = DisplayContext.LENGTH_FULL
            this.substituteHandling = DisplayContext.SUBSTITUTE
            this.cache = LocaleDisplayNamesImpl(locale, dialectHandling)
        }
        return cache
    }

    public func get(locale: ULocale, contexts: Array<DisplayContext>): LocaleDisplayNames {
        var dialectHandlingIn: LocaleDisplayNames_DialectHandling = LocaleDisplayNames_DialectHandling.STANDARD_NAMES
        var capitalizationIn: DisplayContext = DisplayContext.CAPITALIZATION_NONE
        var nameLengthIn: DisplayContext = DisplayContext.LENGTH_FULL
        var substituteHandling: DisplayContext = DisplayContext.SUBSTITUTE
        for (contextItem in contexts) {
            match (contextItem.typeMethod()) {
                case DisplayContext_Type.DIALECT_HANDLING => dialectHandlingIn = if (contextItem.valueMethod() == DisplayContext.STANDARD_NAMES.valueMethod()) { LocaleDisplayNames_DialectHandling.STANDARD_NAMES } else { LocaleDisplayNames_DialectHandling.DIALECT_NAMES }
                case DisplayContext_Type.CAPITALIZATION => capitalizationIn = contextItem
                case DisplayContext_Type.DISPLAY_LENGTH => nameLengthIn = contextItem
                case DisplayContext_Type.SUBSTITUTE_HANDLING => substituteHandling = contextItem
                case _ => ()
            }
        }
        if (!(refEq(dialectHandlingIn, this.dialectHandling) && refEq(capitalizationIn, this.capitalization) && refEq(nameLengthIn, this.nameLength) && refEq(substituteHandling, this.substituteHandling) && locale.equals(this.locale))) {
            this.locale = locale
            this.dialectHandling = dialectHandlingIn
            this.capitalization = capitalizationIn
            this.nameLength = nameLengthIn
            this.substituteHandling = substituteHandling
            this.cache = LocaleDisplayNamesImpl(locale, contexts)
        }
        return cache
    }
}
