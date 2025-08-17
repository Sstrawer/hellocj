package icu4cj.text


public class UTF16 {
    public static let SINGLE_CHAR_BOUNDARY = 1

    public static let LEAD_SURROGATE_BOUNDARY = 2

    public static let TRAIL_SURROGATE_BOUNDARY = 5

    public static let CODEPOINT_MIN_VALUE = 0

    public static let CODEPOINT_MAX_VALUE = 1114111

    public static let SUPPLEMENTARY_MIN_VALUE = 65536

    public static let LEAD_SURROGATE_MIN_VALUE = 55296

    public static let TRAIL_SURROGATE_MIN_VALUE = 56320

    public static let LEAD_SURROGATE_MAX_VALUE = 56319

    public static let TRAIL_SURROGATE_MAX_VALUE = 57343

    public static let SURROGATE_MIN_VALUE = LEAD_SURROGATE_MIN_VALUE

    public static let SURROGATE_MAX_VALUE = TRAIL_SURROGATE_MAX_VALUE

    private static let LEAD_SURROGATE_BITMASK = -1024

    private static let TRAIL_SURROGATE_BITMASK = -1024

    private static let SURROGATE_BITMASK = -2048

    private static let LEAD_SURROGATE_BITS = 55296

    private static let TRAIL_SURROGATE_BITS = 56320

    private static let SURROGATE_BITS = 55296


    public static func charAt(source: String, offset16: Int32): Int32 {
        let single = Char(source[Int64(offset16)])
        if (Int32(UInt32(single)) < LEAD_SURROGATE_MIN_VALUE) {
            return Int32(UInt32(single))
        }
        return _charAt(source, offset16, single)
    }

    private static func _charAt(source: String, offset16: Int32, single: Char): Int32 {
        var tempoffset16 = offset16
        if (Int32(UInt32(single)) > TRAIL_SURROGATE_MAX_VALUE) {
            return Int32(UInt32(single))
        }
        if (Int32(UInt32(single)) <= LEAD_SURROGATE_MAX_VALUE) {
            tempoffset16++
            if (Int32(source.size) != tempoffset16) {
                let trail = Char(source[Int64(tempoffset16)])
                if (Int32(UInt32(trail)) >= TRAIL_SURROGATE_MIN_VALUE && Int32(UInt32(trail)) <= TRAIL_SURROGATE_MAX_VALUE) {
                    return Character.toCodePoint(single, trail)
                }
            }
        } else {
            tempoffset16--
            if (tempoffset16 >= 0) {
                let lead = Char(source[Int64(tempoffset16)])
                if (Int32(UInt32(lead)) >= LEAD_SURROGATE_MIN_VALUE && Int32(UInt32(lead)) <= LEAD_SURROGATE_MAX_VALUE) {
                    return Character.toCodePoint(lead, single)
                }
            }
        }
        return Int32(UInt32(single))
    }

    public static func charAt(source: String, offset16: Int32): Int32 {
        let single = source[offset16]
        if (Int32(UInt32(single)) < UTF16.LEAD_SURROGATE_MIN_VALUE) {
            return Int32(UInt32(single))
        }
        return _charAt(source, offset16, single)
    }

    private static func _charAt(source: String, offset16: Int32, single: Char): Int32 {
        var tempoffset16 = offset16
        if (Int32(UInt32(single)) > UTF16.TRAIL_SURROGATE_MAX_VALUE) {
            return Int32(UInt32(single))
        }
        if (Int32(UInt32(single)) <= UTF16.LEAD_SURROGATE_MAX_VALUE) {
            tempoffset16++
            if (source.size != tempoffset16) {
                let trail = source[tempoffset16]
                if (Int32(UInt32(trail)) >= UTF16.TRAIL_SURROGATE_MIN_VALUE && Int32(UInt32(trail)) <= UTF16.TRAIL_SURROGATE_MAX_VALUE) {
                    return Character.toCodePoint(single, trail)
                }
            }
        } else {
            tempoffset16--
            if (tempoffset16 >= 0) {
                let lead = source[tempoffset16]
                if (Int32(UInt32(lead)) >= UTF16.LEAD_SURROGATE_MIN_VALUE && Int32(UInt32(lead)) <= UTF16.LEAD_SURROGATE_MAX_VALUE) {
                    return Character.toCodePoint(lead, single)
                }
            }
        }
        return Int32(UInt32(single))
    }

    public static func charAt(source: StringBuffer, offset16: Int32): Int32 {
        var tempoffset16 = offset16
        if (tempoffset16 < 0 || tempoffset16 >= Int32(source.size)) {
            throw Exception(tempoffset16.toString())
        }
        let single = source.get(Int64(tempoffset16))
        if (!isSurrogate(Int32(UInt32(single)))) {
            return Int32(UInt32(single))
        }
        if (Int32(UInt32(single)) <= LEAD_SURROGATE_MAX_VALUE) {
            tempoffset16++
            if (Int32(source.size) != tempoffset16) {
                let trail = source.get(Int64(tempoffset16))
                if (isTrailSurrogate(Int32(UInt32(trail)))) {
                    return Character.toCodePoint(single, trail)
                }
            }
        } else {
            tempoffset16--
            if (tempoffset16 >= 0) {
                let lead = source.get(Int64(tempoffset16))
                if (isLeadSurrogate(Int32(UInt32(lead)))) {
                    return Character.toCodePoint(lead, single)
                }
            }
        }
        return Int32(UInt32(single))
    }

    public static func charAt(source: Array<Char>, start: Int32, limit: Int32, offset16: Int32): Int32 {
        var tempoffset16 = offset16
        tempoffset16 += start
        if (tempoffset16 < start || tempoffset16 >= limit) {
            throw IndexOutOfBoundsException(tempoffset16)
        }
        let single = source[Int64(tempoffset16)]
        if (!isSurrogate(Int32(UInt32(single)))) {
            return Int32(UInt32(single))
        }
        if (Int32(UInt32(single)) <= LEAD_SURROGATE_MAX_VALUE) {
            tempoffset16++
            if (tempoffset16 >= limit) {
                return Int32(UInt32(single))
            }
            let trail = source[Int64(tempoffset16)]
            if (isTrailSurrogate(Int32(UInt32(trail)))) {
                return Character.toCodePoint(single, trail)
            }
        } else {
            if (tempoffset16 == start) {
                return Int32(UInt32(single))
            }
            tempoffset16--
            let lead = source[Int64(tempoffset16)]
            if (isLeadSurrogate(Int32(UInt32(lead)))) {
                return Character.toCodePoint(lead, single)
            }
        }
        return Int32(UInt32(single))
    }

