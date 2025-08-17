package icu4cj.text


public class CurrencyPluralInfo <: Cloneable & Serializable {
    private static let serialVersionUID = 1

    public init() {
        initialize(ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public init(locale: Locale) {
        initialize(ULocale.forLocale(locale))
    }

    public init(locale: ULocale) {
        initialize(locale)
    }

    public static func getInstance(): CurrencyPluralInfo {
        return CurrencyPluralInfo()
    }

    public static func getInstance(locale: Locale): CurrencyPluralInfo {
        return CurrencyPluralInfo(locale)
    }

    public static func getInstance(locale: ULocale): CurrencyPluralInfo {
        return CurrencyPluralInfo(locale)
    }

    public func getPluralRules(): PluralRules {
        return pluralRules
    }

    public func getCurrencyPluralPattern(pluralCount: String): String {
        var currencyPluralPattern = pluralCountToCurrencyUnitPattern.get(pluralCount)
        if (currencyPluralPattern.isNone()) {
            if (!(pluralCount == "other")) {
                currencyPluralPattern = pluralCountToCurrencyUnitPattern.get("other")
            }
            if (currencyPluralPattern.isNone()) {
                currencyPluralPattern = defaultCurrencyPluralPattern
            }
        }
        return currencyPluralPattern
    }

    public func getLocale(): ULocale {
        return ulocale
    }

    public func setPluralRules(ruleDescription: String): Unit {
        pluralRules = PluralRules.createRules(ruleDescription)
    }

    public func setCurrencyPluralPattern(pluralCount: String, pattern: String): Unit {
        pluralCountToCurrencyUnitPattern.put(pluralCount, pattern)
    }

    public func setLocale(loc: ULocale): Unit {
        ulocale = loc
        initialize(loc)
    }

    public override func clone(): Object {
        try {
            let other = super.toString()
            other.ulocale = ulocale.clone()
            other.pluralCountToCurrencyUnitPattern = HashMap<String, String>()
            for (pluralCount in SetCollectionView<String>(pluralCountToCurrencyUnitPattern.keys())) {
                let currencyPattern = pluralCountToCurrencyUnitPattern.get(pluralCount)
                other.pluralCountToCurrencyUnitPattern.put(pluralCount, currencyPattern)
            }
            return other
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException(e as Exception)
        }
    }

    public override func equals(a: Object): Bool {
        if (checkOptionalIs<CurrencyPluralInfo, Object>(a)) {
            let other = a
            return pluralRules.equals(other.pluralRules) && // Мapping is present but failed: refEq(pluralCountToCurrencyUnitPattern, other.pluralCountToCurrencyUnitPattern)
        }
        return false
    }

    public override func hashCode(): Int64 {
        return Int64(Int32(pluralCountToCurrencyUnitPattern.hashCode()) ^ Int32(pluralRules.hashCode()) ^ Int32(ulocale.hashCode()))
    }

    
    public func select(number: Float64): String {
        return pluralRules.select(number)
    }

    
    public func select(numberInfo: PluralRules_FixedDecimal): String {
        return pluralRules.select(numberInfo)
    }

    
    public func pluralPatternIterator(): Iterator<String> {
        return SetCollectionView<String>(pluralCountToCurrencyUnitPattern.keys()).iterator()
    }

    private func initialize(uloc: ULocale): Unit {
        ulocale = uloc
        pluralRules = PluralRules.forLocale(uloc)
        setupCurrencyPluralPattern(uloc)
    }

    private func setupCurrencyPluralPattern(uloc: ULocale): Unit {
        pluralCountToCurrencyUnitPattern = HashMap<String, String>()
        var numberStylePattern = NumberFormat.getPattern(uloc, NumberFormat.NUMBERSTYLE)
        let separatorIndex = indexOfWrap(numberStylePattern.indexOf(";"))
        var negNumberPattern: String
        if (separatorIndex != -1) {
            negNumberPattern = numberStylePattern[Int64(separatorIndex + 1)..]
            numberStylePattern = numberStylePattern[0..Int64(separatorIndex)]
        }
        let map = CurrencyData.provider.getInstance(uloc, true).getUnitPatterns()
        for (e in map.entrySet()) {
            let pluralCount = e.getKey()
            let pattern = e.getValue()
            let patternWithNumber: String = pattern.replace("{0}", numberStylePattern)
            var patternWithCurrencySign: String = patternWithNumber.replace("{1}", tripleCurrencyStr)
            if (separatorIndex != -1) {
                let negPattern = pattern
                let negWithNumber: String = negPattern.replace("{0}", negNumberPattern)
                let negWithCurrSign: String = negWithNumber.replace("{1}", tripleCurrencyStr)
                let posNegPatterns = StringBuilder(patternWithCurrencySign)
                posNegPatterns.append(";")
                posNegPatterns.append(negWithCurrSign)
                patternWithCurrencySign = posNegPatterns.toString()
            }
            pluralCountToCurrencyUnitPattern.put(pluralCount, patternWithCurrencySign)
        }
    }

    private static let tripleCurrencySign: Array<Char> = [Char(164), Char(164), Char(164)]

    private static let tripleCurrencyStr = String(tripleCurrencySign)

    private static let defaultCurrencyPluralPatternChar: Array<Char> = [Char(0), '.', '#', '#', ' ', Char(164), Char(164), Char(164)]

    private static let defaultCurrencyPluralPattern = String(defaultCurrencyPluralPatternChar)

    private var pluralCountToCurrencyUnitPattern: Map<String, String> = None

    private var pluralRules: PluralRules

    private var ulocale: ULocale
}
