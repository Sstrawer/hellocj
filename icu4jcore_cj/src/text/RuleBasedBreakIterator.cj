package icu4cj.text


public class RuleBasedBreakIterator <: BreakIterator {
    private init() {
        super()
        fDictionaryCharCount = 0
    }

    public static func getInstanceFromCompiledRules(isTrue: InputStream): RuleBasedBreakIterator {
        let `This` = RuleBasedBreakIterator()
        `This`.fRData = RBBIDataWrapper.get(ICUBinary.getByteBufferFromInputStreamAndCloseStream(isTrue))
        `This`.fLookAheadMatches = Array<Int32>(Int64(`This`.fRData.fFTable.fLookAheadResultsSize)) { _ => 0 }
        return `This`
    }

    static func getInstanceFromCompiledRules(bytes: ByteArrayStream, phraseBreaking: Bool): RuleBasedBreakIterator {
        let instance = getInstanceFromCompiledRules(bytes)
        instance.fPhraseBreaking = phraseBreaking
        return instance
    }

    
    public static func getInstanceFromCompiledRules(bytes: ByteArrayStream): RuleBasedBreakIterator {
        let `This` = RuleBasedBreakIterator()
        `This`.fRData = RBBIDataWrapper.get(bytes)
        `This`.fLookAheadMatches = Array<Int32>(Int64(`This`.fRData.fFTable.fLookAheadResultsSize)) { _ => 0 }
        return `This`
    }

    public init(rules: String) {
        this()
        try {
            let ruleOS = ByteArrayStream()
            compileRules(rules, ruleOS)
            fRData = RBBIDataWrapper.get(ByteArrayStream.wrap(ruleOS.bytes()))
            fLookAheadMatches = Array<Int32>(Int64(fRData.fFTable.fLookAheadResultsSize)) { _ => 0 }
        } catch (e: IOException) {
            let rte = Exception("RuleBasedBreakIterator rule compilation internal error: " + e.message)
            throw rte
        }
    }

    public override func clone(): Object {
        let result: RuleBasedBreakIterator
        result = super.clone()
        if (fText.isSome()) {
            result.fText = fText.clone()
        }
        result.fLookAheadMatches = Array<Int32>(Int64(fRData.fFTable.fLookAheadResultsSize)) { _ => 0 }
        result.fBreakCache = RuleBasedBreakIterator_BreakCache(, fBreakCache)
        result.fDictionaryCache = RuleBasedBreakIterator_DictionaryCache(, fDictionaryCache)
        return result
    }

    public override func equals(that: Object): Bool {
        if (that.isNone()) {
            return false
        }
        if (refEq(this, that)) {
            return true
        }
        try {
            let other = that
            if (!refEq(fRData, other.fRData) && (fRData.isNone() || other.fRData.isNone())) {
                return false
            }
            if (fRData.isSome() && other.fRData.isSome() && (!fRData.fRuleSource.equals(other.fRData.fRuleSource))) {
                return false
            }
            if (fText.isNone() && other.fText.isNone()) {
                return true
            }
            if (fText.isNone() || other.fText.isNone() || !refEq(fText, other.fText)) {
                return false
            }
            return fPosition == other.fPosition
        } catch (e: ClassCastException) {
            return false
        }
    }

    public override func toString(): String {
        var retStr: String = ""
        if (fRData.isSome()) {
            retStr = fRData.fRuleSource
        }
        return retStr
    }

    public override func hashCode(): Int64 {
        return fRData.fRuleSource.hashCode()
    }

    private static let START_STATE = 1

    private static let STOP_STATE = 0

    private static let RBBI_START = 0

    private static let RBBI_RUN = 1

    private static let RBBI_END = 2

    var fText: CharacterIterator = StringCharacterIterator("")

    
    public var fRData: RBBIDataWrapper

    var fPosition: Int32 = 0

    var fRuleStatusIndex: Int32 = 0

    var fDone: Bool = false

    private var fLookAheadMatches: Array<Int32>

    private var fBreakCache: RuleBasedBreakIterator_BreakCache = RuleBasedBreakIterator_BreakCache(this)

    var fPhraseBreaking = false

    var fDictionaryCharCount: Int32 = 0

    var fDictionaryCache: RuleBasedBreakIterator_DictionaryCache = RuleBasedBreakIterator_DictionaryCache(this)

    private static let RBBI_DEBUG_ARG = "rbbi"

    private static let TRACE = ICUDebug.enabled(RBBI_DEBUG_ARG) && indexOfWrap(ICUDebug.value(RBBI_DEBUG_ARG).indexOf("trace")) >= 0

    private static let gUnhandledBreakEngine: UnhandledBreakEngine

