package icu4cj.util

public class MutableCodePointTrie <: CodePointMap & Cloneable {
    public init(initialValue: Int32, errorValue: Int32) {
        super()
        index = Array<Int32>(Int64(BMP_I_LIMIT)) { _ => 0 }
        index3NullOffset = -1
        data = Array<Int32>(Int64(INITIAL_DATA_LENGTH)) { _ => 0 }
        dataNullOffset = -1
        origInitialValue = initialValue
        this.initialValue = initialValue
        this.errorValue = errorValue
        highValue = initialValue
    }

    public override func clone(): MutableCodePointTrie {
        try {
            let builder = super.toString()
            let iCapacity = if (highStart <= BMP_LIMIT) { BMP_I_LIMIT } else { I_LIMIT }
            builder.index = Array<Int32>(Int64(iCapacity)) { _ => 0 }
            builder.flags = Array<UInt8>(Int64(shr(UNICODE_LIMIT, CodePointTrie.SHIFT_3))) { _ => 0 }
            var i = 0
            let iLimit = shr(highStart, CodePointTrie.SHIFT_3)
            while (i < iLimit) {
                builder.index[Int64(i)] = index[Int64(i)]
                builder.flags[Int64(i)] = flags[Int64(i)]
                i++
            }
            builder.index3NullOffset = index3NullOffset
            builder.data = data.clone()
            builder.dataLength = dataLength
            builder.dataNullOffset = dataNullOffset
            builder.origInitialValue = origInitialValue
            builder.initialValue = initialValue
            builder.errorValue = errorValue
            builder.highStart = highStart
            builder.highValue = highValue
            if (!index16.isNone()) {
                throw AssertionError()
            }
            return builder
        } catch (ignored: CloneNotSupportedException) {
            return None
        }
    }

    public static func fromCodePointMap(map: CodePointMap): MutableCodePointTrie {
        let errorValue = map.get(-1)
        let initialValue = map.get(MAX_UNICODE)
        let mutableTrie = MutableCodePointTrie(initialValue, errorValue)
        let range = CodePointMap_Range()
        var start = 0
        while (map.getRange(start, None, range)) {
            let end = range.getEnd()
            let value = range.getValue()
            if (value != initialValue) {
                if (start == end) {
                    mutableTrie.set(start, value)
                } else {
                    mutableTrie.setRange(start, end, value)
                }
            }
            start = end + 1
        }
        return mutableTrie
    }

    private func clear(): Unit {
        index3NullOffset = match (0) { case _ => dataNullOffset = -1; dataNullOffset }
        dataLength = 0
        highValue = match (0) { case _ => initialValue = origInitialValue; initialValue }
        highStart = 0
        index16 = None
    }

    public override func get(c: Int32): Int32 {
        if (c < 0 || MAX_UNICODE < c) {
            return errorValue
        }
        if (c >= highStart) {
            return highValue
        }
        let i = shr(c, CodePointTrie.SHIFT_3)
        if (flags[Int64(i)] == ALL_SAME) {
            return index[Int64(i)]
        } else {
            return data[Int64(index[Int64(i)] + (c & CodePointTrie.SMALL_DATA_MASK))]
        }
    }

