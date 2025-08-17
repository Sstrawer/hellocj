package icu4cj.impl.breakiter


public class LSTMBreakEngine <: DictionaryBreakEngine {
    static func make2DArray(data: Array<Int32>, start: Int32, d1: Int32, d2: Int32): Array<Array<Float32>> {
        var tempstart = start
        let bytes = Array<UInt8>(4) { _ => 0 }
        let result = Array<Array<Float32>>(Int64(d1)) { _ => Array<Float32>(Int64(d2)) { _ => 0.0 } }
        var i = 0
        while (i < d1) {
            var j = 0
            while (j < d2) {
                let d = data[Int64(match (0) { case _ => tempstart++; tempstart - 1 })]
                bytes[0] = UInt8(shr(d, 24))
                bytes[1] = UInt8(shr(d, 16))
                bytes[2] = UInt8(shr(d, 8))
                bytes[3] = UInt8(d)
                result[Int64(i)][Int64(j)] = ByteArrayStream.wrap(bytes).order(ByteOrder.BIG_ENDIAN).getFloat()
                j++
            }
            i++
        }
        return result
    }

    static func make1DArray(data: Array<Int32>, start: Int32, d1: Int32): Array<Float32> {
        var tempstart = start
        let bytes = Array<UInt8>(4) { _ => 0 }
        let result = Array<Float32>(Int64(d1)) { _ => 0.0 }
        var i = 0
        while (i < d1) {
            let d = data[Int64(match (0) { case _ => tempstart++; tempstart - 1 })]
            bytes[0] = UInt8(shr(d, 24))
            bytes[1] = UInt8(shr(d, 16))
            bytes[2] = UInt8(shr(d, 8))
            bytes[3] = UInt8(d)
            result[Int64(i)] = ByteArrayStream.wrap(bytes).order(ByteOrder.BIG_ENDIAN).getFloat()
            i++
        }
        return result
    }

    private static let MIN_WORD = 2u8

    private static let MIN_WORD_SPAN = UInt8(Int32(MIN_WORD) * 2)

    private let fData: LSTMBreakEngine_LSTMData

    private var fScript: Int32 = 0

    private let fVectorizer: LSTMBreakEngine_Vectorizer

    private func makeVectorizer(data: LSTMBreakEngine_LSTMData): LSTMBreakEngine_Vectorizer {
        match (data.fType) {
            case LSTMBreakEngine_EmbeddingType.CODE_POINTS => return LSTMBreakEngine_CodePointsVectorizer(this, data.fDict)
            case LSTMBreakEngine_EmbeddingType.GRAPHEME_CLUSTER => return LSTMBreakEngine_GraphemeClusterVectorizer(this, data.fDict)
            case _ => return None
        }
    }

    public init(script: Int32, set: UnicodeSet, data: LSTMBreakEngine_LSTMData) {
        super()
        setCharacters(set)
        this.fScript = script
        this.fData = data
        this.fVectorizer = makeVectorizer(this.fData)
    }

    public override func hashCode(): Int64 {
        return TypeInfo.of(this).toString()
    }

    public override func handles(c: Int32): Bool {
        return fScript == UCharacter.getIntPropertyValue(c, UProperty.SCRIPT)
    }

    private static func addDotProductTo(a: Array<Float32>, b: Array<Array<Float32>>, result: Array<Float32>): Unit {
        if (!(Int32(a.size) == Int32(b.size))) {
            throw AssertionError()
        }
        if (!(Int32(b[0].size) == Int32(result.size))) {
            throw AssertionError()
        }
        var i = 0
        while (i < Int32(result.size)) {
            var j = 0
            while (j < Int32(a.size)) {
                result[Int64(i)] += a[Int64(j)] * b[Int64(j)][Int64(i)]
                j++
            }
            i++
        }
    }

    private static func addTo(a: Array<Float32>, result: Array<Float32>): Unit {
        if (!(Int32(a.size) == Int32(result.size))) {
            throw AssertionError()
        }
        var i = 0
        while (i < Int32(result.size)) {
            result[Int64(i)] += a[Int64(i)]
            i++
        }
    }

    private static func hadamardProductTo(a: Array<Float32>, result: Array<Float32>): Unit {
        if (!(Int32(a.size) == Int32(result.size))) {
            throw AssertionError()
        }
        var i = 0
        while (i < Int32(result.size)) {
            result[Int64(i)] *= a[Int64(i)]
            i++
        }
    }

