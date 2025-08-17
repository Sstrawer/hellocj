package icu4cj.impl

public class PatternProps {

    public static func isSyntax(c: Int32): Bool {
        if (c < 0) {
            return false
        } else if (c <= 255) {
            return Int32(latin1[Int64(c)]) == 3
        } else if (c < 8208) {
            return false
        } else if (c <= 12336) {
            let bits = syntax2000[Int64(index2000[Int64(shr((c - 8192), 5))])]
            return ((shr(bits, (c & 31))) & 1) != 0
        } else if (64830 <= c && c <= 65094) {
            return c <= 64831 || 65093 <= c
        } else {
            return false
        }
    }

    public static func isSyntaxOrWhiteSpace(c: Int32): Bool {
        if (c < 0) {
            return false
        } else if (c <= 255) {
            return Int32(latin1[Int64(c)]) != 0
        } else if (c < 8206) {
            return false
        } else if (c <= 12336) {
            let bits = syntaxOrWhiteSpace2000[Int64(index2000[Int64(shr((c - 8192), 5))])]
            return ((shr(bits, (c & 31))) & 1) != 0
        } else if (64830 <= c && c <= 65094) {
            return c <= 64831 || 65093 <= c
        } else {
            return false
        }
    }

    public static func isWhiteSpace(c: Int32): Bool {
        if (c < 0) {
            return false
        } else if (c <= 255) {
            return Int32(latin1[Int64(c)]) == 5
        } else if (8206 <= c && c <= 8233) {
            return c <= 8207 || 8232 <= c
        } else {
            return false
        }
    }

    public static func skipWhiteSpace(s: String, i: Int32): Int32 {
        var tempi = i
        while (tempi < s.size && isWhiteSpace(Int32(UInt32(s[tempi])))) {
            tempi++
        }
        return tempi
    }

    public static func trimWhiteSpace(s: String): String {
        if (Int32(s.size) == 0 || (!isWhiteSpace(Int32(UInt32(Char(s[0])))) && !isWhiteSpace(Int32(UInt32(Char(s[Int64(Int32(s.size) - 1)])))))) {
            return s
        }
        var start = 0
        var limit = Int32(s.size)
        while (start < limit && isWhiteSpace(Int32(UInt32(Char(s[Int64(start)]))))) {
            start++
        }
        if (start < limit) {
            while (isWhiteSpace(Int32(UInt32(Char(s[Int64(limit - 1)]))))) {
                limit--
            }
        }
        return s[Int64(start)..Int64(limit)]
    }

    public static func trimSpaceChar(s: String): String {
        if (Int32(s.size) == 0 || (!Character.isSpaceChar(Char(s[0])) && !Character.isSpaceChar(Char(s[Int64(Int32(s.size) - 1)])))) {
            return s
        }
        var start = 0
        var limit = Int32(s.size)
        while (start < limit && Character.isSpaceChar(Char(s[Int64(start)]))) {
            start++
        }
        if (start < limit) {
            while (isWhiteSpace(Int32(UInt32(Char(s[Int64(limit - 1)]))))) {
                limit--
            }
        }
        return s[Int64(start)..Int64(limit)]
    }

    public static func isIdentifier(s: String): Bool {
        let limit = s.size
        if (limit == 0) {
            return false
        }
        var start = 0
        } while (start < limit)
        return true
    }

    public static func isIdentifier(s: String, start: Int32, limit: Int32): Bool {
        var tempstart = start
        if (tempstart >= limit) {
            return false
        }
        } while (tempstart < limit)
        return true
    }

    public static func skipIdentifier(s: String, i: Int32): Int32 {
        var tempi = i
        while (tempi < s.size && !isSyntaxOrWhiteSpace(Int32(UInt32(s[tempi])))) {
            tempi++
        }
        return tempi
    }

    private static let latin1: Array<UInt8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 0, 3, 0, 3, 3, 0, 3, 0, 3, 3, 0, 0, 0, 0, 3, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0]

    private static let index2000: Array<UInt8> = [2, 3, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 6, 7, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 9]

    private static let syntax2000 = [0, -1, -65536, 2147418367, 2146435070, -65536, 4194303, -1048576, -242, 65537]

    private static let syntaxOrWhiteSpace2000 = [0, -1, -16384, 2147419135, 2146435070, -65536, 4194303, -1048576, -242, 65537]
}
