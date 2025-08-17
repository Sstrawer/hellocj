package icu4cj.impl


public class ICUBinary {

    private static let icuDataFiles = ArrayList<ICUBinary_DataFile>()


    private static func addDataFilesFromPath(dataPath: String, files: ArrayList<ICUBinary_DataFile>): Unit {
        var pathStart = 0
        while (pathStart < Int32(dataPath.size)) {
            let sepIndex = indexOfWrap(dataPath.indexOf(UInt8(UInt32(File.pathSeparatorChar)), Int64(pathStart)))
            let pathLimit: Int32
            if (sepIndex >= 0) {
                pathLimit = sepIndex
            } else {
                pathLimit = Int32(dataPath.size)
            }
            var path: String = dataPath[Int64(pathStart)..Int64(pathLimit)].trimAscii()
            if (path.endsWith(File.separator)) {
                path = path[0..Int64(Int32(path.size) - 1)]
            }
            if (Int32(path.size) != 0) {
                addDataFilesFromFolder(File(path), StringBuilder(), icuDataFiles)
            }
            if (sepIndex < 0) {
                break
            }
            pathStart = sepIndex + 1
        }
    }

    private static func addDataFilesFromFolder(folder: File, itemPath: StringBuilder, dataFiles: ArrayList<ICUBinary_DataFile>): Unit {
        let files = folder.listFiles()
        if (files.isNone() || Int32(files.size) == 0) {
            return
        }
        var folderPathLength = Int32(itemPath.size)
        if (folderPathLength > 0) {
            itemPath.append('/')
            folderPathLength++
        }
        for (file in files) {
            let fileName = file.getName()
            if (fileName.endsWith(".txt")) {
                continue
            }
            itemPath.append(fileName)
            if (file.isDirectory()) {
                addDataFilesFromFolder(file, itemPath, dataFiles)
            } else if (fileName.endsWith(".dat")) {
                let pkgBytes = mapFile(file)
                if (pkgBytes.isSome() && ICUBinary_DatPackageReader.validate(pkgBytes)) {
                    dataFiles.append(ICUBinary_PackageDataFile(itemPath.toString(), pkgBytes))
                }
            } else {
                dataFiles.append(ICUBinary_SingleDataFile(itemPath.toString(), file))
            }
            itemPath.setLength(Int64(folderPathLength))
        }
    }

    static func compareKeys(key: String, bytes: ByteArrayStream, offset: Int32): Int32 {
        var tempoffset = offset
        var i = 0
        while (true) {
            let c2 = Int32(bytes.get(tempoffset))
            if (c2 == 0) {
                if (i == key.size) {
                    return 0
                } else {
                    return 1
                }
            } else if (i == key.size) {
                return -1
            }
            let diff = Int32(UInt32(key[i])) - c2
            if (diff != 0) {
                return diff
            }
            i++
            tempoffset++
        }
    }

    static func compareKeys(key: String, bytes: Array<UInt8>, offset: Int32): Int32 {
        var tempoffset = offset
        var i = 0
        while (true) {
            let c2 = Int32(bytes[Int64(tempoffset)])
            if (c2 == 0) {
                if (i == key.size) {
                    return 0
                } else {
                    return 1
                }
            } else if (i == key.size) {
                return -1
            }
            let diff = Int32(UInt32(key[i])) - c2
            if (diff != 0) {
                return diff
            }
            i++
            tempoffset++
        }
    }

    public static func getData(itemPath: String): ByteArrayStream {
        return getData(None, None, itemPath, false)
    }

    public static func getData(loader: ClassLoader, resourceName: String, itemPath: String): ByteArrayStream {
        return getData(loader, resourceName, itemPath, false)
    }

    public static func getRequiredData(itemPath: String): ByteArrayStream {
        return getData(None, None, itemPath, true)
    }

