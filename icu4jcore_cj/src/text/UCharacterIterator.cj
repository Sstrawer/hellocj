package icu4cj.text


public abstract class UCharacterIterator <: Cloneable & UForwardCharacterIterator {
    protected init() { }

    public static func getInstance(source: Replaceable): UCharacterIterator {
        return ReplaceableUCharacterIterator(source)
    }

    public static func getInstance(source: String): UCharacterIterator {
        return ReplaceableUCharacterIterator(source)
    }

    public static func getInstance(source: Array<Char>): UCharacterIterator {
        return getInstance(source, 0, Int32(source.size))
    }

    public static func getInstance(source: Array<Char>, start: Int32, limit: Int32): UCharacterIterator {
        return UCharArrayIterator(source, start, limit)
    }

    public static func getInstance(source: StringBuffer): UCharacterIterator {
        return ReplaceableUCharacterIterator(source)
    }

    public static func getInstance(source: CharacterIterator): UCharacterIterator {
        return CharacterIteratorWrapper(source)
    }

    public func getCharacterIterator(): CharacterIterator {
        return UCharacterIteratorWrapper(this)
    }

    public func current(): Int32

    public func currentCodePoint(): Int32 {
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

    public func getLength(): Int32

    public func getIndex(): Int32

    public override func next(): Int32

    public override func nextCodePoint(): Int32 {
        let ch1 = next()
        if (UTF16.isLeadSurrogate(ch1)) {
            let ch2 = next()
            if (UTF16.isTrailSurrogate(ch2)) {
                return Character.toCodePoint(Char(ch1), Char(ch2))
            } else if (ch2 != DONE) {
                previous()
            }
        }
        return ch1
    }

    public func previous(): Int32

    public func previousCodePoint(): Int32 {
        let ch1 = previous()
        if (UTF16.isTrailSurrogate(ch1)) {
            let ch2 = previous()
            if (UTF16.isLeadSurrogate(ch2)) {
                return Character.toCodePoint(Char(ch2), Char(ch1))
            } else if (ch2 != DONE) {
                next()
            }
        }
        return ch1
    }

    public func setIndex(index: Int32): Unit

    public func setToLimit(): Unit {
        setIndex(getLength())
    }

    public func setToStart(): Unit {
        setIndex(0)
    }

    public func getText(fillIn: Array<Char>, offset: Int32): Int32

    public func getText(fillIn: Array<Char>): Int32 {
        return getText(fillIn, 0)
    }

    public func getText(): String {
        let text = Array<Char>(Int64(getLength())) { _ => '\u{0000}' }
        getText(text)
        return String(text)
    }

    public func moveIndex(delta: Int32): Int32 {
        let x = max(0, min(getIndex() + delta, getLength()))
        setIndex(x)
        return x
    }

    public func moveCodePointIndex(delta: Int32): Int32 {
        var tempdelta = delta
        if (tempdelta > 0) {
            while (tempdelta > 0 && nextCodePoint() != DONE) {
                tempdelta--
            }
        } else {
            while (tempdelta < 0 && previousCodePoint() != DONE) {
                tempdelta++
            }
        }
        if (tempdelta != 0) {
            throw IndexOutOfBoundsException()
        }
        return getIndex()
    }

    public override func clone(): Object {
        return super.toString()
    }
}
