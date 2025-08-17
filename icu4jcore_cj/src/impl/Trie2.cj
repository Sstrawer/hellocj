package icu4cj.impl


public abstract class Trie2 <: Iterable<Trie2_Range> {

    public static func createFromSerialized(bytes: ByteArrayStream): Trie2 {
        let outerByteOrder = bytes.order()
        try {
            let header = Trie2_UTrie2Header()
            header.signature = bytes.getInt()
            match (header.signature) {
                case 1416784178 => ()
                case 845771348 =>
                    let isBigEndian = refEq(outerByteOrder, ByteOrder.BIG_ENDIAN)
                    bytes.order(if (isBigEndian) { ByteOrder.LITTLE_ENDIAN } else { ByteOrder.BIG_ENDIAN })
                    header.signature = 1416784178
                case _ => throw IllegalArgumentException("Buffer does not contain a serialized UTrie2")
            }
            header.options = Int32(UInt32(bytes.getChar()))
            header.indexLength = Int32(UInt32(bytes.getChar()))
            header.shiftedDataLength = Int32(UInt32(bytes.getChar()))
            header.index2NullOffset = Int32(UInt32(bytes.getChar()))
            header.dataNullOffset = Int32(UInt32(bytes.getChar()))
            header.shiftedHighStart = Int32(UInt32(bytes.getChar()))
            if ((header.options & UTRIE2_OPTIONS_VALUE_BITS_MASK) > 1) {
                throw IllegalArgumentException("UTrie2 serialized format error.")
            }
            let width: Trie2_ValueWidth
            let `This`: Trie2
            if ((header.options & UTRIE2_OPTIONS_VALUE_BITS_MASK) == 0) {
                width = Trie2_ValueWidth.BITS_16
                `This` = Trie2_16()
            } else {
                width = Trie2_ValueWidth.BITS_32
                `This` = Trie2_32()
            }
            `This`.header = header
            `This`.indexLength = header.indexLength
            `This`.dataLength = shl(header.shiftedDataLength, UTRIE2_INDEX_SHIFT)
            `This`.index2NullOffset = header.index2NullOffset
            `This`.dataNullOffset = header.dataNullOffset
            `This`.highStart = shl(header.shiftedHighStart, UTRIE2_SHIFT_1)
            `This`.highValueIndex = `This`.dataLength - UTRIE2_DATA_GRANULARITY
            if (refEq(width, Trie2_ValueWidth.BITS_16)) {
                `This`.highValueIndex += `This`.indexLength
            }
            var indexArraySize = `This`.indexLength
            if (refEq(width, Trie2_ValueWidth.BITS_16)) {
                indexArraySize += `This`.dataLength
            }
            `This`.index = ICUBinary.getChars(bytes, indexArraySize, 0)
            if (refEq(width, Trie2_ValueWidth.BITS_16)) {
                `This`.data16 = `This`.indexLength
            } else {
                `This`.data32 = ICUBinary.getInts(bytes, `This`.dataLength, 0)
            }
            match (width) {
                case Trie2_ValueWidth.BITS_16 =>
                    `This`.data32 = None
                    `This`.initialValue = Int32(UInt32(`This`.index[Int64(`This`.dataNullOffset)]))
                    `This`.errorValue = Int32(UInt32(`This`.index[Int64(`This`.data16 + UTRIE2_BAD_UTF8_DATA_OFFSET)]))
                case Trie2_ValueWidth.BITS_32 =>
                    `This`.data16 = 0
                    `This`.initialValue = `This`.data32[Int64(`This`.dataNullOffset)]
                    `This`.errorValue = `This`.data32[Int64(UTRIE2_BAD_UTF8_DATA_OFFSET)]
                case _ => throw IllegalArgumentException("UTrie2 serialized format error.")
            }
            return `This`
        } finally {
            bytes.order(outerByteOrder)
        }
    }

