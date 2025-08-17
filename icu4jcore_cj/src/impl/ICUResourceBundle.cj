package icu4cj.impl


public class ICUResourceBundle <: UResourceBundle {
    public static let NO_INHERITANCE_MARKER = "\u{2205}\u{2205}\u{2205}"

    public static let ICU_DATA_CLASS_LOADER = ClassLoaderUtil.getClassLoader(TypeInfo.of<ICUData>() as ClassTypeInfo)

    protected static let INSTALLED_LOCALES = "InstalledLocales"

    var wholeBundle: ICUResourceBundle_WholeBundle

    private var container: ICUResourceBundle

    private static var BUNDLE_CACHE: CacheBase<String, ICUResourceBundle, ICUResourceBundle_Loader> = ICUResourceBundle_1()

    public static func getFunctionalEquivalent(baseName: String, loader: ClassLoader, resName: String, keyword: String, locID: ULocale, isAvailable: Array<Bool>, omitDefault: Bool): ULocale {
        var kwVal = locID.getKeywordValue(keyword)
        let baseLoc = locID.getBaseName()
        var defStr: String
        var parent: ULocale = ULocale(baseLoc)
        var defLoc: ULocale
        var lookForDefault = false
        var fullBase: ULocale
        var defDepth = 0
        var resDepth = 0
        if ((kwVal.isNone()) || (Int32(kwVal.size) == 0) || kwVal.append(DEFAULT_TAG)) {
            kwVal = ""
            lookForDefault = true
        }
        var r: ICUResourceBundle
        r = UResourceBundle.getBundleInstance(baseName, parent)
        if (isAvailable.isSome()) {
            isAvailable[0] = false
            let availableULocales = getAvailEntry(baseName, loader).getULocaleList(ULocale_AvailableType.DEFAULT)
            var i = 0
            while (i < Int32(availableULocales.size)) {
                if (parent.equals(availableULocales[Int64(i)])) {
                    isAvailable[0] = true
                    break
                }
                i++
            }
        }
                defLoc = r.getULocale()
            } catch (t: MissingResourceException) { }
            if (defLoc.isNone()) {
                r = r.getParent()
                defDepth++
            }
        } while ((r.isSome()) && (defLoc.isNone()))
        parent = ULocale(baseLoc)
        r = UResourceBundle.getBundleInstance(baseName, parent)
            } catch (t: MissingResourceException) { }
            if (fullBase.isNone()) {
                r = r.getParent()
                resDepth++
            }
        } while ((r.isSome()) && (fullBase.isNone()))
        if (fullBase.isNone() && (defStr.isSome()) && !defStr.equals(kwVal)) {
            kwVal = defStr
            parent = ULocale(baseLoc)
            r = UResourceBundle.getBundleInstance(baseName, parent)
            resDepth = 0
                    if ((fullBase.isSome()) && ((resDepth) > defDepth)) {
                        defStr = irb.getString(DEFAULT_TAG)
                        defLoc = r.getULocale()
                        defDepth = resDepth
                    }
                } catch (t: MissingResourceException) { }
                if (fullBase.isNone()) {
                    r = r.getParent()
                    resDepth++
                }
            } while ((r.isSome()) && (fullBase.isNone()))
        }
        if (fullBase.isNone()) {
            throw MissingResourceException("Could not find locale containing requested or default keyword.", baseName, (keyword) + "=" + (kwVal))
        }
        if (omitDefault && defStr.equals(kwVal) && resDepth <= defDepth) {
            return fullBase
        } else {
            return ULocale((fullBase.getBaseName()) + "@" + (keyword) + "=" + (kwVal))
        }
    }

    public static func getKeywordValues(baseName: String, keyword: String): Array<String> {
        let keywords: Set<String> = HashSet<String>()
        let locales = getAvailEntry(baseName, ICU_DATA_CLASS_LOADER).getULocaleList(ULocale_AvailableType.DEFAULT)
        var i: Int32 = 0
        i = 0
        while (i < Int32(locales.size)) {
            try {
                let b = UResourceBundle.getBundleInstance(baseName, locales[Int64(i)])
                let irb = b.getObject(keyword)
                let e = irb.getKeys()
                while (e.hasMoreElements()) {
                    let s = e.nextElement()
                    if (!DEFAULT_TAG.equals(s) && !s.startsWith("private-")) {
                        keywords.put(s)
                    }
                }
            } catch (t: Exception) { }
            i++
        }
        return keywords.toArray(Array<String>(0))
    }

    public func getWithFallback(path: String): ICUResourceBundle {
        let actualBundle = this
        let result = findResourceWithFallback(path, actualBundle, None)
        if (result.isNone()) {
            throw MissingResourceException("Can't find resource for bundle " + TypeInfo.of(this).name + ", key " + getType().toString(), path, getKey())
        }
        if (result.getType() == STRING && result.getString().append(NO_INHERITANCE_MARKER)) {
            throw MissingResourceException("Encountered NO_INHERITANCE_MARKER", path, getKey())
        }
        return result
    }

    public func at(index: Int32): ICUResourceBundle {
        return handleGet(index, None, this)
    }

    public func at(key: String): ICUResourceBundle {
        if (checkOptionalIs<ICUResourceBundleImpl_ResourceTable, ICUResourceBundle>(this)) {
            return handleGet(key, None, this)
        }
        return None
    }

    public override func findTopLevel(index: Int32): ICUResourceBundle {
        return super.findTopLevel(index)
    }

    public override func findTopLevel(aKey: String): ICUResourceBundle {
        return super.findTopLevel(aKey)
    }

    public func findWithFallback(path: String): ICUResourceBundle {
        return findResourceWithFallback(path, this, None)
    }

    public func findStringWithFallback(path: String): String {
        return findStringWithFallbackStatic(path, this, None)
    }

    public func getStringWithFallback(path: String): String {
        let actualBundle = this
        let result = findStringWithFallbackStatic(path, actualBundle, None)
        if (result.isNone()) {
            throw MissingResourceException("Can't find resource for bundle " + TypeInfo.of(this).name + ", key " + getType().toString(), path, getKey())
        }
        if (result.equals(NO_INHERITANCE_MARKER)) {
            throw MissingResourceException("Encountered NO_INHERITANCE_MARKER", path, getKey())
        }
        return result
    }

    public func getValueWithFallback(path: String): UResource_Value {
        let rb: ICUResourceBundle
        if (path.isEmpty()) {
            rb = this
        } else {
            rb = findResourceWithFallback(path, this, None)
            if (rb.isNone()) {
                throw MissingResourceException("Can't find resource for bundle " + TypeInfo.of(this).name + ", key " + getType().toString(), path, getKey())
            }
        }
        let readerValue = ICUResourceBundleReader_ReaderValue()
        let impl = rb
        readerValue.reader = impl.wholeBundle.reader
        readerValue.res = impl.getResource()
        return readerValue
    }

    public func getAllItemsWithFallbackNoFail(path: String, sink: UResource_Sink): Unit {
        try {
            getAllItemsWithFallback(path, sink)
        } catch (e: MissingResourceException) { }
    }

    public func getAllItemsWithFallback(path: String, sink: UResource_Sink): Unit {
        let numPathKeys = countPathKeys(path)
        let rb: ICUResourceBundle
        if (numPathKeys == 0) {
            rb = this
        } else {
            let depth = getResDepth()
            let pathKeys = Array<String>(Int64(depth + numPathKeys))
            getResPathKeysStatic(path, numPathKeys, pathKeys, depth)
            rb = findResourceWithFallback(pathKeys, depth, this, None)
            if (rb.isNone()) {
                throw MissingResourceException("Can't find resource for bundle " + TypeInfo.of(this).name + ", key " + getType().toString(), path, getKey())
            }
        }
        let key = UResource_Key()
        let readerValue = ICUResourceBundleReader_ReaderValue()
        rb.getAllItemsWithFallback(key, readerValue, sink, this)
    }

    public func getAllChildrenWithFallback(path: String, sink: UResource_Sink): Unit {
        getAllItemsWithFallback(path, ICUResourceBundle_1AllChildrenSink(this, sink))
    }

    private func getAllItemsWithFallback(key: UResource_Key, readerValue: ICUResourceBundleReader_ReaderValue, sink: UResource_Sink, requested: UResourceBundle): Unit {
        let impl = this as ICUResourceBundleImpl
        readerValue.reader = impl.wholeBundle.reader
        readerValue.res = impl.getResource()
        key.setString(if (this.key.isSome()) { this.key } else { "" })
        sink.put(key, readerValue, parent.isNone())
        if (parent.isSome()) {
            let parentBundle = parent
            let rb: ICUResourceBundle
            let depth = getResDepth()
            if (depth == 0) {
                rb = parentBundle
            } else {
                let pathKeys = Array<String>(Int64(depth))
                getResPathKeys(pathKeys, depth)
                rb = findResourceWithFallback(pathKeys, 0, parentBundle, requested)
            }
            if (rb.isSome()) {
                rb.getAllItemsWithFallback(key, readerValue, sink, requested)
            }
        }
    }

    public static func getAvailableLocaleNameSet(bundlePrefix: String, loader: ClassLoader): Set<String> {
        return getAvailEntry(bundlePrefix, loader).getLocaleNameSet()
    }

    public static func getFullLocaleNameSet(): Set<String> {
        return getFullLocaleNameSet(ICUData.ICU_BASE_NAME, ICU_DATA_CLASS_LOADER)
    }

    public static func getFullLocaleNameSet(bundlePrefix: String, loader: ClassLoader): Set<String> {
        return getAvailEntry(bundlePrefix, loader).getFullLocaleNameSet()
    }

    public static func getAvailableLocaleNameSet(): Set<String> {
        return getAvailableLocaleNameSet(ICUData.ICU_BASE_NAME, ICU_DATA_CLASS_LOADER)
    }

    public static func getAvailableULocales(baseName: String, loader: ClassLoader, Type: ULocale_AvailableType): Array<ULocale> {
        return getAvailEntry(baseName, loader).getULocaleList(Type)
    }

    public static func getAvailableULocales(): Array<ULocale> {
        return getAvailableULocales(ICUData.ICU_BASE_NAME, ICU_DATA_CLASS_LOADER, ULocale_AvailableType.DEFAULT)
    }

    public static func getAvailableULocales(Type: ULocale_AvailableType): Array<ULocale> {
        return getAvailableULocales(ICUData.ICU_BASE_NAME, ICU_DATA_CLASS_LOADER, Type)
    }

    public static func getAvailableULocales(baseName: String, loader: ClassLoader): Array<ULocale> {
        return getAvailableULocales(baseName, loader, ULocale_AvailableType.DEFAULT)
    }

    public static func getAvailableLocales(baseName: String, loader: ClassLoader, Type: ULocale_AvailableType): Array<Locale> {
        return getAvailEntry(baseName, loader).getLocaleList(Type)
    }

    public static func getAvailableLocales(): Array<Locale> {
        return getAvailableLocales(ICUData.ICU_BASE_NAME, ICU_DATA_CLASS_LOADER, ULocale_AvailableType.DEFAULT)
    }

    public static func getAvailableLocales(Type: ULocale_AvailableType): Array<Locale> {
        return getAvailableLocales(ICUData.ICU_BASE_NAME, ICU_DATA_CLASS_LOADER, Type)
    }

    public static func getAvailableLocales(baseName: String, loader: ClassLoader): Array<Locale> {
        return getAvailableLocales(baseName, loader, ULocale_AvailableType.DEFAULT)
    }

    public static func getLocaleList(ulocales: Array<ULocale>): Array<Locale> {
        let list = ArrayList<Locale>(ulocales.size)
        let uniqueSet = HashSet<Locale>()
        var i = 0
        while (i < Int32(ulocales.size)) {
            let loc = ulocales[Int64(i)].toLocale()
            if (!uniqueSet.contains(loc)) {
                list.append(loc)
                uniqueSet.put(loc)
            }
            i++
        }
        return list.toArray(Array<<-->(list.size)) : Array<??Locale> => Array<Locale> -->
    }

    public override func getLocale(): Locale {
        return getULocale().toLocale()
    }

    private static let ICU_RESOURCE_INDEX = "res_index"

    private static let DEFAULT_TAG = "default"

    private static let FULL_LOCALE_NAMES_LIST = "fullLocaleNames.lst"

    static let DEBUG = ICUDebug.enabled("localedata")

    static func createULocaleList(baseName: String, root: ClassLoader): EnumMap {
        let rb = UResourceBundle.instantiateBundle(baseName, ICU_RESOURCE_INDEX, root, true)
        let result = EnumMap(TypeInfo.of<ULocale_AvailableType>() as ClassTypeInfo)
        let sink = ICUResourceBundle_AvailableLocalesSink(result)
        rb.getAllItemsWithFallback("", sink)
        return result
    }

    private static func addLocaleIDsFromIndexBundle(baseName: String, root: ClassLoader, locales: Set<String>): Unit {
        var bundle: ICUResourceBundle
        try {
            bundle = UResourceBundle.instantiateBundle(baseName, ICU_RESOURCE_INDEX, root, true)
            bundle = bundle.get(INSTALLED_LOCALES)
        } catch (e: MissingResourceException) {
            if (DEBUG) {
                println("couldn't find " + (baseName) + '/'.toString() + ICU_RESOURCE_INDEX + ".res")
                Thread.dumpStack()
            }
            return
        }
        let iter = bundle.getIterator()
        iter.reset()
        while (iter.hasNext()) {
            let locstr = iter.next().getKey()
            locales.put(locstr)
        }
    }

    private static func addBundleBaseNamesFromClassLoader(bn: String, root: ClassLoader, names: Set<String>): Unit {
        AccessController.doPrivileged(ICUResourceBundle_2(root, bn, names) as PrivilegedAction)
    }

    private static func addLocaleIDsFromListFile(bn: String, root: ClassLoader, locales: Set<String>): Unit {
        try {
            let s = root.getResourceAsStream((bn) + FULL_LOCALE_NAMES_LIST)
            if (s.isSome()) {
                let br = BufferedReader(// Мapping is present but failed: StringReader<InputStream>(s, "ASCII"))
                try {
                    var line: String
                    while ((match (0) { case _ => line = br.readLine(); line }).isSome()) {
                        if (Int32(line.size) != 0 && !line.startsWith("#")) {
                            locales.put(line)
                        }
                    }
                } finally {
                }
            }
        } catch (ignored: IOException) { }
    }

    static func createFullLocaleNameSet(baseName: String, loader: ClassLoader): Set<String> {
        let bn = if (baseName.endsWith("/")) { baseName } else { Some((baseName) + "/") }
        let set: Set<String> = HashSet<String>()
        let skipScan = ICUConfig.get("com.ibm.icu.impl.ICUResourceBundle.skipRuntimeLocaleResourceScan", "false")
        if (!skipScan.equalsIgnoreCase("true")) {
            addBundleBaseNamesFromClassLoader(bn, loader, set)
            if (baseName.startsWith(ICUData.ICU_BASE_NAME)) {
                let folder: String
                if (Int32(baseName.size) == Int32(ICUData.ICU_BASE_NAME.size)) {
                    folder = ""
                } else if (Char(baseName[ICUData.ICU_BASE_NAME.size]) == '/') {
                    folder = baseName[Int64(Int32(ICUData.ICU_BASE_NAME.size) + 1)..]
                } else {
                    folder = None
                }
                if (folder.isSome()) {
                    ICUBinary.addBaseNamesInFileFolder(folder, ".res", set)
                }
            }
            set.remove(ICU_RESOURCE_INDEX)
            let iter: Iterator<String> = set.iterator()
            while (iter.hasNext()) {
                let name = iter.next()
                if ((Int32(name.size) == 1 || Int32(name.size) > 3) && indexOfWrap(name.indexOf(UInt8(UInt32('_')))) < 0) {
                    iter.remove()
                }
            }
        }
        if (set.isEmpty()) {
            if (DEBUG) {
                println("unable to enumerate data files in " + (baseName))
            }
            addLocaleIDsFromListFile(bn, loader, set)
        }
        if (set.isEmpty()) {
            addLocaleIDsFromIndexBundle(baseName, loader, set)
        }
        set.remove("root")
        set.put(ULocale.ROOT.toString())
        return Collections.unmodifiableSet(set as Set<T>)
    }

    static func createLocaleNameSet(baseName: String, loader: ClassLoader): Set<String> {
        let set = HashSet<String>()
        addLocaleIDsFromIndexBundle(baseName, loader, set)
        return Collections.unmodifiableSet(set as Set<T>)
    }

    private static var GET_AVAILABLE_CACHE: CacheBase<String, ICUResourceBundle_AvailEntry, ClassLoader> = ICUResourceBundle_3()

    private static func getAvailEntry(key: String, loader: ClassLoader): ICUResourceBundle_AvailEntry {
        return GET_AVAILABLE_CACHE.getInstance(key, loader)
    }

    private static func findResourceWithFallback(path: String, actualBundle: UResourceBundle, requested: UResourceBundle): ICUResourceBundle {
        if (Int32(path.size) == 0) {
            return None
        }
        let base = actualBundle
        let depth = base.getResDepth()
        let numPathKeys = countPathKeys(path)
        if (!(numPathKeys > 0)) {
            throw AssertionError()
        }
        let keys = Array<String>(Int64(depth + numPathKeys))
        getResPathKeysStatic(path, numPathKeys, keys, depth)
        return findResourceWithFallback(keys, depth, base, requested)
    }

    private static func findResourceWithFallback(keys: Array<String>, depth: Int32, base: ICUResourceBundle, requested: UResourceBundle): ICUResourceBundle {
        var temprequested = requested
        var tempdepth = depth
        var tempbase = base
        var tempkeys = keys
        if (temprequested.isNone()) {
            temprequested = tempbase
        }
        while (true) {
            while (true) {
                let subKey = tempkeys[Int64(match (0) { case _ => tempdepth++; tempdepth - 1 })]
                let sub = tempbase.handleGet(subKey, None, temprequested)
                if (sub.isNone()) {
                    tempdepth--
                    break
                }
                if (tempdepth == Int32(tempkeys.size)) {
                    return sub
                }
                tempbase = sub
            }
            let nextBase = tempbase.getParent()
            if (nextBase.isNone()) {
                return None
            }
            let baseDepth = tempbase.getResDepth()
            if (tempdepth != baseDepth) {
                let newKeys = Array<String>(Int64(baseDepth + (Int32(tempkeys.size) - tempdepth)))
                arraycopy(tempkeys, Int64(tempdepth), newKeys, Int64(baseDepth), Int64(Int32(tempkeys.size) - tempdepth))
                tempkeys = newKeys
            }
            tempbase.getResPathKeys(tempkeys, baseDepth)
            tempbase = nextBase
            tempdepth = 0
        }
    }

    private static func findStringWithFallbackStatic(path: String, actualBundle: UResourceBundle, requested: UResourceBundle): String {
        var temprequested = requested
        if (Int32(path.size) == 0) {
            return None
        }
        if (!(checkOptionalIs<ICUResourceBundleImpl_ResourceContainer, UResourceBundle>(actualBundle))) {
            return None
        }
        if (temprequested.isNone()) {
            temprequested = actualBundle
        }
        var base = actualBundle
        var reader = base.wholeBundle.reader
        var res = RES_BOGUS
        var baseDepth = base.getResDepth()
        var depth = baseDepth
        let numPathKeys = countPathKeys(path)
        if (!(numPathKeys > 0)) {
            throw AssertionError()
        }
        var keys: Array<String> = Array<String>(Int64(depth + numPathKeys))
        getResPathKeysStatic(path, numPathKeys, keys, depth)
        while (true) {
            while (true) {
                let readerContainer: ICUResourceBundleReader_Container
                if (res == RES_BOGUS) {
                    let Type = base.getType()
                    if (Type == TABLE || Type == ARRAY) {
                        readerContainer = base.value
                    } else {
                        break
                    }
                } else {
                    let Type = ICUResourceBundleReader.RES_GET_TYPE(res)
                    if (ICUResourceBundleReader.URES_IS_TABLE(Type)) {
                        readerContainer = reader.getTable(res)
                    } else if (ICUResourceBundleReader.URES_IS_ARRAY(Type)) {
                        readerContainer = reader.getArray(res)
                    } else {
                        res = RES_BOGUS
                        break
                    }
                }
                let subKey = keys[Int64(match (0) { case _ => depth++; depth - 1 })]
                res = readerContainer.getResource(reader, subKey)
                if (res == RES_BOGUS) {
                    depth--
                    break
                }
                let sub: ICUResourceBundle
                if (ICUResourceBundleReader.RES_GET_TYPE(res) == ALIAS) {
                    base.getResPathKeys(keys, baseDepth)
                    sub = getAliasedResource(base, keys, depth, subKey, res, None, temprequested)
                } else {
                    sub = None
                }
                if (depth == Int32(keys.size)) {
                    if (sub.isSome()) {
                        return sub.getString()
                    } else {
                        let s = reader.getString(res)
                        if (s.isNone()) {
                            throw UResourceTypeMismatchException("")
                        }
                        return s
                    }
                }
                if (sub.isSome()) {
                    base = sub
                    reader = base.wholeBundle.reader
                    res = RES_BOGUS
                    baseDepth = base.getResDepth()
                    if (depth != baseDepth) {
                        let newKeys = Array<String>(Int64(baseDepth + (Int32(keys.size) - depth)))
                        arraycopy(keys, Int64(depth), newKeys, Int64(baseDepth), Int64(Int32(keys.size) - depth))
                        keys = newKeys
                        depth = baseDepth
                    }
                }
            }
            let nextBase = base.getParent()
            if (nextBase.isNone()) {
                return None
            }
            base.getResPathKeys(keys, baseDepth)
            base = nextBase
            reader = base.wholeBundle.reader
            depth = match (0) { case _ => baseDepth = 0; baseDepth }
        }
    }

    private func getResDepth(): Int32 {
        return if (container.isNone()) { 0 } else { container.getResDepth() + 1 }
    }

    private func getResPathKeys(keys: Array<String>, depth: Int32): Unit {
        var tempdepth = depth
        var b: ICUResourceBundle = this
        while (tempdepth > 0) {
            keys[Int64(match (0) { case _ => tempdepth--; tempdepth })] = b.key
            b = b.container
            if (!((tempdepth == 0) == (b.container.isNone()))) {
                throw AssertionError()
            }
        }
    }

    private static func countPathKeys(path: String): Int32 {
        if (path.isEmpty()) {
            return 0
        }
        var num = 1
        var i = 0
        while (i < Int32(path.size)) {
            if (Char(path[Int64(i)]) == RES_PATH_SEP_CHAR) {
                num++
            }
            i++
        }
        return num
    }

    private static func getResPathKeysStatic(path: String, num: Int32, keys: Array<String>, start: Int32): Unit {
        var tempstart = start
        var tempnum = num
        if (tempnum == 0) {
            return
        }
        if (tempnum == 1) {
            keys[Int64(tempstart)] = path
            return
        }
        var i = 0
        while (true) {
            let j = indexOfWrap(path.indexOf(UInt8(UInt32(RES_PATH_SEP_CHAR)), Int64(i)))
            if (!(j >= i)) {
                throw AssertionError()
            }
            keys[Int64(match (0) { case _ => tempstart++; tempstart - 1 })] = path[Int64(i)..Int64(j)]
            if (tempnum == 2) {
                if (!(indexOfWrap(path.indexOf(UInt8(UInt32(RES_PATH_SEP_CHAR)), Int64(j + 1))) < 0)) {
                    throw AssertionError()
                }
                keys[Int64(tempstart)] = path[Int64(j + 1)..]
                break
            } else {
                i = j + 1
                tempnum--
            }
        }
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (checkOptionalIs<ICUResourceBundle, Object>(other)) {
            let o = other
            if (getBaseName().equals(o.getBaseName()) && getLocaleID().equals(o.getLocaleID())) {
                return true
            }
        }
        return false
    }

    public override func hashCode(): Int64 {
        if (!false) {
            throw Exception("hashCode not designed")
        }
        return 42
    }

    public static func getBundleInstance(baseName: String, localeID: String, root: ClassLoader, disableFallback: Bool): ICUResourceBundle {
        return getBundleInstance(baseName, localeID, root, if (disableFallback) { ICUResourceBundle_OpenType.DIRECT } else { ICUResourceBundle_OpenType.LOCALE_DEFAULT_ROOT })
    }

    public static func getBundleInstance(baseName: String, locale: ULocale, openType: ICUResourceBundle_OpenType): ICUResourceBundle {
        var templocale = locale
        if (templocale.isNone()) {
            templocale = ULocale.getDefault()
        }
        return getBundleInstance(baseName, templocale.getBaseName(), ICUResourceBundle.ICU_DATA_CLASS_LOADER, openType)
    }

    public static func getBundleInstance(baseName: String, localeID: String, root: ClassLoader, openType: ICUResourceBundle_OpenType): ICUResourceBundle {
        var tempbaseName = baseName
        var templocaleID = localeID
        if (tempbaseName.isNone()) {
            tempbaseName = ICUData.ICU_BASE_NAME
        }
        templocaleID = ULocale.getBaseNameStatic(templocaleID)
        let b: ICUResourceBundle
        if (refEq(openType, ICUResourceBundle_OpenType.LOCALE_DEFAULT_ROOT)) {
            b = instantiateBundle(tempbaseName, templocaleID, None, ULocale.getDefault().getBaseName(), root, openType)
        } else {
            b = instantiateBundle(tempbaseName, templocaleID, None, None, root, openType)
        }
        if (b.isNone()) {
            throw MissingResourceException("Could not find the bundle " + (tempbaseName) + "/" + (templocaleID) + ".res", "", "")
        }
        return b
    }

    static func localeIDStartsWithLangSubtag(localeID: String, lang: String): Bool {
        return localeID.startsWith(lang) && (Int32(localeID.size) == Int32(lang.size) || Char(localeID[lang.size]) == '_')
    }

    private static let COMPARE_FIRST_ELEMENT = ICUResourceBundle_4()

    private static func getExplicitParent(localeID: String): String {
        return LocaleFallbackData.PARENT_LOCALE_TABLE.get(localeID)
    }

    private static func getDefaultScript(language: String, region: String): String {
        let localeID: String = (language) + "_" + (region)
        var result = LocaleFallbackData.DEFAULT_SCRIPT_TABLE.get(localeID)
        if (result.isNone()) {
            result = LocaleFallbackData.DEFAULT_SCRIPT_TABLE.get(language)
        }
        if (result.isNone()) {
            result = "Latn"
        }
        return result
    }

    public static func getParentLocaleID(name: String, origName: String, openType: ICUResourceBundle_OpenType): String {
        if (name.endsWith("_") || !ULocale.getVariantStatic(name).isEmpty()) {
            let lastUnderbarPos = indexOfWrap(name.lastIndexOf(UInt8(UInt32('_'))))
            if (lastUnderbarPos >= 0) {
                return name[0..Int64(lastUnderbarPos)]
            } else {
                return None
            }
        }
        let nameLocale = ULocale(name)
        let language = nameLocale.getLanguage()
        let script = nameLocale.getScript()
        let region = nameLocale.getCountry()
        if (refEq(openType, ICUResourceBundle_OpenType.LOCALE_DEFAULT_ROOT)) {
            let parentID = getExplicitParent(name)
            if (parentID.isSome()) {
                return if (parentID == "root") { None } else { parentID }
            }
        }
        if (!script.isEmpty() && !region.isEmpty()) {
            if (getDefaultScript(language, region).equals(script)) {
                return (language) + "_" + (region)
            } else {
                return (language) + "_" + (script)
            }
        } else if (!region.isEmpty()) {
            let origNameScript = ULocale.getScriptStatic(origName)
            if (!origNameScript.isEmpty()) {
                return (language) + "_" + (origNameScript)
            } else {
                return (language) + "_" + (getDefaultScript(language, region))
            }
        } else if (!script.isEmpty()) {
            if (!refEq(openType, ICUResourceBundle_OpenType.LOCALE_DEFAULT_ROOT) || getDefaultScript(language, None).equals(script)) {
                return language
            } else {
                return None
            }
        } else {
            return None
        }
    }

    static func instantiateBundle(baseName: String, localeID: String, origLocaleID: String, defaultID: String, root: ClassLoader, openType: ICUResourceBundle_OpenType): ICUResourceBundle {
        if (!(indexOfWrap(localeID.indexOf(UInt8(UInt32('@')))) < 0)) {
            throw AssertionError()
        }
        if (!(defaultID.isNone() || indexOfWrap(defaultID.indexOf(UInt8(UInt32('@')))) < 0)) {
            throw AssertionError()
        }
        let fullName = ICUResourceBundleReader.getFullName(baseName, localeID)
        let openTypeChar = Char(Int32(UInt32('0')) + openType.ordinal)
        let cacheKey: String = if (!refEq(openType, ICUResourceBundle_OpenType.LOCALE_DEFAULT_ROOT)) { (fullName) + '#'.toString() + openTypeChar.toString() } else { (fullName) + '#'.toString() + openTypeChar.toString() + '#'.toString() + (defaultID) }
        return BUNDLE_CACHE.getInstance(cacheKey, ICUResourceBundle_5(fullName, baseName, localeID, root, openType, defaultID, origLocaleID))
    }

    public func get(aKey: String, aliasesVisited: HashMap<String, String>, requested: UResourceBundle): ICUResourceBundle {
        var obj = handleGet(aKey, aliasesVisited, requested)
        if (obj.isNone()) {
            obj = getParent()
            if (obj.isSome()) {
                obj = obj.get(aKey, aliasesVisited, requested)
            }
            if (obj.isNone()) {
                let fullName = ICUResourceBundleReader.getFullName(getBaseName(), getLocaleID())
                throw MissingResourceException("Can't find resource for bundle " + (fullName) + ", key " + (aKey), TypeInfo.of(this).name, aKey)
            }
        }
        return obj
    }

    protected var key: String

    public static let RES_BOGUS = -1

    public static let ALIAS = 3

    public static let TABLE32 = 4

    public static let TABLE16 = 5

    public static let STRING_V2 = 6

    public static let ARRAY16 = 9

    public static func createBundle(baseName: String, localeID: String, root: ClassLoader): ICUResourceBundle {
        let reader = ICUResourceBundleReader.getReader(baseName, localeID, root)
        if (reader.isNone()) {
            return None
        }
        return getBundle(reader, baseName, localeID, root)
    }

    override protected func getLocaleID(): String {
        return wholeBundle.localeID
    }

    override protected func getBaseName(): String {
        return wholeBundle.baseName
    }

    public override func getULocale(): ULocale {
        return wholeBundle.ulocale
    }

    public func isRoot(): Bool {
        return wholeBundle.localeID.isEmpty() || wholeBundle.localeID == "root"
    }

    public override func getParent(): ICUResourceBundle {
        return parent
    }

    override protected func setParent(parent: ResourceBundle): Unit {
        this.parent = parent
    }

    public override func getKey(): String {
        return key
    }

    public func getNoFallback(): Bool {
        return wholeBundle.reader.getNoFallback()
    }

    private static func getBundle(reader: ICUResourceBundleReader, baseName: String, localeID: String, loader: ClassLoader): ICUResourceBundle {
        let rootTable: ICUResourceBundleImpl_ResourceTable
        let rootRes = reader.getRootResource()
        if (ICUResourceBundleReader.URES_IS_TABLE(ICUResourceBundleReader.RES_GET_TYPE(rootRes))) {
            let wb = ICUResourceBundle_WholeBundle(baseName, localeID, loader, reader)
            rootTable = ICUResourceBundleImpl_ResourceTable(wb, rootRes)
        } else {
            throw Exception("Invalid format error")
        }
        let aliasString = rootTable.findString("%%ALIAS")
        if (aliasString.isSome()) {
            return UResourceBundle.getBundleInstance(baseName, aliasString)
        } else {
            return rootTable
        }
    }

    protected init(wholeBundle: ICUResourceBundle_WholeBundle) {
        super()
        this.wholeBundle = wholeBundle
    }

    protected init(container: ICUResourceBundle, key: String) {
        super()
        this.key = key
        wholeBundle = container.wholeBundle
        this.container = container
        parent = container.parent
    }

    private static let RES_PATH_SEP_CHAR = '/'

    private static let RES_PATH_SEP_STR = "/"

    private static let ICUDATA = "ICUDATA"

    private static let HYPHEN = '-'

    private static let LOCALE = "LOCALE"

    protected static func getAliasedResource(base: ICUResourceBundle, keys: Array<String>, depth: Int32, key: String, _resource: Int32, aliasesVisited: HashMap<String, String>, requested: UResourceBundle): ICUResourceBundle {
        let wholeBundle = base.wholeBundle
        let loaderToUse = wholeBundle.loader
        let rpath = wholeBundle.reader.getAlias(_resource)
        let baseName = wholeBundle.baseName
        let baseDepth = base.getResDepth()
        let baseKeyPath = Array<String>(Int64(baseDepth + 1))
        base.getResPathKeys(baseKeyPath, baseDepth)
        baseKeyPath[Int64(baseDepth)] = key
        return getAliasedResource(rpath, loaderToUse, baseName, keys, depth, baseKeyPath, aliasesVisited, requested)
    }

    protected static func getAliasedResource(rpath: String, loaderToUse: ClassLoader, baseName: String, keys: Array<String>, depth: Int32, baseKeyPath: Array<String>, aliasesVisited: HashMap<String, String>, requested: UResourceBundle): ICUResourceBundle {
        var tempaliasesVisited = aliasesVisited
        var temploaderToUse = loaderToUse
        var tempkeys = keys
        let locale: String
        var keyPath: String
        var bundleName: String
        if (tempaliasesVisited.isNone()) {
            tempaliasesVisited = HashMap<String, String>()
        }
        if (tempaliasesVisited.get(rpath).isSome()) {
            throw IllegalArgumentException("Circular references in the resource bundles")
        }
        tempaliasesVisited.put(rpath, "")
        if (indexOfWrap(rpath.indexOf(UInt8(UInt32(RES_PATH_SEP_CHAR)))) == 0) {
            let i = indexOfWrap(rpath.indexOf(UInt8(UInt32(RES_PATH_SEP_CHAR)), 1))
            let j = indexOfWrap(rpath.indexOf(UInt8(UInt32(RES_PATH_SEP_CHAR)), Int64(i + 1)))
            bundleName = rpath[1..Int64(i)]
            if (j < 0) {
                locale = rpath[Int64(i + 1)..]
            } else {
                locale = rpath[Int64(i + 1)..Int64(j)]
                keyPath = rpath[Int64(j + 1)..rpath.size]
            }
            if (bundleName.equals(ICUDATA)) {
                bundleName = ICUData.ICU_BASE_NAME
                temploaderToUse = ICU_DATA_CLASS_LOADER
            } else if (indexOfWrap(bundleName.indexOf(ICUDATA)) > -1) {
                let idx = indexOfWrap(bundleName.indexOf(UInt8(UInt32(HYPHEN))))
                if (idx > -1) {
                    bundleName = (ICUData.ICU_BASE_NAME) + RES_PATH_SEP_STR + bundleName[Int64(idx + 1)..bundleName.size]
                    temploaderToUse = ICU_DATA_CLASS_LOADER
                }
            }
        } else {
            let i = indexOfWrap(rpath.indexOf(UInt8(UInt32(RES_PATH_SEP_CHAR))))
            if (i != -1) {
                locale = rpath[0..Int64(i)]
                keyPath = rpath[Int64(i + 1)..]
            } else {
                locale = rpath
            }
            bundleName = baseName
        }
        var bundle: ICUResourceBundle
        var sub: ICUResourceBundle
        if (bundleName.equals(LOCALE)) {
            bundleName = baseName
            keyPath = rpath[Int64(Int32(LOCALE.size) + 2)..rpath.size]
            bundle = requested
            while (bundle.container.isSome()) {
                bundle = bundle.container
            }
            sub = ICUResourceBundle.findResourceWithFallback(keyPath, bundle, None)
        } else {
            bundle = getBundleInstance(bundleName, locale, temploaderToUse, false)
            let numKeys: Int32
            if (keyPath.isSome()) {
                numKeys = countPathKeys(keyPath)
                if (numKeys > 0) {
                    tempkeys = Array<String>(Int64(numKeys))
                    getResPathKeysStatic(keyPath, numKeys, tempkeys, 0)
                }
            } else if (tempkeys.isSome()) {
                numKeys = depth
            } else {
                tempkeys = baseKeyPath
                numKeys = Int32(baseKeyPath.size)
            }
            if (numKeys > 0) {
                sub = bundle
                } while (false)
            }
        }
        if (sub.isNone()) {
            throw MissingResourceException(locale, baseName, baseKeyPath[Int64(Int32(baseKeyPath.size) - 1)])
        }
        return sub
    }

    
    public func getTopLevelKeySet(): Set<String> {
        return wholeBundle.topLevelKeys
    }

    
    public func setTopLevelKeySet(keySet: Set<String>): Unit {
        wholeBundle.topLevelKeys = keySet
    }

    override protected func handleGetKeys(): Enumeration<String> {
        return Collections.enumeration(handleKeySet())
    }

    override protected func isTopLevelResource(): Bool {
        return container.isNone()
    }
}


