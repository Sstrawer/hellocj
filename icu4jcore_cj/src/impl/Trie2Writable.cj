package icu4cj.impl

public class Trie2Writable <: Trie2 {
    public init(initialValueP: Int32, errorValueP: Int32) {
        super()
        initself(initialValueP, errorValueP)
    }

    private func initself(initialValueP: Int32, errorValueP: Int32): Unit {
        this.initialValue = initialValueP
        this.errorValue = errorValueP
        this.highStart = 1114112
        this.data = Array<Int32>(Int64(UNEWTRIE2_INITIAL_DATA_LENGTH)) { _ => 0 }
        this.dataCapacity = UNEWTRIE2_INITIAL_DATA_LENGTH
        this.initialValue = initialValueP
        this.errorValue = errorValueP
        this.highStart = 1114112
        this.firstFreeBlock = 0
        this.isCompacted = false
        var i: Int32 = 0
        var j: Int32 = 0
        i = 0
        while (i < 128) {
            data[Int64(i)] = initialValue
            i++
        }
        while (i < 192) {
            data[Int64(i)] = errorValue
            i++
        }
        i = UNEWTRIE2_DATA_NULL_OFFSET
        while (i < UNEWTRIE2_DATA_START_OFFSET) {
            data[Int64(i)] = initialValue
            i++
        }
        dataNullOffset = UNEWTRIE2_DATA_NULL_OFFSET
        dataLength = UNEWTRIE2_DATA_START_OFFSET
        i = 0
        j = 0
        while (j < 128) {
            index2[Int64(i)] = j
            map[Int64(i)] = 1
            i++
            j += UTRIE2_DATA_BLOCK_LENGTH
        }
        while (j < 192) {
            map[Int64(i)] = 0
            i++
            j += UTRIE2_DATA_BLOCK_LENGTH
        }
        map[Int64(match (0) { case _ => i++; i - 1 })] = (shr(1114112, UTRIE2_SHIFT_2)) - (shr(128, UTRIE2_SHIFT_2)) + 1 + UTRIE2_LSCP_INDEX_2_LENGTH
        j += UTRIE2_DATA_BLOCK_LENGTH
        while (j < UNEWTRIE2_DATA_START_OFFSET) {
            map[Int64(i)] = 0
            i++
            j += UTRIE2_DATA_BLOCK_LENGTH
        }
        i = shr(128, UTRIE2_SHIFT_2)
        while (i < UTRIE2_INDEX_2_BMP_LENGTH) {
            index2[Int64(i)] = UNEWTRIE2_DATA_NULL_OFFSET
            i++
        }
        i = 0
        while (i < UNEWTRIE2_INDEX_GAP_LENGTH) {
            index2[Int64(UNEWTRIE2_INDEX_GAP_OFFSET + i)] = -1
            i++
        }
        i = 0
        while (i < UTRIE2_INDEX_2_BLOCK_LENGTH) {
            index2[Int64(UNEWTRIE2_INDEX_2_NULL_OFFSET + i)] = UNEWTRIE2_DATA_NULL_OFFSET
            i++
        }
        index2NullOffset = UNEWTRIE2_INDEX_2_NULL_OFFSET
        index2ength = UNEWTRIE2_INDEX_2_START_OFFSET
        i = 0
        j = 0
        while (i < UTRIE2_OMITTED_BMP_INDEX_1_LENGTH) {
            index1[Int64(i)] = j
            i++
            j += UTRIE2_INDEX_2_BLOCK_LENGTH
        }
        while (i < UNEWTRIE2_INDEX_1_LENGTH) {
            index1[Int64(i)] = UNEWTRIE2_INDEX_2_NULL_OFFSET
            i++
        }
        i = 128
        while (i < 2048) {
            set(i, initialValue)
            i += UTRIE2_DATA_BLOCK_LENGTH
        }
    }

    public init(source: Trie2) {
        super()
        initself(source.initialValue, source.errorValue)
        for (r in source) {
            setRange(r, true)
        }
    }

