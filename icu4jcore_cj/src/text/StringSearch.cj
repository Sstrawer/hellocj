package icu4cj.text

public class StringSearch <: SearchIterator {
    var pattern_: StringSearch_Pattern

    private var collator_: RuleBasedCollator

    private var textIter_: CollationElementIterator

    var textProcessedIter_: StringSearch_CollationPCE

    private var utilIter_: CollationElementIterator

    private var nfd_: Normalizer2

    private var strength_: Int32 = 0

    var ceMask_: Int32 = 0

    var variableTop_: Int32 = 0

    private var toShift_: Bool = false

    public init(pattern: String, target: CharacterIterator, collator: RuleBasedCollator, breakiter: BreakIterator) {
        super(target, breakiter)
        if (collator.getNumericCollation()) {
            throw UnsupportedOperationException("Numeric collation is not supported by StringSearch")
        }
        collator_ = collator
        strength_ = collator.getStrength()
        ceMask_ = getMask(strength_)
        toShift_ = collator.isAlternateHandlingShifted()
        variableTop_ = collator.getVariableTop()
        nfd_ = Normalizer2.getNFDInstance()
        pattern_ = StringSearch_Pattern(pattern)
        search_.setMatchedLength(0)
        search_.matchedIndex_ = DONE
        utilIter_ = None
        textIter_ = CollationElementIterator(target, collator)
        textProcessedIter_ = None
        let collLocale = collator.getLocale(ULocale.VALID_LOCALE)
        search_.internalBreakIter_ = BreakIterator.getCharacterInstance(if (collLocale.isNone()) { ULocale.ROOT } else { collLocale })
        search_.internalBreakIter_.setText(target.clone())
        initialize()
    }

    public init(pattern: String, target: CharacterIterator, collator: RuleBasedCollator) {
        this(pattern, target, collator, None)
    }

    public init(pattern: String, target: CharacterIterator, locale: Locale) {
        this(pattern, target, ULocale.forLocale(locale))
    }

    public init(pattern: String, target: CharacterIterator, locale: ULocale) {
        this(pattern, target, Collator.getInstance(locale), None)
    }

    public init(pattern: String, target: String) {
        this(pattern, StringCharacterIterator(target), Collator.getInstance(), None)
    }

    public func getCollator(): RuleBasedCollator {
        return collator_
    }

    public func setCollator(collator: RuleBasedCollator): Unit {
        if (collator.isNone()) {
            throw IllegalArgumentException("Collator can not be null")
        }
        collator_ = collator
        ceMask_ = getMask(collator_.getStrength())
        let collLocale = collator.getLocale(ULocale.VALID_LOCALE)
        search_.internalBreakIter_ = BreakIterator.getCharacterInstance(if (collLocale.isNone()) { ULocale.ROOT } else { collLocale })
        search_.internalBreakIter_.setText(search_.text().clone())
        toShift_ = collator.isAlternateHandlingShifted()
        variableTop_ = collator.getVariableTop()
        textIter_ = CollationElementIterator(pattern_.text_, collator)
        utilIter_ = CollationElementIterator(pattern_.text_, collator)
        initialize()
    }

    public func getPattern(): String {
        return pattern_.text_
    }

    public func setPattern(pattern: String): Unit {
        if (pattern.isNone() || Int32(pattern.size) <= 0) {
            throw IllegalArgumentException("Pattern to search for can not be null or of length 0")
        }
        pattern_.text_ = pattern
        initialize()
    }

    public func isCanonical(): Bool {
        return search_.isCanonicalMatch_
    }

    public func setCanonical(allowCanonical: Bool): Unit {
        search_.isCanonicalMatch_ = allowCanonical
    }

    public override func setTarget(text: CharacterIterator): Unit {
        super.setTarget(text)
        textIter_.setText(text)
    }

    public override func getIndex(): Int32 {
        let result = textIter_.getOffset()
        if (isOutOfBounds(search_.beginIndex(), search_.endIndex(), result)) {
            return DONE
        }
        return result
    }

    public override func setIndex(position: Int32): Unit {
        super.setIndex(position)
        textIter_.setOffset(position)
    }

    public override func reset(): Unit {
        var sameCollAttribute = true
        let ceMask: Int32
        let shift: Bool
        let varTop: Int32
        let newStrength = collator_.getStrength()
        if ((strength_ < Collator.QUATERNARY && newStrength >= Collator.QUATERNARY) || (strength_ >= Collator.QUATERNARY && newStrength < Collator.QUATERNARY)) {
            sameCollAttribute = false
        }
        strength_ = collator_.getStrength()
        ceMask = getMask(strength_)
        if (ceMask_ != ceMask) {
            ceMask_ = ceMask
            sameCollAttribute = false
        }
        shift = collator_.isAlternateHandlingShifted()
        if (toShift_ != shift) {
            toShift_ = shift
            sameCollAttribute = false
        }
        varTop = collator_.getVariableTop()
        if (variableTop_ != varTop) {
            variableTop_ = varTop
            sameCollAttribute = false
        }
        if (!sameCollAttribute) {
            initialize()
        }
        textIter_.setText(search_.text())
        search_.setMatchedLength(0)
        search_.matchedIndex_ = DONE
        search_.isOverlap_ = false
        search_.isCanonicalMatch_ = false
        search_.elementComparisonType_ = SearchIterator_ElementComparisonType.STANDARD_ELEMENT_COMPARISON
        search_.isForwardSearching_ = true
        search_.reset_ = true
    }

