package icu4cj.impl

public class UCaseProps {
    private init() {
        let bytes = ICUBinary.getRequiredData(DATA_FILE_NAME)
        readData(bytes)
    }

    private func readData(bytes: ByteArrayStream): Unit {
        ICUBinary.readHeader(bytes, FMT, UCaseProps_IsAcceptable())
        var count = bytes.getInt()
        if (count < IX_TOP) {
            throw IOException("indexes[0] too small in " + (DATA_FILE_NAME))
        }
        indexes = Array<Int32>(Int64(count)) { _ => 0 }
        indexes[0] = count
        var i = 1
        while (i < count) {
            indexes[Int64(i)] = bytes.getInt()
            i++
        }
        trie = Trie2_16.createFromSerialized(bytes)
        let expectedTrieLength = indexes[Int64(IX_TRIE_SIZE)]
        let trieLength = trie.getSerializedLength()
        if (trieLength > expectedTrieLength) {
            throw IOException((DATA_FILE_NAME) + ": not enough bytes for the trie")
        }
        ICUBinary.skipBytes(bytes, expectedTrieLength - trieLength)
        count = indexes[Int64(IX_EXC_LENGTH)]
        if (count > 0) {
            exceptions = ICUBinary.getString(bytes, count, 0)
        }
        count = indexes[Int64(IX_UNFOLD_LENGTH)]
        if (count > 0) {
            unfold = ICUBinary.getChars(bytes, count, 0)
        }
    }

    public func addPropertyStarts(set: UnicodeSet): Unit {
        let trieIterator = trie.iterator()
        var range: Trie2_Range
        while (trieIterator.hasNext() && !(match (0) { case _ => range = trieIterator.next(); range }).leadSurrogate) {
            set.add(range.startCodePoint)
        }
    }

    private static func getExceptionsOffset(props: Int32): Int32 {
        return shr(props, EXC_SHIFT)
    }

    static func propsHasException(props: Int32): Bool {
        return (props & EXCEPTION) != 0
    }

    private static let flagsOffset: Array<UInt8> = [0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8]

    private static func hasSlot(flags: Int32, index: Int32): Bool {
        return (flags & (shl(1, index))) != 0
    }

    private static func slotOffset(flags: Int32, index: Int32): UInt8 {
        return flagsOffset[Int64(flags & ((shl(1, index)) - 1))]
    }

    private func getSlotValueAndOffset(excWord: Int32, index: Int32, excOffset: Int32): Int64 {
        var tempexcOffset = excOffset
        var value: Int64 = 0
        if ((excWord & EXC_DOUBLE_SLOTS) == 0) {
            tempexcOffset += Int32(slotOffset(excWord, index))
            value = Int64(UInt32(Char(exceptions[Int64(tempexcOffset)])))
        } else {
            tempexcOffset += 2 * Int32(slotOffset(excWord, index))
            value = Int64(UInt32(Char(exceptions[Int64(match (0) { case _ => tempexcOffset++; tempexcOffset - 1 })])))
            value = (shl(value, 16)) | Int64(UInt32(Char(exceptions[Int64(tempexcOffset)])))
        }
        return value | (shl(Int64(tempexcOffset), 32))
    }

    private func getSlotValue(excWord: Int32, index: Int32, excOffset: Int32): Int32 {
        var tempexcOffset = excOffset
        var value: Int32 = 0
        if ((excWord & EXC_DOUBLE_SLOTS) == 0) {
            tempexcOffset += Int32(slotOffset(excWord, index))
            value = Int32(UInt32(Char(exceptions[Int64(tempexcOffset)])))
        } else {
            tempexcOffset += 2 * Int32(slotOffset(excWord, index))
            value = Int32(UInt32(Char(exceptions[Int64(match (0) { case _ => tempexcOffset++; tempexcOffset - 1 })])))
            value = (shl(value, 16)) | Int32(UInt32(Char(exceptions[Int64(tempexcOffset)])))
        }
        return value
    }

    public func tolower(c: Int32): Int32 {
        var tempc = c
        let props = trie.get(tempc)
        if (!propsHasException(props)) {
            if (isUpperOrTitleFromProps(props)) {
                tempc += getDelta(props)
            }
        } else {
            var excOffset = getExceptionsOffset(props)
            let excWord = Int32(UInt32(Char(exceptions[Int64(match (0) { case _ => excOffset++; excOffset - 1 })])))
            if (hasSlot(excWord, EXC_DELTA) && isUpperOrTitleFromProps(props)) {
                let delta = getSlotValue(excWord, EXC_DELTA, excOffset)
                return if ((excWord & EXC_DELTA_IS_NEGATIVE) == 0) { tempc + delta } else { tempc - delta }
            }
            if (hasSlot(excWord, EXC_LOWER)) {
                tempc = getSlotValue(excWord, EXC_LOWER, excOffset)
            }
        }
        return tempc
    }

