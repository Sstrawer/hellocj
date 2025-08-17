package icu4cj.text


public class CollationElementIterator {
    private var iter_: CollationIterator

    private var rbc_: RuleBasedCollator

    private var otherHalf_: Int32 = 0

    private var dir_: UInt8 = 0

    private var offsets_: UVector32

    private var string_: String

    public static let NULLORDER = -1

    public static let IGNORABLE = 0

    public static func primaryOrder(ce: Int32): Int32 {
        return (ushr(ce, 16)) & 65535
    }

    public static func secondaryOrder(ce: Int32): Int32 {
        return (ushr(ce, 8)) & 255
    }

    public static func tertiaryOrder(ce: Int32): Int32 {
        return ce & 255
    }

    static func getFirstHalf(p: Int64, lower32: Int32): Int32 {
        return (Int32(p) & -65536) | ((shr(lower32, 16)) & 65280) | ((shr(lower32, 8)) & 255)
    }

    static func getSecondHalf(p: Int64, lower32: Int32): Int32 {
        return (shl(Int32(p), 16)) | ((shr(lower32, 8)) & 65280) | (lower32 & 63)
    }

    static func ceNeedsTwoParts(ce: Int64): Bool {
        return (ce & 281470698455103) != 0
    }

    private init(collator: RuleBasedCollator) {
        iter_ = None
        rbc_ = collator
        otherHalf_ = 0
        dir_ = 0
        offsets_ = None
    }

    init(source: String, collator: RuleBasedCollator) {
        this(collator)
        setText(source)
    }

    init(source: CharacterIterator, collator: RuleBasedCollator) {
        this(collator)
        setText(source)
    }

    init(source: UCharacterIterator, collator: RuleBasedCollator) {
        this(collator)
        setText(source)
    }

    public func getOffset(): Int32 {
        if (Int32(dir_) < 0 && offsets_.isSome() && !offsets_.isEmpty()) {
            var i = iter_.getCEsLength()
            if (otherHalf_ != 0) {
                i++
            }
            if (!(i < offsets_.size())) {
                throw AssertionError()
            }
            return offsets_.elementAti(i)
        }
        return iter_.getOffset()
    }

    public func next(): Int32 {
        if (Int32(dir_) > 1) {
            if (otherHalf_ != 0) {
                let oh = otherHalf_
                otherHalf_ = 0
                return oh
            }
        } else if (Int32(dir_) == 1) {
            dir_ = 2
        } else if (Int32(dir_) == 0) {
            dir_ = 2
        } else {
            throw Exception("Illegal change of direction")
        }
        iter_.clearCEsIfNoneRemaining()
        let ce = iter_.nextCE()
        if (ce == Collation.NO_CE) {
            return NULLORDER
        }
        let p = ushr(ce, 32)
        let lower32 = Int32(ce)
        let firstHalf = getFirstHalf(p, lower32)
        let secondHalf = getSecondHalf(p, lower32)
        if (secondHalf != 0) {
            otherHalf_ = secondHalf | 192
        }
        return firstHalf
    }

    public func previous(): Int32 {
        if (Int32(dir_) < 0) {
            if (otherHalf_ != 0) {
                let oh = otherHalf_
                otherHalf_ = 0
                return oh
            }
        } else if (Int32(dir_) == 0) {
            iter_.resetToOffset(Int32(string_.size))
            dir_ = 255
        } else if (Int32(dir_) == 1) {
            dir_ = 255
        } else {
            throw Exception("Illegal change of direction")
        }
        if (offsets_.isNone()) {
            offsets_ = UVector32()
        }
        let limitOffset = if (iter_.getCEsLength() == 0) { iter_.getOffset() } else { 0 }
        let ce = iter_.previousCE(offsets_)
        if (ce == Collation.NO_CE) {
            return NULLORDER
        }
        let p = ushr(ce, 32)
        let lower32 = Int32(ce)
        let firstHalf = getFirstHalf(p, lower32)
        let secondHalf = getSecondHalf(p, lower32)
        if (secondHalf != 0) {
            if (offsets_.isEmpty()) {
                offsets_.addElement(iter_.getOffset())
                offsets_.addElement(limitOffset)
            }
            otherHalf_ = firstHalf
            return secondHalf | 192
        }
        return firstHalf
    }

    public func reset(): Unit {
        iter_.resetToOffset(0)
        otherHalf_ = 0
        dir_ = 0
    }

