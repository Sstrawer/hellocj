package icu4cj.util


public class CharsTrie <: Cloneable & Iterable<CharsTrie_Entry> {
    public init(trieChars: String, offset: Int32) {
        chars_ = trieChars
        pos_ = match (0) { case _ => root_ = offset; root_ }
        remainingMatchLength_ = -1
    }

    public init(other: CharsTrie) {
        chars_ = other.chars_
        root_ = other.root_
        pos_ = other.pos_
        remainingMatchLength_ = other.remainingMatchLength_
    }

    public override func clone(): CharsTrie {
        return super.toString()
    }

    public func reset(): CharsTrie {
        pos_ = root_
        remainingMatchLength_ = -1
        return this
    }

    public func getState64(): Int64 {
        return (shl(Int64(remainingMatchLength_), 32)) | Int64(pos_)
    }

    public func resetToState64(state: Int64): CharsTrie {
        remainingMatchLength_ = Int32(shr(state, 32))
        pos_ = Int32(state)
        return this
    }

    public func saveState(state: CharsTrie_State): CharsTrie {
        state.chars = chars_
        state.root = root_
        state.pos = pos_
        state.remainingMatchLength = remainingMatchLength_
        return this
    }

    public func resetToState(state: CharsTrie_State): CharsTrie {
        if (refEq(chars_, state.chars) && chars_.isSome() && root_ == state.root) {
            pos_ = state.pos
            remainingMatchLength_ = state.remainingMatchLength
        } else {
            throw IllegalArgumentException("incompatible trie state")
        }
        return this
    }

    public func current(): BytesTrie_Result {
        let pos = pos_
        if (pos < 0) {
            return BytesTrie_Result.NO_MATCH
        } else {
            let node: Int32
            return if (remainingMatchLength_ < 0 && (match (0) { case _ => node = Int32(UInt32(chars_[pos])); node }) >= kMinValueLead) { valueResults_[Int64(shr(node, 15))] } else { BytesTrie_Result.NO_VALUE }
        }
    }

    public func first(inUnit: Int32): BytesTrie_Result {
        remainingMatchLength_ = -1
        return nextImpl(root_, inUnit)
    }

    public func firstForCodePoint(cp: Int32): BytesTrie_Result {
        return if (cp <= 65535) { first(cp) } else { (if (first(Int32(UInt32(UTF16.getLeadSurrogate(cp)))).hasNext()) { next(Int32(UInt32(UTF16.getTrailSurrogate(cp)))) } else { Some(BytesTrie_Result.NO_MATCH) }) }
    }

    public func next(inUnit: Int32): BytesTrie_Result {
        var pos = pos_
        if (pos < 0) {
            return BytesTrie_Result.NO_MATCH
        }
        var length = remainingMatchLength_
        if (length >= 0) {
            if (inUnit == Int32(UInt32(chars_[match (0] { case _ => pos++; pos - 1 })))) {
                remainingMatchLength_ = match (0) { case _ => length--; length }
                pos_ = pos
                let node: Int32
                return if (length < 0 && (match (0) { case _ => node = Int32(UInt32(chars_[pos])); node }) >= kMinValueLead) { valueResults_[Int64(shr(node, 15))] } else { BytesTrie_Result.NO_VALUE }
            } else {
                stop()
                return BytesTrie_Result.NO_MATCH
            }
        }
        return nextImpl(pos, inUnit)
    }

    public func nextForCodePoint(cp: Int32): BytesTrie_Result {
        return if (cp <= 65535) { next(cp) } else { (if (next(Int32(UInt32(UTF16.getLeadSurrogate(cp)))).hasNext()) { next(Int32(UInt32(UTF16.getTrailSurrogate(cp)))) } else { Some(BytesTrie_Result.NO_MATCH) }) }
    }

