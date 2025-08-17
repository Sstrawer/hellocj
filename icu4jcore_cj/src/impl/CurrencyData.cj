package icu4cj.impl


public class CurrencyData {
    public static let provider: CurrencyData_CurrencyDisplayInfoProvider


}


public interface CurrencyData_CurrencyDisplayInfoProvider {
    func getInstance(locale: ULocale, withFallback: Bool): CurrencyData_CurrencyDisplayInfo

    func hasData(): Bool
}

public abstract class CurrencyData_CurrencyDisplayInfo <: CurrencyDisplayNames {
    public init() {
        super()
    }

    public func getUnitPatterns(): Map<String, String>

    public func getFormatInfo(isoCode: String): CurrencyData_CurrencyFormatInfo

    public func getSpacingInfo(): CurrencyData_CurrencySpacingInfo
}


public class CurrencyData_CurrencyFormatInfo {
    public let isoCode: String

    public let currencyPattern: String

    public let monetaryDecimalSeparator: String

    public let monetaryGroupingSeparator: String

    public init(isoCode: String, currencyPattern: String, monetarySeparator: String, monetaryGroupingSeparator: String) {
        this.isoCode = isoCode
        this.currencyPattern = currencyPattern
        this.monetaryDecimalSeparator = monetarySeparator
        this.monetaryGroupingSeparator = monetaryGroupingSeparator
    }
}


public class CurrencyData_CurrencySpacingInfo {
    private let symbols = Array<Array<String>>(Int64(CurrencyData_CurrencySpacingInfo_SpacingType.COUNT.ordinal)) { _ => Array<String>(Int64(CurrencyData_CurrencySpacingInfo_SpacingPattern.COUNT.ordinal)) }

    public var hasBeforeCurrency = false

    public var hasAfterCurrency = false


    public init(strings: Array<String>) {
        if (!(Int32(strings.size) == 6)) {
            throw AssertionError()
        }
        var k = 0
        var i = 0
        while (i < CurrencyData_CurrencySpacingInfo_SpacingType.COUNT.ordinal) {
            var j = 0
            while (j < CurrencyData_CurrencySpacingInfo_SpacingPattern.COUNT.ordinal) {
                symbols[Int64(i)][Int64(j)] = strings[Int64(k)]
                k++
                j++
            }
            i++
        }
    }

    public func setSymbolIfNull(Type: CurrencyData_CurrencySpacingInfo_SpacingType, pattern: CurrencyData_CurrencySpacingInfo_SpacingPattern, value: String): Unit {
        let i = Type.ordinal
        let j = pattern.ordinal
        if (symbols[Int64(i)][Int64(j)].isNone()) {
            symbols[Int64(i)][Int64(j)] = value
        }
    }

    public func getBeforeSymbols(): Array<String> {
        return symbols[Int64(CurrencyData_CurrencySpacingInfo_SpacingType.BEFORE.ordinal)]
    }

    public func getAfterSymbols(): Array<String> {
        return symbols[Int64(CurrencyData_CurrencySpacingInfo_SpacingType.AFTER.ordinal)]
    }

    private static let DEFAULT_CUR_MATCH = "[:letter:]"

    private static let DEFAULT_CTX_MATCH = "[:digit:]"

    private static let DEFAULT_INSERT = " "

    public static let DEFAULT = CurrencyData_CurrencySpacingInfo([DEFAULT_CUR_MATCH, DEFAULT_CTX_MATCH, DEFAULT_INSERT, DEFAULT_CUR_MATCH, DEFAULT_CTX_MATCH, DEFAULT_INSERT])
}


public class CurrencyData_CurrencySpacingInfo_SpacingType <: Enum<CurrencyData_CurrencySpacingInfo_SpacingType> {
    public static let BEFORE = CurrencyData_CurrencySpacingInfo_SpacingType("BEFORE", 0)

    public static let AFTER = CurrencyData_CurrencySpacingInfo_SpacingType("AFTER", 1)

    public static let COUNT = CurrencyData_CurrencySpacingInfo_SpacingType("COUNT", 2)

    private static func _values(): Array<CurrencyData_CurrencySpacingInfo_SpacingType> {
        return [CurrencyData_CurrencySpacingInfo_SpacingType.BEFORE, CurrencyData_CurrencySpacingInfo_SpacingType.AFTER, CurrencyData_CurrencySpacingInfo_SpacingType.COUNT]
    }

    private static let _VALUES = CurrencyData_CurrencySpacingInfo_SpacingType._values()