    public func toupper(c: Int32): Int32 {
        var tempc = c
        let props = trie.get(tempc)
        if (!propsHasException(props)) {
            if (getTypeFromProps(props) == LOWER) {
                tempc += getDelta(props)
            }
        } else {
            var excOffset = getExceptionsOffset(props)
            let excWord = Int32(UInt32(Char(exceptions[Int64(match (0) { case _ => excOffset++; excOffset - 1 })])))
            if (hasSlot(excWord, EXC_DELTA) && getTypeFromProps(props) == LOWER) {
                let delta = getSlotValue(excWord, EXC_DELTA, excOffset)
                return if ((excWord & EXC_DELTA_IS_NEGATIVE) == 0) { tempc + delta } else { tempc - delta }
            }
            if (hasSlot(excWord, EXC_UPPER)) {
                tempc = getSlotValue(excWord, EXC_UPPER, excOffset)
            }
        }
        return tempc
    }

    public func totitle(c: Int32): Int32 {
        var tempc = c
        let props = trie.get(tempc)
        if (!propsHasException(props)) {
            if (getTypeFromProps(props) == LOWER) {
                tempc += getDelta(props)
            }
        } else {
            var excOffset = getExceptionsOffset(props)
            let excWord = Int32(UInt32(Char(exceptions[Int64(match (0) { case _ => excOffset++; excOffset - 1 })])))
            if (hasSlot(excWord, EXC_DELTA) && getTypeFromProps(props) == LOWER) {
                let delta = getSlotValue(excWord, EXC_DELTA, excOffset)
                return if ((excWord & EXC_DELTA_IS_NEGATIVE) == 0) { tempc + delta } else { tempc - delta }
            }
            let index: Int32
            if (hasSlot(excWord, EXC_TITLE)) {
                index = EXC_TITLE
            } else if (hasSlot(excWord, EXC_UPPER)) {
                index = EXC_UPPER
            } else {
                return tempc
            }
            tempc = getSlotValue(excWord, index, excOffset)
        }
        return tempc
    }