    private func isInNullBlock(c: Int32, forLSCP: Bool): Bool {
        let i2: Int32
        let block: Int32
        if (Character.isHighSurrogate(Char(c)) && forLSCP) {
            i2 = (UTRIE2_LSCP_INDEX_2_OFFSET - (shr(55296, UTRIE2_SHIFT_2))) + (shr(c, UTRIE2_SHIFT_2))
        } else {
            i2 = index1[Int64(shr(c, UTRIE2_SHIFT_1))] + ((shr(c, UTRIE2_SHIFT_2)) & UTRIE2_INDEX_2_MASK)
        }
        block = index2[Int64(i2)]
        return (block == dataNullOffset)
    }

    private func allocIndex2Block(): Int32 {
        let newBlock: Int32
        let newTop: Int32
        newBlock = index2ength
        newTop = newBlock + UTRIE2_INDEX_2_BLOCK_LENGTH
        if (newTop > Int32(index2.size)) {
            throw Exception("Internal error in Trie2 creation.")
        }
        index2ength = newTop
        arraycopy(index2, Int64(index2NullOffset), index2, Int64(newBlock), Int64(UTRIE2_INDEX_2_BLOCK_LENGTH))
        return newBlock
    }

    private func getIndex2Block(c: Int32, forLSCP: Bool): Int32 {
        let i1: Int32
        var i2: Int32 = 0
        if (c >= 55296 && c < 56320 && forLSCP) {
            return UTRIE2_LSCP_INDEX_2_OFFSET
        }
        i1 = shr(c, UTRIE2_SHIFT_1)
        i2 = index1[Int64(i1)]
        if (i2 == index2NullOffset) {
            i2 = allocIndex2Block()
            index1[Int64(i1)] = i2
        }
        return i2
    }

    private func allocDataBlock(copyBlock: Int32): Int32 {
        let newBlock: Int32
        let newTop: Int32
        if (firstFreeBlock != 0) {
            newBlock = firstFreeBlock
            firstFreeBlock = -map[Int64(shr(newBlock, UTRIE2_SHIFT_2))]
        } else {
            newBlock = dataLength
            newTop = newBlock + UTRIE2_DATA_BLOCK_LENGTH
            if (newTop > dataCapacity) {
                let capacity: Int32
                let newData: Array<Int32>
                if (dataCapacity < UNEWTRIE2_MEDIUM_DATA_LENGTH) {
                    capacity = UNEWTRIE2_MEDIUM_DATA_LENGTH
                } else if (dataCapacity < UNEWTRIE2_MAX_DATA_LENGTH) {
                    capacity = UNEWTRIE2_MAX_DATA_LENGTH
                } else {
                    throw Exception("Internal error in Trie2 creation.")
                }
                newData = Array<Int32>(Int64(capacity)) { _ => 0 }
                arraycopy(data, 0, newData, 0, Int64(dataLength))
                data = newData
                dataCapacity = capacity
            }
            dataLength = newTop
        }
        arraycopy(data, Int64(copyBlock), data, Int64(newBlock), Int64(UTRIE2_DATA_BLOCK_LENGTH))
        map[Int64(shr(newBlock, UTRIE2_SHIFT_2))] = 0
        return newBlock
    }

    private func releaseDataBlock(block: Int32): Unit {
        map[Int64(shr(block, UTRIE2_SHIFT_2))] = -firstFreeBlock
        firstFreeBlock = block
    }

    private func isWritableBlock(block: Int32): Bool {
        return (block != dataNullOffset && 1 == map[Int64(shr(block, UTRIE2_SHIFT_2))])
    }

    private func setIndex2Entry(i2: Int32, block: Int32): Unit {
        let oldBlock: Int32
        map[Int64(shr(block, UTRIE2_SHIFT_2))] += 1
        oldBlock = index2[Int64(i2)]
        if (0 == match (0) { case _ => map[Int64(shr(oldBlock, UTRIE2_SHIFT_2))] -= 1; map[Int64(shr(oldBlock, UTRIE2_SHIFT_2))] }) {
            releaseDataBlock(oldBlock)
        }
        index2[Int64(i2)] = block
    }

    private func getDataBlock(c: Int32, forLSCP: Bool): Int32 {
        var i2: Int32 = 0
        let oldBlock: Int32
        let newBlock: Int32
        i2 = getIndex2Block(c, forLSCP)
        i2 += (shr(c, UTRIE2_SHIFT_2)) & UTRIE2_INDEX_2_MASK
        oldBlock = index2[Int64(i2)]
        if (isWritableBlock(oldBlock)) {
            return oldBlock
        }
        newBlock = allocDataBlock(oldBlock)
        setIndex2Entry(i2, newBlock)
        return newBlock
    }

