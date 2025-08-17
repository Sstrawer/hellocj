package icu4cj.impl.number

public interface MicroPropsMutator<T> {
    public func mutateMicros(micros: MicroProps, value: T): Unit
}