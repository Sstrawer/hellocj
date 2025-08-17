package icu4cj.text


public class MessagePattern <: Cloneable & Freezable<MessagePattern> {
    public init() {
        aposMode = defaultAposMode
    }

    public init(mode: MessagePattern_ApostropheMode) {
        aposMode = mode
    }

    public init(pattern: String) {
        aposMode = defaultAposMode
        parse(pattern)
    }

    public func parse(pattern: String): MessagePattern {
        preParse(pattern)
        parseMessage(0, 0, 0, MessagePattern_ArgType.NONE)
        postParse()
        return this
    }

    public func parseChoiceStyle(pattern: String): MessagePattern {
        preParse(pattern)
        parseChoiceStyle(0, 0)
        postParse()
        return this
    }

    public func parsePluralStyle(pattern: String): MessagePattern {
        preParse(pattern)
        parsePluralOrSelectStyle(MessagePattern_ArgType.PLURAL, 0, 0)
        postParse()
        return this
    }

    public func parseSelectStyle(pattern: String): MessagePattern {
        preParse(pattern)
        parsePluralOrSelectStyle(MessagePattern_ArgType.SELECT, 0, 0)
        postParse()
        return this
    }

    public func clear(): Unit {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to clear() a frozen MessagePattern instance.")
        }
        msg = None
        hasArgNames = match (0) { case _ => hasArgNumbers = false; hasArgNumbers }
        needsAutoQuoting = false
        parts.clear()
        if (numericValues.isSome()) {
            numericValues.clear()
        }
    }

    public func clearPatternAndSetApostropheMode(mode: MessagePattern_ApostropheMode): Unit {
        clear()
        aposMode = mode
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (other.isNone() || !refEq(TypeInfo.of(this), TypeInfo.of(other))) {
            return false
        }
        let o = other
        return refEq(aposMode, o.aposMode) && (if (msg.isNone()) { o.msg.isNone() } else { msg.equals(o.msg) }) && refEq(parts, o.parts)
    }

    public override func hashCode(): Int64 {
        return Int64((Int32(aposMode.hashCode()) * 37 + (if (msg.isSome()) { Int32(msg.hashCode()) } else { 0 })) * 37 + Int32(parts.hashCode()))
    }

    public func getApostropheMode(): MessagePattern_ApostropheMode {
        return aposMode
    }

    public func jdkAposMode(): Bool {
        return refEq(aposMode, MessagePattern_ApostropheMode.DOUBLE_REQUIRED)
    }

    public func getPatternString(): String {
        return msg
    }

    public func hasNamedArguments(): Bool {
        return hasArgNames
    }

    public func hasNumberedArguments(): Bool {
        return hasArgNumbers
    }

    public override func toString(): String {
        return msg
    }

    public static func validateArgumentName(name: String): Int32 {
        if (!PatternProps.isIdentifier(name)) {
            return ARG_NAME_NOT_VALID
        }
        return parseArgNumberStatic(name, 0, Int32(name.size))
    }

    public static let ARG_NAME_NOT_NUMBER = -1

    public static let ARG_NAME_NOT_VALID = -2

    public func autoQuoteApostropheDeep(): String {
        if (!needsAutoQuoting) {
            return msg
        }
        var modified: StringBuilder
        let count = countParts()
        var i = count
        while (i > 0) {
            let part: MessagePattern_Part
            if (refEq((match (0) { case _ => part = getPart(match (0) { case _ => i--; i }); part }).getType(), MessagePattern_Part_Type.INSERT_CHAR)) {
                if (modified.isNone()) {
                    modified = StringBuilder().append(msg)
                }
                modified.insert(Int64(part.index), Char(part.value))
            }
        }
        if (modified.isNone()) {
            return msg
        } else {
            return modified.toString()
        }
    }

    public func countParts(): Int32 {
        return Int32(parts.size)
    }

    public func getPart(i: Int32): MessagePattern_Part {
        return parts[Int64(i)]
    }

    public func getPartType(i: Int32): MessagePattern_Part_Type {
        return parts[Int64(i)].Type
    }

    public func getPatternIndex(partIndex: Int32): Int32 {
        return parts[Int64(partIndex)].index
    }

    public func getSubstring(part: MessagePattern_Part): String {
        let index = part.index
        return msg[Int64(index)..Int64(index + Int32(UInt32(part.length)))]
    }

    public func partSubstringMatches(part: MessagePattern_Part, s: String): Bool {
        return Int32(UInt32(part.length)) == Int32(s.size) && msg.regionMatches(part.index, s, 0, Int32(UInt32(part.length)))
    }

    public func getNumericValue(part: MessagePattern_Part): Float64 {
        let Type = part.Type
        if (refEq(Type, MessagePattern_Part_Type.ARG_INT)) {
            return Float64(part.value)
        } else if (refEq(Type, MessagePattern_Part_Type.ARG_DOUBLE)) {
            return numericValues[Int64(part.value)]
        } else {
            return NO_NUMERIC_VALUE
        }
    }

    public static let NO_NUMERIC_VALUE = -123456789.0

    public func getPluralOffset(pluralStart: Int32): Float64 {
        let part = parts[Int64(pluralStart)]
        if (part.Type.hasNumericValue()) {
            return getNumericValue(part)
        } else {
            return 0.0
        }
    }

    public func getLimitPartIndex(start: Int32): Int32 {
        let limit = parts[Int64(start)].limitPartIndex
        if (limit < start) {
            return start
        }
        return limit
    }

    public override func clone(): Object {
        if (isFrozen()) {
            return this
        } else {
            return cloneAsThawed()
        }
    }

    public override func cloneAsThawed(): MessagePattern {
        let newMsg: MessagePattern
        try {
            newMsg = super.toString()
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException(e as Exception)
        }
        newMsg.parts = parts.clone()
        if (numericValues.isSome()) {
            newMsg.numericValues = numericValues.clone()
        }
        newMsg.frozen = false
        return newMsg
    }

    public override func freeze(): MessagePattern {
        frozen = true
        return this
    }

    public override func isFrozen(): Bool {
        return frozen
    }

    private func preParse(pattern: String): Unit {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to parse(" + (prefixStatic(pattern)) + ") on frozen MessagePattern instance.")
        }
        msg = pattern
        hasArgNames = match (0) { case _ => hasArgNumbers = false; hasArgNumbers }
        needsAutoQuoting = false
        parts.clear()
        if (numericValues.isSome()) {
            numericValues.clear()
        }
    }

    private func postParse(): Unit { }

    private func parseMessage(index: Int32, msgStartLength: Int32, nestingLevel: Int32, parentType: MessagePattern_ArgType): Int32 {
        var tempindex = index
        if (nestingLevel > MessagePattern_Part.MAX_VALUE) {
            throw IndexOutOfBoundsException()
        }
        let msgStart = Int32(parts.size)
        addPart(MessagePattern_Part_Type.MSG_START, tempindex, msgStartLength, nestingLevel)
        tempindex += msgStartLength
        while (tempindex < Int32(msg.size)) {
            var c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })])
            if (c == ''') {
                if (tempindex == Int32(msg.size)) {
                    addPart(MessagePattern_Part_Type.INSERT_CHAR, tempindex, 0, Int32(UInt32(''')))
                    needsAutoQuoting = true
                } else {
                    c = Char(msg[Int64(tempindex)])
                    if (c == ''') {
                        addPart(MessagePattern_Part_Type.SKIP_SYNTAX, match (0) { case _ => tempindex++; tempindex - 1 }, 1, 0)
                    } else if (refEq(aposMode, MessagePattern_ApostropheMode.DOUBLE_REQUIRED) || c == '{' || c == '}' || (refEq(parentType, MessagePattern_ArgType.CHOICE) && c == '|') || (parentType.hasPluralStyle() && c == '#')) {
                        addPart(MessagePattern_Part_Type.SKIP_SYNTAX, tempindex - 1, 1, 0)
                        while (true) {
                            tempindex = indexOfWrap(msg.indexOf(UInt8(UInt32(''')), Int64(tempindex + 1)))
                            if (tempindex >= 0) {
                                if ((tempindex + 1) < Int32(msg.size) && Char(msg[Int64(tempindex + 1)]) == ''') {
                                    addPart(MessagePattern_Part_Type.SKIP_SYNTAX, match (0) { case _ => tempindex++; tempindex }, 1, 0)
                                } else {
                                    addPart(MessagePattern_Part_Type.SKIP_SYNTAX, match (0) { case _ => tempindex++; tempindex - 1 }, 1, 0)
                                    break
                                }
                            } else {
                                tempindex = Int32(msg.size)
                                addPart(MessagePattern_Part_Type.INSERT_CHAR, tempindex, 0, Int32(UInt32(''')))
                                needsAutoQuoting = true
                                break
                            }
                        }
                    } else {
                        addPart(MessagePattern_Part_Type.INSERT_CHAR, tempindex, 0, Int32(UInt32(''')))
                        needsAutoQuoting = true
                    }
                }
            } else if (parentType.hasPluralStyle() && c == '#') {
                addPart(MessagePattern_Part_Type.REPLACE_NUMBER, tempindex - 1, 1, 0)
            } else if (c == '{') {
                tempindex = parseArg(tempindex - 1, 1, nestingLevel)
            } else if ((nestingLevel > 0 && c == '}') || (refEq(parentType, MessagePattern_ArgType.CHOICE) && c == '|')) {
                let limitLength = if (refEq(parentType, MessagePattern_ArgType.CHOICE) && c == '}') { 0 } else { 1 }
                addLimitPart(msgStart, MessagePattern_Part_Type.MSG_LIMIT, tempindex - 1, limitLength, nestingLevel)
                if (refEq(parentType, MessagePattern_ArgType.CHOICE)) {
                    return tempindex - 1
                } else {
                    return tempindex
                }
            }
        }
        if (nestingLevel > 0 && !inTopLevelChoiceMessage(nestingLevel, parentType)) {
            throw IllegalArgumentException("Unmatched '{' braces in message " + (prefix()))
        }
        addLimitPart(msgStart, MessagePattern_Part_Type.MSG_LIMIT, tempindex, 0, nestingLevel)
        return tempindex
    }

    private func parseArg(index: Int32, argStartLength: Int32, nestingLevel: Int32): Int32 {
        var tempindex = index
        let argStart = Int32(parts.size)
        var argType: MessagePattern_ArgType = MessagePattern_ArgType.NONE
        addPart(MessagePattern_Part_Type.ARG_START, tempindex, argStartLength, argType.ordinal)
        let nameIndex = match (0) { case _ => tempindex = skipWhiteSpace(tempindex + argStartLength); tempindex }
        if (tempindex == Int32(msg.size)) {
            throw IllegalArgumentException("Unmatched '{' braces in message " + (prefix()))
        }
        tempindex = skipIdentifier(tempindex)
        let number = parseArgNumber(nameIndex, tempindex)
        if (number >= 0) {
            let length = tempindex - nameIndex
            if (length > MessagePattern_Part.MAX_LENGTH || number > MessagePattern_Part.MAX_VALUE) {
                throw IndexOutOfBoundsException("Argument number too large: " + (prefix(nameIndex)))
            }
            hasArgNumbers = true
            addPart(MessagePattern_Part_Type.ARG_NUMBER, nameIndex, length, number)
        } else if (number == ARG_NAME_NOT_NUMBER) {
            let length = tempindex - nameIndex
            if (length > MessagePattern_Part.MAX_LENGTH) {
                throw IndexOutOfBoundsException("Argument name too long: " + (prefix(nameIndex)))
            }
            hasArgNames = true
            addPart(MessagePattern_Part_Type.ARG_NAME, nameIndex, length, 0)
        } else {
            throw IllegalArgumentException("Bad argument syntax: " + (prefix(nameIndex)))
        }
        tempindex = skipWhiteSpace(tempindex)
        if (tempindex == Int32(msg.size)) {
            throw IllegalArgumentException("Unmatched '{' braces in message " + (prefix()))
        }
        var c = Char(msg[Int64(tempindex)])
        if (c == '}') { } else if (c != ',') {
            throw IllegalArgumentException("Bad argument syntax: " + (prefix(nameIndex)))
        } else {
            let typeIndex = match (0) { case _ => tempindex = skipWhiteSpace(tempindex + 1); tempindex }
            while (tempindex < Int32(msg.size) && isArgTypeChar(Int32(UInt32(Char(msg[Int64(tempindex)]))))) {
                tempindex++
            }
            let length = tempindex - typeIndex
            tempindex = skipWhiteSpace(tempindex)
            if (tempindex == Int32(msg.size)) {
                throw IllegalArgumentException("Unmatched '{' braces in message " + (prefix()))
            }
            if (length == 0 || ((match (0) { case _ => c = Char(msg[Int64(tempindex)]); c }) != ',' && c != '}')) {
                throw IllegalArgumentException("Bad argument syntax: " + (prefix(nameIndex)))
            }
            if (length > MessagePattern_Part.MAX_LENGTH) {
                throw IndexOutOfBoundsException("Argument type name too long: " + (prefix(nameIndex)))
            }
            argType = MessagePattern_ArgType.SIMPLE
            if (length == 6) {
                if (isChoice(typeIndex)) {
                    argType = MessagePattern_ArgType.CHOICE
                } else if (isPlural(typeIndex)) {
                    argType = MessagePattern_ArgType.PLURAL
                } else if (isSelect(typeIndex)) {
                    argType = MessagePattern_ArgType.SELECT
                }
            } else if (length == 13) {
                if (isSelect(typeIndex) && isOrdinal(typeIndex + 6)) {
                    argType = MessagePattern_ArgType.SELECTORDINAL
                }
            }
            parts[Int64(argStart)].value = Int16(argType.ordinal)
            if (refEq(argType, MessagePattern_ArgType.SIMPLE)) {
                addPart(MessagePattern_Part_Type.ARG_TYPE, typeIndex, length, 0)
            }
            if (c == '}') {
                if (!refEq(argType, MessagePattern_ArgType.SIMPLE)) {
                    throw IllegalArgumentException("No style field for complex argument: " + (prefix(nameIndex)))
                }
            } else {
                tempindex++
                if (refEq(argType, MessagePattern_ArgType.SIMPLE)) {
                    tempindex = parseSimpleStyle(tempindex)
                } else if (refEq(argType, MessagePattern_ArgType.CHOICE)) {
                    tempindex = parseChoiceStyle(tempindex, nestingLevel)
                } else {
                    tempindex = parsePluralOrSelectStyle(argType, tempindex, nestingLevel)
                }
            }
        }
        addLimitPart(argStart, MessagePattern_Part_Type.ARG_LIMIT, tempindex, 1, argType.ordinal)
        return tempindex + 1
    }

    private func parseSimpleStyle(index: Int32): Int32 {
        var tempindex = index
        let start = tempindex
        var nestedBraces = 0
        while (tempindex < Int32(msg.size)) {
            let c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })])
            if (c == ''') {
                tempindex = indexOfWrap(msg.indexOf(UInt8(UInt32(''')), Int64(tempindex)))
                if (tempindex < 0) {
                    throw IllegalArgumentException("Quoted literal argument style text reaches to the end of the message: " + (prefix(start)))
                }
                tempindex++
            } else if (c == '{') {
                nestedBraces++
            } else if (c == '}') {
                if (nestedBraces > 0) {
                    nestedBraces--
                } else {
                    let length = match (0) { case _ => tempindex--; tempindex } - start
                    if (length > MessagePattern_Part.MAX_LENGTH) {
                        throw IndexOutOfBoundsException("Argument style text too long: " + (prefix(start)))
                    }
                    addPart(MessagePattern_Part_Type.ARG_STYLE, start, length, 0)
                    return tempindex
                }
            }
        }
        throw IllegalArgumentException("Unmatched '{' braces in message " + (prefix()))
    }

    private func parseChoiceStyle(index: Int32, nestingLevel: Int32): Int32 {
        var tempindex = index
        let start = tempindex
        tempindex = skipWhiteSpace(tempindex)
        if (tempindex == Int32(msg.size) || Char(msg[Int64(tempindex)]) == '}') {
            throw IllegalArgumentException("Missing choice argument pattern in " + (prefix()))
        }
        while (true) {
            let numberIndex = tempindex
            tempindex = skipDouble(tempindex)
            let length = tempindex - numberIndex
            if (length == 0) {
                throw IllegalArgumentException("Bad choice pattern syntax: " + (prefix(start)))
            }
            if (length > MessagePattern_Part.MAX_LENGTH) {
                throw IndexOutOfBoundsException("Choice number too long: " + (prefix(numberIndex)))
            }
            parseDouble(numberIndex, tempindex, true)
            tempindex = skipWhiteSpace(tempindex)
            if (tempindex == Int32(msg.size)) {
                throw IllegalArgumentException("Bad choice pattern syntax: " + (prefix(start)))
            }
            let c = Char(msg[Int64(tempindex)])
            if (!(c == '#' || c == '<' || c == '\u{2264}')) {
                throw IllegalArgumentException("Expected choice separator (#<\u{2264}) instead of '" + c.toString() + "' in choice pattern " + (prefix(start)))
            }
            addPart(MessagePattern_Part_Type.ARG_SELECTOR, tempindex, 1, 0)
            tempindex = parseMessage(match (0) { case _ => tempindex++; tempindex }, 0, nestingLevel + 1, MessagePattern_ArgType.CHOICE)
            if (tempindex == Int32(msg.size)) {
                return tempindex
            }
            if (Char(msg[Int64(tempindex)]) == '}') {
                if (!inMessageFormatPattern(nestingLevel)) {
                    throw IllegalArgumentException("Bad choice pattern syntax: " + (prefix(start)))
                }
                return tempindex
            }
            tempindex = skipWhiteSpace(tempindex + 1)
        }
    }

    private func parsePluralOrSelectStyle(argType: MessagePattern_ArgType, index: Int32, nestingLevel: Int32): Int32 {
        var tempindex = index
        let start = tempindex
        var isEmpty = true
        var hasOther = false
        while (true) {
            tempindex = skipWhiteSpace(tempindex)
            let eos = tempindex == Int32(msg.size)
            if (eos || Char(msg[Int64(tempindex)]) == '}') {
                if (eos == inMessageFormatPattern(nestingLevel)) {
                    throw IllegalArgumentException("Bad " + (argType.toString().toLowerCase(Locale.ENGLISH)) + " pattern syntax: " + (prefix(start)))
                }
                if (!hasOther) {
                    throw IllegalArgumentException("Missing 'other' keyword in " + (argType.toString().toLowerCase(Locale.ENGLISH)) + " pattern in " + (prefix()))
                }
                return tempindex
            }
            let selectorIndex = tempindex
            if (argType.hasPluralStyle() && Char(msg[Int64(selectorIndex)]) == '=') {
                tempindex = skipDouble(tempindex + 1)
                let length = tempindex - selectorIndex
                if (length == 1) {
                    throw IllegalArgumentException("Bad " + (argType.toString().toLowerCase(Locale.ENGLISH)) + " pattern syntax: " + (prefix(start)))
                }
                if (length > MessagePattern_Part.MAX_LENGTH) {
                    throw IndexOutOfBoundsException("Argument selector too long: " + (prefix(selectorIndex)))
                }
                addPart(MessagePattern_Part_Type.ARG_SELECTOR, selectorIndex, length, 0)
                parseDouble(selectorIndex + 1, tempindex, false)
            } else {
                tempindex = skipIdentifier(tempindex)
                let length = tempindex - selectorIndex
                if (length == 0) {
                    throw IllegalArgumentException("Bad " + (argType.toString().toLowerCase(Locale.ENGLISH)) + " pattern syntax: " + (prefix(start)))
                }
                if (argType.hasPluralStyle() && length == 6 && tempindex < Int32(msg.size) && msg.regionMatches(selectorIndex, "offset:", 0, 7)) {
                    if (!isEmpty) {
                        throw IllegalArgumentException("Plural argument 'offset:' (if present) must precede key-message pairs: " + (prefix(start)))
                    }
                    let valueIndex = skipWhiteSpace(tempindex + 1)
                    tempindex = skipDouble(valueIndex)
                    if (tempindex == valueIndex) {
                        throw IllegalArgumentException("Missing value for plural 'offset:' " + (prefix(start)))
                    }
                    if ((tempindex - valueIndex) > MessagePattern_Part.MAX_LENGTH) {
                        throw IndexOutOfBoundsException("Plural offset value too long: " + (prefix(valueIndex)))
                    }
                    parseDouble(valueIndex, tempindex, false)
                    isEmpty = false
                    continue
                } else {
                    if (length > MessagePattern_Part.MAX_LENGTH) {
                        throw IndexOutOfBoundsException("Argument selector too long: " + (prefix(selectorIndex)))
                    }
                    addPart(MessagePattern_Part_Type.ARG_SELECTOR, selectorIndex, length, 0)
                    if (msg.regionMatches(selectorIndex, "other", 0, length)) {
                        hasOther = true
                    }
                }
            }
            tempindex = skipWhiteSpace(tempindex)
            if (tempindex == Int32(msg.size) || Char(msg[Int64(tempindex)]) != '{') {
                throw IllegalArgumentException("No message fragment after " + (argType.toString().toLowerCase(Locale.ENGLISH)) + " selector: " + (prefix(selectorIndex)))
            }
            tempindex = parseMessage(tempindex, 1, nestingLevel + 1, argType)
            isEmpty = false
        }
    }

    private static func parseArgNumberStatic(s: String, start: Int32, limit: Int32): Int32 {
        var tempstart = start
        if (tempstart >= limit) {
            return ARG_NAME_NOT_VALID
        }
        var number: Int32 = 0
        var badNumber: Bool = false
        var c = s[match (0] { case _ => tempstart++; tempstart - 1 })
        if (c == '0') {
            if (tempstart == limit) {
                return 0
            } else {
                number = 0
                badNumber = true
            }
        } else if ('1' <= c && c <= '9') {
            number = 
            badNumber = false
        } else {
            return ARG_NAME_NOT_NUMBER
        }
        while (tempstart < limit) {
            c = s[match (0] { case _ => tempstart++; tempstart - 1 })
            if ('0' <= c && c <= '9') {
                if (number >= Int32.Max / 10) {
                    badNumber = true
                }
                number = number * 10 + ()
            } else {
                return ARG_NAME_NOT_NUMBER
            }
        }
        if (badNumber) {
            return ARG_NAME_NOT_VALID
        } else {
            return number
        }
    }

    private func parseArgNumber(start: Int32, limit: Int32): Int32 {
        return parseArgNumberStatic(msg, start, limit)
    }

    private func parseDouble(start: Int32, limit: Int32, allowInfinity: Bool): Unit {
        if (!(start < limit)) {
            throw AssertionError()
        }
        while (true) {
            var value = 0
            var isNegative = 0
            var index = start
            var c = Char(msg[Int64(match (0) { case _ => index++; index - 1 })])
            if (c == '-') {
                isNegative = 1
                if (index == limit) {
                    break
                }
                c = Char(msg[Int64(match (0) { case _ => index++; index - 1 })])
            } else if (c == '+') {
                if (index == limit) {
                    break
                }
                c = Char(msg[Int64(match (0) { case _ => index++; index - 1 })])
            }
            if (Int32(UInt32(c)) == 8734) {
                if (allowInfinity && index == limit) {
                    addArgDoublePart(if (isNegative != 0) { Float64.NEGATIVE_INFINITY } else { Float64.POSITIVE_INFINITY }, start, limit - start)
                    return
                } else {
                    break
                }
            }
            while ('0' <= c && c <= '9') {
                value = value * 10 + ()
                if (value > (MessagePattern_Part.MAX_VALUE + isNegative)) {
                    break
                }
                if (index == limit) {
                    addPart(MessagePattern_Part_Type.ARG_INT, start, limit - start, if (isNegative != 0) { -value } else { value })
                    return
                }
                c = Char(msg[Int64(match (0) { case _ => index++; index - 1 })])
            }
            let numericValue = parse<Float64>(msg[Int64(start)..Int64(limit)])
            addArgDoublePart(numericValue, start, limit - start)
            return
        }
        throw TimeParseException("Bad syntax for numeric value: " + msg[Int64(start)..Int64(limit)])
    }

    static func appendReducedApostrophes(s: String, start: Int32, limit: Int32, sb: StringBuilder): Unit {
        var tempstart = start
        var doubleApos = -1
        while (true) {
            let i = indexOfWrap(s.indexOf(UInt8(UInt32(''')), Int64(tempstart)))
            if (i < 0 || i >= limit) {
                sb.append(s, tempstart, limit)
                break
            }
            if (i == doubleApos) {
                sb.append(''')
                tempstart++
                doubleApos = -1
            } else {
                sb.append(s, tempstart, i)
                doubleApos = match (0) { case _ => tempstart = i + 1; tempstart }
            }
        }
    }

    private func skipWhiteSpace(index: Int32): Int32 {
        return PatternProps.skipWhiteSpace(msg, index)
    }

    private func skipIdentifier(index: Int32): Int32 {
        return PatternProps.skipIdentifier(msg, index)
    }

    private func skipDouble(index: Int32): Int32 {
        var tempindex = index
        while (tempindex < Int32(msg.size)) {
            let c = Char(msg[Int64(tempindex)])
            if ((c < '0' && indexOfWrap("+-.".indexOf(UInt8(UInt32(c)))) < 0) || (c > '9' && c != 'e' && c != 'E' && Int32(UInt32(c)) != 8734)) {
                break
            }
            tempindex++
        }
        return tempindex
    }

    private static func isArgTypeChar(c: Int32): Bool {
        return (Int32(UInt32('a')) <= c && c <= Int32(UInt32('z'))) || (Int32(UInt32('A')) <= c && c <= Int32(UInt32('Z')))
    }

    private func isChoice(index: Int32): Bool {
        var tempindex = index
        var c: Char = '\u{0000}'
        return ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'c' || c == 'C') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'h' || c == 'H') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'o' || c == 'O') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'i' || c == 'I') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'c' || c == 'C') && ((match (0) { case _ => c = Char(msg[Int64(tempindex)]); c }) == 'e' || c == 'E')
    }

    private func isPlural(index: Int32): Bool {
        var tempindex = index
        var c: Char = '\u{0000}'
        return ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'p' || c == 'P') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'l' || c == 'L') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'u' || c == 'U') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'r' || c == 'R') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'a' || c == 'A') && ((match (0) { case _ => c = Char(msg[Int64(tempindex)]); c }) == 'l' || c == 'L')
    }

    private func isSelect(index: Int32): Bool {
        var tempindex = index
        var c: Char = '\u{0000}'
        return ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 's' || c == 'S') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'e' || c == 'E') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'l' || c == 'L') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'e' || c == 'E') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'c' || c == 'C') && ((match (0) { case _ => c = Char(msg[Int64(tempindex)]); c }) == 't' || c == 'T')
    }

    private func isOrdinal(index: Int32): Bool {
        var tempindex = index
        var c: Char = '\u{0000}'
        return ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'o' || c == 'O') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'r' || c == 'R') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'd' || c == 'D') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'i' || c == 'I') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'n' || c == 'N') && ((match (0) { case _ => c = Char(msg[Int64(match (0) { case _ => tempindex++; tempindex - 1 })]); c }) == 'a' || c == 'A') && ((match (0) { case _ => c = Char(msg[Int64(tempindex)]); c }) == 'l' || c == 'L')
    }

    private func inMessageFormatPattern(nestingLevel: Int32): Bool {
        return nestingLevel > 0 || refEq(parts[0].Type, MessagePattern_Part_Type.MSG_START)
    }

    private func inTopLevelChoiceMessage(nestingLevel: Int32, parentType: MessagePattern_ArgType): Bool {
        return nestingLevel == 1 && refEq(parentType, MessagePattern_ArgType.CHOICE) && !refEq(parts[0].Type, MessagePattern_Part_Type.MSG_START)
    }

    private func addPart(Type: MessagePattern_Part_Type, index: Int32, length: Int32, value: Int32): Unit {
        parts.append(MessagePattern_Part(Type, index, length, value))
    }

    private func addLimitPart(start: Int32, Type: MessagePattern_Part_Type, index: Int32, length: Int32, value: Int32): Unit {
        parts[Int64(start)].limitPartIndex = Int32(parts.size)
        addPart(Type, index, length, value)
    }

    private func addArgDoublePart(numericValue: Float64, start: Int32, length: Int32): Unit {
        let numericIndex: Int32
        if (numericValues.isNone()) {
            numericValues = ArrayList<Float64>()
            numericIndex = 0
        } else {
            numericIndex = Int32(numericValues.size)
            if (numericIndex > MessagePattern_Part.MAX_VALUE) {
                throw IndexOutOfBoundsException("Too many numeric values")
            }
        }
        numericValues.append(numericValue)
        addPart(MessagePattern_Part_Type.ARG_DOUBLE, start, length, numericIndex)
    }

    private static let MAX_PREFIX_LENGTH = 24

    private static func prefixStatic(s: String, start: Int32): String {
        let prefix = StringBuilder()
        if (start == 0) {
            prefix.append("\"")
        } else {
            prefix.append("[at pattern index ").append(start).append("] \"")
        }
        let substringLength = Int32(s.size) - start
        if (substringLength <= MAX_PREFIX_LENGTH) {
            prefix.append(if (start == 0) { s } else { s[Int64(start)..] })
        } else {
            var limit = start + MAX_PREFIX_LENGTH - 4
            if (Character.isHighSurrogate(Char(s[Int64(limit - 1)]))) {
                limit--
            }
            prefix.append(s, start, limit).append(" ...")
        }
        return prefix.append("\"").toString()
    }

    private static func prefixStatic(s: String): String {
        return prefixStatic(s, 0)
    }

    private func prefix(start: Int32): String {
        return prefixStatic(msg, start)
    }

    private func prefix(): String {
        return prefixStatic(msg, 0)
    }

    private var aposMode: MessagePattern_ApostropheMode

    private var msg: String

    private var parts: ArrayList<MessagePattern_Part> = ArrayList<MessagePattern_Part>()

    private var numericValues: ArrayList<Float64>

    private var hasArgNames: Bool = false

    private var hasArgNumbers: Bool = false

    private var needsAutoQuoting: Bool = false

     private var frozen: Bool = false

    private static let defaultAposMode = MessagePattern_ApostropheMode.valueOf(ICUConfig.get("com.ibm.icu.text.MessagePattern.ApostropheMode", "DOUBLE_OPTIONAL"))

    static let argTypes = MessagePattern_ArgType.values()
}


public class MessagePattern_ApostropheMode <: Enum<MessagePattern_ApostropheMode> {
    public static let DOUBLE_OPTIONAL = MessagePattern_ApostropheMode("DOUBLE_OPTIONAL", 0)

    public static let DOUBLE_REQUIRED = MessagePattern_ApostropheMode("DOUBLE_REQUIRED", 1)

    private static func _values(): Array<MessagePattern_ApostropheMode> {
        return [MessagePattern_ApostropheMode.DOUBLE_OPTIONAL, MessagePattern_ApostropheMode.DOUBLE_REQUIRED]
    }

    private static let _VALUES = MessagePattern_ApostropheMode._values()

    public static func values(): Array<MessagePattern_ApostropheMode> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): MessagePattern_ApostropheMode {
        return (TypeInfo.of<MessagePattern_ApostropheMode>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as MessagePattern_ApostropheMode
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class MessagePattern_Part {
    init(t: MessagePattern_Part_Type, i: Int32, l: Int32, v: Int32) {
        Type = t
        index = i
        length = Char(l)
        value = Int16(v)
    }

    public func getType(): MessagePattern_Part_Type {
        return Type
    }

    public func getIndex(): Int32 {
        return index
    }

    public func getLength(): Int32 {
        return Int32(UInt32(length))
    }

    public func getLimit(): Int32 {
        return index + Int32(UInt32(length))
    }

    public func getValue(): Int32 {
        return Int32(value)
    }

    public func getArgType(): MessagePattern_ArgType {
        let Type = getType()
        if (refEq(Type, MessagePattern_Part_Type.ARG_START) || refEq(Type, MessagePattern_Part_Type.ARG_LIMIT)) {
            return MessagePattern.argTypes[Int64(value)]
        } else {
            return MessagePattern_ArgType.NONE
        }
    }

    public override func toString(): String {
        let valueString: String = if (refEq(Type, MessagePattern_Part_Type.ARG_START) || refEq(Type, MessagePattern_Part_Type.ARG_LIMIT)) { getArgType().name } else { Int32(value).toString() }
        return Type.name + "(" + (valueString) + ")@" + index.toString()
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (other.isNone() || !refEq(TypeInfo.of(this), TypeInfo.of(other))) {
            return false
        }
        let o = other
        return refEq(Type, o.Type) && index == o.index && length == o.length && value == o.value && limitPartIndex == o.limitPartIndex
    }

    public override func hashCode(): Int64 {
        return Int64(((Int32(Type.hashCode()) * 37 + index) * 37 + Int32(UInt32(length))) * 37 + Int32(value))
    }

    static let MAX_LENGTH = 65535

    static let MAX_VALUE = Int32(Int16.Max)

    let Type: MessagePattern_Part_Type

    let index: Int32

    let length: Char

    var value: Int16 = 0

    var limitPartIndex: Int32 = 0
}


public class MessagePattern_Part_Type <: Enum<MessagePattern_Part_Type> {
    public static let MSG_START = MessagePattern_Part_Type("MSG_START", 0)

    public static let MSG_LIMIT = MessagePattern_Part_Type("MSG_LIMIT", 1)

    public static let SKIP_SYNTAX = MessagePattern_Part_Type("SKIP_SYNTAX", 2)

    public static let INSERT_CHAR = MessagePattern_Part_Type("INSERT_CHAR", 3)

    public static let REPLACE_NUMBER = MessagePattern_Part_Type("REPLACE_NUMBER", 4)

    public static let ARG_START = MessagePattern_Part_Type("ARG_START", 5)

    public static let ARG_LIMIT = MessagePattern_Part_Type("ARG_LIMIT", 6)

    public static let ARG_NUMBER = MessagePattern_Part_Type("ARG_NUMBER", 7)

    public static let ARG_NAME = MessagePattern_Part_Type("ARG_NAME", 8)

    public static let ARG_TYPE = MessagePattern_Part_Type("ARG_TYPE", 9)

    public static let ARG_STYLE = MessagePattern_Part_Type("ARG_STYLE", 10)

    public static let ARG_SELECTOR = MessagePattern_Part_Type("ARG_SELECTOR", 11)

    public static let ARG_INT = MessagePattern_Part_Type("ARG_INT", 12)

    public static let ARG_DOUBLE = MessagePattern_Part_Type("ARG_DOUBLE", 13)

    private static func _values(): Array<MessagePattern_Part_Type> {
        return [MessagePattern_Part_Type.MSG_START, MessagePattern_Part_Type.MSG_LIMIT, MessagePattern_Part_Type.SKIP_SYNTAX, MessagePattern_Part_Type.INSERT_CHAR, MessagePattern_Part_Type.REPLACE_NUMBER, MessagePattern_Part_Type.ARG_START, MessagePattern_Part_Type.ARG_LIMIT, MessagePattern_Part_Type.ARG_NUMBER, MessagePattern_Part_Type.ARG_NAME, MessagePattern_Part_Type.ARG_TYPE, MessagePattern_Part_Type.ARG_STYLE, MessagePattern_Part_Type.ARG_SELECTOR, MessagePattern_Part_Type.ARG_INT, MessagePattern_Part_Type.ARG_DOUBLE]
    }

    private static let _VALUES = MessagePattern_Part_Type._values()

    public static func values(): Array<MessagePattern_Part_Type> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): MessagePattern_Part_Type {
        return (TypeInfo.of<MessagePattern_Part_Type>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as MessagePattern_Part_Type
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public func hasNumericValue(): Bool {
        return refEq(this, ARG_INT) || refEq(this, ARG_DOUBLE)
    }
}


public class MessagePattern_ArgType <: Enum<MessagePattern_ArgType> {
    public static let NONE = MessagePattern_ArgType("NONE", 0)

    public static let SIMPLE = MessagePattern_ArgType("SIMPLE", 1)

    public static let CHOICE = MessagePattern_ArgType("CHOICE", 2)

    public static let PLURAL = MessagePattern_ArgType("PLURAL", 3)

    public static let SELECT = MessagePattern_ArgType("SELECT", 4)

    public static let SELECTORDINAL = MessagePattern_ArgType("SELECTORDINAL", 5)

    private static func _values(): Array<MessagePattern_ArgType> {
        return [MessagePattern_ArgType.NONE, MessagePattern_ArgType.SIMPLE, MessagePattern_ArgType.CHOICE, MessagePattern_ArgType.PLURAL, MessagePattern_ArgType.SELECT, MessagePattern_ArgType.SELECTORDINAL]
    }

    private static let _VALUES = MessagePattern_ArgType._values()

    public static func values(): Array<MessagePattern_ArgType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): MessagePattern_ArgType {
        return (TypeInfo.of<MessagePattern_ArgType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as MessagePattern_ArgType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public func hasPluralStyle(): Bool {
        return refEq(this, PLURAL) || refEq(this, SELECTORDINAL)
    }
}
