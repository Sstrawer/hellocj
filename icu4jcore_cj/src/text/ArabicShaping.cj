package icu4cj.text

public class ArabicShaping {
    private let options: Int32

    private var isLogical: Bool = false

    private var spacesRelativeToTextBeginEnd: Bool = false

    private var tailChar: Char = '\u{0000}'

    public func shape(source: Array<Char>, sourceStart: Int32, sourceLength: Int32, dest: Array<Char>, destStart: Int32, destSize: Int32): Int32 {
        if (source.isNone()) {
            throw IllegalArgumentException("source can not be null")
        }
        if (sourceStart < 0 || sourceLength < 0 || sourceStart + sourceLength > Int32(source.size)) {
            throw IllegalArgumentException("bad source start (" + sourceStart.toString() + ") or length (" + sourceLength.toString() + ") for buffer of length " + Int32(source.size).toString())
        }
        if (dest.isNone() && destSize != 0) {
            throw IllegalArgumentException("null dest requires destSize == 0")
        }
        if ((destSize != 0) && (destStart < 0 || destSize < 0 || destStart + destSize > Int32(dest.size))) {
            throw IllegalArgumentException("bad dest start (" + destStart.toString() + ") or size (" + destSize.toString() + ") for buffer of length " + Int32(dest.size).toString())
        }
        if (((options & TASHKEEL_MASK) != 0) && !(((options & TASHKEEL_MASK) == TASHKEEL_BEGIN) || ((options & TASHKEEL_MASK) == TASHKEEL_END) || ((options & TASHKEEL_MASK) == TASHKEEL_RESIZE) || ((options & TASHKEEL_MASK) == TASHKEEL_REPLACE_BY_TATWEEL))) {
            throw IllegalArgumentException("Wrong Tashkeel argument")
        }
        if (((options & LAMALEF_MASK) != 0) && !(((options & LAMALEF_MASK) == LAMALEF_BEGIN) || ((options & LAMALEF_MASK) == LAMALEF_END) || ((options & LAMALEF_MASK) == LAMALEF_RESIZE) || ((options & LAMALEF_MASK) == LAMALEF_AUTO) || ((options & LAMALEF_MASK) == LAMALEF_NEAR))) {
            throw IllegalArgumentException("Wrong Lam Alef argument")
        }
        if (((options & TASHKEEL_MASK) != 0) && (options & LETTERS_MASK) == LETTERS_UNSHAPE) {
            throw IllegalArgumentException("Tashkeel replacement should not be enabled in deshaping mode ")
        }
        return internalShape(source, sourceStart, sourceLength, dest, destStart, destSize)
    }

    public func shape(source: Array<Char>, start: Int32, length: Int32): Unit {
        if ((options & LAMALEF_MASK) == LAMALEF_RESIZE) {
            throw ArabicShapingException("Cannot shape in place with length option resize.")
        }
        shape(source, start, length, source, start, length)
    }

    public func shape(text: String): String {
        let src: Array<Char> = text.toRuneArray()
        var dest = src
        if (((options & LAMALEF_MASK) == LAMALEF_RESIZE) && ((options & LETTERS_MASK) == LETTERS_UNSHAPE)) {
            dest = Array<Char>(Int64(Int32(src.size) * 2)) { _ => '\u{0000}' }
        }
        let len = shape(src, 0, Int32(src.size), dest, 0, Int32(dest.size))
        return String(dest)[..Int64(len)]
    }

    public init(options: Int32) {
        this.options = options
        if ((options & DIGITS_MASK) > 128) {
            throw IllegalArgumentException("bad DIGITS options")
        }
        isLogical = ((options & TEXT_DIRECTION_MASK) == TEXT_DIRECTION_LOGICAL)
        spacesRelativeToTextBeginEnd = ((options & SPACES_RELATIVE_TO_TEXT_MASK) == SPACES_RELATIVE_TO_TEXT_BEGIN_END)
        if ((options & SHAPE_TAIL_TYPE_MASK) == SHAPE_TAIL_NEW_UNICODE) {
            tailChar = NEW_TAIL_CHAR
        } else {
            tailChar = OLD_TAIL_CHAR
        }
    }

    public static let SEEN_TWOCELL_NEAR = 2097152

    public static let SEEN_MASK = 7340032

    public static let YEHHAMZA_TWOCELL_NEAR = 16777216

    public static let YEHHAMZA_MASK = 58720256

    public static let TASHKEEL_BEGIN = 262144

    public static let TASHKEEL_END = 393216

    public static let TASHKEEL_RESIZE = 524288

    public static let TASHKEEL_REPLACE_BY_TATWEEL = 786432

    public static let TASHKEEL_MASK = 917504

    public static let SPACES_RELATIVE_TO_TEXT_BEGIN_END = 67108864

    public static let SPACES_RELATIVE_TO_TEXT_MASK = 67108864

    public static let SHAPE_TAIL_NEW_UNICODE = 134217728

    public static let SHAPE_TAIL_TYPE_MASK = 134217728

    public static let LENGTH_GROW_SHRINK = 0

    public static let LAMALEF_RESIZE = 0

    public static let LENGTH_FIXED_SPACES_NEAR = 1

    public static let LAMALEF_NEAR = 1

    public static let LENGTH_FIXED_SPACES_AT_END = 2

    public static let LAMALEF_END = 2

    public static let LENGTH_FIXED_SPACES_AT_BEGINNING = 3

    public static let LAMALEF_BEGIN = 3

    public static let LAMALEF_AUTO = 65536

    public static let LENGTH_MASK = 65539

