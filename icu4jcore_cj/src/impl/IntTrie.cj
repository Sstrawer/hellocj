package icu4cj.impl

public class IntTrie <: Trie {
    public init(bytes: ByteArrayStream, dataManipulate: Trie_DataManipulate) {
        super(bytes, dataManipulate)
        if (!isIntTrie()) {
            throw IllegalArgumentException("Data given does not belong to a int trie.")
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
        m_data_ = Array<Int32>(Int64(dataLength)) { _ => 0 }
        m_dataLength_ = dataLength
        m_initialValue_ = initialValue
        i = 0
        while (i < latin1ength) {
            m_data_[Int64(i)] = initialValue
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
                m_data_[Int64(i)] = leadUnitValue
                i++
            }
        }
    }

    public func getCodePointValue(ch: Int32): Int32 {
        let offset: Int32
        if (0 <= ch && ch < UTF16.LEAD_SURROGATE_MIN_VALUE) {
            offset = (shl(Int32(UInt32(m_index_[Int64(shr(ch, INDEX_STAGE_1_SHIFT_))])), INDEX_STAGE_2_SHIFT_)) + (ch & INDEX_STAGE_3_MASK_)
            return m_data_[Int64(offset)]
        }
        offset = getCodePointOffset(ch)
        return if (offset >= 0) { m_data_[Int64(offset)] } else { m_initialValue_ }
    }

    public func getLeadValue(ch: Char): Int32 {
        return m_data_[Int64(getLeadOffset(ch))]
    }

    public func getBMPValue(ch: Char): Int32 {
        return m_data_[Int64(getBMPOffset(ch))]
    }

    public func getSurrogateValue(lead: Char, trail: Char): Int32 {
        if (!UTF16.isLeadSurrogate(Int32(UInt32(lead))) || !UTF16.isTrailSurrogate(Int32(UInt32(trail)))) {
            throw IllegalArgumentException("Argument characters do not form a supplementary character")
        }
        let offset = getSurrogateOffset(lead, trail)
        if (offset > 0) {
            return m_data_[Int64(offset)]
        }
        return m_initialValue_
    }

    public func getTrailValue(leadvalue: Int32, trail: Char): Int32 {
        if (m_dataManipulate_.isNone()) {
            throw NoneValueException("The field DataManipulate in this Trie is null")
        }
        let offset = m_dataManipulate_.getFoldingOffset(leadvalue)
        if (offset > 0) {
            return m_data_[Int64(getRawOffset(offset, Char(Int32(UInt32(trail)) & SURROGATE_MASK_)))]
        }
        return m_initialValue_
    }

    public func getLatin1inearValue(ch: Char): Int32 {
        return m_data_[Int64(INDEX_STAGE_3_MASK_ + 1 + Int32(UInt32(ch)))]
    }

    public override func equals(other: Object): Bool {
        let result = super.equals(other)
        if (result && checkOptionalIs<IntTrie, Object>(other)) {
            let othertrie = other
            if (m_initialValue_ != othertrie.m_initialValue_ || !m_data_ == othertrie.m_data_) {
                return false
            }
            return true
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
        super.unserialize(bytes)
        m_data_ = ICUBinary.getInts(bytes, m_dataLength_, 0)
        m_initialValue_ = m_data_[0]
    }

    override protected func getSurrogateOffset(lead: Char, trail: Char): Int32 {
        if (m_dataManipulate_.isNone()) {
            throw NoneValueException("The field DataManipulate in this Trie is null")
        }
        let offset = m_dataManipulate_.getFoldingOffset(getLeadValue(lead))
        if (offset > 0) {
            return getRawOffset(offset, Char(Int32(UInt32(trail)) & SURROGATE_MASK_))
        }
        return -1
    }

    override protected func getValue(index: Int32): Int32 {
        return m_data_[Int64(index)]
    }

    override protected func getInitialValue(): Int32 {
        return m_initialValue_
    }

    init(index: Array<Char>, data: Array<Int32>, initialvalue: Int32, options: Int32, datamanipulate: Trie_DataManipulate) {
        super(index, options, datamanipulate)
        m_data_ = data
        m_dataLength_ = Int32(m_data_.size)
        m_initialValue_ = initialvalue
    }

    private var m_initialValue_: Int32 = 0

    private var m_data_: Array<Int32>
}