    public func addCaseClosure(c: Int32, set: UnicodeSet): Unit {
        let props = trie.get(c)
        if (!propsHasException(props)) {
            if (getTypeFromProps(props) != NONE) {
                let delta = getDelta(props)
                if (delta != 0) {
                    set.add(c + delta)
                }
            }
        } else {
            var excOffset = getExceptionsOffset(props)
            let excWord = Int32(UInt32(Char(exceptions[Int64(match (0) { case _ => excOffset++; excOffset - 1 })])))
            let excOffset0 = excOffset
            if ((excWord & EXC_CONDITIONAL_FOLD) != 0) {
                if (c == 73) {
                    set.add(105)
                    return
                } else if (c == 304) {
                    set.add(iDot)
                    return
                }
            } else if (c == 105) {
                set.add(73)
                return
            } else if (c == 305) {
                return
            }
                    index++
                }
            } while (false)
            if (hasSlot(excWord, EXC_DELTA)) {
                excOffset = excOffset0
                let delta = getSlotValue(excWord, EXC_DELTA, excOffset)
                set.add(if ((excWord & EXC_DELTA_IS_NEGATIVE) == 0) { c + delta } else { c - delta })
            }
            var closureOffset: Int32 = 0
            let closureLength: Int32
            if (hasSlot(excWord, EXC_CLOSURE)) {
                excOffset = excOffset0
                let value = getSlotValueAndOffset(excWord, EXC_CLOSURE, excOffset)
                closureLength = Int32(value) & CLOSURE_MAX_LENGTH
                closureOffset = Int32(shr(value, 32)) + 1
            } else {
                closureLength = 0
                closureOffset = 0
            }
            if (hasSlot(excWord, EXC_FULL_MAPPINGS)) {
                excOffset = excOffset0
                let value = getSlotValueAndOffset(excWord, EXC_FULL_MAPPINGS, excOffset)
                var fullLength = Int32(value)
                excOffset = Int32(shr(value, 32)) + 1
                fullLength &= 65535
                excOffset += fullLength & FULL_LOWER
                fullLength >>= 4
                let length = fullLength & 15
                if (length != 0) {
                    set.add(exceptions[Int64(excOffset)..Int64(excOffset + length)])
                    excOffset += length
                }
                fullLength >>= 4
                excOffset += fullLength & 15
                fullLength >>= 4
                excOffset += fullLength
                closureOffset = excOffset
            }
            let limit = closureOffset + closureLength
            } while (false)
        }
    }

    public func addSimpleCaseClosure(c: Int32, set: UnicodeSet): Unit {
        let props = trie.get(c)
        if (!propsHasException(props)) {
            if (getTypeFromProps(props) != NONE) {
                let delta = getDelta(props)
                if (delta != 0) {
                    set.add(c + delta)
                }
            }
        } else {
            var excOffset = getExceptionsOffset(props)
            let excWord = Int32(UInt32(Char(exceptions[Int64(match (0) { case _ => excOffset++; excOffset - 1 })])))
            let excOffset0 = excOffset
            if ((excWord & EXC_CONDITIONAL_FOLD) != 0) {
                if (c == 73) {
                    set.add(105)
                    return
                } else if (c == 304) {
                    return
                }
            } else if (c == 105) {
                set.add(73)
                return
            } else if (c == 305) {
                return
            }
                    index++
                }
            } while (false)
            if (hasSlot(excWord, EXC_DELTA)) {
                excOffset = excOffset0
                let delta = getSlotValue(excWord, EXC_DELTA, excOffset)
                let mapping = if ((excWord & EXC_DELTA_IS_NEGATIVE) == 0) { c + delta } else { c - delta }
                set.add(mapping)
            }
            var closureOffset: Int32 = 0
            let closureLength: Int32
            if (hasSlot(excWord, EXC_CLOSURE)) {
                excOffset = excOffset0
                let value = getSlotValueAndOffset(excWord, EXC_CLOSURE, excOffset)
                closureLength = Int32(value) & CLOSURE_MAX_LENGTH
                closureOffset = Int32(shr(value, 32)) + 1
            } else {
                closureLength = 0
                closureOffset = 0
            }
            if (closureLength > 0 && hasSlot(excWord, EXC_FULL_MAPPINGS)) {
                excOffset = excOffset0
                let value = getSlotValueAndOffset(excWord, EXC_FULL_MAPPINGS, excOffset)
                var fullLength = Int32(value)
                excOffset = Int32(shr(value, 32)) + 1
                fullLength &= 65535
                excOffset += fullLength & FULL_LOWER
                fullLength >>= 4
                excOffset += fullLength & 15
                fullLength >>= 4
                excOffset += fullLength & 15
                fullLength >>= 4
                excOffset += fullLength
                closureOffset = excOffset
            }
            let limit = closureOffset + closureLength
            } while (false)
        }
    }

    private func strcmpMax(s: String, unfoldOffset: Int32, max: Int32): Int32 {
        var tempmax = max
        var tempunfoldOffset = unfoldOffset
        var i1: Int32 = 0
        var length: Int32 = 0
        var c1: Int32 = 0
        var c2: Int32 = 0
        length = Int32(s.size)
        tempmax -= length
        i1 = 0
            c1 -= c2
            if (c1 != 0) {
                return c1
            }
        } while (match (0) { case _ => length--; length } > 0)
        if (tempmax == 0 || Int32(UInt32(unfold[Int64(tempunfoldOffset)])) == 0) {
            return 0
        } else {
            return -tempmax
        }
    }

    public func addStringCaseClosure(s: String, set: UnicodeSet): Bool {
        var i: Int32 = 0
        let length: Int32
        var start: Int32 = 0
        var limit: Int32 = 0
        var result: Int32 = 0
        var unfoldOffset: Int32 = 0
        let unfoldRows: Int32
        let unfoldRowWidth: Int32
        let unfoldStringWidth: Int32
        if (unfold.isNone() || s.isNone()) {
            return false
        }
        length = Int32(s.size)
        if (length <= 1) {
            return false
        }
        unfoldRows = Int32(UInt32(unfold[Int64(UNFOLD_ROWS)]))
        unfoldRowWidth = Int32(UInt32(unfold[Int64(UNFOLD_ROW_WIDTH)]))
        unfoldStringWidth = Int32(UInt32(unfold[Int64(UNFOLD_STRING_WIDTH)]))
        if (length > unfoldStringWidth) {
            return false
        }
        start = 0
        limit = unfoldRows
        while (start < limit) {
            i = (start + limit) / 2
            unfoldOffset = ((i + 1) * unfoldRowWidth)
            result = strcmpMax(s, unfoldOffset, unfoldStringWidth)
            if (result == 0) {
                var c: Int32 = 0
                i = unfoldStringWidth
                while (i < unfoldRowWidth && Int32(UInt32(unfold[Int64(unfoldOffset + i)])) != 0) {
                    c = UTF16.toRuneArray()[unfold, unfoldOffset, Int32(unfold.size), i]
                    set.add(c)
                    addCaseClosure(c, set)
                    i += UTF16.getCharCount(c)
                }
                return true
            } else if (result < 0) {
                limit = i
            } else {
                start = i + 1
            }
        }
        return false
    }

    public func getType(c: Int32): Int32 {
        return getTypeFromProps(trie.get(c))
    }

    public func getTypeOrIgnorable(c: Int32): Int32 {
        return getTypeAndIgnorableFromProps(trie.get(c))
    }

    public func getDotType(c: Int32): Int32 {
        let props = trie.get(c)
        if (!propsHasException(props)) {
            return props & DOT_MASK
        } else {
            return (shr(Int32(UInt32(Char(exceptions[Int64(getExceptionsOffset(props))]))), EXC_DOT_SHIFT)) & DOT_MASK
        }
    }

    public func isSoftDotted(c: Int32): Bool {
        return getDotType(c) == SOFT_DOTTED
    }

    public func isCaseSensitive(c: Int32): Bool {
        let props = trie.get(c)
        if (!propsHasException(props)) {
            return (props & SENSITIVE) != 0
        } else {
            return (Int32(UInt32(Char(exceptions[Int64(getExceptionsOffset(props))]))) & EXC_SENSITIVE) != 0
        }
    }

    public static let MAX_STRING_LENGTH = 31

    public static let LOC_ROOT = 1

    static let LOC_TURKISH = 2

    static let LOC_LITHUANIAN = 3

    static let LOC_GREEK = 4

    public static let LOC_DUTCH = 5

    static let LOC_ARMENIAN = 6

    public static func getCaseLocale(locale: Locale): Int32 {
        return getCaseLocale(locale.getLanguage())
    }

    public static func getCaseLocale(locale: ULocale): Int32 {
        return getCaseLocale(locale.getLanguage())
    }

    private static func getCaseLocale(language: String): Int32 {
        if (Int32(language.size) == 2) {
            if (language == "en" || Char(language[0]) > 't') {
                return LOC_ROOT
            } else if (language == "tr" || language == "az") {
                return LOC_TURKISH
            } else if (language == "el") {
                return LOC_GREEK
            } else if (language == "lt") {
                return LOC_LITHUANIAN
            } else if (language == "nl") {
                return LOC_DUTCH
            } else if (language == "hy") {
                return LOC_ARMENIAN
            }
        } else if (Int32(language.size) == 3) {
            if (language == "tur" || language == "aze") {
                return LOC_TURKISH
            } else if (language == "ell") {
                return LOC_GREEK
            } else if (language == "lit") {
                return LOC_LITHUANIAN
            } else if (language == "nld") {
                return LOC_DUTCH
            } else if (language == "hye") {
                return LOC_ARMENIAN
            }
        }
        return LOC_ROOT
    }

    private func isFollowedByCasedLetter(iter: UCaseProps_ContextIterator, dir: Int32): Bool {
        var c: Int32 = 0
        if (iter.isNone()) {
            return false
        }
        iter.reset(dir)
        while ((match (0) { case _ => c = iter.next(); c }) >= 0) {
            let Type = getTypeOrIgnorable(c)
            if ((Type & 4) != 0) { } else if (Type != NONE) {
                return true
            } else {
                return false
            }
        }
        return false
    }

    private func isPrecededBySoftDotted(iter: UCaseProps_ContextIterator): Bool {
        var c: Int32 = 0
        var dotType: Int32 = 0
        if (iter.isNone()) {
            return false
        }
        iter.reset(-1)
        while ((match (0) { case _ => c = iter.next(); c }) >= 0) {
            dotType = getDotType(c)
            if (dotType == SOFT_DOTTED) {
                return true
            } else if (dotType != OTHER_ACCENT) {
                return false
            }
        }
        return false
    }

    private func isPrecededBy_I(iter: UCaseProps_ContextIterator): Bool {
        var c: Int32 = 0
        var dotType: Int32 = 0
        if (iter.isNone()) {
            return false
        }
        iter.reset(-1)
        while ((match (0) { case _ => c = iter.next(); c }) >= 0) {
            if (c == 73) {
                return true
            }
            dotType = getDotType(c)
            if (dotType != OTHER_ACCENT) {
                return false
            }
        }
        return false
    }

    private func isFollowedByMoreAbove(iter: UCaseProps_ContextIterator): Bool {
        var c: Int32 = 0
        var dotType: Int32 = 0
        if (iter.isNone()) {
            return false
        }
        iter.reset(1)
        while ((match (0) { case _ => c = iter.next(); c }) >= 0) {
            dotType = getDotType(c)
            if (dotType == ABOVE) {
                return true
            } else if (dotType != OTHER_ACCENT) {
                return false
            }
        }
        return false
    }

    private func isFollowedByDotAbove(iter: UCaseProps_ContextIterator): Bool {
        var c: Int32 = 0
        var dotType: Int32 = 0
        if (iter.isNone()) {
            return false
        }
        iter.reset(1)
        while ((match (0) { case _ => c = iter.next(); c }) >= 0) {
            if (c == 775) {
                return true
            }
            dotType = getDotType(c)
            if (dotType != OTHER_ACCENT) {
                return false
            }
        }
        return false
    }

    private static let iDot = "i\u{0307}"

    private static let jDot = "j\u{0307}"

    private static let iOgonekDot = "\u{012f}\u{0307}"

    private static let iDotGrave = "i\u{0307}\u{0300}"

    private static let iDotAcute = "i\u{0307}\u{0301}"

    private static let iDotTilde = "i\u{0307}\u{0303}"

    public func toFullLower(c: Int32, iter: UCaseProps_ContextIterator, out: Appendable, caseLocale: Int32): Int32 {
        var result: Int32 = 0
        let props: Int32
        result = c
        props = trie.get(c)
        if (!propsHasException(props)) {
            if (isUpperOrTitleFromProps(props)) {
                result = c + getDelta(props)
            }
        } else {
            var excOffset = getExceptionsOffset(props)
            let excOffset2: Int32
            let excWord = Int32(UInt32(Char(exceptions[Int64(match (0) { case _ => excOffset++; excOffset - 1 })])))
            let full: Int32
            excOffset2 = excOffset
            if ((excWord & EXC_CONDITIONAL_SPECIAL) != 0) {
                if (caseLocale == LOC_LITHUANIAN && (((c == 73 || c == 74 || c == 302) && isFollowedByMoreAbove(iter)) || (c == 204 || c == 205 || c == 296))) {
                    try {
                        match (c) {
                            case 73 =>
                                out.append(iDot)
                                return 2
                            case 74 =>
                                out.append(jDot)
                                return 2
                            case 302 =>
                                out.append(iOgonekDot)
                                return 2
                            case 204 =>
                                out.append(iDotGrave)
                                return 3
                            case 205 =>
                                out.append(iDotAcute)
                                return 3
                            case 296 =>
                                out.append(iDotTilde)
                                return 3
                            case _ => return 0
                        }
                    } catch (e: IOException) {
                        throw ICUUncheckedIOException(e)
                    }
                } else if (caseLocale == LOC_TURKISH && c == 304) {
                    return 105
                } else if (caseLocale == LOC_TURKISH && c == 775 && isPrecededBy_I(iter)) {
                    return 0
                } else if (caseLocale == LOC_TURKISH && c == 73 && !isFollowedByDotAbove(iter)) {
                    return 305
                } else if (c == 304) {
                    try {
                        out.append(iDot)
                        return 2
                    } catch (e: IOException) {
                        throw ICUUncheckedIOException(e)
                    }
                } else if (c == 931 && !isFollowedByCasedLetter(iter, 1) && isFollowedByCasedLetter(iter, -1)) {
                    return 962
                } else { }
            } else if (hasSlot(excWord, EXC_FULL_MAPPINGS)) {
                let value = getSlotValueAndOffset(excWord, EXC_FULL_MAPPINGS, excOffset)
                full = Int32(value) & FULL_LOWER
                if (full != 0) {
                    excOffset = Int32(shr(value, 32)) + 1
                    try {
                        out.append(exceptions, excOffset, excOffset + full)
                        return full
                    } catch (e: IOException) {
                        throw ICUUncheckedIOException(e)
                    }
                }
            }
            if (hasSlot(excWord, EXC_DELTA) && isUpperOrTitleFromProps(props)) {
                let delta = getSlotValue(excWord, EXC_DELTA, excOffset2)
                return if ((excWord & EXC_DELTA_IS_NEGATIVE) == 0) { c + delta } else { c - delta }
            }
            if (hasSlot(excWord, EXC_LOWER)) {
                result = getSlotValue(excWord, EXC_LOWER, excOffset2)
            }
        }
        return if (result == c) {  } else { result }
    }

    private func toUpperOrTitle(c: Int32, iter: UCaseProps_ContextIterator, out: Appendable, loc: Int32, upperNotTitle: Bool): Int32 {
        var result: Int32 = 0
        let props: Int32
        result = c
        props = trie.get(c)
        if (!propsHasException(props)) {
            if (getTypeFromProps(props) == LOWER) {
                result = c + getDelta(props)
            }
        } else {
            var excOffset = getExceptionsOffset(props)
            let excOffset2: Int32
            let excWord = Int32(UInt32(Char(exceptions[Int64(match (0) { case _ => excOffset++; excOffset - 1 })])))
            var full: Int32 = 0
            let index: Int32
            excOffset2 = excOffset
            if ((excWord & EXC_CONDITIONAL_SPECIAL) != 0) {
                if (loc == LOC_TURKISH && c == 105) {
                    return 304
                } else if (loc == LOC_LITHUANIAN && c == 775 && isPrecededBySoftDotted(iter)) {
                    return 0
                } else if (c == 1415) {
                    try {
                        if (loc == LOC_ARMENIAN) {
                            out.append(if (upperNotTitle) { "\u{0535}\u{054e}" } else { "\u{0535}\u{057e}" })
                        } else {
                            out.append(if (upperNotTitle) { "\u{0535}\u{0552}" } else { "\u{0535}\u{0582}" })
                        }
                        return 2
                    } catch (e: IOException) {
                        throw ICUUncheckedIOException(e)
                    }
                } else { }
            } else if (hasSlot(excWord, EXC_FULL_MAPPINGS)) {
                let value = getSlotValueAndOffset(excWord, EXC_FULL_MAPPINGS, excOffset)
                full = Int32(value) & 65535
                excOffset = Int32(shr(value, 32)) + 1
                excOffset += full & FULL_LOWER
                full >>= 4
                excOffset += full & 15
                full >>= 4
                if (upperNotTitle) {
                    full &= 15
                } else {
                    excOffset += full & 15
                    full = (shr(full, 4)) & 15
                }
                if (full != 0) {
                    try {
                        out.append(exceptions, excOffset, excOffset + full)
                        return full
                    } catch (e: IOException) {
                        throw ICUUncheckedIOException(e)
                    }
                }
            }
            if (hasSlot(excWord, EXC_DELTA) && getTypeFromProps(props) == LOWER) {
                let delta = getSlotValue(excWord, EXC_DELTA, excOffset2)
                return if ((excWord & EXC_DELTA_IS_NEGATIVE) == 0) { c + delta } else { c - delta }
            }
            if (!upperNotTitle && hasSlot(excWord, EXC_TITLE)) {
                index = EXC_TITLE
            } else if (hasSlot(excWord, EXC_UPPER)) {
                index = EXC_UPPER
            } else {
                return 
            }
            result = getSlotValue(excWord, index, excOffset2)
        }
        return if (result == c) {  } else { result }
    }

    public func toFullUpper(c: Int32, iter: UCaseProps_ContextIterator, out: Appendable, caseLocale: Int32): Int32 {
        return toUpperOrTitle(c, iter, out, caseLocale, true)
    }

    public func toFullTitle(c: Int32, iter: UCaseProps_ContextIterator, out: Appendable, caseLocale: Int32): Int32 {
        return toUpperOrTitle(c, iter, out, caseLocale, false)
    }

    static let FOLD_CASE_OPTIONS_MASK = 7

    public func fold(c: Int32, options: Int32): Int32 {
        var tempc = c
        let props = trie.get(tempc)
        if (!propsHasException(props)) {
            if (isUpperOrTitleFromProps(props)) {
                tempc += getDelta(props)
            }
        } else {
            var excOffset = getExceptionsOffset(props)
            let excWord = Int32(UInt32(Char(exceptions[Int64(match (0) { case _ => excOffset++; excOffset - 1 })])))
            let index: Int32
            if ((excWord & EXC_CONDITIONAL_FOLD) != 0) {
                if ((options & FOLD_CASE_OPTIONS_MASK) == UCharacter.FOLD_CASE_DEFAULT) {
                    if (tempc == 73) {
                        return 105
                    } else if (tempc == 304) {
                        return tempc
                    }
                } else {
                    if (tempc == 73) {
                        return 305
                    } else if (tempc == 304) {
                        return 105
                    }
                }
            }
            if ((excWord & EXC_NO_SIMPLE_CASE_FOLDING) != 0) {
                return tempc
            }
            if (hasSlot(excWord, EXC_DELTA) && isUpperOrTitleFromProps(props)) {
                let delta = getSlotValue(excWord, EXC_DELTA, excOffset)
                return if ((excWord & EXC_DELTA_IS_NEGATIVE) == 0) { tempc + delta } else { tempc - delta }
            }
            if (hasSlot(excWord, EXC_FOLD)) {
                index = EXC_FOLD
            } else if (hasSlot(excWord, EXC_LOWER)) {
                index = EXC_LOWER
            } else {
                return tempc
            }
            tempc = getSlotValue(excWord, index, excOffset)
        }
        return tempc
    }

    public func toFullFolding(c: Int32, out: Appendable, options: Int32): Int32 {
        var result: Int32 = 0
        let props: Int32
        result = c
        props = trie.get(c)
        if (!propsHasException(props)) {
            if (isUpperOrTitleFromProps(props)) {
                result = c + getDelta(props)
            }
        } else {
            var excOffset = getExceptionsOffset(props)
            let excOffset2: Int32
            let excWord = Int32(UInt32(Char(exceptions[Int64(match (0) { case _ => excOffset++; excOffset - 1 })])))
            var full: Int32 = 0
            let index: Int32
            excOffset2 = excOffset
            if ((excWord & EXC_CONDITIONAL_FOLD) != 0) {
                if ((options & FOLD_CASE_OPTIONS_MASK) == UCharacter.FOLD_CASE_DEFAULT) {
                    if (c == 73) {
                        return 105
                    } else if (c == 304) {
                        try {
                            out.append(iDot)
                            return 2
                        } catch (e: IOException) {
                            throw ICUUncheckedIOException(e)
                        }
                    }
                } else {
                    if (c == 73) {
                        return 305
                    } else if (c == 304) {
                        return 105
                    }
                }
            } else if (hasSlot(excWord, EXC_FULL_MAPPINGS)) {
                let value = getSlotValueAndOffset(excWord, EXC_FULL_MAPPINGS, excOffset)
                full = Int32(value) & 65535
                excOffset = Int32(shr(value, 32)) + 1
                excOffset += full & FULL_LOWER
                full = (shr(full, 4)) & 15
                if (full != 0) {
                    try {
                        out.append(exceptions, excOffset, excOffset + full)
                        return full
                    } catch (e: IOException) {
                        throw ICUUncheckedIOException(e)
                    }
                }
            }
            if ((excWord & EXC_NO_SIMPLE_CASE_FOLDING) != 0) {
                return 
            }
            if (hasSlot(excWord, EXC_DELTA) && isUpperOrTitleFromProps(props)) {
                let delta = getSlotValue(excWord, EXC_DELTA, excOffset2)
                return if ((excWord & EXC_DELTA_IS_NEGATIVE) == 0) { c + delta } else { c - delta }
            }
            if (hasSlot(excWord, EXC_FOLD)) {
                index = EXC_FOLD
            } else if (hasSlot(excWord, EXC_LOWER)) {
                index = EXC_LOWER
            } else {
                return 
            }
            result = getSlotValue(excWord, index, excOffset2)
        }
        return if (result == c) {  } else { result }
    }

    public static let dummyStringBuilder = StringBuilder()

    public func hasBinaryProperty(c: Int32, which: Int32): Bool {
        match (which) {
            case 22 => return LOWER == getType(c)
            case 30 => return UPPER == getType(c)
            case 27 => return isSoftDotted(c)
            case 34 => return isCaseSensitive(c)
            case 49 => return NONE != getType(c)
            case 50 => return (shr(getTypeOrIgnorable(c), 2)) != 0
            case 51 =>
                dummyStringBuilder.setLength(0)
                return toFullLower(c, None, dummyStringBuilder as Appendable, LOC_ROOT) >= 0
            case 52 =>
                dummyStringBuilder.setLength(0)
                return toFullUpper(c, None, dummyStringBuilder as Appendable, LOC_ROOT) >= 0
            case 53 =>
                dummyStringBuilder.setLength(0)
                return toFullTitle(c, None, dummyStringBuilder as Appendable, LOC_ROOT) >= 0
            case 55 =>
                dummyStringBuilder.setLength(0)
                return toFullLower(c, None, dummyStringBuilder as Appendable, LOC_ROOT) >= 0 || toFullUpper(c, None, dummyStringBuilder as Appendable, LOC_ROOT) >= 0 || toFullTitle(c, None, dummyStringBuilder as Appendable, LOC_ROOT) >= 0
            case _ => return false
        }
    }

    private var indexes: Array<Int32>

    private var exceptions: String

    private var unfold: Array<Char>

    private var trie: Trie2_16

    private static let DATA_NAME = "ucase"

    private static let DATA_TYPE = "icu"

    private static let DATA_FILE_NAME: String = DATA_NAME + "." + DATA_TYPE

    private static let FMT = 1665225541

    private static let IX_TRIE_SIZE = 2

    private static let IX_EXC_LENGTH = 3

    private static let IX_UNFOLD_LENGTH = 4

    private static let IX_TOP = 16

    static func getTrie(): Trie2_16 {
        return INSTANCE.trie
    }

    public static let TYPE_MASK = 3

    public static let NONE = 0

    public static let LOWER = 1

    public static let UPPER = 2

    public static let TITLE = 3

    static func getTypeFromProps(props: Int32): Int32 {
        return props & TYPE_MASK
    }

    private static func getTypeAndIgnorableFromProps(props: Int32): Int32 {
        return props & 7
    }

    static func isUpperOrTitleFromProps(props: Int32): Bool {
        return (props & 2) != 0
    }

    static let IGNORABLE = 4

    private static let EXCEPTION = 8

    private static let SENSITIVE = 16

    private static let DOT_MASK = 96

    private static let SOFT_DOTTED = 32

    private static let ABOVE = 64

    private static let OTHER_ACCENT = 96

    private static let DELTA_SHIFT = 7

    static func getDelta(props: Int32): Int32 {
        return shr(Int32(Int16(props)), DELTA_SHIFT)
    }

    private static let EXC_SHIFT = 4

    private static let EXC_LOWER = 0

    private static let EXC_FOLD = 1

    private static let EXC_UPPER = 2

    private static let EXC_TITLE = 3

    private static let EXC_DELTA = 4

    private static let EXC_CLOSURE = 6

    private static let EXC_FULL_MAPPINGS = 7

    private static let EXC_DOUBLE_SLOTS = 256

    private static let EXC_NO_SIMPLE_CASE_FOLDING = 512

    private static let EXC_DELTA_IS_NEGATIVE = 1024

    private static let EXC_SENSITIVE = 2048

    private static let EXC_DOT_SHIFT = 7

    private static let EXC_CONDITIONAL_SPECIAL = 16384

    private static let EXC_CONDITIONAL_FOLD = 32768

    private static let FULL_LOWER = 15

    private static let CLOSURE_MAX_LENGTH = 15

    private static let UNFOLD_ROWS = 0

    private static let UNFOLD_ROW_WIDTH = 1

    private static let UNFOLD_STRING_WIDTH = 2

    public static let INSTANCE: UCaseProps

}


