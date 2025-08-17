package icu4cj.text


class TransliteratorIDParser {
    init() { }

    private static let ID_DELIM = ';'

    private static let TARGET_SEP = '-'

    private static let VARIANT_SEP = '/'

    private static let OPEN_REV = '('

    private static let CLOSE_REV = ')'

    private static let ANY = "Any"

    private static let FORWARD = Transliterator.FORWARD

    private static let REVERSE = Transliterator.REVERSE

    private static let SPECIAL_INVERSES = Collections.synchronizedMap(HashMap<CaseInsensitiveString, String>() as Map<K, V>)

    public static func parseFilterID(id: String, pos: Array<Int32>): TransliteratorIDParser_SingleID {
        let start = pos[0]
        let specs = parseFilterID(id, pos, true)
        if (specs.isNone()) {
            pos[0] = start
            return None
        }
        let single = specsToID(specs, FORWARD)
        single.filter = specs.filter
        return single
    }

    public static func parseSingleID(id: String, pos: Array<Int32>, dir: Int32): TransliteratorIDParser_SingleID {
        let start = pos[0]
        var specsA: TransliteratorIDParser_Specs
        var specsB: TransliteratorIDParser_Specs
        var sawParen = false
        var pass = 1
        while (pass <= 2) {
            if (pass == 2) {
                specsA = parseFilterID(id, pos, true)
                if (specsA.isNone()) {
                    pos[0] = start
                    return None
                }
            }
            if (Utility.parseChar(id, pos, OPEN_REV)) {
                sawParen = true
                if (!Utility.parseChar(id, pos, CLOSE_REV)) {
                    specsB = parseFilterID(id, pos, true)
                    if (specsB.isNone() || !Utility.parseChar(id, pos, CLOSE_REV)) {
                        pos[0] = start
                        return None
                    }
                }
                break
            }
            pass++
        }
        var single: TransliteratorIDParser_SingleID
        if (sawParen) {
            if (dir == FORWARD) {
                single = specsToID(specsA, FORWARD)
                single.canonID = (single.canonID) + OPEN_REV.toString() + (specsToID(specsB, FORWARD).canonID) + CLOSE_REV.toString()
                if (specsA.isSome()) {
                    single.filter = specsA.filter
                }
            } else {
                single = specsToID(specsB, FORWARD)
                single.canonID = (single.canonID) + OPEN_REV.toString() + (specsToID(specsA, FORWARD).canonID) + CLOSE_REV.toString()
                if (specsB.isSome()) {
                    single.filter = specsB.filter
                }
            }
        } else {
            if (dir == FORWARD) {
                single = specsToID(specsA, FORWARD)
            } else {
                single = specsToSpecialInverse(specsA)
                if (single.isNone()) {
                    single = specsToID(specsA, REVERSE)
                }
            }
            single.filter = specsA.filter
        }
        return single
    }

    public static func parseGlobalFilter(id: String, pos: Array<Int32>, dir: Int32, withParens: Array<Int32>, canonID: StringBuffer): UnicodeSet {
        var filter: UnicodeSet
        let start = pos[0]
        if (withParens[0] == -1) {
            withParens[0] = if (Utility.parseChar(id, pos, OPEN_REV)) { 1 } else { 0 }
        } else if (withParens[0] == 1) {
            if (!Utility.parseChar(id, pos, OPEN_REV)) {
                pos[0] = start
                return None
            }
        }
        pos[0] = PatternProps.skipWhiteSpace(id, pos[0])
        if (UnicodeSet.resemblesPattern(id, pos[0])) {
            let ppos = ParsePosition(pos[0])
            try {
                filter = UnicodeSet(id, ppos, None)
            } catch (e: IllegalArgumentException) {
                pos[0] = start
                return None
            }
            var pattern: String = id[Int64(pos[0])..Int64(ppos.getIndex())]
            pos[0] = ppos.getIndex()
            if (withParens[0] == 1 && !Utility.parseChar(id, pos, CLOSE_REV)) {
                pos[0] = start
                return None
            }
            if (canonID.isSome()) {
                if (dir == FORWARD) {
                    if (withParens[0] == 1) {
                        pattern = OPEN_REV.toString() + (pattern) + CLOSE_REV.toString()
                    }
                    canonID.append((pattern) + ID_DELIM.toString())
                } else {
                    if (withParens[0] == 0) {
                        pattern = OPEN_REV.toString() + (pattern) + CLOSE_REV.toString()
                    }
                    canonID.insert(0, (pattern) + ID_DELIM.toString())
                }
            }
        }
        return filter
    }