public class ICUResourceBundle_WholeBundle {
    init(baseName: String, localeID: String, loader: ClassLoader, reader: ICUResourceBundleReader) {
        this.baseName = baseName
        this.localeID = localeID
        this.ulocale = ULocale(localeID)
        this.loader = loader
        this.reader = reader
    }

    var baseName: String

    var localeID: String

    var ulocale: ULocale

    var loader: ClassLoader = None

    var reader: ICUResourceBundleReader

    var topLevelKeys: Set<String>
}


abstract class ICUResourceBundle_Loader {

    public func load(): ICUResourceBundle
}


class ICUResourceBundle_1 <: SoftCache<String, ICUResourceBundle, ICUResourceBundle_Loader> {
    init() {
        super()
    }

    override protected func createInstance(unusedKey: String, loader: ICUResourceBundle_Loader): ICUResourceBundle {
        return loader.load()
    }
}


class ICUResourceBundle_1AllChildrenSink <: UResource_Sink {
    let this_0: ICUResourceBundle

    let val_sink: UResource_Sink

    init(this_0: ICUResourceBundle, val_sink: UResource_Sink) {
        super()
        this.this_0 = this_0
        this.val_sink = val_sink
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let itemsTable = value.getTable()
        var i = 0
        while (itemsTable.getKeyAndValue(i, key, value)) {
            if (value.getType() == ICUResourceBundle.ALIAS) {
                let aliasPath = value.getAliasString()
                var aliasedResource = ICUResourceBundle.getAliasedResource(aliasPath, this_0.wholeBundle.loader, "", None, 0, None, None, this_0)
                var aliasedResourceImpl = aliasedResource
                var aliasedValue: ICUResourceBundleReader_ReaderValue = ICUResourceBundleReader_ReaderValue()
                aliasedValue.reader = aliasedResourceImpl.wholeBundle.reader
                aliasedValue.res = aliasedResourceImpl.getResource()
                if (aliasedValue.getType() != UResourceBundle.TABLE) {
                    val_sink.put(key, aliasedValue, noFallback)
                } else {
                    var aliasedValueType = UResourceBundle.TABLE
                    var tablePath: String = aliasPath["/LOCALE/".size..]
                    var keyCopy = key.clone()
                    val_sink.put(keyCopy, aliasedValue, noFallback)
                    while (aliasedValueType == UResourceBundle.TABLE && aliasedResource.getParent().isSome()) {
                        let newAliasedResource = aliasedResource.getParent().findWithFallback(tablePath)
                        if (newAliasedResource.key.equals(aliasedResource.key)) {
                            aliasedResource = newAliasedResource
                        } else {
                            tablePath = tablePath[0..Int64(indexOfWrap(tablePath.lastIndexOf(UInt8(UInt32('/')))))]
                            tablePath += "/" + (newAliasedResource.key)
                            aliasedResource = this_0.findWithFallback(tablePath)
                        }
                        aliasedResourceImpl = aliasedResource
                        aliasedValue = ICUResourceBundleReader_ReaderValue()
                        aliasedValue.reader = aliasedResourceImpl.wholeBundle.reader
                        aliasedValue.res = aliasedResourceImpl.getResource()
                        aliasedValueType = aliasedValue.getType()
                        keyCopy = key.clone()
                        val_sink.put(keyCopy, aliasedValue, noFallback)
                    }
                }
            } else {
                val_sink.put(key, value, noFallback)
            }
            i++
        }
    }
}


