package icu4cj.impl


public class IntTrieBuilder <: TrieBuilder {
    public init(table: IntTrieBuilder) {
        super(table)
        m_data_ = Array<Int32>(Int64(m_dataCapacity_)) { _ => 0 }
        arraycopy(table.m_data_, 0, m_data_, 0, Int64(m_dataLength_))
        m_initialValue_ = table.m_initialValue_
        m_leadUnitValue_ = table.m_leadUnitValue_
    }

    public init(aliasdata: Array<Int32>, maxdatalength: Int32, initialvalue: Int32, leadunitvalue: Int32, latin1linear: Bool) {
        super()
        if (maxdatalength < DATA_BLOCK_LENGTH || (latin1linear && maxdatalength < 1024)) {
            throw IllegalArgumentException("Argument maxdatalength is too small")
        }
        if (aliasdata.isSome()) {
            m_data_ = aliasdata
        } else {
            m_data_ = Array<Int32>(Int64(maxdatalength)) { _ => 0 }
        }
        var j = DATA_BLOCK_LENGTH
        if (latin1linear) {
            var i = 0
        }
        m_dataLength_ = j
        Arrays.fill(m_data_, 0, m_dataLength_, initialvalue)
        m_initialValue_ = initialvalue
        m_leadUnitValue_ = leadunitvalue
        m_dataCapacity_ = maxdatalength
        m_isLatin1inear_ = latin1linear
        m_isCompacted_ = false
    }

    public func getValue(ch: Int32): Int32 {
        if (m_isCompacted_ || ch > UCharacter.MAX_VALUE || ch < 0) {
            return 0
        }
        let block = m_index_[Int64(shr(ch, SHIFT_))]
        return m_data_[Int64(abs(block) + (ch & MASK_))]
    }

    public func getValue(ch: Int32, inBlockZero: Array<Bool>): Int32 {
        if (m_isCompacted_ || ch > UCharacter.MAX_VALUE || ch < 0) {
            if (inBlockZero.isSome()) {
                inBlockZero[0] = true
            }
            return 0
        }
        let block = m_index_[Int64(shr(ch, SHIFT_))]
        if (inBlockZero.isSome()) {
            inBlockZero[0] = (block == 0)
        }
        return m_data_[Int64(abs(block) + (ch & MASK_))]
    }

    public func setValue(ch: Int32, value: Int32): Bool {
        if (m_isCompacted_ || ch > UCharacter.MAX_VALUE || ch < 0) {
            return false
        }
        let block = getDataBlock(ch)
        if (block < 0) {
            return false
        }
        m_data_[Int64(block + (ch & MASK_))] = value
        return true
    }

    public func serialize(datamanipulate: TrieBuilder_DataManipulate, triedatamanipulate: Trie_DataManipulate): IntTrie {
        if (datamanipulate.isNone()) {
            throw IllegalArgumentException("Parameters can not be null")
        }
        if (!m_isCompacted_) {
            compact(false)
            fold(datamanipulate)
            compact(true)
            m_isCompacted_ = true
        }
        if (m_dataLength_ >= MAX_DATA_LENGTH_) {
            throw IndexOutOfBoundsException("Data length too small")
        }
        let index = Array<Char>(Int64(m_indexLength_)) { _ => '\u{0000}' }
        let data = Array<Int32>(Int64(m_dataLength_)) { _ => 0 }
        var i = 0
        while (i < m_indexLength_) {
            index[Int64(i)] = Char(ushr(m_index_[Int64(i)], INDEX_SHIFT_))
            i++
        }
        arraycopy(m_data_, 0, data, 0, Int64(m_dataLength_))
        var options = SHIFT_ | (shl(INDEX_SHIFT_, OPTIONS_INDEX_SHIFT_))
        options |= OPTIONS_DATA_IS_32_BIT_
        if (m_isLatin1inear_) {
            options |= OPTIONS_LATIN1_IS_LINEAR_
        }
        return IntTrie(index, data, m_initialValue_, options, triedatamanipulate)
    }

