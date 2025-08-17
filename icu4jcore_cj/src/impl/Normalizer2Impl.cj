package icu4cj.impl


public class Normalizer2Impl <: Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }


    private static let IS_ACCEPTABLE = Normalizer2Impl_IsAcceptable()

    private static let DATA_FORMAT = 1316121906

    public func load(bytes: ByteArrayStream): Normalizer2Impl {
        try {
            dataVersion = ICUBinary.readHeaderAndDataVersion(bytes, DATA_FORMAT, IS_ACCEPTABLE)
            let indexesLength = bytes.getInt() / 4
            if (indexesLength <= IX_MIN_LCCC_CP) {
                throw ICUUncheckedIOException("Normalizer2 data: not enough indexes")
            }
            let inIndexes = Array<Int32>(Int64(indexesLength)) { _ => 0 }
            inIndexes[0] = indexesLength * 4
            var i = 1
            while (i < indexesLength) {
                inIndexes[Int64(i)] = bytes.getInt()
                i++
            }
            minDecompNoCP = inIndexes[Int64(IX_MIN_DECOMP_NO_CP)]
            minCompNoMaybeCP = inIndexes[Int64(IX_MIN_COMP_NO_MAYBE_CP)]
            minLcccCP = inIndexes[Int64(IX_MIN_LCCC_CP)]
            minYesNo = inIndexes[Int64(IX_MIN_YES_NO)]
            minYesNoMappingsOnly = inIndexes[Int64(IX_MIN_YES_NO_MAPPINGS_ONLY)]
            minNoNo = inIndexes[Int64(IX_MIN_NO_NO)]
            minNoNoCompBoundaryBefore = inIndexes[Int64(IX_MIN_NO_NO_COMP_BOUNDARY_BEFORE)]
            minNoNoCompNoMaybeCC = inIndexes[Int64(IX_MIN_NO_NO_COMP_NO_MAYBE_CC)]
            minNoNoEmpty = inIndexes[Int64(IX_MIN_NO_NO_EMPTY)]
            limitNoNo = inIndexes[Int64(IX_LIMIT_NO_NO)]
            minMaybeYes = inIndexes[Int64(IX_MIN_MAYBE_YES)]
            if (!((minMaybeYes & 7) == 0)) {
                throw AssertionError()
            }
            centerNoNoDelta = (shr(minMaybeYes, DELTA_SHIFT)) - MAX_DELTA - 1
            var offset = inIndexes[Int64(IX_NORM_TRIE_OFFSET)]
            var nextOffset = inIndexes[Int64(IX_EXTRA_DATA_OFFSET)]
            let triePosition = bytes.position()
            normTrie = CodePointTrie_Fast16.fromBinary(bytes)
            let trieLength = bytes.position() - triePosition
            if (trieLength > (nextOffset - offset)) {
                throw ICUUncheckedIOException("Normalizer2 data: not enough bytes for normTrie")
            }
            ICUBinary.skipBytes(bytes, (nextOffset - offset) - trieLength)
            offset = nextOffset
            nextOffset = inIndexes[Int64(IX_SMALL_FCD_OFFSET)]
            let numChars = (nextOffset - offset) / 2
            if (numChars != 0) {
                maybeYesCompositions = ICUBinary.getString(bytes, numChars, 0)
                extraData = maybeYesCompositions[Int64(shr((MIN_NORMAL_MAYBE_YES - minMaybeYes), OFFSET_SHIFT))..]
            }
            offset = nextOffset
            smallFCD = Array<UInt8>(256) { _ => 0 }
            bytes.get(smallFCD)
            return this
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public func load(name: String): Normalizer2Impl {
        return load(ICUBinary.getRequiredData(name))
    }

    public func addLcccChars(set: UnicodeSet): Unit {
        var start = 0
        let range = CodePointMap_Range()
        while (normTrie.getRange(start, CodePointMap_RangeOption.FIXED_LEAD_SURROGATES, INERT, None, range)) {
            let end = range.getEnd()
            let norm16 = range.getValue()
            if (norm16 > MIN_NORMAL_MAYBE_YES && norm16 != JAMO_VT) {
                set.add(start, end)
            } else if (minNoNoCompNoMaybeCC <= norm16 && norm16 < limitNoNo) {
                let fcd16 = getFCD16(start)
                if (fcd16 > 255) {
                    set.add(start, end)
                }
            }
            start = end + 1
        }
    }

    public func addPropertyStarts(set: UnicodeSet): Unit {
        var start = 0
        let range = CodePointMap_Range()
        while (normTrie.getRange(start, CodePointMap_RangeOption.FIXED_LEAD_SURROGATES, INERT, None, range)) {
            let end = range.getEnd()
            let value = range.getValue()
            set.add(start)
            if (start != end && isAlgorithmicNoNo(value) && (value & DELTA_TCCC_MASK) > DELTA_TCCC_1) {
                var prevFCD16 = getFCD16(start)
                while (match (0) { case _ => start++; start } <= end) {
                    let fcd16 = getFCD16(start)
                    if (fcd16 != prevFCD16) {
                        set.add(start)
                        prevFCD16 = fcd16
                    }
                }
            }
            start = end + 1
        }
        var c = Normalizer2Impl_Hangul.HANGUL_BASE
        while (c < Normalizer2Impl_Hangul.HANGUL_LIMIT) {
            set.add(c)
            set.add(c + 1)
            c += Normalizer2Impl_Hangul.JAMO_T_COUNT
        }
        set.add(Normalizer2Impl_Hangul.HANGUL_LIMIT)
    }

    public func addCanonIterPropertyStarts(set: UnicodeSet): Unit {
        ensureCanonIterData()
        var start = 0
        let range = CodePointMap_Range()
        while (canonIterData.getRange(start, segmentStarterMapper, range)) {
            set.add(start)
            start = range.getEnd() + 1
        }
    }

    private static let segmentStarterMapper: CodePointMap_ValueFilter = Normalizer2Impl_1()

    public func ensureCanonIterData(): Normalizer2Impl {
        synchronized (GeneratedLockObject) {
            if (canonIterData.isNone()) {
                let mutableTrie = MutableCodePointTrie(0, 0)
                canonStartSets = ArrayList<UnicodeSet>()
                var start = 0
                let range = CodePointMap_Range()
                while (normTrie.getRange(start, CodePointMap_RangeOption.FIXED_LEAD_SURROGATES, INERT, None, range)) {
                    let end = range.getEnd()
                    let norm16 = range.getValue()
                    if (isInert(norm16) || (minYesNo <= norm16 && norm16 < minNoNo)) {
                        start = end + 1
                        continue
                    }
                    var c = start
                    while (c <= end) {
                        let oldValue = mutableTrie.get(c)
                        var newValue = oldValue
                        if (isMaybeOrNonZeroCC(norm16)) {
                            newValue |= CANON_NOT_SEGMENT_STARTER
                            if (norm16 < MIN_NORMAL_MAYBE_YES) {
                                newValue |= CANON_HAS_COMPOSITIONS
                            }
                        } else if (norm16 < minYesNo) {
                            newValue |= CANON_HAS_COMPOSITIONS
                        } else {
                            var c2 = c
                            var norm16_2 = norm16
                            if (isDecompNoAlgorithmic(norm16_2)) {
                                c2 = mapAlgorithmic(c2, norm16_2)
                                norm16_2 = getRawNorm16(c2)
                                if (!(!(isHangulLV(norm16_2) || isHangulLVT(norm16_2)))) {
                                    throw AssertionError()
                                }
                            }
                            if (norm16_2 > minYesNo) {
                                var mapping = shr(norm16_2, OFFSET_SHIFT)
                                let firstUnit = Int32(UInt32(Char(extraData[Int64(mapping)])))
                                let length = firstUnit & MAPPING_LENGTH_MASK
                                if ((firstUnit & MAPPING_HAS_CCC_LCCC_WORD) != 0) {
                                    if (c == c2 && (Int32(UInt32(Char(extraData[Int64(mapping - 1)]))) & 255) != 0) {
                                        newValue |= CANON_NOT_SEGMENT_STARTER
                                    }
                                }
                                if (length != 0) {
                                    mapping++
                                    let limit = mapping + length
                                    c2 = extraData.codePointAt(mapping)
                                    addToStartSet(mutableTrie, c, c2)
                                    if (norm16_2 >= minNoNo) {
                                        while ((mapping.charCount(c2)) : Nothing => Int32 --> < limit) {
                                            c2 = extraData.codePointAt(mapping)
                                            let c2Value = mutableTrie.get(c2)
                                            if ((c2Value & CANON_NOT_SEGMENT_STARTER) == 0) {
                                                mutableTrie.set(c2, c2Value | CANON_NOT_SEGMENT_STARTER)
                                            }
                                        }
                                    }
                                }
                            } else {
                                addToStartSet(mutableTrie, c, c2)
                            }
                        }
                        if (newValue != oldValue) {
                            mutableTrie.set(c, newValue)
                        }
                        c++
                    }
                    start = end + 1
                }
                canonIterData = mutableTrie.buildImmutable(CodePointTrie_Type.SMALL, CodePointTrie_ValueWidth.BITS_32)
            }
            return this
        }
    }

    public func getNorm16(c: Int32): Int32 {
        return if (Normalizer2Impl_UTF16Plus.isLeadSurrogate(c)) { INERT } else { normTrie.get(c) }
    }

    public func getRawNorm16(c: Int32): Int32 {
        return normTrie.get(c)
    }

    public func getCompQuickCheck(norm16: Int32): Int32 {
        if (norm16 < minNoNo || MIN_YES_YES_WITH_CC <= norm16) {
            return 1
        } else if (minMaybeYes <= norm16) {
            return 2
        } else {
            return 0
        }
    }

    public func isAlgorithmicNoNo(norm16: Int32): Bool {
        return limitNoNo <= norm16 && norm16 < minMaybeYes
    }

    public func isCompNo(norm16: Int32): Bool {
        return minNoNo <= norm16 && norm16 < minMaybeYes
    }

    public func isDecompYes(norm16: Int32): Bool {
        return norm16 < minYesNo || minMaybeYes <= norm16
    }

    public func getCC(norm16: Int32): Int32 {
        if (norm16 >= MIN_NORMAL_MAYBE_YES) {
            return getCCFromNormalYesOrMaybe(norm16)
        }
        if (norm16 < minNoNo || limitNoNo <= norm16) {
            return 0
        }
        return getCCFromNoNo(norm16)
    }

    public static func getCCFromNormalYesOrMaybe(norm16: Int32): Int32 {
        return (shr(norm16, OFFSET_SHIFT)) & 255
    }

    public static func getCCFromYesOrMaybe(norm16: Int32): Int32 {
        return if (norm16 >= MIN_NORMAL_MAYBE_YES) { getCCFromNormalYesOrMaybe(norm16) } else { 0 }
    }

    public func getCCFromYesOrMaybeCP(c: Int32): Int32 {
        if (c < minCompNoMaybeCP) {
            return 0
        }
        return getCCFromYesOrMaybe(getNorm16(c))
    }

    public func getFCD16(c: Int32): Int32 {
        if (c < minDecompNoCP) {
            return 0
        } else if (c <= 65535) {
            if (!singleLeadMightHaveNonZeroFCD16(c)) {
                return 0
            }
        }
        return getFCD16FromNormData(c)
    }

    public func singleLeadMightHaveNonZeroFCD16(lead: Int32): Bool {
        let bits = smallFCD[Int64(shr(lead, 8))]
        if (Int32(bits) == 0) {
            return false
        }
        return ((shr(Int32(bits), ((shr(lead, 5)) & 7))) & 1) != 0
    }

    public func getFCD16FromNormData(c: Int32): Int32 {
        var tempc = c
        var norm16 = getNorm16(tempc)
        if (norm16 >= limitNoNo) {
            if (norm16 >= MIN_NORMAL_MAYBE_YES) {
                norm16 = getCCFromNormalYesOrMaybe(norm16)
                return norm16 | (shl(norm16, 8))
            } else if (norm16 >= minMaybeYes) {
                return 0
            } else {
                let deltaTrailCC = norm16 & DELTA_TCCC_MASK
                if (deltaTrailCC <= DELTA_TCCC_1) {
                    return shr(deltaTrailCC, OFFSET_SHIFT)
                }
                tempc = mapAlgorithmic(tempc, norm16)
                norm16 = getRawNorm16(tempc)
            }
        }
        if (norm16 <= minYesNo || isHangulLVT(norm16)) {
            return 0
        }
        let mapping = shr(norm16, OFFSET_SHIFT)
        let firstUnit = Int32(UInt32(Char(extraData[Int64(mapping)])))
        var fcd16 = shr(firstUnit, 8)
        if ((firstUnit & MAPPING_HAS_CCC_LCCC_WORD) != 0) {
            fcd16 |= Int32(UInt32(Char(extraData[Int64(mapping - 1)]))) & 65280
        }
        return fcd16
    }

    public func getDecomposition(c: Int32): String {
        var tempc = c
        var norm16: Int32 = 0
        if (tempc < minDecompNoCP || isMaybeOrNonZeroCC(match (0) { case _ => norm16 = getNorm16(tempc); norm16 })) {
            return None
        }
        var decomp = -1
        if (isDecompNoAlgorithmic(norm16)) {
            decomp = match (0) { case _ => tempc = mapAlgorithmic(tempc, norm16); tempc }
            norm16 = getRawNorm16(tempc)
        }
        if (norm16 < minYesNo) {
            if (decomp < 0) {
                return None
            } else {
                return UTF16.valueOf(decomp)
            }
        } else if (isHangulLV(norm16) || isHangulLVT(norm16)) {
            let buffer = StringBuilder()
            Normalizer2Impl_Hangul.decompose(tempc, buffer as Appendable)
            return buffer.toString()
        }
        var mapping = shr(norm16, OFFSET_SHIFT)
        let length = Int32(UInt32(Char(extraData[Int64(match (0) { case _ => mapping++; mapping - 1 })]))) & MAPPING_LENGTH_MASK
        return extraData[Int64(mapping)..Int64(mapping + length)]
    }

    public func getRawDecomposition(c: Int32): String {
        let norm16: Int32
        if (c < minDecompNoCP || isDecompYes(match (0) { case _ => norm16 = getNorm16(c); norm16 })) {
            return None
        } else if (isHangulLV(norm16) || isHangulLVT(norm16)) {
            let buffer = StringBuilder()
            Normalizer2Impl_Hangul.getRawDecomposition(c, buffer as Appendable)
            return buffer.toString()
        } else if (isDecompNoAlgorithmic(norm16)) {
            return UTF16.valueOf(mapAlgorithmic(c, norm16))
        }
        var mapping = shr(norm16, OFFSET_SHIFT)
        let firstUnit = Int32(UInt32(Char(extraData[Int64(mapping)])))
        let mLength = firstUnit & MAPPING_LENGTH_MASK
        if ((firstUnit & MAPPING_HAS_RAW_MAPPING) != 0) {
            let rawMapping = mapping - ((shr(firstUnit, 7)) & 1) - 1
            let rm0 = Char(extraData[Int64(rawMapping)])
            if (Int32(UInt32(rm0)) <= MAPPING_LENGTH_MASK) {
                return extraData[Int64(rawMapping - Int32(UInt32(rm0)))..Int64(rawMapping)]
            } else {
                let buffer: StringBuilder = StringBuilder().append(rm0)
                mapping += 1 + 2
                return buffer.append(extraData, mapping, mapping + mLength - 2).toString()
            }
        } else {
            mapping += 1
            return extraData[Int64(mapping)..Int64(mapping + mLength)]
        }
    }

    public func isCanonSegmentStarter(c: Int32): Bool {
        return canonIterData.get(c) >= 0
    }

    public func getCanonStartSet(c: Int32, set: UnicodeSet): Bool {
        let canonValue = canonIterData.get(c) & 
        if (canonValue == 0) {
            return false
        }
        set.clear()
        let value = canonValue & CANON_VALUE_MASK
        if ((canonValue & CANON_HAS_SET) != 0) {
            set.addAll(canonStartSets[Int64(value)])
        } else if (value != 0) {
            set.add(value)
        }
        if ((canonValue & CANON_HAS_COMPOSITIONS) != 0) {
            let norm16 = getRawNorm16(c)
            if (norm16 == JAMO_L) {
                let syllable = Normalizer2Impl_Hangul.HANGUL_BASE + (c - Normalizer2Impl_Hangul.JAMO_L_BASE) * Normalizer2Impl_Hangul.JAMO_VT_COUNT
                set.add(syllable, syllable + Normalizer2Impl_Hangul.JAMO_VT_COUNT - 1)
            } else {
                addComposites(getCompositionsList(norm16), set)
            }
        }
        return true
    }

    public static let MIN_YES_YES_WITH_CC = 65026

    public static let JAMO_VT = 65024

    public static let MIN_NORMAL_MAYBE_YES = 64512

    public static let JAMO_L = 2

    public static let INERT = 1

    public static let HAS_COMP_BOUNDARY_AFTER = 1

    public static let OFFSET_SHIFT = 1

    public static let DELTA_TCCC_0 = 0

    public static let DELTA_TCCC_1 = 2

    public static let DELTA_TCCC_GT_1 = 4

    public static let DELTA_TCCC_MASK = 6

    public static let DELTA_SHIFT = 3

    public static let MAX_DELTA = 64

    public static let IX_NORM_TRIE_OFFSET = 0

    public static let IX_EXTRA_DATA_OFFSET = 1

    public static let IX_SMALL_FCD_OFFSET = 2

    public static let IX_RESERVED3_OFFSET = 3

    public static let IX_TOTAL_SIZE = 7

    public static let IX_MIN_DECOMP_NO_CP = 8

    public static let IX_MIN_COMP_NO_MAYBE_CP = 9

    public static let IX_MIN_YES_NO = 10

    public static let IX_MIN_NO_NO = 11

    public static let IX_LIMIT_NO_NO = 12

    public static let IX_MIN_MAYBE_YES = 13

    public static let IX_MIN_YES_NO_MAPPINGS_ONLY = 14

    public static let IX_MIN_NO_NO_COMP_BOUNDARY_BEFORE = 15

    public static let IX_MIN_NO_NO_COMP_NO_MAYBE_CC = 16

    public static let IX_MIN_NO_NO_EMPTY = 17

    public static let IX_MIN_LCCC_CP = 18

    public static let IX_COUNT = 20

    public static let MAPPING_HAS_CCC_LCCC_WORD = 128

    public static let MAPPING_HAS_RAW_MAPPING = 64

    public static let MAPPING_LENGTH_MASK = 31

    public static let COMP_1_LAST_TUPLE = 32768

    public static let COMP_1_TRIPLE = 1

    public static let COMP_1_TRAIL_LIMIT = 13312

    public static let COMP_1_TRAIL_MASK = 32766

    public static let COMP_1_TRAIL_SHIFT = 9

    public static let COMP_2_TRAIL_SHIFT = 6

    public static let COMP_2_TRAIL_MASK = 65472

    public func decompose(s: String, dest: StringBuilder): Appendable {
        decompose(s, 0, s.size, dest, s.size)
        return dest
    }

    public func decompose(s: String, src: Int32, limit: Int32, dest: StringBuilder, destLengthEstimate: Int32): Unit {
        var tempdestLengthEstimate = destLengthEstimate
        if (tempdestLengthEstimate < 0) {
            tempdestLengthEstimate = limit - src
        }
        dest.setLength(0)
        let buffer = Normalizer2Impl_ReorderingBuffer(this, dest, tempdestLengthEstimate)
        decompose(s, src, limit, buffer)
    }

    public func decompose(s: String, src: Int32, limit: Int32, buffer: Normalizer2Impl_ReorderingBuffer): Int32 {
        var tempsrc = src
        let minNoCP = minDecompNoCP
        var prevSrc: Int32 = 0
        var c = 0
        var norm16 = 0
        var prevBoundary = tempsrc
        var prevCC = 0
        while (true) {
            prevSrc = tempsrc
            while (tempsrc != limit) {
                if ((match (0) { case _ => c = Int32(UInt32(s[tempsrc])); c }) < minNoCP || isMostDecompYesAndZeroCC(match (0) { case _ => norm16 = normTrie.bmpGet(c); norm16 })) {
                    tempsrc++
                } else if (!Normalizer2Impl_UTF16Plus.isLeadSurrogate(c)) {
                    break
                } else {
                    let c2: Char
                    if ((tempsrc + 1) != limit && Character.isLowSurrogate(match (0) { case _ => c2 = s[tempsrc + 1]; c2 })) {
                        c = Character.toCodePoint(Char(c), c2)
                        norm16 = normTrie.suppGet(c)
                        if (isMostDecompYesAndZeroCC(norm16)) {
                            tempsrc += 2
                        } else {
                            break
                        }
                    } else {
                        tempsrc++
                    }
                }
            }
            if (tempsrc != prevSrc) {
                if (buffer.isSome()) {
                    buffer.flushAndAppendZeroCC(s, prevSrc, tempsrc)
                } else {
                    prevCC = 0
                    prevBoundary = tempsrc
                }
            }
            if (tempsrc == limit) {
                break
            }
            tempsrc += Character.charCount(c)
            if (buffer.isSome()) {
                decompose(c, norm16, buffer)
            } else {
                if (isDecompYes(norm16)) {
                    let cc = getCCFromYesOrMaybe(norm16)
                    if (prevCC <= cc || cc == 0) {
                        prevCC = cc
                        if (cc <= 1) {
                            prevBoundary = tempsrc
                        }
                        continue
                    }
                }
                return prevBoundary
            }
        }
        return tempsrc
    }

    public func decomposeAndAppend(s: String, doDecompose: Bool, buffer: Normalizer2Impl_ReorderingBuffer): Unit {
        let limit = s.size
        if (limit == 0) {
            return
        }
        if (doDecompose) {
            decompose(s, 0, limit, buffer)
            return
        }
        var c = Character.codePointAt(s, 0)
        var src = 0
        let firstCC: Int32
        var prevCC: Int32 = 0
        var cc: Int32 = 0
        firstCC = match (0) { case _ => prevCC = match (0) { case _ => cc = getCC(getNorm16(c)); cc }; prevCC }
        while (cc != 0) {
            prevCC = cc
            src += Character.charCount(c)
            if (src >= limit) {
                break
            }
            c = Character.codePointAt(s, src)
            cc = getCC(getNorm16(c))
        }
        buffer.append(s, 0, src, false, firstCC, prevCC)
        buffer.append(s, src, limit)
    }

    public func compose(s: String, src: Int32, limit: Int32, onlyContiguous: Bool, doCompose: Bool, buffer: Normalizer2Impl_ReorderingBuffer): Bool {
        var tempsrc = src
        var prevBoundary = tempsrc
        let minNoMaybeCP = minCompNoMaybeCP
        while (true) {
            var prevSrc: Int32 = 0
            var c = 0
            var norm16 = 0
            while (true) {
                if (tempsrc == limit) {
                    if (prevBoundary != limit && doCompose) {
                        buffer.append(s, prevBoundary, limit)
                    }
                    return true
                }
                if ((match (0) { case _ => c = Int32(UInt32(s[tempsrc])); c }) < minNoMaybeCP || isCompYesAndZeroCC(match (0) { case _ => norm16 = normTrie.bmpGet(c); norm16 })) {
                    tempsrc++
                } else {
                    prevSrc = match (0) { case _ => tempsrc++; tempsrc - 1 }
                    if (!Normalizer2Impl_UTF16Plus.isLeadSurrogate(c)) {
                        break
                    } else {
                        let c2: Char
                        if (tempsrc != limit && Character.isLowSurrogate(match (0) { case _ => c2 = s[tempsrc]; c2 })) {
                            tempsrc++
                            c = Character.toCodePoint(Char(c), c2)
                            norm16 = normTrie.suppGet(c)
                            if (!isCompYesAndZeroCC(norm16)) {
                                break
                            }
                        }
                    }
                }
            }
            if (!isMaybeOrNonZeroCC(norm16)) {
                if (!doCompose) {
                    return false
                }
                if (isDecompNoAlgorithmic(norm16)) {
                    if (norm16HasCompBoundaryAfter(norm16, onlyContiguous) || hasCompBoundaryBefore(s, tempsrc, limit)) {
                        if (prevBoundary != prevSrc) {
                            buffer.append(s, prevBoundary, prevSrc)
                        }
                        buffer.append(mapAlgorithmic(c, norm16), 0)
                        prevBoundary = tempsrc
                        continue
                    }
                } else if (norm16 < minNoNoCompBoundaryBefore) {
                    if (norm16HasCompBoundaryAfter(norm16, onlyContiguous) || hasCompBoundaryBefore(s, tempsrc, limit)) {
                        if (prevBoundary != prevSrc) {
                            buffer.append(s, prevBoundary, prevSrc)
                        }
                        var mapping = shr(norm16, OFFSET_SHIFT)
                        let length = Int32(UInt32(Char(extraData[Int64(match (0) { case _ => mapping++; mapping - 1 })]))) & MAPPING_LENGTH_MASK
                        buffer.append(extraData, mapping, mapping + length)
                        prevBoundary = tempsrc
                        continue
                    }
                } else if (norm16 >= minNoNoEmpty) {
                    if (hasCompBoundaryBefore(s, tempsrc, limit) || hasCompBoundaryAfter(s, prevBoundary, prevSrc, onlyContiguous)) {
                        if (prevBoundary != prevSrc) {
                            buffer.append(s, prevBoundary, prevSrc)
                        }
                        prevBoundary = tempsrc
                        continue
                    }
                }
            } else if (isJamoVT(norm16) && prevBoundary != prevSrc) {
                let prev = s[prevSrc - 1]
                if (c < Normalizer2Impl_Hangul.JAMO_T_BASE) {
                    let l = Char(Int32(UInt32(prev)) - Normalizer2Impl_Hangul.JAMO_L_BASE)
                    if (Int32(UInt32(l)) < Normalizer2Impl_Hangul.JAMO_L_COUNT) {
                        if (!doCompose) {
                            return false
                        }
                        var t: Int32 = 0
                        if (tempsrc != limit && 0 < (match (0) { case _ => t = (Int32(UInt32(s[tempsrc])) - Normalizer2Impl_Hangul.JAMO_T_BASE); t }) && t < Normalizer2Impl_Hangul.JAMO_T_COUNT) {
                            tempsrc++
                        } else if (hasCompBoundaryBefore(s, tempsrc, limit)) {
                            t = 0
                        } else {
                            t = -1
                        }
                        if (t >= 0) {
                            let syllable = Normalizer2Impl_Hangul.HANGUL_BASE + (Int32(UInt32(l)) * Normalizer2Impl_Hangul.JAMO_V_COUNT + (c - Normalizer2Impl_Hangul.JAMO_V_BASE)) * Normalizer2Impl_Hangul.JAMO_T_COUNT + t
                            prevSrc--
                            if (prevBoundary != prevSrc) {
                                buffer.append(s, prevBoundary, prevSrc)
                            }
                            buffer.append(Char(syllable))
                            prevBoundary = tempsrc
                            continue
                        }
                    }
                } else if (Normalizer2Impl_Hangul.isHangulLV(Int32(UInt32(prev)))) {
                    if (!doCompose) {
                        return false
                    }
                    let syllable = Int32(UInt32(prev)) + c - Normalizer2Impl_Hangul.JAMO_T_BASE
                    prevSrc--
                    if (prevBoundary != prevSrc) {
                        buffer.append(s, prevBoundary, prevSrc)
                    }
                    buffer.append(Char(syllable))
                    prevBoundary = tempsrc
                    continue
                }
            } else if (norm16 > JAMO_VT) {
                var cc = getCCFromNormalYesOrMaybe(norm16)
                if (onlyContiguous && getPreviousTrailCC(s, prevBoundary, prevSrc) > cc) {
                    if (!doCompose) {
                        return false
                    }
                } else {
                    var n16: Int32 = 0
                    while (true) {
                        if (tempsrc == limit) {
                            if (doCompose) {
                                buffer.append(s, prevBoundary, limit)
                            }
                            return true
                        }
                        let prevCC = cc
                        c = Character.codePointAt(s, tempsrc)
                        n16 = normTrie.get(c)
                        if (n16 >= MIN_YES_YES_WITH_CC) {
                            cc = getCCFromNormalYesOrMaybe(n16)
                            if (prevCC > cc) {
                                if (!doCompose) {
                                    return false
                                }
                                break
                            }
                        } else {
                            break
                        }
                        tempsrc += Character.charCount(c)
                    }
                    if (norm16HasCompBoundaryBefore(n16)) {
                        if (isCompYesAndZeroCC(n16)) {
                            tempsrc += Character.charCount(c)
                        }
                        continue
                    }
                }
            }
            if (prevBoundary != prevSrc && !norm16HasCompBoundaryBefore(norm16)) {
                c = Character.codePointBefore(s, prevSrc)
                norm16 = normTrie.get(c)
                if (!norm16HasCompBoundaryAfter(norm16, onlyContiguous)) {
                    prevSrc -= Character.charCount(c)
                }
            }
            if (doCompose && prevBoundary != prevSrc) {
                buffer.append(s, prevBoundary, prevSrc)
            }
            let recomposeStartIndex = buffer.size
            decomposeShort(s, prevSrc, tempsrc, false, onlyContiguous, buffer)
            tempsrc = decomposeShort(s, tempsrc, limit, true, onlyContiguous, buffer)
            recompose(buffer, recomposeStartIndex, onlyContiguous)
            if (!doCompose) {
                if (!buffer.equals(s, prevSrc, tempsrc)) {
                    return false
                }
                buffer.remove()
            }
            prevBoundary = tempsrc
        }
    }

    public func composeQuickCheck(s: String, src: Int32, limit: Int32, onlyContiguous: Bool, doSpan: Bool): Int32 {
        var tempsrc = src
        var qcResult = 0
        var prevBoundary = tempsrc
        let minNoMaybeCP = minCompNoMaybeCP
        while (true) {
            var prevSrc: Int32 = 0
            var c = 0
            var norm16 = 0
            while (true) {
                if (tempsrc == limit) {
                    return (shl(tempsrc, 1)) | qcResult
                }
                if ((match (0) { case _ => c = Int32(UInt32(s[tempsrc])); c }) < minNoMaybeCP || isCompYesAndZeroCC(match (0) { case _ => norm16 = normTrie.bmpGet(c); norm16 })) {
                    tempsrc++
                } else {
                    prevSrc = match (0) { case _ => tempsrc++; tempsrc - 1 }
                    if (!Normalizer2Impl_UTF16Plus.isLeadSurrogate(c)) {
                        break
                    } else {
                        let c2: Char
                        if (tempsrc != limit && Character.isLowSurrogate(match (0) { case _ => c2 = s[tempsrc]; c2 })) {
                            tempsrc++
                            c = Character.toCodePoint(Char(c), c2)
                            norm16 = normTrie.suppGet(c)
                            if (!isCompYesAndZeroCC(norm16)) {
                                break
                            }
                        }
                    }
                }
            }
            var prevNorm16 = INERT
            if (prevBoundary != prevSrc) {
                prevBoundary = prevSrc
                if (!norm16HasCompBoundaryBefore(norm16)) {
                    c = Character.codePointBefore(s, prevSrc)
                    let n16 = getNorm16(c)
                    if (!norm16HasCompBoundaryAfter(n16, onlyContiguous)) {
                        prevBoundary -= Character.charCount(c)
                        prevNorm16 = n16
                    }
                }
            }
            if (isMaybeOrNonZeroCC(norm16)) {
                var cc = getCCFromYesOrMaybe(norm16)
                if (onlyContiguous && cc != 0 && getTrailCCFromCompYesAndZeroCC(prevNorm16) > cc) { } else {
                    while (true) {
                        if (norm16 < MIN_YES_YES_WITH_CC) {
                            if (!doSpan) {
                                qcResult = 1
                            } else {
                                return shl(prevBoundary, 1)
                            }
                        }
                        if (tempsrc == limit) {
                            return (shl(tempsrc, 1)) | qcResult
                        }
                        let prevCC = cc
                        c = Character.codePointAt(s, tempsrc)
                        norm16 = getNorm16(c)
                        if (isMaybeOrNonZeroCC(norm16)) {
                            cc = getCCFromYesOrMaybe(norm16)
                            if (!(prevCC <= cc || cc == 0)) {
                                break
                            }
                        } else {
                            break
                        }
                        tempsrc += Character.charCount(c)
                    }
                    if (isCompYesAndZeroCC(norm16)) {
                        prevBoundary = tempsrc
                        tempsrc += Character.charCount(c)
                        continue
                    }
                }
            }
            return shl(prevBoundary, 1)
        }
    }

    public func composeAndAppend(s: String, doCompose: Bool, onlyContiguous: Bool, buffer: Normalizer2Impl_ReorderingBuffer): Unit {
        var src = 0
        let limit = s.size
        if (!buffer.isEmpty()) {
            let firstStarterInSrc = findNextCompBoundary(s, 0, limit, onlyContiguous)
            if (0 != firstStarterInSrc) {
                let lastStarterInDest = findPreviousCompBoundary(buffer.getStringBuilder().asString(), buffer.size, onlyContiguous)
                let middle = StringBuilder()
                middle.append(buffer.getStringBuilder().asString(), lastStarterInDest, buffer.size)
                buffer.removeSuffix(buffer.size - lastStarterInDest)
                middle.append(s, 0, firstStarterInSrc)
                compose(middle.toString(), 0, Int32(middle.size), onlyContiguous, true, buffer)
                src = firstStarterInSrc
            }
        }
        if (doCompose) {
            compose(s, src, limit, onlyContiguous, true, buffer)
        } else {
            buffer.append(s, src, limit)
        }
    }

    public func makeFCD(s: String, src: Int32, limit: Int32, buffer: Normalizer2Impl_ReorderingBuffer): Int32 {
        var tempsrc = src
        var prevBoundary = tempsrc
        var prevSrc: Int32 = 0
        var c = 0
        var prevFCD16 = 0
        var fcd16 = 0
        while (true) {
            prevSrc = tempsrc
            while (tempsrc != limit) {
                if ((match (0) { case _ => c = Int32(UInt32(s[tempsrc])); c }) < minLcccCP) {
                    prevFCD16 = 
                    tempsrc++
                } else if (!singleLeadMightHaveNonZeroFCD16(c)) {
                    prevFCD16 = 0
                    tempsrc++
                } else {
                    if (Normalizer2Impl_UTF16Plus.isLeadSurrogate(c)) {
                        let c2: Char
                        if ((tempsrc + 1) != limit && Character.isLowSurrogate(match (0) { case _ => c2 = s[tempsrc + 1]; c2 })) {
                            c = Character.toCodePoint(Char(c), c2)
                        }
                    }
                    if ((match (0) { case _ => fcd16 = getFCD16FromNormData(c); fcd16 }) <= 255) {
                        prevFCD16 = fcd16
                        tempsrc += Character.charCount(c)
                    } else {
                        break
                    }
                }
            }
            if (tempsrc != prevSrc) {
                if (tempsrc == limit) {
                    if (buffer.isSome()) {
                        buffer.flushAndAppendZeroCC(s, prevSrc, tempsrc)
                    }
                    break
                }
                prevBoundary = tempsrc
                if (prevFCD16 < 0) {
                    let prev = 
                    if (prev < minDecompNoCP) {
                        prevFCD16 = 0
                    } else {
                        prevFCD16 = getFCD16FromNormData(prev)
                        if (prevFCD16 > 1) {
                            prevBoundary--
                        }
                    }
                } else {
                    var p = tempsrc - 1
                    if (Character.isLowSurrogate(s[p]) && prevSrc < p && Character.isHighSurrogate(s[p - 1])) {
                        p--
                        prevFCD16 = getFCD16FromNormData(Character.toCodePoint(s[p], s[p + 1]))
                    }
                    if (prevFCD16 > 1) {
                        prevBoundary = p
                    }
                }
                if (buffer.isSome()) {
                    buffer.flushAndAppendZeroCC(s, prevSrc, prevBoundary)
                    buffer.append(s, prevBoundary, tempsrc)
                }
                prevSrc = tempsrc
            } else if (tempsrc == limit) {
                break
            }
            tempsrc += Character.charCount(c)
            if ((prevFCD16 & 255) <= (shr(fcd16, 8))) {
                if ((fcd16 & 255) <= 1) {
                    prevBoundary = tempsrc
                }
                if (buffer.isSome()) {
                    buffer.appendZeroCC(c)
                }
                prevFCD16 = fcd16
                continue
            } else if (buffer.isNone()) {
                return prevBoundary
            } else {
                buffer.removeSuffix(prevSrc - prevBoundary)
                tempsrc = findNextFCDBoundary(s, tempsrc, limit)
                decomposeShort(s, prevBoundary, tempsrc, false, false, buffer)
                prevBoundary = tempsrc
                prevFCD16 = 0
            }
        }
        return tempsrc
    }

    public func makeFCDAndAppend(s: String, doMakeFCD: Bool, buffer: Normalizer2Impl_ReorderingBuffer): Unit {
        var src = 0
        let limit = s.size
        if (!buffer.isEmpty()) {
            let firstBoundaryInSrc = findNextFCDBoundary(s, 0, limit)
            if (0 != firstBoundaryInSrc) {
                let lastBoundaryInDest = findPreviousFCDBoundary(buffer.getStringBuilder().asString(), buffer.size)
                let middle = StringBuilder()
                middle.append(buffer.getStringBuilder().asString(), lastBoundaryInDest, buffer.size)
                buffer.removeSuffix(buffer.size - lastBoundaryInDest)
                middle.append(s, 0, firstBoundaryInSrc)
                makeFCD(middle.toString(), 0, Int32(middle.size), buffer)
                src = firstBoundaryInSrc
            }
        }
        if (doMakeFCD) {
            makeFCD(s, src, limit, buffer)
        } else {
            buffer.append(s, src, limit)
        }
    }

    public func hasDecompBoundaryBefore(c: Int32): Bool {
        return c < minLcccCP || (c <= 65535 && !singleLeadMightHaveNonZeroFCD16(c)) || norm16HasDecompBoundaryBefore(getNorm16(c))
    }

    public func norm16HasDecompBoundaryBefore(norm16: Int32): Bool {
        if (norm16 < minNoNoCompNoMaybeCC) {
            return true
        }
        if (norm16 >= limitNoNo) {
            return norm16 <= MIN_NORMAL_MAYBE_YES || norm16 == JAMO_VT
        }
        let mapping = shr(norm16, OFFSET_SHIFT)
        let firstUnit = Int32(UInt32(Char(extraData[Int64(mapping)])))
        return (firstUnit & MAPPING_HAS_CCC_LCCC_WORD) == 0 || (Int32(UInt32(Char(extraData[Int64(mapping - 1)]))) & 65280) == 0
    }

    public func hasDecompBoundaryAfter(c: Int32): Bool {
        if (c < minDecompNoCP) {
            return true
        }
        if (c <= 65535 && !singleLeadMightHaveNonZeroFCD16(c)) {
            return true
        }
        return norm16HasDecompBoundaryAfter(getNorm16(c))
    }

    public func norm16HasDecompBoundaryAfter(norm16: Int32): Bool {
        if (norm16 <= minYesNo || isHangulLVT(norm16)) {
            return true
        }
        if (norm16 >= limitNoNo) {
            if (isMaybeOrNonZeroCC(norm16)) {
                return norm16 <= MIN_NORMAL_MAYBE_YES || norm16 == JAMO_VT
            }
            return (norm16 & DELTA_TCCC_MASK) <= DELTA_TCCC_1
        }
        let mapping = shr(norm16, OFFSET_SHIFT)
        let firstUnit = Int32(UInt32(Char(extraData[Int64(mapping)])))
        if (firstUnit > 511) {
            return false
        }
        if (firstUnit <= 255) {
            return true
        }
        return (firstUnit & MAPPING_HAS_CCC_LCCC_WORD) == 0 || (Int32(UInt32(Char(extraData[Int64(mapping - 1)]))) & 65280) == 0
    }

    public func isDecompInert(c: Int32): Bool {
        return isDecompYesAndZeroCC(getNorm16(c))
    }

    public func hasCompBoundaryBefore(c: Int32): Bool {
        return c < minCompNoMaybeCP || norm16HasCompBoundaryBefore(getNorm16(c))
    }

    public func hasCompBoundaryAfter(c: Int32, onlyContiguous: Bool): Bool {
        return norm16HasCompBoundaryAfter(getNorm16(c), onlyContiguous)
    }

    public func isCompInert(c: Int32, onlyContiguous: Bool): Bool {
        let norm16 = getNorm16(c)
        return isCompYesAndZeroCC(norm16) && (norm16 & HAS_COMP_BOUNDARY_AFTER) != 0 && (!onlyContiguous || isInert(norm16) || Int32(UInt32(Char(extraData[Int64(shr(norm16, OFFSET_SHIFT))]))) <= 511)
    }

    public func hasFCDBoundaryBefore(c: Int32): Bool {
        return hasDecompBoundaryBefore(c)
    }

    public func hasFCDBoundaryAfter(c: Int32): Bool {
        return hasDecompBoundaryAfter(c)
    }

    public func isFCDInert(c: Int32): Bool {
        return getFCD16(c) <= 1
    }

    private func isMaybe(norm16: Int32): Bool {
        return minMaybeYes <= norm16 && norm16 <= JAMO_VT
    }

    private func isMaybeOrNonZeroCC(norm16: Int32): Bool {
        return norm16 >= minMaybeYes
    }

    private static func isInert(norm16: Int32): Bool {
        return norm16 == INERT
    }

    private static func isJamoL(norm16: Int32): Bool {
        return norm16 == JAMO_L
    }

    private static func isJamoVT(norm16: Int32): Bool {
        return norm16 == JAMO_VT
    }

    private func hangulLVT(): Int32 {
        return minYesNoMappingsOnly | HAS_COMP_BOUNDARY_AFTER
    }

    private func isHangulLV(norm16: Int32): Bool {
        return norm16 == minYesNo
    }

    private func isHangulLVT(norm16: Int32): Bool {
        return norm16 == hangulLVT()
    }

    private func isCompYesAndZeroCC(norm16: Int32): Bool {
        return norm16 < minNoNo
    }

    private func isDecompYesAndZeroCC(norm16: Int32): Bool {
        return norm16 < minYesNo || norm16 == JAMO_VT || (minMaybeYes <= norm16 && norm16 <= MIN_NORMAL_MAYBE_YES)
    }

    private func isMostDecompYesAndZeroCC(norm16: Int32): Bool {
        return norm16 < minYesNo || norm16 == MIN_NORMAL_MAYBE_YES || norm16 == JAMO_VT
    }

    private func isDecompNoAlgorithmic(norm16: Int32): Bool {
        return norm16 >= limitNoNo
    }

    private func getCCFromNoNo(norm16: Int32): Int32 {
        let mapping = shr(norm16, OFFSET_SHIFT)
        if ((Int32(UInt32(Char(extraData[Int64(mapping)]))) & MAPPING_HAS_CCC_LCCC_WORD) != 0) {
            return Int32(UInt32(Char(extraData[Int64(mapping - 1)]))) & 255
        } else {
            return 0
        }
    }

    public func getTrailCCFromCompYesAndZeroCC(norm16: Int32): Int32 {
        if (norm16 <= minYesNo) {
            return 0
        } else {
            return shr(Int32(UInt32(Char(extraData[Int64(shr(norm16, OFFSET_SHIFT))]))), 8)
        }
    }

    private func mapAlgorithmic(c: Int32, norm16: Int32): Int32 {
        return c + (shr(norm16, DELTA_SHIFT)) - centerNoNoDelta
    }

    private func getCompositionsListForDecompYes(norm16: Int32): Int32 {
        var tempnorm16 = norm16
        if (tempnorm16 < JAMO_L || MIN_NORMAL_MAYBE_YES <= tempnorm16) {
            return -1
        } else {
            if ((tempnorm16 < 0) {
                tempnorm16 += MIN_NORMAL_MAYBE_YES
            }
            return shr(tempnorm16, OFFSET_SHIFT)
        }
    }

    private func getCompositionsListForComposite(norm16: Int32): Int32 {
        let list = shr(((MIN_NORMAL_MAYBE_YES - minMaybeYes) + norm16), OFFSET_SHIFT)
        let firstUnit = Int32(UInt32(Char(maybeYesCompositions[Int64(list)])))
        return list + 1 + (firstUnit & MAPPING_LENGTH_MASK)
    }

    private func getCompositionsListForMaybe(norm16: Int32): Int32 {
        return shr((norm16 - minMaybeYes), OFFSET_SHIFT)
    }

    private func getCompositionsList(norm16: Int32): Int32 {
        return if (isDecompYes(norm16)) { getCompositionsListForDecompYes(norm16) } else { getCompositionsListForComposite(norm16) }
    }

    private func decomposeShort(s: String, src: Int32, limit: Int32, stopAtCompBoundary: Bool, onlyContiguous: Bool, buffer: Normalizer2Impl_ReorderingBuffer): Int32 {
        var tempsrc = src
        while (tempsrc < limit) {
            let c = Character.codePointAt(s, tempsrc)
            if (stopAtCompBoundary && c < minCompNoMaybeCP) {
                return tempsrc
            }
            let norm16 = getNorm16(c)
            if (stopAtCompBoundary && norm16HasCompBoundaryBefore(norm16)) {
                return tempsrc
            }
            tempsrc += Character.charCount(c)
            decompose(c, norm16, buffer)
            if (stopAtCompBoundary && norm16HasCompBoundaryAfter(norm16, onlyContiguous)) {
                return tempsrc
            }
        }
        return tempsrc
    }

    private func decompose(c: Int32, norm16: Int32, buffer: Normalizer2Impl_ReorderingBuffer): Unit {
        var tempc = c
        var tempnorm16 = norm16
        if (tempnorm16 >= limitNoNo) {
            if (isMaybeOrNonZeroCC(tempnorm16)) {
                buffer.append(tempc, getCCFromYesOrMaybe(tempnorm16))
                return
            }
            tempc = mapAlgorithmic(tempc, tempnorm16)
            tempnorm16 = getRawNorm16(tempc)
        }
        if (tempnorm16 < minYesNo) {
            buffer.append(tempc, 0)
        } else if (isHangulLV(tempnorm16) || isHangulLVT(tempnorm16)) {
            Normalizer2Impl_Hangul.decompose(tempc, buffer)
        } else {
            var mapping = shr(tempnorm16, OFFSET_SHIFT)
            let firstUnit = Int32(UInt32(Char(extraData[Int64(mapping)])))
            let length = firstUnit & MAPPING_LENGTH_MASK
            let leadCC: Int32
            let trailCC: Int32
            trailCC = shr(firstUnit, 8)
            if ((firstUnit & MAPPING_HAS_CCC_LCCC_WORD) != 0) {
                leadCC = shr(Int32(UInt32(Char(extraData[Int64(mapping - 1)]))), 8)
            } else {
                leadCC = 0
            }
            mapping++
            buffer.append(extraData, mapping, mapping + length, true, leadCC, trailCC)
        }
    }

    private static func combine(compositions: String, list: Int32, trail: Int32): Int32 {
        var templist = list
        let key1: Int32
        var firstUnit: Int32 = 0
        if (trail < COMP_1_TRAIL_LIMIT) {
            key1 = (shl(trail, 1))
            while (key1 > (match (0) { case _ => firstUnit = Int32(UInt32(Char(compositions[Int64(templist)]))); firstUnit })) {
                templist += 2 + (firstUnit & COMP_1_TRIPLE)
            }
            if (key1 == (firstUnit & COMP_1_TRAIL_MASK)) {
                if ((firstUnit & COMP_1_TRIPLE) != 0) {
                    return (shl(Int32(UInt32(Char(compositions[Int64(templist + 1)]))), 16)) | Int32(UInt32(Char(compositions[Int64(templist + 2)])))
                } else {
                    return Int32(UInt32(Char(compositions[Int64(templist + 1)])))
                }
            }
        } else {
            key1 = COMP_1_TRAIL_LIMIT + (((shr(trail, COMP_1_TRAIL_SHIFT))) & )
            let key2 = (shl(trail, COMP_2_TRAIL_SHIFT)) & 65535
            var secondUnit: Int32 = 0
            while (true) {
                if (key1 > (match (0) { case _ => firstUnit = Int32(UInt32(Char(compositions[Int64(templist)]))); firstUnit })) {
                    templist += 2 + (firstUnit & COMP_1_TRIPLE)
                } else if (key1 == (firstUnit & COMP_1_TRAIL_MASK)) {
                    if (key2 > (match (0) { case _ => secondUnit = Int32(UInt32(Char(compositions[Int64(templist + 1)]))); secondUnit })) {
                        if ((firstUnit & COMP_1_LAST_TUPLE) != 0) {
                            break
                        } else {
                            templist += 3
                        }
                    } else if (key2 == (secondUnit & COMP_2_TRAIL_MASK)) {
                        return (shl((secondUnit & ), 16)) | Int32(UInt32(Char(compositions[Int64(templist + 2)])))
                    } else {
                        break
                    }
                } else {
                    break
                }
            }
        }
        return -1
    }

    private func addComposites(list: Int32, set: UnicodeSet): Unit {
        var templist = list
        var firstUnit: Int32 = 0
        var compositeAndFwd: Int32 = 0
                compositeAndFwd = (shl((Int32(UInt32(Char(maybeYesCompositions[Int64(templist + 1)]))) & ), 16)) | Int32(UInt32(Char(maybeYesCompositions[Int64(templist + 2)])))
                templist += 3
            }
            let composite = shr(compositeAndFwd, 1)
            if ((compositeAndFwd & 1) != 0) {
                addComposites(getCompositionsListForComposite(getRawNorm16(composite)), set)
            }
            set.add(composite)
        } while ((firstUnit & COMP_1_LAST_TUPLE) == 0)
    }

    private func recompose(buffer: Normalizer2Impl_ReorderingBuffer, recomposeStartIndex: Int32, onlyContiguous: Bool): Unit {
        let sb = buffer.getStringBuilder()
        var p = recomposeStartIndex
        if (p == Int32(sb.size)) {
            return
        }
        var starter: Int32 = 0
        var pRemove: Int32 = 0
        var compositionsList: Int32 = 0
        var c: Int32 = 0
        var compositeAndFwd: Int32 = 0
        var norm16: Int32 = 0
        var cc: Int32 = 0
        var prevCC: Int32 = 0
        var starterIsSupplementary: Bool = false
        compositionsList = -1
        starter = -1
        starterIsSupplementary = false
        prevCC = 0
        while (true) {
            c = sb.codePointAt(p)
            p += Character.charCount(c)
            norm16 = getNorm16(c)
            cc = getCCFromYesOrMaybe(norm16)
            if (isMaybe(norm16) && compositionsList >= 0 && (prevCC < cc || prevCC == 0)) {
                if (isJamoVT(norm16)) {
                    if (c < Normalizer2Impl_Hangul.JAMO_T_BASE) {
                        let prev = Char(Int32(UInt32(sb.get(Int64(starter)))) - Normalizer2Impl_Hangul.JAMO_L_BASE)
                        if (Int32(UInt32(prev)) < Normalizer2Impl_Hangul.JAMO_L_COUNT) {
                            pRemove = p - 1
                            var syllable = Char(Normalizer2Impl_Hangul.HANGUL_BASE + (Int32(UInt32(prev)) * Normalizer2Impl_Hangul.JAMO_V_COUNT + (c - Normalizer2Impl_Hangul.JAMO_V_BASE)) * Normalizer2Impl_Hangul.JAMO_T_COUNT)
                            let t: Char
                            if (p != Int32(sb.size) && (Int32(UInt32(match (0) { case _ => t = Char(Int32(UInt32(sb.get(Int64(p)))) - Normalizer2Impl_Hangul.JAMO_T_BASE); t }))) < Normalizer2Impl_Hangul.JAMO_T_COUNT) {
                                p++
                                syllable += t
                            }
                            sb.insert(Int64(starter), syllable)
                            sb.delete(pRemove, p)
                            p = pRemove
                        }
                    }
                    if (p == Int32(sb.size)) {
                        break
                    }
                    compositionsList = -1
                    continue
                } else if ((match (0) { case _ => compositeAndFwd = combine(maybeYesCompositions, compositionsList, c); compositeAndFwd }) >= 0) {
                    let composite = shr(compositeAndFwd, 1)
                    pRemove = p - Character.charCount(c)
                    sb.delete(pRemove, p)
                    p = pRemove
                    if (starterIsSupplementary) {
                        if (composite > 65535) {
                            sb.insert(Int64(starter), UTF16.getLeadSurrogate(composite))
                            sb.insert(Int64(starter + 1), UTF16.getTrailSurrogate(composite))
                        } else {
                            sb.insert(Int64(starter), Char(c))
                            sb.deleteCharAt(Int64(starter + 1))
                            starterIsSupplementary = false
                            p--
                        }
                    } else if (composite > 65535) {
                        starterIsSupplementary = true
                        sb.insert(Int64(starter), UTF16.getLeadSurrogate(composite))
                        sb.insert(Int64(starter + 1), UTF16.getTrailSurrogate(composite))
                        p++
                    } else {
                        sb.insert(Int64(starter), Char(composite))
                    }
                    if (p == Int32(sb.size)) {
                        break
                    }
                    if ((compositeAndFwd & 1) != 0) {
                        compositionsList = getCompositionsListForComposite(getRawNorm16(composite))
                    } else {
                        compositionsList = -1
                    }
                    continue
                }
            }
            prevCC = cc
            if (p == Int32(sb.size)) {
                break
            }
            if (cc == 0) {
                if ((match (0) { case _ => compositionsList = getCompositionsListForDecompYes(norm16); compositionsList }) >= 0) {
                    if (c <= 65535) {
                        starterIsSupplementary = false
                        starter = p - 1
                    } else {
                        starterIsSupplementary = true
                        starter = p - 2
                    }
                }
            } else if (onlyContiguous) {
                compositionsList = -1
            }
        }
        buffer.flush()
    }

    public func composePair(a: Int32, b: Int32): Int32 {
        var tempb = b
        let norm16 = getNorm16(a)
        var list: Int32 = 0
        if (isInert(norm16)) {
            return -1
        } else if (norm16 < minYesNoMappingsOnly) {
            if (isJamoL(norm16)) {
                tempb -= Normalizer2Impl_Hangul.JAMO_V_BASE
                if (0 <= tempb && tempb < Normalizer2Impl_Hangul.JAMO_V_COUNT) {
                    return (Normalizer2Impl_Hangul.HANGUL_BASE + ((a - Normalizer2Impl_Hangul.JAMO_L_BASE) * Normalizer2Impl_Hangul.JAMO_V_COUNT + tempb) * Normalizer2Impl_Hangul.JAMO_T_COUNT)
                } else {
                    return -1
                }
            } else if (isHangulLV(norm16)) {
                tempb -= Normalizer2Impl_Hangul.JAMO_T_BASE
                if (0 < tempb && tempb < Normalizer2Impl_Hangul.JAMO_T_COUNT) {
                    return a + tempb
                } else {
                    return -1
                }
            } else {
                list = shr(((MIN_NORMAL_MAYBE_YES - minMaybeYes) + norm16), OFFSET_SHIFT)
                if (norm16 > minYesNo) {
                    list += 1 + (Int32(UInt32(Char(maybeYesCompositions[Int64(list)]))) & MAPPING_LENGTH_MASK)
                }
            }
        } else if (norm16 < minMaybeYes || MIN_NORMAL_MAYBE_YES <= norm16) {
            return -1
        } else {
            list = getCompositionsListForMaybe(norm16)
        }
        if (tempb < 0 || 1114111 < tempb) {
            return -1
        }
        return shr(combine(maybeYesCompositions, list, tempb), 1)
    }

    private func hasCompBoundaryBefore(c: Int32, norm16: Int32): Bool {
        return c < minCompNoMaybeCP || norm16HasCompBoundaryBefore(norm16)
    }

    private func norm16HasCompBoundaryBefore(norm16: Int32): Bool {
        return norm16 < minNoNoCompNoMaybeCC || isAlgorithmicNoNo(norm16)
    }

    private func hasCompBoundaryBefore(s: String, src: Int32, limit: Int32): Bool {
        return src == limit || hasCompBoundaryBefore(Character.codePointAt(s, src))
    }

    private func norm16HasCompBoundaryAfter(norm16: Int32, onlyContiguous: Bool): Bool {
        return (norm16 & HAS_COMP_BOUNDARY_AFTER) != 0 && (!onlyContiguous || isTrailCC01ForCompBoundaryAfter(norm16))
    }

    private func hasCompBoundaryAfter(s: String, start: Int32, p: Int32, onlyContiguous: Bool): Bool {
        return start == p || hasCompBoundaryAfter(Character.codePointBefore(s, p), onlyContiguous)
    }

    private func isTrailCC01ForCompBoundaryAfter(norm16: Int32): Bool {
        return isInert(norm16) || (if (isDecompNoAlgorithmic(norm16)) { (norm16 & DELTA_TCCC_MASK) <= DELTA_TCCC_1 } else { Int32(UInt32(Char(extraData[Int64(shr(norm16, OFFSET_SHIFT))]))) <= 511 })
    }

    private func findPreviousCompBoundary(s: String, p: Int32, onlyContiguous: Bool): Int32 {
        var tempp = p
        while (tempp > 0) {
            let c = Character.codePointBefore(s, tempp)
            let norm16 = getNorm16(c)
            if (norm16HasCompBoundaryAfter(norm16, onlyContiguous)) {
                break
            }
            tempp -= Character.charCount(c)
            if (hasCompBoundaryBefore(c, norm16)) {
                break
            }
        }
        return tempp
    }

    private func findNextCompBoundary(s: String, p: Int32, limit: Int32, onlyContiguous: Bool): Int32 {
        var tempp = p
        while (tempp < limit) {
            let c = Character.codePointAt(s, tempp)
            let norm16 = normTrie.get(c)
            if (hasCompBoundaryBefore(c, norm16)) {
                break
            }
            tempp += Character.charCount(c)
            if (norm16HasCompBoundaryAfter(norm16, onlyContiguous)) {
                break
            }
        }
        return tempp
    }

    private func findPreviousFCDBoundary(s: String, p: Int32): Int32 {
        var tempp = p
        while (tempp > 0) {
            let c = Character.codePointBefore(s, tempp)
            let norm16: Int32
            if (c < minDecompNoCP || norm16HasDecompBoundaryAfter(match (0) { case _ => norm16 = getNorm16(c); norm16 })) {
                break
            }
            tempp -= Character.charCount(c)
            if (norm16HasDecompBoundaryBefore(norm16)) {
                break
            }
        }
        return tempp
    }

    private func findNextFCDBoundary(s: String, p: Int32, limit: Int32): Int32 {
        var tempp = p
        while (tempp < limit) {
            let c = Character.codePointAt(s, tempp)
            let norm16: Int32
            if (c < minLcccCP || norm16HasDecompBoundaryBefore(match (0) { case _ => norm16 = getNorm16(c); norm16 })) {
                break
            }
            tempp += Character.charCount(c)
            if (norm16HasDecompBoundaryAfter(norm16)) {
                break
            }
        }
        return tempp
    }

    private func getPreviousTrailCC(s: String, start: Int32, p: Int32): Int32 {
        if (start == p) {
            return 0
        }
        return getFCD16(Character.codePointBefore(s, p))
    }

    private func addToStartSet(mutableTrie: MutableCodePointTrie, origin: Int32, decompLead: Int32): Unit {
        var canonValue = mutableTrie.get(decompLead)
        if ((canonValue & (CANON_HAS_SET | CANON_VALUE_MASK)) == 0 && origin != 0) {
            mutableTrie.set(decompLead, canonValue | origin)
        } else {
            let set: UnicodeSet
            if ((canonValue & CANON_HAS_SET) == 0) {
                let firstOrigin = canonValue & CANON_VALUE_MASK
                canonValue = (canonValue & ) | CANON_HAS_SET | Int32(canonStartSets.size)
                mutableTrie.set(decompLead, canonValue)
                canonStartSets.append(match (0) { case _ => set = UnicodeSet(); set })
                if (firstOrigin != 0) {
                    set.add(firstOrigin)
                }
            } else {
                set = canonStartSets[Int64(canonValue & CANON_VALUE_MASK)]
            }
            set.add(origin)
        }
    }

    private var dataVersion: VersionInfo

    private var minDecompNoCP: Int32 = 0

    private var minCompNoMaybeCP: Int32 = 0

    private var minLcccCP: Int32 = 0

    private var minYesNo: Int32 = 0

    private var minYesNoMappingsOnly: Int32 = 0

    private var minNoNo: Int32 = 0

    private var minNoNoCompBoundaryBefore: Int32 = 0

    private var minNoNoCompNoMaybeCC: Int32 = 0

    private var minNoNoEmpty: Int32 = 0

    private var limitNoNo: Int32 = 0

    private var centerNoNoDelta: Int32 = 0

    private var minMaybeYes: Int32 = 0

    private var normTrie: CodePointTrie_Fast16

    private var maybeYesCompositions: String

    private var extraData: String

    private var smallFCD: Array<UInt8>

    private var canonIterData: CodePointTrie

    private var canonStartSets: ArrayList<UnicodeSet>

    static let CANON_NOT_SEGMENT_STARTER = -2147483648

    private static let CANON_HAS_COMPOSITIONS = 1073741824

    private static let CANON_HAS_SET = 2097152

    private static let CANON_VALUE_MASK = 2097151
}


