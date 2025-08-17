package icu4cj.text


public class Edits {
    private static let MAX_UNCHANGED_LENGTH = 4096

    static let MAX_UNCHANGED = MAX_UNCHANGED_LENGTH - 1

    private static let MAX_SHORT_CHANGE_OLD_LENGTH = 6

    static let MAX_SHORT_CHANGE_NEW_LENGTH = 7

    static let SHORT_CHANGE_NUM_MASK = 511

    static let MAX_SHORT_CHANGE = 28671

    static let LENGTH_IN_1TRAIL = 61

    static let LENGTH_IN_2TRAIL = 62

    private static let STACK_CAPACITY = 100

    private var array: Array<Char>

    private var length: Int32 = 0

    private var delta: Int32 = 0

    private var numChanges: Int32 = 0

    public init() {
        array = Array<Char>(Int64(STACK_CAPACITY)) { _ => '\u{0000}' }
    }

    public func reset(): Unit {
        length = match (0) { case _ => delta = match (0) { case _ => numChanges = 0; numChanges }; delta }
    }

    private func setLastUnit(last: Int32): Unit {
        array[Int64(length - 1)] = Char(last)
    }

    private func lastUnit(): Int32 {
        return if (length > 0) { Int32(UInt32(array[Int64(length - 1)])) } else { 65535 }
    }

    public func addUnchanged(unchangedLength: Int32): Unit {
        var tempunchangedLength = unchangedLength
        if (tempunchangedLength < 0) {
            throw IllegalArgumentException("addUnchanged(" + tempunchangedLength.toString() + "): length must not be negative")
        }
        let last = lastUnit()
        if (last < MAX_UNCHANGED) {
            let remaining = MAX_UNCHANGED - last
            if (remaining >= tempunchangedLength) {
                setLastUnit(last + tempunchangedLength)
                return
            }
            setLastUnit(MAX_UNCHANGED)
            tempunchangedLength -= remaining
        }
        while (tempunchangedLength >= MAX_UNCHANGED_LENGTH) {
            append(MAX_UNCHANGED)
            tempunchangedLength -= MAX_UNCHANGED_LENGTH
        }
        if (tempunchangedLength > 0) {
            append(tempunchangedLength - 1)
        }
    }

    public func addReplace(oldLength: Int32, newLength: Int32): Unit {
        if (oldLength < 0 || newLength < 0) {
            throw IllegalArgumentException("addReplace(" + oldLength.toString() + ", " + newLength.toString() + "): both lengths must be non-negative")
        }
        if (oldLength == 0 && newLength == 0) {
            return
        }
        numChanges++
        let newDelta = newLength - oldLength
        if (newDelta != 0) {
            if ((newDelta > 0 && delta >= 0 && newDelta > (Int32.Max - delta)) || (newDelta < 0 && delta < 0 && newDelta < (Int32.Min - delta))) {
                throw IndexOutOfBoundsException()
            }
            delta += newDelta
        }
        if (0 < oldLength && oldLength <= MAX_SHORT_CHANGE_OLD_LENGTH && newLength <= MAX_SHORT_CHANGE_NEW_LENGTH) {
            let u = (shl(oldLength, 12)) | (shl(newLength, 9))
            let last = lastUnit()
            if (MAX_UNCHANGED < last && last < MAX_SHORT_CHANGE && (last & ) == u && (last & SHORT_CHANGE_NUM_MASK) < SHORT_CHANGE_NUM_MASK) {
                setLastUnit(last + 1)
                return
            }
            append(u)
            return
        }
        var head = 28672
        if (oldLength < LENGTH_IN_1TRAIL && newLength < LENGTH_IN_1TRAIL) {
            head |= shl(oldLength, 6)
            head |= newLength
            append(head)
        } else if ((Int32(array.size) - length) >= 5 || growArray()) {
            var limit = length + 1
            if (oldLength < LENGTH_IN_1TRAIL) {
                head |= shl(oldLength, 6)
            } else if (oldLength <= 32767) {
                head |= shl(LENGTH_IN_1TRAIL, 6)
                array[Int64(match (0) { case _ => limit++; limit - 1 })] = Char(32768 | oldLength)
            } else {
                head |= shl((LENGTH_IN_2TRAIL + (shr(oldLength, 30))), 6)
                array[Int64(match (0) { case _ => limit++; limit - 1 })] = Char(32768 | (shr(oldLength, 15)))
                array[Int64(match (0) { case _ => limit++; limit - 1 })] = Char(32768 | oldLength)
            }
            if (newLength < LENGTH_IN_1TRAIL) {
                head |= newLength
            } else if (newLength <= 32767) {
                head |= LENGTH_IN_1TRAIL
                array[Int64(match (0) { case _ => limit++; limit - 1 })] = Char(32768 | newLength)
            } else {
                head |= LENGTH_IN_2TRAIL + (shr(newLength, 30))
                array[Int64(match (0) { case _ => limit++; limit - 1 })] = Char(32768 | (shr(newLength, 15)))
                array[Int64(match (0) { case _ => limit++; limit - 1 })] = Char(32768 | newLength)
            }
            array[Int64(length)] = Char(head)
            length = limit
        }
    }