    private static func addHadamardProductTo(a: Array<Float32>, b: Array<Float32>, result: Array<Float32>): Unit {
        if (!(Int32(a.size) == Int32(result.size))) {
            throw AssertionError()
        }
        if (!(Int32(b.size) == Int32(result.size))) {
            throw AssertionError()
        }
        var i = 0
        while (i < Int32(result.size)) {
            result[Int64(i)] += a[Int64(i)] * b[Int64(i)]
            i++
        }
    }

    private static func sigmoid(result: Array<Float32>, start: Int32, length: Int32): Unit {
        if (!(start < Int32(result.size))) {
            throw AssertionError()
        }
        if (!(start + length <= Int32(result.size))) {
            throw AssertionError()
        }
        var i = start
        while (i < start + length) {
            result[Int64(i)] = Float32(1.0 / (1.0 + Float64(exp(-result[Int64(i)]))))
            i++
        }
    }

    private static func tanh(result: Array<Float32>, start: Int32, length: Int32): Unit {
        if (!(start < Int32(result.size))) {
            throw AssertionError()
        }
        if (!(start + length <= Int32(result.size))) {
            throw AssertionError()
        }
        var i = start
        while (i < start + length) {
            result[Int64(i)] = Float32(Math.tanh(Float64(result[Int64(i)])))
            i++
        }
    }

    private static func maxIndex(data: Array<Float32>): Int32 {
        var index = 0
        var max = data[0]
        var i = 1
        while (i < Int32(data.size)) {
            if (data[Int64(i)] > max) {
                max = data[Int64(i)]
                index = i
            }
            i++
        }
        return index
    }

    private func compute(W: Array<Array<Float32>>, U: Array<Array<Float32>>, B: Array<Float32>, x: Array<Float32>, h: Array<Float32>, c: Array<Float32>): Array<Float32> {
        var temph = h
        let ifco = B.clone(0.. Int32(B.size))
        addDotProductTo(x, W, ifco)
        let hU = Array<Float32>(B.size) { _ => 0.0 }
        addDotProductTo(temph, U, ifco)
        let hunits = Int32(B.size) / 4
        sigmoid(ifco, 0 * hunits, hunits)
        sigmoid(ifco, 1 * hunits, hunits)
        tanh(ifco, 2 * hunits, hunits)
        sigmoid(ifco, 3 * hunits, hunits)
        hadamardProductTo(ifco.clone(hunits..2 * hunits), c)
        addHadamardProductTo(Arrays.copyOf(ifco, hunits), ifco.clone(2 * hunits..3 * hunits), c)
        temph = c.clone(0.. Int32(c.size))
        tanh(temph, 0, Int32(temph.size))
        hadamardProductTo(ifco.clone(3 * hunits..4 * hunits), temph)
        return temph
    }

    public override func divideUpDictionaryRange(fIter: CharacterIterator, rangeStart: Int32, rangeEnd: Int32, foundBreaks: DictionaryBreakEngine_DequeI, isPhraseBreaking: Bool): Int32 {
        let beginSize = foundBreaks.size()
        if ((rangeEnd - rangeStart) < Int32(MIN_WORD_SPAN)) {
            return 0
        }
        let offsets = ArrayList<Int32>(Int64(rangeEnd - rangeStart))
        let indicies = ArrayList<Int32>(Int64(rangeEnd - rangeStart))
        fVectorizer.vectorize(fIter, rangeStart, rangeEnd, offsets, indicies)
        let inputSeqLength = Int32(indicies.size)
        let hunits = Int32(this.fData.fForwardU.size)
        var c: Array<Float32> = Array<Float32>(Int64(hunits)) { _ => 0.0 }
        let hBackward = Array<Array<Float32>>(Int64(inputSeqLength)) { _ => Array<Float32>(Int64(hunits)) { _ => 0.0 } }
                hBackward[Int64(i)] = compute(this.fData.fBackwardW, this.fData.fBackwardU, this.fData.fBackwardB, this.fData.fEmbedding[Int64(indicies[Int64(i)])], hBackward[Int64(i)], c)
                i--
            }
        } while (false)
        c = Array<Float32>(Int64(hunits)) { _ => 0.0 }
        var forwardH: Array<Float32> = Array<Float32>(Int64(hunits)) { _ => 0.0 }
        let both = Array<Float32>(Int64(2 * hunits)) { _ => 0.0 }
                }
                i++
            }
        } while (false)
        return foundBreaks.size() - beginSize
    }

    public static func createData(bundle: UResourceBundle): LSTMBreakEngine_LSTMData {
        return LSTMBreakEngine_LSTMData(bundle)
    }

    private static func defaultLSTM(script: Int32): String {
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BRKITR_BASE_NAME)
        return rb.getStringWithFallback("lstm/" + (UScript.getShortName(script)))
    }

    public static func createData(script: Int32): LSTMBreakEngine_LSTMData {
        if (script != UScript.KHMER && script != UScript.LAO && script != UScript.MYANMAR && script != UScript.THAI) {
            return None
        }
        var name = defaultLSTM(script)
        name = name[0..Int64(indexOfWrap(name.indexOf(".")))]
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BRKITR_BASE_NAME, name, ICUResourceBundle.ICU_DATA_CLASS_LOADER)
        return createData(rb)
    }

    public static func create(script: Int32, data: LSTMBreakEngine_LSTMData): LSTMBreakEngine {
        let setExpr: String = "[[:" + (UScript.getShortName(script)) + ":]&[:LineBreak=SA:]]"
        let set = UnicodeSet()
        set.applyPattern(setExpr)
        set.compact()
        return LSTMBreakEngine(script, set, data)
    }
}


