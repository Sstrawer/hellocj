package icu4cj.impl

public class LocaleIDParser {
    private var id: Array<Char>

    private var index: Int32 = 0

    private var buffer: StringBuilder

    private var canonicalize: Bool = false

    private var hadCountry: Bool = false

    var keywords: Map<String, String> = None

    var baseName: String

    private static let KEYWORD_SEPARATOR = '@'

    private static let HYPHEN = '-'

    private static let KEYWORD_ASSIGN = '='

    private static let COMMA = ','

    private static let ITEM_SEPARATOR = ';'

    private static let DOT = '.'

    private static let UNDERSCORE = '_'

    public init(localeID: String) {
        this(localeID, false)
    }

    public init(localeID: String, canonicalize: Bool) {
        id = localeID.toRuneArray()
        index = 0
        buffer = StringBuilder()
        this.canonicalize = canonicalize
    }

    private func reset(): Unit {
        index = 0
        buffer = StringBuilder()
    }

    private func append(c: Char): Unit {
        buffer.append(c)
    }

    private func addSeparator(): Unit {
        append(UNDERSCORE)
    }

    private func getString(start: Int32): String {
        return buffer.substring(start)
    }

    private func set(pos: Int32, s: String): Unit {
        buffer.delete(pos, Int32(buffer.size))
        buffer.insert(Int64(pos), s)
    }

    private func append(s: String): Unit {
        buffer.append(s)
    }

    private static let DONE = '\u{ffff}'

    private func next(): Char {
        if (index == Int32(id.size)) {
            index++
            return DONE
        }
        return id[Int64(match (0) { case _ => index++; index - 1 })]
    }

    private func skipUntilTerminatorOrIDSeparator(): Unit {
        while (!isTerminatorOrIDSeparator(next())) { }
        index--
    }

    private func atTerminator(): Bool {
        return index >= Int32(id.size) || isTerminator(id[Int64(index)])
    }

    private func isTerminator(c: Char): Bool {
        return c == KEYWORD_SEPARATOR || c == DONE || c == DOT
    }

    private func isTerminatorOrIDSeparator(c: Char): Bool {
        return c == UNDERSCORE || c == HYPHEN || isTerminator(c)
    }

    private func haveExperimentalLanguagePrefix(): Bool {
        if (Int32(id.size) > 2) {
            var c = id[1]
            if (c == HYPHEN || c == UNDERSCORE) {
                c = id[0]
                return c == 'x' || c == 'X' || c == 'i' || c == 'I'
            }
        }
        return false
    }

    private func haveKeywordAssign(): Bool {
        var i = index
        while (i < Int32(id.size)) {
            if (id[Int64(i)] == KEYWORD_ASSIGN) {
                return true
            }
            i++
        }
        return false
    }

    private func parseLanguage(): Int32 {
        let startLength = Int32(buffer.size)
        if (haveExperimentalLanguagePrefix()) {
            append(AsciiUtil.toLower(id[0]))
            append(HYPHEN)
            index = 2
        }
        var c: Char = '\u{0000}'
        while (!isTerminatorOrIDSeparator(match (0) { case _ => c = next(); c })) {
            append(AsciiUtil.toLower(c))
        }
        index--
        if (Int32(buffer.size) - startLength == 3) {
            let lang = LocaleIDs.threeToTwoLetterLanguage(getString(0))
            if (lang.isSome()) {
                set(0, lang)
            }
        }
        return 0
    }

    private func skipLanguage(): Unit {
        if (haveExperimentalLanguagePrefix()) {
            index = 2
        }
        skipUntilTerminatorOrIDSeparator()
    }

    private func parseScript(): Int32 {
        if (!atTerminator()) {
            let oldIndex = index
            index++
            var oldBlen = Int32(buffer.size)
            var c: Char = '\u{0000}'
            var firstPass = true
            while (!isTerminatorOrIDSeparator(match (0) { case _ => c = next(); c }) && AsciiUtil.isAlpha(c)) {
                if (firstPass) {
                    addSeparator()
                    append(AsciiUtil.toUpper(c))
                    firstPass = false
                } else {
                    append(AsciiUtil.toLower(c))
                }
            }
            index--
            if (index - oldIndex != 5) {
                index = oldIndex
                buffer.delete(oldBlen, Int32(buffer.size))
            } else {
                oldBlen++
            }
            return oldBlen
        }
        return Int32(buffer.size)
    }

    private func skipScript(): Unit {
        if (!atTerminator()) {
            let oldIndex = index
            index++
            var c: Char = '\u{0000}'
            while (!isTerminatorOrIDSeparator(match (0) { case _ => c = next(); c }) && AsciiUtil.isAlpha(c)) { }
            index--
            if (index - oldIndex != 5) {
                index = oldIndex
            }
        }
    }

