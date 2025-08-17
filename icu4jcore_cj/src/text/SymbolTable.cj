package icu4cj.text

public interface SymbolTable {
    static let SYMBOL_REF = '$'

    func lookup(s: String): Array<Char>

    func lookupMatcher(ch: Int32): UnicodeMatcher

    func parseReference(text: String, pos: ParsePosition, limit: Int32): String
}