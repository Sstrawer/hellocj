package icu4cj.impl.breakiter

public class ThaiBreakEngine <: DictionaryBreakEngine {
    private static let THAI_LOOKAHEAD = 3u8

    private static let THAI_ROOT_COMBINE_THRESHOLD = 3u8

    private static let THAI_PREFIX_COMBINE_THRESHOLD = 3u8

    private static let THAI_PAIYANNOI = Char(3631)

    private static let THAI_MAIYAMOK = Char(3654)

    private static let THAI_MIN_WORD = 2u8

    private static let THAI_MIN_WORD_SPAN = UInt8(Int32(THAI_MIN_WORD) * 2)

    private var fDictionary: DictionaryMatcher

    private var fEndWordSet: UnicodeSet

    private var fBeginWordSet: UnicodeSet

    private var fSuffixSet: UnicodeSet

    private var fMarkSet: UnicodeSet

    public init() {
        super()
        let thaiWordSet = UnicodeSet("[[:Thai:]&[:LineBreak=SA:]]")
        fMarkSet = UnicodeSet("[[:Thai:]&[:LineBreak=SA:]&[:M:]]")
        fMarkSet.add(32)
        fBeginWordSet = UnicodeSet([3585, 3630, 3648, 3652])
        fSuffixSet = UnicodeSet()
        fSuffixSet.add(Int32(UInt32(THAI_PAIYANNOI)))
        fSuffixSet.add(Int32(UInt32(THAI_MAIYAMOK)))
        thaiWordSet.compact()
        fEndWordSet = UnicodeSet(thaiWordSet)
        fEndWordSet.remove(3633)
        fEndWordSet.remove(3648, 3652)
        fMarkSet.compact()
        fEndWordSet.compact()
        fBeginWordSet.compact()
        fSuffixSet.compact()
        thaiWordSet.freeze()
        fMarkSet.freeze()
        fEndWordSet.freeze()
        fBeginWordSet.freeze()
        fSuffixSet.freeze()
        setCharacters(thaiWordSet)
        fDictionary = DictionaryData.loadDictionaryFor("Thai")
    }

    public override func equals(obj: Object): Bool {
        return checkOptionalIs<ThaiBreakEngine, Object>(obj)
    }

    public override func hashCode(): Int64 {
        return TypeInfo.of(this).toString()
    }

    public override func handles(c: Int32): Bool {
        let script = UCharacter.getIntPropertyValue(c, UProperty.SCRIPT)
        return (script == UScript.THAI)
    }

    public override func divideUpDictionaryRange(fIter: CharacterIterator, rangeStart: Int32, rangeEnd: Int32, foundBreaks: DictionaryBreakEngine_DequeI, isPhraseBreaking: Bool): Int32 {
        if ((rangeEnd - rangeStart) < Int32(THAI_MIN_WORD_SPAN)) {
            return 0
        }
        var wordsFound = 0
        var wordLength: Int32 = 0
        let words = Array<DictionaryBreakEngine_PossibleWord>(Int64(THAI_LOOKAHEAD))
        var i = 0
        while (i < Int32(THAI_LOOKAHEAD)) {
            words[Int64(i)] = DictionaryBreakEngine_PossibleWord()
            i++
        }
        var uc: Int32 = 0
        fIter.setIndex(rangeStart)
        var current: Int32 = 0
        while ((match (0) { case _ => current = fIter.getIndex(); current }) < rangeEnd) {
            wordLength = 0
            let candidates = words[Int64(wordsFound % Int32(THAI_LOOKAHEAD))].candidates(fIter, fDictionary, rangeEnd)
            if (candidates == 1) {
                wordLength = words[Int64(wordsFound % Int32(THAI_LOOKAHEAD))].acceptMarked(fIter)
                wordsFound += 1
            } else if (candidates > 1) {
                if (fIter.getIndex() < rangeEnd) {