    public static func getVersion(isTrue: InputStream, littleEndianOk: Bool): Int32 {
        if (!isTrue.markSupported()) {
            throw IllegalArgumentException("Input stream must support mark().")
        }
        isTrue.mark(4)
        let sig = Array<UInt8>(4) { _ => 0 }
        let read = Int32(isTrue.read(sig))
        isTrue.reset()
        if (read != Int32(sig.size)) {
            return 0
        }
        if (Int32(sig[0]) == Int32(UInt32('T')) && Int32(sig[1]) == Int32(UInt32('r')) && Int32(sig[2]) == Int32(UInt32('i')) && Int32(sig[3]) == Int32(UInt32('e'))) {
            return 1
        }
        if (Int32(sig[0]) == Int32(UInt32('T')) && Int32(sig[1]) == Int32(UInt32('r')) && Int32(sig[2]) == Int32(UInt32('i')) && Int32(sig[3]) == Int32(UInt32('2'))) {
            return 2
        }
        if (littleEndianOk) {
            if (Int32(sig[0]) == Int32(UInt32('e')) && Int32(sig[1]) == Int32(UInt32('i')) && Int32(sig[2]) == Int32(UInt32('r')) && Int32(sig[3]) == Int32(UInt32('T'))) {
                return 1
            }
            if (Int32(sig[0]) == Int32(UInt32('2')) && Int32(sig[1]) == Int32(UInt32('i')) && Int32(sig[2]) == Int32(UInt32('r')) && Int32(sig[3]) == Int32(UInt32('T'))) {
                return 2
            }
        }
        return 0
    }

    public func get(codePoint: Int32): Int32

    public func getFromU16SingleLead(c: Char): Int32

    public override func equals(other: Object): Bool {
        if (!(checkOptionalIs<Trie2, Object>(other))) {
            return false
        }
        let OtherTrie = other
        var rangeFromOther: Trie2_Range
        let otherIter = OtherTrie.iterator()
        for (rangeFromThis in this) {
            if (otherIter.hasNext() == false) {
                return false
            }
            rangeFromOther = otherIter.next()
            if (!rangeFromThis.equals(rangeFromOther)) {
                return false
            }
        }
        if (otherIter.hasNext()) {
            return false
        }
        if (errorValue != OtherTrie.errorValue || initialValue != OtherTrie.initialValue) {
            return false
        }
        return true
    }

    public override func hashCode(): Int64 {
        if (fHash == 0) {
            var hash = initHash()
            for (r in this) {
                hash = hashInt(hash, Int32(r.hashCode()))
            }
            if (hash == 0) {
                hash = 1
            }
            fHash = hash
        }
        return Int64(fHash)
    }

    public override func iterator(): Iterator<Trie2_Range> {
        return iterator(defaultValueMapper)
    }

    private static var defaultValueMapper: Trie2_ValueMapper = Trie2_1()

    public func iterator(mapper: Trie2_ValueMapper): Iterator<Trie2_Range> {
        return Trie2_Trie2Iterator(this, mapper) as Iterator<Trie2_Range>
    }

    public func iteratorForLeadSurrogate(lead: Char, mapper: Trie2_ValueMapper): Iterator<Trie2_Range> {
        return Trie2_Trie2Iterator(this, lead, mapper) as Iterator<Trie2_Range>
    }

    public func iteratorForLeadSurrogate(lead: Char): Iterator<Trie2_Range> {
        return Trie2_Trie2Iterator(this, lead, defaultValueMapper) as Iterator<Trie2_Range>
    }

    protected func serializeHeader(dos: DataOutputStream): Int32 {
        var bytesWritten = 0
        dos.writeInt(header.signature)
        dos.writeShort(header.options)
        dos.writeShort(header.indexLength)
        dos.writeShort(header.shiftedDataLength)
        dos.writeShort(header.index2NullOffset)
        dos.writeShort(header.dataNullOffset)
        dos.writeShort(header.shiftedHighStart)
        bytesWritten += 16
        var i: Int32 = 0
        i = 0
        while (i < header.indexLength) {
            dos.writeChar(Int32(UInt32(index[Int64(i)])))
            i++
        }
        bytesWritten += header.indexLength
        return bytesWritten
    }

    public func charSequenceIterator(text: String, index: Int32): Trie2_CharSequenceIterator {
        return Trie2_CharSequenceIterator(this, text, index)
    }

