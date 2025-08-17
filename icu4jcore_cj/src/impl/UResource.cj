package icu4cj.impl


public class UResource {
}


public class UResource_Key <: String & Cloneable & Comparable<UResource_Key> {
    private var bytes: Array<UInt8>

    private var offset: Int32 = 0

    private var length: Int32 = 0

    private var s: String

    public init() {
        s = ""
    }

    public init(s: String) {
        setString(s)
    }

    private init(keyBytes: Array<UInt8>, keyOffset: Int32, keyLength: Int32) {
        bytes = keyBytes
        offset = keyOffset
        length = keyLength
    }

    public func setBytes(keyBytes: Array<UInt8>, keyOffset: Int32): UResource_Key {
        bytes = keyBytes
        offset = keyOffset
        length = 0
        while (Int32(keyBytes[Int64(keyOffset + length)]) != 0) {
            length++
        }
        s = None
        return this
    }

    public func setToEmpty(): UResource_Key {
        bytes = None
        offset = match (0) { case _ => length = 0; length }
        s = ""
        return this
    }

    public func setString(s: String): UResource_Key {
        if (s.isEmpty()) {
            setToEmpty()
        } else {
            bytes = Array<UInt8>(s.size) { _ => 0 }
            offset = 0
            length = Int32(s.size)
            var i = 0
            while (i < length) {
                let c = Char(s[Int64(i)])
                if (Int32(UInt32(c)) <= 127) {
                    bytes[Int64(i)] = UInt8(UInt32(c))
                } else {
                    throw IllegalArgumentException('\"'.toString() + (s) + "\" is not an ASCII string")
                }
                i++
            }
            this.s = s
        }
        return this
    }

    public override func clone(): UResource_Key {
        try {
            return super.toString()
        } catch (cannotOccur: CloneNotSupportedException) {
            return None
        }
    }

    public override func charAt(i: Int32): Char {
        if (!(0 <= i && i < length)) {
            throw AssertionError()
        }
        return Char(bytes[Int64(offset + i)])
    }

    public override func lengthMethod(): Int32 {
        return length
    }

    public override func subSequence(start: Int32, end: Int32): UResource_Key {
        if (!(0 <= start && start < length)) {
            throw AssertionError()
        }
        if (!(start <= end && end <= length)) {
            throw AssertionError()
        }
        return UResource_Key(bytes, offset + start, end - start)
    }

    public override func toString(): String {
        if (s.isNone()) {
            s = internalSubString(0, length)
        }
        return s
    }

    private func internalSubString(start: Int32, end: Int32): String {
        let sb = StringBuilder()
        var i = start
        while (i < end) {
            sb.append(Char(bytes[Int64(offset + i)]))
            i++
        }
        return sb.toString()
    }

    public func substring(start: Int32): String {
        if (!(0 <= start && start < length)) {
            throw AssertionError()
        }
        return internalSubString(start, length)
    }

    public func substring(start: Int32, end: Int32): String {
        if (!(0 <= start && start < length)) {
            throw AssertionError()
        }
        if (!(start <= end && end <= length)) {
            throw AssertionError()
        }
        return internalSubString(start, end)
    }

    private func regionMatches(otherBytes: Array<UInt8>, otherOffset: Int32, n: Int32): Bool {
        var i = 0
        while (i < n) {
            if (bytes[Int64(offset + i)] != otherBytes[Int64(otherOffset + i)]) {
                return false
            }
            i++
        }
        return true
    }

    private func regionMatches(start: Int32, cs: String, n: Int32): Bool {
        var i = 0
        while (i < n) {
            if (Int32(bytes[Int64(offset + start + i)]) != Int32(UInt32(cs[i]))) {
                return false
            }
            i++
        }
        return true
    }

    public override func equals(other: Object): Bool {
        if (other.isNone()) {
            return false
        } else if (refEq(this, other)) {
            return true
        } else if (checkOptionalIs<UResource_Key, Object>(other)) {
            let otherKey = other
            return length == otherKey.length && regionMatches(otherKey.bytes, otherKey.offset, length)
        } else {
            return false
        }
    }

    public func contentEquals(cs: String): Bool {
        if (cs.isNone()) {
            return false
        }
        return refEq(this, cs) || (cs.size == length && regionMatches(0, cs, length))
    }

    public func startsWith(cs: String): Bool {
        let csLength = cs.size
        return csLength <= length && regionMatches(0, cs, csLength)
    }

    public func endsWith(cs: String): Bool {
        let csLength = cs.size
        return csLength <= length && regionMatches(length - csLength, cs, csLength)
    }

    public func regionMatches(start: Int32, cs: String): Bool {
        let csLength = cs.size
        return csLength == (length - start) && regionMatches(start, cs, csLength)
    }

    public override func hashCode(): Int64 {
        if (length == 0) {
            return 0
        }
        var h = Int32(bytes[Int64(offset)])
        var i = 1
        while (i < length) {
            h = 37 * h + Int32(bytes[Int64(offset)])
            i++
        }
        return Int64(h)
    }

    public override func compareTo(other: UResource_Key): Int32 {
        return compareTo(other)
    }

    public func compareTo(cs: String): Int32 {
        let csLength = cs.size
        let minLength = if (length <= csLength) { length } else { csLength }
        var i = 0
        while (i < minLength) {
            let diff = 
            if (diff != 0) {
                return diff
            }
            i++
        }
        return length - csLength
    }
}


public interface UResource_Array {
    public func getSize(): Int32

    public func getValue(i: Int32, value: UResource_Value): Bool
}

public interface UResource_Table {
    public func getSize(): Int32

    public func getKeyAndValue(i: Int32, key: UResource_Key, value: UResource_Value): Bool

    public func findValue(key: String, value: UResource_Value): Bool
}

public abstract class UResource_Value {

    public func getType(): Int32

    public func getString(): String

    public func getAliasString(): String

    public func getInt(): Int32

    public func getUInt(): Int32

    public func getIntVector(): Array<Int32>

    public func getBinary(): ByteArrayStream

    public func getArray(): UResource_Array

    public func getTable(): UResource_Table

    public func isNoInheritanceMarker(): Bool

    public func getStringArray(): Array<String>

    public func getStringArrayOrStringAsArray(): Array<String>

    public func getStringOrFirstOfArray(): String

    public override func toString(): String {
        match (getType()) {
            case 0 => return getString()
            case 7 => return getInt().toString()
            case 14 =>
                let iv = getIntVector()
                let sb = StringBuilder("[")
                sb.append(Int32(iv.size)).append("]{")
                if (Int32(iv.size) != 0) {
                    sb.append(iv[0])
                    var i = 1
                    while (i < Int32(iv.size)) {
                        sb.append(", ").append(iv[Int64(i)])
                        i++
                    }
                }
                return sb.append('}').toString()
            case 1 => return "(binary blob)"
            case 8 => return "(array)"
            case 2 => return "(table)"
            case _ => return "???"
        }
    }
}


public abstract class UResource_Sink {

    public func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit
}
