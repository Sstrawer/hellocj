package icu4cj.impl


public class UTS46 <: IDNA {
    public init(options: Int32) {
        super()
        this.options = options
    }

    public override func labelToASCII(label: String, dest: StringBuilder, info: IDNA_Info): StringBuilder {
        return process(label, true, true, dest, info)
    }

    public override func labelToUnicode(label: String, dest: StringBuilder, info: IDNA_Info): StringBuilder {
        return process(label, true, false, dest, info)
    }

    public override func nameToASCII(name: String, dest: StringBuilder, info: IDNA_Info): StringBuilder {
        process(name, false, true, dest, info)
        if (Int32(dest.size) >= 254 && !info.getErrors().contains(IDNA_Error.DOMAIN_NAME_TOO_LONG) && isASCIIString(dest.asString()) && (Int32(dest.size) > 254 || dest.get(253) != '.')) {
            addError(info, IDNA_Error.DOMAIN_NAME_TOO_LONG)
        }
        return dest
    }

    public override func nameToUnicode(name: String, dest: StringBuilder, info: IDNA_Info): StringBuilder {
        return process(name, false, false, dest, info)
    }

    private static let uts46Norm2 = Normalizer2.getInstance(None, "uts46", Normalizer2_Mode.COMPOSE)

    let options: Int32

    private static let severeErrors = EnumSet.of(IDNA_Error.LEADING_COMBINING_MARK, IDNA_Error.DISALLOWED, IDNA_Error.PUNYCODE, IDNA_Error.LABEL_HAS_DOT, IDNA_Error.INVALID_ACE_LABEL)

    private static func isASCIIString(dest: String): Bool {
        let length = dest.size
        var i = 0
        while (i < length) {
            if (Int32(UInt32(dest[i])) > 127) {
                return false
            }
            i++
        }
        return true
    }

    private static let asciiData: Array<UInt8> = [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255]

    private func process(src: String, isLabel: Bool, toASCII: Bool, dest: StringBuilder, info: IDNA_Info): StringBuilder {
        if (refEq(dest, src)) {
            throw IllegalArgumentException()
        }
        dest.delete(0, 2147483647)
        resetInfo(info)
        let srcLength = src.size
        if (srcLength == 0) {
            addError(info, IDNA_Error.EMPTY_LABEL)
            return dest
        }
        let disallowNonLDHDot = (options & USE_STD3_RULES) != 0
        var labelStart = 0
        var i: Int32 = 0
        i = 0
        while (true) {
            if (i == srcLength) {
                if (toASCII) {
                    if ((i - labelStart) > 63) {
                        addLabelError(info, IDNA_Error.LABEL_TOO_LONG)
                    }
                    if (!isLabel && i >= 254 && (i > 254 || labelStart < i)) {
                        addError(info, IDNA_Error.DOMAIN_NAME_TOO_LONG)
                    }
                }
                promoteAndResetLabelErrors(info)
                return dest
            }
            let c = src[i]
            if (Int32(UInt32(c)) > 127) {
                break
            }
            let cData = Int32(asciiData[Int64(UInt32(c))])
            if (cData > 0) {
                dest.append(Char(Int32(UInt32(c)) + 32))
            } else if (cData < 0 && disallowNonLDHDot) {
                break
            } else {
                dest.append(c)
                if (c == '-') {
                    if (i == (labelStart + 3) && src[i - 1] == '-') {
                        i++
                        break
                    }
                    if (i == labelStart) {
                        addLabelError(info, IDNA_Error.LEADING_HYPHEN)
                    }
                    if ((i + 1) == srcLength || src[i + 1] == '.') {
                        addLabelError(info, IDNA_Error.TRAILING_HYPHEN)
                    }
                } else if (c == '.') {
                    if (isLabel) {
                        i++
                        break
                    }
                    if (i == labelStart) {
                        addLabelError(info, IDNA_Error.EMPTY_LABEL)
                    }
                    if (toASCII && (i - labelStart) > 63) {
                        addLabelError(info, IDNA_Error.LABEL_TOO_LONG)
                    }
                    promoteAndResetLabelErrors(info)
                    labelStart = i + 1
                }
            }
            i++
        }
        promoteAndResetLabelErrors(info)
        processUnicode(src, labelStart, i, isLabel, toASCII, dest, info)
        if (isBiDi(info) && !hasCertainErrors(info, severeErrors) && (!isOkBiDi(info) || (labelStart > 0 && !isASCIIOkBiDi(dest.asString(), labelStart)))) {
            addError(info, IDNA_Error.BIDI)
        }
        return dest
    }

