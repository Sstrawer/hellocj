package icu4cj.impl


public abstract class SoftCache<K, V, D> <: CacheBase<K, V, D> {
    public init() {
        super()
    }

    private var map: ConcurrentHashMap = ConcurrentHashMap()

    public override func getInstance(key: K, data: D): V {
        var mapValue = map.get(key)
        if (mapValue.isSome()) {
            if (!(checkOptionalIs<CacheValue<Any>, Object>(mapValue))) {
                return mapValue
            }
            let cv = mapValue
            if (cv.isNull()) {
                return None
            }
            var value = cv.get()
            if (value.isSome()) {
                return value
            }
            value = createInstance(key, data)
            return cv.resetIfCleared(value)
        } else {
            let value = createInstance(key, data)
            mapValue = if (value.isSome() && CacheValue.futureInstancesWillBeStrong()) { value } else { CacheValue.getInstance(value) }
            mapValue = map.putIfAbsent(key, mapValue)
            if (mapValue.isNone()) {
                return value
            }
            if (!(checkOptionalIs<CacheValue<Any>, Object>(mapValue))) {
                return mapValue
            }
            let cv = mapValue
            return cv.resetIfCleared(value)
        }
    }
}