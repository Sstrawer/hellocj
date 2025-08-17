package icu4cj.impl


public class ICUCurrencyDisplayInfoProvider <: CurrencyData_CurrencyDisplayInfoProvider {

     private var currencyDisplayInfoCache: ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo

    public override func getInstance(locale: ULocale, withFallback: Bool): CurrencyData_CurrencyDisplayInfo {
        var templocale = locale
        if (templocale.isNone()) {
            templocale = ULocale.ROOT
        }
        var instance = currencyDisplayInfoCache
        if (instance.isNone() || !instance.locale.equals(templocale) || instance.fallback != withFallback) {
            let rb: ICUResourceBundle
            if (withFallback) {
                rb = ICUResourceBundle.getBundleInstance(ICUData.ICU_CURR_BASE_NAME, templocale, ICUResourceBundle_OpenType.LOCALE_DEFAULT_ROOT)
            } else {
                try {
                    rb = ICUResourceBundle.getBundleInstance(ICUData.ICU_CURR_BASE_NAME, templocale, ICUResourceBundle_OpenType.LOCALE_ONLY)
                } catch (e: MissingResourceException) {
                    return None
                }
            }
            instance = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo(templocale, rb, withFallback)
            currencyDisplayInfoCache = instance
        }
        return instance
    }

    public override func hasData(): Bool {
        return true
    }
}


class ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo <: CurrencyData_CurrencyDisplayInfo {
    let locale: ULocale

    let fallback: Bool

    private let rb: ICUResourceBundle

     private var formattingDataCache: ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_FormattingData

     private var variantSymbolCache: ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_VariantSymbol

     private var pluralsDataCache: Array<String>

     private var parsingDataCache: SoftReference = SoftReference(None)

     private var unitPatternsCache: Map<String, String> = None

     private var spacingInfoCache: CurrencyData_CurrencySpacingInfo

    public init(locale: ULocale, rb: ICUResourceBundle, fallback: Bool) {
        super()
        this.locale = locale
        this.fallback = fallback
        this.rb = rb
    }

    public override func getULocale(): ULocale {
        return rb.getULocale()
    }

    public override func getName(isoCode: String): String {
        let formattingData = fetchFormattingData(isoCode)
        if (formattingData.displayName.isNone() && fallback) {
            return isoCode
        }
        return formattingData.displayName
    }

    public override func getSymbol(isoCode: String): String {
        let formattingData = fetchFormattingData(isoCode)
        if (formattingData.symbol.isNone() && fallback) {
            return isoCode
        }
        return formattingData.symbol
    }

    public override func getNarrowSymbol(isoCode: String): String {
        let variantSymbol = fetchVariantSymbol(isoCode, "narrow")
        if (variantSymbol.symbol.isNone() && fallback) {
            return getSymbol(isoCode)
        }
        return variantSymbol.symbol
    }

    public override func getFormalSymbol(isoCode: String): String {
        let variantSymbol = fetchVariantSymbol(isoCode, "formal")
        if (variantSymbol.symbol.isNone() && fallback) {
            return getSymbol(isoCode)
        }
        return variantSymbol.symbol
    }

    public override func getVariantSymbol(isoCode: String): String {
        let variantSymbol = fetchVariantSymbol(isoCode, "variant")
        if (variantSymbol.symbol.isNone() && fallback) {
            return getSymbol(isoCode)
        }
        return variantSymbol.symbol
    }

    public override func getPluralName(isoCode: String, pluralKey: String): String {
        let plural = StandardPlural.orNullFromString(pluralKey)
        let pluralsData = fetchPluralsData(isoCode)
        let pluralKeys: Set<String> = SetCollectionView<String>(fetchUnitPatterns().keys())
        var result: String
        if (plural.isSome()) {
            result = pluralsData[Int64(1 + plural.ordinal)]
        }
        if (result.isNone() && (fallback || pluralKeys.contains(pluralKey))) {
            result = pluralsData[Int64(1 + StandardPlural.OTHER.ordinal)]
        }
        if (result.isNone() && (fallback || pluralKeys.contains(pluralKey))) {
            let formattingData = fetchFormattingData(isoCode)
            result = formattingData.displayName
        }
        if (result.isNone() && fallback) {
            result = isoCode
        }
        return result
    }

    public override func symbolMap(): Map<String, String> {
        let parsingData = fetchParsingData()
        return parsingData.symbolToIsoCode
    }

