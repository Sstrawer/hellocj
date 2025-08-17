package icu4cj.lang


public class UCharacter <: UCharacterEnums_ECharacterCategory & UCharacterEnums_ECharacterDirection {
    private static let LEAD_SURROGATE_BITMASK = -1024

    private static let TRAIL_SURROGATE_BITMASK = -1024

    private static let LEAD_SURROGATE_BITS = 55296

    private static let TRAIL_SURROGATE_BITS = 56320

    private static let U16_SURROGATE_OFFSET = ((shl(55296, 10)) + 56320 - 65536)

    public static let MIN_VALUE = Character.MIN_CODE_POINT

    public static let MAX_VALUE = Character.MAX_CODE_POINT

    public static let SUPPLEMENTARY_MIN_VALUE = Character.MIN_SUPPLEMENTARY_CODE_POINT

    public static let REPLACEMENT_CHAR = Int32(UInt32('\u{fffd}'))

    public static let NO_NUMERIC_VALUE = -123456789.0

    public static let MIN_RADIX = Character.MIN_RADIX

    public static let MAX_RADIX = Character.MAX_RADIX

    public static let TITLECASE_NO_LOWERCASE = 256

    public static let TITLECASE_NO_BREAK_ADJUSTMENT = 512

    public static func digit(ch: Int32, radix: Int32): Int32 {
        if (2 <= radix && radix <= 36) {
            var value = digit(ch)
            if (value < 0) {
                value = UCharacterProperty.getEuropeanDigit(ch)
            }
            return if (value < radix) { value } else { -1 }
        } else {
            return -1
        }
    }

    public static func digit(ch: Int32): Int32 {
        return UCharacterProperty.INSTANCE.digit(ch)
    }

    public static func getNumericValue(ch: Int32): Int32 {
        return UCharacterProperty.INSTANCE.getNumericValue(ch)
    }

    public static func getUnicodeNumericValue(ch: Int32): Float64 {
        return UCharacterProperty.INSTANCE.getUnicodeNumericValue(ch)
    }

    
    public static func isSpace(ch: Int32): Bool {
        return ch <= 32 && (ch == 32 || ch == 9 || ch == 10 || ch == 12 || ch == 13)
    }

    public static func getType(ch: Int32): Int32 {
        return UCharacterProperty.INSTANCE.getType(ch)
    }

    public static func isDefined(ch: Int32): Bool {
        return getType(ch) != 0
    }

    public static func isDigit(ch: Int32): Bool {
        return getType(ch) == Int32(UCharacterCategory.DECIMAL_DIGIT_NUMBER)
    }

    public static func isISOControl(ch: Int32): Bool {
        return ch >= 0 && ch <= APPLICATION_PROGRAM_COMMAND_ && ((ch <= UNIT_SEPARATOR_) || (ch >= DELETE_))
    }

    public static func isLetter(ch: Int32): Bool {
        return ((shl(1, getType(ch))) & ((shl(1, Int32(UCharacterCategory.UPPERCASE_LETTER))) | (shl(1, Int32(UCharacterCategory.LOWERCASE_LETTER))) | (shl(1, Int32(UCharacterCategory.TITLECASE_LETTER))) | (shl(1, Int32(UCharacterCategory.MODIFIER_LETTER))) | (shl(1, Int32(UCharacterCategory.OTHER_LETTER))))) != 0
    }

    public static func isLetterOrDigit(ch: Int32): Bool {
        return ((shl(1, getType(ch))) & ((shl(1, Int32(UCharacterCategory.UPPERCASE_LETTER))) | (shl(1, Int32(UCharacterCategory.LOWERCASE_LETTER))) | (shl(1, Int32(UCharacterCategory.TITLECASE_LETTER))) | (shl(1, Int32(UCharacterCategory.MODIFIER_LETTER))) | (shl(1, Int32(UCharacterCategory.OTHER_LETTER))) | (shl(1, Int32(UCharacterCategory.DECIMAL_DIGIT_NUMBER))))) != 0
    }

    
    public static func isJavaLetter(cp: Int32): Bool {
        return isJavaIdentifierStart(cp)
    }

    
    public static func isJavaLetterOrDigit(cp: Int32): Bool {
        return isJavaIdentifierPart(cp)
    }

    public static func isJavaIdentifierStart(cp: Int32): Bool {
        return Character.isJavaIdentifierStart(Char(cp))
    }

    public static func isJavaIdentifierPart(cp: Int32): Bool {
        return Character.isJavaIdentifierPart(Char(cp))
    }

    public static func isLowerCase(ch: Int32): Bool {
        return getType(ch) == Int32(UCharacterCategory.LOWERCASE_LETTER)
    }

    public static func isWhitespace(ch: Int32): Bool {
        return ((shl(1, getType(ch))) & ((shl(1, Int32(UCharacterCategory.SPACE_SEPARATOR))) | (shl(1, Int32(UCharacterCategory.LINE_SEPARATOR))) | (shl(1, Int32(UCharacterCategory.PARAGRAPH_SEPARATOR))))) != 0 && (ch != NO_BREAK_SPACE_) && (ch != FIGURE_SPACE_) && (ch != NARROW_NO_BREAK_SPACE_) || (ch >= 9 && ch <= 13) || (ch >= 28 && ch <= 31)
    }

    public static func isSpaceChar(ch: Int32): Bool {
        return ((shl(1, getType(ch))) & ((shl(1, Int32(UCharacterCategory.SPACE_SEPARATOR))) | (shl(1, Int32(UCharacterCategory.LINE_SEPARATOR))) | (shl(1, Int32(UCharacterCategory.PARAGRAPH_SEPARATOR))))) != 0
    }

    public static func isTitleCase(ch: Int32): Bool {
        return getType(ch) == Int32(UCharacterCategory.TITLECASE_LETTER)
    }

    public static func isUnicodeIdentifierPart(ch: Int32): Bool {
        return hasBinaryProperty(ch, UProperty.ID_CONTINUE)
    }

    public static func isUnicodeIdentifierStart(ch: Int32): Bool {
        return hasBinaryProperty(ch, UProperty.ID_START)
    }

    public static func hasIdentifierType(c: Int32, Type: UCharacter_IdentifierType): Bool {
        return UCharacterProperty.INSTANCE.hasIDType(c, Type)
    }

    public static func getIdentifierTypes(c: Int32, types: EnumSet): Int32 {
        return UCharacterProperty.INSTANCE.getIDTypes(c, types)
    }

    public static func isIdentifierIgnorable(ch: Int32): Bool {
        if (ch <= 159) {
            return isISOControl(ch) && !((ch >= 9 && ch <= 13) || (ch >= 28 && ch <= 31))
        }
        return getType(ch) == Int32(UCharacterCategory.FORMAT)
    }

    public static func isUpperCase(ch: Int32): Bool {
        return getType(ch) == Int32(UCharacterCategory.UPPERCASE_LETTER)
    }

    public static func toLowerCase(ch: Int32): Int32 {
        return UCaseProps.INSTANCE.tolower(ch)
    }

    public static func toString(ch: Int32): String {
        if (ch < MIN_VALUE || ch > MAX_VALUE) {
            return None
        }
        if (ch < SUPPLEMENTARY_MIN_VALUE) {
            return Char(ch).toString()
        }
        return String(Character.toChars(ch))
    }

    public static func toTitleCase(ch: Int32): Int32 {
        return UCaseProps.INSTANCE.totitle(ch)
    }

    public static func toUpperCase(ch: Int32): Int32 {
        return UCaseProps.INSTANCE.toupper(ch)
    }

    public static func isSupplementary(ch: Int32): Bool {
        return ch >= UCharacter.SUPPLEMENTARY_MIN_VALUE && ch <= UCharacter.MAX_VALUE
    }

    public static func isBMP(ch: Int32): Bool {
        return (ch >= 0 && ch <= LAST_CHAR_MASK_)
    }

    public static func isPrintable(ch: Int32): Bool {
        let cat = getType(ch)
        return (cat != Int32(UCharacterCategory.UNASSIGNED) && cat != Int32(UCharacterCategory.CONTROL) && cat != Int32(UCharacterCategory.FORMAT) && cat != Int32(UCharacterCategory.PRIVATE_USE) && cat != Int32(UCharacterCategory.SURROGATE) && cat != Int32(UCharacterCategory.GENERAL_OTHER_TYPES))
    }

    public static func isBaseForm(ch: Int32): Bool {
        let cat = getType(ch)
        return cat == Int32(UCharacterCategory.DECIMAL_DIGIT_NUMBER) || cat == Int32(UCharacterCategory.OTHER_NUMBER) || cat == Int32(UCharacterCategory.LETTER_NUMBER) || cat == Int32(UCharacterCategory.UPPERCASE_LETTER) || cat == Int32(UCharacterCategory.LOWERCASE_LETTER) || cat == Int32(UCharacterCategory.TITLECASE_LETTER) || cat == Int32(UCharacterCategory.MODIFIER_LETTER) || cat == Int32(UCharacterCategory.OTHER_LETTER) || cat == Int32(UCharacterCategory.NON_SPACING_MARK) || cat == Int32(UCharacterCategory.ENCLOSING_MARK) || cat == Int32(UCharacterCategory.COMBINING_SPACING_MARK)
    }

    public static func getDirection(ch: Int32): Int32 {
        return UBiDiProps.INSTANCE.getClass(ch)
    }

    public static func isMirrored(ch: Int32): Bool {
        return UBiDiProps.INSTANCE.isMirrored(ch)
    }

    public static func getMirror(ch: Int32): Int32 {
        return UBiDiProps.INSTANCE.getMirror(ch)
    }

    public static func getBidiPairedBracket(c: Int32): Int32 {
        return UBiDiProps.INSTANCE.getPairedBracket(c)
    }

    public static func getCombiningClass(ch: Int32): Int32 {
        return Normalizer2.getNFDInstance().getCombiningClass(ch)
    }

    public static func isLegal(ch: Int32): Bool {
        if (ch < MIN_VALUE) {
            return false
        }
        if (ch < Int32(UInt32(Character.MIN_SURROGATE))) {
            return true
        }
        if (ch <= Int32(UInt32(Character.MAX_SURROGATE))) {
            return false
        }
        if (UCharacterUtility.isNonCharacter(ch)) {
            return false
        }
        return (ch <= MAX_VALUE)
    }

    public static func isLegal(str: String): Bool {
        let size = Int32(str.size)
        var codepoint: Int32 = 0
        var i = 0
        while (i < size) {
            codepoint = str.codePointAt(i)
            if (!isLegal(codepoint)) {
                return false
            }
            i += Character.charCount(codepoint)
        }
        return true
    }

    public static func getUnicodeVersion(): VersionInfo {
        return UCharacterProperty.INSTANCE.m_unicodeVersion_
    }

    public static func getName(ch: Int32): String {
        return UCharacterName.INSTANCE.getName(ch, UCharacterNameChoice.UNICODE_CHAR_NAME)
    }

    public static func getName(s: String, separator: String): String {
        if (Int32(s.size) == 1) {
            return getName(Int32(UInt32(Char(s[0]))))
        }
        var cp: Int32 = 0
        let sb = StringBuilder()
        var i = 0
        while (i < Int32(s.size)) {
            cp = s.codePointAt(i)
            if (i != 0) {
                sb.append(separator)
            }
            sb.append(UCharacter.getName(cp))
            i += Character.charCount(cp)
        }
        return sb.toString()
    }

    
    public static func getName1_0(ch: Int32): String {
        return None
    }

    public static func getExtendedName(ch: Int32): String {
        return UCharacterName.INSTANCE.getName(ch, UCharacterNameChoice.EXTENDED_CHAR_NAME)
    }

    public static func getNameAlias(ch: Int32): String {
        return UCharacterName.INSTANCE.getName(ch, UCharacterNameChoice.CHAR_NAME_ALIAS)
    }

    
    public static func getISOComment(ch: Int32): String {
        return None
    }

    public static func getCharFromName(name: String): Int32 {
        return UCharacterName.INSTANCE.getCharFromName(UCharacterNameChoice.UNICODE_CHAR_NAME, name)
    }

    
    public static func getCharFromName1_0(name: String): Int32 {
        return -1
    }

    public static func getCharFromExtendedName(name: String): Int32 {
        return UCharacterName.INSTANCE.getCharFromName(UCharacterNameChoice.EXTENDED_CHAR_NAME, name)
    }

    public static func getCharFromNameAlias(name: String): Int32 {
        return UCharacterName.INSTANCE.getCharFromName(UCharacterNameChoice.CHAR_NAME_ALIAS, name)
    }

    public static func getPropertyName(property: Int32, nameChoice: Int32): String {
        return UPropertyAliases.INSTANCE.getPropertyName(property, nameChoice)
    }

    public static func getPropertyEnum(propertyAlias: String): Int32 {
        let propEnum = UPropertyAliases.INSTANCE.getPropertyEnum(propertyAlias)
        if (propEnum == UProperty.UNDEFINED) {
            throw IllegalIcuArgumentException("Invalid name: " + (propertyAlias))
        }
        return propEnum
    }

    public static func getPropertyValueName(property: Int32, value: Int32, nameChoice: Int32): String {
        if ((property == UProperty.CANONICAL_COMBINING_CLASS || property == UProperty.LEAD_CANONICAL_COMBINING_CLASS || property == UProperty.TRAIL_CANONICAL_COMBINING_CLASS) && value >= UCharacter.getIntPropertyMinValue(UProperty.CANONICAL_COMBINING_CLASS) && value <= UCharacter.getIntPropertyMaxValue(UProperty.CANONICAL_COMBINING_CLASS) && nameChoice >= 0 && nameChoice < UProperty_NameChoice.COUNT) {
            try {
                return UPropertyAliases.INSTANCE.getPropertyValueName(property, value, nameChoice)
            } catch (e: IllegalArgumentException) {
                return None
            }
        }
        return UPropertyAliases.INSTANCE.getPropertyValueName(property, value, nameChoice)
    }

    public static func getPropertyValueEnum(property: Int32, valueAlias: String): Int32 {
        let propEnum = UPropertyAliases.INSTANCE.getPropertyValueEnum(property, valueAlias)
        if (propEnum == UProperty.UNDEFINED) {
            throw IllegalIcuArgumentException("Invalid name: " + (valueAlias))
        }
        return propEnum
    }

    
    public static func getPropertyValueEnumNoThrow(property: Int32, valueAlias: String): Int32 {
        return UPropertyAliases.INSTANCE.getPropertyValueEnumNoThrow(property, valueAlias)
    }

    public static func getCodePoint(lead: Int32, trail: Int32): Int32 {
        if (isHighSurrogate(lead) && isLowSurrogate(trail)) {
            return toCodePoint(lead, trail)
        }
        throw IllegalArgumentException("Not a valid surrogate pair")
    }

    public static func getCodePoint(char16: Char): Int32 {
        if (UCharacter.isLegal(Int32(UInt32(char16)))) {
            return Int32(UInt32(char16))
        }
        throw IllegalArgumentException("Illegal codepoint")
    }

    public static func toUpperCase(str: String): String {
        return CaseMapImpl.toUpper(getDefaultCaseLocale(), 0, str)
    }

    public static func toLowerCase(str: String): String {
        return CaseMapImpl.toLower(getDefaultCaseLocale(), 0, str)
    }

    public static func toTitleCase(str: String, breakiter: BreakIterator): String {
        return toTitleCase(Locale.getDefault(), str, breakiter, 0)
    }

    private static func getDefaultCaseLocale(): Int32 {
        return UCaseProps.getCaseLocale(Locale.getDefault())
    }

    private static func getCaseLocale(locale: Locale): Int32 {
        var templocale = locale
        if (templocale.isNone()) {
            templocale = Locale.getDefault()
        }
        return UCaseProps.getCaseLocale(templocale)
    }

