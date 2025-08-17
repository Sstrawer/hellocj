package icu4cj.text


public abstract class Collator <: Comparator & Freezable<Collator> & Cloneable {
    public static let PRIMARY = 0

    public static let SECONDARY = 1

    public static let TERTIARY = 2

    public static let QUATERNARY = 3

    public static let IDENTICAL = 15

    public static let FULL_DECOMPOSITION = IDENTICAL

    public static let NO_DECOMPOSITION = 16

    public static let CANONICAL_DECOMPOSITION = 17

    public override func equals(obj: Object): Bool {
        return refEq(this, obj) || (obj.isSome() && refEq(TypeInfo.of(this), TypeInfo.of(obj)))
    }

    public override func hashCode(): Int64 {
        return 0
    }

    private func checkNotFrozen(): Unit {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify frozen Collator")
        }
    }

    public func setStrength(newStrength: Int32): Unit {
        checkNotFrozen()
    }

    
    public func setStrength2(newStrength: Int32): Collator {
        setStrength(newStrength)
        return this
    }

    public func setDecomposition(decomposition: Int32): Unit {
        checkNotFrozen()
    }

    public func setReorderCodes(order: Array<Int32>): Unit {
        throw UnsupportedOperationException("Needs to be implemented by the subclass.")
    }

    public static func getInstance(): Collator {
        return getInstance(ULocale.getDefault())
    }

    public override func clone(): Object {
        return super.toString()
    }

    private static var shim: Collator_ServiceShim

    private static func getShim(): Collator_ServiceShim {
        if (shim.isNone()) {
            try {
                let cls: ClassTypeInfo = TypeInfo.get("com.ibm.icu.text.CollatorServiceShim") as ClassTypeInfo
                shim = cls.construct([0]) as Collator_ServiceShim
            } catch (e: MissingResourceException) {
                throw e
            } catch (e: Exception) {
                if (DEBUG) {
                    e.printStackTrace()
                }
                throw ICUException(e)
            }
        }
        return shim
    }

    private static func getYesOrNo(keyword: String, s: String): Bool {
        if (Collator_ASCII.equalIgnoreCase(s, "yes")) {
            return true
        }
        if (Collator_ASCII.equalIgnoreCase(s, "no")) {
            return false
        }
        throw IllegalArgumentException("illegal locale keyword=value: " + (keyword) + "=" + (s))
    }

    private static func getIntValue(keyword: String, s: String, values: Array<String>): Int32 {
        var i = 0
        while (i < Int32(values.size)) {
            if (Collator_ASCII.equalIgnoreCase(s, values[Int64(i)])) {
                return i
            }
            i++
        }
        throw IllegalArgumentException("illegal locale keyword=value: " + (keyword) + "=" + (s))
    }

    private static func getReorderCode(keyword: String, s: String): Int32 {
        return Collator_ReorderCodes.FIRST + getIntValue(keyword, s, ["space", "punct", "symbol", "currency", "digit"])
    }

    private static func setAttributesFromKeywords(loc: ULocale, coll: Collator, rbc: RuleBasedCollator): Unit {
        var value = loc.getKeywordValue("colHiraganaQuaternary")
        if (value.isSome()) {
            throw UnsupportedOperationException("locale keyword kh/colHiraganaQuaternary")
        }
        value = loc.getKeywordValue("variableTop")
        if (value.isSome()) {
            throw UnsupportedOperationException("locale keyword vt/variableTop")
        }
        value = loc.getKeywordValue("colStrength")
        if (value.isSome()) {
            let strength = getIntValue("colStrength", value, ["primary", "secondary", "tertiary", "quaternary", "identical"])
            coll.setStrength(if (strength <= Collator.QUATERNARY) { strength } else { Collator.IDENTICAL })
        }
        value = loc.getKeywordValue("colBackwards")
        if (value.isSome()) {
            if (rbc.isSome()) {
                rbc.setFrenchCollation(getYesOrNo("colBackwards", value))
            } else {
                throw UnsupportedOperationException("locale keyword kb/colBackwards only settable for RuleBasedCollator")
            }
        }
        value = loc.getKeywordValue("colCaseLevel")
        if (value.isSome()) {
            if (rbc.isSome()) {
                rbc.setCaseLevel(getYesOrNo("colCaseLevel", value))
            } else {
                throw UnsupportedOperationException("locale keyword kb/colBackwards only settable for RuleBasedCollator")
            }
        }
        value = loc.getKeywordValue("colCaseFirst")
        if (value.isSome()) {
            if (rbc.isSome()) {
                let cf = getIntValue("colCaseFirst", value, ["no", "lower", "upper"])
                if (cf == 0) {
                    rbc.setLowerCaseFirst(false)
                    rbc.setUpperCaseFirst(false)
                } else if (cf == 1) {
                    rbc.setLowerCaseFirst(true)
                } else {
                    rbc.setUpperCaseFirst(true)
                }
            } else {
                throw UnsupportedOperationException("locale keyword kf/colCaseFirst only settable for RuleBasedCollator")
            }
        }
        value = loc.getKeywordValue("colAlternate")
        if (value.isSome()) {
            if (rbc.isSome()) {
                rbc.setAlternateHandlingShifted(getIntValue("colAlternate", value, ["non-ignorable", "shifted"]) != 0)
            } else {
                throw UnsupportedOperationException("locale keyword ka/colAlternate only settable for RuleBasedCollator")
            }
        }
        value = loc.getKeywordValue("colNormalization")
        if (value.isSome()) {
            coll.setDecomposition(if (getYesOrNo("colNormalization", value)) { Collator.CANONICAL_DECOMPOSITION } else { Collator.NO_DECOMPOSITION })
        }
        value = loc.getKeywordValue("colNumeric")
        if (value.isSome()) {
            if (rbc.isSome()) {
                rbc.setNumericCollation(getYesOrNo("colNumeric", value))
            } else {
                throw UnsupportedOperationException("locale keyword kn/colNumeric only settable for RuleBasedCollator")
            }
        }
        value = loc.getKeywordValue("colReorder")
        if (value.isSome()) {
            let codes = Array<Int32>(Int64(UScript.CODE_LIMIT + Collator_ReorderCodes.LIMIT - Collator_ReorderCodes.FIRST)) { _ => 0 }
            var codesLength = 0
            var scriptNameStart = 0
            while (true) {
                if (codesLength == Int32(codes.size)) {
                    throw IllegalArgumentException("too many script codes for colReorder locale keyword: " + (value))
                }
                var limit = scriptNameStart
                while (limit < Int32(value.size) && Char(value[Int64(limit)]) != '-') {
                    limit++
                }
                let scriptName: String = value[Int64(scriptNameStart)..Int64(limit)]
                let code: Int32
                if (Int32(scriptName.size) == 4) {
                    code = UCharacter.getPropertyValueEnum(UProperty.SCRIPT, scriptName)
                } else {
                    code = getReorderCode("colReorder", scriptName)
                }
                codes[Int64(match (0) { case _ => codesLength++; codesLength - 1 })] = code
                if (limit == Int32(value.size)) {
                    break
                }
                scriptNameStart = limit + 1
            }
            if (codesLength == 0) {
                throw IllegalArgumentException("no script codes for colReorder locale keyword")
            }
            let args = Array<Int32>(Int64(codesLength)) { _ => 0 }
            arraycopy(codes, 0, args, 0, Int64(codesLength))
            coll.setReorderCodes(args)
        }
        value = loc.getKeywordValue("kv")
        if (value.isSome()) {
            coll.setMaxVariable(getReorderCode("kv", value))
        }
    }

    public static func getInstance(locale: ULocale): Collator {
        var templocale = locale
        if (templocale.isNone()) {
            templocale = ULocale.getDefault()
        }
        let coll = getShim().getInstance(templocale)
        if (!templocale.getName().equals(templocale.getBaseName())) {
            setAttributesFromKeywords(templocale, coll, if (checkOptionalIs<RuleBasedCollator, Collator>(coll)) { coll } else { None })
        }
        return coll
    }

    public static func getInstance(locale: Locale): Collator {
        return getInstance(ULocale.forLocale(locale))
    }

    public static func registerInstance(collator: Collator, locale: ULocale): Object {
        return getShim().registerInstance(collator, locale)
    }

    public static func registerFactory(factory: Collator_CollatorFactory): Object {
        return getShim().registerFactory(factory)
    }

    public static func unregister(registryKey: Object): Bool {
        if (shim.isNone()) {
            return false
        }
        return shim.unregister(registryKey)
    }

    public static func getAvailableLocales(): Array<Locale> {
        if (shim.isNone()) {
            return ICUResourceBundle.getAvailableLocales(ICUData.ICU_COLLATION_BASE_NAME, ICUResourceBundle.ICU_DATA_CLASS_LOADER)
        }
        return shim.getAvailableLocales()
    }

    public static func getAvailableULocales(): Array<ULocale> {
        if (shim.isNone()) {
            return ICUResourceBundle.getAvailableULocales(ICUData.ICU_COLLATION_BASE_NAME, ICUResourceBundle.ICU_DATA_CLASS_LOADER)
        }
        return shim.getAvailableULocales()
    }

    private static let KEYWORDS: Array<String> = ["collation"]

    private static let RESOURCE = "collations"

    private static let BASE = ICUData.ICU_COLLATION_BASE_NAME

    public static func getKeywords(): Array<String> {
        return KEYWORDS
    }

    public static func getKeywordValues(keyword: String): Array<String> {
        if (!keyword.equals(KEYWORDS[0])) {
            throw IllegalArgumentException("Invalid keyword: " + (keyword))
        }
        return ICUResourceBundle.getKeywordValues(BASE, RESOURCE)
    }

    public static func getKeywordValuesForLocale(key: String, locale: ULocale, commonlyUsed: Bool): Array<String> {
        let bundle = UResourceBundle.getBundleInstance(ICUData.ICU_COLLATION_BASE_NAME, locale)
        let sink = Collator_KeywordsSink()
        bundle.getAllItemsWithFallback("collations", sink)
        return sink.values.toArray(size))
    }

    public static func getFunctionalEquivalent(keyword: String, locID: ULocale, isAvailable: Array<Bool>): ULocale {
        return ICUResourceBundle.getFunctionalEquivalent(BASE, ICUResourceBundle.ICU_DATA_CLASS_LOADER, RESOURCE, keyword, locID, isAvailable, true)
    }

    public static func getFunctionalEquivalent(keyword: String, locID: ULocale): ULocale {
        return getFunctionalEquivalent(keyword, locID, None)
    }

    public static func getDisplayName(objectLocale: Locale, displayLocale: Locale): String {
        return getShim().getDisplayName(ULocale.forLocale(objectLocale), ULocale.forLocale(displayLocale))
    }

    public static func getDisplayName(objectLocale: ULocale, displayLocale: ULocale): String {
        return getShim().getDisplayName(objectLocale, displayLocale)
    }

    public static func getDisplayName(objectLocale: Locale): String {
        return getShim().getDisplayName(ULocale.forLocale(objectLocale), ULocale.getDefault(ULocale_Category.DISPLAY))
    }

    public static func getDisplayName(objectLocale: ULocale): String {
        return getShim().getDisplayName(objectLocale, ULocale.getDefault(ULocale_Category.DISPLAY))
    }

    public func getStrength(): Int32 {
        return TERTIARY
    }

    public func getDecomposition(): Int32 {
        return NO_DECOMPOSITION
    }

    public func equals(source: String, target: String): Bool {
        return (compare(source, target) == 0)
    }

    public func getTailoredSet(): UnicodeSet {
        return UnicodeSet(0, 1114111)
    }

    public func compare(source: String, target: String): Int32

    public override func compare(source: Object, target: Object): Int32 {
        return doCompare(source, target)
    }

    
    protected func doCompare(left: String, right: String): Int32 {
        return compare(toString(left), toString(right))
    }

    public func getCollationKey(source: String): CollationKey

    public func getRawCollationKey(source: String, key: RawCollationKey): RawCollationKey

    public func setMaxVariable(group: Int32): Collator {
        throw UnsupportedOperationException("Needs to be implemented by the subclass.")
    }

    public func getMaxVariable(): Int32 {
        return Collator_ReorderCodes.PUNCTUATION
    }

    
    public func setVariableTop(varTop: String): Int32

    public func getVariableTop(): Int32

    
    public func setVariableTop(varTop: Int32): Unit

    public func getVersion(): VersionInfo

    public func getUCAVersion(): VersionInfo

    public func getReorderCodes(): Array<Int32> {
        throw UnsupportedOperationException("Needs to be implemented by the subclass.")
    }

    public static func getEquivalentReorderCodes(reorderCode: Int32): Array<Int32> {
        let baseData = CollationRoot.getData()
        return baseData.getEquivalentScripts(reorderCode)
    }

    public override func isFrozen(): Bool {
        return false
    }

    public override func freeze(): Collator {
        throw UnsupportedOperationException("Needs to be implemented by the subclass.")
    }

    public override func cloneAsThawed(): Collator {
        throw UnsupportedOperationException("Needs to be implemented by the subclass.")
    }

    protected init() { }

    private static let DEBUG = ICUDebug.enabled("collator")

    public func getLocale(Type: ULocale_Type): ULocale {
        return ULocale.ROOT
    }

    public func setLocale(valid: ULocale, actual: ULocale): Unit { }
}


