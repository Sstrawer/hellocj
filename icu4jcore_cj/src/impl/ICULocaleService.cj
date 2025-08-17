package icu4cj.impl

public class ICULocaleService <: ICUService & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private var fallbackLocale: ULocale

    private var fallbackLocaleName: String

    public init() {
        super()
    }

    public init(name: String) {
        super(name)
    }

    public func get(locale: ULocale): Object {
        return get(locale, ICULocaleService_LocaleKey.KIND_ANY, None)
    }

    public func get(locale: ULocale, kind: Int32): Object {
        return get(locale, kind, None)
    }

    public func get(locale: ULocale, actualReturn: Array<ULocale>): Object {
        return get(locale, ICULocaleService_LocaleKey.KIND_ANY, actualReturn)
    }

    public func get(locale: ULocale, kind: Int32, actualReturn: Array<ULocale>): Object {
        let key = createKey(locale, kind)
        if (actualReturn.isNone()) {
            return getKey(key)
        }
        let temp = Array<String>(1)
        let result = getKey(key, temp)
        if (result.isSome()) {
            let n = indexOfWrap(temp[0].indexOf("/"))
            if (n >= 0) {
                temp[0] = temp[0][Int64(n + 1)..]
            }
            actualReturn[0] = ULocale(temp[0])
        }
        return result
    }

    public func registerObject(obj: Object, locale: ULocale): ICUService_Factory {
        return registerObject(obj, locale, ICULocaleService_LocaleKey.KIND_ANY, true)
    }

    public func registerObject(obj: Object, locale: ULocale, visible: Bool): ICUService_Factory {
        return registerObject(obj, locale, ICULocaleService_LocaleKey.KIND_ANY, visible)
    }

    public func registerObject(obj: Object, locale: ULocale, kind: Int32): ICUService_Factory {
        return registerObject(obj, locale, kind, true)
    }

    public func registerObject(obj: Object, locale: ULocale, kind: Int32, visible: Bool): ICUService_Factory {
        let factory: ICUService_Factory = ICULocaleService_SimpleLocaleKeyFactory(obj, locale, kind, visible)
        return registerFactory(factory)
    }

    public func getAvailableLocales(): Array<Locale> {
        let visIDs = getVisibleIDs()
        let locales = Array<Locale>(visIDs.size)
        var n = 0
        for (id in visIDs) {
            let loc = LocaleUtility.getLocaleFromName(id)
            locales[Int64(match (0) { case _ => n++; n - 1 })] = loc
        }
        return locales
    }

    public func getAvailableULocales(): Array<ULocale> {
        let visIDs = getVisibleIDs()
        let locales = Array<ULocale>(visIDs.size)
        var n = 0
        for (id in visIDs) {
            locales[Int64(match (0) { case _ => n++; n - 1 })] = ULocale(id)
        }
        return locales
    }

    public func validateFallbackLocale(): String {
        let loc = ULocale.getDefault()
        if (!refEq(loc, fallbackLocale)) {
            synchronized (getMonitorByObject(this)) {
                if (!refEq(loc, fallbackLocale)) {
                    fallbackLocaleName = loc.getBaseName()
                    clearServiceCache()
                    fallbackLocale = loc
                }
            }
        }
        return fallbackLocaleName
    }

    public override func createKey(id: String): ICUService_Key {
        return ICULocaleService_LocaleKey.createWithCanonicalFallback(id, validateFallbackLocale())
    }

    public func createKey(id: String, kind: Int32): ICUService_Key {
        return ICULocaleService_LocaleKey.createWithCanonicalFallback(id, validateFallbackLocale(), kind)
    }

    public func createKey(l: ULocale, kind: Int32): ICUService_Key {
        return ICULocaleService_LocaleKey.createWithCanonical(l, validateFallbackLocale(), kind)
    }
}


public class ICULocaleService_LocaleKey <: ICUService_Key {
    private var kind: Int32 = 0

    private var varstart: Int32 = 0

    private var primaryID: String

    private var fallbackID: String

    private var currentID: String

    public static let KIND_ANY = -1

