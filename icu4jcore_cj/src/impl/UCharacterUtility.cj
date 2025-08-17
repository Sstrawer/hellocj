package icu4cj.impl

public class UCharacterUtility {
    public static func isNonCharacter(ch: Int32): Bool {
        if ((ch & NON_CHARACTER_SUFFIX_MIN_3_0_) == NON_CHARACTER_SUFFIX_MIN_3_0_) {
            return true
        }
        return ch >= NON_CHARACTER_MIN_3_1_ && ch <= NON_CHARACTER_MAX_3_1_
    }

    static func toInt(msc: Char, lsc: Char): Int32 {
        return ((shl(Int32(UInt32(msc)), 16)) | Int32(UInt32(lsc)))
    }

    static func getNullTermByteSubString(str: StringBuffer, array: Array<UInt8>, index: Int32): Int32 {
        var tempindex = index
        var b = 1u8
        while (Int32(b) != 0) {
            b = array[Int64(tempindex)]
            if (Int32(b) != 0) {
                str.append(Char(Int32(b) & 255))
            }
            tempindex++
        }
        return tempindex
    }

    static func compareNullTermByteSubString(str: String, array: Array<UInt8>, strindex: Int32, aindex: Int32): Int32 {
        var tempaindex = aindex
        var tempstrindex = strindex
        var b = 1u8
        let length = Int32(str.size)
        while (Int32(b) != 0) {
            b = array[Int64(tempaindex)]
            tempaindex++
            if (Int32(b) == 0) {
                break
            }
            if (tempstrindex == length || (Char(str[Int64(tempstrindex)]) != Char(Int32(b) & 255))) {
                return -1
            }
            tempstrindex++
        }
        return tempstrindex
    }

    static func skipNullTermByteSubString(array: Array<UInt8>, index: Int32, skipcount: Int32): Int32 {
        var tempindex = index
        var b: UInt8 = 0
        var i = 0
        while (i < skipcount) {
            b = 1
            while (Int32(b) != 0) {
                b = array[Int64(tempindex)]
                tempindex++
            }
            i++
        }
        return tempindex
    }

    static func skipByteSubString(array: Array<UInt8>, index: Int32, length: Int32, skipend: UInt8): Int32 {
        var result: Int32 = 0
        var b: UInt8 = 0
        result = 0
        while (result < length) {
            b = array[Int64(index + result)]
            if (b == skipend) {
                result++
                break
            }
            result++
        }
        return result
    }

    private static let NON_CHARACTER_SUFFIX_MIN_3_0_ = 65534

    private static let NON_CHARACTER_MIN_3_1_ = 64976

    private static let NON_CHARACTER_MAX_3_1_ = 65007

}
