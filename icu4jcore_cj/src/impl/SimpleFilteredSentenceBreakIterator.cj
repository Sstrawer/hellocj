package icu4cj.impl


public class SimpleFilteredSentenceBreakIterator <: BreakIterator {
    private var delegate: BreakIterator

    private var text: UCharacterIterator

    private var backwardsTrie: CharsTrie

    private var forwardsPartialTrie: CharsTrie

    public init(adoptBreakIterator: BreakIterator, forwardsPartialTrie: CharsTrie, backwardsTrie: CharsTrie) {
        super()
        this.delegate = adoptBreakIterator
        this.forwardsPartialTrie = forwardsPartialTrie
        this.backwardsTrie = backwardsTrie
    }

    private func resetState(): Unit {
        text = UCharacterIterator.getInstance(delegate.getText().clone())
    }

    private func breakExceptionAt(n: Int32): Bool {
        var bestPosn = -1
        var bestValue = -1
        text.setIndex(n)
        backwardsTrie.reset()
        var uch: Int32 = 0
        if ((match (0) { case _ => uch = text.previousCodePoint(); uch }) == Int32(UInt32(' '))) { } else {
            uch = text.nextCodePoint()
        }
        while ((match (0) { case _ => uch = text.previousCodePoint(); uch }) >= 0) {
            let r = backwardsTrie.nextForCodePoint(uch)
            if (r.hasValue()) {
                bestPosn = text.getIndex()
                bestValue = backwardsTrie.getValue()
            }
            if (!r.hasNext()) {
                break
            }
        }
        backwardsTrie.reset()
        if (bestPosn >= 0) {
            if (bestValue == SimpleFilteredSentenceBreakIterator_Builder.MATCH) {
                return true
            } else if (bestValue == SimpleFilteredSentenceBreakIterator_Builder.PARTIAL && forwardsPartialTrie.isSome()) {
                forwardsPartialTrie.reset()
                var rfwd: BytesTrie_Result = BytesTrie_Result.INTERMEDIATE_VALUE
                text.setIndex(bestPosn)
                while ((match (0) { case _ => uch = text.nextCodePoint(); uch }) != BreakIterator.DONE && ((match (0) { case _ => rfwd = forwardsPartialTrie.nextForCodePoint(uch); rfwd }).hasNext())) { }
                forwardsPartialTrie.reset()
                if (rfwd.matches()) {
                    return true
                }
            }
        }
        return false
    }

    private func internalNext(n: Int32): Int32 {
        var tempn = n
        if (tempn == BreakIterator.DONE || backwardsTrie.isNone()) {
            return tempn
        }
        resetState()
        let textLen = text.getLength()
        while (tempn != BreakIterator.DONE && tempn != textLen) {
            if (breakExceptionAt(tempn)) {
                tempn = delegate.next()
            } else {
                return tempn
            }
        }
        return tempn
    }

    private func internalPrev(n: Int32): Int32 {
        var tempn = n
        if (tempn == 0 || tempn == BreakIterator.DONE || backwardsTrie.isNone()) {
            return tempn
        }
        resetState()
        while (tempn != BreakIterator.DONE && tempn != 0) {
            if (breakExceptionAt(tempn)) {
                tempn = delegate.previous()
            } else {
                return tempn
            }
        }
        return tempn
    }

    public override func equals(obj: Object): Bool {
        if (obj.isNone()) {
            return false
        }
        if (refEq(this, obj)) {
            return true
        }
        if (!refEq(TypeInfo.of(this), TypeInfo.of(obj))) {
            return false
        }
        let other = obj
        return refEq(delegate, other.delegate) && refEq(text, other.text) && refEq(backwardsTrie, other.backwardsTrie) && refEq(forwardsPartialTrie, other.forwardsPartialTrie)
    }

