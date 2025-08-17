package icu4cj.impl


public class Relation<K, V> <: Freezable<Relation<K, V>> {
    private var data: Map<K, Set<V>> = None

    var setCreator: Constructor = None

    var setComparatorParam: Array<Object>

    public static func of<K, V>(map: Map<K, Set<V>>, setCreator: ClassTypeInfo): Relation<K, V> {
        return Relation<K, V>(map, setCreator)
    }

    public static func of<K, V>(map: Map<K, Set<V>>, setCreator: ClassTypeInfo, setComparator: Comparator): Relation<K, V> {
        return Relation<K, V>(map, setCreator, setComparator)
    }

    public init(map: Map<K, Set<V>>, setCreator: ClassTypeInfo) {
        this(map, setCreator, None)
    }

    public init(map: Map<K, Set<V>>, setCreator: ClassTypeInfo, setComparator: Comparator) {
        @AssertThrows[NoneValueException]({
            setComparatorParam = if (setComparator.isNone()) { None } else { [setComparator] }
            if (setComparator.isNone()) {
                this.setCreator = setCreator.getConstructor([0])
                this.setCreator.newInstance(setComparatorParam)
            } else {
                this.setCreator = setCreator.getConstructor([TypeInfo.of<Comparator>() as ClassTypeInfo])
                this.setCreator.newInstance(setComparatorParam)
            }
            data = if (map.isNone()) { HashMap<K, Set<V>>() as Map<K, Set<V>> } else { map }
        } catch (e: Exception) {
            throw IllegalArgumentException("Can't create new set").initCause(e)
        }
    }

    public func clear(): Unit {
        data.clear()
    }

    public func containsKey(key: Object): Bool {
        return data.contains(key)
    }

    public func containsValue(value: Object): Bool {
        for (values in data.values()) {
            if (values.contains(value)) {
                return true
            }
        }
        return false
    }

    public func entrySet(): Set<Map_Entry> {
        return keyValueSet()
    }

    public func keyValuesSet(): Set<Map_Entry> {
        return data.entrySet()
    }

    public func keyValueSet(): Set<Map_Entry> {
        let result = LinkedHashSet()
        for (key in data.keys()) {
            for (value in data.get(key)) {
                result.put(Relation_SimpleEntry<K, V>(key, value) as Map_Entry)
            }
        }
        return result
    }

    public override func equals(o: Object): Bool {
        if (o.isNone()) {
            return false
        }
        if (!refEq(TypeInfo.of(o), TypeInfo.of(this))) {
            return false
        }
        return // Мapping is present but failed: refEq(data, o.data)
    }

    public func getAll(key: Object): Set<V> {
        return data.get(key)
    }

    public func get(key: Object): Set<V> {
        return data.get(key)
    }

    public override func hashCode(): Int64 {
        return data.hashCode()
    }

    public func isEmpty(): Bool {
        return data.isEmpty()
    }

    public func keySet(): Set<K> {
        return // Мapping is present but failed: SetCollectionView<K>(data.keys()) as Set<K>
    }

    public func put(key: K, value: V): V {
        var set = data.get(key)
        if (set.isNone()) {
            data.put(key, match (0) { case _ => set = newSet(); set })
        }
        set.put(value)
        return value
    }

    public func putAll(key: K, values: Collection<V>): V {
        var set = data.get(key)
        if (set.isNone()) {
            data.put(key, match (0) { case _ => set = newSet(); set })
        }
        set.putAll(values)
        return if (Int32(values.size) == 0) { None } else { values.iterator().next() }
    }

    public func putAll(keys: Collection<K>, value: V): V {
        var result: V
        for (key in keys) {
            result = put(key, value)
        }
        return result
    }

    private func newSet(): Set<V> {
        try {
            return setCreator.newInstance(setComparatorParam)
        } catch (e: Exception) {
            throw IllegalArgumentException("Can't create new set").initCause(e)
        }
    }

    public func putAll(t: Map<K, V>): Unit {
        for (entry in t.entrySet()) {
            put(entry.getKey(), entry.getValue())
        }
    }

    public func putAll(t: Relation<K, V>): Unit {
        for (key in t.keySet()) {
            for (value in t.getAll(key)) {
                put(key, value)
            }
        }
    }

    public func removeAll(key: K): Set<V> {
        try {
            return data.remove(key)
        } catch (e: NoneValueException) {
            return None
        }
    }

    public func remove(key: K, value: V): Bool {
        try {
            let set = data.get(key)
            if (set.isNone()) {
                return false
            }
            let result = set.remove(value)
            if (set.size() == 0) {
                data.remove(key)
            }
            return result
        } catch (e: NoneValueException) {
            return false
        }
    }

    public func size(): Int32 {
        return Int32(data.size)
    }

    public func values(): Set<V> {
        return values(LinkedHashSet())
    }

    public func values<C>(result: C): C {
        for (keyValue in data.entrySet()) {
            result.addAll(keyValue.getValue())
        }
        return result
    }

    public override func toString(): String {
        return toString(data)
    }

    public func addAllInverted(source: Relation<V, K>): Relation<K, V> {
        for (value in source.data.keys()) {
            for (key in source.data.get(value)) {
                put(key, value)
            }
        }
        return this
    }

    public func addAllInverted(source: Map<V, K>): Relation<K, V> {
        for (entry in source.entrySet()) {
            put(entry.getValue(), entry.getKey())
        }
        return this
    }

     var frozen = false

    public override func isFrozen(): Bool {
        return frozen
    }

    public override func freeze(): Relation<K, V> {
        if (!frozen) {
            for (key in data.keys()) {
                data.put(key, Collections.unmodifiableSet(data.get(key)))
            }
            data = Collections.unmodifiableMap(data)
            frozen = true
        }
        return this
    }

    public override func cloneAsThawed(): Relation<K, V> {
        throw UnsupportedOperationException()
    }

    public func removeAll(toBeRemoved: Relation<K, V>): Bool {
        var result = false
        for (key in toBeRemoved.keySet()) {
            try {
                let values = toBeRemoved.getAll(key)
                if (values.isSome()) {
                    result |= removeAll(key, values)
                }
            })
        }
        return result
    }

    
    public func removeAll(keys: Array<K>): Set<V> {
        return removeAll(keys)
    }

    public func removeAll(key: K, toBeRemoved: Iterable<V>): Bool {
        var result = false
        for (value in toBeRemoved) {
            result |= remove(key, value)
        }
        return result
    }

    public func removeAll(toBeRemoved: Collection<K>): Set<V> {
        let result = LinkedHashSet()
        for (key in toBeRemoved) {
            @AssertThrows[NoneValueException]({
                let removals: Set<V> = data.remove(key)
                if (removals.isSome()) {
                    result.addAll(removals)
                }
            })
        }
        return result
    }
}

class Relation_SimpleEntry<K, V> <: Map_Entry {
    var key: K

    var value: V

    public init(key: K, value: V) {
        this.key = key
        this.value = value
    }

    public init(e: Map_Entry) {
        this.key = e.getKey()
        this.value = e.getValue()
    }

    public override func getKey(): K {
        return key
    }

    public override func getValue(): V {
        return value
    }

    public override func setValue(value: V): V {
        let oldValue = this.value
        this.value = value
        return oldValue
    }
}