    private static let gAllBreakEngines: ConcurrentLinkedQueue


    
    public func dump(out: PrintStream): Unit {
        var tempout = out
        if (tempout.isNone()) {
            tempout = Console.stdOut as PrintStream
        }
        this.fRData.dump(tempout)
    }

    public static func compileRules(rules: String, ruleBinary: OutputStream): Unit {
        RBBIRuleBuilder.compileRules(rules, ruleBinary)
    }

    public override func first(): Int32 {
        if (fText.isNone()) {
            return BreakIterator.DONE
        }
        fText.first()
        let start = fText.getIndex()
        if (!fBreakCache.seek(start)) {
            fBreakCache.populateNear(start)
        }
        fBreakCache.current()
        if (!(fPosition == start)) {
            throw AssertionError()
        }
        return fPosition
    }

    public override func last(): Int32 {
        if (fText.isNone()) {
            return BreakIterator.DONE
        }
        let endPos = fText.getEndIndex()
        let endShouldBeBoundary = isBoundary(endPos)
        if (!(endShouldBeBoundary)) {
            throw AssertionError()
        }
        if (fPosition != endPos) {
            if (!(fPosition == endPos)) {
                throw AssertionError()
            }
        }
        return endPos
    }

    public override func next(n: Int32): Int32 {
        var tempn = n
        var result = 0
        if (tempn > 0) {
            while (tempn > 0 && result != DONE) {
                result = next()
                tempn--
            }
        } else if (tempn < 0) {
            while (tempn < 0 && result != DONE) {
                result = previous()
                tempn++
            }
        } else {
            result = current()
        }
        return result
    }

    public override func next(): Int32 {
        fBreakCache.next()
        return if (fDone) { DONE } else { fPosition }
    }

    public override func previous(): Int32 {
        fBreakCache.previous()
        return if (fDone) { DONE } else { fPosition }
    }

    public override func following(startPos: Int32): Int32 {
        var tempstartPos = startPos
        if (tempstartPos < fText.getBeginIndex()) {
            return first()
        }
        tempstartPos = CISetIndex32(fText, tempstartPos)
        fBreakCache.following(tempstartPos)
        return if (fDone) { DONE } else { fPosition }
    }

    public override func preceding(offset: Int32): Int32 {
        if (fText.isNone() || offset > fText.getEndIndex()) {
            return last()
        } else if (offset < fText.getBeginIndex()) {
            return first()
        }
        let adjustedOffset = offset
        fBreakCache.preceding(adjustedOffset)
        return if (fDone) { DONE } else { fPosition }
    }

    protected static func checkOffset(offset: Int32, text: CharacterIterator): Unit {
        if (offset < text.getBeginIndex() || offset > text.getEndIndex()) {
            throw IllegalArgumentException("offset out of bounds")
        }
    }

    public override func isBoundary(offset: Int32): Bool {
        checkOffset(offset, fText)
        let adjustedOffset = CISetIndex32(fText, offset)
        var result = false
        if (fBreakCache.seek(adjustedOffset) || fBreakCache.populateNear(adjustedOffset)) {
            result = (fBreakCache.current() == offset)
        }
        if (!result) {
            next()
        }
        return result
    }

    public override func current(): Int32 {
        return if (fText.isSome()) { fPosition } else { BreakIterator.DONE }
    }

    public override func getRuleStatus(): Int32 {
        let idx = fRuleStatusIndex + fRData.fStatusTable[Int64(fRuleStatusIndex)]
        let tagVal = fRData.fStatusTable[Int64(idx)]
        return tagVal
    }

    public override func getRuleStatusVec(fillInArray: Array<Int32>): Int32 {
        let numStatusVals = fRData.fStatusTable[Int64(fRuleStatusIndex)]
        if (fillInArray.isSome()) {
            let numToCopy = min(numStatusVals, Int32(fillInArray.size))
            var i = 0
            while (i < numToCopy) {
                fillInArray[Int64(i)] = fRData.fStatusTable[Int64(fRuleStatusIndex + i + 1)]
                i++
            }
        }
        return numStatusVals
    }

    public override func getText(): CharacterIterator {
        return fText
    }

    public override func setText(newText: CharacterIterator): Unit {
        if (newText.isSome()) {
            fBreakCache.reset(newText.getBeginIndex(), 0)
        } else {
            fBreakCache.reset()
        }
        fDictionaryCache.reset()
        fText = newText
        this.first()
    }

    
    public static let fDebugEnv: String = if (ICUDebug.enabled(RBBI_DEBUG_ARG)) { ICUDebug.value(RBBI_DEBUG_ARG) } else { None }

