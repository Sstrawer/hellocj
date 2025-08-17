package icu4cj.text

class EscapeTransliterator <: Transliterator {
    private var prefix: String

    private var suffix: String

    private var radix: Int32 = 0

    private var minDigits: Int32 = 0

    private var grokSupplementals: Bool = false

    private var supplementalHandler: EscapeTransliterator

    static func register(): Unit {
        Transliterator.registerFactory("Any-Hex/Unicode", EscapeTransliterator_1())
        Transliterator.registerFactory("Any-Hex/Java", EscapeTransliterator_2())
        Transliterator.registerFactory("Any-Hex/C", EscapeTransliterator_3())
        Transliterator.registerFactory("Any-Hex/XML", EscapeTransliterator_4())
        Transliterator.registerFactory("Any-Hex/XML10", EscapeTransliterator_5())
        Transliterator.registerFactory("Any-Hex/Perl", EscapeTransliterator_6())
        Transliterator.registerFactory("Any-Hex/Plain", EscapeTransliterator_7())
        Transliterator.registerFactory("Any-Hex", EscapeTransliterator_8())
    }

    init(ID: String, prefix: String, suffix: String, radix: Int32, minDigits: Int32, grokSupplementals: Bool, supplementalHandler: EscapeTransliterator) {
        super(ID, None)
        this.prefix = prefix
        this.suffix = suffix
        this.radix = radix
        this.minDigits = minDigits
        this.grokSupplementals = grokSupplementals
        this.supplementalHandler = supplementalHandler
    }

    override protected func handleTransliterate(text: Replaceable, pos: Transliterator_Position, incremental: Bool): Unit {
        var start = pos.start
        var limit = pos.limit
        let buf = StringBuilder(prefix)
        let prefixLen = Int32(prefix.size)
        var redoPrefix = false
        while (start < limit) {
            let c = if (grokSupplementals) { text.char32At(start) } else { Int32(UInt32(text.toRuneArray()[start])) }
            let charLen = if (grokSupplementals) { UTF16.getCharCount(c) } else { 1 }
            if ((c & -65536) != 0 && supplementalHandler.isSome()) {
                buf.setLength(0)
                buf.append(supplementalHandler.prefix)
                Utility.appendNumber(buf as T, c, supplementalHandler.radix, supplementalHandler.minDigits)
                buf.append(supplementalHandler.suffix)
                redoPrefix = true
            } else {
                if (redoPrefix) {
                    buf.setLength(0)
                    buf.append(prefix)
                    redoPrefix = false
                } else {
                    buf.setLength(Int64(prefixLen))
                }
                Utility.appendNumber(buf as T, c, radix, minDigits)
                buf.append(suffix)
            }
            text.replace(start, start + charLen, buf.toString())
            start += Int32(buf.size)
            limit += Int32(buf.size) - charLen
        }
        pos.contextLimit += limit - pos.limit
        pos.limit = limit
        pos.start = start
    }

    public override func addSourceTargetSet(inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        sourceSet.addAll(getFilterAsUnicodeSet(inputFilter))
        var it: EscapeTransliterator = this
        while (it.isSome()) {
            if (inputFilter.size() != 0) {
                targetSet.addAll(it.prefix)
                targetSet.addAll(it.suffix)
                let buffer = StringBuilder()
                var i = 0
                while (i < it.radix) {
                    Utility.appendNumber(buffer as T, i, it.radix, it.minDigits)
                    i++
                }
                targetSet.addAll(buffer.toString())
            }
            it = it.supplementalHandler
        }
    }
}


class EscapeTransliterator_1 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return EscapeTransliterator("Any-Hex/Unicode", "U+", "", 16, 4, true, None)
    }
}


class EscapeTransliterator_2 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return EscapeTransliterator("Any-Hex/Java", "\\u", "", 16, 4, false, None)
    }
}


class EscapeTransliterator_3 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return EscapeTransliterator("Any-Hex/C", "\\u", "", 16, 4, true, EscapeTransliterator("", "\\U", "", 16, 8, true, None))
    }
}


class EscapeTransliterator_4 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return EscapeTransliterator("Any-Hex/XML", "&#x", ";", 16, 1, true, None)
    }
}


class EscapeTransliterator_5 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return EscapeTransliterator("Any-Hex/XML10", "&#", ";", 10, 1, true, None)
    }
}


class EscapeTransliterator_6 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return EscapeTransliterator("Any-Hex/Perl", "\\x{", "}", 16, 1, true, None)
    }
}


class EscapeTransliterator_7 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return EscapeTransliterator("Any-Hex/Plain", "", "", 16, 4, true, None)
    }
}


class EscapeTransliterator_8 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return EscapeTransliterator("Any-Hex", "\\u", "", 16, 4, false, None)
    }
}