    private static func getData(loader: ClassLoader, resourceName: String, itemPath: String, required: Bool): ByteArrayStream {
        var temploader = loader
        var tempresourceName = resourceName
        let bytes = getDataFromFile(itemPath)
        if (bytes.isSome()) {
            return bytes
        }
        if (temploader.isNone()) {
            temploader = ClassLoaderUtil.getClassLoader(TypeInfo.of<ICUData>() as ClassTypeInfo)
        }
        if (tempresourceName.isNone()) {
            tempresourceName = (ICUData.ICU_BASE_NAME) + '/'.toString() + (itemPath)
        }
        var buffer: ByteArrayStream = None
        try {
            let isTrue = ICUData.getStream(temploader, tempresourceName, required)
            if (isTrue.isNone()) {
                return None
            }
            buffer = getByteBufferFromInputStreamAndCloseStream(isTrue)
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
        return buffer
    }

    private static func getDataFromFile(itemPath: String): ByteArrayStream {
        for (dataFile in icuDataFiles) {
            let data = dataFile.getData(itemPath)
            if (data.isSome()) {
                return data
            }
        }
        return None
    }

    static func mapFile(path: File): ByteArrayStream {
        let file: FileInputStream
        try {
            file = FileInputStream(path)
            let channel = file.getChannel()
            var bytes: ByteArrayStream = None
            try {
                bytes = channel.map(FileChannel_MapMode.READ_ONLY, 0, channel.size())
            } finally {
            }
            return bytes
        } catch (ignored: FileNotFoundException) {
            eprintln(toString(ignored))
        } catch (ignored: IOException) {
            eprintln(ignored.toString())
        }
        return None
    }

    public static func addBaseNamesInFileFolder(folder: String, suffix: String, names: Set<String>): Unit {
        for (dataFile in icuDataFiles) {
            dataFile.addBaseNamesInFolder(folder, suffix, names)
        }
    }

    public static func readHeaderAndDataVersion(bytes: ByteArrayStream, dataFormat: Int32, authenticate: ICUBinary_Authenticate): VersionInfo {
        return getVersionInfoFromCompactInt(readHeader(bytes, dataFormat, authenticate))
    }

    public static func readHeader(bytes: ByteArrayStream, dataFormat: Int32, authenticate: ICUBinary_Authenticate): Int32 {
        if (!(bytes.isSome() && bytes.position() == 0)) {
            throw AssertionError()
        }
        let magic1 = bytes.get(2)
        let magic2 = bytes.get(3)
        if (magic1 != MAGIC1 || magic2 != MAGIC2) {
            throw IOException(MAGIC_NUMBER_AUTHENTICATION_FAILED_)
        }
        let isBigEndian = bytes.get(8)
        let charsetFamily = bytes.get(9)
        let sizeofUChar = bytes.get(10)
        if (Int32(isBigEndian) < 0 || 1 < Int32(isBigEndian) || charsetFamily != CHAR_SET_ || sizeofUChar != CHAR_SIZE_) {
            throw IOException(HEADER_AUTHENTICATION_FAILED_)
        }
        bytes.order(if (Int32(isBigEndian) != 0) { ByteOrder.BIG_ENDIAN } else { ByteOrder.LITTLE_ENDIAN })
        let headerSize = Int32(UInt32(bytes.getChar(0)))
        let sizeofUDataInfo = Int32(UInt32(bytes.getChar(4)))
        if (sizeofUDataInfo < 20 || headerSize < (sizeofUDataInfo + 4)) {
            throw IOException("Internal Error: Header size error")
        }
        let formatVersion = [bytes.get(16), bytes.get(17), bytes.get(18), bytes.get(19)]
        if (bytes.get(12) != UInt8(shr(dataFormat, 24)) || bytes.get(13) != UInt8(shr(dataFormat, 16)) || bytes.get(14) != UInt8(shr(dataFormat, 8)) || bytes.get(15) != UInt8(dataFormat) || (authenticate.isSome() && !authenticate.isDataVersionAcceptable(formatVersion))) {
            throw IOException(HEADER_AUTHENTICATION_FAILED_ + (String.format("; data format %02x%02x%02x%02x, format version %d.%d.%d.%d", [Int8(bytes.get(12)), Int8(bytes.get(13)), Int8(bytes.get(14)), Int8(bytes.get(15)), Int32(formatVersion[0]) & 255, Int32(formatVersion[1]) & 255, Int32(formatVersion[2]) & 255, Int32(formatVersion[3]) & 255])))
        }
        bytes.position(headerSize)
        return (shl(Int32(bytes.get(20)), 24)) | (shl((Int32(bytes.get(21)) & 255), 16)) | (shl((Int32(bytes.get(22)) & 255), 8)) | (Int32(bytes.get(23)) & 255)
    }

    public static func writeHeader(dataFormat: Int32, formatVersion: Int32, dataVersion: Int32, dos: DataOutputStream): Int32 {
        dos.writeChar(32)
        dos.writeByte(Int32(MAGIC1))
        dos.writeByte(Int32(MAGIC2))
        dos.writeChar(20)
        dos.writeChar(0)
        dos.writeByte(1)
        dos.writeByte(Int32(CHAR_SET_))
        dos.writeByte(Int32(CHAR_SIZE_))
        dos.writeByte(0)
        dos.writeInt(dataFormat)
        dos.writeInt(formatVersion)
        dos.writeInt(dataVersion)
        dos.writeLong(0)
        if (!(dos.size() == 32)) {
            throw AssertionError()
        }
        return 32
    }

    public static func skipBytes(bytes: ByteArrayStream, skipLength: Int32): Unit {
        if (skipLength > 0) {
            bytes.position(bytes.position() + skipLength)
        }
    }

    public static func getBytes(bytes: ByteArrayStream, length: Int32, additionalSkipLength: Int32): Array<UInt8> {
        let dest = Array<UInt8>(Int64(length)) { _ => 0 }
        bytes.get(dest)
        if (additionalSkipLength > 0) {
            skipBytes(bytes, additionalSkipLength)
        }
        return dest
    }

    public static func getString(bytes: ByteArrayStream, length: Int32, additionalSkipLength: Int32): String {
        let cs = bytes.asCharBuffer()
        let s: String = toString(cs.subSequence(0, length))
        skipBytes(bytes, length * 2 + additionalSkipLength)
        return s
    }

    public static func getChars(bytes: ByteArrayStream, length: Int32, additionalSkipLength: Int32): Array<Char> {
        let dest = Array<Char>(Int64(length)) { _ => '\u{0000}' }
        bytes.asCharBuffer().get(dest)
        skipBytes(bytes, length * 2 + additionalSkipLength)
        return dest
    }

    public static func getShorts(bytes: ByteArrayStream, length: Int32, additionalSkipLength: Int32): Array<Int16> {
        let dest = Array<Int16>(Int64(length)) { _ => 0 }
        bytes.asShortBuffer().get(dest)
        skipBytes(bytes, length * 2 + additionalSkipLength)
        return dest
    }

    public static func getInts(bytes: ByteArrayStream, length: Int32, additionalSkipLength: Int32): Array<Int32> {
        let dest = Array<Int32>(Int64(length)) { _ => 0 }
        bytes.asIntBuffer().get(dest)
        skipBytes(bytes, length * 4 + additionalSkipLength)
        return dest
    }

    public static func getLongs(bytes: ByteArrayStream, length: Int32, additionalSkipLength: Int32): Array<Int64> {
        let dest = Array<Int64>(Int64(length)) { _ => 0 }
        bytes.asLongBuffer().get(dest)
        skipBytes(bytes, length * 8 + additionalSkipLength)
        return dest
    }

    public static func sliceWithOrder(bytes: ByteArrayStream): ByteArrayStream {
        let b = bytes.slice()
        return b.order(bytes.order())
    }

    public static func getByteArrayStreamFromInputStreamAndCloseStream(isTrue: InputStream): ByteArrayStream {
        try {
            var bytes: Array<UInt8>
            let avail = isTrue.available()
            if (avail > 32) {
                bytes = Array<UInt8>(Int64(avail)) { _ => 0 }
            } else {
                bytes = Array<UInt8>(128) { _ => 0 }
            }
            var length = 0
            while (true) {
                if (length < Int32(bytes.size)) {
                    let numRead = readFixedBufferFromInputStream(isTrue, bytes, length, Int32(bytes.size) - length)
                    if (numRead < 0) {
                        break
                    }
                    length += numRead
                } else {
                    let nextByte = readByteFromInputStream(isTrue)
                    if (nextByte < 0) {
                        break
                    }
                    var capacity = 2 * Int32(bytes.size)
                    if (capacity < 128) {
                        capacity = 128
                    } else if (capacity < 16384) {
                        capacity *= 2
                    }
                    bytes = bytes.clone(0.. capacity)
                    bytes[Int64(match (0) { case _ => length++; length - 1 })] = UInt8(nextByte)
                }
            }
            return ByteArrayStream.wrap(bytes, 0, length)
        } finally {
        }
    }

    public static func getVersionInfoFromCompactInt(version: Int32): VersionInfo {
        return VersionInfo.getInstance(ushr(version, 24), (shr(version, 16)) & 255, (shr(version, 8)) & 255, version & 255)
    }

    public static func getVersionByteArrayFromCompactInt(version: Int32): Array<UInt8> {
        return [UInt8(shr(version, 24)), UInt8(shr(version, 16)), UInt8(shr(version, 8)), UInt8(version)]
    }

    private static let MAGIC1 = 218u8

    private static let MAGIC2 = 39u8

    private static let CHAR_SET_ = 0u8

    private static let CHAR_SIZE_ = 2u8

    private static let MAGIC_NUMBER_AUTHENTICATION_FAILED_ = "ICU data file error: Not an ICU data file"

    private static let HEADER_AUTHENTICATION_FAILED_ = "ICU data file error: Header authentication failed, please check if you have a valid ICU data file"
}


class ICUBinary_DatPackageReader {

