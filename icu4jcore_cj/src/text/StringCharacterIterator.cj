package icu4cj.text


public class StringCharacterIterator <: CharacterIterator {
    private var text: String

    private var begin: Int32 = 0

    private var end: Int32 = 0

    private var pos: Int32 = 0

    
    public init(text: String) {
        this(text, 0)
    }

    
    public init(text: String, pos: Int32) {
        this(text, 0, Int32(text.size), pos)
    }

    
    public init(text: String, begin: Int32, end: Int32, pos: Int32) {
        if (text.isNone()) {
            throw NoneValueException()
        }
        this.text = text
        if (begin < 0 || begin > end || end > Int32(text.size)) {
            throw IllegalArgumentException("Invalid substring range")
        }
        if (pos < begin || pos > end) {
            throw IllegalArgumentException("Invalid position")
        }
        this.begin = begin
        this.end = end
        this.pos = pos
    }

    
    public func setText(text: String): Unit {
        if (text.isNone()) {
            throw NoneValueException()
        }
        this.text = text
        this.begin = 0
        this.end = Int32(text.size)
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
            return Char(text[Int64(pos)])
        } else {
            return DONE
        }
    }

    
    public override func next(): Char {
        if (pos < end - 1) {
            pos++
            return Char(text[Int64(pos)])
        } else {
            pos = end
            return DONE
        }
    }

    
    public override func previous(): Char {
        if (pos > begin) {
            pos--
            return Char(text[Int64(pos)])
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
        if (!(checkOptionalIs<StringCharacterIterator, Object>(obj))) {
            return false
        }
        let that = obj
        if (Int32(hashCode()) != Int32(that.hashCode())) {
            return false
        }
        if (!text.equals(that.text)) {
            return false
        }
        if (pos != that.pos || begin != that.begin || end != that.end) {
            return false
        }
        return true
    }

    
    public override func hashCode(): Int64 {
        return Int64(Int32(text.hashCode()) ^ pos ^ begin ^ end)
    }

    
    public override func clone(): Object {
        try {
            let other = super.toString()
            return other
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException(e as Exception)
        }
    }
}
