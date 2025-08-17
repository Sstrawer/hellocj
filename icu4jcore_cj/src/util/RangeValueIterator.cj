package icu4cj.util

public interface RangeValueIterator {
    public func next(element: RangeValueIterator_Element): Bool

    public func reset(): Unit
}

public static class RangeValueIterator_Element {
    public var start: Int32 = 0

    public var limit: Int32 = 0

    public var value: Int32 = 0

}