    public static func createWithCanonicalFallback(primaryID: String, canonicalFallbackID: String): ICULocaleService_LocaleKey {
        return createWithCanonicalFallback(primaryID, canonicalFallbackID, KIND_ANY)
    }

    public static func createWithCanonicalFallback(primaryID: String, canonicalFallbackID: String, kind: Int32): ICULocaleService_LocaleKey {
        if (primaryID.isNone()) {
            return None
        }
        let canonicalPrimaryID = ULocale.getNameStatic(primaryID)
        return ICULocaleService_LocaleKey(primaryID, canonicalPrimaryID, canonicalFallbackID, kind)
    }

    public static func createWithCanonical(locale: ULocale, canonicalFallbackID: String, kind: Int32): ICULocaleService_LocaleKey {
        if (locale.isNone()) {
            return None
        }
        let canonicalPrimaryID = locale.getName()
        return ICULocaleService_LocaleKey(canonicalPrimaryID, canonicalPrimaryID, canonicalFallbackID, kind)
    }

    protected init(primaryID: String, canonicalPrimaryID: String, canonicalFallbackID: String, kind: Int32) {
        super(primaryID)
        this.kind = kind
        if (canonicalPrimaryID.isNone() || canonicalPrimaryID.equalsIgnoreCase("root")) {
            this.primaryID = ""
            this.fallbackID = None
        } else {
            let idx = indexOfWrap(canonicalPrimaryID.indexOf(UInt8(UInt32('@'))))
            if (idx == 4 && canonicalPrimaryID.regionMatches(true, 0, "root", 0, 4)) {
                this.primaryID = canonicalPrimaryID[4..]
                this.varstart = 0
                this.fallbackID = None
            } else {
                this.primaryID = canonicalPrimaryID
                this.varstart = idx
                if (canonicalFallbackID.isNone() || this.primaryID.equals(canonicalFallbackID)) {
                    this.fallbackID = ""
                } else {
                    this.fallbackID = canonicalFallbackID
                }
            }
        }
        this.currentID = if (varstart == -1) { this.primaryID } else { this.primaryID[0..Int64(varstart)] }
    }

    public func prefix(): String {
        return if (kind == KIND_ANY) { None } else { kindMethod().toString() }
    }

    public func kindMethod(): Int32 {
        return kind
    }

    public override func canonicalID(): String {
        return primaryID
    }

    public override func currentIDMethod(): String {
        return currentID
    }

    public override func currentDescriptor(): String {
        var result = currentIDMethod()
        if (result.isSome()) {
            let buf = StringBuilder()
            if (kind != KIND_ANY) {
                buf.append(prefix())
            }
            buf.append('/')
            buf.append(result)
            if (varstart != -1) {
                buf.append(primaryID[Int64(varstart)..primaryID.size])
            }
            result = buf.toString()
        }
        return result
    }

    public func canonicalLocale(): ULocale {
        return ULocale(primaryID)
    }

    public func currentLocale(): ULocale {
        if (varstart == -1) {
            return ULocale(currentID)
        } else {
            return ULocale((currentID) + primaryID[Int64(varstart)..])
        }
    }

    public override func fallback(): Bool {
        var x = indexOfWrap(currentID.lastIndexOf(UInt8(UInt32('_'))))
        if (x != -1) {
            while (match (0) { case _ => x--; x } >= 0 && Char(currentID[Int64(x)]) == '_') { }
            currentID = currentID[0..Int64(x + 1)]
            return true
        }
        if (fallbackID.isSome()) {
            currentID = fallbackID
            if (Int32(fallbackID.size) == 0) {
                fallbackID = None
            } else {
                fallbackID = ""
            }
            return true
        }
        currentID = None
        return false
    }

    public override func isFallbackOf(id: String): Bool {
        return LocaleUtility.isFallbackOf(canonicalID(), id)
    }
}


public abstract class ICULocaleService_LocaleKeyFactory <: ICUService_Factory {
    protected let name: String

    protected let visible: Bool

    public static let VISIBLE = true

    public static let INVISIBLE = false

    protected init(visible: Bool) {
        this.visible = visible
        this.name = None
    }

    protected init(visible: Bool, name: String) {
        this.visible = visible
        this.name = name
    }

