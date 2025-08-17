package icu4cj.impl.locale


public class AsciiUtil {

    public static func caseIgnoreMatch(s1: String, s2: String): Bool {
        if (Utility.sameObjects(s1, s2)) {
            return true
        }
        let len = Int32(s1.size)
        if (len != Int32(s2.size)) {
            return false
        }
        var i = 0
        while (i < len) {
            let c1 = Char(s1[Int64(i)])
            let c2 = Char(s2[Int64(i)])
            if (c1 != c2 && toLower(c1) != toLower(c2)) {
                break
            }
            i++
        }
        return (i == len)
    }

    public static func caseIgnoreCompare(s1: String, s2: String): Int32 {
        if (Utility.sameObjects(s1, s2)) {
            return 0
        }
        return AsciiUtil.toLowerString(s1).compare(AsciiUtil.toLowerString(s2)).value()
    }

    public static func toUpper(c: Char): Char {
        var tempc = c
        if (tempc >= 'a' && tempc <= 'z') {
            tempc -= Char(32)
        }
        return tempc
    }

    public static func toLower(c: Char): Char {
        var tempc = c
        if (tempc >= 'A' && tempc <= 'Z') {
            tempc += Char(32)
        }
        return tempc
    }

    public static func toLowerString(s: String): String {
        var idx = 0
        while (idx < Int32(s.size)) {
            let c = Char(s[Int64(idx)])
            if (c >= 'A' && c <= 'Z') {
                break
            }
            idx++
        }
        if (idx == Int32(s.size)) {
            return s
        }
        let buf = StringBuilder(s[0..Int64(idx)])
        while (idx < Int32(s.size)) {
            buf.append(toLower(Char(s[Int64(idx)])))
            idx++
        }
        return buf.toString()
    }

    public static func toUpperString(s: String): String {
        var idx = 0
        while (idx < Int32(s.size)) {
            let c = Char(s[Int64(idx)])
            if (c >= 'a' && c <= 'z') {
                break
            }
            idx++
        }
        if (idx == Int32(s.size)) {
            return s
        }
        let buf = StringBuilder(s[0..Int64(idx)])
        while (idx < Int32(s.size)) {
            buf.append(toUpper(Char(s[Int64(idx)])))
            idx++
        }
        return buf.toString()
    }

    public static func toTitleString(s: String): String {
        if (Int32(s.size) == 0) {
            return s
        }
        var idx = 0
        let c = Char(s[Int64(idx)])
        if (!(c >= 'a' && c <= 'z')) {
            idx = 1
            while (idx < Int32(s.size)) {
                if (c >= 'A' && c <= 'Z') {
                    break
                }
                idx++
            }
        }
        if (idx == Int32(s.size)) {
            return s
        }
        let buf = StringBuilder(s[0..Int64(idx)])
        if (idx == 0) {
            buf.append(toUpper(Char(s[Int64(idx)])))
            idx++
        }
        while (idx < Int32(s.size)) {
            buf.append(toLower(Char(s[Int64(idx)])))
            idx++
        }
        return buf.toString()
    }

    public static func isAlpha(c: Char): Bool {
        return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')
    }

    public static func isAlphaString(s: String): Bool {
        var b = true
        var i = 0
        while (i < Int32(s.size)) {
            if (!isAlpha(Char(s[Int64(i)]))) {
                b = false
                break
            }
            i++
        }
        return b
    }

    public static func isNumeric(c: Char): Bool {
        return (c >= '0' && c <= '9')
    }

    public static func isNumericString(s: String): Bool {
        var b = true
        var i = 0
        while (i < Int32(s.size)) {
            if (!isNumeric(Char(s[Int64(i)]))) {
                b = false
                break
            }
            i++
        }
        return b
    }

    public static func isAlphaNumeric(c: Char): Bool {
        return isAlpha(c) || isNumeric(c)
    }

    public static func isAlphaNumericString(s: String): Bool {
        var b = true
        var i = 0
        while (i < Int32(s.size)) {
            if (!isAlphaNumeric(Char(s[Int64(i)]))) {
                b = false
                break
            }
            i++
        }
        return b
    }
}


public class AsciiUtil_CaseInsensitiveKey {
    private var _key: String

    private var _hash: Int32 = 0

    public init(key: String) {
        _key = key
        _hash = Int32(AsciiUtil.toLowerString(key).hashCode())
    }

    public override func equals(o: Object): Bool {
        if (refEq(this, o)) {
            return true
        }
        if (checkOptionalIs<AsciiUtil_CaseInsensitiveKey, Object>(o)) {
            return AsciiUtil.caseIgnoreMatch(_key, o._key)
        }
        return false
    }

    public override func hashCode(): Int64 {
        return Int64(_hash)
    }
}
