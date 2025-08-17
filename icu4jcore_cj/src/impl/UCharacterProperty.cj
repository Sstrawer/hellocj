package icu4cj.impl


public class UCharacterProperty {
    public static let INSTANCE: UCharacterProperty

    public var m_trie_: Trie2_16

    public var m_unicodeVersion_: VersionInfo

    public static let LATIN_CAPITAL_LETTER_I_WITH_DOT_ABOVE_ = Char(304)

    public static let LATIN_SMALL_LETTER_DOTLESS_I_ = Char(305)

    public static let LATIN_SMALL_LETTER_I_ = Char(105)

    public static let TYPE_MASK = 31

    public static let SRC_NONE = 0

    public static let SRC_CHAR = 1

    public static let SRC_PROPSVEC = 2

    public static let SRC_NAMES = 3

    public static let SRC_CASE = 4

    public static let SRC_BIDI = 5

    public static let SRC_CHAR_AND_PROPSVEC = 6

    public static let SRC_CASE_AND_NORM = 7

    public static let SRC_NFC = 8

    public static let SRC_NFKC = 9

    public static let SRC_NFKC_CF = 10

    public static let SRC_NFC_CANON_ITER = 11

    public static let SRC_INPC = 12

    public static let SRC_INSC = 13

    public static let SRC_VO = 14

    public static let SRC_EMOJI = 15

    public static let SRC_IDSU = 16

    public static let SRC_ID_COMPAT_MATH = 17

    public static let SRC_COUNT = 18

    public func getProperty(ch: Int32): Int32 {
        return m_trie_.get(ch)
    }

    public func getAdditional(codepoint: Int32, column: Int32): Int32 {
        if (!(column >= 0)) {
            throw AssertionError()
        }
        if (column >= m_additionalColumnsCount_) {
            return 0
        }
        return m_additionalVectors_[Int64(m_additionalTrie_.get(codepoint) + column)]
    }

    static let MY_MASK = UCharacterProperty.TYPE_MASK & ((shl(1, Int32(UCharacterCategory.UPPERCASE_LETTER))) | (shl(1, Int32(UCharacterCategory.LOWERCASE_LETTER))) | (shl(1, Int32(UCharacterCategory.TITLECASE_LETTER))) | (shl(1, Int32(UCharacterCategory.MODIFIER_LETTER))) | (shl(1, Int32(UCharacterCategory.OTHER_LETTER))))

    public func getAge(codepoint: Int32): VersionInfo {
        let version = shr(getAdditional(codepoint, 0), AGE_SHIFT_)
        return VersionInfo.getInstance((shr(version, FIRST_NIBBLE_SHIFT_)) & LAST_NIBBLE_MASK_, version & LAST_NIBBLE_MASK_, 0, 0)
    }

    private static let GC_CN_MASK = getMask(Int32(UCharacter.UNASSIGNED))

    private static let GC_CC_MASK = getMask(Int32(UCharacter.CONTROL))

    private static let GC_CS_MASK = getMask(Int32(UCharacter.SURROGATE))

    private static let GC_ZS_MASK = getMask(Int32(UCharacter.SPACE_SEPARATOR))

    private static let GC_ZL_MASK = getMask(Int32(UCharacter.LINE_SEPARATOR))

    private static let GC_ZP_MASK = getMask(Int32(UCharacter.PARAGRAPH_SEPARATOR))

    private static let GC_Z_MASK = GC_ZS_MASK | GC_ZL_MASK | GC_ZP_MASK

    static func isgraphPOSIX(c: Int32): Bool {
        return (getMask(UCharacter.getType(c)) & (GC_CC_MASK | GC_CS_MASK | GC_CN_MASK | GC_Z_MASK)) == 0
    }

    static let ID_COMPAT_MATH_CONTINUE = [178, 179 + 1, 185, 185 + 1, 8304, 8304 + 1, 8308, 8318 + 1, 8320, 8334 + 1]

    static let ID_COMPAT_MATH_START = [8706, 8711, 8734, 120513, 120539, 120571, 120597, 120629, 120655, 120687, 120713, 120745, 120771]