    public override func create(key: ICUService_Key, service: ICUService): Object {
        if (handlesKey(key)) {
            let lkey = key
            let kind = lkey.kindMethod()
            let uloc = lkey.currentLocale()
            return handleCreate(uloc, kind, service)
        } else { }
        return None
    }

    protected func handlesKey(key: ICUService_Key): Bool {
        if (key.isSome()) {
            let id = key.currentID()
            let supported = getSupportedIDs()
            return supported.contains(id)
        }
        return false
    }

    public override func updateVisibleIDs(result: Map<String, ICUService_Factory>): Unit {
        let cache = getSupportedIDs()
        for (id in cache) {
            if (visible) {
                result.put(id, this)
            } else {
                result.remove(id)
            }
        }
    }

    public override func getDisplayName(id: String, locale: ULocale): String {
        if (locale.isNone()) {
            return id
        }
        let loc = ULocale(id)
        return loc.getDisplayName(locale)
    }

    protected func handleCreate(loc: ULocale, kind: Int32, service: ICUService): Object {
        return None
    }

    protected func isSupportedID(id: String): Bool {
        return getSupportedIDs().contains(id)
    }

    protected func getSupportedIDs(): Set<String> {
        return Collections.emptySet<<--> -->()
    }

    public override func toString(): String {
        let buf = StringBuilder(toString(super))
        if (name.isSome()) {
            buf.append(", name: ")
            buf.append(name)
        }
        buf.append(", visible: ")
        buf.append(visible)
        return buf.toString()
    }
}


public class ICULocaleService_SimpleLocaleKeyFactory <: ICULocaleService_LocaleKeyFactory {
    private let obj: Object

    private let id: String

    private let kind: Int32

    public init(obj: Object, locale: ULocale, kind: Int32, visible: Bool) {
        this(obj, locale, kind, visible, None)
    }

    public init(obj: Object, locale: ULocale, kind: Int32, visible: Bool, name: String) {
        super(visible, name)
        this.obj = obj
        this.id = locale.getBaseName()
        this.kind = kind
    }

    public override func create(key: ICUService_Key, service: ICUService): Object {
        if (!(checkOptionalIs<ICULocaleService_LocaleKey, ICUService_Key>(key))) {
            return None
        }
        let lkey = key
        if (kind != ICULocaleService_LocaleKey.KIND_ANY && kind != lkey.kindMethod()) {
            return None
        }
        if (!id.equals(lkey.currentIDMethod())) {
            return None
        }
        return obj
    }

    override protected func isSupportedID(idToCheck: String): Bool {
        return this.id.equals(idToCheck)
    }

    public override func updateVisibleIDs(result: Map<String, ICUService_Factory>): Unit {
        if (visible) {
            result.put(id, this)
        } else {
            result.remove(id)
        }
    }

    public override func toString(): String {
        let buf = StringBuilder(super.toString())
        buf.append(", id: ")
        buf.append(id)
        buf.append(", kind: ")
        buf.append(kind)
        return buf.toString()
    }
}


public class ICULocaleService_ICUResourceBundleFactory <: ICULocaleService_LocaleKeyFactory {
    protected let bundleName: String

    public init() {
        this(ICUData.ICU_BASE_NAME)
    }

    public init(bundleName: String) {
        super(true)
        this.bundleName = bundleName
    }

    override protected func getSupportedIDs(): Set<String> {
        return ICUResourceBundle.getFullLocaleNameSet(bundleName, loader())
    }

    public override func updateVisibleIDs(result: Map<String, ICUService_Factory>): Unit {
        let visibleIDs = ICUResourceBundle.getAvailableLocaleNameSet(bundleName, loader())
        for (id in visibleIDs) {
            result.put(id, this)
        }
    }

    override protected func handleCreate(loc: ULocale, kind: Int32, service: ICUService): Object {
        return ICUResourceBundle.getBundleInstance(bundleName, loc, loader())
    }

    protected func loader(): ClassLoader {
        return ClassLoaderUtil.getClassLoader(TypeInfo.of(this))
    }

    public override func toString(): String {
        return super.toString() + ", bundle: " + (bundleName)
    }
}
