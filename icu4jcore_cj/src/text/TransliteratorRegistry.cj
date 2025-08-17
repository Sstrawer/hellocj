package icu4cj.text


class TransliteratorRegistry {
    static let LOCALE_SEP = '_'

    private static let NO_VARIANT = ""

    private static let ANY = "Any"

    private var registry: Map<CaseInsensitiveString, Array<Object>> = None

    private var specDAG: Map<CaseInsensitiveString, Map<CaseInsensitiveString, ArrayList<CaseInsensitiveString>>> = None

    private let availableIDs: Set<CaseInsensitiveString>

    public init() {
        registry = Collections.synchronizedMap(HashMap<CaseInsensitiveString, Array<Object>>() as Map<K, V>)
        specDAG = Collections.synchronizedMap(HashMap<CaseInsensitiveString, Map<CaseInsensitiveString, ArrayList<CaseInsensitiveString>>>() as Map<K, V>)
        availableIDs = LinkedHashSet() as Set<CaseInsensitiveString>
    }

    public func get(ID: String, aliasReturn: StringBuffer): Transliterator {
        let entry = find(ID)
        return if (entry.isNone()) { None } else { instantiateEntry(ID, entry, aliasReturn) }
    }

    public func put(ID: String, transliteratorSubclass: ClassTypeInfo, visible: Bool): Unit {
        registerEntry(ID, transliteratorSubclass, visible)
    }

    public func put(ID: String, factory: Transliterator_Factory, visible: Bool): Unit {
        registerEntry(ID, factory, visible)
    }

    public func put(ID: String, resourceName: String, dir: Int32, visible: Bool): Unit {
        registerEntry(ID, TransliteratorRegistry_ResourceEntry(resourceName, dir), visible)
    }

    public func put(ID: String, alias: String, visible: Bool): Unit {
        registerEntry(ID, TransliteratorRegistry_AliasEntry(alias), visible)
    }

    public func put(ID: String, trans: Transliterator, visible: Bool): Unit {
        registerEntry(ID, trans, visible)
    }

    public func remove(ID: String): Unit {
        let stv = TransliteratorIDParser.IDtoSTV(ID)
        let id = TransliteratorIDParser.STVtoID(stv[0], stv[1], stv[2])
        registry.remove(CaseInsensitiveString(id))
        removeSTV(stv[0], stv[1], stv[2])
        availableIDs.remove(CaseInsensitiveString(id))
    }

    public func getAvailableIDs(): Enumeration<String> {
        return TransliteratorRegistry_IDEnumeration(Collections.enumeration(availableIDs)) as Enumeration<String>
    }

    public func getAvailableSources(): Enumeration<String> {
        return TransliteratorRegistry_IDEnumeration(Collections.enumeration(specDAG.keys() as Collection<T>)) as Enumeration<String>
    }

    public func getAvailableTargets(source: String): Enumeration<String> {
        let cisrc = CaseInsensitiveString(source)
        let targets = specDAG.get(cisrc)
        if (targets.isNone()) {
            return TransliteratorRegistry_IDEnumeration(None) as Enumeration<String>
        }
        return TransliteratorRegistry_IDEnumeration(Collections.enumeration(targets.keys() as Collection<T>)) as Enumeration<String>
    }

    public func getAvailableVariants(source: String, target: String): Enumeration<String> {
        let cisrc = CaseInsensitiveString(source)
        let citrg = CaseInsensitiveString(target)
        let targets = specDAG.get(cisrc)
        if (targets.isNone()) {
            return TransliteratorRegistry_IDEnumeration(None) as Enumeration<String>
        }
        let variants = targets.get(citrg)
        if (variants.isNone()) {
            return TransliteratorRegistry_IDEnumeration(None) as Enumeration<String>
        }
        return TransliteratorRegistry_IDEnumeration(Collections.enumeration(variants)) as Enumeration<String>
    }

    private func registerEntry(source: String, target: String, variant: String, entry: Object, visible: Bool): Unit {
        var s = source
        if (Int32(s.size) == 0) {
            s = ANY
        }
        let ID = TransliteratorIDParser.STVtoID(source, target, variant)
        registerEntry(ID, s, target, variant, entry, visible)
    }

    private func registerEntry(ID: String, entry: Object, visible: Bool): Unit {
        let stv = TransliteratorIDParser.IDtoSTV(ID)
        let id = TransliteratorIDParser.STVtoID(stv[0], stv[1], stv[2])
        registerEntry(id, stv[0], stv[1], stv[2], entry, visible)
    }