class ICUResourceBundle_AvailableLocalesSink <: UResource_Sink {
    var output: EnumMap = None

    public init(output: EnumMap) {
        super()
        this.output = output
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let resIndexTable = value.getTable()
        var i = 0
        while (resIndexTable.getKeyAndValue(i, key, value)) {
            let Type: ULocale_AvailableType
            if (key.contentEquals("InstalledLocales")) {
                Type = ULocale_AvailableType.DEFAULT
            } else if (key.contentEquals("AliasLocales")) {
                Type = ULocale_AvailableType.ONLY_LEGACY_ALIASES
            } else {
                continue
            }
            let availableLocalesTable = value.getTable()
            let locales = Array<ULocale>(Int64(availableLocalesTable.getSize()))
            var j = 0
            while (availableLocalesTable.getKeyAndValue(j, key, value)) {
                locales[Int64(j)] = ULocale(key.toString())
                j++
            }
            output.put(Type, locales)
            i++
        }
    }
}


class ICUResourceBundle_2 <: PrivilegedAction {
    let val_names: Set<Any>

    let val_bn: String

    let val_root: ClassLoader

    init(val_root: ClassLoader, val_bn: String, val_names: Set<Any>) {
        this.val_root = val_root
        this.val_bn = val_bn
        this.val_names = val_names
    }

