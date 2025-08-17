package icu4cj.text

public class NumberingSystem {
    private static let OTHER_NS_KEYWORDS: Array<String> = ["native", "traditional", "finance"]

    public static let LATIN = lookupInstanceByName("latn")

    public init() {
        radix = 10
        algorithmic = false
        desc = "0123456789"
        name = "latn"
    }

    public static func getInstance(radix_in: Int32, isAlgorithmic_in: Bool, desc_in: String): NumberingSystem {
        return getInstance(None, radix_in, isAlgorithmic_in, desc_in)
    }

    private static func getInstance(name_in: String, radix_in: Int32, isAlgorithmic_in: Bool, desc_in: String): NumberingSystem {
        if (radix_in < 2) {
            throw IllegalArgumentException("Invalid radix for numbering system")
        }
        if (!isAlgorithmic_in) {
            if (desc_in.codePointCount(0, Int32(desc_in.size)) != radix_in || !isValidDigitString(desc_in)) {
                throw IllegalArgumentException("Invalid digit string for numbering system")
            }
        }
        let ns = NumberingSystem()
        ns.radix = radix_in
        ns.algorithmic = isAlgorithmic_in
        ns.desc = desc_in
        ns.name = name_in
        return ns
    }

    public static func getInstance(inLocale: Locale): NumberingSystem {
        return getInstance(ULocale.forLocale(inLocale))
    }

    public static func getInstance(locale: ULocale): NumberingSystem {
        var nsResolved = true
        var numbersKeyword = locale.getKeywordValue("numbers")
        if (numbersKeyword.isSome()) {
            for (keyword in OTHER_NS_KEYWORDS) {
                if (numbersKeyword.equals(keyword)) {
                    nsResolved = false
                    break
                }
            }
        } else {
            numbersKeyword = "default"
            nsResolved = false
        }
        if (nsResolved) {
            let ns = getInstanceByName(numbersKeyword)
            if (ns.isSome()) {
                return ns
            }
            numbersKeyword = "default"
        }
        let baseName = locale.getBaseName()
        let key: String = (baseName) + "@numbers=" + (numbersKeyword)
        let localeLookupData = NumberingSystem_LocaleLookupData(locale, numbersKeyword)
        return cachedLocaleData.getInstance(key, localeLookupData)
    }

    static func lookupInstanceByLocale(localeLookupData: NumberingSystem_LocaleLookupData): NumberingSystem {
        let locale = localeLookupData.locale
        var rb: ICUResourceBundle
        try {
            rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, locale)
            rb = rb.getWithFallback("NumberElements")
        } catch (ex: MissingResourceException) {
            return NumberingSystem()
        }
        var numbersKeyword = localeLookupData.numbersKeyword
        var resolvedNumberingSystem: String
        while (true) {
            try {
                resolvedNumberingSystem = rb.getStringWithFallback(numbersKeyword)
                break
            } catch (ex: MissingResourceException) {
                if (numbersKeyword == "native" || numbersKeyword == "finance") {
                    numbersKeyword = "default"
                } else if (numbersKeyword == "traditional") {
                    numbersKeyword = "native"
                } else {
                    break
                }
            }
        }
        var ns: NumberingSystem
        if (resolvedNumberingSystem.isSome()) {
            ns = getInstanceByName(resolvedNumberingSystem)
        }
        if (ns.isNone()) {
            ns = NumberingSystem()
        }
        return ns
    }

    public static func getInstance(): NumberingSystem {
        return getInstance(ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public static func getInstanceByName(name: String): NumberingSystem {
        return cachedStringData.getInstance(name, None)
    }

    static func lookupInstanceByName(name: String): NumberingSystem {
        let radix: Int32
        let isAlgorithmic: Bool
        let description: String
        try {
            let numberingSystemsInfo = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "numberingSystems")
            let nsCurrent = numberingSystemsInfo.get("numberingSystems")
            let nsTop = nsCurrent.get(name)
            description = nsTop.getString("desc")
            let nsRadixBundle = nsTop.get("radix")
            let nsAlgBundle = nsTop.get("algorithmic")
            radix = nsRadixBundle.getInt()
            let algorithmic = nsAlgBundle.getInt()
            isAlgorithmic = (algorithmic == 1)
        } catch (ex: MissingResourceException) {
            return None
        }
        return getInstance(name, radix, isAlgorithmic, description)
    }

    public static func getAvailableNames(): Array<String> {
        let numberingSystemsInfo = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "numberingSystems")
        let nsCurrent = numberingSystemsInfo.get("numberingSystems")
        var temp: UResourceBundle
        var nsName: String
        let output = ArrayList<String>()
        let it = nsCurrent.getIterator()
        while (it.hasNext()) {
            temp = it.next()
            nsName = temp.getKey()
            output.append(nsName)
        }
        return output.toArray(size))
    }

    public static func isValidDigitString(str: String): Bool {
        let numCodepoints = str.codePointCount(0, Int32(str.size))
        return (numCodepoints == 10)
    }

    public func getRadix(): Int32 {
        return radix
    }

    public func getDescription(): String {
        return desc
    }

    public func getName(): String {
        return name
    }

    public func isAlgorithmic(): Bool {
        return algorithmic
    }

    private var desc: String

    private var radix: Int32 = 0

    private var algorithmic: Bool = false

    private var name: String

    private static var cachedLocaleData: CacheBase<String, NumberingSystem, NumberingSystem_LocaleLookupData> = NumberingSystem_1()

    private static var cachedStringData: CacheBase<String, NumberingSystem, Void> = NumberingSystem_2()
}


class NumberingSystem_LocaleLookupData {
    public let locale: ULocale

    public let numbersKeyword: String

    init(locale: ULocale, numbersKeyword: String) {
        this.locale = locale
        this.numbersKeyword = numbersKeyword
    }
}


class NumberingSystem_1 <: SoftCache<String, NumberingSystem, NumberingSystem_LocaleLookupData> {
    init() {
        super()
    }

    override protected func createInstance(key: String, localeLookupData: NumberingSystem_LocaleLookupData): NumberingSystem {
        return NumberingSystem.lookupInstanceByLocale(localeLookupData)
    }
}


class NumberingSystem_2 <: SoftCache<String, NumberingSystem, Void> {
    init() {
        super()
    }

    override protected func createInstance(key: String, unused: Void): NumberingSystem {
        return NumberingSystem.lookupInstanceByName(key)
    }
}
