package icu4cj.impl.breakiter


public class CjkBreakEngine <: DictionaryBreakEngine {
    private var fHangulWordSet: UnicodeSet

    private var fDigitOrOpenPunctuationOrAlphabetSet: UnicodeSet

    private var fClosePunctuationSet: UnicodeSet

    private var fDictionary: DictionaryMatcher

    private var fSkipSet: HashSet<String>

    private var fMlBreakEngine: MlBreakEngine

    private var isCj = false

    public init(korean: Bool) {
        super()
        fHangulWordSet = UnicodeSet("[\\u{ac00}-\\u{d7a3}]")
        fHangulWordSet.freeze()
        fDigitOrOpenPunctuationOrAlphabetSet = UnicodeSet("[[:Nd:][:Pi:][:Ps:][:Alphabetic:]]")
        fDigitOrOpenPunctuationOrAlphabetSet.freeze()
        fClosePunctuationSet = UnicodeSet("[[:Pc:][:Pd:][:Pe:][:Pf:][:Po:]]")
        fClosePunctuationSet.freeze()
        fSkipSet = HashSet<String>()
        fDictionary = DictionaryData.loadDictionaryFor("Hira")
        if (korean) {
            setCharacters(fHangulWordSet)
        } else {
            isCj = true
            let cjSet = UnicodeSet("[[:Han:][:Hiragana:][:Katakana:]\\u{30fc}\\u{ff70}\\u{ff9e}\\u{ff9f}]")
            setCharacters(cjSet)
            if (Bool.parseBool(ICUConfig.get("com.ibm.icu.impl.breakiter.useMLPhraseBreaking", "false"))) {
                fMlBreakEngine = MlBreakEngine(fDigitOrOpenPunctuationOrAlphabetSet, fClosePunctuationSet)
            } else {
                initializeJapanesePhraseParamater()
            }
        }
    }

    private func initializeJapanesePhraseParamater(): Unit {
        loadJapaneseExtensions()
        loadHiragana()
    }

