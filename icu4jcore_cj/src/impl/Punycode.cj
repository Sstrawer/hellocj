package icu4cj.impl


public class Punycode {

    private static let BASE = 36

    private static let TMIN = 1

    private static let TMAX = 26

    private static let SKEW = 38

    private static let DAMP = 700

    private static let INITIAL_BIAS = 72

    private static let INITIAL_N = 128

    private static let HYPHEN = Char(45)

    private static let DELIMITER = HYPHEN

    private static let ZERO = 48

    private static let SMALL_A = 97

    private static let SMALL_Z = 122

    private static let CAPITAL_A = 65

    private static let CAPITAL_Z = 90

    private static func adaptBias(delta: Int32, length: Int32, firstTime: Bool): Int32 {
        var tempdelta = delta
        if (firstTime) {
            tempdelta /= DAMP
        } else {
            tempdelta /= 2
        }
        tempdelta += tempdelta / length
        var count = 0
        while (tempdelta > ((BASE - TMIN) * TMAX) / 2) {
            tempdelta /= (BASE - TMIN)
            count += BASE
        }
        return count + (((BASE - TMIN + 1) * tempdelta) / (tempdelta + SKEW))
    }

    private static func decodeDigit(cp: Int32): Int32 {
        if (cp <= Int32(UInt32('Z'))) {
            if (cp <= Int32(UInt32('9'))) {
                if (cp < Int32(UInt32('0'))) {
                    return -1
                } else {
                    return cp - Int32(UInt32('0')) + 26
                }
            } else {
                return cp - Int32(UInt32('A'))
            }
        } else if (cp <= Int32(UInt32('z'))) {
            return cp - Int32(UInt32('a'))
        } else {
            return -1
        }
    }

    private static func asciiCaseMap(b: Char, uppercase: Bool): Char {
        var tempb = b
        if (uppercase) {
            if (SMALL_A <= Int32(UInt32(tempb)) && Int32(UInt32(tempb)) <= SMALL_Z) {
                tempb -= (Char(SMALL_A - CAPITAL_A))
            }
        } else {
            if (CAPITAL_A <= Int32(UInt32(tempb)) && Int32(UInt32(tempb)) <= CAPITAL_Z) {
                tempb += (Char(SMALL_A - CAPITAL_A))
            }
        }
        return tempb
    }

    private static func digitToBasic(digit: Int32, uppercase: Bool): Char {
        if (digit < 26) {
            if (uppercase) {
                return Char(CAPITAL_A + digit)
            } else {
                return Char(SMALL_A + digit)
            }
        } else {
            return Char((ZERO - 26) + digit)
        }
    }

    private static let ENCODE_MAX_CODE_UNITS = 1000

    private static let DECODE_MAX_CHARS = 2000