    var header: Trie2_UTrie2Header

    var index: Array<Char>

    var data16: Int32 = 0

    var data32: Array<Int32>

    var indexLength: Int32 = 0

    var dataLength: Int32 = 0

    var index2NullOffset: Int32 = 0

    var initialValue: Int32 = 0

    var errorValue: Int32 = 0

    var highStart: Int32 = 0

    var highValueIndex: Int32 = 0

    var dataNullOffset: Int32 = 0

    var fHash: Int32 = 0

    static let UTRIE2_OPTIONS_VALUE_BITS_MASK = 15

    static let UTRIE2_SHIFT_1 = 6 + 5

    static let UTRIE2_SHIFT_2 = 5

    static let UTRIE2_SHIFT_1_2 = UTRIE2_SHIFT_1 - UTRIE2_SHIFT_2

    static let UTRIE2_OMITTED_BMP_INDEX_1_LENGTH = shr(65536, UTRIE2_SHIFT_1)

    static let UTRIE2_CP_PER_INDEX_1_ENTRY = shl(1, UTRIE2_SHIFT_1)

    static let UTRIE2_INDEX_2_BLOCK_LENGTH = shl(1, UTRIE2_SHIFT_1_2)

    static let UTRIE2_INDEX_2_MASK = UTRIE2_INDEX_2_BLOCK_LENGTH - 1

    static let UTRIE2_DATA_BLOCK_LENGTH = shl(1, UTRIE2_SHIFT_2)

    static let UTRIE2_DATA_MASK = UTRIE2_DATA_BLOCK_LENGTH - 1

    static let UTRIE2_INDEX_SHIFT = 2

    static let UTRIE2_DATA_GRANULARITY = shl(1, UTRIE2_INDEX_SHIFT)

    static let UTRIE2_INDEX_2_OFFSET = 0

    static let UTRIE2_LSCP_INDEX_2_OFFSET = shr(65536, UTRIE2_SHIFT_2)

    static let UTRIE2_LSCP_INDEX_2_LENGTH = shr(1024, UTRIE2_SHIFT_2)

    static let UTRIE2_INDEX_2_BMP_LENGTH = UTRIE2_LSCP_INDEX_2_OFFSET + UTRIE2_LSCP_INDEX_2_LENGTH

    static let UTRIE2_UTF8_2B_INDEX_2_OFFSET = UTRIE2_INDEX_2_BMP_LENGTH

    static let UTRIE2_UTF8_2B_INDEX_2_LENGTH = shr(2048, 6)

    static let UTRIE2_INDEX_1_OFFSET = UTRIE2_UTF8_2B_INDEX_2_OFFSET + UTRIE2_UTF8_2B_INDEX_2_LENGTH

    static let UTRIE2_MAX_INDEX_1_LENGTH = shr(1048576, UTRIE2_SHIFT_1)

    static let UTRIE2_BAD_UTF8_DATA_OFFSET = 128

    static let UTRIE2_DATA_START_OFFSET = 192

    static let UNEWTRIE2_INDEX_GAP_OFFSET = UTRIE2_INDEX_2_BMP_LENGTH

    static let UNEWTRIE2_INDEX_GAP_LENGTH = ((UTRIE2_UTF8_2B_INDEX_2_LENGTH + UTRIE2_MAX_INDEX_1_LENGTH) + UTRIE2_INDEX_2_MASK) & 

    static let UNEWTRIE2_MAX_INDEX_2_LENGTH = (shr(1114112, UTRIE2_SHIFT_2)) + UTRIE2_LSCP_INDEX_2_LENGTH + UNEWTRIE2_INDEX_GAP_LENGTH + UTRIE2_INDEX_2_BLOCK_LENGTH

    static let UNEWTRIE2_INDEX_1_LENGTH = shr(1114112, UTRIE2_SHIFT_1)

    static let UNEWTRIE2_MAX_DATA_LENGTH = (1114112 + 64 + 64 + 1024)

