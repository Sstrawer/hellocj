package icu4cj.util


public interface Freezable<T> <: Cloneable {
    public func isFrozen(): Bool

    public func freeze(): T

    public func cloneAsThawed(): T
}