    private func parseCountry(): Int32 {
        if (!atTerminator()) {
            let oldIndex = index
            index++
            var oldBlen = Int32(buffer.size)
            var c: Char = '\u{0000}'
            var firstPass = true
            while (!isTerminatorOrIDSeparator(match (0) { case _ => c = next(); c })) {
                if (firstPass) {
                    hadCountry = true
                    addSeparator()
                    oldBlen++
                    firstPass = false
                }
                append(AsciiUtil.toUpper(c))
            }
            index--
            let charsAppended = Int32(buffer.size) - oldBlen
            if (charsAppended == 0) { } else if (charsAppended < 2 || charsAppended > 3) {
                index = oldIndex
                oldBlen--
                buffer.delete(oldBlen, Int32(buffer.size))
                hadCountry = false
            } else if (charsAppended == 3) {
                let region = LocaleIDs.threeToTwoLetterRegion(getString(oldBlen))
                if (region.isSome()) {
                    set(oldBlen, region)
                }
            }
            return oldBlen
        }
        return Int32(buffer.size)
    }

    private func skipCountry(): Unit {
        if (!atTerminator()) {
            if (id[Int64(index)] == UNDERSCORE || id[Int64(index)] == HYPHEN) {
                index++
            }
            let oldIndex = index
            skipUntilTerminatorOrIDSeparator()
            let charsSkipped = index - oldIndex
            if (charsSkipped < 2 || charsSkipped > 3) {
                index = oldIndex
            }
        }
    }

    private static let MAX_VARIANTS_LENGTH = 179

    private func parseVariant(): Int32 {
        var oldBlen = Int32(buffer.size)
        var start = true
        var needSeparator = true
        var skipping = false
        var c: Char = '\u{0000}'
        var firstPass = true
        while ((match (0) { case _ => c = next(); c }) != DONE) {
            if (c == DOT) {
                start = false
                skipping = true
            } else if (c == KEYWORD_SEPARATOR) {
                if (haveKeywordAssign()) {
                    break
                }
                skipping = false
                start = false
                needSeparator = true
            } else if (start) {
                start = false
                if (c != UNDERSCORE && c != HYPHEN) {
                    index--
                }
            } else if (!skipping) {
                if (needSeparator) {
                    needSeparator = false
                    if (firstPass && !hadCountry) {
                        addSeparator()
                        oldBlen++
                    }
                    addSeparator()
                    if (firstPass) {
                        oldBlen++
                        firstPass = false
                    }
                }
                c = AsciiUtil.toUpper(c)
                if (c == HYPHEN || c == COMMA) {
                    c = UNDERSCORE
                }
                append(c)
                if (Int32(buffer.size) - oldBlen > MAX_VARIANTS_LENGTH) {
                    throw IllegalArgumentException("variants is too long")
                }
            }
        }
        index--
        return oldBlen
    }

    public func getLanguage(): String {
        reset()
        return getString(parseLanguage())
    }

    public func getScript(): String {
        reset()
        skipLanguage()
        return getString(parseScript())
    }

    public func getCountry(): String {
        reset()
        skipLanguage()
        skipScript()
        return getString(parseCountry())
    }

    public func getVariant(): String {
        reset()
        skipLanguage()
        skipScript()
        skipCountry()
        return getString(parseVariant())
    }

    public func getLanguageScriptCountryVariant(): Array<String> {
        reset()
        return [getString(parseLanguage()), getString(parseScript()), getString(parseCountry()), getString(parseVariant())]
    }

    public func setBaseName(baseName: String): Unit {
        this.baseName = baseName
    }

    public func parseBaseName(): Unit {
        if (baseName.isSome()) {
            set(0, baseName)
        } else {
            reset()
            parseLanguage()
            parseScript()
            parseCountry()
            parseVariant()
            let len = Int32(buffer.size)
            if (len > 0 && buffer.get(Int64(len - 1)) == UNDERSCORE) {
                buffer.deleteCharAt(Int64(len - 1))
            }
        }
    }

    public func getBaseName(): String {
        if (baseName.isSome()) {
            return baseName
        }
        parseBaseName()
        return getString(0)
    }

    public func getName(): String {
        parseBaseName()
        parseKeywords()
        return getString(0)
    }

    private func setToKeywordStart(): Bool {
        var i = index
        while (i < Int32(id.size)) {
            if (id[Int64(i)] == KEYWORD_SEPARATOR) {
                if (canonicalize) {
                    var j = match (0) { case _ => i++; i }
                    while (j < Int32(id.size)) {
                        if (id[Int64(j)] == KEYWORD_ASSIGN) {
                            index = i
                            return true
                        }
                        j++
                    }
                } else {
                    if (match (0) { case _ => i++; i } < Int32(id.size)) {
                        index = i
                        return true
                    }
                }
                break
            }
            i++
        }
        return false
    }