public interface Collator_ReorderCodes {
    let DEFAULT = -1

    let NONE = UScript.UNKNOWN

    let OTHERS = UScript.UNKNOWN

    let SPACE = 4096

    let FIRST = SPACE

    let PUNCTUATION = 4097

    let SYMBOL = 4098

    let CURRENCY = 4099

    let DIGIT = 4100

    
    let LIMIT = 4101
}

public abstract class Collator_CollatorFactory {
    public func visible(): Bool {
        return true
    }

    public func createCollator(loc: ULocale): Collator {
        return createCollator(loc.toLocale())
    }

    public func createCollator(loc: Locale): Collator {
        return createCollator(ULocale.forLocale(loc))
    }

    public func getDisplayName(objectLocale: Locale, displayLocale: Locale): String {
        return getDisplayName(ULocale.forLocale(objectLocale), ULocale.forLocale(displayLocale))
    }

    public func getDisplayName(objectLocale: ULocale, displayLocale: ULocale): String {
        if (visible()) {
            let supported = getSupportedLocaleIDs()
            let name = objectLocale.getBaseName()
            if (supported.contains(name)) {
                return objectLocale.getDisplayName(displayLocale)
            }
        }
        return None
    }

    public func getSupportedLocaleIDs(): Set<String>

    protected init() { }
}


