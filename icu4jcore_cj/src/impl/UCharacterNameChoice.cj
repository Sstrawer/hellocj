package icu4cj.impl

public interface UCharacterNameChoice {
    static let UNICODE_CHAR_NAME = 0

    static let OBSOLETE_UNUSED_UNICODE_10_CHAR_NAME = 1

    static let EXTENDED_CHAR_NAME = 2

    static let CHAR_NAME_ALIAS = 3

    static let CHAR_NAME_CHOICE_COUNT = 4

    static let ISO_COMMENT_ = CHAR_NAME_CHOICE_COUNT
}