    public static func charAt(source: Replaceable, offset16: Int32): Int32 {
        var tempoffset16 = offset16
        if (tempoffset16 < 0 || tempoffset16 >= source.size) {
            throw Exception(tempoffset16.toString())
        }
        let single = source.toRuneArray()[tempoffset16]
        if (!isSurrogate(Int32(UInt32(single)))) {
            return Int32(UInt32(single))
        }
        if (Int32(UInt32(single)) <= LEAD_SURROGATE_MAX_VALUE) {
            tempoffset16++
            if (source.size != tempoffset16) {
                let trail = source.toRuneArray()[tempoffset16]
                if (isTrailSurrogate(Int32(UInt32(trail)))) {
                    return Character.toCodePoint(single, trail)
                }
            }
        } else {
            tempoffset16--
            if (tempoffset16 >= 0) {
                let lead = source.toRuneArray()[tempoffset16]
                if (isLeadSurrogate(Int32(UInt32(lead)))) {
                    return Character.toCodePoint(lead, single)
                }
            }
        }
        return Int32(UInt32(single))
    }

    public static func getCharCount(char32: Int32): Int32 {
        if (char32 < SUPPLEMENTARY_MIN_VALUE) {
            return 1
        }
        return 2
    }

    public static func bounds(source: String, offset16: Int32): Int32 {
        var tempoffset16 = offset16
        let ch = Char(source[Int64(tempoffset16)])
        if (isSurrogate(Int32(UInt32(ch)))) {
            if (isLeadSurrogate(Int32(UInt32(ch)))) {
                if (match (0) { case _ => tempoffset16++; tempoffset16 } < Int32(source.size) && isTrailSurrogate(Int32(UInt32(Char(source[Int64(tempoffset16)]))))) {
                    return LEAD_SURROGATE_BOUNDARY
                }
            } else {
                tempoffset16--
                if (tempoffset16 >= 0 && isLeadSurrogate(Int32(UInt32(Char(source[Int64(tempoffset16)]))))) {
                    return TRAIL_SURROGATE_BOUNDARY
                }
            }
        }
        return SINGLE_CHAR_BOUNDARY
    }

    public static func bounds(source: StringBuffer, offset16: Int32): Int32 {
        var tempoffset16 = offset16
        let ch = source.get(Int64(tempoffset16))
        if (isSurrogate(Int32(UInt32(ch)))) {
            if (isLeadSurrogate(Int32(UInt32(ch)))) {
                if (match (0) { case _ => tempoffset16++; tempoffset16 } < Int32(source.size) && isTrailSurrogate(Int32(UInt32(source.get(Int64(tempoffset16)))))) {
                    return LEAD_SURROGATE_BOUNDARY
                }
            } else {
                tempoffset16--
                if (tempoffset16 >= 0 && isLeadSurrogate(Int32(UInt32(source.get(Int64(tempoffset16)))))) {
                    return TRAIL_SURROGATE_BOUNDARY
                }
            }
        }
        return SINGLE_CHAR_BOUNDARY
    }

    public static func bounds(source: Array<Char>, start: Int32, limit: Int32, offset16: Int32): Int32 {
        var tempoffset16 = offset16
        tempoffset16 += start
        if (tempoffset16 < start || tempoffset16 >= limit) {
            throw IndexOutOfBoundsException(tempoffset16)
        }
        let ch = source[Int64(tempoffset16)]
        if (isSurrogate(Int32(UInt32(ch)))) {
            if (isLeadSurrogate(Int32(UInt32(ch)))) {
                tempoffset16++
                if (tempoffset16 < limit && isTrailSurrogate(Int32(UInt32(source[Int64(tempoffset16)])))) {
                    return LEAD_SURROGATE_BOUNDARY
                }
            } else {
                tempoffset16--
                if (tempoffset16 >= start && isLeadSurrogate(Int32(UInt32(source[Int64(tempoffset16)])))) {
                    return TRAIL_SURROGATE_BOUNDARY
                }
            }
        }
        return SINGLE_CHAR_BOUNDARY
    }

    public static func isSurrogate(codePoint: Int32): Bool {
        return (codePoint & SURROGATE_BITMASK) == SURROGATE_BITS
    }

    public static func isTrailSurrogate(codePoint: Int32): Bool {
        return (codePoint & TRAIL_SURROGATE_BITMASK) == TRAIL_SURROGATE_BITS
    }

    public static func isLeadSurrogate(codePoint: Int32): Bool {
        return (codePoint & LEAD_SURROGATE_BITMASK) == LEAD_SURROGATE_BITS
    }

    public static func getLeadSurrogate(char32: Int32): Char {
        if (char32 >= SUPPLEMENTARY_MIN_VALUE) {
            return Char(LEAD_SURROGATE_OFFSET_ + (shr(char32, LEAD_SURROGATE_SHIFT_)))
        }
        return Char(0)
    }

    public static func getTrailSurrogate(char32: Int32): Char {
        if (char32 >= SUPPLEMENTARY_MIN_VALUE) {
            return Char(TRAIL_SURROGATE_MIN_VALUE + (char32 & TRAIL_SURROGATE_MASK_))
        }
        return Char(char32)
    }

    public static func valueOf(char32: Int32): String {
        if (char32 < CODEPOINT_MIN_VALUE || char32 > CODEPOINT_MAX_VALUE) {
            throw IllegalArgumentException("Illegal codepoint")
        }
        return toString(char32)
    }

    public static func valueOf(source: String, offset16: Int32): String {
        match (bounds(source, offset16)) {
            case 2 => return source[Int64(offset16)..Int64(offset16 + 2)]
            case 5 => return source[Int64(offset16 - 1)..Int64(offset16 + 1)]
            case _ => return source[Int64(offset16)..Int64(offset16 + 1)]
        }
    }

    public static func valueOf(source: StringBuffer, offset16: Int32): String {
        match (bounds(source, offset16)) {
            case 2 => return source.substring(offset16, offset16 + 2)
            case 5 => return source.substring(offset16 - 1, offset16 + 1)
            case _ => return source.substring(offset16, offset16 + 1)
        }
    }

