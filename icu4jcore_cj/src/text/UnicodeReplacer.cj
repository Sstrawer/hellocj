package icu4cj.text

interface UnicodeReplacer {
    public func replace(text: Replaceable, start: Int32, limit: Int32, cursor: Array<Int32>): Int32

    public func toReplacerPattern(escapeUnprintable: Bool): String

    public func addReplacementSetTo(toUnionTo: UnicodeSet): Unit
}