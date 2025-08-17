package icu4cj.impl

public class USerializedSet {

    public func getSet(src: Array<Char>, srcStart: Int32): Bool {
        var tempsrcStart = srcStart
        array = None
        arrayOffset = match (0) { case _ => bmpLength = match (0) { case _ => length = 0; length }; bmpLength }
        length = Int32(UInt32(src[Int64(match (0) { case _ => tempsrcStart++; tempsrcStart - 1 })]))
        if ((length & 32768) != 0) {
            length &= 32767
            if (Int32(src.size) < (tempsrcStart + 1 + length)) {
                length = 0
                throw IndexOutOfBoundsException()
            }
            bmpLength = Int32(UInt32(src[Int64(match (0) { case _ => tempsrcStart++; tempsrcStart - 1 })]))
        } else {
            if (Int32(src.size) < (tempsrcStart + length)) {
                length = 0
                throw IndexOutOfBoundsException()
            }
            bmpLength = length
        }
        array = Array<Char>(Int64(length)) { _ => '\u{0000}' }
        arraycopy(src, Int64(tempsrcStart), array, 0, Int64(length))
        return true
    }

    public func setToOne(c: Int32): Unit {
        var tempc = c
        if (1114111 < tempc) {
            return
        }
        if (tempc < 65535) {
            bmpLength = match (0) { case _ => length = 2; length }
            array[0] = Char(tempc)
            array[1] = Char(tempc + 1)
        } else if (tempc == 65535) {
            bmpLength = 1
            length = 3
            array[0] = Char(65535)
            array[1] = Char(1)
            array[2] = Char(0)
        } else if (tempc < 1114111) {
            bmpLength = 0
            length = 4
            array[0] = Char(shr(tempc, 16))
            array[1] = Char(tempc)
            tempc++
            array[2] = Char(shr(tempc, 16))
            array[3] = Char(tempc)
        } else {
            bmpLength = 0
            length = 2
            array[0] = Char(16)
            array[1] = Char(65535)
        }
    }

    public func getRange(rangeIndex: Int32, range: Array<Int32>): Bool {
        var temprangeIndex = rangeIndex
        if (temprangeIndex < 0) {
            return false
        }
        if (array.isNone()) {
            array = Array<Char>(8) { _ => '\u{0000}' }
        }
        if (range.isNone() || Int32(range.size) < 2) {
            throw IllegalArgumentException()
        }
        temprangeIndex *= 2
        if (temprangeIndex < bmpLength) {
            range[0] = Int32(UInt32(array[Int64(match (0) { case _ => temprangeIndex++; temprangeIndex - 1 })]))
            if (temprangeIndex < bmpLength) {
                range[1] = Int32(UInt32(array[Int64(temprangeIndex)])) - 1
            } else if (temprangeIndex < length) {
                range[1] = ((shl(Int32(UInt32(array[Int64(temprangeIndex)])), 16)) | Int32(UInt32(array[Int64(temprangeIndex + 1)]))) - 1
            } else {
                range[1] = 1114111
            }
            return true
        } else {
            temprangeIndex -= bmpLength
            temprangeIndex *= 2
            let suppLength = length - bmpLength
            if (temprangeIndex < suppLength) {
                let offset = arrayOffset + bmpLength
                range[0] = (shl(Int32(UInt32(array[Int64(offset + temprangeIndex)])), 16)) | Int32(UInt32(array[Int64(offset + temprangeIndex + 1)]))
                temprangeIndex += 2
                if (temprangeIndex < suppLength) {
                    range[1] = ((shl(Int32(UInt32(array[Int64(offset + temprangeIndex)])), 16)) | Int32(UInt32(array[Int64(offset + temprangeIndex + 1)]))) - 1
                } else {
                    range[1] = 1114111
                }
                return true
            } else {
                return false
            }
        }
    }

    public func contains(c: Int32): Bool {
        if (c > 1114111) {
            return false
        }
        if (c <= 65535) {
            var i: Int32 = 0
            i = 0
            while (i < bmpLength && Char(c) >= array[Int64(i)]) {
                i++
            }
            return ((i & 1) != 0)
        } else {
            var i: Int32 = 0
            let high = Char(shr(c, 16))
            let low = Char(c)
            i = bmpLength
            while (i < length && (high > array[Int64(i)] || (high == array[Int64(i)] && low >= array[Int64(i + 1)]))) {
                i += 2
            }
            return (((i + bmpLength) & 2) != 0)
        }
    }

    public func countRanges(): Int32 {
        return (bmpLength + (length - bmpLength) / 2 + 1) / 2
    }

    private var array: Array<Char> = Array<Char>(8) { _ => '\u{0000}' }

    private var arrayOffset: Int32 = 0

    private var bmpLength: Int32 = 0

    private var length: Int32 = 0
}
