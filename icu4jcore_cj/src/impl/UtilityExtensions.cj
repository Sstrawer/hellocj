package icu4cj.impl


public class UtilityExtensions {

    public static func appendToRule(rule: StringBuffer, text: String, isLiteral: Bool, escapeUnprintable: Bool, quoteBuf: StringBuffer): Unit {
        var i = 0
        while (i < Int32(text.size)) {
            Utility.appendToRule(rule, Int32(UInt32(Char(text[Int64(i)]))), isLiteral, escapeUnprintable, quoteBuf)
            i++
        }
    }

    public static func appendToRule(rule: StringBuffer, matcher: UnicodeMatcher, escapeUnprintable: Bool, quoteBuf: StringBuffer): Unit {
        if (matcher.isSome()) {
            appendToRule(rule, matcher.toPattern(escapeUnprintable), true, escapeUnprintable, quoteBuf)
        }
    }

    public static func formatInput(input: ReplaceableString, pos: Transliterator_Position): String {
        let appendTo = StringBuffer()
        formatInput(appendTo, input, pos)
        return Utility.escape(toString(appendTo))
    }

    public static func formatInput(appendTo: StringBuffer, input: ReplaceableString, pos: Transliterator_Position): StringBuffer {
        if (0 <= pos.contextStart && pos.contextStart <= pos.start && pos.start <= pos.limit && pos.limit <= pos.contextLimit && pos.contextLimit <= input.size) {
            let b: String
            let c: String
            let d: String
            b = input.substring(pos.contextStart, pos.start)
            c = input.substring(pos.start, pos.limit)
            d = input.substring(pos.limit, pos.contextLimit)
            appendTo.append('{').append(b).append('|').append(c).append('|').append(d).append('}')
        } else {
            appendTo.append("INVALID Position {cs=" + pos.contextStart.toString() + ", s=" + pos.start.toString() + ", l=" + pos.limit.toString() + ", cl=" + pos.contextLimit.toString() + "} on " + input.asString())
        }
        return appendTo
    }

    public static func formatInput(input: Replaceable, pos: Transliterator_Position): String {
        return formatInput(input, pos)
    }

    public static func formatInput(appendTo: StringBuffer, input: Replaceable, pos: Transliterator_Position): StringBuffer {
        return formatInput(appendTo, input, pos)
    }
}