    override protected func handleNext(position: Int32): Int32 {
        if (pattern_.CELength_ == 0) {
            search_.matchedIndex_ = if (search_.matchedIndex_ == DONE) { getIndex() } else { search_.matchedIndex_ + 1 }
            search_.setMatchedLength(0)
            textIter_.setOffset(search_.matchedIndex_)
            if (search_.matchedIndex_ == search_.endIndex()) {
                search_.matchedIndex_ = DONE
            }
        } else {
            if (search_.matchedLength() <= 0) {
                search_.matchedIndex_ = position - 1
            }
            textIter_.setOffset(position)
            if (search_.isCanonicalMatch_) {
                handleNextCanonical()
            } else {
                handleNextExact()
            }
            if (search_.matchedIndex_ == DONE) {
                textIter_.setOffset(search_.endIndex())
            } else {
                textIter_.setOffset(search_.matchedIndex_)
            }
            return search_.matchedIndex_
        }
        return DONE
    }

    override protected func handlePrevious(position: Int32): Int32 {
        if (pattern_.CELength_ == 0) {
            search_.matchedIndex_ = if (search_.matchedIndex_ == DONE) { getIndex() } else { search_.matchedIndex_ }
            if (search_.matchedIndex_ == search_.beginIndex()) {
                setMatchNotFound()
            } else {
                search_.matchedIndex_--
                textIter_.setOffset(search_.matchedIndex_)
                search_.setMatchedLength(0)
            }
        } else {
            textIter_.setOffset(position)
            if (search_.isCanonicalMatch_) {
                handlePreviousCanonical()
            } else {
                handlePreviousExact()
            }
        }
        return search_.matchedIndex_
    }

    private static let INITIAL_ARRAY_SIZE_ = 256

    private static let PRIMARYORDERMASK = -65536

    private static let SECONDARYORDERMASK = 65280

    private static let TERTIARYORDERMASK = 255

    private static func getMask(strength: Int32): Int32 {
        match (strength) {
            case 0 => return PRIMARYORDERMASK
            case 1 => return SECONDARYORDERMASK | PRIMARYORDERMASK
            case _ => return TERTIARYORDERMASK | SECONDARYORDERMASK | PRIMARYORDERMASK
        }
    }

    private func getCE(sourcece: Int32): Int32 {
        var tempsourcece = sourcece
        tempsourcece &= ceMask_
        if (toShift_) {
            if (variableTop_ > tempsourcece) {
                if (strength_ >= Collator.QUATERNARY) {
                    tempsourcece &= PRIMARYORDERMASK
                } else {
                    tempsourcece = CollationElementIterator.IGNORABLE
                }
            }
        } else if (strength_ >= Collator.QUATERNARY && tempsourcece == CollationElementIterator.IGNORABLE) {
            tempsourcece = 65535
        }
        return tempsourcece
    }

    private static func addToIntArray(destination: Array<Int32>, offset: Int32, value: Int32, increments: Int32): Array<Int32> {
        var tempdestination = destination
        var newlength = Int32(tempdestination.size)
        if (offset + 1 == newlength) {
            newlength += increments
            let temp = Array<Int32>(Int64(newlength)) { _ => 0 }
            arraycopy(tempdestination, 0, temp, 0, Int64(offset))
            tempdestination = temp
        }
        tempdestination[Int64(offset)] = value
        return tempdestination
    }

    private static func addToLongArray(destination: Array<Int64>, offset: Int32, destinationlength: Int32, value: Int64, increments: Int32): Array<Int64> {
        var tempdestination = destination
        var newlength = destinationlength
        if (offset + 1 == newlength) {
            newlength += increments
            let temp = Array<Int64>(Int64(newlength)) { _ => 0 }
            arraycopy(tempdestination, 0, temp, 0, Int64(offset))
            tempdestination = temp
        }
        tempdestination[Int64(offset)] = value
        return tempdestination
    }

    private func initializePatternCETable(): Int32 {
        var cetable: Array<Int32> = Array<Int32>(Int64(INITIAL_ARRAY_SIZE_)) { _ => 0 }
        let patternlength = Int32(pattern_.text_.size)
        var coleiter = utilIter_
        if (coleiter.isNone()) {
            coleiter = CollationElementIterator(pattern_.text_, collator_)
            utilIter_ = coleiter
        } else {
            coleiter.setText(pattern_.text_)
        }
        var offset = 0
        var result = 0
        var ce: Int32 = 0
        while ((match (0) { case _ => ce = coleiter.next(); ce }) != CollationElementIterator.NULLORDER) {
            let newce = getCE(ce)
            if (newce != CollationElementIterator.IGNORABLE) {
                let temp = addToIntArray(cetable, offset, newce, patternlength - coleiter.getOffset() + 1)
                offset++
                cetable = temp
            }
            result += (coleiter.getMaxExpansion(ce) - 1)
        }
        cetable[Int64(offset)] = 0
        pattern_.CE_ = cetable
        pattern_.CELength_ = offset
        return result
    }