    var binProps: Array<UCharacterProperty_BinaryProperty> = [UCharacterProperty_BinaryProperty(this, 1, (shl(1, ALPHABETIC_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, ASCII_HEX_DIGIT_PROPERTY_))), UCharacterProperty_1(this, SRC_BIDI), UCharacterProperty_2(this, SRC_BIDI), UCharacterProperty_BinaryProperty(this, 1, (shl(1, DASH_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, DEFAULT_IGNORABLE_CODE_POINT_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, DEPRECATED_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, DIACRITIC_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, EXTENDER_PROPERTY_))), UCharacterProperty_3(this, SRC_NFC), UCharacterProperty_BinaryProperty(this, 1, (shl(1, GRAPHEME_BASE_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, GRAPHEME_EXTEND_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, GRAPHEME_LINK_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, HEX_DIGIT_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, HYPHEN_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, ID_CONTINUE_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, ID_START_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, IDEOGRAPHIC_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, IDS_BINARY_OPERATOR_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, IDS_TRINARY_OPERATOR_PROPERTY_))), UCharacterProperty_4(this, SRC_BIDI), UCharacterProperty_BinaryProperty(this, 1, (shl(1, LOGICAL_ORDER_EXCEPTION_PROPERTY_))), UCharacterProperty_CaseBinaryProperty(this, UProperty.LOWERCASE), UCharacterProperty_BinaryProperty(this, 1, (shl(1, MATH_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, NONCHARACTER_CODE_POINT_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, QUOTATION_MARK_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, RADICAL_PROPERTY_))), UCharacterProperty_CaseBinaryProperty(this, UProperty.SOFT_DOTTED), UCharacterProperty_BinaryProperty(this, 1, (shl(1, TERMINAL_PUNCTUATION_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, UNIFIED_IDEOGRAPH_PROPERTY_))), UCharacterProperty_CaseBinaryProperty(this, UProperty.UPPERCASE), UCharacterProperty_BinaryProperty(this, 1, (shl(1, WHITE_SPACE_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, XID_CONTINUE_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, XID_START_PROPERTY_))), UCharacterProperty_CaseBinaryProperty(this, UProperty.CASE_SENSITIVE), UCharacterProperty_BinaryProperty(this, 1, (shl(1, S_TERM_PROPERTY_))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, VARIATION_SELECTOR_PROPERTY_))), UCharacterProperty_NormInertBinaryProperty(this, SRC_NFC, UProperty.NFD_INERT), UCharacterProperty_NormInertBinaryProperty(this, SRC_NFKC, UProperty.NFKD_INERT), UCharacterProperty_NormInertBinaryProperty(this, SRC_NFC, UProperty.NFC_INERT), UCharacterProperty_NormInertBinaryProperty(this, SRC_NFKC, UProperty.NFKC_INERT), UCharacterProperty_5(this, SRC_NFC_CANON_ITER), UCharacterProperty_BinaryProperty(this, 1, (shl(1, PATTERN_SYNTAX))), UCharacterProperty_BinaryProperty(this, 1, (shl(1, PATTERN_WHITE_SPACE))), UCharacterProperty_6(this, SRC_CHAR_AND_PROPSVEC), UCharacterProperty_7(this, SRC_CHAR), UCharacterProperty_8(this, SRC_CHAR), UCharacterProperty_9(this, SRC_CHAR), UCharacterProperty_10(this, SRC_CHAR), UCharacterProperty_CaseBinaryProperty(this, UProperty.CASED), UCharacterProperty_CaseBinaryProperty(this, UProperty.CASE_IGNORABLE), UCharacterProperty_CaseBinaryProperty(this, UProperty.CHANGES_WHEN_LOWERCASED), UCharacterProperty_CaseBinaryProperty(this, UProperty.CHANGES_WHEN_UPPERCASED), UCharacterProperty_CaseBinaryProperty(this, UProperty.CHANGES_WHEN_TITLECASED), UCharacterProperty_11(this, SRC_CASE_AND_NORM), UCharacterProperty_CaseBinaryProperty(this, UProperty.CHANGES_WHEN_CASEMAPPED), UCharacterProperty_12(this, SRC_NFKC_CF), UCharacterProperty_EmojiBinaryProperty(this, UProperty.EMOJI), UCharacterProperty_EmojiBinaryProperty(this, UProperty.EMOJI_PRESENTATION), UCharacterProperty_EmojiBinaryProperty(this, UProperty.EMOJI_MODIFIER), UCharacterProperty_EmojiBinaryProperty(this, UProperty.EMOJI_MODIFIER_BASE), UCharacterProperty_EmojiBinaryProperty(this, UProperty.EMOJI_COMPONENT), UCharacterProperty_13(this, SRC_PROPSVEC), UCharacterProperty_BinaryProperty(this, 1, shl(1, PREPENDED_CONCATENATION_MARK)), UCharacterProperty_EmojiBinaryProperty(this, UProperty.EXTENDED_PICTOGRAPHIC), UCharacterProperty_EmojiBinaryProperty(this, UProperty.BASIC_EMOJI), UCharacterProperty_EmojiBinaryProperty(this, UProperty.EMOJI_KEYCAP_SEQUENCE), UCharacterProperty_EmojiBinaryProperty(this, UProperty.RGI_EMOJI_MODIFIER_SEQUENCE), UCharacterProperty_EmojiBinaryProperty(this, UProperty.RGI_EMOJI_FLAG_SEQUENCE), UCharacterProperty_EmojiBinaryProperty(this, UProperty.RGI_EMOJI_TAG_SEQUENCE), UCharacterProperty_EmojiBinaryProperty(this, UProperty.RGI_EMOJI_ZWJ_SEQUENCE), UCharacterProperty_EmojiBinaryProperty(this, UProperty.RGI_EMOJI), UCharacterProperty_14(this, SRC_IDSU), UCharacterProperty_MathCompatBinaryProperty(this, UProperty.ID_COMPAT_MATH_START), UCharacterProperty_MathCompatBinaryProperty(this, UProperty.ID_COMPAT_MATH_CONTINUE)]

    public func hasBinaryProperty(c: Int32, which: Int32): Bool {
        if (which < UProperty.BINARY_START || UProperty.BINARY_LIMIT <= which) {
            return false
        } else {
            return binProps[Int64(which)].contains(c)
        }
    }

    public func getType(c: Int32): Int32 {
        return getProperty(c) & TYPE_MASK
    }

    static let gcbToHst = [UCharacter_HangulSyllableType.NOT_APPLICABLE, UCharacter_HangulSyllableType.NOT_APPLICABLE, UCharacter_HangulSyllableType.NOT_APPLICABLE, UCharacter_HangulSyllableType.NOT_APPLICABLE, UCharacter_HangulSyllableType.LEADING_JAMO, UCharacter_HangulSyllableType.NOT_APPLICABLE, UCharacter_HangulSyllableType.LV_SYLLABLE, UCharacter_HangulSyllableType.LVT_SYLLABLE, UCharacter_HangulSyllableType.TRAILING_JAMO, UCharacter_HangulSyllableType.VOWEL_JAMO]

    var intProps: Array<UCharacterProperty_IntProperty> = [UCharacterProperty_15(this), UCharacterProperty_IntProperty(this, 0, BLOCK_MASK_, BLOCK_SHIFT_), UCharacterProperty_16(this, SRC_NFC), UCharacterProperty_IntProperty(this, 2, DECOMPOSITION_TYPE_MASK_, 0), UCharacterProperty_IntProperty(this, 0, EAST_ASIAN_MASK_, EAST_ASIAN_SHIFT_), UCharacterProperty_17(this, SRC_CHAR), UCharacterProperty_18(this), UCharacterProperty_19(this), UCharacterProperty_IntProperty(this, 2, LB_MASK, LB_SHIFT), UCharacterProperty_20(this, SRC_CHAR), UCharacterProperty_21(this, SRC_PROPSVEC), UCharacterProperty_22(this, SRC_PROPSVEC), UCharacterProperty_NormQuickCheckIntProperty(this, SRC_NFC, UProperty.NFD_QUICK_CHECK, 1), UCharacterProperty_NormQuickCheckIntProperty(this, SRC_NFKC, UProperty.NFKD_QUICK_CHECK, 1), UCharacterProperty_NormQuickCheckIntProperty(this, SRC_NFC, UProperty.NFC_QUICK_CHECK, 2), UCharacterProperty_NormQuickCheckIntProperty(this, SRC_NFKC, UProperty.NFKC_QUICK_CHECK, 2), UCharacterProperty_23(this, SRC_NFC), UCharacterProperty_24(this, SRC_NFC), UCharacterProperty_IntProperty(this, 2, GCB_MASK, GCB_SHIFT), UCharacterProperty_IntProperty(this, 2, SB_MASK, SB_SHIFT), UCharacterProperty_IntProperty(this, 2, WB_MASK, WB_SHIFT), UCharacterProperty_25(this), UCharacterProperty_26(this, SRC_INPC), UCharacterProperty_27(this, SRC_INSC), UCharacterProperty_28(this, SRC_VO), UCharacterProperty_29(this, SRC_PROPSVEC)]

    public func getIntPropertyValue(c: Int32, which: Int32): Int32 {
        if (which < UProperty.INT_START) {
            if (UProperty.BINARY_START <= which && which < UProperty.BINARY_LIMIT) {
                return if (binProps[Int64(which)].contains(c)) { 1 } else { 0 }
            }
        } else if (which < UProperty.INT_LIMIT) {
            return intProps[Int64(which - UProperty.INT_START)].getValue(c)
        } else if (which == UProperty.GENERAL_CATEGORY_MASK) {
            return getMask(getType(c))
        }
        return 0
    }

    public func getIntPropertyMaxValue(which: Int32): Int32 {
        if (which < UProperty.INT_START) {
            if (UProperty.BINARY_START <= which && which < UProperty.BINARY_LIMIT) {
                return 1
            }
        } else if (which < UProperty.INT_LIMIT) {
            return intProps[Int64(which - UProperty.INT_START)].getMaxValue(which)
        }
        return -1
    }

    func getSource(which: Int32): Int32 {
        if (which < UProperty.BINARY_START) {
            return SRC_NONE
        } else if (which < UProperty.BINARY_LIMIT) {
            return binProps[Int64(which)].getSource()
        } else if (which < UProperty.INT_START) {
            return SRC_NONE
        } else if (which < UProperty.INT_LIMIT) {
            return intProps[Int64(which - UProperty.INT_START)].getSource()
        } else if (which < UProperty.STRING_START) {
            match (which) {
                case 8192 | 12288 => return SRC_CHAR
                case _ => return SRC_NONE
            }
        } else if (which < UProperty.STRING_LIMIT) {
            match (which) {
                case 16384 => return SRC_PROPSVEC
                case 16385 => return SRC_BIDI
                case 16386 | 16388 | 16390 | 16391 | 16392 | 16393 | 16394 | 16396 => return SRC_CASE
                case 16387 | 16389 | 16395 => return SRC_NAMES
                case _ => return SRC_NONE
            }
        } else {
            match (which) {
                case 28672 | 28673 => return SRC_PROPSVEC
                case _ => return SRC_NONE
            }
        }
    }

    public func getMaxValues(column: Int32): Int32 {
        match (column) {
            case 0 => return m_maxBlockScriptValue_
            case 2 => return m_maxJTGValue_
            case _ => return 0
        }
    }

    public static func getMask(Type: Int32): Int32 {
        return shl(1, Type)
    }

    public static func getEuropeanDigit(ch: Int32): Int32 {
        if ((ch > 122 && ch < 65313) || ch < 65 || (ch > 90 && ch < 97) || ch > 65370 || (ch > 65338 && ch < 65345)) {
            return -1
        }
        if (ch <= 122) {
            return ch + 10 - (if (ch <= 90) { 65 } else { 97 })
        }
        if (ch <= 65338) {
            return ch + 10 - 65313
        }
        return ch + 10 - 65345
    }

    public func digit(c: Int32): Int32 {
        let value = getNumericTypeValue(getProperty(c)) - NTV_DECIMAL_START_
        if (value <= 9) {
            return value
        } else {
            return -1
        }
    }

    public func getNumericValue(c: Int32): Int32 {
        let ntv = getNumericTypeValue(getProperty(c))
        if (ntv == NTV_NONE_) {
            return getEuropeanDigit(c)
        } else if (ntv < NTV_DIGIT_START_) {
            return ntv - NTV_DECIMAL_START_
        } else if (ntv < NTV_NUMERIC_START_) {
            return ntv - NTV_DIGIT_START_
        } else if (ntv < NTV_FRACTION_START_) {
            return ntv - NTV_NUMERIC_START_
        } else if (ntv < NTV_LARGE_START_) {
            return -2
        } else if (ntv < NTV_BASE60_START_) {
            let mant = (shr(ntv, 5)) - 14
            var exp = (ntv & 31) + 2
            if (exp < 9 || (exp == 9 && mant <= 2)) {
                var numValue = mant
                return numValue
            } else {
                return -2
            }
        } else if (ntv < NTV_FRACTION20_START_) {
            var numValue = (shr(ntv, 2)) - 191
            let exp = (ntv & 3) + 1
            match (exp) {
                case 4 => numValue *= 60 * 60 * 60 * 60
                case 3 => numValue *= 60 * 60 * 60
                case 2 => numValue *= 60 * 60
                case 1 => numValue *= 60
                case 0 => ()
                case _ => ()
            }
            return numValue
        } else if (ntv < NTV_RESERVED_START_) {
            return -2
        } else {
            return -2
        }
    }

    public func getUnicodeNumericValue(c: Int32): Float64 {
        let ntv = getNumericTypeValue(getProperty(c))
        if (ntv == NTV_NONE_) {
            return UCharacter.NO_NUMERIC_VALUE
        } else if (ntv < NTV_DIGIT_START_) {
            return Float64(ntv - NTV_DECIMAL_START_)
        } else if (ntv < NTV_NUMERIC_START_) {
            return Float64(ntv - NTV_DIGIT_START_)
        } else if (ntv < NTV_FRACTION_START_) {
            return Float64(ntv - NTV_NUMERIC_START_)
        } else if (ntv < NTV_LARGE_START_) {
            let numerator = (shr(ntv, 4)) - 12
            let denominator = (ntv & 15) + 1
            return Float64(numerator) / Float64(denominator)
        } else if (ntv < NTV_BASE60_START_) {
            var numValue: Float64 = 0.0
            let mant = (shr(ntv, 5)) - 14
            var exp = (ntv & 31) + 2
            numValue = Float64(mant)
            while (exp >= 4) {
                numValue *= 10000.0
                exp -= 4
            }
            match (exp) {
                case 3 => numValue *= 1000.0
                case 2 => numValue *= 100.0
                case 1 => numValue *= 10.0
                case 0 => ()
                case _ => ()
            }
            return numValue
        } else if (ntv < NTV_FRACTION20_START_) {
            var numValue = (shr(ntv, 2)) - 191
            let exp = (ntv & 3) + 1
            match (exp) {
                case 4 => numValue *= 60 * 60 * 60 * 60
                case 3 => numValue *= 60 * 60 * 60
                case 2 => numValue *= 60 * 60
                case 1 => numValue *= 60
                case 0 => ()
                case _ => ()
            }
            return Float64(numValue)
        } else if (ntv < NTV_FRACTION32_START_) {
            let frac20 = ntv - NTV_FRACTION20_START_
            let numerator = 2 * (frac20 & 3) + 1
            let denominator = shl(20, (shr(frac20, 2)))
            return Float64(numerator) / Float64(denominator)
        } else if (ntv < NTV_RESERVED_START_) {
            let frac32 = ntv - NTV_FRACTION32_START_
            let numerator = 2 * (frac32 & 3) + 1
            let denominator = shl(32, (shr(frac32, 2)))
            return Float64(numerator) / Float64(denominator)
        } else {
            return UCharacter.NO_NUMERIC_VALUE
        }
    }

    var m_additionalTrie_: Trie2_16

    var m_additionalVectors_: Array<Int32>

    var m_additionalColumnsCount_: Int32 = 0

    var m_maxBlockScriptValue_: Int32 = 0

    var m_maxJTGValue_: Int32 = 0

    public var m_scriptExtensions_: Array<Char>

    private static let DATA_FILE_NAME_ = "uprops.icu"

    private static let NUMERIC_TYPE_VALUE_SHIFT_ = 6

    static func getNumericTypeValue(props: Int32): Int32 {
        return shr(props, NUMERIC_TYPE_VALUE_SHIFT_)
    }

    private static let NTV_NONE_ = 0

    private static let NTV_DECIMAL_START_ = 1

    private static let NTV_DIGIT_START_ = 11

    private static let NTV_NUMERIC_START_ = 21

    private static let NTV_FRACTION_START_ = 176

    private static let NTV_LARGE_START_ = 480

    private static let NTV_BASE60_START_ = 768

    private static let NTV_FRACTION20_START_ = NTV_BASE60_START_ + 36

    private static let NTV_FRACTION32_START_ = NTV_FRACTION20_START_ + 24

    private static let NTV_RESERVED_START_ = NTV_FRACTION32_START_ + 16

    static func ntvGetType(ntv: Int32): Int32 {
        return if (ntv == NTV_NONE_) { UCharacter_NumericType.NONE } else { if (ntv < NTV_DIGIT_START_) { UCharacter_NumericType.DECIMAL } else { if (ntv < NTV_NUMERIC_START_) { UCharacter_NumericType.DIGIT } else { UCharacter_NumericType.NUMERIC } } }
    }

    public static let SCRIPT_X_MASK = 15728895

    public static let SCRIPT_HIGH_MASK = 3145728

    public static let SCRIPT_HIGH_SHIFT = 12

    public static let MAX_SCRIPT = 1023

    private static let EAST_ASIAN_MASK_ = 917504

    private static let EAST_ASIAN_SHIFT_ = 17

    private static let BLOCK_MASK_ = 130816

    private static let BLOCK_SHIFT_ = 8

    public static let SCRIPT_LOW_MASK = 255

    public static let SCRIPT_X_WITH_COMMON = 4194304

    public static let SCRIPT_X_WITH_INHERITED = 8388608

    public static let SCRIPT_X_WITH_OTHER = 12582912

    public static func mergeScriptCodeOrIndex(scriptX: Int32): Int32 {
        return (shr((scriptX & SCRIPT_HIGH_MASK), SCRIPT_HIGH_SHIFT)) | (scriptX & SCRIPT_LOW_MASK)
    }

    private static let WHITE_SPACE_PROPERTY_ = 0

    private static let DASH_PROPERTY_ = 1

    private static let HYPHEN_PROPERTY_ = 2

    private static let QUOTATION_MARK_PROPERTY_ = 3

    private static let TERMINAL_PUNCTUATION_PROPERTY_ = 4

    private static let MATH_PROPERTY_ = 5

    private static let HEX_DIGIT_PROPERTY_ = 6

    private static let ASCII_HEX_DIGIT_PROPERTY_ = 7

    private static let ALPHABETIC_PROPERTY_ = 8

    private static let IDEOGRAPHIC_PROPERTY_ = 9

    private static let DIACRITIC_PROPERTY_ = 10

    private static let EXTENDER_PROPERTY_ = 11

    private static let NONCHARACTER_CODE_POINT_PROPERTY_ = 12

    private static let GRAPHEME_EXTEND_PROPERTY_ = 13

    private static let GRAPHEME_LINK_PROPERTY_ = 14

    private static let IDS_BINARY_OPERATOR_PROPERTY_ = 15

    private static let IDS_TRINARY_OPERATOR_PROPERTY_ = 16

    private static let RADICAL_PROPERTY_ = 17

    private static let UNIFIED_IDEOGRAPH_PROPERTY_ = 18

    private static let DEFAULT_IGNORABLE_CODE_POINT_PROPERTY_ = 19

    private static let DEPRECATED_PROPERTY_ = 20

    private static let LOGICAL_ORDER_EXCEPTION_PROPERTY_ = 21

    private static let XID_START_PROPERTY_ = 22

    private static let XID_CONTINUE_PROPERTY_ = 23

    private static let ID_START_PROPERTY_ = 24

    private static let ID_CONTINUE_PROPERTY_ = 25

    private static let GRAPHEME_BASE_PROPERTY_ = 26

    private static let S_TERM_PROPERTY_ = 27

    private static let VARIATION_SELECTOR_PROPERTY_ = 28

    private static let PATTERN_SYNTAX = 29

    private static let PATTERN_WHITE_SPACE = 30

    private static let PREPENDED_CONCATENATION_MARK = 31

    static let ID_TYPE_SHIFT = 26

    private static let ID_TYPE_BIT = 128

    private static let ID_TYPE_EXCLUSION = 32

    private static let ID_TYPE_LIMITED_USE = 16

    private static let ID_TYPE_UNCOMMON_USE = 8

    private static let ID_TYPE_TECHNICAL = 4

    private static let ID_TYPE_OBSOLETE = 2

    private static let ID_TYPE_NOT_XID = 1

    private static let ID_TYPE_NOT_CHARACTER = 0

    private static let ID_TYPE_FORBIDDEN = ID_TYPE_EXCLUSION | ID_TYPE_LIMITED_USE

    private static let ID_TYPE_DEPRECATED = ID_TYPE_FORBIDDEN

    private static let ID_TYPE_DEFAULT_IGNORABLE = ID_TYPE_FORBIDDEN + 1

    private static let ID_TYPE_NOT_NFKC = ID_TYPE_FORBIDDEN + 2

    static let ID_TYPE_ALLOWED_MIN = ID_TYPE_FORBIDDEN + 12

    private static let ID_TYPE_INCLUSION = ID_TYPE_FORBIDDEN + 14

    private static let ID_TYPE_RECOMMENDED = ID_TYPE_FORBIDDEN + 15

    private static let idTypeToEncoded = [ID_TYPE_NOT_CHARACTER, ID_TYPE_DEPRECATED, ID_TYPE_DEFAULT_IGNORABLE, ID_TYPE_NOT_NFKC, ID_TYPE_BIT | ID_TYPE_NOT_XID, ID_TYPE_BIT | ID_TYPE_EXCLUSION, ID_TYPE_BIT | ID_TYPE_OBSOLETE, ID_TYPE_BIT | ID_TYPE_TECHNICAL, ID_TYPE_BIT | ID_TYPE_UNCOMMON_USE, ID_TYPE_BIT | ID_TYPE_LIMITED_USE, ID_TYPE_INCLUSION, ID_TYPE_RECOMMENDED]

    private static let LB_MASK = 66060288

    private static let LB_SHIFT = 20

    private static let SB_MASK = 1015808

    private static let SB_SHIFT = 15

    private static let WB_MASK = 31744

    private static let WB_SHIFT = 10

    static let GCB_MASK = 992

    static let GCB_SHIFT = 5

    private static let DECOMPOSITION_TYPE_MASK_ = 31

    private static let FIRST_NIBBLE_SHIFT_ = 4

    private static let LAST_NIBBLE_MASK_ = 15

    private static let AGE_SHIFT_ = 24

    private init() {
        if (Int32(binProps.size) != UProperty.BINARY_LIMIT) {
            throw ICUException("binProps.length!=UProperty.BINARY_LIMIT")
        }
        if (Int32(intProps.size) != (UProperty.INT_LIMIT - UProperty.INT_START)) {
            throw ICUException("intProps.length!=(UProperty.INT_LIMIT-UProperty.INT_START)")
        }
        let bytes = ICUBinary.getRequiredData(DATA_FILE_NAME_)
        m_unicodeVersion_ = ICUBinary.readHeaderAndDataVersion(bytes, DATA_FORMAT, UCharacterProperty_IsAcceptable())
        let propertyOffset = bytes.getInt()
        bytes.getInt()
        bytes.getInt()
        let additionalOffset = bytes.getInt()
        let additionalVectorsOffset = bytes.getInt()
        m_additionalColumnsCount_ = bytes.getInt()
        let scriptExtensionsOffset = bytes.getInt()
        let reservedOffset7 = bytes.getInt()
        bytes.getInt()
        bytes.getInt()
        m_maxBlockScriptValue_ = bytes.getInt()
        m_maxJTGValue_ = bytes.getInt()
        ICUBinary.skipBytes(bytes, shl((16 - 12), 2))
        m_trie_ = Trie2_16.createFromSerialized(bytes)
        var expectedTrieLength = (propertyOffset - 16) * 4
        var trieLength = m_trie_.getSerializedLength()
        if (trieLength > expectedTrieLength) {
            throw IOException("uprops.icu: not enough bytes for main trie")
        }
        ICUBinary.skipBytes(bytes, expectedTrieLength - trieLength)
        ICUBinary.skipBytes(bytes, (additionalOffset - propertyOffset) * 4)
        if (m_additionalColumnsCount_ > 0) {
            m_additionalTrie_ = Trie2_16.createFromSerialized(bytes)
            expectedTrieLength = (additionalVectorsOffset - additionalOffset) * 4
            trieLength = m_additionalTrie_.getSerializedLength()
            if (trieLength > expectedTrieLength) {
                throw IOException("uprops.icu: not enough bytes for additional-properties trie")
            }
            ICUBinary.skipBytes(bytes, expectedTrieLength - trieLength)
            let size = scriptExtensionsOffset - additionalVectorsOffset
            m_additionalVectors_ = ICUBinary.getInts(bytes, size, 0)
        }
        let numChars = (reservedOffset7 - scriptExtensionsOffset) * 2
        if (numChars > 0) {
            m_scriptExtensions_ = ICUBinary.getChars(bytes, numChars, 0)
        }
    }

    private static let DATA_FORMAT = 1431335535

    private static let TAB = 9

    private static let CR = 13

    private static let U_A = 65

    private static let U_F = 70

    private static let U_Z = 90

    private static let U_a = 97

    private static let U_f = 102

    private static let U_z = 122

    private static let DEL = 127

    private static let NL = 133

    private static let NBSP = 160

    private static let CGJ = 847

    private static let FIGURESP = 8199

    private static let HAIRSP = 8202

    private static let RLM = 8207

    private static let NNBSP = 8239

    private static let WJ = 8288

    private static let INHSWAP = 8298

    private static let NOMDIG = 8303

    private static let U_FW_A = 65313

    private static let U_FW_F = 65318

    private static let U_FW_Z = 65338

    private static let U_FW_a = 65345

    private static let U_FW_f = 65350

    private static let U_FW_z = 65370

    private static let ZWNBSP = 65279

    public func addPropertyStarts(set: UnicodeSet): UnicodeSet {
        let trieIterator = m_trie_.iterator()
        var range: Trie2_Range
        while (trieIterator.hasNext() && !(match (0) { case _ => range = trieIterator.next(); range }).leadSurrogate) {
            set.add(range.startCodePoint)
        }
        set.add(TAB)
        set.add(TAB + 1)
        set.add(CR + 1)
        set.add(28)
        set.add(31 + 1)
        set.add(NL)
        set.add(NL + 1)
        set.add(DEL)
        set.add(HAIRSP)
        set.add(RLM + 1)
        set.add(INHSWAP)
        set.add(NOMDIG + 1)
        set.add(ZWNBSP)
        set.add(ZWNBSP + 1)
        set.add(NBSP)
        set.add(NBSP + 1)
        set.add(FIGURESP)
        set.add(FIGURESP + 1)
        set.add(NNBSP)
        set.add(NNBSP + 1)
        set.add(12295)
        set.add(12296)
        set.add(19968)
        set.add(19969)
        set.add(20108)
        set.add(20109)
        set.add(19977)
        set.add(19978)
        set.add(22235)
        set.add(22236)
        set.add(20116)
        set.add(20117)
        set.add(20845)
        set.add(20846)
        set.add(19971)
        set.add(19972)
        set.add(20843)
        set.add(20844)
        set.add(20061)
        set.add(20062)
        set.add(U_a)
        set.add(U_z + 1)
        set.add(U_A)
        set.add(U_Z + 1)
        set.add(U_FW_a)
        set.add(U_FW_z + 1)
        set.add(U_FW_A)
        set.add(U_FW_Z + 1)
        set.add(U_f + 1)
        set.add(U_F + 1)
        set.add(U_FW_f + 1)
        set.add(U_FW_F + 1)
        set.add(WJ)
        set.add(65520)
        set.add(65531 + 1)
        set.add(917504)
        set.add(921599 + 1)
        set.add(CGJ)
        set.add(CGJ + 1)
        return set
    }

    public func upropsvec_addPropertyStarts(set: UnicodeSet): Unit {
        if (m_additionalColumnsCount_ > 0) {
            let trieIterator = m_additionalTrie_.iterator()
            var range: Trie2_Range
            while (trieIterator.hasNext() && !(match (0) { case _ => range = trieIterator.next(); range }).leadSurrogate) {
                set.add(range.startCodePoint)
            }
        }
    }

    static func ulayout_addPropertyStarts(src: Int32, set: UnicodeSet): UnicodeSet {
        return UCharacterProperty_LayoutProps.INSTANCE.addPropertyStarts(src, set)
    }

    static func mathCompat_addPropertyStarts(set: UnicodeSet): Unit {
        for (c in ID_COMPAT_MATH_CONTINUE) {
            set.add(c)
        }
        for (c in ID_COMPAT_MATH_START) {
            set.add(c)
            set.add(c + 1)
        }
    }

    public func hasIDType(c: Int32, typeIndex: Int32): Bool {
        if (typeIndex < 0 || typeIndex >= Int32(idTypeToEncoded.size)) {
            return false
        }
        let encodedType = idTypeToEncoded[Int64(typeIndex)]
        let value = ushr(getAdditional(c, 2), ID_TYPE_SHIFT)
        if ((encodedType & ID_TYPE_BIT) != 0) {
            return value < ID_TYPE_FORBIDDEN && (value & encodedType) != 0
        } else {
            return value == encodedType
        }
    }

    public func hasIDType(c: Int32, Type: UCharacter_IdentifierType): Bool {
        return hasIDType(c, Type.ordinal)
    }

    private static func maybeAddType(value: Int32, bit: Int32, t: UCharacter_IdentifierType, types: EnumSet): Unit {
        if ((value & bit) != 0) {
            types.add(t)
        }
    }

    public func getIDTypes(c: Int32, types: EnumSet): Int32 {
        types.clear()
        let value = ushr(getAdditional(c, 2), ID_TYPE_SHIFT)
        if ((value & ID_TYPE_FORBIDDEN) == ID_TYPE_FORBIDDEN || value == ID_TYPE_NOT_CHARACTER) {
            let t: UCharacter_IdentifierType
            match (value) {
                case 0 => t = UCharacter_IdentifierType.NOT_CHARACTER
                case 48 => t = UCharacter_IdentifierType.DEPRECATED
                case 49 => t = UCharacter_IdentifierType.DEFAULT_IGNORABLE
                case 50 => t = UCharacter_IdentifierType.NOT_NFKC
                case 62 => t = UCharacter_IdentifierType.INCLUSION
                case 63 => t = UCharacter_IdentifierType.RECOMMENDED
                case _ => throw Exception(String.format("unknown IdentifierType data value 0x%02x", [value]))
            }
            types.add(t)
            return 1
        } else {
            maybeAddType(value, ID_TYPE_NOT_XID, UCharacter_IdentifierType.NOT_XID, types)
            maybeAddType(value, ID_TYPE_EXCLUSION, UCharacter_IdentifierType.EXCLUSION, types)
            maybeAddType(value, ID_TYPE_OBSOLETE, UCharacter_IdentifierType.OBSOLETE, types)
            maybeAddType(value, ID_TYPE_TECHNICAL, UCharacter_IdentifierType.TECHNICAL, types)
            maybeAddType(value, ID_TYPE_UNCOMMON_USE, UCharacter_IdentifierType.UNCOMMON_USE, types)
            maybeAddType(value, ID_TYPE_LIMITED_USE, UCharacter_IdentifierType.LIMITED_USE, types)
            return Int32(types.size)
        }
    }

}


