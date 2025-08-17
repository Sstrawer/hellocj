package icu4cj.text


public class UnicodeSet <: UnicodeFilter & Iterable<String> & Comparable<UnicodeSet> & Freezable<UnicodeSet> {
    private static let EMPTY_STRINGS = Collections.unmodifiableSortedSet(TreeSet() as SortedSet)

    public static let EMPTY = UnicodeSet().freeze()

    public static let ALL_CODE_POINTS = UnicodeSet(0, 1114111).freeze()

    private static var XSYMBOL_TABLE: UnicodeSet_XSymbolTable

    private static let LOW = 0

    private static let HIGH = 1114112

    private static let INITIAL_CAPACITY = 25

    private static let MAX_LENGTH = HIGH + 1

    public static let MIN_VALUE = LOW

    public static let MAX_VALUE = HIGH - 1

    var len: Int32 = 0

    var list: Array<Int32>

    private var rangeList: Array<Int32>

    private var buffer: Array<Int32>

    var strings = EMPTY_STRINGS

    private var pat: String

    private static let ANY_ID = "ANY"

    private static let ASCII_ID = "ASCII"

    private static let ASSIGNED = "Assigned"

     private var bmpSet: BMPSet

     private var stringSpan: UnicodeSetStringSpan

    public init() {
        super()
        list = Array<Int32>(Int64(INITIAL_CAPACITY)) { _ => 0 }
        list[0] = HIGH
        len = 1
    }

    public init(other: UnicodeSet) {
        super()
        set(other)
    }

    public init(start: Int32, end: Int32) {
        this()
        add(start, end)
    }

    public init(pairs: Array<Int32>) {
        super()
        if ((Int32(pairs.size) & 1) != 0) {
            throw IllegalArgumentException("Must have even number of integers")
        }
        list = Array<Int32>(Int64(Int32(pairs.size) + 1)) { _ => 0 }
        len = Int32(list.size)
        var last = -1
        var i = 0
        while (i < Int32(pairs.size)) {
            let start = pairs[Int64(i)]
            if (last >= start) {
                throw IllegalArgumentException("Must be monotonically increasing.")
            }
            list[Int64(match (0) { case _ => i++; i - 1 })] = start
            let limit = pairs[Int64(i)] + 1
            if (start >= limit) {
                throw IllegalArgumentException("Must be monotonically increasing.")
            }
            list[Int64(match (0) { case _ => i++; i - 1 })] = match (0) { case _ => last = limit; last }
        }
        list[Int64(i)] = HIGH
    }

    public init(pattern: String) {
        this()
        applyPattern(pattern, None, None, IGNORE_SPACE)
    }

    public init(pattern: String, ignoreWhitespace: Bool) {
        this()
        applyPattern(pattern, None, None, if (ignoreWhitespace) { IGNORE_SPACE } else { 0 })
    }

    public init(pattern: String, options: Int32) {
        this()
        applyPattern(pattern, None, None, options)
    }

    public init(pattern: String, pos: ParsePosition, symbols: SymbolTable) {
        this()
        applyPattern(pattern, pos, symbols, IGNORE_SPACE)
    }

    public init(pattern: String, pos: ParsePosition, symbols: SymbolTable, options: Int32) {
        this()
        applyPattern(pattern, pos, symbols, options)
    }

    public override func clone(): Object {
        if (isFrozen()) {
            return this
        }
        return UnicodeSet(this)
    }

    public func set(start: Int32, end: Int32): UnicodeSet {
        checkFrozen()
        clear()
        complement(start, end)
        return this
    }

    public func set(other: UnicodeSet): UnicodeSet {
        checkFrozen()
        list = other.list.clone(0.. other.len)
        len = other.len
        pat = other.pat
        if (other.hasStrings()) {
            strings = TreeSet(other.strings)
        } else {
            strings = EMPTY_STRINGS
        }
        return this
    }

    public func applyPattern(pattern: String): UnicodeSet {
        checkFrozen()
        return applyPattern(pattern, None, None, IGNORE_SPACE)
    }

    public func applyPattern(pattern: String, ignoreWhitespace: Bool): UnicodeSet {
        checkFrozen()
        return applyPattern(pattern, None, None, if (ignoreWhitespace) { IGNORE_SPACE } else { 0 })
    }

    public func applyPattern(pattern: String, options: Int32): UnicodeSet {
        checkFrozen()
        return applyPattern(pattern, None, None, options)
    }

    public static func resemblesPattern(pattern: String, pos: Int32): Bool {
        return ((pos + 1) < Int32(pattern.size) && Char(pattern[Int64(pos)]) == '[') || resemblesPropertyPattern(pattern, pos)
    }

