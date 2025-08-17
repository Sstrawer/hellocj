package icu4cj.text


public abstract class Transliterator <: StringTransform {
    public static let FORWARD = 0

    public static let REVERSE = 1

    private var ID: String

    private var filter: UnicodeSet

    private var maximumContextLength = 0

    private static var registry: TransliteratorRegistry

    private static var displayNameCache: Map<CaseInsensitiveString, String> = None

    private static let RB_DISPLAY_NAME_PREFIX = "%Translit%%"

    private static let RB_SCRIPT_DISPLAY_NAME_PREFIX = "%Translit%"

    private static let RB_DISPLAY_NAME_PATTERN = "TransliteratorNamePattern"

    static let ID_DELIM = ';'

    static let ID_SEP = '-'

    static let VARIANT_SEP = '/'

    static let DEBUG = false

    protected init(ID: String, filter: UnicodeFilter) {
        if (ID.isNone()) {
            throw NoneValueException()
        }
        this.ID = ID
        setFilter(filter)
    }

    public func transliterate(text: Replaceable, start: Int32, limit: Int32): Int32 {
        if (start < 0 || limit < start || text.size < limit) {
            return -1
        }
        let pos = Transliterator_Position(start, limit, start)
        filteredTransliterate(text, pos, false, true)
        return pos.limit
    }

    public func transliterate(text: Replaceable): Unit {
        transliterate(text, 0, text.size)
    }

    public func transliterate(text: String): String {
        let result = ReplaceableString(text)
        transliterate(result)
        return result.toString()
    }

    public func transliterate(text: Replaceable, index: Transliterator_Position, insertion: String): Unit {
        index.validate(text.size)
        if (insertion.isSome()) {
            text.replace(index.limit, index.limit, insertion)
            index.limit += Int32(insertion.size)
            index.contextLimit += Int32(insertion.size)
        }
        if (index.limit > 0 && UTF16.isLeadSurrogate(Int32(UInt32(text.toRuneArray()[index.limit - 1])))) {
            return
        }
        filteredTransliterate(text, index, true, true)
    }

    public func transliterate(text: Replaceable, index: Transliterator_Position, insertion: Int32): Unit {
        transliterate(text, index, UTF16.valueOf(insertion))
    }

    public func transliterate(text: Replaceable, index: Transliterator_Position): Unit {
        transliterate(text, index, None)
    }

    public func finishTransliteration(text: Replaceable, index: Transliterator_Position): Unit {
        index.validate(text.size)
        filteredTransliterate(text, index, false, true)
    }

    protected func handleTransliterate(text: Replaceable, pos: Transliterator_Position, incremental: Bool): Unit