class UCharacterProperty_LayoutProps {
    private static let IS_ACCEPTABLE = UCharacterProperty_LayoutProps_IsAcceptable()

    private static let DATA_FORMAT = 1281456495

    private static let IX_INPC_TRIE_TOP = 1

    private static let IX_INSC_TRIE_TOP = 2

    private static let IX_VO_TRIE_TOP = 3

    private static let IX_MAX_VALUES = 9

    private static let MAX_INPC_SHIFT = 24

    private static let MAX_INSC_SHIFT = 16

    private static let MAX_VO_SHIFT = 8

    static let INSTANCE = UCharacterProperty_LayoutProps()

    var inpcTrie: CodePointTrie

    var inscTrie: CodePointTrie

    var voTrie: CodePointTrie

    var maxInpcValue = 0

    var maxInscValue = 0

    var maxVoValue = 0

    init() {
        let bytes = ICUBinary.getRequiredData("ulayout.icu")
        try {
            ICUBinary.readHeaderAndDataVersion(bytes, DATA_FORMAT, IS_ACCEPTABLE)
            let startPos = bytes.position()
            let indexesLength = bytes.getInt()
            if (indexesLength < 12) {
                throw ICUUncheckedIOException("Text layout properties data: not enough indexes")
            }
            let inIndexes = Array<Int32>(Int64(indexesLength)) { _ => 0 }
            inIndexes[0] = indexesLength
            var i = 1
            while (i < indexesLength) {
                inIndexes[Int64(i)] = bytes.getInt()
                i++
            }
            var offset = indexesLength * 4
            var top = inIndexes[Int64(IX_INPC_TRIE_TOP)]
            var trieSize = top - offset
            if (trieSize >= 16) {
                inpcTrie = CodePointTrie.fromBinary(None, None, bytes)
            }
            var pos = bytes.position() - startPos
            if (!(top >= pos)) {
                throw AssertionError()
            }
            ICUBinary.skipBytes(bytes, top - pos)
            offset = top
            top = inIndexes[Int64(IX_INSC_TRIE_TOP)]
            trieSize = top - offset
            if (trieSize >= 16) {
                inscTrie = CodePointTrie.fromBinary(None, None, bytes)
            }
            pos = bytes.position() - startPos
            if (!(top >= pos)) {
                throw AssertionError()
            }
            ICUBinary.skipBytes(bytes, top - pos)
            offset = top
            top = inIndexes[Int64(IX_VO_TRIE_TOP)]
            trieSize = top - offset
            if (trieSize >= 16) {
                voTrie = CodePointTrie.fromBinary(None, None, bytes)
            }
            pos = bytes.position() - startPos
            if (!(top >= pos)) {
                throw AssertionError()
            }
            ICUBinary.skipBytes(bytes, top - pos)
            let maxValues = inIndexes[Int64(IX_MAX_VALUES)]
            maxInpcValue = ushr(maxValues, MAX_INPC_SHIFT)
            maxInscValue = (shr(maxValues, MAX_INSC_SHIFT)) & 255
            maxVoValue = (shr(maxValues, MAX_VO_SHIFT)) & 255
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public func addPropertyStarts(src: Int32, set: UnicodeSet): UnicodeSet {
        let trie: CodePointTrie
        match (src) {
            case 12 => trie = inpcTrie
            case 13 => trie = inscTrie
            case 14 => trie = voTrie
            case _ => throw Exception()
        }
        if (trie.isNone()) {
            throw MissingResourceException("no data for one of the text layout properties; src=" + src.toString(), "LayoutProps", "")
        }
        let range = CodePointMap_Range()
        var start = 0
        while (trie.getRange(start, None, range)) {
            set.add(start)
            start = range.getEnd() + 1
        }
        return set
    }
}


class UCharacterProperty_LayoutProps_IsAcceptable <: ICUBinary_Authenticate {

    public override func isDataVersionAcceptable(version: Array<UInt8>): Bool {
        return Int32(version[0]) == 1
    }
}


class UCharacterProperty_BinaryProperty {
    let this_0: UCharacterProperty

    var column: Int32 = 0

    var mask: Int32 = 0

    init(this_0: UCharacterProperty, column: Int32, mask: Int32) {
        this.this_0 = this_0
        this.column = column
        this.mask = mask
    }

    init(this_0: UCharacterProperty, source: Int32) {
        this.this_0 = this_0
        this.column = source
        this.mask = 0
    }

    func getSource(): Int32 {
        return if (mask == 0) { column } else { UCharacterProperty.SRC_PROPSVEC }
    }

    public func contains(c: Int32): Bool {
        return (this_0.getAdditional(c, column) & mask) != 0
    }
}


class UCharacterProperty_CaseBinaryProperty <: UCharacterProperty_BinaryProperty {
    var which: Int32 = 0

    init(this_0: UCharacterProperty, which: Int32) {
        super(this_0, UCharacterProperty.SRC_CASE)
        this.which = which
    }

    public override func contains(c: Int32): Bool {
        return UCaseProps.INSTANCE.hasBinaryProperty(c, which)
    }
}


class UCharacterProperty_EmojiBinaryProperty <: UCharacterProperty_BinaryProperty {
    var which: Int32 = 0

    init(this_0: UCharacterProperty, which: Int32) {
        super(this_0, UCharacterProperty.SRC_EMOJI)
        this.which = which
    }

    public override func contains(c: Int32): Bool {
        return EmojiProps.INSTANCE.hasBinaryProperty(c, which)
    }
}


class UCharacterProperty_NormInertBinaryProperty <: UCharacterProperty_BinaryProperty {
    var which: Int32 = 0

    init(this_0: UCharacterProperty, source: Int32, which: Int32) {
        super(this_0, source)
        this.which = which
    }

    public override func contains(c: Int32): Bool {
        return Norm2AllModes.getN2WithImpl(which - UProperty.NFD_INERT).isInert(c)
    }
}


class UCharacterProperty_MathCompatBinaryProperty <: UCharacterProperty_BinaryProperty {
    var which: Int32 = 0

    init(this_0: UCharacterProperty, which: Int32) {
        super(this_0, UCharacterProperty.SRC_ID_COMPAT_MATH)
        this.which = which
    }

    public override func contains(c: Int32): Bool {
        if (which == UProperty.ID_COMPAT_MATH_CONTINUE) {
            var i = 0
            while (i < Int32(UCharacterProperty.ID_COMPAT_MATH_CONTINUE.size)) {
                if (c < UCharacterProperty.ID_COMPAT_MATH_CONTINUE[Int64(i)]) {
                    return false
                }
                if (c < UCharacterProperty.ID_COMPAT_MATH_CONTINUE[Int64(i + 1)]) {
                    return true
                }
                i += 2
            }
        }
        if (c < UCharacterProperty.ID_COMPAT_MATH_START[0]) {
            return false
        }
        for (startChar in UCharacterProperty.ID_COMPAT_MATH_START) {
            if (c == startChar) {
                return true
            }
        }
        return false
    }
}


class UCharacterProperty_1 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        return UBiDiProps.INSTANCE.isBidiControl(c)
    }
}


