package icu4cj.util


public abstract class UResourceBundle <: ResourceBundle {
    public static func getBundleInstance(baseName: String, localeName: String): UResourceBundle {
        return getBundleInstance(baseName, localeName, ICUResourceBundle.ICU_DATA_CLASS_LOADER, false)
    }

    public static func getBundleInstance(baseName: String, localeName: String, root: ClassLoader): UResourceBundle {
        return getBundleInstance(baseName, localeName, root, false)
    }

    protected static func getBundleInstance(baseName: String, localeName: String, root: ClassLoader, disableFallback: Bool): UResourceBundle {
        return instantiateBundle(baseName, localeName, root, disableFallback)
    }

    public init() {
        ResourceBundle()
    }

    public static func getBundleInstance(locale: ULocale): UResourceBundle {
        var templocale = locale
        if (templocale.isNone()) {
            templocale = ULocale.getDefault()
        }
        return getBundleInstance(ICUData.ICU_BASE_NAME, templocale.getBaseName(), ICUResourceBundle.ICU_DATA_CLASS_LOADER, false)
    }

    public static func getBundleInstance(baseName: String): UResourceBundle {
        var tempbaseName = baseName
        if (tempbaseName.isNone()) {
            tempbaseName = ICUData.ICU_BASE_NAME
        }
        let uloc = ULocale.getDefault()
        return getBundleInstance(tempbaseName, uloc.getBaseName(), ICUResourceBundle.ICU_DATA_CLASS_LOADER, false)
    }

    public static func getBundleInstance(baseName: String, locale: Locale): UResourceBundle {
        var tempbaseName = baseName
        if (tempbaseName.isNone()) {
            tempbaseName = ICUData.ICU_BASE_NAME
        }
        let uloc = if (locale.isNone()) { ULocale.getDefault() } else { ULocale.forLocale(locale) }
        return getBundleInstance(tempbaseName, uloc.getBaseName(), ICUResourceBundle.ICU_DATA_CLASS_LOADER, false)
    }

    public static func getBundleInstance(baseName: String, locale: ULocale): UResourceBundle {
        var tempbaseName = baseName
        var templocale = locale
        if (tempbaseName.isNone()) {
            tempbaseName = ICUData.ICU_BASE_NAME
        }
        if (templocale.isNone()) {
            templocale = ULocale.getDefault()
        }
        return getBundleInstance(tempbaseName, templocale.getBaseName(), ICUResourceBundle.ICU_DATA_CLASS_LOADER, false)
    }

    public static func getBundleInstance(baseName: String, locale: Locale, loader: ClassLoader): UResourceBundle {
        var tempbaseName = baseName
        if (tempbaseName.isNone()) {
            tempbaseName = ICUData.ICU_BASE_NAME
        }
        let uloc = if (locale.isNone()) { ULocale.getDefault() } else { ULocale.forLocale(locale) }
        return getBundleInstance(tempbaseName, uloc.getBaseName(), loader, false)
    }

    public static func getBundleInstance(baseName: String, locale: ULocale, loader: ClassLoader): UResourceBundle {
        var tempbaseName = baseName
        var templocale = locale
        if (tempbaseName.isNone()) {
            tempbaseName = ICUData.ICU_BASE_NAME
        }
        if (templocale.isNone()) {
            templocale = ULocale.getDefault()
        }
        return getBundleInstance(tempbaseName, templocale.getBaseName(), loader, false)
    }

    public func getULocale(): ULocale

    protected func getLocaleID(): String

    protected func getBaseName(): String

    protected func getParent(): UResourceBundle

    public override func getLocale(): Locale {
        return getULocale().toLocale()
    }

    private static var ROOT_CACHE: Map<String, UResourceBundle_RootType> = ConcurrentHashMap() as Map<String, UResourceBundle_RootType>

    private static func getRootType(baseName: String, root: ClassLoader): UResourceBundle_RootType {
        var rootType = ROOT_CACHE.get(baseName)
        if (rootType.isNone()) {
            let rootLocale: String = if (indexOfWrap(baseName.indexOf(UInt8(UInt32('.')))) == -1) { "root" } else { "" }
            try {
                ICUResourceBundle.getBundleInstance(baseName, rootLocale, root, true)
                rootType = UResourceBundle_RootType.ICU
            } catch (ex: MissingResourceException) {
                try {
                    ResourceBundleWrapper.getBundleInstance(baseName, rootLocale, root, true)
                    rootType = UResourceBundle_RootType.JAVA
                } catch (e: MissingResourceException) {
                    rootType = UResourceBundle_RootType.MISSING
                }
            }
            ROOT_CACHE.put(baseName, rootType)
        }
        return rootType
    }

