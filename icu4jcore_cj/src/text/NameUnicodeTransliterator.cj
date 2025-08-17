package icu4cj.text


class NameUnicodeTransliterator <: Transliterator {
    static let _ID = "Name-Any"

    static let OPEN_PAT = "\\N~{~"

    static let OPEN_DELIM = '\'

    static let CLOSE_DELIM = '}'

    static let SPACE = ' '

    static func register(): Unit {
        Transliterator.registerFactory(_ID, NameUnicodeTransliterator_1())
    }

    public init(filter: UnicodeFilter) {
        super(_ID, filter)
    }

    override protected func handleTransliterate(text: Replaceable, offsets: Transliterator_Position, isIncremental: Bool): Unit {
        let maxLen = UCharacterName.INSTANCE.getMaxCharNameLength() + 1
        let name = StringBuffer(maxLen)
        let legal = UnicodeSet()
        UCharacterName.INSTANCE.getCharNameCharacters(legal)
        var cursor = offsets.start
        var limit = offsets.limit
        var mode = 0
        var openPos = -1
        var c: Int32 = 0
        while (cursor < limit) {
            c = text.char32At(cursor)
            match (mode) {
                case 0 => if (c == Int32(UInt32(OPEN_DELIM))) {
                    openPos = cursor
                    let i = Utility.parsePattern(OPEN_PAT, text, cursor, limit)
                    if (i >= 0 && i < limit) {
                        mode = 1
                        name.setLength(0)
                        cursor = i
                        continue
                    }
                }
                case 1 =>
                    if (PatternProps.isWhiteSpace(c)) {
                        if (Int32(name.size) > 0 && name.get(Int64(Int32(name.size) - 1)) != SPACE) {
                            name.append(SPACE)
                            if (Int32(name.size) > maxLen) {
                                mode = 0
                            }
                        }
                        break
                    }
                    if (c == Int32(UInt32(CLOSE_DELIM))) {
                        var len = Int32(name.size)
                        if (len > 0 && name.get(Int64(len - 1)) == SPACE) {
                            name.setLength(Int64(match (0) { case _ => len--; len }))
                        }
                        c = UCharacter.getCharFromExtendedName(toString(name))
                        if (c != -1) {
                            cursor++
                            let str = UTF16.valueOf(c)
                            text.replace(openPos, cursor, str)
                            let delta = cursor - openPos - Int32(str.size)
                            cursor -= delta
                            limit -= delta
                        }
                        mode = 0
                        openPos = -1
                        continue
                    }
                    if (legal.contains(c)) {
                        UTF16.append(name, c)
                        if (Int32(name.size) >= maxLen) {
                            mode = 0
                        }
                    } else {
                        cursor--
                        mode = 0
                    }
                case _ => ()
            }
            cursor += UTF16.getCharCount(c)
        }
        offsets.contextLimit += limit - offsets.limit
        offsets.limit = limit
        offsets.start = if (isIncremental && openPos >= 0) { openPos } else { cursor }
    }

    public override func addSourceTargetSet(inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        let myFilter = getFilterAsUnicodeSet(inputFilter)
        if (!myFilter.containsAll(UnicodeNameTransliterator.OPEN_DELIM) || !myFilter.contains(Int32(UInt32(CLOSE_DELIM)))) {
            return
        }
        let items = UnicodeSet().addAll(Int32(UInt32('0')), Int32(UInt32('9'))).addAll(Int32(UInt32('A')), Int32(UInt32('F'))).addAll(Int32(UInt32('a')), Int32(UInt32('z'))).add(Int32(UInt32('<'))).add(Int32(UInt32('>'))).add(Int32(UInt32('('))).add(Int32(UInt32(')'))).add(Int32(UInt32('-'))).add(Int32(UInt32(' '))).addAll(UnicodeNameTransliterator.OPEN_DELIM).add(Int32(UInt32(CLOSE_DELIM)))
        items.retainAll(myFilter)
        if (items.size() > 0) {
            sourceSet.addAll(items)
            targetSet.addAll(0, 1114111)
        }
    }
}


class NameUnicodeTransliterator_1 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return NameUnicodeTransliterator(None)
    }
}