    public func getLanguageBreakEngine(c: Int32): LanguageBreakEngine {
        for (candidate in gAllBreakEngines) {
            if (candidate.handles(c)) {
                return candidate
            }
        }
        synchronized (getMonitorByObject(gAllBreakEngines)) {
            for (candidate in gAllBreakEngines) {
                if (candidate.handles(c)) {
                    return candidate
                }
            }
            var script = UCharacter.getIntPropertyValue(c, UProperty.SCRIPT)
            if (script == UScript.KATAKANA || script == UScript.HIRAGANA) {
                script = UScript.HAN
            }
            var eng: LanguageBreakEngine
            try {
                match (script) {
                    case 38 => try {
                        eng = LSTMBreakEngine.create(script, LSTMBreakEngine.createData(script))
                    } catch (e: MissingResourceException) {
                        eng = ThaiBreakEngine()
                    }
                    case 24 => eng = LaoBreakEngine()
                    case 28 => try {
                        eng = LSTMBreakEngine.create(script, LSTMBreakEngine.createData(script))
                    } catch (e: MissingResourceException) {
                        eng = BurmeseBreakEngine()
                    }
                    case 23 => eng = KhmerBreakEngine()
                    case 17 => eng = CjkBreakEngine(false)
                    case 18 => eng = CjkBreakEngine(true)
                    case _ =>
                        gUnhandledBreakEngine.handleChar(c)
                        eng = gUnhandledBreakEngine
                }
            } catch (e: IOException) {
                eng = None
            }
            if (eng.isSome() && !refEq(eng, gUnhandledBreakEngine)) {
                gAllBreakEngines.add(eng)
            }
            return eng
        }
    }

    public func handleNext(): Int32 {
        if (TRACE) {
            println("Handle Next   pos      char  state category")
        }
        fRuleStatusIndex = 0
        fDictionaryCharCount = 0
        let text = fText
        let trie = fRData.fTrie
        let stateTable = fRData.fFTable.fTable
        let initialPosition = fPosition
        text.setIndex(initialPosition)
        var result = initialPosition
        var c = Int32(UInt32(text.current()))
        if (c >= UTF16.LEAD_SURROGATE_MIN_VALUE) {
            c = CharacterIteration.nextTrail32(text, c)
            if (c == CharacterIteration.DONE32) {
                fDone = true
                return BreakIterator.DONE
            }
        }
        var state = START_STATE
        var row = fRData.getRowIndex(state)
        var category = 3i16
        let flagsState = fRData.fFTable.fFlags
        let dictStart = fRData.fFTable.fDictCategoriesStart
        var mode = RBBI_RUN
        if ((flagsState & RBBIDataWrapper.RBBI_BOF_REQUIRED) != 0) {
            category = 2i16
            mode = RBBI_START
            if (TRACE) {
                print("            " + (RBBIDataWrapper.intToString(text.getIndex(), 5)))
                print(RBBIDataWrapper.intToHexString(c, 10))
                println((RBBIDataWrapper.intToString(state, 7)) + (RBBIDataWrapper.intToString(Int32(category), 6)))
            }
        }
        while (state != STOP_STATE) {
            if (c == CharacterIteration.DONE32) {
                if (mode == RBBI_END) {
                    break
                }
                mode = RBBI_END
                category = 1i16
            } else if (mode == RBBI_RUN) {
                category = Int16(trie.get(c))
                if (Int32(category) >= dictStart) {
                    fDictionaryCharCount++
                }
                if (TRACE) {
                    print("            " + (RBBIDataWrapper.intToString(text.getIndex(), 5)))
                    print(RBBIDataWrapper.intToHexString(c, 10))
                    println((RBBIDataWrapper.intToString(state, 7)) + (RBBIDataWrapper.intToString(Int32(category), 6)))
                }
                c = Int32(UInt32(text.next()))
                if (c >= UTF16.LEAD_SURROGATE_MIN_VALUE) {
                    c = CharacterIteration.nextTrail32(text, c)
                }
            } else {
                mode = RBBI_RUN
            }
            state = Int32(UInt32(stateTable[Int64(row + RBBIDataWrapper.NEXTSTATES + Int32(category))]))
            row = fRData.getRowIndex(state)
            let accepting = Int32(UInt32(stateTable[Int64(row + RBBIDataWrapper.ACCEPTING)]))
            if (accepting == RBBIDataWrapper.ACCEPTING_UNCONDITIONAL) {
                result = text.getIndex()
                if (c >= UTF16.SUPPLEMENTARY_MIN_VALUE && c <= UTF16.CODEPOINT_MAX_VALUE) {
                    result--
                }
                fRuleStatusIndex = Int32(UInt32(stateTable[Int64(row + RBBIDataWrapper.TAGSIDX)]))
            } else if (accepting > RBBIDataWrapper.ACCEPTING_UNCONDITIONAL) {
                let lookaheadResult = fLookAheadMatches[Int64(accepting)]
                if (lookaheadResult >= 0) {
                    fRuleStatusIndex = Int32(UInt32(stateTable[Int64(row + RBBIDataWrapper.TAGSIDX)]))
                    fPosition = lookaheadResult
                    return lookaheadResult
                }
            }
            let rule = Int32(UInt32(stateTable[Int64(row + RBBIDataWrapper.LOOKAHEAD)]))
            if (rule != 0) {
                var pos = text.getIndex()
                if (c >= UTF16.SUPPLEMENTARY_MIN_VALUE && c <= UTF16.CODEPOINT_MAX_VALUE) {
                    pos--
                }
                fLookAheadMatches[Int64(rule)] = pos
            }
        }
        if (result == initialPosition) {
            if (TRACE) {
                println("Iterator did not move. Advancing by 1.")
            }
            text.setIndex(initialPosition)
            CharacterIteration.next32(text)
            result = text.getIndex()
            fRuleStatusIndex = 0
        }
        fPosition = result
        if (TRACE) {
            println("result = " + result.toString())
        }
        return result
    }