    public static func valueOf(source: Array<Char>, start: Int32, limit: Int32, offset16: Int32): String {
        match (bounds(source, start, limit, offset16)) {
            case 2 => return String(source)[Int64(start + offset16)..Int64(start + offset16) + 2]
            case 5 => return String(source)[Int64(start + offset16 - 1)..Int64(start + offset16 - 1) + 2]
            case _ => ()
        }
        return String(source)[Int64(start + offset16)..Int64(start + offset16) + 1]
    }

    public static func findOffsetFromCodePoint(source: String, offset32: Int32): Int32 {
        var ch: Char = '\u{0000}'
        let size = Int32(source.size)
        var result = 0
        var count = offset32
        if (offset32 < 0 || offset32 > size) {
            throw Exception(offset32.toString())
        }
        while (result < size && count > 0) {
            ch = Char(source[Int64(result)])
            if (isLeadSurrogate(Int32(UInt32(ch))) && ((result + 1) < size) && isTrailSurrogate(Int32(UInt32(Char(source[Int64(result + 1)]))))) {
                result++
            }
            count--
            result++
        }
        if (count != 0) {
            throw Exception(offset32.toString())
        }
        return result
    }

    public static func findOffsetFromCodePoint(source: StringBuffer, offset32: Int32): Int32 {
        var ch: Char = '\u{0000}'
        let size = Int32(source.size)
        var result = 0
        var count = offset32
        if (offset32 < 0 || offset32 > size) {
            throw Exception(offset32.toString())
        }
        while (result < size && count > 0) {
            ch = source.get(Int64(result))
            if (isLeadSurrogate(Int32(UInt32(ch))) && ((result + 1) < size) && isTrailSurrogate(Int32(UInt32(source.get(Int64(result + 1)))))) {
                result++
            }
            count--
            result++
        }
        if (count != 0) {
            throw Exception(offset32.toString())
        }
        return result
    }

    public static func findOffsetFromCodePoint(source: Array<Char>, start: Int32, limit: Int32, offset32: Int32): Int32 {
        var ch: Char = '\u{0000}'
        var result = start
        var count = offset32
        if (offset32 > limit - start) {
            throw IndexOutOfBoundsException(offset32)
        }
        while (result < limit && count > 0) {
            ch = source[Int64(result)]
            if (isLeadSurrogate(Int32(UInt32(ch))) && ((result + 1) < limit) && isTrailSurrogate(Int32(UInt32(source[Int64(result + 1)])))) {
                result++
            }
            count--
            result++
        }
        if (count != 0) {
            throw IndexOutOfBoundsException(offset32)
        }
        return result - start
    }

    public static func findCodePointOffset(source: String, offset16: Int32): Int32 {
        if (offset16 < 0 || offset16 > Int32(source.size)) {
            throw Exception(offset16.toString())
        }
        var result = 0
        var ch: Char = '\u{0000}'
        var hadLeadSurrogate = false
        var i = 0
        while (i < offset16) {
            ch = Char(source[Int64(i)])
            if (hadLeadSurrogate && isTrailSurrogate(Int32(UInt32(ch)))) {
                hadLeadSurrogate = false
            } else {
                hadLeadSurrogate = isLeadSurrogate(Int32(UInt32(ch)))
                result++
            }
            i++
        }
        if (offset16 == Int32(source.size)) {
            return result
        }
        if (hadLeadSurrogate && (isTrailSurrogate(Int32(UInt32(Char(source[Int64(offset16)])))))) {
            result--
        }
        return result
    }

    public static func findCodePointOffset(source: StringBuffer, offset16: Int32): Int32 {
        if (offset16 < 0 || offset16 > Int32(source.size)) {
            throw Exception(offset16.toString())
        }
        var result = 0
        var ch: Char = '\u{0000}'
        var hadLeadSurrogate = false
        var i = 0
        while (i < offset16) {
            ch = source.get(Int64(i))
            if (hadLeadSurrogate && isTrailSurrogate(Int32(UInt32(ch)))) {
                hadLeadSurrogate = false
            } else {
                hadLeadSurrogate = isLeadSurrogate(Int32(UInt32(ch)))
                result++
            }
            i++
        }
        if (offset16 == Int32(source.size)) {
            return result
        }
        if (hadLeadSurrogate && (isTrailSurrogate(Int32(UInt32(source.get(Int64(offset16))))))) {
            result--
        }
        return result
    }

    public static func findCodePointOffset(source: Array<Char>, start: Int32, limit: Int32, offset16: Int32): Int32 {
        var tempoffset16 = offset16
        tempoffset16 += start
        if (tempoffset16 > limit) {
            throw Exception(tempoffset16.toString())
        }
        var result = 0
        var ch: Char = '\u{0000}'
        var hadLeadSurrogate = false
        var i = start
        while (i < tempoffset16) {
            ch = source[Int64(i)]
            if (hadLeadSurrogate && isTrailSurrogate(Int32(UInt32(ch)))) {
                hadLeadSurrogate = false
            } else {
                hadLeadSurrogate = isLeadSurrogate(Int32(UInt32(ch)))
                result++
            }
            i++
        }
        if (tempoffset16 == limit) {
            return result
        }
        if (hadLeadSurrogate && (isTrailSurrogate(Int32(UInt32(source[Int64(tempoffset16)]))))) {
            result--
        }
        return result
    }

    public static func append(target: StringBuffer, char32: Int32): StringBuffer {
        if (char32 < CODEPOINT_MIN_VALUE || char32 > CODEPOINT_MAX_VALUE) {
            throw IllegalArgumentException("Illegal codepoint: " + char32.format("x"))
        }
        if (char32 >= SUPPLEMENTARY_MIN_VALUE) {
            target.append(getLeadSurrogate(char32))
            target.append(getTrailSurrogate(char32))
        } else {
            target.append(Char(char32))
        }
        return target
    }

    public static func appendCodePoint(target: StringBuffer, cp: Int32): StringBuffer {
        return append(target, cp)
    }

    public static func append(target: Array<Char>, limit: Int32, char32: Int32): Int32 {
        var templimit = limit
        if (char32 < CODEPOINT_MIN_VALUE || char32 > CODEPOINT_MAX_VALUE) {
            throw IllegalArgumentException("Illegal codepoint")
        }
        if (char32 >= SUPPLEMENTARY_MIN_VALUE) {
            target[Int64(match (0) { case _ => templimit++; templimit - 1 })] = getLeadSurrogate(char32)
            target[Int64(match (0) { case _ => templimit++; templimit - 1 })] = getTrailSurrogate(char32)
        } else {
            target[Int64(match (0) { case _ => templimit++; templimit - 1 })] = Char(char32)
        }
        return templimit
    }