public class Normalizer2Impl_Hangul {

    public static let JAMO_L_BASE = 4352

    public static let JAMO_L_END = 4370

    public static let JAMO_V_BASE = 4449

    public static let JAMO_V_END = 4469

    public static let JAMO_T_BASE = 4519

    public static let JAMO_T_END = 4546

    public static let HANGUL_BASE = 44032

    public static let HANGUL_END = 55203

    public static let JAMO_L_COUNT = 19

    public static let JAMO_V_COUNT = 21

    public static let JAMO_T_COUNT = 28

    public static let JAMO_L_LIMIT = JAMO_L_BASE + JAMO_L_COUNT

    public static let JAMO_V_LIMIT = JAMO_V_BASE + JAMO_V_COUNT

    public static let JAMO_VT_COUNT = JAMO_V_COUNT * JAMO_T_COUNT

    public static let HANGUL_COUNT = JAMO_L_COUNT * JAMO_V_COUNT * JAMO_T_COUNT

    public static let HANGUL_LIMIT = HANGUL_BASE + HANGUL_COUNT

    public static func isHangul(c: Int32): Bool {
        return HANGUL_BASE <= c && c < HANGUL_LIMIT
    }

    public static func isHangulLV(c: Int32): Bool {
        var tempc = c
        tempc -= HANGUL_BASE
        return 0 <= tempc && tempc < HANGUL_COUNT && tempc % JAMO_T_COUNT == 0
    }

