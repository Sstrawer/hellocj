package icu4cj.impl

public class CharacterIteratorWrapper <: UCharacterIterator {
    private var iterator: CharacterIterator = None

    public init(iter: CharacterIterator) {
        super()
        if (iter.isNone()) {
            throw IllegalArgumentException()
        }
        iterator = iter
    }

    public override func current(): Int32 {
        let c = Int32(UInt32(iterator.current()))
        if (c == Int32(UInt32(CharacterIterator.DONE))) {
            return DONE
        }
        return c
    }

    public override func getLength(): Int32 {
        return (iterator.getEndIndex() - iterator.getBeginIndex())
    }

    public override func getIndex(): Int32 {
        return iterator.getIndex()
    }

    public override func next(): Int32 {
        let i = Int32(UInt32(iterator.current()))
        iterator.next()
        if (i == Int32(UInt32(CharacterIterator.DONE))) {
            return DONE
        }
        return i
    }

    public override func previous(): Int32 {
        let i = Int32(UInt32(iterator.previous()))
        if (i == Int32(UInt32(CharacterIterator.DONE))) {
            return DONE
        }
        return i
    }

    public override func setIndex(index: Int32): Unit {
        try {
            iterator.setIndex(index)
        } catch (e: IllegalArgumentException) {
            throw IndexOutOfBoundsException()
        }
    }

    public override func setToLimit(): Unit {
        iterator.setIndex(iterator.getEndIndex())
    }

    public override func getText(fillIn: Array<Char>, offset: Int32): Int32 {
        var tempoffset = offset
        let length = iterator.getEndIndex() - iterator.getBeginIndex()
        let currentIndex = iterator.getIndex()
        if (tempoffset < 0 || tempoffset + length > Int32(fillIn.size)) {
            throw IndexOutOfBoundsException(length.toString())
        }
        var ch = iterator.first()
        while (ch != CharacterIterator.DONE) {
            fillIn[Int64(match (0) { case _ => tempoffset++; tempoffset - 1 })] = ch
            ch = iterator.next()
        }
        iterator.setIndex(currentIndex)
        return length
    }

    public override func clone(): Object {
        try {
            let result = super.clone()
            result.iterator = this.iterator.clone()
            return result
        } catch (e: CloneNotSupportedException) {
            return None
        }
    }

    public override func moveIndex(delta: Int32): Int32 {
        let length = iterator.getEndIndex() - iterator.getBeginIndex()
        var idx = iterator.getIndex() + delta
        if (idx < 0) {
            idx = 0
        } else if (idx > length) {
            idx = length
        }
        return Int32(UInt32(iterator.setIndex(idx)))
    }

    public override func getCharacterIterator(): CharacterIterator {
        return iterator.clone()
    }
}