    private func initializePatternPCETable(): Int32 {
        var pcetable: Array<Int64> = Array<Int64>(Int64(INITIAL_ARRAY_SIZE_)) { _ => 0 }
        let pcetablesize = Int32(pcetable.size)
        let patternlength = Int32(pattern_.text_.size)
        var coleiter = utilIter_
        if (coleiter.isNone()) {
            coleiter = CollationElementIterator(pattern_.text_, collator_)
            utilIter_ = coleiter
        } else {
            coleiter.setText(pattern_.text_)
        }
        var offset = 0
        let result = 0
        var pce: Int64 = 0
        let iter = StringSearch_CollationPCE(coleiter)
        while ((match (0) { case _ => pce = iter.nextProcessed(None); pce }) != StringSearch_CollationPCE.PROCESSED_NULLORDER) {
            let temp = addToLongArray(pcetable, offset, pcetablesize, pce, patternlength - coleiter.getOffset() + 1)
            offset++
            pcetable = temp
        }
        pcetable[Int64(offset)] = 0
        pattern_.PCE_ = pcetable
        pattern_.PCELength_ = offset
        return result
    }

    private func initializePattern(): Int32 {
        pattern_.PCE_ = None
        return initializePatternCETable()
    }

    private func initialize(): Unit {
        initializePattern()
    }

    
    override protected func setMatchNotFound(): Unit {
        super.setMatchNotFound()
        if (search_.isForwardSearching_) {
            textIter_.setOffset(search_.text().getEndIndex())
        } else {
            textIter_.setOffset(0)
        }
    }

    private static func isOutOfBounds(textstart: Int32, textlimit: Int32, offset: Int32): Bool {
        return offset < textstart || offset > textlimit
    }

    private func checkIdentical(start: Int32, end: Int32): Bool {
        if (strength_ != Collator.IDENTICAL) {
            return true
        }
        var textstr = getString(targetText, start, end - start)
        if (refEq(Normalizer.quickCheck(textstr, Normalizer.NFD, 0), Normalizer.NO)) {
            textstr = Normalizer.decompose(textstr, false)
        }
        var patternstr = pattern_.text_
        if (refEq(Normalizer.quickCheck(patternstr, Normalizer.NFD, 0), Normalizer.NO)) {
            patternstr = Normalizer.decompose(patternstr, false)
        }
        return textstr.equals(patternstr)
    }

    public func initTextProcessedIter(): Bool {
        if (textProcessedIter_.isNone()) {
            textProcessedIter_ = StringSearch_CollationPCE(textIter_)
        } else {
            textProcessedIter_.initself(textIter_)
        }
        return true
    }

    private func nextBoundaryAfter(startIndex: Int32): Int32 {
        var breakiterator = search_.breakIter()
        if (breakiterator.isNone()) {
            breakiterator = search_.internalBreakIter_
        }
        if (breakiterator.isSome()) {
            return breakiterator.following(startIndex)
        }
        return startIndex
    }

    private func isBreakBoundary(index: Int32): Bool {
        var breakiterator = search_.breakIter()
        if (breakiterator.isNone()) {
            breakiterator = search_.internalBreakIter_
        }
        return (breakiterator.isSome() && breakiterator.isBoundary(index))
    }

    private static let CE_MATCH = -1

    private static let CE_NO_MATCH = 0

    private static let CE_SKIP_TARG = 1

    private static let CE_SKIP_PATN = 2

    private static var CE_LEVEL2_BASE = 5

    private static var CE_LEVEL3_BASE = 327680

    private static func compareCE64s(targCE: Int64, patCE: Int64, compareType: SearchIterator_ElementComparisonType): Int32 {
        if (targCE == patCE) {
            return CE_MATCH
        }
        if (refEq(compareType, SearchIterator_ElementComparisonType.STANDARD_ELEMENT_COMPARISON)) {
            return CE_NO_MATCH
        }
        let targCEshifted = ushr(targCE, 32)
        let patCEshifted = ushr(patCE, 32)
        var mask: Int64 = 0
        mask = 4294901760
        let targLev1 = Int32(targCEshifted & mask)
        let patLev1 = Int32(patCEshifted & mask)
        if (targLev1 != patLev1) {
            if (targLev1 == 0) {
                return CE_SKIP_TARG
            }
            if (patLev1 == 0 && refEq(compareType, SearchIterator_ElementComparisonType.ANY_BASE_WEIGHT_IS_WILDCARD)) {
                return CE_SKIP_PATN
            }
            return CE_NO_MATCH
        }
        mask = 65535
        let targLev2 = Int32(targCEshifted & mask)
        let patLev2 = Int32(patCEshifted & mask)
        if (targLev2 != patLev2) {
            if (targLev2 == 0) {
                return CE_SKIP_TARG
            }
            if (patLev2 == 0 && refEq(compareType, SearchIterator_ElementComparisonType.ANY_BASE_WEIGHT_IS_WILDCARD)) {
                return CE_SKIP_PATN
            }
            return if (patLev2 == CE_LEVEL2_BASE || (refEq(compareType, SearchIterator_ElementComparisonType.ANY_BASE_WEIGHT_IS_WILDCARD) && targLev2 == CE_LEVEL2_BASE)) { CE_MATCH } else { CE_NO_MATCH }
        }
        mask = 4294901760
        let targLev3 = Int32(targCE & mask)
        let patLev3 = Int32(patCE & mask)
        if (targLev3 != patLev3) {
            return if (patLev3 == CE_LEVEL3_BASE || (refEq(compareType, SearchIterator_ElementComparisonType.ANY_BASE_WEIGHT_IS_WILDCARD) && targLev3 == CE_LEVEL3_BASE)) { CE_MATCH } else { CE_NO_MATCH }
        }
        return CE_MATCH
    }

