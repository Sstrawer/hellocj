package icu4cj.impl


public class IDNA2003 {

    private static var ACE_PREFIX: Array<Char> = [Char(120), Char(110), Char(45), Char(45)]

    private static let MAX_LABEL_LENGTH = 63

    private static let HYPHEN = 45

    private static let CAPITAL_A = 65

    private static let CAPITAL_Z = 90

    private static let LOWER_CASE_DELTA = 32

    private static let FULL_STOP = 46

    private static let MAX_DOMAIN_NAME_LENGTH = 255

    private static let namePrep = StringPrep.getInstance(StringPrep.RFC3491_NAMEPREP)

    private static func startsWithPrefix(src: StringBuffer): Bool {
        if (Int32(src.size) < Int32(ACE_PREFIX.size)) {
            return false
        }
        var i = 0
        while (i < Int32(ACE_PREFIX.size)) {
            if (toASCIILower(src.get(Int64(i))) != ACE_PREFIX[Int64(i)]) {
                return false
            }
            i++
        }
        return true
    }

    private static func toASCIILower(ch: Char): Char {
        if (CAPITAL_A <= Int32(UInt32(ch)) && Int32(UInt32(ch)) <= CAPITAL_Z) {
            return Char(Int32(UInt32(ch)) + LOWER_CASE_DELTA)
        }
        return ch
    }

    private static func toASCIILower(src: String): StringBuffer {
        let dest = StringBuffer()
        var i = 0
        while (i < src.size) {
            dest.append(toASCIILower(src[i]))
            i++
        }
        return dest
    }

    private static func compareCaseInsensitiveASCII(s1: StringBuffer, s2: StringBuffer): Int32 {
        var c1: Char = '\u{0000}'
        var c2: Char = '\u{0000}'
        var rc: Int32 = 0
        var i = 0
        while (true) {
            if (i == Int32(s1.size)) {
                return 0
            }
            c1 = s1.get(Int64(i))
            c2 = s2.get(Int64(i))
            if (c1 != c2) {
                rc = 
                if (rc != 0) {
                    return rc
                }
            }
            i++
        }
    }

    private static func getSeparatorIndex(src: Array<Char>, start: Int32, limit: Int32): Int32 {
        var tempstart = start
        while (tempstart < limit) {
            if (isLabelSeparator(Int32(UInt32(src[Int64(tempstart)])))) {
                return tempstart
            }
            tempstart++
        }
        return tempstart
    }

    private static func isLDHChar(ch: Int32): Bool {
        if (ch > 122) {
            return false
        }
        if ((ch == 45) || (48 <= ch && ch <= 57) || (65 <= ch && ch <= 90) || (97 <= ch && ch <= 122)) {
            return true
        }
        return false
    }

    private static func isLabelSeparator(ch: Int32): Bool {
        match (ch) {
            case 46 | 12290 | 65294 | 65377 => return true
            case _ => return false
        }
    }

    public static func convertToASCII(src: UCharacterIterator, options: Int32): StringBuffer {
        var caseFlags: Array<Bool>
        var srcIsASCII = true
        var srcIsLDH = true
        let useSTD3ASCIIRules = ((options & IDNA.USE_STD3_RULES) != 0)
        var ch: Int32 = 0
        while ((match (0) { case _ => ch = src.next(); ch }) != UCharacterIterator.DONE) {
            if (ch > 127) {
                srcIsASCII = false
                break
            }
        }
        var failPos = -1
        src.setToStart()
        var processOut: StringBuffer = None
        if (!srcIsASCII) {
            processOut = namePrep.prepare(src, options)
        } else {
            processOut = StringBuffer(src.getText())
        }
        let poLen = Int32(processOut.size)
        if (poLen == 0) {
            throw StringPrepParseException("Found zero length label after NamePrep.", StringPrepParseException.ZERO_LENGTH_LABEL)
        }
        var dest: StringBuffer = StringBuffer()
        srcIsASCII = true
        var j = 0
        while (j < poLen) {
            ch = Int32(UInt32(processOut.get(Int64(j))))
            if (ch > 127) {
                srcIsASCII = false
            } else if (isLDHChar(ch) == false) {
                srcIsLDH = false
                failPos = j
            }
            j++
        }
        if (useSTD3ASCIIRules == true) {
            if (srcIsLDH == false || Int32(UInt32(processOut.get(0))) == HYPHEN || Int32(UInt32(processOut.get(Int64(Int32(processOut.size) - 1)))) == HYPHEN) {
                if (srcIsLDH == false) {
                    throw StringPrepParseException("The input does not conform to the STD 3 ASCII rules", StringPrepParseException.STD3_ASCII_RULES_ERROR, toString(processOut), if (failPos > 0) { (failPos - 1) } else { failPos })
                } else if (Int32(UInt32(processOut.get(0))) == HYPHEN) {
                    throw StringPrepParseException("The input does not conform to the STD 3 ASCII rules", StringPrepParseException.STD3_ASCII_RULES_ERROR, toString(processOut), 0)
                } else {
                    throw StringPrepParseException("The input does not conform to the STD 3 ASCII rules", StringPrepParseException.STD3_ASCII_RULES_ERROR, toString(processOut), if (poLen > 0) { poLen - 1 } else { poLen })
                }
            }
        }
        if (srcIsASCII) {
            dest = processOut
        } else {
            if (!startsWithPrefix(processOut)) {
                caseFlags = Array<Bool>(Int64(poLen)) { _ => false }
                let punyout = Punycode.encode(processOut, caseFlags)
                let lowerOut = toASCIILower(punyout.asString())
                dest.append(ACE_PREFIX, 0, Int32(ACE_PREFIX.size))
                dest.append(lowerOut)
            } else {
                throw StringPrepParseException("The input does not start with the ACE Prefix.", StringPrepParseException.ACE_PREFIX_ERROR, toString(processOut), 0)
            }
        }
        if (Int32(dest.size) > MAX_LABEL_LENGTH) {
            throw StringPrepParseException("The labels in the input are too long. Length > 63.", StringPrepParseException.LABEL_TOO_LONG_ERROR, toString(dest), 0)
        }
        return dest
    }

