package icu4cj.impl


public class Row<C0, C1, C2, C3, C4> <: Comparable<Any> & Cloneable & Freezable<Row<C0, C1, C2, C3, C4>> {

    protected var items: Array<Object>

     protected var frozen: Bool = false

    public static func of<C0, C1>(p0: C0, p1: C1): Row_R2<C0, C1> {
        return Row_R2<C0, C1>(p0, p1)
    }

    public static func of<C0, C1, C2>(p0: C0, p1: C1, p2: C2): Row_R3<C0, C1, C2> {
        return Row_R3<C0, C1, C2>(p0, p1, p2)
    }

    public static func of<C0, C1, C2, C3>(p0: C0, p1: C1, p2: C2, p3: C3): Row_R4<C0, C1, C2, C3> {
        return Row_R4<C0, C1, C2, C3>(p0, p1, p2, p3)
    }

    public static func of<C0, C1, C2, C3, C4>(p0: C0, p1: C1, p2: C2, p3: C3, p4: C4): Row_R5<C0, C1, C2, C3, C4> {
        return Row_R5<C0, C1, C2, C3, C4>(p0, p1, p2, p3, p4)
    }

    public func set0(item: C0): Row<C0, C1, C2, C3, C4> {
        return set(0, item)
    }

    public func get0(): C0 {
        return items[0]
    }

    public func set1(item: C1): Row<C0, C1, C2, C3, C4> {
        return set(1, item)
    }

    public func get1(): C1 {
        return items[1]
    }

    public func set2(item: C2): Row<C0, C1, C2, C3, C4> {
        return set(2, item)
    }

    public func get2(): C2 {
        return items[2]
    }

    public func set3(item: C3): Row<C0, C1, C2, C3, C4> {
        return set(3, item)
    }

    public func get3(): C3 {
        return items[3]
    }

    public func set4(item: C4): Row<C0, C1, C2, C3, C4> {
        return set(4, item)
    }

    public func get4(): C4 {
        return items[4]
    }

    protected func set(i: Int32, item: Object): Row<C0, C1, C2, C3, C4> {
        if (frozen) {
            throw UnsupportedOperationException("Attempt to modify frozen object")
        }
        items[Int64(i)] = item
        return this
    }

    public override func hashCode(): Int64 {
        var sum = Int32(items.size)
        for (item in items) {
            sum = sum * 37 + Utility.checkHash(item)
        }
        return Int64(sum)
    }

    public override func equals(other: Object): Bool {
        if (other.isNone()) {
            return false
        }
        if (refEq(this, other)) {
            return true
        }
        try {
            let that = other
            if (Int32(items.size) != Int32(that.items.size)) {
                return false
            }
            var i = 0
            for (item in items) {
                if (!Objects.equals(item, that.items[Int64(match (0) { case _ => i++; i - 1 })])) {
                    return false
                }
            }
            return true
        } catch (e: Exception) {
            return false
        }
    }

    public override func compareTo(other: Object): Int32 {
        var result: Int32 = 0
        let that = other
        result = Int32(items.size) - Int32(that.items.size)
        if (result != 0) {
            return result
        }
        var i = 0
        for (item in items) {
            result = Utility.checkCompare(item, that.items[Int64(match (0) { case _ => i++; i - 1 })])
            if (result != 0) {
                return result
            }
        }
        return 0
    }

    public override func toString(): String {
        let result = StringBuilder("[")
        var first = true
        for (item in items) {
            if (first) {
                first = false
            } else {
                result.append(", ")
            }
            result.append(item)
        }
        return result.append("]").toString()
    }

    public override func isFrozen(): Bool {
        return frozen
    }

    public override func freeze(): Row<C0, C1, C2, C3, C4> {
        frozen = true
        return this
    }

    public override func clone(): Object {
        if (frozen) {
            return this
        }
        try {
            let result = super.toString()
            items = items.clone()
            return result
        } catch (e: CloneNotSupportedException) {
            return None
        }
    }

    public override func cloneAsThawed(): Row<C0, C1, C2, C3, C4> {
        try {
            let result = super.toString()
            items = items.clone()
            result.frozen = false
            return result
        } catch (e: CloneNotSupportedException) {
            return None
        }
    }
}

public class Row_R2<C0, C1> <: Row<C0, C1, C1, C1, C1> {
    public init(a: C0, b: C1) {
        super()
        items = [a, b]
    }
}

public class Row_R3<C0, C1, C2> <: Row<C0, C1, C2, C2, C2> {
    public init(a: C0, b: C1, c: C2) {
        super()
        items = [a, b, c]
    }
}

public class Row_R4<C0, C1, C2, C3> <: Row<C0, C1, C2, C3, C3> {
    public init(a: C0, b: C1, c: C2, d: C3) {
        super()
        items = [a, b, c, d]
    }
}

public class Row_R5<C0, C1, C2, C3, C4> <: Row<C0, C1, C2, C3, C4> {
    public init(a: C0, b: C1, c: C2, d: C3, e: C4) {
        super()
        items = [a, b, c, d, e]
    }
}