    public override func nameMap(): Map<String, String> {
        let parsingData = fetchParsingData()
        return parsingData.nameToIsoCode
    }

    public override func getUnitPatterns(): Map<String, String> {
        let unitPatterns = fetchUnitPatterns()
        return unitPatterns
    }

    public override func getFormatInfo(isoCode: String): CurrencyData_CurrencyFormatInfo {
        let formattingData = fetchFormattingData(isoCode)
        return formattingData.formatInfo
    }

    public override func getSpacingInfo(): CurrencyData_CurrencySpacingInfo {
        let spacingInfo = fetchSpacingInfo()
        if ((!spacingInfo.hasBeforeCurrency || !spacingInfo.hasAfterCurrency) && fallback) {
            return CurrencyData_CurrencySpacingInfo.DEFAULT
        }
        return spacingInfo
    }

    public func fetchFormattingData(isoCode: String): ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_FormattingData {
        var result = formattingDataCache
        if (result.isNone() || !result.isoCode.equals(isoCode)) {
            result = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_FormattingData(isoCode)
            let sink = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink(!fallback, ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCIES)
            sink.formattingData = result
            rb.getAllItemsWithFallbackNoFail("Currencies/" + (isoCode), sink)
            formattingDataCache = result
        }
        return result
    }

    public func fetchVariantSymbol(isoCode: String, variant: String): ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_VariantSymbol {
        var result = variantSymbolCache
        if (result.isNone() || !result.isoCode.equals(isoCode) || !result.variant.equals(variant)) {
            result = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_VariantSymbol(isoCode, variant)
            let sink = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink(!fallback, ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCY_VARIANT)
            sink.variantSymbol = result
            rb.getAllItemsWithFallbackNoFail("Currencies%" + (variant) + "/" + (isoCode), sink)
            variantSymbolCache = result
        }
        return result
    }

    public func fetchPluralsData(isoCode: String): Array<String> {
        var result = pluralsDataCache
        if (result.isNone() || !result[0].equals(isoCode)) {
            result = Array<String>(Int64(1 + StandardPlural.COUNT))
            result[0] = isoCode
            let sink = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink(!fallback, ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCY_PLURALS)
            sink.pluralsData = result
            rb.getAllItemsWithFallbackNoFail("CurrencyPlurals/" + (isoCode), sink)
            pluralsDataCache = result
        }
        return result
    }

    public func fetchParsingData(): ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_ParsingData {
        var result = parsingDataCache.get()
        if (result.isNone()) {
            result = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_ParsingData()
            let sink = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink(!fallback, ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.TOP)
            sink.parsingData = result
            rb.getAllItemsWithFallback("", sink)
            parsingDataCache = SoftReference(result)
        }
        return result
    }

    public func fetchUnitPatterns(): Map<String, String> {
        var result = unitPatternsCache
        if (result.isNone()) {
            result = HashMap<String, String>()
            let sink = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink(!fallback, ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCY_UNIT_PATTERNS)
            sink.unitPatterns = result
            rb.getAllItemsWithFallback("CurrencyUnitPatterns", sink)
            unitPatternsCache = result
        }
        return result
    }

    public func fetchSpacingInfo(): CurrencyData_CurrencySpacingInfo {
        var result = spacingInfoCache
        if (result.isNone()) {
            result = CurrencyData_CurrencySpacingInfo()
            let sink = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink(!fallback, ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCY_SPACING)
            sink.spacingInfo = result
            rb.getAllItemsWithFallback("currencySpacing", sink)
            spacingInfoCache = result
        }
        return result
    }
}


class ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_FormattingData {
    let isoCode: String

    var displayName: String

    var symbol: String

    var formatInfo: CurrencyData_CurrencyFormatInfo

    init(isoCode: String) {
        this.isoCode = isoCode
    }
}


class ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_VariantSymbol {
    let isoCode: String

    let variant: String

    var symbol: String

    init(isoCode: String, variant: String) {
        this.isoCode = isoCode
        this.variant = variant
    }
}


class ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_ParsingData {

    var symbolToIsoCode: Map<String, String> = HashMap<String, String>()

    var nameToIsoCode: Map<String, String> = HashMap<String, String>()
}


class ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink <: UResource_Sink {
    let noRoot: Bool

    let entrypointTable: ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable

    var formattingData: ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_FormattingData

    var pluralsData: Array<String>

    var parsingData: ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_ParsingData

    var unitPatterns: Map<String, String> = None

