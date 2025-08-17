package icu4cj.impl.locale


public abstract class LocaleObjectCache<K, V> {
    private var _map: ConcurrentHashMap = None

    private var _queue: ReferenceQueue = ReferenceQueue()

    public init() {
        this(16, 0.75, 16)
    }

    public init(initialCapacity: Int32, loadFactor: Float32, concurrencyLevel: Int32) {
        _map = ConcurrentHashMap(initialCapacity, loadFactor, concurrencyLevel)
    }

    public func get(key: K): V {
        var tempkey = key
        var value: V
        cleanStaleEntries()
        var entry = _map.get(tempkey)
        if (entry.isSome()) {
            value = entry.get()
        }
        if (value.isNone()) {
            tempkey = normalizeKey(tempkey)
            let newVal = createObject(tempkey)
            if (tempkey.isNone() || newVal.isNone()) {
                return None
            }
            let newEntry = LocaleObjectCache_CacheEntry<K, V>(tempkey, newVal, _queue)
            while (value.isNone()) {
                cleanStaleEntries()
                entry = _map.putIfAbsent(tempkey, newEntry)
                if (entry.isNone()) {
                    value = newVal
                    break
                } else {
                    value = entry.get()
                }
            }
        }
        return value
    }

    private func cleanStaleEntries(): Unit {
        var entry: LocaleObjectCache_CacheEntry<K, V> = None
        while ((match (0) { case _ => entry = _queue.poll(); entry }).isSome()) {
            _map.remove(entry.getKey())
        }
    }

    protected func createObject(key: K): V

    protected func normalizeKey(key: K): K {
        return key
    }
}

class LocaleObjectCache_CacheEntry<K, V> <: SoftReference {
    private var _key: K

    init(key: K, value: V, queue: ReferenceQueue) {
        SoftReference(value, queue)
        _key = key
    }

    public func getKey(): K {
        return _key
    }
}