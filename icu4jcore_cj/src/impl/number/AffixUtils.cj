package icu4cj.impl.number


public class AffixUtils {

    private static let STATE_BASE = 0

    private static let STATE_FIRST_QUOTE = 1

    private static let STATE_INSIDE_QUOTE = 2

    private static let STATE_AFTER_QUOTE = 3

    private static let STATE_FIRST_CURR = 4

    private static let STATE_SECOND_CURR = 5

    private static let STATE_THIRD_CURR = 6

    private static let STATE_FOURTH_CURR = 7

    private static let STATE_FIFTH_CURR = 8

    private static let STATE_OVERFLOW_CURR = 9

    private static let TYPE_CODEPOINT = 0

    public static let TYPE_MINUS_SIGN = -1

    public static let TYPE_PLUS_SIGN = -2

    public static let TYPE_APPROXIMATELY_SIGN = -3

    public static let TYPE_PERCENT = -4

    public static let TYPE_PERMILLE = -5

    public static let TYPE_CURRENCY_SINGLE = -6

    public static let TYPE_CURRENCY_DOUBLE = -7

    public static let TYPE_CURRENCY_TRIPLE = -8

    public static let TYPE_CURRENCY_QUAD = -9

    public static let TYPE_CURRENCY_QUINT = -10

    public static let TYPE_CURRENCY_OVERFLOW = -15

    public static func estimateLength(patternString: String): Int32 {
        if (patternString.isNone()) {
            return 0
        }
        var state = STATE_BASE
        var offset = 0
        var length = 0
        while (offset < patternString.size) {
            let cp = Character.codePointAt(patternString, offset)
            match (state) {
                case 0 => if (cp == Int32(UInt32('\''))) {
                    state = STATE_FIRST_QUOTE
                } else {
                    length++
                }
                case 1 => if (cp == Int32(UInt32('\''))) {
                    length++
                    state = STATE_BASE
                } else {
                    length++
                    state = STATE_INSIDE_QUOTE
                }
                case 2 => if (cp == Int32(UInt32('\''))) {
                    state = STATE_AFTER_QUOTE
                } else {
                    length++
                }
                case 3 => if (cp == Int32(UInt32('\''))) {
                    length++
                    state = STATE_INSIDE_QUOTE
                } else {
                    length++
                }
                case _ => throw AssertionError()
            }
            offset += Character.charCount(cp)
        }
        match (state) {
            case 1 | 2 => throw IllegalArgumentException("Unterminated quote: \"" + (patternString) + "\"")
            case _ => ()
        }
        return length
    }

    public static func escape(input: String, output: StringBuilder): Int32 {
        if (input.isNone()) {
            return 0
        }
        var state = STATE_BASE
        var offset = 0
        let startLength = Int32(output.size)
        while (offset < input.size) {
            let cp = Character.codePointAt(input, offset)
            match (cp) {
                case Int32(UInt32('\'')) => {
                    output.append("''")
                }
                case Int32(UInt32('-')) | Int32(UInt32('+')) | Int32(UInt32('%')) | 8240 | 164 => {
                    if (state == STATE_BASE) {
                        output.append('\'')
                        output.appendCodePoint(cp)
                        state = STATE_INSIDE_QUOTE
                    } else {
                        output.appendCodePoint(cp)
                    }
                }
                case _ => {
                    if (state == STATE_INSIDE_QUOTE) {
                        output.append('\'')
                        output.appendCodePoint(cp)
                        state = STATE_BASE
                    } else {
                        output.appendCodePoint(cp)
                    }
                }
            }
            offset += Character.charCount(cp)
        }
        if (state == STATE_INSIDE_QUOTE) {
            output.append('\'')
        }
        return Int32(output.size) - startLength
    }

    public static func escape(input: String): String {
        if (input.isNone()) {
            return None
        }
        let sb = StringBuilder()
        escape(input, sb)
        return sb.toString()
    }

    public static func getFieldForType(Type: Int32): NumberFormat_Field {
        match (Type) {
            case -1 => return NumberFormat_Field.SIGN
            case -2 => return NumberFormat_Field.SIGN
            case -3 => return NumberFormat_Field.APPROXIMATELY_SIGN
            case -4 => return NumberFormat_Field.PERCENT
            case -5 => return NumberFormat_Field.PERMILLE
            case -6 => return NumberFormat_Field.CURRENCY
            case -7 => return NumberFormat_Field.CURRENCY
            case -8 => return NumberFormat_Field.CURRENCY
            case -9 => return NumberFormat_Field.CURRENCY
            case -10 => return NumberFormat_Field.CURRENCY
            case -15 => return NumberFormat_Field.CURRENCY
            case _ => throw AssertionError()
        }
    }