    public func serialize(os: OutputStream, reduceTo16Bits: Bool, datamanipulate: TrieBuilder_DataManipulate): Int32 {
        if (datamanipulate.isNone()) {
            throw IllegalArgumentException("Parameters can not be null")
        }
        if (!m_isCompacted_) {
            compact(false)
            fold(datamanipulate)
            compact(true)
            m_isCompacted_ = true
        }
        var length: Int32 = 0
        if (reduceTo16Bits) {
            length = m_dataLength_ + m_indexLength_
        } else {
            length = m_dataLength_
        }
        if (length >= MAX_DATA_LENGTH_) {
            throw IndexOutOfBoundsException("Data length too small")
        }
        length = Trie.HEADER_LENGTH_ + 2 * m_indexLength_
        if (reduceTo16Bits) {
            length += 2 * m_dataLength_
        } else {
            length += 4 * m_dataLength_
        }
        if (os.isNone()) {
            return length
        }
        let dos = DataOutputStream(os)
        dos.writeInt(Trie.HEADER_SIGNATURE_)
        var options = Trie.INDEX_STAGE_1_SHIFT_ | (shl(Trie.INDEX_STAGE_2_SHIFT_, Trie.HEADER_OPTIONS_INDEX_SHIFT_))
        if (!reduceTo16Bits) {
            options |= Trie.HEADER_OPTIONS_DATA_IS_32_BIT_
        }
        if (m_isLatin1inear_) {
            options |= Trie.HEADER_OPTIONS_LATIN1_IS_LINEAR_MASK_
        }
        dos.writeInt(options)
        dos.writeInt(m_indexLength_)
        dos.writeInt(m_dataLength_)
        if (reduceTo16Bits) {
            } while (false)
            } while (false)
        } else {
            } while (false)
            } while (false)
        }
        return length
    }

    public func setRange(start: Int32, limit: Int32, value: Int32, overwrite: Bool): Bool {
        var tempstart = start
        var templimit = limit
        if (m_isCompacted_ || tempstart < UCharacter.MIN_VALUE || tempstart > UCharacter.MAX_VALUE || templimit < UCharacter.MIN_VALUE || templimit > (UCharacter.MAX_VALUE + 1) || tempstart > templimit) {
            return false
        }
        if (tempstart == templimit) {
            return true
        }
        if ((tempstart & MASK_) != 0) {
            let block = getDataBlock(tempstart)
            if (block < 0) {
                return false
            }
            let nextStart = (tempstart + DATA_BLOCK_LENGTH) & 
            if (nextStart <= templimit) {
                fillBlock(block, tempstart & MASK_, DATA_BLOCK_LENGTH, value, overwrite)
                tempstart = nextStart
            } else {
                fillBlock(block, tempstart & MASK_, templimit & MASK_, value, overwrite)
                return true
            }
        }
        let rest = templimit & MASK_
        templimit &= 
        var repeatBlock = 0
        if (value == m_initialValue_) { } else {
            repeatBlock = -1
        }
        while (tempstart < templimit) {
            let block = m_index_[Int64(shr(tempstart, SHIFT_))]
            if (block > 0) {
                fillBlock(block, 0, DATA_BLOCK_LENGTH, value, overwrite)
            } else if (m_data_[Int64(-block)] != value && (block == 0 || overwrite)) {
                if (repeatBlock >= 0) {
                    m_index_[Int64(shr(tempstart, SHIFT_))] = -repeatBlock
                } else {
                    repeatBlock = getDataBlock(tempstart)
                    if (repeatBlock < 0) {
                        return false
                    }
                    m_index_[Int64(shr(tempstart, SHIFT_))] = -repeatBlock
                    fillBlock(repeatBlock, 0, DATA_BLOCK_LENGTH, value, true)
                }
            }
            tempstart += DATA_BLOCK_LENGTH
        }
        if (rest > 0) {
            let block = getDataBlock(tempstart)
            if (block < 0) {
                return false
            }
            fillBlock(block, 0, rest, value, overwrite)
        }
        return true
    }

    protected var m_data_: Array<Int32>

    protected var m_initialValue_: Int32 = 0

    private var m_leadUnitValue_: Int32 = 0

    private func allocDataBlock(): Int32 {
        let newBlock = m_dataLength_
        let newTop = newBlock + DATA_BLOCK_LENGTH
        if (newTop > m_dataCapacity_) {
            return -1
        }
        m_dataLength_ = newTop
        return newBlock
    }

    private func getDataBlock(ch: Int32): Int32 {
        var tempch = ch
        tempch >>= SHIFT_
        let indexValue = m_index_[Int64(tempch)]
        if (indexValue > 0) {
            return indexValue
        }
        let newBlock = allocDataBlock()
        if (newBlock < 0) {
            return -1
        }
        m_index_[Int64(tempch)] = newBlock
        arraycopy(m_data_, Int64(abs(indexValue)), m_data_, Int64(newBlock), Int64(shl(DATA_BLOCK_LENGTH, 2)))
        return newBlock
    }

    private func compact(overlap: Bool): Unit {
        if (m_isCompacted_) {
            return
        }
        findUnusedBlocks()
        var overlapStart = DATA_BLOCK_LENGTH
        if (m_isLatin1inear_ && SHIFT_ <= 8) {
            overlapStart += 256
        }
        var newStart = DATA_BLOCK_LENGTH
        var i: Int32 = 0
        var start = newStart
        while (start < m_dataLength_) {
            if (m_map_[Int64(ushr(start, SHIFT_))] < 0) {
                start += DATA_BLOCK_LENGTH
                continue
            }
            if (start >= overlapStart) {
                i = findSameDataBlock(m_data_, newStart, start, if (overlap) { DATA_GRANULARITY_ } else { DATA_BLOCK_LENGTH })
                if (i >= 0) {
                    m_map_[Int64(ushr(start, SHIFT_))] = i
                    start += DATA_BLOCK_LENGTH
                    continue
                }
            }
            if (overlap && start >= overlapStart) {
                i = DATA_BLOCK_LENGTH - DATA_GRANULARITY_
                while (i > 0 && !equal_int(m_data_, newStart - i, start, i)) {
                    i -= DATA_GRANULARITY_
                }
            } else {
                i = 0
            }
            if (i > 0) {
                m_map_[Int64(ushr(start, SHIFT_))] = newStart - i
                start += i
                i = DATA_BLOCK_LENGTH - i
                while (i > 0) {
                    m_data_[Int64(match (0) { case _ => newStart++; newStart - 1 })] = m_data_[Int64(match (0) { case _ => start++; start - 1 })]
                    i--
                }
            } else if (newStart < start) {
                m_map_[Int64(ushr(start, SHIFT_))] = newStart
                i = DATA_BLOCK_LENGTH
                while (i > 0) {
                    m_data_[Int64(match (0) { case _ => newStart++; newStart - 1 })] = m_data_[Int64(match (0) { case _ => start++; start - 1 })]
                    i--
                }
            } else {
                m_map_[Int64(ushr(start, SHIFT_))] = start
                newStart += DATA_BLOCK_LENGTH
                start = newStart
            }
        }
        i = 0
        while (i < m_indexLength_) {
            m_index_[Int64(i)] = m_map_[Int64(ushr(abs(m_index_[Int64(i)]), SHIFT_))]
            i++
        }
        m_dataLength_ = newStart
    }

    private static func findSameDataBlock(data: Array<Int32>, dataLength: Int32, otherBlock: Int32, step: Int32): Int32 {
        var tempdataLength = dataLength
        tempdataLength -= DATA_BLOCK_LENGTH
        var block = 0
        while (block <= tempdataLength) {
            if (equal_int(data, block, otherBlock, DATA_BLOCK_LENGTH)) {
                return block
            }
            block += step
        }
        return -1
    }

    private func fold(manipulate: TrieBuilder_DataManipulate): Unit {
        let leadIndexes = Array<Int32>(Int64(SURROGATE_BLOCK_COUNT_)) { _ => 0 }
        let index = m_index_
        arraycopy(index, Int64(shr(55296, SHIFT_)), leadIndexes, 0, Int64(SURROGATE_BLOCK_COUNT_))
        var block = 0
        if (m_leadUnitValue_ == m_initialValue_) { } else {
            block = allocDataBlock()
            if (block < 0) {
                throw Exception("Internal error: Out of memory space")
            }
            fillBlock(block, 0, DATA_BLOCK_LENGTH, m_leadUnitValue_, true)
            block = -block
        }
        } while (false)
        var indexLength = BMP_INDEX_LENGTH_
                        if (block == indexLength) {
                            arraycopy(index, Int64(shr(c, SHIFT_)), index, Int64(indexLength), Int64(SURROGATE_BLOCK_COUNT_))
                            indexLength += SURROGATE_BLOCK_COUNT_
                        }
                    }
                    c += 1024
                } else {
                    c += DATA_BLOCK_LENGTH
                }
            }
        } while (false)
        if (indexLength >= MAX_INDEX_LENGTH_) {
            throw IndexOutOfBoundsException("Index table overflow")
        }
        arraycopy(index, Int64(BMP_INDEX_LENGTH_), index, Int64(BMP_INDEX_LENGTH_ + SURROGATE_BLOCK_COUNT_), Int64(indexLength - BMP_INDEX_LENGTH_))
        arraycopy(leadIndexes, 0, index, Int64(BMP_INDEX_LENGTH_), Int64(SURROGATE_BLOCK_COUNT_))
        indexLength += SURROGATE_BLOCK_COUNT_
        m_indexLength_ = indexLength
    }

    private func fillBlock(block: Int32, start: Int32, limit: Int32, value: Int32, overwrite: Bool): Unit {
        var templimit = limit
        var tempblock = block
        templimit += tempblock
        tempblock += start
        if (overwrite) {
            while (tempblock < templimit) {
                m_data_[Int64(match (0) { case _ => tempblock++; tempblock - 1 })] = value
            }
        } else {
            while (tempblock < templimit) {
                if (m_data_[Int64(tempblock)] == m_initialValue_) {
                    m_data_[Int64(tempblock)] = value
                }
                tempblock++
            }
        }
    }
}
