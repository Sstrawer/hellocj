package icu4cj.util


public class CompactCharArray <: Cloneable {
    
    public static let UNICODECOUNT = 65536

    
    public init() {
        this(Char(0))
    }

    
    public init(defaultValue: Char) {
        var i: Int32 = 0
        values = Array<Char>(Int64(UNICODECOUNT)) { _ => '\u{0000}' }
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

    
    public init(indexArray: Array<Char>, newValues: Array<Char>) {
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
        this(Utility.RLEStringToCharArray(indexArray), Utility.RLEStringToCharArray(valueArray))
    }

    
    public func elementAt(index: Char): Char {
        let ix = (Int32(UInt32(indices[Int64(shr(Int32(UInt32(index)), BLOCKSHIFT))])) & 65535) + (Int32(UInt32(index)) & BLOCKMASK)
        return if (ix >= Int32(values.size)) { defaultValue } else { values[Int64(ix)] }
    }

    
    public func setElementAt(index: Char, value: Char): Unit {
        if (isCompact) {
            expand()
        }
        values[Int64(UInt32(index))] = value
        touchBlock(shr(Int32(UInt32(index)), BLOCKSHIFT), Int32(UInt32(value)))
    }

    
    public func setElementAt(start: Char, end: Char, value: Char): Unit {
        var i: Int32 = 0
        if (isCompact) {
            expand()
        }
        i = Int32(UInt32(start))
        while (i <= Int32(UInt32(end))) {
            values[Int64(i)] = value
            touchBlock(shr(i, BLOCKSHIFT), Int32(UInt32(value)))
            i++
        }
    }

    
    public func compact(): Unit {
        compact(true)
    }

    
    public func compact(exhaustive: Bool): Unit {
        if (!isCompact) {
            var iBlockStart = 0
            var iUntouched = Char(65535)
            var newSize = 0
            let target = if (exhaustive) { Some(Array<Char>(Int64(UNICODECOUNT)) { _ => '\u{0000}' }) } else { values }
            var i = 0
            while (i < Int32(indices.size)) {
                indices[Int64(i)] = Char(65535)
                let touched = blockTouched(i)
                if (!touched && Int32(UInt32(iUntouched)) != 65535) {
                    indices[Int64(i)] = iUntouched
                } else {
                    var jBlockStart = 0
                            j++
                            jBlockStart += BLOCKCOUNT
                        }
                    } while (false)
                    if (Int32(UInt32(indices[Int64(i)])) == 65535) {
                        let dest: Int32
                        if (exhaustive) {
                            dest = FindOverlappingPosition(iBlockStart, target, newSize)
                        } else {
                            dest = newSize
                        }
                        let limit = dest + BLOCKCOUNT
                        if (limit > newSize) {
                            } while (false)
                            newSize = limit
                        }
                        indices[Int64(i)] = Char(dest)
                        if (!touched) {
                            iUntouched = Char(jBlockStart)
                        }
                    }
                }
                i++
                iBlockStart += BLOCKCOUNT
            }
            let result = Array<Char>(Int64(newSize)) { _ => '\u{0000}' }
            arraycopy(target, 0, result, 0, Int64(newSize))
            values = result
            isCompact = true
            hashes = None
        }
    }

    private func FindOverlappingPosition(start: Int32, tempValues: Array<Char>, tempCount: Int32): Int32 {
        var i = 0
        while (i < tempCount) {
            var currentCount = BLOCKCOUNT
            if (i + BLOCKCOUNT > tempCount) {
                currentCount = tempCount - i
            }
            if (arrayRegionMatches(values, start, tempValues, i, currentCount)) {
                return i
            }
            i += 1
        }
        return tempCount
    }

    static func arrayRegionMatches(source: Array<Char>, sourceStart: Int32, target: Array<Char>, targetStart: Int32, len: Int32): Bool {
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

    
    public func getValueArray(): Array<Char> {
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
            result = result * 37 + Int32(UInt32(values[Int64(i)]))
            i += increment
        }
        return Int64(result)
    }

    private func expand(): Unit {
        var i: Int32 = 0
        if (isCompact) {
            let tempArray: Array<Char>
            hashes = Array<Int32>(Int64(INDEXCOUNT)) { _ => 0 }
            tempArray = Array<Char>(Int64(UNICODECOUNT)) { _ => '\u{0000}' }
            i = 0
            while (i < UNICODECOUNT) {
                tempArray[Int64(i)] = elementAt(Char(i))
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

    
    public static let BLOCKSHIFT = 5

    static let BLOCKCOUNT = (shl(1, BLOCKSHIFT))

    static let INDEXSHIFT = (16 - BLOCKSHIFT)

    static let INDEXCOUNT = (shl(1, INDEXSHIFT))

    static let BLOCKMASK = BLOCKCOUNT - 1

    private var values: Array<Char>

    private var indices: Array<Char>

    private var hashes: Array<Int32>

    private var isCompact: Bool = false

    var defaultValue: Char = '\u{0000}'
}