    private static func appendCodePoint(app: Appendable, c: Int32): Unit {
        if (!(0 <= c && c <= 1114111)) {
            throw AssertionError()
        }
        try {
            if (c <= 65535) {
                app.append(Char(c))
            } else {
                app.append(UTF16.getLeadSurrogate(c)).append(UTF16.getTrailSurrogate(c))
            }
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    private static func append(app: Appendable, s: String): Unit {
        try {
            app.append(s)
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    private static func _appendToPat<T>(buf: T, s: String, escapeUnprintable: Bool): T {
        var cp: Int32 = 0
        var i = 0
        while (i < Int32(s.size)) {
            cp = s.codePointAt(i)
            _appendToPat(buf, cp, escapeUnprintable)
            i += Character.charCount(cp)
        }
        return buf
    }

    static func _appendToPat<T>(buf: T, c: Int32, escapeUnprintable: Bool): T {
        try {
            if (if (escapeUnprintable) { Utility.isUnprintable(c) } else { Utility.shouldAlwaysBeEscaped(c) }) {
                return Utility.escape(buf, c)
            }
            <-- Internal error: switch (c) {
            case '[':

            case ']':

            case '-':

            case '^':

            case '&':

            case '\':

            case '{':

            case '}':

            case '$':

            case ':':
                buf.append('\');
                break;

            default:
                if (PatternProps.isWhiteSpace(c)) {
                    buf.append('\');
                }
                break;

            } -->
            appendCodePoint(buf, c)
            return buf
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    private static func _appendToPat<T>(result: T, start: Int32, end: Int32, escapeUnprintable: Bool): T {
        _appendToPat(result, start, escapeUnprintable)
        if (start != end) {
            if ((start + 1) != end || start == 56319) {
                try {
                    result.append('-')
                } catch (e: IOException) {
                    throw ICUUncheckedIOException(e)
                }
            }
            _appendToPat(result, end, escapeUnprintable)
        }
        return result
    }

    public override func toPattern(escapeUnprintable: Bool): String {
        if (pat.isSome() && !escapeUnprintable) {
            return pat
        }
        let result = StringBuilder()
        return _toPattern(result as T, escapeUnprintable).toString()
    }

    private func _toPattern<T>(result: T, escapeUnprintable: Bool): T {
        if (pat.isNone()) {
            return appendNewPattern(result, escapeUnprintable, true)
        }
        try {
            if (!escapeUnprintable) {
                result.append(pat)
                return result
            }
            var oddNumberOfBackslashes = false
            var i = 0
            while (i < Int32(pat.size)) {
                let c = pat.codePointAt(i)
                i += Character.charCount(c)
                if (Utility.isUnprintable(c)) {
                    Utility.escape(result, c)
                    oddNumberOfBackslashes = false
                } else if (!oddNumberOfBackslashes && c == Int32(UInt32('\'))) {
                    oddNumberOfBackslashes = true
                } else {
                    if (oddNumberOfBackslashes) {
                        result.append('\')
                    }
                    appendCodePoint(result, c)
                    oddNumberOfBackslashes = false
                }
            }
            if (oddNumberOfBackslashes) {
                result.append('\')
            }
            return result
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public func _generatePattern(result: StringBuffer, escapeUnprintable: Bool): StringBuffer {
        return _generatePattern(result, escapeUnprintable, true)
    }

    public func _generatePattern(result: StringBuffer, escapeUnprintable: Bool, includeStrings: Bool): StringBuffer {
        return appendNewPattern(result, escapeUnprintable, includeStrings)
    }

    private func appendNewPattern<T>(result: T, escapeUnprintable: Bool, includeStrings: Bool): T {
        try {
            result.append('[')
            var i = 0
            var limit = len & 
            if (len >= 4 && list[0] == 0 && limit == len && !hasStrings()) {
                result.append('^')
                i = 1
                limit--
            }
            while (i < limit) {
                var start = list[Int64(i)]
                let end = list[Int64(i + 1)] - 1
                if (!(55296 <= end && end <= 56319)) {
                    _appendToPat(result, start, end, escapeUnprintable)
                    i += 2
                } else {
                    let firstLead = i
                    while ((i < limit && list[Int64(i)] <= 56319) { }
                    let firstAfterLead = i
                    while (i < limit && (match (0) { case _ => start = list[Int64(i)]; start }) <= 57343) {
                        _appendToPat(result, start, list[Int64(i + 1)] - 1, escapeUnprintable)
                        i += 2
                    }
                    var j = firstLead
                    while (j < firstAfterLead) {
                        _appendToPat(result, list[Int64(j)], list[Int64(j + 1)] - 1, escapeUnprintable)
                        j += 2
                    }
                }
            }
            if (includeStrings && hasStrings()) {
                for (s in strings) {
                    result.append('{')
                    _appendToPat(result, s, escapeUnprintable)
                    result.append('}')
                }
            }
            result.append(']')
            return result
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
    }

    public func size(): Int32 {
        var n = 0
        let count = getRangeCount()
        var i = 0
        while (i < count) {
            n += getRangeEnd(i) - getRangeStart(i) + 1
            i++
        }
        return n + Int32(strings.size)
    }

    public func isEmpty(): Bool {
        return len == 1 && !hasStrings()
    }

    public func hasStrings(): Bool {
        return !strings.isEmpty()
    }

    public override func matchesIndexValue(v: Int32): Bool {
        var i = 0
        while (i < getRangeCount()) {
            let low = getRangeStart(i)
            let high = getRangeEnd(i)
            if ((low & ) == (high & )) {
                if ((low & 255) <= v && v <= (high & 255)) {
                    return true
                }
            } else if ((low & 255) <= v || v <= (high & 255)) {
                return true
            }
            i++
        }
        if (hasStrings()) {
            for (s in strings) {
                if (s.isEmpty()) {
                    continue
                }
                let c = UTF16.toRuneArray()[s, 0]
                if ((c & 255) == v) {
                    return true
                }
            }
        }
        return false
    }

    public override func matches(text: Replaceable, offset: Array<Int32>, limit: Int32, incremental: Bool): Int32 {
        if (offset[0] == limit) {
            if (contains(Int32(UInt32(UnicodeMatcher.ETHER)))) {
                return if (incremental) { U_PARTIAL_MATCH } else { U_MATCH }
            } else {
                return U_MISMATCH
            }
        } else {
            if (hasStrings()) {
                let forward = offset[0] < limit
                let firstChar = text.toRuneArray()[offset[0]]
                var highWaterLength = 0
                for (trial in strings) {
                    if (trial.isEmpty()) {
                        continue
                    }
                    let c = Char(trial[if (forward) { 0 } else { Int64(Int32(trial.size) - 1) }])
                    if (forward && c > firstChar) {
                        break
                    }
                    if (c != firstChar) {
                        continue
                    }
                    let length = matchRest(text, offset[0], limit, trial)
                    if (incremental) {
                        let maxLen = if (forward) { limit - offset[0] } else { offset[0] - limit }
                        if (length == maxLen) {
                            return U_PARTIAL_MATCH
                        }
                    }
                    if (length == Int32(trial.size)) {
                        if (length > highWaterLength) {
                            highWaterLength = length
                        }
                        if (forward && length < highWaterLength) {
                            break
                        }
                        continue
                    }
                }
                if (highWaterLength != 0) {
                    offset[0] += if (forward) { highWaterLength } else { -highWaterLength }
                    return U_MATCH
                }
            }
            return super.matches(text, offset, limit, incremental)
        }
    }

    private static func matchRest(text: Replaceable, start: Int32, limit: Int32, s: String): Int32 {
        var maxLen: Int32 = 0
        var slen = Int32(s.size)
        if (start < limit) {
            maxLen = limit - start
            if (maxLen > slen) {
                maxLen = slen
            }
                    i++
                }
            } while (false)
        } else {
            maxLen = start - limit
            if (maxLen > slen) {
                maxLen = slen
            }
            slen--
                    i++
                }
            } while (false)
        }
        return maxLen
    }

    
    public func matchesAt(text: String, offset: Int32): Int32 {
        var lastLen = -1
    private static func matchesAtStatic(text: String, offsetInText: Int32, substring: String): Int32 {
        let len = substring.size
        let textLength = text.size
        if (textLength + offsetInText > len) {
            return -1
        }
        var i = 0
        var j = offsetInText
        while (i < len) {
            let pc = substring[i]
            let tc = text[j]
            if (pc != tc) {
                return -1
            }
            i++
            j++
        }
        return i
    }

    public override func addMatchSetTo(toUnionTo: UnicodeSet): Unit {
        toUnionTo.addAll(this)
    }

    public func indexOf(c: Int32): Int32 {
        if (c < MIN_VALUE || c > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(c), 6)))
        }
        var i = 0
        var n = 0
        while (true) {
            let start = list[Int64(match (0) { case _ => i++; i - 1 })]
            if (c < start) {
                return -1
            }
            let limit = list[Int64(match (0) { case _ => i++; i - 1 })]
            if (c < limit) {
                return n + c - start
            }
            n += limit - start
        }
    }

    public func charAt(index: Int32): Int32 {
        var tempindex = index
        if (tempindex >= 0) {
            let len2 = len & 
            var i = 0
            while (i < len2) {
                let start = list[Int64(match (0) { case _ => i++; i - 1 })]
                let count = list[Int64(match (0) { case _ => i++; i - 1 })] - start
                if (tempindex < count) {
                    return start + tempindex
                }
                tempindex -= count
            }
        }
        return -1
    }

    public func add(start: Int32, end: Int32): UnicodeSet {
        checkFrozen()
        return add_unchecked(start, end)
    }

    public func addAll(start: Int32, end: Int32): UnicodeSet {
        checkFrozen()
        return add_unchecked(start, end)
    }

    private func add_unchecked(start: Int32, end: Int32): UnicodeSet {
        if (start < MIN_VALUE || start > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(start), 6)))
        }
        if (end < MIN_VALUE || end > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(end), 6)))
        }
        if (start < end) {
            let limit = end + 1
            if ((len & 1) != 0) {
                let lastLimit = if (len == 1) { -2 } else { list[Int64(len - 2)] }
                if (lastLimit <= start) {
                    checkFrozen()
                    if (lastLimit == start) {
                        list[Int64(len - 2)] = limit
                        if (limit == HIGH) {
                            len--
                        }
                    } else {
                        list[Int64(len - 1)] = start
                        if (limit < HIGH) {
                            ensureCapacity(len + 2)
                            list[Int64(match (0) { case _ => len++; len - 1 })] = limit
                            list[Int64(match (0) { case _ => len++; len - 1 })] = HIGH
                        } else {
                            ensureCapacity(len + 1)
                            list[Int64(match (0) { case _ => len++; len - 1 })] = HIGH
                        }
                    }
                    pat = None
                    return this
                }
            }
            add(range(start, end), 2, 0)
        } else if (start == end) {
            add(start)
        }
        return this
    }

    public func add(c: Int32): UnicodeSet {
        checkFrozen()
        return add_unchecked(c)
    }

    private func add_unchecked(c: Int32): UnicodeSet {
        if (c < MIN_VALUE || c > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(c), 6)))
        }
        let i = findCodePoint(c)
        if ((i & 1) != 0) {
            return this
        }
        if (c == list[Int64(i)] - 1) {
            list[Int64(i)] = c
            if (c == MAX_VALUE) {
                ensureCapacity(len + 1)
                list[Int64(match (0) { case _ => len++; len - 1 })] = HIGH
            }
            if (i > 0 && c == list[Int64(i - 1)]) {
                arraycopy(list, Int64(i + 1), list, Int64(i - 1), Int64(len - i - 1))
                len -= 2
            }
        } else if (i > 0 && c == list[Int64(i - 1)]) {
            list[Int64(i - 1)] += 1
        } else {
            if (len + 2 > Int32(list.size)) {
                let temp = Array<Int32>(Int64(nextCapacity(len + 2))) { _ => 0 }
                if (i != 0) {
                    arraycopy(list, 0, temp, 0, Int64(i))
                }
                arraycopy(list, Int64(i), temp, Int64(i + 2), Int64(len - i))
                list = temp
            } else {
                arraycopy(list, Int64(i), list, Int64(i + 2), Int64(len - i))
            }
            list[Int64(i)] = c
            list[Int64(i + 1)] = c + 1
            len += 2
        }
        pat = None
        return this
    }

    public func add(s: String): UnicodeSet {
        checkFrozen()
        let cp = getSingleCP(s)
        if (cp < 0) {
            let str: String = toString(s)
            if (!strings.contains(str)) {
                addString(str)
                pat = None
            }
        } else {
            add_unchecked(cp, cp)
        }
        return this
    }

    private func addString(s: String): Unit {
        if (refEq(strings, EMPTY_STRINGS)) {
            strings = TreeSet()
        }
        strings.put(toString(s))
    }

    private static func getSingleCP(s: String): Int32 {
        if (s.size == 1) {
            return Int32(UInt32(s[0]))
        }
        if (s.size == 2) {
            let cp = Character.codePointAt(s, 0)
            if (cp > 65535) {
                return cp
            }
        }
        return -1
    }

    public func addAll(s: String): UnicodeSet {
        checkFrozen()
        var cp: Int32 = 0
        var i = 0
        while (i < s.size) {
            cp = UTF16.toRuneArray()[s, i]
            add_unchecked(cp, cp)
            i += UTF16.getCharCount(cp)
        }
        return this
    }

    public func retainAll(s: String): UnicodeSet {
        return retainAll(fromAll(s))
    }

    public func complementAll(s: String): UnicodeSet {
        return complementAll(fromAll(s))
    }

    public func removeAll(s: String): UnicodeSet {
        return removeAll(fromAll(s))
    }

    public func removeAllStrings(): UnicodeSet {
        checkFrozen()
        if (hasStrings()) {
            strings.clear()
            pat = None
        }
        return this
    }

    public static func comefrom(s: String): UnicodeSet {
        return UnicodeSet().add(s)
    }

    public static func fromAll(s: String): UnicodeSet {
        return UnicodeSet().addAll(s)
    }

    public func retain(start: Int32, end: Int32): UnicodeSet {
        checkFrozen()
        if (start < MIN_VALUE || start > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(start), 6)))
        }
        if (end < MIN_VALUE || end > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(end), 6)))
        }
        if (start <= end) {
            retain(range(start, end), 2, 0)
        } else {
            clear()
        }
        return this
    }

    public func retain(c: Int32): UnicodeSet {
        return retain(c, c)
    }

    public func retain(cs: String): UnicodeSet {
        let cp = getSingleCP(cs)
        if (cp < 0) {
            checkFrozen()
            let s: String = toString(cs)
            let isIn = strings.contains(s)
            if (isIn && getRangeCount() == 0 && size() == 1) {
                return this
            }
            clear()
            if (isIn) {
                addString(s)
            }
            pat = None
        } else {
            retain(cp, cp)
        }
        return this
    }

    public func remove(start: Int32, end: Int32): UnicodeSet {
        checkFrozen()
        if (start < MIN_VALUE || start > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(start), 6)))
        }
        if (end < MIN_VALUE || end > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(end), 6)))
        }
        if (start <= end) {
            retain(range(start, end), 2, 2)
        }
        return this
    }

    public func remove(c: Int32): UnicodeSet {
        return remove(c, c)
    }

    public func remove(s: String): UnicodeSet {
        let cp = getSingleCP(s)
        if (cp < 0) {
            checkFrozen()
            let str: String = toString(s)
            if (strings.contains(str)) {
                strings.remove(str)
                pat = None
            }
        } else {
            remove(cp, cp)
        }
        return this
    }

    public func complement(start: Int32, end: Int32): UnicodeSet {
        checkFrozen()
        if (start < MIN_VALUE || start > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(start), 6)))
        }
        if (end < MIN_VALUE || end > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(end), 6)))
        }
        if (start <= end) {
            xor(range(start, end), 2, 0)
        }
        pat = None
        return this
    }

    public func complement(c: Int32): UnicodeSet {
        return complement(c, c)
    }

    public func complement(): UnicodeSet {
        checkFrozen()
        if (list[0] == LOW) {
            arraycopy(list, 1, list, 0, Int64(len - 1))
            len--
        } else {
            ensureCapacity(len + 1)
            arraycopy(list, 0, list, 1, Int64(len))
            list[0] = LOW
            len++
        }
        pat = None
        return this
    }

    public func complement(s: String): UnicodeSet {
        checkFrozen()
        let cp = getSingleCP(s)
        if (cp < 0) {
            let s2: String = toString(s)
            if (strings.contains(s2)) {
                strings.remove(s2)
            } else {
                addString(s2)
            }
            pat = None
        } else {
            complement(cp, cp)
        }
        return this
    }

    public override func contains(c: Int32): Bool {
        if (c < MIN_VALUE || c > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(c), 6)))
        }
        if (bmpSet.isSome()) {
            return bmpSet.contains(c)
        }
        if (stringSpan.isSome()) {
            return stringSpan.contains(c)
        }
        let i = findCodePoint(c)
        return ((i & 1) != 0)
    }

    private func findCodePoint(c: Int32): Int32 {
        if (c < list[0]) {
            return 0
        }
        if (len >= 2 && c >= list[Int64(len - 2)]) {
            return len - 1
        }
        var lo = 0
        var hi = len - 1
        while (true) {
            let i = ushr((lo + hi), 1)
            if (i == lo) {
                return hi
            }
            if (c < list[Int64(i)]) {
                hi = i
            } else {
                lo = i
            }
        }
    }

    public func contains(start: Int32, end: Int32): Bool {
        if (start < MIN_VALUE || start > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(start), 6)))
        }
        if (end < MIN_VALUE || end > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(end), 6)))
        }
        let i = findCodePoint(start)
        return ((i & 1) != 0 && end < list[Int64(i)])
    }

    public func contains(s: String): Bool {
        let cp = getSingleCP(s)
        if (cp < 0) {
            return strings.contains(toString(s))
        } else {
            return contains(cp)
        }
    }

    public func containsAll(b: UnicodeSet): Bool {
        let listB = b.list
        var needA = true
        var needB = true
        var aPtr = 0
        var bPtr = 0
        let aLen = len - 1
        let bLen = b.len - 1
        var startA = 0
        var startB = 0
        var limitA = 0
        var limitB = 0
        while (true) {
            if (needA) {
                if (aPtr >= aLen) {
                    if (needB && bPtr >= bLen) {
                        break
                    }
                    return false
                }
                startA = list[Int64(match (0) { case _ => aPtr++; aPtr - 1 })]
                limitA = list[Int64(match (0) { case _ => aPtr++; aPtr - 1 })]
            }
            if (needB) {
                if (bPtr >= bLen) {
                    break
                }
                startB = listB[Int64(match (0) { case _ => bPtr++; bPtr - 1 })]
                limitB = listB[Int64(match (0) { case _ => bPtr++; bPtr - 1 })]
            }
            if (startB >= limitA) {
                needA = true
                needB = false
                continue
            }
            if (startB >= startA && limitB <= limitA) {
                needA = false
                needB = true
                continue
            }
            return false
        }
        if (!strings.containsAll(b.strings)) {
            return false
        }
        return true
    }

    public func containsAll(s: String): Bool {
        var cp: Int32 = 0
        var i = 0
        while (i < Int32(s.size)) {
            cp = UTF16.toRuneArray()[s, i]
            if (!contains(cp)) {
                if (!hasStrings()) {
                    return false
                }
                return containsAll(s, 0)
            }
            i += UTF16.getCharCount(cp)
        }
        return true
    }

    private func containsAll(s: String, i: Int32): Bool {
        if (i >= Int32(s.size)) {
            return true
        }
        let cp = UTF16.toRuneArray()[s, i]
        if (contains(cp) && containsAll(s, i + UTF16.getCharCount(cp))) {
            return true
        }
        for (setStr in strings) {
            if (!setStr.isEmpty() && s.startsWith(setStr, i) && containsAll(s, i + Int32(setStr.size))) {
                return true
            }
        }
        return false
    }

    
    public func getRegexEquivalent(): String {
        if (!hasStrings()) {
            return toString()
        }
        let result = StringBuilder("(:")
        appendNewPattern(result as T, true, false)
        for (s in strings) {
            result.append('|')
            _appendToPat(result as T, s, true)
        }
        return result.append(")").toString()
    }

    public func containsNone(start: Int32, end: Int32): Bool {
        if (start < MIN_VALUE || start > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(start), 6)))
        }
        if (end < MIN_VALUE || end > MAX_VALUE) {
            throw IllegalArgumentException("Invalid code point U+" + (Utility.hex(Int64(end), 6)))
        }
        var i = -1
        while (true) {
            if (start < list[Int64(match (0) { case _ => i++; i })]) {
                break
            }
        }
        return ((i & 1) == 0 && end < list[Int64(i)])
    }

    public func containsNone(b: UnicodeSet): Bool {
        let listB = b.list
        var needA = true
        var needB = true
        var aPtr = 0
        var bPtr = 0
        let aLen = len - 1
        let bLen = b.len - 1
        var startA = 0
        var startB = 0
        var limitA = 0
        var limitB = 0
        while (true) {
            if (needA) {
                if (aPtr >= aLen) {
                    break
                }
                startA = list[Int64(match (0) { case _ => aPtr++; aPtr - 1 })]
                limitA = list[Int64(match (0) { case _ => aPtr++; aPtr - 1 })]
            }
            if (needB) {
                if (bPtr >= bLen) {
                    break
                }
                startB = listB[Int64(match (0) { case _ => bPtr++; bPtr - 1 })]
                limitB = listB[Int64(match (0) { case _ => bPtr++; bPtr - 1 })]
            }
            if (startB >= limitA) {
                needA = true
                needB = false
                continue
            }
            if (startA >= limitB) {
                needA = false
                needB = true
                continue
            }
            return false
        }
        if (!SortedSetRelation.hasRelation(strings, SortedSetRelation.DISJOINT, b.strings)) {
            return false
        }
        return true
    }

    public func containsNone(s: String): Bool {
        return span(s, UnicodeSet_SpanCondition.NOT_CONTAINED) == s.size
    }

    public func containsSome(start: Int32, end: Int32): Bool {
        return !containsNone(start, end)
    }

    public func containsSome(s: UnicodeSet): Bool {
        return !containsNone(s)
    }

    public func containsSome(s: String): Bool {
        return !containsNone(s)
    }

    public func addAll(c: UnicodeSet): UnicodeSet {
        checkFrozen()
        add(c.list, c.len, 0)
        if (c.hasStrings()) {
            if (refEq(strings, EMPTY_STRINGS)) {
                strings = TreeSet(c.strings)
            } else {
                strings.addAll(c.strings)
            }
        }
        return this
    }

    public func retainAll(c: UnicodeSet): UnicodeSet {
        checkFrozen()
        retain(c.list, c.len, 0)
        if (hasStrings()) {
            if (!c.hasStrings()) {
                strings.clear()
            } else {
                strings.retainAll(c.strings)
            }
        }
        return this
    }

    public func removeAll(c: UnicodeSet): UnicodeSet {
        checkFrozen()
        retain(c.list, c.len, 2)
        if (hasStrings() && c.hasStrings()) {
            strings.removeAll(c.strings)
        }
        return this
    }

    public func complementAll(c: UnicodeSet): UnicodeSet {
        checkFrozen()
        xor(c.list, c.len, 0)
        if (c.hasStrings()) {
            if (refEq(strings, EMPTY_STRINGS)) {
                strings = TreeSet(c.strings)
            } else {
                SortedSetRelation.doOperation(strings, SortedSetRelation.COMPLEMENTALL, c.strings)
            }
        }
        return this
    }

    public func clear(): UnicodeSet {
        checkFrozen()
        list[0] = HIGH
        len = 1
        pat = None
        if (hasStrings()) {
            strings.clear()
        }
        return this
    }

    public func getRangeCount(): Int32 {
        return len / 2
    }

    public func getRangeStart(index: Int32): Int32 {
        return list[Int64(index * 2)]
    }

    public func getRangeEnd(index: Int32): Int32 {
        return (list[Int64(index * 2 + 1)] - 1)
    }

    public func compact(): UnicodeSet {
        checkFrozen()
        if ((len + 7) < Int32(list.size)) {
            list = list.clone(0.. len)
        }
        rangeList = None
        buffer = None
        if (!refEq(strings, EMPTY_STRINGS) && strings.isEmpty()) {
            strings = EMPTY_STRINGS
        }
        return this
    }

    public override func equals(o: Object): Bool {
        if (o.isNone()) {
            return false
        }
        if (refEq(this, o)) {
            return true
        }
        try {
            let that = o
            if (len != that.len) {
                return false
            }
            var i = 0
            while (i < len) {
                if (list[Int64(i)] != that.list[Int64(i)]) {
                    return false
                }
                i++
            }
            if (!refEq(strings, that.strings)) {
                return false
            }
        } catch (e: Exception) {
            return false
        }
        return true
    }

    public override func hashCode(): Int64 {
        var result = len
        var i = 0
        while (i < len) {
            result *= 1000003
            result += list[Int64(i)]
            i++
        }
        return Int64(result)
    }

    public override func toString(): String {
        return toPattern(true)
    }

    
    public func applyPattern(pattern: String, pos: ParsePosition, symbols: SymbolTable, options: Int32): UnicodeSet {
        var temppos = pos
        let parsePositionWasNull = temppos.isNone()
        if (parsePositionWasNull) {
            temppos = ParsePosition(0)
        }
        let rebuiltPat = StringBuilder()
        let chars = RuleCharacterIterator(pattern, symbols, temppos)
        applyPattern(chars, symbols, rebuiltPat as Appendable, options, 0)
        if (chars.inVariable()) {
            syntaxError(chars, "Extra chars in variable value")
        }
        pat = rebuiltPat.toString()
        if (parsePositionWasNull) {
            var i = temppos.getIndex()
            if ((options & IGNORE_SPACE) != 0) {
                i = PatternProps.skipWhiteSpace(pattern, i)
            }
            if (i != Int32(pattern.size)) {
                throw IllegalArgumentException("Parse of \"" + (pattern) + "\" failed at " + i.toString())
            }
        }
        return this
    }

    private static let LAST0_START = 0

    private static let LAST1_RANGE = 1

    private static let LAST2_SET = 2

    private static let MODE0_NONE = 0

    private static let MODE1_INBRACKET = 1

    private static let MODE2_OUTBRACKET = 2

    private static let SETMODE0_NONE = 0

    private static let SETMODE1_UNICODESET = 1

    private static let SETMODE2_PROPERTYPAT = 2

    private static let SETMODE3_PREPARSED = 3

    private static let MAX_DEPTH = 100

    private func applyPattern(chars: RuleCharacterIterator, symbols: SymbolTable, rebuiltPat: Appendable, options: Int32, depth: Int32): Unit {
        if (depth > MAX_DEPTH) {
            syntaxError(chars, "Pattern nested too deeply")
        }
        var opts = RuleCharacterIterator.PARSE_VARIABLES | RuleCharacterIterator.PARSE_ESCAPES
        if ((options & IGNORE_SPACE) != 0) {
            opts |= RuleCharacterIterator.SKIP_WHITESPACE
        }
        let patBuf = StringBuilder()
        var buf: StringBuilder
        var usePat = false
        var scratch: UnicodeSet
        var backup: RuleCharacterIterator_Position
        var lastItem = LAST0_START
        var lastChar = 0
        var mode = MODE0_NONE
        var op = Char(0)
        var invert = false
        clear()
        var lastString: String
        while (mode != MODE2_OUTBRACKET && !chars.atEnd()) {
            var c = 0
            var literal = false
            var nested: UnicodeSet
            var setMode = SETMODE0_NONE
            if (resemblesPropertyPattern(chars, opts)) {
                setMode = SETMODE2_PROPERTYPAT
            } else {
                backup = chars.getPos(backup)
                c = chars.next(opts)
                literal = chars.isEscapedMethod()
                if (c == Int32(UInt32('[')) && !literal) {
                    if (mode == MODE1_INBRACKET) {
                        chars.setPos(backup)
                        setMode = SETMODE1_UNICODESET
                    } else {
                        mode = MODE1_INBRACKET
                        patBuf.append('[')
                        backup = chars.getPos(backup)
                        c = chars.next(opts)
                        literal = chars.isEscapedMethod()
                        if (c == Int32(UInt32('^')) && !literal) {
                            invert = true
                            patBuf.append('^')
                            backup = chars.getPos(backup)
                            c = chars.next(opts)
                            literal = chars.isEscapedMethod()
                        }
                        if (c == Int32(UInt32('-'))) {
                            literal = true
                        } else {
                            chars.setPos(backup)
                            continue
                        }
                    }
                } else if (symbols.isSome()) {
                    let m = symbols.lookupMatcher(c)
                    if (m.isSome()) {
                        try {
                            nested = m
                            setMode = SETMODE3_PREPARSED
                        } catch (e: ClassCastException) {
                            syntaxError(chars, "Syntax error")
                        }
                    }
                }
            }
            if (setMode != SETMODE0_NONE) {
                if (lastItem == LAST1_RANGE) {
                    if (Int32(UInt32(op)) != 0) {
                        syntaxError(chars, "Char expected after operator")
                    }
                    add_unchecked(lastChar, lastChar)
                    _appendToPat(patBuf as T, lastChar, false)
                    lastItem = LAST0_START
                    op = Char(0)
                }
                if (op == '-' || op == '&') {
                    patBuf.append(op)
                }
                if (nested.isNone()) {
                    if (scratch.isNone()) {
                        scratch = UnicodeSet()
                    }
                    nested = scratch
                }
                match (setMode) {
                    case 1 => nested.applyPattern(chars, symbols, patBuf as Appendable, options, depth + 1)
                    case 2 =>
                        chars.skipIgnored(opts)
                        nested.applyPropertyPattern(chars, patBuf as Appendable, symbols)
                    case 3 => nested._toPattern(patBuf as T, false)
                    case _ => ()
                }
                usePat = true
                if (mode == MODE0_NONE) {
                    set(nested)
                    mode = MODE2_OUTBRACKET
                    break
                }
                <-- Internal error: switch (op) {
                case '-':
                    removeAll(nested);
                    break;

                case '&':
                    retainAll(nested);
                    break;

                case 0:
                    addAll(nested);
                    break;

                } -->
                op = Char(0)
                lastItem = LAST2_SET
                continue
            }
            if (mode == MODE0_NONE) {
                syntaxError(chars, "Missing '['")
            }
            if (!literal) {
                <-- Internal error: switch (c) {
                case ']':
                    if (lastItem == LAST1_RANGE) {
                        add_unchecked(lastChar, lastChar);
                        _appendToPat(patBuf, lastChar, false);
                    }
                    if (op == '-') {
                        add_unchecked(op, op);
                        patBuf.append(op);
                    } else if (op == '&') {
                        syntaxError(chars, "Trailing '&'");
                    }
                    patBuf.append(']');
                    mode = MODE2_OUTBRACKET;
                    continue;

                case '-':
                    if (op == 0) {
                        if (lastItem != LAST0_START) {
                            op = (char)c;
                            continue;
                        } else if (lastString != null) {
                            op = (char)c;
                            continue;
                        } else {
                            add_unchecked(c, c);
                            c = chars.next(opts);
                            literal = chars.isEscapedMethod();
                            if (c == ']' && !literal) {
                                patBuf.append("-]");
                                mode = MODE2_OUTBRACKET;
                                continue;
                            }
                        }
                    }
                    syntaxError(chars, "'-' not after char, string, or set");
                    break;

                case '&':
                    if (lastItem == LAST2_SET && op == 0) {
                        op = (char)c;
                        continue;
                    }
                    syntaxError(chars, "'&' not after set");
                    break;

                case '^':
                    syntaxError(chars, "'^' not after '['");
                    break;

                case '{':
                    if (op != 0 && op != '-') {
                        syntaxError(chars, "Missing operand after operator");
                    }
                    if (lastItem == LAST1_RANGE) {
                        add_unchecked(lastChar, lastChar);
                        _appendToPat(patBuf, lastChar, false);
                    }
                    lastItem = LAST0_START;
                    if (buf == null) {
                        buf = new StringBuilder();
                    } else {
                        buf.setLength(0);
                    }
                    boolean ok = false;
                    while (!chars.atEnd()) {
                        c = chars.next(opts);
                        literal = chars.isEscapedMethod();
                        if (c == '}' && !literal) {
                            ok = true;
                            break;
                        }
                        appendCodePoint(buf, c);
                    }
                    if (!ok) {
                        syntaxError(chars, "Invalid multicharacter string");
                    }
                    String curString = buf.toString();
                    if (op == '-') {
                        int lastSingle = CharSequences.getSingleCodePoint(lastString == null  "" : lastString);
                        int curSingle = CharSequences.getSingleCodePoint(curString);
                        if (lastSingle != Integer.MAX_VALUE && curSingle != Integer.MAX_VALUE) {
                            add(lastSingle, curSingle);
                        } else {
                            if (strings == EMPTY_STRINGS) {
                                strings = new TreeSet<>();
                            }
                            try {
                                StringRange.expand(lastString, curString, true, strings);
                            } catch (Exception e) {
                                syntaxError(chars, e.getMessage());
                            }
                        }
                        lastString = null;
                        op = 0;
                    } else {
                        add(curString);
                        lastString = curString;
                    }
                    patBuf.append('{');
                    _appendToPat(patBuf, curString, false);
                    patBuf.append('}');
                    continue;

                case SymbolTable.SYMBOL_REF:
                    backup = chars.getPos(backup);
                    c = chars.next(opts);
                    literal = chars.isEscapedMethod();
                    boolean anchor = (c == ']' && !literal);
                    if (symbols == null && !anchor) {
                        c = SymbolTable.SYMBOL_REF;
                        chars.setPos(backup);
                        break;
                    }
                    if (anchor && op == 0) {
                        if (lastItem == LAST1_RANGE) {
                            add_unchecked(lastChar, lastChar);
                            _appendToPat(patBuf, lastChar, false);
                        }
                        add_unchecked(UnicodeMatcher.ETHER);
                        usePat = true;
                        patBuf.append(SymbolTable.SYMBOL_REF).append(']');
                        mode = MODE2_OUTBRACKET;
                        continue;
                    }
                    syntaxError(chars, "Unquoted '$'");
                    break;

                default:
                    break;

                } -->
            }
            match (lastItem) {
                case 0 =>
                    if (op == '-' && lastString.isSome()) {
                        syntaxError(chars, "Invalid range")
                    }
                    lastItem = LAST1_RANGE
                    lastChar = c
                    lastString = None
                case 1 => if (op == '-') {
                    if (lastString.isSome()) {
                        syntaxError(chars, "Invalid range")
                    }
                    if (lastChar >= c) {
                        syntaxError(chars, "Invalid range")
                    }
                    add_unchecked(lastChar, c)
                    _appendToPat(patBuf as T, lastChar, false)
                    patBuf.append(op)
                    _appendToPat(patBuf as T, c, false)
                    lastItem = LAST0_START
                    op = Char(0)
                } else {
                    add_unchecked(lastChar, lastChar)
                    _appendToPat(patBuf as T, lastChar, false)
                    lastChar = c
                }
                case 2 =>
                    if (Int32(UInt32(op)) != 0) {
                        syntaxError(chars, "Set expected after operator")
                    }
                    lastChar = c
                    lastItem = LAST1_RANGE
                case _ => ()
            }
        }
        if (mode != MODE2_OUTBRACKET) {
            syntaxError(chars, "Missing ']'")
        }
        chars.skipIgnored(opts)
        if ((options & CASE_MASK) != 0) {
            closeOver(options)
        }
        if (invert) {
            complement().removeAllStrings()
        }
        if (usePat) {
            append(rebuiltPat, patBuf.toString())
        } else {
            appendNewPattern(rebuiltPat, false, true)
        }
    }

    private static func syntaxError(chars: RuleCharacterIterator, msg: String): Unit {
        throw IllegalArgumentException("Error: " + (msg) + " at \"" + (Utility.escape(chars.toString())) + '\"'.toString())
    }

    public func addAllTo<T>(target: T): T {
        return addAllToStatic(this, target)
    }

    public func addAllTo(target: Array<String>): Array<String> {
        return addAllToStatic(this, target)
    }

    public static func toArray(set: UnicodeSet): Array<String> {
        return addAllToStatic(set,
    }

    public func add(source: Iterable<Object>): UnicodeSet {
        return addAll(source)
    }

    public func addAll(source: Iterable<Object>): UnicodeSet {
        checkFrozen()
        for (o in source) {
            add(toString(o))
        }
        return this
    }

    private func nextCapacity(minCapacity: Int32): Int32 {
        if (minCapacity < INITIAL_CAPACITY) {
            return minCapacity + INITIAL_CAPACITY
        } else if (minCapacity <= 2500) {
            return 5 * minCapacity
        } else {
            var newCapacity = 2 * minCapacity
            if (newCapacity > MAX_LENGTH) {
                newCapacity = MAX_LENGTH
            }
            return newCapacity
        }
    }

    private func ensureCapacity(newLen: Int32): Unit {
        var tempnewLen = newLen
        if (tempnewLen > MAX_LENGTH) {
            tempnewLen = MAX_LENGTH
        }
        if (tempnewLen <= Int32(list.size)) {
            return
        }
        let newCapacity = nextCapacity(tempnewLen)
        let temp = Array<Int32>(Int64(newCapacity)) { _ => 0 }
        arraycopy(list, 0, temp, 0, Int64(len))
        list = temp
    }

    private func ensureBufferCapacity(newLen: Int32): Unit {
        var tempnewLen = newLen
        if (tempnewLen > MAX_LENGTH) {
            tempnewLen = MAX_LENGTH
        }
        if (buffer.isSome() && tempnewLen <= Int32(buffer.size)) {
            return
        }
        let newCapacity = nextCapacity(tempnewLen)
        buffer = Array<Int32>(Int64(newCapacity)) { _ => 0 }
    }

    private func range(start: Int32, end: Int32): Array<Int32> {
        if (rangeList.isNone()) {
            rangeList = [start, end + 1, HIGH]
        } else {
            rangeList[0] = start
            rangeList[1] = end + 1
        }
        return rangeList
    }

    private func xor(other: Array<Int32>, otherLen: Int32, polarity: Int32): UnicodeSet {
        ensureBufferCapacity(len + otherLen)
        var i = 0
        var j = 0
        var k = 0
        var a = list[Int64(match (0) { case _ => i++; i - 1 })]
        var b: Int32 = 0
        if (polarity == 1 || polarity == 2) {
            b = LOW
            if (other[Int64(j)] == LOW) {
                j++
                b = other[Int64(j)]
            }
        } else {
            b = other[Int64(match (0) { case _ => j++; j - 1 })]
        }
        while (true) {
            if (a < b) {
                buffer[Int64(match (0) { case _ => k++; k - 1 })] = a
                a = list[Int64(match (0) { case _ => i++; i - 1 })]
            } else if (b < a) {
                buffer[Int64(match (0) { case _ => k++; k - 1 })] = b
                b = other[Int64(match (0) { case _ => j++; j - 1 })]
            } else if (a != HIGH) {
                a = list[Int64(match (0) { case _ => i++; i - 1 })]
                b = other[Int64(match (0) { case _ => j++; j - 1 })]
            } else {
                buffer[Int64(match (0) { case _ => k++; k - 1 })] = HIGH
                len = k
                break
            }
        }
        let temp = list
        list = buffer
        buffer = temp
        pat = None
        return this
    }

    private func add(other: Array<Int32>, otherLen: Int32, polarity: Int32): UnicodeSet {
        var temppolarity = polarity
        ensureBufferCapacity(len + otherLen)
        var i = 0
        var j = 0
        var k = 0
        var a = list[Int64(match (0) { case _ => i++; i - 1 })]
        var b = other[Int64(match (0) { case _ => j++; j - 1 })]
    private func retain(other: Array<Int32>, otherLen: Int32, polarity: Int32): UnicodeSet {
        var temppolarity = polarity
        ensureBufferCapacity(len + otherLen)
        var i = 0
        var j = 0
        var k = 0
        var a = list[Int64(match (0) { case _ => i++; i - 1 })]
        var b = other[Int64(match (0) { case _ => j++; j - 1 })]
    private static func max(a: Int32, b: Int32): Int32 {
        return if (a > b) { a } else { b }
    }

    static let NO_VERSION = VersionInfo.getInstance(0, 0, 0, 0)

    private func applyFilter(filter: UnicodeSet_Filter, inclusions: UnicodeSet): Unit {
        clear()
        var startHasProperty = -1
        let limitRange = inclusions.getRangeCount()
        var j = 0
        while (j < limitRange) {
            let start = inclusions.getRangeStart(j)
            let end = inclusions.getRangeEnd(j)
            var ch = start
            while (ch <= end) {
                if (filter.contains(ch)) {
                    if (startHasProperty < 0) {
                        startHasProperty = ch
                    }
                } else if (startHasProperty >= 0) {
                    add_unchecked(startHasProperty, ch - 1)
                    startHasProperty = -1
                }
                ch++
            }
            j++
        }
        if (startHasProperty >= 0) {
            add_unchecked(startHasProperty, 1114111)
        }
    }

    private static func mungeCharName(source: String): String {
        var tempsource = source
        tempsource = PatternProps.trimWhiteSpace(tempsource)
        var buf: StringBuilder
        var i = 0
        while (i < Int32(tempsource.size)) {
            var ch = Char(tempsource[Int64(i)])
            if (PatternProps.isWhiteSpace(Int32(UInt32(ch)))) {
                if (buf.isNone()) {
                    buf = StringBuilder().append(tempsource, 0, i)
                } else if (buf.get(Int64(Int32(buf.size) - 1)) == ' ') {
                    continue
                }
                ch = ' '
            }
            if (buf.isSome()) {
                buf.append(ch)
            }
            i++
        }
        return if (buf.isNone()) { tempsource } else { buf.toString() }
    }

    public func applyIntPropertyValue(property: Int32, value: Int32): UnicodeSet {
        if (property == UProperty.GENERAL_CATEGORY_MASK) {
            let inclusions = CharacterPropertiesImpl.getInclusionsForProperty(property)
            applyFilter(UnicodeSet_GeneralCategoryMaskFilter(value), inclusions)
        } else if (property == UProperty.SCRIPT_EXTENSIONS) {
            let inclusions = CharacterPropertiesImpl.getInclusionsForProperty(property)
            applyFilter(UnicodeSet_ScriptExtensionsFilter(value), inclusions)
        } else if (property == UProperty.IDENTIFIER_TYPE) {
            let inclusions = CharacterPropertiesImpl.getInclusionsForProperty(property)
            applyFilter(UnicodeSet_IdentifierTypeFilter(value), inclusions)
        } else if (0 <= property && property < UProperty.BINARY_LIMIT) {
            if (value == 0 || value == 1) {
                set(CharacterProperties.getBinaryPropertySet(property))
                if (value == 0) {
                    complement().removeAllStrings()
                }
            } else {
                clear()
            }
        } else if (UProperty.INT_START <= property && property < UProperty.INT_LIMIT) {
            let inclusions = CharacterPropertiesImpl.getInclusionsForProperty(property)
            applyFilter(UnicodeSet_IntPropertyFilter(property, value), inclusions)
        } else {
            throw IllegalArgumentException("unsupported property " + property.toString())
        }
        return this
    }

    public func applyPropertyAlias(propertyAlias: String, valueAlias: String): UnicodeSet {
        return applyPropertyAlias(propertyAlias, valueAlias, None)
    }

    public func applyPropertyAlias(propertyAlias: String, valueAlias: String, symbols: SymbolTable): UnicodeSet {
        checkFrozen()
        var p: Int32 = 0
        var v: Int32 = 0
        var invert = false
        if (symbols.isSome() && (checkOptionalIs<UnicodeSet_XSymbolTable, SymbolTable>(symbols)) && symbols.applyPropertyAlias(propertyAlias, valueAlias, this)) {
            return this
        }
        if (XSYMBOL_TABLE.isSome()) {
            if (XSYMBOL_TABLE.applyPropertyAlias(propertyAlias, valueAlias, this)) {
                return this
            }
        }
        if (Int32(valueAlias.size) > 0) {
            p = UCharacter.getPropertyEnum(propertyAlias)
            if (p == UProperty.GENERAL_CATEGORY) {
                p = UProperty.GENERAL_CATEGORY_MASK
            }
            if ((p >= UProperty.BINARY_START && p < UProperty.BINARY_LIMIT) || (p >= UProperty.INT_START && p < UProperty.INT_LIMIT) || (p >= UProperty.MASK_START && p < UProperty.MASK_LIMIT)) {
                try {
                    v = UCharacter.getPropertyValueEnum(p, valueAlias)
                } catch (e: IllegalArgumentException) {
                    if (p == UProperty.CANONICAL_COMBINING_CLASS || p == UProperty.LEAD_CANONICAL_COMBINING_CLASS || p == UProperty.TRAIL_CANONICAL_COMBINING_CLASS) {
                        v = parse<Int32>(PatternProps.trimWhiteSpace(valueAlias))
                        if (v < 0 || v > 255) {
                            throw e
                        }
                    } else {
                        throw e
                    }
                }
            } else {
                match (p) {
                    case 12288 =>
                        let value = parse<Float64>(PatternProps.trimWhiteSpace(valueAlias))
                        applyFilter(UnicodeSet_NumericValueFilter(value), CharacterPropertiesImpl.getInclusionsForProperty(p))
                        return this
                    case 16389 =>
                        let buf = mungeCharName(valueAlias)
                        let ch = UCharacter.getCharFromExtendedName(buf)
                        if (ch == -1) {
                            throw IllegalArgumentException("Invalid character name")
                        }
                        clear()
                        add_unchecked(ch)
                        return this
                    case 16395 => throw IllegalArgumentException("Unicode_1_Name (na1) not supported")
                    case 16384 =>
                        let version = VersionInfo.getInstance(mungeCharName(valueAlias))
                        applyFilter(UnicodeSet_VersionFilter(version), CharacterPropertiesImpl.getInclusionsForProperty(p))
                        return this
                    case 28672 => v = UCharacter.getPropertyValueEnum(UProperty.SCRIPT, valueAlias)
                    case 28673 => v = UCharacter.getPropertyValueEnum(p, valueAlias)
                    case _ => throw IllegalArgumentException("Unsupported property")
                }
            }
        } else {
            let pnames = UPropertyAliases.INSTANCE
            p = UProperty.GENERAL_CATEGORY_MASK
            v = pnames.getPropertyValueEnum(p, propertyAlias)
            if (v == UProperty.UNDEFINED) {
                p = UProperty.SCRIPT
                v = pnames.getPropertyValueEnum(p, propertyAlias)
                if (v == UProperty.UNDEFINED) {
                    p = pnames.getPropertyEnum(propertyAlias)
                    if (p == UProperty.UNDEFINED) {
                        p = -1
                    }
                    if (p >= UProperty.BINARY_START && p < UProperty.BINARY_LIMIT) {
                        v = 1
                    } else if (p == -1) {
                        if (0 == UPropertyAliases.compare(ANY_ID, propertyAlias)) {
                            set(MIN_VALUE, MAX_VALUE)
                            return this
                        } else if (0 == UPropertyAliases.compare(ASCII_ID, propertyAlias)) {
                            set(0, 127)
                            return this
                        } else if (0 == UPropertyAliases.compare(ASSIGNED, propertyAlias)) {
                            p = UProperty.GENERAL_CATEGORY_MASK
                            v = (shl(1, Int32(UCharacter.UNASSIGNED)))
                            invert = true
                        } else {
                            throw IllegalArgumentException("Invalid property alias: " + (propertyAlias) + "=" + (valueAlias))
                        }
                    } else {
                        throw IllegalArgumentException("Missing property value")
                    }
                }
            }
        }
        applyIntPropertyValue(p, v)
        if (invert) {
            complement().removeAllStrings()
        }
        return this
    }

    private static func resemblesPropertyPattern(pattern: String, pos: Int32): Bool {
        if ((pos + 5) > Int32(pattern.size)) {
            return false
        }
        return pattern.regionMatches(pos, "[:", 0, 2) || pattern.regionMatches(true, pos, "\\p", 0, 2) || pattern.regionMatches(pos, "\\N", 0, 2)
    }

    private static func resemblesPropertyPattern(chars: RuleCharacterIterator, iterOpts: Int32): Bool {
        var tempiterOpts = iterOpts
        var result = false
        tempiterOpts &= 
        let pos = chars.getPos(None)
        let c = chars.next(tempiterOpts)
        if (c == Int32(UInt32('[')) || c == Int32(UInt32('\'))) {
            let d = chars.next(tempiterOpts & )
            result = if (c == Int32(UInt32('['))) { (d == Int32(UInt32(':'))) } else { (d == Int32(UInt32('N')) || d == Int32(UInt32('p')) || d == Int32(UInt32('P'))) }
        }
        chars.setPos(pos)
        return result
    }

    private func applyPropertyPattern(pattern: String, ppos: ParsePosition, symbols: SymbolTable): UnicodeSet {
        var pos = ppos.getIndex()
        if ((pos + 5) > Int32(pattern.size)) {
            return None
        }
        var posix = false
        var isName = false
        var invert = false
        if (pattern.regionMatches(pos, "[:", 0, 2)) {
            posix = true
            pos = PatternProps.skipWhiteSpace(pattern, (pos + 2))
            if (pos < Int32(pattern.size) && Char(pattern[Int64(pos)]) == '^') {
                pos++
                invert = true
            }
        } else if (pattern.regionMatches(true, pos, "\\p", 0, 2) || pattern.regionMatches(pos, "\\N", 0, 2)) {
            let c = Char(pattern[Int64(pos + 1)])
            invert = (c == 'P')
            isName = (c == 'N')
            pos = PatternProps.skipWhiteSpace(pattern, (pos + 2))
            if (pos == Int32(pattern.size) || Char(pattern[Int64(match (0) { case _ => pos++; pos - 1 })]) != '{') {
                return None
            }
        } else {
            return None
        }
        let close = indexOfWrap(pattern.indexOf(if (posix) { ":]" } else { "}" }, Int64(pos)))
        if (close < 0) {
            return None
        }
        let equals = indexOfWrap(pattern.indexOf(UInt8(UInt32('=')), Int64(pos)))
        var propName: String
        var valueName: String
        if (equals >= 0 && equals < close && !isName) {
            propName = pattern[Int64(pos)..Int64(equals)]
            valueName = pattern[Int64(equals + 1)..Int64(close)]
        } else {
            propName = pattern[Int64(pos)..Int64(close)]
            valueName = ""
            if (isName) {
                valueName = propName
                propName = "na"
            }
        }
        applyPropertyAlias(propName, valueName, symbols)
        if (invert) {
            complement().removeAllStrings()
        }
        ppos.setIndex(close + (if (posix) { 2 } else { 1 }))
        return this
    }

    private func applyPropertyPattern(chars: RuleCharacterIterator, rebuiltPat: Appendable, symbols: SymbolTable): Unit {
        let patStr = chars.getCurrentBuffer()
        let start = chars.getCurrentBufferPos()
        let pos = ParsePosition(start)
        applyPropertyPattern(patStr, pos, symbols)
        let length = pos.getIndex() - start
        if (length == 0) {
            syntaxError(chars, "Invalid property pattern")
        }
        chars.jumpahead(length)
        append(rebuiltPat, patStr[Int64(start)..Int64(pos.getIndex())])
    }

    public static let IGNORE_SPACE = 1

    
    public static let CASE = 2

    public static let CASE_INSENSITIVE = 2

    public static let ADD_CASE_MAPPINGS = 4

    public static let SIMPLE_CASE_INSENSITIVE = 6

    private static let CASE_MASK = CASE_INSENSITIVE | ADD_CASE_MAPPINGS

    private static func addCaseMapping(set: UnicodeSet, result: Int32, full: StringBuilder): Unit {
        if (result >= 0) {
            if (result > UCaseProps.MAX_STRING_LENGTH) {
                set.add(result)
            } else {
                set.add(full.toString())
                full.setLength(0)
            }
        }
    }

    public func maybeOnlyCaseSensitive(src: UnicodeSet): UnicodeSet {
        if (src.size() < 30) {
            return src
        }
        let sensitive = CharacterProperties.getBinaryPropertySet(UProperty.CASE_SENSITIVE)
        if (src.hasStrings() || src.getRangeCount() > sensitive.getRangeCount()) {
            return sensitive.cloneAsThawed().retainAll(src)
        } else {
            return src.clone().retainAll(sensitive)
        }
    }

    private static func scfString(s: String, scf: StringBuilder): Bool {
        let length = s.size
        var i = 0
        while (i < length) {
            var c = Character.codePointAt(s, i)
            var scfChar = UCharacter.foldCase(c, UCharacter.FOLD_CASE_DEFAULT)
            if (scfChar != c) {
                scf.setLength(0)
                scf.append(s, 0, i)
                while (true) {
                    scf.appendCodePoint(scfChar)
                    i += Character.charCount(c)
                    if (i == length) {
                        return true
                    }
                    c = Character.codePointAt(s, i)
                    scfChar = UCharacter.foldCase(c, UCharacter.FOLD_CASE_DEFAULT)
                }
            }
            i += Character.charCount(c)
        }
        return false
    }

    public func closeOver(attribute: Int32): UnicodeSet {
        checkFrozen()
        match (attribute & CASE_MASK) {
            case 0 => ()
            case 2 => closeOverCaseInsensitive(false)
            case 4 => closeOverAddCaseMappings()
            case 6 => closeOverCaseInsensitive(true)
            case _ => ()
        }
        return this
    }

    private func closeOverCaseInsensitive(simple: Bool): Unit {
        let csp = UCaseProps.INSTANCE
        let foldSet = UnicodeSet(this)
        if (!simple && foldSet.hasStrings()) {
            foldSet.strings.clear()
        }
        let codePoints = maybeOnlyCaseSensitive(this)
        let n = codePoints.getRangeCount()
        var i = 0
        while (i < n) {
            let start = codePoints.getRangeStart(i)
            let end = codePoints.getRangeEnd(i)
            if (simple) {
                } while (false)
            } else {
                } while (false)
            }
            i++
        }
        if (hasStrings()) {
            let sb: StringBuilder = if (simple) { StringBuilder() } else { None }
            for (s in strings) {
                if (simple) {
                    if (scfString(s, sb)) {
                        foldSet.remove(s).add(sb.asString())
                    }
                } else {
                    let str = UCharacter.foldCase(s, 0)
                    if (!csp.addStringCaseClosure(str, foldSet)) {
                        foldSet.add(str)
                    }
                }
            }
        }
        set(foldSet)
    }

    private func closeOverAddCaseMappings(): Unit {
        let csp = UCaseProps.INSTANCE
        let foldSet = UnicodeSet(this)
        let codePoints = maybeOnlyCaseSensitive(this)
        let n = codePoints.getRangeCount()
        var result: Int32 = 0
        let full = StringBuilder()
        var i = 0
        while (i < n) {
            let start = codePoints.getRangeStart(i)
            let end = codePoints.getRangeEnd(i)
            var cp = start
            while (cp <= end) {
                result = csp.toFullLower(cp, None, full as Appendable, UCaseProps.LOC_ROOT)
                addCaseMapping(foldSet, result, full)
                result = csp.toFullTitle(cp, None, full as Appendable, UCaseProps.LOC_ROOT)
                addCaseMapping(foldSet, result, full)
                result = csp.toFullUpper(cp, None, full as Appendable, UCaseProps.LOC_ROOT)
                addCaseMapping(foldSet, result, full)
                result = csp.toFullFolding(cp, full as Appendable, 0)
                addCaseMapping(foldSet, result, full)
                cp++
            }
            i++
        }
        if (hasStrings()) {
            let root = ULocale.ROOT
            let bi = BreakIterator.getWordInstance(root)
            for (str in strings) {
                foldSet.add(UCharacter.toLowerCase(root, str))
                foldSet.add(UCharacter.toTitleCase(root, str, bi))
                foldSet.add(UCharacter.toUpperCase(root, str))
                foldSet.add(UCharacter.foldCase(str, 0))
            }
        }
        set(foldSet)
    }

    public override func isFrozen(): Bool {
        return (bmpSet.isSome() || stringSpan.isSome())
    }

    public override func freeze(): UnicodeSet {
        if (!isFrozen()) {
            compact()
            if (hasStrings()) {
                stringSpan = UnicodeSetStringSpan(this, // Мapping is present but failed: ArrayList<String>(strings), UnicodeSetStringSpan.ALL)
            }
            if (stringSpan.isNone() || !stringSpan.needsStringSpanUTF16()) {
                bmpSet = BMPSet(list, len)
            }
        }
        return this
    }

    public func span(s: String, spanCondition: UnicodeSet_SpanCondition): Int32 {
        return span(s, 0, spanCondition)
    }

    public func span(s: String, start: Int32, spanCondition: UnicodeSet_SpanCondition): Int32 {
        var tempstart = start
        let end = s.size
        if (tempstart < 0) {
            tempstart = 0
        } else if (tempstart >= end) {
            return end
        }
        if (bmpSet.isSome()) {
            return bmpSet.span(s, tempstart, spanCondition, None)
        }
        if (stringSpan.isSome()) {
            return stringSpan.span(s, tempstart, spanCondition)
        } else if (hasStrings()) {
            let which = if (refEq(spanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED)) { UnicodeSetStringSpan.FWD_UTF16_NOT_CONTAINED } else { UnicodeSetStringSpan.FWD_UTF16_CONTAINED }
            let strSpan = UnicodeSetStringSpan(this, // Мapping is present but failed: ArrayList<String>(strings), which)
            if (strSpan.needsStringSpanUTF16()) {
                return strSpan.span(s, tempstart, spanCondition)
            }
        }
        return spanCodePointsAndCount(s, tempstart, spanCondition, None)
    }

    
    public func spanAndCount(s: String, start: Int32, spanCondition: UnicodeSet_SpanCondition, outCount: OutputInt): Int32 {
        var tempstart = start
        if (outCount.isNone()) {
            throw IllegalArgumentException("outCount must not be null")
        }
        let end = s.size
        if (tempstart < 0) {
            tempstart = 0
        } else if (tempstart >= end) {
            return end
        }
        if (stringSpan.isSome()) {
            return stringSpan.spanAndCount(s, tempstart, spanCondition, outCount)
        } else if (bmpSet.isSome()) {
            return bmpSet.span(s, tempstart, spanCondition, outCount)
        } else if (hasStrings()) {
            var which = if (refEq(spanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED)) { UnicodeSetStringSpan.FWD_UTF16_NOT_CONTAINED } else { UnicodeSetStringSpan.FWD_UTF16_CONTAINED }
            which |= UnicodeSetStringSpan.WITH_COUNT
            let strSpan = UnicodeSetStringSpan(this, // Мapping is present but failed: ArrayList<String>(strings), which)
            return strSpan.spanAndCount(s, tempstart, spanCondition, outCount)
        }
        return spanCodePointsAndCount(s, tempstart, spanCondition, outCount)
    }

    private func spanCodePointsAndCount(s: String, start: Int32, spanCondition: UnicodeSet_SpanCondition, outCount: OutputInt): Int32 {
        let spanContained = (!refEq(spanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED))
        var c: Int32 = 0
        var next = start
        let length = s.size
        var count = 0
            count++
            next += Character.charCount(c)
        } while (next < length)
        if (outCount.isSome()) {
            outCount.value = count
        }
        return next
    }

    public func spanBack(s: String, spanCondition: UnicodeSet_SpanCondition): Int32 {
        return spanBack(s, s.size, spanCondition)
    }

    public func spanBack(s: String, fromIndex: Int32, spanCondition: UnicodeSet_SpanCondition): Int32 {
        var tempfromIndex = fromIndex
        if (tempfromIndex <= 0) {
            return 0
        }
        if (tempfromIndex > s.size) {
            tempfromIndex = s.size
        }
        if (bmpSet.isSome()) {
            return bmpSet.spanBack(s, tempfromIndex, spanCondition)
        }
        if (stringSpan.isSome()) {
            return stringSpan.spanBack(s, tempfromIndex, spanCondition)
        } else if (hasStrings()) {
            let which = if (refEq(spanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED)) { UnicodeSetStringSpan.BACK_UTF16_NOT_CONTAINED } else { UnicodeSetStringSpan.BACK_UTF16_CONTAINED }
            let strSpan = UnicodeSetStringSpan(this, // Мapping is present but failed: ArrayList<String>(strings), which)
            if (strSpan.needsStringSpanUTF16()) {
                return strSpan.spanBack(s, tempfromIndex, spanCondition)
            }
        }
        let spanContained = (!refEq(spanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED))
        var c: Int32 = 0
        var prev = tempfromIndex
            prev -= Character.charCount(c)
        } while (prev > 0)
        return prev
    }

    public override func cloneAsThawed(): UnicodeSet {
        let result = UnicodeSet(this)
        if (!(!result.isFrozen())) {
            throw AssertionError()
        }
        return result
    }

    private func checkFrozen(): Unit {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify frozen object")
        }
    }

    public func ranges(): Iterable<UnicodeSet_EntryRange> {
        return UnicodeSet_EntryRangeIterable(this) as Iterable<UnicodeSet_EntryRange>
    }

    public override func iterator(): Iterator<String> {
        return UnicodeSet_UnicodeSetIterator2(this) as Iterator<String>
    }

    public func containsAll<T>(collection: Iterable<T>): Bool {
        for (o in collection) {
            if (!contains(o)) {
                return false
            }
        }
        return true
    }

    public func containsNone<T>(collection: Iterable<T>): Bool {
        for (o in collection) {
            if (contains(o)) {
                return false
            }
        }
        return true
    }

    public func containsSome<T>(collection: Iterable<T>): Bool {
        return !containsNone(collection)
    }

    public func addAll<T>(collection: Array<T>): UnicodeSet {
        checkFrozen()
        for (str in collection) {
            add(str)
        }
        return this
    }

    public func removeAll<T>(collection: Iterable<T>): UnicodeSet {
        checkFrozen()
        for (o in collection) {
            remove(o)
        }
        return this
    }

    public func retainAll<T>(collection: Iterable<T>): UnicodeSet {
        checkFrozen()
        let toRetain = UnicodeSet()
        toRetain.addAll(collection)
        retainAll(toRetain)
        return this
    }

    public override func compareTo(o: UnicodeSet): Int32 {
        return compareTo(o, UnicodeSet_ComparisonStyle.SHORTER_FIRST)
    }

    public func compareTo(o: UnicodeSet, style: UnicodeSet_ComparisonStyle): Int32 {
        if (!refEq(style, UnicodeSet_ComparisonStyle.LEXICOGRAPHIC)) {
            let diff = size() - o.size()
            if (diff != 0) {
                return if ((diff < 0) == (refEq(style, UnicodeSet_ComparisonStyle.SHORTER_FIRST))) { -1 } else { 1 }
            }
        }
        var result: Int32 = 0
        var i = 0
        while (true) {
            if (0 != (match (0) { case _ => result = list[Int64(i)] - o.list[Int64(i)]; result })) {
                if (list[Int64(i)] == HIGH) {
                    if (!hasStrings()) {
                        return 1
                    }
                    let item = strings.first()
                    return compare(item, o.list[Int64(i)])
                }
                if (o.list[Int64(i)] == HIGH) {
                    if (!o.hasStrings()) {
                        return -1
                    }
                    let item = o.strings.first()
                    let compareResult = compare(item, list[Int64(i)])
                    return if (compareResult > 0) { -1 } else { if (compareResult < 0) { 1 } else { 0 } }
                }
                return if ((i & 1) == 0) { result } else { -result }
            }
            if (list[Int64(i)] == HIGH) {
                break
            }
            i++
        }
        return compare(strings, o.strings)
    }

    public func compareTo(other: Iterable<String>): Int32 {
        return compare(this, other)
    }

    public static func compare(string: String, codePoint: Int32): Int32 {
        return CharSequences.compare(string, codePoint)
    }

    public static func compare(codePoint: Int32, string: String): Int32 {
        return -CharSequences.compare(string, codePoint)
    }

    public static func compare<T>(collection1: Iterable<T>, collection2: Iterable<T>): Int32 {
        return compare(collection1.iterator(), collection2.iterator())
    }

    
    public static func compare<T>(first: Iterator<T>, other: Iterator<T>): Int32 {
        while (true) {
            if (!first.hasNext()) {
                return if (other.hasNext()) { -1 } else { 0 }
            } else if (!other.hasNext()) {
                return 1
            }
            let item1: T = first.next()
            let item2: T = other.next()
            let result = item1.compareTo(item2)
            if (result != 0) {
                return result
            }
        }
        throw Exception()
    }

    public static func compare<T>(collection1: Collection<T>, collection2: Collection<T>, style: UnicodeSet_ComparisonStyle): Int32 {
        if (!refEq(style, UnicodeSet_ComparisonStyle.LEXICOGRAPHIC)) {
            let diff = Int32(collection1.size) - Int32(collection2.size)
            if (diff != 0) {
                return if ((diff < 0) == (refEq(style, UnicodeSet_ComparisonStyle.SHORTER_FIRST))) { -1 } else { 1 }
            }
        }
        return compare(collection1, collection2)
    }

    public static func addAllToStatic<T, U>(source: Iterable<T>, target: U): U {
        for (item in source) {
            target.add(item)
        }
        return target
    }

    public static func addAllToStatic<T>(source: Iterable<T>, target: Array<T>): Array<T> {
        var i = 0
        for (item in source) {
            target[Int64(match (0) { case _ => i++; i - 1 })] = item
        }
        return target
    }

    public func stringsMethod(): Collection<String> {
        if (hasStrings()) {
            return Collections.unmodifiableSortedSet(strings)
        } else {
            return EMPTY_STRINGS
        }
    }

    
    public static func getSingleCodePoint(s: String): Int32 {
        return CharSequences.getSingleCodePoint(s)
    }

    
    public func addBridges(dontCare: UnicodeSet): UnicodeSet {
        let notInInput = UnicodeSet(this).complement().removeAllStrings()
        let it = UnicodeSetIterator(notInInput)
        while (it.nextRange()) {
            if (it.codepoint != 0 && it.codepointEnd != 1114111 && dontCare.contains(it.codepoint, it.codepointEnd)) {
                add(it.codepoint, it.codepointEnd)
            }
        }
        return this
    }

    
    public func findIn(value: String, fromIndex: Int32, findNot: Bool): Int32 {
        var tempfromIndex = fromIndex
        var cp: Int32 = 0
        while (tempfromIndex < value.size) {
            cp = UTF16.toRuneArray()[value, tempfromIndex]
            if (contains(cp) != findNot) {
                break
            }
            tempfromIndex += UTF16.getCharCount(cp)
        }
        return tempfromIndex
    }

    
    public func findLastIn(value: String, fromIndex: Int32, findNot: Bool): Int32 {
        var tempfromIndex = fromIndex
        var cp: Int32 = 0
        tempfromIndex -= 1
        while (tempfromIndex >= 0) {
            cp = UTF16.toRuneArray()[value, tempfromIndex]
            if (contains(cp) != findNot) {
                break
            }
            tempfromIndex -= UTF16.getCharCount(cp)
        }
        return if (tempfromIndex < 0) { -1 } else { tempfromIndex }
    }

    
    public func stripFrom(source: String, matches: Bool): String {
        let result = StringBuilder()
        var pos = 0
        while (pos < source.size) {
            let inside = findIn(source, pos, !matches)
            result.append(source.subSequence(pos, inside))
            pos = findIn(source, inside, matches)
        }
        return result.toString()
    }

    
    public static func getDefaultXSymbolTable(): UnicodeSet_XSymbolTable {
        return XSYMBOL_TABLE
    }

    
    public static func setDefaultXSymbolTable(xSymbolTable: UnicodeSet_XSymbolTable): Unit {
        CharacterPropertiesImpl.clear()
        XSYMBOL_TABLE = xSymbolTable
    }
}


interface UnicodeSet_Filter {
    func contains(codePoint: Int32): Bool
}

class UnicodeSet_NumericValueFilter <: UnicodeSet_Filter {
    var value: Float64 = 0.0

    init(value: Float64) {
        this.value = value
    }

    public override func contains(ch: Int32): Bool {
        return UCharacter.getUnicodeNumericValue(ch) == value
    }
}


class UnicodeSet_GeneralCategoryMaskFilter <: UnicodeSet_Filter {
    var mask: Int32 = 0

    init(mask: Int32) {
        this.mask = mask
    }

    public override func contains(ch: Int32): Bool {
        return ((shl(1, UCharacter.getType(ch))) & mask) != 0
    }
}


class UnicodeSet_IntPropertyFilter <: UnicodeSet_Filter {
    var property: Int32 = 0

    var value: Int32 = 0

    init(property: Int32, value: Int32) {
        this.property = property
        this.value = value
    }

    public override func contains(ch: Int32): Bool {
        return UCharacter.getIntPropertyValue(ch, property) == value
    }
}


class UnicodeSet_ScriptExtensionsFilter <: UnicodeSet_Filter {
    var script: Int32 = 0

    init(script: Int32) {
        this.script = script
    }

    public override func contains(c: Int32): Bool {
        return UScript.hasScript(c, script)
    }
}


class UnicodeSet_IdentifierTypeFilter <: UnicodeSet_Filter {
    var idType: Int32 = 0

    init(idType: Int32) {
        this.idType = idType
    }

    public override func contains(c: Int32): Bool {
        return UCharacterProperty.INSTANCE.hasIDType(c, idType)
    }
}


class UnicodeSet_VersionFilter <: UnicodeSet_Filter {
    var version: VersionInfo

    init(version: VersionInfo) {
        this.version = version
    }

    public override func contains(ch: Int32): Bool {
        let v = UCharacter.getAge(ch)
        return !Utility.sameObjects(v, UnicodeSet.NO_VERSION) && v.compareTo(version) <= 0
    }
}


public abstract class UnicodeSet_XSymbolTable <: SymbolTable {

    public override func lookupMatcher(i: Int32): UnicodeMatcher {
        return None
    }

    public func applyPropertyAlias(propertyName: String, propertyValue: String, result: UnicodeSet): Bool {
        return false
    }

    public override func lookup(s: String): Array<Char> {
        return None
    }

    public override func parseReference(text: String, pos: ParsePosition, limit: Int32): String {
        return None
    }
}


public class UnicodeSet_EntryRange {
    public var codepoint: Int32 = 0

    public var codepointEnd: Int32 = 0


    public override func toString(): String {
        let b = StringBuilder()
        return (if (codepoint == codepointEnd) { UnicodeSet._appendToPat(b as T, codepoint, false) } else { UnicodeSet._appendToPat(UnicodeSet._appendToPat(b as T, codepoint, false).append('-') as T, codepointEnd, false) }).toString()
    }
}


class UnicodeSet_EntryRangeIterable <: Iterable<UnicodeSet_EntryRange> {
    let this_0: UnicodeSet

    init(this_0: UnicodeSet) {
        this.this_0 = this_0
    }

    public override func iterator(): Iterator<UnicodeSet_EntryRange> {
        return UnicodeSet_EntryRangeIterator(this_0) as Iterator<UnicodeSet_EntryRange>
    }
}


class UnicodeSet_EntryRangeIterator <: Iterator<UnicodeSet_EntryRange> {
    let this_0: UnicodeSet

    init(this_0: UnicodeSet) {
        this.this_0 = this_0
    }

    var pos: Int32 = 0

    var result: UnicodeSet_EntryRange = UnicodeSet_EntryRange()

    public override func hasNext(): Bool {
        return pos < this_0.len - 1
    }

    public override func next(): UnicodeSet_EntryRange {
        if (pos < this_0.len - 1) {
            result.codepoint = this_0.list[Int64(match (0) { case _ => pos++; pos - 1 })]
            result.codepointEnd = this_0.list[Int64(match (0) { case _ => pos++; pos - 1 })] - 1
        } else {
            throw NoSuchElementException()
        }
        return result
    }

    public override func remove(): Unit {
        throw UnsupportedOperationException()
    }
}


class UnicodeSet_UnicodeSetIterator2 <: Iterator<String> {
    private var sourceList: Array<Int32>

    private var len: Int32 = 0

    private var item: Int32 = 0

    private var current: Int32 = 0

    private var limit: Int32 = 0

    private var sourceStrings: SortedSet = None

    private var stringIterator: Iterator<String>

    private var buffer: Array<Char>

    init(source: UnicodeSet) {
        len = source.len - 1
        if (len > 0) {
            sourceStrings = source.strings
            sourceList = source.list
            current = sourceList[Int64(match (0) { case _ => item++; item - 1 })]
            limit = sourceList[Int64(match (0) { case _ => item++; item - 1 })]
        } else {
            stringIterator = source.strings.iterator()
            sourceList = None
        }
    }

    public override func hasNext(): Bool {
        return sourceList.isSome() || stringIterator.hasNext()
    }

    public override func next(): String {
        if (sourceList.isNone()) {
            return stringIterator.next()
        }
        let codepoint = match (0) { case _ => current++; current - 1 }
        if (current >= limit) {
            if (item >= len) {
                stringIterator = sourceStrings.iterator()
                sourceList = None
            } else {
                current = sourceList[Int64(match (0) { case _ => item++; item - 1 })]
                limit = sourceList[Int64(match (0) { case _ => item++; item - 1 })]
            }
        }
        if (codepoint <= 65535) {
            return Char(codepoint).toString()
        }
        if (buffer.isNone()) {
            buffer = Array<Char>(2) { _ => '\u{0000}' }
        }
        let offset = codepoint - Character.MIN_SUPPLEMENTARY_CODE_POINT
        buffer[0] = Char((ushr(offset, 10)) + Int32(UInt32(Character.MIN_HIGH_SURROGATE)))
        buffer[1] = Char((offset & 1023) + Int32(UInt32(Character.MIN_LOW_SURROGATE)))
        return String.valueOf(buffer)
    }

    public override func remove(): Unit {
        throw UnsupportedOperationException()
    }
}


public class UnicodeSet_ComparisonStyle <: Enum<UnicodeSet_ComparisonStyle> {
    public static let SHORTER_FIRST = UnicodeSet_ComparisonStyle("SHORTER_FIRST", 0)

    public static let LEXICOGRAPHIC = UnicodeSet_ComparisonStyle("LEXICOGRAPHIC", 1)

    public static let LONGER_FIRST = UnicodeSet_ComparisonStyle("LONGER_FIRST", 2)

    private static func _values(): Array<UnicodeSet_ComparisonStyle> {
        return [UnicodeSet_ComparisonStyle.SHORTER_FIRST, UnicodeSet_ComparisonStyle.LEXICOGRAPHIC, UnicodeSet_ComparisonStyle.LONGER_FIRST]
    }

    private static let _VALUES = UnicodeSet_ComparisonStyle._values()

    public static func values(): Array<UnicodeSet_ComparisonStyle> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): UnicodeSet_ComparisonStyle {
        return (TypeInfo.of<UnicodeSet_ComparisonStyle>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as UnicodeSet_ComparisonStyle
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class UnicodeSet_SpanCondition <: Enum<UnicodeSet_SpanCondition> {
    public static let NOT_CONTAINED = UnicodeSet_SpanCondition("NOT_CONTAINED", 0)

    public static let CONTAINED = UnicodeSet_SpanCondition("CONTAINED", 1)

    public static let SIMPLE = UnicodeSet_SpanCondition("SIMPLE", 2)

    public static let CONDITION_COUNT = UnicodeSet_SpanCondition("CONDITION_COUNT", 3)

    private static func _values(): Array<UnicodeSet_SpanCondition> {
        return [UnicodeSet_SpanCondition.NOT_CONTAINED, UnicodeSet_SpanCondition.CONTAINED, UnicodeSet_SpanCondition.SIMPLE, UnicodeSet_SpanCondition.CONDITION_COUNT]
    }

    private static let _VALUES = UnicodeSet_SpanCondition._values()

    public static func values(): Array<UnicodeSet_SpanCondition> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): UnicodeSet_SpanCondition {
        return (TypeInfo.of<UnicodeSet_SpanCondition>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as UnicodeSet_SpanCondition
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