    public func rangeEnd(start: Int32, limitp: Int32, val: Int32): Int32 {
        var c: Int32 = 0
        let limit = min(highStart, limitp)
        c = start + 1
        while (c < limit) {
            if (get(c) != val) {
                break
            }
            c++
        }
        if (c >= highStart) {
            c = limitp
        }
        return c - 1
    }

    static func initHash(): Int32 {
        return -2128831035
    }

    static func hashByte(h: Int32, b: Int32): Int32 {
        var temph = h
        temph = temph * 16777619
        temph = temph ^ b
        return temph
    }

    static func hashUChar32(h: Int32, c: Int32): Int32 {
        var temph = h
        temph = Trie2.hashByte(temph, c & 255)
        temph = Trie2.hashByte(temph, (shr(c, 8)) & 255)
        temph = Trie2.hashByte(temph, shr(c, 16))
        return temph
    }

    static func hashInt(h: Int32, i: Int32): Int32 {
        var temph = h
        temph = Trie2.hashByte(temph, i & 255)
        temph = Trie2.hashByte(temph, (shr(i, 8)) & 255)
        temph = Trie2.hashByte(temph, (shr(i, 16)) & 255)
        temph = Trie2.hashByte(temph, (shr(i, 24)) & 255)
        return temph
    }
}


public class Trie2_Range {

    public var startCodePoint: Int32 = 0

    public var endCodePoint: Int32 = 0

    public var value: Int32 = 0

    public var leadSurrogate: Bool = false

    public override func equals(other: Object): Bool {
        if (other.isNone() || !(refEq(TypeInfo.of(other), TypeInfo.of(this)))) {
            return false
        }
        let tother = other
        return this.startCodePoint == tother.startCodePoint && this.endCodePoint == tother.endCodePoint && this.value == tother.value && this.leadSurrogate == tother.leadSurrogate
    }

    public override func hashCode(): Int64 {
        var h = Trie2.initHash()
        h = Trie2.hashUChar32(h, startCodePoint)
        h = Trie2.hashUChar32(h, endCodePoint)
        h = Trie2.hashInt(h, value)
        h = Trie2.hashByte(h, if (leadSurrogate) { 1 } else { 0 })
        return Int64(h)
    }
}


class Trie2_1 <: Trie2_ValueMapper {

    public override func map(input: Int32): Int32 {
        return input
    }
}


public interface Trie2_ValueMapper {
    public func map(originalVal: Int32): Int32
}

public class Trie2_CharSequenceValues {

    public var index: Int32 = 0

    public var codePoint: Int32 = 0

    public var value: Int32 = 0
}


public class Trie2_CharSequenceIterator <: Iterator<Trie2_CharSequenceValues> {
    let this_0: Trie2

    init(this_0: Trie2, t: String, index: Int32) {
        this.this_0 = this_0
        text = t
        textLength = text.size
        set(index)
    }

    private var text: String

    private var textLength: Int32 = 0

    private var index: Int32 = 0

    private var fResults: Trie2_CharSequenceValues = Trie2_CharSequenceValues()

    public func set(i: Int32): Unit {
        if (i < 0 || i > textLength) {
            throw IndexOutOfBoundsException()
        }
        index = i
    }

    public override func hasNext(): Bool {
        return index < textLength
    }

    public func hasPrevious(): Bool {
        return index > 0
    }

    public override func next(): Trie2_CharSequenceValues {
        let c = Character.codePointAt(text, index)
        let val = this_0.get(c)
        fResults.index = index
        fResults.codePoint = c
        fResults.value = val
        index++
        if (c >= 65536) {
            index++
        }
        return fResults
    }

    public func previous(): Trie2_CharSequenceValues {
        let c = Character.codePointBefore(text, index)
        let val = this_0.get(c)
        index--
        if (c >= 65536) {
            index--
        }
        fResults.index = index
        fResults.codePoint = c
        fResults.value = val
        return fResults
    }

    public override func remove(): Unit {
        throw UnsupportedOperationException("Trie2.CharSequenceIterator does not support remove().")
    }
}


class Trie2_ValueWidth <: Enum<Trie2_ValueWidth> {
    public static let BITS_16 = Trie2_ValueWidth("BITS_16", 0)

