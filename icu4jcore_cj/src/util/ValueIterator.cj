package icu4cj.util

public interface ValueIterator {
    public func next(element: ValueIterator_Element): Bool

    public func reset(): Unit

    public func setRange(start: Int32, limit: Int32): Unit
}

public static class ValueIterator_Element {
    public var integer: Int32 = 0

    public var value: Object

}