    private static func maybeFilterValue(value: Int32, initialValue: Int32, nullValue: Int32, filter: CodePointMap_ValueFilter): Int32 {
        var tempvalue = value
        if (tempvalue == initialValue) {
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
            var value = highValue
            if (filter.isSome()) {
                value = filter.apply(value)
            }
            range.set(start, MAX_UNICODE, value)
            return true
        }
        var nullValue = initialValue
        if (filter.isSome()) {
            nullValue = filter.apply(nullValue)
        }
        var c = start
        var trieValue = 0
        var value = 0
        var haveValue = false
        var i = shr(c, CodePointTrie.SHIFT_3)
                        trieValue = trieValue2
                    }
                } else {
                    trieValue = trieValue2
                    value = maybeFilterValue(trieValue2, initialValue, nullValue, filter)
                    haveValue = true
                }
                c = (c + CodePointTrie.SMALL_DATA_BLOCK_LENGTH) & 
            } else {
                var di = index[Int64(i)] + (c & CodePointTrie.SMALL_DATA_MASK)
                var trieValue2 = data[Int64(di)]
                if (haveValue) {
                    if (trieValue2 != trieValue) {
                        if (filter.isNone() || maybeFilterValue(trieValue2, initialValue, nullValue, filter) != value) {
                            range.set(start, c - 1, value)
                            return true
                        }
                        trieValue = trieValue2
                    }
                } else {
                    trieValue = trieValue2
                    value = maybeFilterValue(trieValue2, initialValue, nullValue, filter)
                    haveValue = true
                }
                while ((match (0) { case _ => c++; c } & CodePointTrie.SMALL_DATA_MASK) != 0) {
                    trieValue2 = data[Int64(match (0) { case _ => di++; di })]
                    if (trieValue2 != trieValue) {
                        if (filter.isNone() || maybeFilterValue(trieValue2, initialValue, nullValue, filter) != value) {
                            range.set(start, c - 1, value)
                            return true
                        }
                        trieValue = trieValue2
                    }
                }
            }
            i++
        } while (c < highStart)
        if (!(haveValue)) {
            throw AssertionError()
        }
        if (maybeFilterValue(highValue, initialValue, nullValue, filter) != value) {
            range.set(start, c - 1, value)
        } else {
            range.set(start, MAX_UNICODE, value)
        }
        return true
    }

    private func writeBlock(block: Int32, value: Int32): Unit {
        let limit = block + CodePointTrie.SMALL_DATA_BLOCK_LENGTH
        Arrays.fill(data, block, limit, value)
    }

    public func set(c: Int32, value: Int32): Unit {
        if (c < 0 || MAX_UNICODE < c) {
            throw IllegalArgumentException("invalid code point")
        }
        ensureHighStart(c)
        let block = getDataBlock(shr(c, CodePointTrie.SHIFT_3))
        data[Int64(block + (c & CodePointTrie.SMALL_DATA_MASK))] = value
    }

    private func fillBlock(block: Int32, start: Int32, limit: Int32, value: Int32): Unit {
        Arrays.fill(data, block + start, block + limit, value)
    }

    public func setRange(start: Int32, end: Int32, value: Int32): Unit {
        var tempstart = start
        if (tempstart < 0 || MAX_UNICODE < tempstart || end < 0 || MAX_UNICODE < end || tempstart > end) {
            throw IllegalArgumentException("invalid code point range")
        }
        ensureHighStart(end)
        var limit = end + 1
        if ((tempstart & CodePointTrie.SMALL_DATA_MASK) != 0) {
            let block = getDataBlock(shr(tempstart, CodePointTrie.SHIFT_3))
            let nextStart = (tempstart + CodePointTrie.SMALL_DATA_MASK) & 
            if (nextStart <= limit) {
                fillBlock(block, tempstart & CodePointTrie.SMALL_DATA_MASK, CodePointTrie.SMALL_DATA_BLOCK_LENGTH, value)
                tempstart = nextStart
            } else {
                fillBlock(block, tempstart & CodePointTrie.SMALL_DATA_MASK, limit & CodePointTrie.SMALL_DATA_MASK, value)
                return
            }
        }
        let rest = limit & CodePointTrie.SMALL_DATA_MASK
        limit &= 
        while (tempstart < limit) {
            let i = shr(tempstart, CodePointTrie.SHIFT_3)
            if (flags[Int64(i)] == ALL_SAME) {
                index[Int64(i)] = value
            } else {
                fillBlock(index[Int64(i)], 0, CodePointTrie.SMALL_DATA_BLOCK_LENGTH, value)
            }
            tempstart += CodePointTrie.SMALL_DATA_BLOCK_LENGTH
        }
        if (rest > 0) {
            let block = getDataBlock(shr(tempstart, CodePointTrie.SHIFT_3))
            fillBlock(block, 0, rest, value)
        }
    }

    public func buildImmutable(Type: CodePointTrie_Type, valueWidth: CodePointTrie_ValueWidth): CodePointTrie {
        if (Type.isNone() || valueWidth.isNone()) {
            throw IllegalArgumentException("The type and valueWidth must be specified.")
        }
        try {
            return build(Type, valueWidth)
        } finally {
            clear()
        }
    }

    private static let MAX_UNICODE = 1114111

    private static let UNICODE_LIMIT = 1114112

    private static let BMP_LIMIT = 65536

    private static let ASCII_LIMIT = 128

    static let I_LIMIT = shr(UNICODE_LIMIT, CodePointTrie.SHIFT_3)

    private static let BMP_I_LIMIT = shr(BMP_LIMIT, CodePointTrie.SHIFT_3)

    private static let ASCII_I_LIMIT = shr(ASCII_LIMIT, CodePointTrie.SHIFT_3)

    private static let SMALL_DATA_BLOCKS_PER_BMP_BLOCK = (shl(1, (CodePointTrie.FAST_SHIFT - CodePointTrie.SHIFT_3)))

    private static let ALL_SAME = 0u8

    private static let MIXED = 1u8

    private static let SAME_AS = 2u8

    private static let INITIAL_DATA_LENGTH = (shl(1, 14))

    private static let MEDIUM_DATA_LENGTH = (shl(1, 17))

    private static let MAX_DATA_LENGTH = UNICODE_LIMIT

    private static let I3_NULL = 0u8

    private static let I3_BMP = 1u8

    private static let I3_16 = 2u8

    private static let I3_18 = 3u8

    private static let INDEX_3_18BIT_BLOCK_LENGTH = CodePointTrie.INDEX_3_BLOCK_LENGTH + CodePointTrie.INDEX_3_BLOCK_LENGTH / 8

    private var index: Array<Int32>

    private var index3NullOffset: Int32 = 0

    private var data: Array<Int32>

    private var dataLength: Int32 = 0

    private var dataNullOffset: Int32 = 0

    private var origInitialValue: Int32 = 0

    private var initialValue: Int32 = 0

    private var errorValue: Int32 = 0

    private var highStart: Int32 = 0

    private var highValue: Int32 = 0

    private var index16: Array<Char>

    private var flags: Array<UInt8> = Array<UInt8>(Int64(shr(UNICODE_LIMIT, CodePointTrie.SHIFT_3))) { _ => 0 }

    private func ensureHighStart(c: Int32): Unit {
        var tempc = c
        if (tempc >= highStart) {
            tempc = (tempc + CodePointTrie.CP_PER_INDEX_2_ENTRY) & 
            var i = shr(highStart, CodePointTrie.SHIFT_3)
            let iLimit = shr(tempc, CodePointTrie.SHIFT_3)
            if (iLimit > Int32(index.size)) {
                let newIndex = Array<Int32>(Int64(I_LIMIT)) { _ => 0 }
                var j = 0
                while (j < i) {
                    newIndex[Int64(j)] = index[Int64(j)]
                    j++
                }
                index = newIndex
            }
            highStart = tempc
        }
    }

    private func allocDataBlock(blockLength: Int32): Int32 {
        let newBlock = dataLength
        let newTop = newBlock + blockLength
        if (newTop > Int32(data.size)) {
            let capacity: Int32
            if (Int32(data.size) < MEDIUM_DATA_LENGTH) {
                capacity = MEDIUM_DATA_LENGTH
            } else if (Int32(data.size) < MAX_DATA_LENGTH) {
                capacity = MAX_DATA_LENGTH
            } else {
                throw AssertionError()
            }
            let newData = Array<Int32>(Int64(capacity)) { _ => 0 }
            var j = 0
            while (j < dataLength) {
                newData[Int64(j)] = data[Int64(j)]
                j++
            }
            data = newData
        }
        dataLength = newTop
        return newBlock
    }

    private func getDataBlock(i: Int32): Int32 {
        if (flags[Int64(i)] == MIXED) {
            return index[Int64(i)]
        }
        if (i < BMP_I_LIMIT) {
            var newBlock = allocDataBlock(CodePointTrie.FAST_DATA_BLOCK_LENGTH)
            var iStart = i & 
            let iLimit = iStart + SMALL_DATA_BLOCKS_PER_BMP_BLOCK
                writeBlock(newBlock, index[Int64(iStart)])
                flags[Int64(iStart)] = MIXED
                index[Int64(match (0) { case _ => iStart++; iStart - 1 })] = newBlock
                newBlock += CodePointTrie.SMALL_DATA_BLOCK_LENGTH
            } while (iStart < iLimit)
            return index[Int64(i)]
        } else {
            let newBlock = allocDataBlock(CodePointTrie.SMALL_DATA_BLOCK_LENGTH)
            if (newBlock < 0) {
                return newBlock
            }
            writeBlock(newBlock, index[Int64(i)])
            flags[Int64(i)] = MIXED
            index[Int64(i)] = newBlock
            return newBlock
        }
    }

    private func maskValues(mask: Int32): Unit {
        initialValue &= mask
        errorValue &= mask
        highValue &= mask
        let iLimit = shr(highStart, CodePointTrie.SHIFT_3)
                i++
            }
        } while (false)
        } while (false)
    }

    static func equalBlocks(s: Array<Int32>, si: Int32, t: Array<Int32>, ti: Int32, length: Int32): Bool {
        var tempsi = si
        var tempti = ti
        var templength = length
        while (templength > 0 && s[Int64(tempsi)] == t[Int64(tempti)]) {
            tempsi++
            tempti++
            templength--
        }
        return templength == 0
    }

    static func equalBlocks(s: Array<Char>, si: Int32, t: Array<Int32>, ti: Int32, length: Int32): Bool {
        var tempsi = si
        var tempti = ti
        var templength = length
        while (templength > 0 && Int32(UInt32(s[Int64(tempsi)])) == t[Int64(tempti)]) {
            tempsi++
            tempti++
            templength--
        }
        return templength == 0
    }

    static func equalBlocks(s: Array<Char>, si: Int32, t: Array<Char>, ti: Int32, length: Int32): Bool {
        var tempsi = si
        var tempti = ti
        var templength = length
        while (templength > 0 && s[Int64(tempsi)] == t[Int64(tempti)]) {
            tempsi++
            tempti++
            templength--
        }
        return templength == 0
    }

    static func allValuesSameAs(p: Array<Int32>, pi: Int32, length: Int32, value: Int32): Bool {
        var temppi = pi
        let pLimit = temppi + length
        while (temppi < pLimit && p[Int64(temppi)] == value) {
            temppi++
        }
        return temppi == pLimit
    }

    private static func findSameBlock(p: Array<Char>, pStart: Int32, length: Int32, q: Array<Char>, qStart: Int32, blockLength: Int32): Int32 {
        var templength = length
        var temppStart = pStart
        templength -= blockLength
        while (temppStart <= templength) {
            if (equalBlocks(p, temppStart, q, qStart, blockLength)) {
                return temppStart
            }
            temppStart++
        }
        return -1
    }

    private static func findAllSameBlock(p: Array<Int32>, start: Int32, limit: Int32, value: Int32, blockLength: Int32): Int32 {
        var templimit = limit
        templimit -= blockLength
        var block = start
        while (block <= templimit) {
            if (p[Int64(block)] == value) {
                var i = 1
                while (true) {
                    if (i == blockLength) {
                        return block
                    }
                    if (p[Int64(block + i)] != value) {
                        block += i
                        break
                    }
                    i++
                }
            }
            block++
        }
        return -1
    }

    private static func getOverlap(p: Array<Int32>, length: Int32, q: Array<Int32>, qStart: Int32, blockLength: Int32): Int32 {
        var overlap = blockLength - 1
        if (!(overlap <= length)) {
            throw AssertionError()
        }
        while (overlap > 0 && !equalBlocks(p, length - overlap, q, qStart, overlap)) {
            overlap--
        }
        return overlap
    }

    private static func getOverlap(p: Array<Char>, length: Int32, q: Array<Int32>, qStart: Int32, blockLength: Int32): Int32 {
        var overlap = blockLength - 1
        if (!(overlap <= length)) {
            throw AssertionError()
        }
        while (overlap > 0 && !equalBlocks(p, length - overlap, q, qStart, overlap)) {
            overlap--
        }
        return overlap
    }

    private static func getOverlap(p: Array<Char>, length: Int32, q: Array<Char>, qStart: Int32, blockLength: Int32): Int32 {
        var overlap = blockLength - 1
        if (!(overlap <= length)) {
            throw AssertionError()
        }
        while (overlap > 0 && !equalBlocks(p, length - overlap, q, qStart, overlap)) {
            overlap--
        }
        return overlap
    }

    private static func getAllSameOverlap(p: Array<Int32>, length: Int32, value: Int32, blockLength: Int32): Int32 {
        let min = length - (blockLength - 1)
        var i = length
        while (min < i && p[Int64(i - 1)] == value) {
            i--
        }
        return length - i
    }

    private static func isStartOfSomeFastBlock(dataOffset: Int32, index: Array<Int32>, fastILimit: Int32): Bool {
        var i = 0
        while (i < fastILimit) {
            if (index[Int64(i)] == dataOffset) {
                return true
            }
            i += SMALL_DATA_BLOCKS_PER_BMP_BLOCK
        }
        return false
    }

    private func findHighStart(): Int32 {
        var i = shr(highStart, CodePointTrie.SHIFT_3)
        while (i > 0) {
            let match: Bool
            if (flags[Int64(match (0) { case _ => i--; i })] == ALL_SAME) {
                match = index[Int64(i)] == highValue
            } else {
                let p = index[Int64(i)]
                var j = 0
                while (true) {
                    if (j == CodePointTrie.SMALL_DATA_BLOCK_LENGTH) {
                        match = true
                        break
                    }
                    if (data[Int64(p + j)] != highValue) {
                        match = false
                        break
                    }
                    j++
                }
            }
            if (!match) {
                return shl((i + 1), CodePointTrie.SHIFT_3)
            }
        }
        return 0
    }

    private func compactWholeDataBlocks(fastILimit: Int32, allSameBlocks: MutableCodePointTrie_AllSameBlocks): Int32 {
        var newDataCapacity = ASCII_LIMIT
        newDataCapacity += CodePointTrie.SMALL_DATA_BLOCK_LENGTH
        newDataCapacity += 4
        let iLimit = shr(highStart, CodePointTrie.SHIFT_3)
        var blockLength = CodePointTrie.FAST_DATA_BLOCK_LENGTH
        var inc = SMALL_DATA_BLOCKS_PER_BMP_BLOCK
        var i = 0
        while (i < iLimit) {
            if (i == fastILimit) {
                blockLength = CodePointTrie.SMALL_DATA_BLOCK_LENGTH
                inc = 1
            }
            var value = index[Int64(i)]
            if (flags[Int64(i)] == MIXED) {
                let p = value
                value = data[Int64(p)]
                if (allValuesSameAs(data, p + 1, blockLength - 1, value)) {
                    flags[Int64(i)] = ALL_SAME
                    index[Int64(i)] = value
                } else {
                    newDataCapacity += blockLength
                    continue
                }
            } else {
                if (!(flags[Int64(i)] == ALL_SAME)) {
                    throw AssertionError()
                }
                if (inc > 1) {
                    var allSame = true
                    let next_i = i + inc
                            if (index[Int64(j)] != value) {
                                allSame = false
                                break
                            }
                            j++
                        }
                    } while (false)
                    if (!allSame) {
                        if (getDataBlock(i) < 0) {
                            return -1
                        }
                        newDataCapacity += blockLength
                        continue
                    }
                }
            }
            var other = allSameBlocks.findOrAdd(i, inc, value)
            if (other == MutableCodePointTrie_AllSameBlocks.OVERFLOW) {
                var jInc = SMALL_DATA_BLOCKS_PER_BMP_BLOCK
                        if (j == fastILimit) {
                            jInc = 1
                        }
                        if (flags[Int64(j)] == ALL_SAME && index[Int64(j)] == value) {
                            allSameBlocks.add(j, jInc + inc, value)
                            other = j
                            break
                        }
                        j += jInc
                    }
                } while (false)
            }
            if (other >= 0) {
                flags[Int64(i)] = SAME_AS
                index[Int64(i)] = other
            } else {
                newDataCapacity += blockLength
            }
            i += inc
        }
        return newDataCapacity
    }

    private func compactData(fastILimit: Int32, newData: Array<Int32>, dataNullIndex: Int32, mixedBlocks: MutableCodePointTrie_MixedBlocks): Int32 {
        var newDataLength = 0
        } while (false)
        var blockLength = CodePointTrie.FAST_DATA_BLOCK_LENGTH
        mixedBlocks.initself(Int32(newData.size), blockLength)
        mixedBlocks.`extend`(newData, 0, 0, newDataLength)
        let iLimit = shr(highStart, CodePointTrie.SHIFT_3)
        var inc = SMALL_DATA_BLOCKS_PER_BMP_BLOCK
        var fastLength = 0
                if (flags[Int64(i)] == ALL_SAME) {
                    let value = index[Int64(i)]
                    var n = mixedBlocks.findAllSameBlock(newData, value)
                    while (n >= 0 && i == dataNullIndex && i >= fastILimit && n < fastLength && isStartOfSomeFastBlock(n, index, fastILimit)) {
                        n = findAllSameBlock(newData, n + 1, newDataLength, value, blockLength)
                    }
                    if (n >= 0) {
                        index[Int64(i)] = n
                    } else {
                        n = getAllSameOverlap(newData, newDataLength, value, blockLength)
                        index[Int64(i)] = newDataLength - n
                        let prevDataLength = newDataLength
                        while (n < blockLength) {
                            newData[Int64(match (0) { case _ => newDataLength++; newDataLength - 1 })] = value
                            n++
                        }
                        mixedBlocks.`extend`(newData, 0, prevDataLength, newDataLength)
                    }
                } else if (flags[Int64(i)] == MIXED) {
                    let block = index[Int64(i)]
                    var n = mixedBlocks.findBlock(newData, data, block)
                    if (n >= 0) {
                        index[Int64(i)] = n
                    } else {
                        n = getOverlap(newData, newDataLength, data, block, blockLength)
                        index[Int64(i)] = newDataLength - n
                        let prevDataLength = newDataLength
                        while (n < blockLength) {
                            newData[Int64(match (0) { case _ => newDataLength++; newDataLength - 1 })] = data[Int64(block + match (0) { case _ => n++; n - 1 })]
                        }
                        mixedBlocks.`extend`(newData, 0, prevDataLength, newDataLength)
                    }
                } else {
                    let j = index[Int64(i)]
                    index[Int64(i)] = index[Int64(j)]
                }
                i += inc
            }
        } while (false)
        return newDataLength
    }

    private func compactIndex(fastILimit: Int32, mixedBlocks: MutableCodePointTrie_MixedBlocks): Int32 {
        let fastIndexLength = shr(fastILimit, (CodePointTrie.FAST_SHIFT - CodePointTrie.SHIFT_3))
        if ((shr(highStart, CodePointTrie.FAST_SHIFT)) <= fastIndexLength) {
            index3NullOffset = CodePointTrie.NO_INDEX3_NULL_OFFSET
            return fastIndexLength
        }
        let fastIndex = Array<Char>(Int64(fastIndexLength)) { _ => '\u{0000}' }
        var i3FirstNull = -1
                        index3NullOffset = i3FirstNull
                    }
                } else {
                    i3FirstNull = -1
                }
                let iNext = i + SMALL_DATA_BLOCKS_PER_BMP_BLOCK
                while (match (0) { case _ => i++; i } < iNext) {
                    i3 += CodePointTrie.SMALL_DATA_BLOCK_LENGTH
                    index[Int64(i)] = i3
                }
                j++
            }
        } while (false)
        mixedBlocks.initself(fastIndexLength, CodePointTrie.INDEX_3_BLOCK_LENGTH)
        mixedBlocks.`extend`(fastIndex, 0, 0, fastIndexLength)
        var index3Capacity = 0
        i3FirstNull = index3NullOffset
        var hasLongI3Blocks = false
        let iStart = if (fastILimit < BMP_I_LIMIT) { 0 } else { BMP_I_LIMIT }
        let iLimit = shr(highStart, CodePointTrie.SHIFT_3)
                } while (match (0) { case _ => j++; j } < jLimit)
                if (isNull) {
                    flags[Int64(i)] = I3_NULL
                    if (i3FirstNull < 0) {
                        if (oredI3 <= 65535) {
                            index3Capacity += CodePointTrie.INDEX_3_BLOCK_LENGTH
                        } else {
                            index3Capacity += INDEX_3_18BIT_BLOCK_LENGTH
                            hasLongI3Blocks = true
                        }
                        i3FirstNull = 0
                    }
                } else {
                    if (oredI3 <= 65535) {
                        let n = mixedBlocks.findBlock(fastIndex, index, i)
                        if (n >= 0) {
                            flags[Int64(i)] = I3_BMP
                            index[Int64(i)] = n
                        } else {
                            flags[Int64(i)] = I3_16
                            index3Capacity += CodePointTrie.INDEX_3_BLOCK_LENGTH
                        }
                    } else {
                        flags[Int64(i)] = I3_18
                        index3Capacity += INDEX_3_18BIT_BLOCK_LENGTH
                        hasLongI3Blocks = true
                    }
                }
                i = j
            }
        } while (false)
        let index2Capacity = shr((iLimit - iStart), CodePointTrie.SHIFT_2_3)
        let index1ength = shr((index2Capacity + CodePointTrie.INDEX_2_MASK), CodePointTrie.SHIFT_1_2)
        let index16Capacity = fastIndexLength + index1ength + index3Capacity + index2Capacity + 1
        index16 = fastIndex.clone(0.. index16Capacity)
        mixedBlocks.initself(index16Capacity, CodePointTrie.INDEX_3_BLOCK_LENGTH)
        var longI3Blocks: MutableCodePointTrie_MixedBlocks
        if (hasLongI3Blocks) {
            longI3Blocks = MutableCodePointTrie_MixedBlocks()
            longI3Blocks.initself(index16Capacity, INDEX_3_18BIT_BLOCK_LENGTH)
        }
        let index2 = Array<Char>(Int64(index2Capacity)) { _ => '\u{0000}' }
        var i2ength = 0
        i3FirstNull = index3NullOffset
        let index3Start = fastIndexLength + index1ength
        var indexLength = index3Start
                if (f == I3_NULL) {
                    i3 = index3NullOffset
                } else if (f == I3_BMP) {
                    i3 = index[Int64(i)]
                } else if (f == I3_16) {
                    var n = mixedBlocks.findBlock(index16, index, i)
                    if (n >= 0) {
                        i3 = n
                    } else {
                        if (indexLength == index3Start) {
                            n = 0
                        } else {
                            n = getOverlap(index16, indexLength, index, i, CodePointTrie.INDEX_3_BLOCK_LENGTH)
                        }
                        i3 = indexLength - n
                        let prevIndexLength = indexLength
                        while (n < CodePointTrie.INDEX_3_BLOCK_LENGTH) {
                            index16[Int64(match (0) { case _ => indexLength++; indexLength - 1 })] = Char(index[Int64(i + match (0) { case _ => n++; n - 1 })])
                        }
                        mixedBlocks.`extend`(index16, index3Start, prevIndexLength, indexLength)
                        if (hasLongI3Blocks) {
                            longI3Blocks.`extend`(index16, index3Start, prevIndexLength, indexLength)
                        }
                    }
                } else {
                    if (!(f == I3_18)) {
                        throw AssertionError()
                    }
                    if (!(hasLongI3Blocks)) {
                        throw AssertionError()
                    }
                    var j = i
                    let jLimit = i + CodePointTrie.INDEX_3_BLOCK_LENGTH
                    var k = indexLength
                    var n = longI3Blocks.findBlock(index16, index16, indexLength)
                    if (n >= 0) {
                        i3 = n | 32768
                    } else {
                        if (indexLength == index3Start) {
                            n = 0
                        } else {
                            n = getOverlap(index16, indexLength, index16, indexLength, INDEX_3_18BIT_BLOCK_LENGTH)
                        }
                        i3 = (indexLength - n) | 32768
                        let prevIndexLength = indexLength
                        if (n > 0) {
                            let start = indexLength
                            while (n < INDEX_3_18BIT_BLOCK_LENGTH) {
                                index16[Int64(match (0) { case _ => indexLength++; indexLength - 1 })] = index16[Int64(start + match (0) { case _ => n++; n - 1 })]
                            }
                        } else {
                            indexLength += INDEX_3_18BIT_BLOCK_LENGTH
                        }
                        mixedBlocks.`extend`(index16, index3Start, prevIndexLength, indexLength)
                        if (hasLongI3Blocks) {
                            longI3Blocks.`extend`(index16, index3Start, prevIndexLength, indexLength)
                        }
                    }
                }
                if (index3NullOffset < 0 && i3FirstNull >= 0) {
                    index3NullOffset = i3
                }
                index2[Int64(match (0) { case _ => i2ength++; i2ength - 1 })] = Char(i3)
                i += CodePointTrie.INDEX_3_BLOCK_LENGTH
            }
        } while (false)
        if (!(i2ength == index2Capacity)) {
            throw AssertionError()
        }
        if (!(indexLength <= index3Start + index3Capacity)) {
            throw AssertionError()
        }
        if (index3NullOffset < 0) {
            index3NullOffset = CodePointTrie.NO_INDEX3_NULL_OFFSET
        }
        if (indexLength >= (CodePointTrie.NO_INDEX3_NULL_OFFSET + CodePointTrie.INDEX_3_BLOCK_LENGTH)) {
            throw IndexOutOfBoundsException("The trie data exceeds limitations of the data structure.")
        }
        var blockLength = CodePointTrie.INDEX_2_BLOCK_LENGTH
        var i1 = fastIndexLength
                    n = mixedBlocks.findBlock(index16, index2, i)
                } else {
                    blockLength = i2ength - i
                    n = findSameBlock(index16, index3Start, indexLength, index2, i, blockLength)
                }
                let i2: Int32
                if (n >= 0) {
                    i2 = n
                } else {
                    if (indexLength == index3Start) {
                        n = 0
                    } else {
                        n = getOverlap(index16, indexLength, index2, i, blockLength)
                    }
                    i2 = indexLength - n
                    let prevIndexLength = indexLength
                    while (n < blockLength) {
                        index16[Int64(match (0) { case _ => indexLength++; indexLength - 1 })] = index2[Int64(i + match (0) { case _ => n++; n - 1 })]
                    }
                    mixedBlocks.`extend`(index16, index3Start, prevIndexLength, indexLength)
                }
                index16[Int64(match (0) { case _ => i1++; i1 - 1 })] = Char(i2)
                i += blockLength
            }
        } while (false)
        if (!(i1 == index3Start)) {
            throw AssertionError()
        }
        if (!(indexLength <= index16Capacity)) {
            throw AssertionError()
        }
        return indexLength
    }

    private func compactTrie(fastILimit: Int32): Int32 {
        if (!((highStart & (CodePointTrie.CP_PER_INDEX_2_ENTRY - 1)) == 0)) {
            throw AssertionError()
        }
        highValue = get(MAX_UNICODE)
        var realHighStart = findHighStart()
        realHighStart = (realHighStart + (CodePointTrie.CP_PER_INDEX_2_ENTRY - 1)) & 
        if (realHighStart == UNICODE_LIMIT) {
            highValue = initialValue
        }
        let fastLimit = shl(fastILimit, CodePointTrie.SHIFT_3)
        if (realHighStart < fastLimit) {
            } while (false)
            highStart = fastLimit
        } else {
            highStart = realHighStart
        }
        let asciiData = Array<Int32>(Int64(ASCII_LIMIT)) { _ => 0 }
        } while (false)
        let allSameBlocks = MutableCodePointTrie_AllSameBlocks()
        let newDataCapacity = compactWholeDataBlocks(fastILimit, allSameBlocks)
        let newData = asciiData.clone(0.. newDataCapacity)
        let dataNullIndex = allSameBlocks.findMostUsed()
        let mixedBlocks = MutableCodePointTrie_MixedBlocks()
        let newDataLength = compactData(fastILimit, newData, dataNullIndex, mixedBlocks)
        if (!(newDataLength <= newDataCapacity)) {
            throw AssertionError()
        }
        data = newData
        dataLength = newDataLength
        if (dataLength > (262143 + CodePointTrie.SMALL_DATA_BLOCK_LENGTH)) {
            throw IndexOutOfBoundsException("The trie data exceeds limitations of the data structure.")
        }
        if (dataNullIndex >= 0) {
            dataNullOffset = index[Int64(dataNullIndex)]
            initialValue = data[Int64(dataNullOffset)]
        } else {
            dataNullOffset = CodePointTrie.NO_DATA_NULL_OFFSET
        }
        let indexLength = compactIndex(fastILimit, mixedBlocks)
        highStart = realHighStart
        return indexLength
    }

    private func build(Type: CodePointTrie_Type, valueWidth: CodePointTrie_ValueWidth): CodePointTrie {
        match (valueWidth) {
            case CodePointTrie_ValueWidth.BITS_32 => ()
            case CodePointTrie_ValueWidth.BITS_16 => maskValues(65535)
            case CodePointTrie_ValueWidth.BITS_8 => maskValues(255)
            case _ => throw IllegalArgumentException()
        }
        let fastLimit = if (refEq(Type, CodePointTrie_Type.FAST)) { BMP_LIMIT } else { CodePointTrie.SMALL_LIMIT }
        var indexLength = compactTrie(shr(fastLimit, CodePointTrie.SHIFT_3))
        if (refEq(valueWidth, CodePointTrie_ValueWidth.BITS_32) && (indexLength & 1) != 0) {
            index16[Int64(match (0) { case _ => indexLength++; indexLength - 1 })] = Char(65518)
        }
        var length = indexLength * 2
        if (refEq(valueWidth, CodePointTrie_ValueWidth.BITS_16)) {
            if (((indexLength ^ dataLength) & 1) != 0) {
                data[Int64(match (0) { case _ => dataLength++; dataLength - 1 })] = errorValue
            }
            if (data[Int64(dataLength - 1)] != errorValue || data[Int64(dataLength - 2)] != highValue) {
                data[Int64(match (0) { case _ => dataLength++; dataLength - 1 })] = highValue
                data[Int64(match (0) { case _ => dataLength++; dataLength - 1 })] = errorValue
            }
            length += dataLength * 2
        } else if (refEq(valueWidth, CodePointTrie_ValueWidth.BITS_32)) {
            if (data[Int64(dataLength - 1)] != errorValue || data[Int64(dataLength - 2)] != highValue) {
                if (data[Int64(dataLength - 1)] != highValue) {
                    data[Int64(match (0) { case _ => dataLength++; dataLength - 1 })] = highValue
                }
                data[Int64(match (0) { case _ => dataLength++; dataLength - 1 })] = errorValue
            }
            length += dataLength * 4
        } else {
            var and3 = (length + dataLength) & 3
            if (and3 == 0 && data[Int64(dataLength - 1)] == errorValue && data[Int64(dataLength - 2)] == highValue) { } else if (and3 == 3 && data[Int64(dataLength - 1)] == highValue) {
                data[Int64(match (0) { case _ => dataLength++; dataLength - 1 })] = errorValue
            } else {
                while (and3 != 2) {
                    data[Int64(match (0) { case _ => dataLength++; dataLength - 1 })] = highValue
                    and3 = (and3 + 1) & 3
                }
                data[Int64(match (0) { case _ => dataLength++; dataLength - 1 })] = highValue
                data[Int64(match (0) { case _ => dataLength++; dataLength - 1 })] = errorValue
            }
            length += dataLength
        }
        if (!((length & 3) == 0)) {
            throw AssertionError()
        }
        let trieIndex: Array<Char>
        if (highStart <= fastLimit) {
            trieIndex = Array<Char>(Int64(indexLength)) { _ => '\u{0000}' }
            } while (false)
        } else {
            if (indexLength == Int32(index16.size)) {
                trieIndex = index16
                index16 = None
            } else {
                trieIndex = index16.clone(0.. indexLength)
            }
        }
        match (valueWidth) {
            case CodePointTrie_ValueWidth.BITS_16 =>
                let data16 = Array<Char>(Int64(dataLength)) { _ => '\u{0000}' }
                } while (false)
                return if (refEq(Type, CodePointTrie_Type.FAST)) { CodePointTrie_Fast16(trieIndex, data16, highStart, index3NullOffset, dataNullOffset) } else { CodePointTrie_Small16(trieIndex, data16, highStart, index3NullOffset, dataNullOffset) }
            case CodePointTrie_ValueWidth.BITS_32 =>
                let data32 = data.clone(0.. dataLength)
                return if (refEq(Type, CodePointTrie_Type.FAST)) { CodePointTrie_Fast32(trieIndex, data32, highStart, index3NullOffset, dataNullOffset) } else { CodePointTrie_Small32(trieIndex, data32, highStart, index3NullOffset, dataNullOffset) }
            case CodePointTrie_ValueWidth.BITS_8 =>
                let data8 = Array<UInt8>(Int64(dataLength)) { _ => 0 }
                } while (false)
                return if (refEq(Type, CodePointTrie_Type.FAST)) { CodePointTrie_Fast8(trieIndex, data8, highStart, index3NullOffset, dataNullOffset) } else { CodePointTrie_Small8(trieIndex, data8, highStart, index3NullOffset, dataNullOffset) }
            case _ => throw IllegalArgumentException()
        }
    }
}


