package icu4cj.text

abstract class CharsetRecog_2022 <: CharsetRecognizer {
    init() {
        super()
    }

    public func match(text: Array<UInt8>, textLen: Int32, escapeSequences: Array<Array<UInt8>>): Int32 {
        var i: Int32 = 0
        var j: Int32 = 0
        var escN: Int32 = 0
        var hits = 0
        var misses = 0
        var shifts = 0
        var quality: Int32 = 0

class CharsetRecog_2022_CharsetRecog_2022JP <: CharsetRecog_2022 {
    init() {
        super()
    }

    private var escapeSequences: Array<Array<UInt8>> = [[27, 36, 40, 67], [27, 36, 40, 68], [27, 36, 64], [27, 36, 65], [27, 36, 66], [27, 38, 64], [27, 40, 66], [27, 40, 72], [27, 40, 73], [27, 40, 74], [27, 46, 65], [27, 46, 70]]

    public override func getName(): String {
        return "ISO-2022-JP"
    }

    public override func match(det: CharsetDetector): CharsetMatch {
        let confidence = match(det.fInputBytes, det.fInputLen, escapeSequences)
        return if (confidence == 0) { None } else { CharsetMatch(det, this, confidence) }
    }
}


class CharsetRecog_2022_CharsetRecog_2022KR <: CharsetRecog_2022 {
    init() {
        super()
    }

    private var escapeSequences: Array<Array<UInt8>> = [[27, 36, 41, 67]]

    public override func getName(): String {
        return "ISO-2022-KR"
    }

    public override func match(det: CharsetDetector): CharsetMatch {
        let confidence = match(det.fInputBytes, det.fInputLen, escapeSequences)
        return if (confidence == 0) { None } else { CharsetMatch(det, this, confidence) }
    }
}


class CharsetRecog_2022_CharsetRecog_2022CN <: CharsetRecog_2022 {
    init() {
        super()
    }

    private var escapeSequences: Array<Array<UInt8>> = [[27, 36, 41, 65], [27, 36, 41, 71], [27, 36, 42, 72], [27, 36, 41, 69], [27, 36, 43, 73], [27, 36, 43, 74], [27, 36, 43, 75], [27, 36, 43, 76], [27, 36, 43, 77], [27, 78], [27, 79]]

    public override func getName(): String {
        return "ISO-2022-CN"
    }

    public override func match(det: CharsetDetector): CharsetMatch {
        let confidence = match(det.fInputBytes, det.fInputLen, escapeSequences)
        return if (confidence == 0) { None } else { CharsetMatch(det, this, confidence) }
    }
}