    private static let DATA_FORMAT = 1131245124

    private static let IS_ACCEPTABLE = ICUBinary_DatPackageReader_IsAcceptable()

    static func validate(bytes: ByteArrayStream): Bool {
        try {
            ICUBinary.readHeader(bytes, DATA_FORMAT, IS_ACCEPTABLE)
        } catch (ignored: IOException) {
            return false
        }
        let count = bytes.getInt(bytes.position())
        if (count <= 0) {
            return false
        }
        if (bytes.position() + 4 + count * (8 + 16) > bytes.capacity()) {
            return false
        }
        if (!startsWithPackageName(bytes, getNameOffset(bytes, 0)) || !startsWithPackageName(bytes, getNameOffset(bytes, count - 1))) {
            return false
        }
        return true
    }

    private static func startsWithPackageName(bytes: ByteArrayStream, start: Int32): Bool {
        var length = Int32(ICUData.PACKAGE_NAME.size) - 1
        var i = 0
        while (i < length) {
            if (Int32(bytes.get(start + i)) != Int32(UInt32(Char(ICUData.PACKAGE_NAME[Int64(i)])))) {
                return false
            }
            i++
        }
        let c = bytes.get(start + match (0) { case _ => length++; length - 1 })
        if ((Int32(c) != Int32(UInt32('b')) && Int32(c) != Int32(UInt32('l'))) || Int32(bytes.get(start + length)) != Int32(UInt32('/'))) {
            return false
        }
        return true
    }