    public override func hashCode(): Int64 {
        return Int64((Int32(forwardsPartialTrie.toString()))
    }

    public override func clone(): Object {
        let other = super.clone()
        try {
            if (delegate.isSome()) {
                other.delegate = delegate.clone()
            }
            if (text.isSome()) {
                other.text = text.clone()
            }
            if (backwardsTrie.isSome()) {
                other.backwardsTrie = backwardsTrie.clone()
            }
            if (forwardsPartialTrie.isSome()) {
                other.forwardsPartialTrie = forwardsPartialTrie.clone()
            }
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException(e as Exception)
        }
        return other
    }

    public override func first(): Int32 {
        return delegate.first()
    }

    public override func preceding(offset: Int32): Int32 {
        return internalPrev(delegate.preceding(offset))
    }

    public override func previous(): Int32 {
        return internalPrev(delegate.previous())
    }

    public override func current(): Int32 {
        return delegate.current()
    }

    public override func isBoundary(offset: Int32): Bool {
        if (!delegate.isBoundary(offset)) {
            return false
        }
        if (backwardsTrie.isNone()) {
            return true
        }
        resetState()
        return !breakExceptionAt(offset)
    }

    public override func next(): Int32 {
        return internalNext(delegate.next())
    }

    public override func next(n: Int32): Int32 {
        return internalNext(delegate.next(n))
    }

    public override func following(offset: Int32): Int32 {
        return internalNext(delegate.following(offset))
    }

    public override func last(): Int32 {
        return delegate.last()
    }

    public override func getText(): CharacterIterator {
        return delegate.getText()
    }

    public override func setText(newText: CharacterIterator): Unit {
        delegate.setText(newText)
    }
}


public class SimpleFilteredSentenceBreakIterator_Builder <: FilteredBreakIteratorBuilder {
    private var filterSet: HashSet<String> = HashSet<String>()

    static let PARTIAL = (shl(1, 0))

    static let MATCH = (shl(1, 1))

    static let SuppressInReverse = (shl(1, 0))

    static let AddToForward = (shl(1, 1))

    public init(loc: Locale) {
        this(ULocale.forLocale(loc))
    }

    public init(loc: ULocale) {
        super()
        let rb = ICUResourceBundle.getBundleInstance(ICUData.ICU_BRKITR_BASE_NAME, loc, ICUResourceBundle_OpenType.LOCALE_ROOT)
        let breaks = rb.findWithFallback("exceptions/SentenceBreak")
        if (breaks.isSome()) {
            var index = 0
            let size = breaks.getSize()
            while (index < size) {
                let b = breaks.get(index)
                let br = b.getString()
                filterSet.put(br)
                index++
            }
        }
    }

    public init() {
        super()
    }

    public override func suppressBreakAfter(str: String): Bool {
        return filterSet.put(str)
    }

    public override func unsuppressBreakAfter(str: String): Bool {
        return filterSet.remove(str)
    }

    public override func wrapIteratorWithFilter(adoptBreakIterator: BreakIterator): BreakIterator {
        if (filterSet.isEmpty()) {
            return adoptBreakIterator
        }
        let builder = CharsTrieBuilder()
        let builder2 = CharsTrieBuilder()
        var revCount = 0
        var fwdCount = 0
        let subCount = Int32(filterSet.size)
        let ustrs = Array<String>(Int64(subCount))
        let partials = Array<Int32>(Int64(subCount)) { _ => 0 }
        var backwardsTrie: CharsTrie
        var forwardsPartialTrie: CharsTrie
        var i = 0
        for (s in filterSet) {
            ustrs[Int64(i)] = s
            partials[Int64(i)] = 0
            i++
        }
        i = 0
        while (i < subCount) {
            let thisStr: String = toString(ustrs[Int64(i)])
            let nn = indexOfWrap(thisStr.indexOf(UInt8(UInt32('.'))))
            if (nn > -1 && (nn + 1) != Int32(thisStr.size)) {
                var sameAs = -1
                var j = 0
                while (j < subCount) {
                    if (j == i) {
                        continue
                    }
                    if (thisStr.regionMatches(0, toString(ustrs[Int64(j)]), 0, nn + 1)) {
                        if (partials[Int64(j)] == 0) {
                            partials[Int64(j)] = SuppressInReverse | AddToForward
                        } else if ((partials[Int64(j)] & SuppressInReverse) != 0) {
                            sameAs = j
                        }
                    }
                    j++
                }
                if ((sameAs == -1) && (partials[Int64(i)] == 0)) {
                    let prefix = StringBuilder(thisStr[0..Int64(nn + 1)])
                    prefix.reverse()
                    builder.add(prefix.toString(), PARTIAL)
                    revCount++
                    partials[Int64(i)] = SuppressInReverse | AddToForward
                }
            }
            i++
        }
        i = 0
        while (i < subCount) {
            let thisStr: String = toString(ustrs[Int64(i)])
            if (partials[Int64(i)] == 0) {
                let reversed: StringBuilder = StringBuilder(thisStr).reverse()
                builder.add(reversed.asString(), MATCH)
                revCount++
            } else {
                builder2.add(thisStr, MATCH)
                fwdCount++
            }
            i++
        }
        if (revCount > 0) {
            backwardsTrie = builder.build(StringTrieBuilder_Option.FAST)
        }
        if (fwdCount > 0) {
            forwardsPartialTrie = builder2.build(StringTrieBuilder_Option.FAST)
        }
        return SimpleFilteredSentenceBreakIterator(adoptBreakIterator, forwardsPartialTrie, backwardsTrie)
    }
}