    private func filteredTransliterate(text: Replaceable, index: Transliterator_Position, incremental: Bool, rollback: Bool): Unit {
        if (filter.isNone() && !rollback) {
            handleTransliterate(text, index, incremental)
            return
        }
        var globalLimit = index.limit
        let log: StringBuffer = None
        if (DEBUG) {
            log = StringBuffer()
        }
        while (true) {
            if (filter.isSome()) {
                var c: Int32 = 0
                while (index.start < globalLimit && !filter.contains(match (0) { case _ => c = text.char32At(index.start); c })) {
                    index.start += UTF16.getCharCount(c)
                }
                index.limit = index.start
                while (index.limit < globalLimit && filter.contains(match (0) { case _ => c = text.char32At(index.limit); c })) {
                    index.limit += UTF16.getCharCount(c)
                }
            }
            if (index.start == index.limit) {
                break
            }
            let isIncrementalRun = (if (index.limit < globalLimit) { false } else { incremental })
            var delta: Int32 = 0
            if (rollback && isIncrementalRun) {
                if (DEBUG) {
                    log.setLength(0)
                    println("filteredTransliterate{" + (getID()) + "}i: IN=" + (UtilityExtensions.formatInput(text, index)))
                }
                let runStart = index.start
                var runLimit = index.limit
                let runLength = runLimit - runStart
                var rollbackOrigin = text.size
                text.copy(runStart, runLimit, rollbackOrigin)
                var passStart = runStart
                var rollbackStart = rollbackOrigin
                var passLimit = index.start
                var uncommittedLength = 0
                var totalDelta = 0
                while (true) {
                    let charLength = UTF16.getCharCount(text.char32At(passLimit))
                    passLimit += charLength
                    if (passLimit > runLimit) {
                        break
                    }
                    uncommittedLength += charLength
                    index.limit = passLimit
                    if (DEBUG) {
                        log.setLength(0)
                        log.append("filteredTransliterate{" + (getID()) + "}i: ")
                        UtilityExtensions.formatInput(log, text, index)
                    }
                    handleTransliterate(text, index, true)
                    if (DEBUG) {
                        log.append(" => ")
                        UtilityExtensions.formatInput(log, text, index)
                    }
                    delta = index.limit - passLimit
                    if (index.start != index.limit) {
                        let rs = rollbackStart + delta - (index.limit - passStart)
                        text.replace(passStart, index.limit, "")
                        text.copy(rs, rs + uncommittedLength, passStart)
                        index.start = passStart
                        index.limit = passLimit
                        index.contextLimit -= delta
                        if (DEBUG) {
                            log.append(" (ROLLBACK)")
                        }
                    } else {
                        passStart = match (0) { case _ => passLimit = index.start; passLimit }
                        rollbackStart += delta + uncommittedLength
                        uncommittedLength = 0
                        runLimit += delta
                        totalDelta += delta
                    }
                    if (DEBUG) {
                        println(Utility.escape(toString(log)))
                    }
                }
                rollbackOrigin += totalDelta
                globalLimit += totalDelta
                text.replace(rollbackOrigin, rollbackOrigin + runLength, "")
                index.start = passStart
            } else {
                if (DEBUG) {
                    log.setLength(0)
                    log.append("filteredTransliterate{" + (getID()) + "}: ")
                    UtilityExtensions.formatInput(log, text, index)
                }
                let limit = index.limit
                handleTransliterate(text, index, isIncrementalRun)
                delta = index.limit - limit
                if (DEBUG) {
                    log.append(" => ")
                    UtilityExtensions.formatInput(log, text, index)
                }
                if (!isIncrementalRun && index.start != index.limit) {
                    throw Exception("ERROR: Incomplete non-incremental transliteration by " + (getID()))
                }
                globalLimit += delta
                if (DEBUG) {
                    println(Utility.escape(toString(log)))
                }
            }
            if (filter.isNone() || isIncrementalRun) {
                break
            }
        }
        index.limit = globalLimit
        if (DEBUG) {
            println("filteredTransliterate{" + (getID()) + "}: OUT=" + (UtilityExtensions.formatInput(text, index)))
        }
    }

    public func filteredTransliterate(text: Replaceable, index: Transliterator_Position, incremental: Bool): Unit {
        filteredTransliterate(text, index, incremental, false)
    }

    public func getMaximumContextLength(): Int32 {
        return maximumContextLength
    }

    protected func setMaximumContextLength(a: Int32): Unit {
        if (a < 0) {
            throw IllegalArgumentException("Invalid context length " + a.toString())
        }
        maximumContextLength = a
    }

    public func getID(): String {
        return ID
    }

    protected func setID(id: String): Unit {
        ID = id
    }

    public static func getDisplayName(ID: String): String {
        return getDisplayName(ID, ULocale.getDefault(ULocale_Category.DISPLAY))
    }

    public static func getDisplayName(id: String, inLocale: Locale): String {
        return getDisplayName(id, ULocale.forLocale(inLocale))
    }

