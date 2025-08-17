package icu4cj.impl


public class TrieIterator <: RangeValueIterator {
    public init(trie: Trie) {
        if (trie.isNone()) {
            throw IllegalArgumentException("Argument trie cannot be null")
        }
        m_trie_ = trie
        m_initialValue_ = extract(m_trie_.getInitialValue())
        reset()
    }

    public override func next(element: RangeValueIterator_Element): Bool {
        if (m_nextCodepoint_ > UCharacter.MAX_VALUE) {
            return false
        }
        if (m_nextCodepoint_ < UCharacter.SUPPLEMENTARY_MIN_VALUE && calculateNextBMPElement(element)) {
            return true
        }
        calculateNextSupplementaryElement(element)
        return true
    }

    public override func reset(): Unit {
        m_currentCodepoint_ = 0
        m_nextCodepoint_ = 0
        m_nextIndex_ = 0
        m_nextBlock_ = shl(Int32(UInt32(m_trie_.m_index_[0])), Trie.INDEX_STAGE_2_SHIFT_)
        if (m_nextBlock_ == m_trie_.m_dataOffset_) {
            m_nextValue_ = m_initialValue_
        } else {
            m_nextValue_ = extract(m_trie_.getValue(m_nextBlock_))
        }
        m_nextBlockIndex_ = 0
        m_nextTrailIndexOffset_ = TRAIL_SURROGATE_INDEX_BLOCK_LENGTH_
    }

    protected func extract(value: Int32): Int32 {
        return value
    }

    private func setResult(element: RangeValueIterator_Element, start: Int32, limit: Int32, value: Int32): Unit {
        element.start = start
        element.limit = limit
        element.value = value
    }

    private func calculateNextBMPElement(element: RangeValueIterator_Element): Bool {
        let currentValue = m_nextValue_
        m_currentCodepoint_ = m_nextCodepoint_
        m_nextCodepoint_++
        m_nextBlockIndex_++
        if (!checkBlockDetail(currentValue)) {
            setResult(element, m_currentCodepoint_, m_nextCodepoint_, currentValue)
            return true
        }
        while (m_nextCodepoint_ < UCharacter.SUPPLEMENTARY_MIN_VALUE) {
            if (m_nextCodepoint_ == LEAD_SURROGATE_MIN_VALUE_) {
                m_nextIndex_ = BMP_INDEX_LENGTH_
            } else if (m_nextCodepoint_ == TRAIL_SURROGATE_MIN_VALUE_) {
                m_nextIndex_ = shr(m_nextCodepoint_, Trie.INDEX_STAGE_1_SHIFT_)
            } else {
                m_nextIndex_++
            }
            m_nextBlockIndex_ = 0
            if (!checkBlock(currentValue)) {
                setResult(element, m_currentCodepoint_, m_nextCodepoint_, currentValue)
                return true
            }
        }
        m_nextCodepoint_--
        m_nextBlockIndex_--
        return false
    }

    private func calculateNextSupplementaryElement(element: RangeValueIterator_Element): Unit {
        let currentValue = m_nextValue_
        m_nextCodepoint_++
        m_nextBlockIndex_++
        if (Int32(UInt32(UTF16.getTrailSurrogate(m_nextCodepoint_))) != UTF16.TRAIL_SURROGATE_MIN_VALUE) {
            if (!checkNullNextTrailIndex() && !checkBlockDetail(currentValue)) {
                setResult(element, m_currentCodepoint_, m_nextCodepoint_, currentValue)
                m_currentCodepoint_ = m_nextCodepoint_
                return
            }
            m_nextIndex_++
            m_nextTrailIndexOffset_++
            if (!checkTrailBlock(currentValue)) {
                setResult(element, m_currentCodepoint_, m_nextCodepoint_, currentValue)
                m_currentCodepoint_ = m_nextCodepoint_
                return
            }
        }
        var nextLead = Int32(UInt32(UTF16.getLeadSurrogate(m_nextCodepoint_)))
        while (nextLead < TRAIL_SURROGATE_MIN_VALUE_) {
            let leadBlock = shl(Int32(UInt32(m_trie_.m_index_[Int64(shr(nextLead, Trie.INDEX_STAGE_1_SHIFT_))])), Trie.INDEX_STAGE_2_SHIFT_)
            if (leadBlock == m_trie_.m_dataOffset_) {
                if (currentValue != m_initialValue_) {
                    m_nextValue_ = m_initialValue_
                    m_nextBlock_ = leadBlock
                    m_nextBlockIndex_ = 0
                    setResult(element, m_currentCodepoint_, m_nextCodepoint_, currentValue)
                    m_currentCodepoint_ = m_nextCodepoint_
                    return
                }
                nextLead += DATA_BLOCK_LENGTH_
                m_nextCodepoint_ = Character.toCodePoint(Char(nextLead), Char(UTF16.TRAIL_SURROGATE_MIN_VALUE))
                continue
            }
            if (m_trie_.m_dataManipulate_.isNone()) {
                throw NoneValueException("The field DataManipulate in this Trie is null")
            }
            m_nextIndex_ = m_trie_.m_dataManipulate_.getFoldingOffset(m_trie_.getValue(leadBlock + (nextLead & Trie.INDEX_STAGE_3_MASK_)))
            if (m_nextIndex_ <= 0) {
                if (currentValue != m_initialValue_) {
                    m_nextValue_ = m_initialValue_
                    m_nextBlock_ = m_trie_.m_dataOffset_
                    m_nextBlockIndex_ = 0
                    setResult(element, m_currentCodepoint_, m_nextCodepoint_, currentValue)
                    m_currentCodepoint_ = m_nextCodepoint_
                    return
                }
                m_nextCodepoint_ += TRAIL_SURROGATE_COUNT_
            } else {
                m_nextTrailIndexOffset_ = 0
                if (!checkTrailBlock(currentValue)) {
                    setResult(element, m_currentCodepoint_, m_nextCodepoint_, currentValue)
                    m_currentCodepoint_ = m_nextCodepoint_
                    return
                }
            }
            nextLead++
        }
        setResult(element, m_currentCodepoint_, UCharacter.MAX_VALUE + 1, currentValue)
    }