    private static func getCaseLocale(locale: ULocale): Int32 {
        var templocale = locale
        if (templocale.isNone()) {
            templocale = ULocale.getDefault()
        }
        return UCaseProps.getCaseLocale(templocale)
    }

    public static func toUpperCase(locale: Locale, str: String): String {
        return CaseMapImpl.toUpper(getCaseLocale(locale), 0, str)
    }

    public static func toUpperCase(locale: ULocale, str: String): String {
        return CaseMapImpl.toUpper(getCaseLocale(locale), 0, str)
    }

    public static func toLowerCase(locale: Locale, str: String): String {
        return CaseMapImpl.toLower(getCaseLocale(locale), 0, str)
    }

    public static func toLowerCase(locale: ULocale, str: String): String {
        return CaseMapImpl.toLower(getCaseLocale(locale), 0, str)
    }

    public static func toTitleCase(locale: Locale, str: String, breakiter: BreakIterator): String {
        return toTitleCase(locale, str, breakiter, 0)
    }

    public static func toTitleCase(locale: ULocale, str: String, titleIter: BreakIterator): String {
        return toTitleCase(locale, str, titleIter, 0)
    }

    public static func toTitleCase(locale: ULocale, str: String, titleIter: BreakIterator, options: Int32): String {
        var templocale = locale
        var temptitleIter = titleIter
        if (temptitleIter.isNone() && templocale.isNone()) {
            templocale = ULocale.getDefault()
        }
        temptitleIter = CaseMapImpl.getTitleBreakIterator(templocale, options, temptitleIter)
        temptitleIter.setText(str)
        return CaseMapImpl.toTitle(getCaseLocale(templocale), options, temptitleIter, str)
    }

    public static func toTitleCase(locale: Locale, str: String, titleIter: BreakIterator, options: Int32): String {
        var templocale = locale
        var temptitleIter = titleIter
        if (temptitleIter.isNone() && templocale.isNone()) {
            templocale = Locale.getDefault()
        }
        temptitleIter = CaseMapImpl.getTitleBreakIterator(templocale, options, temptitleIter)
        temptitleIter.setText(str)
        return CaseMapImpl.toTitle(getCaseLocale(templocale), options, temptitleIter, str)
    }

    public static func foldCase(ch: Int32, defaultmapping: Bool): Int32 {
        return foldCase(ch, if (defaultmapping) { FOLD_CASE_DEFAULT } else { FOLD_CASE_EXCLUDE_SPECIAL_I })
    }

    public static func foldCase(str: String, defaultmapping: Bool): String {
        return foldCase(str, if (defaultmapping) { FOLD_CASE_DEFAULT } else { FOLD_CASE_EXCLUDE_SPECIAL_I })
    }

    public static let FOLD_CASE_DEFAULT = 0

    public static let FOLD_CASE_EXCLUDE_SPECIAL_I = 1

    public static func foldCase(ch: Int32, options: Int32): Int32 {
        return UCaseProps.INSTANCE.fold(ch, options)
    }

    public static func foldCase(str: String, options: Int32): String {
        return CaseMapImpl.fold(options, str)
    }

    public static func getHanNumericValue(ch: Int32): Int32 {
        match (ch) {
            case 12295 | 38646 => return 0
            case 19968 | 22777 => return 1
            case 20108 | 36019 => return 2
            case 19977 | 21443 => return 3
            case 22235 | 32902 => return 4
            case 20116 | 20237 => return 5
            case 20845 | 38520 => return 6
            case 19971 | 26578 => return 7
            case 20843 | 25420 => return 8
            case 20061 | 29590 => return 9
            case 21313 | 25342 => return 10
            case 30334 | 20336 => return 100
            case 21315 | 20191 => return 1000
            case 33356 => return 10000
            case 20740 => return 100000000
            case _ => ()
        }
        return -1
    }

    public static func getTypeIterator(): RangeValueIterator {
        return UCharacter_UCharacterTypeIterator()
    }

    public static func getNameIterator(): ValueIterator {
        return UCharacterNameIterator(UCharacterName.INSTANCE, UCharacterNameChoice.UNICODE_CHAR_NAME)
    }

    
    public static func getName1_0Iterator(): ValueIterator {
        return UCharacter_DummyValueIterator()
    }

    public static func getExtendedNameIterator(): ValueIterator {
        return UCharacterNameIterator(UCharacterName.INSTANCE, UCharacterNameChoice.EXTENDED_CHAR_NAME)
    }

    public static func getAge(ch: Int32): VersionInfo {
        if (ch < MIN_VALUE || ch > MAX_VALUE) {
            throw IllegalArgumentException("Codepoint out of bounds")
        }
        return UCharacterProperty.INSTANCE.getAge(ch)
    }

    public static func hasBinaryProperty(ch: Int32, property: Int32): Bool {
        return UCharacterProperty.INSTANCE.hasBinaryProperty(ch, property)
    }

    public static func hasBinaryProperty(s: String, property: Int32): Bool {
        let length = s.size
        if (length == 1) {
            return hasBinaryProperty(Int32(UInt32(s[0])), property)
        } else if (length == 2) {
            let c = Character.codePointAt(s, 0)
            if (Character.charCount(c) == length) {
                return hasBinaryProperty(c, property)
            }
        }
        return UProperty.BASIC_EMOJI <= property && property <= UProperty.RGI_EMOJI && EmojiProps.INSTANCE.hasBinaryProperty(s, property)
    }

    public static func isUAlphabetic(ch: Int32): Bool {
        return hasBinaryProperty(ch, UProperty.ALPHABETIC)
    }

    public static func isULowercase(ch: Int32): Bool {
        return hasBinaryProperty(ch, UProperty.LOWERCASE)
    }

    public static func isUUppercase(ch: Int32): Bool {
        return hasBinaryProperty(ch, UProperty.UPPERCASE)
    }

    public static func isUWhiteSpace(ch: Int32): Bool {
        return hasBinaryProperty(ch, UProperty.WHITE_SPACE)
    }

    public static func getIntPropertyValue(ch: Int32, Type: Int32): Int32 {
        return UCharacterProperty.INSTANCE.getIntPropertyValue(ch, Type)
    }

    
    public static func getStringPropertyValue(propertyEnum: Int32, codepoint: Int32, nameChoice: Int32): String {
        if ((propertyEnum >= UProperty.BINARY_START && propertyEnum < UProperty.BINARY_LIMIT) || (propertyEnum >= UProperty.INT_START && propertyEnum < UProperty.INT_LIMIT)) {
            return getPropertyValueName(propertyEnum, getIntPropertyValue(codepoint, propertyEnum), nameChoice)
        }
        if (propertyEnum == UProperty.NUMERIC_VALUE) {
            return getUnicodeNumericValue(codepoint).toString()
        }
        match (propertyEnum) {
            case 16384 => return getAge(codepoint).toString()
            case 16387 => return getISOComment(codepoint)
            case 16385 => return toString(getMirror(codepoint))
            case 16386 => return toString(foldCase(codepoint, true))
            case 16388 => return toString(toLowerCase(codepoint))
            case 16389 => return getName(codepoint)
            case 16390 => return toString(foldCase(codepoint, true))
            case 16391 => return toString(toLowerCase(codepoint))
            case 16392 => return toString(toTitleCase(codepoint))
            case 16393 => return toString(toUpperCase(codepoint))
            case 16394 => return toString(toTitleCase(codepoint))
            case 16395 => return getName1_0(codepoint)
            case 16396 => return toString(toUpperCase(codepoint))
            case _ => ()
        }
        throw IllegalArgumentException("Illegal Property Enum")
    }

    public static func getIntPropertyMinValue(Type: Int32): Int32 {
        return 0
    }

    public static func getIntPropertyMaxValue(Type: Int32): Int32 {
        return UCharacterProperty.INSTANCE.getIntPropertyMaxValue(Type)
    }

    public static func forDigit(digit: Int32, radix: Int32): Char {
        return Character.forDigit(digit, radix)
    }

    public static let MIN_HIGH_SURROGATE = Character.MIN_HIGH_SURROGATE

    public static let MAX_HIGH_SURROGATE = Character.MAX_HIGH_SURROGATE

    public static let MIN_LOW_SURROGATE = Character.MIN_LOW_SURROGATE

    public static let MAX_LOW_SURROGATE = Character.MAX_LOW_SURROGATE

    public static let MIN_SURROGATE = Character.MIN_SURROGATE

    public static let MAX_SURROGATE = Character.MAX_SURROGATE

    public static let MIN_SUPPLEMENTARY_CODE_POINT = Character.MIN_SUPPLEMENTARY_CODE_POINT

    public static let MAX_CODE_POINT = Character.MAX_CODE_POINT

    public static let MIN_CODE_POINT = Character.MIN_CODE_POINT

    public static func isValidCodePoint(cp: Int32): Bool {
        return cp >= 0 && cp <= MAX_CODE_POINT
    }

    public static func isSupplementaryCodePoint(cp: Int32): Bool {
        return Character.isSupplementaryCodePoint(cp)
    }

    public static func isHighSurrogate(codePoint: Int32): Bool {
        return (codePoint & LEAD_SURROGATE_BITMASK) == LEAD_SURROGATE_BITS
    }

    public static func isLowSurrogate(codePoint: Int32): Bool {
        return (codePoint & TRAIL_SURROGATE_BITMASK) == TRAIL_SURROGATE_BITS
    }

    public static func isSurrogatePair(high: Int32, low: Int32): Bool {
        return isHighSurrogate(high) && isLowSurrogate(low)
    }

    public static func charCount(cp: Int32): Int32 {
        return Character.charCount(cp)
    }

    public static func toCodePoint(high: Int32, low: Int32): Int32 {
        return (shl(high, 10)) + low - U16_SURROGATE_OFFSET
    }

    public static func codePointAt(seq: String, index: Int32): Int32 {
        var tempindex = index
        let c1 = seq[match (0] { case _ => tempindex++; tempindex - 1 })
        if (isHighSurrogate(Int32(UInt32(c1)))) {
            if (tempindex < seq.size) {
                let c2 = seq[tempindex]
                if (isLowSurrogate(Int32(UInt32(c2)))) {
                    return toCodePoint(Int32(UInt32(c1)), Int32(UInt32(c2)))
                }
            }
        }
        return Int32(UInt32(c1))
    }

    public static func codePointAt(text: Array<Char>, index: Int32): Int32 {
        var tempindex = index
        let c1 = text[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]
        if (isHighSurrogate(Int32(UInt32(c1)))) {
            if (tempindex < Int32(text.size)) {
                let c2 = text[Int64(tempindex)]
                if (isLowSurrogate(Int32(UInt32(c2)))) {
                    return toCodePoint(Int32(UInt32(c1)), Int32(UInt32(c2)))
                }
            }
        }
        return Int32(UInt32(c1))
    }

    public static func codePointAt(text: Array<Char>, index: Int32, limit: Int32): Int32 {
        var tempindex = index
        if (tempindex >= limit || limit > Int32(text.size)) {
            throw IndexOutOfBoundsException()
        }
        let c1 = text[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]
        if (isHighSurrogate(Int32(UInt32(c1)))) {
            if (tempindex < limit) {
                let c2 = text[Int64(tempindex)]
                if (isLowSurrogate(Int32(UInt32(c2)))) {
                    return toCodePoint(Int32(UInt32(c1)), Int32(UInt32(c2)))
                }
            }
        }
        return Int32(UInt32(c1))
    }

    public static func codePointBefore(seq: String, index: Int32): Int32 {
        var tempindex = index
        let c2 = seq[match (0] { case _ => tempindex--; tempindex })
        if (isLowSurrogate(Int32(UInt32(c2)))) {
            if (tempindex > 0) {
                let c1 = seq[match (0] { case _ => tempindex--; tempindex })
                if (isHighSurrogate(Int32(UInt32(c1)))) {
                    return toCodePoint(Int32(UInt32(c1)), Int32(UInt32(c2)))
                }
            }
        }
        return Int32(UInt32(c2))
    }

    public static func codePointBefore(text: Array<Char>, index: Int32): Int32 {
        var tempindex = index
        let c2 = text[Int64(match (0) { case _ => tempindex--; tempindex })]
        if (isLowSurrogate(Int32(UInt32(c2)))) {
            if (tempindex > 0) {
                let c1 = text[Int64(match (0) { case _ => tempindex--; tempindex })]
                if (isHighSurrogate(Int32(UInt32(c1)))) {
                    return toCodePoint(Int32(UInt32(c1)), Int32(UInt32(c2)))
                }
            }
        }
        return Int32(UInt32(c2))
    }

    public static func codePointBefore(text: Array<Char>, index: Int32, limit: Int32): Int32 {
        var tempindex = index
        if (tempindex <= limit || limit < 0) {
            throw IndexOutOfBoundsException()
        }
        let c2 = text[Int64(match (0) { case _ => tempindex--; tempindex })]
        if (isLowSurrogate(Int32(UInt32(c2)))) {
            if (tempindex > limit) {
                let c1 = text[Int64(match (0) { case _ => tempindex--; tempindex })]
                if (isHighSurrogate(Int32(UInt32(c1)))) {
                    return toCodePoint(Int32(UInt32(c1)), Int32(UInt32(c2)))
                }
            }
        }
        return Int32(UInt32(c2))
    }

    public static func toChars(cp: Int32, dst: Array<Char>, dstIndex: Int32): Int32 {
        return Character.toChars(cp, dst, dstIndex)
    }

    public static func toChars(cp: Int32): Array<Char> {
        return Character.toChars(cp)
    }

    public static func getDirectionality(cp: Int32): UInt8 {
        return UInt8(getDirection(cp))
    }

    public static func codePointCount(text: String, start: Int32, limit: Int32): Int32 {
        var templimit = limit
        if (start < 0 || templimit < start || templimit > text.size) {
            throw IndexOutOfBoundsException("start (" + start.toString() + ") or limit (" + templimit.toString() + ") invalid or out of range 0, " + text.size.toString())
        }
        var len = templimit - start
        while (templimit > start) {
            var ch = text[match (0] { case _ => templimit--; templimit })
            while (ch >= MIN_LOW_SURROGATE && ch <= MAX_LOW_SURROGATE && templimit > start) {
                ch = text[match (0] { case _ => templimit--; templimit })
                if (ch >= MIN_HIGH_SURROGATE && ch <= MAX_HIGH_SURROGATE) {
                    len--
                    break
                }
            }
        }
        return len
    }

    public static func codePointCount(text: Array<Char>, start: Int32, limit: Int32): Int32 {
        var templimit = limit
        if (start < 0 || templimit < start || templimit > Int32(text.size)) {
            throw IndexOutOfBoundsException("start (" + start.toString() + ") or limit (" + templimit.toString() + ") invalid or out of range 0, " + Int32(text.size).toString())
        }
        var len = templimit - start
        while (templimit > start) {
            var ch = text[Int64(match (0) { case _ => templimit--; templimit })]
            while (ch >= MIN_LOW_SURROGATE && ch <= MAX_LOW_SURROGATE && templimit > start) {
                ch = text[Int64(match (0) { case _ => templimit--; templimit })]
                if (ch >= MIN_HIGH_SURROGATE && ch <= MAX_HIGH_SURROGATE) {
                    len--
                    break
                }
            }
        }
        return len
    }

