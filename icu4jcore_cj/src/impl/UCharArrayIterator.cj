package icu4cj.impl

public class UCharArrayIterator <: UCharacterIterator {
    private let text: Array<Char>

    private let start: Int32

    private let limit: Int32

    private var pos: Int32 = 0

    public init(text: Array<Char>, start: Int32, limit: Int32) {
        super()
        if (start < 0 || limit > Int32(text.size) || start > limit) {
            throw IllegalArgumentException("start: " + start.toString() + " or limit: " + limit.toString() + " out of range [0, " + Int32(text.size).toString() + ")")
        }
        this.text = text
        this.start = start
        this.limit = limit
        this.pos = start
    }

    public override func current(): Int32 {
        return if (pos < limit) { Int32(UInt32(text[Int64(pos)])) } else { DONE }
    }

    public override func getLength(): Int32 {
        return limit - start
    }

    public override func getIndex(): Int32 {
        return pos - start
    }

    public override func next(): Int32 {
        return if (pos < limit) { Int32(UInt32(text[Int64(match (0) { case _ => pos++; pos - 1 })])) } else { DONE }
    }

    public override func previous(): Int32 {
        return if (pos > start) { Int32(UInt32(text[Int64(match (0) { case _ => pos--; pos })])) } else { DONE }
    }

    public override func setIndex(index: Int32): Unit {
        if (index < 0 || index > limit - start) {
            throw IndexOutOfBoundsException("index: " + index.toString() + " out of range [0, " + ((limit - start).toString()) + ")")
        }
        pos = start + index
    }

    public override func getText(fillIn: Array<Char>, offset: Int32): Int32 {
        let len = limit - start
        arraycopy(text, Int64(start), fillIn, Int64(offset), Int64(len))
        return len
    }

    public override func clone(): Object {
        try {
            return super.clone()
        } catch (e: CloneNotSupportedException) {
            return None
        }
    }
}