class MutableCodePointTrie_AllSameBlocks {
    static let NEW_UNIQUE = -1

    static let OVERFLOW = -2

    init() {
        mostRecent = -1
    }

    public func findOrAdd(index: Int32, count: Int32, value: Int32): Int32 {
        if (mostRecent >= 0 && values[Int64(mostRecent)] == value) {
            refCounts[Int64(mostRecent)] += count
            return indexes[Int64(mostRecent)]
        }
        var i = 0
        while (i < length) {
            if (values[Int64(i)] == value) {
                mostRecent = i
                refCounts[Int64(i)] += count
                return indexes[Int64(i)]
            }
            i++
        }
        if (length == CAPACITY) {
            return OVERFLOW
        }
        mostRecent = length
        indexes[Int64(length)] = index
        values[Int64(length)] = value
        refCounts[Int64(match (0) { case _ => length++; length - 1 })] = count
        return NEW_UNIQUE
    }

    public func add(index: Int32, count: Int32, value: Int32): Unit {
        if (!(length == CAPACITY)) {
            throw AssertionError()
        }
        var least = -1
        var leastCount = MutableCodePointTrie.I_LIMIT
        var i = 0
        while (i < length) {
            if (!(values[Int64(i)] != value)) {
                throw AssertionError()
            }
            if (refCounts[Int64(i)] < leastCount) {
                least = i
                leastCount = refCounts[Int64(i)]
            }
            i++
        }
        if (!(least >= 0)) {
            throw AssertionError()
        }
        mostRecent = least
        indexes[Int64(least)] = index
        values[Int64(least)] = value
        refCounts[Int64(least)] = count
    }