    public static func countCodePoint(source: String): Int32 {
        if (source.isNone() || Int32(source.size) == 0) {
            return 0
        }
        return findCodePointOffset(source, Int32(source.size))
    }

    public static func countCodePoint(source: StringBuffer): Int32 {
        if (source.isNone() || Int32(source.size) == 0) {
            return 0
        }
        return findCodePointOffset(source, Int32(source.size))
    }

    public static func countCodePoint(source: Array<Char>, start: Int32, limit: Int32): Int32 {
        if (source.isNone() || Int32(source.size) == 0) {
            return 0
        }
        return findCodePointOffset(source, start, limit, limit - start)
    }

    public static func setCharAt(target: StringBuffer, offset16: Int32, char32: Int32): Unit {
        var tempoffset16 = offset16
        var count = 1
        let single = target.get(Int64(tempoffset16))
        if (isSurrogate(Int32(UInt32(single)))) {
            if (isLeadSurrogate(Int32(UInt32(single))) && (Int32(target.size) > tempoffset16 + 1) && isTrailSurrogate(Int32(UInt32(target.get(Int64(tempoffset16 + 1)))))) {
                count++
            } else {
                if (isTrailSurrogate(Int32(UInt32(single))) && (tempoffset16 > 0) && isLeadSurrogate(Int32(UInt32(target.get(Int64(tempoffset16 - 1)))))) {
                    tempoffset16--
                    count++
                }
            }
        }
        target.replace(tempoffset16, tempoffset16 + count, valueOf(char32))
    }

    public static func setCharAt(target: Array<Char>, limit: Int32, offset16: Int32, char32: Int32): Int32 {
        var tempoffset16 = offset16
        if (tempoffset16 >= limit) {
            throw IndexOutOfBoundsException(tempoffset16)
        }
        var count = 1
        let single = target[Int64(tempoffset16)]
        if (isSurrogate(Int32(UInt32(single)))) {
            if (isLeadSurrogate(Int32(UInt32(single))) && (Int32(target.size) > tempoffset16 + 1) && isTrailSurrogate(Int32(UInt32(target[Int64(tempoffset16 + 1)])))) {
                count++
            } else {
                if (isTrailSurrogate(Int32(UInt32(single))) && (tempoffset16 > 0) && isLeadSurrogate(Int32(UInt32(target[Int64(tempoffset16 - 1)])))) {
                    tempoffset16--
                    count++
                }
            }
        }
        let str = valueOf(char32)
        var result = limit
        let strlength = Int32(str.size)
        target[Int64(tempoffset16)] = Char(str[0])
        if (count == strlength) {
            if (count == 2) {
                target[Int64(tempoffset16 + 1)] = Char(str[1])
            }
        } else {
            arraycopy(target, Int64(tempoffset16 + count), target, Int64(tempoffset16 + strlength), Int64(limit - (tempoffset16 + count)))
            if (count < strlength) {
                target[Int64(tempoffset16 + 1)] = Char(str[1])
                result++
                if (result < Int32(target.size)) {
                    target[Int64(result)] = Char(0)
                }
            } else {
                result--
                target[Int64(result)] = Char(0)
            }
        }
        return result
    }

    public static func moveCodePointOffset(source: String, offset16: Int32, shift32: Int32): Int32 {
        var result = offset16
        let size = Int32(source.size)
        var count: Int32 = 0
        var ch: Char = '\u{0000}'
        if (offset16 < 0 || offset16 > size) {
            throw Exception(offset16.toString())
        }
        if (shift32 > 0) {
            if (shift32 + offset16 > size) {
                throw Exception(offset16.toString())
            }
            count = shift32
            while (result < size && count > 0) {
                ch = Char(source[Int64(result)])
                if (isLeadSurrogate(Int32(UInt32(ch))) && ((result + 1) < size) && isTrailSurrogate(Int32(UInt32(Char(source[Int64(result + 1)]))))) {
                    result++
                }
                count--
                result++
            }
        } else {
            if (offset16 + shift32 < 0) {
                throw Exception(offset16.toString())
            }
            count = -shift32
            while (count > 0) {
                result--
                if (result < 0) {
                    break
                }
                ch = Char(source[Int64(result)])
                if (isTrailSurrogate(Int32(UInt32(ch))) && result > 0 && isLeadSurrogate(Int32(UInt32(Char(source[Int64(result - 1)]))))) {
                    result--
                }
                count--
            }
        }
        if (count != 0) {
            throw Exception(shift32.toString())
        }
        return result
    }

    public static func moveCodePointOffset(source: StringBuffer, offset16: Int32, shift32: Int32): Int32 {
        var result = offset16
        let size = Int32(source.size)
        var count: Int32 = 0
        var ch: Char = '\u{0000}'
        if (offset16 < 0 || offset16 > size) {
            throw Exception(offset16.toString())
        }
        if (shift32 > 0) {
            if (shift32 + offset16 > size) {
                throw Exception(offset16.toString())
            }
            count = shift32
            while (result < size && count > 0) {
                ch = source.get(Int64(result))
                if (isLeadSurrogate(Int32(UInt32(ch))) && ((result + 1) < size) && isTrailSurrogate(Int32(UInt32(source.get(Int64(result + 1)))))) {
                    result++
                }
                count--
                result++
            }
        } else {
            if (offset16 + shift32 < 0) {
                throw Exception(offset16.toString())
            }
            count = -shift32
            while (count > 0) {
                result--
                if (result < 0) {
                    break
                }
                ch = source.get(Int64(result))
                if (isTrailSurrogate(Int32(UInt32(ch))) && result > 0 && isLeadSurrogate(Int32(UInt32(source.get(Int64(result - 1)))))) {
                    result--
                }
                count--
            }
        }
        if (count != 0) {
            throw Exception(shift32.toString())
        }
        return result
    }