class UCharacterProperty_2 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        return UBiDiProps.INSTANCE.isMirrored(c)
    }
}


class UCharacterProperty_3 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        let impl = Norm2AllModes.getNFCInstance().impl
        return impl.isCompNo(impl.getNorm16(c))
    }
}


class UCharacterProperty_4 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        return UBiDiProps.INSTANCE.isJoinControl(c)
    }
}


class UCharacterProperty_5 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        return Norm2AllModes.getNFCInstance().impl.ensureCanonIterData().isCanonSegmentStarter(c)
    }
}


class UCharacterProperty_6 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        return UCharacter.isUAlphabetic(c) || UCharacter.isDigit(c)
    }
}


class UCharacterProperty_7 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        if (c <= 159) {
            return c == 9 || c == 32
        } else {
            return UCharacter.getType(c) == Int32(UCharacter.SPACE_SEPARATOR)
        }
    }
}


class UCharacterProperty_8 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        return UCharacterProperty.isgraphPOSIX(c)
    }
}


class UCharacterProperty_9 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        return (UCharacter.getType(c) == Int32(UCharacter.SPACE_SEPARATOR)) || UCharacterProperty.isgraphPOSIX(c)
    }
}


class UCharacterProperty_10 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        if ((c <= 102 && c >= 65 && (c <= 70 || c >= 97)) || (c >= 65313 && c <= 65350 && (c <= 65318 || c >= 65345))) {
            return true
        }
        return UCharacter.getType(c) == Int32(UCharacter.DECIMAL_DIGIT_NUMBER)
    }
}


