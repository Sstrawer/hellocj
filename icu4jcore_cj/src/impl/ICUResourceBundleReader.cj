package icu4cj.impl


public class ICUResourceBundleReader {
    private static let DATA_FORMAT = 1382380354

    private static let IS_ACCEPTABLE = ICUResourceBundleReader_IsAcceptable()

    private static let URES_INDEX_LENGTH = 0

    private static let URES_INDEX_KEYS_TOP = 1

    private static let URES_INDEX_BUNDLE_TOP = 3

    private static let URES_INDEX_MAX_TABLE_LENGTH = 4

    private static let URES_INDEX_ATTRIBUTES = 5

    private static let URES_INDEX_16BIT_TOP = 6

    private static let URES_INDEX_POOL_CHECKSUM = 7

    private static let URES_ATT_NO_FALLBACK = 1

    private static let URES_ATT_IS_POOL_BUNDLE = 2

    private static let URES_ATT_USES_POOL_BUNDLE = 4

    private static let EMPTY_16_BIT_UNITS = CharBuffer.wrap("\u{0000}")

    static let LARGE_SIZE = 24

    private static let DEBUG = false

    private var dataVersion: Int32 = 0

    private var bytes: ByteArrayStream = None

    private var keyBytes: Array<UInt8>

    var b16BitUnits: CharBuffer = None

    private var poolBundleReader: ICUResourceBundleReader

    private var rootRes: Int32 = 0

    private var localKeyLimit: Int32 = 0

    var poolStringIndexLimit: Int32 = 0

    var poolStringIndex16imit: Int32 = 0

    private var noFallback: Bool = false

    private var isPoolBundle: Bool = false

    private var usesPoolBundle: Bool = false

    private var poolCheckSum: Int32 = 0

    private var resourceCache: ICUResourceBundleReader_ResourceCache

    private static var CACHE: ICUResourceBundleReader_ReaderCache = ICUResourceBundleReader_ReaderCache()

    static let NULL_READER = ICUResourceBundleReader()


    init(inBytes: ByteArrayStream, baseName: String, localeID: String, loader: ClassLoader) {
        initself(inBytes)
        if (usesPoolBundle) {
            poolBundleReader = getReader(baseName, "pool", loader)
            if (poolBundleReader.isNone() || !poolBundleReader.isPoolBundle) {
                throw Exception("pool.res is not a pool bundle")
            }
            if (poolBundleReader.poolCheckSum != poolCheckSum) {
                throw Exception("pool.res has a different checksum than this bundle")
            }
        }
    }

    static func getReader(baseName: String, localeID: String, root: ClassLoader): ICUResourceBundleReader {
        let info = ICUResourceBundleReader_ReaderCacheKey(baseName, localeID)
        let reader = CACHE.getInstance(info, root)
        if (refEq(reader, NULL_READER)) {
            return None
        }
        return reader
    }

    private func initself(inBytes: ByteArrayStream): Unit {
        dataVersion = ICUBinary.readHeader(inBytes, DATA_FORMAT, IS_ACCEPTABLE)
        let majorFormatVersion = Int32(inBytes.get(16))
        bytes = ICUBinary.sliceWithOrder(inBytes)
        let dataLength = bytes.remaining()
        if (DEBUG) {
            println("The ByteArrayStream is direct (memory-mapped): " + bytes.isDirect().toString())
        }
        if (DEBUG) {
            println("The available bytes in the buffer before reading the data: " + dataLength.toString())
        }
        rootRes = bytes.getInt(0)
        let indexes0 = getIndexesInt(URES_INDEX_LENGTH)
        let indexLength = indexes0 & 255
        if (indexLength <= URES_INDEX_MAX_TABLE_LENGTH) {
            throw ICUException("not enough indexes")
        }
        let bundleTop: Int32
        if (dataLength < (shl((1 + indexLength), 2)) || dataLength < (shl((match (0) { case _ => bundleTop = getIndexesInt(URES_INDEX_BUNDLE_TOP); bundleTop }), 2))) {
            throw ICUException("not enough bytes")
        }
        var maxOffset = bundleTop - 1
        if (majorFormatVersion >= 3) {
            poolStringIndexLimit = ushr(indexes0, 8)
        }
        if (indexLength > URES_INDEX_ATTRIBUTES) {
            let att = getIndexesInt(URES_INDEX_ATTRIBUTES)
            noFallback = (att & URES_ATT_NO_FALLBACK) != 0
            isPoolBundle = (att & URES_ATT_IS_POOL_BUNDLE) != 0
            usesPoolBundle = (att & URES_ATT_USES_POOL_BUNDLE) != 0
            poolStringIndexLimit |= shl((att & 61440), 12)
            poolStringIndex16imit = ushr(att, 16)
        }
        let keysBottom = 1 + indexLength
        let keysTop = getIndexesInt(URES_INDEX_KEYS_TOP)
        if (keysTop > keysBottom) {
            if (isPoolBundle) {
                keyBytes = Array<UInt8>(Int64(shl((keysTop - keysBottom), 2))) { _ => 0 }
                bytes.position(shl(keysBottom, 2))
            } else {
                localKeyLimit = shl(keysTop, 2)
                keyBytes = Array<UInt8>(Int64(localKeyLimit)) { _ => 0 }
            }
            bytes.get(keyBytes)
        }
        if (indexLength > URES_INDEX_16BIT_TOP) {
            let _16BitTop = getIndexesInt(URES_INDEX_16BIT_TOP)
            if (_16BitTop > keysTop) {
                let num16BitUnits = (_16BitTop - keysTop) * 2
                bytes.position(shl(keysTop, 2))
                b16BitUnits = bytes.asCharBuffer()
                b16BitUnits.limit(num16BitUnits)
                maxOffset |= num16BitUnits - 1
            } else {
                b16BitUnits = EMPTY_16_BIT_UNITS
            }
        } else {
            b16BitUnits = EMPTY_16_BIT_UNITS
        }
        if (indexLength > URES_INDEX_POOL_CHECKSUM) {
            poolCheckSum = getIndexesInt(URES_INDEX_POOL_CHECKSUM)
        }
        if (!isPoolBundle || b16BitUnits.size > 1) {
            resourceCache = ICUResourceBundleReader_ResourceCache(maxOffset)
        }
        bytes.position(0)
    }