    public func handleSafePrevious(fromPosition: Int32): Int32 {
        var state: Char = '\u{0000}'
        var category = 0i16
        var result = 0
        let text = fText
        let trie = fRData.fTrie
        let stateTable = fRData.fRTable.fTable
        CISetIndex32(text, fromPosition)
        if (TRACE) {
            print("Handle Previous   pos   char  state category")
        }
        if (text.getIndex() == text.getBeginIndex()) {
            return BreakIterator.DONE
        }
        var c = CharacterIteration.previous32(text)
        state = Char(START_STATE)
        var row = fRData.getRowIndex(Int32(UInt32(state)))
        while (c != CharacterIteration.DONE32) {
            category = Int16(trie.get(c))
            if (TRACE) {
                print("            " + (RBBIDataWrapper.intToString(text.getIndex(), 5)))
                print(RBBIDataWrapper.intToHexString(c, 10))
                println((RBBIDataWrapper.intToString(Int32(UInt32(state)), 7)) + (RBBIDataWrapper.intToString(Int32(category), 6)))
            }
            if (!(Int32(category) < fRData.fHeader.fCatCount)) {
                throw AssertionError()
            }
            state = stateTable[Int64(row + RBBIDataWrapper.NEXTSTATES + Int32(category))]
            row = fRData.getRowIndex(Int32(UInt32(state)))
            if (Int32(UInt32(state)) == STOP_STATE) {
                break
            }
            c = CharacterIteration.previous32(text)
        }
        result = text.getIndex()
        if (TRACE) {
            println("result = " + result.toString())
        }
        return result
    }

    private static func CISetIndex32(ci: CharacterIterator, index: Int32): Int32 {
        if (index <= ci.getBeginIndex()) {
            ci.first()
        } else if (index >= ci.getEndIndex()) {
            ci.setIndex(ci.getEndIndex())
        } else if (Character.isLowSurrogate(ci.setIndex(index))) {
            if (!Character.isHighSurrogate(ci.previous())) {
                ci.next()
            }
        }
        return ci.getIndex()
    }
}


class RuleBasedBreakIterator_DictionaryCache {
    let this_0: RuleBasedBreakIterator

    public func reset(): Unit {
        fPositionInCache = -1
        fStart = 0
        fLimit = 0
        fFirstRuleStatusIndex = 0
        fOtherRuleStatusIndex = 0
        fBreaks.removeAllElements()
    }

    public func following(fromPos: Int32): Bool {
        if (fromPos >= fLimit || fromPos < fStart) {
            fPositionInCache = -1
            return false
        }
        var r = 0
        if (fPositionInCache >= 0 && fPositionInCache < fBreaks.size() && fBreaks.elementAt(fPositionInCache) == fromPos) {
            fPositionInCache++
            if (fPositionInCache >= fBreaks.size()) {
                fPositionInCache = -1
                return false
            }
            r = fBreaks.elementAt(fPositionInCache)
            if (!(r > fromPos)) {
                throw AssertionError()
            }
            fBoundary = r
            fStatusIndex = fOtherRuleStatusIndex
            return true
        }
        fPositionInCache = 0
        while (fPositionInCache < fBreaks.size()) {
            r = fBreaks.elementAt(fPositionInCache)
            if (r > fromPos) {
                fBoundary = r
                fStatusIndex = fOtherRuleStatusIndex
                return true
            }
            fPositionInCache++
        }
        if (!(false)) {
            throw AssertionError()
        }
        fPositionInCache = -1
        return false
    }