    var spacingInfo: CurrencyData_CurrencySpacingInfo

    var variantSymbol: ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_VariantSymbol

    init(noRoot: Bool, entrypointTable: ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable) {
        super()
        this.noRoot = noRoot
        this.entrypointTable = entrypointTable
    }

    public override func put(key: UResource_Key, value: UResource_Value, isRoot: Bool): Unit {
        if (noRoot && isRoot) {
            return
        }
        match (entrypointTable) {
            case ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.TOP => consumeTopTable(key, value)
            case ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCIES => consumeCurrenciesEntry(key, value)
            case ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCY_PLURALS => consumeCurrencyPluralsEntry(key, value)
            case ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCY_VARIANT => consumeCurrenciesVariantEntry(key, value)
            case ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCY_SPACING => consumeCurrencySpacingTable(key, value)
            case ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCY_UNIT_PATTERNS => consumeCurrencyUnitPatternsTable(key, value)
            case _ => ()
        }
    }

    private func consumeTopTable(key: UResource_Key, value: UResource_Value): Unit {
        let table = value.getTable()
        var i = 0
        while (table.getKeyAndValue(i, key, value)) {
            if (key.contentEquals("Currencies")) {
                consumeCurrenciesTable(key, value)
            } else if (key.contentEquals("Currencies%variant")) {
                consumeCurrenciesVariantTable(key, value)
            } else if (key.contentEquals("CurrencyPlurals")) {
                consumeCurrencyPluralsTable(key, value)
            }
            i++
        }
    }

    public func consumeCurrenciesTable(key: UResource_Key, value: UResource_Value): Unit {
        if (!parsingData.isSome()) {
            throw AssertionError()
        }
        let table = value.getTable()
        var i = 0
        while (table.getKeyAndValue(i, key, value)) {
            let isoCode: String = key.toString()
            if (value.getType() != UResourceBundle.ARRAY) {
                throw ICUException("Unexpected data type in Currencies table for " + (isoCode))
            }
            let array = value.getArray()
            parsingData.symbolToIsoCode.put(isoCode, isoCode)
            array.getValue(0, value)
            parsingData.symbolToIsoCode.put(value.getString(), isoCode)
            array.getValue(1, value)
            parsingData.nameToIsoCode.put(value.getString(), isoCode)
            i++
        }
    }

    public func consumeCurrenciesEntry(key: UResource_Key, value: UResource_Value): Unit {
        if (!formattingData.isSome()) {
            throw AssertionError()
        }
        let isoCode: String = key.toString()
        if (value.getType() != UResourceBundle.ARRAY) {
            throw ICUException("Unexpected data type in Currencies table for " + (isoCode))
        }
        let array = value.getArray()
        if (formattingData.symbol.isNone()) {
            array.getValue(0, value)
            formattingData.symbol = value.getString()
        }
        if (formattingData.displayName.isNone()) {
            array.getValue(1, value)
            formattingData.displayName = value.getString()
        }
        if (array.getSize() > 2 && formattingData.formatInfo.isNone()) {
            array.getValue(2, value)
            let formatArray = value.getArray()
            formatArray.getValue(0, value)
            let formatPattern = value.getString()
            formatArray.getValue(1, value)
            let decimalSeparator = value.getString()
            formatArray.getValue(2, value)
            let groupingSeparator = value.getString()
            formattingData.formatInfo = CurrencyData_CurrencyFormatInfo(isoCode, formatPattern, decimalSeparator, groupingSeparator)
        }
    }

    public func consumeCurrenciesVariantEntry(key: UResource_Key, value: UResource_Value): Unit {
        if (!variantSymbol.isSome()) {
            throw AssertionError()
        }
        if (variantSymbol.symbol.isNone()) {
            variantSymbol.symbol = value.getString()
        }
    }

    public func consumeCurrenciesVariantTable(key: UResource_Key, value: UResource_Value): Unit {
        if (!parsingData.isSome()) {
            throw AssertionError()
        }
        let table = value.getTable()
        var i = 0
        while (table.getKeyAndValue(i, key, value)) {
            let isoCode: String = key.toString()
            parsingData.symbolToIsoCode.put(value.getString(), isoCode)
            i++
        }
    }