public class LSTMBreakEngine_EmbeddingType <: Enum<LSTMBreakEngine_EmbeddingType> {
    public static let UNKNOWN = LSTMBreakEngine_EmbeddingType("UNKNOWN", 0)

    public static let CODE_POINTS = LSTMBreakEngine_EmbeddingType("CODE_POINTS", 1)

    public static let GRAPHEME_CLUSTER = LSTMBreakEngine_EmbeddingType("GRAPHEME_CLUSTER", 2)

    private static func _values(): Array<LSTMBreakEngine_EmbeddingType> {
        return [LSTMBreakEngine_EmbeddingType.UNKNOWN, LSTMBreakEngine_EmbeddingType.CODE_POINTS, LSTMBreakEngine_EmbeddingType.GRAPHEME_CLUSTER]
    }

    private static let _VALUES = LSTMBreakEngine_EmbeddingType._values()

    public static func values(): Array<LSTMBreakEngine_EmbeddingType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): LSTMBreakEngine_EmbeddingType {
        return (TypeInfo.of<LSTMBreakEngine_EmbeddingType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as LSTMBreakEngine_EmbeddingType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class LSTMBreakEngine_LSTMClass <: Enum<LSTMBreakEngine_LSTMClass> {
    public static let BEGIN = LSTMBreakEngine_LSTMClass("BEGIN", 0)

    public static let INSIDE = LSTMBreakEngine_LSTMClass("INSIDE", 1)

    public static let END = LSTMBreakEngine_LSTMClass("END", 2)

    public static let SINGLE = LSTMBreakEngine_LSTMClass("SINGLE", 3)

    private static func _values(): Array<LSTMBreakEngine_LSTMClass> {
        return [LSTMBreakEngine_LSTMClass.BEGIN, LSTMBreakEngine_LSTMClass.INSIDE, LSTMBreakEngine_LSTMClass.END, LSTMBreakEngine_LSTMClass.SINGLE]
    }

    private static let _VALUES = LSTMBreakEngine_LSTMClass._values()

    public static func values(): Array<LSTMBreakEngine_LSTMClass> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): LSTMBreakEngine_LSTMClass {
        return (TypeInfo.of<LSTMBreakEngine_LSTMClass>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as LSTMBreakEngine_LSTMClass
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class LSTMBreakEngine_LSTMData {

    public init(rb: UResourceBundle) {
        let embeddings = rb.get("embeddings").getInt()
        let hunits = rb.get("hunits").getInt()
        this.fType = LSTMBreakEngine_EmbeddingType.UNKNOWN
        this.fName = rb.get("model").getString()
        let typeString = rb.get("type").getString()
        if (typeString == "codepoints") {
            this.fType = LSTMBreakEngine_EmbeddingType.CODE_POINTS
        } else if (typeString == "graphclust") {
            this.fType = LSTMBreakEngine_EmbeddingType.GRAPHEME_CLUSTER
        }
        let dict = rb.get("dict").getStringArray()
        let data = rb.get("data").getIntVector()
        let dataLen = Int32(data.size)
        let numIndex = Int32(dict.size)
        fDict = HashMap<String, Int32>(Int64(numIndex + 1))
        var idx = 0
        for (embedding in dict) {
            fDict.put(embedding, match (0) { case _ => idx++; idx - 1 })
        }
        let mat1Size = (numIndex + 1) * embeddings
        let mat2Size = embeddings * 4 * hunits
        let mat3Size = hunits * 4 * hunits
        let mat4Size = 4 * hunits
        let mat5Size = mat2Size
        let mat6Size = mat3Size
        let mat7Size = mat4Size
        let mat8Size = 2 * hunits * 4
        let mat9Size = 4
        if (!(dataLen == mat1Size + mat2Size + mat3Size + mat4Size + mat5Size + mat6Size + mat7Size + mat8Size + mat9Size)) {
            throw AssertionError()
        }
        var start = 0
        this.fEmbedding = LSTMBreakEngine.make2DArray(data, start, (numIndex + 1), embeddings)
        start += mat1Size
        this.fForwardW = LSTMBreakEngine.make2DArray(data, start, embeddings, 4 * hunits)
        start += mat2Size
        this.fForwardU = LSTMBreakEngine.make2DArray(data, start, hunits, 4 * hunits)
        start += mat3Size
        this.fForwardB = LSTMBreakEngine.make1DArray(data, start, 4 * hunits)
        start += mat4Size
        this.fBackwardW = LSTMBreakEngine.make2DArray(data, start, embeddings, 4 * hunits)
        start += mat5Size
        this.fBackwardU = LSTMBreakEngine.make2DArray(data, start, hunits, 4 * hunits)
        start += mat6Size
        this.fBackwardB = LSTMBreakEngine.make1DArray(data, start, 4 * hunits)
        start += mat7Size
        this.fOutputW = LSTMBreakEngine.make2DArray(data, start, 2 * hunits, 4)
        start += mat8Size
        this.fOutputB = LSTMBreakEngine.make1DArray(data, start, 4)
    }

    public var fType: LSTMBreakEngine_EmbeddingType

    public var fName: String

    public var fDict: Map<String, Int32> = None

    public var fEmbedding: Array<Array<Float32>>

    public var fForwardW: Array<Array<Float32>>

    public var fForwardU: Array<Array<Float32>>

    public var fForwardB: Array<Float32>

    public var fBackwardW: Array<Array<Float32>>

    public var fBackwardU: Array<Array<Float32>>

    public var fBackwardB: Array<Float32>

    public var fOutputW: Array<Array<Float32>>

    public var fOutputB: Array<Float32>
}


abstract class LSTMBreakEngine_Vectorizer {
    public init(this_0: LSTMBreakEngine, dict: Map<String, Int32>) {
        this.fDict = dict
    }

    public func vectorize(fIter: CharacterIterator, rangeStart: Int32, rangeEnd: Int32, offsets: ArrayList<Int32>, indicies: ArrayList<Int32>): Unit

    protected func getIndex(token: String): Int32 {
        let res = fDict.get(token)
        return if (res.isNone()) { Int32(fDict.size) } else { res }
    }

    private var fDict: Map<String, Int32> = None
}


class LSTMBreakEngine_CodePointsVectorizer <: LSTMBreakEngine_Vectorizer {
    public init(this_0: LSTMBreakEngine, dict: Map<String, Int32>) {
        super(this_0, dict)
    }

    public override func vectorize(fIter: CharacterIterator, rangeStart: Int32, rangeEnd: Int32, offsets: ArrayList<Int32>, indicies: ArrayList<Int32>): Unit {
        fIter.setIndex(rangeStart)
        var c = fIter.current()
        while (c != CharacterIterator.DONE && fIter.getIndex() < rangeEnd) {
            offsets.append(fIter.getIndex())
            indicies.append(getIndex(c.toString()))
            c = fIter.next()
        }
    }
}


class LSTMBreakEngine_GraphemeClusterVectorizer <: LSTMBreakEngine_Vectorizer {
    public init(this_0: LSTMBreakEngine, dict: Map<String, Int32>) {
        super(this_0, dict)
    }

    private func substring(text: CharacterIterator, startPos: Int32, endPos: Int32): String {
        let saved = text.getIndex()
        text.setIndex(startPos)
        let sb = StringBuilder()
        var c = text.current()
        while (c != CharacterIterator.DONE && text.getIndex() < endPos) {
            sb.append(c)
            c = text.next()
        }
        text.setIndex(saved)
        return sb.toString()
    }

    public override func vectorize(text: CharacterIterator, startPos: Int32, endPos: Int32, offsets: ArrayList<Int32>, indicies: ArrayList<Int32>): Unit {
        let iter = BreakIterator.getCharacterInstance()
        iter.setText(text)
        var last = iter.next(startPos)
        var curr = iter.next()
        while (curr != BreakIterator.DONE && curr <= endPos) {
            offsets.append(last)
            let segment = substring(text, last, curr)
            let index = getIndex(segment)
            indicies.append(index)
            last = curr
            curr = iter.next()
        }
    }
}
