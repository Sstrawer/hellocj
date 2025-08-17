package icu4cj.impl

public class StringPrepDataReader <: ICUBinary_Authenticate {
    private static let debug = ICUDebug.enabled("NormalizerDataReader")

    public init(bytes: ByteArrayStream) {
        if (debug) {
            println("Bytes in buffer " + bytes.remaining().toString())
        }
        byteBuffer = bytes
        unicodeVersion = ICUBinary.readHeader(byteBuffer, DATA_FORMAT_ID, this)
        if (debug) {
            println("Bytes left in byteBuffer " + byteBuffer.remaining().toString())
        }
    }

    public func read(length: Int32): Array<Char> {
        return ICUBinary.getChars(byteBuffer, length, 0)
    }

    public override func isDataVersionAcceptable(version: Array<UInt8>): Bool {
        return version[0] == DATA_FORMAT_VERSION[0] && version[2] == DATA_FORMAT_VERSION[2] && version[3] == DATA_FORMAT_VERSION[3]
    }

    public func readIndexes(length: Int32): Array<Int32> {
        let indexes = Array<Int32>(Int64(length)) { _ => 0 }
        var i = 0
        while (i < length) {
            indexes[Int64(i)] = byteBuffer.getInt()
            i++
        }
        return indexes
    }

    public func getUnicodeVersion(): Array<UInt8> {
        return ICUBinary.getVersionByteArrayFromCompactInt(unicodeVersion)
    }

    private var byteBuffer: ByteArrayStream = None

    private var unicodeVersion: Int32 = 0

    private static let DATA_FORMAT_ID = 1397772880

    private static let DATA_FORMAT_VERSION = [3u8, 2u8, 5u8, 2u8]
}