    public func set(c: Int32, value: Int32): Trie2Writable {
        if (c < 0 || c > 1114111) {
            throw IllegalArgumentException("Invalid code point.")
        }
        set(c, true, value)
        fHash = 0
        return this
    }

    private func set(c: Int32, forLSCP: Bool, value: Int32): Trie2Writable {
        let block: Int32
        if (isCompacted) {
            uncompact()
        }
        block = getDataBlock(c, forLSCP)
        data[Int64(block + (c & UTRIE2_DATA_MASK))] = value
        return this
    }

    private func uncompact(): Unit {
        let tempTrie = Trie2Writable(this)
        this.index1 = tempTrie.index1
        this.index2 = tempTrie.index2
        this.data = tempTrie.data
        this.index2ength = tempTrie.index2ength
        this.dataCapacity = tempTrie.dataCapacity
        this.isCompacted = tempTrie.isCompacted
        this.header = tempTrie.header
        this.index = tempTrie.index
        this.data16 = tempTrie.data16
        this.data32 = tempTrie.data32
        this.indexLength = tempTrie.indexLength
        this.dataLength = tempTrie.dataLength
        this.index2NullOffset = tempTrie.index2NullOffset
        this.initialValue = tempTrie.initialValue
        this.errorValue = tempTrie.errorValue
        this.highStart = tempTrie.highStart
        this.highValueIndex = tempTrie.highValueIndex
        this.dataNullOffset = tempTrie.dataNullOffset
    }

    private func writeBlock(block: Int32, value: Int32): Unit {
        var tempblock = block
        let limit = tempblock + UTRIE2_DATA_BLOCK_LENGTH
        while (tempblock < limit) {
            data[Int64(match (0) { case _ => tempblock++; tempblock - 1 })] = value
        }
    }

    private func fillBlock(block: Int32, start: Int32, limit: Int32, value: Int32, initialValue: Int32, overwrite: Bool): Unit {
        var i: Int32 = 0
        let pLimit = block + limit
        if (overwrite) {
            i = block + start
            while (i < pLimit) {
                data[Int64(i)] = value
                i++
            }
        } else {
            i = block + start
            while (i < pLimit) {
                if (data[Int64(i)] == initialValue) {
                    data[Int64(i)] = value
                }
                i++
            }
        }
    }

    public func setRange(start: Int32, end: Int32, value: Int32, overwrite: Bool): Trie2Writable {
        var tempstart = start
        var block: Int32 = 0
        let rest: Int32
        var repeatBlock: Int32 = 0
        var limit: Int32 = 0
        if (tempstart > 1114111 || tempstart < 0 || end > 1114111 || end < 0 || tempstart > end) {
            throw IllegalArgumentException("Invalid code point range.")
        }
        if (!overwrite && value == initialValue) {
            return this
        }
        fHash = 0
        if (isCompacted) {
            this.uncompact()
        }
        limit = end + 1
        if ((tempstart & UTRIE2_DATA_MASK) != 0) {
            let nextStart: Int32
            block = getDataBlock(tempstart, true)
            nextStart = (tempstart + UTRIE2_DATA_BLOCK_LENGTH) & 
            if (nextStart <= limit) {
                fillBlock(block, tempstart & UTRIE2_DATA_MASK, UTRIE2_DATA_BLOCK_LENGTH, value, initialValue, overwrite)
                tempstart = nextStart
            } else {
                fillBlock(block, tempstart & UTRIE2_DATA_MASK, limit & UTRIE2_DATA_MASK, value, initialValue, overwrite)
                return this
            }
        }
        rest = limit & UTRIE2_DATA_MASK
        limit &= 
        if (value == initialValue) {
            repeatBlock = dataNullOffset
        } else {
            repeatBlock = -1
        }
        while (tempstart < limit) {
            var i2: Int32 = 0
            var setRepeatBlock = false
            if (value == initialValue && isInNullBlock(tempstart, true)) {
                tempstart += UTRIE2_DATA_BLOCK_LENGTH
                continue
            }
            i2 = getIndex2Block(tempstart, true)
            i2 += (shr(tempstart, UTRIE2_SHIFT_2)) & UTRIE2_INDEX_2_MASK
            block = index2[Int64(i2)]
            if (isWritableBlock(block)) {
                if (overwrite && block >= UNEWTRIE2_DATA_0800_OFFSET) {
                    setRepeatBlock = true
                } else {
                    fillBlock(block, 0, UTRIE2_DATA_BLOCK_LENGTH, value, initialValue, overwrite)
                }
            } else if (data[Int64(block)] != value && (overwrite || block == dataNullOffset)) {
                setRepeatBlock = true
            }
            if (setRepeatBlock) {
                if (repeatBlock >= 0) {
                    setIndex2Entry(i2, repeatBlock)
                } else {
                    repeatBlock = getDataBlock(tempstart, true)
                    writeBlock(repeatBlock, value)
                }
            }
            tempstart += UTRIE2_DATA_BLOCK_LENGTH
        }
        if (rest > 0) {
            block = getDataBlock(tempstart, true)
            fillBlock(block, 0, rest, value, initialValue, overwrite)
        }
        return this
    }

