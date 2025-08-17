package icu4cj.impl.number.parse

public class ParsingUtils {

    public static let PARSE_FLAG_IGNORE_CASE = 1

    public static let PARSE_FLAG_MONETARY_SEPARATORS = 2

    public static let PARSE_FLAG_STRICT_SEPARATORS = 4

    public static let PARSE_FLAG_STRICT_GROUPING_SIZE = 8

    public static let PARSE_FLAG_INTEGER_ONLY = 16

    public static let PARSE_FLAG_GROUPING_DISABLED = 32

    public static let PARSE_FLAG_INCLUDE_UNPAIRED_AFFIXES = 128

    public static let PARSE_FLAG_USE_FULL_AFFIXES = 256

    public static let PARSE_FLAG_EXACT_AFFIX = 512

    public static let PARSE_FLAG_PLUS_SIGN_ALLOWED = 1024

    public static let PARSE_FLAG_FORCE_BIG_DECIMAL = 4096

    public static let PARSE_FLAG_NO_FOREIGN_CURRENCIES = 8192

    public static let PARSE_FLAG_ALLOW_INFINITE_RECURSION = 16384

    public static let PARSE_FLAG_STRICT_IGNORABLES = 32768

    public static let PARSE_FLAG_JAVA_COMPATIBILITY_IGNORABLES = 65536

    public static func putLeadCodePoints(input: UnicodeSet, output: UnicodeSet): Unit {
        for (range in input.ranges()) {
            output.add(range.codepoint, range.codepointEnd)
        }
        for (str in input.stringsMethod()) {
            if (!str.isEmpty()) {
                output.add(str.codePointAt(0))
            }
        }
    }

    public static func putLeadCodePoint(input: String, output: UnicodeSet): Unit {
        if (!input.isEmpty()) {
            output.add(input.codePointAt(0))
        }
    }
}