    public static func values(): Array<CurrencyData_CurrencySpacingInfo_SpacingType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): CurrencyData_CurrencySpacingInfo_SpacingType {
        return (TypeInfo.of<CurrencyData_CurrencySpacingInfo_SpacingType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as CurrencyData_CurrencySpacingInfo_SpacingType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class CurrencyData_CurrencySpacingInfo_SpacingPattern <: Enum<CurrencyData_CurrencySpacingInfo_SpacingPattern> {
    public static let CURRENCY_MATCH = CurrencyData_CurrencySpacingInfo_SpacingPattern("CURRENCY_MATCH", 0, DecimalFormatSymbols.CURRENCY_SPC_CURRENCY_MATCH)

    public static let SURROUNDING_MATCH = CurrencyData_CurrencySpacingInfo_SpacingPattern("SURROUNDING_MATCH", 1, DecimalFormatSymbols.CURRENCY_SPC_SURROUNDING_MATCH)

    public static let INSERT_BETWEEN = CurrencyData_CurrencySpacingInfo_SpacingPattern("INSERT_BETWEEN", 2, DecimalFormatSymbols.CURRENCY_SPC_INSERT)

    public static let COUNT = CurrencyData_CurrencySpacingInfo_SpacingPattern("COUNT", 3)

    private static func _values(): Array<CurrencyData_CurrencySpacingInfo_SpacingPattern> {
        return [CurrencyData_CurrencySpacingInfo_SpacingPattern.CURRENCY_MATCH, CurrencyData_CurrencySpacingInfo_SpacingPattern.SURROUNDING_MATCH, CurrencyData_CurrencySpacingInfo_SpacingPattern.INSERT_BETWEEN, CurrencyData_CurrencySpacingInfo_SpacingPattern.COUNT]
    }

    private static let _VALUES = CurrencyData_CurrencySpacingInfo_SpacingPattern._values()

    public static func values(): Array<CurrencyData_CurrencySpacingInfo_SpacingPattern> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): CurrencyData_CurrencySpacingInfo_SpacingPattern {
        return (TypeInfo.of<CurrencyData_CurrencySpacingInfo_SpacingPattern>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as CurrencyData_CurrencySpacingInfo_SpacingPattern
    }

    init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    init(_enum_name: String, _enum_ordinal: Int32, value: Int32) {
        super(_enum_name, _enum_ordinal)
        if (!(value == ordinal)) {
            throw AssertionError()
        }
    }
}


class CurrencyData_1 <: CurrencyData_CurrencyDisplayInfoProvider {

    public override func getInstance(locale: ULocale, withFallback: Bool): CurrencyData_CurrencyDisplayInfo {
        return CurrencyData_DefaultInfo.getWithFallback(withFallback)
    }

    public override func hasData(): Bool {
        return false
    }
}


public class CurrencyData_DefaultInfo <: CurrencyData_CurrencyDisplayInfo {
    private let fallback: Bool

    private init(fallback: Bool) {
        super()
        this.fallback = fallback
    }

    public static func getWithFallback(fallback: Bool): CurrencyData_CurrencyDisplayInfo {
        return if (fallback) { FALLBACK_INSTANCE } else { NO_FALLBACK_INSTANCE }
    }

    public override func getName(isoCode: String): String {
        return if (fallback) { isoCode } else { None }
    }

    public override func getPluralName(isoCode: String, pluralType: String): String {
        return if (fallback) { isoCode } else { None }
    }

    public override func getSymbol(isoCode: String): String {
        return if (fallback) { isoCode } else { None }
    }

    public override func getNarrowSymbol(isoCode: String): String {
        return if (fallback) { isoCode } else { None }
    }

    public override func getFormalSymbol(isoCode: String): String {
        return if (fallback) { isoCode } else { None }
    }

    public override func getVariantSymbol(isoCode: String): String {
        return if (fallback) { isoCode } else { None }
    }

    public override func symbolMap(): Map<String, String> {
        return Collections.emptyMap<<--, // Cannot infer type argument: V -->>()
    }

    public override func nameMap(): Map<String, String> {
        return Collections.emptyMap<<--, // Cannot infer type argument: V -->>()
    }

    public override func getULocale(): ULocale {
        return ULocale.ROOT
    }

    public override func getUnitPatterns(): Map<String, String> {
        if (fallback) {
            return Collections.emptyMap<<--, // Cannot infer type argument: V -->>()
        }
        return None
    }

    public override func getFormatInfo(isoCode: String): CurrencyData_CurrencyFormatInfo {
        return None
    }

    public override func getSpacingInfo(): CurrencyData_CurrencySpacingInfo {
        return if (fallback) { CurrencyData_CurrencySpacingInfo.DEFAULT } else { None }
    }

    private static let FALLBACK_INSTANCE: CurrencyData_CurrencyDisplayInfo = CurrencyData_DefaultInfo(true)

    private static let NO_FALLBACK_INSTANCE: CurrencyData_CurrencyDisplayInfo = CurrencyData_DefaultInfo(false)
}