    public func next(s: String, sIndex: Int32, sLimit: Int32): BytesTrie_Result {
        var tempsIndex = sIndex
        if (tempsIndex >= sLimit) {
            return current()
        }
        var pos = pos_
        if (pos < 0) {
            return BytesTrie_Result.NO_MATCH
        }
        var length = remainingMatchLength_
        while (true) {
            var inUnit: Char = '\u{0000}'
            while (true) {
                if (tempsIndex == sLimit) {
                    remainingMatchLength_ = length
                    pos_ = pos
                    let node: Int32
                    return if (length < 0 && (match (0) { case _ => node = Int32(UInt32(chars_[pos])); node }) >= kMinValueLead) { valueResults_[Int64(shr(node, 15))] } else { BytesTrie_Result.NO_VALUE }
                }
                inUnit = s[match (0] { case _ => tempsIndex++; tempsIndex - 1 })
                if (length < 0) {
                    remainingMatchLength_ = length
                    break
                }
                if (inUnit != chars_[pos]) {
                    stop()
                    return BytesTrie_Result.NO_MATCH
                }
                pos++
                length--
            }
            var node = Int32(UInt32(chars_[match (0] { case _ => pos++; pos - 1 })))
            while (true) {
                if (node < kMinLinearMatch) {
                    let result = branchNext(pos, node, Int32(UInt32(inUnit)))
                    if (refEq(result, BytesTrie_Result.NO_MATCH)) {
                        return BytesTrie_Result.NO_MATCH
                    }
                    if (tempsIndex == sLimit) {
                        return result
                    }
                    if (refEq(result, BytesTrie_Result.FINAL_VALUE)) {
                        stop()
                        return BytesTrie_Result.NO_MATCH
                    }
                    inUnit = s[match (0] { case _ => tempsIndex++; tempsIndex - 1 })
                    pos = pos_
                    node = Int32(UInt32(chars_[match (0] { case _ => pos++; pos - 1 })))
                } else if (node < kMinValueLead) {
                    length = node - kMinLinearMatch
                    if (inUnit != chars_[pos]) {
                        stop()
                        return BytesTrie_Result.NO_MATCH
                    }
                    pos++
                    length--
                    break
                } else if ((node & kValueIsFinal) != 0) {
                    stop()
                    return BytesTrie_Result.NO_MATCH
                } else {
                    pos = skipNodeValue(pos, node)
                    node &= kNodeTypeMask
                }
            }
        }
    }

    public func getValue(): Int32 {
        var pos = pos_
        let leadUnit = Int32(UInt32(chars_[match (0] { case _ => pos++; pos - 1 })))
        if (!(leadUnit >= kMinValueLead)) {
            throw AssertionError()
        }
        return if ((leadUnit & kValueIsFinal) != 0) { readValue(chars_, pos, leadUnit & 32767) } else { readNodeValue(chars_, pos, leadUnit) }
    }

    public func getUniqueValue(): Int64 {
        let pos = pos_
        if (pos < 0) {
            return 0
        }
        let uniqueValue = findUniqueValue(chars_, pos + remainingMatchLength_ + 1, 0)
        return shr((shl(uniqueValue, 31)), 31)
    }

    public func getNextChars(out: Appendable): Int32 {
        var pos = pos_
        if (pos < 0) {
            return 0
        }
        if (remainingMatchLength_ >= 0) {
            append(out, Int32(UInt32(chars_[pos])))
            return 1
        }
        var node = Int32(UInt32(chars_[match (0] { case _ => pos++; pos - 1 })))
        if (node >= kMinValueLead) {
            if ((node & kValueIsFinal) != 0) {
                return 0
            } else {
                pos = skipNodeValue(pos, node)
                node &= kNodeTypeMask
            }
        }
        if (node < kMinLinearMatch) {
            if (node == 0) {
                node = Int32(UInt32(chars_[match (0] { case _ => pos++; pos - 1 })))
            }
            getNextBranchChars(chars_, pos, match (0) { case _ => node++; node }, out)
            return node
        } else {
            append(out, Int32(UInt32(chars_[pos])))
            return 1
        }
    }

    public override func iterator(): CharsTrie_Iterator {
        return CharsTrie_Iterator(chars_, pos_, remainingMatchLength_, 0)
    }

    public func iterator(maxStringLength: Int32): CharsTrie_Iterator {
        return CharsTrie_Iterator(chars_, pos_, remainingMatchLength_, maxStringLength)
    }

    public static func iteratorStatic(trieChars: String, offset: Int32, maxStringLength: Int32): CharsTrie_Iterator {
        return CharsTrie_Iterator(trieChars, offset, -1, maxStringLength)
    }

    private func stop(): Unit {
        pos_ = -1
    }

