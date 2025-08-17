package icu4cj.message2


class StringUtils {

    static func isContentChar(cp: Int32): Bool {
        return (cp >= 1 && cp <= 8) || (cp >= 11 && cp <= 12) || (cp >= 14 && cp <= 31) || (cp >= 33 && cp <= 45) || (cp >= 47 && cp <= 63) || (cp >= 65 && cp <= 91) || (cp >= 93 && cp <= 122) || (cp >= 126 && cp <= 55295) || (cp >= 57344 && cp <= 1114111)
    }

    static func isTextChar(cp: Int32): Bool {
        return isContentChar(cp) || isWhitespace(cp) || cp == Int32(UInt32('.')) || cp == Int32(UInt32('@')) || cp == Int32(UInt32('|'))
    }

    static func isBackslash(cp: Int32): Bool {
        return cp == Int32(UInt32('\''))
    }

    static func isWhitespace(cp: Int32): Bool {
        return cp == Int32(UInt32(' ')) || cp == Int32(UInt32('\t')) || cp == Int32(UInt32('\r')) || cp == Int32(UInt32('\n')) || cp == Int32(UInt32('\u{3000}'))
    }

    static func isNameStart(cp: Int32): Bool {
        return isAlpha(cp) || cp == Int32(UInt32('_')) || (cp >= 192 && cp <= 214) || (cp >= 216 && cp <= 246) || (cp >= 248 && cp <= 767) || (cp >= 880 && cp <= 893) || (cp >= 895 && cp <= 8191) || (cp >= 8204 && cp <= 8205) || (cp >= 8304 && cp <= 8591) || (cp >= 11264 && cp <= 12271) || (cp >= 12289 && cp <= 55295) || (cp >= 63744 && cp <= 64975) || (cp >= 65008 && cp <= 65532) || (cp >= 65536 && cp <= 983039)
    }

    static func isNameChar(cp: Int32): Bool {
        return isNameStart(cp) || isDigit(cp) || cp == Int32(UInt32('-')) || cp == Int32(UInt32('.')) || cp == 183 || (cp >= 768 && cp <= 879) || (cp >= 8255 && cp <= 8256)
    }

    static func isPrivateStart(cp: Int32): Bool {
        return cp == Int32(UInt32('^')) || cp == Int32(UInt32('&'))
    }

    static func isQuotedChar(cp: Int32): Bool {
        return isContentChar(cp) || isWhitespace(cp) || cp == Int32(UInt32('.')) || cp == Int32(UInt32('@')) || cp == Int32(UInt32('{')) || cp == Int32(UInt32('}'))
    }

    static func isReservedChar(cp: Int32): Bool {
        return isContentChar(cp) || cp == Int32(UInt32('.'))
    }

    static func isSimpleStartChar(cp: Int32): Bool {
        return StringUtils.isContentChar(cp) || StringUtils.isWhitespace(cp) || cp == Int32(UInt32('@')) || cp == Int32(UInt32('|'))
    }

    static func isAlpha(cp: Int32): Bool {
        return (cp >= Int32(UInt32('a')) && cp <= Int32(UInt32('z'))) || (cp >= Int32(UInt32('A')) && cp <= Int32(UInt32('Z')))
    }

    static func isDigit(cp: Int32): Bool {
        return cp >= Int32(UInt32('0')) && cp <= Int32(UInt32('9'))
    }

    static func isFunctionSigil(cp: Int32): Bool {
        return cp == Int32(UInt32(':'))
    }

    static func isPrivateAnnotationSigil(cp: Int32): Bool {
        return cp == Int32(UInt32('^')) || cp == Int32(UInt32('&'))
    }

    private static let RESERVED_ANNOTATION_SIGILS = "!%*+<>~"

    static func isReservedAnnotationSigil(cp: Int32): Bool {
        return indexOfWrap(RESERVED_ANNOTATION_SIGILS.indexOf(UInt8(cp))) != -1
    }
}