    public func preceding(fromPos: Int32): Bool {
        if (fromPos <= fStart || fromPos > fLimit) {
            fPositionInCache = -1
            return false
        }
        if (fromPos == fLimit) {
            fPositionInCache = fBreaks.size() - 1
            if (fPositionInCache >= 0) {
                if (!(fBreaks.elementAt(fPositionInCache) == fromPos)) {
                    throw AssertionError()
                }
            }
        }
        var r: Int32 = 0
        if (fPositionInCache > 0 && fPositionInCache < fBreaks.size() && fBreaks.elementAt(fPositionInCache) == fromPos) {
            fPositionInCache--
            r = fBreaks.elementAt(fPositionInCache)
            if (!(r < fromPos)) {
                throw AssertionError()
            }
            fBoundary = r
            fStatusIndex = if (r == fStart) { fFirstRuleStatusIndex } else { fOtherRuleStatusIndex }
            return true
        }
        if (fPositionInCache == 0) {
            fPositionInCache = -1
            return false
        }
        fPositionInCache = fBreaks.size() - 1
        while (fPositionInCache >= 0) {
            r = fBreaks.elementAt(fPositionInCache)
            if (r < fromPos) {
                fBoundary = r
                fStatusIndex = if (r == fStart) { fFirstRuleStatusIndex } else { fOtherRuleStatusIndex }
                return true
            }
            fPositionInCache--
        }
        if (!(false)) {
            throw AssertionError()
        }
        fPositionInCache = -1
        return false
    }

    public func populateDictionary(startPos: Int32, endPos: Int32, firstRuleStatus: Int32, otherRuleStatus: Int32): Unit {
        if ((endPos - startPos) <= 1) {
            return
        }
        reset()
        fFirstRuleStatusIndex = firstRuleStatus
        fOtherRuleStatusIndex = otherRuleStatus
        let rangeStart = startPos
        let rangeEnd = endPos
        var category: Int32 = 0
        var current: Int32 = 0
        var foundBreakCount = 0
        this_0.fText.setIndex(rangeStart)
        var c = CharacterIteration.current32(this_0.fText)
        category = Int32(Int16(this_0.fRData.fTrie.get(c)))
        let dictStart = this_0.fRData.fFTable.fDictCategoriesStart
        while (true) {
            while ((match (0) { case _ => current = this_0.fText.getIndex(); current }) < rangeEnd && (category < dictStart)) {
                c = CharacterIteration.next32(this_0.fText)
                category = Int32(Int16(this_0.fRData.fTrie.get(c)))
            }
            if (current >= rangeEnd) {
                break
            }
            let lbe = this_0.getLanguageBreakEngine(c)
            if (lbe.isSome()) {
                foundBreakCount += lbe.findBreaks(this_0.fText, rangeStart, rangeEnd, fBreaks, this_0.fPhraseBreaking)
            }
            c = CharacterIteration.current32(this_0.fText)
            category = Int32(Int16(this_0.fRData.fTrie.get(c)))
        }
        if (foundBreakCount > 0) {
            if (!(foundBreakCount == fBreaks.size())) {
                throw AssertionError()
            }
            if (startPos < fBreaks.elementAt(0)) {
                fBreaks.offer(startPos)
            }
            if (endPos > fBreaks.peek()) {
                fBreaks.push(endPos)
            }
            fPositionInCache = 0
            fStart = fBreaks.elementAt(0)
            fLimit = fBreaks.peek()
        } else { }
    }

    init(this_0: RuleBasedBreakIterator) {
        this.this_0 = this_0
        fPositionInCache = -1
        fBreaks = DictionaryBreakEngine_DequeI()
    }

    init(this_0: RuleBasedBreakIterator, src: RuleBasedBreakIterator_DictionaryCache) {
        this.this_0 = this_0
        try {
            fBreaks = src.fBreaks.clone()
        } catch (e: CloneNotSupportedException) {
            throw Exception()
        }
        fPositionInCache = src.fPositionInCache
        fStart = src.fStart
        fLimit = src.fLimit
        fFirstRuleStatusIndex = src.fFirstRuleStatusIndex
        fOtherRuleStatusIndex = src.fOtherRuleStatusIndex
        fBoundary = src.fBoundary
        fStatusIndex = src.fStatusIndex
    }

    var fBreaks: DictionaryBreakEngine_DequeI

    var fPositionInCache: Int32 = 0

    var fStart: Int32 = 0

    var fLimit: Int32 = 0

    var fFirstRuleStatusIndex: Int32 = 0

    var fOtherRuleStatusIndex: Int32 = 0

    var fBoundary: Int32 = 0

    var fStatusIndex: Int32 = 0
}


class RuleBasedBreakIterator_BreakCache {
    let this_0: RuleBasedBreakIterator

    init(this_0: RuleBasedBreakIterator) {
        this.this_0 = this_0
        reset()
    }

    public func reset(pos: Int32, ruleStatus: Int32): Unit {
        fStartBufIdx = 0
        fEndBufIdx = 0
        fTextIdx = pos
        fBufIdx = 0
        fBoundaries[0] = pos
        fStatuses[0] = Int16(ruleStatus)
    }