    static func getData(bytes: ByteArrayStream, key: String): ByteArrayStream {
        let index = binarySearch(bytes, key)
        if (index >= 0) {
            let data = bytes.duplicate()
            data.position(getDataOffset(bytes, index))
            data.limit(getDataOffset(bytes, index + 1))
            return ICUBinary.sliceWithOrder(data)
        } else {
            return None
        }
    }

    static func addBaseNamesInFolder(bytes: ByteArrayStream, folder: String, suffix: String, names: Set<String>): Unit {
        var index = binarySearch(bytes, folder)
        if (index < 0) {
            index = 
        }
        let base = bytes.position()
        let count = bytes.getInt(base)
        let sb = StringBuilder()
        while (index < count && addBaseName(bytes, index, folder, suffix, sb, names)) {
            index++
        }
    }

    private static func binarySearch(bytes: ByteArrayStream, key: String): Int32 {
        let base = bytes.position()
        let count = bytes.getInt(base)
        var start = 0
        var limit = count
        while (start < limit) {
            let mid = ushr((start + limit), 1)
            var nameOffset = getNameOffset(bytes, mid)
            nameOffset += Int32(ICUData.PACKAGE_NAME.size) + 1
            let result = ICUBinary.compareKeys(key, bytes, nameOffset)
            if (result < 0) {
                limit = mid
            } else if (result > 0) {
                start = mid + 1
            } else {
                return mid
            }
        }
        return 
    }

