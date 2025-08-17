package icu4cj.impl

public abstract class Trie {
    public func isLatin1inear(): Bool {
        return m_isLatin1inear_
    }

    public override func equals(other: Object): Bool {
        if (refEq(other, this)) {
            return true
        }
        if (!(checkOptionalIs<Trie, Object>(other))) {
            return false
        }
        let othertrie = other
        return m_isLatin1inear_ == othertrie.m_isLatin1inear_ && m_options_ == othertrie.m_options_ && m_dataLength_ == othertrie.m_dataLength_ && m_index_ == othertrie.m_index_
    }

    public override func hashCode(): Int64 {
        if (!false) {
            throw Exception("hashCode not designed")
        }
        return 42
    }

    public func getSerializedDataSize(): Int32 {
        var result = (shl(4, 2))
        result += (shl(m_dataOffset_, 1))
        if (isCharTrie()) {
            result += (shl(m_dataLength_, 1))
        } else if (isIntTrie()) {
            result += (shl(m_dataLength_, 2))
        }
        return result
    }

    protected init(bytes: ByteArrayStream, dataManipulate: Trie_DataManipulate) {
        let signature = bytes.getInt()
        m_options_ = bytes.getInt()
        if (!checkHeader(signature)) {
            throw IllegalArgumentException("ICU data file error: Trie header authentication failed, please check if you have the most updated ICU data file")
        }
        if (dataManipulate.isSome()) {
            m_dataManipulate_ = dataManipulate
        } else {
            m_dataManipulate_ = Trie_DefaultGetFoldingOffset()
        }
        m_isLatin1inear_ = (m_options_ & HEADER_OPTIONS_LATIN1_IS_LINEAR_MASK_) != 0
        m_dataOffset_ = bytes.getInt()
        m_dataLength_ = bytes.getInt()
        unserialize(bytes)
    }

    protected init(index: Array<Char>, options: Int32, dataManipulate: Trie_DataManipulate) {
        m_options_ = options
        if (dataManipulate.isSome()) {
            m_dataManipulate_ = dataManipulate
        } else {
            m_dataManipulate_ = Trie_DefaultGetFoldingOffset()
        }
        m_isLatin1inear_ = (m_options_ & HEADER_OPTIONS_LATIN1_IS_LINEAR_MASK_) != 0
        m_index_ = index
        m_dataOffset_ = Int32(m_index_.size)
    }

    protected static let LEAD_INDEX_OFFSET_ = shr(10240, 5)

    protected static let INDEX_STAGE_1_SHIFT_ = 5

    protected static let INDEX_STAGE_2_SHIFT_ = 2

    protected static let DATA_BLOCK_LENGTH = shl(1, INDEX_STAGE_1_SHIFT_)

    protected static let INDEX_STAGE_3_MASK_ = DATA_BLOCK_LENGTH - 1

    protected static let SURROGATE_BLOCK_BITS = 10 - INDEX_STAGE_1_SHIFT_

    protected static let SURROGATE_BLOCK_COUNT = (shl(1, SURROGATE_BLOCK_BITS))

    protected static let BMP_INDEX_LENGTH = shr(65536, INDEX_STAGE_1_SHIFT_)

    protected static let SURROGATE_MASK_ = 1023

    protected var m_index_: Array<Char>

    protected var m_dataManipulate_: Trie_DataManipulate

    protected var m_dataOffset_: Int32 = 0

    protected var m_dataLength_: Int32 = 0

    protected func getSurrogateOffset(lead: Char, trail: Char): Int32

    protected func getValue(index: Int32): Int32

    protected func getInitialValue(): Int32

    protected func getRawOffset(offset: Int32, ch: Char): Int32 {
        return (shl(Int32(UInt32(m_index_[Int64(offset + (shr(Int32(UInt32(ch)), INDEX_STAGE_1_SHIFT_)))])), INDEX_STAGE_2_SHIFT_)) + (Int32(UInt32(ch)) & INDEX_STAGE_3_MASK_)
    }

    protected func getBMPOffset(ch: Char): Int32 {
        return if (Int32(UInt32(ch)) >= UTF16.LEAD_SURROGATE_MIN_VALUE && Int32(UInt32(ch)) <= UTF16.LEAD_SURROGATE_MAX_VALUE) { getRawOffset(LEAD_INDEX_OFFSET_, ch) } else { getRawOffset(0, ch) }
    }

    protected func getLeadOffset(ch: Char): Int32 {
        return getRawOffset(0, ch)
    }

    protected func getCodePointOffset(ch: Int32): Int32 {
        if (ch < 0) {
            return -1
        } else if (ch < UTF16.LEAD_SURROGATE_MIN_VALUE) {
            return getRawOffset(0, Char(ch))
        } else if (ch < UTF16.SUPPLEMENTARY_MIN_VALUE) {
            return getBMPOffset(Char(ch))
        } else if (ch <= UCharacter.MAX_VALUE) {
            return getSurrogateOffset(UTF16.getLeadSurrogate(ch), Char(ch & SURROGATE_MASK_))
        } else {
            return -1
        }
    }

    protected func unserialize(bytes: ByteArrayStream): Unit {
        m_index_ = ICUBinary.getChars(bytes, m_dataOffset_, 0)
    }

    protected func isIntTrie(): Bool {
        return (m_options_ & HEADER_OPTIONS_DATA_IS_32_BIT_) != 0
    }

    protected func isCharTrie(): Bool {
        return (m_options_ & HEADER_OPTIONS_DATA_IS_32_BIT_) == 0
    }

    protected static let HEADER_LENGTH_ = 4 * 4

    protected static let HEADER_OPTIONS_LATIN1_IS_LINEAR_MASK_ = 512

    protected static let HEADER_SIGNATURE_ = 1416784229

    private static let HEADER_OPTIONS_SHIFT_MASK_ = 15

    protected static let HEADER_OPTIONS_INDEX_SHIFT_ = 4

    protected static let HEADER_OPTIONS_DATA_IS_32_BIT_ = 256

    private var m_isLatin1inear_: Bool = false

    private var m_options_: Int32 = 0

    private func checkHeader(signature: Int32): Bool {
        if (signature != HEADER_SIGNATURE_) {
            return false
        }
        if ((m_options_ & HEADER_OPTIONS_SHIFT_MASK_) != INDEX_STAGE_1_SHIFT_ || ((shr(m_options_, HEADER_OPTIONS_INDEX_SHIFT_)) & HEADER_OPTIONS_SHIFT_MASK_) != INDEX_STAGE_2_SHIFT_) {
            return false
        }
        return true
    }
}


public interface Trie_DataManipulate {
    public func getFoldingOffset(value: Int32): Int32
}

class Trie_DefaultGetFoldingOffset <: Trie_DataManipulate {

    public override func getFoldingOffset(value: Int32): Int32 {
        return value
    }
}
