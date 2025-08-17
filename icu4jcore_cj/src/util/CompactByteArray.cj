package icu4cj.util


public class CompactByteArray <: Cloneable {
    
    public static let UNICODECOUNT = 65536

    
    public init() {
        this(0)
    }

    
    public init(defaultValue: UInt8) {
        var i: Int32 = 0
        values = Array<UInt8>(Int64(UNICODECOUNT)) { _ => 0 }
        indices = Array<Char>(Int64(INDEXCOUNT)) { _ => '\u{0000}' }
        hashes = Array<Int32>(Int64(INDEXCOUNT)) { _ => 0 }
        i = 0
        while (i < UNICODECOUNT) {
            values[Int64(i)] = defaultValue
            i++
        }
        i = 0
        while (i < INDEXCOUNT) {
            indices[Int64(i)] = Char(shl(i, BLOCKSHIFT))
            hashes[Int64(i)] = 0
            i++
        }
        isCompact = false
        this.defaultValue = defaultValue
    }

    
    public init(indexArray: Array<Char>, newValues: Array<UInt8>) {
        var i: Int32 = 0
        if (Int32(indexArray.size) != INDEXCOUNT) {
            throw IllegalArgumentException("Index out of bounds.")
        }
        i = 0
        while (i < INDEXCOUNT) {
            let index = indexArray[Int64(i)]
            if (Int32(UInt32(index)) >= Int32(newValues.size) + BLOCKCOUNT) {
                throw IllegalArgumentException("Index out of bounds.")
            }
            i++
        }
        indices = indexArray
        values = newValues
        isCompact = true
    }

    
    public init(indexArray: String, valueArray: String) {
        this(Utility.RLEStringToCharArray(indexArray), Utility.RLEStringToByteArray(valueArray))
    }

    
    public func elementAt(index: Char): UInt8 {
        return (values[Int64((Int32(UInt32(indices[Int64(shr(Int32(UInt32(index)), BLOCKSHIFT))])) & 65535) + (Int32(UInt32(index)) & BLOCKMASK))])
    }

    
    public func setElementAt(index: Char, value: UInt8): Unit {
        if (isCompact) {
            expand()
        }
        values[Int64(UInt32(index))] = value
        touchBlock(shr(Int32(UInt32(index)), BLOCKSHIFT), Int32(value))
    }

    
    public func setElementAt(start: Char, end: Char, value: UInt8): Unit {
        var i: Int32 = 0
        if (isCompact) {
            expand()
        }
        i = Int32(UInt32(start))
        while (i <= Int32(UInt32(end))) {
            values[Int64(i)] = value
            touchBlock(shr(i, BLOCKSHIFT), Int32(value))
            i++
        }
    }

    
    public func compact(): Unit {
        compact(false)
    }

    
    public func compact(exhaustive: Bool): Unit {
        if (!isCompact) {
            var limitCompacted = 0
            var iBlockStart = 0
            var iUntouched = Char(65535)
            var i = 0
            while (i < Int32(indices.size)) {
                indices[Int64(i)] = Char(65535)
                let touched = blockTouched(i)
                if (!touched && Int32(UInt32(iUntouched)) != 65535) {
                    indices[Int64(i)] = iUntouched
                } else {
                    var jBlockStart = 0
                    var j = 0
                    j = 0
                    while (j < limitCompacted) {
                        if (hashes[Int64(i)] == hashes[Int64(j)] && arrayRegionMatches(values, iBlockStart, values, jBlockStart, BLOCKCOUNT)) {
                            indices[Int64(i)] = Char(jBlockStart)
                            break
                        }
                        j++
                        jBlockStart += BLOCKCOUNT
                    }
                    if (Int32(UInt32(indices[Int64(i)])) == 65535) {
                        arraycopy(values, Int64(iBlockStart), values, Int64(jBlockStart), Int64(BLOCKCOUNT))
                        indices[Int64(i)] = Char(jBlockStart)
                        hashes[Int64(j)] = hashes[Int64(i)]
                        limitCompacted++
                        if (!touched) {
                            iUntouched = Char(jBlockStart)
                        }
                    }
                }
                i++
                iBlockStart += BLOCKCOUNT
            }
            let newSize = limitCompacted * BLOCKCOUNT
            let result = Array<UInt8>(Int64(newSize)) { _ => 0 }
            arraycopy(values, 0, result, 0, Int64(newSize))
            values = result
            isCompact = true
            hashes = None
        }
    }

    static func arrayRegionMatches(source: Array<UInt8>, sourceStart: Int32, target: Array<UInt8>, targetStart: Int32, len: Int32): Bool {
        let sourceEnd = sourceStart + len
        let delta = targetStart - sourceStart
        var i = sourceStart
        while (i < sourceEnd) {
            if (source[Int64(i)] != target[Int64(i + delta)]) {
                return false
            }
            i++
        }
        return true
    }

    private func touchBlock(i: Int32, value: Int32): Unit {
        hashes[Int64(i)] = (hashes[Int64(i)] + (shl(value, 1))) | 1
    }

    private func blockTouched(i: Int32): Bool {
        return hashes[Int64(i)] != 0
    }

    
    public func getIndexArray(): Array<Char> {
        return indices
    }

    
    public func getValueArray(): Array<UInt8> {
        return values
    }

    
    public override func clone(): Object {
        try {
            let other = super.toString()
            other.values = values.clone()
            other.indices = indices.clone()
            if (hashes.isSome()) {
                other.hashes = hashes.clone()
            }
            return other
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException(e as Exception)
        }
    }

    
    public override func equals(obj: Object): Bool {
        if (obj.isNone()) {
            return false
        }
        if (refEq(this, obj)) {
            return true
        }
        if (!refEq(TypeInfo.of(this), TypeInfo.of(obj))) {
            return false
        }
        let other = obj
        var i = 0
        while (i < UNICODECOUNT) {
            if (elementAt(Char(i)) != other.elementAt(Char(i))) {
                return false
            }
            i++
        }
        return true
    }

    
    public override func hashCode(): Int64 {
        var result = 0
        let increment = min(3, Int32(values.size) / 16)
        var i = 0
        while (i < Int32(values.size)) {
            result = result * 37 + Int32(values[Int64(i)])
            i += increment
        }
        return Int64(result)
    }

    private func expand(): Unit {
        var i: Int32 = 0
        if (isCompact) {
            let tempArray: Array<UInt8>
            hashes = Array<Int32>(Int64(INDEXCOUNT)) { _ => 0 }
            tempArray = Array<UInt8>(Int64(UNICODECOUNT)) { _ => 0 }
            i = 0
            while (i < UNICODECOUNT) {
                let value = elementAt(Char(i))
                tempArray[Int64(i)] = value
                touchBlock(shr(i, BLOCKSHIFT), Int32(value))
                i++
            }
            i = 0
            while (i < INDEXCOUNT) {
                indices[Int64(i)] = Char(shl(i, BLOCKSHIFT))
                i++
            }
            values = None
            values = tempArray
            isCompact = false
        }
    }

    private static let BLOCKSHIFT = 7

    private static let BLOCKCOUNT = (shl(1, BLOCKSHIFT))

    private static let INDEXSHIFT = (16 - BLOCKSHIFT)

    private static let INDEXCOUNT = (shl(1, INDEXSHIFT))

    private static let BLOCKMASK = BLOCKCOUNT - 1

    private var values: Array<UInt8>

    private var indices: Array<Char>

    private var hashes: Array<Int32>

    private var isCompact: Bool = false

    var defaultValue: UInt8 = 0
}
