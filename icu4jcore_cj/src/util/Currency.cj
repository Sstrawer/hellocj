package icu4cj.util


public class Currency <: MeasureUnit {
    private static let GeneratedStaticLockObject = Monitor()

    private static let serialVersionUID = -5839973855554750484

    private static let DEBUG = ICUDebug.enabled("currency")

    private static var CURRENCY_NAME_CACHE: ICUCache<ULocale, ArrayList<TextTrieMap<Currency_CurrencyStringInfo>>> = SimpleCache<ULocale, ArrayList<TextTrieMap<Currency_CurrencyStringInfo>>>()

    public static let SYMBOL_NAME = 0

    public static let LONG_NAME = 1

    public static let PLURAL_LONG_NAME = 2

    public static let NARROW_SYMBOL_NAME = 3

    public static let FORMAL_SYMBOL_NAME = 4

    public static let VARIANT_SYMBOL_NAME = 5

    private static var shim: Currency_ServiceShim

    private static func getShim(): Currency_ServiceShim {
        if (shim.isNone()) {
            try {
                let cls: ClassTypeInfo = TypeInfo.get("com.ibm.icu.util.CurrencyServiceShim") as ClassTypeInfo
                shim = cls.construct([0]) as Currency_ServiceShim
            } catch (e: Exception) {
                if (DEBUG) {
                    e.printStackTrace()
                }
                throw Exception(e.message)
            }
        }
        return shim
    }

    public static func getInstance(locale: Locale): Currency {
        return getInstance(ULocale.forLocale(locale))
    }

    public static func getInstance(locale: ULocale): Currency {
        let currency = locale.getKeywordValue("currency")
        if (currency.isSome()) {
            return getInstance(currency)
        }
        if (shim.isNone()) {
            return createCurrency(locale)
        }
        return shim.createInstance(locale)
    }

