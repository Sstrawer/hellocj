package icu4cj.impl

public class Trie2_16 <: Trie2 {
    init() {
        super()
    }

    public static func createFromSerialized(bytes: ByteArrayStream): Trie2_16 {
        return Trie2.createFromSerialized(bytes)
    }

    public override func get(codePoint: Int32): Int32 {
        let value: Int32
        var ix: Int32 = 0
        if (codePoint >= 0) {
            if (codePoint < 55296 || (codePoint > 56319 && codePoint <= 65535)) {
                ix = Int32(UInt32(index[Int64(shr(codePoint, UTRIE2_SHIFT_2))]))
                ix = (shl(ix, UTRIE2_INDEX_SHIFT)) + (codePoint & UTRIE2_DATA_MASK)
                value = Int32(UInt32(index[Int64(ix)]))
                return value
            }
            if (codePoint <= 65535) {
                ix = Int32(UInt32(index[Int64(UTRIE2_LSCP_INDEX_2_OFFSET + (shr((codePoint - 55296), UTRIE2_SHIFT_2)))]))
                ix = (shl(ix, UTRIE2_INDEX_SHIFT)) + (codePoint & UTRIE2_DATA_MASK)
                value = Int32(UInt32(index[Int64(ix)]))
                return value
            }
            if (codePoint < highStart) {
                ix = (UTRIE2_INDEX_1_OFFSET - UTRIE2_OMITTED_BMP_INDEX_1_LENGTH) + (shr(codePoint, UTRIE2_SHIFT_1))
                ix = Int32(UInt32(index[Int64(ix)]))
                ix += (shr(codePoint, UTRIE2_SHIFT_2)) & UTRIE2_INDEX_2_MASK
                ix = Int32(UInt32(index[Int64(ix)]))
                ix = (shl(ix, UTRIE2_INDEX_SHIFT)) + (codePoint & UTRIE2_DATA_MASK)
                value = Int32(UInt32(index[Int64(ix)]))
                return value
            }
            if (codePoint <= 1114111) {
                value = Int32(UInt32(index[Int64(highValueIndex)]))
                return value
            }
        }
        return errorValue
    }

    public override func getFromU16SingleLead(codeUnit: Char): Int32 {
        let value: Int32
        var ix: Int32 = 0
        ix = Int32(UInt32(index[Int64(shr(Int32(UInt32(codeUnit)), UTRIE2_SHIFT_2))]))
        ix = (shl(ix, UTRIE2_INDEX_SHIFT)) + (Int32(UInt32(codeUnit)) & UTRIE2_DATA_MASK)
        value = Int32(UInt32(index[Int64(ix)]))
        return value
    }

    public func serialize(os: OutputStream): Int32 {
        let dos = DataOutputStream(os)
        var bytesWritten = 0
        bytesWritten += serializeHeader(dos)
        var i = 0
        while (i < dataLength) {
            dos.writeChar(Int32(UInt32(index[Int64(data16 + i)])))
            i++
        }
        bytesWritten += dataLength * 2
        return bytesWritten
    }

    public func getSerializedLength(): Int32 {
        return 16 + (header.indexLength + dataLength) * 2
    }

    public override func rangeEnd(startingCP: Int32, limit: Int32, value: Int32): Int32 {
        var cp = startingCP
        var block = 0
        var index2Block = 0
