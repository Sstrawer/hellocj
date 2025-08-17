package icu4cj.util


public abstract class CodePointTrie <: CodePointMap {
    init(index: Array<Char>, data: CodePointTrie_Data, highStart: Int32, index3NullOffset: Int32, dataNullOffset: Int32) {
        super()
        this.ascii = Array<Int32>(Int64(ASCII_LIMIT)) { _ => 0 }
        this.index = index
        this.data = data
        this.dataLength = data.getDataLength()
        this.highStart = highStart
        this.index3NullOffset = index3NullOffset
        this.dataNullOffset = dataNullOffset
        var c = 0
        while (c < ASCII_LIMIT) {
            ascii[Int64(c)] = data.getFromIndex(c)
            c++
        }
        var nullValueOffset = dataNullOffset
        if (nullValueOffset >= dataLength) {
            nullValueOffset = dataLength - HIGH_VALUE_NEG_DATA_OFFSET
        }
        nullValue = data.getFromIndex(nullValueOffset)
    }

    public static func fromBinary(Type: CodePointTrie_Type, valueWidth: CodePointTrie_ValueWidth, bytes: ByteArrayStream): CodePointTrie {
        var temptype = Type
        var tempvalueWidth = valueWidth
        let outerByteOrder = bytes.order()
        try {
            if (bytes.remaining() < 16) {
                throw ICUUncheckedIOException("Buffer too short for a CodePointTrie header")
            }
            var signature = bytes.getInt()
            match (signature) {
                case 1416784179 => ()
                case 862548564 =>
                    let isBigEndian = refEq(outerByteOrder, ByteOrder.BIG_ENDIAN)
                    bytes.order(if (isBigEndian) { ByteOrder.LITTLE_ENDIAN } else { ByteOrder.BIG_ENDIAN })
                    signature = 1416784179
                case _ => throw ICUUncheckedIOException("Buffer does not contain a serialized CodePointTrie")
            }
            let options = Int32(UInt32(bytes.getChar()))
            let indexLength = Int32(UInt32(bytes.getChar()))
            var dataLength = Int32(UInt32(bytes.getChar()))
            let index3NullOffset = Int32(UInt32(bytes.getChar()))
            var dataNullOffset = Int32(UInt32(bytes.getChar()))
            let shiftedHighStart = Int32(UInt32(bytes.getChar()))
            let typeInt = (shr(options, 6)) & 3
            let actualType: CodePointTrie_Type
            match (typeInt) {
                case 0 => actualType = CodePointTrie_Type.FAST
                case 1 => actualType = CodePointTrie_Type.SMALL
                case _ => throw ICUUncheckedIOException("CodePointTrie data header has an unsupported type")
            }
            let valueWidthInt = options & OPTIONS_VALUE_BITS_MASK
            let actualValueWidth: CodePointTrie_ValueWidth
            match (valueWidthInt) {
                case 0 => actualValueWidth = CodePointTrie_ValueWidth.BITS_16
                case 1 => actualValueWidth = CodePointTrie_ValueWidth.BITS_32
                case 2 => actualValueWidth = CodePointTrie_ValueWidth.BITS_8
                case _ => throw ICUUncheckedIOException("CodePointTrie data header has an unsupported value width")
            }
            if ((options & OPTIONS_RESERVED_MASK) != 0) {
                throw ICUUncheckedIOException("CodePointTrie data header has unsupported options")
            }
            if (temptype.isNone()) {
                temptype = actualType
            }
            if (tempvalueWidth.isNone()) {
                tempvalueWidth = actualValueWidth
            }
            if (!refEq(temptype, actualType) || !refEq(tempvalueWidth, actualValueWidth)) {
                throw ICUUncheckedIOException("CodePointTrie data header has a different type or value width than required")
            }
            dataLength |= (shl((options & OPTIONS_DATA_LENGTH_MASK), 4))
            dataNullOffset |= (shl((options & OPTIONS_DATA_NULL_OFFSET_MASK), 8))
            let highStart = shl(shiftedHighStart, SHIFT_2)
            var actualLength = indexLength * 2
            if (refEq(tempvalueWidth, CodePointTrie_ValueWidth.BITS_16)) {
                actualLength += dataLength * 2
            } else if (refEq(tempvalueWidth, CodePointTrie_ValueWidth.BITS_32)) {
                actualLength += dataLength * 4
            } else {
                actualLength += dataLength
            }
            if (bytes.remaining() < actualLength) {
                throw ICUUncheckedIOException("Buffer too short for the CodePointTrie data")
            }
            let index = ICUBinary.getChars(bytes, indexLength, 0)
            match (tempvalueWidth) {
                case CodePointTrie_ValueWidth.BITS_16 =>
                    let data16 = ICUBinary.getChars(bytes, dataLength, 0)
                    return if (refEq(temptype, CodePointTrie_Type.FAST)) { CodePointTrie_Fast16(index, data16, highStart, index3NullOffset, dataNullOffset) } else { CodePointTrie_Small16(index, data16, highStart, index3NullOffset, dataNullOffset) }
                case CodePointTrie_ValueWidth.BITS_32 =>
                    let data32 = ICUBinary.getInts(bytes, dataLength, 0)
                    return if (refEq(temptype, CodePointTrie_Type.FAST)) { CodePointTrie_Fast32(index, data32, highStart, index3NullOffset, dataNullOffset) } else { CodePointTrie_Small32(index, data32, highStart, index3NullOffset, dataNullOffset) }
                case CodePointTrie_ValueWidth.BITS_8 =>
                    let data8 = ICUBinary.toArray() // bytes, dataLength, 0)
                    return if (refEq(temptype, CodePointTrie_Type.FAST)) { CodePointTrie_Fast8(index, data8, highStart, index3NullOffset, dataNullOffset) } else { CodePointTrie_Small8(index, data8, highStart, index3NullOffset, dataNullOffset) }
                case _ => throw Exception("should be unreachable")
            }
        } finally {
            bytes.order(outerByteOrder)
        }
    }