    private func loadJapaneseExtensions(): Unit {
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BRKITR_BASE_NAME, "ja")
        let tag = "extensions"
        let bundle = rb.get(tag)
        let iterator = bundle.getIterator()
        while (iterator.hasNext()) {
            fSkipSet.put(iterator.nextString())
        }
    }

    private func loadHiragana(): Unit {
        let hiraganaWordSet = UnicodeSet("[:Hiragana:]")
        hiraganaWordSet.freeze()
        let iterator = UnicodeSetIterator(hiraganaWordSet)
        while (iterator.next()) {
            fSkipSet.put(iterator.getString())
        }
    }

    public override func equals(obj: Object): Bool {
        if (checkOptionalIs<CjkBreakEngine, Object>(obj)) {
            let other = obj
            return this.fSet.equals(other.fSet)
        }
        return false
    }

    public override func hashCode(): Int64 {
        return TypeInfo.of(this).toString()
    }

    private static let kMaxKatakanaLength = 8

    private static let kMaxKatakanaGroupLength = 20

    private static let maxSnlp = 255

    private static let kint32max = Int32.Max

    private static func getKatakanaCost(wordlength: Int32): Int32 {
        let katakanaCost = [8192, 984, 408, 240, 204, 252, 300, 372, 480]
        return if (wordlength > kMaxKatakanaLength) { 8192 } else { katakanaCost[Int64(wordlength)] }
    }

    private static func isKatakana(value: Int32): Bool {
        return (value >= 12449 && value <= 12542 && value != 12539) || (value >= 65382 && value <= 65439)
    }

    public override func divideUpDictionaryRange(inText: CharacterIterator, startPos: Int32, endPos: Int32, foundBreaks: DictionaryBreakEngine_DequeI, isPhraseBreaking: Bool): Int32 {
        if (startPos >= endPos) {
            return 0
        }
        inText.setIndex(startPos)
        let inputLength = endPos - startPos
        var charPositions: Array<Int32> = Array<Int32>(Int64(inputLength + 1)) { _ => 0 }
        let s = StringBuffer("")
        inText.setIndex(startPos)
        while (inText.getIndex() < endPos) {
            s.append(inText.current())
            inText.next()
        }
        let prenormstr: String = toString(s)
        let isNormalized = refEq(Normalizer.quickCheck(prenormstr, Normalizer.NFKC), Normalizer.YES) || Normalizer.isNormalized(prenormstr, Normalizer.NFKC, 0)
        let text: CharacterIterator
        var numCodePts = 0
        if (isNormalized) {
            text = StringCharacterIterator(prenormstr)
            var index = 0
            charPositions[0] = 0
            while (index < Int32(prenormstr.size)) {
                let codepoint = prenormstr.codePointAt(index)
                index += Character.charCount(codepoint)
                numCodePts++
                charPositions[Int64(numCodePts)] = index
            }
        } else {
            let normStr = Normalizer.normalize(prenormstr, Normalizer.NFKC)
            text = StringCharacterIterator(normStr)
            charPositions = Array<Int32>(Int64(Int32(normStr.size) + 1)) { _ => 0 }
            let normalizer = Normalizer(prenormstr, Normalizer.NFKC, 0)
            var index = 0
            charPositions[0] = 0
            while (index < normalizer.endIndex()) {
                normalizer.next()
                numCodePts++
                index = normalizer.getIndex()
                charPositions[Int64(numCodePts)] = index
            }
        }
        if (Bool.parseBool(ICUConfig.get("com.ibm.icu.impl.breakiter.useMLPhraseBreaking", "false"))) {
            if (isPhraseBreaking && isCj) {
                return fMlBreakEngine.divideUpRange(inText, startPos, endPos, text, numCodePts, charPositions, foundBreaks)
            }
        }
        let bestSnlp = Array<Int32>(Int64(numCodePts + 1)) { _ => 0 }
        bestSnlp[0] = 0
        } while (false)
        let prev = Array<Int32>(Int64(numCodePts + 1)) { _ => 0 }
        } while (false)
        let maxWordSize = 20
        let values = Array<Int32>(Int64(numCodePts)) { _ => 0 }
        let lengths = Array<Int32>(Int64(numCodePts)) { _ => 0 }
        var ix = 0
        text.setIndex(ix)
        var is_prev_katakana = false
                let maxSearchLength = if (i + maxWordSize < numCodePts) { maxWordSize } else { (numCodePts - i) }
                let count_ = Array<Int32>(1) { _ => 0 }
                fDictionary.matches(text, maxSearchLength, lengths, count_, maxSearchLength, values)
                var count = count_[0]
                text.setIndex(ix)
                if ((count == 0 || lengths[0] != 1) && CharacterIteration.current32(text) != CharacterIteration.DONE32 && !fHangulWordSet.contains(CharacterIteration.current32(text))) {
                    values[Int64(count)] = maxSnlp
                    lengths[Int64(count)] = 1
                    count++
                }
                        j++
                    }
                } while (false)
                let is_katakana = isKatakana(CharacterIteration.current32(text))
                if (!is_prev_katakana && is_katakana) {
                    var j = i + 1
                    CharacterIteration.next32(text)
                    while (j < numCodePts && (j - i) < kMaxKatakanaGroupLength && isKatakana(CharacterIteration.current32(text))) {
                        CharacterIteration.next32(text)
                        j++
                    }
                    if ((j - i) < kMaxKatakanaGroupLength) {
                        let newSnlp = bestSnlp[Int64(i)] + getKatakanaCost(j - i)
                        if (newSnlp < bestSnlp[Int64(j)]) {
                            bestSnlp[Int64(j)] = newSnlp
                            prev[Int64(j)] = i
                        }
                    }
                }
                is_prev_katakana = is_katakana
                i++
                text.setIndex(ix)
                CharacterIteration.next32(text)
            }
        } while (false)
        let t_boundary = Array<Int32>(Int64(numCodePts + 1)) { _ => 0 }
        var numBreaks = 0
        if (bestSnlp[Int64(numCodePts)] == kint32max) {
            t_boundary[Int64(numBreaks)] = numCodePts
            numBreaks++
        } else if (isPhraseBreaking) {
            t_boundary[Int64(numBreaks)] = numCodePts
            numBreaks++
            var prevIdx = numCodePts
            var codeUnitIdx = 0
            var prevCodeUnitIdx = 0
            var length = 0
                    i = prev[Int64(i)]
                }
            } while (false)
        } else {
            } while (false)
            Assert.assrt(prev[Int64(t_boundary[Int64(numBreaks - 1)])] == 0)
        }
        if (foundBreaks.size() == 0 || foundBreaks.peek() < startPos) {
            t_boundary[Int64(match (0) { case _ => numBreaks++; numBreaks - 1 })] = 0
        }
        var correctedNumBreaks = 0
        var previous = -1
                }
                previous = pos
                i--
            }
        } while (false)
        if (!foundBreaks.isEmpty() && foundBreaks.peek() == endPos) {
            if (isPhraseBreaking) {
                inText.setIndex(endPos)
                let current = CharacterIteration.current32(inText)
                if (current != CharacterIteration.DONE32 && !fDigitOrOpenPunctuationOrAlphabetSet.contains(current)) {
                    foundBreaks.pop()
                    correctedNumBreaks--
                }
            } else {
                foundBreaks.pop()
                correctedNumBreaks--
            }
        }
        if (!foundBreaks.isEmpty()) {
            inText.setIndex(foundBreaks.peek())
        }
        return correctedNumBreaks
    }

    private func getPatternFromText(text: CharacterIterator, sb: StringBuffer, start: Int32, length: Int32): String {
        sb.setLength(0)
        if (length > 0) {
            text.setIndex(start)
            sb.append(text.current())
            var i = 1
            while (i < length) {
                sb.append(text.next())
                i++
            }
        }
        return toString(sb)
    }
}
