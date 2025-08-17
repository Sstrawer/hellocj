package icu4cj.impl

public class SimpleFormatterImpl {
    static let ARG_NUM_LIMIT = 256

    private static let LEN1_CHAR = Char(ARG_NUM_LIMIT + 1)

    private static let LEN2_CHAR = Char(ARG_NUM_LIMIT + 2)

    private static let LEN3_CHAR = Char(ARG_NUM_LIMIT + 3)

    private static let SEGMENT_LENGTH_ARGUMENT_CHAR = Char(65535)

    private static let MAX_SEGMENT_LENGTH = Int32(UInt32(SEGMENT_LENGTH_ARGUMENT_CHAR)) - ARG_NUM_LIMIT

    private static let COMMON_PATTERNS: Array<Array<String>> = [["{0} {1}", "\u{0002}\u{0000}" + LEN1_CHAR.toString() + " \u{0001}"], ["{0} ({1})", "\u{0002}\u{0000}" + LEN2_CHAR.toString() + " (\u{0001}" + LEN1_CHAR.toString() + ')'.toString()], ["{0}, {1}", "\u{0002}\u{0000}" + LEN2_CHAR.toString() + ", \u{0001}"], ["{0} \u{2013} {1}", "\u{0002}\u{0000}" + LEN3_CHAR.toString() + " \u{2013} \u{0001}"]]