    private func append(r: Int32): Unit {
        if (length < Int32(array.size) || growArray()) {
            array[Int64(match (0) { case _ => length++; length - 1 })] = Char(r)
        }
    }

    private func growArray(): Bool {
        let newCapacity: Int32
        if (Int32(array.size) == STACK_CAPACITY) {
            newCapacity = 2000
        } else if (Int32(array.size) == Int32.Max) {
            throw BufferOverflowException()
        } else if (Int32(array.size) >= (Int32.Max / 2)) {
            newCapacity = Int32.Max
        } else {
            newCapacity = 2 * Int32(array.size)
        }
        if ((newCapacity - Int32(array.size)) < 5) {
            throw BufferOverflowException()
        }
        array = array.clone(0.. newCapacity)
        return true
    }

    public func lengthDelta(): Int32 {
        return delta
    }

    public func hasChanges(): Bool {
        return numChanges != 0
    }

    public func numberOfChanges(): Int32 {
        return numChanges
    }

    public func getCoarseChangesIterator(): Edits_Iterator {
        return Edits_Iterator(array, length, true, true)
    }

    public func getCoarseIterator(): Edits_Iterator {
        return Edits_Iterator(array, length, false, true)
    }

    public func getFineChangesIterator(): Edits_Iterator {
        return Edits_Iterator(array, length, true, false)
    }

    public func getFineIterator(): Edits_Iterator {
        return Edits_Iterator(array, length, false, false)
    }