    private func processUnicode(src: String, labelStart: Int32, mappingStart: Int32, isLabel: Bool, toASCII: Bool, dest: StringBuilder, info: IDNA_Info): StringBuilder {
        var templabelStart = labelStart
        if (mappingStart == 0) {
            uts46Norm2.normalize(src, dest)
        } else {
            uts46Norm2.normalizeSecondAndAppend(dest, src.subSequence(mappingStart, src.size))
        }
        var doMapDevChars = if (toASCII) { (options & NONTRANSITIONAL_TO_ASCII) == 0 } else { (options & NONTRANSITIONAL_TO_UNICODE) == 0 }
        var destLength = Int32(dest.size)
        var labelLimit = templabelStart
        while (labelLimit < destLength) {
            let c = dest.get(Int64(labelLimit))
            if (c == '.' && !isLabel) {
                let labelLength = labelLimit - templabelStart
                let newLength = processLabel(dest, templabelStart, labelLength, toASCII, info)
                promoteAndResetLabelErrors(info)
                destLength += newLength - labelLength
                labelLimit = templabelStart += newLength + 1
                continue
            } else if (Int32(UInt32(c)) < 223) { } else if (Int32(UInt32(c)) <= 8205 && (Int32(UInt32(c)) == 223 || Int32(UInt32(c)) == 962 || Int32(UInt32(c)) >= 8204)) {
                setTransitionalDifferent(info)
                if (doMapDevChars) {
                    destLength = mapDevChars(dest, templabelStart, labelLimit)
                    doMapDevChars = false
                    continue
                }
            } else if (Character.isSurrogate(c)) {
                if (if (Normalizer2Impl_UTF16Plus.isSurrogateLead(Int32(UInt32(c)))) { (labelLimit + 1) == destLength || !Character.isLowSurrogate(dest.get(Int64(labelLimit + 1))) } else { labelLimit == templabelStart || !Character.isHighSurrogate(dest.get(Int64(labelLimit - 1))) }) {
                    addLabelError(info, IDNA_Error.DISALLOWED)
                    dest.insert(Int64(labelLimit), '\u{fffd}')
                }
            }
            labelLimit++
        }
        if (0 == templabelStart || templabelStart < labelLimit) {
            processLabel(dest, templabelStart, labelLimit - templabelStart, toASCII, info)
            promoteAndResetLabelErrors(info)
        }
        return dest
    }

    private func mapDevChars(dest: StringBuilder, labelStart: Int32, mappingStart: Int32): Int32 {
        var length = Int32(dest.size)
        var didMapDevChars = false
        var i = mappingStart
        while (i < length) {
            let c = dest.get(Int64(i))
            <-- Internal error: switch (c) {
            case 223:
                didMapDevChars = true;
                dest.setCharAt(i++, 's');
                dest.insert(i++, 's');
                ++length;
                break;

            case 962:
                didMapDevChars = true;
                dest.setCharAt(i++, '\u{03c3}');
                break;

            case 8204:

            case 8205:
                didMapDevChars = true;
                dest.delete(i, i + 1);
                --length;
                break;

            default:
                ++i;
                break;

            } -->
        }
        if (didMapDevChars) {
            let normalized = uts46Norm2.normalize(dest.subSequence(labelStart, Int32(dest.size)))
            dest.replace(Int64(labelStart), 2147483647, normalized)
            return Int32(dest.size)
        }
        return length
    }