    public static func moveCodePointOffset(source: Array<Char>, start: Int32, limit: Int32, offset16: Int32, shift32: Int32): Int32 {
        let size = Int32(source.size)
        var count: Int32 = 0
        var ch: Char = '\u{0000}'
        var result = offset16 + start
        if (start < 0 || limit < start) {
            throw Exception(start.toString())
        }
        if (limit > size) {
            throw Exception(limit.toString())
        }
        if (offset16 < 0 || result > limit) {
            throw Exception(offset16.toString())
        }
        if (shift32 > 0) {
            if (shift32 + result > size) {
                throw Exception(result.toString())
            }
            count = shift32
            while (result < limit && count > 0) {
                ch = source[Int64(result)]
                if (isLeadSurrogate(Int32(UInt32(ch))) && (result + 1 < limit) && isTrailSurrogate(Int32(UInt32(source[Int64(result + 1)])))) {
                    result++
                }
                count--
                result++
            }
        } else {
            if (result + shift32 < start) {
                throw Exception(result.toString())
            }
            count = -shift32
            while (count > 0) {
                result--
                if (result < start) {
                    break
                }
                ch = source[Int64(result)]
                if (isTrailSurrogate(Int32(UInt32(ch))) && result > start && isLeadSurrogate(Int32(UInt32(source[Int64(result - 1)])))) {
                    result--
                }
                count--
            }
        }
        if (count != 0) {
            throw Exception(shift32.toString())
        }
        result -= start
        return result
    }

    public static func insert(target: StringBuffer, offset16: Int32, char32: Int32): StringBuffer {
        var tempoffset16 = offset16
        let str = valueOf(char32)
        if (tempoffset16 != Int32(target.size) && bounds(target, tempoffset16) == TRAIL_SURROGATE_BOUNDARY) {
            tempoffset16++
        }
        target.insert(tempoffset16, str)
        return target
    }

    public static func insert(target: Array<Char>, limit: Int32, offset16: Int32, char32: Int32): Int32 {
        var tempoffset16 = offset16
        let str = valueOf(char32)
        if (tempoffset16 != limit && bounds(target, 0, limit, tempoffset16) == TRAIL_SURROGATE_BOUNDARY) {
            tempoffset16++
        }
        let size = Int32(str.size)
        if (limit + size > Int32(target.size)) {
            throw IndexOutOfBoundsException(tempoffset16 + size)
        }
        arraycopy(target, Int64(tempoffset16), target, Int64(tempoffset16 + size), Int64(limit - tempoffset16))
        target[Int64(tempoffset16)] = Char(str[0])
        if (size == 2) {
            target[Int64(tempoffset16 + 1)] = Char(str[1])
        }
        return limit + size
    }

    public static func delete(target: StringBuffer, offset16: Int32): StringBuffer {
        var tempoffset16 = offset16
        var count = 1
        match (bounds(target, tempoffset16)) {
            case 2 => count++
            case 5 =>
                count++
                tempoffset16--
            case _ => ()
        }
        target.delete(tempoffset16, tempoffset16 + count)
        return target
    }

    public static func delete(target: Array<Char>, limit: Int32, offset16: Int32): Int32 {
        var tempoffset16 = offset16
        var count = 1
        match (bounds(target, 0, limit, tempoffset16)) {
            case 2 => count++
            case 5 =>
                count++
                tempoffset16--
            case _ => ()
        }
        arraycopy(target, Int64(tempoffset16 + count), target, Int64(tempoffset16), Int64(limit - (tempoffset16 + count)))
        target[Int64(limit - count)] = Char(0)
        return limit - count
    }

    public static func indexOf(source: String, char32: Int32): Int32 {
        if (char32 < CODEPOINT_MIN_VALUE || char32 > CODEPOINT_MAX_VALUE) {
            throw IllegalArgumentException("Argument char32 is not a valid codepoint")
        }
        if (char32 < LEAD_SURROGATE_MIN_VALUE || (char32 > TRAIL_SURROGATE_MAX_VALUE && char32 < SUPPLEMENTARY_MIN_VALUE)) {
            return indexOfWrap(source.indexOf(UInt8(UInt32(Char(char32)))))
        }
        if (char32 < SUPPLEMENTARY_MIN_VALUE) {
            let result = indexOfWrap(source.indexOf(UInt8(UInt32(Char(char32)))))
            if (result >= 0) {
                if (isLeadSurrogate(char32) && (result < Int32(source.size) - 1) && isTrailSurrogate(Int32(UInt32(Char(source[Int64(result + 1)]))))) {
                    return indexOf(source, char32, result + 1)
                }
                if (result > 0 && isLeadSurrogate(Int32(UInt32(Char(source[Int64(result - 1)]))))) {
                    return indexOf(source, char32, result + 1)
                }
            }
            return result
        }
        let char32str = toString(char32)
        return indexOfWrap(source.indexOf(char32str))
    }

    public static func indexOf(source: String, str: String): Int32 {
        let strLength = Int32(str.size)
        if (!isTrailSurrogate(Int32(UInt32(Char(str[0])))) && !isLeadSurrogate(Int32(UInt32(Char(str[Int64(strLength - 1)]))))) {
            return indexOfWrap(source.indexOf(str))
        }
        let result = indexOfWrap(source.indexOf(str))
        let resultEnd = result + strLength
        if (result >= 0) {
            if (isLeadSurrogate(Int32(UInt32(Char(str[Int64(strLength - 1)])))) && (result < Int32(source.size) - 1) && isTrailSurrogate(Int32(UInt32(Char(source[Int64(resultEnd + 1)]))))) {
                return indexOf(source, str, resultEnd + 1)
            }
            if (isTrailSurrogate(Int32(UInt32(Char(str[0])))) && result > 0 && isLeadSurrogate(Int32(UInt32(Char(source[Int64(result - 1)]))))) {
                return indexOf(source, str, resultEnd + 1)
            }
        }
        return result
    }

    public static func indexOf(source: String, char32: Int32, fromIndex: Int32): Int32 {
        if (char32 < CODEPOINT_MIN_VALUE || char32 > CODEPOINT_MAX_VALUE) {
            throw IllegalArgumentException("Argument char32 is not a valid codepoint")
        }
        if (char32 < LEAD_SURROGATE_MIN_VALUE || (char32 > TRAIL_SURROGATE_MAX_VALUE && char32 < SUPPLEMENTARY_MIN_VALUE)) {
            return indexOfWrap(source.indexOf(UInt8(UInt32(Char(char32))), Int64(fromIndex)))
        }
        if (char32 < SUPPLEMENTARY_MIN_VALUE) {
            let result = indexOfWrap(source.indexOf(UInt8(UInt32(Char(char32))), Int64(fromIndex)))
            if (result >= 0) {
                if (isLeadSurrogate(char32) && (result < Int32(source.size) - 1) && isTrailSurrogate(Int32(UInt32(Char(source[Int64(result + 1)]))))) {
                    return indexOf(source, char32, result + 1)
                }
                if (result > 0 && isLeadSurrogate(Int32(UInt32(Char(source[Int64(result - 1)]))))) {
                    return indexOf(source, char32, result + 1)
                }
            }
            return result
        }
        let char32str = toString(char32)
        return indexOfWrap(source.indexOf(char32str, Int64(fromIndex)))
    }