    public func mergeAndAppend(ab: Edits, bc: Edits): Edits {
        let abIter = ab.getFineIterator()
        let bcIter = bc.getFineIterator()
        var abHasNext = true
        var bcHasNext = true
        var aLength = 0
        var ab_bLength = 0
        var bc_bLength = 0
        var cLength = 0
        var pending_aLength = 0
        var pending_cLength = 0
        while (true) {
            if (bc_bLength == 0) {
                if (bcHasNext && (match (0) { case _ => bcHasNext = bcIter.next(); bcHasNext })) {
                    bc_bLength = bcIter.oldLength()
                    cLength = bcIter.newLength()
                    if (bc_bLength == 0) {
                        if (ab_bLength == 0 || !abIter.hasChange()) {
                            addReplace(pending_aLength, pending_cLength + cLength)
                            pending_aLength = match (0) { case _ => pending_cLength = 0; pending_cLength }
                        } else {
                            pending_cLength += cLength
                        }
                        continue
                    }
                }
            }
            if (ab_bLength == 0) {
                if (abHasNext && (match (0) { case _ => abHasNext = abIter.next(); abHasNext })) {
                    aLength = abIter.oldLength()
                    ab_bLength = abIter.newLength()
                    if (ab_bLength == 0) {
                        if (bc_bLength == bcIter.oldLength() || !bcIter.hasChange()) {
                            addReplace(pending_aLength + aLength, pending_cLength)
                            pending_aLength = match (0) { case _ => pending_cLength = 0; pending_cLength }
                        } else {
                            pending_aLength += aLength
                        }
                        continue
                    }
                } else if (bc_bLength == 0) {
                    break
                } else {
                    throw IllegalArgumentException("The ab output string is shorter than the bc input string.")
                }
            }
            if (bc_bLength == 0) {
                throw IllegalArgumentException("The bc input string is shorter than the ab output string.")
            }
            if (!abIter.hasChange() && !bcIter.hasChange()) {
                if (pending_aLength != 0 || pending_cLength != 0) {
                    addReplace(pending_aLength, pending_cLength)
                    pending_aLength = match (0) { case _ => pending_cLength = 0; pending_cLength }
                }
                let unchangedLength = if (aLength <= cLength) { aLength } else { cLength }
                addUnchanged(unchangedLength)
                ab_bLength = aLength -= unchangedLength
                bc_bLength = cLength -= unchangedLength
                continue
            }
            if (!abIter.hasChange() && bcIter.hasChange()) {
                if (ab_bLength >= bc_bLength) {
                    addReplace(pending_aLength + bc_bLength, pending_cLength + cLength)
                    pending_aLength = match (0) { case _ => pending_cLength = 0; pending_cLength }
                    aLength = ab_bLength -= bc_bLength
                    bc_bLength = 0
                    continue
                }
            } else if (abIter.hasChange() && !bcIter.hasChange()) {
                if (ab_bLength <= bc_bLength) {
                    addReplace(pending_aLength + aLength, pending_cLength + ab_bLength)
                    pending_aLength = match (0) { case _ => pending_cLength = 0; pending_cLength }
                    cLength = bc_bLength -= ab_bLength
                    ab_bLength = 0
                    continue
                }
            } else {
                if (ab_bLength == bc_bLength) {
                    addReplace(pending_aLength + aLength, pending_cLength + cLength)
                    pending_aLength = match (0) { case _ => pending_cLength = 0; pending_cLength }
                    ab_bLength = match (0) { case _ => bc_bLength = 0; bc_bLength }
                    continue
                }
            }
            pending_aLength += aLength
            pending_cLength += cLength
            if (ab_bLength < bc_bLength) {
                bc_bLength -= ab_bLength
                cLength = match (0) { case _ => ab_bLength = 0; ab_bLength }
            } else {
                ab_bLength -= bc_bLength
                aLength = match (0) { case _ => bc_bLength = 0; bc_bLength }
            }
        }
        if (pending_aLength != 0 || pending_cLength != 0) {
            addReplace(pending_aLength, pending_cLength)
        }
        return this
    }
}


public class Edits_Iterator {
    private let array: Array<Char>

    private var index: Int32 = 0

    private let length: Int32

    private var remaining: Int32 = 0

    private let onlyChanges_: Bool

    private let coarse: Bool

    private var dir: Int32 = 0

    private var changed: Bool = false

    private var oldLength_: Int32 = 0

    private var newLength_: Int32 = 0

    private var srcIndex: Int32 = 0

    private var replIndex: Int32 = 0

    private var destIndex: Int32 = 0

    init(a: Array<Char>, len: Int32, oc: Bool, crs: Bool) {
        array = a
        length = len
        onlyChanges_ = oc
        coarse = crs
    }