    public static func offsetByCodePoints(text: String, index: Int32, codePointOffset: Int32): Int32 {
        var tempcodePointOffset = codePointOffset
        var tempindex = index
        if (tempindex < 0 || tempindex > text.size) {
            throw IndexOutOfBoundsException("index ( " + tempindex.toString() + ") out of range 0, " + text.size.toString())
        }
        if (tempcodePointOffset < 0) {
            while (match (0) { case _ => tempcodePointOffset++; tempcodePointOffset } <= 0) {
                var ch = text[match (0] { case _ => tempindex--; tempindex })
                while (ch >= MIN_LOW_SURROGATE && ch <= MAX_LOW_SURROGATE && tempindex > 0) {
                    ch = text[match (0] { case _ => tempindex--; tempindex })
                    if (ch < MIN_HIGH_SURROGATE || ch > MAX_HIGH_SURROGATE) {
                        if (match (0) { case _ => tempcodePointOffset++; tempcodePointOffset } > 0) {
                            return tempindex + 1
                        }
                    }
                }
            }
        } else {
            let limit = text.size
            while (match (0) { case _ => tempcodePointOffset--; tempcodePointOffset } >= 0) {
                var ch = text[match (0] { case _ => tempindex++; tempindex - 1 })
                while (ch >= MIN_HIGH_SURROGATE && ch <= MAX_HIGH_SURROGATE && tempindex < limit) {
                    ch = text[match (0] { case _ => tempindex++; tempindex - 1 })
                    if (ch < MIN_LOW_SURROGATE || ch > MAX_LOW_SURROGATE) {
                        if (match (0) { case _ => tempcodePointOffset--; tempcodePointOffset } < 0) {
                            return tempindex - 1
                        }
                    }
                }
            }
        }
        return tempindex
    }

    public static func offsetByCodePoints(text: Array<Char>, start: Int32, count: Int32, index: Int32, codePointOffset: Int32): Int32 {
        var tempcodePointOffset = codePointOffset
        var tempindex = index
        let limit = start + count
        if (start < 0 || limit < start || limit > Int32(text.size) || tempindex < start || tempindex > limit) {
            throw IndexOutOfBoundsException("index ( " + tempindex.toString() + ") out of range " + start.toString() + ", " + limit.toString() + " in array 0, " + Int32(text.size).toString())
        }
        if (tempcodePointOffset < 0) {
            while (match (0) { case _ => tempcodePointOffset++; tempcodePointOffset } <= 0) {
                var ch = text[Int64(match (0) { case _ => tempindex--; tempindex })]
                if (tempindex < start) {
                    throw IndexOutOfBoundsException("index ( " + tempindex.toString() + ") < start (" + start.toString() + ")")
                }
                while (ch >= MIN_LOW_SURROGATE && ch <= MAX_LOW_SURROGATE && tempindex > start) {
                    ch = text[Int64(match (0) { case _ => tempindex--; tempindex })]
                    if (ch < MIN_HIGH_SURROGATE || ch > MAX_HIGH_SURROGATE) {
                        if (match (0) { case _ => tempcodePointOffset++; tempcodePointOffset } > 0) {
                            return tempindex + 1
                        }
                    }
                }
            }
        } else {
            while (match (0) { case _ => tempcodePointOffset--; tempcodePointOffset } >= 0) {
                var ch = text[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]
                if (tempindex > limit) {
                    throw IndexOutOfBoundsException("index ( " + tempindex.toString() + ") > limit (" + limit.toString() + ")")
                }
                while (ch >= MIN_HIGH_SURROGATE && ch <= MAX_HIGH_SURROGATE && tempindex < limit) {
                    ch = text[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]
                    if (ch < MIN_LOW_SURROGATE || ch > MAX_LOW_SURROGATE) {
                        if (match (0) { case _ => tempcodePointOffset--; tempcodePointOffset } < 0) {
                            return tempindex - 1
                        }
                    }
                }
            }
        }
        return tempindex
    }

    private static let LAST_CHAR_MASK_ = 65535

    private static let NO_BREAK_SPACE_ = 160

    private static let FIGURE_SPACE_ = 8199

    private static let NARROW_NO_BREAK_SPACE_ = 8239

    private static let IDEOGRAPHIC_NUMBER_ZERO_ = 12295

    private static let CJK_IDEOGRAPH_FIRST_ = 19968

    private static let CJK_IDEOGRAPH_SECOND_ = 20108

    private static let CJK_IDEOGRAPH_THIRD_ = 19977

    private static let CJK_IDEOGRAPH_FOURTH_ = 22235

    private static let CJK_IDEOGRAPH_FIFTH_ = 20116

    private static let CJK_IDEOGRAPH_SIXTH_ = 20845

    private static let CJK_IDEOGRAPH_SEVENTH_ = 19971

    private static let CJK_IDEOGRAPH_EIGHTH_ = 20843

    private static let CJK_IDEOGRAPH_NINETH_ = 20061

    private static let APPLICATION_PROGRAM_COMMAND_ = 159

    private static let UNIT_SEPARATOR_ = 31

    private static let DELETE_ = 127

    private static let CJK_IDEOGRAPH_COMPLEX_ZERO_ = 38646

    private static let CJK_IDEOGRAPH_COMPLEX_ONE_ = 22777

    private static let CJK_IDEOGRAPH_COMPLEX_TWO_ = 36019

    private static let CJK_IDEOGRAPH_COMPLEX_THREE_ = 21443

    private static let CJK_IDEOGRAPH_COMPLEX_FOUR_ = 32902

    private static let CJK_IDEOGRAPH_COMPLEX_FIVE_ = 20237

    private static let CJK_IDEOGRAPH_COMPLEX_SIX_ = 38520

    private static let CJK_IDEOGRAPH_COMPLEX_SEVEN_ = 26578

    private static let CJK_IDEOGRAPH_COMPLEX_EIGHT_ = 25420

    private static let CJK_IDEOGRAPH_COMPLEX_NINE_ = 29590

    private static let CJK_IDEOGRAPH_TEN_ = 21313

    private static let CJK_IDEOGRAPH_COMPLEX_TEN_ = 25342

    private static let CJK_IDEOGRAPH_HUNDRED_ = 30334

    private static let CJK_IDEOGRAPH_COMPLEX_HUNDRED_ = 20336

    private static let CJK_IDEOGRAPH_THOUSAND_ = 21315

    private static let CJK_IDEOGRAPH_COMPLEX_THOUSAND_ = 20191

    private static let CJK_IDEOGRAPH_TEN_THOUSAND_ = 33356

    private static let CJK_IDEOGRAPH_HUNDRED_MILLION_ = 20740

}


public class UCharacter_UnicodeBlock <: Character_Subset {
    public static let INVALID_CODE_ID = -1

    public static let BASIC_LATIN_ID = 1

    public static let LATIN_1_SUPPLEMENT_ID = 2

    public static let LATIN_EXTENDED_A_ID = 3

    public static let LATIN_EXTENDED_B_ID = 4

    public static let IPA_EXTENSIONS_ID = 5

    public static let SPACING_MODIFIER_LETTERS_ID = 6

    public static let COMBINING_DIACRITICAL_MARKS_ID = 7

    public static let GREEK_ID = 8

    public static let CYRILLIC_ID = 9

    public static let ARMENIAN_ID = 10

    public static let HEBREW_ID = 11

    public static let ARABIC_ID = 12

    public static let SYRIAC_ID = 13

    public static let THAANA_ID = 14

    public static let DEVANAGARI_ID = 15

    public static let BENGALI_ID = 16

    public static let GURMUKHI_ID = 17

    public static let GUJARATI_ID = 18

    public static let ORIYA_ID = 19

    public static let TAMIL_ID = 20

    public static let TELUGU_ID = 21

    public static let KANNADA_ID = 22

    public static let MALAYALAM_ID = 23

    public static let SINHALA_ID = 24

    public static let THAI_ID = 25

    public static let LAO_ID = 26

    public static let TIBETAN_ID = 27

    public static let MYANMAR_ID = 28

    public static let GEORGIAN_ID = 29

    public static let HANGUL_JAMO_ID = 30

    public static let ETHIOPIC_ID = 31

    public static let CHEROKEE_ID = 32

    public static let UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS_ID = 33

    public static let OGHAM_ID = 34

    public static let RUNIC_ID = 35

    public static let KHMER_ID = 36

    public static let MONGOLIAN_ID = 37

    public static let LATIN_EXTENDED_ADDITIONAL_ID = 38

    public static let GREEK_EXTENDED_ID = 39

    public static let GENERAL_PUNCTUATION_ID = 40

    public static let SUPERSCRIPTS_AND_SUBSCRIPTS_ID = 41

    public static let CURRENCY_SYMBOLS_ID = 42

    public static let COMBINING_MARKS_FOR_SYMBOLS_ID = 43

    public static let LETTERLIKE_SYMBOLS_ID = 44

    public static let NUMBER_FORMS_ID = 45

    public static let ARROWS_ID = 46

    public static let MATHEMATICAL_OPERATORS_ID = 47

    public static let MISCELLANEOUS_TECHNICAL_ID = 48

    public static let CONTROL_PICTURES_ID = 49

    public static let OPTICAL_CHARACTER_RECOGNITION_ID = 50

    public static let ENCLOSED_ALPHANUMERICS_ID = 51

    public static let BOX_DRAWING_ID = 52

    public static let BLOCK_ELEMENTS_ID = 53

    public static let GEOMETRIC_SHAPES_ID = 54

    public static let MISCELLANEOUS_SYMBOLS_ID = 55

    public static let DINGBATS_ID = 56

    public static let BRAILLE_PATTERNS_ID = 57

    public static let CJK_RADICALS_SUPPLEMENT_ID = 58

    public static let KANGXI_RADICALS_ID = 59

    public static let IDEOGRAPHIC_DESCRIPTION_CHARACTERS_ID = 60

    public static let CJK_SYMBOLS_AND_PUNCTUATION_ID = 61

    public static let HIRAGANA_ID = 62

    public static let KATAKANA_ID = 63

    public static let BOPOMOFO_ID = 64

    public static let HANGUL_COMPATIBILITY_JAMO_ID = 65

    public static let KANBUN_ID = 66

    public static let BOPOMOFO_EXTENDED_ID = 67

    public static let ENCLOSED_CJK_LETTERS_AND_MONTHS_ID = 68

    public static let CJK_COMPATIBILITY_ID = 69

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A_ID = 70

    public static let CJK_UNIFIED_IDEOGRAPHS_ID = 71

    public static let YI_SYLLABLES_ID = 72

    public static let YI_RADICALS_ID = 73

    public static let HANGUL_SYLLABLES_ID = 74

    public static let HIGH_SURROGATES_ID = 75

    public static let HIGH_PRIVATE_USE_SURROGATES_ID = 76

    public static let LOW_SURROGATES_ID = 77

    public static let PRIVATE_USE_AREA_ID = 78

    public static let PRIVATE_USE_ID = PRIVATE_USE_AREA_ID

    public static let CJK_COMPATIBILITY_IDEOGRAPHS_ID = 79

    public static let ALPHABETIC_PRESENTATION_FORMS_ID = 80

    public static let ARABIC_PRESENTATION_FORMS_A_ID = 81

    public static let COMBINING_HALF_MARKS_ID = 82

    public static let CJK_COMPATIBILITY_FORMS_ID = 83

    public static let SMALL_FORM_VARIANTS_ID = 84

    public static let ARABIC_PRESENTATION_FORMS_B_ID = 85

    public static let SPECIALS_ID = 86

    public static let HALFWIDTH_AND_FULLWIDTH_FORMS_ID = 87

    public static let OLD_ITALIC_ID = 88

    public static let GOTHIC_ID = 89

    public static let DESERET_ID = 90

    public static let BYZANTINE_MUSICAL_SYMBOLS_ID = 91

    public static let MUSICAL_SYMBOLS_ID = 92

    public static let MATHEMATICAL_ALPHANUMERIC_SYMBOLS_ID = 93

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_B_ID = 94

    public static let CJK_COMPATIBILITY_IDEOGRAPHS_SUPPLEMENT_ID = 95

    public static let TAGS_ID = 96

    public static let CYRILLIC_SUPPLEMENTARY_ID = 97

    public static let CYRILLIC_SUPPLEMENT_ID = 97

    public static let TAGALOG_ID = 98

    public static let HANUNOO_ID = 99

    public static let BUHID_ID = 100

    public static let TAGBANWA_ID = 101

    public static let MISCELLANEOUS_MATHEMATICAL_SYMBOLS_A_ID = 102

    public static let SUPPLEMENTAL_ARROWS_A_ID = 103

    public static let SUPPLEMENTAL_ARROWS_B_ID = 104

    public static let MISCELLANEOUS_MATHEMATICAL_SYMBOLS_B_ID = 105

    public static let SUPPLEMENTAL_MATHEMATICAL_OPERATORS_ID = 106

    public static let KATAKANA_PHONETIC_EXTENSIONS_ID = 107

    public static let VARIATION_SELECTORS_ID = 108

    public static let SUPPLEMENTARY_PRIVATE_USE_AREA_A_ID = 109

    public static let SUPPLEMENTARY_PRIVATE_USE_AREA_B_ID = 110

    public static let LIMBU_ID = 111

    public static let TAI_LE_ID = 112

    public static let KHMER_SYMBOLS_ID = 113

    public static let PHONETIC_EXTENSIONS_ID = 114

    public static let MISCELLANEOUS_SYMBOLS_AND_ARROWS_ID = 115

    public static let YIJING_HEXAGRAM_SYMBOLS_ID = 116

    public static let LINEAR_B_SYLLABARY_ID = 117

    public static let LINEAR_B_IDEOGRAMS_ID = 118

    public static let AEGEAN_NUMBERS_ID = 119

    public static let UGARITIC_ID = 120

    public static let SHAVIAN_ID = 121

    public static let OSMANYA_ID = 122

    public static let CYPRIOT_SYLLABARY_ID = 123

    public static let TAI_XUAN_JING_SYMBOLS_ID = 124

    public static let VARIATION_SELECTORS_SUPPLEMENT_ID = 125

    public static let ANCIENT_GREEK_MUSICAL_NOTATION_ID = 126

    public static let ANCIENT_GREEK_NUMBERS_ID = 127

    public static let ARABIC_SUPPLEMENT_ID = 128

    public static let BUGINESE_ID = 129

    public static let CJK_STROKES_ID = 130

    public static let COMBINING_DIACRITICAL_MARKS_SUPPLEMENT_ID = 131

    public static let COPTIC_ID = 132

    public static let ETHIOPIC_EXTENDED_ID = 133

    public static let ETHIOPIC_SUPPLEMENT_ID = 134

    public static let GEORGIAN_SUPPLEMENT_ID = 135

    public static let GLAGOLITIC_ID = 136

    public static let KHAROSHTHI_ID = 137

    public static let MODIFIER_TONE_LETTERS_ID = 138

    public static let NEW_TAI_LUE_ID = 139

    public static let OLD_PERSIAN_ID = 140

    public static let PHONETIC_EXTENSIONS_SUPPLEMENT_ID = 141

    public static let SUPPLEMENTAL_PUNCTUATION_ID = 142

    public static let SYLOTI_NAGRI_ID = 143

    public static let TIFINAGH_ID = 144

    public static let VERTICAL_FORMS_ID = 145

    public static let NKO_ID = 146

    public static let BALINESE_ID = 147

    public static let LATIN_EXTENDED_C_ID = 148

    public static let LATIN_EXTENDED_D_ID = 149

    public static let PHAGS_PA_ID = 150

    public static let PHOENICIAN_ID = 151

    public static let CUNEIFORM_ID = 152

    public static let CUNEIFORM_NUMBERS_AND_PUNCTUATION_ID = 153

    public static let COUNTING_ROD_NUMERALS_ID = 154

    public static let SUNDANESE_ID = 155

    public static let LEPCHA_ID = 156

    public static let OL_CHIKI_ID = 157

    public static let CYRILLIC_EXTENDED_A_ID = 158

    public static let VAI_ID = 159

    public static let CYRILLIC_EXTENDED_B_ID = 160

    public static let SAURASHTRA_ID = 161

    public static let KAYAH_LI_ID = 162

    public static let REJANG_ID = 163

    public static let CHAM_ID = 164

    public static let ANCIENT_SYMBOLS_ID = 165

    public static let PHAISTOS_DISC_ID = 166

    public static let LYCIAN_ID = 167

    public static let CARIAN_ID = 168

    public static let LYDIAN_ID = 169

    public static let MAHJONG_TILES_ID = 170

