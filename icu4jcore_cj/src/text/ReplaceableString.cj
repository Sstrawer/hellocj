package icu4cj.text

public class ReplaceableString <: Replaceable {
    private var buf: StringBuffer = None

    public init(str: String) {
        buf = StringBuffer(str)
    }

    public init(buf: StringBuffer) {
        this.buf = buf
    }

    public init() {
        buf = StringBuffer()
    }

    public override func toString(): String {
        return toString(buf)
    }

    public func substring(start: Int32, limit: Int32): String {
        return buf.substring(start, limit)
    }

    public override func length(): Int32 {
        return Int32(buf.size)
    }

    public override func charAt(offset: Int32): Char {
        return buf.get(Int64(offset))
    }

    public override func char32At(offset: Int32): Int32 {
        return UTF16.toRuneArray()[buf, offset]
    }

    public override func getChars(srcStart: Int32, srcLimit: Int32, dst: Array<Char>, dstStart: Int32): Unit {
        if (srcStart != srcLimit) {
            buf.getChars(srcStart, srcLimit, dst, dstStart)
        }
    }

    public override func replace(start: Int32, limit: Int32, text: String): Unit {
        buf.replace(start, limit, text)
    }

    public override func replace(start: Int32, limit: Int32, chars: Array<Char>, charsStart: Int32, charsLen: Int32): Unit {
        buf.delete(start, limit)
        buf.insert(start, chars, charsStart, charsLen)
    }

    public override func copy(start: Int32, limit: Int32, dest: Int32): Unit {
        if (start == limit && start >= 0 && start <= Int32(buf.size)) {
            return
        }
        let text = Array<Char>(Int64(limit - start)) { _ => '\u{0000}' }
        getChars(start, limit, text, 0)
        replace(dest, dest, text, 0, limit - start)
    }

    public override func hasMetaData(): Bool {
        return false
    }
}