    public static func encode(src: String, caseFlags: Array<Bool>): StringBuilder {
        var n: Int32 = 0
        var delta: Int32 = 0
        var handledCPCount: Int32 = 0
        let basicLength: Int32
        var bias: Int32 = 0
        var j: Int32 = 0
        var m: Int32 = 0
        var q: Int32 = 0
        var k: Int32 = 0
        var t: Int32 = 0
        var srcCPCount: Int32 = 0
        var c: Char = '\u{0000}'
        var c2: Char = '\u{0000}'
        let srcLength = src.size
        if (srcLength > ENCODE_MAX_CODE_UNITS) {
            throw ICUInputTooLongException("input too long: " + srcLength.toString() + " UTF-16 code units")
        }
        let cpBuffer = Array<Int32>(Int64(srcLength)) { _ => 0 }
        let dest = StringBuilder()
        srcCPCount = 0
        j = 0
        while (j < srcLength) {
            c = src[j]
            if (isBasic(Int32(UInt32(c)))) {
                cpBuffer[Int64(match (0) { case _ => srcCPCount++; srcCPCount - 1 })] = 0
                dest.append(if (caseFlags.isSome()) { asciiCaseMap(c, caseFlags[Int64(j)]) } else { c })
            } else {
                n = shl((if (caseFlags.isSome() && caseFlags[Int64(j)]) { 1 } else { 0 }), 31)
                if (!UTF16.isSurrogate(Int32(UInt32(c)))) {
                    n |= Int32(UInt32(c))
                } else if (UTF16.isLeadSurrogate(Int32(UInt32(c))) && (j + 1) < srcLength && UTF16.isTrailSurrogate(Int32(UInt32(match (0) { case _ => c2 = src[j + 1]; c2 })))) {
                    j++
                    n |= UCharacter.getCodePoint(Int32(UInt32(c)), Int32(UInt32(c2)))
                } else {
                    throw StringPrepParseException("Illegal char found", StringPrepParseException.ILLEGAL_CHAR_FOUND)
                }
                cpBuffer[Int64(match (0) { case _ => srcCPCount++; srcCPCount - 1 })] = n
            }
            j++
        }
        basicLength = Int32(dest.size)
        if (basicLength > 0) {
            dest.append(DELIMITER)
        }
        n = INITIAL_N
        delta = 0
        bias = INITIAL_BIAS
        handledCPCount = basicLength
        while (handledCPCount < srcCPCount) {
            m = 2147483647
            j = 0
            while (j < srcCPCount) {
                q = cpBuffer[Int64(j)] & 2147483647
                if (n <= q && q < m) {
                    m = q
                }
                j++
            }
            if (m - n > (2147483647 - handledCPCount - delta) / (handledCPCount + 1)) {
                throw Exception("Internal program error")
            }
            delta += (m - n) * (handledCPCount + 1)
            n = m
            j = 0
            while (j < srcCPCount) {
                q = cpBuffer[Int64(j)] & 2147483647
                if (q < n) {
                    delta++
                } else if (q == n) {
                    q = delta
                    k = BASE
                    while (true) {
                        t = k - bias
                        if (t < TMIN) {
                            t = TMIN
                        } else if (k >= (bias + TMAX)) {
                            t = TMAX
                        }
                        if (q < t) {
                            break
                        }
                        dest.append(digitToBasic(t + (q - t) % (BASE - t), false))
                        q = (q - t) / (BASE - t)
                        k += BASE
                    }
                    dest.append(digitToBasic(q, (cpBuffer[Int64(j)] < 0)))
                    bias = adaptBias(delta, handledCPCount + 1, (handledCPCount == basicLength))
                    delta = 0
                    handledCPCount++
                }
                j++
            }
            delta++
            n++
        }
        return dest
    }

    private static func isBasic(ch: Int32): Bool {
        return (ch < INITIAL_N)
    }

    private static func isBasicUpperCase(ch: Int32): Bool {
        return (CAPITAL_A <= ch && ch >= CAPITAL_Z)
    }

    private static func isSurrogate(ch: Int32): Bool {
        return (((ch) & -2048) == 55296)
    }