    static func readValue(chars: String, pos: Int32, leadUnit: Int32): Int32 {
        let value: Int32
        if (leadUnit < kMinTwoUnitValueLead) {
            value = leadUnit
        } else if (leadUnit < kThreeUnitValueLead) {
            value = (shl((leadUnit - kMinTwoUnitValueLead), 16)) | Int32(UInt32(chars[pos]))
        } else {
            value = (shl(Int32(UInt32(chars[pos])), 16)) | Int32(UInt32(chars[pos + 1]))
        }
        return value
    }

    static func skipValue(pos: Int32, leadUnit: Int32): Int32 {
        var temppos = pos
        if (leadUnit >= kMinTwoUnitValueLead) {
            if (leadUnit < kThreeUnitValueLead) {
                temppos++
            } else {
                temppos += 2
            }
        }
        return temppos
    }

    private static func skipValue(chars: String, pos: Int32): Int32 {
        var temppos = pos
        let leadUnit = Int32(UInt32(chars[match (0] { case _ => temppos++; temppos - 1 })))
        return skipValue(temppos, leadUnit & 32767)
    }

    static func readNodeValue(chars: String, pos: Int32, leadUnit: Int32): Int32 {
        if (!(kMinValueLead <= leadUnit && leadUnit < kValueIsFinal)) {
            throw AssertionError()
        }
        let value: Int32
        if (leadUnit < kMinTwoUnitNodeValueLead) {
            value = (shr(leadUnit, 6)) - 1
        } else if (leadUnit < kThreeUnitNodeValueLead) {
            value = (shl(((leadUnit & 32704) - kMinTwoUnitNodeValueLead), 10)) | Int32(UInt32(chars[pos]))
        } else {
            value = (shl(Int32(UInt32(chars[pos])), 16)) | Int32(UInt32(chars[pos + 1]))
        }
        return value
    }

    static func skipNodeValue(pos: Int32, leadUnit: Int32): Int32 {
        var temppos = pos
        if (!(kMinValueLead <= leadUnit && leadUnit < kValueIsFinal)) {
            throw AssertionError()
        }
        if (leadUnit >= kMinTwoUnitNodeValueLead) {
            if (leadUnit < kThreeUnitNodeValueLead) {
                temppos++
            } else {
                temppos += 2
            }
        }
        return temppos
    }

    static func jumpByDelta(chars: String, pos: Int32): Int32 {
        var temppos = pos
        var delta = Int32(UInt32(chars[match (0] { case _ => temppos++; temppos - 1 })))
        if (delta >= kMinTwoUnitDeltaLead) {
            if (delta == kThreeUnitDeltaLead) {
                delta = (shl(Int32(UInt32(chars[temppos])), 16)) | Int32(UInt32(chars[temppos + 1]))
                temppos += 2
            } else {
                delta = (shl((delta - kMinTwoUnitDeltaLead), 16)) | Int32(UInt32(chars[match (0] { case _ => temppos++; temppos - 1 })))
            }
        }
        return temppos + delta
    }

    static func skipDelta(chars: String, pos: Int32): Int32 {
        var temppos = pos
        let delta = Int32(UInt32(chars[match (0] { case _ => temppos++; temppos - 1 })))
        if (delta >= kMinTwoUnitDeltaLead) {
            if (delta == kThreeUnitDeltaLead) {
                temppos += 2
            } else {
                temppos++
            }
        }
        return temppos
    }

    private static var valueResults_: Array<BytesTrie_Result> = [BytesTrie_Result.INTERMEDIATE_VALUE, BytesTrie_Result.FINAL_VALUE]