    private func registerEntry(ID: String, source: String, target: String, variant: String, entry: Object, visible: Bool): Unit {
        let ciID = CaseInsensitiveString(ID)
        let arrayOfObj: Array<Object>
        if (entry) {
            arrayOfObj = entry
        } else {
            arrayOfObj = [entry]
        }
        registry.put(ciID, arrayOfObj)
        if (visible) {
            registerSTV(source, target, variant)
            availableIDs.put(ciID)
        } else {
            removeSTV(source, target, variant)
            availableIDs.remove(ciID)
        }
    }

    private func registerSTV(source: String, target: String, variant: String): Unit {
        let cisrc = CaseInsensitiveString(source)
        let citrg = CaseInsensitiveString(target)
        let civar = CaseInsensitiveString(variant)
        var targets = specDAG.get(cisrc)
        if (targets.isNone()) {
            targets = Collections.synchronizedMap(HashMap<CaseInsensitiveString, ArrayList<CaseInsensitiveString>>() as Map<K, V>)
            specDAG.put(cisrc, targets)
        }
        var variants = targets.get(citrg)
        if (variants.isNone()) {
            variants = ArrayList<CaseInsensitiveString>()
            targets.put(citrg, variants)
        }
        if (!variants.contains(civar)) {
            if (Int32(variant.size) > 0) {
                variants.append(civar)
            } else {
                variants.insert(0, civar)
            }
        }
    }

    private func removeSTV(source: String, target: String, variant: String): Unit {
        let cisrc = CaseInsensitiveString(source)
        let citrg = CaseInsensitiveString(target)
        let civar = CaseInsensitiveString(variant)
        let targets = specDAG.get(cisrc)
        if (targets.isNone()) {
            return
        }
        let variants = targets.get(citrg)
        if (variants.isNone()) {
            return
        }
        variants.removeObject(civar)
        if (Int32(variants.size) == 0) {
            targets.remove(citrg)
            if (Int32(targets.size) == 0) {
                specDAG.remove(cisrc)
            }
        }
    }

    private static let DEBUG = false

    private func findInDynamicStore(src: TransliteratorRegistry_Spec, trg: TransliteratorRegistry_Spec, variant: String): Array<Object> {
        let ID = TransliteratorIDParser.STVtoID(src.get(), trg.get(), variant)
        if (DEBUG) {
            println("TransliteratorRegistry.findInDynamicStore:" + (ID))
        }
        return registry.get(CaseInsensitiveString(ID))
    }

    private func findInStaticStore(src: TransliteratorRegistry_Spec, trg: TransliteratorRegistry_Spec, variant: String): Array<Object> {
        if (DEBUG) {
            let ID = TransliteratorIDParser.STVtoID(src.get(), trg.get(), variant)
            println("TransliteratorRegistry.findInStaticStore:" + (ID))
        }
        var entry: Array<Object>
        if (src.isLocale()) {
            entry = findInBundle(src, trg, variant, Transliterator.FORWARD)
        } else if (trg.isLocale()) {
            entry = findInBundle(trg, src, variant, Transliterator.REVERSE)
        }
        if (entry.isSome()) {
            registerEntry(src.getTop(), trg.getTop(), variant, entry, false)
        }
        return entry
    }

    private func findInBundle(specToOpen: TransliteratorRegistry_Spec, specToFind: TransliteratorRegistry_Spec, variant: String, direction: Int32): Array<Object> {
        let res = specToOpen.getBundle()
        if (res.isNone()) {
            return None
        }
        var pass = 0
        while (pass < 2) {
            let tag = StringBuilder()
            if (pass == 0) {
                tag.append(if (direction == Transliterator.FORWARD) { "TransliterateTo" } else { "TransliterateFrom" })
            } else {
                tag.append("Transliterate")
            }
            tag.append(specToFind.get().toUpperCase(Locale.ENGLISH))
            try {
                let subres = res.getStringArray(tag.toString())
                var i = 0
                if (Int32(variant.size) != 0) {
                    i = 0
                    while (i < Int32(subres.size)) {
                        if (subres[Int64(i)].equalsIgnoreCase(variant)) {
                            break
                        }
                        i += 2
                    }
                }
                if (i < Int32(subres.size)) {
                    let dir = if (pass == 0) { Transliterator.FORWARD } else { direction }
                    return [TransliteratorRegistry_LocaleEntry(subres[Int64(i + 1)], dir)]
                }
            } catch (e: MissingResourceException) {
                if (DEBUG) {
                    println("missing resource: " + toString(e))
                }
            }
            pass++
        }
        return None
    }