    public static func unescape(affixPattern: String, output: FormattedStringBuilder, position: Int32, provider: AffixUtils_SymbolProvider, field: NumberFormat_Field): Int32 {
        if (!affixPattern.isSome()) {
            throw AssertionError()
        }
        var length = 0
        var tag = 0
        while (hasNext(tag, affixPattern)) {
            tag = nextToken(tag, affixPattern)
            let typeOrCp = getTypeOrCp(tag)
            if (typeOrCp == TYPE_CURRENCY_OVERFLOW) {
                length += output.insertCodePoint(position + length, 65533, NumberFormat_Field.CURRENCY)
            } else if (typeOrCp < 0) {
                length += output.insert(position + length, provider.getSymbol(typeOrCp), getFieldForType(typeOrCp))
            } else {
                length += output.insertCodePoint(position + length, typeOrCp, field)
            }
        }
        return length
    }

    public static func unescapedCount(affixPattern: String, lengthOrCount: Bool, provider: AffixUtils_SymbolProvider): Int32 {
        var length = 0
        var tag = 0
        while (hasNext(tag, affixPattern)) {
            tag = nextToken(tag, affixPattern)
            let typeOrCp = getTypeOrCp(tag)
            if (typeOrCp == TYPE_CURRENCY_OVERFLOW) {
                length += 1
            } else if (typeOrCp < 0) {
                let symbol = provider.getSymbol(typeOrCp)
                length += if (lengthOrCount) { symbol.size } else { Character.codePointCount(symbol, 0, symbol.size) }
            } else {
                length += if (lengthOrCount) { Character.charCount(typeOrCp) } else { 1 }
            }
        }
        return length
    }

    public static func containsType(affixPattern: String, Type: Int32): Bool {
        if (affixPattern.isNone() || affixPattern.size == 0) {
            return false
        }
        var tag = 0
        while (hasNext(tag, affixPattern)) {
            tag = nextToken(tag, affixPattern)
            if (getTypeOrCp(tag) == Type) {
                return true
            }
        }
        return false
    }

    public static func hasCurrencySymbols(affixPattern: String): Bool {
        if (affixPattern.isNone() || affixPattern.size == 0) {
            return false
        }
        var tag = 0
        while (hasNext(tag, affixPattern)) {
            tag = nextToken(tag, affixPattern)
            let typeOrCp = getTypeOrCp(tag)
            if (typeOrCp < 0 && refEq(getFieldForType(typeOrCp), NumberFormat_Field.CURRENCY)) {
                return true
            }
        }
        return false
    }

    public static func replaceType(affixPattern: String, Type: Int32, replacementChar: Char): String {
        if (affixPattern.isNone() || affixPattern.size == 0) {
            return ""
        }
        let chars: Array<Char> = toString(affixPattern).toRuneArray()
        var tag = 0
        while (hasNext(tag, affixPattern)) {
            tag = nextToken(tag, affixPattern)
            if (getTypeOrCp(tag) == Type) {
                let offset = getOffset(tag)
                chars[Int64(offset - 1)] = replacementChar
            }
        }
        return String(chars)
    }

    public static func containsOnlySymbolsAndIgnorables(affixPattern: String, ignorables: UnicodeSet): Bool {
        if (affixPattern.isNone()) {
            return true
        }
        var tag = 0
        while (hasNext(tag, affixPattern)) {
            tag = nextToken(tag, affixPattern)
            let typeOrCp = getTypeOrCp(tag)
            if (typeOrCp >= 0 && !ignorables.contains(typeOrCp)) {
                return false
            }
        }
        return true
    }

    public static func iterateWithConsumer(affixPattern: String, consumer: AffixUtils_TokenConsumer): Unit {
        if (!affixPattern.isSome()) {
            throw AssertionError()
        }
        var tag = 0
        while (hasNext(tag, affixPattern)) {
            tag = nextToken(tag, affixPattern)
            let typeOrCp = getTypeOrCp(tag)
            consumer.consumeToken(typeOrCp)
        }
    }