    private static func replaceLabel(dest: StringBuilder, destLabelStart: Int32, destLabelLength: Int32, label: String, labelLength: Int32): Int32 {
        if (!refEq(label, dest)) {
            dest.delete(destLabelStart, destLabelStart + destLabelLength).insert(Int64(destLabelStart), label)
        }
        return labelLength
    }

    private func processLabel(dest: StringBuilder, labelStart: Int32, labelLength: Int32, toASCII: Bool, info: IDNA_Info): Int32 {
        var templabelStart = labelStart
        var templabelLength = labelLength
        let fromPunycode: StringBuilder
        let labelString: StringBuilder
        let destLabelStart = templabelStart
        var destLabelLength = templabelLength
        let wasPunycode: Bool
        if (templabelLength >= 4 && dest.get(Int64(templabelStart)) == 'x' && dest.get(Int64(templabelStart + 1)) == 'n' && dest.get(Int64(templabelStart + 2)) == '-' && dest.get(Int64(templabelStart + 3)) == '-') {
            if (templabelLength == 4 || (templabelLength > 5 && dest.get(Int64(templabelStart + templabelLength - 1)) == '-')) {
                addLabelError(info, IDNA_Error.INVALID_ACE_LABEL)
                return markBadACELabel(dest, templabelStart, templabelLength, toASCII, info)
            }
            wasPunycode = true
            try {
                fromPunycode = Punycode.decode(dest.subSequence(templabelStart + 4, templabelStart + templabelLength), None)
            } catch (e: StringPrepParseException) {
                addLabelError(info, IDNA_Error.PUNYCODE)
                return markBadACELabel(dest, templabelStart, templabelLength, toASCII, info)
            }
            let isValid = uts46Norm2.isNormalized(fromPunycode.asString())
            if (!isValid) {
                addLabelError(info, IDNA_Error.INVALID_ACE_LABEL)
                return markBadACELabel(dest, templabelStart, templabelLength, toASCII, info)
            }
            labelString = fromPunycode
            templabelStart = 0
            templabelLength = Int32(fromPunycode.size)
        } else {
            wasPunycode = false
            labelString = dest
        }
        if (templabelLength == 0) {
            addLabelError(info, IDNA_Error.EMPTY_LABEL)
            return replaceLabel(dest, destLabelStart, destLabelLength, labelString.asString(), templabelLength)
        }
        if (templabelLength >= 4 && labelString.get(Int64(templabelStart + 2)) == '-' && labelString.get(Int64(templabelStart + 3)) == '-') {
            addLabelError(info, IDNA_Error.HYPHEN_3_4)
        }
        if (labelString.get(Int64(templabelStart)) == '-') {
            addLabelError(info, IDNA_Error.LEADING_HYPHEN)
        }
        if (labelString.get(Int64(templabelStart + templabelLength - 1)) == '-') {
            addLabelError(info, IDNA_Error.TRAILING_HYPHEN)
        }
        var i = templabelStart
        let limit = templabelStart + templabelLength
        var oredChars = Char(0)
        let disallowNonLDHDot = (options & USE_STD3_RULES) != 0
                    addLabelError(info, IDNA_Error.DISALLOWED)
                    labelString.insert(Int64(i), '\u{fffd}')
                }
            } else {
                oredChars |= c
                if (Int32(UInt32(c)) == 65533) {
                    addLabelError(info, IDNA_Error.DISALLOWED)
                }
            }
            i++
        } while (i < limit)
        let c: Int32
        c = labelString.codePointAt(templabelStart)
        if ((U_GET_GC_MASK(c) & U_GC_M_MASK) != 0) {
            addLabelError(info, IDNA_Error.LEADING_COMBINING_MARK)
            labelString.insert(Int64(templabelStart), '\u{fffd}')
            if (c > 65535) {
                labelString.deleteCharAt(Int64(templabelStart + 1))
                templabelLength--
                if (refEq(labelString, dest)) {
                    destLabelLength--
                }
            }
        }
        if (!hasCertainLabelErrors(info, severeErrors)) {
            if ((options & CHECK_BIDI) != 0 && (!isBiDi(info) || isOkBiDi(info))) {
                checkLabelBiDi(labelString.asString(), templabelStart, templabelLength, info)
            }
            if ((options & CHECK_CONTEXTJ) != 0 && (Int32(UInt32(oredChars)) & 8204) == 8204 && !isLabelOkContextJ(labelString.asString(), templabelStart, templabelLength)) {
                addLabelError(info, IDNA_Error.CONTEXTJ)
            }
            if ((options & CHECK_CONTEXTO) != 0 && Int32(UInt32(oredChars)) >= 183) {
                checkLabelContextO(labelString.asString(), templabelStart, templabelLength, info)
            }
            if (toASCII) {
                if (wasPunycode) {
                    if (destLabelLength > 63) {
                        addLabelError(info, IDNA_Error.LABEL_TOO_LONG)
                    }
                    return destLabelLength
                } else if (Int32(UInt32(oredChars)) >= 128) {
                    let punycode: StringBuilder
                    try {
                        punycode = Punycode.encode(labelString.subSequence(templabelStart, templabelStart + templabelLength), None)
                    } catch (e: StringPrepParseException) {
                        throw ICUException(e as Exception)
                    }
                    punycode.insert(0, "xn--")
                    if (Int32(punycode.size) > 63) {
                        addLabelError(info, IDNA_Error.LABEL_TOO_LONG)
                    }
                    return replaceLabel(dest, destLabelStart, destLabelLength, punycode.asString(), Int32(punycode.size))
                } else {
                    if (templabelLength > 63) {
                        addLabelError(info, IDNA_Error.LABEL_TOO_LONG)
                    }
                }
            }
        } else {
            if (wasPunycode) {
                addLabelError(info, IDNA_Error.INVALID_ACE_LABEL)
                return markBadACELabel(dest, destLabelStart, destLabelLength, toASCII, info)
            }
        }
        return replaceLabel(dest, destLabelStart, destLabelLength, labelString.asString(), templabelLength)
    }

    private func markBadACELabel(dest: StringBuilder, labelStart: Int32, labelLength: Int32, toASCII: Bool, info: IDNA_Info): Int32 {
        var templabelLength = labelLength
        let disallowNonLDHDot = (options & USE_STD3_RULES) != 0
        var isASCII = true
        var onlyLDH = true
        let limit = labelStart + templabelLength
        var i = labelStart + 4
        while (i < limit) {
            let c = dest.get(Int64(i))
            if (Int32(UInt32(c)) <= 127) {
                if (c == '.') {
                    addLabelError(info, IDNA_Error.LABEL_HAS_DOT)
                    dest.insert(Int64(i), '\u{fffd}')
                    isASCII = match (0) { case _ => onlyLDH = false; onlyLDH }
                } else if (Int32(asciiData[Int64(UInt32(c))]) < 0) {
                    onlyLDH = false
                    if (disallowNonLDHDot) {
                        dest.insert(Int64(i), '\u{fffd}')
                        isASCII = false
                    }
                }
            } else {
                isASCII = match (0) { case _ => onlyLDH = false; onlyLDH }
            }
            i++
        }
        if (onlyLDH) {
            dest.insert(Int64(labelStart + templabelLength), '\u{fffd}')
            templabelLength++
        } else {
            if (toASCII && isASCII && templabelLength > 63) {
                addLabelError(info, IDNA_Error.LABEL_TOO_LONG)
            }
        }
        return templabelLength
    }

    private static let L_MASK = U_MASK(UCharacterDirection.LEFT_TO_RIGHT)

    private static let R_AL_MASK = U_MASK(UCharacterDirection.RIGHT_TO_LEFT) | U_MASK(UCharacterDirection.RIGHT_TO_LEFT_ARABIC)

    private static let L_R_AL_MASK = L_MASK | R_AL_MASK

    private static let R_AL_AN_MASK = R_AL_MASK | U_MASK(UCharacterDirection.ARABIC_NUMBER)

    private static let EN_AN_MASK = U_MASK(UCharacterDirection.EUROPEAN_NUMBER) | U_MASK(UCharacterDirection.ARABIC_NUMBER)

    private static let R_AL_EN_AN_MASK = R_AL_MASK | EN_AN_MASK

    private static let L_EN_MASK = L_MASK | U_MASK(UCharacterDirection.EUROPEAN_NUMBER)

    private static let ES_CS_ET_ON_BN_NSM_MASK = U_MASK(UCharacterDirection.EUROPEAN_NUMBER_SEPARATOR) | U_MASK(UCharacterDirection.COMMON_NUMBER_SEPARATOR) | U_MASK(UCharacterDirection.EUROPEAN_NUMBER_TERMINATOR) | U_MASK(UCharacterDirection.OTHER_NEUTRAL) | U_MASK(UCharacterDirection.BOUNDARY_NEUTRAL) | U_MASK(UCharacterDirection.DIR_NON_SPACING_MARK)

    private static let L_EN_ES_CS_ET_ON_BN_NSM_MASK = L_EN_MASK | ES_CS_ET_ON_BN_NSM_MASK

    private static let R_AL_AN_EN_ES_CS_ET_ON_BN_NSM_MASK = R_AL_MASK | EN_AN_MASK | ES_CS_ET_ON_BN_NSM_MASK

    private func checkLabelBiDi(label: String, labelStart: Int32, labelLength: Int32, info: IDNA_Info): Unit {
        var c: Int32 = 0
        var i = labelStart
        c = Character.codePointAt(label, i)
        i += Character.charCount(c)
        let firstMask = U_MASK(UBiDiProps.INSTANCE.getClass(c))
        if ((firstMask & ) != 0) {
            setNotOkBiDi(info)
        }
        let lastMask: Int32
        var labelLimit = labelStart + labelLength
        while (true) {
            if (i >= labelLimit) {
                lastMask = firstMask
                break
            }
            c = Character.codePointBefore(label, labelLimit)
            labelLimit -= Character.charCount(c)
            let dir = UBiDiProps.INSTANCE.getClass(c)
            if (dir != UCharacterDirection.DIR_NON_SPACING_MARK) {
                lastMask = U_MASK(dir)
                break
            }
        }
        if (if ((firstMask & L_MASK) != 0) { (lastMask & ) != 0 } else { (lastMask & ) != 0 }) {
            setNotOkBiDi(info)
        }
        var mask = firstMask | lastMask
        while (i < labelLimit) {
            c = Character.codePointAt(label, i)
            i += Character.charCount(c)
            mask |= U_MASK(UBiDiProps.INSTANCE.getClass(c))
        }
        if ((firstMask & L_MASK) != 0) {
            if ((mask & ) != 0) {
                setNotOkBiDi(info)
            }
        } else {
            if ((mask & ) != 0) {
                setNotOkBiDi(info)
            }
            if ((mask & EN_AN_MASK) == EN_AN_MASK) {
                setNotOkBiDi(info)
            }
        }
        if ((mask & R_AL_AN_MASK) != 0) {
            setBiDi(info)
        }
    }

    private static func isASCIIOkBiDi(s: String, length: Int32): Bool {
        var labelStart = 0
        var i = 0
        while (i < length) {
            var c = s[i]
            if (c == '.') {
                if (i > labelStart) {
                    c = s[i - 1]
                    if (!('a' <= c && c <= 'z') && !('0' <= c && c <= '9')) {
                        return false
                    }
                }
                labelStart = i + 1
            } else if (i == labelStart) {
                if (!('a' <= c && c <= 'z')) {
                    return false
                }
            } else {
                if (Int32(UInt32(c)) <= 32 && (Int32(UInt32(c)) >= 28 || (9 <= Int32(UInt32(c)) && Int32(UInt32(c)) <= 13))) {
                    return false
                }
            }
            i++
        }
        return true
    }

    private func isLabelOkContextJ(label: String, labelStart: Int32, labelLength: Int32): Bool {
        let labelLimit = labelStart + labelLength
        var i = labelStart
        while (i < labelLimit) {
            if (Int32(UInt32(label[i])) == 8204) {
                if (i == labelStart) {
                    return false
                }
                var c: Int32 = 0
                var j = i
                c = Character.codePointBefore(label, j)
                j -= Character.charCount(c)
                if (uts46Norm2.getCombiningClass(c) == 9) {
                    continue
                }
                while (true) {
                    let Type = UBiDiProps.INSTANCE.getJoiningType(c)
                    if (Type == UCharacter_JoiningType.TRANSPARENT) {
                        if (j == 0) {
                            return false
                        }
                        c = Character.codePointBefore(label, j)
                        j -= Character.charCount(c)
                    } else if (Type == UCharacter_JoiningType.LEFT_JOINING || Type == UCharacter_JoiningType.DUAL_JOINING) {
                        break
                    } else {
                        return false
                    }
                }
                j = i + 1
                while (true) {
                    if (j == labelLimit) {
                        return false
                    }
                    c = Character.codePointAt(label, j)
                    j += Character.charCount(c)
                    let Type = UBiDiProps.INSTANCE.getJoiningType(c)
                    if (Type == UCharacter_JoiningType.TRANSPARENT) { } else if (Type == UCharacter_JoiningType.RIGHT_JOINING || Type == UCharacter_JoiningType.DUAL_JOINING) {
                        break
                    } else {
                        return false
                    }
                }
            } else if (Int32(UInt32(label[i])) == 8205) {
                if (i == labelStart) {
                    return false
                }
                let c = Character.codePointBefore(label, i)
                if (uts46Norm2.getCombiningClass(c) != 9) {
                    return false
                }
            }
            i++
        }
        return true
    }

    private func checkLabelContextO(label: String, labelStart: Int32, labelLength: Int32, info: IDNA_Info): Unit {
        let labelEnd = labelStart + labelLength - 1
        var arabicDigits = 0
        var i = labelStart
        while (i <= labelEnd) {
            var c = Int32(UInt32(label[i]))
            if (c < 183) { } else if (c <= 1785) {
                if (c == 183) {
                    if (!(labelStart < i && label[i - 1] == 'l' && i < labelEnd && label[i + 1] == 'l')) {
                        addLabelError(info, IDNA_Error.CONTEXTO_PUNCTUATION)
                    }
                } else if (c == 885) {
                    if (!(i < labelEnd && UScript.GREEK == UScript.getScript(Character.codePointAt(label, i + 1)))) {
                        addLabelError(info, IDNA_Error.CONTEXTO_PUNCTUATION)
                    }
                } else if (c == 1523 || c == 1524) {
                    if (!(labelStart < i && UScript.HEBREW == UScript.getScript(Character.codePointBefore(label, i)))) {
                        addLabelError(info, IDNA_Error.CONTEXTO_PUNCTUATION)
                    }
                } else if (1632 <= c) {
                    if (c <= 1641) {
                        if (arabicDigits > 0) {
                            addLabelError(info, IDNA_Error.CONTEXTO_DIGITS)
                        }
                        arabicDigits = -1
                    } else if (1776 <= c) {
                        if (arabicDigits < 0) {
                            addLabelError(info, IDNA_Error.CONTEXTO_DIGITS)
                        }
                        arabicDigits = 1
                    }
                }
            } else if (c == 12539) {
                var j = labelStart
                while (true) {
                    if (j > labelEnd) {
                        addLabelError(info, IDNA_Error.CONTEXTO_PUNCTUATION)
                        break
                    }
                    c = Character.codePointAt(label, j)
                    let script = UScript.getScript(c)
                    if (script == UScript.HIRAGANA || script == UScript.KATAKANA || script == UScript.HAN) {
                        break
                    }
                    j += Character.charCount(c)
                }
            }
            i++
        }
    }

    private static func U_MASK(x: Int32): Int32 {
        return shl(1, x)
    }

    private static func U_GET_GC_MASK(c: Int32): Int32 {
        return (shl(1, UCharacter.getType(c)))
    }

    private static var U_GC_M_MASK = U_MASK(Int32(UCharacterCategory.NON_SPACING_MARK)) | U_MASK(Int32(UCharacterCategory.ENCLOSING_MARK)) | U_MASK(Int32(UCharacterCategory.COMBINING_SPACING_MARK))
}