    public static func getAvailableCurrencyCodes(loc: ULocale, d: DateTime): Array<String> {
        let region = ULocale.getRegionForSupplementalData(loc, false)
        let filter = CurrencyMetaInfo_CurrencyFilter.onDate(d).withRegion(region)
        let list = getTenderCurrencies(filter)
        if (list.isEmpty()) {
            return None
        }
        return list.toArray(size))
    }

    public static func getAvailableCurrencyCodes(loc: Locale, d: DateTime): Array<String> {
        return getAvailableCurrencyCodes(ULocale.forLocale(loc), d)
    }

    public static func getAvailableCurrencies(): Set<Currency> {
        let info = CurrencyMetaInfo.getInstance()
        let list = info.currencies(CurrencyMetaInfo_CurrencyFilter.all())
        let resultSet = HashSet<Currency>(list.size)
        for (code in list) {
            resultSet.put(getInstance(code))
        }
        return resultSet
    }

    private static let regionCurrencyCache: CacheBase<String, Currency, Void> = Currency_1()

    static func createCurrency(loc: ULocale): Currency {
        let key = ULocale.getRegionForSupplementalData(loc, false)
        return regionCurrencyCache.getInstance(key, None)
    }

    static func loadCurrency(key: String): Currency {
        let region = key
        let info = CurrencyMetaInfo.getInstance()
        var list = info.currencies(CurrencyMetaInfo_CurrencyFilter.onRegion(region).withTender())
        if (list.isEmpty()) {
            list = info.currencies(CurrencyMetaInfo_CurrencyFilter.onRegion(region))
        }
        if (!list.isEmpty()) {
            let code = list[0]
            return getInstance(code)
        }
        return None
    }

    public static func getInstance(theISOCode: String): Currency {
        if (theISOCode.isNone()) {
            throw NoneValueException("The input currency code is null.")
        }
        if (!isAlpha3Code(theISOCode)) {
            throw IllegalArgumentException("The input currency code is not 3-letter alphabetic code.")
        }
        return MeasureUnit.internalGetInstance("currency", theISOCode.toUpperCase(Locale.ENGLISH))
    }

    private static func isAlpha3Code(code: String): Bool {
        if (Int32(code.size) != 3) {
            return false
        } else {
            var i = 0
            while (i < 3) {
                let ch = Char(code[Int64(i)])
                if (ch < 'A' || (ch > 'Z' && ch < 'a') || ch > 'z') {
                    return false
                }
                i++
            }
        }
        return true
    }

    public static func fromJavaCurrency(currency: Currency): Currency {
        return getInstance(currency.getCurrencyCode())
    }

    public func toJavaCurrency(): Currency {
        return Currency.getInstance(getCurrencyCode())
    }

    public static func registerInstance(currency: Currency, locale: ULocale): Object {
        return getShim().registerInstance(currency, locale)
    }

    public static func unregister(registryKey: Object): Bool {
        if (registryKey.isNone()) {
            throw IllegalArgumentException("registryKey must not be null")
        }
        if (shim.isNone()) {
            return false
        }
        return shim.unregister(registryKey)
    }

    public static func getAvailableLocales(): Array<Locale> {
        if (shim.isNone()) {
            return ICUResourceBundle.getAvailableLocales()
        } else {
            return shim.getAvailableLocales()
        }
    }

    public static func getAvailableULocales(): Array<ULocale> {
        if (shim.isNone()) {
            return ICUResourceBundle.getAvailableULocales()
        } else {
            return shim.getAvailableULocales()
        }
    }

    public static func getKeywordValuesForLocale(key: String, locale: ULocale, commonlyUsed: Bool): Array<String> {
        if (!"currency".equals(key)) {
            return EMPTY_STRING_ARRAY
        }
        if (!commonlyUsed) {
            return getAllTenderCurrencies().toArray(Array<String>(0))
        }
        if (UND.equals(locale)) {
            return EMPTY_STRING_ARRAY
        }
        let prefRegion = ULocale.getRegionForSupplementalData(locale, true)
        let filter = CurrencyMetaInfo_CurrencyFilter.now().withRegion(prefRegion)
        let result = getTenderCurrencies(filter)
        if (Int32(result.size) == 0) {
            return EMPTY_STRING_ARRAY
        }
        return result.toArray(size))
    }

    private static let UND = ULocale("und")

    private static let EMPTY_STRING_ARRAY = Array<String>(0)

    public func getCurrencyCode(): String {
        return subType
    }

    public func getNumericCode(): Int32 {
        var result = 0
        try {
            let bundle = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "currencyNumericCodes", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
            let codeMap = bundle.get("codeMap")
            let numCode = codeMap.get(subType)
            result = numCode.getInt()
        } catch (e: MissingResourceException) { }
        return result
    }

    public func getSymbol(): String {
        return getSymbol(ULocale.getDefault(ULocale_Category.DISPLAY))
    }

    public func getSymbol(loc: Locale): String {
        return getSymbol(ULocale.forLocale(loc))
    }

    public func getSymbol(uloc: ULocale): String {
        return getName(uloc, SYMBOL_NAME, None)
    }

    public func getName(locale: Locale, nameStyle: Int32, isChoiceFormat: Array<Bool>): String {
        return getName(ULocale.forLocale(locale), nameStyle, isChoiceFormat)
    }

    public func getName(locale: ULocale, nameStyle: Int32, isChoiceFormat: Array<Bool>): String {
        if (isChoiceFormat.isSome()) {
            isChoiceFormat[0] = false
        }
        let names = CurrencyDisplayNames.getInstance(locale)
        match (nameStyle) {
            case 0 => return names.getSymbol(subType)
            case 3 => return names.getNarrowSymbol(subType)
            case 4 => return names.getFormalSymbol(subType)
            case 5 => return names.getVariantSymbol(subType)
            case 1 => return names.getName(subType)
            case _ => throw IllegalArgumentException("bad name style: " + nameStyle.toString())
        }
    }

    public func getName(locale: Locale, nameStyle: Int32, pluralCount: String, isChoiceFormat: Array<Bool>): String {
        return getName(ULocale.forLocale(locale), nameStyle, pluralCount, isChoiceFormat)
    }

    public func getName(locale: ULocale, nameStyle: Int32, pluralCount: String, isChoiceFormat: Array<Bool>): String {
        if (nameStyle != PLURAL_LONG_NAME) {
            return getName(locale, nameStyle, isChoiceFormat)
        }
        if (isChoiceFormat.isSome()) {
            isChoiceFormat[0] = false
        }
        let names = CurrencyDisplayNames.getInstance(locale)
        return names.getPluralName(subType, pluralCount)
    }

    public func getDisplayName(): String {
        return getName(Locale.getDefault(), LONG_NAME, None)
    }

    public func getDisplayName(locale: Locale): String {
        return getName(locale, LONG_NAME, None)
    }

    
    public static func parse(locale: ULocale, text: String, Type: Int32, pos: ParsePosition): String {
        let currencyTrieVec = getCurrencyTrieVec(locale)
        var maxLength = 0
        var isoResult: String
        let currencyNameTrie = currencyTrieVec[1]
        var handler: Currency_CurrencyNameResultHandler = Currency_CurrencyNameResultHandler()
        currencyNameTrie.find(text, pos.getIndex(), handler)
        isoResult = handler.getBestCurrencyISOCode()
        maxLength = handler.getBestMatchLength()
        if (Type != Currency.LONG_NAME) {
            let currencySymbolTrie = currencyTrieVec[0]
            handler = Currency_CurrencyNameResultHandler()
            currencySymbolTrie.find(text, pos.getIndex(), handler)
            if (handler.getBestMatchLength() > maxLength) {
                isoResult = handler.getBestCurrencyISOCode()
                maxLength = handler.getBestMatchLength()
            }
        }
        let start = pos.getIndex()
        pos.setIndex(start + maxLength)
        return isoResult
    }

    
    public static func getParsingTrie(locale: ULocale, Type: Int32): TextTrieMap<Currency_CurrencyStringInfo> {
        let currencyTrieVec = getCurrencyTrieVec(locale)
        if (Type == Currency.LONG_NAME) {
            return currencyTrieVec[1]
        } else {
            return currencyTrieVec[0]
        }
    }

    private static func getCurrencyTrieVec(locale: ULocale): ArrayList<TextTrieMap<Currency_CurrencyStringInfo>> {
        var currencyTrieVec = CURRENCY_NAME_CACHE.get(locale)
        if (currencyTrieVec.isNone()) {
            let currencyNameTrie = TextTrieMap<Currency_CurrencyStringInfo>(true)
            let currencySymbolTrie = TextTrieMap<Currency_CurrencyStringInfo>(false)
            currencyTrieVec = ArrayList<TextTrieMap<Currency_CurrencyStringInfo>>()
            currencyTrieVec.append(currencySymbolTrie)
            currencyTrieVec.append(currencyNameTrie)
            setupCurrencyTrieVec(locale, currencyTrieVec)
            CURRENCY_NAME_CACHE.put(locale, currencyTrieVec)
        }
        return currencyTrieVec
    }

    private static func setupCurrencyTrieVec(locale: ULocale, trieVec: ArrayList<TextTrieMap<Currency_CurrencyStringInfo>>): Unit {
        let symTrie = trieVec[0]
        let trie = trieVec[1]
        let names = CurrencyDisplayNames.getInstance(locale)
        for (e in names.symbolMap().entrySet()) {
            let symbol = e.getKey()
            let isoCode = e.getValue()
            let key = StaticUnicodeSets.chooseCurrency(symbol)
            let value = Currency_CurrencyStringInfo(isoCode, symbol)
            if (key.isSome()) {
                let equivalents = StaticUnicodeSets.get(key)
                for (equivalentSymbol in equivalents) {
                    symTrie.put(equivalentSymbol, value)
                }
            } else {
                symTrie.put(symbol, value)
            }
        }
        for (e in names.nameMap().entrySet()) {
            let name = e.getKey()
            let isoCode = e.getValue()
            trie.put(name, Currency_CurrencyStringInfo(isoCode, name))
        }
    }

    public func getDefaultFractionDigits(): Int32 {
        return getDefaultFractionDigits(Currency_CurrencyUsage.STANDARD)
    }

    public func getDefaultFractionDigits(Usage: Currency_CurrencyUsage): Int32 {
        let info = CurrencyMetaInfo.getInstance()
        let digits = info.currencyDigits(subType, Usage)
        return digits.fractionDigits
    }

    public func getRoundingIncrement(): Float64 {
        return getRoundingIncrement(Currency_CurrencyUsage.STANDARD)
    }

    public func getRoundingIncrement(Usage: Currency_CurrencyUsage): Float64 {
        let info = CurrencyMetaInfo.getInstance()
        let digits = info.currencyDigits(subType, Usage)
        let data1 = digits.roundingIncrement
        if (data1 == 0) {
            return 0.0
        }
        let data0 = digits.fractionDigits
        if (data0 < 0 || data0 >= Int32(POW10.size)) {
            return 0.0
        }
        return Float64(data1) / Float64(POW10[Int64(data0)])
    }

    public override func toString(): String {
        return subType
    }

    protected init(theISOCode: String) {
        super("currency", theISOCode)
        isoCode = theISOCode
    }

    private static let POW10 = [1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000]

    private static var ALL_TENDER_CODES: SoftReference = None

    private static var ALL_CODES_AS_SET: SoftReference = None

    private static func getAllTenderCurrencies(): ArrayList<String> {
        synchronized (GeneratedStaticLockObject) {
            var all: ArrayList<String> = if (ALL_TENDER_CODES.isNone()) { None } else { ALL_TENDER_CODES.get() }
            if (all.isNone()) {
                let filter = CurrencyMetaInfo_CurrencyFilter.all()
                all = Collections.unmodifiableList(getTenderCurrencies(filter))
                ALL_TENDER_CODES = SoftReference(all)
            }
            return all
        }
    }

    private static func getAllCurrenciesAsSet(): Set<String> {
        synchronized (GeneratedStaticLockObject) {
            var all: Set<String> = if (ALL_CODES_AS_SET.isNone()) { None } else { ALL_CODES_AS_SET.get() }
            if (all.isNone()) {
                let info = CurrencyMetaInfo.getInstance()
                all = Collections.unmodifiableSet(// Мapping is present but failed: HashSet<E>(info.currencies(CurrencyMetaInfo_CurrencyFilter.all())) as Set<T>)
                ALL_CODES_AS_SET = SoftReference(all)
            }
            return all
        }
    }

    public static func isAvailable(code: String, comefrom: DateTime, to: DateTime): Bool {
        var tempcode = code
        if (!isAlpha3Code(tempcode)) {
            return false
        }
        if (comefrom.isSome() && to.isSome() && comefrom.after(to)) {
            throw IllegalArgumentException("To is before from")
        }
        tempcode = tempcode.toUpperCase(Locale.ENGLISH)
        let isKnown = getAllCurrenciesAsSet().contains(tempcode)
        if (isKnown == false) {
            return false
        } else if (comefrom.isNone() && to.isNone()) {
            return true
        }
        let info = CurrencyMetaInfo.getInstance()
        let allActive = info.currencies(CurrencyMetaInfo_CurrencyFilter.onDateRange(comefrom, to).withCurrency(tempcode))
        return allActive.contains(tempcode)
    }

    private static func getTenderCurrencies(filter: CurrencyMetaInfo_CurrencyFilter): ArrayList<String> {
        let info = CurrencyMetaInfo.getInstance()
        return info.currencies(filter.withTender())
    }

    private func writeReplace(): Object {
        return MeasureUnit_MeasureUnitProxy(Type, subType)
    }

    private let isoCode: String

    private func readResolve(): Object {
        return Currency.getInstance(isoCode)
    }
}