    private func readLength(head: Int32): Int32 {
        if (head < Edits.LENGTH_IN_1TRAIL) {
            return head
        } else if (head < Edits.LENGTH_IN_2TRAIL) {
            if (!(index < length)) {
                throw AssertionError()
            }
            if (!(Int32(UInt32(array[Int64(index)])) >= 32768)) {
                throw AssertionError()
            }
            return Int32(UInt32(array[Int64(match (0) { case _ => index++; index - 1 })])) & 32767
        } else {
            if (!((index + 2) <= length)) {
                throw AssertionError()
            }
            if (!(Int32(UInt32(array[Int64(index)])) >= 32768)) {
                throw AssertionError()
            }
            if (!(Int32(UInt32(array[Int64(index + 1)])) >= 32768)) {
                throw AssertionError()
            }
            let len = (shl((head & 1), 30)) | (shl((Int32(UInt32(array[Int64(index)])) & 32767), 15)) | (Int32(UInt32(array[Int64(index + 1)])) & 32767)
            index += 2
            return len
        }
    }

    private func updateNextIndexes(): Unit {
        srcIndex += oldLength_
        if (changed) {
            replIndex += newLength_
        }
        destIndex += newLength_
    }

    private func updatePreviousIndexes(): Unit {
        srcIndex -= oldLength_
        if (changed) {
            replIndex -= newLength_
        }
        destIndex -= newLength_
    }

    private func noNext(): Bool {
        dir = 0
        changed = false
        oldLength_ = match (0) { case _ => newLength_ = 0; newLength_ }
        return false
    }

    public func next(): Bool {
        return next(onlyChanges_)
    }

    private func next(onlyChanges: Bool): Bool {
        if (dir > 0) {
            updateNextIndexes()
        } else {
            if (dir < 0) {
                if (remaining > 0) {
                    index++
                    dir = 1
                    return true
                }
            }
            dir = 1
        }
        if (remaining >= 1) {
            if (remaining > 1) {
                remaining--
                return true
            }
            remaining = 0
        }
        if (index >= length) {
            return noNext()
        }
        var u = Int32(UInt32(array[Int64(match (0) { case _ => index++; index - 1 })]))
        if (u <= Edits.MAX_UNCHANGED) {
            changed = false
            oldLength_ = u + 1
            while (index < length && (match (0) { case _ => u = Int32(UInt32(array[Int64(index)])); u }) <= Edits.MAX_UNCHANGED) {
                index++
                oldLength_ += u + 1
            }
            newLength_ = oldLength_
            if (onlyChanges) {
                updateNextIndexes()
                if (index >= length) {
                    return noNext()
                }
                index++
            } else {
                return true
            }
        }
        changed = true
        if (u <= Edits.MAX_SHORT_CHANGE) {
            let oldLen = shr(u, 12)
            let newLen = (shr(u, 9)) & Edits.MAX_SHORT_CHANGE_NEW_LENGTH
            let num = (u & Edits.SHORT_CHANGE_NUM_MASK) + 1
            if (coarse) {
                oldLength_ = num * oldLen
                newLength_ = num * newLen
            } else {
                oldLength_ = oldLen
                newLength_ = newLen
                if (num > 1) {
                    remaining = num
                }
                return true
            }
        } else {
            if (!(u <= 32767)) {
                throw AssertionError()
            }
            oldLength_ = readLength((shr(u, 6)) & 63)
            newLength_ = readLength(u & 63)
            if (!coarse) {
                return true
            }
        }
        while (index < length && (match (0) { case _ => u = Int32(UInt32(array[Int64(index)])); u }) > Edits.MAX_UNCHANGED) {
            index++
            if (u <= Edits.MAX_SHORT_CHANGE) {
                let num = (u & Edits.SHORT_CHANGE_NUM_MASK) + 1
                oldLength_ += (shr(u, 12)) * num
                newLength_ += ((shr(u, 9)) & Edits.MAX_SHORT_CHANGE_NEW_LENGTH) * num
            } else {
                if (!(u <= 32767)) {
                    throw AssertionError()
                }
                oldLength_ += readLength((shr(u, 6)) & 63)
                newLength_ += readLength(u & 63)
            }
        }
        return true
    }

