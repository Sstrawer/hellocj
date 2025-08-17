package icu4cj.text


class AnyTransliterator <: Transliterator {
    static let TARGET_SEP = '-'

    static let VARIANT_SEP = '/'

    static let ANY = "Any"

    static let NULL_ID = "Null"

    static let LATIN_PIVOT = "-Latin;Latin-"

    private var cache: ConcurrentHashMap = None

    private var target: String

    private var targetScript: Int32 = 0

    override protected func handleTransliterate(text: Replaceable, pos: Transliterator_Position, isIncremental: Bool): Unit {
        let allStart = pos.start
        var allLimit = pos.limit
        let it = AnyTransliterator_ScriptRunIterator(text, pos.contextStart, pos.contextLimit)
        while (it.next()) {
            if (it.limit <= allStart) {
                continue
            }
            let t = getTransliterator(it.scriptCode)
            if (t.isNone()) {
                pos.start = it.limit
                continue
            }
            let incremental = isIncremental && (it.limit >= allLimit)
            pos.start = max(allStart, it.start)
            pos.limit = min(allLimit, it.limit)
            let limit = pos.limit
            t.filteredTransliterate(text, pos, incremental)
            let delta = pos.limit - limit
            allLimit += delta
            it.adjustLimit(delta)
            if (it.limit >= allLimit) {
                break
            }
        }
        pos.limit = allLimit
    }

    private init(id: String, theTarget: String, theVariant: String, theTargetScript: Int32) {
        super(id, None)
        targetScript = theTargetScript
        cache = ConcurrentHashMap()
        target = theTarget
        if (Int32(theVariant.size) > 0) {
            target = (theTarget) + VARIANT_SEP.toString() + (theVariant)
        }
    }

    public init(id: String, filter: UnicodeFilter, target2: String, targetScript2: Int32, widthFix2: Transliterator, cache2: ConcurrentHashMap) {
        super(id, filter)
        targetScript = targetScript2
        cache = cache2
        target = target2
    }

    private func getTransliterator(source: Int32): Transliterator {
        if (source == targetScript || source == UScript.INVALID_CODE) {
            if (isWide(targetScript)) {
                return None
            } else {
                return AnyTransliterator_WidthFix.INSTANCE
            }
        }
        let key: Int32 = source
        var t = cache.get(key)
        if (t.isNone()) {
            let sourceName = UScript.getName(source)
            var id: String = (sourceName) + TARGET_SEP.toString() + (target)
            @AssertThrows[Exception]({
                t = Transliterator.getInstance(id, FORWARD)
            })
            if (t.isNone()) {
                id = (sourceName) + LATIN_PIVOT + (target)
                @AssertThrows[Exception]({
                    t = Transliterator.getInstance(id, FORWARD)
                })
            }
            if (t.isSome()) {
                if (!isWide(targetScript)) {
                    let v = ArrayList<Transliterator>()
                    v.append(AnyTransliterator_WidthFix.INSTANCE)
                    v.append(t)
                    t = CompoundTransliterator(v)
                }
                let prevCachedT = cache.putIfAbsent(key, t)
                if (prevCachedT.isSome()) {
                    t = prevCachedT
                }
            } else if (!isWide(targetScript)) {
                return AnyTransliterator_WidthFix.INSTANCE
            }
        }
        return t
    }

    private func isWide(script: Int32): Bool {
        return script == UScript.BOPOMOFO || script == UScript.HAN || script == UScript.HANGUL || script == UScript.HIRAGANA || script == UScript.KATAKANA
    }

    static func register(): Unit {
        let seen = HashMap<String, Set<String>>()
        let s = Transliterator.getAvailableSources()
        while (s.hasMoreElements()) {
            let source = s.nextElement()
            if (source.equalsIgnoreCase(ANY)) {
                continue
            }
            let t = Transliterator.getAvailableTargets(source)
            while (t.hasMoreElements()) {
                let target = t.nextElement()
                let targetScript = scriptNameToCode(target)
                if (targetScript == UScript.INVALID_CODE) {
                    continue
                }
                var seenVariants = seen.get(target)
                if (seenVariants.isNone()) {
                    seen.put(target, match (0) { case _ => seenVariants = HashSet<String>(); seenVariants })
                }
                let v = Transliterator.getAvailableVariants(source, target)
                while (v.hasMoreElements()) {
                    let variant = v.nextElement()
                    if (seenVariants.contains(variant)) {
                        continue
                    }
                    seenVariants.put(variant)
                    let id: String
                    id = TransliteratorIDParser.STVtoID(ANY, target, variant)
                    let trans = AnyTransliterator(id, target, variant, targetScript)
                    Transliterator.registerInstance(trans)
                    Transliterator.registerSpecialInverse(target, NULL_ID, false)
                }
            }
        }
    }

    private static func scriptNameToCode(name: String): Int32 {
        try {
            let codes = UScript.getCode(name)
            return if (codes.isSome()) { codes[0] } else { UScript.INVALID_CODE }
        } catch (e: MissingResourceException) {
            return UScript.INVALID_CODE
        }
    }

    public func safeClone(): Transliterator {
        var filter = getFilter()
        if (filter.isSome() && checkOptionalIs<UnicodeSet, UnicodeFilter>(filter)) {
            filter = UnicodeSet(filter)
        }
        return AnyTransliterator(getID(), filter, target, targetScript, None, cache)
    }

    public override func addSourceTargetSet(inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        let myFilter = getFilterAsUnicodeSet(inputFilter)
        sourceSet.addAll(myFilter)
        if (myFilter.size() != 0) {
            targetSet.addAll(0, 1114111)
        }
    }
}


class AnyTransliterator_WidthFix {

    private static let ID = "[[:dt=Nar:][:dt=Wide:]] nfkd"

    static let INSTANCE = Transliterator.getInstance(ID)
}


class AnyTransliterator_ScriptRunIterator {
    private var text: Replaceable

    private var textStart: Int32 = 0

    private var textLimit: Int32 = 0

    public var scriptCode: Int32 = 0

    public var start: Int32 = 0

    public var limit: Int32 = 0

    public init(text: Replaceable, start: Int32, limit: Int32) {
        this.text = text
        this.textStart = start
        this.textLimit = limit
        this.limit = start
    }

    public func next(): Bool {
        var ch: Int32 = 0
        var s: Int32 = 0
        scriptCode = UScript.INVALID_CODE
        start = limit
        if (start == textLimit) {
            return false
        }
        while (start > textStart) {
            ch = text.char32At(start - 1)
            s = UScript.getScript(ch)
            if (s == UScript.COMMON || s == UScript.INHERITED) {
                start--
            } else {
                break
            }
        }
        while (limit < textLimit) {
            ch = text.char32At(limit)
            s = UScript.getScript(ch)
            if (s != UScript.COMMON && s != UScript.INHERITED) {
                if (scriptCode == UScript.INVALID_CODE) {
                    scriptCode = s
                } else if (s != scriptCode) {
                    break
                }
            }
            limit++
        }
        return true
    }

    public func adjustLimit(delta: Int32): Unit {
        limit += delta
        textLimit += delta
    }
}