    public static func indexOf(source: String, str: String, fromIndex: Int32): Int32 {
        let strLength = Int32(str.size)
        if (!isTrailSurrogate(Int32(UInt32(Char(str[0])))) && !isLeadSurrogate(Int32(UInt32(Char(str[Int64(strLength - 1)]))))) {
            return indexOfWrap(source.indexOf(str, Int64(fromIndex)))
        }
        let result = indexOfWrap(source.indexOf(str, Int64(fromIndex)))
        let resultEnd = result + strLength
        if (result >= 0) {
            if (isLeadSurrogate(Int32(UInt32(Char(str[Int64(strLength - 1)])))) && (result < Int32(source.size) - 1) && isTrailSurrogate(Int32(UInt32(Char(source[Int64(resultEnd)]))))) {
                return indexOf(source, str, resultEnd + 1)
            }
            if (isTrailSurrogate(Int32(UInt32(Char(str[0])))) && result > 0 && isLeadSurrogate(Int32(UInt32(Char(source[Int64(result - 1)]))))) {
                return indexOf(source, str, resultEnd + 1)
            }
        }
        return result
    }

    public static func lastIndexOf(source: String, char32: Int32): Int32 {
        if (char32 < CODEPOINT_MIN_VALUE || char32 > CODEPOINT_MAX_VALUE) {
            throw IllegalArgumentException("Argument char32 is not a valid codepoint")
        }
        if (char32 < LEAD_SURROGATE_MIN_VALUE || (char32 > TRAIL_SURROGATE_MAX_VALUE && char32 < SUPPLEMENTARY_MIN_VALUE)) {
            return indexOfWrap(source.lastIndexOf(UInt8(UInt32(Char(char32)))))
        }
        if (char32 < SUPPLEMENTARY_MIN_VALUE) {
            let result = indexOfWrap(source.lastIndexOf(UInt8(UInt32(Char(char32)))))
            if (result >= 0) {
                if (isLeadSurrogate(char32) && (result < Int32(source.size) - 1) && isTrailSurrogate(Int32(UInt32(Char(source[Int64(result + 1)]))))) {
                    return lastIndexOf(source, char32, result - 1)
                }
                if (result > 0 && isLeadSurrogate(Int32(UInt32(Char(source[Int64(result - 1)]))))) {
                    return lastIndexOf(source, char32, result - 1)
                }
            }
            return result
        }
        let char32str = toString(char32)
        return indexOfWrap(source.lastIndexOf(char32str))
    }

    public static func lastIndexOf(source: String, str: String): Int32 {
        let strLength = Int32(str.size)
        if (!isTrailSurrogate(Int32(UInt32(Char(str[0])))) && !isLeadSurrogate(Int32(UInt32(Char(str[Int64(strLength - 1)]))))) {
            return indexOfWrap(source.lastIndexOf(str))
        }
        let result = indexOfWrap(source.lastIndexOf(str))
        if (result >= 0) {
            if (isLeadSurrogate(Int32(UInt32(Char(str[Int64(strLength - 1)])))) && (result < Int32(source.size) - 1) && isTrailSurrogate(Int32(UInt32(Char(source[Int64(result + strLength + 1)]))))) {
                return lastIndexOf(source, str, result - 1)
            }
            if (isTrailSurrogate(Int32(UInt32(Char(str[0])))) && result > 0 && isLeadSurrogate(Int32(UInt32(Char(source[Int64(result - 1)]))))) {
                return lastIndexOf(source, str, result - 1)
            }
        }
        return result
    }

    public static func lastIndexOf(source: String, char32: Int32, fromIndex: Int32): Int32 {
        if (char32 < CODEPOINT_MIN_VALUE || char32 > CODEPOINT_MAX_VALUE) {
            throw IllegalArgumentException("Argument char32 is not a valid codepoint")
        }
        if (char32 < LEAD_SURROGATE_MIN_VALUE || (char32 > TRAIL_SURROGATE_MAX_VALUE && char32 < SUPPLEMENTARY_MIN_VALUE)) {
            return indexOfWrap(source.lastIndexOf(UInt8(UInt32(Char(char32))), Int64(fromIndex)))
        }
        if (char32 < SUPPLEMENTARY_MIN_VALUE) {
            let result = indexOfWrap(source.lastIndexOf(UInt8(UInt32(Char(char32))), Int64(fromIndex)))
            if (result >= 0) {
                if (isLeadSurrogate(char32) && (result < Int32(source.size) - 1) && isTrailSurrogate(Int32(UInt32(Char(source[Int64(result + 1)]))))) {
                    return lastIndexOf(source, char32, result - 1)
                }
                if (result > 0 && isLeadSurrogate(Int32(UInt32(Char(source[Int64(result - 1)]))))) {
                    return lastIndexOf(source, char32, result - 1)
                }
            }
            return result
        }
        let char32str = toString(char32)
        return indexOfWrap(source.lastIndexOf(char32str, Int64(fromIndex)))
    }

    public static func lastIndexOf(source: String, str: String, fromIndex: Int32): Int32 {
        let strLength = Int32(str.size)
        if (!isTrailSurrogate(Int32(UInt32(Char(str[0])))) && !isLeadSurrogate(Int32(UInt32(Char(str[Int64(strLength - 1)]))))) {
            return indexOfWrap(source.lastIndexOf(str, Int64(fromIndex)))
        }
        let result = indexOfWrap(source.lastIndexOf(str, Int64(fromIndex)))
        if (result >= 0) {
            if (isLeadSurrogate(Int32(UInt32(Char(str[Int64(strLength - 1)])))) && (result < Int32(source.size) - 1) && isTrailSurrogate(Int32(UInt32(Char(source[Int64(result + strLength)]))))) {
                return lastIndexOf(source, str, result - 1)
            }
            if (isTrailSurrogate(Int32(UInt32(Char(str[0])))) && result > 0 && isLeadSurrogate(Int32(UInt32(Char(source[Int64(result - 1)]))))) {
                return lastIndexOf(source, str, result - 1)
            }
        }
        return result
    }

