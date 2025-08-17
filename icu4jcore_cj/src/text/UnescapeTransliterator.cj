package icu4cj.text

class UnescapeTransliterator <: Transliterator {
    private var spec: Array<Char>

    static let END = Char(65535)

    static func register(): Unit {
        Transliterator.registerFactory("Hex-Any/Unicode", UnescapeTransliterator_1())
        Transliterator.registerFactory("Hex-Any/Java", UnescapeTransliterator_2())
        Transliterator.registerFactory("Hex-Any/C", UnescapeTransliterator_3())
        Transliterator.registerFactory("Hex-Any/XML", UnescapeTransliterator_4())
        Transliterator.registerFactory("Hex-Any/XML10", UnescapeTransliterator_5())
        Transliterator.registerFactory("Hex-Any/Perl", UnescapeTransliterator_6())
        Transliterator.registerFactory("Hex-Any", UnescapeTransliterator_7())
    }

    init(ID: String, spec: Array<Char>) {
        super(ID, None)
        this.spec = spec
    }

    override protected func handleTransliterate(text: Replaceable, pos: Transliterator_Position, isIncremental: Bool): Unit {
        var start = pos.start
        var limit = pos.limit
        var i: Int32 = 0
        var ipat: Int32 = 0
    public override func addSourceTargetSet(inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        let myFilter = getFilterAsUnicodeSet(inputFilter)
        let items = UnicodeSet()
        let buffer = StringBuilder()
        var i = 0
        while (spec[Int64(i)] != END) {
            let end = i + Int32(UInt32(spec[Int64(i)])) + Int32(UInt32(spec[Int64(i + 1)])) + 5
            let radix = Int32(UInt32(spec[Int64(i + 2)]))
            } while (false)
            } while (false)
            i = end
        }
        items.addAll(buffer.toString())
        items.retainAll(myFilter)
        if (items.size() > 0) {
            sourceSet.addAll(items)
            targetSet.addAll(0, 1114111)
        }
    }
}


class UnescapeTransliterator_1 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return UnescapeTransliterator("Hex-Any/Unicode", [Char(2), Char(0), Char(16), Char(4), Char(6), 'U', '+', UnescapeTransliterator.END])
    }
}


class UnescapeTransliterator_2 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return UnescapeTransliterator("Hex-Any/Java", [Char(2), Char(0), Char(16), Char(4), Char(4), '\', 'u', UnescapeTransliterator.END])
    }
}


class UnescapeTransliterator_3 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return UnescapeTransliterator("Hex-Any/C", [Char(2), Char(0), Char(16), Char(4), Char(4), '\', 'u', Char(2), Char(0), Char(16), Char(8), Char(8), '\', 'U', UnescapeTransliterator.END])
    }
}


class UnescapeTransliterator_4 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return UnescapeTransliterator("Hex-Any/XML", [Char(3), Char(1), Char(16), Char(1), Char(6), '&', '#', 'x', ';', UnescapeTransliterator.END])
    }
}


class UnescapeTransliterator_5 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return UnescapeTransliterator("Hex-Any/XML10", [Char(2), Char(1), Char(10), Char(1), Char(7), '&', '#', ';', UnescapeTransliterator.END])
    }
}


class UnescapeTransliterator_6 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return UnescapeTransliterator("Hex-Any/Perl", [Char(3), Char(1), Char(16), Char(1), Char(6), '\', 'x', '{', '}', UnescapeTransliterator.END])
    }
}


class UnescapeTransliterator_7 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return UnescapeTransliterator("Hex-Any", [Char(2), Char(0), Char(16), Char(4), Char(6), 'U', '+', Char(2), Char(0), Char(16), Char(4), Char(4), '\', 'u', Char(2), Char(0), Char(16), Char(8), Char(8), '\', 'U', Char(3), Char(1), Char(16), Char(1), Char(6), '&', '#', 'x', ';', Char(2), Char(1), Char(10), Char(1), Char(7), '&', '#', ';', Char(3), Char(1), Char(16), Char(1), Char(6), '\', 'x', '{', '}', UnescapeTransliterator.END])
    }
}
