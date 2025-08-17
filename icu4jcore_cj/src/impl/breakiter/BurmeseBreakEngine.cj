package icu4cj.impl.breakiter

public class BurmeseBreakEngine <: DictionaryBreakEngine {
    private static let BURMESE_LOOKAHEAD = 3u8

    private static let BURMESE_ROOT_COMBINE_THRESHOLD = 3u8

    private static let BURMESE_PREFIX_COMBINE_THRESHOLD = 3u8

    private static let BURMESE_MIN_WORD = 2u8

    private var fDictionary: DictionaryMatcher

    private var fEndWordSet: UnicodeSet

    private var fBeginWordSet: UnicodeSet

    private var fMarkSet: UnicodeSet

    public init() {
        super()
        fBeginWordSet = UnicodeSet(4096, 4138)
        fEndWordSet = UnicodeSet("[[:Mymr:]&[:LineBreak=SA:]]")
        fMarkSet = UnicodeSet("[[:Mymr:]&[:LineBreak=SA:]&[:M:]]")
        fMarkSet.add(32)
        fMarkSet.compact()
        fEndWordSet.compact()
        fBeginWordSet.compact()
        fMarkSet.freeze()
        fEndWordSet.freeze()
        fBeginWordSet.freeze()
        setCharacters(fEndWordSet)
        fDictionary = DictionaryData.loadDictionaryFor("Mymr")
    }

    public override func equals(obj: Object): Bool {
        return checkOptionalIs<BurmeseBreakEngine, Object>(obj)
    }

    public override func hashCode(): Int64 {
        return TypeInfo.of(this).toString()
    }

    public override func handles(c: Int32): Bool {
        let script = UCharacter.getIntPropertyValue(c, UProperty.SCRIPT)
        return (script == UScript.MYANMAR)
    }

    public override func divideUpDictionaryRange(fIter: CharacterIterator, rangeStart: Int32, rangeEnd: Int32, foundBreaks: DictionaryBreakEngine_DequeI, isPhraseBreaking: Bool): Int32 {
        if ((rangeEnd - rangeStart) < Int32(BURMESE_MIN_WORD)) {
            return 0
        }
        var wordsFound = 0
        var wordLength: Int32 = 0
        var current: Int32 = 0
        let words = Array<DictionaryBreakEngine_PossibleWord>(Int64(BURMESE_LOOKAHEAD))
        var i = 0
        while (i < Int32(BURMESE_LOOKAHEAD)) {
            words[Int64(i)] = DictionaryBreakEngine_PossibleWord()
            i++
        }
        var uc: Int32 = 0
        fIter.setIndex(rangeStart)
        while ((match (0) { case _ => current = fIter.getIndex(); current }) < rangeEnd) {
            wordLength = 0
            let candidates = words[Int64(wordsFound % Int32(BURMESE_LOOKAHEAD))].candidates(fIter, fDictionary, rangeEnd)
            if (candidates == 1) {
                wordLength = words[Int64(wordsFound % Int32(BURMESE_LOOKAHEAD))].acceptMarked(fIter)
                wordsFound += 1
            } else if (candidates > 1) {
                var foundBest = false
                if (fIter.getIndex() < rangeEnd) {
                            } while (words[Int64((wordsFound + 1) % Int32(BURMESE_LOOKAHEAD))].backUp(fIter))
                        }
                    } while (words[Int64(wordsFound % Int32(BURMESE_LOOKAHEAD))].backUp(fIter) && !foundBest)
                }
                wordLength = words[Int64(wordsFound % Int32(BURMESE_LOOKAHEAD))].acceptMarked(fIter)
                wordsFound += 1
            }
            if (fIter.getIndex() < rangeEnd && wordLength < Int32(BURMESE_ROOT_COMBINE_THRESHOLD)) {
                if (words[Int64(wordsFound % Int32(BURMESE_LOOKAHEAD))].candidates(fIter, fDictionary, rangeEnd) <= 0 && (wordLength == 0 || words[Int64(wordsFound % Int32(BURMESE_LOOKAHEAD))].longestPrefix() < Int32(BURMESE_PREFIX_COMBINE_THRESHOLD))) {
                    var remaining = rangeEnd - (current + wordLength)
                    var pc = Int32(UInt32(fIter.current()))
                    var chars = 0
                    while (true) {
                        fIter.next()
                        uc = Int32(UInt32(fIter.current()))
                        chars += 1
                        if (match (0) { case _ => remaining--; remaining } <= 0) {
                            break
                        }
                        if (fEndWordSet.contains(pc) && fBeginWordSet.contains(uc)) {
                            let candidate = words[Int64((wordsFound + 1) % Int32(BURMESE_LOOKAHEAD))].candidates(fIter, fDictionary, rangeEnd)
                            fIter.setIndex(current + wordLength + chars)
                            if (candidate > 0) {
                                break
                            }
                        }
                        pc = uc
                    }
                    if (wordLength <= 0) {
                        wordsFound += 1
                    }
                    wordLength += chars
                } else {
                    fIter.setIndex(current + wordLength)
                }
            }
            var currPos: Int32 = 0
            while ((match (0) { case _ => currPos = fIter.getIndex(); currPos }) < rangeEnd && fMarkSet.contains(Int32(UInt32(fIter.current())))) {
                fIter.next()
                wordLength += fIter.getIndex() - currPos
            }
            if (wordLength > 0) {
                foundBreaks.push(current + wordLength)
            }
        }
        if (foundBreaks.peek() >= rangeEnd) {
            foundBreaks.pop()
            wordsFound -= 1
        }
        return wordsFound
    }
}