    public static let DOMINO_TILES_ID = 171

    public static let SAMARITAN_ID = 172

    public static let UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS_EXTENDED_ID = 173

    public static let TAI_THAM_ID = 174

    public static let VEDIC_EXTENSIONS_ID = 175

    public static let LISU_ID = 176

    public static let BAMUM_ID = 177

    public static let COMMON_INDIC_NUMBER_FORMS_ID = 178

    public static let DEVANAGARI_EXTENDED_ID = 179

    public static let HANGUL_JAMO_EXTENDED_A_ID = 180

    public static let JAVANESE_ID = 181

    public static let MYANMAR_EXTENDED_A_ID = 182

    public static let TAI_VIET_ID = 183

    public static let MEETEI_MAYEK_ID = 184

    public static let HANGUL_JAMO_EXTENDED_B_ID = 185

    public static let IMPERIAL_ARAMAIC_ID = 186

    public static let OLD_SOUTH_ARABIAN_ID = 187

    public static let AVESTAN_ID = 188

    public static let INSCRIPTIONAL_PARTHIAN_ID = 189

    public static let INSCRIPTIONAL_PAHLAVI_ID = 190

    public static let OLD_TURKIC_ID = 191

    public static let RUMI_NUMERAL_SYMBOLS_ID = 192

    public static let KAITHI_ID = 193

    public static let EGYPTIAN_HIEROGLYPHS_ID = 194

    public static let ENCLOSED_ALPHANUMERIC_SUPPLEMENT_ID = 195

    public static let ENCLOSED_IDEOGRAPHIC_SUPPLEMENT_ID = 196

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_C_ID = 197

    public static let MANDAIC_ID = 198

    public static let BATAK_ID = 199

    public static let ETHIOPIC_EXTENDED_A_ID = 200

    public static let BRAHMI_ID = 201

    public static let BAMUM_SUPPLEMENT_ID = 202

    public static let KANA_SUPPLEMENT_ID = 203

    public static let PLAYING_CARDS_ID = 204

    public static let MISCELLANEOUS_SYMBOLS_AND_PICTOGRAPHS_ID = 205

    public static let EMOTICONS_ID = 206

    public static let TRANSPORT_AND_MAP_SYMBOLS_ID = 207

    public static let ALCHEMICAL_SYMBOLS_ID = 208

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_D_ID = 209

    public static let ARABIC_EXTENDED_A_ID = 210

    public static let ARABIC_MATHEMATICAL_ALPHABETIC_SYMBOLS_ID = 211

    public static let CHAKMA_ID = 212

    public static let MEETEI_MAYEK_EXTENSIONS_ID = 213

    public static let MEROITIC_CURSIVE_ID = 214

    public static let MEROITIC_HIEROGLYPHS_ID = 215

    public static let MIAO_ID = 216

    public static let SHARADA_ID = 217

    public static let SORA_SOMPENG_ID = 218

    public static let SUNDANESE_SUPPLEMENT_ID = 219

    public static let TAKRI_ID = 220

    public static let BASSA_VAH_ID = 221

    public static let CAUCASIAN_ALBANIAN_ID = 222

    public static let COPTIC_EPACT_NUMBERS_ID = 223

    public static let COMBINING_DIACRITICAL_MARKS_EXTENDED_ID = 224

    public static let DUPLOYAN_ID = 225

    public static let ELBASAN_ID = 226

    public static let GEOMETRIC_SHAPES_EXTENDED_ID = 227

    public static let GRANTHA_ID = 228

    public static let KHOJKI_ID = 229

    public static let KHUDAWADI_ID = 230

    public static let LATIN_EXTENDED_E_ID = 231

    public static let LINEAR_A_ID = 232

    public static let MAHAJANI_ID = 233

    public static let MANICHAEAN_ID = 234

    public static let MENDE_KIKAKUI_ID = 235

    public static let MODI_ID = 236

    public static let MRO_ID = 237

    public static let MYANMAR_EXTENDED_B_ID = 238

    public static let NABATAEAN_ID = 239

    public static let OLD_NORTH_ARABIAN_ID = 240

    public static let OLD_PERMIC_ID = 241

    public static let ORNAMENTAL_DINGBATS_ID = 242

    public static let PAHAWH_HMONG_ID = 243

    public static let PALMYRENE_ID = 244

    public static let PAU_CIN_HAU_ID = 245

    public static let PSALTER_PAHLAVI_ID = 246

    public static let SHORTHAND_FORMAT_CONTROLS_ID = 247

    public static let SIDDHAM_ID = 248

    public static let SINHALA_ARCHAIC_NUMBERS_ID = 249

    public static let SUPPLEMENTAL_ARROWS_C_ID = 250

    public static let TIRHUTA_ID = 251

    public static let WARANG_CITI_ID = 252

    public static let AHOM_ID = 253

    public static let ANATOLIAN_HIEROGLYPHS_ID = 254

    public static let CHEROKEE_SUPPLEMENT_ID = 255

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_E_ID = 256

    public static let EARLY_DYNASTIC_CUNEIFORM_ID = 257

    public static let HATRAN_ID = 258

    public static let MULTANI_ID = 259

    public static let OLD_HUNGARIAN_ID = 260

    public static let SUPPLEMENTAL_SYMBOLS_AND_PICTOGRAPHS_ID = 261

    public static let SUTTON_SIGNWRITING_ID = 262

    public static let ADLAM_ID = 263

    public static let BHAIKSUKI_ID = 264

    public static let CYRILLIC_EXTENDED_C_ID = 265

    public static let GLAGOLITIC_SUPPLEMENT_ID = 266

    public static let IDEOGRAPHIC_SYMBOLS_AND_PUNCTUATION_ID = 267

    public static let MARCHEN_ID = 268

    public static let MONGOLIAN_SUPPLEMENT_ID = 269

    public static let NEWA_ID = 270

    public static let OSAGE_ID = 271

    public static let TANGUT_ID = 272

    public static let TANGUT_COMPONENTS_ID = 273

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_F_ID = 274

    public static let KANA_EXTENDED_A_ID = 275

    public static let MASARAM_GONDI_ID = 276

    public static let NUSHU_ID = 277

    public static let SOYOMBO_ID = 278

    public static let SYRIAC_SUPPLEMENT_ID = 279

    public static let ZANABAZAR_SQUARE_ID = 280

    public static let CHESS_SYMBOLS_ID = 281

    public static let DOGRA_ID = 282

    public static let GEORGIAN_EXTENDED_ID = 283

    public static let GUNJALA_GONDI_ID = 284

    public static let HANIFI_ROHINGYA_ID = 285

    public static let INDIC_SIYAQ_NUMBERS_ID = 286

    public static let MAKASAR_ID = 287

    public static let MAYAN_NUMERALS_ID = 288

    public static let MEDEFAIDRIN_ID = 289

    public static let OLD_SOGDIAN_ID = 290

    public static let SOGDIAN_ID = 291

    public static let EGYPTIAN_HIEROGLYPH_FORMAT_CONTROLS_ID = 292

    public static let ELYMAIC_ID = 293

    public static let NANDINAGARI_ID = 294

    public static let NYIAKENG_PUACHUE_HMONG_ID = 295

    public static let OTTOMAN_SIYAQ_NUMBERS_ID = 296

    public static let SMALL_KANA_EXTENSION_ID = 297

    public static let SYMBOLS_AND_PICTOGRAPHS_EXTENDED_A_ID = 298

    public static let TAMIL_SUPPLEMENT_ID = 299

    public static let WANCHO_ID = 300

    public static let CHORASMIAN_ID = 301

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_G_ID = 302

    public static let DIVES_AKURU_ID = 303

    public static let KHITAN_SMALL_SCRIPT_ID = 304

    public static let LISU_SUPPLEMENT_ID = 305

    public static let SYMBOLS_FOR_LEGACY_COMPUTING_ID = 306

    public static let TANGUT_SUPPLEMENT_ID = 307

    public static let YEZIDI_ID = 308

    public static let ARABIC_EXTENDED_B_ID = 309

    public static let CYPRO_MINOAN_ID = 310

    public static let ETHIOPIC_EXTENDED_B_ID = 311

    public static let KANA_EXTENDED_B_ID = 312

    public static let LATIN_EXTENDED_F_ID = 313

    public static let LATIN_EXTENDED_G_ID = 314

    public static let OLD_UYGHUR_ID = 315

    public static let TANGSA_ID = 316

    public static let TOTO_ID = 317

    public static let UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS_EXTENDED_A_ID = 318

    public static let VITHKUQI_ID = 319

    public static let ZNAMENNY_MUSICAL_NOTATION_ID = 320

    public static let ARABIC_EXTENDED_C_ID = 321

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_H_ID = 322

    public static let CYRILLIC_EXTENDED_D_ID = 323

    public static let DEVANAGARI_EXTENDED_A_ID = 324

    public static let KAKTOVIK_NUMERALS_ID = 325

    public static let KAWI_ID = 326

    public static let NAG_MUNDARI_ID = 327

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_I_ID = 328

    
    public static let COUNT = 329

    private static let BLOCKS_ = Array<UCharacter_UnicodeBlock>(Int64(COUNT))

    public static let NO_BLOCK = UCharacter_UnicodeBlock("NO_BLOCK", 0)

    public static let BASIC_LATIN = UCharacter_UnicodeBlock("BASIC_LATIN", BASIC_LATIN_ID)

    public static let LATIN_1_SUPPLEMENT = UCharacter_UnicodeBlock("LATIN_1_SUPPLEMENT", LATIN_1_SUPPLEMENT_ID)

    public static let LATIN_EXTENDED_A = UCharacter_UnicodeBlock("LATIN_EXTENDED_A", LATIN_EXTENDED_A_ID)

    public static let LATIN_EXTENDED_B = UCharacter_UnicodeBlock("LATIN_EXTENDED_B", LATIN_EXTENDED_B_ID)

    public static let IPA_EXTENSIONS = UCharacter_UnicodeBlock("IPA_EXTENSIONS", IPA_EXTENSIONS_ID)

    public static let SPACING_MODIFIER_LETTERS = UCharacter_UnicodeBlock("SPACING_MODIFIER_LETTERS", SPACING_MODIFIER_LETTERS_ID)

    public static let COMBINING_DIACRITICAL_MARKS = UCharacter_UnicodeBlock("COMBINING_DIACRITICAL_MARKS", COMBINING_DIACRITICAL_MARKS_ID)

    public static let GREEK = UCharacter_UnicodeBlock("GREEK", GREEK_ID)

    public static let CYRILLIC = UCharacter_UnicodeBlock("CYRILLIC", CYRILLIC_ID)

    public static let ARMENIAN = UCharacter_UnicodeBlock("ARMENIAN", ARMENIAN_ID)

    public static let HEBREW = UCharacter_UnicodeBlock("HEBREW", HEBREW_ID)

    public static let ARABIC = UCharacter_UnicodeBlock("ARABIC", ARABIC_ID)

    public static let SYRIAC = UCharacter_UnicodeBlock("SYRIAC", SYRIAC_ID)

    public static let THAANA = UCharacter_UnicodeBlock("THAANA", THAANA_ID)

    public static let DEVANAGARI = UCharacter_UnicodeBlock("DEVANAGARI", DEVANAGARI_ID)

    public static let BENGALI = UCharacter_UnicodeBlock("BENGALI", BENGALI_ID)

    public static let GURMUKHI = UCharacter_UnicodeBlock("GURMUKHI", GURMUKHI_ID)

    public static let GUJARATI = UCharacter_UnicodeBlock("GUJARATI", GUJARATI_ID)

    public static let ORIYA = UCharacter_UnicodeBlock("ORIYA", ORIYA_ID)

    public static let TAMIL = UCharacter_UnicodeBlock("TAMIL", TAMIL_ID)

    public static let TELUGU = UCharacter_UnicodeBlock("TELUGU", TELUGU_ID)

    public static let KANNADA = UCharacter_UnicodeBlock("KANNADA", KANNADA_ID)

    public static let MALAYALAM = UCharacter_UnicodeBlock("MALAYALAM", MALAYALAM_ID)

    public static let SINHALA = UCharacter_UnicodeBlock("SINHALA", SINHALA_ID)

    public static let THAI = UCharacter_UnicodeBlock("THAI", THAI_ID)

    public static let LAO = UCharacter_UnicodeBlock("LAO", LAO_ID)

    public static let TIBETAN = UCharacter_UnicodeBlock("TIBETAN", TIBETAN_ID)

    public static let MYANMAR = UCharacter_UnicodeBlock("MYANMAR", MYANMAR_ID)

    public static let GEORGIAN = UCharacter_UnicodeBlock("GEORGIAN", GEORGIAN_ID)

    public static let HANGUL_JAMO = UCharacter_UnicodeBlock("HANGUL_JAMO", HANGUL_JAMO_ID)

    public static let ETHIOPIC = UCharacter_UnicodeBlock("ETHIOPIC", ETHIOPIC_ID)

    public static let CHEROKEE = UCharacter_UnicodeBlock("CHEROKEE", CHEROKEE_ID)

    public static let UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS = UCharacter_UnicodeBlock("UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS", UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS_ID)

    public static let OGHAM = UCharacter_UnicodeBlock("OGHAM", OGHAM_ID)

    public static let RUNIC = UCharacter_UnicodeBlock("RUNIC", RUNIC_ID)

    public static let KHMER = UCharacter_UnicodeBlock("KHMER", KHMER_ID)

    public static let MONGOLIAN = UCharacter_UnicodeBlock("MONGOLIAN", MONGOLIAN_ID)

    public static let LATIN_EXTENDED_ADDITIONAL = UCharacter_UnicodeBlock("LATIN_EXTENDED_ADDITIONAL", LATIN_EXTENDED_ADDITIONAL_ID)

    public static let GREEK_EXTENDED = UCharacter_UnicodeBlock("GREEK_EXTENDED", GREEK_EXTENDED_ID)

    public static let GENERAL_PUNCTUATION = UCharacter_UnicodeBlock("GENERAL_PUNCTUATION", GENERAL_PUNCTUATION_ID)

    public static let SUPERSCRIPTS_AND_SUBSCRIPTS = UCharacter_UnicodeBlock("SUPERSCRIPTS_AND_SUBSCRIPTS", SUPERSCRIPTS_AND_SUBSCRIPTS_ID)

    public static let CURRENCY_SYMBOLS = UCharacter_UnicodeBlock("CURRENCY_SYMBOLS", CURRENCY_SYMBOLS_ID)

    public static let COMBINING_MARKS_FOR_SYMBOLS = UCharacter_UnicodeBlock("COMBINING_MARKS_FOR_SYMBOLS", COMBINING_MARKS_FOR_SYMBOLS_ID)

    public static let LETTERLIKE_SYMBOLS = UCharacter_UnicodeBlock("LETTERLIKE_SYMBOLS", LETTERLIKE_SYMBOLS_ID)

    public static let NUMBER_FORMS = UCharacter_UnicodeBlock("NUMBER_FORMS", NUMBER_FORMS_ID)

    public static let ARROWS = UCharacter_UnicodeBlock("ARROWS", ARROWS_ID)

    public static let MATHEMATICAL_OPERATORS = UCharacter_UnicodeBlock("MATHEMATICAL_OPERATORS", MATHEMATICAL_OPERATORS_ID)

    public static let MISCELLANEOUS_TECHNICAL = UCharacter_UnicodeBlock("MISCELLANEOUS_TECHNICAL", MISCELLANEOUS_TECHNICAL_ID)

    public static let CONTROL_PICTURES = UCharacter_UnicodeBlock("CONTROL_PICTURES", CONTROL_PICTURES_ID)

    public static let OPTICAL_CHARACTER_RECOGNITION = UCharacter_UnicodeBlock("OPTICAL_CHARACTER_RECOGNITION", OPTICAL_CHARACTER_RECOGNITION_ID)