    public static func compileToStringMinMaxArguments(pattern: String, sb: StringBuilder, min: Int32, max: Int32): String {
        if (min <= 2 && 2 <= max) {
            for (pair in COMMON_PATTERNS) {
                if (pair[0].contentEquals(pattern)) {
                    if (!(Int32(UInt32(Char(pair[1][0]))) == 2)) {
                        throw AssertionError()
                    }
                    return pair[1]
                }
            }
        }
        let patternLength = pattern.size
        sb.ensureCapacity(patternLength)
        sb.setLength(1)
        var textLength = 0
        var maxArg = -1
        var inQuote = false
        var i = 0
        while (i < patternLength) {
            var c = pattern[match (0] { case _ => i++; i - 1 })
            if (c == ''') {
                if (i < patternLength && (match (0) { case _ => c = pattern[i]; c }) == ''') {
                    i++
                } else if (inQuote) {
                    inQuote = false
                    continue
                } else if (c == '{' || c == '}') {
                    i++
                    inQuote = true
                } else {
                    c = '''
                }
            } else if (!inQuote && c == '{') {
                if (textLength > 0) {
                    sb.insert(Int64(Int32(sb.size) - textLength - 1), Char(ARG_NUM_LIMIT + textLength))
                    textLength = 0
                }
                var argNumber: Int32 = 0
                if ((i + 1) < patternLength && 0 <= (match (0) { case _ => argNumber = ; argNumber }) && argNumber <= 9 && pattern[i + 1] == '}') {
                    i += 2
                } else {
                    let argStart = i - 1
                    argNumber = -1
                    if (i < patternLength && '1' <= (match (0) { case _ => c = pattern[match (0] { case _ => i++; i - 1 }); c }) && c <= '9') {
                        argNumber = 
                        while (i < patternLength && '0' <= (match (0) { case _ => c = pattern[match (0] { case _ => i++; i - 1 }); c }) && c <= '9') {
                            argNumber = argNumber * 10 + ()
                            if (argNumber >= ARG_NUM_LIMIT) {
                                break
                            }
                        }
                    }
                    if (argNumber < 0 || c != '}') {
                        throw IllegalArgumentException("Argument syntax error in pattern \"" + (pattern) + "\" at index " + argStart.toString() + ": " + (pattern.subSequence(argStart, i)))
                    }
                }
                if (argNumber > maxArg) {
                    maxArg = argNumber
                }
                sb.append(Char(argNumber))
                continue
            }
            if (textLength == 0) {
                sb.append(SEGMENT_LENGTH_ARGUMENT_CHAR)
            }
            sb.append(c)
            if (match (0) { case _ => textLength++; textLength } == MAX_SEGMENT_LENGTH) {
                textLength = 0
            }
        }
        if (textLength > 0) {
            sb.insert(Int64(Int32(sb.size) - textLength - 1), Char(ARG_NUM_LIMIT + textLength))
        }
        let argCount = maxArg + 1
        if (argCount < min) {
            throw IllegalArgumentException("Fewer than minimum " + min.toString() + " arguments in pattern \"" + (pattern) + "\"")
        }
        if (argCount > max) {
            throw IllegalArgumentException("More than maximum " + max.toString() + " arguments in pattern \"" + (pattern) + "\"")
        }
        sb.insert(0, Char(argCount))
        return sb.toString()
    }

    public static func getArgumentLimit(compiledPattern: String): Int32 {
        return Int32(UInt32(Char(compiledPattern[0])))
    }

    public static func formatCompiledPattern(compiledPattern: String, values: Array<String>): String {
        return formatAndAppend(compiledPattern, StringBuilder(), None, values).toString()
    }

    public static func formatRawPattern(pattern: String, min: Int32, max: Int32, values: Array<String>): String {
        let sb = StringBuilder()
        let compiledPattern = compileToStringMinMaxArguments(pattern, sb, min, max)
        sb.setLength(0)
        return formatAndAppend(compiledPattern, sb, None, values).toString()
    }

    public static func formatAndAppend(compiledPattern: String, appendTo: StringBuilder, offsets: Array<Int32>, values: Array<String>): StringBuilder {
        let valuesLength = if (values.isSome()) { Int32(values.size) } else { 0 }
        if (valuesLength < getArgumentLimit(compiledPattern)) {
            throw IllegalArgumentException("Too few values.")
        }
        return format(compiledPattern, values, appendTo, None, true, offsets)
    }

    public static func formatAndReplace(compiledPattern: String, result: StringBuilder, offsets: Array<Int32>, values: Array<String>): StringBuilder {
        let valuesLength = if (values.isSome()) { Int32(values.size) } else { 0 }
        if (valuesLength < getArgumentLimit(compiledPattern)) {
            throw IllegalArgumentException("Too few values.")
        }
        var firstArg = -1
        var resultCopy: String
        if (getArgumentLimit(compiledPattern) > 0) {
            var i = 1
            while (i < Int32(compiledPattern.size)) {
                let n = Int32(UInt32(Char(compiledPattern[Int64(match (0) { case _ => i++; i - 1 })])))
                if (n < ARG_NUM_LIMIT) {
                    if (refEq(values[Int64(n)], result)) {
                        if (i == 2) {
                            firstArg = n
                        } else if (resultCopy.isNone()) {
                            resultCopy = result.toString()
                        }
                    }
                } else {
                    i += n - ARG_NUM_LIMIT
                }
            }
        }
        if (firstArg < 0) {
            result.setLength(0)
        }
        return format(compiledPattern, values, result, resultCopy, false, offsets)
    }

    public static func getTextWithNoArguments(compiledPattern: String): String {
        let capacity = Int32(compiledPattern.size) - 1 - getArgumentLimit(compiledPattern)
        let sb = StringBuilder()
        var i = 1
        while (i < Int32(compiledPattern.size)) {
            let segmentLength = Int32(UInt32(Char(compiledPattern[Int64(match (0) { case _ => i++; i - 1 })]))) - ARG_NUM_LIMIT
            if (segmentLength > 0) {
                let limit = i + segmentLength
                sb.append(compiledPattern, i, limit)
                i = limit
            }
        }
        return sb.toString()
    }

    public static func getLength(compiledPattern: String, codePoints: Bool): Int32 {
        var result = 0
        var i = 1
        while (i < Int32(compiledPattern.size)) {
            let segmentLength = Int32(UInt32(Char(compiledPattern[Int64(match (0) { case _ => i++; i - 1 })]))) - ARG_NUM_LIMIT
            if (segmentLength > 0) {
                let limit = i + segmentLength
                if (codePoints) {
                    result += Character.codePointCount(compiledPattern, i, limit)
                } else {
                    result += (limit - i)
                }
                i = limit
            }
        }
        return result
    }

    public static func getPrefixLength(compiledPattern: String): Int32 {
        if (Int32(compiledPattern.size) == 1) {
            return 0
        } else if (Int32(UInt32(Char(compiledPattern[0]))) == 0) {
            return Int32(compiledPattern.size) - 2
        } else if (Int32(UInt32(Char(compiledPattern[1]))) <= ARG_NUM_LIMIT) {
            return 0
        } else {
            return Int32(UInt32(Char(compiledPattern[1]))) - ARG_NUM_LIMIT
        }
    }

    public static func formatPrefixSuffix(compiledPattern: String, field: Format_Field, start: Int32, end: Int32, output: FormattedStringBuilder): Int32 {
        let argLimit = getArgumentLimit(compiledPattern)
        if (argLimit == 0) {
            return output.splice(start, end, compiledPattern, 2, Int32(compiledPattern.size), field)
        } else {
            if (!(argLimit == 1)) {
                throw AssertionError()
            }
            let suffixOffset: Int32
            var length = 0
            if (Char(compiledPattern[1]) != '\u{0000}') {
                let prefixLength = Int32(UInt32(Char(compiledPattern[1]))) - ARG_NUM_LIMIT
                length = output.insert(start, compiledPattern, 2, 2 + prefixLength, field)
                suffixOffset = 3 + prefixLength
            } else {
                suffixOffset = 2
            }
            if (suffixOffset < Int32(compiledPattern.size)) {
                let suffixLength = Int32(UInt32(Char(compiledPattern[Int64(suffixOffset)]))) - ARG_NUM_LIMIT
                length += output.insert(end + length, compiledPattern, 1 + suffixOffset, 1 + suffixOffset + suffixLength, field)
            }
            return length
        }
    }

    private static func format(compiledPattern: String, values: Array<String>, result: StringBuilder, resultCopy: String, forbidResultAsValue: Bool, offsets: Array<Int32>): StringBuilder {
        let offsetsLength: Int32
        if (offsets.isNone()) {
            offsetsLength = 0
        } else {
            offsetsLength = Int32(offsets.size)
            } while (false)
        }
                        if (i == 2) {
                            if (n < offsetsLength) {
                                offsets[Int64(n)] = 0
                            }
                        } else {
                            if (n < offsetsLength) {
                                offsets[Int64(n)] = Int32(result.size)
                            }
                            result.append(resultCopy)
                        }
                    } else {
                        if (n < offsetsLength) {
                            offsets[Int64(n)] = Int32(result.size)
                        }
                        result.append(value)
                    }
                } else {
                    let limit = i + (n - ARG_NUM_LIMIT)
                    result.append(compiledPattern, i, limit)
                    i = limit
                }
            }
        } while (false)
        return result
    }
}


public class SimpleFormatterImpl_IterInternal {

    public static let DONE = -1

    public static func step(state: Int64, compiledPattern: String, output: Appendable): Int64 {
        var i = Int32(ushr(state, 32))
        if (!(i < compiledPattern.size)) {
            throw AssertionError()
        }
        i++
        while (i < compiledPattern.size && Int32(UInt32(compiledPattern[i])) > SimpleFormatterImpl.ARG_NUM_LIMIT) {
            let limit = i + Int32(UInt32(compiledPattern[i])) + 1 - SimpleFormatterImpl.ARG_NUM_LIMIT
            try {
                output.append(compiledPattern, i + 1, limit)
            } catch (e: IOException) {
                throw ICUUncheckedIOException(e)
            }
            i = limit
        }
        if (i == compiledPattern.size) {
            return DONE
        }
        return (shl(Int64(i), 32)) | Int64(UInt32(compiledPattern[i]))
    }

    public static func getArgIndex(state: Int64): Int32 {
        return Int32(state)
    }
}