class UCharacterProperty_11 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        var tempc = c
        let nfd = Norm2AllModes.getNFCInstance().impl.getDecomposition(tempc)
        if (nfd.isSome()) {
            tempc = nfd.codePointAt(0)
            if (Character.charCount(tempc) != Int32(nfd.size)) {
                tempc = -1
            }
        } else if (tempc < 0) {
            return false
        }
        if (tempc >= 0) {
            let csp = UCaseProps.INSTANCE
            UCaseProps.dummyStringBuilder.setLength(0)
            return csp.toFullFolding(tempc, UCaseProps.dummyStringBuilder as Appendable, UCharacter.FOLD_CASE_DEFAULT) >= 0
        } else {
            let folded = UCharacter.foldCase(nfd, true)
            return !folded.equals(nfd)
        }
    }
}


class UCharacterProperty_12 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        let kcf = Norm2AllModes.getNFKC_CFInstance().impl
        let src = UTF16.valueOf(c)
        let dest = StringBuilder()
        let buffer = Normalizer2Impl_ReorderingBuffer(kcf, dest as Appendable, 5)
        kcf.compose(src, 0, Int32(src.size), false, true, buffer)
        return !Normalizer2Impl_UTF16Plus.equal(dest.toString(), src)
    }
}


class UCharacterProperty_13 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        return 127462 <= c && c <= 127487
    }
}