    public static func isJamoL(c: Int32): Bool {
        return JAMO_L_BASE <= c && c < JAMO_L_LIMIT
    }

    public static func isJamoV(c: Int32): Bool {
        return JAMO_V_BASE <= c && c < JAMO_V_LIMIT
    }

    public static func isJamoT(c: Int32): Bool {
        let t = c - JAMO_T_BASE
        return 0 < t && t < JAMO_T_COUNT
    }

    public static func isJamo(c: Int32): Bool {
        return JAMO_L_BASE <= c && c <= JAMO_T_END && (c <= JAMO_L_END || (JAMO_V_BASE <= c && c <= JAMO_V_END) || JAMO_T_BASE < c)
    }

    public static func decompose(c: Int32, buffer: Appendable): Int32 {
        var tempc = c
        try {
            tempc -= HANGUL_BASE
            let c2 = tempc % JAMO_T_COUNT
            tempc /= JAMO_T_COUNT
            buffer.append(Char(JAMO_L_BASE + tempc / JAMO_V_COUNT))
            buffer.append(Char(JAMO_V_BASE + tempc % JAMO_V_COUNT))
            if (c2 == 0) {
                return 2
            } else {
                buffer.append(Char(JAMO_T_BASE + c2))
                return 3
            }
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public static func getRawDecomposition(c: Int32, buffer: Appendable): Unit {
        var tempc = c
        try {
            let orig = tempc
            tempc -= HANGUL_BASE
            let c2 = tempc % JAMO_T_COUNT
            if (c2 == 0) {
                tempc /= JAMO_T_COUNT
                buffer.append(Char(JAMO_L_BASE + tempc / JAMO_V_COUNT))
                buffer.append(Char(JAMO_V_BASE + tempc % JAMO_V_COUNT))
            } else {
                buffer.append(Char(orig - c2))
                buffer.append(Char(JAMO_T_BASE + c2))
            }
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }
}


public class Normalizer2Impl_ReorderingBuffer <: Appendable {
    public init(ni: Normalizer2Impl, dest: Appendable, destCapacity: Int32) {
        impl = ni
        app = dest
        if (checkOptionalIs<StringBuilder, Appendable>(app)) {
            appIsStringBuilder = true
            str = dest
            str.ensureCapacity(destCapacity)
            reorderStart = 0
            if (Int32(str.size) == 0) {
                lastCC = 0
            } else {
                setIterator()
                lastCC = previousCC()
                if (lastCC > 1) {
                    while (previousCC() > 1) { }
                }
                reorderStart = codePointLimit
            }
        } else {
            appIsStringBuilder = false
            str = StringBuilder()
            reorderStart = 0
            lastCC = 0
        }
    }

    public func isEmpty(): Bool {
        return Int32(str.size) == 0
    }

    public func length(): Int32 {
        return Int32(str.size)
    }

    public func getLastCC(): Int32 {
        return lastCC
    }

    public func getStringBuilder(): StringBuilder {
        return str
    }

    public func equals(s: String, start: Int32, limit: Int32): Bool {
        return Normalizer2Impl_UTF16Plus.equal(str.asString(), 0, Int32(str.size), s, start, limit)
    }

    public func append(c: Int32, cc: Int32): Unit {
        if (lastCC <= cc || cc == 0) {
            str.appendCodePoint(c)
            lastCC = cc
            if (cc <= 1) {
                reorderStart = Int32(str.size)
            }
        } else {
            insert(c, cc)
        }
    }

    public func append(s: String, start: Int32, limit: Int32, isNFD: Bool, leadCC: Int32, trailCC: Int32): Unit {
        var tempstart = start
        var templeadCC = leadCC
        if (tempstart == limit) {
            return
        }
        if (lastCC <= templeadCC || templeadCC == 0) {
            if (trailCC <= 1) {
                reorderStart = Int32(str.size) + (limit - tempstart)
            } else if (templeadCC <= 1) {
                reorderStart = Int32(str.size) + 1
            }
            str.append(s, tempstart, limit)
            lastCC = trailCC
        } else {
            var c = Character.codePointAt(s, tempstart)
            tempstart += Character.charCount(c)
            insert(c, templeadCC)
            while (tempstart < limit) {
                c = Character.codePointAt(s, tempstart)
                tempstart += Character.charCount(c)
                if (tempstart < limit) {
                    if (isNFD) {
                        templeadCC = Normalizer2Impl.getCCFromYesOrMaybe(impl.getNorm16(c))
                    } else {
                        templeadCC = impl.getCC(impl.getNorm16(c))
                    }
                } else {
                    templeadCC = trailCC
                }
                append(c, templeadCC)
            }
        }
    }

    public override func append(c: Char): Normalizer2Impl_ReorderingBuffer {
        str.append(c)
        lastCC = 0
        reorderStart = Int32(str.size)
        return this
    }

    public func appendZeroCC(c: Int32): Unit {
        str.appendCodePoint(c)
        lastCC = 0
        reorderStart = Int32(str.size)
    }

    public override func append(s: String): Normalizer2Impl_ReorderingBuffer {
        if (s.size != 0) {
            str.append(s)
            lastCC = 0
            reorderStart = Int32(str.size)
        }
        return this
    }

    public override func append(s: String, start: Int32, limit: Int32): Normalizer2Impl_ReorderingBuffer {
        if (start != limit) {
            str.append(s, start, limit)
            lastCC = 0
            reorderStart = Int32(str.size)
        }
        return this
    }

    public func flush(): Unit {
        if (appIsStringBuilder) {
            reorderStart = Int32(str.size)
        } else {
            try {
                app.append(str.asString())
                str.setLength(0)
                reorderStart = 0
            } catch (e: IOException) {
                throw ICUUncheckedIOException(e)
            }
        }
        lastCC = 0
    }

    public func flushAndAppendZeroCC(s: String, start: Int32, limit: Int32): Normalizer2Impl_ReorderingBuffer {
        if (appIsStringBuilder) {
            str.append(s, start, limit)
            reorderStart = Int32(str.size)
        } else {
            try {
                app.append(str.asString()).append(s, start, limit)
                str.setLength(0)
                reorderStart = 0
            } catch (e: IOException) {
                throw ICUUncheckedIOException(e)
            }
        }
        lastCC = 0
        return this
    }

    public func remove(): Unit {
        str.setLength(0)
        lastCC = 0
        reorderStart = 0
    }

    public func removeSuffix(suffixLength: Int32): Unit {
        let oldLength = Int32(str.size)
        str.delete(oldLength - suffixLength, oldLength)
        lastCC = 0
        reorderStart = Int32(str.size)
    }

    private func insert(c: Int32, cc: Int32): Unit {
        setIterator()
        skipPrevious()
        while (previousCC() > cc) { }
        if (c <= 65535) {
            str.insert(Int64(codePointLimit), Char(c))
            if (cc <= 1) {
                reorderStart = codePointLimit + 1
            }
        } else {
            str.insert(Int64(codePointLimit), Character.toChars(c).asString())
            if (cc <= 1) {
                reorderStart = codePointLimit + 2
            }
        }
    }

    private let impl: Normalizer2Impl

    private let app: Appendable

    private let str: StringBuilder

    private let appIsStringBuilder: Bool

    private var reorderStart: Int32 = 0

    private var lastCC: Int32 = 0

    private func setIterator(): Unit {
        codePointStart = Int32(str.size)
    }

    private func skipPrevious(): Unit {
        codePointLimit = codePointStart
        codePointStart = str.offsetByCodePoints(codePointStart, -1)
    }

    private func previousCC(): Int32 {
        codePointLimit = codePointStart
        if (reorderStart >= codePointStart) {
            return 0
        }
        let c = str.codePointBefore(codePointStart)
        codePointStart -= Character.charCount(c)
        return impl.getCCFromYesOrMaybeCP(c)
    }

    private var codePointStart: Int32 = 0

    private var codePointLimit: Int32 = 0
}


public class Normalizer2Impl_UTF16Plus {

    public static func isLeadSurrogate(c: Int32): Bool {
        return (c & -1024) == 55296
    }

    public static func isTrailSurrogate(c: Int32): Bool {
        return (c & -1024) == 56320
    }

    public static func isSurrogate(c: Int32): Bool {
        return (c & -2048) == 55296
    }

    public static func isSurrogateLead(c: Int32): Bool {
        return (c & 1024) == 0
    }

    public static func equal(s1: String, s2: String): Bool {
        if (refEq(s1, s2)) {
            return true
        }
        let length = s1.size
        if (length != s2.size) {
            return false
        }
        var i = 0
        while (i < length) {
            if (s1[i] != s2[i]) {
                return false
            }
            i++
        }
        return true
    }

    public static func equal(s1: String, start1: Int32, limit1: Int32, s2: String, start2: Int32, limit2: Int32): Bool {
        var tempstart1 = start1
        var tempstart2 = start2
        if ((limit1 - tempstart1) != (limit2 - tempstart2)) {
            return false
        }
        if (refEq(s1, s2) && tempstart1 == tempstart2) {
            return true
        }
        while (tempstart1 < limit1) {
            if (s1[match (0] { case _ => tempstart1++; tempstart1 - 1 }) != s2[match (0] { case _ => tempstart2++; tempstart2 - 1 })) {
                return false
            }
        }
        return true
    }
}


class Normalizer2Impl_IsAcceptable <: ICUBinary_Authenticate {

    public override func isDataVersionAcceptable(version: Array<UInt8>): Bool {
        return Int32(version[0]) == 4
    }
}


class Normalizer2Impl_1 <: CodePointMap_ValueFilter {

    public override func apply(value: Int32): Int32 {
        return value & Normalizer2Impl.CANON_NOT_SEGMENT_STARTER
    }
}
