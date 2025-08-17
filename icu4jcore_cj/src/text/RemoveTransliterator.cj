package icu4cj.text

class RemoveTransliterator <: Transliterator {
    private static let _ID = "Any-Remove"

    static func register(): Unit {
        Transliterator.registerFactory(_ID, RemoveTransliterator_1())
        Transliterator.registerSpecialInverse("Remove", "Null", false)
    }

    public init() {
        super(_ID, None)
    }

    override protected func handleTransliterate(text: Replaceable, index: Transliterator_Position, incremental: Bool): Unit {
        text.replace(index.start, index.limit, "")
        let len = index.limit - index.start
        index.contextLimit -= len
        index.limit -= len
    }

    public override func addSourceTargetSet(inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        let myFilter = getFilterAsUnicodeSet(inputFilter)
        sourceSet.addAll(myFilter)
    }
}


class RemoveTransliterator_1 <: Transliterator_Factory {
    init() { }

    public override func getInstance(ID: String): Transliterator {
        return RemoveTransliterator()
    }
}