    public func consumeCurrencyPluralsTable(key: UResource_Key, value: UResource_Value): Unit {
        if (!parsingData.isSome()) {
            throw AssertionError()
        }
        let table = value.getTable()
        var i = 0
        while (table.getKeyAndValue(i, key, value)) {
            let isoCode: String = key.toString()
            let pluralsTable = value.getTable()
            var j = 0
            while (pluralsTable.getKeyAndValue(j, key, value)) {
                let plural = StandardPlural.orNullFromString(key.toString())
                if (plural.isNone()) {
                    throw ICUException("Could not make StandardPlural from keyword " + key.asString())
                }
                parsingData.nameToIsoCode.put(value.getString(), isoCode)
                j++
            }
            i++
        }
    }

    public func consumeCurrencyPluralsEntry(key: UResource_Key, value: UResource_Value): Unit {
        if (!pluralsData.isSome()) {
            throw AssertionError()
        }
        let pluralsTable = value.getTable()
        var j = 0
        while (pluralsTable.getKeyAndValue(j, key, value)) {
            let plural = StandardPlural.orNullFromString(key.toString())
            if (plural.isNone()) {
                throw ICUException("Could not make StandardPlural from keyword " + key.asString())
            }
            if (pluralsData[Int64(1 + plural.ordinal)].isNone()) {
                pluralsData[Int64(1 + plural.ordinal)] = value.getString()
            }
            j++
        }
    }

    public func consumeCurrencySpacingTable(key: UResource_Key, value: UResource_Value): Unit {
        if (!spacingInfo.isSome()) {
            throw AssertionError()
        }
        let spacingTypesTable = value.getTable()
        var i = 0
        while (spacingTypesTable.getKeyAndValue(i, key, value)) {
            let Type: CurrencyData_CurrencySpacingInfo_SpacingType
            if (key.contentEquals("beforeCurrency")) {
                Type = CurrencyData_CurrencySpacingInfo_SpacingType.BEFORE
                spacingInfo.hasBeforeCurrency = true
            } else if (key.contentEquals("afterCurrency")) {
                Type = CurrencyData_CurrencySpacingInfo_SpacingType.AFTER
                spacingInfo.hasAfterCurrency = true
            } else {
                continue
            }
            let patternsTable = value.getTable()
            var j = 0
            while (patternsTable.getKeyAndValue(j, key, value)) {
                let pattern: CurrencyData_CurrencySpacingInfo_SpacingPattern
                if (key.contentEquals("currencyMatch")) {
                    pattern = CurrencyData_CurrencySpacingInfo_SpacingPattern.CURRENCY_MATCH
                } else if (key.contentEquals("surroundingMatch")) {
                    pattern = CurrencyData_CurrencySpacingInfo_SpacingPattern.SURROUNDING_MATCH
                } else if (key.contentEquals("insertBetween")) {
                    pattern = CurrencyData_CurrencySpacingInfo_SpacingPattern.INSERT_BETWEEN
                } else {
                    continue
                }
                spacingInfo.setSymbolIfNull(Type, pattern, value.getString())
                j++
            }
            i++
        }
    }

    public func consumeCurrencyUnitPatternsTable(key: UResource_Key, value: UResource_Value): Unit {
        if (!unitPatterns.isSome()) {
            throw AssertionError()
        }
        let table = value.getTable()
        var i = 0
        while (table.getKeyAndValue(i, key, value)) {
            let pluralKeyword: String = key.toString()
            if (unitPatterns.get(pluralKeyword).isNone()) {
                unitPatterns.put(pluralKeyword, value.getString())
            }
            i++
        }
    }
}


class ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable <: Enum<ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable> {
    public static let TOP = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable("TOP", 0)

    public static let CURRENCIES = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable("CURRENCIES", 1)

    public static let CURRENCY_PLURALS = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable("CURRENCY_PLURALS", 2)

    public static let CURRENCY_VARIANT = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable("CURRENCY_VARIANT", 3)

    public static let CURRENCY_SPACING = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable("CURRENCY_SPACING", 4)

    public static let CURRENCY_UNIT_PATTERNS = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable("CURRENCY_UNIT_PATTERNS", 5)

    private static func _values(): Array<ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable> {
        return [ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.TOP, ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCIES, ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCY_PLURALS, ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCY_VARIANT, ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCY_SPACING, ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable.CURRENCY_UNIT_PATTERNS]
    }

    private static let _VALUES = ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable._values()

    public static func values(): Array<ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable {
        return (TypeInfo.of<ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as ICUCurrencyDisplayInfoProvider_ICUCurrencyDisplayInfo_CurrencySink_EntrypointTable
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