    public static let LAMALEF_MASK = 65539

    public static let TEXT_DIRECTION_LOGICAL = 0

    public static let TEXT_DIRECTION_VISUAL_RTL = 0

    public static let TEXT_DIRECTION_VISUAL_LTR = 4

    public static let TEXT_DIRECTION_MASK = 4

    public static let LETTERS_NOOP = 0

    public static let LETTERS_SHAPE = 8

    public static let LETTERS_UNSHAPE = 16

    public static let LETTERS_SHAPE_TASHKEEL_ISOLATED = 24

    public static let LETTERS_MASK = 24

    public static let DIGITS_NOOP = 0

    public static let DIGITS_EN2AN = 32

    public static let DIGITS_AN2EN = 64

    public static let DIGITS_EN2AN_INIT_LR = 96

    public static let DIGITS_EN2AN_INIT_AL = 128

    public static let DIGITS_MASK = 224

    public static let DIGIT_TYPE_AN = 0

    public static let DIGIT_TYPE_AN_EXTENDED = 256

    public static let DIGIT_TYPE_MASK = 256

    private static let HAMZAFE_CHAR = '\u{fe80}'

    private static let HAMZA06_CHAR = '\u{0621}'

    private static let YEH_HAMZA_CHAR = '\u{0626}'

    private static let YEH_HAMZAFE_CHAR = '\u{fe89}'

    private static let LAMALEF_SPACE_SUB = '\u{ffff}'

    private static let TASHKEEL_SPACE_SUB = '\u{fffe}'

    private static let LAM_CHAR = '\u{0644}'

    private static let SPACE_CHAR = ' '

    private static let SHADDA_CHAR = '\u{fe7c}'

    private static let SHADDA06_CHAR = '\u{0651}'

    private static let TATWEEL_CHAR = '\u{0640}'

    private static let SHADDA_TATWEEL_CHAR = '\u{fe7d}'

    private static let NEW_TAIL_CHAR = '\u{fe73}'

    private static let OLD_TAIL_CHAR = '\u{200b}'

    private static let SHAPE_MODE = 0

    private static let DESHAPE_MODE = 1

    public override func equals(rhs: Object): Bool {
        return rhs.isSome() && refEq(TypeInfo.of(rhs), TypeInfo.of<ArabicShaping>()) && options == rhs.options
    }

    public override func hashCode(): Int64 {
        return Int64(options)
    }

    public override func toString(): String {
        let buf = StringBuilder(toString(super))
        buf.append('[')
        match (options & LAMALEF_MASK) {
            case 0 => buf.append("LamAlef resize")
            case 1 => buf.append("LamAlef spaces at near")
            case 3 => buf.append("LamAlef spaces at begin")
            case 2 => buf.append("LamAlef spaces at end")
            case 65536 => buf.append("lamAlef auto")
            case _ => ()
        }
        match (options & TEXT_DIRECTION_MASK) {
            case 0 => buf.append(", logical")
            case 4 => buf.append(", visual")
            case _ => ()
        }
        match (options & LETTERS_MASK) {
            case 0 => buf.append(", no letter shaping")
            case 8 => buf.append(", shape letters")
            case 24 => buf.append(", shape letters tashkeel isolated")
            case 16 => buf.append(", unshape letters")
            case _ => ()
        }
        match (options & SEEN_MASK) {
            case 2097152 => buf.append(", Seen at near")
            case _ => ()
        }
        match (options & YEHHAMZA_MASK) {
            case 16777216 => buf.append(", Yeh Hamza at near")
            case _ => ()
        }
        match (options & TASHKEEL_MASK) {
            case 262144 => buf.append(", Tashkeel at begin")
            case 393216 => buf.append(", Tashkeel at end")
            case 786432 => buf.append(", Tashkeel replace with tatweel")
            case 524288 => buf.append(", Tashkeel resize")
            case _ => ()
        }
        match (options & DIGITS_MASK) {
            case 0 => buf.append(", no digit shaping")
            case 32 => buf.append(", shape digits to AN")
            case 64 => buf.append(", shape digits to EN")
            case 96 => buf.append(", shape digits to AN contextually: default EN")
            case 128 => buf.append(", shape digits to AN contextually: default AL")
            case _ => ()
        }
        match (options & DIGIT_TYPE_MASK) {
            case 0 => buf.append(", standard Arabic-Indic digits")
            case 256 => buf.append(", extended Arabic-Indic digits")
            case _ => ()
        }
        buf.append("]")
        return buf.toString()
    }

    private static let IRRELEVANT = 4

    private static let LAMTYPE = 16

    private static let ALEFTYPE = 32

    private static let LINKR = 1

    private static let LINKL = 2

    private static let LINK_MASK = 3

    private static let irrelevantPos = [0, 2, 4, 6, 8, 10, 12, 14]

    private static let tailFamilyIsolatedFinal = [1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1]

    private static let tashkeelMedial = [0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1]

    private static let yehHamzaToYeh: Array<Char> = [Char(65263), Char(65264)]

    private static let convertNormalizedLamAlef = ['\u{0622}', '\u{0623}', '\u{0625}', '\u{0627}']