    private func getIndexesInt(i: Int32): Int32 {
        return bytes.getInt(shl((1 + i), 2))
    }

    public func getVersion(): VersionInfo {
        return ICUBinary.getVersionInfoFromCompactInt(dataVersion)
    }

    public func getRootResource(): Int32 {
        return rootRes
    }

    public func getNoFallback(): Bool {
        return noFallback
    }

    public func getUsesPoolBundle(): Bool {
        return usesPoolBundle
    }

    static func RES_GET_TYPE(res: Int32): Int32 {
        return ushr(res, 28)
    }

    static func RES_GET_OFFSET(res: Int32): Int32 {
        return res & 268435455
    }

    public func getResourceByteOffset(offset: Int32): Int32 {
        return shl(offset, 2)
    }

    static func RES_GET_INT(res: Int32): Int32 {
        return shr((shl(res, 4)), 4)
    }

    static func RES_GET_UINT(res: Int32): Int32 {
        return res & 268435455
    }

    static func URES_IS_ARRAY(Type: Int32): Bool {
        return Type == UResourceBundle.ARRAY || Type == ICUResourceBundle.ARRAY16
    }

    static func URES_IS_TABLE(Type: Int32): Bool {
        return Type == UResourceBundle.TABLE || Type == ICUResourceBundle.TABLE16 || Type == ICUResourceBundle.TABLE32
    }

    private static let emptyBytes = Array<UInt8>(0) { _ => 0 }

    private static let emptyByteArrayStream = ByteArrayStream.allocate(0).asReadOnlyBuffer()

    private static let emptyChars = Array<Char>(0) { _ => '\u{0000}' }

    private static let emptyInts = Array<Int32>(0) { _ => 0 }

    private static let emptyString = ""

    private static let EMPTY_ARRAY = ICUResourceBundleReader_Array()

    private static let EMPTY_TABLE = ICUResourceBundleReader_Table()

    private func getChars(offset: Int32, count: Int32): Array<Char> {
        var tempoffset = offset
        let chars = Array<Char>(Int64(count)) { _ => '\u{0000}' }
        if (count <= 16) {
            var i = 0
            while (i < count) {
                chars[Int64(i)] = bytes.getChar(tempoffset)
                tempoffset += 2
                i++
            }
        } else {
            let temp = bytes.asCharBuffer()
            temp.position(tempoffset / 2)
            temp.get(chars)
        }
        return chars
    }

    public func getInt(offset: Int32): Int32 {
        return bytes.getInt(offset)
    }

    private func getInts(offset: Int32, count: Int32): Array<Int32> {
        var tempoffset = offset
        let ints = Array<Int32>(Int64(count)) { _ => 0 }
        if (count <= 16) {
            var i = 0
            while (i < count) {
                ints[Int64(i)] = bytes.getInt(tempoffset)
                tempoffset += 4
                i++
            }
        } else {
            let temp = bytes.asIntBuffer()
            temp.position(tempoffset / 4)
            temp.get(ints)
        }
        return ints
    }

    public func getTable16KeyOffsets(offset: Int32): Array<Char> {
        var tempoffset = offset
        let length = Int32(UInt32(b16BitUnits[match (0] { case _ => tempoffset++; tempoffset - 1 })))
        if (length > 0) {
            let result = Array<Char>(Int64(length)) { _ => '\u{0000}' }
            if (length <= 16) {
                var i = 0
                while (i < length) {
                    result[Int64(i)] = b16BitUnits[match (0] { case _ => tempoffset++; tempoffset - 1 })
                    i++
                }
            } else {
                let temp = b16BitUnits.duplicate()
                temp.position(tempoffset)
                temp.get(result)
            }
            return result
        } else {
            return emptyChars
        }
    }

    public func getTableKeyOffsets(offset: Int32): Array<Char> {
        let length = Int32(UInt32(bytes.getChar(offset)))
        if (length > 0) {
            return getChars(offset + 2, length)
        } else {
            return emptyChars
        }
    }

    public func getTable32KeyOffsets(offset: Int32): Array<Int32> {
        let length = getInt(offset)
        if (length > 0) {
            return getInts(offset + 4, length)
        } else {
            return emptyInts
        }
    }

    private static func makeKeyStringFromBytes(keyBytes: Array<UInt8>, keyOffset: Int32): String {
        var end = keyOffset
        while (Int32(keyBytes[Int64(end)]) != 0) {
            end++
        }
        let len = end - keyOffset
        return String(keyBytes, keyOffset, len, StandardCharsets.ISO_8859_1)
    }

