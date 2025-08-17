package icu4cj.text


public class CharsetDetector {

    public func setDeclaredEncoding(encoding: String): CharsetDetector {
        fDeclaredEncoding = encoding
        return this
    }

    public func setText(input: Array<UInt8>): CharsetDetector {
        fRawInput = input
        fRawLength = Int32(input.size)
        return this
    }

    private static let kBufSize = 8000

    public func setText(input: InputStream): CharsetDetector {
        fInputStream = input
        fInputStream.mark(kBufSize)
        fRawInput = Array<UInt8>(Int64(kBufSize)) { _ => 0 }
        fRawLength = 0
        var remainingLength = kBufSize
        while (remainingLength > 0) {
            let bytesRead = readFixedBufferFromInputStream(fInputStream, fRawInput, fRawLength, remainingLength)
            if (bytesRead <= 0) {
                break
            }
            fRawLength += bytesRead
            remainingLength -= bytesRead
        }
        fInputStream.reset()
        return this
    }

    public func detect(): CharsetMatch {
        let matches = detectAll()
        if (matches.isNone() || Int32(matches.size) == 0) {
            return None
        }
        return matches[0]
    }

    public func detectAll(): Array<CharsetMatch> {
        let matches = ArrayList<CharsetMatch>()
        MungeInput()
        var i = 0
        while (i < Int32(ALL_CS_RECOGNIZERS.size)) {
            let rcinfo = ALL_CS_RECOGNIZERS[Int64(i)]
            let active = if (fEnabledRecognizers.isSome()) { fEnabledRecognizers[Int64(i)] } else { rcinfo.isDefaultEnabled }
            if (active) {
                let m = rcinfo.recognizer.match(this)
                if (m.isSome()) {
                    matches.append(m)
                }
            }
            i++
        }
        Collections.sort(matches)
        Collections.reverse(matches)
        var resultArray: Array<CharsetMatch> = Array<CharsetMatch>(matches.size)
        resultArray = matches.toArray(resultArray)
        return resultArray
    }

    public func getReader(input: InputStream, declaredEncoding: String): StringReader<InputStream> {
        fDeclaredEncoding = declaredEncoding
        try {
            setText(input)
            let match = detect()
            if (match.isNone()) {
                return None
            }
            return match.getReader()
        } catch (e: IOException) {
            return None
        }
    }

    public func getString(input: Array<UInt8>, declaredEncoding: String): String {
        fDeclaredEncoding = declaredEncoding
        try {
            setText(input)
            let match = detect()
            if (match.isNone()) {
                return None
            }
            return match.getString(-1)
        } catch (e: IOException) {
            return None
        }
    }

    public static func getAllDetectableCharsets(): Array<String> {
        let allCharsetNames = Array<String>(ALL_CS_RECOGNIZERS.size)
        var i = 0
        while (i < Int32(allCharsetNames.size)) {
            allCharsetNames[Int64(i)] = ALL_CS_RECOGNIZERS[Int64(i)].recognizer.getName()
            i++
        }
        return allCharsetNames
    }

    public func inputFilterEnabled(): Bool {
        return fStripTags
    }

    public func enableInputFilter(filter: Bool): Bool {
        let previous = fStripTags
        fStripTags = filter
        return previous
    }

    private func MungeInput(): Unit {
        var srci = 0
        var dsti = 0
        var b: UInt8 = 0
        var inMarkup = false
        var openTags = 0
        var badTags = 0
        if (fStripTags) {
            srci = 0
            while (srci < fRawLength && dsti < Int32(fInputBytes.size)) {
                b = fRawInput[Int64(srci)]
                if (b == UInt8(UInt32('<'))) {
                    if (inMarkup) {
                        badTags++
                    }
                    inMarkup = true
                    openTags++
                }
                if (!inMarkup) {
                    fInputBytes[Int64(match (0) { case _ => dsti++; dsti - 1 })] = b
                }
                if (b == UInt8(UInt32('>'))) {
                    inMarkup = false
                }
                srci++
            }
            fInputLen = dsti
        }
        if (openTags < 5 || openTags / 5 < badTags || (fInputLen < 100 && fRawLength > 600)) {
            var limit = fRawLength
            if (limit > kBufSize) {
                limit = kBufSize
            }
            srci = 0
            while (srci < limit) {
                fInputBytes[Int64(srci)] = fRawInput[Int64(srci)]
                srci++
            }
            fInputLen = srci
        }
        Arrays.fill(fByteStats, 0i16)
        srci = 0
        while (srci < fInputLen) {
            let val = Int32(fInputBytes[Int64(srci)]) & 255
            fByteStats[Int64(val)] += 1
            srci++
        }
        fC1Bytes = false
        var i = 128
        while (i <= 159) {
            if (Int32(fByteStats[Int64(i)]) != 0) {
                fC1Bytes = true
                break
            }
            i += 1
        }
    }

    var fInputBytes: Array<UInt8> = Array<UInt8>(Int64(kBufSize)) { _ => 0 }

    var fInputLen: Int32 = 0

    var fByteStats: Array<Int16> = Array<Int16>(256) { _ => 0 }

    var fC1Bytes = false

    var fDeclaredEncoding: String

    var fRawInput: Array<UInt8>

    var fRawLength: Int32 = 0

    var fInputStream: InputStream

    private var fStripTags = false

    private var fEnabledRecognizers: Array<Bool>

    private static let ALL_CS_RECOGNIZERS: ArrayList<CharsetDetector_CSRecognizerInfo>


    
    public func getDetectableCharsets(): Array<String> {
        let csnames = ArrayList<String>(ALL_CS_RECOGNIZERS.size)
        var i = 0
        while (i < Int32(ALL_CS_RECOGNIZERS.size)) {
            let rcinfo = ALL_CS_RECOGNIZERS[Int64(i)]
            let active = if (fEnabledRecognizers.isNone()) { rcinfo.isDefaultEnabled } else { fEnabledRecognizers[Int64(i)] }
            if (active) {
                csnames.append(rcinfo.recognizer.getName())
            }
            i++
        }
        return csnames.toArray(size))
    }

    
    public func setDetectableCharset(encoding: String, enabled: Bool): CharsetDetector {
        var modIdx = -1
        var isDefaultVal = false
                i++
            }
        } while (false)
        if (modIdx < 0) {
            throw IllegalArgumentException("Invalid encoding: \"" + (encoding) + "\"")
        }
        if (fEnabledRecognizers.isNone() && !isDefaultVal) {
            fEnabledRecognizers = Array<Bool>(ALL_CS_RECOGNIZERS.size) { _ => false }
            } while (false)
        }
        if (fEnabledRecognizers.isSome()) {
            fEnabledRecognizers[Int64(modIdx)] = enabled
        }
        return this
    }
}


class CharsetDetector_CSRecognizerInfo {
    var recognizer: CharsetRecognizer

    var isDefaultEnabled: Bool = false

    init(recognizer: CharsetRecognizer, isDefaultEnabled: Bool) {
        this.recognizer = recognizer
        this.isDefaultEnabled = isDefaultEnabled
    }
}
