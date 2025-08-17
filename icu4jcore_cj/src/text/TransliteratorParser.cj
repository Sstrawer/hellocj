package icu4cj.text


class TransliteratorParser {
    public var dataVector: ArrayList<RuleBasedTransliterator_Data>

    public var idBlockVector: ArrayList<String>

    var curData: RuleBasedTransliterator_Data

    public var compoundFilter: UnicodeSet

    private var direction: Int32 = 0

    var parseData: TransliteratorParser_ParseData

    var variablesVector: ArrayList<Object>

    var variableNames: Map<String, Array<Char>> = None

    private var segmentStandins: StringBuffer = None

    private var segmentObjects: ArrayList<StringMatcher>

    private var variableNext: Char = '\u{0000}'

    private var variableLimit: Char = '\u{0000}'

    private var undefinedVariableName: String

    private var dotStandIn = -1

    private static let ID_TOKEN = "::"

    private static let ID_TOKEN_LEN = 2

    private static let VARIABLE_DEF_OP = '='

    private static let FORWARD_RULE_OP = '>'

    private static let REVERSE_RULE_OP = '<'

    private static let FWDREV_RULE_OP = '~'

    private static let OPERATORS = "=><\u{2190}\u{2192}\u{2194}"

    static let HALF_ENDERS = "=><\u{2190}\u{2192}\u{2194};"

