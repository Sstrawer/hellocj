package icu4cj.util


public class LocalePriorityList <: Iterable<ULocale> {
    static let D1: Float64 = 1.0

    static let languageSplitter = Pattern.compile("\\s*,\\s*")

    static let weightSplitter = Pattern.compile("\\s*(\\S*)\\s*;\\s*q\\s*=\\s*(\\S*)")

    let languagesAndWeights: Map<ULocale, Float64>

    public static func add(locales: Array<ULocale>): LocalePriorityList_Builder {
        return LocalePriorityList_Builder().add(locales)
    }

    public static func add(locale: ULocale, weight: Float64): LocalePriorityList_Builder {
        return LocalePriorityList_Builder().add(locale, weight)
    }

    public static func add(list: LocalePriorityList): LocalePriorityList_Builder {
        return LocalePriorityList_Builder(list)
    }

    public static func add(acceptLanguageString: String): LocalePriorityList_Builder {
        return LocalePriorityList_Builder().add(acceptLanguageString)
    }

    public func getWeight(locale: ULocale): Float64 {
        return languagesAndWeights.get(locale)
    }

    public func getULocales(): Set<ULocale> {
        return SetCollectionView<ULocale>(languagesAndWeights.keys())
    }

    public override func toString(): String {
        let result = StringBuilder()
        for (entry in languagesAndWeights.entrySet()) {
            let language = entry.getKey()
            let weight = entry.getValue()
            if (Int32(result.size) != 0) {
                result.append(", ")
            }
            result.append(language.asString())
            if (weight != 1.0) {
                result.append(";q=").append(weight)
            }
        }
        return result.toString()
    }

    public override func iterator(): Iterator<ULocale> {
        return SetCollectionView<ULocale>(languagesAndWeights.keys()).iterator()
    }

    public override func equals(o: Object): Bool {
        if (o.isNone()) {
            return false
        }
        if (refEq(this, o)) {
            return true
        }
        try {
            let that = o
            return // Мapping is present but failed: refEq(languagesAndWeights, that.languagesAndWeights)
        } catch (e: Exception) {
            return false
        }
    }

    public override func hashCode(): Int64 {
        return languagesAndWeights.hashCode()
    }

    init(languageToWeight: Map<ULocale, Float64>) {
        this.languagesAndWeights = languageToWeight
    }

    static var myDescendingDouble: Comparator = LocalePriorityList_1() as Comparator
}


public class LocalePriorityList_Builder {
    private var languageToWeight: Map<ULocale, Float64> = None

    private var built: LocalePriorityList

    private var hasWeights = false

    init() {
        languageToWeight = LinkedHashMap() as Map<ULocale, Float64>
    }

    init(list: LocalePriorityList) {
        built = list
        for (value in list.languagesAndWeights.values()) {
            let weight = value
            if (!(0.0 < weight && weight <= 1.0)) {
                throw AssertionError()
            }
            if (weight != 1.0) {
                hasWeights = true
                break
            }
        }
    }

    public func build(): LocalePriorityList {
        return build(false)
    }

    public func build(preserveWeights: Bool): LocalePriorityList {
        if (built.isSome()) {
            return built
        }
        let temp: Map<ULocale, Float64>
        if (hasWeights) {
            let weightToLanguages = TreeMap(LocalePriorityList.myDescendingDouble)
            for (entry in languageToWeight.entrySet()) {
                let lang = entry.getKey()
                let weight = entry.getValue()
                var s = weightToLanguages.get(weight)
                if (s.isNone()) {
                    weightToLanguages.put(weight, match (0) { case _ => s = LinkedList<ULocale>() as ArrayList<ULocale>; s })
                }
                s.append(lang)
            }
            if (Int32(weightToLanguages.size) <= 1) {
                temp = languageToWeight
                if (weightToLanguages.isEmpty() || weightToLanguages.firstKey() == 1.0) {
                    hasWeights = false
                }
            } else {
                temp = LinkedHashMap() as Map<ULocale, Float64>
                for (langEntry in weightToLanguages.entrySet()) {
                    let weight = if (preserveWeights) { langEntry.getKey() } else { LocalePriorityList.D1 }
                    for (lang in langEntry.getValue()) {
                        temp.put(lang, weight)
                    }
                }
            }
        } else {
            temp = languageToWeight
        }
        languageToWeight = None
        return match (0) { case _ => built = LocalePriorityList(Collections.unmodifiableMap(temp)); built }
    }

    public func add(list: LocalePriorityList): LocalePriorityList_Builder {
        for (entry in list.languagesAndWeights.entrySet()) {
            add(entry.getKey(), entry.getValue())
        }
        return this
    }

    public func add(locale: ULocale): LocalePriorityList_Builder {
        return add(locale, 1.0)
    }

    public func add(locales: Array<ULocale>): LocalePriorityList_Builder {
        for (languageCode in locales) {
            add(languageCode, 1.0)
        }
        return this
    }

    public func add(locale: ULocale, weight: Float64): LocalePriorityList_Builder {
        if (languageToWeight.isNone()) {
            languageToWeight = LinkedHashMap(built.languagesAndWeights) as Map<ULocale, Float64>
            built = None
        }
        if (languageToWeight.contains(locale)) {
            languageToWeight.remove(locale)
        }
        let value: Float64
        if (weight <= 0.0) {
            return this
        } else if (weight >= 1.0) {
            value = LocalePriorityList.D1
        } else {
            value = weight
            hasWeights = true
        }
        languageToWeight.put(locale, value)
        return this
    }

    public func add(acceptLanguageList: String): LocalePriorityList_Builder {
        let items = LocalePriorityList.languageSplitter.split(acceptLanguageList.trimAscii())
        let itemMatcher = LocalePriorityList.weightSplitter.matcher("")
        for (item in items) {
            if (itemMatcher.reset(item).matches()) {
                let language = ULocale(itemMatcher.group(1))
                let weight = parse<Float64>(itemMatcher.group(2))
                if (!(0.0 <= weight && weight <= 1.0)) {
                    throw IllegalArgumentException("Illegal weight, must be 0..1: " + weight.toString())
                }
                add(language, weight)
            } else if (Int32(item.size) != 0) {
                add(ULocale(item))
            }
        }
        return this
    }
}


class LocalePriorityList_1 <: Comparator {

    public override func compare(o1: Float64, o2: Float64): Int32 {
        let result = o1.append(o2.asString())
        return if (result > 0) { -1 } else { if (result < 0) { 1 } else { 0 } }
    }
}