    private static func isDoneOrKeywordAssign(c: Char): Bool {
        return c == DONE || c == KEYWORD_ASSIGN
    }

    private static func isDoneOrItemSeparator(c: Char): Bool {
        return c == DONE || c == ITEM_SEPARATOR
    }

    private func getKeyword(): String {
        let start = index
        while (!isDoneOrKeywordAssign(next())) { }
        index--
        return AsciiUtil.toLowerString(String(id)[Int64(start)..Int64(start) + Int64(index - start)].trimAscii())
    }

    private func getValue(): String {
        let start = index
        while (!isDoneOrItemSeparator(next())) { }
        index--
        return String(id)[Int64(start)..Int64(start) + Int64(index - start)].trimAscii()
    }

    private func getKeyComparator(): Comparator {
        let comp = LocaleIDParser_1(this)
        return comp
    }

    public func getKeywordMap(): Map<String, String> {
        if (keywords.isNone()) {
            var m: TreeMap = None
            if (setToKeywordStart()) {
                    let c = next()
                    if (c != KEYWORD_ASSIGN) {
                        if (c == DONE) {
                            break
                        } else {
                            continue
                        }
                    }
                    let value = getValue()
                    if (Int32(value.size) == 0) {
                        continue
                    }
                    if (m.isNone()) {
                        m = TreeMap(getKeyComparator())
                    } else if (m.contains(key)) {
                        continue
                    }
                    m.put(key, value)
                } while (next() == ITEM_SEPARATOR)
            }
            keywords = if (m.isSome()) { m } else { Collections.emptyMap<<--, // Cannot infer type argument: V -->>() }
        }
        return keywords
    }

    private func parseKeywords(): Int32 {
        var oldBlen = Int32(buffer.size)
        let m = getKeywordMap()
        if (!m.isEmpty()) {
            var first = true
            for (e in m.entrySet()) {
                append(if (first) { KEYWORD_SEPARATOR } else { ITEM_SEPARATOR })
                first = false
                append(e.getKey())
                append(KEYWORD_ASSIGN)
                append(e.getValue())
            }
            if (first == false) {
                oldBlen++
            }
        }
        return oldBlen
    }

    public func getKeywords(): Iterator<String> {
        let m = getKeywordMap()
        return if (m.isEmpty()) { None } else { SetCollectionView<String>(m.keys()).iterator() }
    }

    public func getKeywordValue(keywordName: String): String {
        let m = getKeywordMap()
        return if (m.isEmpty()) { None } else { m.get(AsciiUtil.toLowerString(keywordName.trimAscii())) }
    }

    public func defaultKeywordValue(keywordName: String, value: String): Unit {
        setKeywordValue(keywordName, value, false)
    }

    public func setKeywordValue(keywordName: String, value: String): Unit {
        setKeywordValue(keywordName, value, true)
    }

    private func setKeywordValue(keywordName: String, value: String, reset: Bool): Unit {
        var tempkeywordName = keywordName
        var tempvalue = value
        if (tempkeywordName.isNone()) {
            if (reset) {
                keywords = Collections.emptyMap<<--, // Cannot infer type argument: V -->>()
            }
        } else {
            tempkeywordName = AsciiUtil.toLowerString(tempkeywordName.trimAscii())
            if (Int32(tempkeywordName.size) == 0) {
                throw IllegalArgumentException("keyword must not be empty")
            }
            if (tempvalue.isSome()) {
                tempvalue = tempvalue.trimAscii()
                if (Int32(tempvalue.size) == 0) {
                    throw IllegalArgumentException("value must not be empty")
                }
            }
            let m = getKeywordMap()
            if (m.isEmpty()) {
                if (tempvalue.isSome()) {
                    keywords = TreeMap(getKeyComparator()) as Map<String, String>
                    keywords.put(tempkeywordName, tempvalue.trimAscii())
                }
            } else {
                if (reset || !m.contains(tempkeywordName)) {
                    if (tempvalue.isSome()) {
                        m.put(tempkeywordName, tempvalue)
                    } else {
                        m.remove(tempkeywordName)
                        if (m.isEmpty()) {
                            keywords = Collections.emptyMap<<--, // Cannot infer type argument: V -->>()
                        }
                    }
                }
            }
        }
    }
}


class LocaleIDParser_1 <: Comparator {
    init(this_0: LocaleIDParser) { }

    public override func compare(lhs: String, rhs: String): Int32 {
        return lhs.compare(rhs).value()
    }
}