    public func getKey16String(keyOffset: Int32): String {
        if (keyOffset < localKeyLimit) {
            return makeKeyStringFromBytes(keyBytes, keyOffset)
        } else {
            return makeKeyStringFromBytes(poolBundleReader.keyBytes, keyOffset - localKeyLimit)
        }
    }

    public func getKey32String(keyOffset: Int32): String {
        if (keyOffset >= 0) {
            return makeKeyStringFromBytes(keyBytes, keyOffset)
        } else {
            return makeKeyStringFromBytes(poolBundleReader.keyBytes, keyOffset & 2147483647)
        }
    }

    public func setKeyFromKey16(keyOffset: Int32, key: UResource_Key): Unit {
        if (keyOffset < localKeyLimit) {
            key.setBytes(keyBytes, keyOffset)
        } else {
            key.setBytes(poolBundleReader.keyBytes, keyOffset - localKeyLimit)
        }
    }

    public func setKeyFromKey32(keyOffset: Int32, key: UResource_Key): Unit {
        if (keyOffset >= 0) {
            key.setBytes(keyBytes, keyOffset)
        } else {
            key.setBytes(poolBundleReader.keyBytes, keyOffset & 2147483647)
        }
    }

    public func compareKeys(key: String, keyOffset: Char): Int32 {
        if (Int32(UInt32(keyOffset)) < localKeyLimit) {
            return ICUBinary.compareKeys(key, keyBytes, Int32(UInt32(keyOffset)))
        } else {
            return ICUBinary.compareKeys(key, poolBundleReader.keyBytes, Int32(UInt32(keyOffset)) - localKeyLimit)
        }
    }

    public func compareKeys32(key: String, keyOffset: Int32): Int32 {
        if (keyOffset >= 0) {
            return ICUBinary.compareKeys(key, keyBytes, keyOffset)
        } else {
            return ICUBinary.compareKeys(key, poolBundleReader.keyBytes, keyOffset & 2147483647)
        }
    }

    public func getStringV2(res: Int32): String {
        if (!(RES_GET_TYPE(res) == ICUResourceBundle.STRING_V2)) {
            throw AssertionError()
        }
        var offset = RES_GET_OFFSET(res)
        if (!(offset != 0)) {
            throw AssertionError()
        }
        let value = resourceCache.get(res)
        if (value.isSome()) {
            return value
        }
        let s: String
        let first = Int32(UInt32(b16BitUnits[offset]))
        if ((first & -1024) != 56320) {
            if (first == 0) {
                return emptyString
            }
            let sb = StringBuilder()
            sb.append(Char(first))
            var c: Char = '\u{0000}'
            while ((Int32(UInt32(match (0) { case _ => c = b16BitUnits[match (0] { case _ => offset++; offset }); c }))) != 0) {
                sb.append(c)
            }
            s = sb.toString()
        } else {
            let length: Int32
            if (first < 57327) {
                length = first & 1023
                offset++
            } else if (first < 57343) {
                length = (shl((first - 57327), 16)) | Int32(UInt32(b16BitUnits[offset + 1]))
                offset += 2
            } else {
                length = (shl(Int32(UInt32(b16BitUnits[offset + 1])), 16)) | Int32(UInt32(b16BitUnits[offset + 2]))
                offset += 3
            }
            s = toString((b16BitUnits).subSequence(offset, offset + length))
        }
        return resourceCache.putIfAbsent(res, s, Int32(s.size) * 2)
    }

    private func makeStringFromBytes(offset: Int32, length: Int32): String {
        var tempoffset = offset
        if (length <= 16) {
            let sb = StringBuilder()
            var i = 0
            while (i < length) {
                sb.append(bytes.getChar(tempoffset))
                tempoffset += 2
                i++
            }
            return sb.toString()
        } else {
            let cs = bytes.asCharBuffer()
            tempoffset /= 2
            return toString(cs.subSequence(tempoffset, tempoffset + length))
        }
    }

    public func getString(res: Int32): String {
        var offset = RES_GET_OFFSET(res)
        if (res != offset && RES_GET_TYPE(res) != ICUResourceBundle.STRING_V2) {
            return None
        }
        if (offset == 0) {
            return emptyString
        }
        if (res != offset) {
            if (offset < poolStringIndexLimit) {
                return poolBundleReader.getStringV2(res)
            } else {
                return getStringV2(res - poolStringIndexLimit)
            }
        }
        let value = resourceCache.get(res)
        if (value.isSome()) {
            return value
        }
        offset = getResourceByteOffset(offset)
        let length = getInt(offset)
        let s = makeStringFromBytes(offset + 4, length)
        return resourceCache.putIfAbsent(res, s, Int32(s.size) * 2)
    }

    public func isNoInheritanceMarker(res: Int32): Bool {
        var offset = RES_GET_OFFSET(res)
        if (offset == 0) { } else if (res == offset) {
            offset = getResourceByteOffset(offset)
            return getInt(offset) == 3 && Int32(UInt32(bytes.getChar(offset + 4))) == 8709 && Int32(UInt32(bytes.getChar(offset + 6))) == 8709 && Int32(UInt32(bytes.getChar(offset + 8))) == 8709
        } else if (RES_GET_TYPE(res) == ICUResourceBundle.STRING_V2) {
            if (offset < poolStringIndexLimit) {
                return poolBundleReader.isStringV2NoInheritanceMarker(offset)
            } else {
                return isStringV2NoInheritanceMarker(offset - poolStringIndexLimit)
            }
        }
        return false
    }