    private func search(startIdx: Int32, m: StringSearch_Match): Bool {
        if (pattern_.CELength_ == 0 || startIdx < search_.beginIndex() || startIdx > search_.endIndex()) {
            throw IllegalArgumentException("search(" + startIdx.toString() + ", m) - expected position to be between " + search_.beginIndex().toString() + " and " + search_.endIndex().toString())
        }
        if (pattern_.PCE_.isNone()) {
            initializePatternPCETable()
        }
        textIter_.setOffset(startIdx)
        let ceb = StringSearch_CEBuffer(this)
        var targetIx = 0
        var targetCEI: StringSearch_CEI
        var patIx: Int32 = 0
        var found: Bool = false
        var mStart = -1
        var mLimit = -1
        var minLimit: Int32 = 0
        var maxLimit: Int32 = 0
        targetIx = 0
        while (true) {
            found = true
            var targetIxOffset = 0
            var patCE = 0
            let firstCEI = ceb.get(targetIx)
            if (firstCEI.isNone()) {
                throw ICUException("CEBuffer.get(" + targetIx.toString() + ") returned null.")
            }
            patIx = 0
            while (patIx < pattern_.PCELength_) {
                patCE = pattern_.PCE_[Int64(patIx)]
                targetCEI = ceb.get(targetIx + patIx + targetIxOffset)
                let ceMatch = compareCE64s(targetCEI.ce_, patCE, search_.elementComparisonType_)
                if (ceMatch == CE_NO_MATCH) {
                    found = false
                    break
                } else if (ceMatch > CE_NO_MATCH) {
                    if (ceMatch == CE_SKIP_TARG) {
                        patIx--
                        targetIxOffset++
                    } else {
                        targetIxOffset--
                    }
                }
                patIx++
            }
            targetIxOffset += pattern_.PCELength_
            if (!found && ((targetCEI.isNone()) || (targetCEI.ce_ != StringSearch_CollationPCE.PROCESSED_NULLORDER))) {
                continue
            }
            if (!found) {
                break
            }
            let lastCEI = ceb.get(targetIx + targetIxOffset - 1)
            mStart = firstCEI.lowIndex_
            minLimit = lastCEI.lowIndex_
            var nextCEI: StringSearch_CEI
            if (refEq(search_.elementComparisonType_, SearchIterator_ElementComparisonType.STANDARD_ELEMENT_COMPARISON)) {
                nextCEI = ceb.get(targetIx + targetIxOffset)
                maxLimit = nextCEI.lowIndex_
                if (nextCEI.lowIndex_ == nextCEI.highIndex_ && nextCEI.ce_ != StringSearch_CollationPCE.PROCESSED_NULLORDER) {
                    found = false
                }
            } else {
                while (true) {
                    nextCEI = ceb.get(targetIx + targetIxOffset)
                    maxLimit = nextCEI.lowIndex_
                    if (nextCEI.ce_ == StringSearch_CollationPCE.PROCESSED_NULLORDER) {
                        break
                    }
                    if (((ushr((nextCEI.ce_), 32)) & 4294901760) == 0) {
                        let ceMatch = compareCE64s(nextCEI.ce_, patCE, search_.elementComparisonType_)
                        if (ceMatch == CE_NO_MATCH || ceMatch == CE_SKIP_PATN) {
                            found = false
                            break
                        }
                    } else if (nextCEI.lowIndex_ == nextCEI.highIndex_) {
                        found = false
                        break
                    } else {
                        break
                    }
                    targetIxOffset++
                }
            }
            if (!isBreakBoundary(mStart)) {
                found = false
            }
            let secondIx = firstCEI.highIndex_
            if (mStart == secondIx) {
                found = false
            }
            let allowMidclusterMatch = breakIterator.isNone() && ((ushr((nextCEI.ce_), 32)) & 4294901760) != 0 && maxLimit >= lastCEI.highIndex_ && nextCEI.highIndex_ > maxLimit && (nfd_.hasBoundaryBefore(codePointAt(targetText, maxLimit)) || nfd_.hasBoundaryAfter(codePointBefore(targetText, maxLimit)))
            mLimit = maxLimit
            if (minLimit < maxLimit) {
                if (minLimit == lastCEI.highIndex_ && isBreakBoundary(minLimit)) {
                    mLimit = minLimit
                } else {
                    let nba = nextBoundaryAfter(minLimit)
                    if (nba >= lastCEI.highIndex_ && (!allowMidclusterMatch || nba < maxLimit)) {
                        mLimit = nba
                    }
                }
            }
            if (!allowMidclusterMatch) {
                if (mLimit > maxLimit) {
                    found = false
                }
                if (!isBreakBoundary(mLimit)) {
                    found = false
                }
            }
            if (!checkIdentical(mStart, mLimit)) {
                found = false
            }
            if (found) {
                break
            }
            targetIx++
        }
        if (found == false) {
            mLimit = -1
            mStart = -1
        }
        if (m.isSome()) {
            m.start_ = mStart
            m.limit_ = mLimit
        }
        return found
    }

