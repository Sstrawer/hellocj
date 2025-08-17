package icu4cj.impl

public class Utility {

    private static let APOSTROPHE = '''

    private static let BACKSLASH = '\'

    private static let MAGIC_UNSIGNED = -2147483648

    public static func arrayEquals(source: Array<Object>, target: Object): Bool {
        if (source.isNone()) {
            return (target.isNone())
        }
        if (!(target)) {
            return false
        }
        let targ = target
        return (Int32(source.size) == Int32(targ.size) && arrayRegionMatches(source, 0, targ, 0, Int32(source.size)))
    }

    public static func arrayEquals(source: Array<Int32>, target: Object): Bool {
        if (source.isNone()) {
            return (target.isNone())
        }
        if (!(target)) {
            return false
        }
        let targ = target
        return (Int32(source.size) == Int32(targ.size) && arrayRegionMatches(source, 0, targ, 0, Int32(source.size)))
    }

    public static func arrayEquals(source: Array<Float64>, target: Object): Bool {
        if (source.isNone()) {
            return (target.isNone())
        }
        if (!(target)) {
            return false
        }
        let targ = target
        return (Int32(source.size) == Int32(targ.size) && arrayRegionMatches(source, 0, targ, 0, Int32(source.size)))
    }

    public static func arrayEquals(source: Array<UInt8>, target: Object): Bool {
        if (source.isNone()) {
            return (target.isNone())
        }
        if (!(target)) {
            return false
        }
        let targ = target
        return (Int32(source.size) == Int32(targ.size) && arrayRegionMatches(source, 0, targ, 0, Int32(source.size)))
    }

    public static func arrayEquals(source: Object, target: Object): Bool {
        if (source.isNone()) {
            return (target.isNone())
        }
        if (source) {
            return (arrayEquals(source, target))
        }
        if (source) {
            return (arrayEquals(source, target))
        }
        if (source) {
            return (arrayEquals(source, target))
        }
        if (source) {
            return (arrayEquals(source, target))
        }
        return refEq(source, target)
    }

    public static func arrayRegionMatches(source: Array<Object>, sourceStart: Int32, target: Array<Object>, targetStart: Int32, len: Int32): Bool {
        let sourceEnd = sourceStart + len
        let delta = targetStart - sourceStart
        var i = sourceStart
        while (i < sourceEnd) {
            if (!arrayEquals(source[Int64(i)], target[Int64(i + delta)])) {
                return false
            }
            i++
        }
        return true
    }

    public static func arrayRegionMatches(source: Array<Char>, sourceStart: Int32, target: Array<Char>, targetStart: Int32, len: Int32): Bool {
        let sourceEnd = sourceStart + len
        let delta = targetStart - sourceStart
        var i = sourceStart
        while (i < sourceEnd) {
            if (source[Int64(i)] != target[Int64(i + delta)]) {
                return false
            }
            i++
        }
        return true
    }

    public static func arrayRegionMatches(source: Array<Int32>, sourceStart: Int32, target: Array<Int32>, targetStart: Int32, len: Int32): Bool {
        let sourceEnd = sourceStart + len
        let delta = targetStart - sourceStart
        var i = sourceStart
        while (i < sourceEnd) {
            if (source[Int64(i)] != target[Int64(i + delta)]) {
                return false
            }
            i++
        }
        return true
    }

    public static func arrayRegionMatches(source: Array<Float64>, sourceStart: Int32, target: Array<Float64>, targetStart: Int32, len: Int32): Bool {
        let sourceEnd = sourceStart + len
        let delta = targetStart - sourceStart
        var i = sourceStart
        while (i < sourceEnd) {
            if (source[Int64(i)] != target[Int64(i + delta)]) {
                return false
            }
            i++
        }
        return true
    }

    public static func arrayRegionMatches(source: Array<UInt8>, sourceStart: Int32, target: Array<UInt8>, targetStart: Int32, len: Int32): Bool {
        let sourceEnd = sourceStart + len
        let delta = targetStart - sourceStart
        var i = sourceStart
        while (i < sourceEnd) {
            if (source[Int64(i)] != target[Int64(i + delta)]) {
                return false
            }
            i++
        }
        return true
    }

    public static func sameObjects(a: Object, b: Object): Bool {
        return refEq(a, b)
    }

    public static func checkCompare<T>(a: T, b: T): Int32 {
        return if (a.isNone()) { if (b.isNone()) { 0 } else { -1 } } else { if } } : Any => Int32 -->
    }

    public static func checkHash(a: Object): Int32 {
        return if (a.isNone()) { 0 } else { Int32(a.toString()) }
    }

    private static let ESCAPE = '\u{a5a5}'

    static let ESCAPE_BYTE = 165u8

    public static func arrayToRLEString(a: Array<Int32>): String {
        let buffer = StringBuilder()
        appendInt(buffer as T, Int32(a.size))
        var runValue = a[0]
        var runLength = 1
        var i = 1
        while (i < Int32(a.size)) {
            let s = a[Int64(i)]
            if (s == runValue && runLength < 65535) {
                runLength++
            } else {
                encodeRun(buffer as T, runValue, runLength)
                runValue = s
                runLength = 1
            }
            i++
        }
        encodeRun(buffer as T, runValue, runLength)
        return buffer.toString()
    }

    public static func arrayToRLEString(a: Array<Int16>): String {
        let buffer = StringBuilder()
        buffer.append(Char(shr(Int32(a.size), 16)))
        buffer.append(Char(Int32(a.size)))
        var runValue = a[0]
        var runLength = 1
        var i = 1
        while (i < Int32(a.size)) {
            let s = a[Int64(i)]
            if (s == runValue && runLength < 65535) {
                runLength++
            } else {
                encodeRun(buffer as T, runValue, runLength)
                runValue = s
                runLength = 1
            }
            i++
        }
        encodeRun(buffer as T, runValue, runLength)
        return buffer.toString()
    }

    public static func arrayToRLEString(a: Array<Char>): String {
        let buffer = StringBuilder()
        buffer.append(Char(shr(Int32(a.size), 16)))
        buffer.append(Char(Int32(a.size)))
        var runValue = a[0]
        var runLength = 1
        var i = 1
        while (i < Int32(a.size)) {
            let s = a[Int64(i)]
            if (s == runValue && runLength < 65535) {
                runLength++
            } else {
                encodeRun(buffer as T, Int16(UInt32(runValue)), runLength)
                runValue = s
                runLength = 1
            }
            i++
        }
        encodeRun(buffer as T, Int16(UInt32(runValue)), runLength)
        return buffer.toString()
    }

    public static func arrayToRLEString(a: Array<UInt8>): String {
        let buffer = StringBuilder()
        buffer.append(Char(shr(Int32(a.size), 16)))
        buffer.append(Char(Int32(a.size)))
        var runValue = a[0]
        var runLength = 1
        let state = Array<UInt8>(2) { _ => 0 }
        var i = 1
        while (i < Int32(a.size)) {
            let b = a[Int64(i)]
            if (b == runValue && runLength < 255) {
                runLength++
            } else {
                encodeRun(buffer as T, runValue, runLength, state)
                runValue = b
                runLength = 1
            }
            i++
        }
        encodeRun(buffer as T, runValue, runLength, state)
        if (Int32(state[0]) != 0) {
            appendEncodedByte(buffer as T, 0, state)
        }
        return buffer.toString()
    }

    private static func encodeRun<T>(buffer: T, value: Int32, length: Int32): Unit {
        var templength = length
        if (templength < 4) {
            var j = 0
            while (j < templength) {
                if (value == Int32(UInt32(ESCAPE))) {
                    appendInt(buffer, value)
                }
                appendInt(buffer, value)
                j++
            }
        } else {
            if (templength == Int32(UInt32(ESCAPE))) {
                if (value == Int32(UInt32(ESCAPE))) {
                    appendInt(buffer, Int32(UInt32(ESCAPE)))
                }
                appendInt(buffer, value)
                templength--
            }
            appendInt(buffer, Int32(UInt32(ESCAPE)))
            appendInt(buffer, templength)
            appendInt(buffer, value)
        }
    }

    private static func appendInt<T>(buffer: T, value: Int32): Unit {
        try {
            buffer.append(Char(ushr(value, 16)))
            buffer.append(Char(value & 65535))
        } catch (e: IOException) {
            throw IllegalIcuArgumentException(e)
        }
    }

    private static func encodeRun<T>(buffer: T, value: Int16, length: Int32): Unit {
        var templength = length
        try {
            let valueChar = Char(value)
            if (templength < 4) {
                var j = 0
                while (j < templength) {
                    if (valueChar == ESCAPE) {
                        buffer.append(ESCAPE)
                    }
                    buffer.append(valueChar)
                    j++
                }
            } else {
                if (templength == Int32(UInt32(ESCAPE))) {
                    if (valueChar == ESCAPE) {
                        buffer.append(ESCAPE)
                    }
                    buffer.append(valueChar)
                    templength--
                }
                buffer.append(ESCAPE)
                buffer.append(Char(templength))
                buffer.append(valueChar)
            }
        } catch (e: IOException) {
            throw IllegalIcuArgumentException(e)
        }
    }

    private static func encodeRun<T>(buffer: T, value: UInt8, length: Int32, state: Array<UInt8>): Unit {
        var templength = length
        if (templength < 4) {
            var j = 0
            while (j < templength) {
                if (value == ESCAPE_BYTE) {
                    appendEncodedByte(buffer, ESCAPE_BYTE, state)
                }
                appendEncodedByte(buffer, value, state)
                j++
            }
        } else {
            if (UInt8(templength) == ESCAPE_BYTE) {
                if (value == ESCAPE_BYTE) {
                    appendEncodedByte(buffer, ESCAPE_BYTE, state)
                }
                appendEncodedByte(buffer, value, state)
                templength--
            }
            appendEncodedByte(buffer, ESCAPE_BYTE, state)
            appendEncodedByte(buffer, UInt8(templength), state)
            appendEncodedByte(buffer, value, state)
        }
    }

    private static func appendEncodedByte<T>(buffer: T, value: UInt8, state: Array<UInt8>): Unit {
        try {
            if (Int32(state[0]) != 0) {
                let c = Char((shl(Int32(state[1]), 8)) | ((Int32(value)) & 255))
                buffer.append(c)
                state[0] = 0
            } else {
                state[0] = 1
                state[1] = value
            }
        } catch (e: IOException) {
            throw IllegalIcuArgumentException(e)
        }
    }

    public static func RLEStringToIntArray(s: String): Array<Int32> {
        let length = getInt(s, 0)
        let array = Array<Int32>(Int64(length)) { _ => 0 }
        var ai = 0
        var i = 1
        let maxI = Int32(s.size) / 2
        while (ai < length && i < maxI) {
            var c = getInt(s, match (0) { case _ => i++; i - 1 })
            if (c == Int32(UInt32(ESCAPE))) {
                c = getInt(s, match (0) { case _ => i++; i - 1 })
                if (c == Int32(UInt32(ESCAPE))) {
                    array[Int64(match (0) { case _ => ai++; ai - 1 })] = c
                } else {
                    let runLength = c
                    let runValue = getInt(s, match (0) { case _ => i++; i - 1 })
                    var j = 0
                    while (j < runLength) {
                        array[Int64(match (0) { case _ => ai++; ai - 1 })] = runValue
                        j++
                    }
                }
            } else {
                array[Int64(match (0) { case _ => ai++; ai - 1 })] = c
            }
        }
        if (ai != length || i != maxI) {
            throw Exception("Bad run-length encoded int array")
        }
        return array
    }

    static func getInt(s: String, i: Int32): Int32 {
        return (shl((Int32(UInt32(Char(s[Int64(2 * i)])))), 16)) | Int32(UInt32(Char(s[Int64(2 * i + 1)])))
    }

    public static func RLEStringToShortArray(s: String): Array<Int16> {
        let length = (shl((Int32(UInt32(Char(s[0])))), 16)) | (Int32(UInt32(Char(s[1]))))
        let array = Array<Int16>(Int64(length)) { _ => 0 }
        var ai = 0
        var i = 2
        while (i < Int32(s.size)) {
            var c = Char(s[Int64(i)])
            if (c == ESCAPE) {
                c = Char(s[Int64(match (0) { case _ => i++; i })])
                if (c == ESCAPE) {
                    array[Int64(match (0) { case _ => ai++; ai - 1 })] = Int16(UInt32(c))
                } else {
                    let runLength = Int32(UInt32(c))
                    let runValue = Int16(UInt32(Char(s[Int64(match (0) { case _ => i++; i })])))
                    var j = 0
                    while (j < runLength) {
                        array[Int64(match (0) { case _ => ai++; ai - 1 })] = runValue
                        j++
                    }
                }
            } else {
                array[Int64(match (0) { case _ => ai++; ai - 1 })] = Int16(UInt32(c))
            }
            i++
        }
        if (ai != length) {
            throw Exception("Bad run-length encoded short array")
        }
        return array
    }

    public static func RLEStringToCharArray(s: String): Array<Char> {
        let length = (shl((Int32(UInt32(Char(s[0])))), 16)) | (Int32(UInt32(Char(s[1]))))
        let array = Array<Char>(Int64(length)) { _ => '\u{0000}' }
        var ai = 0
        var i = 2
        while (i < Int32(s.size)) {
            var c = Char(s[Int64(i)])
            if (c == ESCAPE) {
                c = Char(s[Int64(match (0) { case _ => i++; i })])
                if (c == ESCAPE) {
                    array[Int64(match (0) { case _ => ai++; ai - 1 })] = c
                } else {
                    let runLength = Int32(UInt32(c))
                    let runValue = Char(s[Int64(match (0) { case _ => i++; i })])
                    var j = 0
                    while (j < runLength) {
                        array[Int64(match (0) { case _ => ai++; ai - 1 })] = runValue
                        j++
                    }
                }
            } else {
                array[Int64(match (0) { case _ => ai++; ai - 1 })] = c
            }
            i++
        }
        if (ai != length) {
            throw Exception("Bad run-length encoded short array")
        }
        return array
    }

    public static func RLEStringToByteArray(s: String): Array<UInt8> {
        let length = (shl((Int32(UInt32(Char(s[0])))), 16)) | (Int32(UInt32(Char(s[1]))))
        let array = Array<UInt8>(Int64(length)) { _ => 0 }
        var nextChar = true
        var c = Char(0)
        var node = 0
        var runLength = 0
        var i = 2
        var ai = 0
        while (ai < length) {
            let b: UInt8
            if (nextChar) {
                c = Char(s[Int64(match (0) { case _ => i++; i - 1 })])
                b = UInt8(shr(Int32(UInt32(c)), 8))
                nextChar = false
            } else {
                b = UInt8(Int32(UInt32(c)) & 255)
                nextChar = true
            }
            match (node) {
                case 0 => if (b == ESCAPE_BYTE) {
                    node = 1
                } else {
                    array[Int64(match (0) { case _ => ai++; ai - 1 })] = b
                }
                case 1 => if (b == ESCAPE_BYTE) {
                    array[Int64(match (0) { case _ => ai++; ai - 1 })] = ESCAPE_BYTE
                    node = 0
                } else {
                    runLength = Int32(b)
                    if (runLength < 0) {
                        runLength += 256
                    }
                    node = 2
                }
                case 2 =>
                    var j = 0
                    while (j < runLength) {
                        array[Int64(match (0) { case _ => ai++; ai - 1 })] = b
                        j++
                    }
                    node = 0
                case _ => ()
            }
        }
        if (node != 0) {
            throw Exception("Bad run-length encoded byte array")
        }
        if (i != Int32(s.size)) {
            throw Exception("Excess data in RLE byte array string")
        }
        return array
    }

    public static var LINE_SEPARATOR = System.getProperty("line.separator")

    public static func formatForSource(s: String): String {
        let buffer = StringBuilder()
        var i = 0
        while (i < Int32(s.size)) {
            if (i > 0) {
                buffer.append('+').append(LINE_SEPARATOR)
            }
            buffer.append("        \"")
            var count = 11
            while (i < Int32(s.size) && count < 80) {
                let c = Char(s[Int64(match (0) { case _ => i++; i - 1 })])
                if (c < ' ' || c == '\"' || c == '\') {
                    if (c == '\n') {
                        buffer.append("\\n")
                        count += 2
                    } else if (c == '\t') {
                        buffer.append("\\t")
                        count += 2
                    } else if (c == '\r') {
                        buffer.append("\\r")
                        count += 2
                    } else {
                        buffer.append('\')
                        buffer.append(HEX_DIGIT[Int64(shr((Int32(UInt32(c)) & 448), 6))])
                        buffer.append(HEX_DIGIT[Int64(shr((Int32(UInt32(c)) & 56), 3))])
                        buffer.append(HEX_DIGIT[(Int64(Int32(UInt32(c)) & 7))])
                        count += 4
                    }
                } else if (c <= '~') {
                    buffer.append(c)
                    count += 1
                } else {
                    buffer.append("\\u")
                    buffer.append(HEX_DIGIT[Int64(shr((Int32(UInt32(c)) & 61440), 12))])
                    buffer.append(HEX_DIGIT[Int64(shr((Int32(UInt32(c)) & 3840), 8))])
                    buffer.append(HEX_DIGIT[Int64(shr((Int32(UInt32(c)) & 240), 4))])
                    buffer.append(HEX_DIGIT[(Int64(Int32(UInt32(c)) & 15))])
                    count += 6
                }
            }
            buffer.append('\"')
        }
        return buffer.toString()
    }

    static let HEX_DIGIT = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F']

    public static func format1ForSource(s: String): String {
        let buffer = StringBuilder()
        buffer.append("\"")
        var i = 0
        while (i < Int32(s.size)) {
            let c = Char(s[Int64(match (0) { case _ => i++; i - 1 })])
            if (c < ' ' || c == '\"' || c == '\') {
                if (c == '\n') {
                    buffer.append("\\n")
                } else if (c == '\t') {
                    buffer.append("\\t")
                } else if (c == '\r') {
                    buffer.append("\\r")
                } else {
                    buffer.append('\')
                    buffer.append(HEX_DIGIT[Int64(shr((Int32(UInt32(c)) & 448), 6))])
                    buffer.append(HEX_DIGIT[Int64(shr((Int32(UInt32(c)) & 56), 3))])
                    buffer.append(HEX_DIGIT[(Int64(Int32(UInt32(c)) & 7))])
                }
            } else if (c <= '~') {
                buffer.append(c)
            } else {
                buffer.append("\\u")
                buffer.append(HEX_DIGIT[Int64(shr((Int32(UInt32(c)) & 61440), 12))])
                buffer.append(HEX_DIGIT[Int64(shr((Int32(UInt32(c)) & 3840), 8))])
                buffer.append(HEX_DIGIT[Int64(shr((Int32(UInt32(c)) & 240), 4))])
                buffer.append(HEX_DIGIT[(Int64(Int32(UInt32(c)) & 15))])
            }
        }
        buffer.append('\"')
        return buffer.toString()
    }

    public static func escape(s: String): String {
        let buf = StringBuilder()
        var i = 0
        while (i < Int32(s.size)) {
            let c = Character.codePointAt(s, i)
            i += UTF16.getCharCount(c)
            if (c >= Int32(UInt32(' ')) && c <= 127) {
                if (c == Int32(UInt32('\'))) {
                    buf.append("\\\\")
                } else {
                    buf.append(Char(c))
                }
            } else {
                let four = c <= 65535
                buf.append(if (four) { "\\u" } else { "\\U" })
                buf.append(hex(Int64(c), if (four) { 4 } else { 8 }))
            }
        }
        return buf.toString()
    }

    private static let UNESCAPE_MAP: Array<Char> = [Char(97), Char(7), Char(98), Char(8), Char(101), Char(27), Char(102), Char(12), Char(110), Char(10), Char(114), Char(13), Char(116), Char(9), Char(118), Char(11)]

    private static func _digit8(c: Int32): Int32 {
        if (c >= Int32(UInt32('0')) && c <= Int32(UInt32('7'))) {
            return c - Int32(UInt32('0'))
        }
        return -1
    }

    private static func _digit16(c: Int32): Int32 {
        if (c >= Int32(UInt32('0')) && c <= Int32(UInt32('9'))) {
            return c - Int32(UInt32('0'))
        }
        if (c >= Int32(UInt32('A')) && c <= Int32(UInt32('F'))) {
            return c - (Int32(UInt32('A')) - 10)
        }
        if (c >= Int32(UInt32('a')) && c <= Int32(UInt32('f'))) {
            return c - (Int32(UInt32('a')) - 10)
        }
        return -1
    }

    public static func unescapeAndLengthAt(s: String, offset: Int32): Int32 {
        return unescapeAndLengthAt(s, offset, s.size)
    }

    private static func unescapeAndLengthAt(s: String, offset: Int32, length: Int32): Int32 {
        var tempoffset = offset
        var result = 0
        var n = 0
        var minDig = 0
        var maxDig = 0
        var bitsPerDigit = 4
        var dig: Int32 = 0
        var braces = false
        if (tempoffset < 0 || tempoffset >= length) {
            return -1
        }
        let start = tempoffset
        var c = Int32(UInt32(s[match (0] { case _ => tempoffset++; tempoffset - 1 })))
        <-- Internal error: switch (c) {
        case 'u':
            minDig = maxDig = 4;
            break;

        case 'U':
            minDig = maxDig = 8;
            break;

        case 'x':
            minDig = 1;
            if (tempoffset < length && s.toRuneArray()[tempoffset] == '{') {
                ++tempoffset;
                braces = true;
                maxDig = 8;
            } else {
                maxDig = 2;
            }
            break;

        default:
            dig = _digit8(c);
            if (dig >= 0) {
                minDig = 1;
                maxDig = 3;
                n = 1;
                bitsPerDigit = 3;
                result = dig;
            }
            break;

        } -->
        if (minDig != 0) {
            while (tempoffset < length && n < maxDig) {
                c = Int32(UInt32(s[tempoffset]))
                dig = if (bitsPerDigit == 3) { _digit8(c) } else { _digit16(c) }
                if (dig < 0) {
                    break
                }
                result = (shl(result, bitsPerDigit)) | dig
                tempoffset++
                n++
            }
            if (n < minDig) {
                return -1
            }
            if (braces) {
                if (c != Int32(UInt32('}'))) {
                    return -1
                }
                tempoffset++
            }
            if (result < 0 || result >= 1114112) {
                return -1
            }
            if (tempoffset < length && UTF16.isLeadSurrogate(result)) {
                var ahead = tempoffset + 1
                c = Int32(UInt32(s[tempoffset]))
                if (c == Int32(UInt32('\')) && ahead < length) {
                    var tailLimit = ahead + 11
                    if (tailLimit > length) {
                        tailLimit = length
                    }
                    let cpAndLength = unescapeAndLengthAt(s, ahead, tailLimit)
                    if (cpAndLength >= 0) {
                        c = shr(cpAndLength, 8)
                        ahead += cpAndLength & 255
                    }
                }
                if (UTF16.isTrailSurrogate(c)) {
                    tempoffset = ahead
                    result = UCharacter.toCodePoint(result, c)
                }
            }
            return codePointAndLength(result, start, tempoffset)
        }
        var i = 0
        while (i < Int32(UNESCAPE_MAP.size)) {
            if (c == Int32(UInt32(UNESCAPE_MAP[Int64(i)]))) {
                return codePointAndLength(Int32(UInt32(UNESCAPE_MAP[Int64(i + 1)])), start, tempoffset)
            } else if (c < Int32(UInt32(UNESCAPE_MAP[Int64(i)]))) {
                break
            }
            i += 2
        }
        if (c == Int32(UInt32('c')) && tempoffset < length) {
            c = Character.codePointAt(s, tempoffset)
            return codePointAndLength(c & 31, start, tempoffset + Character.charCount(c))
        }
        if (UTF16.isLeadSurrogate(c) && tempoffset < length) {
            let c2 = Int32(UInt32(s[tempoffset]))
            if (UTF16.isTrailSurrogate(c2)) {
                tempoffset++
                c = UCharacter.toCodePoint(c, c2)
            }
        }
        return codePointAndLength(c, start, tempoffset)
    }

    private static func codePointAndLength(c: Int32, length: Int32): Int32 {
        if (!(0 <= c && c <= 1114111)) {
            throw AssertionError()
        }
        if (!(0 <= length && length <= 255)) {
            throw AssertionError()
        }
        return shl(c, 8) | length
    }

    private static func codePointAndLength(c: Int32, start: Int32, limit: Int32): Int32 {
        return codePointAndLength(c, limit - start)
    }

    public static func cpFromCodePointAndLength(cpAndLength: Int32): Int32 {
        if (!(cpAndLength >= 0)) {
            throw AssertionError()
        }
        return shr(cpAndLength, 8)
    }

    public static func lengthFromCodePointAndLength(cpAndLength: Int32): Int32 {
        if (!(cpAndLength >= 0)) {
            throw AssertionError()
        }
        return cpAndLength & 255
    }

    public static func unescape(s: String): String {
        var buf: StringBuilder
        var i = 0
        while (i < s.size) {
            let c = s[match (0] { case _ => i++; i - 1 })
            if (c == '\') {
                if (buf.isNone()) {
                    buf = StringBuilder().append(s, 0, i - 1)
                }
                let cpAndLength = unescapeAndLengthAt(s, i)
                if (cpAndLength < 0) {
                    throw IllegalArgumentException("Invalid escape sequence " + (s.subSequence(i - 1, min(i + 9, s.size))))
                }
                buf.appendCodePoint(shr(cpAndLength, 8))
                i += cpAndLength & 255
            } else if (buf.isSome()) {
                buf.append(c)
            }
        }
        if (buf.isNone()) {
            return toString(s)
        }
        return buf.toString()
    }

    public static func unescapeLeniently(s: String): String {
        var buf: StringBuilder
        var i = 0
        while (i < s.size) {
            let c = s[match (0] { case _ => i++; i - 1 })
            if (c == '\') {
                if (buf.isNone()) {
                    buf = StringBuilder().append(s, 0, i - 1)
                }
                let cpAndLength = unescapeAndLengthAt(s, i)
                if (cpAndLength < 0) {
                    buf.append(c)
                } else {
                    buf.appendCodePoint(shr(cpAndLength, 8))
                    i += cpAndLength & 255
                }
            } else if (buf.isSome()) {
                buf.append(c)
            }
        }
        if (buf.isNone()) {
            return toString(s)
        }
        return buf.toString()
    }

    public static func hex(ch: Int64): String {
        return hex(ch, 4)
    }

    public static func hex(i: Int64, places: Int32): String {
        var tempi = i
        if (tempi == Int64.Min) {
            return "-8000000000000000"
        }
        let negative = tempi < 0
        if (negative) {
            tempi = -tempi
        }
        var result = Int64.toString(tempi, 16).toUpperCase(Locale.ENGLISH)
        if (Int32(result.size) < places) {
            result = "0000000000000000"[result.size..Int64(places)] + (result)
        }
        if (negative) {
            return '-'.toString() + (result)
        }
        return result
    }

    public static func hex(s: String): String {
        return hex(s, 4, ",", true, StringBuilder() as T).toString()
    }

    public static func hex<S, U, T>(s: S, width: Int32, separator: U, useCodePoints: Bool, result: T): T {
        try {
            if (useCodePoints) {
                var cp: Int32 = 0
                        result.append(hex(Int64(cp), width))
                        i += UTF16.getCharCount(cp)
                    }
                } while (false)
            } else {
                        result.append(hex(Int64(UInt32(s[i])), width))
                        i++
                    }
                } while (false)
            }
            return result
        } catch (e: IOException) {
            throw IllegalIcuArgumentException(e)
        }
    }

    public static func hex(o: Array<UInt8>, start: Int32, end: Int32, separator: String): String {
        let result = StringBuilder()
        var i = start
        while (i < end) {
            if (i != 0) {
                result.append(separator)
            }
            result.append(hex(Int64(o[Int64(i)])))
            i++
        }
        return result.toString()
    }

    public static func hex<S>(s: S, width: Int32, separator: S): String {
        return hex(s, width, separator, true, StringBuilder() as T).toString()
    }

    public static func split(s: String, divider: Char, output: Array<String>): Unit {
        var last = 0
        var current = 0
        var i: Int32 = 0
        i = 0
        while (i < Int32(s.size)) {
            if (Char(s[Int64(i)]) == divider) {
                output[Int64(match (0) { case _ => current++; current - 1 })] = s[Int64(last)..Int64(i)]
                last = i + 1
            }
            i++
        }
        output[Int64(match (0) { case _ => current++; current - 1 })] = s[Int64(last)..Int64(i)]
        while (current < Int32(output.size)) {
            output[Int64(match (0) { case _ => current++; current - 1 })] = ""
        }
    }

    public static func split(s: String, divider: Char): Array<String> {
        var last = 0
        var i: Int32 = 0
        let output = ArrayList<String>()
        i = 0
        while (i < Int32(s.size)) {
            if (Char(s[Int64(i)]) == divider) {
                output.append(s[Int64(last)..Int64(i)])
                last = i + 1
            }
            i++
        }
        output.append(s[Int64(last)..Int64(i)])
        return output.toArray(size))
    }

    public static func lookup(source: String, target: Array<String>): Int32 {
        var i = 0
        while (i < Int32(target.size)) {
            if (source.equals(target[Int64(i)])) {
                return i
            }
            i++
        }
        return -1
    }

    public static func parseChar(id: String, pos: Array<Int32>, ch: Char): Bool {
        let start = pos[0]
        pos[0] = PatternProps.skipWhiteSpace(id, pos[0])
        if (pos[0] == Int32(id.size) || Char(id[Int64(pos[0])]) != ch) {
            pos[0] = start
            return false
        }
        pos[0] += 1
        return true
    }

    public static func parsePattern(rule: String, pos: Int32, limit: Int32, pattern: String, parsedInts: Array<Int32>): Int32 {
        var temppos = pos
        let p = Array<Int32>(1) { _ => 0 }
        var intCount = 0
        var i = 0
        while (i < Int32(pattern.size)) {
            let cpat = Char(pattern[Int64(i)])
            let c: Char
            match (cpat) {
                case ' ' =>
                    if (temppos >= limit) {
                        return -1
                    }
                    c = Char(rule[Int64(match (0) { case _ => temppos++; temppos - 1 })])
                    if (!PatternProps.isWhiteSpace(Int32(UInt32(c)))) {
                        return -1
                    }
                case '~' => temppos = PatternProps.skipWhiteSpace(rule, temppos)
                case '#' =>
                    p[0] = temppos
                    parsedInts[Int64(match (0) { case _ => intCount++; intCount - 1 })] = parseInteger(rule, p, limit)
                    if (p[0] == temppos) {
                        return -1
                    }
                    temppos = p[0]
                case _ =>
                    if (temppos >= limit) {
                        return -1
                    }
                    c = Char(UCharacter.toLowerCase(Int32(UInt32(Char(rule[Int64(match (0) { case _ => temppos++; temppos - 1 })])))))
                    if (c != cpat) {
                        return -1
                    }
            }
            i++
        }
        return temppos
    }

    public static func parsePattern(pat: String, text: Replaceable, index: Int32, limit: Int32): Int32 {
        var tempindex = index
        var ipat = 0
        if (ipat == Int32(pat.size)) {
            return tempindex
        }
        var cpat = Character.codePointAt(pat, ipat)
        while (tempindex < limit) {
            let c = text.char32At(tempindex)
            if (cpat == Int32(UInt32('~'))) {
                if (PatternProps.isWhiteSpace(c)) {
                    tempindex += UTF16.getCharCount(c)
                    continue
                } else {
                    if (match (0) { case _ => ipat++; ipat } == Int32(pat.size)) {
                        return tempindex
                    }
                }
            } else if (c == cpat) {
                let n = UTF16.getCharCount(c)
                tempindex += n
                ipat += n
                if (ipat == Int32(pat.size)) {
                    return tempindex
                }
            } else {
                return -1
            }
            cpat = UTF16.toRuneArray()[pat, ipat]
        }
        return -1
    }

    public static func parseInteger(rule: String, pos: Array<Int32>, limit: Int32): Int32 {
        var count = 0
        var value = 0
        var p = pos[0]
        var radix = 10
        if (rule.regionMatches(true, p, "0x", 0, 2)) {
            p += 2
            radix = 16
        } else if (p < limit && Char(rule[Int64(p)]) == '0') {
            p++
            count = 1
            radix = 8
        }
        while (p < limit) {
            let d = UCharacter.digit(Int32(UInt32(Char(rule[Int64(match (0) { case _ => p++; p - 1 })]))), radix)
            if (d < 0) {
                p--
                break
            }
            count++
            let v = (value * radix) + d
            if (v <= value) {
                return 0
            }
            value = v
        }
        if (count > 0) {
            pos[0] = p
        }
        return value
    }

    public static func parseUnicodeIdentifier(str: String, pos: Array<Int32>): String {
        let buf = StringBuilder()
        var p = pos[0]
        while (p < Int32(str.size)) {
            let ch = Character.codePointAt(str, p)
            if (Int32(buf.size) == 0) {
                if (UCharacter.isUnicodeIdentifierStart(ch)) {
                    buf.appendCodePoint(ch)
                } else {
                    return None
                }
            } else {
                if (UCharacter.isUnicodeIdentifierPart(ch)) {
                    buf.appendCodePoint(ch)
                } else {
                    break
                }
            }
            p += UTF16.getCharCount(ch)
        }
        pos[0] = p
        return buf.toString()
    }

    static let DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

    private static func recursiveAppendNumber<T>(result: T, n: Int32, radix: Int32, minDigits: Int32): Unit {
        try {
            let digit = n % radix
            if (n >= radix || minDigits > 1) {
                recursiveAppendNumber(result, n / radix, radix, minDigits - 1)
            }
            result.append(DIGITS[Int64(digit)])
        } catch (e: IOException) {
            throw IllegalIcuArgumentException(e)
        }
    }

    public static func appendNumber<T>(result: T, n: Int32, radix: Int32, minDigits: Int32): T {
        try {
            if (radix < 2 || radix > 36) {
                throw IllegalArgumentException("Illegal radix " + radix.toString())
            }
            var abs = n
            if (n < 0) {
                abs = -n
                result.append("-")
            }
            recursiveAppendNumber(result, abs, radix, minDigits)
            return result
        } catch (e: IOException) {
            throw IllegalIcuArgumentException(e)
        }
    }

    public static func parseNumber(text: String, pos: Array<Int32>, radix: Int32): Int32 {
        var n = 0
        var p = pos[0]
        while (p < Int32(text.size)) {
            let ch = Character.codePointAt(text, p)
            let d = UCharacter.digit(ch, radix)
            if (d < 0) {
                break
            }
            n = radix * n + d
            if (n < 0) {
                return -1
            }
            p++
        }
        if (p == pos[0]) {
            return -1
        }
        pos[0] = p
        return n
    }

    public static func isUnprintable(c: Int32): Bool {
        return !(c >= 32 && c <= 126)
    }

    public static func shouldAlwaysBeEscaped(c: Int32): Bool {
        if (c < 32) {
            return true
        } else if (c <= 126) {
            return false
        } else if (c <= 159) {
            return true
        } else if (c < 55296) {
            return false
        } else if (c <= 57343 || (64976 <= c && c <= 65007) || (c & 65534) == 65534) {
            return true
        } else if (c <= 1114111) {
            return false
        } else {
            return true
        }
    }

    public static func escapeUnprintable<T>(result: T, c: Int32): Bool {
        if (isUnprintable(c)) {
            escape(result, c)
            return true
        }
        return false
    }

    public static func escape<T>(result: T, c: Int32): T {
        try {
            result.append('\')
            if ((c & ) != 0) {
                result.append('U')
                result.append(DIGITS[Int64(15 & (shr(c, 28)))])
                result.append(DIGITS[Int64(15 & (shr(c, 24)))])
                result.append(DIGITS[Int64(15 & (shr(c, 20)))])
                result.append(DIGITS[Int64(15 & (shr(c, 16)))])
            } else {
                result.append('u')
            }
            result.append(DIGITS[Int64(15 & (shr(c, 12)))])
            result.append(DIGITS[Int64(15 & (shr(c, 8)))])
            result.append(DIGITS[Int64(15 & (shr(c, 4)))])
            result.append(DIGITS[Int64(15 & c)])
            return result
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public static func quotedIndexOf(text: String, start: Int32, limit: Int32, setOfChars: String): Int32 {
        var i = start
        while (i < limit) {
            let c = Char(text[Int64(i)])
            if (c == BACKSLASH) {
                i++
            } else if (c == APOSTROPHE) {
                while (match (0) { case _ => i++; i } < limit && Char(text[Int64(i)]) != APOSTROPHE) { }
            } else if (indexOfWrap(setOfChars.indexOf(UInt8(UInt32(c)))) >= 0) {
                return i
            }
            i++
        }
        return -1
    }

    public static func appendToRule(rule: StringBuffer, c: Int32, isLiteral: Bool, escapeUnprintable: Bool, quoteBuf: StringBuffer): Unit {
        if (isLiteral || (escapeUnprintable && Utility.isUnprintable(c))) {
            if (Int32(quoteBuf.size) > 0) {
                while (Int32(quoteBuf.size) >= 2 && quoteBuf.get(0) == APOSTROPHE && quoteBuf.get(1) == APOSTROPHE) {
                    rule.append(BACKSLASH).append(APOSTROPHE)
                    quoteBuf.delete(0, 2)
                }
                var trailingCount = 0
                while (Int32(quoteBuf.size) >= 2 && quoteBuf.get(Int64(Int32(quoteBuf.size) - 2)) == APOSTROPHE && quoteBuf.get(Int64(Int32(quoteBuf.size) - 1)) == APOSTROPHE) {
                    quoteBuf.setLength(Int64(Int32(quoteBuf.size) - 2))
                    trailingCount++
                }
                if (Int32(quoteBuf.size) > 0) {
                    rule.append(APOSTROPHE)
                    rule.append(quoteBuf)
                    rule.append(APOSTROPHE)
                    quoteBuf.setLength(0)
                }
                while (match (0) { case _ => trailingCount--; trailingCount + 1 } > 0) {
                    rule.append(BACKSLASH).append(APOSTROPHE)
                }
            }
            if (c != -1) {
                if (c == Int32(UInt32(' '))) {
                    let len = Int32(rule.size)
                    if (len > 0 && rule.get(Int64(len - 1)) != ' ') {
                        rule.append(' ')
                    }
                } else if (!escapeUnprintable || !Utility.escapeUnprintable(rule, c)) {
                    rule.appendCodePoint(c)
                }
            }
        } else if (Int32(quoteBuf.size) == 0 && (c == Int32(UInt32(APOSTROPHE)) || c == Int32(UInt32(BACKSLASH)))) {
            rule.append(BACKSLASH).append(Char(c))
        } else if (Int32(quoteBuf.size) > 0 || (c >= 33 && c <= 126 && !((c >= 48 && c <= 57) || (c >= 65 && c <= 90) || (c >= 97 && c <= 122))) || PatternProps.isWhiteSpace(c)) {
            quoteBuf.appendCodePoint(c)
            if (c == Int32(UInt32(APOSTROPHE))) {
                quoteBuf.append(Char(c))
            }
        } else {
            rule.appendCodePoint(c)
        }
    }

    public static func appendToRule(rule: StringBuffer, text: String, isLiteral: Bool, escapeUnprintable: Bool, quoteBuf: StringBuffer): Unit {
        var i = 0
        while (i < Int32(text.size)) {
            appendToRule(rule, Int32(UInt32(Char(text[Int64(i)]))), isLiteral, escapeUnprintable, quoteBuf)
            i++
        }
    }

    public static func appendToRule(rule: StringBuffer, matcher: UnicodeMatcher, escapeUnprintable: Bool, quoteBuf: StringBuffer): Unit {
        if (matcher.isSome()) {
            appendToRule(rule, matcher.toPattern(escapeUnprintable), true, escapeUnprintable, quoteBuf)
        }
    }

    public static func compareUnsigned(source: Int32, target: Int32): Int32 {
        var tempsource = source
        var temptarget = target
        tempsource += MAGIC_UNSIGNED
        temptarget += MAGIC_UNSIGNED
        if (tempsource < temptarget) {
            return -1
        } else if (tempsource > temptarget) {
            return 1
        }
        return 0
    }

    public static func highBit(n: Int32): UInt8 {
        var tempn = n
        if (tempn <= 0) {
            return 255
        }
        var bit = 0u8
        if (tempn >= shl(1, 16)) {
            tempn >>= 16
            bit += 16
        }
        if (tempn >= shl(1, 8)) {
            tempn >>= 8
            bit += 8
        }
        if (tempn >= shl(1, 4)) {
            tempn >>= 4
            bit += 4
        }
        if (tempn >= shl(1, 2)) {
            tempn >>= 2
            bit += 2
        }
        if (tempn >= shl(1, 1)) {
            tempn >>= 1
            bit += 1
        }
        return bit
    }

    public static func valueOf(source: Array<Int32>): String {
        let result = StringBuilder()
        var i = 0
        while (i < Int32(source.size)) {
            result.appendCodePoint(source[Int64(i)])
            i++
        }
        return result.toString()
    }

    public static func repeat(s: String, count: Int32): String {
        if (count <= 0) {
            return ""
        }
        if (count == 1) {
            return s
        }
        let result = StringBuilder()
        var i = 0
        while (i < count) {
            result.append(s)
            i++
        }
        return result.toString()
    }

    public static func splitString(src: String, target: String): Array<String> {
        return src.split("\\Q" + (target) + "\\E")
    }

    public static func splitWhitespace(src: String): Array<String> {
        return src.split("\\s+")
    }

    public static func fromHex(string: String, minLength: Int32, separator: String): String {
        return fromHex(string, minLength, Pattern.compile(if (separator.isSome()) { separator } else { "\\s+" }))
    }

    public static func fromHex(string: String, minLength: Int32, separator: Pattern): String {
        let buffer = StringBuilder()
        let parts = separator.split(string)
        for (part in parts) {
            if (Int32(part.size) < minLength) {
                throw IllegalArgumentException("code point too short: " + (part))
            }
            let cp = parse<Int32>(part, 16)
            buffer.appendCodePoint(cp)
        }
        return buffer.toString()
    }

    public static func addExact(x: Int32, y: Int32): Int32 {
        let r = x + y
        if (((x ^ r) & (y ^ r)) < 0) {
            throw ArithmeticException("integer overflow")
        }
        return r
    }

    public static func charSequenceEquals(a: String, b: String): Bool {
        if (refEq(a, b)) {
            return true
        }
        if (a.isNone() || b.isNone()) {
            return false
        }
        if (a.size != b.size) {
            return false
        }
        var i = 0
        while (i < a.size) {
            if (a[i] != b[i]) {
                return false
            }
            i++
        }
        return true
    }

    public static func charSequenceHashCode(value: String): Int32 {
        var hash = 0
        var i = 0
        while (i < value.size) {
            hash = hash * 31 + Int32(UInt32(value[i]))
            i++
        }
        return hash
    }

    public static func appendTo<A>(string: String, appendable: A): A {
        try {
            appendable.append(string)
            return appendable
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public static func joinStrings(delimiter: String, elements: Iterable<String>): String {
        if (delimiter.isNone() || (elements).isNone()) {
            throw NoneValueException("Delimiter or elements is null")
        }
        let buf = StringBuilder()
        let itr: Iterator<String> = elements.iterator()
        var isFirstElem = true
        while (itr.hasNext()) {
            let element = itr.next()
            if (element.isSome()) {
                if (!isFirstElem) {
                    buf.append(delimiter)
                } else {
                    isFirstElem = false
                }
                buf.append(element)
            }
        }
        return buf.toString()
    }
}