class UCharacterProperty_14 <: UCharacterProperty_BinaryProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func contains(c: Int32): Bool {
        return 12286 <= c && c <= 12287
    }
}


class UCharacterProperty_IntProperty {
    let this_0: UCharacterProperty

    var column: Int32 = 0

    var mask: Int32 = 0

    var shift: Int32 = 0

    init(this_0: UCharacterProperty, column: Int32, mask: Int32, shift: Int32) {
        this.this_0 = this_0
        this.column = column
        this.mask = mask
        this.shift = shift
    }

    init(this_0: UCharacterProperty, source: Int32) {
        this.this_0 = this_0
        this.column = source
        this.mask = 0
    }

    func getSource(): Int32 {
        return if (mask == 0) { column } else { UCharacterProperty.SRC_PROPSVEC }
    }

    public func getValue(c: Int32): Int32 {
        return ushr((this_0.getAdditional(c, column) & mask), shift)
    }

    public func getMaxValue(which: Int32): Int32 {
        return ushr((this_0.getMaxValues(column) & mask), shift)
    }
}


class UCharacterProperty_BiDiIntProperty <: UCharacterProperty_IntProperty {
    init(this_0: UCharacterProperty) {
        super(this_0, UCharacterProperty.SRC_BIDI)
    }

    public override func getMaxValue(which: Int32): Int32 {
        return UBiDiProps.INSTANCE.getMaxValue(which)
    }
}