    public static func replace(source: String, oldChar32: Int32, newChar32: Int32): String {
        if (oldChar32 <= 0 || oldChar32 > CODEPOINT_MAX_VALUE) {
            throw IllegalArgumentException("Argument oldChar32 is not a valid codepoint")
        }
        if (newChar32 <= 0 || newChar32 > CODEPOINT_MAX_VALUE) {
            throw IllegalArgumentException("Argument newChar32 is not a valid codepoint")
        }
        var index = indexOf(source, oldChar32)
        if (index == -1) {
            return source
        }
        let newChar32Str = toString(newChar32)
        var oldChar32Size = 1
        let newChar32Size = Int32(newChar32Str.size)
        let result = StringBuffer(source)
        var resultIndex = index
        if (oldChar32 >= SUPPLEMENTARY_MIN_VALUE) {
            oldChar32Size = 2
        }
        while (index != -1) {
            let endResultIndex = resultIndex + oldChar32Size
            result.replace(resultIndex, endResultIndex, newChar32Str)
            let lastEndIndex = index + oldChar32Size
            index = indexOf(source, oldChar32, lastEndIndex)
            resultIndex += newChar32Size + index - lastEndIndex
        }
        return toString(result)
    }

    public static func replace(source: String, oldStr: String, newStr: String): String {
        var index = indexOf(source, oldStr)
        if (index == -1) {
            return source
        }
        let oldStrSize = Int32(oldStr.size)
        let newStrSize = Int32(newStr.size)
        let result = StringBuffer(source)
        var resultIndex = index
        while (index != -1) {
            let endResultIndex = resultIndex + oldStrSize
            result.replace(resultIndex, endResultIndex, newStr)
            let lastEndIndex = index + oldStrSize
            index = indexOf(source, oldStr, lastEndIndex)
            resultIndex += newStrSize + index - lastEndIndex
        }
        return toString(result)
    }

    public static func reverse(source: StringBuffer): StringBuffer {
        let length = Int32(source.size)
        let result = StringBuffer(length)
        var i = length
        while (match (0) { case _ => i--; i + 1 } > 0) {
            let ch = source.get(Int64(i))
            if (isTrailSurrogate(Int32(UInt32(ch))) && i > 0) {
                let ch2 = source.get(Int64(i - 1))
                if (isLeadSurrogate(Int32(UInt32(ch2)))) {
                    result.append(ch2)
                    result.append(ch)
                    i--
                    continue
                }
            }
            result.append(ch)
        }
        return result
    }

    public static func hasMoreCodePointsThan(source: String, number: Int32): Bool {
        var tempnumber = number
        if (tempnumber < 0) {
            return true
        }
        if (source.isNone()) {
            return false
        }
        let length = Int32(source.size)
        if ((shr((length + 1), 1)) > tempnumber) {
            return true
        }
        var maxsupplementary = length - tempnumber
        if (maxsupplementary <= 0) {
            return false
        }
        var start = 0
        while (true) {
            if (length == 0) {
                return false
            }
            if (tempnumber == 0) {
                return true
            }
            if (isLeadSurrogate(Int32(UInt32(Char(source[Int64(match (0) { case _ => start++; start - 1 })])))) && start != length && isTrailSurrogate(Int32(UInt32(Char(source[Int64(start)]))))) {
                start++
                if (match (0) { case _ => maxsupplementary--; maxsupplementary } <= 0) {
                    return false
                }
            }
            tempnumber--
        }
        throw Exception()
    }

    public static func hasMoreCodePointsThan(source: Array<Char>, start: Int32, limit: Int32, number: Int32): Bool {
        var tempstart = start
        var tempnumber = number
        let length = limit - tempstart
        if (length < 0 || tempstart < 0 || limit < 0) {
            throw IndexOutOfBoundsException("Start and limit indexes should be non-negative and start <= limit")
        }
        if (tempnumber < 0) {
            return true
        }
        if (source.isNone()) {
            return false
        }
        if ((shr((length + 1), 1)) > tempnumber) {
            return true
        }
        var maxsupplementary = length - tempnumber
        if (maxsupplementary <= 0) {
            return false
        }
        while (true) {
            if (length == 0) {
                return false
            }
            if (tempnumber == 0) {
                return true
            }
            if (isLeadSurrogate(Int32(UInt32(source[Int64(match (0) { case _ => tempstart++; tempstart - 1 })]))) && tempstart != limit && isTrailSurrogate(Int32(UInt32(source[Int64(tempstart)])))) {
                tempstart++
                if (match (0) { case _ => maxsupplementary--; maxsupplementary } <= 0) {
                    return false
                }
            }
            tempnumber--
        }
        throw Exception()
    }

    public static func hasMoreCodePointsThan(source: StringBuffer, number: Int32): Bool {
        var tempnumber = number
        if (tempnumber < 0) {
            return true
        }
        if (source.isNone()) {
            return false
        }
        let length = Int32(source.size)
        if ((shr((length + 1), 1)) > tempnumber) {
            return true
        }
        var maxsupplementary = length - tempnumber
        if (maxsupplementary <= 0) {
            return false
        }
        var start = 0
        while (true) {
            if (length == 0) {
                return false
            }
            if (tempnumber == 0) {
                return true
            }
            if (isLeadSurrogate(Int32(UInt32(source.get(Int64(match (0) { case _ => start++; start - 1 }))))) && start != length && isTrailSurrogate(Int32(UInt32(source.get(Int64(start)))))) {
                start++
                if (match (0) { case _ => maxsupplementary--; maxsupplementary } <= 0) {
                    return false
                }
            }
            tempnumber--
        }
        throw Exception()
    }

    public static func newString(codePoints: Array<Int32>, offset: Int32, count: Int32): String {
        if (count < 0) {
            throw IllegalArgumentException()
        }
        var chars: Array<Char> = Array<Char>(Int64(count)) { _ => '\u{0000}' }
        var w = 0
        var r = offset
        let e = offset + count
        while (r < e) {
            let cp = codePoints[Int64(r)]
            if (cp < 0 || cp > 1114111) {
                throw IllegalArgumentException()
            }
            while (true) {
                try {
                    if (cp < 65536) {
                        chars[Int64(w)] = Char(cp)
                        w++
                    } else {
                        chars[Int64(w)] = Char(LEAD_SURROGATE_OFFSET_ + (shr(cp, LEAD_SURROGATE_SHIFT_)))
                        chars[Int64(w + 1)] = Char(TRAIL_SURROGATE_MIN_VALUE + (cp & TRAIL_SURROGATE_MASK_))
                        w += 2
                    }
                    break
                } catch (ex: IndexOutOfBoundsException) {
                    let newlen = Int32(ceil(Float64(Int32(codePoints.size)) * (Float64(w + 2)) / (Float64(r - offset + 1))))
                    let temp = Array<Char>(Int64(newlen)) { _ => '\u{0000}' }
                    arraycopy(chars, 0, temp, 0, Int64(w))
                    chars = temp
                }
            }
            r++
        }
        return String(chars)[..Int64(w)]
    }