abstract class Collator_ServiceShim {
    init() { }

    public func getInstance(l: ULocale): Collator

    public func registerInstance(c: Collator, l: ULocale): Object

    public func registerFactory(f: Collator_CollatorFactory): Object

    public func unregister(k: Object): Bool

    public func getAvailableLocales(): Array<Locale>

    public func getAvailableULocales(): Array<ULocale>

    public func getDisplayName(ol: ULocale, dl: ULocale): String
}


class Collator_ASCII {
    private init() { }

    static func equalIgnoreCase(left: String, right: String): Bool {
        let length = left.size
        if (length != right.size) {
            return false
        }
        var i = 0
        while (i < length) {
            let lc = left[i]
            let rc = right[i]
            if (lc == rc) {
                continue
            }
            if ('A' <= lc && lc <= 'Z') {
                if ((Int32(UInt32(lc)) + 32) == Int32(UInt32(rc))) {
                    continue
                }
            } else if ('A' <= rc && rc <= 'Z') {
                if ((Int32(UInt32(rc)) + 32) == Int32(UInt32(lc))) {
                    continue
                }
            }
            return false
            i++
        }
        return true
    }
}


class Collator_KeywordsSink <: UResource_Sink {
    init() {
        super()
    }

    var values: LinkedList<String> = LinkedList<String>()

    var hasDefault = false

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let collations = value.getTable()
        var i = 0
        while (collations.getKeyAndValue(i, key, value)) {
            let Type = value.getType()
            if (Type == UResourceBundle.STRING) {
                if (!hasDefault && key.contentEquals("default")) {
                    let defcoll = value.getString()
                    if (!defcoll.isEmpty()) {
                        values.append(defcoll)
                        values.prepend(defcoll)
                        hasDefault = true
                    }
                }
            } else if (Type == UResourceBundle.TABLE && !key.startsWith("private-")) {
                let collkey: String = key.toString()
                if (!values.contains(collkey)) {
                    values.append(collkey)
                }
            }
            i++
        }
    }
}
