package icu4cj.impl


public class StringSegment <: String {
    private let str: String

    private var start: Int32 = 0

    private var end: Int32 = 0

    private var foldCase: Bool = false

    public init(str: String, foldCase: Bool) {
        this.str = str
        this.start = 0
        this.end = Int32(str.size)
        this.foldCase = foldCase
    }

    public func getOffset(): Int32 {
        return start
    }

    public func setOffset(start: Int32): Unit {
        if (!(start <= end)) {
            throw AssertionError()
        }
        this.start = start
    }

    public func adjustOffset(delta: Int32): Unit {
        if (!(start + delta >= 0)) {
            throw AssertionError()
        }
        if (!(start + delta <= end)) {
            throw AssertionError()
        }
        start += delta
    }

    public func adjustOffsetByCodePoint(): Unit {
        start += Character.charCount(getCodePoint())
    }

    public func setLength(length: Int32): Unit {
        if (!(length >= 0)) {
            throw AssertionError()
        }
        if (!(start + length <= Int32(str.size))) {
            throw AssertionError()
        }
        end = start + length
    }

    public func resetLength(): Unit {
        end = Int32(str.size)
    }

    public override func length(): Int32 {
        return end - start
    }

    public override func charAt(index: Int32): Char {
        return Char(str[Int64(index + start)])
    }

    public override func subSequence(start: Int32, end: Int32): String {
        return str.subSequence(start + this.start, end + this.start)
    }

    public func getCodePoint(): Int32 {
        if (!(start < end)) {
            throw AssertionError()
        }
        let lead = Char(str[Int64(start)])
        let trail: Char
        if (Character.isHighSurrogate(lead) && start + 1 < end && Character.isLowSurrogate(match (0) { case _ => trail = Char(str[Int64(start + 1)]); trail })) {
            return Character.toCodePoint(lead, trail)
        }
        return Int32(UInt32(lead))
    }

    public func codePointAt(index: Int32): Int32 {
        return str.codePointAt(start + index)
    }

    public func startsWith(otherCp: Int32): Bool {
        return codePointsEqual(getCodePoint(), otherCp, foldCase)
    }

    public func startsWith(uniset: UnicodeSet): Bool {
        let cp = getCodePoint()
        if (cp == -1) {
            return false
        }
        return uniset.contains(cp)
    }

    public func startsWith(other: String): Bool {
        if (other.isNone() || other.size == 0 || length() == 0) {
            return false
        }
        let cp1 = Character.codePointAt(this, 0)
        let cp2 = Character.codePointAt(other, 0)
        return codePointsEqual(cp1, cp2, foldCase)
    }

    public func getCommonPrefixLength(other: String): Int32 {
        return getPrefixLengthInternal(other, foldCase)
    }

    public func getCaseSensitivePrefixLength(other: String): Int32 {
        return getPrefixLengthInternal(other, false)
    }

    private func getPrefixLengthInternal(other: String, foldCase: Bool): Int32 {
        if (!(other.size != 0)) {
            throw AssertionError()
        }
        var offset = 0
        while (offset < min(length(), other.size)) {
            let cp1 = Character.codePointAt(this, offset)
            let cp2 = Character.codePointAt(other, offset)
            if (!codePointsEqual(cp1, cp2, foldCase)) {
                break
            }
            offset += Character.charCount(cp1)
        }
        return offset
    }

    private static func codePointsEqual(cp1: Int32, cp2: Int32, foldCase: Bool): Bool {
        var tempcp1 = cp1
        var tempcp2 = cp2
        if (tempcp1 == tempcp2) {
            return true
        }
        if (!foldCase) {
            return false
        }
        tempcp1 = UCharacter.foldCase(tempcp1, true)
        tempcp2 = UCharacter.foldCase(tempcp2, true)
        return tempcp1 == tempcp2
    }

    public func contentEquals(other: String): Bool {
        return Utility.charSequenceEquals(this, other)
    }

    public override func toString(): String {
        return str[0..Int64(start)] + "[" + str[Int64(start)..Int64(end)] + "]" + str[Int64(end)..]
    }

    public func asString(): String {
        return str[Int64(start)..Int64(end)]
    }
}
