package icu4cj.impl

public class IterableComparator<T> {
    private let comparator: Comparator

    private let shorterFirst: Int32

    public init() {
        this(None, true)
    }

    public init(comparator: Comparator) {
        this(comparator, true)
    }

    public init(comparator: Comparator, shorterFirst: Bool) {
        this.comparator = comparator
        this.shorterFirst = if (shorterFirst) { 1 } else { -1 }
    }

    public override func compare(a: Iterable<T>, b: Iterable<T>): Int32 {
        if (a.isNone()) {
            return if (b.isNone()) { 0 } else { -shorterFirst }
        } else if (b.isNone()) {
            return shorterFirst
        }
        let ai: Iterator<T> = a.iterator()
        let bi: Iterator<T> = b.iterator()
        while (true) {
            if (!ai.hasNext()) {
                return if (bi.hasNext()) { -shorterFirst } else { 0 }
            }
            if (!bi.hasNext()) {
                return shorterFirst
            }
            let aItem: T = ai.next()
            let bItem: T = bi.next()
            let result = if (comparator.isSome()) { comparator.compare(aItem, bItem) } else { aItem.compare(bItem).value() }
            if (result != 0) {
                return result
            }
        }
        throw Exception()
    }

    public static func compareIterables<T>(a: Iterable<T>, b: Iterable<T>): Int32 {
        return NOCOMPARATOR.compare(a, b)
    }

    private static let NOCOMPARATOR = IterableComparator<Any>()
}