    private static func codePointAt(iter: CharacterIterator, index: Int32): Int32 {
        let currentIterIndex = iter.getIndex()
        let codeUnit = iter.setIndex(index)
        var cp = Int32(UInt32(codeUnit))
        if (Character.isHighSurrogate(codeUnit)) {
            let nextUnit = iter.next()
            if (Character.isLowSurrogate(nextUnit)) {
                cp = Character.toCodePoint(codeUnit, nextUnit)
            }
        }
        iter.setIndex(currentIterIndex)
        return cp
    }

    private static func codePointBefore(iter: CharacterIterator, index: Int32): Int32 {
        let currentIterIndex = iter.getIndex()
        iter.setIndex(index)
        let codeUnit = iter.previous()
        var cp = Int32(UInt32(codeUnit))
        if (Character.isLowSurrogate(codeUnit)) {
            let prevUnit = iter.previous()
            if (Character.isHighSurrogate(prevUnit)) {
                cp = Character.toCodePoint(prevUnit, codeUnit)
            }
        }
        iter.setIndex(currentIterIndex)
        return cp
    }

    private func searchBackwards(startIdx: Int32, m: StringSearch_Match): Bool {
        if (pattern_.CELength_ == 0 || startIdx < search_.beginIndex() || startIdx > search_.endIndex()) {
            throw IllegalArgumentException("searchBackwards(" + startIdx.toString() + ", m) - expected position to be between " + search_.beginIndex().toString() + " and " + search_.endIndex().toString())
        }
        if (pattern_.PCE_.isNone()) {
            initializePatternPCETable()
        }
        let ceb = StringSearch_CEBuffer(this)
        var targetIx = 0
        if (startIdx < search_.endIndex()) {
            let bi = search_.internalBreakIter_
            let next = bi.following(startIdx)
            textIter_.setOffset(next)
            targetIx = 0
            while (true) {
                if (ceb.getPrevious(targetIx).lowIndex_ < startIdx) {
                    break
                }
                targetIx++
            }
        } else {
            textIter_.setOffset(startIdx)
        }
        var targetCEI: StringSearch_CEI
        var patIx: Int32 = 0
        var found: Bool = false
        let limitIx = targetIx
        var mStart = -1
        var mLimit = -1
        var minLimit: Int32 = 0
        var maxLimit: Int32 = 0
        targetIx = limitIx
        while (true) {
            found = true
            let lastCEI = ceb.getPrevious(targetIx)
            if (lastCEI.isNone()) {
                throw ICUException("CEBuffer.getPrevious(" + targetIx.toString() + ") returned null.")
            }
            var targetIxOffset = 0
            patIx = pattern_.PCELength_ - 1
            while (patIx >= 0) {
                let patCE = pattern_.PCE_[Int64(patIx)]
                targetCEI = ceb.getPrevious(targetIx + pattern_.PCELength_ - 1 - patIx + targetIxOffset)
                let ceMatch = compareCE64s(targetCEI.ce_, patCE, search_.elementComparisonType_)
                if (ceMatch == CE_NO_MATCH) {
                    found = false
                    break
                } else if (ceMatch > CE_NO_MATCH) {
                    if (ceMatch == CE_SKIP_TARG) {
                        patIx++
                        targetIxOffset++
                    } else {
                        targetIxOffset--
                    }
                }
                patIx--
            }
            if (!found && ((targetCEI.isNone()) || (targetCEI.ce_ != StringSearch_CollationPCE.PROCESSED_NULLORDER))) {
                continue
            }
            if (!found) {
                break
            }
            let firstCEI = ceb.getPrevious(targetIx + pattern_.PCELength_ - 1 + targetIxOffset)
            mStart = firstCEI.lowIndex_
            if (!isBreakBoundary(mStart)) {
                found = false
            }
            if (mStart == firstCEI.highIndex_) {
                found = false
            }
            minLimit = lastCEI.lowIndex_
            if (targetIx > 0) {
                let nextCEI = ceb.getPrevious(targetIx - 1)
                if (nextCEI.lowIndex_ == nextCEI.highIndex_ && nextCEI.ce_ != StringSearch_CollationPCE.PROCESSED_NULLORDER) {
                    found = false
                }
                mLimit = match (0) { case _ => maxLimit = nextCEI.lowIndex_; maxLimit }
                let allowMidclusterMatch = breakIterator.isNone() && ((ushr((nextCEI.ce_), 32)) & 4294901760) != 0 && maxLimit >= lastCEI.highIndex_ && nextCEI.highIndex_ > maxLimit && (nfd_.hasBoundaryBefore(codePointAt(targetText, maxLimit)) || nfd_.hasBoundaryAfter(codePointBefore(targetText, maxLimit)))
                if (minLimit < maxLimit) {
                    let nba = nextBoundaryAfter(minLimit)
                    if (nba >= lastCEI.highIndex_ && (!allowMidclusterMatch || nba < maxLimit)) {
                        mLimit = nba
                    }
                }
                if (!allowMidclusterMatch) {
                    if (mLimit > maxLimit) {
                        found = false
                    }
                    if (!isBreakBoundary(mLimit)) {
                        found = false
                    }
                }
            } else {
                let nba = nextBoundaryAfter(minLimit)
                mLimit = match (0) { case _ => maxLimit = if ((nba > 0) && (startIdx > nba)) { nba } else { startIdx }; maxLimit }
            }
            if (!checkIdentical(mStart, mLimit)) {
                found = false
            }
            if (found) {
                break
            }
            targetIx++
        }
        if (found == false) {
            mLimit = -1
            mStart = -1
        }
        if (m.isSome()) {
            m.start_ = mStart
            m.limit_ = mLimit
        }
        return found
    }