    public func setOffset(newOffset: Int32): Unit {
        var tempnewOffset = newOffset
        if (0 < tempnewOffset && tempnewOffset < Int32(string_.size)) {
            var offset = tempnewOffset
                offset--
            } while (offset > 0)
            if (offset < tempnewOffset) {
                var lastSafeOffset = offset
                    if (offset <= tempnewOffset) {
                        lastSafeOffset = offset
                    }
                } while (offset < tempnewOffset)
                tempnewOffset = lastSafeOffset
            }
        }
        iter_.resetToOffset(tempnewOffset)
        otherHalf_ = 0
        dir_ = 1
    }

    public func setText(source: String): Unit {
        string_ = source
        let newIter: CollationIterator
        let numeric = rbc_.settings.readOnly().isNumeric()
        if (rbc_.settings.readOnly().dontCheckFCD()) {
            newIter = UTF16CollationIterator(rbc_.data, numeric, string_, 0)
        } else {
            newIter = FCDUTF16CollationIterator(rbc_.data, numeric, string_, 0)
        }
        iter_ = newIter
        otherHalf_ = 0
        dir_ = 0
    }

    public func setText(source: UCharacterIterator): Unit {
        string_ = source.getText()
        let src: UCharacterIterator
        try {
            src = source.clone()
        } catch (e: CloneNotSupportedException) {
            setText(source.getText())
            return
        }
        src.setToStart()
        let newIter: CollationIterator
        let numeric = rbc_.settings.readOnly().isNumeric()
        if (rbc_.settings.readOnly().dontCheckFCD()) {
            newIter = IterCollationIterator(rbc_.data, numeric, src)
        } else {
            newIter = FCDIterCollationIterator(rbc_.data, numeric, src, 0)
        }
        iter_ = newIter
        otherHalf_ = 0
        dir_ = 0
    }

    public func setText(source: CharacterIterator): Unit {
        let src: UCharacterIterator = CharacterIteratorWrapper(source)
        src.setToStart()
        string_ = src.getText()
        let newIter: CollationIterator
        let numeric = rbc_.settings.readOnly().isNumeric()
        if (rbc_.settings.readOnly().dontCheckFCD()) {
            newIter = IterCollationIterator(rbc_.data, numeric, src)
        } else {
            newIter = FCDIterCollationIterator(rbc_.data, numeric, src, 0)
        }
        iter_ = newIter
        otherHalf_ = 0
        dir_ = 0
    }

    static func computeMaxExpansions(data: CollationData): Map<Int32, Int32> {
        let maxExpansions: Map<Int32, Int32> = HashMap<Int32, Int32>()
        let sink = CollationElementIterator_MaxExpSink(maxExpansions)
        ContractionsAndExpansions(None, None, sink, true).forData(data)
        return maxExpansions
    }

    public func getMaxExpansion(ce: Int32): Int32 {
        return getMaxExpansionStatic(rbc_.tailoring.maxExpansions, ce)
    }

    static func getMaxExpansionStatic(maxExpansions: Map<Int32, Int32>, order: Int32): Int32 {
        if (order == 0) {
            return 1
        }
        let max: Int32
        if (maxExpansions.isSome() && (match (0) { case _ => max = maxExpansions.get(order); max }).isSome()) {
            return max
        }
        if ((order & 192) == 192) {
            return 2
        } else {
            return 1
        }
    }

    private func normalizeDir(): UInt8 {
        return if (Int32(dir_) == 1) { 0 } else { dir_ }
    }

    public override func equals(that: Object): Bool {
        if (refEq(that, this)) {
            return true
        }
        if (checkOptionalIs<CollationElementIterator, Object>(that)) {
            let thatceiter = that
            return rbc_.equals(thatceiter.rbc_) && otherHalf_ == thatceiter.otherHalf_ && normalizeDir() == thatceiter.normalizeDir() && string_.equals(thatceiter.string_) && iter_.equals(thatceiter.iter_)
        }
        return false
    }

    public override func hashCode(): Int64 {
        if (!false) {
            throw Exception("hashCode not designed")
        }
        return 42
    }

    
    public func getRuleBasedCollator(): RuleBasedCollator {
        return rbc_
    }
}


class CollationElementIterator_MaxExpSink <: ContractionsAndExpansions_CESink {
    init(h: Map<Int32, Int32>) {
        maxExpansions = h
    }

    public override func handleCE(ce: Int64): Unit { }

    public override func handleExpansion(ces: Array<Int64>, start: Int32, length: Int32): Unit {
        if (length <= 1) {
            return
        }
        var count = 0
        var i = 0
        while (i < length) {
            count += if (CollationElementIterator.ceNeedsTwoParts(ces[Int64(start + i)])) { 2 } else { 1 }
            i++
        }
        let ce = ces[Int64(start + length - 1)]
        let p = ushr(ce, 32)
        let lower32 = Int32(ce)
        var lastHalf = CollationElementIterator.getSecondHalf(p, lower32)
        if (lastHalf == 0) {
            lastHalf = CollationElementIterator.getFirstHalf(p, lower32)
            if (!(lastHalf != 0)) {
                throw AssertionError()
            }
        } else {
            lastHalf |= 192
        }
        let oldCount = maxExpansions.get(lastHalf)
        if (oldCount.isNone() || count > oldCount) {
            maxExpansions.put(lastHalf, count)
        }
    }

    private var maxExpansions: Map<Int32, Int32> = None
}
