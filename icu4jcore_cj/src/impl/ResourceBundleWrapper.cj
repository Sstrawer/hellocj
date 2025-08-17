package icu4cj.impl


public class ResourceBundleWrapper <: UResourceBundle {
    private var bundle: ResourceBundle = None

    var localeID: String

    var baseName: String

    private var keys: ArrayList<String>

    private static var BUNDLE_CACHE: CacheBase<String, ResourceBundleWrapper, ResourceBundleWrapper_Loader> = ResourceBundleWrapper_1()

    init(bundle: ResourceBundle) {
        super()
        this.bundle = bundle
    }

    override protected func handleGetObject(aKey: String): Object {
        var current: ResourceBundleWrapper = this
        var obj: Object
        while (current.isSome()) {
            try {
                obj = current.bundle.getObject(aKey)
                break
            } catch (ex: MissingResourceException) {
                current = current.getParent()
            }
        }
        if (obj.isNone()) {
            throw MissingResourceException("Can't find resource for bundle " + (baseName) + ", key " + (aKey), TypeInfo.of(this).name, aKey)
        }
        return obj
    }

    public override func getKeys(): Enumeration<String> {
        return Collections.enumeration(keys)
    }

    public func initKeysVector(): Unit {
        var current: ResourceBundleWrapper = this
        keys = ArrayList<String>()
        while (current.isSome()) {
            let e = current.bundle.getKeys()
            while (e.hasMoreElements()) {
                let elem = e.nextElement()
                if (!keys.contains(elem)) {
                    keys.append(elem)
                }
            }
            current = current.getParent()
        }
    }

    override protected func getLocaleID(): String {
        return localeID
    }

    override protected func getBaseName(): String {
        return TypeInfo.of(bundle).name.replace('.'.toString(), '/'.toString())
    }

    public override func getULocale(): ULocale {
        return ULocale(localeID)
    }

    public override func getParent(): UResourceBundle {
        return parent
    }

    static let DEBUG = ICUDebug.enabled("resourceBundleWrapper")

    public static func getBundleInstance(baseName: String, localeID: String, root: ClassLoader, disableFallback: Bool): ResourceBundleWrapper {
        var temproot = root
        if (temproot.isNone()) {
            temproot = ClassLoaderUtil.getClassLoader()
        }
        let b: ResourceBundleWrapper
        if (disableFallback) {
            b = instantiateBundle(baseName, localeID, None, temproot, disableFallback)
        } else {
            b = instantiateBundle(baseName, localeID, ULocale.getDefault().getBaseName(), temproot, disableFallback)
        }
        if (b.isNone()) {
            var separator: String = "_"
            if (indexOfWrap(baseName.indexOf(UInt8(UInt32('/')))) >= 0) {
                separator = "/"
            }
            throw MissingResourceException("Could not find the bundle " + (baseName) + (separator) + (localeID), "", "")
        }
        return b
    }

    static func localeIDStartsWithLangSubtag(localeID: String, lang: String): Bool {
        return localeID.startsWith(lang) && (Int32(localeID.size) == Int32(lang.size) || Char(localeID[lang.size]) == '_')
    }

    static func instantiateBundle(baseName: String, localeID: String, defaultID: String, root: ClassLoader, disableFallback: Bool): ResourceBundleWrapper {
        let name = if (localeID.isEmpty()) { baseName } else { Some((baseName) + '_'.toString() + (localeID)) }
        let cacheKey = if (disableFallback) { name } else { Some((name) + '#'.toString() + (defaultID)) }
        return BUNDLE_CACHE.getInstance(cacheKey, ResourceBundleWrapper_2(localeID, baseName, defaultID, root, disableFallback, name))
    }
}


abstract class ResourceBundleWrapper_Loader {

    public func load(): ResourceBundleWrapper
}


class ResourceBundleWrapper_1 <: SoftCache<String, ResourceBundleWrapper, ResourceBundleWrapper_Loader> {
    init() {
        super()
    }

    override protected func createInstance(unusedKey: String, loader: ResourceBundleWrapper_Loader): ResourceBundleWrapper {
        return loader.load()
    }
}


class ResourceBundleWrapper_2 <: ResourceBundleWrapper_Loader {
    let val_name: String

