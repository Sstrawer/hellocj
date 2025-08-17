package icu4cj.text

class UnicodeNameTransliterator <: Transliterator {
    static let _ID = "Any-Name"

    static let OPEN_DELIM = "\\N{"

    static let CLOSE_DELIM = '}'

    static let OPEN_DELIM_LEN = 3

    static func register(): Unit {
        Transliterator.registerFactory(_ID, UnicodeNameTransliterator_1())
    }

    public init(filter: UnicodeFilter) {
        super(_ID, filter)
    }

    override protected func handleTransliterate(text: Replaceable, offsets: Transliterator_Position, isIncremental: Bool): Unit {
        var cursor = offsets.start
        var limit = offsets.limit
        let str = StringBuilder()
        str.append(OPEN_DELIM)
        var len: Int32 = 0
        var name: String
        while (cursor < limit) {
            let c = text.char32At(cursor)
            if ((match (0) { case _ => name = UCharacter.getExtendedName(c); name }).isSome()) {
                str.setLength(Int64(OPEN_DELIM_LEN))
                str.append(name).append(CLOSE_DELIM)
                let clen = UTF16.getCharCount(c)
                text.replace(cursor, cursor + clen, str.toString())
                len = Int32(str.size)
                cursor += len
                limit += len - clen
            } else {
                cursor++
            }
        }
        offsets.contextLimit += limit - offsets.limit
        offsets.limit = limit
        offsets.start = cursor
    }

    public override func addSourceTargetSet(inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        let myFilter = getFilterAsUnicodeSet(inputFilter)
        if (myFilter.size() > 0) {
            sourceSet.addAll(myFilter)
            targetSet.addAll(Int32(UInt32('0')), Int32(UInt32('9'))).addAll(Int32(UInt32('A')), Int32(UInt32('Z'))).add(Int32(UInt32('-'))).add(Int32(UInt32(' '))).addAll(OPEN_DELIM).add(Int32(UInt32(CLOSE_DELIM))).addAll(Int32(UInt32('a')), Int32(UInt32('z'))).add(Int32(UInt32('<'))).add(Int32(UInt32('>'))).add(Int32(UInt32('('))).add(Int32(UInt32(')')))
        }
    }
}


class UnicodeNameTransliterator_1 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return UnicodeNameTransliterator(None)
    }
}