    private func handleNextExact(): Bool {
        return handleNextCommonImpl()
    }

    private func handleNextCanonical(): Bool {
        return handleNextCommonImpl()
    }

    private func handleNextCommonImpl(): Bool {
        let textOffset = textIter_.getOffset()
        let match = StringSearch_Match()
        if (search(textOffset, match)) {
            search_.matchedIndex_ = match.start_
            search_.setMatchedLength(match.limit_ - match.start_)
            return true
        } else {
            setMatchNotFound()
            return false
        }
    }

    private func handlePreviousExact(): Bool {
        return handlePreviousCommonImpl()
    }

    private func handlePreviousCanonical(): Bool {
        return handlePreviousCommonImpl()
    }

    private func handlePreviousCommonImpl(): Bool {
        let textOffset: Int32
        if (search_.isOverlap_) {
            if (search_.matchedIndex_ != DONE) {
                textOffset = search_.matchedIndex_ + search_.matchedLength() - 1
            } else {
                initializePatternPCETable()
                if (!initTextProcessedIter()) {
                    setMatchNotFound()
                    return false
                }
                var nPCEs = 0
                while (nPCEs < pattern_.PCELength_ - 1) {
                    let pce = textProcessedIter_.nextProcessed(None)
                    if (pce == StringSearch_CollationPCE.PROCESSED_NULLORDER) {
                        break
                    }
                    nPCEs++
                }
                textOffset = textIter_.getOffset()
            }
        } else {
            textOffset = textIter_.getOffset()
        }
        let match = StringSearch_Match()
        if (searchBackwards(textOffset, match)) {
            search_.matchedIndex_ = match.start_
            search_.setMatchedLength(match.limit_ - match.start_)
            return true
        } else {
            setMatchNotFound()
            return false
        }
    }

    private static func getString(text: CharacterIterator, start: Int32, length: Int32): String {
        let result = StringBuilder()
        let offset = text.getIndex()
        text.setIndex(start)
        var i = 0
        while (i < length) {
            result.append(text.current())
            text.next()
            i++
        }
        text.setIndex(offset)
        return result.toString()
    }
}


class StringSearch_Match {

    var start_ = -1

    var limit_ = -1
}


class StringSearch_Pattern {
    var text_: String

    var PCE_: Array<Int64>

    var PCELength_ = 0

    var CE_: Array<Int32>

    var CELength_ = 0

    protected init(pattern: String) {
        text_ = pattern
    }
}


class StringSearch_CollationPCE {
    public static let PROCESSED_NULLORDER = -1

    static let DEFAULT_BUFFER_SIZE = 16

    static let BUFFER_GROW = 8

    private static let PRIMARYORDERMASK = -65536

    private static let CONTINUATION_MARKER = 192

    private var pceBuffer_: StringSearch_CollationPCE_PCEBuffer = StringSearch_CollationPCE_PCEBuffer()

    private var cei_: CollationElementIterator

    private var strength_: Int32 = 0

    private var toShift_: Bool = false

    private var isShifted_: Bool = false

    private var variableTop_: Int32 = 0

    public init(iter: CollationElementIterator) {
        initself(iter)
    }

    public func initself(iter: CollationElementIterator): Unit {
        cei_ = iter
        initself(iter.getRuleBasedCollator())
    }

    private func initself(coll: RuleBasedCollator): Unit {
        strength_ = coll.getStrength()
        toShift_ = coll.isAlternateHandlingShifted()
        isShifted_ = false
        variableTop_ = coll.getVariableTop()
    }

