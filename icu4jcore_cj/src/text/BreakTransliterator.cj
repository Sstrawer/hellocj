package icu4cj.text

class BreakTransliterator <: Transliterator & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private var bi: BreakIterator

    private var insertion: String

    private var boundaries: Array<Int32> = Array<Int32>(50) { _ => 0 }

    private var boundaryCount = 0

    public init(ID: String, filter: UnicodeFilter, bi: BreakIterator, insertion: String) {
        super(ID, filter)
        this.bi = bi
        this.insertion = insertion
    }

    public init(ID: String, filter: UnicodeFilter) {
        this(ID, filter, None, " ")
    }

    public func getInsertion(): String {
        return insertion
    }

    public func setInsertion(insertion: String): Unit {
        this.insertion = insertion
    }

    public func getBreakIterator(): BreakIterator {
        if (bi.isNone()) {
            bi = BreakIterator.getWordInstance(ULocale("th_TH"))
        }
        return bi
    }

    public func setBreakIterator(bi: BreakIterator): Unit {
        this.bi = bi
    }

    static let LETTER_OR_MARK_MASK = (shl(1, Int32(Character.UPPERCASE_LETTER))) | (shl(1, Int32(Character.LOWERCASE_LETTER))) | (shl(1, Int32(Character.TITLECASE_LETTER))) | (shl(1, Int32(Character.MODIFIER_LETTER))) | (shl(1, Int32(Character.OTHER_LETTER))) | (shl(1, Int32(Character.COMBINING_SPACING_MARK))) | (shl(1, Int32(Character.NON_SPACING_MARK))) | (shl(1, Int32(Character.ENCLOSING_MARK)))

    override protected func handleTransliterate(text: Replaceable, pos: Transliterator_Position, incremental: Bool): Unit {
        synchronized (GeneratedLockObject) {
            boundaryCount = 0
            var boundary = 0
            getBreakIterator()
            bi.setText(BreakTransliterator_ReplaceableCharacterIterator(text, pos.start, pos.limit, pos.start))
            boundary = bi.first()
            while (boundary != BreakIterator.DONE && boundary < pos.limit) {
                if (boundary == 0) {
                    continue
                }
                var cp = UTF16.toRuneArray()[text, boundary - 1]
                var Type = UCharacter.getType(cp)
                if (((shl(1, Type)) & LETTER_OR_MARK_MASK) == 0) {
                    continue
                }
                cp = UTF16.toRuneArray()[text, boundary]
                Type = UCharacter.getType(cp)
                if (((shl(1, Type)) & LETTER_OR_MARK_MASK) == 0) {
                    continue
                }
                if (boundaryCount >= Int32(boundaries.size)) {
                    let temp = Array<Int32>(Int64(Int32(boundaries.size) * 2)) { _ => 0 }
                    arraycopy(boundaries, 0, temp, 0, boundaries.size)
                    boundaries = temp
                }
                boundaries[Int64(match (0) { case _ => boundaryCount++; boundaryCount - 1 })] = boundary
                boundary = bi.next()
            }
            var delta = 0
            var lastBoundary = 0
            if (boundaryCount != 0) {
                delta = boundaryCount * Int32(insertion.size)
                lastBoundary = boundaries[Int64(boundaryCount - 1)]
                while (boundaryCount > 0) {
                    boundary = boundaries[Int64(match (0) { case _ => boundaryCount--; boundaryCount })]
                    text.replace(boundary, boundary, insertion)
                }
            }
            pos.contextLimit += delta
            pos.limit += delta
            pos.start = if (incremental) { lastBoundary + delta } else { pos.limit }
        }
    }

    static func register(): Unit {
        let trans: Transliterator = BreakTransliterator("Any-BreakInternal", None)
        Transliterator.registerInstance(trans, false)
    }

    public override func addSourceTargetSet(inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        let myFilter = getFilterAsUnicodeSet(inputFilter)
        if (myFilter.size() != 0) {
            targetSet.addAll(insertion)
        }
    }
}


class BreakTransliterator_ReplaceableCharacterIterator <: CharacterIterator {
    private var text: Replaceable

    private var begin: Int32 = 0

    private var end: Int32 = 0

    private var pos: Int32 = 0

    public init(text: Replaceable, begin: Int32, end: Int32, pos: Int32) {
        if (text.isNone()) {
            throw NoneValueException()
        }
        this.text = text
        if (begin < 0 || begin > end || end > text.size) {
            throw IllegalArgumentException("Invalid substring range")
        }
        if (pos < begin || pos > end) {
            throw IllegalArgumentException("Invalid position")
        }
        this.begin = begin
        this.end = end
        this.pos = pos
    }

    public func setText(text: Replaceable): Unit {
        if (text.isNone()) {
            throw NoneValueException()
        }
        this.text = text
        this.begin = 0
        this.end = text.size
        this.pos = 0
    }

    public override func first(): Char {
        pos = begin
        return current()
    }

    public override func last(): Char {
        if (end != begin) {
            pos = end - 1
        } else {
            pos = end
        }
        return current()
    }

    public override func setIndex(p: Int32): Char {
        if (p < begin || p > end) {
            throw IllegalArgumentException("Invalid index")
        }
        pos = p
        return current()
    }

    public override func current(): Char {
        if (pos >= begin && pos < end) {
            return text.toRuneArray()[pos]
        } else {
            return DONE
        }
    }

    public override func next(): Char {
        if (pos < end - 1) {
            pos++
            return text.toRuneArray()[pos]
        } else {
            pos = end
            return DONE
        }
    }

    public override func previous(): Char {
        if (pos > begin) {
            pos--
            return text.toRuneArray()[pos]
        } else {
            return DONE
        }
    }

    public override func getBeginIndex(): Int32 {
        return begin
    }

    public override func getEndIndex(): Int32 {
        return end
    }

    public override func getIndex(): Int32 {
        return pos
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (!(checkOptionalIs<BreakTransliterator_ReplaceableCharacterIterator, Object>(obj))) {
            return false
        }
        let that = obj
        if (Int32(hashCode()) != Int32(that.hashCode())) {
            return false
        }
        if (!refEq(text, that.text)) {
            return false
        }
        if (pos != that.pos || begin != that.begin || end != that.end) {
            return false
        }
        return true
    }

    public override func hashCode(): Int64 {
        return Int64(Int32(text.toString()) ^ pos ^ begin ^ end)
    }

    public override func clone(): Object {
        try {
            let other = super.toString()
            return other
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException()
        }
    }
}