    public func setRange(range: Trie2_Range, overwrite: Bool): Trie2Writable {
        fHash = 0
        if (range.leadSurrogate) {
            var c = range.startCodePoint
            while (c <= range.endCodePoint) {
                if (overwrite || getFromU16SingleLead(Char(c)) == this.initialValue) {
                    setForLeadSurrogateCodeUnit(Char(c), range.value)
                }
                c++
            }
        } else {
            setRange(range.startCodePoint, range.endCodePoint, range.value, overwrite)
        }
        return this
    }

    public func setForLeadSurrogateCodeUnit(codeUnit: Char, value: Int32): Trie2Writable {
        fHash = 0
        set(Int32(UInt32(codeUnit)), false, value)
        return this
    }

    public override func get(codePoint: Int32): Int32 {
        if (codePoint < 0 || codePoint > 1114111) {
            return errorValue
        } else {
            return get(codePoint, true)
        }
    }

    private func get(c: Int32, fromLSCP: Bool): Int32 {
        let i2: Int32
        let block: Int32
        if (c >= highStart && (!(c >= 55296 && c < 56320) || fromLSCP)) {
            return data[Int64(dataLength - UTRIE2_DATA_GRANULARITY)]
        }
        if ((c >= 55296 && c < 56320) && fromLSCP) {
            i2 = (UTRIE2_LSCP_INDEX_2_OFFSET - (shr(55296, UTRIE2_SHIFT_2))) + (shr(c, UTRIE2_SHIFT_2))
        } else {
            i2 = index1[Int64(shr(c, UTRIE2_SHIFT_1))] + ((shr(c, UTRIE2_SHIFT_2)) & UTRIE2_INDEX_2_MASK)
        }
        block = index2[Int64(i2)]
        return data[Int64(block + (c & UTRIE2_DATA_MASK))]
    }

    public override func getFromU16SingleLead(c: Char): Int32 {
        return get(Int32(UInt32(c)), false)
    }

    private func equal_int(a: Array<Int32>, s: Int32, t: Int32, length: Int32): Bool {
        var i = 0
        while (i < length) {
            if (a[Int64(s + i)] != a[Int64(t + i)]) {
                return false
            }
            i++
        }
        return true
    }

    private func findSameIndex2Block(index2ength: Int32, otherBlock: Int32): Int32 {
        var tempindex2ength = index2ength
        var block: Int32 = 0
        tempindex2ength -= UTRIE2_INDEX_2_BLOCK_LENGTH
        block = 0
        while (block <= tempindex2ength) {
            if (equal_int(index2, block, otherBlock, UTRIE2_INDEX_2_BLOCK_LENGTH)) {
                return block
            }
            block++
        }
        return -1
    }

    private func findSameDataBlock(dataLength: Int32, otherBlock: Int32, blockLength: Int32): Int32 {
        var tempdataLength = dataLength
        var block: Int32 = 0
        tempdataLength -= blockLength
        block = 0
        while (block <= tempdataLength) {
            if (equal_int(data, block, otherBlock, blockLength)) {
                return block
            }
            block += UTRIE2_DATA_GRANULARITY
        }
        return -1
    }

