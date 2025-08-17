package icu4cj.message2


class InputSource {
    let buffer: String

    private var cursor: Int32 = 0

    private var lastReadCursor = -1

    private var lastReadCount = 0

    init(input: String) {
        if (input.isNone()) {
            throw IllegalArgumentException("Input string should not be null")
        }
        this.buffer = input
        this.cursor = 0
    }

    public func atEnd(): Bool {
        return cursor >= Int32(buffer.size)
    }

    public func peekChar(): Int32 {
        if (atEnd()) {
            return -1
        }
        return Int32(UInt32(Char(buffer[Int64(cursor)])))
    }

    public func readCodePoint(): Int32 {
        if (lastReadCursor != cursor) {
            lastReadCursor = cursor
            lastReadCount = 1
        } else {
            lastReadCount++
            if (lastReadCount >= 10) {
                throw Exception("Stuck in a loop!")
            }
        }
        if (atEnd()) {
            return -1
        }
        let c = Char(buffer[Int64(match (0) { case _ => cursor++; cursor - 1 })])
        if (Character.isHighSurrogate(c)) {
            if (!atEnd()) {
                let c2 = Char(buffer[Int64(match (0) { case _ => cursor++; cursor - 1 })])
                if (Character.isLowSurrogate(c2)) {
                    return Character.toCodePoint(c, c2)
                } else {
                    cursor--
                    return Int32(UInt32(c))
                }
            }
        }
        return Int32(UInt32(c))
    }

    public func backup(amount: Int32): Unit {
        cursor -= amount
    }

    public func getPosition(): Int32 {
        return cursor
    }

    public func skip(amount: Int32): Unit {
        cursor += amount
    }

    public func gotoPosition(position: Int32): Unit {
        cursor = position
    }
}
