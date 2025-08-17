package icu4cj.impl

public class UCharacterIteratorWrapper <: CharacterIterator {
    public init(iter: UCharacterIterator) {
        this.iterator = iter
    }

    private var iterator: UCharacterIterator

    public override func first(): Char {
        iterator.setToStart()
        return Char(iterator.current())
    }

    public override func last(): Char {
        iterator.setToLimit()
        return Char(iterator.previous())
    }

    public override func current(): Char {
        return Char(iterator.current())
    }

    public override func next(): Char {
        iterator.next()
        return Char(iterator.current())
    }

    public override func previous(): Char {
        return Char(iterator.previous())
    }

    public override func setIndex(position: Int32): Char {
        iterator.setIndex(position)
        return Char(iterator.current())
    }

    public override func getBeginIndex(): Int32 {
        return 0
    }

    public override func getEndIndex(): Int32 {
        return iterator.getLength()
    }

    public override func getIndex(): Int32 {
        return iterator.getIndex()
    }

    public override func clone(): Object {
        try {
            let result = super.toString()
            result.iterator = this.iterator.clone()
            return result
        } catch (e: CloneNotSupportedException) {
            return None
        }
    }
}