class UCaseProps_IsAcceptable <: ICUBinary_Authenticate {

    public override func isDataVersionAcceptable(version: Array<UInt8>): Bool {
        return Int32(version[0]) == 4
    }
}


public interface UCaseProps_ContextIterator {
    public func reset(dir: Int32): Unit

    public func next(): Int32
}

class UCaseProps_LatinCase {

    static let LIMIT = Char(384)

    static let LONG_S = Char(383)

    static let EXC = UInt8(-128)

    static let TO_LOWER_NORMAL: Array<UInt8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, EXC, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 0, 32, 32, 32, 32, 32, 32, 32, EXC, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, EXC, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, EXC, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 135, 1, 0, 1, 0, 1, 0, EXC]

    static let TO_LOWER_TR_LT: Array<UInt8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 32, 32, 32, 32, 32, 32, EXC, EXC, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, EXC, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, EXC, EXC, 32, 32, 32, 32, 32, 32, 32, 32, 32, 0, 32, 32, 32, 32, 32, 32, 32, EXC, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, EXC, 0, 1, 0, 1, 0, EXC, 0, EXC, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, EXC, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 135, 1, 0, 1, 0, 1, 0, EXC]

    static let TO_UPPER_NORMAL: Array<UInt8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, EXC, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, EXC, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 0, 224, 224, 224, 224, 224, 224, 224, 121, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, EXC, 0, 255, 0, 255, 0, 255, 0, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, EXC, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 0, 255, 0, 255, 0, 255, EXC]

    static let TO_UPPER_TR: Array<UInt8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 224, 224, 224, 224, 224, 224, 224, 224, EXC, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, EXC, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, EXC, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 0, 224, 224, 224, 224, 224, 224, 224, 121, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, EXC, 0, 255, 0, 255, 0, 255, 0, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, EXC, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 0, 0, 255, 0, 255, 0, 255, EXC]
}