    public static let BITS_32 = Trie2_ValueWidth("BITS_32", 1)

    private static func _values(): Array<Trie2_ValueWidth> {
        return [Trie2_ValueWidth.BITS_16, Trie2_ValueWidth.BITS_32]
    }

    private static let _VALUES = Trie2_ValueWidth._values()

    public static func values(): Array<Trie2_ValueWidth> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): Trie2_ValueWidth {
        return (TypeInfo.of<Trie2_ValueWidth>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as Trie2_ValueWidth
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class Trie2_UTrie2Header {

    var signature: Int32 = 0

    var options: Int32 = 0

    var indexLength: Int32 = 0

    var shiftedDataLength: Int32 = 0

    var index2NullOffset: Int32 = 0

    var dataNullOffset: Int32 = 0

    var shiftedHighStart: Int32 = 0
}


class Trie2_Trie2Iterator <: Iterator<Trie2_Range> {
    let this_0: Trie2

    init(this_0: Trie2, vm: Trie2_ValueMapper) {
        this.this_0 = this_0
        mapper = vm
        nextStart = 0
        limitCP = 1114112
        doLeadSurrogates = true
    }

    init(this_0: Trie2, leadSurrogate: Char, vm: Trie2_ValueMapper) {
        this.this_0 = this_0
        if (Int32(UInt32(leadSurrogate)) < 55296 || Int32(UInt32(leadSurrogate)) > 56319) {
            throw IllegalArgumentException("Bad lead surrogate value.")
        }
        mapper = vm
        nextStart = shl((Int32(UInt32(leadSurrogate)) - 55232), 10)
        limitCP = nextStart + 1024
        doLeadSurrogates = false
    }

    public override func next(): Trie2_Range {
        if (!hasNext()) {
            throw NoSuchElementException()
        }
        if (nextStart >= limitCP) {
            doingCodePoints = false
            nextStart = 55296
        }
        var endOfRange = 0
        var val = 0
        var mappedVal = 0
        if (doingCodePoints) {
            val = this_0.get(nextStart)
            mappedVal = mapper.map(val)
            endOfRange = this_0.rangeEnd(nextStart, limitCP, val)
            while (true) {
                if (endOfRange >= limitCP - 1) {
                    break
                }
                val = this_0.get(endOfRange + 1)
                if (mapper.map(val) != mappedVal) {
                    break
                }
                endOfRange = this_0.rangeEnd(endOfRange + 1, limitCP, val)
            }
        } else {
            val = this_0.getFromU16SingleLead(Char(nextStart))
            mappedVal = mapper.map(val)
            endOfRange = rangeEndLS(Char(nextStart))
            while (true) {
                if (endOfRange >= 56319) {
                    break
                }
                val = this_0.getFromU16SingleLead(Char(endOfRange + 1))
                if (mapper.map(val) != mappedVal) {
                    break
                }
                endOfRange = rangeEndLS(Char(endOfRange + 1))
            }
        }
        returnValue.startCodePoint = nextStart
        returnValue.endCodePoint = endOfRange
        returnValue.value = mappedVal
        returnValue.leadSurrogate = !doingCodePoints
        nextStart = endOfRange + 1
        return returnValue
    }

    public override func hasNext(): Bool {
        return doingCodePoints && (doLeadSurrogates || nextStart < limitCP) || nextStart < 56320
    }

    public override func remove(): Unit {
        throw UnsupportedOperationException()
    }

    private func rangeEndLS(startingLS: Char): Int32 {
        if (Int32(UInt32(startingLS)) >= 56319) {
            return 56319
        }
        var c: Int32 = 0
        let val = this_0.getFromU16SingleLead(startingLS)
        c = Int32(UInt32(startingLS)) + 1
        while (c <= 56319) {
            if (this_0.getFromU16SingleLead(Char(c)) != val) {
                break
            }
            c++
        }
        return c - 1
    }

    private var mapper: Trie2_ValueMapper

    private var returnValue: Trie2_Range = Trie2_Range()

    private var nextStart: Int32 = 0

    private var limitCP: Int32 = 0

    private var doingCodePoints = true

    private var doLeadSurrogates = true
}