    private func findHighStart(highValue: Int32): Int32 {
        var value: Int32 = 0
        var c: Int32 = 0
        let prev: Int32
        var i1: Int32 = 0
        var i2: Int32 = 0
        var j: Int32 = 0
        var i2Block: Int32 = 0
        var prevI2Block: Int32 = 0
        var block: Int32 = 0
        var prevBlock: Int32 = 0
        if (highValue == initialValue) {
            prevI2Block = index2NullOffset
            prevBlock = dataNullOffset
        } else {
            prevI2Block = -1
            prevBlock = -1
        }
        prev = 1114112
        i1 = UNEWTRIE2_INDEX_1_LENGTH
        c = prev
        while (c > 0) {
            i2Block = index1[Int64(match (0) { case _ => i1--; i1 })]
            if (i2Block == prevI2Block) {
                c -= UTRIE2_CP_PER_INDEX_1_ENTRY
                continue
            }
            prevI2Block = i2Block
            if (i2Block == index2NullOffset) {
                if (highValue != initialValue) {
                    return c
                }
                c -= UTRIE2_CP_PER_INDEX_1_ENTRY
            } else {
                i2 = UTRIE2_INDEX_2_BLOCK_LENGTH
                while (i2 > 0) {
                    block = index2[Int64(i2Block + match (0) { case _ => i2--; i2 })]
                    if (block == prevBlock) {
                        c -= UTRIE2_DATA_BLOCK_LENGTH
                        continue
                    }
                    prevBlock = block
                    if (block == dataNullOffset) {
                        if (highValue != initialValue) {
                            return c
                        }
                        c -= UTRIE2_DATA_BLOCK_LENGTH
                    } else {
                        j = UTRIE2_DATA_BLOCK_LENGTH
                        while (j > 0) {
                            value = data[Int64(block + match (0) { case _ => j--; j })]
                            if (value != highValue) {
                                return c
                            }
                            c--
                        }
                    }
                }
            }
        }
        return 0
    }

    private func compactData(): Unit {
        var start: Int32 = 0
        var newStart: Int32 = 0
        var movedStart: Int32 = 0
        var blockLength: Int32 = 0
        var overlap: Int32 = 0
        var i: Int32 = 0
        var mapIndex: Int32 = 0
        var blockCount: Int32 = 0
        newStart = UTRIE2_DATA_START_OFFSET
        start = 0
        i = 0
        while (start < newStart) {
            map[Int64(i)] = start
            start += UTRIE2_DATA_BLOCK_LENGTH
            i++
        }
        blockLength = 64
        blockCount = shr(blockLength, UTRIE2_SHIFT_2)
        start = newStart
        while (start < dataLength) {
            if (start == UNEWTRIE2_DATA_0800_OFFSET) {
                blockLength = UTRIE2_DATA_BLOCK_LENGTH
                blockCount = 1
            }
            if (map[Int64(shr(start, UTRIE2_SHIFT_2))] <= 0) {
                start += blockLength
                continue
            }
            movedStart = findSameDataBlock(newStart, start, blockLength)
            if (movedStart >= 0) {
                i = blockCount
                mapIndex = shr(start, UTRIE2_SHIFT_2)
                while (i > 0) {
                    map[Int64(match (0) { case _ => mapIndex++; mapIndex - 1 })] = movedStart
                    movedStart += UTRIE2_DATA_BLOCK_LENGTH
                    i--
                }
                start += blockLength
                continue
            }
            overlap = blockLength - UTRIE2_DATA_GRANULARITY
            while (overlap > 0 && !equal_int(data, (newStart - overlap), start, overlap)) {
                overlap -= UTRIE2_DATA_GRANULARITY
            }
            if (overlap > 0 || newStart < start) {
                movedStart = newStart - overlap
                i = blockCount
                mapIndex = shr(start, UTRIE2_SHIFT_2)
                while (i > 0) {
                    map[Int64(match (0) { case _ => mapIndex++; mapIndex - 1 })] = movedStart
                    movedStart += UTRIE2_DATA_BLOCK_LENGTH
                    i--
                }
                start += overlap
                i = blockLength - overlap
                while (i > 0) {
                    data[Int64(match (0) { case _ => newStart++; newStart - 1 })] = data[Int64(match (0) { case _ => start++; start - 1 })]
                    i--
                }
            } else {
                i = blockCount
                mapIndex = shr(start, UTRIE2_SHIFT_2)
                while (i > 0) {
                    map[Int64(match (0) { case _ => mapIndex++; mapIndex - 1 })] = start
                    start += UTRIE2_DATA_BLOCK_LENGTH
                    i--
                }
                newStart = start
            }
        }
        i = 0
        while (i < index2ength) {
            if (i == UNEWTRIE2_INDEX_GAP_OFFSET) {
                i += UNEWTRIE2_INDEX_GAP_LENGTH
            }
            index2[Int64(i)] = map[Int64(shr(index2[Int64(i)], UTRIE2_SHIFT_2))]
            i++
        }
        dataNullOffset = map[Int64(shr(dataNullOffset, UTRIE2_SHIFT_2))]
        while ((newStart & (UTRIE2_DATA_GRANULARITY - 1)) != 0) {
            data[Int64(match (0) { case _ => newStart++; newStart - 1 })] = initialValue
        }
        if (UTRIE2_DEBUG) {
            Console.stdOut.printf("compacting UTrie2: count of 32-bit data words %d->%d%n", [dataLength, newStart])
        }
        dataLength = newStart
    }

