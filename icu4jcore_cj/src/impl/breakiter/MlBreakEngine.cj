package icu4cj.impl.breakiter


class ModelIndex <: Enum<ModelIndex> {
    public static let kUWStart = ModelIndex("kUWStart", 0, 0)

    public static let kBWStart = ModelIndex("kBWStart", 1, 6)

    public static let kTWStart = ModelIndex("kTWStart", 2, 9)

    private static func _values(): Array<ModelIndex> {
        return [ModelIndex.kUWStart, ModelIndex.kBWStart, ModelIndex.kTWStart]
    }

    private static let _VALUES = ModelIndex._values()

    public static func values(): Array<ModelIndex> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): ModelIndex {
        return (TypeInfo.of<ModelIndex>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as ModelIndex
    }

    private let value: Int32

    private init(_enum_name: String, _enum_ordinal: Int32, value: Int32) {
        super(_enum_name, _enum_ordinal)
        this.value = value
    }

    public func getValue(): Int32 {
        return value
    }
}


public class MlBreakEngine {
    private static let MAX_FEATURE = 13

    private var fDigitOrOpenPunctuationOrAlphabetSet: UnicodeSet

    private var fClosePunctuationSet: UnicodeSet

    private var fModel: ArrayList<HashMap<String, Int32>> = None

    private var fNegativeSum: Int32 = 0

    public init(digitOrOpenPunctuationOrAlphabetSet: UnicodeSet, closePunctuationSet: UnicodeSet) {
        fDigitOrOpenPunctuationOrAlphabetSet = digitOrOpenPunctuationOrAlphabetSet
        fClosePunctuationSet = closePunctuationSet
        fModel = ArrayList<HashMap<String, Int32>>(Int64(MAX_FEATURE))
        var i = 0
        while (i < MAX_FEATURE) {
            fModel.append(HashMap<String, Int32>())
            i++
        }
        fNegativeSum = 0
        loadMLModel()
    }

    public func divideUpRange(inText: CharacterIterator, startPos: Int32, endPos: Int32, inString: CharacterIterator, codePointLength: Int32, charPositions: Array<Int32>, foundBreaks: DictionaryBreakEngine_DequeI): Int32 {
        if (startPos >= endPos) {
            return 0
        }
        let boundary = ArrayList<Int32>(Int64(codePointLength))
        let inputStr = transform(inString)
        let indexSize = codePointLength + 4
        let indexList = Array<Int32>(Int64(indexSize)) { _ => 0 }
        var numCodeUnits = initIndexList(inString, indexList, codePointLength)
        boundary.insert(0, 0)
        var idx = 0
        while (idx + 1 < codePointLength) {
            evaluateBreakpoint(inputStr, indexList, idx, numCodeUnits, boundary)
            if (idx + 4 < codePointLength) {
                indexList[Int64(idx + 6)] = numCodeUnits
                numCodeUnits += Character.charCount(CharacterIteration.next32(inString))
            }
            idx++
        }
        if (boundary[Int64(Int32(boundary.size) - 1)] != codePointLength) {
            boundary.append(codePointLength)
        }
        var correctedNumBreaks = 0
        var previous = -1
        let numBreaks = Int32(boundary.size)
        var i = 0
        while (i < numBreaks) {
            let pos = charPositions[Int64(boundary[Int64(i)])] + startPos
            inText.setIndex(pos)
            if (pos > previous) {
                if (pos != startPos || (pos > 0 && fClosePunctuationSet.contains(CharacterIteration.previous32(inText)))) {
                    foundBreaks.push(pos)
                    correctedNumBreaks++
                }
            }
            previous = pos
            i++
        }
        if (!foundBreaks.isEmpty() && foundBreaks.peek() == endPos) {
            inText.setIndex(endPos)
            let current = CharacterIteration.current32(inText)
            if (current != CharacterIteration.DONE32 && !fDigitOrOpenPunctuationOrAlphabetSet.contains(current)) {
                foundBreaks.pop()
                correctedNumBreaks--
            }
        }
        if (!foundBreaks.isEmpty()) {
            inText.setIndex(foundBreaks.peek())
        }
        return correctedNumBreaks
    }

