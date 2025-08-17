package icu4cj.impl.duration


public class Period {
    let timeLimit: UInt8

    let inFuture: Bool

    let counts: Array<Int32>

    public static func atStatic(count: Float32, unit: TimeUnit): Period {
        checkCount(count)
        return Period(Int32(DataRecord_ETimeLimit.NOLIMIT), false, count, unit)
    }

    public static func moreThanStatic(count: Float32, unit: TimeUnit): Period {
        checkCount(count)
        return Period(Int32(DataRecord_ETimeLimit.MT), false, count, unit)
    }

    public static func lessThanStatic(count: Float32, unit: TimeUnit): Period {
        checkCount(count)
        return Period(Int32(DataRecord_ETimeLimit.LT), false, count, unit)
    }

    public func and(count: Float32, unit: TimeUnit): Period {
        checkCount(count)
        return setTimeUnitValue(unit, count)
    }

    public func omit(unit: TimeUnit): Period {
        return setTimeUnitInternalValue(unit, 0)
    }

    public func at(): Period {
        return setTimeLimit(DataRecord_ETimeLimit.NOLIMIT)
    }

    public func moreThan(): Period {
        return setTimeLimit(DataRecord_ETimeLimit.MT)
    }

    public func lessThan(): Period {
        return setTimeLimit(DataRecord_ETimeLimit.LT)
    }

    public func inFutureMethod(): Period {
        return setFuture(true)
    }

    public func inPast(): Period {
        return setFuture(false)
    }

    public func inFutureMethod(future: Bool): Period {
        return setFuture(future)
    }

    public func inPast(past: Bool): Period {
        return setFuture(!past)
    }

    public func isSet(): Bool {
        var i = 0
        while (i < Int32(counts.size)) {
            if (counts[Int64(i)] != 0) {
                return true
            }
            i++
        }
        return false
    }

    public func isSet(unit: TimeUnit): Bool {
        return counts[Int64(unit.ordinal)] > 0
    }

    public func getCount(unit: TimeUnit): Float32 {
        let ord = Int32(unit.ordinal)
        if (counts[Int64(ord)] == 0) {
            return 0.0
        }
        return (Float32(counts[Int64(ord)] - 1)) / 1000.0
    }

    public func isInFuture(): Bool {
        return inFuture
    }

    public func isInPast(): Bool {
        return !inFuture
    }

    public func isMoreThan(): Bool {
        return timeLimit == DataRecord_ETimeLimit.MT
    }

    public func isLessThan(): Bool {
        return timeLimit == DataRecord_ETimeLimit.LT
    }

    public override func equals(rhs: Object): Bool {
        try {
            return equals(rhs)
        } catch (e: ClassCastException) {
            return false
        }
    }

    public func equals(rhs: Period): Bool {
        if (rhs.isSome() && this.timeLimit == rhs.timeLimit && this.inFuture == rhs.inFuture) {
            var i = 0
            while (i < Int32(counts.size)) {
                if (counts[Int64(i)] != rhs.counts[Int64(i)]) {
                    return false
                }
                i++
            }
            return true
        }
        return false
    }

    public override func hashCode(): Int64 {
        var hc = (shl(Int32(timeLimit), 1)) | (if (inFuture) { 1 } else { 0 })
        var i = 0
        while (i < Int32(counts.size)) {
            hc = (shl(hc, 2)) ^ counts[Int64(i)]
            i++
        }
        return Int64(hc)
    }

    private init(limit: Int32, future: Bool, count: Float32, unit: TimeUnit) {
        this.timeLimit = UInt8(limit)
        this.inFuture = future
        this.counts = Array<Int32>(TimeUnit.units.size) { _ => 0 }
        this.counts[Int64(unit.ordinal)] = Int32(count * 1000.0) + 1
    }

    init(timeLimit: Int32, inFuture: Bool, counts: Array<Int32>) {
        this.timeLimit = UInt8(timeLimit)
        this.inFuture = inFuture
        this.counts = counts
    }

    private func setTimeUnitValue(unit: TimeUnit, value: Float32): Period {
        if (value < 0.0) {
            throw IllegalArgumentException("value: " + value.toString())
        }
        return setTimeUnitInternalValue(unit, Int32(value * 1000.0) + 1)
    }

    private func setTimeUnitInternalValue(unit: TimeUnit, value: Int32): Period {
        let ord = Int32(unit.ordinal)
        if (counts[Int64(ord)] != value) {
            let newCounts = Array<Int32>(counts.size) { _ => 0 }
            var i = 0
            while (i < Int32(counts.size)) {
                newCounts[Int64(i)] = counts[Int64(i)]
                i++
            }
            newCounts[Int64(ord)] = value
            return Period(Int32(timeLimit), inFuture, newCounts)
        }
        return this
    }

    private func setFuture(future: Bool): Period {
        if (this.inFuture != future) {
            return Period(Int32(timeLimit), future, counts)
        }
        return this
    }

    private func setTimeLimit(limit: UInt8): Period {
        if (this.timeLimit != limit) {
            return Period(Int32(limit), inFuture, counts)
        }
        return this
    }

    private static func checkCount(count: Float32): Unit {
        if (count < 0.0) {
            throw IllegalArgumentException("count (" + count.toString() + ") cannot be negative")
        }
    }
}
