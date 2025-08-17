package icu4cj.impl


public class ReplaceableUCharacterIterator <: UCharacterIterator {
    public init(replaceable: Replaceable) {
        super()
        if (replaceable.isNone()) {
            throw IllegalArgumentException()
        }
        this.replaceable = replaceable
        this.currentIndex = 0
    }

    public init(str: String) {
        super()
        if (str.isNone()) {
            throw IllegalArgumentException()
        }
        this.replaceable = ReplaceableString(str)
        this.currentIndex = 0
    }

    public init(buf: StringBuffer) {
        super()
        if (buf.isNone()) {
            throw IllegalArgumentException()
        }
        this.replaceable = ReplaceableString(buf)
        this.currentIndex = 0
    }

    public override func clone(): Object {
        try {
            return super.clone()
        } catch (e: CloneNotSupportedException) {
            return None
        }
    }

    public override func current(): Int32 {
        if (currentIndex < replaceable.size) {
            return Int32(UInt32(replaceable.toRuneArray()[currentIndex]))
        }
        return DONE
    }

    public override func currentCodePoint(): Int32 {
        let ch = current()
        if (UTF16.isLeadSurrogate(ch)) {
            next()
            let ch2 = current()
            previous()
            if (UTF16.isTrailSurrogate(ch2)) {
                return Character.toCodePoint(Char(ch), Char(ch2))
            }
        }
        return ch
    }

    public override func getLength(): Int32 {
        return replaceable.size
    }

    public override func getIndex(): Int32 {
        return currentIndex
    }

    public override func next(): Int32 {
        if (currentIndex < replaceable.size) {
            return Int32(UInt32(replaceable.toRuneArray()[match (0) { case _ => currentIndex++; currentIndex - 1 }]))
        }
        return DONE
    }

    public override func previous(): Int32 {
        if (currentIndex > 0) {
            return Int32(UInt32(replaceable.toRuneArray()[match (0) { case _ => currentIndex--; currentIndex }]))
        }
        return DONE
    }

    public override func setIndex(currentIndex: Int32): Unit {
        if (currentIndex < 0 || currentIndex > replaceable.size) {
            throw IndexOutOfBoundsException()
        }
        this.currentIndex = currentIndex
    }

    public override func getText(fillIn: Array<Char>, offset: Int32): Int32 {
        let length = replaceable.size
        if (offset < 0 || offset + length > Int32(fillIn.size)) {
            throw IndexOutOfBoundsException(length.toString())
        }
        replaceable.getChars(0, length, fillIn, offset)
        return length
    }

    private var replaceable: Replaceable

    private var currentIndex: Int32 = 0
}
