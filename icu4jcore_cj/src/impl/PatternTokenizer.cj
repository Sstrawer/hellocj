package icu4cj.impl

public class PatternTokenizer {

    private var ignorableCharacters: UnicodeSet = UnicodeSet()

    private var syntaxCharacters: UnicodeSet = UnicodeSet()

    private var extraQuotingCharacters: UnicodeSet = UnicodeSet()

    private var escapeCharacters: UnicodeSet = UnicodeSet()

    private var usingSlash = false

    private var usingQuote = false

     private var needingQuoteCharacters: UnicodeSet

    private var start: Int32 = 0

    private var limit: Int32 = 0

    private var pattern: String

    public func getIgnorableCharacters(): UnicodeSet {
        return ignorableCharacters.clone()
    }

    public func setIgnorableCharacters(ignorableCharacters: UnicodeSet): PatternTokenizer {
        this.ignorableCharacters = ignorableCharacters.clone()
        needingQuoteCharacters = None
        return this
    }

    public func getSyntaxCharacters(): UnicodeSet {
        return syntaxCharacters.clone()
    }

    public func getExtraQuotingCharacters(): UnicodeSet {
        return extraQuotingCharacters.clone()
    }

    public func setSyntaxCharacters(syntaxCharacters: UnicodeSet): PatternTokenizer {
        this.syntaxCharacters = syntaxCharacters.clone()
        needingQuoteCharacters = None
        return this
    }

    public func setExtraQuotingCharacters(syntaxCharacters: UnicodeSet): PatternTokenizer {
        this.extraQuotingCharacters = syntaxCharacters.clone()
        needingQuoteCharacters = None
        return this
    }

    public func getEscapeCharacters(): UnicodeSet {
        return escapeCharacters.clone()
    }

    public func setEscapeCharacters(escapeCharacters: UnicodeSet): PatternTokenizer {
        this.escapeCharacters = escapeCharacters.clone()
        return this
    }

    public func isUsingQuote(): Bool {
        return usingQuote
    }

    public func setUsingQuote(usingQuote: Bool): PatternTokenizer {
        this.usingQuote = usingQuote
        needingQuoteCharacters = None
        return this
    }

    public func isUsingSlash(): Bool {
        return usingSlash
    }

    public func setUsingSlash(usingSlash: Bool): PatternTokenizer {
        this.usingSlash = usingSlash
        needingQuoteCharacters = None
        return this
    }

    public func getLimit(): Int32 {
        return limit
    }

    public func setLimit(limit: Int32): PatternTokenizer {
        this.limit = limit
        return this
    }

    public func getStart(): Int32 {
        return start
    }

    public func setStart(start: Int32): PatternTokenizer {
        this.start = start
        return this
    }

    public func setPattern(pattern: String): PatternTokenizer {
        return setPattern(toString(pattern))
    }

    public func setPattern(pattern: String): PatternTokenizer {
        if (pattern.isNone()) {
            throw IllegalArgumentException("Inconsistent arguments")
        }
        this.start = 0
        this.limit = Int32(pattern.size)
        this.pattern = pattern
        return this
    }