public class Currency_CurrencyUsage <: Enum<Currency_CurrencyUsage> {
    public static let STANDARD = Currency_CurrencyUsage("STANDARD", 0)

    public static let CASH = Currency_CurrencyUsage("CASH", 1)

    private static func _values(): Array<Currency_CurrencyUsage> {
        return [Currency_CurrencyUsage.STANDARD, Currency_CurrencyUsage.CASH]
    }

    private static let _VALUES = Currency_CurrencyUsage._values()

    public static func values(): Array<Currency_CurrencyUsage> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): Currency_CurrencyUsage {
        return (TypeInfo.of<Currency_CurrencyUsage>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as Currency_CurrencyUsage
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


abstract class Currency_ServiceShim {

    public func getAvailableULocales(): Array<ULocale>

    public func getAvailableLocales(): Array<Locale>

    public func createInstance(l: ULocale): Currency

    public func registerInstance(c: Currency, l: ULocale): Object

    public func unregister(f: Object): Bool
}


class Currency_1 <: SoftCache<String, Currency, Void> {
    init() {
        super()
    }

    override protected func createInstance(key: String, unused: Void): Currency {
        return Currency.loadCurrency(key)
    }
}



public class Currency_CurrencyStringInfo {
    private var isoCode: String

    private var currencyString: String

    
    public init(isoCode: String, currencyString: String) {
        this.isoCode = isoCode
        this.currencyString = currencyString
    }

    
    public func getISOCode(): String {
        return isoCode
    }

    
    public func getCurrencyString(): String {
        return currencyString
    }
}


class Currency_CurrencyNameResultHandler <: TextTrieMap_ResultHandler<Currency_CurrencyStringInfo> {

    private var bestMatchLength: Int32 = 0

    private var bestCurrencyISOCode: String

    public override func handlePrefixMatch(matchLength: Int32, values: Iterator<Currency_CurrencyStringInfo>): Bool {
        if (values.hasNext()) {
            bestCurrencyISOCode = values.next().getISOCode()
            bestMatchLength = matchLength
        }
        return true
    }

    public func getBestCurrencyISOCode(): String {
        return bestCurrencyISOCode
    }

    public func getBestMatchLength(): Int32 {
        return bestMatchLength
    }
}