    public static func parseCompoundID(id: String, dir: Int32, canonID: StringBuffer, list: ArrayList<TransliteratorIDParser_SingleID>, globalFilter: Array<UnicodeSet>): Bool {
        let pos = [0]
        let withParens = Array<Int32>(1) { _ => 0 }
        list.clear()
        var filter: UnicodeSet
        globalFilter[0] = None
        canonID.setLength(0)
        withParens[0] = 0
        filter = parseGlobalFilter(id, pos, dir, withParens, canonID)
        if (filter.isSome()) {
            if (!Utility.parseChar(id, pos, ID_DELIM)) {
                canonID.setLength(0)
                pos[0] = 0
            }
            if (dir == FORWARD) {
                globalFilter[0] = filter
            }
        }
        var sawDelimiter = true
        while (true) {
            let single = parseSingleID(id, pos, dir)
            if (single.isNone()) {
                break
            }
            if (dir == FORWARD) {
                list.append(single)
            } else {
                list.insert(0, single)
            }
            if (!Utility.parseChar(id, pos, ID_DELIM)) {
                sawDelimiter = false
                break
            }
        }
        if (Int32(list.size) == 0) {
            return false
        }
        var i = 0
        while (i < Int32(list.size)) {
            let single = list[Int64(i)]
            canonID.append(single.canonID)
            if (i != (Int32(list.size) - 1)) {
                canonID.append(ID_DELIM)
            }
            i++
        }
        if (sawDelimiter) {
            withParens[0] = 1
            filter = parseGlobalFilter(id, pos, dir, withParens, canonID)
            if (filter.isSome()) {
                Utility.parseChar(id, pos, ID_DELIM)
                if (dir == REVERSE) {
                    globalFilter[0] = filter
                }
            }
        }
        pos[0] = PatternProps.skipWhiteSpace(id, pos[0])
        if (pos[0] != Int32(id.size)) {
            return false
        }
        return true
    }

    static func instantiateList(ids: ArrayList<TransliteratorIDParser_SingleID>): ArrayList<Transliterator> {
        var t: Transliterator
        let translits = ArrayList<Transliterator>()
        for (single in ids) {
            if (Int32(single.basicID.size) == 0) {
                continue
            }
            t = single.getInstance()
            if (t.isNone()) {
                throw IllegalArgumentException("Illegal ID " + (single.canonID))
            }
            translits.append(t)
        }
        if (Int32(translits.size) == 0) {
            t = Transliterator.getBasicInstance("Any-Null", None)
            if (t.isNone()) {
                throw IllegalArgumentException("Internal error; cannot instantiate Any-Null")
            }
            translits.append(t)
        }
        return translits
    }

    public static func IDtoSTV(id: String): Array<String> {
        var source: String = ANY
        var target: String
        var variant: String = ""
        var sep = indexOfWrap(id.indexOf(UInt8(UInt32(TARGET_SEP))))
        var var = indexOfWrap(id.indexOf(UInt8(UInt32(VARIANT_SEP))))
        if (var < 0) {
            var = Int32(id.size)
        }
        var isSourcePresent = false
        if (sep < 0) {
            target = id[0..Int64(var)]
            variant = id[Int64(var)..]
        } else if (sep < var) {
            if (sep > 0) {
                source = id[0..Int64(sep)]
                isSourcePresent = true
            }
            target = id[Int64(match (0) { case _ => sep++; sep })..Int64(var)]
            variant = id[Int64(var)..]
        } else {
            if (var > 0) {
                source = id[0..Int64(var)]
                isSourcePresent = true
            }
            variant = id[Int64(var)..Int64(match (0) { case _ => sep++; sep - 1 })]
            target = id[Int64(sep)..]
        }
        if (Int32(variant.size) > 0) {
            variant = variant[1..]
        }
        return [source, target, variant, if (isSourcePresent) { "" } else { None }]
    }

    public static func STVtoID(source: String, target: String, variant: String): String {
        let id = StringBuilder(source)
        if (Int32(id.size) == 0) {
            id.append(ANY)
        }
        id.append(TARGET_SEP).append(target)
        if (variant.isSome() && Int32(variant.size) != 0) {
            id.append(VARIANT_SEP).append(variant)
        }
        return id.toString()
    }

    public static func registerSpecialInverse(target: String, inverseTarget: String, bidirectional: Bool): Unit {
        SPECIAL_INVERSES.put(CaseInsensitiveString(target), inverseTarget)
        if (bidirectional && !target.equalsIgnoreCase(inverseTarget)) {
            SPECIAL_INVERSES.put(CaseInsensitiveString(inverseTarget), target)
        }
    }

