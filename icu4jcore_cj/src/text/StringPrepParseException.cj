package icu4cj.text

public class StringPrepParseException <: ParseException {
    static let serialVersionUID = 7160264827701651255

    public static let INVALID_CHAR_FOUND = 0

    public static let ILLEGAL_CHAR_FOUND = 1

    public static let PROHIBITED_ERROR = 2

    public static let UNASSIGNED_ERROR = 3

    public static let CHECK_BIDI_ERROR = 4

    public static let STD3_ASCII_RULES_ERROR = 5

    public static let ACE_PREFIX_ERROR = 6

    public static let VERIFICATION_ERROR = 7

    public static let LABEL_TOO_LONG_ERROR = 8

    public static let BUFFER_OVERFLOW_ERROR = 9

    public static let ZERO_LENGTH_LABEL = 10

    public static let DOMAIN_NAME_TOO_LONG_ERROR = 11

    public init(message: String, error: Int32) {
        ParseException(message, -1)
        this.error = error
        this.line = 0
    }

    public init(message: String, error: Int32, rules: String, pos: Int32) {
        ParseException(message, -1)
        this.error = error
        setContext(rules, pos)
        this.line = 0
    }

    public init(message: String, error: Int32, rules: String, pos: Int32, lineNumber: Int32) {
        ParseException(message, -1)
        this.error = error
        setContext(rules, pos)
        this.line = lineNumber
    }

    public override func equals(other: Object): Bool {
        if (!(checkOptionalIs<StringPrepParseException, Object>(other))) {
            return false
        }
        return other.error == this.error
    }

    public override func hashCode(): Int64 {
        if (!false) {
            throw Exception("hashCode not designed")
        }
        return 42
    }

    public override func toString(): String {
        let buf = StringBuilder()
        buf.append(super.message)
        buf.append(". line:  ")
        buf.append(line)
        buf.append(". preContext:  ")
        buf.append(preContext)
        buf.append(". postContext: ")
        buf.append(postContext)
        buf.append("\n")
        return buf.toString()
    }

    private var error: Int32 = 0

    private var line: Int32 = 0

    private var preContext: StringBuffer = StringBuffer()

    private var postContext: StringBuffer = StringBuffer()

    private static let PARSE_CONTEXT_LEN = 16

    private func setPreContext(str: String, pos: Int32): Unit {
        setPreContext(str.toRuneArray(), pos)
    }

    private func setPreContext(str: Array<Char>, pos: Int32): Unit {
        let start = if (pos <= PARSE_CONTEXT_LEN) { 0 } else { (pos - (PARSE_CONTEXT_LEN - 1)) }
        let len = if (start <= PARSE_CONTEXT_LEN) { start } else { PARSE_CONTEXT_LEN }
        preContext.append(str, start, len)
    }

    private func setPostContext(str: String, pos: Int32): Unit {
        setPostContext(str.toRuneArray(), pos)
    }

    private func setPostContext(str: Array<Char>, pos: Int32): Unit {
        let start = pos
        let len = Int32(str.size) - start
        postContext.append(str, start, len)
    }

    private func setContext(str: String, pos: Int32): Unit {
        setPreContext(str, pos)
        setPostContext(str, pos)
    }

    public func getError(): Int32 {
        return error
    }
}
