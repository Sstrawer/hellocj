package icu4cj.impl

public class CollectionSet<E> <: Set<E> {
    private let data: Collection<E>

    public init(data: Collection<E>) {
        this.data = data
    }

    public override func size(): Int32 {
        return Int32(data.size)
    }

    public override func isEmpty(): Bool {
        return data.isEmpty()
    }

    public override func contains(o: Object): Bool {
        return data.contains(o)
    }

    public override func iterator(): Iterator<E> {
        return data.iterator()
    }

    public override func toArray(): Array<Object> {
        return data.toArray()
    }

    public override func toArray<T>(a: Array<T>): Array<T> {
        return data.toArray(a)
    }

    public override func add(e: E): Bool {
        return data.add(e)
    }

    public override func remove(o: Object): Bool {
        return data.remove(o)
    }

    public override func containsAll(c: Collection<Object>): Bool {
        return data.containsAll(c)
    }

    public override func addAll(c: Collection<E>): Bool {
        return data.addAll(c)
    }

    public override func retainAll(c: Collection<Object>): Bool {
        return data.retainAll(c)
    }

    public override func removeAll(c: Collection<Object>): Bool {
        return data.removeAll(c)
    }

    public override func clear(): Unit {
        data.clear()
    }
}