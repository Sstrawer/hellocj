package icu4cj.impl


public class ICUService <: ICUNotifier & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    protected let name: String

    public init() {
        super()
        name = ""
    }

    private static let DEBUG = ICUDebug.enabled("service")

    public init(name: String) {
        super()
        this.name = name
    }

    private let factoryLock = ICURWLock()

    private let factories = ArrayList<ICUService_Factory>()

    private var defaultSize = 0

    public func get(descriptor: String): Object {
        return getKey(createKey(descriptor), None)
    }

    public func get(descriptor: String, actualReturn: Array<String>): Object {
        if (descriptor.isNone()) {
            throw NoneValueException("descriptor must not be null")
        }
        return getKey(createKey(descriptor), actualReturn)
    }

    public func getKey(key: ICUService_Key): Object {
        return getKey(key, None)
    }

    public func getKey(key: ICUService_Key, actualReturn: Array<String>): Object {
        return getKey(key, actualReturn, None)
    }

    public func getKey(key: ICUService_Key, actualReturn: Array<String>, factory: ICUService_Factory): Object {
        if (Int32(factories.size) == 0) {
            return handleDefault(key, actualReturn)
        }
        if (DEBUG) {
            println("Service: " + (name) + " key: " + (key.canonicalID()))
        }
        var result: ICUService_CacheEntry
        if (key.isSome()) {
            try {
                factoryLock.acquireRead()
                var cache = this.cache
                if (cache.isNone()) {
                    if (DEBUG) {
                        println("Service " + (name) + " cache was empty")
                    }
                    cache = ConcurrentHashMap() as Map<String, ICUService_CacheEntry>
                }
                var currentDescriptor: String
                var cacheDescriptorList: ArrayList<String>
                var putInCache = false
                var NDebug = 0
                var startIndex = 0
                let limit = Int32(factories.size)
                var cacheResult = true
                if (factory.isSome()) {
                    var i = 0
                    while (i < limit) {
                        if (refEq(factory, factories[Int64(i)])) {
                            startIndex = i + 1
                            break
                        }
                        i++
                    }
                    if (startIndex == 0) {
                        throw Exception("Factory " + toString(factory) + "not registered with service: " + this.toString())
                    }
                    cacheResult = false
                }
    private var cache: Map<String, ICUService_CacheEntry> = None

    protected func handleDefault(key: ICUService_Key, actualIDReturn: Array<String>): Object {
        return None
    }

    public func getVisibleIDs(): Set<String> {
        return getVisibleIDs(None)
    }

    public func getVisibleIDs(matchID: String): Set<String> {
        var result: Set<String> = SetCollectionView<String>(getVisibleIDMap().keys())
        let fallbackKey = createKey(matchID)
        if (fallbackKey.isSome()) {
            let temp: Set<String> = HashSet<String>(result.size)
            for (id in result) {
                if (fallbackKey.isFallbackOf(id)) {
                    temp.put(id)
                }
            }
            result = temp
        }
        return result
    }

    private func getVisibleIDMap(): Map<String, ICUService_Factory> {
        synchronized (getMonitorByObject(this)) {
            if (idcache.isNone()) {
                try {
                    factoryLock.acquireRead()
                    let mutableMap: Map<String, ICUService_Factory> = HashMap<String, ICUService_Factory>()
                    let lIter = factories.listIterator(Int32(factories.size))
                    while (lIter.hasPrevious()) {
                        let f = lIter.previous()
                        f.updateVisibleIDs(mutableMap)
                    }
                    let result = Collections.unmodifiableMap(mutableMap as Map<K, V>)
                    this.idcache = result
                    return result
                } finally {
                    factoryLock.releaseRead()
                }
            }
            return idcache
        }
    }

    private var idcache: Map<String, ICUService_Factory> = None

    public func getDisplayName(id: String): String {
        return getDisplayName(id, ULocale.getDefault(ULocale_Category.DISPLAY))
    }

    public func getDisplayName(id: String, locale: ULocale): String {
        let m = getVisibleIDMap()
        var f = m.get(id)
        if (f.isSome()) {
            return f.getDisplayName(id, locale)
        }
        let key = createKey(id)
        while (key.fallback()) {
            f = m.get(key.currentID())
            if (f.isSome()) {
                return f.getDisplayName(id, locale)
            }
        }
        return None
    }

    public func getDisplayNames(): SortedMap {
        let locale = ULocale.getDefault(ULocale_Category.DISPLAY)
        return getDisplayNames(locale, None, None)
    }

    public func getDisplayNames(locale: ULocale): SortedMap {
        return getDisplayNames(locale, None, None)
    }

    public func getDisplayNames(locale: ULocale, com: Comparator): SortedMap {
        return getDisplayNames(locale, com, None)
    }

    public func getDisplayNames(locale: ULocale, matchID: String): SortedMap {
        return getDisplayNames(locale, None, matchID)
    }

    public func getDisplayNames(locale: ULocale, com: Comparator, matchID: String): SortedMap {
        var dncache: SortedMap = None
        var ref = dnref
        if (ref.isSome()) {
            dncache = ref.get(locale, com)
        }
        while (dncache.isNone()) {
            synchronized (getMonitorByObject(this)) {
                if (refEq(ref, dnref) || dnref.isNone()) {
                    dncache = TreeMap(com)
                    let m = getVisibleIDMap()
                    let ei = m.entrySet().iterator()
                    while (ei.hasNext()) {
                        let e = ei.next()
                        let id = e.getKey()
                        let f = e.getValue()
                        dncache.put(f.getDisplayName(id, locale), id)
                    }
                    dncache = Collections.unmodifiableSortedMap(dncache)
                    dnref = ICUService_LocaleRef(dncache, locale, com)
                } else {
                    ref = dnref
                    dncache = ref.get(locale, com)
                }
            }
        }
        let matchKey = createKey(matchID)
        if (matchKey.isNone()) {
            return dncache
        }
        let result: SortedMap = TreeMap(dncache)
        let iter = result.entrySet().iterator()
        while (iter.hasNext()) {
            let e = iter.next()
            if (!matchKey.isFallbackOf(e.getValue())) {
                iter.remove()
            }
        }
        return result
    }

    private var dnref: ICUService_LocaleRef

    public func factoriesMethod(): ArrayList<ICUService_Factory> {
        try {
            factoryLock.acquireRead()
            return ArrayList<ICUService_Factory>(factories)
        } finally {
            factoryLock.releaseRead()
        }
    }

    public func registerObject(obj: Object, id: String): ICUService_Factory {
        return registerObject(obj, id, true)
    }

    public func registerObject(obj: Object, id: String, visible: Bool): ICUService_Factory {
        let canonicalID = createKey(id).canonicalID()
        return registerFactory(ICUService_SimpleFactory(obj, canonicalID, visible))
    }

    public func registerFactory(factory: ICUService_Factory): ICUService_Factory {
        if (factory.isNone()) {
            throw NoneValueException()
        }
        try {
            factoryLock.acquireWrite()
            factories.insert(0, factory)
            clearCaches()
        } finally {
            factoryLock.releaseWrite()
        }
        notifyChanged()
        return factory
    }

    public func unregisterFactory(factory: ICUService_Factory): Bool {
        if (factory.isNone()) {
            throw NoneValueException()
        }
        var result = false
        try {
            factoryLock.acquireWrite()
            if (factories.removeObject(factory)) {
                result = true
                clearCaches()
            }
        } finally {
            factoryLock.releaseWrite()
        }
        if (result) {
            notifyChanged()
        }
        return result
    }

    public func reset(): Unit {
        try {
            factoryLock.acquireWrite()
            reInitializeFactories()
            clearCaches()
        } finally {
            factoryLock.releaseWrite()
        }
        notifyChanged()
    }

    protected func reInitializeFactories(): Unit {
        factories.clear()
    }

    public func isDefault(): Bool {
        return Int32(factories.size) == defaultSize
    }

    protected func markDefault(): Unit {
        defaultSize = Int32(factories.size)
    }

    public func createKey(id: String): ICUService_Key {
        return if (id.isNone()) { None } else { ICUService_Key(id) }
    }

    protected func clearCaches(): Unit {
        cache = None
        idcache = None
        dnref = None
    }

    protected func clearServiceCache(): Unit {
        cache = None
    }

    override protected func acceptsListener(l: EventListener): Bool {
        return checkOptionalIs<ICUService_ServiceListener, EventListener>(l)
    }

    override protected func notifyListener(l: EventListener): Unit {
        l.serviceChanged(this)
    }

    public func stats(): String {
        let stats = factoryLock.resetStats()
        if (stats.isSome()) {
            return stats.toString()
        }
        return "no stats"
    }

    public func getName(): String {
        return name
    }

    public override func toString(): String {
        return toString(super) + "{" + (name) + "}"
    }
}


public class ICUService_Key {
    private let id: String

    public init(id: String) {
        this.id = id
    }

    public func idMethod(): String {
        return id
    }

    public func canonicalID(): String {
        return id
    }

    public func currentID(): String {
        return canonicalID()
    }

    public func currentDescriptor(): String {
        return "/" + (currentID())
    }

    public func fallback(): Bool {
        return false
    }

    public func isFallbackOf(idToCheck: String): Bool {
        return canonicalID().equals(idToCheck)
    }
}


public interface ICUService_Factory {
    public func create(key: ICUService_Key, service: ICUService): Object

    public func updateVisibleIDs(result: Map<String, ICUService_Factory>): Unit

    public func getDisplayName(id: String, locale: ULocale): String
}

public class ICUService_SimpleFactory <: ICUService_Factory {
    protected var instance: Object

    protected var id: String

    protected var visible: Bool = false

    public init(instance: Object, id: String) {
        this(instance, id, true)
    }

    public init(instance: Object, id: String, visible: Bool) {
        if (instance.isNone() || id.isNone()) {
            throw IllegalArgumentException("Instance or id is null")
        }
        this.instance = instance
        this.id = id
        this.visible = visible
    }

    public override func create(key: ICUService_Key, service: ICUService): Object {
        if (id.equals(key.currentID())) {
            return instance
        }
        return None
    }

    public override func updateVisibleIDs(result: Map<String, ICUService_Factory>): Unit {
        if (visible) {
            result.put(id, this)
        } else {
            result.remove(id)
        }
    }

    public override func getDisplayName(identifier: String, locale: ULocale): String {
        return if (visible && id.equals(identifier)) { identifier } else { None }
    }

    public override func toString(): String {
        let buf = StringBuilder(toString(super))
        buf.append(", id: ")
        buf.append(id)
        buf.append(", visible: ")
        buf.append(visible)
        return buf.toString()
    }
}


class ICUService_CacheEntry {
    let actualDescriptor: String

    let service: Object

    init(actualDescriptor: String, service: Object) {
        this.actualDescriptor = actualDescriptor
        this.service = service
    }
}


class ICUService_LocaleRef {
    private let locale: ULocale

    private var dnCache: SortedMap = None

    private var com: Comparator = None

    init(dnCache: SortedMap, locale: ULocale, com: Comparator) {
        this.locale = locale
        this.com = com
        this.dnCache = dnCache
    }

    public func get(loc: ULocale, comp: Comparator): SortedMap {
        let m = dnCache
        if (m.isSome() && this.locale.equals(loc) && (refEq(this.com, comp) || (this.com.isSome() && refEq(this.com, comp)))) {
            return m
        }
        return None
    }
}


public interface ICUService_ServiceListener <: EventListener {
    public func serviceChanged(service: ICUService): Unit
}