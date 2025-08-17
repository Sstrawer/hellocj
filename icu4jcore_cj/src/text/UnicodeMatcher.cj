package icu4cj.text

public interface UnicodeMatcher {
    let U_MISMATCH = 0

    let U_PARTIAL_MATCH = 1

    let U_MATCH = 2

    static let ETHER = '\u{ffff}'

    public func matches(text: Replaceable, offset: Array<Int32>, limit: Int32, incremental: Bool): Int32

    public func toPattern(escapeUnprintable: Bool): String

    public func matchesIndexValue(v: Int32): Bool

    public func addMatchSetTo(toUnionTo: UnicodeSet): Unit
}