    public static func getDisplayName(id: String, inLocale: ULocale): String {
        let bundle = UResourceBundle.getBundleInstance(ICUData.ICU_TRANSLIT_BASE_NAME, inLocale)
        let stv = TransliteratorIDParser.IDtoSTV(id)
        if (stv.isNone()) {
            return ""
        }
        var ID: String = (stv[0]) + '-'.toString() + (stv[1])
        if (stv[2].isSome() && Int32(stv[2].size) > 0) {
            ID = (ID) + '/'.toString() + (stv[2])
        }
        let n = displayNameCache.get(CaseInsensitiveString(ID))
        if (n.isSome()) {
            return n
        }
        try {
            return bundle.getString(RB_DISPLAY_NAME_PREFIX + (ID))
        } catch (e: MissingResourceException) { }
        try {
            let format = MessageFormat(bundle.getString(RB_DISPLAY_NAME_PATTERN))
            let args: Array<Object> = [2, stv[0], stv[1]]
            var j = 1
            while (j <= 2) {
                try {
                    args[Int64(j)] = bundle.getString(RB_SCRIPT_DISPLAY_NAME_PREFIX + (args[Int64(j)]))
                } catch (e: MissingResourceException) { }
                j++
            }
            return if (Int32(stv[2].size) > 0) { (Some((format.format(args)) + '/'.toString() + (stv[2]))) } else { format.format(args) }
        } catch (e2: MissingResourceException) { }
        throw Exception()
    }

    public func getFilter(): UnicodeFilter {
        return filter
    }

    public func setFilter(filter: UnicodeFilter): Unit {
        if (filter.isNone()) {
            this.filter = None
        } else {
            try {
                this.filter = UnicodeSet(filter).freeze()
            } catch (e: Exception) {
                this.filter = UnicodeSet()
                filter.addMatchSetTo(this.filter)
                this.filter.freeze()
            }
        }
    }

    public static func getInstance(ID: String): Transliterator {
        return getInstance(ID, FORWARD)
    }

    public static func getInstance(ID: String, dir: Int32): Transliterator {
        let canonID = StringBuffer()
        let list = ArrayList<TransliteratorIDParser_SingleID>()
        let globalFilter = Array<UnicodeSet>(1)
        if (!TransliteratorIDParser.parseCompoundID(ID, dir, canonID, list, globalFilter)) {
            throw IllegalArgumentException("Invalid ID " + (ID))
        }
        let translits = TransliteratorIDParser.instantiateList(list)
        var t: Transliterator
        if (Int32(list.size) > 1 || canonID.indexOf(";") >= 0) {
            t = CompoundTransliterator(translits)
        } else {
            t = translits[0]
        }
        t.setID(toString(canonID))
        if (globalFilter[0].isSome()) {
            t.setFilter(globalFilter[0])
        }
        return t
    }

    static func getBasicInstance(id: String, canonID: String): Transliterator {
        let s = StringBuffer()
        var t = registry.get(id, s)
        if (Int32(s.size) != 0) {
            t = getInstance(toString(s), FORWARD)
        }
        if (t.isSome() && canonID.isSome()) {
            t.setID(canonID)
        }
        return t
    }