    private func isStringV2NoInheritanceMarker(offset: Int32): Bool {
        let first = Int32(UInt32(b16BitUnits[offset]))
        if (first == 8709) {
            return Int32(UInt32(b16BitUnits[offset + 1])) == 8709 && Int32(UInt32(b16BitUnits[offset + 2])) == 8709 && Int32(UInt32(b16BitUnits[offset + 3])) == 0
        } else if (first == 56323) {
            return Int32(UInt32(b16BitUnits[offset + 1])) == 8709 && Int32(UInt32(b16BitUnits[offset + 2])) == 8709 && Int32(UInt32(b16BitUnits[offset + 3])) == 8709
        } else {
            return false
        }
    }

    public func getAlias(res: Int32): String {
        var offset = RES_GET_OFFSET(res)
        let length: Int32
        if (RES_GET_TYPE(res) == ICUResourceBundle.ALIAS) {
            if (offset == 0) {
                return emptyString
            } else {
                let value = resourceCache.get(res)
                if (value.isSome()) {
                    return value
                }
                offset = getResourceByteOffset(offset)
                length = getInt(offset)
                let s = makeStringFromBytes(offset + 4, length)
                return resourceCache.putIfAbsent(res, s, length * 2)
            }
        } else {
            return None
        }
    }

    public func getBinary(res: Int32, ba: Array<UInt8>): Array<UInt8> {
        var tempba = ba
        var offset = RES_GET_OFFSET(res)
        let length: Int32
        if (RES_GET_TYPE(res) == UResourceBundle.BINARY) {
            if (offset == 0) {
                return emptyBytes
            } else {
                offset = getResourceByteOffset(offset)
                length = getInt(offset)
                if (length == 0) {
                    return emptyBytes
                }
                if (tempba.isNone() || Int32(tempba.size) != length) {
                    tempba = Array<UInt8>(Int64(length)) { _ => 0 }
                }
                offset += 4
                if (length <= 16) {
                    var i = 0
                    while (i < length) {
                        tempba[Int64(i)] = bytes.get(match (0) { case _ => offset++; offset - 1 })
                        i++
                    }
                } else {
                    let temp = bytes.duplicate()
                    temp.position(offset)
                    temp.get(tempba)
                }
                return tempba
            }
        } else {
            return None
        }
    }

    public func getBinary(res: Int32): ByteArrayStream {
        var offset = RES_GET_OFFSET(res)
        let length: Int32
        if (RES_GET_TYPE(res) == UResourceBundle.BINARY) {
            if (offset == 0) {
                return emptyByteArrayStream.duplicate()
            } else {
                offset = getResourceByteOffset(offset)
                length = getInt(offset)
                if (length == 0) {
                    return emptyByteArrayStream.duplicate()
                }
                offset += 4
                var result = bytes.duplicate()
                result.position(offset).limit(offset + length)
                result = ICUBinary.sliceWithOrder(result)
                if (!result.isReadOnly()) {
                    result = result.asReadOnlyBuffer()
                }
                return result
            }
        } else {
            return None
        }
    }

    public func getIntVector(res: Int32): Array<Int32> {
        var offset = RES_GET_OFFSET(res)
        let length: Int32
        if (RES_GET_TYPE(res) == UResourceBundle.INT_VECTOR) {
            if (offset == 0) {
                return emptyInts
            } else {
                offset = getResourceByteOffset(offset)
                length = getInt(offset)
                return getInts(offset + 4, length)
            }
        } else {
            return None
        }
    }

    public func getArray(res: Int32): ICUResourceBundleReader_Array {
        let Type = RES_GET_TYPE(res)
        if (!URES_IS_ARRAY(Type)) {
            return None
        }
        let offset = RES_GET_OFFSET(res)
        if (offset == 0) {
            return EMPTY_ARRAY
        }
        let value = resourceCache.get(res)
        if (value.isSome()) {
            return value
        }
        let array: ICUResourceBundleReader_Array = if (Type == UResourceBundle.ARRAY) { ICUResourceBundleReader_Array32(this, offset) } else { ICUResourceBundleReader_Array16(this, offset) }
        return resourceCache.putIfAbsent(res, array, 0)
    }

    public func getTable(res: Int32): ICUResourceBundleReader_Table {
        let Type = RES_GET_TYPE(res)
        if (!URES_IS_TABLE(Type)) {
            return None
        }
        let offset = RES_GET_OFFSET(res)
        if (offset == 0) {
            return EMPTY_TABLE
        }
        let value = resourceCache.get(res)
        if (value.isSome()) {
            return value
        }
        let table: ICUResourceBundleReader_Table
        let size: Int32
        if (Type == UResourceBundle.TABLE) {
            table = ICUResourceBundleReader_Table1632(this, offset)
            size = table.getSize() * 2
        } else if (Type == ICUResourceBundle.TABLE16) {
            table = ICUResourceBundleReader_Table16(this, offset)
            size = table.getSize() * 2
        } else {
            table = ICUResourceBundleReader_Table32(this, offset)
            size = table.getSize() * 4
        }
        return resourceCache.putIfAbsent(res, table, size)
    }

