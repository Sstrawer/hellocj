package icu4cj.lang

public abstract class UProperty {
    
    public static let UNDEFINED = -1
    
    public static let ALPHABETIC = 0
    
    public static let BINARY_START = ALPHABETIC
    
    public static let ASCII_HEX_DIGIT = 1

    public static let BIDI_CONTROL = 2

    public static let BIDI_MIRRORED = 3

    public static let DASH = 4

    public static let DEFAULT_IGNORABLE_CODE_POINT = 5

    public static let DEPRECATED = 6

    public static let DIACRITIC = 7

    public static let EXTENDER = 8

    public static let FULL_COMPOSITION_EXCLUSION = 9

    public static let GRAPHEME_BASE = 10

    public static let GRAPHEME_EXTEND = 11

    public static let GRAPHEME_LINK = 12

    public static let HEX_DIGIT = 13

    public static let HYPHEN = 14

    public static let ID_CONTINUE = 15

    public static let ID_START = 16

    public static let IDEOGRAPHIC = 17

    public static let IDS_BINARY_OPERATOR = 18

    public static let IDS_TRINARY_OPERATOR = 19

    public static let JOIN_CONTROL = 20

    public static let LOGICAL_ORDER_EXCEPTION = 21

    public static let LOWERCASE = 22

    public static let MATH = 23

    public static let NONCHARACTER_CODE_POINT = 24

    public static let QUOTATION_MARK = 25

    public static let RADICAL = 26

    public static let SOFT_DOTTED = 27

    public static let TERMINAL_PUNCTUATION = 28

    public static let UNIFIED_IDEOGRAPH = 29

    public static let UPPERCASE = 30

    public static let WHITE_SPACE = 31

    public static let XID_CONTINUE = 32

    public static let XID_START = 33

    public static let CASE_SENSITIVE = 34

    public static let S_TERM = 35

    public static let VARIATION_SELECTOR = 36

    public static let NFD_INERT = 37

    public static let NFKD_INERT = 38

    public static let NFC_INERT = 39

    public static let NFKC_INERT = 40

    public static let SEGMENT_STARTER = 41

    public static let PATTERN_SYNTAX = 42

    public static let PATTERN_WHITE_SPACE = 43

    public static let POSIX_ALNUM = 44

    public static let POSIX_BLANK = 45

    public static let POSIX_GRAPH = 46

    public static let POSIX_PRINT = 47

    public static let POSIX_XDIGIT = 48

    public static let CASED = 49

    public static let CASE_IGNORABLE = 50

    public static let CHANGES_WHEN_LOWERCASED = 51

    public static let CHANGES_WHEN_UPPERCASED = 52

    public static let CHANGES_WHEN_TITLECASED = 53

    public static let CHANGES_WHEN_CASEFOLDED = 54

    public static let CHANGES_WHEN_CASEMAPPED = 55

    public static let CHANGES_WHEN_NFKC_CASEFOLDED = 56

    public static let EMOJI = 57

    public static let EMOJI_PRESENTATION = 58

    public static let EMOJI_MODIFIER = 59

    public static let EMOJI_MODIFIER_BASE = 60

    public static let EMOJI_COMPONENT = 61

    public static let REGIONAL_INDICATOR = 62

    public static let PREPENDED_CONCATENATION_MARK = 63

    public static let EXTENDED_PICTOGRAPHIC = 64

    public static let BASIC_EMOJI = 65

    public static let EMOJI_KEYCAP_SEQUENCE = 66

    public static let RGI_EMOJI_MODIFIER_SEQUENCE = 67

    public static let RGI_EMOJI_FLAG_SEQUENCE = 68

    public static let RGI_EMOJI_TAG_SEQUENCE = 69

    public static let RGI_EMOJI_ZWJ_SEQUENCE = 70

    public static let RGI_EMOJI = 71

    public static let IDS_UNARY_OPERATOR = 72

    public static let ID_COMPAT_MATH_START = 73

    public static let ID_COMPAT_MATH_CONTINUE = 74

    
    public static let BINARY_LIMIT = 75

    public static let BIDI_CLASS = 4096

    public static let INT_START = BIDI_CLASS

    public static let BLOCK = 4097

    public static let CANONICAL_COMBINING_CLASS = 4098

    public static let DECOMPOSITION_TYPE = 4099

    public static let EAST_ASIAN_WIDTH = 4100

    public static let GENERAL_CATEGORY = 4101

    public static let JOINING_GROUP = 4102

    public static let JOINING_TYPE = 4103

    public static let LINE_BREAK = 4104

    public static let NUMERIC_TYPE = 4105

    public static let SCRIPT = 4106

    public static let HANGUL_SYLLABLE_TYPE = 4107

    public static let NFD_QUICK_CHECK = 4108

    public static let NFKD_QUICK_CHECK = 4109

    public static let NFC_QUICK_CHECK = 4110

    public static let NFKC_QUICK_CHECK = 4111

    public static let LEAD_CANONICAL_COMBINING_CLASS = 4112

    public static let TRAIL_CANONICAL_COMBINING_CLASS = 4113

    public static let GRAPHEME_CLUSTER_BREAK = 4114

    public static let SENTENCE_BREAK = 4115

    public static let WORD_BREAK = 4116

    public static let BIDI_PAIRED_BRACKET_TYPE = 4117

    public static let INDIC_POSITIONAL_CATEGORY = 4118

    public static let INDIC_SYLLABIC_CATEGORY = 4119

    public static let VERTICAL_ORIENTATION = 4120

    public static let IDENTIFIER_STATUS = 4121

    
    public static let INT_LIMIT = 4122

    public static let GENERAL_CATEGORY_MASK = 8192

    public static let MASK_START = GENERAL_CATEGORY_MASK

    
    public static let MASK_LIMIT = 8193

    public static let NUMERIC_VALUE = 12288

    public static let DOUBLE_START = NUMERIC_VALUE

    
    public static let DOUBLE_LIMIT = 12289

    public static let AGE = 16384

    public static let STRING_START = AGE

    public static let BIDI_MIRRORING_GLYPH = 16385

    public static let CASE_FOLDING = 16386

    
    public static let ISO_COMMENT = 16387

    public static let LOWERCASE_MAPPING = 16388

    public static let NAME = 16389

    public static let SIMPLE_CASE_FOLDING = 16390

    public static let SIMPLE_LOWERCASE_MAPPING = 16391

    public static let SIMPLE_TITLECASE_MAPPING = 16392

    public static let SIMPLE_UPPERCASE_MAPPING = 16393

    public static let TITLECASE_MAPPING = 16394

    
    public static let UNICODE_1_NAME = 16395

    public static let UPPERCASE_MAPPING = 16396

    public static let BIDI_PAIRED_BRACKET = 16397

    
    public static let STRING_LIMIT = 16398

    public static let SCRIPT_EXTENSIONS = 28672

    public static let OTHER_PROPERTY_START = SCRIPT_EXTENSIONS

    public static let IDENTIFIER_TYPE = 28673

    
    public static let OTHER_PROPERTY_LIMIT = 28674
}

public interface UProperty_NameChoice {
    static let SHORT = 0

    static let LONG = 1

    
    static let COUNT = 2
}