    private static func setRootType(baseName: String, rootType: UResourceBundle_RootType): Unit {
        ROOT_CACHE.put(baseName, rootType)
    }

    protected static func instantiateBundle(baseName: String, localeName: String, root: ClassLoader, disableFallback: Bool): UResourceBundle {
        let rootType = getRootType(baseName, root)
        match (rootType) {
            case UResourceBundle_RootType.ICU => return ICUResourceBundle.getBundleInstance(baseName, localeName, root, disableFallback)
            case UResourceBundle_RootType.JAVA => return ResourceBundleWrapper.getBundleInstance(baseName, localeName, root, disableFallback)
            case UResourceBundle_RootType.MISSING =>
                var b: UResourceBundle
                try {
                    b = ICUResourceBundle.getBundleInstance(baseName, localeName, root, disableFallback)
                    setRootType(baseName, UResourceBundle_RootType.ICU)
                } catch (ex: MissingResourceException) {
                    b = ResourceBundleWrapper.getBundleInstance(baseName, localeName, root, disableFallback)
                    setRootType(baseName, UResourceBundle_RootType.JAVA)
                }
                return b
            case _ =>
                var b: UResourceBundle
                try {
                    b = ICUResourceBundle.getBundleInstance(baseName, localeName, root, disableFallback)
                    setRootType(baseName, UResourceBundle_RootType.ICU)
                } catch (ex: MissingResourceException) {
                    b = ResourceBundleWrapper.getBundleInstance(baseName, localeName, root, disableFallback)
                    setRootType(baseName, UResourceBundle_RootType.JAVA)
                }
                return b
        }
    }

    public func getBinary(): ByteArrayStream {
        throw UResourceTypeMismatchException("")
    }

    public func getString(): String {
        throw UResourceTypeMismatchException("")
    }

    public func getStringArray(): Array<String> {
        throw UResourceTypeMismatchException("")
    }

    public func getBinary(ba: Array<UInt8>): Array<UInt8> {
        throw UResourceTypeMismatchException("")
    }

    public func getIntVector(): Array<Int32> {
        throw UResourceTypeMismatchException("")
    }

    public func getInt(): Int32 {
        throw UResourceTypeMismatchException("")
    }

    public func getUInt(): Int32 {
        throw UResourceTypeMismatchException("")
    }

    public func get(aKey: String): UResourceBundle {
        let obj = findTopLevel(aKey)
        if (obj.isNone()) {
            let fullName = ICUResourceBundleReader.getFullName(getBaseName(), getLocaleID())
            throw MissingResourceException("Can't find resource for bundle " + (fullName) + ", key " + (aKey), TypeInfo.of(this).name, aKey)
        }
        return obj
    }

    
    protected func findTopLevel(aKey: String): UResourceBundle {
        var res: UResourceBundle = this
        while (res.isSome()) {
            let obj = res.handleGet(aKey, None, this)
            if (obj.isSome()) {
                return obj
            }
            res = res.getParent()
        }
        return None
    }

    public func getString(index: Int32): String {
        let temp = get(index)
        if (temp.getType() == STRING) {
            return temp.getString()
        }
        throw UResourceTypeMismatchException("")
    }

    public func get(index: Int32): UResourceBundle {
        var obj = handleGet(index, None, this)
        if (obj.isNone()) {
            obj = getParent()
            if (obj.isSome()) {
                obj = obj.get(index)
            }
            if (obj.isNone()) {
                throw MissingResourceException("Can't find resource for bundle " + TypeInfo.of(this).name + ", key " + (getKey()), TypeInfo.of(this).name, getKey())
            }
        }
        return obj
    }

    
    protected func findTopLevel(index: Int32): UResourceBundle {
        var res: UResourceBundle = this
        while (res.isSome()) {
            let obj = res.handleGet(index, None, this)
            if (obj.isSome()) {
                return obj
            }
            res = res.getParent()
        }
        return None
    }