    static let QUOTE = '''

    static let ESCAPE = '\'

    private static let END_OF_RULE = ';'

    private static let RULE_COMMENT_CHAR = '#'

    static let CONTEXT_ANTE = '{'

    static let CONTEXT_POST = '}'

    static let CURSOR_POS = '|'

    static let CURSOR_OFFSET = '@'

    static let ANCHOR_START = '^'

    static let KLEENE_STAR = '*'

    static let ONE_OR_MORE = '+'

    static let ZERO_OR_ONE = '?'

    static let DOT = '.'

    private static let DOT_SET = "[^[:Zp:][:Zl:]\\r\\n$]"

    static let SEGMENT_OPEN = '('

    static let SEGMENT_CLOSE = ')'

    static let FUNCTION = '&'

    private static let ALT_REVERSE_RULE_OP = '\u{2190}'

    private static let ALT_FORWARD_RULE_OP = '\u{2192}'

    private static let ALT_FWDREV_RULE_OP = '\u{2194}'

    static let ALT_FUNCTION = '\u{2206}'

    static var ILLEGAL_TOP: UnicodeSet = UnicodeSet("[\\)]")

    static var ILLEGAL_SEG: UnicodeSet = UnicodeSet("[\\{\\}\\|\\@]")

    static var ILLEGAL_FUNC: UnicodeSet = UnicodeSet("[\\^\\(\\.\\*\\+\\\\{\\}\\|\\@]")

    public init() { }

    public func parse(rules: String, dir: Int32): Unit {
        parseRules(TransliteratorParser_RuleArray([rules]), dir)
    }

    public func parseRules(ruleArray: TransliteratorParser_RuleBody, dir: Int32): Unit {
        var parsingIDs = true
        var ruleCount = 0
        dataVector = ArrayList<RuleBasedTransliterator_Data>()
        idBlockVector = ArrayList<String>()
        curData = None
        direction = dir
        compoundFilter = None
        variablesVector = ArrayList<Object>()
        variableNames = HashMap<String, Array<Char>>()
        parseData = TransliteratorParser_ParseData(this)
        let errors = ArrayList<Exception>()
        var errorCount = 0
        ruleArray.reset()
        let idBlockResult = StringBuilder()
        this.compoundFilter = None
        var compoundFilterOffset = -1
    private func parseRule(rule: String, pos: Int32, limit: Int32): Int32 {
        var temppos = pos
        let start = temppos
        var oper = Char(0)
        segmentStandins = StringBuffer()
        segmentObjects = ArrayList<StringMatcher>()
        var left: TransliteratorParser_RuleHalf = TransliteratorParser_RuleHalf()
        var right: TransliteratorParser_RuleHalf = TransliteratorParser_RuleHalf()
        undefinedVariableName = None
        temppos = left.parse(rule, temppos, limit, this)
        if (temppos == limit || indexOfWrap(OPERATORS.indexOf(UInt8(UInt32(match (0) { case _ => oper = Char(rule[Int64(match (0) { case _ => temppos--; temppos })]); oper })))) < 0) {
            syntaxError("No operator pos=" + temppos.toString(), rule, start)
        }
        temppos++
        if (oper == REVERSE_RULE_OP && (temppos < limit && Char(rule[Int64(temppos)]) == FORWARD_RULE_OP)) {
            temppos++
            oper = FWDREV_RULE_OP
        }
        match (oper) {
            case '\u{2192}' => oper = FORWARD_RULE_OP
            case '\u{2190}' => oper = REVERSE_RULE_OP
            case '\u{2194}' => oper = FWDREV_RULE_OP
            case _ => ()
        }
        temppos = right.parse(rule, temppos, limit, this)
        if (temppos < limit) {
            if (Char(rule[Int64(match (0) { case _ => temppos--; temppos })]) == END_OF_RULE) {
                temppos++
            } else {
                syntaxError("Unquoted operator", rule, start)
            }
        }
        if (oper == VARIABLE_DEF_OP) {
            if (undefinedVariableName.isNone()) {
                syntaxError("Missing '$' or duplicate definition", rule, start)
            }
            if (Int32(left.text.size) != 1 || Char(left.text[0]) != variableLimit) {
                syntaxError("Malformed LHS", rule, start)
            }
            if (left.anchorStart || left.anchorEnd || right.anchorStart || right.anchorEnd) {
                syntaxError("Malformed variable def", rule, start)
            }
            let n = Int32(right.text.size)
            let value = Array<Char>(Int64(n)) { _ => '\u{0000}' }
            right.text.toRuneArray().copyTo(value, 0, 0, Int64(n - 0))
            variableNames.put(undefinedVariableName, value)
            variableLimit++
            return temppos
        }
        if (undefinedVariableName.isSome()) {
            syntaxError("Undefined variable $" + (undefinedVariableName), rule, start)
        }
        if (Int32(segmentStandins.size) > Int32(segmentObjects.size)) {
            syntaxError("Undefined segment reference", rule, start)
        }
                i++
            }
        } while (false)
                i++
            }
        } while (false)
        if (oper != FWDREV_RULE_OP && ((direction == Transliterator.FORWARD) != (oper == FORWARD_RULE_OP))) {
            return temppos
        }
        if (direction == Transliterator.REVERSE) {
            let temp = left
            left = right
            right = temp
        }
        if (oper == FWDREV_RULE_OP) {
            right.removeContext()
            left.cursor = -1
            left.cursorOffset = 0
        }
        if (left.ante < 0) {
            left.ante = 0
        }
        if (left.post < 0) {
            left.post = Int32(left.text.size)
        }
        if (right.ante >= 0 || right.post >= 0 || left.cursor >= 0 || (right.cursorOffset != 0 && right.cursor < 0) || right.anchorStart || right.anchorEnd || !left.isValidInput(this) || !right.isValidOutput(this) || left.ante > left.post) {
            syntaxError("Malformed rule", rule, start)
        }
        var segmentsArray: Array<UnicodeMatcher>
        if (Int32(segmentObjects.size) > 0) {
            segmentsArray = Array<UnicodeMatcher>(segmentObjects.size)
            segmentObjects.toArray(segmentsArray)
        }
        curData.ruleSet.addRule(TransliterationRule(left.text, left.ante, left.post, right.text, right.cursor, right.cursorOffset, segmentsArray, left.anchorStart, left.anchorEnd, curData))
        return temppos
    }

    private func setVariableRange(start: Int32, end: Int32): Unit {
        if (start > end || start < 0 || end > 65535) {
            throw IllegalIcuArgumentException("Invalid variable range " + start.toString() + ", " + end.toString())
        }
        curData.variablesBase = Char(start)
        if (Int32(dataVector.size) == 0) {
            variableNext = Char(start)
            variableLimit = Char(end + 1)
        }
    }

    public func checkVariableRange(ch: Int32, rule: String, start: Int32): Unit {
        if (ch >= Int32(UInt32(curData.variablesBase)) && ch < Int32(UInt32(variableLimit))) {
            syntaxError("Variable range character in rule", rule, start)
        }
    }

    private func pragmaMaximumBackup(backup: Int32): Unit {
        throw IllegalIcuArgumentException("use maximum backup pragma not implemented yet")
    }

    private func pragmaNormalizeRules(mode: Normalizer_Mode): Unit {
        throw IllegalIcuArgumentException("use normalize rules pragma not implemented yet")
    }

    static func resemblesPragma(rule: String, pos: Int32, limit: Int32): Bool {
        return Utility.parsePattern(rule, pos, limit, "use ", None) >= 0
    }

    private func parsePragma(rule: String, pos: Int32, limit: Int32): Int32 {
        var temppos = pos
        let array = Array<Int32>(2) { _ => 0 }
        temppos += 4
        var p = Utility.parsePattern(rule, temppos, limit, "~variable range # #~;", array)
        if (p >= 0) {
            setVariableRange(array[0], array[1])
            return p
        }
        p = Utility.parsePattern(rule, temppos, limit, "~maximum backup #~;", array)
        if (p >= 0) {
            pragmaMaximumBackup(array[0])
            return p
        }
        p = Utility.parsePattern(rule, temppos, limit, "~nfd rules~;", None)
        if (p >= 0) {
            pragmaNormalizeRules(Normalizer.NFD)
            return p
        }
        p = Utility.parsePattern(rule, temppos, limit, "~nfc rules~;", None)
        if (p >= 0) {
            pragmaNormalizeRules(Normalizer.NFC)
            return p
        }
        return -1
    }

    static func syntaxError(msg: String, rule: String, start: Int32): Unit {
        let end = ruleEnd(rule, start, Int32(rule.size))
        throw IllegalIcuArgumentException((msg) + " in \"" + (Utility.escape(rule[Int64(start)..Int64(end)])) + '\"'.toString())
    }

    static func ruleEnd(rule: String, start: Int32, limit: Int32): Int32 {
        var end = Utility.quotedIndexOf(rule, start, limit, ";")
        if (end < 0) {
            end = limit
        }
        return end
    }

    func parseSet(rule: String, pos: ParsePosition): Char {
        let set = UnicodeSet(rule, pos, parseData)
        if (variableNext >= variableLimit) {
            throw Exception("Private use variables exhausted")
        }
        set.compact()
        return generateStandInFor(set)
    }

    public func generateStandInFor(obj: Object): Char {
        var i = 0
        while (i < Int32(variablesVector.size)) {
            if (refEq(variablesVector[Int64(i)], obj)) {
                return Char(Int32(UInt32(curData.variablesBase)) + i)
            }
            i++
        }
        if (variableNext >= variableLimit) {
            throw Exception("Variable range exhausted")
        }
        variablesVector.append(obj)
        return variableNext++
    }

    public func getSegmentStandin(seg: Int32): Char {
        if (Int32(segmentStandins.size) < seg) {
            segmentStandins.setLength(Int64(seg))
        }
        var c = segmentStandins.get(Int64(seg - 1))
        if (Int32(UInt32(c)) == 0) {
            if (variableNext >= variableLimit) {
                throw Exception("Variable range exhausted")
            }
            c = variableNext++
            variablesVector.append(None)
            segmentStandins.insert(Int64(seg - 1), c)
        }
        return c
    }

    public func setSegmentObject(seg: Int32, obj: StringMatcher): Unit {
        while (Int32(segmentObjects.size) < seg) {
            segmentObjects.append(None)
        }
        let index = 
        if (segmentObjects[Int64(seg - 1)].isSome() || variablesVector[Int64(index)].isSome()) {
            throw Exception()
        }
        segmentObjects.set(Int64(seg - 1), obj)
        variablesVector.set(Int64(index), obj)
    }

    public func getDotStandIn(): Char {
        if (dotStandIn == -1) {
            dotStandIn = Int32(UInt32(generateStandInFor(UnicodeSet(DOT_SET))))
        }
        return Char(dotStandIn)
    }

    public func appendVariableDef(name: String, buf: StringBuffer): Unit {
        let ch = variableNames.get(name)
        if (ch.isNone()) {
            if (undefinedVariableName.isNone()) {
                undefinedVariableName = name
                if (variableNext >= variableLimit) {
                    throw Exception("Private use variables exhausted")
                }
                buf.append(match (0) { case _ => variableLimit--; variableLimit })
            } else {
                throw IllegalIcuArgumentException("Undefined variable $" + (name))
            }
        } else {
            buf.append(ch)
        }
    }
}


class TransliteratorParser_ParseData <: SymbolTable {
    let this_0: TransliteratorParser

    init(this_0: TransliteratorParser) {
        this.this_0 = this_0
    }

    public override func lookup(name: String): Array<Char> {
        return this_0.variableNames.get(name)
    }

    public override func lookupMatcher(ch: Int32): UnicodeMatcher {
        let i = ch - Int32(UInt32(this_0.curData.variablesBase))
        if (i >= 0 && i < Int32(this_0.variablesVector.size)) {
            return this_0.variablesVector[Int64(i)]
        }
        return None
    }

    public override func parseReference(text: String, pos: ParsePosition, limit: Int32): String {
        let start = pos.getIndex()
        var i = start
        while (i < limit) {
            let c = Char(text[Int64(i)])
            if ((i == start && !UCharacter.isUnicodeIdentifierStart(Int32(UInt32(c)))) || !UCharacter.isUnicodeIdentifierPart(Int32(UInt32(c)))) {
                break
            }
            i++
        }
        if (i == start) {
            return None
        }
        pos.setIndex(i)
        return text[Int64(start)..Int64(i)]
    }

    public func isMatcher(ch: Int32): Bool {
        let i = ch - Int32(UInt32(this_0.curData.variablesBase))
        if (i >= 0 && i < Int32(this_0.variablesVector.size)) {
            return checkOptionalIs<UnicodeMatcher, Object>(this_0.variablesVector[Int64(i)])
        }
        return true
    }

    public func isReplacer(ch: Int32): Bool {
        let i = ch - Int32(UInt32(this_0.curData.variablesBase))
        if (i >= 0 && i < Int32(this_0.variablesVector.size)) {
            return checkOptionalIs<UnicodeReplacer, Object>(this_0.variablesVector[Int64(i)])
        }
        return true
    }
}


abstract class TransliteratorParser_RuleBody {
    init() { }

    public func nextLine(): String {
        var s = handleNextLine()
        if (s.isSome() && Int32(s.size) > 0 && Char(s[Int64(Int32(s.size) - 1)]) == '\') {
            let b = StringBuilder(s)
                b.append(s)
            } while (Int32(s.size) > 0 && Char(s[Int64(Int32(s.size) - 1)]) == '\')
            s = b.toString()
        }
        return s
    }

    public func reset(): Unit

    public func handleNextLine(): String
}


class TransliteratorParser_RuleArray <: TransliteratorParser_RuleBody {
    var array: Array<String>

    var i: Int32 = 0

    public init(array: Array<String>) {
        super()
        this.array = array
        i = 0
    }

    public override func handleNextLine(): String {
        return if (i < Int32(array.size)) { array[Int64(match (0) { case _ => i++; i - 1 })] } else { None }
    }

    public override func reset(): Unit {
        i = 0
    }
}


class TransliteratorParser_RuleHalf {
    init() { }

    public var text: String

    public var cursor = -1

    public var ante = -1

    public var post = -1

    public var cursorOffset = 0

    private var cursorOffsetPos = 0

    public var anchorStart = false

    public var anchorEnd = false

    private var nextSegmentNumber = 1

    public func parse(rule: String, pos: Int32, limit: Int32, parser: TransliteratorParser): Int32 {
        var temppos = pos
        let start = temppos
        let buf = StringBuffer()
        temppos = parseSection(rule, temppos, limit, parser, buf, TransliteratorParser.ILLEGAL_TOP, false)
        text = toString(buf)
        if (cursorOffset > 0 && cursor != cursorOffsetPos) {
            TransliteratorParser.syntaxError("Misplaced " + TransliteratorParser.CURSOR_POS.toString(), rule, start)
        }
        return temppos
    }

    private func parseSection(rule: String, pos: Int32, limit: Int32, parser: TransliteratorParser, buf: StringBuffer, illegal: UnicodeSet, isSegment: Bool): Int32 {
        var temppos = pos
        let start = temppos
        var pp: ParsePosition = None
        var quoteStart = -1
        var quoteLimit = -1
        var varStart = -1
        var varLimit = -1
        let iref = Array<Int32>(1) { _ => 0 }
        let bufStart = Int32(buf.size)
    public func removeContext(): Unit {
        text = text[if (ante < 0) { 0 } else { Int64(ante) }..if (post < 0) { text.size } else { Int64(post) }]
        ante = match (0) { case _ => post = -1; post }
        anchorStart = match (0) { case _ => anchorEnd = false; anchorEnd }
    }

    public func isValidOutput(parser: TransliteratorParser): Bool {
        var i = 0
        while (i < Int32(text.size)) {
            let c = UTF16.toRuneArray()[text, i]
            i += UTF16.getCharCount(c)
            if (!parser.parseData.isReplacer(c)) {
                return false
            }
        }
        return true
    }

    public func isValidInput(parser: TransliteratorParser): Bool {
        var i = 0
        while (i < Int32(text.size)) {
            let c = UTF16.toRuneArray()[text, i]
            i += UTF16.getCharCount(c)
            if (!parser.parseData.isMatcher(c)) {
                return false
            }
        }
        return true
    }
}