    private func compactIndex2(): Unit {
        var i: Int32 = 0
        var start: Int32 = 0
        var newStart: Int32 = 0
        var movedStart: Int32 = 0
        var overlap: Int32 = 0
        newStart = UTRIE2_INDEX_2_BMP_LENGTH
        start = 0
        i = 0
        while (start < newStart) {
            map[Int64(i)] = start
            start += UTRIE2_INDEX_2_BLOCK_LENGTH
            i++
        }
        newStart += UTRIE2_UTF8_2B_INDEX_2_LENGTH + (shr((highStart - 65536), UTRIE2_SHIFT_1))
        start = UNEWTRIE2_INDEX_2_NULL_OFFSET
        while (start < index2ength) {
            if ((match (0) { case _ => movedStart = findSameIndex2Block(newStart, start); movedStart }) >= 0) {
                map[Int64(shr(start, UTRIE2_SHIFT_1_2))] = movedStart
                start += UTRIE2_INDEX_2_BLOCK_LENGTH
                continue
            }
            overlap = UTRIE2_INDEX_2_BLOCK_LENGTH - 1
            while (overlap > 0 && !equal_int(index2, newStart - overlap, start, overlap)) {
                overlap--
            }
            if (overlap > 0 || newStart < start) {
                map[Int64(shr(start, UTRIE2_SHIFT_1_2))] = newStart - overlap
                start += overlap
                i = UTRIE2_INDEX_2_BLOCK_LENGTH - overlap
                while (i > 0) {
                    index2[Int64(match (0) { case _ => newStart++; newStart - 1 })] = index2[Int64(match (0) { case _ => start++; start - 1 })]
                    i--
                }
            } else {
                map[Int64(shr(start, UTRIE2_SHIFT_1_2))] = start
                start += UTRIE2_INDEX_2_BLOCK_LENGTH
                newStart = start
            }
        }
        i = 0
        while (i < UNEWTRIE2_INDEX_1_LENGTH) {
            index1[Int64(i)] = map[Int64(shr(index1[Int64(i)], UTRIE2_SHIFT_1_2))]
            i++
        }
        index2NullOffset = map[Int64(shr(index2NullOffset, UTRIE2_SHIFT_1_2))]
        while ((newStart & ((UTRIE2_DATA_GRANULARITY - 1) | 1)) != 0) {
            index2[Int64(match (0) { case _ => newStart++; newStart - 1 })] = shl(65535, UTRIE2_INDEX_SHIFT)
        }
        if (UTRIE2_DEBUG) {
            Console.stdOut.printf("compacting UTrie2: count of 16-bit index-2 words %d->%d%n", [index2ength, newStart])
        }
        index2ength = newStart
    }

