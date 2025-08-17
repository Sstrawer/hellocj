package icu4cj.impl

public class Pair<F, S> {
    public let first: F

    public let second: S

    protected init(first: F, second: S) {
        this.first = first
        this.second = second
    }

    public static func of<F, S>(first: F, second: S): Pair<F, S> {
        if (first.isNone() || second.isNone()) {
            throw IllegalArgumentException("Pair.of requires non null values.")
        }
        return Pair<F, S>(first, second)
    }

    public override func equals(other: Object): Bool {
        if (refEq(other, this)) {
            return true
        }
        if (!(checkOptionalIs<Pair<Any, Any>, Object>(other))) {
            return false
        }
        let rhs = other
        return // Мapping is present but failed: refEq -->(first, rhs.first) && <-- Мapping is present but failed: refEq(second, rhs.second)
    }

    public override func hashCode(): Int64 {
        return Int64(Int32(first.toString()))
    }
}