    public static let SINGLE_QUOTE = '''

    public static let BACK_SLASH = '\'

    private static var NO_QUOTE = -1

    private static var IN_QUOTE = -2

    public func quoteLiteral(string: String): String {
        return quoteLiteral(toString(string))
    }

    public func quoteLiteral(string: String): String {
        if (needingQuoteCharacters.isNone()) {
            needingQuoteCharacters = UnicodeSet().addAll(syntaxCharacters).addAll(ignorableCharacters).addAll(extraQuotingCharacters)
            if (usingSlash) {
                needingQuoteCharacters.add(Int32(UInt32(BACK_SLASH)))
            }
            if (usingQuote) {
                needingQuoteCharacters.add(Int32(UInt32(SINGLE_QUOTE)))
            }
        }
        let result = StringBuffer()
        var quotedChar = NO_QUOTE
        var cp: Int32 = 0
        var i = 0
        while (i < Int32(string.size)) {
            cp = UTF16.toRuneArray()[string, i]
            if (escapeCharacters.contains(cp)) {
                if (quotedChar == IN_QUOTE) {
                    result.append(SINGLE_QUOTE)
                    quotedChar = NO_QUOTE
                }
                appendEscaped(result, cp)
                continue
            }
            if (needingQuoteCharacters.contains(cp)) {
                if (quotedChar == IN_QUOTE) {
                    UTF16.append(result, cp)
                    if (usingQuote && cp == Int32(UInt32(SINGLE_QUOTE))) {
                        result.append(SINGLE_QUOTE)
                    }
                    continue
                }
                if (usingSlash) {
                    result.append(BACK_SLASH)
                    UTF16.append(result, cp)
                    continue
                }
                if (usingQuote) {
                    if (cp == Int32(UInt32(SINGLE_QUOTE))) {
                        result.append(SINGLE_QUOTE)
                        result.append(SINGLE_QUOTE)
                        continue
                    }
                    result.append(SINGLE_QUOTE)
                    UTF16.append(result, cp)
                    quotedChar = IN_QUOTE
                    continue
                }
                appendEscaped(result, cp)
                continue
            }
            if (quotedChar == IN_QUOTE) {
                result.append(SINGLE_QUOTE)
                quotedChar = NO_QUOTE
            }
            UTF16.append(result, cp)
            i += UTF16.getCharCount(cp)
        }
        if (quotedChar == IN_QUOTE) {
            result.append(SINGLE_QUOTE)
        }
        return toString(result)
    }

    private func appendEscaped(result: StringBuffer, cp: Int32): Unit {
        if (cp <= 65535) {
            result.append("\\u").append(Utility.hex(Int64(cp), 4))
        } else {
            result.append("\\U").append(Utility.hex(Int64(cp), 8))
        }
    }

    public func normalize(): String {
        let oldStart = start
        let result = StringBuffer()
        let buffer = StringBuffer()
        while (true) {
            buffer.setLength(0)
            let status = next(buffer)
            if (status == DONE) {
                start = oldStart
                return toString(result)
            }
            if (status != SYNTAX) {
                result.append(quoteLiteral(buffer))
            } else {
                result.append(buffer)
            }
        }
        throw Exception()
    }

    public static let DONE = 0

    public static let SYNTAX = 1

    public static let LITERAL = 2

    public static let BROKEN_QUOTE = 3

    public static let BROKEN_ESCAPE = 4

    public static let UNKNOWN = 5

    private static let AFTER_QUOTE = -1

    private static let NONE = 0

    private static let START_QUOTE = 1

    private static let NORMAL_QUOTE = 2

    private static let SLASH_START = 3

    private static let HEX = 4

    public func next(buffer: StringBuffer): Int32 {
        if (start >= limit) {
            return DONE
        }
        var status = UNKNOWN
        var lastQuote = UNKNOWN
        var quoteStatus = NONE
        var hexCount = 0
        var hexValue = 0
        var cp: Int32 = 0
                case 'U':
                    quoteStatus = HEX;
                    hexCount = 8;
                    hexValue = 0;
                    continue main;

                default:
                    if (usingSlash) {
                        UTF16.append(buffer, cp);
                        quoteStatus = NONE;
                        continue main;
                    } else {
                        buffer.append(BACK_SLASH);
                        quoteStatus = NONE;
                    }

                } -->
                case 4 =>
                    hexValue <<= 4
                    hexValue += cp
                    <-- Internal error: switch (cp) {
                    case '0':

                    case '1':

                    case '2':

                    case '3':

                    case '4':

                    case '5':

                    case '6':

                    case '7':

                    case '8':

                    case '9':
                        hexValue -= '0';
                        break;

                    case 'a':

                    case 'b':

                    case 'c':

                    case 'd':

                    case 'e':

                    case 'f':
                        hexValue -= 'a' - 10;
                        break;

                    case 'A':

                    case 'B':

                    case 'C':

                    case 'D':

                    case 'E':

                    case 'F':
                        hexValue -= 'A' - 10;
                        break;

                    default:
                        start = i;
                        return BROKEN_ESCAPE;

                    } -->
                    hexCount--
                    if (hexCount == 0) {
                        quoteStatus = NONE
                        UTF16.append(buffer, hexValue)
                    }