    public func findMostUsed(): Int32 {
        if (length == 0) {
            return -1
        }
        var max = -1
        var maxCount = 0
        var i = 0
        while (i < length) {
            if (refCounts[Int64(i)] > maxCount) {
                max = i
                maxCount = refCounts[Int64(i)]
            }
            i++
        }
        return indexes[Int64(max)]
    }

    private static let CAPACITY = 32

    private var length: Int32 = 0

    private var mostRecent: Int32 = 0

    private var indexes: Array<Int32> = Array<Int32>(Int64(CAPACITY)) { _ => 0 }

    private var values: Array<Int32> = Array<Int32>(Int64(CAPACITY)) { _ => 0 }

    private var refCounts: Array<Int32> = Array<Int32>(Int64(CAPACITY)) { _ => 0 }
}


class MutableCodePointTrie_MixedBlocks {

    public func initself(maxLength: Int32, newBlockLength: Int32): Unit {
        let maxDataIndex = maxLength - newBlockLength + 1
        let newLength: Int32
        if (maxDataIndex <= 4095) {
            newLength = 6007
            shift = 12
            mask = 4095
        } else if (maxDataIndex <= 32767) {
            newLength = 50021
            shift = 15
            mask = 32767
        } else if (maxDataIndex <= 131071) {
            newLength = 200003
            shift = 17
            mask = 131071
        } else {
            newLength = 1500007
            shift = 21
            mask = 2097151
        }
        if (table.isNone() || newLength > Int32(table.size)) {
            table = Array<Int32>(Int64(newLength)) { _ => 0 }
        } else {
            Arrays.fill(table, 0, newLength, 0)
        }
        length = newLength
        blockLength = newBlockLength
    }