    private func compactTrie(): Unit {
        var localHighStart: Int32 = 0
        let suppHighStart: Int32
        var highValue: Int32 = 0
        highValue = get(1114111)
        localHighStart = findHighStart(highValue)
        localHighStart = (localHighStart + (UTRIE2_CP_PER_INDEX_1_ENTRY - 1)) & 
        if (localHighStart == 1114112) {
            highValue = errorValue
        }
        this.highStart = localHighStart
        if (UTRIE2_DEBUG) {
            Console.stdOut.printf("UTrie2: highStart U+%04x  highValue 0x%x  initialValue 0x%x%n", [highStart, highValue, initialValue])
        }
        if (highStart < 1114112) {
            suppHighStart = if (highStart <= 65536) { 65536 } else { highStart }
            setRange(suppHighStart, 1114111, initialValue, true)
        }
        compactData()
        if (highStart > 65536) {
            compactIndex2()
        } else {
            if (UTRIE2_DEBUG) {
                Console.stdOut.printf("UTrie2: highStart U+%04x  count of 16-bit index-2 words %d->%d%n", [highStart, index2ength, UTRIE2_INDEX_1_OFFSET])
            }
        }
        data[Int64(match (0) { case _ => dataLength++; dataLength - 1 })] = highValue
        while ((dataLength & (UTRIE2_DATA_GRANULARITY - 1)) != 0) {
            data[Int64(match (0) { case _ => dataLength++; dataLength - 1 })] = initialValue
        }
        isCompacted = true
    }

    public func toTrie2_16(): Trie2_16 {
        let frozenTrie = Trie2_16()
        freeze(frozenTrie, Trie2_ValueWidth.BITS_16)
        return frozenTrie
    }

    public func toTrie2_32(): Trie2_32 {
        let frozenTrie = Trie2_32()
        freeze(frozenTrie, Trie2_ValueWidth.BITS_32)
        return frozenTrie
    }

    private static let UTRIE2_MAX_INDEX_LENGTH = 65535

    private static let UTRIE2_MAX_DATA_LENGTH = shl(65535, UTRIE2_INDEX_SHIFT)

    private func freeze(dest: Trie2, valueBits: Trie2_ValueWidth): Unit {
        var i: Int32 = 0
        let allIndexesLength: Int32
        let dataMove: Int32
        if (!isCompacted) {
            compactTrie()
        }
        if (highStart <= 65536) {
            allIndexesLength = UTRIE2_INDEX_1_OFFSET
        } else {
            allIndexesLength = index2ength
        }
        if (refEq(valueBits, Trie2_ValueWidth.BITS_16)) {
            dataMove = allIndexesLength
        } else {
            dataMove = 0
        }
        if (allIndexesLength > UTRIE2_MAX_INDEX_LENGTH || (dataMove + dataNullOffset) > 65535 || (dataMove + UNEWTRIE2_DATA_0800_OFFSET) > 65535 || (dataMove + dataLength) > UTRIE2_MAX_DATA_LENGTH) {
            throw UnsupportedOperationException("Trie2 data is too large.")
        }
        var indexLength = allIndexesLength
        if (refEq(valueBits, Trie2_ValueWidth.BITS_16)) {
            indexLength += dataLength
        } else {
            dest.data32 = Array<Int32>(Int64(dataLength)) { _ => 0 }
        }
        dest.index = Array<Char>(Int64(indexLength)) { _ => '\u{0000}' }
        dest.indexLength = allIndexesLength
        dest.dataLength = dataLength
        if (highStart <= 65536) {
            dest.index2NullOffset = 65535
        } else {
            dest.index2NullOffset = UTRIE2_INDEX_2_OFFSET + index2NullOffset
        }
        dest.initialValue = initialValue
        dest.errorValue = errorValue
        dest.highStart = highStart
        dest.highValueIndex = dataMove + dataLength - UTRIE2_DATA_GRANULARITY
        dest.dataNullOffset = (dataMove + dataNullOffset)
        dest.header = Trie2_UTrie2Header()
        dest.header.signature = 1416784178
        dest.header.options = if (refEq(valueBits, Trie2_ValueWidth.BITS_16)) { 0 } else { 1 }
        dest.header.indexLength = dest.indexLength
        dest.header.shiftedDataLength = shr(dest.dataLength, UTRIE2_INDEX_SHIFT)
        dest.header.index2NullOffset = dest.index2NullOffset
        dest.header.dataNullOffset = dest.dataNullOffset
        dest.header.shiftedHighStart = shr(dest.highStart, UTRIE2_SHIFT_1)
        var destIdx = 0
        i = 0
        while (i < UTRIE2_INDEX_2_BMP_LENGTH) {
            dest.index[Int64(match (0) { case _ => destIdx++; destIdx - 1 })] = Char(shr((index2[Int64(i)] + dataMove), UTRIE2_INDEX_SHIFT))
            i++
        }
        if (UTRIE2_DEBUG) {
            println("\n\nIndex2 for BMP limit is " + destIdx.format("x"))
        }
        i = 0
        while (i < (194 - 192)) {
            dest.index[Int64(match (0) { case _ => destIdx++; destIdx - 1 })] = Char(dataMove + UTRIE2_BAD_UTF8_DATA_OFFSET)
            i++
        }
        while (i < (224 - 192)) {
            dest.index[Int64(match (0) { case _ => destIdx++; destIdx - 1 })] = Char(dataMove + index2[Int64(shl(i, (6 - UTRIE2_SHIFT_2)))])
            i++
        }
        if (UTRIE2_DEBUG) {
            println("Index2 for UTF-8 2byte values limit is " + destIdx.format("x"))
        }
        if (highStart > 65536) {
            let index1ength = shr((highStart - 65536), UTRIE2_SHIFT_1)
            let index2Offset = UTRIE2_INDEX_2_BMP_LENGTH + UTRIE2_UTF8_2B_INDEX_2_LENGTH + index1ength
            i = 0
            while (i < index1ength) {
                dest.index[Int64(match (0) { case _ => destIdx++; destIdx - 1 })] = Char(UTRIE2_INDEX_2_OFFSET + index1[Int64(i + UTRIE2_OMITTED_BMP_INDEX_1_LENGTH)])
                i++
            }
            if (UTRIE2_DEBUG) {
                println("Index 1 for supplementals, limit is " + destIdx.format("x"))
            }
            i = 0
            while (i < index2ength - index2Offset) {
                dest.index[Int64(match (0) { case _ => destIdx++; destIdx - 1 })] = Char(shr((dataMove + index2[Int64(index2Offset + i)]), UTRIE2_INDEX_SHIFT))
                i++
            }
            if (UTRIE2_DEBUG) {
                println("Index 2 for supplementals, limit is " + destIdx.format("x"))
            }
        }
        match (valueBits) {
            case Trie2_ValueWidth.BITS_16 =>
                if (!(destIdx == dataMove)) {
                    throw AssertionError()
                }
                dest.data16 = destIdx
                i = 0
                while (i < dataLength) {
                    dest.index[Int64(match (0) { case _ => destIdx++; destIdx - 1 })] = Char(data[Int64(i)])
                    i++
                }
            case Trie2_ValueWidth.BITS_32 =>
                i = 0
                while (i < dataLength) {
                    dest.data32[Int64(i)] = this.data[Int64(i)]
                    i++
                }
            case _ => ()
        }
    }

