package icu4cj.util


public class BytesTrie <: Cloneable & Iterable<BytesTrie_Entry> {
    public init(trieBytes: Array<UInt8>, offset: Int32) {
        bytes_ = trieBytes
        pos_ = match (0) { case _ => root_ = offset; root_ }
        remainingMatchLength_ = -1
    }

    public init(other: BytesTrie) {
        bytes_ = other.bytes_
        root_ = other.root_
        pos_ = other.pos_
        remainingMatchLength_ = other.remainingMatchLength_
    }

    public override func clone(): BytesTrie {
        return super.toString()
    }

    public func reset(): BytesTrie {
        pos_ = root_
        remainingMatchLength_ = -1
        return this
    }

    public func getState64(): Int64 {
        return (shl(Int64(remainingMatchLength_), 32)) | Int64(pos_)
    }

    public func resetToState64(state: Int64): BytesTrie {
        remainingMatchLength_ = Int32(shr(state, 32))
        pos_ = Int32(state)
        return this
    }

    public func saveState(state: BytesTrie_State): BytesTrie {
        state.bytes = bytes_
        state.root = root_
        state.pos = pos_
        state.remainingMatchLength = remainingMatchLength_
        return this
    }

    public func resetToState(state: BytesTrie_State): BytesTrie {
        if (refEq(bytes_, state.bytes) && bytes_.isSome() && root_ == state.root) {
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
            return if (remainingMatchLength_ < 0 && (match (0) { case _ => node = Int32(bytes_[Int64(pos)]) & 255; node }) >= kMinValueLead) { valueResults_[Int64(node & kValueIsFinal)] } else { BytesTrie_Result.NO_VALUE }
        }
    }

    public func first(inByte: Int32): BytesTrie_Result {
        var tempinByte = inByte
        remainingMatchLength_ = -1
        if (tempinByte < 0) {
            tempinByte += 256
        }
        return nextImpl(root_, tempinByte)
    }

    public func next(inByte: Int32): BytesTrie_Result {
        var tempinByte = inByte
        var pos = pos_
        if (pos < 0) {
            return BytesTrie_Result.NO_MATCH
        }
        if (tempinByte < 0) {
            tempinByte += 256
        }
        var length = remainingMatchLength_
        if (length >= 0) {
            if (tempinByte == (Int32(bytes_[Int64(match (0) { case _ => pos++; pos - 1 })]) & 255)) {
                remainingMatchLength_ = match (0) { case _ => length--; length }
                pos_ = pos
                let node: Int32
                return if (length < 0 && (match (0) { case _ => node = Int32(bytes_[Int64(pos)]) & 255; node }) >= kMinValueLead) { valueResults_[Int64(node & kValueIsFinal)] } else { BytesTrie_Result.NO_VALUE }
            } else {
                stop()
                return BytesTrie_Result.NO_MATCH
            }
        }
        return nextImpl(pos, tempinByte)
    }

    public func next(s: Array<UInt8>, sIndex: Int32, sLimit: Int32): BytesTrie_Result {
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
            var inByte: UInt8 = 0
            while (true) {
                if (tempsIndex == sLimit) {
                    remainingMatchLength_ = length
                    pos_ = pos
                    let node: Int32
                    return if (length < 0 && (match (0) { case _ => node = (Int32(bytes_[Int64(pos)]) & 255); node }) >= kMinValueLead) { valueResults_[Int64(node & kValueIsFinal)] } else { BytesTrie_Result.NO_VALUE }
                }
                inByte = s[Int64(match (0) { case _ => tempsIndex++; tempsIndex - 1 })]
                if (length < 0) {
                    remainingMatchLength_ = length
                    break
                }
                if (inByte != bytes_[Int64(pos)]) {
                    stop()
                    return BytesTrie_Result.NO_MATCH
                }
                pos++
                length--
            }
            while (true) {
                let node = Int32(bytes_[Int64(match (0) { case _ => pos++; pos - 1 })]) & 255
                if (node < kMinLinearMatch) {
                    let result = branchNext(pos, node, Int32(inByte) & 255)
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
                    inByte = s[Int64(match (0) { case _ => tempsIndex++; tempsIndex - 1 })]
                    pos = pos_
                } else if (node < kMinValueLead) {
                    length = node - kMinLinearMatch
                    if (inByte != bytes_[Int64(pos)]) {
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
                    pos = skipValue(pos, node)
                    if (!((Int32(bytes_[Int64(pos)]) & 255) < kMinValueLead)) {
                        throw AssertionError()
                    }
                }
            }
        }
    }

