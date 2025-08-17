package icu4cj.impl.number


public class CompactData <: MultiplierProducer {
    static let USE_FALLBACK = "<USE FALLBACK>"

    let patterns: Array<String>

    let multipliers: Array<UInt8>

    var largestMagnitude: UInt8 = 0

    var isEmpty: Bool = false

    static let COMPACT_MAX_DIGITS = 20

    public init() {
        patterns = Array<String>(Int64((CompactData.COMPACT_MAX_DIGITS + 1) * StandardPlural.COUNT))
        multipliers = Array<UInt8>(Int64(CompactData.COMPACT_MAX_DIGITS + 1)) { _ => 0 }
        largestMagnitude = 0
        isEmpty = true
    }

    public func populate(locale: ULocale, nsName: String, compactStyle: CompactDecimalFormat_CompactStyle, compactType: CompactData_CompactType): Unit {
        if (!isEmpty) {
            throw AssertionError()
        }
        let sink = CompactData_CompactDataSink(this)
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, locale)
        let nsIsLatn = nsName == "latn"
        let compactIsShort = refEq(compactStyle, CompactDecimalFormat_CompactStyle.SHORT)
        let resourceKey = StringBuilder()
        getResourceBundleKey(nsName, compactStyle, compactType, resourceKey)
        rb.getAllItemsWithFallbackNoFail(resourceKey.toString(), sink)
        if (isEmpty && !nsIsLatn) {
            getResourceBundleKey("latn", compactStyle, compactType, resourceKey)
            rb.getAllItemsWithFallbackNoFail(resourceKey.toString(), sink)
        }
        if (isEmpty && !compactIsShort) {
            getResourceBundleKey(nsName, CompactDecimalFormat_CompactStyle.SHORT, compactType, resourceKey)
            rb.getAllItemsWithFallbackNoFail(resourceKey.toString(), sink)
        }
        if (isEmpty && !nsIsLatn && !compactIsShort) {
            getResourceBundleKey("latn", CompactDecimalFormat_CompactStyle.SHORT, compactType, resourceKey)
            rb.getAllItemsWithFallbackNoFail(resourceKey.toString(), sink)
        }
        if (isEmpty) {
            throw ICUException("Could not load compact decimal data for locale " + locale.asString())
        }
    }

    private static func getResourceBundleKey(nsName: String, compactStyle: CompactDecimalFormat_CompactStyle, compactType: CompactData_CompactType, sb: StringBuilder): Unit {
        sb.setLength(0)
        sb.append("NumberElements/")
        sb.append(nsName)
        sb.append(if (refEq(compactStyle, CompactDecimalFormat_CompactStyle.SHORT)) { "/patternsShort" } else { "/patternsLong" })
        sb.append(if (refEq(compactType, CompactData_CompactType.DECIMAL)) { "/decimalFormat" } else { "/currencyFormat" })
    }

    public func populate(powersToPluralsToPatterns: Map<String, Map<String, String>>): Unit {
        if (!isEmpty) {
            throw AssertionError()
        }
        for (magnitudeEntry in powersToPluralsToPatterns.entrySet()) {
            let magnitude = UInt8(Int32(magnitudeEntry.getKey().size) - 1)
            for (pluralEntry in magnitudeEntry.getValue().entrySet()) {
                let pluralString: String = toString(pluralEntry.getKey())
                let plural = StandardPlural.fromString(pluralString)
                let patternString: String = toString(pluralEntry.getValue())
                patterns[Int64(getIndex(Int32(magnitude), plural))] = patternString
                let numZeros = countZeros(patternString)
                if (numZeros > 0) {
                    multipliers[Int64(magnitude)] = UInt8(numZeros - Int32(magnitude) - 1)
                    if (magnitude > largestMagnitude) {
                        largestMagnitude = magnitude
                    }
                    isEmpty = false
                }
            }
        }
    }

    public override func getMultiplier(magnitude: Int32): Int32 {
        var tempmagnitude = magnitude
        if (tempmagnitude < 0) {
            return 0
        }
        if (tempmagnitude > Int32(largestMagnitude)) {
            tempmagnitude = Int32(largestMagnitude)
        }
        return Int32(multipliers[Int64(tempmagnitude)])
    }

    public func getPattern(magnitude: Int32, rules: PluralRules, dq: DecimalQuantity): String {
        var tempmagnitude = magnitude
        if (tempmagnitude < 0) {
            return None
        }
        if (tempmagnitude > Int32(largestMagnitude)) {
            tempmagnitude = Int32(largestMagnitude)
        }
        var patternString: String
        if (dq.isHasIntegerValue()) {
            let i = dq.toLong(true)
            if (i == 0) {
                patternString = patterns[Int64(getIndex(tempmagnitude, StandardPlural.EQ_0))]
            } else if (i == 1) {
                patternString = patterns[Int64(getIndex(tempmagnitude, StandardPlural.EQ_1))]
            }
            if (patternString.isSome()) {
                return patternString
            }
        }
        let plural = dq.getStandardPlural(rules)
        patternString = patterns[Int64(getIndex(tempmagnitude, plural))]
        if (patternString.isNone() && !refEq(plural, StandardPlural.OTHER)) {
            patternString = patterns[Int64(getIndex(tempmagnitude, StandardPlural.OTHER))]
        }
        if (refEq(patternString, USE_FALLBACK)) {
            patternString = None
        }
        return patternString
    }

    public func getUniquePatterns(output: Set<String>): Unit {
        if (!output.isEmpty()) {
            throw AssertionError()
        }
        output.putAll(patterns)
        output.remove(USE_FALLBACK)
        output.remove(None)
    }

    static func getIndex(magnitude: Int32, plural: StandardPlural): Int32 {
        return magnitude * StandardPlural.COUNT + plural.ordinal
    }

    static func countZeros(patternString: String): Int32 {
        var numZeros = 0
        var i = 0
        while (i < Int32(patternString.size)) {
            if (Char(patternString[Int64(i)]) == '0') {
                numZeros++
            } else if (numZeros > 0) {
                break
            }
            i++
        }
        return numZeros
    }
}


