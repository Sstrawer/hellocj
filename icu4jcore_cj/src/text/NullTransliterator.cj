package icu4cj.text

class NullTransliterator <: Transliterator {
    static let SHORT_ID = "Null"

    static let _ID = "Any-Null"

    public init() {
        super(_ID, None)
    }

    override protected func handleTransliterate(text: Replaceable, offsets: Transliterator_Position, incremental: Bool): Unit {
        offsets.start = offsets.limit
    }

    public override func addSourceTargetSet(inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit { }
}
