package icu4cj.impl


public class TrieBuilder {
    public static let DATA_BLOCK_LENGTH = shl(1, Trie.INDEX_STAGE_1_SHIFT_)

    public func isInZeroBlock(ch: Int32): Bool {
        if (m_isCompacted_ || ch > UCharacter.MAX_VALUE || ch < UCharacter.MIN_VALUE) {
            return true
        }
        return m_index_[Int64(shr(ch, SHIFT_))] == 0
    }

    protected var m_index_: Array<Int32>

    protected var m_indexLength_: Int32 = 0

    protected var m_dataCapacity_: Int32 = 0

    protected var m_dataLength_: Int32 = 0

    protected var m_isLatin1inear_: Bool = false

    protected var m_isCompacted_: Bool = false

    protected var m_map_: Array<Int32>

    protected static let SHIFT_ = Trie.INDEX_STAGE_1_SHIFT_

    protected static let MAX_INDEX_LENGTH_ = (shr(1114112, SHIFT_))

    protected static let BMP_INDEX_LENGTH_ = shr(65536, SHIFT_)

    protected static let SURROGATE_BLOCK_COUNT_ = shl(1, (10 - SHIFT_))

    protected static let MASK_ = Trie.INDEX_STAGE_3_MASK_

    protected static let INDEX_SHIFT_ = Trie.INDEX_STAGE_2_SHIFT_

    protected static let MAX_DATA_LENGTH_ = (shl(65536, INDEX_SHIFT_))

    protected static let OPTIONS_INDEX_SHIFT_ = 4

    protected static let OPTIONS_DATA_IS_32_BIT_ = 256

    protected static let OPTIONS_LATIN1_IS_LINEAR_ = 512

    protected static let DATA_GRANULARITY_ = shl(1, INDEX_SHIFT_)

    protected init() {
        m_index_ = Array<Int32>(Int64(MAX_INDEX_LENGTH_)) { _ => 0 }
        m_map_ = Array<Int32>(Int64(shr(MAX_BUILD_TIME_DATA_LENGTH_, SHIFT_))) { _ => 0 }
        m_isLatin1inear_ = false
        m_isCompacted_ = false
        m_indexLength_ = MAX_INDEX_LENGTH_
    }

    protected init(table: TrieBuilder) {
        m_index_ = Array<Int32>(Int64(MAX_INDEX_LENGTH_)) { _ => 0 }
        m_indexLength_ = table.m_indexLength_
        arraycopy(table.m_index_, 0, m_index_, 0, Int64(m_indexLength_))
        m_dataCapacity_ = table.m_dataCapacity_
        m_dataLength_ = table.m_dataLength_
        m_map_ = Array<Int32>(table.m_map_.size) { _ => 0 }
        arraycopy(table.m_map_, 0, m_map_, 0, m_map_.size)
        m_isLatin1inear_ = table.m_isLatin1inear_
        m_isCompacted_ = table.m_isCompacted_
    }

    protected static func equal_int(array: Array<Int32>, start1: Int32, start2: Int32, length: Int32): Bool {
        var tempstart1 = start1
        var tempstart2 = start2
        var templength = length
        while (templength > 0 && array[Int64(tempstart1)] == array[Int64(tempstart2)]) {
            tempstart1++
            tempstart2++
            templength--
        }
        return templength == 0
    }

    protected func findUnusedBlocks(): Unit {
        Arrays.fill(m_map_, 255)
        var i = 0
        while (i < m_indexLength_) {
            m_map_[Int64(shr(abs(m_index_[Int64(i)]), SHIFT_))] = 0
            i++
        }
        m_map_[0] = 0
    }

    protected static func findSameIndexBlock(index: Array<Int32>, indexLength: Int32, otherBlock: Int32): Int32 {
        var block = BMP_INDEX_LENGTH_
        while (block < indexLength) {
            if (equal_int(index, block, otherBlock, SURROGATE_BLOCK_COUNT_)) {
                return block
            }
            block += SURROGATE_BLOCK_COUNT_
        }
        return indexLength
    }

    private static let MAX_BUILD_TIME_DATA_LENGTH_ = 1114112 + DATA_BLOCK_LENGTH + 1024
}


public interface TrieBuilder_DataManipulate {
    public func getFoldedValue(start: Int32, offset: Int32): Int32
}