    public static func createFromRules(ID: String, rules: String, dir: Int32): Transliterator {
        var t: Transliterator
        let parser = TransliteratorParser()
        parser.parse(rules, dir)
        if (Int32(parser.idBlockVector.size) == 0 && Int32(parser.dataVector.size) == 0) {
            t = NullTransliterator()
        } else if (Int32(parser.idBlockVector.size) == 0 && Int32(parser.dataVector.size) == 1) {
            t = RuleBasedTransliterator(ID, parser.dataVector[0], parser.compoundFilter)
        } else if (Int32(parser.idBlockVector.size) == 1 && Int32(parser.dataVector.size) == 0) {
            if (parser.compoundFilter.isSome()) {
                t = getInstance((parser.compoundFilter.toPattern(false)) + ";" + (parser.idBlockVector[0]))
            } else {
                t = getInstance(parser.idBlockVector[0])
            }
            if (t.isSome()) {
                t.setID(ID)
            }
        } else {
            let transliterators = ArrayList<Transliterator>()
            var passNumber = 1
            let limit = Int32(max(parser.idBlockVector.size, parser.dataVector.size))
            var i = 0
            while (i < limit) {
                if (i < Int32(parser.idBlockVector.size)) {
                    let idBlock = parser.idBlockVector[Int64(i)]
                    if (Int32(idBlock.size) > 0) {
                        let temp = getInstance(idBlock)
                        if (!(checkOptionalIs<NullTransliterator, Transliterator>(temp))) {
                            transliterators.append(getInstance(idBlock))
                        }
                    }
                }
                if (i < Int32(parser.dataVector.size)) {
                    let data = parser.dataVector[Int64(i)]
                    transliterators.append(RuleBasedTransliterator("%Pass" + (match (0) { case _ => passNumber++; passNumber - 1 }).toString(), data, None))
                }
                i++
            }
            t = CompoundTransliterator(transliterators, passNumber - 1)
            t.setID(ID)
            if (parser.compoundFilter.isSome()) {
                t.setFilter(parser.compoundFilter)
            }
        }
        return t
    }

    public func toRules(escapeUnprintable: Bool): String {
        return baseToRules(escapeUnprintable)
    }

    protected func baseToRules(escapeUnprintable: Bool): String {
        if (escapeUnprintable) {
            let rulesSource = StringBuffer()
            let id = getID()
            var i = 0
            while (i < Int32(id.size)) {
                let c = UTF16.toRuneArray()[id, i]
                if (!Utility.escapeUnprintable(rulesSource, c)) {
                    UTF16.append(rulesSource, c)
                }
                i += UTF16.getCharCount(c)
            }
            rulesSource.insert(0, "::")
            rulesSource.append(ID_DELIM)
            return toString(rulesSource)
        }
        return "::" + (getID()) + ID_DELIM.toString()
    }

    public func getElements(): Array<Transliterator> {
        let result: Array<Transliterator>
        if (checkOptionalIs<CompoundTransliterator, Transliterator>(this)) {
            let cpd = this as CompoundTransliterator
            result = Array<Transliterator>(Int64(cpd.getCount()))
            var i = 0
            while (i < Int32(result.size)) {
                result[Int64(i)] = cpd.getTransliterator(i)
                i++
            }
        } else {
            result = [this]
        }
        return result
    }

    public func getSourceSet(): UnicodeSet {
        let result = UnicodeSet()
        addSourceTargetSet(getFilterAsUnicodeSet(UnicodeSet.ALL_CODE_POINTS), result, UnicodeSet())
        return result
    }

    protected func handleGetSourceSet(): UnicodeSet {
        return UnicodeSet()
    }

    public func getTargetSet(): UnicodeSet {
        let result = UnicodeSet()
        addSourceTargetSet(getFilterAsUnicodeSet(UnicodeSet.ALL_CODE_POINTS), UnicodeSet(), result)
        return result
    }

    
    public func addSourceTargetSet(inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        let myFilter = getFilterAsUnicodeSet(inputFilter)
        let temp = UnicodeSet(handleGetSourceSet()).retainAll(myFilter)
        sourceSet.addAll(temp)
        for (s in temp) {
            let t = transliterate(s)
            if (!s.equals(t)) {
                targetSet.addAll(t)
            }
        }
    }

    
    public func getFilterAsUnicodeSet(externalFilter: UnicodeSet): UnicodeSet {
        if (filter.isNone()) {
            return externalFilter
        }
        let filterSet = UnicodeSet(externalFilter)
        var temp: UnicodeSet
        try {
            temp = filter
        } catch (e: ClassCastException) {
            filter.addMatchSetTo(match (0) { case _ => temp = UnicodeSet(); temp })
        }
        return filterSet.retainAll(temp).freeze()
    }