class UCharacterProperty_CombiningClassIntProperty <: UCharacterProperty_IntProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func getMaxValue(which: Int32): Int32 {
        return 255
    }
}


class UCharacterProperty_NormQuickCheckIntProperty <: UCharacterProperty_IntProperty {
    var which: Int32 = 0

    var max: Int32 = 0

    init(this_0: UCharacterProperty, source: Int32, which: Int32, max: Int32) {
        super(this_0, source)
        this.which = which
        this.max = max
    }

    public override func getValue(c: Int32): Int32 {
        return Norm2AllModes.getN2WithImpl(which - UProperty.NFD_QUICK_CHECK).getQuickCheck(c)
    }

    public override func getMaxValue(which: Int32): Int32 {
        return max
    }
}


class UCharacterProperty_15 <: UCharacterProperty_BiDiIntProperty {
    init(this_0: UCharacterProperty) {
        super(this_0)
    }

    public override func getValue(c: Int32): Int32 {
        return UBiDiProps.INSTANCE.getClass(c)
    }
}


class UCharacterProperty_16 <: UCharacterProperty_CombiningClassIntProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func getValue(c: Int32): Int32 {
        return Normalizer2.getNFDInstance().getCombiningClass(c)
    }
}


class UCharacterProperty_17 <: UCharacterProperty_IntProperty {
    let this_0: UCharacterProperty

    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
        this.this_0 = this_0
    }

    public override func getValue(c: Int32): Int32 {
        return this_0.getType(c)
    }

    public override func getMaxValue(which: Int32): Int32 {
        return Int32(UCharacterCategory.CHAR_CATEGORY_COUNT) - 1
    }
}


