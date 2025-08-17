package icu4cj.impl

public class CSCharacterIterator <: CharacterIterator {
    private var index: Int32 = 0

    private var seq: String

    public init(text: String) {
        if (text.isNone()) {
            throw NoneValueException()
        }
        seq = text
        index = 0
    }

    public override func first(): Char {
        index = 0
        return current()
    }

    public override func last(): Char {
        index = seq.size
        return previous()
    }

    public override func current(): Char {
        if (index == seq.size) {
            return DONE
        }
        return seq[index]
    }

    public override func next(): Char {
        if (index < seq.size) {
            index++
        }
        return current()
    }

    public override func previous(): Char {
        if (index == 0) {
            return DONE
        }
        index--
        return current()
    }

    public override func setIndex(position: Int32): Char {
        if (position < 0 || position > seq.size) {
            throw IllegalArgumentException()
        }
        index = position
        return current()
    }

    public override func getBeginIndex(): Int32 {
        return 0
    }

    public override func getEndIndex(): Int32 {
        return seq.size
    }

    public override func getIndex(): Int32 {
        return index
    }

    public override func clone(): Object {
        let copy = CSCharacterIterator(seq)
        copy.setIndex(index)
        return copy
    }
}