    public static let ENCLOSED_ALPHANUMERICS = UCharacter_UnicodeBlock("ENCLOSED_ALPHANUMERICS", ENCLOSED_ALPHANUMERICS_ID)

    public static let BOX_DRAWING = UCharacter_UnicodeBlock("BOX_DRAWING", BOX_DRAWING_ID)

    public static let BLOCK_ELEMENTS = UCharacter_UnicodeBlock("BLOCK_ELEMENTS", BLOCK_ELEMENTS_ID)

    public static let GEOMETRIC_SHAPES = UCharacter_UnicodeBlock("GEOMETRIC_SHAPES", GEOMETRIC_SHAPES_ID)

    public static let MISCELLANEOUS_SYMBOLS = UCharacter_UnicodeBlock("MISCELLANEOUS_SYMBOLS", MISCELLANEOUS_SYMBOLS_ID)

    public static let DINGBATS = UCharacter_UnicodeBlock("DINGBATS", DINGBATS_ID)

    public static let BRAILLE_PATTERNS = UCharacter_UnicodeBlock("BRAILLE_PATTERNS", BRAILLE_PATTERNS_ID)

    public static let CJK_RADICALS_SUPPLEMENT = UCharacter_UnicodeBlock("CJK_RADICALS_SUPPLEMENT", CJK_RADICALS_SUPPLEMENT_ID)

    public static let KANGXI_RADICALS = UCharacter_UnicodeBlock("KANGXI_RADICALS", KANGXI_RADICALS_ID)

    public static let IDEOGRAPHIC_DESCRIPTION_CHARACTERS = UCharacter_UnicodeBlock("IDEOGRAPHIC_DESCRIPTION_CHARACTERS", IDEOGRAPHIC_DESCRIPTION_CHARACTERS_ID)

    public static let CJK_SYMBOLS_AND_PUNCTUATION = UCharacter_UnicodeBlock("CJK_SYMBOLS_AND_PUNCTUATION", CJK_SYMBOLS_AND_PUNCTUATION_ID)

    public static let HIRAGANA = UCharacter_UnicodeBlock("HIRAGANA", HIRAGANA_ID)

    public static let KATAKANA = UCharacter_UnicodeBlock("KATAKANA", KATAKANA_ID)

    public static let BOPOMOFO = UCharacter_UnicodeBlock("BOPOMOFO", BOPOMOFO_ID)

    public static let HANGUL_COMPATIBILITY_JAMO = UCharacter_UnicodeBlock("HANGUL_COMPATIBILITY_JAMO", HANGUL_COMPATIBILITY_JAMO_ID)

    public static let KANBUN = UCharacter_UnicodeBlock("KANBUN", KANBUN_ID)

    public static let BOPOMOFO_EXTENDED = UCharacter_UnicodeBlock("BOPOMOFO_EXTENDED", BOPOMOFO_EXTENDED_ID)

    public static let ENCLOSED_CJK_LETTERS_AND_MONTHS = UCharacter_UnicodeBlock("ENCLOSED_CJK_LETTERS_AND_MONTHS", ENCLOSED_CJK_LETTERS_AND_MONTHS_ID)

    public static let CJK_COMPATIBILITY = UCharacter_UnicodeBlock("CJK_COMPATIBILITY", CJK_COMPATIBILITY_ID)

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A = UCharacter_UnicodeBlock("CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A", CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A_ID)

    public static let CJK_UNIFIED_IDEOGRAPHS = UCharacter_UnicodeBlock("CJK_UNIFIED_IDEOGRAPHS", CJK_UNIFIED_IDEOGRAPHS_ID)

    public static let YI_SYLLABLES = UCharacter_UnicodeBlock("YI_SYLLABLES", YI_SYLLABLES_ID)

    public static let YI_RADICALS = UCharacter_UnicodeBlock("YI_RADICALS", YI_RADICALS_ID)

    public static let HANGUL_SYLLABLES = UCharacter_UnicodeBlock("HANGUL_SYLLABLES", HANGUL_SYLLABLES_ID)

    public static let HIGH_SURROGATES = UCharacter_UnicodeBlock("HIGH_SURROGATES", HIGH_SURROGATES_ID)

    public static let HIGH_PRIVATE_USE_SURROGATES = UCharacter_UnicodeBlock("HIGH_PRIVATE_USE_SURROGATES", HIGH_PRIVATE_USE_SURROGATES_ID)

    public static let LOW_SURROGATES = UCharacter_UnicodeBlock("LOW_SURROGATES", LOW_SURROGATES_ID)

    public static let PRIVATE_USE_AREA = UCharacter_UnicodeBlock("PRIVATE_USE_AREA", 78)

    public static let PRIVATE_USE = PRIVATE_USE_AREA

    public static let CJK_COMPATIBILITY_IDEOGRAPHS = UCharacter_UnicodeBlock("CJK_COMPATIBILITY_IDEOGRAPHS", CJK_COMPATIBILITY_IDEOGRAPHS_ID)

    public static let ALPHABETIC_PRESENTATION_FORMS = UCharacter_UnicodeBlock("ALPHABETIC_PRESENTATION_FORMS", ALPHABETIC_PRESENTATION_FORMS_ID)

    public static let ARABIC_PRESENTATION_FORMS_A = UCharacter_UnicodeBlock("ARABIC_PRESENTATION_FORMS_A", ARABIC_PRESENTATION_FORMS_A_ID)

    public static let COMBINING_HALF_MARKS = UCharacter_UnicodeBlock("COMBINING_HALF_MARKS", COMBINING_HALF_MARKS_ID)

    public static let CJK_COMPATIBILITY_FORMS = UCharacter_UnicodeBlock("CJK_COMPATIBILITY_FORMS", CJK_COMPATIBILITY_FORMS_ID)

    public static let SMALL_FORM_VARIANTS = UCharacter_UnicodeBlock("SMALL_FORM_VARIANTS", SMALL_FORM_VARIANTS_ID)

    public static let ARABIC_PRESENTATION_FORMS_B = UCharacter_UnicodeBlock("ARABIC_PRESENTATION_FORMS_B", ARABIC_PRESENTATION_FORMS_B_ID)

    public static let SPECIALS = UCharacter_UnicodeBlock("SPECIALS", SPECIALS_ID)

    public static let HALFWIDTH_AND_FULLWIDTH_FORMS = UCharacter_UnicodeBlock("HALFWIDTH_AND_FULLWIDTH_FORMS", HALFWIDTH_AND_FULLWIDTH_FORMS_ID)

    public static let OLD_ITALIC = UCharacter_UnicodeBlock("OLD_ITALIC", OLD_ITALIC_ID)

    public static let GOTHIC = UCharacter_UnicodeBlock("GOTHIC", GOTHIC_ID)

    public static let DESERET = UCharacter_UnicodeBlock("DESERET", DESERET_ID)

    public static let BYZANTINE_MUSICAL_SYMBOLS = UCharacter_UnicodeBlock("BYZANTINE_MUSICAL_SYMBOLS", BYZANTINE_MUSICAL_SYMBOLS_ID)

    public static let MUSICAL_SYMBOLS = UCharacter_UnicodeBlock("MUSICAL_SYMBOLS", MUSICAL_SYMBOLS_ID)

    public static let MATHEMATICAL_ALPHANUMERIC_SYMBOLS = UCharacter_UnicodeBlock("MATHEMATICAL_ALPHANUMERIC_SYMBOLS", MATHEMATICAL_ALPHANUMERIC_SYMBOLS_ID)

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_B = UCharacter_UnicodeBlock("CJK_UNIFIED_IDEOGRAPHS_EXTENSION_B", CJK_UNIFIED_IDEOGRAPHS_EXTENSION_B_ID)

    public static let CJK_COMPATIBILITY_IDEOGRAPHS_SUPPLEMENT = UCharacter_UnicodeBlock("CJK_COMPATIBILITY_IDEOGRAPHS_SUPPLEMENT", CJK_COMPATIBILITY_IDEOGRAPHS_SUPPLEMENT_ID)

    public static let TAGS = UCharacter_UnicodeBlock("TAGS", TAGS_ID)

    public static let CYRILLIC_SUPPLEMENTARY = UCharacter_UnicodeBlock("CYRILLIC_SUPPLEMENTARY", CYRILLIC_SUPPLEMENTARY_ID)

    public static let CYRILLIC_SUPPLEMENT = UCharacter_UnicodeBlock("CYRILLIC_SUPPLEMENT", CYRILLIC_SUPPLEMENT_ID)

    public static let TAGALOG = UCharacter_UnicodeBlock("TAGALOG", TAGALOG_ID)

    public static let HANUNOO = UCharacter_UnicodeBlock("HANUNOO", HANUNOO_ID)

    public static let BUHID = UCharacter_UnicodeBlock("BUHID", BUHID_ID)

    public static let TAGBANWA = UCharacter_UnicodeBlock("TAGBANWA", TAGBANWA_ID)

    public static let MISCELLANEOUS_MATHEMATICAL_SYMBOLS_A = UCharacter_UnicodeBlock("MISCELLANEOUS_MATHEMATICAL_SYMBOLS_A", MISCELLANEOUS_MATHEMATICAL_SYMBOLS_A_ID)

    public static let SUPPLEMENTAL_ARROWS_A = UCharacter_UnicodeBlock("SUPPLEMENTAL_ARROWS_A", SUPPLEMENTAL_ARROWS_A_ID)

    public static let SUPPLEMENTAL_ARROWS_B = UCharacter_UnicodeBlock("SUPPLEMENTAL_ARROWS_B", SUPPLEMENTAL_ARROWS_B_ID)

    public static let MISCELLANEOUS_MATHEMATICAL_SYMBOLS_B = UCharacter_UnicodeBlock("MISCELLANEOUS_MATHEMATICAL_SYMBOLS_B", MISCELLANEOUS_MATHEMATICAL_SYMBOLS_B_ID)

    public static let SUPPLEMENTAL_MATHEMATICAL_OPERATORS = UCharacter_UnicodeBlock("SUPPLEMENTAL_MATHEMATICAL_OPERATORS", SUPPLEMENTAL_MATHEMATICAL_OPERATORS_ID)

    public static let KATAKANA_PHONETIC_EXTENSIONS = UCharacter_UnicodeBlock("KATAKANA_PHONETIC_EXTENSIONS", KATAKANA_PHONETIC_EXTENSIONS_ID)

    public static let VARIATION_SELECTORS = UCharacter_UnicodeBlock("VARIATION_SELECTORS", VARIATION_SELECTORS_ID)

    public static let SUPPLEMENTARY_PRIVATE_USE_AREA_A = UCharacter_UnicodeBlock("SUPPLEMENTARY_PRIVATE_USE_AREA_A", SUPPLEMENTARY_PRIVATE_USE_AREA_A_ID)

    public static let SUPPLEMENTARY_PRIVATE_USE_AREA_B = UCharacter_UnicodeBlock("SUPPLEMENTARY_PRIVATE_USE_AREA_B", SUPPLEMENTARY_PRIVATE_USE_AREA_B_ID)

    public static let LIMBU = UCharacter_UnicodeBlock("LIMBU", LIMBU_ID)

    public static let TAI_LE = UCharacter_UnicodeBlock("TAI_LE", TAI_LE_ID)

    public static let KHMER_SYMBOLS = UCharacter_UnicodeBlock("KHMER_SYMBOLS", KHMER_SYMBOLS_ID)

    public static let PHONETIC_EXTENSIONS = UCharacter_UnicodeBlock("PHONETIC_EXTENSIONS", PHONETIC_EXTENSIONS_ID)

    public static let MISCELLANEOUS_SYMBOLS_AND_ARROWS = UCharacter_UnicodeBlock("MISCELLANEOUS_SYMBOLS_AND_ARROWS", MISCELLANEOUS_SYMBOLS_AND_ARROWS_ID)

    public static let YIJING_HEXAGRAM_SYMBOLS = UCharacter_UnicodeBlock("YIJING_HEXAGRAM_SYMBOLS", YIJING_HEXAGRAM_SYMBOLS_ID)

    public static let LINEAR_B_SYLLABARY = UCharacter_UnicodeBlock("LINEAR_B_SYLLABARY", LINEAR_B_SYLLABARY_ID)

    public static let LINEAR_B_IDEOGRAMS = UCharacter_UnicodeBlock("LINEAR_B_IDEOGRAMS", LINEAR_B_IDEOGRAMS_ID)

    public static let AEGEAN_NUMBERS = UCharacter_UnicodeBlock("AEGEAN_NUMBERS", AEGEAN_NUMBERS_ID)

    public static let UGARITIC = UCharacter_UnicodeBlock("UGARITIC", UGARITIC_ID)

    public static let SHAVIAN = UCharacter_UnicodeBlock("SHAVIAN", SHAVIAN_ID)

    public static let OSMANYA = UCharacter_UnicodeBlock("OSMANYA", OSMANYA_ID)

    public static let CYPRIOT_SYLLABARY = UCharacter_UnicodeBlock("CYPRIOT_SYLLABARY", CYPRIOT_SYLLABARY_ID)

    public static let TAI_XUAN_JING_SYMBOLS = UCharacter_UnicodeBlock("TAI_XUAN_JING_SYMBOLS", TAI_XUAN_JING_SYMBOLS_ID)

    public static let VARIATION_SELECTORS_SUPPLEMENT = UCharacter_UnicodeBlock("VARIATION_SELECTORS_SUPPLEMENT", VARIATION_SELECTORS_SUPPLEMENT_ID)

    public static let ANCIENT_GREEK_MUSICAL_NOTATION = UCharacter_UnicodeBlock("ANCIENT_GREEK_MUSICAL_NOTATION", ANCIENT_GREEK_MUSICAL_NOTATION_ID)

    public static let ANCIENT_GREEK_NUMBERS = UCharacter_UnicodeBlock("ANCIENT_GREEK_NUMBERS", ANCIENT_GREEK_NUMBERS_ID)

    public static let ARABIC_SUPPLEMENT = UCharacter_UnicodeBlock("ARABIC_SUPPLEMENT", ARABIC_SUPPLEMENT_ID)

    public static let BUGINESE = UCharacter_UnicodeBlock("BUGINESE", BUGINESE_ID)

    public static let CJK_STROKES = UCharacter_UnicodeBlock("CJK_STROKES", CJK_STROKES_ID)

    public static let COMBINING_DIACRITICAL_MARKS_SUPPLEMENT = UCharacter_UnicodeBlock("COMBINING_DIACRITICAL_MARKS_SUPPLEMENT", COMBINING_DIACRITICAL_MARKS_SUPPLEMENT_ID)

    public static let COPTIC = UCharacter_UnicodeBlock("COPTIC", COPTIC_ID)

    public static let ETHIOPIC_EXTENDED = UCharacter_UnicodeBlock("ETHIOPIC_EXTENDED", ETHIOPIC_EXTENDED_ID)

    public static let ETHIOPIC_SUPPLEMENT = UCharacter_UnicodeBlock("ETHIOPIC_SUPPLEMENT", ETHIOPIC_SUPPLEMENT_ID)

    public static let GEORGIAN_SUPPLEMENT = UCharacter_UnicodeBlock("GEORGIAN_SUPPLEMENT", GEORGIAN_SUPPLEMENT_ID)

    public static let GLAGOLITIC = UCharacter_UnicodeBlock("GLAGOLITIC", GLAGOLITIC_ID)

    public static let KHAROSHTHI = UCharacter_UnicodeBlock("KHAROSHTHI", KHAROSHTHI_ID)

    public static let MODIFIER_TONE_LETTERS = UCharacter_UnicodeBlock("MODIFIER_TONE_LETTERS", MODIFIER_TONE_LETTERS_ID)

    public static let NEW_TAI_LUE = UCharacter_UnicodeBlock("NEW_TAI_LUE", NEW_TAI_LUE_ID)

    public static let OLD_PERSIAN = UCharacter_UnicodeBlock("OLD_PERSIAN", OLD_PERSIAN_ID)