    static var PUBLIC_TYPES: Array<Int32> = [UResourceBundle.STRING, UResourceBundle.BINARY, UResourceBundle.TABLE, ICUResourceBundle.ALIAS, UResourceBundle.TABLE, UResourceBundle.TABLE, UResourceBundle.STRING, UResourceBundle.INT, UResourceBundle.ARRAY, UResourceBundle.ARRAY, UResourceBundle.NONE, UResourceBundle.NONE, UResourceBundle.NONE, UResourceBundle.NONE, UResourceBundle.INT_VECTOR, UResourceBundle.NONE]

    private static let ICU_RESOURCE_SUFFIX = ".res"

    public static func getFullName(baseName: String, localeName: String): String {
        var templocaleName = localeName
        var tempbaseName = baseName
        if (tempbaseName.isNone() || Int32(tempbaseName.size) == 0) {
            if (Int32(templocaleName.size) == 0) {
                return match (0) { case _ => templocaleName = ULocale.getDefault().toString(); templocaleName }
            }
            return (templocaleName) + ICU_RESOURCE_SUFFIX
        } else {
            if (indexOfWrap(tempbaseName.indexOf(UInt8(UInt32('.')))) == -1) {
                if (Char(tempbaseName[Int64(Int32(tempbaseName.size) - 1)]) != '/') {
                    return (tempbaseName) + "/" + (templocaleName) + ICU_RESOURCE_SUFFIX
                } else {
                    return (tempbaseName) + (templocaleName) + ICU_RESOURCE_SUFFIX
                }
            } else {
                tempbaseName = tempbaseName.replace('.'.toString(), '/'.toString())
                if (Int32(templocaleName.size) == 0) {
                    return (tempbaseName) + ICU_RESOURCE_SUFFIX
                } else {
                    return (tempbaseName) + "_" + (templocaleName) + ICU_RESOURCE_SUFFIX
                }
            }
        }
    }
}


class ICUResourceBundleReader_IsAcceptable <: ICUBinary_Authenticate {

    public override func isDataVersionAcceptable(formatVersion: Array<UInt8>): Bool {
        return (Int32(formatVersion[0]) == 1 && (Int32(formatVersion[1]) & 255) >= 1) || (2 <= Int32(formatVersion[0]) && Int32(formatVersion[0]) <= 3)
    }
}


class ICUResourceBundleReader_ReaderCacheKey {
    let baseName: String

    let localeID: String

    init(baseName: String, localeID: String) {
        this.baseName = if (baseName.isNone()) { "" } else { baseName }
        this.localeID = if (localeID.isNone()) { "" } else { localeID }
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (!(checkOptionalIs<ICUResourceBundleReader_ReaderCacheKey, Object>(obj))) {
            return false
        }
        let info = obj
        return this.baseName.equals(info.baseName) && this.localeID.equals(info.localeID)
    }

    public override func hashCode(): Int64 {
        return Int64(Int32(baseName.hashCode()) ^ Int32(localeID.hashCode()))
    }
}


class ICUResourceBundleReader_ReaderCache <: SoftCache<ICUResourceBundleReader_ReaderCacheKey, ICUResourceBundleReader, ClassLoader> {
    init() {
        super()
    }

    override protected func createInstance(key: ICUResourceBundleReader_ReaderCacheKey, loader: ClassLoader): ICUResourceBundleReader {
        let fullName = ICUResourceBundleReader.getFullName(key.baseName, key.localeID)
        try {
            let inBytes: ByteArrayStream
            if (key.baseName.isSome() && key.baseName.startsWith(ICUData.ICU_BASE_NAME)) {
                let itemPath: String = fullName[Int64(Int32(ICUData.ICU_BASE_NAME.size) + 1)..]
                inBytes = ICUBinary.getData(loader, fullName, itemPath)
                if (inBytes.isNone()) {
                    return ICUResourceBundleReader.NULL_READER
                }
            } else {
                let stream = ICUData.getStream(loader, fullName)
                if (stream.isNone()) {
                    return ICUResourceBundleReader.NULL_READER
                }
                inBytes = ICUBinary.getByteBufferFromInputStreamAndCloseStream(stream)
            }
            return ICUResourceBundleReader(inBytes, key.baseName, key.localeID, loader)
        } catch (ex: IOException) {
            throw ICUUncheckedIOException("Data file " + (fullName) + " is corrupt - " + ex.message, ex)
        }
    }
}


class ICUResourceBundleReader_ReaderValue <: UResource_Value {
    init() {
        super()
    }

    var reader: ICUResourceBundleReader

    var res: Int32 = 0

    public override func getType(): Int32 {
        return ICUResourceBundleReader.PUBLIC_TYPES[Int64(ICUResourceBundleReader.RES_GET_TYPE(res))]
    }

    public override func getString(): String {
        let s = reader.getString(res)
        if (s.isNone()) {
            throw UResourceTypeMismatchException("")
        }
        return s
    }

    public override func getAliasString(): String {
        let s = reader.getAlias(res)
        if (s.isNone()) {
            throw UResourceTypeMismatchException("")
        }
        return s
    }

    public override func getInt(): Int32 {
        if (ICUResourceBundleReader.RES_GET_TYPE(res) != UResourceBundle.INT) {
            throw UResourceTypeMismatchException("")
        }
        return ICUResourceBundleReader.RES_GET_INT(res)
    }