    public func getInverse(): Transliterator {
        return getInstance(ID, REVERSE)
    }

    public static func registerClass(ID: String, transClass: ClassTypeInfo, displayName: String): Unit {
        registry.put(ID, transClass, true)
        if (displayName.isSome()) {
            displayNameCache.put(CaseInsensitiveString(ID), displayName)
        }
    }

    public static func registerFactory(ID: String, factory: Transliterator_Factory): Unit {
        registry.put(ID, factory, true)
    }

    public static func registerInstance(trans: Transliterator): Unit {
        registry.put(trans.getID(), trans, true)
    }

    static func registerInstance(trans: Transliterator, visible: Bool): Unit {
        registry.put(trans.getID(), trans, visible)
    }

    public static func registerAlias(aliasID: String, realID: String): Unit {
        registry.put(aliasID, realID, true)
    }

    static func registerSpecialInverse(target: String, inverseTarget: String, bidirectional: Bool): Unit {
        TransliteratorIDParser.registerSpecialInverse(target, inverseTarget, bidirectional)
    }

    public static func unregister(ID: String): Unit {
        displayNameCache.remove(CaseInsensitiveString(ID))
        registry.remove(ID)
    }

    public static func getAvailableIDs(): Enumeration<String> {
        return registry.getAvailableIDs()
    }

    public static func getAvailableSources(): Enumeration<String> {
        return registry.getAvailableSources()
    }

    public static func getAvailableTargets(source: String): Enumeration<String> {
        return registry.getAvailableTargets(source)
    }

    public static func getAvailableVariants(source: String, target: String): Enumeration<String> {
        return registry.getAvailableVariants(source, target)
    }

    private static let ROOT = "root"

    private static let RB_RULE_BASED_IDS = "RuleBasedTransliteratorIDs"


    
    public static func registerAny(): Unit {
        AnyTransliterator.register()
    }

    public override func transform(source: String): String {
        return transliterate(source)
    }
}


public class Transliterator_Position {
    public var contextStart: Int32 = 0

    public var contextLimit: Int32 = 0

    public var start: Int32 = 0

    public var limit: Int32 = 0

    public init() {
        this(0, 0, 0, 0)
    }

    public init(contextStart: Int32, contextLimit: Int32, start: Int32) {
        this(contextStart, contextLimit, start, contextLimit)
    }

    public init(contextStart: Int32, contextLimit: Int32, start: Int32, limit: Int32) {
        this.contextStart = contextStart
        this.contextLimit = contextLimit
        this.start = start
        this.limit = limit
    }

    public init(pos: Transliterator_Position) {
        set(pos)
    }

    public func set(pos: Transliterator_Position): Unit {
        contextStart = pos.contextStart
        contextLimit = pos.contextLimit
        start = pos.start
        limit = pos.limit
    }

    public override func equals(obj: Object): Bool {
        if (checkOptionalIs<Transliterator_Position, Object>(obj)) {
            let pos = obj
            return contextStart == pos.contextStart && contextLimit == pos.contextLimit && start == pos.start && limit == pos.limit
        }
        return false
    }

    public override func hashCode(): Int64 {
        return Int64(Objects.hash([contextStart, contextLimit, start, limit]))
    }

    public override func toString(): String {
        return "[cs=" + contextStart.toString() + ", s=" + start.toString() + ", l=" + limit.toString() + ", cl=" + contextLimit.toString() + "]"
    }

    public func validate(length: Int32): Unit {
        if (contextStart < 0 || start < contextStart || limit < start || contextLimit < limit || length < contextLimit) {
            throw IllegalArgumentException("Invalid Position {cs=" + contextStart.toString() + ", s=" + start.toString() + ", l=" + limit.toString() + ", cl=" + contextLimit.toString() + "}, len=" + length.toString())
        }
    }
}


public interface Transliterator_Factory {
    func getInstance(ID: String): Transliterator
}