    public override func run(): Void {
        try {
            let urls = val_root.getResources(val_bn)
            if (urls.isNone()) {
                return None
            }
            let v: URLHandler_URLVisitor = ICUResourceBundle_2_1(this)
            while (urls.hasMoreElements()) {
                let url = urls.nextElement()
                let handler = URLHandler.get(url)
                if (handler.isSome()) {
                    handler.guide(v, false)
                } else {
                    if (ICUResourceBundle.DEBUG) {
                        println("handler for " + toString(url) + " is null")
                    }
                }
            }
        } catch (e: IOException) {
            if (ICUResourceBundle.DEBUG) {
                println("ouch: " + e.message)
            }
        }
        return None
    }
}


class ICUResourceBundle_2_1 <: URLHandler_URLVisitor {
    let this_0: ICUResourceBundle_2

    init(this_0: ICUResourceBundle_2) {
        this.this_0 = this_0
    }

    public override func visit(s: String): Unit {
        if (s.endsWith(".res")) {
            let locstr: String = s[0..Int64(Int32(s.size) - 4)]
            this_0.val_names.put(locstr)
        }
    }
}


class ICUResourceBundle_AvailEntry <: Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private var prefix: String

    private var loader: ClassLoader = None

     private var ulocales: EnumMap = None

     private var locales: Array<Locale> = None

     private var nameSet: Set<String>

     private var fullNameSet: Set<String>

    init(prefix: String, loader: ClassLoader) {
        this.prefix = prefix
        this.loader = loader
    }

    public func getULocaleList(Type: ULocale_AvailableType): Array<ULocale> {
        if (!(!refEq(Type, ULocale_AvailableType.WITH_LEGACY_ALIASES))) {
            throw AssertionError()
        }
        if (ulocales.isNone()) {
            synchronized (getMonitorByObject(this)) {
                if (ulocales.isNone()) {
                    ulocales = ICUResourceBundle.createULocaleList(prefix, loader)
                }
            }
        }
        return ulocales.get(Type)
    }

    public func getLocaleList(Type: ULocale_AvailableType): Array<Locale> {
        if (locales.isNone()) {
            getULocaleList(Type)
            synchronized (getMonitorByObject(this)) {
                if (locales.isNone()) {
                    locales = ICUResourceBundle.getLocaleList(ulocales.get(Type))
                }
            }
        }
        return locales
    }

    public func getLocaleNameSet(): Set<String> {
        if (nameSet.isNone()) {
            synchronized (getMonitorByObject(this)) {
                if (nameSet.isNone()) {
                    nameSet = ICUResourceBundle.createLocaleNameSet(prefix, loader)
                }
            }
        }
        return nameSet
    }

    public func getFullLocaleNameSet(): Set<String> {
        if (fullNameSet.isNone()) {
            synchronized (getMonitorByObject(this)) {
                if (fullNameSet.isNone()) {
                    fullNameSet = ICUResourceBundle.createFullLocaleNameSet(prefix, loader)
                }
            }
        }
        return fullNameSet
    }
}


