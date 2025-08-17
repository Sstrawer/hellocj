package icu4cj.impl

public interface ICUCache<K, V> {
    let SOFT = 0

    let WEAK = 1

    let NULL = Object()

    public func clear(): Unit

    public func put(key: K, value: V): Unit

    public func get(key: Object): V
}