    public static func getSingleCodePoint(s: String): Int32 {
        if (s.isNone() || s.size == 0) {
            return -1
        } else if (s.size == 1) {
            return Int32(UInt32(s[0]))
        } else if (s.size > 2) {
            return -1
        }
        let cp = Character.codePointAt(s, 0)
        if (cp > 65535) {
            return cp
        }
        return -1
    }

    public static func compareCodePoint(codePoint: Int32, s: String): Int32 {
        if (s.isNone()) {
            return 1
        }
        let strLen = s.size
        if (strLen == 0) {
            return 1
        }
        let second = Character.codePointAt(s, 0)
        let diff = codePoint - second
        if (diff != 0) {
            return diff
        }
        return if (strLen == Character.charCount(codePoint)) { 0 } else { -1 }
    }

    private static let LEAD_SURROGATE_SHIFT_ = 10

    private static let TRAIL_SURROGATE_MASK_ = 1023

    private static let LEAD_SURROGATE_OFFSET_ = LEAD_SURROGATE_MIN_VALUE - (shr(SUPPLEMENTARY_MIN_VALUE, LEAD_SURROGATE_SHIFT_))

    private static func toString(ch: Int32): String {
        if (ch < SUPPLEMENTARY_MIN_VALUE) {
            return Char(ch).toString()
        }
        let result = StringBuilder()
        result.append(getLeadSurrogate(ch))
        result.append(getTrailSurrogate(ch))
        return result.toString()
    }
}


public class UTF16_StringComparator <: Comparator {
    public init() {
        this(false, false, FOLD_CASE_DEFAULT)
    }

    public init(codepointcompare: Bool, ignorecase: Bool, foldcaseoption: Int32) {
        setCodePointCompare(codepointcompare)
        m_ignoreCase_ = ignorecase
        if (foldcaseoption < FOLD_CASE_DEFAULT || foldcaseoption > FOLD_CASE_EXCLUDE_SPECIAL_I) {
            throw IllegalArgumentException("Invalid fold case option")
        }
        m_foldCase_ = foldcaseoption
    }

    public static let FOLD_CASE_DEFAULT = 0

    public static let FOLD_CASE_EXCLUDE_SPECIAL_I = 1

    public func setCodePointCompare(flag: Bool): Unit {
        if (flag) {
            m_codePointCompare_ = Normalizer.COMPARE_CODE_POINT_ORDER
        } else {
            m_codePointCompare_ = 0
        }
    }

    public func setIgnoreCase(ignorecase: Bool, foldcaseoption: Int32): Unit {
        m_ignoreCase_ = ignorecase
        if (foldcaseoption < FOLD_CASE_DEFAULT || foldcaseoption > FOLD_CASE_EXCLUDE_SPECIAL_I) {
            throw IllegalArgumentException("Invalid fold case option")
        }
        m_foldCase_ = foldcaseoption
    }

    public func getCodePointCompare(): Bool {
        return m_codePointCompare_ == Normalizer.COMPARE_CODE_POINT_ORDER
    }

    public func getIgnoreCase(): Bool {
        return m_ignoreCase_
    }

    public func getIgnoreCaseOption(): Int32 {
        return m_foldCase_
    }

    public override func compare(a: String, b: String): Int32 {
        if (Utility.sameObjects(a, b)) {
            return 0
        }
        if (a.isNone()) {
            return -1
        }
        if (b.isNone()) {
            return 1
        }
        if (m_ignoreCase_) {
            return compareCaseInsensitive(a, b)
        }
        return compareCaseSensitive(a, b)
    }

    private var m_codePointCompare_: Int32 = 0

    private var m_foldCase_: Int32 = 0

    private var m_ignoreCase_: Bool = false

    private static let CODE_POINT_COMPARE_SURROGATE_OFFSET_ = 10240

    private func compareCaseInsensitive(s1: String, s2: String): Int32 {
        return Normalizer.cmpEquivFold(s1, s2, m_foldCase_ | m_codePointCompare_ | Normalizer.COMPARE_IGNORE_CASE)
    }

    private func compareCaseSensitive(s1: String, s2: String): Int32 {
        let length1 = Int32(s1.size)
        let length2 = Int32(s2.size)
        var minlength = length1
        var result = 0
        if (length1 < length2) {
            result = -1
        } else if (length1 > length2) {
            result = 1
            minlength = length2
        }
        var c1 = Char(0)
        var c2 = Char(0)
        var index = 0
        while (index < minlength) {
            c1 = Char(s1[Int64(index)])
            c2 = Char(s2[Int64(index)])
            if (c1 != c2) {
                break
            }
            index++
        }
        if (index == minlength) {
            return result
        }
        let codepointcompare = m_codePointCompare_ == Normalizer.COMPARE_CODE_POINT_ORDER
        if (Int32(UInt32(c1)) >= UTF16.LEAD_SURROGATE_MIN_VALUE && Int32(UInt32(c2)) >= UTF16.LEAD_SURROGATE_MIN_VALUE && codepointcompare) {
            if ((Int32(UInt32(c1)) <= UTF16.LEAD_SURROGATE_MAX_VALUE && (index + 1) != length1 && UTF16.isTrailSurrogate(Int32(UInt32(Char(s1[Int64(index + 1)]))))) || (UTF16.isTrailSurrogate(Int32(UInt32(c1))) && index != 0 && UTF16.isLeadSurrogate(Int32(UInt32(Char(s1[Int64(index - 1)])))))) { } else {
                c1 -= Char(CODE_POINT_COMPARE_SURROGATE_OFFSET_)
            }
            if ((Int32(UInt32(c2)) <= UTF16.LEAD_SURROGATE_MAX_VALUE && (index + 1) != length2 && UTF16.isTrailSurrogate(Int32(UInt32(Char(s2[Int64(index + 1)]))))) || (UTF16.isTrailSurrogate(Int32(UInt32(c2))) && index != 0 && UTF16.isLeadSurrogate(Int32(UInt32(Char(s2[Int64(index - 1)])))))) { } else {
                c2 -= Char(CODE_POINT_COMPARE_SURROGATE_OFFSET_)
            }
        }
        return 
    }
}