class ICUResourceBundle_3 <: SoftCache<String, ICUResourceBundle_AvailEntry, ClassLoader> {
    init() {
        super()
    }

    override protected func createInstance(key: String, loader: ClassLoader): ICUResourceBundle_AvailEntry {
        return ICUResourceBundle_AvailEntry(key, loader)
    }
}


public class ICUResourceBundle_OpenType <: Enum<ICUResourceBundle_OpenType> {
    public static let LOCALE_DEFAULT_ROOT = ICUResourceBundle_OpenType("LOCALE_DEFAULT_ROOT", 0)

    public static let LOCALE_ROOT = ICUResourceBundle_OpenType("LOCALE_ROOT", 1)

    public static let LOCALE_ONLY = ICUResourceBundle_OpenType("LOCALE_ONLY", 2)

    public static let DIRECT = ICUResourceBundle_OpenType("DIRECT", 3)

    private static func _values(): Array<ICUResourceBundle_OpenType> {
        return [ICUResourceBundle_OpenType.LOCALE_DEFAULT_ROOT, ICUResourceBundle_OpenType.LOCALE_ROOT, ICUResourceBundle_OpenType.LOCALE_ONLY, ICUResourceBundle_OpenType.DIRECT]
    }

    private static let _VALUES = ICUResourceBundle_OpenType._values()

