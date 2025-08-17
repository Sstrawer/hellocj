package icu4cj.text

class CharsetRecog_UTF8 <: CharsetRecognizer {
    init() {
        super()
    }

    public override func getName(): String {
        return "UTF-8"
    }

    public override func match(det: CharsetDetector): CharsetMatch {
        var hasBOM = false
        var numValid = 0
        var numInvalid = 0
        let input = det.fRawInput
        var i: Int32 = 0
        var trailBytes = 0
        var confidence: Int32 = 0
        if (det.fRawLength >= 3 && (Int32(input[0]) & 255) == 239 && (Int32(input[1]) & 255) == 187 && (Int32(input[2]) & 255) == 191) {
            hasBOM = true
        }
        i = 0
        while (i < det.fRawLength) {
            var b = Int32(input[Int64(i)])
            if ((b & 128) == 0) {
                continue
            }
            if ((b & 224) == 192) {
                trailBytes = 1
            } else if ((b & 240) == 224) {
                trailBytes = 2
            } else if ((b & 248) == 240) {
                trailBytes = 3
            } else {
                numInvalid++
                continue
            }
            while (true) {
                i++
                if (i >= det.fRawLength) {
                    break
                }
                b = Int32(input[Int64(i)])
                if ((b & 192) != 128) {
                    numInvalid++
                    break
                }
                if (match (0) { case _ => trailBytes--; trailBytes } == 0) {
                    numValid++
                    break
                }
            }
            i++
        }
        confidence = 0
        if (hasBOM && numInvalid == 0) {
            confidence = 100
        } else if (hasBOM && numValid > numInvalid * 10) {
            confidence = 80
        } else if (numValid > 3 && numInvalid == 0) {
            confidence = 100
        } else if (numValid > 0 && numInvalid == 0) {
            confidence = 80
        } else if (numValid == 0 && numInvalid == 0) {
            confidence = 15
        } else if (numValid > numInvalid * 10) {
            confidence = 25
        }
        return if (confidence == 0) { None } else { CharsetMatch(det, this, confidence) }
    }
}