    private static let araLink = [1 + 32 + 256 * 17, 1 + 32 + 256 * 19, 1 + 256 * 21, 1 + 32 + 256 * 23, 1 + 2 + 256 * 25, 1 + 32 + 256 * 29, 1 + 2 + 256 * 31, 1 + 256 * 35, 1 + 2 + 256 * 37, 1 + 2 + 256 * 41, 1 + 2 + 256 * 45, 1 + 2 + 256 * 49, 1 + 2 + 256 * 53, 1 + 256 * 57, 1 + 256 * 59, 1 + 256 * 61, 1 + 256 * 63, 1 + 2 + 256 * 65, 1 + 2 + 256 * 69, 1 + 2 + 256 * 73, 1 + 2 + 256 * 77, 1 + 2 + 256 * 81, 1 + 2 + 256 * 85, 1 + 2 + 256 * 89, 1 + 2 + 256 * 93, 0, 0, 0, 0, 0, 1 + 2, 1 + 2 + 256 * 97, 1 + 2 + 256 * 101, 1 + 2 + 256 * 105, 1 + 2 + 16 + 256 * 109, 1 + 2 + 256 * 113, 1 + 2 + 256 * 117, 1 + 2 + 256 * 121, 1 + 256 * 125, 1 + 256 * 127, 1 + 2 + 256 * 129, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 1 + 256 * 133, 1 + 256 * 135, 1 + 256 * 137, 1 + 256 * 139, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 1 + 32, 1 + 32, 0, 1 + 32, 1, 1, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1, 1 + 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 + 2, 1, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1, 1]

    private static let presLink = [1 + 2, 1 + 2, 1 + 2, 0, 1 + 2, 0, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 1 + 2, 0, 0 + 32, 1 + 32, 0 + 32, 1 + 32, 0, 1, 0 + 32, 1 + 32, 0, 2, 1 + 2, 1, 0 + 32, 1 + 32, 0, 2, 1 + 2, 1, 0, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0 + 16, 2 + 16, 1 + 2 + 16, 1 + 16, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 2, 1 + 2, 1, 0, 1, 0, 1, 0, 2, 1 + 2, 1, 0, 1, 0, 1, 0, 1, 0, 1]

    private static var convertFEto06: Array<Int32> = [1611, 1611, 1612, 1612, 1613, 1613, 1614, 1614, 1615, 1615, 1616, 1616, 1617, 1617, 1618, 1618, 1569, 1570, 1570, 1571, 1571, 1572, 1572, 1573, 1573, 1574, 1574, 1574, 1574, 1575, 1575, 1576, 1576, 1576, 1576, 1577, 1577, 1578, 1578, 1578, 1578, 1579, 1579, 1579, 1579, 1580, 1580, 1580, 1580, 1581, 1581, 1581, 1581, 1582, 1582, 1582, 1582, 1583, 1583, 1584, 1584, 1585, 1585, 1586, 1586, 1587, 1587, 1587, 1587, 1588, 1588, 1588, 1588, 1589, 1589, 1589, 1589, 1590, 1590, 1590, 1590, 1591, 1591, 1591, 1591, 1592, 1592, 1592, 1592, 1593, 1593, 1593, 1593, 1594, 1594, 1594, 1594, 1601, 1601, 1601, 1601, 1602, 1602, 1602, 1602, 1603, 1603, 1603, 1603, 1604, 1604, 1604, 1604, 1605, 1605, 1605, 1605, 1606, 1606, 1606, 1606, 1607, 1607, 1607, 1607, 1608, 1608, 1609, 1609, 1610, 1610, 1610, 1610, 1628, 1628, 1629, 1629, 1630, 1630, 1631, 1631]

    private static let shapeTable = [[[0, 0, 0, 0], [0, 0, 0, 0], [0, 1, 0, 3], [0, 1, 0, 1]], [[0, 0, 2, 2], [0, 0, 1, 2], [0, 1, 1, 2], [0, 1, 1, 3]], [[0, 0, 0, 0], [0, 0, 0, 0], [0, 1, 0, 3], [0, 1, 0, 3]], [[0, 0, 1, 2], [0, 0, 1, 2], [0, 1, 1, 2], [0, 1, 1, 3]]]

    private func shapeToArabicDigitsWithContext(dest: Array<Char>, start: Int32, length: Int32, digitBase: Char, lastStrongWasAL: Bool): Unit {
        var tempdigitBase = digitBase
        var templastStrongWasAL = lastStrongWasAL
        let bdp = UBiDiProps.INSTANCE
        tempdigitBase -= '0'
        var i = start + length
        while (match (0) { case _ => i--; i } >= start) {
            let ch = dest[Int64(i)]
            match (bdp.getClass(Int32(UInt32(ch)))) {
                case 0 | 1 => templastStrongWasAL = false
                case 13 => templastStrongWasAL = true
                case 2 => if (templastStrongWasAL && ch <= '9') {
                    dest[Int64(i)] = 
                }
                case _ => ()
            }
        }
    }

    private static func invertBuffer(buffer: Array<Char>, start: Int32, length: Int32): Unit {
        var i = start
        var j = start + length - 1
        while (i < j) {
            let temp = buffer[Int64(i)]
            buffer[Int64(i)] = buffer[Int64(j)]
            buffer[Int64(j)] = temp
            i++
            j--
        }
    }

    private static func changeLamAlef(ch: Char): Char {
        match (ch) {
            case '\u{0622}' => return '\u{065c}'
            case '\u{0623}' => return '\u{065d}'
            case '\u{0625}' => return '\u{065e}'
            case '\u{0627}' => return '\u{065f}'
            case _ => return '\u{0000}'
        }
    }

