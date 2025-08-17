package icu4cj.impl

public class SimpleCache<K, V> <: ICUCache<K, V> {
    private static let DEFAULT_CAPACITY = 16

     private var cacheRef: Reference = None

    private var Type = ICUCache.SOFT

    private var capacity = DEFAULT_CAPACITY


    public init(cacheType: Int32) {
        this(cacheType, DEFAULT_CAPACITY)
    }

    public init(cacheType: Int32, initialCapacity: Int32) {
        if (cacheType == ICUCache.WEAK) {
            Type = cacheType
        }
        if (initialCapacity > 0) {
            capacity = initialCapacity
        }
    }

    public override func get(key: Object): V {
        let ref = cacheRef
        if (ref.isSome()) {
            let map = ref.get()
            if (map.isSome()) {
                return map.get(key)
            }
        }
        return None
    }

    public override func put(key: K, value: V): Unit {
        var ref = cacheRef
        var map: Map<K, V> = None
        if (ref.isSome()) {
            map = ref.get()
        }
        if (map.isNone()) {
            map = Collections.synchronizedMap(HashMap<K, V>(Int64(capacity)) as Map<K, V>)
            if (Type == ICUCache.WEAK) {
                ref = WeakReference(map)
            } else {
                ref = SoftReference(map)
            }
            cacheRef = ref
        }
        map.put(key, value)
    }

    public override func clear(): Unit {
        cacheRef = None
    }
}