    public func getValue(): Int32 {
        var pos = pos_
        let leadByte = Int32(bytes_[Int64(match (0) { case _ => pos++; pos - 1 })]) & 255
        if (!(leadByte >= kMinValueLead)) {
            throw AssertionError()
        }
        return readValue(bytes_, pos, shr(leadByte, 1))
    }

    public func getUniqueValue(): Int64 {
        let pos = pos_
        if (pos < 0) {
            return 0
        }
        let uniqueValue = findUniqueValue(bytes_, pos + remainingMatchLength_ + 1, 0)
        return shr((shl(uniqueValue, 31)), 31)
    }

    public func getNextBytes(out: Appendable): Int32 {
        var pos = pos_
        if (pos < 0) {
            return 0
        }
        if (remainingMatchLength_ >= 0) {
            append(out, Int32(bytes_[Int64(pos)]) & 255)
            return 1
        }
        var node = Int32(bytes_[Int64(match (0) { case _ => pos++; pos - 1 })]) & 255
        if (node >= kMinValueLead) {
            if ((node & kValueIsFinal) != 0) {
                return 0
            } else {
                pos = skipValue(pos, node)
                node = Int32(bytes_[Int64(match (0) { case _ => pos++; pos - 1 })]) & 255
                if (!(node < kMinValueLead)) {
                    throw AssertionError()
                }
            }
        }
        if (node < kMinLinearMatch) {
            if (node == 0) {
                node = Int32(bytes_[Int64(match (0) { case _ => pos++; pos - 1 })]) & 255
            }
            getNextBranchBytes(bytes_, pos, match (0) { case _ => node++; node }, out)
            return node
        } else {
            append(out, Int32(bytes_[Int64(pos)]) & 255)
            return 1
        }
    }

    public override func iterator(): BytesTrie_Iterator {
        return BytesTrie_Iterator(bytes_, pos_, remainingMatchLength_, 0)
    }

    public func iterator(maxStringLength: Int32): BytesTrie_Iterator {
        return BytesTrie_Iterator(bytes_, pos_, remainingMatchLength_, maxStringLength)
    }

    public static func iteratorStatic(trieBytes: Array<UInt8>, offset: Int32, maxStringLength: Int32): BytesTrie_Iterator {
        return BytesTrie_Iterator(trieBytes, offset, -1, maxStringLength)
    }

    private func stop(): Unit {
        pos_ = -1
    }

    static func readValue(bytes: Array<UInt8>, pos: Int32, leadByte: Int32): Int32 {
        let value: Int32
        if (leadByte < kMinTwoByteValueLead) {
            value = leadByte - kMinOneByteValueLead
        } else if (leadByte < kMinThreeByteValueLead) {
            value = (shl((leadByte - kMinTwoByteValueLead), 8)) | (Int32(bytes[Int64(pos)]) & 255)
        } else if (leadByte < kFourByteValueLead) {
            value = (shl((leadByte - kMinThreeByteValueLead), 16)) | (shl((Int32(bytes[Int64(pos)]) & 255), 8)) | (Int32(bytes[Int64(pos + 1)]) & 255)
        } else if (leadByte == kFourByteValueLead) {
            value = (shl((Int32(bytes[Int64(pos)]) & 255), 16)) | (shl((Int32(bytes[Int64(pos + 1)]) & 255), 8)) | (Int32(bytes[Int64(pos + 2)]) & 255)
        } else {
            value = (shl(Int32(bytes[Int64(pos)]), 24)) | (shl((Int32(bytes[Int64(pos + 1)]) & 255), 16)) | (shl((Int32(bytes[Int64(pos + 2)]) & 255), 8)) | (Int32(bytes[Int64(pos + 3)]) & 255)
        }
        return value
    }