    public func `extend`(data: Array<Int32>, minStart: Int32, prevDataLength: Int32, newDataLength: Int32): Unit {
        var start = prevDataLength - blockLength
        if (start >= minStart) {
            start++
        } else {
            start = minStart
        }
        let end = newDataLength - blockLength
        while (start <= end) {
            let hashCode = makeHashCode(data, start)
            addEntry(data, None, start, hashCode, start)
            start++
        }
    }

    public func `extend`(data: Array<Char>, minStart: Int32, prevDataLength: Int32, newDataLength: Int32): Unit {
        var start = prevDataLength - blockLength
        if (start >= minStart) {
            start++
        } else {
            start = minStart
        }
        let end = newDataLength - blockLength
        while (start <= end) {
            let hashCode = makeHashCode(data, start)
            addEntry(None, data, start, hashCode, start)
            start++
        }
    }

    public func findBlock(data: Array<Int32>, blockData: Array<Int32>, blockStart: Int32): Int32 {
        let hashCode = makeHashCode(blockData, blockStart)
        let entryIndex = findEntry(data, None, blockData, None, blockStart, hashCode)
        if (entryIndex >= 0) {
            return (table[Int64(entryIndex)] & mask) - 1
        } else {
            return -1
        }
    }

    public func findBlock(data: Array<Char>, blockData: Array<Int32>, blockStart: Int32): Int32 {
        let hashCode = makeHashCode(blockData, blockStart)
        let entryIndex = findEntry(None, data, blockData, None, blockStart, hashCode)
        if (entryIndex >= 0) {
            return (table[Int64(entryIndex)] & mask) - 1
        } else {
            return -1
        }
    }