    public static func decode(src: String, caseFlags: Array<Bool>): StringBuilder {
        let srcLength = src.size
        if (srcLength > DECODE_MAX_CHARS) {
            throw ICUInputTooLongException("input too long: " + srcLength.toString() + " characters")
        }
        let dest = StringBuilder()
        var n: Int32 = 0
        var i: Int32 = 0
        var bias: Int32 = 0
        let basicLength: Int32
        var j: Int32 = 0
        var input: Int32 = 0
        var oldi: Int32 = 0
        var w: Int32 = 0
        var k: Int32 = 0
        var digit: Int32 = 0
        var t: Int32 = 0
        var destCPCount: Int32 = 0
        var firstSupplementaryIndex: Int32 = 0
        var cpLength: Int32 = 0
        var b: Char = '\u{0000}'
        j = srcLength
        while (j > 0) {
            if (src[match (0] { case _ => j--; j }) == DELIMITER) {
                break
            }
        }
        basicLength = match (0) { case _ => destCPCount = j; destCPCount }
        j = 0
        while (j < basicLength) {
            b = src[j]
            if (!isBasic(Int32(UInt32(b)))) {
                throw StringPrepParseException("Illegal char found", StringPrepParseException.INVALID_CHAR_FOUND)
            }
            dest.append(b)
            if (caseFlags.isSome() && j < Int32(caseFlags.size)) {
                caseFlags[Int64(j)] = isBasicUpperCase(Int32(UInt32(b)))
            }
            j++
        }
        n = INITIAL_N
        i = 0
        bias = INITIAL_BIAS
        firstSupplementaryIndex = 1000000000
        input = if (basicLength > 0) { basicLength + 1 } else { 0 }
        while (input < srcLength) {
            oldi = i
            w = 1
            k = BASE
            while (true) {
                if (input >= srcLength) {
                    throw StringPrepParseException("Illegal char found", StringPrepParseException.ILLEGAL_CHAR_FOUND)
                }
                digit = decodeDigit(Int32(UInt32(src[match (0] { case _ => input++; input - 1 }))))
                if (digit < 0) {
                    throw StringPrepParseException("Invalid char found", StringPrepParseException.INVALID_CHAR_FOUND)
                }
                if (digit > (2147483647 - i) / w) {
                    throw StringPrepParseException("Illegal char found", StringPrepParseException.ILLEGAL_CHAR_FOUND)
                }
                i += digit * w
                t = k - bias
                if (t < TMIN) {
                    t = TMIN
                } else if (k >= (bias + TMAX)) {
                    t = TMAX
                }
                if (digit < t) {
                    break
                }
                if (w > 2147483647 / (BASE - t)) {
                    throw StringPrepParseException("Illegal char found", StringPrepParseException.ILLEGAL_CHAR_FOUND)
                }
                w *= BASE - t
                k += BASE
            }
            destCPCount++
            bias = adaptBias(i - oldi, destCPCount, (oldi == 0))
            if (i / destCPCount > (2147483647 - n)) {
                throw StringPrepParseException("Illegal char found", StringPrepParseException.ILLEGAL_CHAR_FOUND)
            }
            n += i / destCPCount
            i %= destCPCount
            if (n > 1114111 || isSurrogate(n)) {
                throw StringPrepParseException("Illegal char found", StringPrepParseException.ILLEGAL_CHAR_FOUND)
            }
            cpLength = Character.charCount(n)
            let codeUnitIndex: Int32
            if (i <= firstSupplementaryIndex) {
                codeUnitIndex = i
                if (cpLength > 1) {
                    firstSupplementaryIndex = codeUnitIndex
                } else {
                    firstSupplementaryIndex++
                }
            } else {
                codeUnitIndex = dest.offsetByCodePoints(firstSupplementaryIndex, i - firstSupplementaryIndex)
            }
            if (caseFlags.isSome() && (Int32(dest.size) + cpLength) <= Int32(caseFlags.size)) {
                if (codeUnitIndex < Int32(dest.size)) {
                    arraycopy(caseFlags, Int64(codeUnitIndex), caseFlags, Int64(codeUnitIndex + cpLength), Int64(Int32(dest.size) - codeUnitIndex))
                }
                caseFlags[Int64(codeUnitIndex)] = isBasicUpperCase(Int32(UInt32(src[input - 1])))
                if (cpLength == 2) {
                    caseFlags[Int64(codeUnitIndex + 1)] = false
                }
            }
            if (cpLength == 1) {
                dest.insert(Int64(codeUnitIndex), Char(n))
            } else {
                dest.insert(Int64(codeUnitIndex), UTF16.getLeadSurrogate(n))
                dest.insert(Int64(codeUnitIndex + 1), UTF16.getTrailSurrogate(n))
            }
            i++
        }
        return dest
    }
}