    static func skipValue(pos: Int32, leadByte: Int32): Int32 {
        var temppos = pos
        if (!(leadByte >= kMinValueLead)) {
            throw AssertionError()
        }
        if (leadByte >= (shl(kMinTwoByteValueLead, 1))) {
            if (leadByte < (shl(kMinThreeByteValueLead, 1))) {
                temppos++
            } else if (leadByte < (shl(kFourByteValueLead, 1))) {
                temppos += 2
            } else {
                temppos += 3 + ((shr(leadByte, 1)) & 1)
            }
        }
        return temppos
    }

    private static func skipValue(bytes: Array<UInt8>, pos: Int32): Int32 {
        var temppos = pos
        let leadByte = Int32(bytes[Int64(match (0) { case _ => temppos++; temppos - 1 })]) & 255
        return skipValue(temppos, leadByte)
    }

    
    public static func jumpByDelta(bytes: Array<UInt8>, pos: Int32): Int32 {
        var temppos = pos
        var delta = Int32(bytes[Int64(match (0) { case _ => temppos++; temppos - 1 })]) & 255
        if (delta < kMinTwoByteDeltaLead) { } else if (delta < kMinThreeByteDeltaLead) {
            delta = (shl((delta - kMinTwoByteDeltaLead), 8)) | (Int32(bytes[Int64(match (0) { case _ => temppos++; temppos - 1 })]) & 255)
        } else if (delta < kFourByteDeltaLead) {
            delta = (shl((delta - kMinThreeByteDeltaLead), 16)) | (shl((Int32(bytes[Int64(temppos)]) & 255), 8)) | (Int32(bytes[Int64(temppos + 1)]) & 255)
            temppos += 2
        } else if (delta == kFourByteDeltaLead) {
            delta = (shl((Int32(bytes[Int64(temppos)]) & 255), 16)) | (shl((Int32(bytes[Int64(temppos + 1)]) & 255), 8)) | (Int32(bytes[Int64(temppos + 2)]) & 255)
            temppos += 3
        } else {
            delta = (shl(Int32(bytes[Int64(temppos)]), 24)) | (shl((Int32(bytes[Int64(temppos + 1)]) & 255), 16)) | (shl((Int32(bytes[Int64(temppos + 2)]) & 255), 8)) | (Int32(bytes[Int64(temppos + 3)]) & 255)
            temppos += 4
        }
        return temppos + delta
    }

    static func skipDelta(bytes: Array<UInt8>, pos: Int32): Int32 {
        var temppos = pos
        let delta = Int32(bytes[Int64(match (0) { case _ => temppos++; temppos - 1 })]) & 255
        if (delta >= kMinTwoByteDeltaLead) {
            if (delta < kMinThreeByteDeltaLead) {
                temppos++
            } else if (delta < kFourByteDeltaLead) {
                temppos += 2
            } else {
                temppos += 3 + (delta & 1)
            }
        }
        return temppos
    }

    private static var valueResults_: Array<BytesTrie_Result> = [BytesTrie_Result.INTERMEDIATE_VALUE, BytesTrie_Result.FINAL_VALUE]