    private func transform(inString: CharacterIterator): String {
        let sb = StringBuilder()
        inString.setIndex(0)
        var c = inString.first()
        while (c != CharacterIterator.DONE) {
            sb.append(c)
            c = inString.next()
        }
        return sb.toString()
    }

    private func evaluateBreakpoint(inputStr: String, indexList: Array<Int32>, startIdx: Int32, numCodeUnits: Int32, boundary: ArrayList<Int32>): Unit {
        var start = 0
        var end = 0
        var score = fNegativeSum
                i++
            }
        } while (false)
                i++
            }
        } while (false)
                i++
            }
        } while (false)
        if (score > 0) {
            boundary.append(startIdx + 1)
        }
    }

    private func initIndexList(inString: CharacterIterator, indexList: Array<Int32>, codePointLength: Int32): Int32 {
        var index = 0
        inString.setIndex(index)
        Arrays.fill(indexList, -1)
        if (codePointLength > 0) {
            indexList[2] = 0
            index += Character.charCount(CharacterIteration.current32(inString))
            if (codePointLength > 1) {
                indexList[3] = index
                index += Character.charCount(CharacterIteration.next32(inString))
                if (codePointLength > 2) {
                    indexList[4] = index
                    index += Character.charCount(CharacterIteration.next32(inString))
                    if (codePointLength > 3) {
                        indexList[5] = index
                        index += Character.charCount(CharacterIteration.next32(inString))
                    }
                }
            }
        }
        return index
    }

    private func loadMLModel(): Unit {
        var index = 0
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BRKITR_BASE_NAME, "jaml")
        initKeyValue(rb, "UW1Keys", "UW1Values", fModel[Int64(match (0) { case _ => index++; index - 1 })])
        initKeyValue(rb, "UW2Keys", "UW2Values", fModel[Int64(match (0) { case _ => index++; index - 1 })])
        initKeyValue(rb, "UW3Keys", "UW3Values", fModel[Int64(match (0) { case _ => index++; index - 1 })])
        initKeyValue(rb, "UW4Keys", "UW4Values", fModel[Int64(match (0) { case _ => index++; index - 1 })])
        initKeyValue(rb, "UW5Keys", "UW5Values", fModel[Int64(match (0) { case _ => index++; index - 1 })])
        initKeyValue(rb, "UW6Keys", "UW6Values", fModel[Int64(match (0) { case _ => index++; index - 1 })])
        initKeyValue(rb, "BW1Keys", "BW1Values", fModel[Int64(match (0) { case _ => index++; index - 1 })])
        initKeyValue(rb, "BW2Keys", "BW2Values", fModel[Int64(match (0) { case _ => index++; index - 1 })])
        initKeyValue(rb, "BW3Keys", "BW3Values", fModel[Int64(match (0) { case _ => index++; index - 1 })])
        initKeyValue(rb, "TW1Keys", "TW1Values", fModel[Int64(match (0) { case _ => index++; index - 1 })])
        initKeyValue(rb, "TW2Keys", "TW2Values", fModel[Int64(match (0) { case _ => index++; index - 1 })])
        initKeyValue(rb, "TW3Keys", "TW3Values", fModel[Int64(match (0) { case _ => index++; index - 1 })])
        initKeyValue(rb, "TW4Keys", "TW4Values", fModel[Int64(match (0) { case _ => index++; index - 1 })])
        fNegativeSum /= 2
    }

    private func initKeyValue(rb: UResourceBundle, keyName: String, valueName: String, map: HashMap<String, Int32>): Unit {
        var idx = 0
        let keyBundle = rb.get(keyName)
        let valueBundle = rb.get(valueName)
        let value = valueBundle.getIntVector()
        let iterator = keyBundle.getIterator()
        while (iterator.hasNext()) {
            fNegativeSum -= value[Int64(idx)]
            map.put(iterator.nextString(), value[Int64(match (0) { case _ => idx++; idx - 1 })])
        }
    }
}