    private static func nextToken(tag: Int64, patternString: String): Int64 {
        var offset = getOffset(tag)
        var state = getState(tag)
        while (offset < patternString.size) {
            let cp = Character.codePointAt(patternString, offset)
            let count = Character.charCount(cp)
            match (state) {
                case 0 => <-- Internal error: switch (cp) {
                case '\'':
                    state = STATE_FIRST_QUOTE;
                    offset += count;
                    break;

                case '-':
                    return makeTag(offset + count, TYPE_MINUS_SIGN, STATE_BASE, 0);

                case '+':
                    return makeTag(offset + count, TYPE_PLUS_SIGN, STATE_BASE, 0);

                case '~':
                    return makeTag(offset + count, TYPE_APPROXIMATELY_SIGN, STATE_BASE, 0);

                case '%':
                    return makeTag(offset + count, TYPE_PERCENT, STATE_BASE, 0);

                case '\u{2030}':
                    return makeTag(offset + count, TYPE_PERMILLE, STATE_BASE, 0);

                case '\u{00a4}':
                    state = STATE_FIRST_CURR;
                    offset += count;
                    break;

                default:
                    return makeTag(offset + count, TYPE_CODEPOINT, STATE_BASE, cp);

                } -->
                case 1 => if (cp == Int32(UInt32('\''))) {
                    return makeTag(offset + count, TYPE_CODEPOINT, STATE_BASE, cp)
                } else {
                    return makeTag(offset + count, TYPE_CODEPOINT, STATE_INSIDE_QUOTE, cp)
                }
                case 2 => if (cp == Int32(UInt32('\''))) {
                    state = STATE_AFTER_QUOTE
                    offset += count
                    break
                } else {
                    return makeTag(offset + count, TYPE_CODEPOINT, STATE_INSIDE_QUOTE, cp)
                }
                case 3 => if (cp == Int32(UInt32('\''))) {
                    return makeTag(offset + count, TYPE_CODEPOINT, STATE_INSIDE_QUOTE, cp)
                } else {
                    state = STATE_BASE
                    break
                }
                case 4 => if (cp == Int32(UInt32('\u{00a4}'))) {
                    state = STATE_SECOND_CURR
                    offset += count
                    break
                } else {
                    return makeTag(offset, TYPE_CURRENCY_SINGLE, STATE_BASE, 0)
                }
                case 5 => if (cp == Int32(UInt32('\u{00a4}'))) {
                    state = STATE_THIRD_CURR
                    offset += count
                    break
                } else {
                    return makeTag(offset, TYPE_CURRENCY_DOUBLE, STATE_BASE, 0)
                }
                case 6 => if (cp == Int32(UInt32('\u{00a4}'))) {
                    state = STATE_FOURTH_CURR
                    offset += count
                    break
                } else {
                    return makeTag(offset, TYPE_CURRENCY_TRIPLE, STATE_BASE, 0)
                }
                case 7 => if (cp == Int32(UInt32('\u{00a4}'))) {
                    state = STATE_FIFTH_CURR
                    offset += count
                    break
                } else {
                    return makeTag(offset, TYPE_CURRENCY_QUAD, STATE_BASE, 0)
                }
                case 8 => if (cp == Int32(UInt32('\u{00a4}'))) {
                    state = STATE_OVERFLOW_CURR
                    offset += count
                    break
                } else {
                    return makeTag(offset, TYPE_CURRENCY_QUINT, STATE_BASE, 0)
                }
                case 9 => if (cp == Int32(UInt32('\u{00a4}'))) {
                    offset += count
                    break
                } else {
                    return makeTag(offset, TYPE_CURRENCY_OVERFLOW, STATE_BASE, 0)
                }
                case _ => throw AssertionError()
            }
        }
        match (state) {
            case 0 => return -1
            case 1 | 2 => throw IllegalArgumentException("Unterminated quote in pattern affix: \"" + (patternString) + "\"")
            case 3 => return -1
            case 4 => return makeTag(offset, TYPE_CURRENCY_SINGLE, STATE_BASE, 0)
            case 5 => return makeTag(offset, TYPE_CURRENCY_DOUBLE, STATE_BASE, 0)
            case 6 => return makeTag(offset, TYPE_CURRENCY_TRIPLE, STATE_BASE, 0)
            case 7 => return makeTag(offset, TYPE_CURRENCY_QUAD, STATE_BASE, 0)
            case 8 => return makeTag(offset, TYPE_CURRENCY_QUINT, STATE_BASE, 0)
            case 9 => return makeTag(offset, TYPE_CURRENCY_OVERFLOW, STATE_BASE, 0)
            case _ => throw AssertionError()
        }
    }

    private static func hasNext(tag: Int64, string: String): Bool {
        if (!(tag >= 0)) {
            throw AssertionError()
        }
        let state = getState(tag)
        let offset = getOffset(tag)
        if (state == STATE_INSIDE_QUOTE && offset == string.size - 1 && string[offset] == '\'') {
            return false
        } else if (state != STATE_BASE) {
            return true
        } else {
            return offset < string.size
        }
    }

    private static func getTypeOrCp(tag: Int64): Int32 {
        if (!(tag >= 0)) {
            throw AssertionError()
        }
        let Type = getType(tag)
        return if (Type == TYPE_CODEPOINT) { getCodePoint(tag) } else { -Type }
    }

    private static func makeTag(offset: Int32, Type: Int32, state: Int32, cp: Int32): Int64 {
        var tag = 0
        tag |= Int64(offset)
        tag |= shl((-Int64(Type)), 32)
        tag |= shl(Int64(state), 36)
        tag |= shl(Int64(cp), 40)
        if (!(tag >= 0)) {
            throw AssertionError()
        }
        return tag
    }

    private static func getOffset(tag: Int64): Int32 {
        return Int32(tag & -1)
    }

    private static func getType(tag: Int64): Int32 {
        return Int32((ushr(tag, 32)) & 15)
    }

    private static func getState(tag: Int64): Int32 {
        return Int32((ushr(tag, 36)) & 15)
    }

    private static func getCodePoint(tag: Int64): Int32 {
        return Int32(ushr(tag, 40))
    }
}


public interface AffixUtils_SymbolProvider {
    public func getSymbol(Type: Int32): String
}

public interface AffixUtils_TokenConsumer {
    public func consumeToken(typeOrCp: Int32): Unit
}