    public func reset(): Unit {
        reset(0, 0)
    }

    public func next(): Unit {
        if (fBufIdx == fEndBufIdx) {
            this_0.fDone = !populateFollowing()
            this_0.fPosition = fTextIdx
            this_0.fRuleStatusIndex = Int32(fStatuses[Int64(fBufIdx)])
        } else {
            fBufIdx = modChunkSize(fBufIdx + 1)
            fTextIdx = match (0) { case _ => this_0.fPosition = fBoundaries[Int64(fBufIdx)]; this_0.fPosition }
            this_0.fRuleStatusIndex = Int32(fStatuses[Int64(fBufIdx)])
        }
    }

    public func previous(): Unit {
        let initialBufIdx = fBufIdx
        if (fBufIdx == fStartBufIdx) {
            populatePreceding()
        } else {
            fBufIdx = modChunkSize(fBufIdx - 1)
            fTextIdx = fBoundaries[Int64(fBufIdx)]
        }
        this_0.fDone = (fBufIdx == initialBufIdx)
        this_0.fPosition = fTextIdx
        this_0.fRuleStatusIndex = Int32(fStatuses[Int64(fBufIdx)])
        return
    }

    public func following(startPos: Int32): Unit {
        if (startPos == fTextIdx || seek(startPos) || populateNear(startPos)) {
            this_0.fDone = false
            next()
        }
    }

    public func preceding(startPos: Int32): Unit {
        if (startPos == fTextIdx || seek(startPos) || populateNear(startPos)) {
            if (startPos == fTextIdx) {
                previous()
            } else {
                if (!(startPos > fTextIdx)) {
                    throw AssertionError()
                }
                current()
            }
        }
        return
    }

    public func current(): Int32 {
        this_0.fPosition = fTextIdx
        this_0.fRuleStatusIndex = Int32(fStatuses[Int64(fBufIdx)])
        this_0.fDone = false
        return fTextIdx
    }

    public func populateNear(position: Int32): Bool {
        if (!(position < fBoundaries[Int64(fStartBufIdx)] || position > fBoundaries[Int64(fEndBufIdx)])) {
            throw AssertionError()
        }
        let CACHE_NEAR = 15
        let startOfText = this_0.fText.getBeginIndex()
        var aBoundary = -1
        var ruleStatusIndex = 0
        var retainCache = false
        if ((position > fBoundaries[Int64(fStartBufIdx)] - CACHE_NEAR) && position < (fBoundaries[Int64(fEndBufIdx)] + CACHE_NEAR)) {
            retainCache = true
        } else if (position <= startOfText + CACHE_NEAR) {
            retainCache = false
            aBoundary = startOfText
        } else {
            let backupPos = this_0.handleSafePrevious(position)
            if (fBoundaries[Int64(fEndBufIdx)] < position && fBoundaries[Int64(fEndBufIdx)] >= (backupPos - CACHE_NEAR)) {
                retainCache = true
            } else if (backupPos < startOfText + CACHE_NEAR) {
                aBoundary = startOfText
                retainCache = (fBoundaries[Int64(fStartBufIdx)] <= (position + CACHE_NEAR))
            } else {
                retainCache = false
                this_0.fPosition = backupPos
                aBoundary = this_0.handleNext()
                if (aBoundary == backupPos + 1 || (aBoundary == backupPos + 2 && Character.isHighSurrogate(this_0.fText.setIndex(backupPos)) && Character.isLowSurrogate(this_0.fText.next()))) {
                    aBoundary = this_0.handleNext()
                }
                if (aBoundary == BreakIterator.DONE) {
                    aBoundary = this_0.fText.getEndIndex()
                }
                ruleStatusIndex = this_0.fRuleStatusIndex
            }
        }
        if (!retainCache) {
            if (!(aBoundary != -1)) {
                throw AssertionError()
            }
            reset(aBoundary, ruleStatusIndex)
        }
        if (fBoundaries[Int64(fEndBufIdx)] < position) {
            while (fBoundaries[Int64(fEndBufIdx)] < position) {
                if (!populateFollowing()) {
                    if (!false) {
                        throw AssertionError()
                    }
                    return false
                }
            }
            fBufIdx = fEndBufIdx
            fTextIdx = fBoundaries[Int64(fBufIdx)]
            while (fTextIdx > position) {
                previous()
            }
            return true
        }
        if (fBoundaries[Int64(fStartBufIdx)] > position) {
            while (fBoundaries[Int64(fStartBufIdx)] > position) {
                populatePreceding()
            }
            fBufIdx = fStartBufIdx
            fTextIdx = fBoundaries[Int64(fBufIdx)]
            while (fTextIdx < position) {
                next()
            }
            if (fTextIdx > position) {
                previous()
            }
            return true
        }
        if (!(fTextIdx == position)) {
            throw AssertionError()
        }
        return true
    }

