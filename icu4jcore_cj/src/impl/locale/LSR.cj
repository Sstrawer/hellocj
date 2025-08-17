package icu4cj.impl.locale


public class LSR {
    public static let REGION_INDEX_LIMIT = 1001 + 26 * 26

    public static let EXPLICIT_LSR = 7

    public static let EXPLICIT_LANGUAGE = 4

    public static let EXPLICIT_SCRIPT = 2

    public static let EXPLICIT_REGION = 1

    public static let IMPLICIT_LSR = 0

    public static let DONT_CARE_FLAGS = 0

    public static let DEBUG_OUTPUT = false

    public let language: String

    public let script: String

    public let region: String

    let regionIndex: Int32

    public let flags: Int32

    public init(language: String, script: String, region: String, flags: Int32) {
        this.language = language
        this.script = script
        this.region = region
        regionIndex = indexForRegion(region)
        this.flags = flags
    }

    public static func indexForRegion(region: String): Int32 {
        if (Int32(region.size) == 2) {
            let a = 
            if (a < 0 || 25 < a) {
                return 0
            }
            let b = 
            if (b < 0 || 25 < b) {
                return 0
            }
            return 26 * a + b + 1001
        } else if (Int32(region.size) == 3) {
            let a = 
            if (a < 0 || 9 < a) {
                return 0
            }
            let b = 
            if (b < 0 || 9 < b) {
                return 0
            }
            let c = 
            if (c < 0 || 9 < c) {
                return 0
            }
            return (10 * a + b) * 10 + c + 1
        }
        return 0
    }

    public override func toString(): String {
        let result = StringBuilder(language)
        if (!script.isEmpty()) {
            result.append('-').append(script)
        }
        if (!region.isEmpty()) {
            result.append('-').append(region)
        }
        return result.toString()
    }

    public func isEquivalentTo(other: LSR): Bool {
        return language.equals(other.language) && script.equals(other.script) && region.equals(other.region)
    }

    public override func equals(obj: Object): Bool {
        let other: LSR
        return refEq(this, obj) || (obj.isSome() && refEq(TypeInfo.of(obj), TypeInfo.of(this)) && language.equals((match (0) { case _ => other = obj; other }).language) && script.equals(other.script) && region.equals(other.region) && flags == other.flags)
    }

    public override func hashCode(): Int64 {
        return Int64(Objects.hash([language, script, region, flags]))
    }

    private func encodeLanguageToInt(): Int32 {
        if (!(Int32(language.size) >= 2)) {
            throw AssertionError()
        }
        if (!(Int32(language.size) <= 3)) {
            throw AssertionError()
        }
        if (!(Char(language[0]) >= 'a')) {
            throw AssertionError()
        }
        if (!(Char(language[0]) <= 'z')) {
            throw AssertionError()
        }
        if (!(Char(language[1]) >= 'a')) {
            throw AssertionError()
        }
        if (!(Char(language[1]) <= 'z')) {
            throw AssertionError()
        }
        if (!(Int32(language.size) == 2 || Char(language[2]) >= 'a')) {
            throw AssertionError()
        }
        if (!(Int32(language.size) == 2 || Char(language[2]) <= 'z')) {
            throw AssertionError()
        }
        return  + 1 + 27 * ( + 1) + (if (Int32(language.size) == 2) { 0 } else { 27 * 27 * ( + 1) })
    }

    private func encodeScriptToInt(): Int32 {
        let ret = UScript.getCodeFromName(script)
        if (!(ret != UScript.INVALID_CODE)) {
            throw AssertionError()
        }
        return ret
    }

    private func encodeRegionToInt(m49: ArrayList<String>): Int32 {
        if (!(Int32(region.size) >= 2)) {
            throw AssertionError()
        }
        if (!(Int32(region.size) <= 3)) {
            throw AssertionError()
        }
        if (Int32(region.size) == 3) {
            let index = m49.indexOf(region)
            if (!(index >= 0)) {
                throw AssertionError()
            }
            if (index < 0) {
                throw Exception("Please add '" + (region) + "' to M49 in LocaleDistanceMapper.java")
            }
            return index
        }
        if (!(Char(region[0]) >= 'A')) {
            throw AssertionError()
        }
        if (!(Char(region[0]) <= 'Z')) {
            throw AssertionError()
        }
        if (!(Char(region[1]) >= 'A')) {
            throw AssertionError()
        }
        if (!(Char(region[1]) <= 'Z')) {
            throw AssertionError()
        }
        return ( + 1) + 27 * ( + 1)
    }

    public func encodeToIntForResource(m49: ArrayList<String>): Int32 {
        return (encodeLanguageToInt() + (27 * 27 * 27) * encodeRegionToInt(m49)) | (shl(encodeScriptToInt(), 24))
    }

    private static func toLanguage(encoded: Int32): String {
        var tempencoded = encoded
        if (tempencoded == 0) {
            return ""
        }
        if (tempencoded == 1) {
            return "skip"
        }
        tempencoded &= 16777215
        tempencoded %= 27 * 27 * 27
        let res = StringBuilder()
        res.append(Char(Int32(UInt32('a')) + ((tempencoded % 27) - 1)))
        res.append(Char(Int32(UInt32('a')) + (((tempencoded / 27) % 27) - 1)))
        if (tempencoded / (27 * 27) != 0) {
            res.append(Char(Int32(UInt32('a')) + ((tempencoded / (27 * 27)) - 1)))
        }
        return res.toString()
    }

    private static func toScript(encoded: Int32): String {
        var tempencoded = encoded
        if (tempencoded == 0) {
            return ""
        }
        if (tempencoded == 1) {
            return "script"
        }
        tempencoded = (shr(tempencoded, 24)) & 255
        return UScript.getShortName(tempencoded)
    }

    private static func toRegion(encoded: Int32, m49: Array<String>): String {
        var tempencoded = encoded
        if (tempencoded == 0 || tempencoded == 1) {
            return ""
        }
        tempencoded &= 16777215
        tempencoded /= 27 * 27 * 27
        tempencoded %= 27 * 27
        if (tempencoded < 27) {
            return m49[Int64(tempencoded)]
        }
        let res = StringBuilder()
        res.append(Char(Int32(UInt32('A')) + ((tempencoded % 27) - 1)))
        res.append(Char(Int32(UInt32('A')) + (((tempencoded / 27) % 27) - 1)))
        return res.toString()
    }

    public static func decodeInts(nums: Array<Int32>, m49: Array<String>): Array<LSR> {
        let lsrs = Array<LSR>(nums.size)
        var i = 0
        while (i < Int32(nums.size)) {
            let n = nums[Int64(i)]
            lsrs[Int64(i)] = LSR(toLanguage(n), toScript(n), toRegion(n, m49), LSR.IMPLICIT_LSR)
            i++
        }
        return lsrs
    }
}
