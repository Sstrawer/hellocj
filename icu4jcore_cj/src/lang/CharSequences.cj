package icu4cj.lang



public class CharSequences {
    
    public static func matchAfter(a: String, b: String, aIndex: Int32, bIndex: Int32): Int32 {
        var i = aIndex
        var j = bIndex
        let alen = a.size
        let blen = b.size
        while (i < alen && j < blen) {
            let ca = a[i]
            let cb = b[j]
            if (ca != cb) {
                break
            }
            i++
            j++
        }
        var result = i - aIndex
        if (result != 0 && !onCharacterBoundary(a, i) && !onCharacterBoundary(b, j)) {
            result--
        }
        return result
    }

    
    public func codePointLength(s: String): Int32 {
        return Character.codePointCount(s, 0, s.size)
    }

    
    public static func equals(codepoint: Int32, other: String): Bool {
        if (other.isNone()) {
            return false
        }
        match (other.size) {
            case 1 => return codepoint == Int32(UInt32(other[0]))
            case 2 => return codepoint > 65535 && codepoint == Character.codePointAt(other, 0)
            case _ => return false
        }
    }

    
    public static func equals(other: String, codepoint: Int32): Bool {
        return equals(codepoint, other)
    }

    
    public static func compare(string: String, codePoint: Int32): Int32 {
        if (codePoint < Character.MIN_CODE_POINT || codePoint > Character.MAX_CODE_POINT) {
            throw IllegalArgumentException()
        }
        let stringLength = string.size
        if (stringLength == 0) {
            return -1
        }
        let firstChar = string[0]
        let offset = codePoint - Character.MIN_SUPPLEMENTARY_CODE_POINT
        if (offset < 0) {
            let result = Int32(UInt32(firstChar)) - codePoint
            if (result != 0) {
                return result
            }
            return stringLength - 1
        }
        let lead = Char((ushr(offset, 10)) + Int32(UInt32(Character.MIN_HIGH_SURROGATE)))
        var result = 
        if (result != 0) {
            return result
        }
        if (stringLength > 1) {
            let trail = Char((offset & 1023) + Int32(UInt32(Character.MIN_LOW_SURROGATE)))
            result = 
            if (result != 0) {
                return result
            }
        }
        return stringLength - 2
    }

    
    public static func compare(codepoint: Int32, a: String): Int32 {
        let result = compare(a, codepoint)
        return if (result > 0) { -1 } else { if (result < 0) { 1 } else { 0 } }
    }

    
    public static func getSingleCodePoint(s: String): Int32 {
        let length = s.size
        if (length < 1 || length > 2) {
            return Int32.Max
        }
        let result = Character.codePointAt(s, 0)
        return if ((result < 65536) == (length == 1)) { result } else { Int32.Max }
    }

    
    public static func equals<T>(a: T, b: T): Bool {
        return if (a.isNone()) { b.isNone() } else { if(a, b) } } : Any => Bool -->
    }

    
    public static func compare(a: String, b: String): Int32 {
        let alength = a.size
        let blength = b.size
        let min = if (alength <= blength) { alength } else { blength }
        var i = 0
        while (i < min) {
            let diff = 
            if (diff != 0) {
                return diff
            }
            i++
        }
        return alength - blength
    }

    
    public static func equalsChars(a: String, b: String): Bool {
        return a.size == b.size && compare(a, b) == 0
    }

    
    public static func onCharacterBoundary(s: String, i: Int32): Bool {
        return i <= 0 || i >= s.size || !Character.isHighSurrogate(s[i - 1]) || !Character.isLowSurrogate(s[i])
    }

    
    public static func indexOf(s: String, codePoint: Int32): Int32 {
        var cp: Int32 = 0
        var i = 0
        while (i < s.size) {
            cp = Character.codePointAt(s, i)
            if (cp == codePoint) {
                return i
            }
            i += Character.charCount(cp)
        }
        return -1
    }

    
    public static func codePoints(s: String): Array<Int32> {
        let result = Array<Int32>(Int64(s.size)) { _ => 0 }
        var j = 0
        var i = 0
        while (i < s.size) {
            let cp = s[i]
            if (Int32(UInt32(cp)) >= 56320 && Int32(UInt32(cp)) <= 57343 && i != 0) {
                let last = Char(result[Int64(j - 1)])
                if (Int32(UInt32(last)) >= 55296 && Int32(UInt32(last)) <= 56319) {
                    result[Int64(j - 1)] = Character.toCodePoint(last, cp)
                    continue
                }
            }
            result[Int64(match (0) { case _ => j++; j - 1 })] = Int32(UInt32(cp))
            i++
        }
        if (j == Int32(result.size)) {
            return result
        }
        let shortResult = Array<Int32>(Int64(j)) { _ => 0 }
        arraycopy(result, 0, shortResult, 0, Int64(j))
        return shortResult
    }

}