    private static func specialChar(ch: Char): Int32 {
        if ((ch > '\u{0621}' && ch < '\u{0626}') || (ch == '\u{0627}') || (ch > '\u{062e}' && ch < '\u{0633}') || (ch > '\u{0647}' && ch < '\u{064a}') || (ch == '\u{0629}')) {
            return 1
        } else if (ch >= '\u{064b}' && ch <= '\u{0652}') {
            return 2
        } else if (Int32(UInt32(ch)) >= 1619 && Int32(UInt32(ch)) <= 1621 || Int32(UInt32(ch)) == 1648 || Int32(UInt32(ch)) >= 65136 && Int32(UInt32(ch)) <= 65151) {
            return 3
        } else {
            return 0
        }
    }

    private static func getLink(ch: Char): Int32 {
        if (ch >= '\u{0622}' && ch <= '\u{06d3}') {
            return araLink[0]
        } else if (ch == '\u{200d}') {
            return 3
        } else if (ch >= '\u{206d}' && ch <= '\u{206f}') {
            return 4
        } else if (ch >= '\u{fe70}' && ch <= '\u{fefc}') {
            return presLink[0]
        } else {
            return 0
        }
    }

    private static func countSpacesLeft(dest: Array<Char>, start: Int32, count: Int32): Int32 {
        var i = start
        let e = start + count
        while (i < e) {
            if (dest[Int64(i)] != SPACE_CHAR) {
                return i - start
            }
            i++
        }
        return count
    }

    private static func countSpacesRight(dest: Array<Char>, start: Int32, count: Int32): Int32 {
        var i = start + count
        while (match (0) { case _ => i--; i } >= start) {
            if (dest[Int64(i)] != SPACE_CHAR) {
                return start + count - 1 - i
            }
        }
        return count
    }

    private static func isTashkeelChar(ch: Char): Bool {
        return (ch >= '\u{064b}' && ch <= '\u{0652}')
    }

    private static func isSeenTailFamilyChar(ch: Char): Int32 {
        if (Int32(UInt32(ch)) >= 65201 && Int32(UInt32(ch)) < 65215) {
            return tailFamilyIsolatedFinal[Int64(Int32(UInt32(ch)) - 65201)]
        } else {
            return 0
        }
    }

    private static func isSeenFamilyChar(ch: Char): Int32 {
        if (Int32(UInt32(ch)) >= 1587 && Int32(UInt32(ch)) <= 1590) {
            return 1
        } else {
            return 0
        }
    }

    private static func isTailChar(ch: Char): Bool {
        if (ch == OLD_TAIL_CHAR || ch == NEW_TAIL_CHAR) {
            return true
        } else {
            return false
        }
    }

    private static func isAlefMaksouraChar(ch: Char): Bool {
        return ((Int32(UInt32(ch)) == 65263) || (Int32(UInt32(ch)) == 65264) || (Int32(UInt32(ch)) == 1609))
    }

    private static func isYehHamzaChar(ch: Char): Bool {
        if ((Int32(UInt32(ch)) == 65161) || (Int32(UInt32(ch)) == 65162)) {
            return true
        } else {
            return false
        }
    }

    private static func isTashkeelCharFE(ch: Char): Bool {
        return (Int32(UInt32(ch)) != 65141 && (Int32(UInt32(ch)) >= 65136 && Int32(UInt32(ch)) <= 65151))
    }

    private static func isTashkeelOnTatweelChar(ch: Char): Int32 {
        if (Int32(UInt32(ch)) >= 65136 && Int32(UInt32(ch)) <= 65151 && ch != NEW_TAIL_CHAR && Int32(UInt32(ch)) != 65141 && ch != SHADDA_TATWEEL_CHAR) {
            return tashkeelMedial[Int64(Int32(UInt32(ch)) - 65136)]
        } else if ((Int32(UInt32(ch)) >= 64754 && Int32(UInt32(ch)) <= 64756) || (ch == SHADDA_TATWEEL_CHAR)) {
            return 2
        } else {
            return 0
        }
    }

    private static func isIsolatedTashkeelChar(ch: Char): Int32 {
        if (Int32(UInt32(ch)) >= 65136 && Int32(UInt32(ch)) <= 65151 && ch != NEW_TAIL_CHAR && Int32(UInt32(ch)) != 65141) {
            return (1 - tashkeelMedial[Int64(Int32(UInt32(ch)) - 65136)])
        } else if (Int32(UInt32(ch)) >= 64606 && Int32(UInt32(ch)) <= 64611) {
            return 1
        } else {
            return 0
        }
    }

    private static func isAlefChar(ch: Char): Bool {
        return ch == '\u{0622}' || ch == '\u{0623}' || ch == '\u{0625}' || ch == '\u{0627}'
    }

    private static func isLamAlefChar(ch: Char): Bool {
        return ch >= '\u{fef5}' && ch <= '\u{fefc}'
    }

    private static func isNormalizedLamAlefChar(ch: Char): Bool {
        return ch >= '\u{065c}' && ch <= '\u{065f}'
    }

