package icu4cj.text

abstract class CharsetRecog_Unicode <: CharsetRecognizer {
    init() {
        super()
    }

    public override func getName(): String

    public override func match(det: CharsetDetector): CharsetMatch

    static func codeUnit16FromBytes(hi: UInt8, lo: UInt8): Int32 {
        return (shl((Int32(hi) & 255), 8)) | (Int32(lo) & 255)
    }

    static func adjustConfidence(codeUnit: Int32, confidence: Int32): Int32 {
        var tempconfidence = confidence
        if (codeUnit == 0) {
            tempconfidence -= 10
        } else if ((codeUnit >= 32 && codeUnit <= 255) || codeUnit == 10) {
            tempconfidence += 10
        }
        if (tempconfidence < 0) {
            tempconfidence = 0
        } else if (tempconfidence > 100) {
            tempconfidence = 100
        }
        return tempconfidence
    }
}


class CharsetRecog_Unicode_CharsetRecog_UTF_16_BE <: CharsetRecog_Unicode {
    init() {
        super()
    }

    public override func getName(): String {
        return "UTF-16BE"
    }

    public override func match(det: CharsetDetector): CharsetMatch {
        let input = det.fRawInput
        var confidence = 10
        let bytesToCheck = min(Int32(input.size), 30)
        var charIndex = 0
        while (charIndex < bytesToCheck - 1) {
            let codeUnit = codeUnit16FromBytes(input[Int64(charIndex)], input[Int64(charIndex + 1)])
            if (charIndex == 0 && codeUnit == 65279) {
                confidence = 100
                break
            }
            confidence = adjustConfidence(codeUnit, confidence)
            if (confidence == 0 || confidence == 100) {
                break
            }
            charIndex += 2
        }
        if (bytesToCheck < 4 && confidence < 100) {
            confidence = 0
        }
        if (confidence > 0) {
            return CharsetMatch(det, this, confidence)
        }
        return None
    }
}


class CharsetRecog_Unicode_CharsetRecog_UTF_16_LE <: CharsetRecog_Unicode {
    init() {
        super()
    }

    public override func getName(): String {
        return "UTF-16E"
    }

    public override func match(det: CharsetDetector): CharsetMatch {
        let input = det.fRawInput
        var confidence = 10
        let bytesToCheck = min(Int32(input.size), 30)
        var charIndex = 0
        while (charIndex < bytesToCheck - 1) {
            let codeUnit = codeUnit16FromBytes(input[Int64(charIndex + 1)], input[Int64(charIndex)])
            if (charIndex == 0 && codeUnit == 65279) {
                confidence = 100
                break
            }
            confidence = adjustConfidence(codeUnit, confidence)
            if (confidence == 0 || confidence == 100) {
                break
            }
            charIndex += 2
        }
        if (bytesToCheck < 4 && confidence < 100) {
            confidence = 0
        }
        if (confidence > 0) {
            return CharsetMatch(det, this, confidence)
        }
        return None
    }
}


abstract class CharsetRecog_Unicode_CharsetRecog_UTF_32 <: CharsetRecog_Unicode {
    init() {
        super()
    }

    public func getChar(input: Array<UInt8>, index: Int32): Int32

    public override func getName(): String

    public override func match(det: CharsetDetector): CharsetMatch {
        let input = det.fRawInput
        let limit = (det.fRawLength / 4) * 4
        var numValid = 0
        var numInvalid = 0
        var hasBOM = false
        var confidence = 0
        if (limit == 0) {
            return None
        }
        if (getChar(input, 0) == 65279) {
            hasBOM = true
        }
        var i = 0
        while (i < limit) {
            let ch = getChar(input, i)
            if (ch < 0 || ch >= 1114111 || (ch >= 55296 && ch <= 57343)) {
                numInvalid += 1
            } else {
                numValid += 1
            }
            i += 4
        }
        if (hasBOM && numInvalid == 0) {
            confidence = 100
        } else if (hasBOM && numValid > numInvalid * 10) {
            confidence = 80
        } else if (numValid > 3 && numInvalid == 0) {
            confidence = 100
        } else if (numValid > 0 && numInvalid == 0) {
            confidence = 80
        } else if (numValid > numInvalid * 10) {
            confidence = 25
        }
        return if (confidence == 0) { None } else { CharsetMatch(det, this, confidence) }
    }
}


class CharsetRecog_Unicode_CharsetRecog_UTF_32_BE <: CharsetRecog_Unicode_CharsetRecog_UTF_32 {
    init() {
        super()
    }

    public override func getChar(input: Array<UInt8>, index: Int32): Int32 {
        return shl((Int32(input[Int64(index + 0)]) & 255), 24) | shl((Int32(input[Int64(index + 1)]) & 255), 16) | shl((Int32(input[Int64(index + 2)]) & 255), 8) | (Int32(input[Int64(index + 3)]) & 255)
    }

    public override func getName(): String {
        return "UTF-32BE"
    }
}


class CharsetRecog_Unicode_CharsetRecog_UTF_32_LE <: CharsetRecog_Unicode_CharsetRecog_UTF_32 {
    init() {
        super()
    }

    public override func getChar(input: Array<UInt8>, index: Int32): Int32 {
        return shl((Int32(input[Int64(index + 3)]) & 255), 24) | shl((Int32(input[Int64(index + 2)]) & 255), 16) | shl((Int32(input[Int64(index + 1)]) & 255), 8) | (Int32(input[Int64(index + 0)]) & 255)
    }

    public override func getName(): String {
        return "UTF-32E"
    }
}