    private func processCE(ce: Int32): Int64 {
        var primary = 0
        var secondary = 0
        var tertiary = 0
        var quaternary = 0
        match (strength_) {
            case 1 => secondary = Int64(CollationElementIterator.secondaryOrder(ce))
            case 0 => primary = Int64(CollationElementIterator.primaryOrder(ce))
            case _ => tertiary = Int64(CollationElementIterator.tertiaryOrder(ce))
        }
        if ((toShift_ && variableTop_ > ce && primary != 0) || (isShifted_ && primary == 0)) {
            if (primary == 0) {
                return Int64(CollationElementIterator.IGNORABLE)
            }
            if (strength_ >= Collator.QUATERNARY) {
                quaternary = primary
            }
            primary = match (0) { case _ => secondary = match (0) { case _ => tertiary = 0; tertiary }; secondary }
            isShifted_ = true
        } else {
            if (strength_ >= Collator.QUATERNARY) {
                quaternary = 65535
            }
            isShifted_ = false
        }
        return shl(primary, 48) | shl(secondary, 32) | shl(tertiary, 16) | quaternary
    }

    public func nextProcessed(range: StringSearch_CollationPCE_Range): Int64 {
        var result = Int64(CollationElementIterator.IGNORABLE)
        var low = 0
        var high = 0
        pceBuffer_.reset()
            result = processCE(ce)
        } while (result == Int64(CollationElementIterator.IGNORABLE))
        if (range.isSome()) {
            range.ixLow_ = low
            range.ixHigh_ = high
        }
        return result
    }

    public func previousProcessed(range: StringSearch_CollationPCE_Range): Int64 {
        var result = Int64(CollationElementIterator.IGNORABLE)
        var low = 0
        var high = 0
        while (pceBuffer_.empty()) {
            let rceb = StringSearch_CollationPCE_RCEBuffer()
            var ce: Int32 = 0
            var finish = false
                    finish = true
                    break
                }
                rceb.put(ce, low, high)
            } while ((ce & PRIMARYORDERMASK) == 0 || isContinuation(ce))
            if (finish) {
                break
            }
            while (!rceb.empty()) {
                let rcei = rceb.get()
                result = processCE(rcei.ce_)
                if (result != Int64(CollationElementIterator.IGNORABLE)) {
                    pceBuffer_.put(result, rcei.low_, rcei.high_)
                }
            }
        }
        if (pceBuffer_.empty()) {
            if (range.isSome()) {
                range.ixLow_ = -1
                range.ixHigh_ = -1
            }
            return Int64(CollationElementIterator.NULLORDER)
        }
        let pcei = pceBuffer_.get()
        if (range.isSome()) {
            range.ixLow_ = pcei.low_
            range.ixHigh_ = pcei.high_
        }
        return pcei.ce_
    }

    private static func isContinuation(ce: Int32): Bool {
        return ((ce & CONTINUATION_MARKER) == CONTINUATION_MARKER)
    }
}


public class StringSearch_CollationPCE_Range {

    var ixLow_: Int32 = 0

    var ixHigh_: Int32 = 0
}


class StringSearch_CollationPCE_PCEI {

    var ce_: Int64 = 0

    var low_: Int32 = 0

    var high_: Int32 = 0
}


class StringSearch_CollationPCE_PCEBuffer {

    private var buffer_: Array<StringSearch_CollationPCE_PCEI> = Array<StringSearch_CollationPCE_PCEI>(Int64(StringSearch_CollationPCE.DEFAULT_BUFFER_SIZE))

    private var bufferIndex_ = 0

    public func reset(): Unit {
        bufferIndex_ = 0
    }

    public func empty(): Bool {
        return bufferIndex_ <= 0
    }

    public func put(ce: Int64, ixLow: Int32, ixHigh: Int32): Unit {
        if (bufferIndex_ >= Int32(buffer_.size)) {
            let newBuffer = Array<StringSearch_CollationPCE_PCEI>(Int64(Int32(buffer_.size) + StringSearch_CollationPCE.BUFFER_GROW))
            arraycopy(buffer_, 0, newBuffer, 0, buffer_.size)
            buffer_ = newBuffer
        }
        buffer_[Int64(bufferIndex_)] = StringSearch_CollationPCE_PCEI()
        buffer_[Int64(bufferIndex_)].ce_ = ce
        buffer_[Int64(bufferIndex_)].low_ = ixLow
        buffer_[Int64(bufferIndex_)].high_ = ixHigh
        bufferIndex_ += 1
    }

    public func get(): StringSearch_CollationPCE_PCEI {
        if (bufferIndex_ > 0) {
            return buffer_[Int64(match (0) { case _ => bufferIndex_--; bufferIndex_ })]
        }
        return None
    }
}


class StringSearch_CollationPCE_RCEI {

    var ce_: Int32 = 0

    var low_: Int32 = 0

    var high_: Int32 = 0
}


class StringSearch_CollationPCE_RCEBuffer {

