package icu4cj.util


public class CaseInsensitiveString {
    private var string: String

    private var hash = 0

    private var folded: String

    private static func foldCase(foldee: String): String {
        return UCharacter.foldCase(foldee, true)
    }

    private func getFolded(): Unit {
        if (folded.isNone()) {
            folded = foldCase(string)
        }
    }

    public init(s: String) {
        string = s
    }

    public func getString(): String {
        return string
    }

    public override func equals(o: Object): Bool {
        if (o.isNone()) {
            return false
        }
        if (refEq(this, o)) {
            return true
        }
        if (checkOptionalIs<CaseInsensitiveString, Object>(o)) {
            getFolded()
            let cis = o
            cis.getFolded()
            return folded.equals(cis.folded)
        }
        return false
    }

    public override func hashCode(): Int64 {
        getFolded()
        if (hash == 0) {
            hash = Int32(folded.hashCode())
        }
        return Int64(hash)
    }

    public override func toString(): String {
        return string
    }
}