    let val_disableFallback: Bool

    let val_root: ClassLoader

    let val_defaultID: String

    let val_baseName: String

    let val_localeID: String

    init(val_localeID: String, val_baseName: String, val_defaultID: String, val_root: ClassLoader, val_disableFallback: Bool, val_name: String) {
        super()
        this.val_localeID = val_localeID
        this.val_baseName = val_baseName
        this.val_defaultID = val_defaultID
        this.val_root = val_root
        this.val_disableFallback = val_disableFallback
        this.val_name = val_name
    }

    public override func load(): ResourceBundleWrapper {
        var parent: ResourceBundleWrapper
        let i = indexOfWrap(val_localeID.lastIndexOf(UInt8(UInt32('_'))))
        var loadFromProperties = false
        var parentIsRoot = false
        if (i != -1) {
            let locName: String = val_localeID[0..Int64(i)]
            parent = ResourceBundleWrapper.instantiateBundle(val_baseName, locName, val_defaultID, val_root, val_disableFallback)
        } else if (!val_localeID.isEmpty()) {
            parent = ResourceBundleWrapper.instantiateBundle(val_baseName, "", val_defaultID, val_root, val_disableFallback)
            parentIsRoot = true
        }
        var b: ResourceBundleWrapper
        try {
            let cls = val_root.loadClass(val_name).asSubclass<<--> -->(TypeInfo.of<ResourceBundle>() as ClassTypeInfo)
            let bx: ResourceBundle = cls.construct([0]) as ResourceBundle
            b = ResourceBundleWrapper(bx)
            if (parent.isSome()) {
                b.setParent(parent)
            }
            b.baseName = val_baseName
            b.localeID = val_localeID
        } catch (e: ClassNotFoundException) {
            loadFromProperties = true
        } catch (e: NoClassDefFoundError) {
            loadFromProperties = true
        } catch (e: Exception) {
            if (ResourceBundleWrapper.DEBUG) {
                println("failure")
            }
            if (ResourceBundleWrapper.DEBUG) {
                println(e.toString())
            }
        }
        if (loadFromProperties) {
            try {
                let resName: String = val_name.replace('.'.toString(), '/'.toString()) + ".properties"
                var stream = AccessController.doPrivileged(ResourceBundleWrapper_2_1(this, resName) as PrivilegedAction)
                if (stream.isSome()) {
                    stream = BufferedInputStream(stream) as InputStream
                    try {
                        b = ResourceBundleWrapper(PropertyResourceBundle(stream))
                        if (parent.isSome()) {
                            b.setParent(parent)
                        }
                        b.baseName = val_baseName
                        b.localeID = val_localeID
                    } catch (ex: Exception) { } finally {
                        try {
                        } catch (ex: Exception) { }
                    }
                }
                if (b.isNone() && !val_disableFallback && !val_localeID.isEmpty() && indexOfWrap(val_localeID.indexOf(UInt8(UInt32('_')))) < 0 && !ResourceBundleWrapper.localeIDStartsWithLangSubtag(val_defaultID, val_localeID)) {
                    b = ResourceBundleWrapper.instantiateBundle(val_baseName, val_defaultID, val_defaultID, val_root, val_disableFallback)
                }
                if (b.isNone() && (!parentIsRoot || !val_disableFallback)) {
                    b = parent
                }
            } catch (e: Exception) {
                if (ResourceBundleWrapper.DEBUG) {
                    println("failure")
                }
                if (ResourceBundleWrapper.DEBUG) {
                    println(e.toString())
                }
            }
        }
        if (b.isSome()) {
            b.initKeysVector()
        } else {
            if (ResourceBundleWrapper.DEBUG) {
                println("Returning null for " + (val_baseName) + "_" + (val_localeID))
            }
        }
        return b
    }
}


class ResourceBundleWrapper_2_1 <: PrivilegedAction {
    let this_0: ResourceBundleWrapper_2

    let val_resName: String

    init(this_0: ResourceBundleWrapper_2, val_resName: String) {
        this.this_0 = this_0
        this.val_resName = val_resName
    }

    public override func run(): InputStream {
        return this_0.val_root.getResourceAsStream(val_resName)
    }
}