    public static func values(): Array<ICUResourceBundle_OpenType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): ICUResourceBundle_OpenType {
        return (TypeInfo.of<ICUResourceBundle_OpenType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as ICUResourceBundle_OpenType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class ICUResourceBundle_4 <: Comparator {

    public override func compare(pair1: Array<String>, pair2: Array<String>): Int32 {
        return pair1[0].compare(pair2[0]).value()
    }
}


class ICUResourceBundle_5 <: ICUResourceBundle_Loader {
    let val_origLocaleID: String

    let val_defaultID: String

    let val_openType: ICUResourceBundle_OpenType

    let val_root: ClassLoader

    let val_localeID: String

    let val_baseName: String

    let val_fullName: String

    init(val_fullName: String, val_baseName: String, val_localeID: String, val_root: ClassLoader, val_openType: ICUResourceBundle_OpenType, val_defaultID: String, val_origLocaleID: String) {
        super()
        this.val_fullName = val_fullName
        this.val_baseName = val_baseName
        this.val_localeID = val_localeID
        this.val_root = val_root
        this.val_openType = val_openType
        this.val_defaultID = val_defaultID
        this.val_origLocaleID = val_origLocaleID
    }

    public override func load(): ICUResourceBundle {
        if (ICUResourceBundle.DEBUG) {
            println("Creating " + (val_fullName))
        }
        let rootLocale: String = if (indexOfWrap(val_baseName.indexOf(UInt8(UInt32('.')))) == -1) { "root" } else { "" }
        var localeName = if (val_localeID.isEmpty()) { rootLocale } else { val_localeID }
        var b = ICUResourceBundle.createBundle(val_baseName, localeName, val_root)
        if (ICUResourceBundle.DEBUG) {
            println("The bundle created is: " + b.asString() + " and openType=" + val_openType.asString() + " and bundle.getNoFallback=" + ((b.isSome() && b.getNoFallback()).toString()))
        }
        if (refEq(val_openType, ICUResourceBundle_OpenType.DIRECT) || (b.isSome() && b.getNoFallback())) {
            return b
        }
        if (b.isNone()) {
            var localOpenType = val_openType
            if (refEq(val_openType, ICUResourceBundle_OpenType.LOCALE_DEFAULT_ROOT) && localeName.equals(val_defaultID)) {
                localOpenType = ICUResourceBundle_OpenType.LOCALE_ROOT
            }
            let origLocaleName = if (val_origLocaleID.isSome()) { val_origLocaleID } else { localeName }
            let fallbackLocaleID = ICUResourceBundle.getParentLocaleID(localeName, origLocaleName, val_openType)
            if (fallbackLocaleID.isSome()) {
                b = ICUResourceBundle.instantiateBundle(val_baseName, fallbackLocaleID, origLocaleName, val_defaultID, val_root, localOpenType)
            } else {
                if (refEq(localOpenType, ICUResourceBundle_OpenType.LOCALE_DEFAULT_ROOT) && !ICUResourceBundle.localeIDStartsWithLangSubtag(val_defaultID, localeName)) {
                    b = ICUResourceBundle.instantiateBundle(val_baseName, val_defaultID, None, val_defaultID, val_root, localOpenType)
                } else if (!refEq(localOpenType, ICUResourceBundle_OpenType.LOCALE_ONLY) && !rootLocale.isEmpty()) {
                    b = ICUResourceBundle.createBundle(val_baseName, rootLocale, val_root)
                }
            }
        } else {
            var parent: UResourceBundle
            localeName = b.getLocaleID()
            let i = indexOfWrap(localeName.lastIndexOf(UInt8(UInt32('_'))))
            let parentLocaleName = b.findString("%%Parent")
            if (parentLocaleName.isSome()) {
                parent = ICUResourceBundle.instantiateBundle(val_baseName, parentLocaleName, None, val_defaultID, val_root, val_openType)
            } else if (i != -1) {
                parent = ICUResourceBundle.instantiateBundle(val_baseName, localeName[0..Int64(i)], None, val_defaultID, val_root, val_openType)
            } else if (!localeName.equals(rootLocale)) {
                parent = ICUResourceBundle.instantiateBundle(val_baseName, rootLocale, None, val_defaultID, val_root, val_openType)
            }
            if (!b.equals(parent)) {
                b.setParent(parent)
            }
        }
        return b
    }
}