    private var buffer_: Array<StringSearch_CollationPCE_RCEI> = Array<StringSearch_CollationPCE_RCEI>(Int64(StringSearch_CollationPCE.DEFAULT_BUFFER_SIZE))

    private var bufferIndex_ = 0

    public func empty(): Bool {
        return bufferIndex_ <= 0
    }

    public func put(ce: Int32, ixLow: Int32, ixHigh: Int32): Unit {
        if (bufferIndex_ >= Int32(buffer_.size)) {
            let newBuffer = Array<StringSearch_CollationPCE_RCEI>(Int64(Int32(buffer_.size) + StringSearch_CollationPCE.BUFFER_GROW))
            arraycopy(buffer_, 0, newBuffer, 0, buffer_.size)
            buffer_ = newBuffer
        }
        buffer_[Int64(bufferIndex_)] = StringSearch_CollationPCE_RCEI()
        buffer_[Int64(bufferIndex_)].ce_ = ce
        buffer_[Int64(bufferIndex_)].low_ = ixLow
        buffer_[Int64(bufferIndex_)].high_ = ixHigh
        bufferIndex_ += 1
    }

    public func get(): StringSearch_CollationPCE_RCEI {
        if (bufferIndex_ > 0) {
            return buffer_[Int64(match (0) { case _ => bufferIndex_--; bufferIndex_ })]
        }
        return None
    }
}


class StringSearch_CEI {

    var ce_: Int64 = 0

    var lowIndex_: Int32 = 0

    var highIndex_: Int32 = 0
}


class StringSearch_CEBuffer {
    static let CEBUFFER_EXTRA = 32

    static let MAX_TARGET_IGNORABLES_PER_PAT_JAMO_L = 8

    static let MAX_TARGET_IGNORABLES_PER_PAT_OTHER = 3

    var buf_: Array<StringSearch_CEI>

    var bufSize_: Int32 = 0

    var firstIx_: Int32 = 0

    var limitIx_: Int32 = 0

    var strSearch_: StringSearch

    init(ss: StringSearch) {
        strSearch_ = ss
        bufSize_ = ss.pattern_.PCELength_ + CEBUFFER_EXTRA
        if (!refEq(ss.search_.elementComparisonType_, SearchIterator_ElementComparisonType.STANDARD_ELEMENT_COMPARISON)) {
            let patText = ss.pattern_.text_
            if (patText.isSome()) {
                var i = 0
                while (i < Int32(patText.size)) {
                    let c = Char(patText[Int64(i)])
                    if (MIGHT_BE_JAMO_L(c)) {
                        bufSize_ += MAX_TARGET_IGNORABLES_PER_PAT_JAMO_L
                    } else {
                        bufSize_ += MAX_TARGET_IGNORABLES_PER_PAT_OTHER
                    }
                    i++
                }
            }
        }
        firstIx_ = 0
        limitIx_ = 0
        if (!ss.initTextProcessedIter()) {
            return
        }
        buf_ = Array<StringSearch_CEI>(Int64(bufSize_))
    }

    public func get(index: Int32): StringSearch_CEI {
        let i = index % bufSize_
        if (index >= firstIx_ && index < limitIx_) {
            return buf_[Int64(i)]
        }
        if (index != limitIx_) {
            if (!(false)) {
                throw AssertionError()
            }
            return None
        }
        limitIx_++
        if (limitIx_ - firstIx_ >= bufSize_) {
            firstIx_++
        }
        let range = StringSearch_CollationPCE_Range()
        if (buf_[Int64(i)].isNone()) {
            buf_[Int64(i)] = StringSearch_CEI()
        }
        buf_[Int64(i)].ce_ = strSearch_.textProcessedIter_.nextProcessed(range)
        buf_[Int64(i)].lowIndex_ = range.ixLow_
        buf_[Int64(i)].highIndex_ = range.ixHigh_
        return buf_[Int64(i)]
    }

    public func getPrevious(index: Int32): StringSearch_CEI {
        let i = index % bufSize_
        if (index >= firstIx_ && index < limitIx_) {
            return buf_[Int64(i)]
        }
        if (index != limitIx_) {
            if (!(false)) {
                throw AssertionError()
            }
            return None
        }
        limitIx_++
        if (limitIx_ - firstIx_ >= bufSize_) {
            firstIx_++
        }
        let range = StringSearch_CollationPCE_Range()
        if (buf_[Int64(i)].isNone()) {
            buf_[Int64(i)] = StringSearch_CEI()
        }
        buf_[Int64(i)].ce_ = strSearch_.textProcessedIter_.previousProcessed(range)
        buf_[Int64(i)].lowIndex_ = range.ixLow_
        buf_[Int64(i)].highIndex_ = range.ixHigh_
        return buf_[Int64(i)]
    }

    static func MIGHT_BE_JAMO_L(c: Char): Bool {
        return (Int32(UInt32(c)) >= 4352 && Int32(UInt32(c)) <= 4446) || (Int32(UInt32(c)) >= 12593 && Int32(UInt32(c)) <= 12622) || (Int32(UInt32(c)) >= 12645 && Int32(UInt32(c)) <= 12678)
    }
}