    private func previous(): Bool {
        if (dir >= 0) {
            if (dir > 0) {
                if (remaining > 0) {
                    index--
                    dir = -1
                    return true
                }
                updateNextIndexes()
            }
            dir = -1
        }
        if (remaining > 0) {
            let u = Int32(UInt32(array[Int64(index)]))
            if (!(Edits.MAX_UNCHANGED < u && u <= Edits.MAX_SHORT_CHANGE)) {
                throw AssertionError()
            }
            if (remaining <= (u & Edits.SHORT_CHANGE_NUM_MASK)) {
                remaining++
                updatePreviousIndexes()
                return true
            }
            remaining = 0
        }
        if (index <= 0) {
            return noNext()
        }
        var u = Int32(UInt32(array[Int64(match (0) { case _ => index--; index })]))
        if (u <= Edits.MAX_UNCHANGED) {
            changed = false
            oldLength_ = u + 1
            while (index > 0 && (match (0) { case _ => u = Int32(UInt32(array[Int64(index - 1)])); u }) <= Edits.MAX_UNCHANGED) {
                index--
                oldLength_ += u + 1
            }
            newLength_ = oldLength_
            updatePreviousIndexes()
            return true
        }
        changed = true
        if (u <= Edits.MAX_SHORT_CHANGE) {
            let oldLen = shr(u, 12)
            let newLen = (shr(u, 9)) & Edits.MAX_SHORT_CHANGE_NEW_LENGTH
            let num = (u & Edits.SHORT_CHANGE_NUM_MASK) + 1
            if (coarse) {
                oldLength_ = num * oldLen
                newLength_ = num * newLen
            } else {
                oldLength_ = oldLen
                newLength_ = newLen
                if (num > 1) {
                    remaining = 1
                }
                updatePreviousIndexes()
                return true
            }
        } else {
            if (u <= 32767) {
                oldLength_ = readLength((shr(u, 6)) & 63)
                newLength_ = readLength(u & 63)
            } else {
                if (!(index > 0)) {
                    throw AssertionError()
                }
                while ((match (0) { case _ => u = Int32(UInt32(array[Int64(match (0) { case _ => index--; index })])); u }) > 32767) { }
                if (!(u > Edits.MAX_SHORT_CHANGE)) {
                    throw AssertionError()
                }
                let headIndex = match (0) { case _ => index++; index - 1 }
                oldLength_ = readLength((shr(u, 6)) & 63)
                newLength_ = readLength(u & 63)
                index = headIndex
            }
            if (!coarse) {
                updatePreviousIndexes()
                return true
            }
        }
        while (index > 0 && (match (0) { case _ => u = Int32(UInt32(array[Int64(index - 1)])); u }) > Edits.MAX_UNCHANGED) {
            index--
            if (u <= Edits.MAX_SHORT_CHANGE) {
                let num = (u & Edits.SHORT_CHANGE_NUM_MASK) + 1
                oldLength_ += (shr(u, 12)) * num
                newLength_ += ((shr(u, 9)) & Edits.MAX_SHORT_CHANGE_NEW_LENGTH) * num
            } else if (u <= 32767) {
                let headIndex = match (0) { case _ => index++; index - 1 }
                oldLength_ += readLength((shr(u, 6)) & 63)
                newLength_ += readLength(u & 63)
                index = headIndex
            }
        }
        updatePreviousIndexes()
        return true
    }

    public func findSourceIndex(i: Int32): Bool {
        return findIndex(i, true) == 0
    }

    public func findDestinationIndex(i: Int32): Bool {
        return findIndex(i, false) == 0
    }