public class CompactData_CompactType <: Enum<CompactData_CompactType> {
    public static let DECIMAL = CompactData_CompactType("DECIMAL", 0)

    public static let CURRENCY = CompactData_CompactType("CURRENCY", 1)

    private static func _values(): Array<CompactData_CompactType> {
        return [CompactData_CompactType.DECIMAL, CompactData_CompactType.CURRENCY]
    }

    private static let _VALUES = CompactData_CompactType._values()

    public static func values(): Array<CompactData_CompactType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): CompactData_CompactType {
        return (TypeInfo.of<CompactData_CompactType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as CompactData_CompactType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class CompactData_CompactDataSink <: UResource_Sink {
    var data: CompactData

    public init(data: CompactData) {
        super()
        this.data = data
    }

    public override func put(key: UResource_Key, value: UResource_Value, isRoot: Bool): Unit {
        let powersOfTenTable = value.getTable()
        var i3 = 0
        while (powersOfTenTable.getKeyAndValue(i3, key, value)) {
            let magnitude = UInt8(key.lengthMethod() - 1)
            if (Int32(magnitude) >= CompactData.COMPACT_MAX_DIGITS) {
                continue
            }
            var multiplier = data.multipliers[Int64(magnitude)]
            let pluralVariantsTable = value.getTable()
            var i4 = 0
            while (pluralVariantsTable.getKeyAndValue(i4, key, value)) {
                let plural = StandardPlural.fromString(key.toString())
                if (data.patterns[Int64(CompactData.getIndex(Int32(magnitude), plural))].isSome()) {
                    continue
                }
                var patternString: String = value.toString()
                if (patternString == "0") {
                    patternString = CompactData.USE_FALLBACK
                }
                data.patterns[Int64(CompactData.getIndex(Int32(magnitude), plural))] = patternString
                if (Int32(multiplier) == 0) {
                    let numZeros = CompactData.countZeros(patternString)
                    if (numZeros > 0) {
                        multiplier = UInt8(numZeros - Int32(magnitude) - 1)
                    }
                }
                i4++
            }
            if (Int32(data.multipliers[Int64(magnitude)]) == 0) {
                data.multipliers[Int64(magnitude)] = multiplier
                if (magnitude > data.largestMagnitude) {
                    data.largestMagnitude = magnitude
                }
                data.isEmpty = false
            } else {
                if (!(data.multipliers[Int64(magnitude)] == multiplier)) {
                    throw AssertionError()
                }
            }
            i3++
        }
    }
}