    public func findBlock(data: Array<Char>, blockData: Array<Char>, blockStart: Int32): Int32 {
        let hashCode = makeHashCode(blockData, blockStart)
        let entryIndex = findEntry(None, data, None, blockData, blockStart, hashCode)
        if (entryIndex >= 0) {
            return (table[Int64(entryIndex)] & mask) - 1
        } else {
            return -1
        }
    }

    public func findAllSameBlock(data: Array<Int32>, blockValue: Int32): Int32 {
        let hashCode = makeHashCode(blockValue)
        let entryIndex = findEntry(data, blockValue, hashCode)
        if (entryIndex >= 0) {
            return (table[Int64(entryIndex)] & mask) - 1
        } else {
            return -1
        }
    }

    private func makeHashCode(blockData: Array<Int32>, blockStart: Int32): Int32 {
        var tempblockStart = blockStart
        let blockLimit = tempblockStart + blockLength
        var hashCode = blockData[Int64(match (0) { case _ => tempblockStart++; tempblockStart - 1 })]
        return hashCode
    }

    private func makeHashCode(blockData: Array<Char>, blockStart: Int32): Int32 {
        var tempblockStart = blockStart
        let blockLimit = tempblockStart + blockLength
        var hashCode = Int32(UInt32(blockData[Int64(match (0) { case _ => tempblockStart++; tempblockStart - 1 })]))
        return hashCode
    }

