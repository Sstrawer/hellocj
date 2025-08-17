package icu4cj.util


public class UResourceBundleIterator {
    private var bundle: UResourceBundle

    private var index = 0

    private var size = 0

    public init(bndl: UResourceBundle) {
        bundle = bndl
        size = bundle.getSize()
    }

    public func next(): UResourceBundle {
        if (index < size) {
            return bundle.get(match (0) { case _ => index++; index - 1 })
        }
        throw NoSuchElementException()
    }

    public func nextString(): String {
        if (index < size) {
            return bundle.getString(match (0) { case _ => index++; index - 1 })
        }
        throw NoSuchElementException()
    }

    public func reset(): Unit {
        index = 0
    }

    public func hasNext(): Bool {
        return index < size
    }
}