class UCharacterProperty_18 <: UCharacterProperty_BiDiIntProperty {
    init(this_0: UCharacterProperty) {
        super(this_0)
    }

    public override func getValue(c: Int32): Int32 {
        return UBiDiProps.INSTANCE.getJoiningGroup(c)
    }
}


class UCharacterProperty_19 <: UCharacterProperty_BiDiIntProperty {
    init(this_0: UCharacterProperty) {
        super(this_0)
    }

    public override func getValue(c: Int32): Int32 {
        return UBiDiProps.INSTANCE.getJoiningType(c)
    }
}


class UCharacterProperty_20 <: UCharacterProperty_IntProperty {
    let this_0: UCharacterProperty

    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
        this.this_0 = this_0
    }

    public override func getValue(c: Int32): Int32 {
        return UCharacterProperty.ntvGetType(UCharacterProperty.getNumericTypeValue(this_0.getProperty(c)))
    }

    public override func getMaxValue(which: Int32): Int32 {
        return UCharacter_NumericType.COUNT - 1
    }
}


class UCharacterProperty_21 <: UCharacterProperty_IntProperty {
    let this_0: UCharacterProperty

    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
        this.this_0 = this_0
    }

    public override func getValue(c: Int32): Int32 {
        return UScript.getScript(c)
    }

    public override func getMaxValue(which: Int32): Int32 {
        let scriptX = this_0.getMaxValues(0) & UCharacterProperty.SCRIPT_X_MASK
        return UCharacterProperty.mergeScriptCodeOrIndex(scriptX)
    }
}


class UCharacterProperty_22 <: UCharacterProperty_IntProperty {
    let this_0: UCharacterProperty

    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
        this.this_0 = this_0
    }

    public override func getValue(c: Int32): Int32 {
        let gcb = ushr((this_0.getAdditional(c, 2) & UCharacterProperty.GCB_MASK), UCharacterProperty.GCB_SHIFT)
        if (gcb < Int32(UCharacterProperty.gcbToHst.size)) {
            return UCharacterProperty.gcbToHst[Int64(gcb)]
        } else {
            return UCharacter_HangulSyllableType.NOT_APPLICABLE
        }
    }

    public override func getMaxValue(which: Int32): Int32 {
        return UCharacter_HangulSyllableType.COUNT - 1
    }
}


class UCharacterProperty_23 <: UCharacterProperty_CombiningClassIntProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func getValue(c: Int32): Int32 {
        return shr(Norm2AllModes.getNFCInstance().impl.getFCD16(c), 8)
    }
}


class UCharacterProperty_24 <: UCharacterProperty_CombiningClassIntProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func getValue(c: Int32): Int32 {
        return Norm2AllModes.getNFCInstance().impl.getFCD16(c) & 255
    }
}


class UCharacterProperty_25 <: UCharacterProperty_BiDiIntProperty {
    init(this_0: UCharacterProperty) {
        super(this_0)
    }

    public override func getValue(c: Int32): Int32 {
        return UBiDiProps.INSTANCE.getPairedBracketType(c)
    }
}


class UCharacterProperty_26 <: UCharacterProperty_IntProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func getValue(c: Int32): Int32 {
        let trie = UCharacterProperty_LayoutProps.INSTANCE.inpcTrie
        return if (trie.isSome()) { trie.get(c) } else { 0 }
    }

    public override func getMaxValue(which: Int32): Int32 {
        return UCharacterProperty_LayoutProps.INSTANCE.maxInpcValue
    }
}


class UCharacterProperty_27 <: UCharacterProperty_IntProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func getValue(c: Int32): Int32 {
        let trie = UCharacterProperty_LayoutProps.INSTANCE.inscTrie
        return if (trie.isSome()) { trie.get(c) } else { 0 }
    }

    public override func getMaxValue(which: Int32): Int32 {
        return UCharacterProperty_LayoutProps.INSTANCE.maxInscValue
    }
}


class UCharacterProperty_28 <: UCharacterProperty_IntProperty {
    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
    }

    public override func getValue(c: Int32): Int32 {
        let trie = UCharacterProperty_LayoutProps.INSTANCE.voTrie
        return if (trie.isSome()) { trie.get(c) } else { 0 }
    }

    public override func getMaxValue(which: Int32): Int32 {
        return UCharacterProperty_LayoutProps.INSTANCE.maxVoValue
    }
}


class UCharacterProperty_29 <: UCharacterProperty_IntProperty {
    let this_0: UCharacterProperty

    init(this_0: UCharacterProperty, source: Int32) {
        super(this_0, source)
        this.this_0 = this_0
    }

    public override func getValue(c: Int32): Int32 {
        let value = ushr(this_0.getAdditional(c, 2), UCharacterProperty.ID_TYPE_SHIFT)
        return if (value >= UCharacterProperty.ID_TYPE_ALLOWED_MIN) { UCharacter_IdentifierStatus.ALLOWED.ordinal } else { UCharacter_IdentifierStatus.RESTRICTED.ordinal }
    }

    public override func getMaxValue(which: Int32): Int32 {
        return UCharacter_IdentifierStatus.ALLOWED.ordinal
    }
}


class UCharacterProperty_IsAcceptable <: ICUBinary_Authenticate {

    public override func isDataVersionAcceptable(version: Array<UInt8>): Bool {
        return Int32(version[0]) == 8
    }
}