    private func find(ID: String): Array<Object> {
        let stv = TransliteratorIDParser.IDtoSTV(ID)
        return find(stv[0], stv[1], stv[2])
    }

    private func find(source: String, target: String, variant: String): Array<Object> {
        let src = TransliteratorRegistry_Spec(source)
        let trg = TransliteratorRegistry_Spec(target)
        var entry: Array<Object>
        if (Int32(variant.size) != 0) {
            entry = findInDynamicStore(src, trg, variant)
            if (entry.isSome()) {
                return entry
            }
            entry = findInStaticStore(src, trg, variant)
            if (entry.isSome()) {
                return entry
            }
        }
        while (true) {
            src.reset()
            while (true) {
                entry = findInDynamicStore(src, trg, NO_VARIANT)
                if (entry.isSome()) {
                    return entry
                }
                entry = findInStaticStore(src, trg, NO_VARIANT)
                if (entry.isSome()) {
                    return entry
                }
                if (!src.hasFallback()) {
                    break
                }
                src.next()
            }
            if (!trg.hasFallback()) {
                break
            }
            trg.next()
        }
        return None
    }

    private func instantiateEntry(ID: String, entryWrapper: Array<Object>, aliasReturn: StringBuffer): Transliterator {
        while (true) {
            let entry = entryWrapper[0]
            if (checkOptionalIs<RuleBasedTransliterator_Data, Object>(entry)) {
                let data = entry
                return RuleBasedTransliterator(ID, data, None)
            } else if (checkOptionalIs<ClassTypeInfo, Object>(entry)) {
                try {
                    return entry.construct([0]) as Transliterator
                } catch (e: InstantiationException) { } catch (e2: IllegalAccessException) { }
                return None
            } else if (checkOptionalIs<TransliteratorRegistry_AliasEntry, Object>(entry)) {
                aliasReturn.append(entry.alias)
                return None
            } else if (checkOptionalIs<Transliterator_Factory, Object>(entry)) {
                return entry.getInstance(ID)
            } else if (checkOptionalIs<TransliteratorRegistry_CompoundRBTEntry, Object>(entry)) {
                return entry.getInstance()
            } else if (checkOptionalIs<AnyTransliterator, Object>(entry)) {
                let temp = entry
                return temp.safeClone()
            } else if (checkOptionalIs<RuleBasedTransliterator, Object>(entry)) {
                let temp = entry
                return temp.safeClone()
            } else if (checkOptionalIs<CompoundTransliterator, Object>(entry)) {
                let temp = entry
                return temp.safeClone()
            } else if (checkOptionalIs<Transliterator, Object>(entry)) {
                return entry
            }
            let parser = TransliteratorParser()
            try {
                let re = entry
                parser.parse(re.resource, re.direction)
            } catch (e: ClassCastException) {
                let le = entry
                parser.parse(le.rule, le.direction)
            }
            if (Int32(parser.idBlockVector.size) == 0 && Int32(parser.dataVector.size) == 0) {
                entryWrapper[0] = TransliteratorRegistry_AliasEntry(NullTransliterator._ID)
            } else if (Int32(parser.idBlockVector.size) == 0 && Int32(parser.dataVector.size) == 1) {
                entryWrapper[0] = parser.dataVector[0]
            } else if (Int32(parser.idBlockVector.size) == 1 && Int32(parser.dataVector.size) == 0) {
                if (parser.compoundFilter.isSome()) {
                    entryWrapper[0] = TransliteratorRegistry_AliasEntry((parser.compoundFilter.toPattern(false)) + ";" + (parser.idBlockVector[0]))
                } else {
                    entryWrapper[0] = TransliteratorRegistry_AliasEntry(parser.idBlockVector[0])
                }
            } else {
                entryWrapper[0] = TransliteratorRegistry_CompoundRBTEntry(ID, parser.idBlockVector, parser.dataVector, parser.compoundFilter)
            }
        }
    }
}


class TransliteratorRegistry_Spec {
    private var top: String

    private var spec: String

    private var nextSpec: String

    private var scriptName: String

    private var isSpecLocale: Bool = false

    private var isNextLocale: Bool = false

    private var res: ICUResourceBundle