    private static func parseFilterID(id: String, pos: Array<Int32>, allowFilter: Bool): TransliteratorIDParser_Specs {
        var first: String
        var source: String
        var target: String
        var variant: String
        var filter: String
        var delimiter = Char(0)
        var specCount = 0
        let start = pos[0]
        while (true) {
            pos[0] = PatternProps.skipWhiteSpace(id, pos[0])
            if (pos[0] == Int32(id.size)) {
                break
            }
            if (allowFilter && filter.isNone() && UnicodeSet.resemblesPattern(id, pos[0])) {
                let ppos = ParsePosition(pos[0])
                UnicodeSet(id, ppos, None)
                filter = id[Int64(pos[0])..Int64(ppos.getIndex())]
                pos[0] = ppos.getIndex()
                continue
            }
            if (Int32(UInt32(delimiter)) == 0) {
                let c = Char(id[Int64(pos[0])])
                if ((c == TARGET_SEP && target.isNone()) || (c == VARIANT_SEP && variant.isNone())) {
                    delimiter = c
                    pos[0] += 1
                    continue
                }
            }
            if (Int32(UInt32(delimiter)) == 0 && specCount > 0) {
                break
            }
            let spec = Utility.parseUnicodeIdentifier(id, pos)
            if (spec.isNone()) {
                break
            }
            <-- Internal error: switch (delimiter) {
            case 0:
                first = spec;
                break;

            case TARGET_SEP:
                target = spec;
                break;

            case VARIANT_SEP:
                variant = spec;
                break;

            } -->
            specCount++
            delimiter = Char(0)
        }
        if (first.isSome()) {
            if (target.isNone()) {
                target = first
            } else {
                source = first
            }
        }
        if (source.isNone() && target.isNone()) {
            pos[0] = start
            return None
        }
        var sawSource = true
        if (source.isNone()) {
            source = ANY
            sawSource = false
        }
        if (target.isNone()) {
            target = ANY
        }
        return TransliteratorIDParser_Specs(source, target, variant, sawSource, filter)
    }

    private static func specsToID(specs: TransliteratorIDParser_Specs, dir: Int32): TransliteratorIDParser_SingleID {
        var canonID: String = ""
        var basicID: String = ""
        var basicPrefix: String = ""
        if (specs.isSome()) {
            let buf = StringBuilder()
            if (dir == FORWARD) {
                if (specs.sawSource) {
                    buf.append(specs.source).append(TARGET_SEP)
                } else {
                    basicPrefix = (specs.source) + TARGET_SEP.toString()
                }
                buf.append(specs.target)
            } else {
                buf.append(specs.target).append(TARGET_SEP).append(specs.source)
            }
            if (specs.variant.isSome()) {
                buf.append(VARIANT_SEP).append(specs.variant)
            }
            basicID = (basicPrefix) + buf.toString()
            if (specs.filter.isSome()) {
                buf.insert(0, specs.filter)
            }
            canonID = buf.toString()
        }
        return TransliteratorIDParser_SingleID(canonID, basicID)
    }

    private static func specsToSpecialInverse(specs: TransliteratorIDParser_Specs): TransliteratorIDParser_SingleID {
        if (!specs.source.equalsIgnoreCase(ANY)) {
            return None
        }
        let inverseTarget = SPECIAL_INVERSES.get(CaseInsensitiveString(specs.target))
        if (inverseTarget.isSome()) {
            let buf = StringBuilder()
            if (specs.filter.isSome()) {
                buf.append(specs.filter)
            }
            if (specs.sawSource) {
                buf.append(ANY).append(TARGET_SEP)
            }
            buf.append(inverseTarget)
            var basicID: String = ANY + TARGET_SEP.toString() + (inverseTarget)
            if (specs.variant.isSome()) {
                buf.append(VARIANT_SEP).append(specs.variant)
                basicID = (basicID) + VARIANT_SEP.toString() + (specs.variant)
            }
            return TransliteratorIDParser_SingleID(buf.toString(), basicID)
        }
        return None
    }
}


class TransliteratorIDParser_Specs {
    public var source: String

    public var target: String

    public var variant: String

    public var filter: String

    public var sawSource: Bool = false

    init(s: String, t: String, v: String, sawS: Bool, f: String) {
        source = s
        target = t
        variant = v
        sawSource = sawS
        filter = f
    }
}


class TransliteratorIDParser_SingleID {
    public var canonID: String

    public var basicID: String

    public var filter: String

    init(c: String, b: String, f: String) {
        canonID = c
        basicID = b
        filter = f
    }

    init(c: String, b: String) {
        this(c, b, None)
    }

    public func getInstance(): Transliterator {
        let t: Transliterator
        if (basicID.isNone() || Int32(basicID.size) == 0) {
            t = Transliterator.getBasicInstance("Any-Null", canonID)
        } else {
            t = Transliterator.getBasicInstance(basicID, canonID)
        }
        if (t.isSome()) {
            if (filter.isSome()) {
                t.setFilter(UnicodeSet(filter))
            }
        }
        return t
    }
}