    public static func convertIDNToASCII(src: String, options: Int32): StringBuffer {
        let srcArr: Array<Char> = src.toRuneArray()
        let result = StringBuffer()
        var sepIndex = 0
        var oldSepIndex = 0
        while (true) {
            sepIndex = getSeparatorIndex(srcArr, sepIndex, Int32(srcArr.size))
            let label = String(srcArr)[Int64(oldSepIndex)..Int64(oldSepIndex) + Int64(sepIndex - oldSepIndex)]
            if (!(Int32(label.size) == 0 && sepIndex == Int32(srcArr.size))) {
                let iter = UCharacterIterator.getInstance(label)
                result.append(convertToASCII(iter, options))
            }
            if (sepIndex == Int32(srcArr.size)) {
                break
            }
            sepIndex++
            oldSepIndex = sepIndex
            result.append(Char(FULL_STOP))
        }
        if (Int32(result.size) > MAX_DOMAIN_NAME_LENGTH) {
            throw StringPrepParseException("The output exceed the max allowed length.", StringPrepParseException.DOMAIN_NAME_TOO_LONG_ERROR)
        }
        return result
    }

    public static func convertToUnicode(src: UCharacterIterator, options: Int32): StringBuffer {
        let caseFlags: Array<Bool> = None
        var srcIsASCII = true
        var ch: Int32 = 0
        let saveIndex = src.getIndex()
        while ((match (0) { case _ => ch = src.next(); ch }) != UCharacterIterator.DONE) {
            if (ch > 127) {
                srcIsASCII = false
            }
        }
        let processOut: StringBuffer
        if (srcIsASCII == false) {
            try {
                src.setIndex(saveIndex)
                processOut = namePrep.prepare(src, options)
            } catch (ex: StringPrepParseException) {
                return StringBuffer(src.getText())
            }
        } else {
            processOut = StringBuffer(src.getText())
        }
        if (startsWithPrefix(processOut)) {
            var decodeOut: StringBuffer = None
            let temp = processOut.substring(Int32(ACE_PREFIX.size), Int32(processOut.size))
            try {
                decodeOut = StringBuffer(Punycode.decode(temp, caseFlags).asString())
            } catch (e: StringPrepParseException) {
                decodeOut = None
            }
            if (decodeOut.isSome()) {
                let toASCIIOut = convertToASCII(UCharacterIterator.getInstance(decodeOut), options)
                if (compareCaseInsensitiveASCII(processOut, toASCIIOut) != 0) {
                    decodeOut = None
                }
            }
            if (decodeOut.isSome()) {
                return decodeOut
            }
        }
        return StringBuffer(src.getText())
    }

    public static func convertIDNToUnicode(src: String, options: Int32): StringBuffer {
        let srcArr: Array<Char> = src.toRuneArray()
        let result = StringBuffer()
        var sepIndex = 0
        var oldSepIndex = 0
        while (true) {
            sepIndex = getSeparatorIndex(srcArr, sepIndex, Int32(srcArr.size))
            let label = String(srcArr)[Int64(oldSepIndex)..Int64(oldSepIndex) + Int64(sepIndex - oldSepIndex)]
            if (Int32(label.size) == 0 && sepIndex != Int32(srcArr.size)) {
                throw StringPrepParseException("Found zero length label after NamePrep.", StringPrepParseException.ZERO_LENGTH_LABEL)
            }
            let iter = UCharacterIterator.getInstance(label)
            result.append(convertToUnicode(iter, options))
            if (sepIndex == Int32(srcArr.size)) {
                break
            }
            result.append(srcArr[Int64(sepIndex)])
            sepIndex++
            oldSepIndex = sepIndex
        }
        if (Int32(result.size) > MAX_DOMAIN_NAME_LENGTH) {
            throw StringPrepParseException("The output exceed the max allowed length.", StringPrepParseException.DOMAIN_NAME_TOO_LONG_ERROR)
        }
        return result
    }

    public static func compare(s1: String, s2: String, options: Int32): Int32 {
        let s1Out = convertIDNToASCII(s1, options)
        let s2Out = convertIDNToASCII(s2, options)
        return compareCaseInsensitiveASCII(s1Out, s2Out)
    }
}
