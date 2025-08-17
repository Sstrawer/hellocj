package icu4cj.impl.number.range


public class StandardPluralRanges {
    var flatTriples: Array<StandardPlural>

    var numTriples = 0

     private static var languageToSet: Map<String, String> = None

    public static let DEFAULT = StandardPluralRanges()

    private static func getLanguageToSet(): Map<String, String> {
        var candidate = languageToSet
        if (candidate.isNone()) {
            let map: Map<String, String> = HashMap<String, String>()
            let sink = StandardPluralRanges_PluralRangeSetsDataSink(map)
            let resource = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "pluralRanges")
            resource.getAllItemsWithFallback("locales", sink)
            candidate = Collections.unmodifiableMap(map as Map<K, V>)
        }
        if (languageToSet.isNone()) {
            languageToSet = candidate
        }
        return languageToSet
    }

    private static func getPluralRangesData(set: String, out: StandardPluralRanges): Unit {
        let sb = StringBuilder()
        let resource: ICUResourceBundle
        resource = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "pluralRanges")
        sb.setLength(0)
        sb.append("rules/")
        sb.append(set)
        let key: String = sb.toString()
        let sink = StandardPluralRanges_PluralRangesDataSink(out)
        resource.getAllItemsWithFallback(key, sink)
    }

    public static func forLocale(locale: ULocale): StandardPluralRanges {
        return forSet(getSetForLocale(locale))
    }

    public static func forSet(set: String): StandardPluralRanges {
        let result = StandardPluralRanges()
        if (set.isNone()) {
            return DEFAULT
        }
        getPluralRangesData(set, result)
        return result
    }

    public static func getSetForLocale(locale: ULocale): String {
        return getLanguageToSet().get(locale.getLanguage())
    }


    public func addPluralRange(first: StandardPlural, second: StandardPlural, result: StandardPlural): Unit {
        flatTriples[Int64(3 * numTriples)] = first
        flatTriples[Int64(3 * numTriples + 1)] = second
        flatTriples[Int64(3 * numTriples + 2)] = result
        numTriples++
    }

    public func setCapacity(length: Int32): Unit {
        flatTriples = Array<StandardPlural>(Int64(length * 3))
    }

    public func resolve(first: StandardPlural, second: StandardPlural): StandardPlural {
        var i = 0
        while (i < numTriples) {
            if (refEq(first, flatTriples[Int64(3 * i)]) && refEq(second, flatTriples[Int64(3 * i + 1)])) {
                return flatTriples[Int64(3 * i + 2)]
            }
            i++
        }
        return StandardPlural.OTHER
    }
}


class StandardPluralRanges_PluralRangeSetsDataSink <: UResource_Sink {
    var output: Map<String, String> = None

    init(output: Map<String, String>) {
        super()
        this.output = output
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let table = value.getTable()
        var i = 0
        while (table.getKeyAndValue(i, key, value)) {
            if (!key.toString().equals(ULocale(key.toString()).getLanguage())) {
                throw AssertionError()
            }
            output.put(key.toString(), value.toString())
            i++
        }
    }
}


class StandardPluralRanges_PluralRangesDataSink <: UResource_Sink {
    var output: StandardPluralRanges

    init(output: StandardPluralRanges) {
        super()
        this.output = output
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let entriesArray = value.getArray()
        output.setCapacity(entriesArray.getSize())
        var i = 0
        while (entriesArray.getValue(i, value)) {
            let pluralFormsArray = value.getArray()
            if (pluralFormsArray.getSize() != 3) {
                throw UResourceTypeMismatchException("Expected 3 elements in pluralRanges.txt array")
            }
            pluralFormsArray.getValue(0, value)
            let first = StandardPlural.fromString(value.getString())
            pluralFormsArray.getValue(1, value)
            let second = StandardPlural.fromString(value.getString())
            pluralFormsArray.getValue(2, value)
            let result = StandardPlural.fromString(value.getString())
            output.addPluralRange(first, second, result)
            i++
        }
    }
}
