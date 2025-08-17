package icu4cj.impl


public abstract class CacheBase<K, V, D> {

    public func getInstance(key: K, data: D): V

    protected func createInstance(key: K, data: D): V
}