    private func findIndex(i: Int32, findSource: Bool): Int32 {
        if (i < 0) {
            return -1
        }
        var spanStart: Int32 = 0
        var spanLength: Int32 = 0
        if (findSource) {
            spanStart = srcIndex
            spanLength = oldLength_
        } else {
            spanStart = destIndex
            spanLength = newLength_
        }
        if (i < spanStart) {
            if (i >= (spanStart / 2)) {
                while (true) {
                    let hasPrevious = previous()
                    if (!(hasPrevious)) {
                        throw AssertionError()
                    }
                    spanStart = if (findSource) { srcIndex } else { destIndex }
                    if (i >= spanStart) {
                        return 0
                    }
                    if (remaining > 0) {
                        spanLength = if (findSource) { oldLength_ } else { newLength_ }
                        let u = Int32(UInt32(array[Int64(index)]))
                        if (!(Edits.MAX_UNCHANGED < u && u <= Edits.MAX_SHORT_CHANGE)) {
                            throw AssertionError()
                        }
                        let num = (u & Edits.SHORT_CHANGE_NUM_MASK) + 1 - remaining
                        let len = num * spanLength
                        if (i >= (spanStart - len)) {
                            let n = ((spanStart - i - 1) / spanLength) + 1
                            srcIndex -= n * oldLength_
                            replIndex -= n * newLength_
                            destIndex -= n * newLength_
                            remaining += n
                            return 0
                        }
                        srcIndex -= num * oldLength_
                        replIndex -= num * newLength_
                        destIndex -= num * newLength_
                        remaining = 0
                    }
                }
            }
            dir = 0
            index = match (0) { case _ => remaining = match (0) { case _ => oldLength_ = match (0) { case _ => newLength_ = match (0) { case _ => srcIndex = match (0) { case _ => replIndex = match (0) { case _ => destIndex = 0; destIndex }; replIndex }; srcIndex }; newLength_ }; oldLength_ }; remaining }
        } else if (i < (spanStart + spanLength)) {
            return 0
        }
        while (next(false)) {
            if (findSource) {
                spanStart = srcIndex
                spanLength = oldLength_
            } else {
                spanStart = destIndex
                spanLength = newLength_
            }
            if (i < (spanStart + spanLength)) {
                return 0
            }
            if (remaining > 1) {
                let len = remaining * spanLength
                if (i < (spanStart + len)) {
                    let n = (i - spanStart) / spanLength
                    srcIndex += n * oldLength_
                    replIndex += n * newLength_
                    destIndex += n * newLength_
                    remaining -= n
                    return 0
                }
                oldLength_ *= remaining
                newLength_ *= remaining
                remaining = 0
            }
        }
        return 1
    }

    public func destinationIndexFromSourceIndex(i: Int32): Int32 {
        let `where` = findIndex(i, true)
        if (`where` < 0) {
            return 0
        }
        if (`where` > 0 || i == srcIndex) {
            return destIndex
        }
        if (changed) {
            return destIndex + newLength_
        } else {
            return destIndex + (i - srcIndex)
        }
    }

    public func sourceIndexFromDestinationIndex(i: Int32): Int32 {
        let `where` = findIndex(i, false)
        if (`where` < 0) {
            return 0
        }
        if (`where` > 0 || i == destIndex) {
            return srcIndex
        }
        if (changed) {
            return srcIndex + oldLength_
        } else {
            return srcIndex + (i - destIndex)
        }
    }

    public func hasChange(): Bool {
        return changed
    }

    public func oldLength(): Int32 {
        return oldLength_
    }

    public func newLength(): Int32 {
        return newLength_
    }

    public func sourceIndex(): Int32 {
        return srcIndex
    }

    public func replacementIndex(): Int32 {
        return replIndex
    }

    public func destinationIndex(): Int32 {
        return destIndex
    }

    public override func toString(): String {
        let sb = StringBuilder()
        sb.append(toString(super))
        sb.append("{ src[")
        sb.append(srcIndex)
        sb.append("..")
        sb.append(srcIndex + oldLength_)
        if (changed) {
            sb.append("] \u{21dd} dest[")
        } else {
            sb.append("] \u{2261} dest[")
        }
        sb.append(destIndex)
        sb.append("..")
        sb.append(destIndex + newLength_)
        if (changed) {
            sb.append("], repl[")
            sb.append(replIndex)
            sb.append("..")
            sb.append(replIndex + newLength_)
            sb.append("] }")
        } else {
            sb.append("] (no-change) }")
        }
        return sb.toString()
    }
}