    private func branchNext(pos: Int32, length: Int32, inByte: Int32): BytesTrie_Result {
        var templength = length
        var temppos = pos
        if (templength == 0) {
            templength = Int32(bytes_[Int64(match (0) { case _ => temppos++; temppos - 1 })]) & 255
        }
        templength++
        while (templength > kMaxBranchLinearSubNodeLength) {
            if (inByte < (Int32(bytes_[Int64(match (0) { case _ => temppos++; temppos - 1 })]) & 255)) {
                templength >>= 1
                temppos = jumpByDelta(bytes_, temppos)
            } else {
                templength = templength - (shr(templength, 1))
                temppos = skipDelta(bytes_, temppos)
            }
        }
                if ((node & kValueIsFinal) != 0) {
                    result = BytesTrie_Result.FINAL_VALUE
                } else {
                    temppos++
                    node >>= 1
                    let delta: Int32
                    if (node < kMinTwoByteValueLead) {
                        delta = node - kMinOneByteValueLead
                    } else if (node < kMinThreeByteValueLead) {
                        delta = (shl((node - kMinTwoByteValueLead), 8)) | (Int32(bytes_[Int64(match (0) { case _ => temppos++; temppos - 1 })]) & 255)
                    } else if (node < kFourByteValueLead) {
                        delta = (shl((node - kMinThreeByteValueLead), 16)) | (shl((Int32(bytes_[Int64(temppos)]) & 255), 8)) | (Int32(bytes_[Int64(temppos + 1)]) & 255)
                        temppos += 2
                    } else if (node == kFourByteValueLead) {
                        delta = (shl((Int32(bytes_[Int64(temppos)]) & 255), 16)) | (shl((Int32(bytes_[Int64(temppos + 1)]) & 255), 8)) | (Int32(bytes_[Int64(temppos + 2)]) & 255)
                        temppos += 3
                    } else {
                        delta = (shl(Int32(bytes_[Int64(temppos)]), 24)) | (shl((Int32(bytes_[Int64(temppos + 1)]) & 255), 16)) | (shl((Int32(bytes_[Int64(temppos + 2)]) & 255), 8)) | (Int32(bytes_[Int64(temppos + 3)]) & 255)
                        temppos += 4
                    }
                    temppos += delta
                    node = Int32(bytes_[Int64(temppos)]) & 255
                    result = if (node >= kMinValueLead) { valueResults_[Int64(node & kValueIsFinal)] } else { BytesTrie_Result.NO_VALUE }
                }
                pos_ = temppos
                return result
            }
            templength--
            temppos = skipValue(bytes_, temppos)
        } while (templength > 1)
        if (inByte == (Int32(bytes_[Int64(match (0) { case _ => temppos++; temppos - 1 })]) & 255)) {
            pos_ = temppos
            let node = Int32(bytes_[Int64(temppos)]) & 255
            return if (node >= kMinValueLead) { valueResults_[Int64(node & kValueIsFinal)] } else { BytesTrie_Result.NO_VALUE }
        } else {
            stop()
            return BytesTrie_Result.NO_MATCH
        }
    }

    private func nextImpl(pos: Int32, inByte: Int32): BytesTrie_Result {
        var temppos = pos
        while (true) {
            var node = Int32(bytes_[Int64(match (0) { case _ => temppos++; temppos - 1 })]) & 255
            if (node < kMinLinearMatch) {
                return branchNext(temppos, node, inByte)
            } else if (node < kMinValueLead) {
                var length = node - kMinLinearMatch
                if (inByte == (Int32(bytes_[Int64(match (0) { case _ => temppos++; temppos - 1 })]) & 255)) {
                    remainingMatchLength_ = match (0) { case _ => length--; length }
                    pos_ = temppos
                    return if (length < 0 && (match (0) { case _ => node = Int32(bytes_[Int64(temppos)]) & 255; node }) >= kMinValueLead) { valueResults_[Int64(node & kValueIsFinal)] } else { BytesTrie_Result.NO_VALUE }
                } else {
                    break
                }
            } else if ((node & kValueIsFinal) != 0) {
                break
            } else {
                temppos = skipValue(temppos, node)
                if (!((Int32(bytes_[Int64(temppos)]) & 255) < kMinValueLead)) {
                    throw AssertionError()
                }
            }
        }
        stop()
        return BytesTrie_Result.NO_MATCH
    }

    private static func findUniqueValueFromBranch(bytes: Array<UInt8>, pos: Int32, length: Int32, uniqueValue: Int64): Int64 {
        var temppos = pos
        var tempuniqueValue = uniqueValue
        var templength = length
        while (templength > kMaxBranchLinearSubNodeLength) {
            temppos++
            tempuniqueValue = findUniqueValueFromBranch(bytes, jumpByDelta(bytes, temppos), shr(templength, 1), tempuniqueValue)
            if (tempuniqueValue == 0) {
                return 0
            }
            templength = templength - (shr(templength, 1))
            temppos = skipDelta(bytes, temppos)
        }
                } else {
                    tempuniqueValue = (shl(Int64(value), 1)) | 1
                }
            } else {
                tempuniqueValue = findUniqueValue(bytes, temppos + value, tempuniqueValue)
                if (tempuniqueValue == 0) {
                    return 0
                }
            }
        } while (match (0) { case _ => templength--; templength } > 1)
        return (shl(Int64(temppos + 1), 33)) | (tempuniqueValue & 8589934591)
    }

    private static func findUniqueValue(bytes: Array<UInt8>, pos: Int32, uniqueValue: Int64): Int64 {
        var temppos = pos
        var tempuniqueValue = uniqueValue
        while (true) {
            var node = Int32(bytes[Int64(match (0) { case _ => temppos++; temppos - 1 })]) & 255
            if (node < kMinLinearMatch) {
                if (node == 0) {
                    node = Int32(bytes[Int64(match (0) { case _ => temppos++; temppos - 1 })]) & 255
                }
                tempuniqueValue = findUniqueValueFromBranch(bytes, temppos, node + 1, tempuniqueValue)
                if (tempuniqueValue == 0) {
                    return 0
                }
                temppos = Int32(ushr(tempuniqueValue, 33))
            } else if (node < kMinValueLead) {
                temppos += node - kMinLinearMatch + 1
            } else {
                let isFinal = (node & kValueIsFinal) != 0
                let value = readValue(bytes, temppos, shr(node, 1))
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
                temppos = skipValue(temppos, node)
            }
        }
    }

    private static func getNextBranchBytes(bytes: Array<UInt8>, pos: Int32, length: Int32, out: Appendable): Unit {
        var temppos = pos
        var templength = length
        while (templength > kMaxBranchLinearSubNodeLength) {
            temppos++
            getNextBranchBytes(bytes, jumpByDelta(bytes, temppos), shr(templength, 1), out)
            templength = templength - (shr(templength, 1))
            temppos = skipDelta(bytes, temppos)
        }
        append(out, Int32(bytes[Int64(temppos)]) & 255)
    }

    private static func append(out: Appendable, c: Int32): Unit {
        try {
            out.append(Char(c))
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    static let kMaxBranchLinearSubNodeLength = 5

    static let kMinLinearMatch = 16

    static let kMaxLinearMatchLength = 16

    static let kMinValueLead = kMinLinearMatch + kMaxLinearMatchLength

    static let kValueIsFinal = 1

    static let kMinOneByteValueLead = kMinValueLead / 2

    static let kMaxOneByteValue = 64

    static let kMinTwoByteValueLead = kMinOneByteValueLead + kMaxOneByteValue + 1

    static let kMaxTwoByteValue = 6911

    static let kMinThreeByteValueLead = kMinTwoByteValueLead + (shr(kMaxTwoByteValue, 8)) + 1

    static let kFourByteValueLead = 126

    static let kMaxThreeByteValue = (shl((kFourByteValueLead - kMinThreeByteValueLead), 16)) - 1

    static let kFiveByteValueLead = 127

    static let kMaxOneByteDelta = 191

    static let kMinTwoByteDeltaLead = kMaxOneByteDelta + 1

    static let kMinThreeByteDeltaLead = 240

    static let kFourByteDeltaLead = 254

    static let kFiveByteDeltaLead = 255

    static let kMaxTwoByteDelta = (shl((kMinThreeByteDeltaLead - kMinTwoByteDeltaLead), 8)) - 1

    static let kMaxThreeByteDelta = (shl((kFourByteDeltaLead - kMinThreeByteDeltaLead), 16)) - 1

    private var bytes_: Array<UInt8>

    private var root_: Int32 = 0

    private var pos_: Int32 = 0

    private var remainingMatchLength_: Int32 = 0
}


public class BytesTrie_State {

    var bytes: Array<UInt8>

    var root: Int32 = 0

    var pos: Int32 = 0

    var remainingMatchLength: Int32 = 0
}


public class BytesTrie_Result <: Enum<BytesTrie_Result> {
    public static let NO_MATCH = BytesTrie_Result("NO_MATCH", 0)

    public static let NO_VALUE = BytesTrie_Result("NO_VALUE", 1)

    public static let FINAL_VALUE = BytesTrie_Result("FINAL_VALUE", 2)

    public static let INTERMEDIATE_VALUE = BytesTrie_Result("INTERMEDIATE_VALUE", 3)

    private static func _values(): Array<BytesTrie_Result> {
        return [BytesTrie_Result.NO_MATCH, BytesTrie_Result.NO_VALUE, BytesTrie_Result.FINAL_VALUE, BytesTrie_Result.INTERMEDIATE_VALUE]
    }

    private static let _VALUES = BytesTrie_Result._values()

    public static func values(): Array<BytesTrie_Result> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): BytesTrie_Result {
        return (TypeInfo.of<BytesTrie_Result>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as BytesTrie_Result
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public func matches(): Bool {
        return !refEq(this, NO_MATCH)
    }

    public func hasValue(): Bool {
        return ordinal >= 2
    }

    public func hasNext(): Bool {
        return (ordinal & 1) != 0
    }
}


public class BytesTrie_Entry {
    init(capacity: Int32) {
        bytes = Array<UInt8>(Int64(capacity)) { _ => 0 }
    }

    public func bytesLength(): Int32 {
        return length
    }

    public func byteAt(index: Int32): UInt8 {
        return bytes[Int64(index)]
    }

    public func copyBytesTo(dest: Array<UInt8>, destOffset: Int32): Unit {
        arraycopy(bytes, 0, dest, Int64(destOffset), Int64(length))
    }

    public func bytesAsByteArrayStream(): ByteArrayStream {
        return ByteArrayStream.wrap(bytes, 0, length).asReadOnlyBuffer()
    }

    public var value: Int32 = 0

    private func ensureCapacity(len: Int32): Unit {
        if (Int32(bytes.size) < len) {
            let newBytes = Array<UInt8>(Int64(min(2 * Int32(bytes.size), 2 * len))) { _ => 0 }
            arraycopy(bytes, 0, newBytes, 0, Int64(length))
            bytes = newBytes
        }
    }

    public func append(b: UInt8): Unit {
        ensureCapacity(length + 1)
        bytes[Int64(match (0) { case _ => length++; length - 1 })] = b
    }

    public func append(b: Array<UInt8>, off: Int32, len: Int32): Unit {
        ensureCapacity(length + len)
        arraycopy(b, Int64(off), bytes, Int64(length), Int64(len))
        length += len
    }

    public func truncateString(newLength: Int32): Unit {
        length = newLength
    }

    private var bytes: Array<UInt8>

    var length: Int32 = 0
}


public class BytesTrie_Iterator <: Iterator<BytesTrie_Entry> {
    init(trieBytes: Array<UInt8>, offset: Int32, remainingMatchLength: Int32, maxStringLength: Int32) {
        bytes_ = trieBytes
        pos_ = match (0) { case _ => initialPos_ = offset; initialPos_ }
        remainingMatchLength_ = match (0) { case _ => initialRemainingMatchLength_ = remainingMatchLength; initialRemainingMatchLength_ }
        maxLength_ = maxStringLength
        entry_ = BytesTrie_Entry(if (maxLength_ != 0) { maxLength_ } else { 32 })
        var length = remainingMatchLength_
        if (length >= 0) {
            length++
            if (maxLength_ > 0 && length > maxLength_) {
                length = maxLength_
            }
            entry_.append(bytes_, pos_, length)
            pos_ += length
            remainingMatchLength_ -= length
        }
    }

    public func reset(): BytesTrie_Iterator {
        pos_ = initialPos_
        remainingMatchLength_ = initialRemainingMatchLength_
        var length = remainingMatchLength_ + 1
        if (maxLength_ > 0 && length > maxLength_) {
            length = maxLength_
        }
        entry_.truncateString(length)
        pos_ += length
        remainingMatchLength_ -= length
        stack_.clear()
        return this
    }

    public override func hasNext(): Bool {
        return pos_ >= 0 || !stack_.isEmpty()
    }

    public override func next(): BytesTrie_Entry {
        var pos = pos_
        if (pos < 0) {
            if (stack_.isEmpty()) {
                throw NoSuchElementException()
            }
            let top = stack_.remove(Int64(Int32(stack_.size) - 1))
            var length = Int32(top)
            pos = Int32(shr(top, 32))
            entry_.truncateString(length & 65535)
            length = ushr(length, 16)
            if (length > 1) {
                pos = branchNext(pos, length)
                if (pos < 0) {
                    return entry_
                }
            } else {
                entry_.append(bytes_[Int64(match (0) { case _ => pos++; pos - 1 })])
            }
        }
        if (remainingMatchLength_ >= 0) {
            return truncateAndStop()
        }
        while (true) {
            var node = Int32(bytes_[Int64(match (0) { case _ => pos++; pos - 1 })]) & 255
            if (node >= BytesTrie.kMinValueLead) {
                let isFinal = (node & BytesTrie.kValueIsFinal) != 0
                entry_.value = BytesTrie.readValue(bytes_, pos, shr(node, 1))
                if (isFinal || (maxLength_ > 0 && entry_.length == maxLength_)) {
                    pos_ = -1
                } else {
                    pos_ = BytesTrie.skipValue(pos, node)
                }
                return entry_
            }
            if (maxLength_ > 0 && entry_.length == maxLength_) {
                return truncateAndStop()
            }
            if (node < BytesTrie.kMinLinearMatch) {
                if (node == 0) {
                    node = Int32(bytes_[Int64(match (0) { case _ => pos++; pos - 1 })]) & 255
                }
                pos = branchNext(pos, node + 1)
                if (pos < 0) {
                    return entry_
                }
            } else {
                let length = node - BytesTrie.kMinLinearMatch + 1
                if (maxLength_ > 0 && entry_.length + length > maxLength_) {
                    entry_.append(bytes_, pos, maxLength_ - entry_.length)
                    return truncateAndStop()
                }
                entry_.append(bytes_, pos, length)
                pos += length
            }
        }
    }

    public override func remove(): Unit {
        throw UnsupportedOperationException()
    }

    private func truncateAndStop(): BytesTrie_Entry {
        pos_ = -1
        entry_.value = -1
        return entry_
    }

    private func branchNext(pos: Int32, length: Int32): Int32 {
        var temppos = pos
        var templength = length
        while (templength > BytesTrie.kMaxBranchLinearSubNodeLength) {
            temppos++
            stack_.append((shl(Int64(BytesTrie.skipDelta(bytes_, temppos)), 32)) | (Int64(shl((templength - (shr(templength, 1))), 16))) | Int64(entry_.length))
            templength >>= 1
            temppos = BytesTrie.jumpByDelta(bytes_, temppos)
        }
        let trieByte = bytes_[Int64(match (0) { case _ => temppos++; temppos - 1 })]
        let node = Int32(bytes_[Int64(match (0) { case _ => temppos++; temppos - 1 })]) & 255
        let isFinal = (node & BytesTrie.kValueIsFinal) != 0
        let value = BytesTrie.readValue(bytes_, temppos, shr(node, 1))
        temppos = BytesTrie.skipValue(temppos, node)
        stack_.append((shl(Int64(temppos), 32)) | (Int64(shl((templength - 1), 16))) | Int64(entry_.length))
        entry_.append(trieByte)
        if (isFinal) {
            pos_ = -1
            entry_.value = value
            return -1
        } else {
            return temppos + value
        }
    }

    private var bytes_: Array<UInt8>

    private var pos_: Int32 = 0

    private var initialPos_: Int32 = 0

    private var remainingMatchLength_: Int32 = 0

    private var initialRemainingMatchLength_: Int32 = 0

    private var maxLength_: Int32 = 0

    private var entry_: BytesTrie_Entry

    private var stack_: ArrayList<Int64> = ArrayList<Int64>()
}
