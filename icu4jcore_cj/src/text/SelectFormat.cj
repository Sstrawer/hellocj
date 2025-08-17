package icu4cj.text

public class SelectFormat <: Format {
    private static let serialVersionUID = 2993154333257524984

    private var pattern: String

     private var msgPattern: MessagePattern

    public init(pattern: String) {
        Format()
        applyPattern(pattern)
    }

    private func reset(): Unit {
        pattern = None
        if (msgPattern.isSome()) {
            msgPattern.clear()
        }
    }

    public func applyPattern(pattern: String): Unit {
        this.pattern = pattern
        if (msgPattern.isNone()) {
            msgPattern = MessagePattern()
        }
        try {
            msgPattern.parseSelectStyle(pattern)
        } catch (e: Exception) {
            reset()
            throw e
        }
    }

    public func toPattern(): String {
        return pattern
    }

    static func findSubMessage(pattern: MessagePattern, partIndex: Int32, keyword: String): Int32 {
        var temppartIndex = partIndex
        let count = pattern.countParts()
        var msgStart = 0
            if (!refEq(Type, MessagePattern_Part_Type.ARG_SELECTOR)) {
                throw AssertionError()
            }
            if (pattern.partSubstringMatches(part, keyword)) {
                return temppartIndex
            } else if (msgStart == 0 && pattern.partSubstringMatches(part, "other")) {
                msgStart = temppartIndex
            }
            temppartIndex = pattern.getLimitPartIndex(temppartIndex)
        } while (match (0) { case _ => temppartIndex++; temppartIndex } < count)
        return msgStart
    }

    public func format(keyword: String): String {
        if (!PatternProps.isIdentifier(keyword)) {
            throw IllegalArgumentException("Invalid formatting argument.")
        }
        if (msgPattern.isNone() || msgPattern.countParts() == 0) {
            throw Exception("Invalid format error.")
        }
        let msgStart = findSubMessage(msgPattern, 0, keyword)
        if (!msgPattern.jdkAposMode()) {
            let msgLimit = msgPattern.getLimitPartIndex(msgStart)
            return msgPattern.getPatternString()[Int64(msgPattern.getPart(msgStart).getLimit())..Int64(msgPattern.getPatternIndex(msgLimit))]
        }
        var result: StringBuilder
        var prevIndex = msgPattern.getPart(msgStart).getLimit()
        var i = msgStart
        while (true) {
            let part = msgPattern.getPart(match (0) { case _ => i++; i })
            let Type = part.getType()
            var index = part.getIndex()
            if (refEq(Type, MessagePattern_Part_Type.MSG_LIMIT)) {
                if (result.isNone()) {
                    return pattern[Int64(prevIndex)..Int64(index)]
                } else {
                    return result.append(pattern, prevIndex, index).toString()
                }
            } else if (refEq(Type, MessagePattern_Part_Type.SKIP_SYNTAX)) {
                if (result.isNone()) {
                    result = StringBuilder()
                }
                result.append(pattern, prevIndex, index)
                prevIndex = part.getLimit()
            } else if (refEq(Type, MessagePattern_Part_Type.ARG_START)) {
                if (result.isNone()) {
                    result = StringBuilder()
                }
                result.append(pattern, prevIndex, index)
                prevIndex = index
                i = msgPattern.getLimitPartIndex(i)
                index = msgPattern.getPart(i).getLimit()
                MessagePattern.appendReducedApostrophes(pattern, prevIndex, index, result)
                prevIndex = index
            }
        }
    }

    public override func format(keyword: Object, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        if (keyword) {
            toAppendTo.append(format(keyword))
        } else {
            throw IllegalArgumentException("'" + toString(keyword) + "' is not a String")
        }
        return toAppendTo
    }

    public override func parseObject(source: String, pos: ParsePosition): Object {
        throw UnsupportedOperationException()
    }

    public override func equals(obj: Object): Bool {
        if (refEq(this, obj)) {
            return true
        }
        if (obj.isNone() || !refEq(TypeInfo.of(this), TypeInfo.of(obj))) {
            return false
        }
        let sf = obj
        return if (msgPattern.isNone()) { sf.msgPattern.isNone() } else { msgPattern.equals(sf.msgPattern) }
    }

    public override func hashCode(): Int64 {
        if (pattern.isSome()) {
            return pattern.hashCode()
        }
        return 0
    }

    public override func toString(): String {
        return "pattern='" + (pattern) + "'"
    }

    private func readObject(input: ObjectInputStream): Unit {
        input.defaultReadObject()
        if (pattern.isSome()) {
            applyPattern(pattern)
        }
    }
}