    public init(theSpec: String) {
        top = theSpec
        spec = None
        scriptName = None
        try {
            let script = UScript.getCodeFromName(top)
            let s = UScript.getCode(top)
            if (s.isSome()) {
                scriptName = UScript.getName(s[0])
                if (scriptName.equalsIgnoreCase(top)) {
                    scriptName = None
                }
            }
            isSpecLocale = false
            res = None
            if (script == UScript.INVALID_CODE) {
                let toploc = LocaleUtility.getLocaleFromName(top)
                res = UResourceBundle.getBundleInstance(ICUData.ICU_TRANSLIT_BASE_NAME, toploc)
                if (res.isSome() && LocaleUtility.isFallbackOf(res.getULocale().toString(), top)) {
                    isSpecLocale = true
                }
            }
        } catch (e: MissingResourceException) {
            scriptName = None
        }
        reset()
    }

    public func hasFallback(): Bool {
        return nextSpec.isSome()
    }

    public func reset(): Unit {
        if (!Utility.sameObjects(spec, top)) {
            spec = top
            isSpecLocale = (res.isSome())
            setupNext()
        }
    }

    private func setupNext(): Unit {
        isNextLocale = false
        if (isSpecLocale) {
            nextSpec = spec
            let i = indexOfWrap(nextSpec.lastIndexOf(UInt8(UInt32(TransliteratorRegistry.LOCALE_SEP))))
            if (i > 0) {
                nextSpec = spec[0..Int64(i)]
                isNextLocale = true
            } else {
                nextSpec = scriptName
            }
        } else {
            if (!Utility.sameObjects(nextSpec, scriptName)) {
                nextSpec = scriptName
            } else {
                nextSpec = None
            }
        }
    }

    public func next(): String {
        spec = nextSpec
        isSpecLocale = isNextLocale
        setupNext()
        return spec
    }

    public func get(): String {
        return spec
    }

    public func isLocale(): Bool {
        return isSpecLocale
    }

    public func getBundle(): ResourceBundle {
        if (res.isSome() && res.getULocale().toString().equals(spec)) {
            return res
        }
        return None
    }

    public func getTop(): String {
        return top
    }
}


class TransliteratorRegistry_ResourceEntry {
    public var resource: String

    public var direction: Int32 = 0

    public init(n: String, d: Int32) {
        resource = n
        direction = d
    }
}


class TransliteratorRegistry_LocaleEntry {
    public var rule: String

    public var direction: Int32 = 0

    public init(r: String, d: Int32) {
        rule = r
        direction = d
    }
}


class TransliteratorRegistry_AliasEntry {
    public var alias: String

    public init(a: String) {
        alias = a
    }
}


class TransliteratorRegistry_CompoundRBTEntry {
    private var ID: String

    private var idBlockVector: ArrayList<String>

    private var dataVector: ArrayList<RuleBasedTransliterator_Data>

    private var compoundFilter: UnicodeSet

    public init(theID: String, theIDBlockVector: ArrayList<String>, theDataVector: ArrayList<RuleBasedTransliterator_Data>, theCompoundFilter: UnicodeSet) {
        ID = theID
        idBlockVector = theIDBlockVector
        dataVector = theDataVector
        compoundFilter = theCompoundFilter
    }

    public func getInstance(): Transliterator {
        let transliterators = ArrayList<Transliterator>()
        var passNumber = 1
        let limit = Int32(max(idBlockVector.size, dataVector.size))
        var i = 0
        while (i < limit) {
            if (i < Int32(idBlockVector.size)) {
                let idBlock = idBlockVector[Int64(i)]
                if (Int32(idBlock.size) > 0) {
                    transliterators.append(Transliterator.getInstance(idBlock))
                }
            }
            if (i < Int32(dataVector.size)) {
                let data = dataVector[Int64(i)]
                transliterators.append(RuleBasedTransliterator("%Pass" + (match (0) { case _ => passNumber++; passNumber - 1 }).toString(), data, None))
            }
            i++
        }
        let t: Transliterator = CompoundTransliterator(transliterators, passNumber - 1)
        t.setID(ID)
        if (compoundFilter.isSome()) {
            t.setFilter(compoundFilter)
        }
        return t
    }
}


class TransliteratorRegistry_IDEnumeration <: Enumeration<String> {
    var en: Enumeration<CaseInsensitiveString>

    public init(e: Enumeration<CaseInsensitiveString>) {
        en = e
    }

    public override func hasMoreElements(): Bool {
        return en.isSome() && en.hasMoreElements()
    }

    public override func nextElement(): String {
        return (en.nextElement()).getString()
    }
}