    private static let UNEWTRIE2_INITIAL_DATA_LENGTH = shl(1, 14)

    private static let UNEWTRIE2_MEDIUM_DATA_LENGTH = shl(1, 17)

    private static let UNEWTRIE2_INDEX_2_NULL_OFFSET = UNEWTRIE2_INDEX_GAP_OFFSET + UNEWTRIE2_INDEX_GAP_LENGTH

    private static let UNEWTRIE2_INDEX_2_START_OFFSET = UNEWTRIE2_INDEX_2_NULL_OFFSET + UTRIE2_INDEX_2_BLOCK_LENGTH

    private static let UNEWTRIE2_DATA_NULL_OFFSET = UTRIE2_DATA_START_OFFSET

    private static let UNEWTRIE2_DATA_START_OFFSET = UNEWTRIE2_DATA_NULL_OFFSET + 64

    private static let UNEWTRIE2_DATA_0800_OFFSET = UNEWTRIE2_DATA_START_OFFSET + 1920

    private var index1: Array<Int32> = Array<Int32>(Int64(UNEWTRIE2_INDEX_1_LENGTH)) { _ => 0 }

    private var index2: Array<Int32> = Array<Int32>(Int64(UNEWTRIE2_MAX_INDEX_2_LENGTH)) { _ => 0 }

    private var data: Array<Int32>

    private var index2ength: Int32 = 0

    private var dataCapacity: Int32 = 0

    private var firstFreeBlock: Int32 = 0

    private var index2NullOffset: Int32 = 0

    private var isCompacted: Bool = false

    private var map: Array<Int32> = Array<Int32>(Int64(shr(UNEWTRIE2_MAX_DATA_LENGTH, UTRIE2_SHIFT_2))) { _ => 0 }

    private var UTRIE2_DEBUG = false
}