    public func getType(): CodePointTrie_Type

    public func getValueWidth(): CodePointTrie_ValueWidth {
        return data.getValueWidth()
    }

    public override func get(c: Int32): Int32 {
        return data.getFromIndex(cpIndex(c))
    }

    public func asciiGet(c: Int32): Int32 {
        return ascii[Int64(c)]
    }

    private static let MAX_UNICODE = 1114111

    private static let ASCII_LIMIT = 128

    private static func maybeFilterValue(value: Int32, trieNullValue: Int32, nullValue: Int32, filter: CodePointMap_ValueFilter): Int32 {
        var tempvalue = value
        if (tempvalue == trieNullValue) {
            tempvalue = nullValue
        } else if (filter.isSome()) {
            tempvalue = filter.apply(tempvalue)
        }
        return tempvalue
    }

    public override func getRange(start: Int32, filter: CodePointMap_ValueFilter, range: CodePointMap_Range): Bool {
        if (start < 0 || MAX_UNICODE < start) {
            return false
        }
        if (start >= highStart) {
            let di = dataLength - HIGH_VALUE_NEG_DATA_OFFSET
            var value = data.getFromIndex(di)
            if (filter.isSome()) {
                value = filter.apply(value)
            }
            range.set(start, MAX_UNICODE, value)
            return true
        }
        var nullValue = this.nullValue
        if (filter.isSome()) {
            nullValue = filter.apply(nullValue)
        }
        let Type = getType()
        var prevI3Block = -1
        var prevBlock = -1
        var c = start
        var trieValue = 0
        var value = 0
        var haveValue = false
                var i1 = shr(c, SHIFT_1)
                if (refEq(Type, CodePointTrie_Type.FAST)) {
                    if (!(65535 < c && c < highStart)) {
                        throw AssertionError()
                    }
                    i1 += BMP_INDEX_LENGTH - OMITTED_BMP_INDEX_1_LENGTH
                } else {
                    if (!(c < highStart && highStart > SMALL_LIMIT)) {
                        throw AssertionError()
                    }
                    i1 += SMALL_INDEX_LENGTH
                }
                i3Block = Int32(UInt32(index[Int64(Int32(UInt32(index[Int64(i1)])) + ((shr(c, SHIFT_2)) & INDEX_2_MASK))]))
                if (i3Block == prevI3Block && (c - start) >= CP_PER_INDEX_2_ENTRY) {
                    if (!((c & (CP_PER_INDEX_2_ENTRY - 1)) == 0)) {
                        throw AssertionError()
                    }
                    c += CP_PER_INDEX_2_ENTRY
                    continue
                }
                prevI3Block = i3Block
                if (i3Block == index3NullOffset) {
                    if (haveValue) {
                        if (nullValue != value) {
                            range.set(start, c - 1, value)
                            return true
                        }
                    } else {
                        trieValue = this.nullValue
                        value = nullValue
                        haveValue = true
                    }
                    prevBlock = dataNullOffset
                    c = (c + CP_PER_INDEX_2_ENTRY) & 
                    continue
                }
                i3 = (shr(c, SHIFT_3)) & INDEX_3_MASK
                i3BlockLength = INDEX_3_BLOCK_LENGTH
                dataBlockLength = SMALL_DATA_BLOCK_LENGTH
            }
                    var group = (i3Block & 32767) + (i3 & ) + (shr(i3, 3))
                    let gi = i3 & 7
                    block = (shl(Int32(UInt32(index[Int64(match (0) { case _ => group++; group - 1 })])), (2 + (2 * gi)))) & 196608
                    block |= Int32(UInt32(index[Int64(group + gi)]))
                }
                if (block == prevBlock && (c - start) >= dataBlockLength) {
                    if (!((c & (dataBlockLength - 1)) == 0)) {
                        throw AssertionError()
                    }
                    c += dataBlockLength
                } else {
                    let dataMask = dataBlockLength - 1
                    prevBlock = block
                    if (block == dataNullOffset) {
                        if (haveValue) {
                            if (nullValue != value) {
                                range.set(start, c - 1, value)
                                return true
                            }
                        } else {
                            trieValue = this.nullValue
                            value = nullValue
                            haveValue = true
                        }
                        c = (c + dataBlockLength) & 
                    } else {
                        var di = block + (c & dataMask)
                        var trieValue2 = data.getFromIndex(di)
                        if (haveValue) {
                            if (trieValue2 != trieValue) {
                                if (filter.isNone() || maybeFilterValue(trieValue2, this.nullValue, nullValue, filter) != value) {
                                    range.set(start, c - 1, value)
                                    return true
                                }
                                trieValue = trieValue2
                            }
                        } else {
                            trieValue = trieValue2
                            value = maybeFilterValue(trieValue2, this.nullValue, nullValue, filter)
                            haveValue = true
                        }
                        while ((match (0) { case _ => c++; c } & dataMask) != 0) {
                            trieValue2 = data.getFromIndex(match (0) { case _ => di++; di })
                            if (trieValue2 != trieValue) {
                                if (filter.isNone() || maybeFilterValue(trieValue2, this.nullValue, nullValue, filter) != value) {
                                    range.set(start, c - 1, value)
                                    return true
                                }
                                trieValue = trieValue2
                            }
                        }
                    }
                }
            } while (match (0) { case _ => i3++; i3 } < i3BlockLength)
        } while (c < highStart)
        if (!(haveValue)) {
            throw AssertionError()
        }
        let di = dataLength - HIGH_VALUE_NEG_DATA_OFFSET
        let highValue = data.getFromIndex(di)
        if (maybeFilterValue(highValue, this.nullValue, nullValue, filter) != value) {
            c--
        } else {
            c = MAX_UNICODE
        }
        range.set(start, c, value)
        return true
    }

    public func toBinary(os: OutputStream): Int32 {
        try {
            let dos = DataOutputStream(os)
            dos.writeInt(1416784179)
            dos.writeChar((shr((dataLength & 983040), 4)) | (shr((dataNullOffset & 983040), 8)) | (shl(getType().ordinal, 6)) | getValueWidth().ordinal)
            dos.writeChar(Int32(index.size))
            dos.writeChar(dataLength)
            dos.writeChar(index3NullOffset)
            dos.writeChar(dataNullOffset)
            dos.writeChar(shr(highStart, SHIFT_2))
            var length = 16
            for (i in index) {
                dos.writeChar(Int32(UInt32(i)))
            }
            length += Int32(index.size) * 2
            length += data.write(dos)
            return length
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    static let FAST_SHIFT = 6

    static let FAST_DATA_BLOCK_LENGTH = shl(1, FAST_SHIFT)

    private static let FAST_DATA_MASK = FAST_DATA_BLOCK_LENGTH - 1

    static let SMALL_MAX = 4095

    static let ERROR_VALUE_NEG_DATA_OFFSET = 1

    private static let HIGH_VALUE_NEG_DATA_OFFSET = 2

    private static let BMP_INDEX_LENGTH = shr(65536, FAST_SHIFT)

    static let SMALL_LIMIT = 4096

    private static let SMALL_INDEX_LENGTH = shr(SMALL_LIMIT, FAST_SHIFT)

    static let SHIFT_3 = 4

    private static let SHIFT_2 = 5 + SHIFT_3

    private static let SHIFT_1 = 5 + SHIFT_2

    static let SHIFT_2_3 = SHIFT_2 - SHIFT_3

    static let SHIFT_1_2 = SHIFT_1 - SHIFT_2

    private static let OMITTED_BMP_INDEX_1_LENGTH = shr(65536, SHIFT_1)

    static let INDEX_2_BLOCK_LENGTH = shl(1, SHIFT_1_2)

    static let INDEX_2_MASK = INDEX_2_BLOCK_LENGTH - 1

    static let CP_PER_INDEX_2_ENTRY = shl(1, SHIFT_2)

    static let INDEX_3_BLOCK_LENGTH = shl(1, SHIFT_2_3)

    private static let INDEX_3_MASK = INDEX_3_BLOCK_LENGTH - 1

    static let SMALL_DATA_BLOCK_LENGTH = shl(1, SHIFT_3)

    static let SMALL_DATA_MASK = SMALL_DATA_BLOCK_LENGTH - 1

    private static let OPTIONS_DATA_LENGTH_MASK = 61440

    private static let OPTIONS_DATA_NULL_OFFSET_MASK = 3840

    private static let OPTIONS_RESERVED_MASK = 56

    private static let OPTIONS_VALUE_BITS_MASK = 7

    static let NO_INDEX3_NULL_OFFSET = 32767

    static let NO_DATA_NULL_OFFSET = 1048575

    private let ascii: Array<Int32>

    private let index: Array<Char>

    
    protected let data: CodePointTrie_Data

    
    protected let dataLength: Int32

    
    protected let highStart: Int32

    private let index3NullOffset: Int32

    private let dataNullOffset: Int32

    private let nullValue: Int32

    
    protected func fastIndex(c: Int32): Int32 {
        return Int32(UInt32(index[Int64(shr(c, FAST_SHIFT))])) + (c & FAST_DATA_MASK)
    }

    
    protected func smallIndex(Type: CodePointTrie_Type, c: Int32): Int32 {
        if (c >= highStart) {
            return dataLength - HIGH_VALUE_NEG_DATA_OFFSET
        }
        return internalSmallIndex(Type, c)
    }

    private func internalSmallIndex(Type: CodePointTrie_Type, c: Int32): Int32 {
        var i1 = shr(c, SHIFT_1)
        if (refEq(Type, CodePointTrie_Type.FAST)) {
            if (!(65535 < c && c < highStart)) {
                throw AssertionError()
            }
            i1 += BMP_INDEX_LENGTH - OMITTED_BMP_INDEX_1_LENGTH
        } else {
            if (!(0 <= c && c < highStart && highStart > SMALL_LIMIT)) {
                throw AssertionError()
            }
            i1 += SMALL_INDEX_LENGTH
        }
        var i3Block = Int32(UInt32(index[Int64(Int32(UInt32(index[Int64(i1)])) + ((shr(c, SHIFT_2)) & INDEX_2_MASK))]))
        var i3 = (shr(c, SHIFT_3)) & INDEX_3_MASK
        var dataBlock: Int32 = 0
        if ((i3Block & 32768) == 0) {
            dataBlock = Int32(UInt32(index[Int64(i3Block + i3)]))
        } else {
            i3Block = (i3Block & 32767) + (i3 & ) + (shr(i3, 3))
            i3 &= 7
            dataBlock = (shl(Int32(UInt32(index[Int64(match (0) { case _ => i3Block++; i3Block - 1 })])), (2 + (2 * i3)))) & 196608
            dataBlock |= Int32(UInt32(index[Int64(i3Block + i3)]))
        }
        return dataBlock + (c & SMALL_DATA_MASK)
    }

    
    protected func cpIndex(c: Int32): Int32
}


public class CodePointTrie_Type <: Enum<CodePointTrie_Type> {
    public static let FAST = CodePointTrie_Type("FAST", 0)

    public static let SMALL = CodePointTrie_Type("SMALL", 1)

    private static func _values(): Array<CodePointTrie_Type> {
        return [CodePointTrie_Type.FAST, CodePointTrie_Type.SMALL]
    }

    private static let _VALUES = CodePointTrie_Type._values()

    public static func values(): Array<CodePointTrie_Type> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): CodePointTrie_Type {
        return (TypeInfo.of<CodePointTrie_Type>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as CodePointTrie_Type
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class CodePointTrie_ValueWidth <: Enum<CodePointTrie_ValueWidth> {
    public static let BITS_16 = CodePointTrie_ValueWidth("BITS_16", 0)

    public static let BITS_32 = CodePointTrie_ValueWidth("BITS_32", 1)

    public static let BITS_8 = CodePointTrie_ValueWidth("BITS_8", 2)

    private static func _values(): Array<CodePointTrie_ValueWidth> {
        return [CodePointTrie_ValueWidth.BITS_16, CodePointTrie_ValueWidth.BITS_32, CodePointTrie_ValueWidth.BITS_8]
    }

    private static let _VALUES = CodePointTrie_ValueWidth._values()

    public static func values(): Array<CodePointTrie_ValueWidth> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): CodePointTrie_ValueWidth {
        return (TypeInfo.of<CodePointTrie_ValueWidth>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as CodePointTrie_ValueWidth
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


abstract class CodePointTrie_Data {

    public func getValueWidth(): CodePointTrie_ValueWidth

    public func getDataLength(): Int32

    public func getFromIndex(index: Int32): Int32

    public func write(dos: DataOutputStream): Int32
}


class CodePointTrie_Data16 <: CodePointTrie_Data {
    var array: Array<Char>

    init(a: Array<Char>) {
        super()
        array = a
    }

    public override func getValueWidth(): CodePointTrie_ValueWidth {
        return CodePointTrie_ValueWidth.BITS_16
    }

    public override func getDataLength(): Int32 {
        return Int32(array.size)
    }

    public override func getFromIndex(index: Int32): Int32 {
        return Int32(UInt32(array[Int64(index)]))
    }

    public override func write(dos: DataOutputStream): Int32 {
        for (v in array) {
            dos.writeChar(Int32(UInt32(v)))
        }
        return Int32(array.size) * 2
    }
}


class CodePointTrie_Data32 <: CodePointTrie_Data {
    var array: Array<Int32>

    init(a: Array<Int32>) {
        super()
        array = a
    }

    public override func getValueWidth(): CodePointTrie_ValueWidth {
        return CodePointTrie_ValueWidth.BITS_32
    }

    public override func getDataLength(): Int32 {
        return Int32(array.size)
    }

    public override func getFromIndex(index: Int32): Int32 {
        return array[Int64(index)]
    }

    public override func write(dos: DataOutputStream): Int32 {
        for (v in array) {
            dos.writeInt(v)
        }
        return Int32(array.size) * 4
    }
}


class CodePointTrie_Data8 <: CodePointTrie_Data {
    var array: Array<UInt8>

    init(a: Array<UInt8>) {
        super()
        array = a
    }

    public override func getValueWidth(): CodePointTrie_ValueWidth {
        return CodePointTrie_ValueWidth.BITS_8
    }

    public override func getDataLength(): Int32 {
        return Int32(array.size)
    }

    public override func getFromIndex(index: Int32): Int32 {
        return Int32(array[Int64(index)]) & 255
    }

    public override func write(dos: DataOutputStream): Int32 {
        for (v in array) {
            dos.writeByte(Int32(v))
        }
        return Int32(array.size)
    }
}


public abstract class CodePointTrie_Fast <: CodePointTrie {
    init(index: Array<Char>, data: CodePointTrie_Data, highStart: Int32, index3NullOffset: Int32, dataNullOffset: Int32) {
        super(index, data, highStart, index3NullOffset, dataNullOffset)
    }

    public static func fromBinary(valueWidth: CodePointTrie_ValueWidth, bytes: ByteArrayStream): CodePointTrie_Fast {
        return CodePointTrie.fromBinary(CodePointTrie_Type.FAST, valueWidth, bytes)
    }

    public override func getType(): CodePointTrie_Type {
        return CodePointTrie_Type.FAST
    }

    public func bmpGet(c: Int32): Int32

    public func suppGet(c: Int32): Int32

    
    override protected func cpIndex(c: Int32): Int32 {
        if (c >= 0) {
            if (c <= 65535) {
                return fastIndex(c)
            } else if (c <= 1114111) {
                return smallIndex(CodePointTrie_Type.FAST, c)
            }
        }
        return dataLength - CodePointTrie.ERROR_VALUE_NEG_DATA_OFFSET
    }

    public override func stringIterator(s: String, sIndex: Int32): CodePointMap_StringIterator {
        return CodePointTrie_Fast_FastStringIterator(this, s, sIndex)
    }
}


class CodePointTrie_Fast_FastStringIterator <: CodePointMap_StringIterator {
    let this_0: CodePointTrie_Fast

    init(this_0: CodePointTrie_Fast, s: String, sIndex: Int32) {
        super(this_0, s, sIndex)
        this.this_0 = this_0
    }

    public override func next(): Bool {
        if (sIndex >= s.size) {
            return false
        }
        let lead = s[match (0] { case _ => sIndex++; sIndex - 1 })
        c = Int32(UInt32(lead))
        let dataIndex: Int32
        if (!Character.isSurrogate(lead)) {
            dataIndex = this_0.fastIndex(c)
        } else {
            let trail: Char
            if (Normalizer2Impl_UTF16Plus.isSurrogateLead(Int32(UInt32(lead))) && sIndex < s.size && Character.isLowSurrogate(match (0) { case _ => trail = s[sIndex]; trail })) {
                sIndex++
                c = Character.toCodePoint(lead, trail)
                dataIndex = this_0.smallIndex(CodePointTrie_Type.FAST, c)
            } else {
                dataIndex = this_0.dataLength - CodePointTrie.ERROR_VALUE_NEG_DATA_OFFSET
            }
        }
        value = this_0.data.getFromIndex(dataIndex)
        return true
    }

    public override func previous(): Bool {
        if (sIndex <= 0) {
            return false
        }
        let trail = s[match (0] { case _ => sIndex--; sIndex })
        c = Int32(UInt32(trail))
        let dataIndex: Int32
        if (!Character.isSurrogate(trail)) {
            dataIndex = this_0.fastIndex(c)
        } else {
            let lead: Char
            if (!Normalizer2Impl_UTF16Plus.isSurrogateLead(Int32(UInt32(trail))) && sIndex > 0 && Character.isHighSurrogate(match (0) { case _ => lead = s[sIndex - 1]; lead })) {
                sIndex--
                c = Character.toCodePoint(lead, trail)
                dataIndex = this_0.smallIndex(CodePointTrie_Type.FAST, c)
            } else {
                dataIndex = this_0.dataLength - CodePointTrie.ERROR_VALUE_NEG_DATA_OFFSET
            }
        }
        value = this_0.data.getFromIndex(dataIndex)
        return true
    }
}


public abstract class CodePointTrie_Small <: CodePointTrie {
    init(index: Array<Char>, data: CodePointTrie_Data, highStart: Int32, index3NullOffset: Int32, dataNullOffset: Int32) {
        super(index, data, highStart, index3NullOffset, dataNullOffset)
    }

    public static func fromBinary(valueWidth: CodePointTrie_ValueWidth, bytes: ByteArrayStream): CodePointTrie_Small {
        return CodePointTrie.fromBinary(CodePointTrie_Type.SMALL, valueWidth, bytes)
    }

    public override func getType(): CodePointTrie_Type {
        return CodePointTrie_Type.SMALL
    }

    
    override protected func cpIndex(c: Int32): Int32 {
        if (c >= 0) {
            if (c <= CodePointTrie.SMALL_MAX) {
                return fastIndex(c)
            } else if (c <= 1114111) {
                return smallIndex(CodePointTrie_Type.SMALL, c)
            }
        }
        return dataLength - ERROR_VALUE_NEG_DATA_OFFSET
    }

    public override func stringIterator(s: String, sIndex: Int32): CodePointMap_StringIterator {
        return CodePointTrie_Small_SmallStringIterator(this, s, sIndex)
    }
}


class CodePointTrie_Small_SmallStringIterator <: CodePointMap_StringIterator {
    let this_0: CodePointTrie_Small

    init(this_0: CodePointTrie_Small, s: String, sIndex: Int32) {
        super(this_0, s, sIndex)
        this.this_0 = this_0
    }

    public override func next(): Bool {
        if (sIndex >= s.size) {
            return false
        }
        let lead = s[match (0] { case _ => sIndex++; sIndex - 1 })
        c = Int32(UInt32(lead))
        let dataIndex: Int32
        if (!Character.isSurrogate(lead)) {
            dataIndex = this_0.cpIndex(c)
        } else {
            let trail: Char
            if (Normalizer2Impl_UTF16Plus.isSurrogateLead(Int32(UInt32(lead))) && sIndex < s.size && Character.isLowSurrogate(match (0) { case _ => trail = s[sIndex]; trail })) {
                sIndex++
                c = Character.toCodePoint(lead, trail)
                dataIndex = this_0.smallIndex(CodePointTrie_Type.SMALL, c)
            } else {
                dataIndex = this_0.dataLength - CodePointTrie.ERROR_VALUE_NEG_DATA_OFFSET
            }
        }
        value = this_0.data.getFromIndex(dataIndex)
        return true
    }

    public override func previous(): Bool {
        if (sIndex <= 0) {
            return false
        }
        let trail = s[match (0] { case _ => sIndex--; sIndex })
        c = Int32(UInt32(trail))
        let dataIndex: Int32
        if (!Character.isSurrogate(trail)) {
            dataIndex = this_0.cpIndex(c)
        } else {
            let lead: Char
            if (!Normalizer2Impl_UTF16Plus.isSurrogateLead(Int32(UInt32(trail))) && sIndex > 0 && Character.isHighSurrogate(match (0) { case _ => lead = s[sIndex - 1]; lead })) {
                sIndex--
                c = Character.toCodePoint(lead, trail)
                dataIndex = this_0.smallIndex(CodePointTrie_Type.SMALL, c)
            } else {
                dataIndex = this_0.dataLength - CodePointTrie.ERROR_VALUE_NEG_DATA_OFFSET
            }
        }
        value = this_0.data.getFromIndex(dataIndex)
        return true
    }
}


public class CodePointTrie_Fast16 <: CodePointTrie_Fast {
    private let dataArray: Array<Char>

    init(index: Array<Char>, data16: Array<Char>, highStart: Int32, index3NullOffset: Int32, dataNullOffset: Int32) {
        super(index, CodePointTrie_Data16(data16), highStart, index3NullOffset, dataNullOffset)
        this.dataArray = data16
    }

    public static func fromBinary(bytes: ByteArrayStream): CodePointTrie_Fast16 {
        return CodePointTrie.fromBinary(CodePointTrie_Type.FAST, CodePointTrie_ValueWidth.BITS_16, bytes)
    }

    public override func get(c: Int32): Int32 {
        return Int32(UInt32(dataArray[Int64(cpIndex(c))]))
    }

    public override func bmpGet(c: Int32): Int32 {
        if (!(0 <= c && c <= 65535)) {
            throw AssertionError()
        }
        return Int32(UInt32(dataArray[Int64(fastIndex(c))]))
    }

    public override func suppGet(c: Int32): Int32 {
        if (!(65536 <= c && c <= 1114111)) {
            throw AssertionError()
        }
        return Int32(UInt32(dataArray[Int64(smallIndex(CodePointTrie_Type.FAST, c))]))
    }
}


public class CodePointTrie_Fast32 <: CodePointTrie_Fast {
    private let dataArray: Array<Int32>

    init(index: Array<Char>, data32: Array<Int32>, highStart: Int32, index3NullOffset: Int32, dataNullOffset: Int32) {
        super(index, CodePointTrie_Data32(data32), highStart, index3NullOffset, dataNullOffset)
        this.dataArray = data32
    }

    public static func fromBinary(bytes: ByteArrayStream): CodePointTrie_Fast32 {
        return CodePointTrie.fromBinary(CodePointTrie_Type.FAST, CodePointTrie_ValueWidth.BITS_32, bytes)
    }

    public override func get(c: Int32): Int32 {
        return dataArray[Int64(cpIndex(c))]
    }

    public override func bmpGet(c: Int32): Int32 {
        if (!(0 <= c && c <= 65535)) {
            throw AssertionError()
        }
        return dataArray[Int64(fastIndex(c))]
    }

    public override func suppGet(c: Int32): Int32 {
        if (!(65536 <= c && c <= 1114111)) {
            throw AssertionError()
        }
        return dataArray[Int64(smallIndex(CodePointTrie_Type.FAST, c))]
    }
}


public class CodePointTrie_Fast8 <: CodePointTrie_Fast {
    private let dataArray: Array<UInt8>

    init(index: Array<Char>, data8: Array<UInt8>, highStart: Int32, index3NullOffset: Int32, dataNullOffset: Int32) {
        super(index, CodePointTrie_Data8(data8), highStart, index3NullOffset, dataNullOffset)
        this.dataArray = data8
    }

    public static func fromBinary(bytes: ByteArrayStream): CodePointTrie_Fast8 {
        return CodePointTrie.fromBinary(CodePointTrie_Type.FAST, CodePointTrie_ValueWidth.BITS_8, bytes)
    }

    public override func get(c: Int32): Int32 {
        return Int32(dataArray[Int64(cpIndex(c))]) & 255
    }

    public override func bmpGet(c: Int32): Int32 {
        if (!(0 <= c && c <= 65535)) {
            throw AssertionError()
        }
        return Int32(dataArray[Int64(fastIndex(c))]) & 255
    }

    public override func suppGet(c: Int32): Int32 {
        if (!(65536 <= c && c <= 1114111)) {
            throw AssertionError()
        }
        return Int32(dataArray[Int64(smallIndex(CodePointTrie_Type.FAST, c))]) & 255
    }
}


public class CodePointTrie_Small16 <: CodePointTrie_Small {
    init(index: Array<Char>, data16: Array<Char>, highStart: Int32, index3NullOffset: Int32, dataNullOffset: Int32) {
        super(index, CodePointTrie_Data16(data16), highStart, index3NullOffset, dataNullOffset)
    }

    public static func fromBinary(bytes: ByteArrayStream): CodePointTrie_Small16 {
        return CodePointTrie.fromBinary(CodePointTrie_Type.SMALL, CodePointTrie_ValueWidth.BITS_16, bytes)
    }
}


public class CodePointTrie_Small32 <: CodePointTrie_Small {
    init(index: Array<Char>, data32: Array<Int32>, highStart: Int32, index3NullOffset: Int32, dataNullOffset: Int32) {
        super(index, CodePointTrie_Data32(data32), highStart, index3NullOffset, dataNullOffset)
    }

    public static func fromBinary(bytes: ByteArrayStream): CodePointTrie_Small32 {
        return CodePointTrie.fromBinary(CodePointTrie_Type.SMALL, CodePointTrie_ValueWidth.BITS_32, bytes)
    }
}


public class CodePointTrie_Small8 <: CodePointTrie_Small {
    init(index: Array<Char>, data8: Array<UInt8>, highStart: Int32, index3NullOffset: Int32, dataNullOffset: Int32) {
        super(index, CodePointTrie_Data8(data8), highStart, index3NullOffset, dataNullOffset)
    }

    public static func fromBinary(bytes: ByteArrayStream): CodePointTrie_Small8 {
        return CodePointTrie.fromBinary(CodePointTrie_Type.SMALL, CodePointTrie_ValueWidth.BITS_8, bytes)
    }
}