    private func calculateSize(source: Array<Char>, sourceStart: Int32, sourceLength: Int32): Int32 {
        var destSize = sourceLength
        match (options & LETTERS_MASK) {
            case 8 | 24 => if (isLogical) {
                        i++
                    }
                } while (false)
            } else {
                        i++
                    }
                } while (false)
            }
            case 16 => do {
                var i = sourceStart
                let e = sourceStart + sourceLength
                while (i < e) {
                    if (isLamAlefChar(source[Int64(i)])) {
                        destSize++
                    }
                    i++
                }
            } while (false)
            case _ => ()
        }
        return destSize
    }

    private static func countSpaceSub(dest: Array<Char>, length: Int32, subChar: Char): Int32 {
        var i = 0
        var count = 0
        while (i < length) {
            if (dest[Int64(i)] == subChar) {
                count++
            }
            i++
        }
        return count
    }

    private static func shiftArray(dest: Array<Char>, start: Int32, e: Int32, subChar: Char): Unit {
        var w = e
        var r = e
        while (match (0) { case _ => r--; r } >= start) {
            let ch = dest[Int64(r)]
            if (ch != subChar) {
                w--
                if (w != r) {
                    dest[Int64(w)] = ch
                }
            }
        }
    }

    private static func flipArray(dest: Array<Char>, start: Int32, e: Int32, w: Int32): Int32 {
        var tempw = w
        var r: Int32 = 0
        if (tempw > start) {
            r = tempw
            tempw = start
            while (r < e) {
                dest[Int64(match (0) { case _ => tempw++; tempw - 1 })] = dest[Int64(match (0) { case _ => r++; r - 1 })]
            }
        } else {
            tempw = e
        }
        return tempw
    }

    private static func handleTashkeelWithTatweel(dest: Array<Char>, sourceLength: Int32): Int32 {
        var i: Int32 = 0
        i = 0
        while (i < sourceLength) {
            if (isTashkeelOnTatweelChar(dest[Int64(i)]) == 1) {
                dest[Int64(i)] = TATWEEL_CHAR
            } else if (isTashkeelOnTatweelChar(dest[Int64(i)]) == 2) {
                dest[Int64(i)] = SHADDA_TATWEEL_CHAR
            } else if ((isIsolatedTashkeelChar(dest[Int64(i)]) == 1) && dest[Int64(i)] != SHADDA_CHAR) {
                dest[Int64(i)] = SPACE_CHAR
            }
            i++
        }
        return sourceLength
    }

    private func handleGeneratedSpaces(dest: Array<Char>, start: Int32, length: Int32): Int32 {
        var templength = length
        var lenOptionsLamAlef = options & LAMALEF_MASK
        var lenOptionsTashkeel = options & TASHKEEL_MASK
        var lamAlefOn = false
        var tashkeelOn = false
        if (!isLogical & !spacesRelativeToTextBeginEnd) {
            match (lenOptionsLamAlef) {
                case 3 => lenOptionsLamAlef = LAMALEF_END
                case 2 => lenOptionsLamAlef = LAMALEF_BEGIN
                case _ => ()
            }
            match (lenOptionsTashkeel) {
                case 262144 => lenOptionsTashkeel = TASHKEEL_END
                case 393216 => lenOptionsTashkeel = TASHKEEL_BEGIN
                case _ => ()
            }
        }
        if (lenOptionsLamAlef == LAMALEF_NEAR) {
                    i++
                }
            } while (false)
        } else {
            let e = start + templength
            var wL = countSpaceSub(dest, templength, LAMALEF_SPACE_SUB)
            var wT = countSpaceSub(dest, templength, TASHKEEL_SPACE_SUB)
            if (lenOptionsLamAlef == LAMALEF_END) {
                lamAlefOn = true
            }
            if (lenOptionsTashkeel == TASHKEEL_END) {
                tashkeelOn = true
            }
            if (lamAlefOn && (lenOptionsLamAlef == LAMALEF_END)) {
                shiftArray(dest, start, e, LAMALEF_SPACE_SUB)
                while (wL > start) {
                    dest[Int64(match (0) { case _ => wL--; wL })] = SPACE_CHAR
                }
            }
            if (tashkeelOn && (lenOptionsTashkeel == TASHKEEL_END)) {
                shiftArray(dest, start, e, TASHKEEL_SPACE_SUB)
                while (wT > start) {
                    dest[Int64(match (0) { case _ => wT--; wT })] = SPACE_CHAR
                }
            }
            lamAlefOn = false
            tashkeelOn = false
            if (lenOptionsLamAlef == LAMALEF_RESIZE) {
                lamAlefOn = true
            }
            if (lenOptionsTashkeel == TASHKEEL_RESIZE) {
                tashkeelOn = true
            }
            if (lamAlefOn && (lenOptionsLamAlef == LAMALEF_RESIZE)) {
                shiftArray(dest, start, e, LAMALEF_SPACE_SUB)
                wL = flipArray(dest, start, e, wL)
                templength = wL - start
            }
            if (tashkeelOn && (lenOptionsTashkeel == TASHKEEL_RESIZE)) {
                shiftArray(dest, start, e, TASHKEEL_SPACE_SUB)
                wT = flipArray(dest, start, e, wT)
                templength = wT - start
            }
            lamAlefOn = false
            tashkeelOn = false
            if ((lenOptionsLamAlef == LAMALEF_BEGIN) || (lenOptionsLamAlef == LAMALEF_AUTO)) {
                lamAlefOn = true
            }
            if (lenOptionsTashkeel == TASHKEEL_BEGIN) {
                tashkeelOn = true
            }
            if (lamAlefOn && ((lenOptionsLamAlef == LAMALEF_BEGIN) || (lenOptionsLamAlef == LAMALEF_AUTO))) {
                shiftArray(dest, start, e, LAMALEF_SPACE_SUB)
                wL = flipArray(dest, start, e, wL)
                while (wL < e) {
                    dest[Int64(match (0) { case _ => wL++; wL - 1 })] = SPACE_CHAR
                }
            }
            if (tashkeelOn && (lenOptionsTashkeel == TASHKEEL_BEGIN)) {
                shiftArray(dest, start, e, TASHKEEL_SPACE_SUB)
                wT = flipArray(dest, start, e, wT)
                while (wT < e) {
                    dest[Int64(match (0) { case _ => wT++; wT - 1 })] = SPACE_CHAR
                }
            }
        }
        return templength
    }

    private func expandCompositCharAtBegin(dest: Array<Char>, start: Int32, length: Int32, lacount: Int32): Bool {
        var spaceNotFound = false
        if (lacount > countSpacesRight(dest, start, length)) {
            spaceNotFound = true
            return spaceNotFound
        }
        var r = start + length - lacount
        var w = start + length
        while (match (0) { case _ => r--; r } >= start) {
            let ch = dest[Int64(r)]
            if (isNormalizedLamAlefChar(ch)) {
                dest[Int64(match (0) { case _ => w--; w })] = LAM_CHAR
                dest[Int64(match (0) { case _ => w--; w })] = convertNormalizedLamAlef[0]
            } else {
                dest[Int64(match (0) { case _ => w--; w })] = ch
            }
        }
        return spaceNotFound
    }

    private func expandCompositCharAtEnd(dest: Array<Char>, start: Int32, length: Int32, lacount: Int32): Bool {
        var spaceNotFound = false
        if (lacount > countSpacesLeft(dest, start, length)) {
            spaceNotFound = true
            return spaceNotFound
        }
        var r = start + lacount
        var w = start
        let e = start + length
        while (r < e) {
            let ch = dest[Int64(r)]
            if (isNormalizedLamAlefChar(ch)) {
                dest[Int64(match (0) { case _ => w++; w - 1 })] = convertNormalizedLamAlef[0]
                dest[Int64(match (0) { case _ => w++; w - 1 })] = LAM_CHAR
            } else {
                dest[Int64(match (0) { case _ => w++; w - 1 })] = ch
            }
            r++
        }
        return spaceNotFound
    }

    private func expandCompositCharAtNear(dest: Array<Char>, start: Int32, length: Int32, yehHamzaOption: Int32, seenTailOption: Int32, lamAlefOption: Int32): Bool {
        var spaceNotFound = false
        if (isNormalizedLamAlefChar(dest[Int64(start)])) {
            spaceNotFound = true
            return spaceNotFound
        }
        var i = start + length
        while (match (0) { case _ => i--; i } >= start) {
            let ch = dest[Int64(i)]
            if (lamAlefOption == 1 && isNormalizedLamAlefChar(ch)) {
                if (i > start && dest[Int64(i - 1)] == SPACE_CHAR) {
                    dest[Int64(i)] = LAM_CHAR
                    dest[Int64(match (0) { case _ => i--; i })] = convertNormalizedLamAlef[0]
                } else {
                    spaceNotFound = true
                    return spaceNotFound
                }
            } else if (seenTailOption == 1 && isSeenTailFamilyChar(ch) == 1) {
                if (i > start && dest[Int64(i - 1)] == SPACE_CHAR) {
                    dest[Int64(i - 1)] = tailChar
                } else {
                    spaceNotFound = true
                    return spaceNotFound
                }
            } else if (yehHamzaOption == 1 && isYehHamzaChar(ch)) {
                if (i > start && dest[Int64(i - 1)] == SPACE_CHAR) {
                    dest[Int64(i)] = yehHamzaToYeh[0]
                    dest[Int64(i - 1)] = HAMZAFE_CHAR
                } else {
                    spaceNotFound = true
                    return spaceNotFound
                }
            }
        }
        return false
    }

    private func expandCompositChar(dest: Array<Char>, start: Int32, length: Int32, lacount: Int32, shapingMode: Int32): Int32 {
        var templength = length
        var lenOptionsLamAlef = options & LAMALEF_MASK
        let lenOptionsSeen = options & SEEN_MASK
        let lenOptionsYehHamza = options & YEHHAMZA_MASK
        var spaceNotFound = false
        if (!isLogical && !spacesRelativeToTextBeginEnd) {
            match (lenOptionsLamAlef) {
                case 3 => lenOptionsLamAlef = LAMALEF_END
                case 2 => lenOptionsLamAlef = LAMALEF_BEGIN
                case _ => ()
            }
        }
        if (shapingMode == 1) {
            if (lenOptionsLamAlef == LAMALEF_AUTO) {
                if (isLogical) {
                    spaceNotFound = expandCompositCharAtEnd(dest, start, templength, lacount)
                    if (spaceNotFound) {
                        spaceNotFound = expandCompositCharAtBegin(dest, start, templength, lacount)
                    }
                    if (spaceNotFound) {
                        spaceNotFound = expandCompositCharAtNear(dest, start, templength, 0, 0, 1)
                    }
                    if (spaceNotFound) {
                        throw ArabicShapingException("No spacefor lamalef")
                    }
                } else {
                    spaceNotFound = expandCompositCharAtBegin(dest, start, templength, lacount)
                    if (spaceNotFound) {
                        spaceNotFound = expandCompositCharAtEnd(dest, start, templength, lacount)
                    }
                    if (spaceNotFound) {
                        spaceNotFound = expandCompositCharAtNear(dest, start, templength, 0, 0, 1)
                    }
                    if (spaceNotFound) {
                        throw ArabicShapingException("No spacefor lamalef")
                    }
                }
            } else if (lenOptionsLamAlef == LAMALEF_END) {
                spaceNotFound = expandCompositCharAtEnd(dest, start, templength, lacount)
                if (spaceNotFound) {
                    throw ArabicShapingException("No spacefor lamalef")
                }
            } else if (lenOptionsLamAlef == LAMALEF_BEGIN) {
                spaceNotFound = expandCompositCharAtBegin(dest, start, templength, lacount)
                if (spaceNotFound) {
                    throw ArabicShapingException("No spacefor lamalef")
                }
            } else if (lenOptionsLamAlef == LAMALEF_NEAR) {
                spaceNotFound = expandCompositCharAtNear(dest, start, templength, 0, 0, 1)
                if (spaceNotFound) {
                    throw ArabicShapingException("No spacefor lamalef")
                }
            } else if (lenOptionsLamAlef == LAMALEF_RESIZE) {
                var r = start + templength
                var w = r + lacount
                while (match (0) { case _ => r--; r } >= start) {
                    let ch = dest[Int64(r)]
                    if (isNormalizedLamAlefChar(ch)) {
                        dest[Int64(match (0) { case _ => w--; w })] = '\u{0644}'
                        dest[Int64(match (0) { case _ => w--; w })] = convertNormalizedLamAlef[0]
                    } else {
                        dest[Int64(match (0) { case _ => w--; w })] = ch
                    }
                }
                templength += lacount
            }
        } else {
            if (lenOptionsSeen == SEEN_TWOCELL_NEAR) {
                spaceNotFound = expandCompositCharAtNear(dest, start, templength, 0, 1, 0)
                if (spaceNotFound) {
                    throw ArabicShapingException("No space for Seen tail expansion")
                }
            }
            if (lenOptionsYehHamza == YEHHAMZA_TWOCELL_NEAR) {
                spaceNotFound = expandCompositCharAtNear(dest, start, templength, 1, 0, 0)
                if (spaceNotFound) {
                    throw ArabicShapingException("No space for YehHamza expansion")
                }
            }
        }
        return templength
    }

    private func normalize(dest: Array<Char>, start: Int32, length: Int32): Int32 {
        var lacount = 0
        var i = start
        let e = i + length
        while (i < e) {
            let ch = dest[Int64(i)]
            if (ch >= '\u{fe70}' && ch <= '\u{fefc}') {
                if (isLamAlefChar(ch)) {
                    lacount++
                }
                dest[Int64(i)] = Char(convertFEto06[0])
            }
            i++
        }
        return lacount
    }

    private func deshapeNormalize(dest: Array<Char>, start: Int32, length: Int32): Int32 {
        var lacount = 0
        var yehHamzaComposeEnabled = 0
        var seenComposeEnabled = 0
        yehHamzaComposeEnabled = if ((options & YEHHAMZA_MASK) == YEHHAMZA_TWOCELL_NEAR) { 1 } else { 0 }
        seenComposeEnabled = if ((options & SEEN_MASK) == SEEN_TWOCELL_NEAR) { 1 } else { 0 }
        var i = start
        let e = i + length
        while (i < e) {
            let ch = dest[Int64(i)]
            if ((yehHamzaComposeEnabled == 1) && ((ch == HAMZA06_CHAR) || (ch == HAMZAFE_CHAR)) && (i < (length - 1)) && isAlefMaksouraChar(dest[Int64(i + 1)])) {
                dest[Int64(i)] = SPACE_CHAR
                dest[Int64(i + 1)] = YEH_HAMZA_CHAR
            } else if ((seenComposeEnabled == 1) && (isTailChar(ch)) && (i < (length - 1)) && (isSeenTailFamilyChar(dest[Int64(i + 1)]) == 1)) {
                dest[Int64(i)] = SPACE_CHAR
            } else if (ch >= '\u{fe70}' && ch <= '\u{fefc}') {
                if (isLamAlefChar(ch)) {
                    lacount++
                }
                dest[Int64(i)] = Char(convertFEto06[0])
            }
            i++
        }
        return lacount
    }

    private func shapeUnicode(dest: Array<Char>, start: Int32, length: Int32, destSize: Int32, tashkeelFlag: Int32): Int32 {
        var tempdestSize = destSize
        let lamalef_count = normalize(dest, start, length)
        var lamalef_found = false
        var seenfam_found = false
        var yehhamza_found = false
        var tashkeel_found = false
        var i = start + length - 1
        var currLink = getLink(dest[Int64(i)])
        var nextLink = 0
        var prevLink = 0
        var lastLink = 0
        var lastPos = i
        var nx = -2
        var nw = 0
        while (i >= 0) {
            if ((currLink & Int32(UInt32('\u{ff00}'))) != 0 || isTashkeelChar(dest[Int64(i)])) {
                nw = i - 1
                nx = -2
                while (nx < 0) {
                    if (nw == -1) {
                        nextLink = 0
                        nx = Int32.Max
                    } else {
                        nextLink = getLink(dest[Int64(nw)])
                        if ((nextLink & IRRELEVANT) == 0) {
                            nx = nw
                        } else {
                            nw--
                        }
                    }
                }
                if (((currLink & ALEFTYPE) > 0) && ((lastLink & LAMTYPE) > 0)) {
                    lamalef_found = true
                    let wLamalef = changeLamAlef(dest[Int64(i)])
                    if (wLamalef != '\u{0000}') {
                        dest[Int64(i)] = '\u{ffff}'
                        dest[Int64(lastPos)] = wLamalef
                        i = lastPos
                    }
                    lastLink = prevLink
                    currLink = getLink(wLamalef)
                }
                if ((i > 0) && (dest[Int64(i - 1)] == SPACE_CHAR)) {
                    if (isSeenFamilyChar(dest[Int64(i)]) == 1) {
                        seenfam_found = true
                    } else if (dest[Int64(i)] == YEH_HAMZA_CHAR) {
                        yehhamza_found = true
                    }
                } else if (i == 0) {
                    if (isSeenFamilyChar(dest[Int64(i)]) == 1) {
                        seenfam_found = true
                    } else if (dest[Int64(i)] == YEH_HAMZA_CHAR) {
                        yehhamza_found = true
                    }
                }
                let flag = specialChar(dest[Int64(i)])
                var shape = shapeTable[Int64(nextLink & LINK_MASK)][Int64(lastLink & LINK_MASK)][Int64(currLink & LINK_MASK)]
                if (flag == 1) {
                    shape &= 1
                } else if (flag == 2) {
                    if (tashkeelFlag == 0 && ((lastLink & LINKL) != 0) && ((nextLink & LINKR) != 0) && dest[Int64(i)] != '\u{064c}' && dest[Int64(i)] != '\u{064d}' && !((nextLink & ALEFTYPE) == ALEFTYPE && (lastLink & LAMTYPE) == LAMTYPE)) {
                        shape = 1
                    } else if (tashkeelFlag == 2 && dest[Int64(i)] == SHADDA06_CHAR) {
                        shape = 1
                    } else {
                        shape = 0
                    }
                }
                if (flag == 2) {
                    if (tashkeelFlag == 2 && dest[Int64(i)] != SHADDA06_CHAR) {
                        dest[Int64(i)] = TASHKEEL_SPACE_SUB
                        tashkeel_found = true
                    } else {
                        dest[Int64(i)] = Char(Int32(UInt32('\u{fe70}')) + irrelevantPos[0] + shape)
                    }
                } else {
                    dest[Int64(i)] = Char(Int32(UInt32('\u{fe70}')) + (shr(currLink, 8)) + shape)
                }
            }
            if ((currLink & IRRELEVANT) == 0) {
                prevLink = lastLink
                lastLink = currLink
                lastPos = i
            }
            i--
            if (i == nx) {
                currLink = nextLink
                nx = -2
            } else if (i != -1) {
                currLink = getLink(dest[Int64(i)])
            }
        }
        tempdestSize = length
        if (lamalef_found || tashkeel_found) {
            tempdestSize = handleGeneratedSpaces(dest, start, length)
        }
        if (seenfam_found || yehhamza_found) {
            tempdestSize = expandCompositChar(dest, start, tempdestSize, lamalef_count, SHAPE_MODE)
        }
        return tempdestSize
    }

    private func deShapeUnicode(dest: Array<Char>, start: Int32, length: Int32, destSize: Int32): Int32 {
        var tempdestSize = destSize
        let lamalef_count = deshapeNormalize(dest, start, length)
        if (lamalef_count != 0) {
            tempdestSize = expandCompositChar(dest, start, length, lamalef_count, DESHAPE_MODE)
        } else {
            tempdestSize = length
        }
        return tempdestSize
    }

    private func internalShape(source: Array<Char>, sourceStart: Int32, sourceLength: Int32, dest: Array<Char>, destStart: Int32, destSize: Int32): Int32 {
        if (sourceLength == 0) {
            return 0
        }
        if (destSize == 0) {
            if (((options & LETTERS_MASK) != LETTERS_NOOP) && ((options & LAMALEF_MASK) == LAMALEF_RESIZE)) {
                return calculateSize(source, sourceStart, sourceLength)
            } else {
                return sourceLength
            }
        }
        let temp = Array<Char>(Int64(sourceLength * 2)) { _ => '\u{0000}' }
        arraycopy(source, Int64(sourceStart), temp, 0, Int64(sourceLength))
        if (isLogical) {
            invertBuffer(temp, 0, sourceLength)
        }
        var outputSize = sourceLength
        match (options & LETTERS_MASK) {
            case 24 => outputSize = shapeUnicode(temp, 0, sourceLength, destSize, 1)
            case 8 => if (((options & TASHKEEL_MASK) != 0) && ((options & TASHKEEL_MASK) != TASHKEEL_REPLACE_BY_TATWEEL)) {
                outputSize = shapeUnicode(temp, 0, sourceLength, destSize, 2)
            } else {
                outputSize = shapeUnicode(temp, 0, sourceLength, destSize, 0)
                if ((options & TASHKEEL_MASK) == TASHKEEL_REPLACE_BY_TATWEEL) {
                    outputSize = handleTashkeelWithTatweel(temp, sourceLength)
                }
            }
            case 16 => outputSize = deShapeUnicode(temp, 0, sourceLength, destSize)
            case _ => ()
        }
        if (outputSize > destSize) {
            throw ArabicShapingException("not enough room for result data")
        }
        if ((options & DIGITS_MASK) != DIGITS_NOOP) {
            var digitBase = '0'
            match (options & DIGIT_TYPE_MASK) {
                case 0 => digitBase = '\u{0660}'
                case 256 => digitBase = '\u{06f0}'
                case _ => ()
            }
            match (options & DIGITS_MASK) {
                case 32 =>
                    let digitDelta = 
                            i++
                        }
                    } while (false)
                case 64 =>
                    let digitTop = Char(Int32(UInt32(digitBase)) + 9)
                    let digitDelta = 
                            i++
                        }
                    } while (false)
                case 96 => shapeToArabicDigitsWithContext(temp, 0, outputSize, digitBase, false)
                case 128 => shapeToArabicDigitsWithContext(temp, 0, outputSize, digitBase, true)
                case _ => ()
            }
        }
        if (isLogical) {
            invertBuffer(temp, 0, outputSize)
        }
        arraycopy(temp, 0, dest, Int64(destStart), Int64(outputSize))
        return outputSize
    }
}