    public override func getUInt(): Int32 {
        if (ICUResourceBundleReader.RES_GET_TYPE(res) != UResourceBundle.INT) {
            throw UResourceTypeMismatchException("")
        }
        return ICUResourceBundleReader.RES_GET_UINT(res)
    }

    public override func getIntVector(): Array<Int32> {
        let iv = reader.getIntVector(res)
        if (iv.isNone()) {
            throw UResourceTypeMismatchException("")
        }
        return iv
    }

    public override func getBinary(): ByteArrayStream {
        let bb = reader.getBinary(res)
        if (bb.isNone()) {
            throw UResourceTypeMismatchException("")
        }
        return bb
    }

    public override func getArray(): UResource_Array {
        let array = reader.getArray(res)
        if (array.isNone()) {
            throw UResourceTypeMismatchException("")
        }
        return array
    }

    public override func getTable(): UResource_Table {
        let table = reader.getTable(res)
        if (table.isNone()) {
            throw UResourceTypeMismatchException("")
        }
        return table
    }

    public override func isNoInheritanceMarker(): Bool {
        return reader.isNoInheritanceMarker(res)
    }

    public override func getStringArray(): Array<String> {
        let array = reader.getArray(res)
        if (array.isNone()) {
            throw UResourceTypeMismatchException("")
        }
        return getStringArray(array)
    }

    public override func getStringArrayOrStringAsArray(): Array<String> {
        let array = reader.getArray(res)
        if (array.isSome()) {
            return getStringArray(array)
        }
        let s = reader.getString(res)
        if (s.isSome()) {
            return [s]
        }
        throw UResourceTypeMismatchException("")
    }

    public override func getStringOrFirstOfArray(): String {
        var s = reader.getString(res)
        if (s.isSome()) {
            return s
        }
        let array = reader.getArray(res)
        if (array.isSome() && array.size > 0) {
            let r = array.getContainerResource(reader, 0)
            s = reader.getString(r)
            if (s.isSome()) {
                return s
            }
        }
        throw UResourceTypeMismatchException("")
    }

    private func getStringArray(array: ICUResourceBundleReader_Array): Array<String> {
        let result = Array<String>(Int64(array.size))
        var i = 0
        while (i < array.size) {
            let r = array.getContainerResource(reader, i)
            let s = reader.getString(r)
            if (s.isNone()) {
                throw UResourceTypeMismatchException("")
            }
            result[Int64(i)] = s
            i++
        }
        return result
    }
}


class ICUResourceBundleReader_Container {
    protected var size: Int32 = 0

    protected var itemsOffset: Int32 = 0

    public func getSize(): Int32 {
        return size
    }

    public func getContainerResource(reader: ICUResourceBundleReader, index: Int32): Int32 {
        return ICUResourceBundle.RES_BOGUS
    }

    protected func getContainer16Resource(reader: ICUResourceBundleReader, index: Int32): Int32 {
        if (index < 0 || size <= index) {
            return ICUResourceBundle.RES_BOGUS
        }
        var res16 = Int32(UInt32(reader.b16BitUnits[itemsOffset + index]))
        if (res16 < reader.poolStringIndex16imit) { } else {
            res16 = res16 - reader.poolStringIndex16imit + reader.poolStringIndexLimit
        }
        return (shl(ICUResourceBundle.STRING_V2, 28)) | res16
    }

    protected func getContainer32Resource(reader: ICUResourceBundleReader, index: Int32): Int32 {
        if (index < 0 || size <= index) {
            return ICUResourceBundle.RES_BOGUS
        }
        return reader.getInt(itemsOffset + 4 * index)
    }

    public func getResource(reader: ICUResourceBundleReader, resKey: String): Int32 {
        return getContainerResource(reader, parse<Int32>(resKey))
    }

}


class ICUResourceBundleReader_Array <: ICUResourceBundleReader_Container & UResource_Array {
    init() {
        super()
    }

    public override func getValue(i: Int32, value: UResource_Value): Bool {
        if (0 <= i && i < size) {
            let readerValue = value
            readerValue.res = getContainerResource(readerValue.reader, i)
            return true
        }
        return false
    }
}


class ICUResourceBundleReader_Array32 <: ICUResourceBundleReader_Array {
    public override func getContainerResource(reader: ICUResourceBundleReader, index: Int32): Int32 {
        return getContainer32Resource(reader, index)
    }

    init(reader: ICUResourceBundleReader, offset: Int32) {
        super()
        var tempoffset = offset
        tempoffset = reader.getResourceByteOffset(tempoffset)
        size = reader.getInt(tempoffset)
        itemsOffset = tempoffset + 4
    }
}


class ICUResourceBundleReader_Array16 <: ICUResourceBundleReader_Array {
    public override func getContainerResource(reader: ICUResourceBundleReader, index: Int32): Int32 {
        return getContainer16Resource(reader, index)
    }

    init(reader: ICUResourceBundleReader, offset: Int32) {
        super()
        size = Int32(UInt32(reader.b16BitUnits[offset]))
        itemsOffset = offset + 1
    }
}


class ICUResourceBundleReader_Table <: ICUResourceBundleReader_Container & UResource_Table {
    protected var keyOffsets: Array<Char>

    protected var key32Offsets: Array<Int32>

    init() {
        super()
    }

