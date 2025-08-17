package icu4cj.util


public class ByteArrayWrapper <: Comparable<ByteArrayWrapper> {
    public var bytes: Array<UInt8>

    public var size: Int32 = 0


    public init(bytesToAdopt: Array<UInt8>, size: Int32) {
        if ((bytesToAdopt.isNone() && size != 0) || size < 0 || (bytesToAdopt.isSome() && size > Int32(bytesToAdopt.size))) {
            throw IndexOutOfBoundsException("illegal size: " + size.toString())
        }
        this.bytes = bytesToAdopt
        this.size = size
    }

    public init(source: ByteArrayStream) {
        size = source.limit()
        bytes = Array<UInt8>(Int64(size)) { _ => 0 }
        source.get(bytes, 0, size)
    }

    public func ensureCapacity(capacity: Int32): ByteArrayWrapper {
        if (bytes.isNone() || Int32(bytes.size) < capacity) {
            let newbytes = Array<UInt8>(Int64(capacity)) { _ => 0 }
            if (bytes.isSome()) {
                copyBytes(bytes, 0, newbytes, 0, size)
            }
            bytes = newbytes
        }
        return this
    }

    public func set(src: Array<UInt8>, start: Int32, limit: Int32): ByteArrayWrapper {
        size = 0
        append(src, start, limit)
        return this
    }

    public func append(src: Array<UInt8>, start: Int32, limit: Int32): ByteArrayWrapper {
        let len = limit - start
        ensureCapacity(size + len)
        copyBytes(src, start, bytes, size, len)
        size += len
        return this
    }

    public func releaseBytes(): Array<UInt8> {
        let result = bytes
        bytes = None
        size = 0
        return result
    }

    public override func toString(): String {
        let result = StringBuilder()
        var i = 0
        while (i < size) {
            if (i != 0) {
                result.append(" ")
            }
            result.append(Utility.hex(Int64(Int32(bytes[Int64(i)]) & 255), 2))
            i++
        }
        return result.toString()
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (other.isNone()) {
            return false
        }
        @AssertThrows[ClassCastException]({
            let that = other
            if (size != that.size) {
                return false
            }
            var i = 0
            while (i < size) {
                if (bytes[Int64(i)] != that.bytes[Int64(i)]) {
                    return false
                }
                i++
            }
            return true
        })
        return false
    }

    public override func hashCode(): Int64 {
        var result = size
        var i = 0
        while (i < size) {
            result = 37 * result + Int32(bytes[Int64(i)])
            i++
        }
        return Int64(result)
    }

    public override func compareTo(other: ByteArrayWrapper): Int32 {
        if (refEq(this, other)) {
            return 0
        }
        let minSize = if (size < other.size) { size } else { other.size }
        var i = 0
        while (i < minSize) {
            if (bytes[Int64(i)] != other.bytes[Int64(i)]) {
                return (Int32(bytes[Int64(i)]) & 255) - (Int32(other.bytes[Int64(i)]) & 255)
            }
            i++
        }
        return size - other.size
    }

    private static func copyBytes(src: Array<UInt8>, srcoff: Int32, tgt: Array<UInt8>, tgtoff: Int32, length: Int32): Unit {
        var templength = length
        if (templength < 64) {
            var i = srcoff
            var n = tgtoff
            while (match (0) { case _ => templength--; templength } >= 0) {
                tgt[Int64(n)] = src[Int64(i)]
                i++
                n++
            }
        } else {
            arraycopy(src, Int64(srcoff), tgt, Int64(tgtoff), Int64(templength))
        }
    }
}
