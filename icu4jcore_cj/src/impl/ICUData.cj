package icu4cj.impl


public class ICUData {

    static let ICU_DATA_PATH = "com/ibm/icu/impl/"

    static let PACKAGE_NAME: String = "icudt" + VersionInfo.ICU_DATA_VERSION_PATH

    public static let ICU_BUNDLE: String = "data/" + (PACKAGE_NAME)

    public static let ICU_BASE_NAME: String = ICU_DATA_PATH + (ICU_BUNDLE)

    public static let ICU_COLLATION_BASE_NAME: String = (ICU_BASE_NAME) + "/coll"

    public static let ICU_BRKITR_NAME = "brkitr"

    public static let ICU_BRKITR_BASE_NAME: String = (ICU_BASE_NAME) + '/'.toString() + ICU_BRKITR_NAME

    public static let ICU_RBNF_BASE_NAME: String = (ICU_BASE_NAME) + "/rbnf"

    public static let ICU_TRANSLIT_BASE_NAME: String = (ICU_BASE_NAME) + "/translit"

    public static let ICU_LANG_BASE_NAME: String = (ICU_BASE_NAME) + "/lang"

    public static let ICU_CURR_BASE_NAME: String = (ICU_BASE_NAME) + "/curr"

    public static let ICU_REGION_BASE_NAME: String = (ICU_BASE_NAME) + "/region"

    public static let ICU_ZONE_BASE_NAME: String = (ICU_BASE_NAME) + "/zone"

    public static let ICU_UNIT_BASE_NAME: String = (ICU_BASE_NAME) + "/unit"

    private static let logBinaryDataFromInputStream = false

    private static let logger: Logger = None

    public static func exists(resourceName: String): Bool {
        var i: URL = None
        if (System.getSecurityManager().isSome()) {
            i = AccessController.doPrivileged(ICUData_1(resourceName) as PrivilegedAction)
        } else {
            i = TypeInfo.of<ICUData>().getResource(resourceName)
        }
        return i.isSome()
    }

    private static func getStream(root: ClassTypeInfo, resourceName: String, required: Bool): InputStream {
        var i: InputStream
        if (System.getSecurityManager().isSome()) {
            i = AccessController.doPrivileged(ICUData_2(root, resourceName) as PrivilegedAction)
        } else {
            i = getInputStreamFromFile(resourceName)
        }
        if (i.isNone() && required) {
            throw MissingResourceException("could not locate data " + (resourceName), root.getPackage().getName(), resourceName)
        }
        checkStreamForBinaryData(i, resourceName)
        return i
    }

    static func getStream(loader: ClassLoader, resourceName: String, required: Bool): InputStream {
        var i: InputStream
        if (System.getSecurityManager().isSome()) {
            i = AccessController.doPrivileged(ICUData_3(loader, resourceName) as PrivilegedAction)
        } else {
            i = loader.getResourceAsStream(resourceName)
        }
        if (i.isNone() && required) {
            throw MissingResourceException("could not locate data", toString(loader), resourceName)
        }
        checkStreamForBinaryData(i, resourceName)
        return i
    }

    private static func checkStreamForBinaryData(isTrue: InputStream, resourceName: String): Unit {
        if (logBinaryDataFromInputStream) {
            try {
                isTrue.mark(32)
                let b = Array<UInt8>(32) { _ => 0 }
                let len = Int32(isTrue.read(b))
                if (len == 32 && b[2] == 218 && Int32(b[3]) == 39) {
                    let msg = String.format("ICU binary data file loaded from Class/ClassLoader as InputStream from %s: MappedData %02x%02x%02x%02x  dataFormat %02x%02x%02x%02x", [resourceName, Int8(b[0]), Int8(b[1]), Int8(b[2]), Int8(b[3]), Int8(b[12]), Int8(b[13]), Int8(b[14]), Int8(b[15])])
                    logger.info(msg)
                }
                isTrue.reset()
            } catch (ignored: IOException) { }
        }
    }

    public static func getStream(loader: ClassLoader, resourceName: String): InputStream {
        return getStream(loader, resourceName, false)
    }

    public static func getRequiredStream(loader: ClassLoader, resourceName: String): InputStream {
        return getStream(loader, resourceName, true)
    }

    public static func getStream(resourceName: String): InputStream {
        return getStream(TypeInfo.of<ICUData>() as ClassTypeInfo, resourceName, false)
    }

    public static func getRequiredStream(resourceName: String): InputStream {
        return getStream(TypeInfo.of<ICUData>() as ClassTypeInfo, resourceName, true)
    }

    public static func getStream(root: ClassTypeInfo, resourceName: String): InputStream {
        return getStream(root, resourceName, false)
    }

    public static func getRequiredStream(root: ClassTypeInfo, resourceName: String): InputStream {
        return getStream(root, resourceName, true)
    }
}


class ICUData_1 <: PrivilegedAction {
    let val_resourceName: String

    init(val_resourceName: String) {
        this.val_resourceName = val_resourceName
    }

    public override func run(): URL {
        return TypeInfo.of<ICUData>().getResource(val_resourceName)
    }
}


class ICUData_2 <: PrivilegedAction {
    let val_resourceName: String

    let val_root: ClassTypeInfo

    init(val_root: ClassTypeInfo, val_resourceName: String) {
        this.val_root = val_root
        this.val_resourceName = val_resourceName
    }

    public override func run(): InputStream {
        return getInputStreamFromFile(val_resourceName)
    }
}


class ICUData_3 <: PrivilegedAction {
    let val_resourceName: String

    let val_loader: ClassLoader

    init(val_loader: ClassLoader, val_resourceName: String) {
        this.val_loader = val_loader
        this.val_resourceName = val_resourceName
    }

    public override func run(): InputStream {
        return val_loader.getResourceAsStream(val_resourceName)
    }
}
