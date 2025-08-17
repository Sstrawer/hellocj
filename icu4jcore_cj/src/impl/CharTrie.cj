package icu4cj.impl

public class CharTrie <: Trie {
    public init(bytes: ByteArrayStream, dataManipulate: Trie_DataManipulate) {
        super(bytes, dataManipulate)
        if (!isCharTrie()) {
            throw IllegalArgumentException("Data given does not belong to a char trie.")
        }
    }

    public init(initialValue: Int32, leadUnitValue: Int32, dataManipulate: Trie_DataManipulate) {
        super(Array<Char>(Int64(BMP_INDEX_LENGTH + SURROGATE_BLOCK_COUNT)) { _ => '\u{0000}' }, HEADER_OPTIONS_LATIN1_IS_LINEAR_MASK_, dataManipulate)
        var dataLength: Int32 = 0
        let latin1ength: Int32
        var i: Int32 = 0
        var limit: Int32 = 0
        let block: Char
        dataLength = match (0) { case _ => latin1ength = 256; latin1ength }
        if (leadUnitValue != initialValue) {
            dataLength += DATA_BLOCK_LENGTH
        }
        m_data_ = Array<Char>(Int64(dataLength)) { _ => '\u{0000}' }
        m_dataLength_ = dataLength
        m_initialValue_ = Char(initialValue)
        i = 0
        while (i < latin1ength) {
            m_data_[Int64(i)] = Char(initialValue)
            i++
        }
        if (leadUnitValue != initialValue) {
            block = Char(shr(latin1ength, INDEX_STAGE_2_SHIFT_))
            i = shr(55296, INDEX_STAGE_1_SHIFT_)
            limit = shr(56320, INDEX_STAGE_1_SHIFT_)
            while (i < limit) {
                m_index_[Int64(i)] = block
                i++
            }
            limit = latin1ength + DATA_BLOCK_LENGTH
            i = latin1ength
            while (i < limit) {
                m_data_[Int64(i)] = Char(leadUnitValue)
                i++
            }
        }
    }

    public func getCodePointValue(ch: Int32): Char {
        let offset: Int32
        if (0 <= ch && ch < UTF16.LEAD_SURROGATE_MIN_VALUE) {
            offset = (shl(Int32(UInt32(m_index_[Int64(shr(ch, INDEX_STAGE_1_SHIFT_))])), INDEX_STAGE_2_SHIFT_)) + (ch & INDEX_STAGE_3_MASK_)
            return m_data_[Int64(offset)]
        }
        offset = getCodePointOffset(ch)
        return if (offset >= 0) { m_data_[Int64(offset)] } else { m_initialValue_ }
    }

    public func getLeadValue(ch: Char): Char {
        return m_data_[Int64(getLeadOffset(ch))]
    }

    public func getBMPValue(ch: Char): Char {
        return m_data_[Int64(getBMPOffset(ch))]
    }

    public func getSurrogateValue(lead: Char, trail: Char): Char {
        let offset = getSurrogateOffset(lead, trail)
        if (offset > 0) {
            return m_data_[Int64(offset)]
        }
        return m_initialValue_
    }

    public func getTrailValue(leadvalue: Int32, trail: Char): Char {
        if (m_dataManipulate_.isNone()) {
            throw NoneValueException("The field DataManipulate in this Trie is null")
        }
        let offset = m_dataManipulate_.getFoldingOffset(leadvalue)
        if (offset > 0) {
            return m_data_[Int64(getRawOffset(offset, Char(Int32(UInt32(trail)) & SURROGATE_MASK_)))]
        }
        return m_initialValue_
    }

    public func getLatin1inearValue(ch: Char): Char {
        return m_data_[Int64(INDEX_STAGE_3_MASK_ + 1 + m_dataOffset_ + Int32(UInt32(ch)))]
    }

    public override func equals(other: Object): Bool {
        let result = super.equals(other)
        if (result && checkOptionalIs<CharTrie, Object>(other)) {
            let othertrie = other
            return m_initialValue_ == othertrie.m_initialValue_
        }
        return false
    }

    public override func hashCode(): Int64 {
        if (!false) {
            throw Exception("hashCode not designed")
        }
        return 42
    }

    override protected func unserialize(bytes: ByteArrayStream): Unit {
        let indexDataLength = m_dataOffset_ + m_dataLength_
        m_index_ = ICUBinary.getChars(bytes, indexDataLength, 0)
        m_data_ = m_index_
        m_initialValue_ = m_data_[Int64(m_dataOffset_)]
    }

    override protected func getSurrogateOffset(lead: Char, trail: Char): Int32 {
        if (m_dataManipulate_.isNone()) {
            throw NoneValueException("The field DataManipulate in this Trie is null")
        }
        let offset = m_dataManipulate_.getFoldingOffset(Int32(UInt32(getLeadValue(lead))))
        if (offset > 0) {
            return getRawOffset(offset, Char(Int32(UInt32(trail)) & SURROGATE_MASK_))
        }
        return -1
    }

    override protected func getValue(index: Int32): Int32 {
        return Int32(UInt32(m_data_[Int64(index)]))
    }

    override protected func getInitialValue(): Int32 {
        return Int32(UInt32(m_initialValue_))
    }

    private var m_initialValue_: Char = '\u{0000}'

    private var m_data_: Array<Char>
}
