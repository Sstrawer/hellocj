package icu4cj.lang


public class UCharacterEnums {
}


public interface UCharacterEnums_ECharacterCategory {
    public static let UNASSIGNED = 0u8

    public static let GENERAL_OTHER_TYPES = 0u8

    public static let UPPERCASE_LETTER = 1u8

    public static let LOWERCASE_LETTER = 2u8

    public static let TITLECASE_LETTER = 3u8

    public static let MODIFIER_LETTER = 4u8

    public static let OTHER_LETTER = 5u8

    public static let NON_SPACING_MARK = 6u8

    public static let ENCLOSING_MARK = 7u8

    public static let COMBINING_SPACING_MARK = 8u8

    public static let DECIMAL_DIGIT_NUMBER = 9u8

    public static let LETTER_NUMBER = 10u8

    public static let OTHER_NUMBER = 11u8

    public static let SPACE_SEPARATOR = 12u8

    public static let LINE_SEPARATOR = 13u8

    public static let PARAGRAPH_SEPARATOR = 14u8

    public static let CONTROL = 15u8

    public static let FORMAT = 16u8

    public static let PRIVATE_USE = 17u8

    public static let SURROGATE = 18u8

    public static let DASH_PUNCTUATION = 19u8

    public static let START_PUNCTUATION = 20u8

    public static let END_PUNCTUATION = 21u8

    public static let CONNECTOR_PUNCTUATION = 22u8

    public static let OTHER_PUNCTUATION = 23u8

    public static let MATH_SYMBOL = 24u8

    public static let CURRENCY_SYMBOL = 25u8

    public static let MODIFIER_SYMBOL = 26u8

    public static let OTHER_SYMBOL = 27u8

    public static let INITIAL_PUNCTUATION = 28u8

    public static let INITIAL_QUOTE_PUNCTUATION = 28u8

    public static let FINAL_PUNCTUATION = 29u8

    public static let FINAL_QUOTE_PUNCTUATION = 29u8

    public static let CHAR_CATEGORY_COUNT = 30u8
}

public interface UCharacterEnums_ECharacterDirection {
    public static let LEFT_TO_RIGHT = 0

    public static let DIRECTIONALITY_LEFT_TO_RIGHT = UInt8(LEFT_TO_RIGHT)

    public static let RIGHT_TO_LEFT = 1

    public static let DIRECTIONALITY_RIGHT_TO_LEFT = UInt8(RIGHT_TO_LEFT)

    public static let EUROPEAN_NUMBER = 2

    public static let DIRECTIONALITY_EUROPEAN_NUMBER = UInt8(EUROPEAN_NUMBER)

    public static let EUROPEAN_NUMBER_SEPARATOR = 3

    public static let DIRECTIONALITY_EUROPEAN_NUMBER_SEPARATOR = UInt8(EUROPEAN_NUMBER_SEPARATOR)

    public static let EUROPEAN_NUMBER_TERMINATOR = 4

    public static let DIRECTIONALITY_EUROPEAN_NUMBER_TERMINATOR = UInt8(EUROPEAN_NUMBER_TERMINATOR)

    public static let ARABIC_NUMBER = 5

    public static let DIRECTIONALITY_ARABIC_NUMBER = UInt8(ARABIC_NUMBER)

    public static let COMMON_NUMBER_SEPARATOR = 6

    public static let DIRECTIONALITY_COMMON_NUMBER_SEPARATOR = UInt8(COMMON_NUMBER_SEPARATOR)

    public static let BLOCK_SEPARATOR = 7

    public static let DIRECTIONALITY_PARAGRAPH_SEPARATOR = UInt8(BLOCK_SEPARATOR)

    public static let SEGMENT_SEPARATOR = 8

    public static let DIRECTIONALITY_SEGMENT_SEPARATOR = UInt8(SEGMENT_SEPARATOR)

    public static let WHITE_SPACE_NEUTRAL = 9

    public static let DIRECTIONALITY_WHITESPACE = UInt8(WHITE_SPACE_NEUTRAL)

    public static let OTHER_NEUTRAL = 10

    public static let DIRECTIONALITY_OTHER_NEUTRALS = UInt8(OTHER_NEUTRAL)

    public static let LEFT_TO_RIGHT_EMBEDDING = 11

    public static let DIRECTIONALITY_LEFT_TO_RIGHT_EMBEDDING = UInt8(LEFT_TO_RIGHT_EMBEDDING)

    public static let LEFT_TO_RIGHT_OVERRIDE = 12

    public static let DIRECTIONALITY_LEFT_TO_RIGHT_OVERRIDE = UInt8(LEFT_TO_RIGHT_OVERRIDE)

    public static let RIGHT_TO_LEFT_ARABIC = 13

    public static let DIRECTIONALITY_RIGHT_TO_LEFT_ARABIC = UInt8(RIGHT_TO_LEFT_ARABIC)

    public static let RIGHT_TO_LEFT_EMBEDDING = 14

    public static let DIRECTIONALITY_RIGHT_TO_LEFT_EMBEDDING = UInt8(RIGHT_TO_LEFT_EMBEDDING)

    public static let RIGHT_TO_LEFT_OVERRIDE = 15

    public static let DIRECTIONALITY_RIGHT_TO_LEFT_OVERRIDE = UInt8(RIGHT_TO_LEFT_OVERRIDE)

    public static let POP_DIRECTIONAL_FORMAT = 16

    public static let DIRECTIONALITY_POP_DIRECTIONAL_FORMAT = UInt8(POP_DIRECTIONAL_FORMAT)

    public static let DIR_NON_SPACING_MARK = 17

    public static let DIRECTIONALITY_NONSPACING_MARK = UInt8(DIR_NON_SPACING_MARK)

    public static let BOUNDARY_NEUTRAL = 18

    public static let DIRECTIONALITY_BOUNDARY_NEUTRAL = UInt8(BOUNDARY_NEUTRAL)

    public static let FIRST_STRONG_ISOLATE = 19u8

    public static let LEFT_TO_RIGHT_ISOLATE = 20u8

    public static let RIGHT_TO_LEFT_ISOLATE = 21u8

    public static let POP_DIRECTIONAL_ISOLATE = 22u8

    
    public static let CHAR_DIRECTION_COUNT = 23

    public static let DIRECTIONALITY_UNDEFINED = 255u8
}