    public func getKey(reader: ICUResourceBundleReader, index: Int32): String {
        if (index < 0 || size <= index) {
            return None
        }
        return if (keyOffsets.isSome()) { reader.getKey16String(Int32(UInt32(keyOffsets[Int64(index)]))) } else { reader.getKey32String(key32Offsets[Int64(index)]) }
    }

    private static let URESDATA_ITEM_NOT_FOUND = -1

    public func findTableItem(reader: ICUResourceBundleReader, key: String): Int32 {
        var mid: Int32 = 0
        var start: Int32 = 0
        var limit: Int32 = 0
        var result: Int32 = 0
        start = 0
        limit = size
        while (start < limit) {
            mid = ushr((start + limit), 1)
            if (keyOffsets.isSome()) {
                result = reader.compareKeys(key, keyOffsets[Int64(mid)])
            } else {
                result = reader.compareKeys32(key, key32Offsets[Int64(mid)])
            }
            if (result < 0) {
                limit = mid
            } else if (result > 0) {
                start = mid + 1
            } else {
                return mid
            }
        }
        return URESDATA_ITEM_NOT_FOUND
    }

    public override func getResource(reader: ICUResourceBundleReader, resKey: String): Int32 {
        return getContainerResource(reader, findTableItem(reader, resKey))
    }

    public override func getKeyAndValue(i: Int32, key: UResource_Key, value: UResource_Value): Bool {
        if (0 <= i && i < size) {
            let readerValue = value
            if (keyOffsets.isSome()) {
                readerValue.reader.setKeyFromKey16(Int32(UInt32(keyOffsets[Int64(i)])), key)
            } else {
                readerValue.reader.setKeyFromKey32(key32Offsets[Int64(i)], key)
            }
            readerValue.res = getContainerResource(readerValue.reader, i)
            return true
        }
        return false
    }

    public override func findValue(key: String, value: UResource_Value): Bool {
        let readerValue = value
        let i = findTableItem(readerValue.reader, key)
        if (i >= 0) {
            readerValue.res = getContainerResource(readerValue.reader, i)
            return true
        } else {
            return false
        }
    }
}


class ICUResourceBundleReader_Table1632 <: ICUResourceBundleReader_Table {
    public override func getContainerResource(reader: ICUResourceBundleReader, index: Int32): Int32 {
        return getContainer32Resource(reader, index)
    }

    init(reader: ICUResourceBundleReader, offset: Int32) {
        super()
        var tempoffset = offset
        tempoffset = reader.getResourceByteOffset(tempoffset)
        keyOffsets = reader.getTableKeyOffsets(tempoffset)
        size = Int32(keyOffsets.size)
        itemsOffset = tempoffset + 2 * ((size + 2) & )
    }
}


class ICUResourceBundleReader_Table16 <: ICUResourceBundleReader_Table {
    public override func getContainerResource(reader: ICUResourceBundleReader, index: Int32): Int32 {
        return getContainer16Resource(reader, index)
    }

    init(reader: ICUResourceBundleReader, offset: Int32) {
        super()
        keyOffsets = reader.getTable16KeyOffsets(offset)
        size = Int32(keyOffsets.size)
        itemsOffset = offset + 1 + size
    }
}


class ICUResourceBundleReader_Table32 <: ICUResourceBundleReader_Table {
    public override func getContainerResource(reader: ICUResourceBundleReader, index: Int32): Int32 {
        return getContainer32Resource(reader, index)
    }

    init(reader: ICUResourceBundleReader, offset: Int32) {
        super()
        var tempoffset = offset
        tempoffset = reader.getResourceByteOffset(tempoffset)
        key32Offsets = reader.getTable32KeyOffsets(tempoffset)
        size = Int32(key32Offsets.size)
        itemsOffset = tempoffset + 4 * (1 + size)
    }
}


