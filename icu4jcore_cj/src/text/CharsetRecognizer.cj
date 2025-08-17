package icu4cj.text

abstract class CharsetRecognizer {

    public func getName(): String

    public func getLanguage(): String {
        return None
    }

    public func match(det: CharsetDetector): CharsetMatch
}