    public static let PHONETIC_EXTENSIONS_SUPPLEMENT = UCharacter_UnicodeBlock("PHONETIC_EXTENSIONS_SUPPLEMENT", PHONETIC_EXTENSIONS_SUPPLEMENT_ID)

    public static let SUPPLEMENTAL_PUNCTUATION = UCharacter_UnicodeBlock("SUPPLEMENTAL_PUNCTUATION", SUPPLEMENTAL_PUNCTUATION_ID)

    public static let SYLOTI_NAGRI = UCharacter_UnicodeBlock("SYLOTI_NAGRI", SYLOTI_NAGRI_ID)

    public static let TIFINAGH = UCharacter_UnicodeBlock("TIFINAGH", TIFINAGH_ID)

    public static let VERTICAL_FORMS = UCharacter_UnicodeBlock("VERTICAL_FORMS", VERTICAL_FORMS_ID)

    public static let NKO = UCharacter_UnicodeBlock("NKO", NKO_ID)

    public static let BALINESE = UCharacter_UnicodeBlock("BALINESE", BALINESE_ID)

    public static let LATIN_EXTENDED_C = UCharacter_UnicodeBlock("LATIN_EXTENDED_C", LATIN_EXTENDED_C_ID)

    public static let LATIN_EXTENDED_D = UCharacter_UnicodeBlock("LATIN_EXTENDED_D", LATIN_EXTENDED_D_ID)

    public static let PHAGS_PA = UCharacter_UnicodeBlock("PHAGS_PA", PHAGS_PA_ID)

    public static let PHOENICIAN = UCharacter_UnicodeBlock("PHOENICIAN", PHOENICIAN_ID)

    public static let CUNEIFORM = UCharacter_UnicodeBlock("CUNEIFORM", CUNEIFORM_ID)

    public static let CUNEIFORM_NUMBERS_AND_PUNCTUATION = UCharacter_UnicodeBlock("CUNEIFORM_NUMBERS_AND_PUNCTUATION", CUNEIFORM_NUMBERS_AND_PUNCTUATION_ID)

    public static let COUNTING_ROD_NUMERALS = UCharacter_UnicodeBlock("COUNTING_ROD_NUMERALS", COUNTING_ROD_NUMERALS_ID)

    public static let SUNDANESE = UCharacter_UnicodeBlock("SUNDANESE", SUNDANESE_ID)

    public static let LEPCHA = UCharacter_UnicodeBlock("LEPCHA", LEPCHA_ID)

    public static let OL_CHIKI = UCharacter_UnicodeBlock("OL_CHIKI", OL_CHIKI_ID)

    public static let CYRILLIC_EXTENDED_A = UCharacter_UnicodeBlock("CYRILLIC_EXTENDED_A", CYRILLIC_EXTENDED_A_ID)

    public static let VAI = UCharacter_UnicodeBlock("VAI", VAI_ID)

    public static let CYRILLIC_EXTENDED_B = UCharacter_UnicodeBlock("CYRILLIC_EXTENDED_B", CYRILLIC_EXTENDED_B_ID)

    public static let SAURASHTRA = UCharacter_UnicodeBlock("SAURASHTRA", SAURASHTRA_ID)

    public static let KAYAH_LI = UCharacter_UnicodeBlock("KAYAH_LI", KAYAH_LI_ID)

    public static let REJANG = UCharacter_UnicodeBlock("REJANG", REJANG_ID)

    public static let CHAM = UCharacter_UnicodeBlock("CHAM", CHAM_ID)

    public static let ANCIENT_SYMBOLS = UCharacter_UnicodeBlock("ANCIENT_SYMBOLS", ANCIENT_SYMBOLS_ID)

    public static let PHAISTOS_DISC = UCharacter_UnicodeBlock("PHAISTOS_DISC", PHAISTOS_DISC_ID)

    public static let LYCIAN = UCharacter_UnicodeBlock("LYCIAN", LYCIAN_ID)

    public static let CARIAN = UCharacter_UnicodeBlock("CARIAN", CARIAN_ID)

    public static let LYDIAN = UCharacter_UnicodeBlock("LYDIAN", LYDIAN_ID)

    public static let MAHJONG_TILES = UCharacter_UnicodeBlock("MAHJONG_TILES", MAHJONG_TILES_ID)

    public static let DOMINO_TILES = UCharacter_UnicodeBlock("DOMINO_TILES", DOMINO_TILES_ID)

    public static let SAMARITAN = UCharacter_UnicodeBlock("SAMARITAN", SAMARITAN_ID)

    public static let UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS_EXTENDED = UCharacter_UnicodeBlock("UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS_EXTENDED", UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS_EXTENDED_ID)

    public static let TAI_THAM = UCharacter_UnicodeBlock("TAI_THAM", TAI_THAM_ID)

    public static let VEDIC_EXTENSIONS = UCharacter_UnicodeBlock("VEDIC_EXTENSIONS", VEDIC_EXTENSIONS_ID)

    public static let LISU = UCharacter_UnicodeBlock("LISU", LISU_ID)

    public static let BAMUM = UCharacter_UnicodeBlock("BAMUM", BAMUM_ID)

    public static let COMMON_INDIC_NUMBER_FORMS = UCharacter_UnicodeBlock("COMMON_INDIC_NUMBER_FORMS", COMMON_INDIC_NUMBER_FORMS_ID)

    public static let DEVANAGARI_EXTENDED = UCharacter_UnicodeBlock("DEVANAGARI_EXTENDED", DEVANAGARI_EXTENDED_ID)

    public static let HANGUL_JAMO_EXTENDED_A = UCharacter_UnicodeBlock("HANGUL_JAMO_EXTENDED_A", HANGUL_JAMO_EXTENDED_A_ID)

    public static let JAVANESE = UCharacter_UnicodeBlock("JAVANESE", JAVANESE_ID)

    public static let MYANMAR_EXTENDED_A = UCharacter_UnicodeBlock("MYANMAR_EXTENDED_A", MYANMAR_EXTENDED_A_ID)

    public static let TAI_VIET = UCharacter_UnicodeBlock("TAI_VIET", TAI_VIET_ID)

    public static let MEETEI_MAYEK = UCharacter_UnicodeBlock("MEETEI_MAYEK", MEETEI_MAYEK_ID)

    public static let HANGUL_JAMO_EXTENDED_B = UCharacter_UnicodeBlock("HANGUL_JAMO_EXTENDED_B", HANGUL_JAMO_EXTENDED_B_ID)

    public static let IMPERIAL_ARAMAIC = UCharacter_UnicodeBlock("IMPERIAL_ARAMAIC", IMPERIAL_ARAMAIC_ID)

    public static let OLD_SOUTH_ARABIAN = UCharacter_UnicodeBlock("OLD_SOUTH_ARABIAN", OLD_SOUTH_ARABIAN_ID)

    public static let AVESTAN = UCharacter_UnicodeBlock("AVESTAN", AVESTAN_ID)

    public static let INSCRIPTIONAL_PARTHIAN = UCharacter_UnicodeBlock("INSCRIPTIONAL_PARTHIAN", INSCRIPTIONAL_PARTHIAN_ID)

    public static let INSCRIPTIONAL_PAHLAVI = UCharacter_UnicodeBlock("INSCRIPTIONAL_PAHLAVI", INSCRIPTIONAL_PAHLAVI_ID)

    public static let OLD_TURKIC = UCharacter_UnicodeBlock("OLD_TURKIC", OLD_TURKIC_ID)

    public static let RUMI_NUMERAL_SYMBOLS = UCharacter_UnicodeBlock("RUMI_NUMERAL_SYMBOLS", RUMI_NUMERAL_SYMBOLS_ID)

    public static let KAITHI = UCharacter_UnicodeBlock("KAITHI", KAITHI_ID)

    public static let EGYPTIAN_HIEROGLYPHS = UCharacter_UnicodeBlock("EGYPTIAN_HIEROGLYPHS", EGYPTIAN_HIEROGLYPHS_ID)

    public static let ENCLOSED_ALPHANUMERIC_SUPPLEMENT = UCharacter_UnicodeBlock("ENCLOSED_ALPHANUMERIC_SUPPLEMENT", ENCLOSED_ALPHANUMERIC_SUPPLEMENT_ID)

    public static let ENCLOSED_IDEOGRAPHIC_SUPPLEMENT = UCharacter_UnicodeBlock("ENCLOSED_IDEOGRAPHIC_SUPPLEMENT", ENCLOSED_IDEOGRAPHIC_SUPPLEMENT_ID)

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_C = UCharacter_UnicodeBlock("CJK_UNIFIED_IDEOGRAPHS_EXTENSION_C", CJK_UNIFIED_IDEOGRAPHS_EXTENSION_C_ID)

    public static let MANDAIC = UCharacter_UnicodeBlock("MANDAIC", MANDAIC_ID)

    public static let BATAK = UCharacter_UnicodeBlock("BATAK", BATAK_ID)

    public static let ETHIOPIC_EXTENDED_A = UCharacter_UnicodeBlock("ETHIOPIC_EXTENDED_A", ETHIOPIC_EXTENDED_A_ID)

    public static let BRAHMI = UCharacter_UnicodeBlock("BRAHMI", BRAHMI_ID)

    public static let BAMUM_SUPPLEMENT = UCharacter_UnicodeBlock("BAMUM_SUPPLEMENT", BAMUM_SUPPLEMENT_ID)

    public static let KANA_SUPPLEMENT = UCharacter_UnicodeBlock("KANA_SUPPLEMENT", KANA_SUPPLEMENT_ID)

    public static let PLAYING_CARDS = UCharacter_UnicodeBlock("PLAYING_CARDS", PLAYING_CARDS_ID)

    public static let MISCELLANEOUS_SYMBOLS_AND_PICTOGRAPHS = UCharacter_UnicodeBlock("MISCELLANEOUS_SYMBOLS_AND_PICTOGRAPHS", MISCELLANEOUS_SYMBOLS_AND_PICTOGRAPHS_ID)

    public static let EMOTICONS = UCharacter_UnicodeBlock("EMOTICONS", EMOTICONS_ID)

    public static let TRANSPORT_AND_MAP_SYMBOLS = UCharacter_UnicodeBlock("TRANSPORT_AND_MAP_SYMBOLS", TRANSPORT_AND_MAP_SYMBOLS_ID)

    public static let ALCHEMICAL_SYMBOLS = UCharacter_UnicodeBlock("ALCHEMICAL_SYMBOLS", ALCHEMICAL_SYMBOLS_ID)

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_D = UCharacter_UnicodeBlock("CJK_UNIFIED_IDEOGRAPHS_EXTENSION_D", CJK_UNIFIED_IDEOGRAPHS_EXTENSION_D_ID)

    public static let ARABIC_EXTENDED_A = UCharacter_UnicodeBlock("ARABIC_EXTENDED_A", ARABIC_EXTENDED_A_ID)

    public static let ARABIC_MATHEMATICAL_ALPHABETIC_SYMBOLS = UCharacter_UnicodeBlock("ARABIC_MATHEMATICAL_ALPHABETIC_SYMBOLS", ARABIC_MATHEMATICAL_ALPHABETIC_SYMBOLS_ID)

    public static let CHAKMA = UCharacter_UnicodeBlock("CHAKMA", CHAKMA_ID)

    public static let MEETEI_MAYEK_EXTENSIONS = UCharacter_UnicodeBlock("MEETEI_MAYEK_EXTENSIONS", MEETEI_MAYEK_EXTENSIONS_ID)

    public static let MEROITIC_CURSIVE = UCharacter_UnicodeBlock("MEROITIC_CURSIVE", MEROITIC_CURSIVE_ID)

    public static let MEROITIC_HIEROGLYPHS = UCharacter_UnicodeBlock("MEROITIC_HIEROGLYPHS", MEROITIC_HIEROGLYPHS_ID)

    public static let MIAO = UCharacter_UnicodeBlock("MIAO", MIAO_ID)

    public static let SHARADA = UCharacter_UnicodeBlock("SHARADA", SHARADA_ID)

    public static let SORA_SOMPENG = UCharacter_UnicodeBlock("SORA_SOMPENG", SORA_SOMPENG_ID)

    public static let SUNDANESE_SUPPLEMENT = UCharacter_UnicodeBlock("SUNDANESE_SUPPLEMENT", SUNDANESE_SUPPLEMENT_ID)

    public static let TAKRI = UCharacter_UnicodeBlock("TAKRI", TAKRI_ID)

    public static let BASSA_VAH = UCharacter_UnicodeBlock("BASSA_VAH", BASSA_VAH_ID)

    public static let CAUCASIAN_ALBANIAN = UCharacter_UnicodeBlock("CAUCASIAN_ALBANIAN", CAUCASIAN_ALBANIAN_ID)

    public static let COPTIC_EPACT_NUMBERS = UCharacter_UnicodeBlock("COPTIC_EPACT_NUMBERS", COPTIC_EPACT_NUMBERS_ID)

    public static let COMBINING_DIACRITICAL_MARKS_EXTENDED = UCharacter_UnicodeBlock("COMBINING_DIACRITICAL_MARKS_EXTENDED", COMBINING_DIACRITICAL_MARKS_EXTENDED_ID)

    public static let DUPLOYAN = UCharacter_UnicodeBlock("DUPLOYAN", DUPLOYAN_ID)

    public static let ELBASAN = UCharacter_UnicodeBlock("ELBASAN", ELBASAN_ID)

    public static let GEOMETRIC_SHAPES_EXTENDED = UCharacter_UnicodeBlock("GEOMETRIC_SHAPES_EXTENDED", GEOMETRIC_SHAPES_EXTENDED_ID)

    public static let GRANTHA = UCharacter_UnicodeBlock("GRANTHA", GRANTHA_ID)

    public static let KHOJKI = UCharacter_UnicodeBlock("KHOJKI", KHOJKI_ID)

    public static let KHUDAWADI = UCharacter_UnicodeBlock("KHUDAWADI", KHUDAWADI_ID)

    public static let LATIN_EXTENDED_E = UCharacter_UnicodeBlock("LATIN_EXTENDED_E", LATIN_EXTENDED_E_ID)

    public static let LINEAR_A = UCharacter_UnicodeBlock("LINEAR_A", LINEAR_A_ID)

    public static let MAHAJANI = UCharacter_UnicodeBlock("MAHAJANI", MAHAJANI_ID)

    public static let MANICHAEAN = UCharacter_UnicodeBlock("MANICHAEAN", MANICHAEAN_ID)

    public static let MENDE_KIKAKUI = UCharacter_UnicodeBlock("MENDE_KIKAKUI", MENDE_KIKAKUI_ID)

    public static let MODI = UCharacter_UnicodeBlock("MODI", MODI_ID)

    public static let MRO = UCharacter_UnicodeBlock("MRO", MRO_ID)

    public static let MYANMAR_EXTENDED_B = UCharacter_UnicodeBlock("MYANMAR_EXTENDED_B", MYANMAR_EXTENDED_B_ID)

    public static let NABATAEAN = UCharacter_UnicodeBlock("NABATAEAN", NABATAEAN_ID)

    public static let OLD_NORTH_ARABIAN = UCharacter_UnicodeBlock("OLD_NORTH_ARABIAN", OLD_NORTH_ARABIAN_ID)

    public static let OLD_PERMIC = UCharacter_UnicodeBlock("OLD_PERMIC", OLD_PERMIC_ID)

    public static let ORNAMENTAL_DINGBATS = UCharacter_UnicodeBlock("ORNAMENTAL_DINGBATS", ORNAMENTAL_DINGBATS_ID)

    public static let PAHAWH_HMONG = UCharacter_UnicodeBlock("PAHAWH_HMONG", PAHAWH_HMONG_ID)

    public static let PALMYRENE = UCharacter_UnicodeBlock("PALMYRENE", PALMYRENE_ID)