    private func branchNext(pos: Int32, length: Int32, inUnit: Int32): BytesTrie_Result {
        var templength = length
        var temppos = pos
        if (templength == 0) {
            templength = Int32(UInt32(chars_[match (0] { case _ => temppos++; temppos - 1 })))
        }
        templength++
        while (templength > kMaxBranchLinearSubNodeLength) {
            if (inUnit < Int32(UInt32(chars_[match (0] { case _ => temppos++; temppos - 1 })))) {
                templength >>= 1
                temppos = jumpByDelta(chars_, temppos)
            } else {
                templength = templength - (shr(templength, 1))
                temppos = skipDelta(chars_, temppos)
            }
        }
                    temppos++
                    let delta: Int32
                    if (node < kMinTwoUnitValueLead) {
                        delta = node
                    } else if (node < kThreeUnitValueLead) {
                        delta = (shl((node - kMinTwoUnitValueLead), 16)) | Int32(UInt32(chars_[match (0] { case _ => temppos++; temppos - 1 })))
                    } else {
                        delta = (shl(Int32(UInt32(chars_[temppos])), 16)) | Int32(UInt32(chars_[temppos + 1]))
                        temppos += 2
                    }
                    temppos += delta
                    node = Int32(UInt32(chars_[temppos]))
                    result = if (node >= kMinValueLead) { valueResults_[Int64(shr(node, 15))] } else { BytesTrie_Result.NO_VALUE }
                }
                pos_ = temppos
                return result
            }
            templength--
            temppos = skipValue(chars_, temppos)
        } while (templength > 1)
        if (inUnit == Int32(UInt32(chars_[match (0] { case _ => temppos++; temppos - 1 })))) {
            pos_ = temppos
            let node = Int32(UInt32(chars_[temppos]))
            return if (node >= kMinValueLead) { valueResults_[Int64(shr(node, 15))] } else { BytesTrie_Result.NO_VALUE }
        } else {
            stop()
            return BytesTrie_Result.NO_MATCH
        }
    }

    private func nextImpl(pos: Int32, inUnit: Int32): BytesTrie_Result {
        var temppos = pos
        var node = Int32(UInt32(chars_[match (0] { case _ => temppos++; temppos - 1 })))
        while (true) {
            if (node < kMinLinearMatch) {
                return branchNext(temppos, node, inUnit)
            } else if (node < kMinValueLead) {
                var length = node - kMinLinearMatch
                if (inUnit == Int32(UInt32(chars_[match (0] { case _ => temppos++; temppos - 1 })))) {
                    remainingMatchLength_ = match (0) { case _ => length--; length }
                    pos_ = temppos
                    return if (length < 0 && (match (0) { case _ => node = Int32(UInt32(chars_[temppos])); node }) >= kMinValueLead) { valueResults_[Int64(shr(node, 15))] } else { BytesTrie_Result.NO_VALUE }
                } else {
                    break
                }
            } else if ((node & kValueIsFinal) != 0) {
                break
            } else {
                temppos = skipNodeValue(temppos, node)
                node &= kNodeTypeMask
            }
        }
        stop()
        return BytesTrie_Result.NO_MATCH
    }

    private static func findUniqueValueFromBranch(chars: String, pos: Int32, length: Int32, uniqueValue: Int64): Int64 {
        var temppos = pos
        var tempuniqueValue = uniqueValue
        var templength = length
        while (templength > kMaxBranchLinearSubNodeLength) {
            temppos++
            tempuniqueValue = findUniqueValueFromBranch(chars, jumpByDelta(chars, temppos), shr(templength, 1), tempuniqueValue)
            if (tempuniqueValue == 0) {
                return 0
            }
            templength = templength - (shr(templength, 1))
            temppos = skipDelta(chars, temppos)
        }
                } else {
                    tempuniqueValue = (shl(Int64(value), 1)) | 1
                }
            } else {
                tempuniqueValue = findUniqueValue(chars, temppos + value, tempuniqueValue)
                if (tempuniqueValue == 0) {
                    return 0
                }
            }
        } while (match (0) { case _ => templength--; templength } > 1)
        return (shl(Int64(temppos + 1), 33)) | (tempuniqueValue & 8589934591)
    }

    private static func findUniqueValue(chars: String, pos: Int32, uniqueValue: Int64): Int64 {
        var temppos = pos
        var tempuniqueValue = uniqueValue
        var node = Int32(UInt32(chars[match (0] { case _ => temppos++; temppos - 1 })))
        while (true) {
            if (node < kMinLinearMatch) {
                if (node == 0) {
                    node = Int32(UInt32(chars[match (0] { case _ => temppos++; temppos - 1 })))
                }
                tempuniqueValue = findUniqueValueFromBranch(chars, temppos, node + 1, tempuniqueValue)
                if (tempuniqueValue == 0) {
                    return 0
                }
                temppos = Int32(ushr(tempuniqueValue, 33))
                node = Int32(UInt32(chars[match (0] { case _ => temppos++; temppos - 1 })))
            } else if (node < kMinValueLead) {
                temppos += node - kMinLinearMatch + 1
                node = Int32(UInt32(chars[match (0] { case _ => temppos++; temppos - 1 })))
            } else {
                let isFinal = (node & kValueIsFinal) != 0
                let value: Int32
                if (isFinal) {
                    value = readValue(chars, temppos, node & 32767)
                } else {
                    value = readNodeValue(chars, temppos, node)
                }
                if (tempuniqueValue != 0) {
                    if (value != Int32(shr(tempuniqueValue, 1))) {
                        return 0
                    }
                } else {
                    tempuniqueValue = (shl(Int64(value), 1)) | 1
                }
                if (isFinal) {
                    return tempuniqueValue
                }
                temppos = skipNodeValue(temppos, node)
                node &= kNodeTypeMask
            }
        }
    }

    private static func getNextBranchChars(chars: String, pos: Int32, length: Int32, out: Appendable): Unit {
        var temppos = pos
        var templength = length
        while (templength > kMaxBranchLinearSubNodeLength) {
            temppos++
            getNextBranchChars(chars, jumpByDelta(chars, temppos), shr(templength, 1), out)
            templength = templength - (shr(templength, 1))
            temppos = skipDelta(chars, temppos)
        }
        append(out, Int32(UInt32(chars[temppos])))
    }

    private static func append(out: Appendable, c: Int32): Unit {
        try {
            out.append(Char(c))
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    static let kMaxBranchLinearSubNodeLength = 5

    static let kMinLinearMatch = 48

    static let kMaxLinearMatchLength = 16

    static let kMinValueLead = kMinLinearMatch + kMaxLinearMatchLength

    static let kNodeTypeMask = kMinValueLead - 1

    static let kValueIsFinal = 32768

    static let kMaxOneUnitValue = 16383

    static let kMinTwoUnitValueLead = kMaxOneUnitValue + 1

    static let kThreeUnitValueLead = 32767

    static let kMaxTwoUnitValue = (shl((kThreeUnitValueLead - kMinTwoUnitValueLead), 16)) - 1

    static let kMaxOneUnitNodeValue = 255

    static let kMinTwoUnitNodeValueLead = kMinValueLead + (shl((kMaxOneUnitNodeValue + 1), 6))

    static let kThreeUnitNodeValueLead = 32704

    static let kMaxTwoUnitNodeValue = (shl((kThreeUnitNodeValueLead - kMinTwoUnitNodeValueLead), 10)) - 1

    static let kMaxOneUnitDelta = 64511

    static let kMinTwoUnitDeltaLead = kMaxOneUnitDelta + 1

    static let kThreeUnitDeltaLead = 65535

    static let kMaxTwoUnitDelta = (shl((kThreeUnitDeltaLead - kMinTwoUnitDeltaLead), 16)) - 1

    private var chars_: String

    private var root_: Int32 = 0

    private var pos_: Int32 = 0

    private var remainingMatchLength_: Int32 = 0
}


public class CharsTrie_State {

    var chars: String

    var root: Int32 = 0

    var pos: Int32 = 0

    var remainingMatchLength: Int32 = 0
}


public class CharsTrie_Entry {
    public var chars: String

    public var value: Int32 = 0

}


public class CharsTrie_Iterator <: Iterator<CharsTrie_Entry> {
    init(trieChars: String, offset: Int32, remainingMatchLength: Int32, maxStringLength: Int32) {
        chars_ = trieChars
        pos_ = match (0) { case _ => initialPos_ = offset; initialPos_ }
        remainingMatchLength_ = match (0) { case _ => initialRemainingMatchLength_ = remainingMatchLength; initialRemainingMatchLength_ }
        maxLength_ = maxStringLength
        var length = remainingMatchLength_
        if (length >= 0) {
            length++
            if (maxLength_ > 0 && length > maxLength_) {
                length = maxLength_
            }
            str_.append(chars_, pos_, pos_ + length)
            pos_ += length
            remainingMatchLength_ -= length
        }
    }

    public func reset(): CharsTrie_Iterator {
        pos_ = initialPos_
        remainingMatchLength_ = initialRemainingMatchLength_
        skipValue_ = false
        var length = remainingMatchLength_ + 1
        if (maxLength_ > 0 && length > maxLength_) {
            length = maxLength_
        }
        str_.setLength(Int64(length))
        pos_ += length
        remainingMatchLength_ -= length
        stack_.clear()
        return this
    }

    public override func hasNext(): Bool {
        return pos_ >= 0 || !stack_.isEmpty()
    }

    public override func next(): CharsTrie_Entry {
        var pos = pos_
        if (pos < 0) {
            if (stack_.isEmpty()) {
                throw NoSuchElementException()
            }
            let top = stack_.remove(Int64(Int32(stack_.size) - 1))
            var length = Int32(top)
            pos = Int32(shr(top, 32))
            str_.setLength(Int64(length & 65535))
            length = ushr(length, 16)
            if (length > 1) {
                pos = branchNext(pos, length)
                if (pos < 0) {
                    return entry_
                }
            } else {
                str_.append(chars_[match (0] { case _ => pos++; pos - 1 }))
            }
        }
        if (remainingMatchLength_ >= 0) {
            return truncateAndStop()
        }
        while (true) {
            var node = Int32(UInt32(chars_[match (0] { case _ => pos++; pos - 1 })))
            if (node >= CharsTrie.kMinValueLead) {
                if (skipValue_) {
                    pos = CharsTrie.skipNodeValue(pos, node)
                    node &= CharsTrie.kNodeTypeMask
                    skipValue_ = false
                } else {
                    let isFinal = (node & CharsTrie.kValueIsFinal) != 0
                    if (isFinal) {
                        entry_.value = CharsTrie.readValue(chars_, pos, node & 32767)
                    } else {
                        entry_.value = CharsTrie.readNodeValue(chars_, pos, node)
                    }
                    if (isFinal || (maxLength_ > 0 && Int32(str_.size) == maxLength_)) {
                        pos_ = -1
                    } else {
                        pos_ = pos - 1
                        skipValue_ = true
                    }
                    entry_.chars = str_.asString()
                    return entry_
                }
            }
            if (maxLength_ > 0 && Int32(str_.size) == maxLength_) {
                return truncateAndStop()
            }
            if (node < CharsTrie.kMinLinearMatch) {
                if (node == 0) {
                    node = Int32(UInt32(chars_[match (0] { case _ => pos++; pos - 1 })))
                }
                pos = branchNext(pos, node + 1)
                if (pos < 0) {
                    return entry_
                }
            } else {
                let length = node - CharsTrie.kMinLinearMatch + 1
                if (maxLength_ > 0 && Int32(str_.size) + length > maxLength_) {
                    str_.append(chars_, pos, pos + maxLength_ - Int32(str_.size))
                    return truncateAndStop()
                }
                str_.append(chars_, pos, pos + length)
                pos += length
            }
        }
    }

    public override func remove(): Unit {
        throw UnsupportedOperationException()
    }

    private func truncateAndStop(): CharsTrie_Entry {
        pos_ = -1
        entry_.chars = str_.asString()
        entry_.value = -1
        return entry_
    }

    private func branchNext(pos: Int32, length: Int32): Int32 {
        var temppos = pos
        var templength = length
        while (templength > CharsTrie.kMaxBranchLinearSubNodeLength) {
            temppos++
            stack_.append((shl(Int64(CharsTrie.skipDelta(chars_, temppos)), 32)) | (Int64(shl((templength - (shr(templength, 1))), 16))) | str_.size)
            templength >>= 1
            temppos = CharsTrie.jumpByDelta(chars_, temppos)
        }
        let trieUnit = chars_[match (0] { case _ => temppos++; temppos - 1 })
        var node = Int32(UInt32(chars_[match (0] { case _ => temppos++; temppos - 1 })))
        let isFinal = (node & CharsTrie.kValueIsFinal) != 0
        let value = CharsTrie.readValue(chars_, temppos, node &= 32767)
        temppos = CharsTrie.skipValue(temppos, node)
        stack_.append((shl(Int64(temppos), 32)) | (Int64(shl((templength - 1), 16))) | str_.size)
        str_.append(trieUnit)
        if (isFinal) {
            pos_ = -1
            entry_.chars = str_.asString()
            entry_.value = value
            return -1
        } else {
            return temppos + value
        }
    }

    private var chars_: String

    private var pos_: Int32 = 0

    private var initialPos_: Int32 = 0

    private var remainingMatchLength_: Int32 = 0

    private var initialRemainingMatchLength_: Int32 = 0

    private var skipValue_: Bool = false

    private var str_: StringBuilder = StringBuilder()

    private var maxLength_: Int32 = 0

    private var entry_: CharsTrie_Entry = CharsTrie_Entry()

    private var stack_: ArrayList<Int64> = ArrayList<Int64>()
}
