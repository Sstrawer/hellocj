package icu4cj.message2

class StringView <: String {
    let offset: Int32

    let text: String

    init(text: String, offset: Int32) {
        this.offset = offset
        this.text = text
    }

    init(text: String) {
        this(text, 0)
    }

    public override func length(): Int32 {
        return Int32(text.size) - offset
    }

    public override func charAt(index: Int32): Char {
        return Char(text[Int64(index + offset)])
    }

    public override func subSequence(start: Int32, end: Int32): String {
        return text.subSequence(start + offset, end + offset)
    }

    public override func toString(): String {
        return text[Int64(offset)..]
    }
}