class ICUResourceBundleReader_ResourceCache <: Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private static let SIMPLE_LENGTH = 32

    private static let ROOT_BITS = 7

    private static let NEXT_BITS = 6

    private var keys: Array<Int32> = Array<Int32>(Int64(SIMPLE_LENGTH)) { _ => 0 }

    private var values: Array<Object> = Array<Object>(Int64(SIMPLE_LENGTH))

    private var length: Int32 = 0

    private var maxOffsetBits: Int32 = 0

    private var levelBitsList: Int32 = 0

    private var rootLevel: ICUResourceBundleReader_ResourceCache_Level

    static func storeDirectly(size: Int32): Bool {
        return size < ICUResourceBundleReader.LARGE_SIZE || CacheValue.futureInstancesWillBeStrong()
    }

    static func putIfCleared(values: Array<Object>, index: Int32, item: Object, size: Int32): Object {
        var value = values[Int64(index)]
        if (!(checkOptionalIs<SoftReference, Object>(value))) {
            return value
        }
        if (!(size >= ICUResourceBundleReader.LARGE_SIZE)) {
            throw AssertionError()
        }
        value = value.get()
        if (value.isSome()) {
            return value
        }
        values[Int64(index)] = if (CacheValue.futureInstancesWillBeStrong()) { item } else { SoftReference(item) }
        return item
    }

    init(maxOffset: Int32) {
        var tempmaxOffset = maxOffset
        if (!(tempmaxOffset != 0)) {
            throw AssertionError()
        }
        maxOffsetBits = 28
        while (tempmaxOffset <= 134217727) {
            tempmaxOffset <<= 1
            maxOffsetBits--
        }
        var keyBits = maxOffsetBits + 2
        if (keyBits <= ROOT_BITS) {
            levelBitsList = keyBits
        } else if (keyBits < (ROOT_BITS + 3)) {
            levelBitsList = 48 | (keyBits - 3)
        } else {
            levelBitsList = ROOT_BITS
            keyBits -= ROOT_BITS
            var shift = 4
            while (true) {
                if (keyBits <= NEXT_BITS) {
                    levelBitsList |= shl(keyBits, shift)
                    break
                } else if (keyBits < (NEXT_BITS + 3)) {
                    levelBitsList |= shl((48 | (keyBits - 3)), shift)
                    break
                } else {
                    levelBitsList |= shl(NEXT_BITS, shift)
                    keyBits -= NEXT_BITS
                    shift += 4
                }
            }
        }
    }

    private func makeKey(res: Int32): Int32 {
        let Type = ICUResourceBundleReader.RES_GET_TYPE(res)
        let miniType = if (Type == ICUResourceBundle.STRING_V2) { 1 } else { if (Type == ICUResourceBundle.TABLE16) { 3 } else { if (Type == ICUResourceBundle.ARRAY16) { 2 } else { 0 } } }
        return ICUResourceBundleReader.RES_GET_OFFSET(res) | (shl(miniType, maxOffsetBits))
    }

    private func findSimple(key: Int32): Int32 {
        return Arrays.binarySearch(keys, 0, length, key)
    }

    public func get(res: Int32): Object {
        synchronized (GeneratedLockObject) {
            if (!(ICUResourceBundleReader.RES_GET_OFFSET(res) != 0)) {
                throw AssertionError()
            }
            var value: Object
            if (length >= 0) {
                let index = findSimple(res)
                if (index >= 0) {
                    value = values[Int64(index)]
                } else {
                    return None
                }
            } else {
                value = rootLevel.get(makeKey(res))
                if (value.isNone()) {
                    return None
                }
            }
            if (checkOptionalIs<SoftReference, Object>(value)) {
                value = value.get()
            }
            return value
        }
    }

    public func putIfAbsent(res: Int32, item: Object, size: Int32): Object {
        synchronized (GeneratedLockObject) {
            if (length >= 0) {
                var index = findSimple(res)
                if (index >= 0) {
                    return putIfCleared(values, index, item, size)
                } else if (length < SIMPLE_LENGTH) {
                    index = 
                    if (index < length) {
                        arraycopy(keys, Int64(index), keys, Int64(index + 1), Int64(length - index))
                        arraycopy(values, Int64(index), values, Int64(index + 1), Int64(length - index))
                    }
                    length++
                    keys[Int64(index)] = res
                    values[Int64(index)] = if (storeDirectly(size)) { item } else { SoftReference(item) }
                    return item
                } else {
                    rootLevel = ICUResourceBundleReader_ResourceCache_Level(levelBitsList, 0)
                    var i = 0
                    while (i < SIMPLE_LENGTH) {
                        rootLevel.putIfAbsent(makeKey(keys[Int64(i)]), values[Int64(i)], 0)
                        i++
                    }
                    keys = None
                    values = None
                    length = -1
                }
            }
            return rootLevel.putIfAbsent(makeKey(res), item, size)
        }
    }
}


class ICUResourceBundleReader_ResourceCache_Level {
    var levelBitsList: Int32 = 0

    var shift: Int32 = 0

    var mask: Int32 = 0

    var keys: Array<Int32>

    var values: Array<Object>

    init(levelBitsList: Int32, shift: Int32) {
        this.levelBitsList = levelBitsList
        this.shift = shift
        let bits = levelBitsList & 15
        if (!(bits != 0)) {
            throw AssertionError()
        }
        let length = shl(1, bits)
        mask = length - 1
        keys = Array<Int32>(Int64(length)) { _ => 0 }
        values = Array<Object>(Int64(length))
    }

    public func get(key: Int32): Object {
        let index = (shr(key, shift)) & mask
        let k = keys[Int64(index)]
        if (k == key) {
            return values[Int64(index)]
        }
        if (k == 0) {
            let level = values[Int64(index)]
            if (level.isSome()) {
                return level.get(key)
            }
        }
        return None
    }

    public func putIfAbsent(key: Int32, item: Object, size: Int32): Object {
        let index = (shr(key, shift)) & mask
        let k = keys[Int64(index)]
        if (k == key) {
            return ICUResourceBundleReader_ResourceCache.putIfCleared(values, index, item, size)
        }
        if (k == 0) {
            let level = values[Int64(index)]
            if (level.isSome()) {
                return level.putIfAbsent(key, item, size)
            }
            keys[Int64(index)] = key
            values[Int64(index)] = if (ICUResourceBundleReader_ResourceCache.storeDirectly(size)) { item } else { SoftReference(item) }
            return item
        }
        let level = ICUResourceBundleReader_ResourceCache_Level(shr(levelBitsList, 4), shift + (levelBitsList & 15))
        let i = (shr(k, level.shift)) & level.mask
        level.keys[Int64(i)] = k
        level.values[Int64(i)] = values[Int64(index)]
        keys[Int64(index)] = 0
        values[Int64(index)] = level
        return level.putIfAbsent(key, item, size)
    }
}