    public static let PAU_CIN_HAU = UCharacter_UnicodeBlock("PAU_CIN_HAU", PAU_CIN_HAU_ID)

    public static let PSALTER_PAHLAVI = UCharacter_UnicodeBlock("PSALTER_PAHLAVI", PSALTER_PAHLAVI_ID)

    public static let SHORTHAND_FORMAT_CONTROLS = UCharacter_UnicodeBlock("SHORTHAND_FORMAT_CONTROLS", SHORTHAND_FORMAT_CONTROLS_ID)

    public static let SIDDHAM = UCharacter_UnicodeBlock("SIDDHAM", SIDDHAM_ID)

    public static let SINHALA_ARCHAIC_NUMBERS = UCharacter_UnicodeBlock("SINHALA_ARCHAIC_NUMBERS", SINHALA_ARCHAIC_NUMBERS_ID)

    public static let SUPPLEMENTAL_ARROWS_C = UCharacter_UnicodeBlock("SUPPLEMENTAL_ARROWS_C", SUPPLEMENTAL_ARROWS_C_ID)

    public static let TIRHUTA = UCharacter_UnicodeBlock("TIRHUTA", TIRHUTA_ID)

    public static let WARANG_CITI = UCharacter_UnicodeBlock("WARANG_CITI", WARANG_CITI_ID)

    public static let AHOM = UCharacter_UnicodeBlock("AHOM", AHOM_ID)

    public static let ANATOLIAN_HIEROGLYPHS = UCharacter_UnicodeBlock("ANATOLIAN_HIEROGLYPHS", ANATOLIAN_HIEROGLYPHS_ID)

    public static let CHEROKEE_SUPPLEMENT = UCharacter_UnicodeBlock("CHEROKEE_SUPPLEMENT", CHEROKEE_SUPPLEMENT_ID)

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_E = UCharacter_UnicodeBlock("CJK_UNIFIED_IDEOGRAPHS_EXTENSION_E", CJK_UNIFIED_IDEOGRAPHS_EXTENSION_E_ID)

    public static let EARLY_DYNASTIC_CUNEIFORM = UCharacter_UnicodeBlock("EARLY_DYNASTIC_CUNEIFORM", EARLY_DYNASTIC_CUNEIFORM_ID)

    public static let HATRAN = UCharacter_UnicodeBlock("HATRAN", HATRAN_ID)

    public static let MULTANI = UCharacter_UnicodeBlock("MULTANI", MULTANI_ID)

    public static let OLD_HUNGARIAN = UCharacter_UnicodeBlock("OLD_HUNGARIAN", OLD_HUNGARIAN_ID)

    public static let SUPPLEMENTAL_SYMBOLS_AND_PICTOGRAPHS = UCharacter_UnicodeBlock("SUPPLEMENTAL_SYMBOLS_AND_PICTOGRAPHS", SUPPLEMENTAL_SYMBOLS_AND_PICTOGRAPHS_ID)

    public static let SUTTON_SIGNWRITING = UCharacter_UnicodeBlock("SUTTON_SIGNWRITING", SUTTON_SIGNWRITING_ID)

    public static let ADLAM = UCharacter_UnicodeBlock("ADLAM", ADLAM_ID)

    public static let BHAIKSUKI = UCharacter_UnicodeBlock("BHAIKSUKI", BHAIKSUKI_ID)

    public static let CYRILLIC_EXTENDED_C = UCharacter_UnicodeBlock("CYRILLIC_EXTENDED_C", CYRILLIC_EXTENDED_C_ID)

    public static let GLAGOLITIC_SUPPLEMENT = UCharacter_UnicodeBlock("GLAGOLITIC_SUPPLEMENT", GLAGOLITIC_SUPPLEMENT_ID)

    public static let IDEOGRAPHIC_SYMBOLS_AND_PUNCTUATION = UCharacter_UnicodeBlock("IDEOGRAPHIC_SYMBOLS_AND_PUNCTUATION", IDEOGRAPHIC_SYMBOLS_AND_PUNCTUATION_ID)

    public static let MARCHEN = UCharacter_UnicodeBlock("MARCHEN", MARCHEN_ID)

    public static let MONGOLIAN_SUPPLEMENT = UCharacter_UnicodeBlock("MONGOLIAN_SUPPLEMENT", MONGOLIAN_SUPPLEMENT_ID)

    public static let NEWA = UCharacter_UnicodeBlock("NEWA", NEWA_ID)

    public static let OSAGE = UCharacter_UnicodeBlock("OSAGE", OSAGE_ID)

    public static let TANGUT = UCharacter_UnicodeBlock("TANGUT", TANGUT_ID)

    public static let TANGUT_COMPONENTS = UCharacter_UnicodeBlock("TANGUT_COMPONENTS", TANGUT_COMPONENTS_ID)

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_F = UCharacter_UnicodeBlock("CJK_UNIFIED_IDEOGRAPHS_EXTENSION_F", CJK_UNIFIED_IDEOGRAPHS_EXTENSION_F_ID)

    public static let KANA_EXTENDED_A = UCharacter_UnicodeBlock("KANA_EXTENDED_A", KANA_EXTENDED_A_ID)

    public static let MASARAM_GONDI = UCharacter_UnicodeBlock("MASARAM_GONDI", MASARAM_GONDI_ID)

    public static let NUSHU = UCharacter_UnicodeBlock("NUSHU", NUSHU_ID)

    public static let SOYOMBO = UCharacter_UnicodeBlock("SOYOMBO", SOYOMBO_ID)

    public static let SYRIAC_SUPPLEMENT = UCharacter_UnicodeBlock("SYRIAC_SUPPLEMENT", SYRIAC_SUPPLEMENT_ID)

    public static let ZANABAZAR_SQUARE = UCharacter_UnicodeBlock("ZANABAZAR_SQUARE", ZANABAZAR_SQUARE_ID)

    public static let CHESS_SYMBOLS = UCharacter_UnicodeBlock("CHESS_SYMBOLS", CHESS_SYMBOLS_ID)

    public static let DOGRA = UCharacter_UnicodeBlock("DOGRA", DOGRA_ID)

    public static let GEORGIAN_EXTENDED = UCharacter_UnicodeBlock("GEORGIAN_EXTENDED", GEORGIAN_EXTENDED_ID)

    public static let GUNJALA_GONDI = UCharacter_UnicodeBlock("GUNJALA_GONDI", GUNJALA_GONDI_ID)

    public static let HANIFI_ROHINGYA = UCharacter_UnicodeBlock("HANIFI_ROHINGYA", HANIFI_ROHINGYA_ID)

    public static let INDIC_SIYAQ_NUMBERS = UCharacter_UnicodeBlock("INDIC_SIYAQ_NUMBERS", INDIC_SIYAQ_NUMBERS_ID)

    public static let MAKASAR = UCharacter_UnicodeBlock("MAKASAR", MAKASAR_ID)

    public static let MAYAN_NUMERALS = UCharacter_UnicodeBlock("MAYAN_NUMERALS", MAYAN_NUMERALS_ID)

    public static let MEDEFAIDRIN = UCharacter_UnicodeBlock("MEDEFAIDRIN", MEDEFAIDRIN_ID)

    public static let OLD_SOGDIAN = UCharacter_UnicodeBlock("OLD_SOGDIAN", OLD_SOGDIAN_ID)

    public static let SOGDIAN = UCharacter_UnicodeBlock("SOGDIAN", SOGDIAN_ID)

    public static let EGYPTIAN_HIEROGLYPH_FORMAT_CONTROLS = UCharacter_UnicodeBlock("EGYPTIAN_HIEROGLYPH_FORMAT_CONTROLS", EGYPTIAN_HIEROGLYPH_FORMAT_CONTROLS_ID)

    public static let ELYMAIC = UCharacter_UnicodeBlock("ELYMAIC", ELYMAIC_ID)

    public static let NANDINAGARI = UCharacter_UnicodeBlock("NANDINAGARI", NANDINAGARI_ID)

    public static let NYIAKENG_PUACHUE_HMONG = UCharacter_UnicodeBlock("NYIAKENG_PUACHUE_HMONG", NYIAKENG_PUACHUE_HMONG_ID)

    public static let OTTOMAN_SIYAQ_NUMBERS = UCharacter_UnicodeBlock("OTTOMAN_SIYAQ_NUMBERS", OTTOMAN_SIYAQ_NUMBERS_ID)

    public static let SMALL_KANA_EXTENSION = UCharacter_UnicodeBlock("SMALL_KANA_EXTENSION", SMALL_KANA_EXTENSION_ID)

    public static let SYMBOLS_AND_PICTOGRAPHS_EXTENDED_A = UCharacter_UnicodeBlock("SYMBOLS_AND_PICTOGRAPHS_EXTENDED_A", SYMBOLS_AND_PICTOGRAPHS_EXTENDED_A_ID)

    public static let TAMIL_SUPPLEMENT = UCharacter_UnicodeBlock("TAMIL_SUPPLEMENT", TAMIL_SUPPLEMENT_ID)

    public static let WANCHO = UCharacter_UnicodeBlock("WANCHO", WANCHO_ID)

    public static let CHORASMIAN = UCharacter_UnicodeBlock("CHORASMIAN", CHORASMIAN_ID)

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_G = UCharacter_UnicodeBlock("CJK_UNIFIED_IDEOGRAPHS_EXTENSION_G", CJK_UNIFIED_IDEOGRAPHS_EXTENSION_G_ID)

    public static let DIVES_AKURU = UCharacter_UnicodeBlock("DIVES_AKURU", DIVES_AKURU_ID)

    public static let KHITAN_SMALL_SCRIPT = UCharacter_UnicodeBlock("KHITAN_SMALL_SCRIPT", KHITAN_SMALL_SCRIPT_ID)

    public static let LISU_SUPPLEMENT = UCharacter_UnicodeBlock("LISU_SUPPLEMENT", LISU_SUPPLEMENT_ID)

    public static let SYMBOLS_FOR_LEGACY_COMPUTING = UCharacter_UnicodeBlock("SYMBOLS_FOR_LEGACY_COMPUTING", SYMBOLS_FOR_LEGACY_COMPUTING_ID)

    public static let TANGUT_SUPPLEMENT = UCharacter_UnicodeBlock("TANGUT_SUPPLEMENT", TANGUT_SUPPLEMENT_ID)

    public static let YEZIDI = UCharacter_UnicodeBlock("YEZIDI", YEZIDI_ID)

    public static let ARABIC_EXTENDED_B = UCharacter_UnicodeBlock("ARABIC_EXTENDED_B", ARABIC_EXTENDED_B_ID)

    public static let CYPRO_MINOAN = UCharacter_UnicodeBlock("CYPRO_MINOAN", CYPRO_MINOAN_ID)

    public static let ETHIOPIC_EXTENDED_B = UCharacter_UnicodeBlock("ETHIOPIC_EXTENDED_B", ETHIOPIC_EXTENDED_B_ID)

    public static let KANA_EXTENDED_B = UCharacter_UnicodeBlock("KANA_EXTENDED_B", KANA_EXTENDED_B_ID)

    public static let LATIN_EXTENDED_F = UCharacter_UnicodeBlock("LATIN_EXTENDED_F", LATIN_EXTENDED_F_ID)

    public static let LATIN_EXTENDED_G = UCharacter_UnicodeBlock("LATIN_EXTENDED_G", LATIN_EXTENDED_G_ID)

    public static let OLD_UYGHUR = UCharacter_UnicodeBlock("OLD_UYGHUR", OLD_UYGHUR_ID)

    public static let TANGSA = UCharacter_UnicodeBlock("TANGSA", TANGSA_ID)

    public static let TOTO = UCharacter_UnicodeBlock("TOTO", TOTO_ID)

    public static let UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS_EXTENDED_A = UCharacter_UnicodeBlock("UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS_EXTENDED_A", UNIFIED_CANADIAN_ABORIGINAL_SYLLABICS_EXTENDED_A_ID)

    public static let VITHKUQI = UCharacter_UnicodeBlock("VITHKUQI", VITHKUQI_ID)

    public static let ZNAMENNY_MUSICAL_NOTATION = UCharacter_UnicodeBlock("ZNAMENNY_MUSICAL_NOTATION", ZNAMENNY_MUSICAL_NOTATION_ID)

    public static let ARABIC_EXTENDED_C = UCharacter_UnicodeBlock("ARABIC_EXTENDED_C", ARABIC_EXTENDED_C_ID)

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_H = UCharacter_UnicodeBlock("CJK_UNIFIED_IDEOGRAPHS_EXTENSION_H", CJK_UNIFIED_IDEOGRAPHS_EXTENSION_H_ID)

    public static let CYRILLIC_EXTENDED_D = UCharacter_UnicodeBlock("CYRILLIC_EXTENDED_D", CYRILLIC_EXTENDED_D_ID)

    public static let DEVANAGARI_EXTENDED_A = UCharacter_UnicodeBlock("DEVANAGARI_EXTENDED_A", DEVANAGARI_EXTENDED_A_ID)

    public static let KAKTOVIK_NUMERALS = UCharacter_UnicodeBlock("KAKTOVIK_NUMERALS", KAKTOVIK_NUMERALS_ID)

    public static let KAWI = UCharacter_UnicodeBlock("KAWI", KAWI_ID)

    public static let NAG_MUNDARI = UCharacter_UnicodeBlock("NAG_MUNDARI", NAG_MUNDARI_ID)

    public static let CJK_UNIFIED_IDEOGRAPHS_EXTENSION_I = UCharacter_UnicodeBlock("CJK_UNIFIED_IDEOGRAPHS_EXTENSION_I", CJK_UNIFIED_IDEOGRAPHS_EXTENSION_I_ID)

    public static let INVALID_CODE = UCharacter_UnicodeBlock("INVALID_CODE", INVALID_CODE_ID)


    public static func getInstance(id: Int32): UCharacter_UnicodeBlock {
        if (id >= 0 && id < Int32(BLOCKS_.size)) {
            return BLOCKS_[Int64(id)]
        }
        return INVALID_CODE
    }

    public static func of(ch: Int32): UCharacter_UnicodeBlock {
        if (ch > UCharacter.MAX_VALUE) {
            return INVALID_CODE
        }
        return UCharacter_UnicodeBlock.getInstance(UCharacterProperty.INSTANCE.getIntPropertyValue(ch, UProperty.BLOCK))
    }

    public static func forName(blockName: String): UCharacter_UnicodeBlock {
        var m: Map<String, UCharacter_UnicodeBlock> = None
        if (mref.isSome()) {
            m = mref.get()
        }
        if (m.isNone()) {
            m = HashMap<String, UCharacter_UnicodeBlock>(BLOCKS_.size)
            var i = 0
            while (i < Int32(BLOCKS_.size)) {
                let b = BLOCKS_[Int64(i)]
                let name = trimBlockName(UCharacter.getPropertyValueName(UProperty.BLOCK, b.getID(), UProperty_NameChoice.LONG))
                m.put(name, b)
                i++
            }
            mref = SoftReference(m)
        }
        let b = m.get(trimBlockName(blockName))
        if (b.isNone()) {
            throw IllegalArgumentException()
        }
        return b
    }

    private static var mref: SoftReference = None

    private static func trimBlockName(name: String): String {
        let upper = name.toUpperCase(Locale.ENGLISH)
        let result = StringBuilder()
        var i = 0
        while (i < Int32(upper.size)) {
            let c = Char(upper[Int64(i)])
            if (c != ' ' && c != '_' && c != '-') {
                result.append(c)
            }
            i++
        }
        return result.toString()
    }

    public func getID(): Int32 {
        return m_id_
    }

    private var m_id_: Int32 = 0

    private init(name: String, id: Int32) {
        Character_Subset(name)
        m_id_ = id
        if (id >= 0) {
            BLOCKS_[Int64(id)] = this
        }
    }
}


public interface UCharacter_EastAsianWidth {
    let NEUTRAL = 0

    let AMBIGUOUS = 1