    private func makeHashCode(blockValue: Int32): Int32 {
        var hashCode = blockValue
        var i = 1
        while (i < blockLength) {
            hashCode = 37 * hashCode + blockValue
            i++
        }
        return hashCode
    }

    private func addEntry(data32: Array<Int32>, data16: Array<Char>, blockStart: Int32, hashCode: Int32, dataIndex: Int32): Unit {
        if (!(0 <= dataIndex && dataIndex < mask)) {
            throw AssertionError()
        }
        let entryIndex = findEntry(data32, data16, data32, data16, blockStart, hashCode)
        if (entryIndex < 0) {
            table[0] = (shl(hashCode, shift)) | (dataIndex + 1)
        }
    }

    private func findEntry(data32: Array<Int32>, data16: Array<Char>, blockData32: Array<Int32>, blockData16: Array<Char>, blockStart: Int32, hashCode: Int32): Int32 {
        let shiftedHashCode = shl(hashCode, shift)
        let initialEntryIndex = modulo(hashCode, length - 1) + 1
        var entryIndex = initialEntryIndex
        while (true) {
            let entry = table[Int64(entryIndex)]
            if (entry == 0) {
                return 
            }
            if ((entry & ) == shiftedHashCode) {
                let dataIndex = (entry & mask) - 1
                if (if (data32.isSome()) { MutableCodePointTrie.equalBlocks(data32, dataIndex, blockData32, blockStart, blockLength) } else { if (blockData32.isSome()) { MutableCodePointTrie.equalBlocks(data16, dataIndex, blockData32, blockStart, blockLength) } else { MutableCodePointTrie.equalBlocks(data16, dataIndex, blockData16, blockStart, blockLength) } }) {
                    return entryIndex
                }
            }
            entryIndex = nextIndex(initialEntryIndex, entryIndex)
        }
    }

    private func findEntry(data: Array<Int32>, blockValue: Int32, hashCode: Int32): Int32 {
        let shiftedHashCode = shl(hashCode, shift)
        let initialEntryIndex = modulo(hashCode, length - 1) + 1
        var entryIndex = initialEntryIndex
        while (true) {
            let entry = table[Int64(entryIndex)]
            if (entry == 0) {
                return 
            }
            if ((entry & ) == shiftedHashCode) {
                let dataIndex = (entry & mask) - 1
                if (MutableCodePointTrie.allValuesSameAs(data, dataIndex, blockLength, blockValue)) {
                    return entryIndex
                }
            }
            entryIndex = nextIndex(initialEntryIndex, entryIndex)
        }
    }

    private func nextIndex(initialEntryIndex: Int32, entryIndex: Int32): Int32 {
        return (entryIndex + initialEntryIndex) % length
    }

    private func modulo(n: Int32, m: Int32): Int32 {
        var i = n % m
        if (i < 0) {
            i += m
        }
        return i
    }

    private var table: Array<Int32>

    private var length: Int32 = 0

    private var shift: Int32 = 0

    private var mask: Int32 = 0

    private var blockLength: Int32 = 0
}
