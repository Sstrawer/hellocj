package icu4cj.text


public class CharsetMatch <: Comparable<CharsetMatch> {
    public func getReader(): StringReader<InputStream> {
        var inputStream = fInputStream
        if (inputStream.isNone()) {
            inputStream = ByteArrayInputStream(fRawInput, 0, fRawLength)
        }
        try {
            inputStream.reset()
            return // Мapping is present but failed: StringReader<InputStream>(inputStream, getName())
        } catch (e: IOException) {
            return None
        }
    }

    public func getString(): String {
        return getString(-1)
    }

    public func getString(maxLength: Int32): String {
        var result: String
        if (fInputStream.isSome()) {
            let sb = StringBuilder()
            let buffer = Array<Char>(1024) { _ => '\u{0000}' }
            let reader = getReader()
            var max = if (maxLength < 0) { Int32.Max } else { maxLength }
            var bytesRead = 0
            while ((match (0) { case _ => bytesRead = reader.read(buffer[0..0 + Int64(min(max, 1024))]); bytesRead }) >= 0) {
                sb.append(buffer, 0, bytesRead)
                max -= bytesRead
            }
            return sb.toString()
        } else {
            var name = getName()
            let startSuffix = if (indexOfWrap(name.indexOf("_rtl")) < 0) { indexOfWrap(name.indexOf("_ltr")) } else { indexOfWrap(name.indexOf("_rtl")) }
            if (startSuffix > 0) {
                name = name[0..Int64(startSuffix)]
            }
            result = String(fRawInput, name)
        }
        return result
    }

    public func getConfidence(): Int32 {
        return fConfidence
    }

    public func getName(): String {
        return fCharsetName
    }

    public func getLanguage(): String {
        return fLang
    }

    public override func compareTo(other: CharsetMatch): Int32 {
        var compareResult = 0
        if (this.fConfidence > other.fConfidence) {
            compareResult = 1
        } else if (this.fConfidence < other.fConfidence) {
            compareResult = -1
        }
        return compareResult
    }

    init(det: CharsetDetector, rec: CharsetRecognizer, conf: Int32) {
        fConfidence = conf
        if (det.fInputStream.isNone()) {
            fRawInput = det.fRawInput
            fRawLength = det.fRawLength
        }
        fInputStream = det.fInputStream
        fCharsetName = rec.getName()
        fLang = rec.getLanguage()
    }

    init(det: CharsetDetector, rec: CharsetRecognizer, conf: Int32, csName: String, lang: String) {
        fConfidence = conf
        if (det.fInputStream.isNone()) {
            fRawInput = det.fRawInput
            fRawLength = det.fRawLength
        }
        fInputStream = det.fInputStream
        fCharsetName = csName
        fLang = lang
    }

    private var fConfidence: Int32 = 0

    private var fRawInput: Array<UInt8>

    private var fRawLength: Int32 = 0

    private var fInputStream: InputStream

    private var fCharsetName: String

    private var fLang: String
}