    public override func getKeys(): Enumeration<String> {
        return Collections.enumeration(keySet())
    }

    
    public override func keySet(): Set<String> {
        var keys: Set<String>
        var icurb: ICUResourceBundle
        if (isTopLevelResource() && checkOptionalIs<ICUResourceBundle, UResourceBundle>(this)) {
            icurb = this as ICUResourceBundle
            keys = icurb.getTopLevelKeySet()
        }
        if (keys.isNone()) {
            if (isTopLevelResource()) {
                let newKeySet: TreeSet
                if (parent.isNone()) {
                    newKeySet = TreeSet()
                } else if (checkOptionalIs<UResourceBundle, ResourceBundle>(parent)) {
                    newKeySet = TreeSet(parent.keySet())
                } else {
                    newKeySet = TreeSet()
                    let parentKeys = parent.getKeys()
                    while (parentKeys.hasMoreElements()) {
                        newKeySet.put(parentKeys.nextElement())
                    }
                }
                newKeySet.putAll(handleKeySet())
                keys = Collections.unmodifiableSet(newKeySet)
                if (icurb.isSome()) {
                    icurb.setTopLevelKeySet(keys)
                }
            } else {
                return handleKeySet()
            }
        }
        return keys
    }

    
    override protected func handleKeySet(): Set<String> {
        return Collections.emptySet<<--> -->()
    }

    public func getSize(): Int32 {
        return 1
    }

    public func getType(): Int32 {
        return NONE
    }

    public func getVersion(): VersionInfo {
        return None
    }

    public func getIterator(): UResourceBundleIterator {
        return UResourceBundleIterator(this)
    }

    public func getKey(): String {
        return None
    }

    public static let NONE = -1

    public static let STRING = 0

    public static let BINARY = 1

    public static let TABLE = 2

    public static let INT = 7

    public static let ARRAY = 8

    public static let INT_VECTOR = 14

    protected func handleGet(aKey: String, aliasesVisited: HashMap<String, String>, requested: UResourceBundle): UResourceBundle {
        return None
    }

    protected func handleGet(index: Int32, aliasesVisited: HashMap<String, String>, requested: UResourceBundle): UResourceBundle {
        return None
    }

    protected func handleGetStringArray(): Array<String> {
        return None
    }

    protected func handleGetKeys(): Enumeration<String> {
        return None
    }

    override protected func handleGetObject(aKey: String): Object {
        return handleGetObjectImpl(aKey, this)
    }

    private func handleGetObjectImpl(aKey: String, requested: UResourceBundle): Object {
        var obj = resolveObject(aKey, requested)
        if (obj.isNone()) {
            let parentBundle = getParent()
            if (parentBundle.isSome()) {
                obj = parentBundle.handleGetObjectImpl(aKey, requested)
            }
            if (obj.isNone()) {
                throw MissingResourceException("Can't find resource for bundle " + TypeInfo.of(this).name + ", key " + (aKey), TypeInfo.of(this).name, aKey)
            }
        }
        return obj
    }

    private func resolveObject(aKey: String, requested: UResourceBundle): Object {
        if (getType() == STRING) {
            return getString()
        }
        let obj = handleGet(aKey, None, requested)
        if (obj.isSome()) {
            if (obj.getType() == STRING) {
                return obj.getString()
            }
            try {
                if (obj.getType() == ARRAY) {
                    return obj.handleGetStringArray()
                }
            } catch (ex: UResourceTypeMismatchException) {
                return obj
            }
        }
        return obj
    }

    
    protected func isTopLevelResource(): Bool {
        return true
    }
}


class UResourceBundle_RootType <: Enum<UResourceBundle_RootType> {
    public static let MISSING = UResourceBundle_RootType("MISSING", 0)

    public static let ICU = UResourceBundle_RootType("ICU", 1)

    public static let JAVA = UResourceBundle_RootType("JAVA", 2)

    private static func _values(): Array<UResourceBundle_RootType> {
        return [UResourceBundle_RootType.MISSING, UResourceBundle_RootType.ICU, UResourceBundle_RootType.JAVA]
    }

    private static let _VALUES = UResourceBundle_RootType._values()

    public static func values(): Array<UResourceBundle_RootType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): UResourceBundle_RootType {
        return (TypeInfo.of<UResourceBundle_RootType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as UResourceBundle_RootType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