    public func populateFollowing(): Bool {
        let fromPosition = fBoundaries[Int64(fEndBufIdx)]
        let fromRuleStatusIdx = Int32(fStatuses[Int64(fEndBufIdx)])
        var pos = 0
        var ruleStatusIdx = 0
        if (this_0.fDictionaryCache.following(fromPosition)) {
            addFollowing(this_0.fDictionaryCache.fBoundary, this_0.fDictionaryCache.fStatusIndex, UpdateCachePosition)
            return true
        }
        this_0.fPosition = fromPosition
        pos = this_0.handleNext()
        if (pos == BreakIterator.DONE) {
            return false
        }
        ruleStatusIdx = this_0.fRuleStatusIndex
        if (this_0.fDictionaryCharCount > 0) {
            this_0.fDictionaryCache.populateDictionary(fromPosition, pos, fromRuleStatusIdx, ruleStatusIdx)
            if (this_0.fDictionaryCache.following(fromPosition)) {
                addFollowing(this_0.fDictionaryCache.fBoundary, this_0.fDictionaryCache.fStatusIndex, UpdateCachePosition)
                return true
            }
        }
        addFollowing(pos, ruleStatusIdx, UpdateCachePosition)
        var count = 0
        while (count < 6) {
            pos = this_0.handleNext()
            if (pos == BreakIterator.DONE || this_0.fDictionaryCharCount > 0) {
                break
            }
            addFollowing(pos, this_0.fRuleStatusIndex, RetainCachePosition)
            count++
        }
        return true
    }