    let HALFWIDTH = 2

    let FULLWIDTH = 3

    let NARROW = 4

    let WIDE = 5

    
    let COUNT = 6
}

public interface UCharacter_DecompositionType {
    let NONE = 0

    let CANONICAL = 1

    let COMPAT = 2

    let CIRCLE = 3

    let FINAL = 4

    let FONT = 5

    let FRACTION = 6

    let INITIAL = 7

    let ISOLATED = 8

    let MEDIAL = 9

    let NARROW = 10

    let NOBREAK = 11

    let SMALL = 12

    let SQUARE = 13

    let SUB = 14

    let SUPER = 15

    let VERTICAL = 16

    let WIDE = 17

    
    let COUNT = 18
}

public interface UCharacter_JoiningType {
    let NON_JOINING = 0

    let JOIN_CAUSING = 1

    let DUAL_JOINING = 2

    let LEFT_JOINING = 3

    let RIGHT_JOINING = 4

    let TRANSPARENT = 5

    
    let COUNT = 6
}

public interface UCharacter_JoiningGroup {
    let NO_JOINING_GROUP = 0

    let AIN = 1

    let ALAPH = 2

    let ALEF = 3

    let BEH = 4

    let BETH = 5

    let DAL = 6

    let DALATH_RISH = 7

    let E = 8

    let FEH = 9

    let FINAL_SEMKATH = 10

    let GAF = 11

    let GAMAL = 12

    let HAH = 13

    let TEH_MARBUTA_GOAL = 14

    let HAMZA_ON_HEH_GOAL = TEH_MARBUTA_GOAL

    let HE = 15

    let HEH = 16

    let HEH_GOAL = 17

    let HETH = 18

    let KAF = 19

    let KAPH = 20

    let KNOTTED_HEH = 21

    let LAM = 22

    let LAMADH = 23

    let MEEM = 24

    let MIM = 25

    let NOON = 26

    let NUN = 27

    let PE = 28

    let QAF = 29

    let QAPH = 30

    let REH = 31

    let REVERSED_PE = 32

    let SAD = 33

    let SADHE = 34

    let SEEN = 35

    let SEMKATH = 36

    let SHIN = 37

    let SWASH_KAF = 38

    let SYRIAC_WAW = 39

    let TAH = 40

    let TAW = 41

    let TEH_MARBUTA = 42

    let TETH = 43

    let WAW = 44

    let YEH = 45

    let YEH_BARREE = 46

    let YEH_WITH_TAIL = 47

    let YUDH = 48

    let YUDH_HE = 49

    let ZAIN = 50

    let FE = 51

    let KHAPH = 52

    let ZHAIN = 53

    let BURUSHASKI_YEH_BARREE = 54

    let FARSI_YEH = 55

    let NYA = 56

    let ROHINGYA_YEH = 57

    let MANICHAEAN_ALEPH = 58

    let MANICHAEAN_AYIN = 59

    let MANICHAEAN_BETH = 60

    let MANICHAEAN_DALETH = 61

    let MANICHAEAN_DHAMEDH = 62

    let MANICHAEAN_FIVE = 63

    let MANICHAEAN_GIMEL = 64

    let MANICHAEAN_HETH = 65

    let MANICHAEAN_HUNDRED = 66

    let MANICHAEAN_KAPH = 67

    let MANICHAEAN_LAMEDH = 68

    let MANICHAEAN_MEM = 69

    let MANICHAEAN_NUN = 70

    let MANICHAEAN_ONE = 71

    let MANICHAEAN_PE = 72

    let MANICHAEAN_QOPH = 73

    let MANICHAEAN_RESH = 74

    let MANICHAEAN_SADHE = 75

    let MANICHAEAN_SAMEKH = 76

    let MANICHAEAN_TAW = 77

    let MANICHAEAN_TEN = 78

    let MANICHAEAN_TETH = 79

    let MANICHAEAN_THAMEDH = 80

    let MANICHAEAN_TWENTY = 81

    let MANICHAEAN_WAW = 82

    let MANICHAEAN_YODH = 83

    let MANICHAEAN_ZAYIN = 84

    let STRAIGHT_WAW = 85

    let AFRICAN_FEH = 86

    let AFRICAN_NOON = 87

    let AFRICAN_QAF = 88

    let MALAYALAM_BHA = 89

    let MALAYALAM_JA = 90

    let MALAYALAM_LLA = 91

    let MALAYALAM_LLLA = 92

    let MALAYALAM_NGA = 93

    let MALAYALAM_NNA = 94

    let MALAYALAM_NNNA = 95

    let MALAYALAM_NYA = 96

    let MALAYALAM_RA = 97

    let MALAYALAM_SSA = 98

    let MALAYALAM_TTA = 99

    let HANIFI_ROHINGYA_KINNA_YA = 100

    let HANIFI_ROHINGYA_PA = 101

    let THIN_YEH = 102

    let VERTICAL_TAIL = 103

    
    let COUNT = 104
}

public interface UCharacter_GraphemeClusterBreak {
    let OTHER = 0

    let CONTROL = 1

    let CR = 2

    let EXTEND = 3

    let L = 4

    let LF = 5

    let LV = 6

    let LVT = 7

    let T = 8

    let V = 9

    let SPACING_MARK = 10

    let PREPEND = 11

    let REGIONAL_INDICATOR = 12

    let E_BASE = 13

    let E_BASE_GAZ = 14

    let E_MODIFIER = 15

    let GLUE_AFTER_ZWJ = 16

    let ZWJ = 17

    
    let COUNT = 18
}

public interface UCharacter_WordBreak {
    let OTHER = 0

    let ALETTER = 1

    let FORMAT = 2

    let KATAKANA = 3

    let MIDLETTER = 4

    let MIDNUM = 5

    let NUMERIC = 6

    let EXTENDNUMLET = 7

    let CR = 8

    let EXTEND = 9

    let LF = 10

    let MIDNUMLET = 11

    let NEWLINE = 12

    let REGIONAL_INDICATOR = 13

    let HEBREW_LETTER = 14

    let SINGLE_QUOTE = 15

    let DOUBLE_QUOTE = 16

    let E_BASE = 17

    let E_BASE_GAZ = 18

    let E_MODIFIER = 19

    let GLUE_AFTER_ZWJ = 20

    let ZWJ = 21

    let WSEGSPACE = 22

    
    let COUNT = 23
}

public interface UCharacter_SentenceBreak {
    let OTHER = 0

    let ATERM = 1

    let CLOSE = 2

    let FORMAT = 3

    let LOWER = 4

    let NUMERIC = 5

    let OLETTER = 6

    let SEP = 7

    let SP = 8

    let STERM = 9

    let UPPER = 10

    let CR = 11

    let EXTEND = 12

    let LF = 13

    let SCONTINUE = 14

    
    let COUNT = 15
}

public interface UCharacter_LineBreak {
    let UNKNOWN = 0

    let AMBIGUOUS = 1

    let ALPHABETIC = 2

    let BREAK_BOTH = 3

    let BREAK_AFTER = 4

    let BREAK_BEFORE = 5

    let MANDATORY_BREAK = 6

    let CONTINGENT_BREAK = 7

    let CLOSE_PUNCTUATION = 8

    let COMBINING_MARK = 9

    let CARRIAGE_RETURN = 10

    let EXCLAMATION = 11

    let GLUE = 12

    let HYPHEN = 13

    let IDEOGRAPHIC = 14

    let INSEPERABLE = 15

    let INSEPARABLE = 15

    let INFIX_NUMERIC = 16

    let LINE_FEED = 17

    let NONSTARTER = 18

    let NUMERIC = 19

    let OPEN_PUNCTUATION = 20

    let POSTFIX_NUMERIC = 21

    let PREFIX_NUMERIC = 22

    let QUOTATION = 23

    let COMPLEX_CONTEXT = 24

    let SURROGATE = 25

    let SPACE = 26

    let BREAK_SYMBOLS = 27

    let ZWSPACE = 28

    let NEXT_LINE = 29

    let WORD_JOINER = 30

    let H2 = 31

    let H3 = 32

    let JL = 33

    let JT = 34

    let JV = 35

    let CLOSE_PARENTHESIS = 36

    let CONDITIONAL_JAPANESE_STARTER = 37

    let HEBREW_LETTER = 38

    let REGIONAL_INDICATOR = 39

    let E_BASE = 40

    let E_MODIFIER = 41

    let ZWJ = 42

    let AKSARA = 43

    let AKSARA_PREBASE = 44

    let AKSARA_START = 45

    let VIRAMA_FINAL = 46

    let VIRAMA = 47

    
    let COUNT = 48
}

public interface UCharacter_NumericType {
    let NONE = 0

    let DECIMAL = 1

    let DIGIT = 2

    let NUMERIC = 3

    
    let COUNT = 4
}

public interface UCharacter_HangulSyllableType {
    let NOT_APPLICABLE = 0

    let LEADING_JAMO = 1

    let VOWEL_JAMO = 2

    let TRAILING_JAMO = 3

    let LV_SYLLABLE = 4

    let LVT_SYLLABLE = 5

    
    let COUNT = 6
}

public interface UCharacter_BidiPairedBracketType {
    let NONE = 0

    let OPEN = 1

    let CLOSE = 2

    
    let COUNT = 3
}

public interface UCharacter_IndicPositionalCategory {
    let NA = 0

    let BOTTOM = 1

    let BOTTOM_AND_LEFT = 2

    let BOTTOM_AND_RIGHT = 3

    let LEFT = 4

    let LEFT_AND_RIGHT = 5

    let OVERSTRUCK = 6

    let RIGHT = 7

    let TOP = 8

    let TOP_AND_BOTTOM = 9

    let TOP_AND_BOTTOM_AND_RIGHT = 10

    let TOP_AND_LEFT = 11

    let TOP_AND_LEFT_AND_RIGHT = 12

    let TOP_AND_RIGHT = 13

    let VISUAL_ORDER_LEFT = 14

    let TOP_AND_BOTTOM_AND_LEFT = 15
}

public interface UCharacter_IndicSyllabicCategory {
    let OTHER = 0

    let AVAGRAHA = 1

    let BINDU = 2

    let BRAHMI_JOINING_NUMBER = 3

    let CANTILLATION_MARK = 4

    let CONSONANT = 5

    let CONSONANT_DEAD = 6

    let CONSONANT_FINAL = 7

    let CONSONANT_HEAD_LETTER = 8

    let CONSONANT_INITIAL_POSTFIXED = 9

    let CONSONANT_KILLER = 10

    let CONSONANT_MEDIAL = 11

    let CONSONANT_PLACEHOLDER = 12

    let CONSONANT_PRECEDING_REPHA = 13

    let CONSONANT_PREFIXED = 14

    let CONSONANT_SUBJOINED = 15

    let CONSONANT_SUCCEEDING_REPHA = 16

    let CONSONANT_WITH_STACKER = 17

    let GEMINATION_MARK = 18

    let INVISIBLE_STACKER = 19

    let JOINER = 20

    let MODIFYING_LETTER = 21

    let NON_JOINER = 22

    let NUKTA = 23

    let NUMBER = 24

    let NUMBER_JOINER = 25

    let PURE_KILLER = 26

    let REGISTER_SHIFTER = 27

    let SYLLABLE_MODIFIER = 28

    let TONE_LETTER = 29

    let TONE_MARK = 30

    let VIRAMA = 31

    let VISARGA = 32

    let VOWEL = 33

    let VOWEL_DEPENDENT = 34

    let VOWEL_INDEPENDENT = 35
}

public interface UCharacter_VerticalOrientation {
    let ROTATED = 0

    let TRANSFORMED_ROTATED = 1

    let TRANSFORMED_UPRIGHT = 2

    let UPRIGHT = 3
}

public class UCharacter_IdentifierStatus <: Enum<UCharacter_IdentifierStatus> {
    public static let RESTRICTED = UCharacter_IdentifierStatus("RESTRICTED", 0)

    public static let ALLOWED = UCharacter_IdentifierStatus("ALLOWED", 1)

    private static func _values(): Array<UCharacter_IdentifierStatus> {
        return [UCharacter_IdentifierStatus.RESTRICTED, UCharacter_IdentifierStatus.ALLOWED]
    }

    private static let _VALUES = UCharacter_IdentifierStatus._values()

    public static func values(): Array<UCharacter_IdentifierStatus> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): UCharacter_IdentifierStatus {
        return (TypeInfo.of<UCharacter_IdentifierStatus>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as UCharacter_IdentifierStatus
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class UCharacter_IdentifierType <: Enum<UCharacter_IdentifierType> {
    public static let NOT_CHARACTER = UCharacter_IdentifierType("NOT_CHARACTER", 0)

    public static let DEPRECATED = UCharacter_IdentifierType("DEPRECATED", 1)

    public static let DEFAULT_IGNORABLE = UCharacter_IdentifierType("DEFAULT_IGNORABLE", 2)

    public static let NOT_NFKC = UCharacter_IdentifierType("NOT_NFKC", 3)

    public static let NOT_XID = UCharacter_IdentifierType("NOT_XID", 4)

    public static let EXCLUSION = UCharacter_IdentifierType("EXCLUSION", 5)

    public static let OBSOLETE = UCharacter_IdentifierType("OBSOLETE", 6)

    public static let TECHNICAL = UCharacter_IdentifierType("TECHNICAL", 7)

    public static let UNCOMMON_USE = UCharacter_IdentifierType("UNCOMMON_USE", 8)

    public static let LIMITED_USE = UCharacter_IdentifierType("LIMITED_USE", 9)

    public static let INCLUSION = UCharacter_IdentifierType("INCLUSION", 10)

    public static let RECOMMENDED = UCharacter_IdentifierType("RECOMMENDED", 11)

    private static func _values(): Array<UCharacter_IdentifierType> {
        return [UCharacter_IdentifierType.NOT_CHARACTER, UCharacter_IdentifierType.DEPRECATED, UCharacter_IdentifierType.DEFAULT_IGNORABLE, UCharacter_IdentifierType.NOT_NFKC, UCharacter_IdentifierType.NOT_XID, UCharacter_IdentifierType.EXCLUSION, UCharacter_IdentifierType.OBSOLETE, UCharacter_IdentifierType.TECHNICAL, UCharacter_IdentifierType.UNCOMMON_USE, UCharacter_IdentifierType.LIMITED_USE, UCharacter_IdentifierType.INCLUSION, UCharacter_IdentifierType.RECOMMENDED]
    }

    private static let _VALUES = UCharacter_IdentifierType._values()

    public static func values(): Array<UCharacter_IdentifierType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): UCharacter_IdentifierType {
        return (TypeInfo.of<UCharacter_IdentifierType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as UCharacter_IdentifierType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class UCharacter_UCharacterTypeIterator <: RangeValueIterator {
    init() {
        reset()
    }

    public override func next(element: RangeValueIterator_Element): Bool {
        if (trieIterator.hasNext() && !(match (0) { case _ => range = trieIterator.next(); range }).leadSurrogate) {
            element.start = range.startCodePoint
            element.limit = range.endCodePoint + 1
            element.value = range.value
            return true
        } else {
            return false
        }
    }

    public override func reset(): Unit {
        trieIterator = UCharacterProperty.INSTANCE.m_trie_.iterator(MASK_TYPE)
    }

    private var trieIterator: Iterator<Trie2_Range>

    private var range: Trie2_Range

    private static let MASK_TYPE = UCharacter_UCharacterTypeIterator_MaskType()
}


class UCharacter_UCharacterTypeIterator_MaskType <: Trie2_ValueMapper {

    public override func map(value: Int32): Int32 {
        return value & UCharacterProperty.TYPE_MASK
    }
}


class UCharacter_DummyValueIterator <: ValueIterator {

    public override func next(element: ValueIterator_Element): Bool {
        return false
    }

    public override func reset(): Unit { }

    public override func setRange(start: Int32, limit: Int32): Unit { }
}