    private func checkBlockDetail(currentValue: Int32): Bool {
        while (m_nextBlockIndex_ < DATA_BLOCK_LENGTH_) {
            m_nextValue_ = extract(m_trie_.getValue(m_nextBlock_ + m_nextBlockIndex_))
            if (m_nextValue_ != currentValue) {
                return false
            }
            m_nextBlockIndex_++
            m_nextCodepoint_++
        }
        return true
    }

    private func checkBlock(currentValue: Int32): Bool {
        let currentBlock = m_nextBlock_
        m_nextBlock_ = shl(Int32(UInt32(m_trie_.m_index_[Int64(m_nextIndex_)])), Trie.INDEX_STAGE_2_SHIFT_)
        if (m_nextBlock_ == currentBlock && (m_nextCodepoint_ - m_currentCodepoint_) >= DATA_BLOCK_LENGTH_) {
            m_nextCodepoint_ += DATA_BLOCK_LENGTH_
        } else if (m_nextBlock_ == m_trie_.m_dataOffset_) {
            if (currentValue != m_initialValue_) {
                m_nextValue_ = m_initialValue_
                m_nextBlockIndex_ = 0
                return false
            }
            m_nextCodepoint_ += DATA_BLOCK_LENGTH_
        } else {
            if (!checkBlockDetail(currentValue)) {
                return false
            }
        }
        return true
    }

    private func checkTrailBlock(currentValue: Int32): Bool {
        while (m_nextTrailIndexOffset_ < TRAIL_SURROGATE_INDEX_BLOCK_LENGTH_) {
            m_nextBlockIndex_ = 0
            if (!checkBlock(currentValue)) {
                return false
            }
            m_nextTrailIndexOffset_++
            m_nextIndex_++
        }
        return true
    }

    private func checkNullNextTrailIndex(): Bool {
        if (m_nextIndex_ <= 0) {
            m_nextCodepoint_ += TRAIL_SURROGATE_COUNT_ - 1
            let nextLead = Int32(UInt32(UTF16.getLeadSurrogate(m_nextCodepoint_)))
            let leadBlock = shl(Int32(UInt32(m_trie_.m_index_[Int64(shr(nextLead, Trie.INDEX_STAGE_1_SHIFT_))])), Trie.INDEX_STAGE_2_SHIFT_)
            if (m_trie_.m_dataManipulate_.isNone()) {
                throw NoneValueException("The field DataManipulate in this Trie is null")
            }
            m_nextIndex_ = m_trie_.m_dataManipulate_.getFoldingOffset(m_trie_.getValue(leadBlock + (nextLead & Trie.INDEX_STAGE_3_MASK_)))
            m_nextIndex_--
            m_nextBlockIndex_ = DATA_BLOCK_LENGTH_
            return true
        }
        return false
    }

    private static let BMP_INDEX_LENGTH_ = shr(65536, Trie.INDEX_STAGE_1_SHIFT_)

    private static let LEAD_SURROGATE_MIN_VALUE_ = 55296

    private static let TRAIL_SURROGATE_MIN_VALUE_ = 56320

    private static let TRAIL_SURROGATE_COUNT_ = 1024

    private static let TRAIL_SURROGATE_INDEX_BLOCK_LENGTH_ = shl(1, (10 - Trie.INDEX_STAGE_1_SHIFT_))

    private static let DATA_BLOCK_LENGTH_ = shl(1, Trie.INDEX_STAGE_1_SHIFT_)

    private var m_trie_: Trie

    private var m_initialValue_: Int32 = 0

    private var m_currentCodepoint_: Int32 = 0

    private var m_nextCodepoint_: Int32 = 0

    private var m_nextValue_: Int32 = 0

    private var m_nextIndex_: Int32 = 0

    private var m_nextBlock_: Int32 = 0

    private var m_nextBlockIndex_: Int32 = 0

    private var m_nextTrailIndexOffset_: Int32 = 0
}