    public func populatePreceding(): Bool {
        let textBegin = this_0.fText.getBeginIndex()
        let fromPosition = fBoundaries[Int64(fStartBufIdx)]
        if (fromPosition == textBegin) {
            return false
        }
        var position = textBegin
        var positionStatusIdx = 0
        if (this_0.fDictionaryCache.preceding(fromPosition)) {
            addPreceding(this_0.fDictionaryCache.fBoundary, this_0.fDictionaryCache.fStatusIndex, UpdateCachePosition)
            return true
        }
        var backupPosition = fromPosition
                backupPosition = this_0.handleSafePrevious(backupPosition)
            }
            if (backupPosition == BreakIterator.DONE || backupPosition == textBegin) {
                position = textBegin
                positionStatusIdx = 0
            } else {
                this_0.fPosition = backupPosition
                position = this_0.handleNext()
                if (position == backupPosition + 1 || (position == backupPosition + 2 && Character.isHighSurrogate(this_0.fText.setIndex(backupPosition)) && Character.isLowSurrogate(this_0.fText.next()))) {
                    position = this_0.handleNext()
                }
                positionStatusIdx = this_0.fRuleStatusIndex
            }
        } while (position >= fromPosition)
        fSideBuffer.removeAllElements()
        fSideBuffer.push(position)
        fSideBuffer.push(positionStatusIdx)
            var segmentHandledByDictionary = false
            if (this_0.fDictionaryCharCount != 0) {
                let dictSegEndPosition = position
                this_0.fDictionaryCache.populateDictionary(prevPosition, dictSegEndPosition, prevStatusIdx, positionStatusIdx)
                while (this_0.fDictionaryCache.following(prevPosition)) {
                    position = this_0.fDictionaryCache.fBoundary
                    positionStatusIdx = this_0.fDictionaryCache.fStatusIndex
                    segmentHandledByDictionary = true
                    if (!(position > prevPosition)) {
                        throw AssertionError()
                    }
                    if (position >= fromPosition) {
                        break
                    }
                    if (!(position <= dictSegEndPosition)) {
                        throw AssertionError()
                    }
                    fSideBuffer.push(position)
                    fSideBuffer.push(positionStatusIdx)
                    prevPosition = position
                }
                if (!(position == dictSegEndPosition || position >= fromPosition)) {
                    throw AssertionError()
                }
            }
            if (!segmentHandledByDictionary && position < fromPosition) {
                fSideBuffer.push(position)
                fSideBuffer.push(positionStatusIdx)
            }
        } while (position < fromPosition)
        var success = false
        if (!fSideBuffer.isEmpty()) {
            positionStatusIdx = fSideBuffer.pop()
            position = fSideBuffer.pop()
            addPreceding(position, positionStatusIdx, UpdateCachePosition)
            success = true
        }
        while (!fSideBuffer.isEmpty()) {
            positionStatusIdx = fSideBuffer.pop()
            position = fSideBuffer.pop()
            if (!addPreceding(position, positionStatusIdx, RetainCachePosition)) {
                break
            }
        }
        return success
    }

    static let RetainCachePosition = false

    static let UpdateCachePosition = true

    public func addFollowing(position: Int32, ruleStatusIdx: Int32, update: Bool): Unit {
        if (!(position > fBoundaries[Int64(fEndBufIdx)])) {
            throw AssertionError()
        }
        if (!(ruleStatusIdx <= Int32(Int16.Max))) {
            throw AssertionError()
        }
        let nextIdx = modChunkSize(fEndBufIdx + 1)
        if (nextIdx == fStartBufIdx) {
            fStartBufIdx = modChunkSize(fStartBufIdx + 6)
        }
        fBoundaries[Int64(nextIdx)] = position
        fStatuses[Int64(nextIdx)] = Int16(ruleStatusIdx)
        fEndBufIdx = nextIdx
        if (update == UpdateCachePosition) {
            fBufIdx = nextIdx
            fTextIdx = position
        } else {
            if (!(nextIdx != fBufIdx)) {
                throw AssertionError()
            }
        }
    }

    public func addPreceding(position: Int32, ruleStatusIdx: Int32, update: Bool): Bool {
        if (!(position < fBoundaries[Int64(fStartBufIdx)])) {
            throw AssertionError()
        }
        if (!(ruleStatusIdx <= Int32(Int16.Max))) {
            throw AssertionError()
        }
        let nextIdx = modChunkSize(fStartBufIdx - 1)
        if (nextIdx == fEndBufIdx) {
            if (fBufIdx == fEndBufIdx && update == RetainCachePosition) {
                return false
            }
            fEndBufIdx = modChunkSize(fEndBufIdx - 1)
        }
        fBoundaries[Int64(nextIdx)] = position
        fStatuses[Int64(nextIdx)] = Int16(ruleStatusIdx)
        fStartBufIdx = nextIdx
        if (update == UpdateCachePosition) {
            fBufIdx = nextIdx
            fTextIdx = position
        }
        return true
    }

    public func seek(pos: Int32): Bool {
        if (pos < fBoundaries[Int64(fStartBufIdx)] || pos > fBoundaries[Int64(fEndBufIdx)]) {
            return false
        }
        if (pos == fBoundaries[Int64(fStartBufIdx)]) {
            fBufIdx = fStartBufIdx
            fTextIdx = fBoundaries[Int64(fBufIdx)]
            return true
        }
        if (pos == fBoundaries[Int64(fEndBufIdx)]) {
            fBufIdx = fEndBufIdx
            fTextIdx = fBoundaries[Int64(fBufIdx)]
            return true
        }
        var min = fStartBufIdx
        var max = fEndBufIdx
        while (min != max) {
            var probe = (min + max + (if (min > max) { CACHE_SIZE } else { 0 })) / 2
            probe = modChunkSize(probe)
            if (fBoundaries[Int64(probe)] > pos) {
                max = probe
            } else {
                min = modChunkSize(probe + 1)
            }
        }
        if (!(fBoundaries[Int64(max)] > pos)) {
            throw AssertionError()
        }
        fBufIdx = modChunkSize(max - 1)
        fTextIdx = fBoundaries[Int64(fBufIdx)]
        if (!(fTextIdx <= pos)) {
            throw AssertionError()
        }
        return true
    }

    init(this_0: RuleBasedBreakIterator, src: RuleBasedBreakIterator_BreakCache) {
        this.this_0 = this_0
        fStartBufIdx = src.fStartBufIdx
        fEndBufIdx = src.fEndBufIdx
        fTextIdx = src.fTextIdx
        fBufIdx = src.fBufIdx
        fBoundaries = src.fBoundaries.clone()
        fStatuses = src.fStatuses.clone()
        fSideBuffer = DictionaryBreakEngine_DequeI()
    }

    public func dumpCache(): Unit {
        Console.stdOut.printf("fTextIdx:%d   fBufIdx:%d%n", [fTextIdx, fBufIdx])
        var i = fStartBufIdx
        while (true) {
            Console.stdOut.printf("%d  %d%n", [i, fBoundaries[Int64(i)]])
            if (i == fEndBufIdx) {
                break
            }
            i = modChunkSize(i + 1)
        }
    }

    private func modChunkSize(index: Int32): Int32 {
        return index & (CACHE_SIZE - 1)
    }

    static let CACHE_SIZE = 128

    var fStartBufIdx: Int32 = 0

    var fEndBufIdx: Int32 = 0

    var fTextIdx: Int32 = 0

    var fBufIdx: Int32 = 0

    var fBoundaries: Array<Int32> = Array<Int32>(Int64(CACHE_SIZE)) { _ => 0 }

    var fStatuses: Array<Int16> = Array<Int16>(Int64(CACHE_SIZE)) { _ => 0 }

    var fSideBuffer: DictionaryBreakEngine_DequeI = DictionaryBreakEngine_DequeI()
}