    private static func getNameOffset(bytes: ByteArrayStream, index: Int32): Int32 {
        let base = bytes.position()
        if (!(0 <= index && index < bytes.getInt(base))) {
            throw AssertionError()
        }
        return base + bytes.getInt(base + 4 + index * 8)
    }

    private static func getDataOffset(bytes: ByteArrayStream, index: Int32): Int32 {
        let base = bytes.position()
        let count = bytes.getInt(base)
        if (index == count) {
            return bytes.capacity()
        }
        if (!(0 <= index && index < count)) {
            throw AssertionError()
        }
        return base + bytes.getInt(base + 4 + 4 + index * 8)
    }

    static func addBaseName(bytes: ByteArrayStream, index: Int32, folder: String, suffix: String, sb: StringBuilder, names: Set<String>): Bool {
        var offset = getNameOffset(bytes, index)
        offset += Int32(ICUData.PACKAGE_NAME.size) + 1
        if (Int32(folder.size) != 0) {
            var i = 0
            while (i < Int32(folder.size)) {
                if (Int32(bytes.get(offset)) != Int32(UInt32(Char(folder[Int64(i)])))) {
                    return false
                }
                i++
                offset++
            }
            if (Int32(bytes.get(match (0) { case _ => offset++; offset - 1 })) != Int32(UInt32('/'))) {
                return false
            }
        }
        sb.setLength(0)
        var b: UInt8 = 0
        while ((Int32(match (0) { case _ => b = bytes.get(match (0) { case _ => offset++; offset - 1 }); b })) != 0) {
            let c = Char(b)
            if (c == '/') {
                return true
            }
            sb.append(c)
        }
        let nameLimit = Int32(sb.size) - Int32(suffix.size)
        if (sb.lastIndexOf(suffix, nameLimit) >= 0) {
            names.put(sb.substring(0, nameLimit))
        }
        return true
    }
}


class ICUBinary_DatPackageReader_IsAcceptable <: ICUBinary_Authenticate {

    public override func isDataVersionAcceptable(version: Array<UInt8>): Bool {
        return Int32(version[0]) == 1
    }
}


abstract class ICUBinary_DataFile {
    protected let itemPath: String

    init(item: String) {
        itemPath = item
    }

    public override func toString(): String {
        return itemPath
    }

    public func getData(requestedPath: String): ByteArrayStream

    public func addBaseNamesInFolder(folder: String, suffix: String, names: Set<String>): Unit
}


class ICUBinary_SingleDataFile <: ICUBinary_DataFile {
    private let path: File

    init(item: String, path: File) {
        super(item)
        this.path = path
    }

    public override func toString(): String {
        return toString(path)
    }

    public override func getData(requestedPath: String): ByteArrayStream {
        if (requestedPath.equals(itemPath)) {
            return ICUBinary.mapFile(path)
        } else {
            return None
        }
    }

    public override func addBaseNamesInFolder(folder: String, suffix: String, names: Set<String>): Unit {
        if (Int32(itemPath.size) > Int32(folder.size) + Int32(suffix.size) && itemPath.startsWith(folder) && itemPath.endsWith(suffix) && Char(itemPath[folder.size]) == '/' && indexOfWrap(itemPath.indexOf(UInt8(UInt32('/')), Int64(Int32(folder.size) + 1))) < 0) {
            names.put(itemPath[Int64(Int32(folder.size) + 1)..Int64(Int32(itemPath.size) - Int32(suffix.size))])
        }
    }
}


class ICUBinary_PackageDataFile <: ICUBinary_DataFile {
    private let pkgBytes: ByteArrayStream

    init(item: String, bytes: ByteArrayStream) {
        super(item)
        pkgBytes = bytes
    }

    public override func getData(requestedPath: String): ByteArrayStream {
        return ICUBinary_DatPackageReader.getData(pkgBytes, requestedPath)
    }

    public override func addBaseNamesInFolder(folder: String, suffix: String, names: Set<String>): Unit {
        ICUBinary_DatPackageReader.addBaseNamesInFolder(pkgBytes, folder, suffix, names)
    }
}


public interface ICUBinary_Authenticate {
    public func isDataVersionAcceptable(version: Array<UInt8>): Bool
}