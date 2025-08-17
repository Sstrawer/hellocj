package icu4cj.impl


public class StringRange {

    static let DEBUG = false

    public static let COMPARE_INT_ARRAYS = StringRange_1()

    public static func compact(source: Set<String>, adder: StringRange_Adder, shorterPairs: Bool, moreCompact: Bool): Unit {
        if (!moreCompact) {
            var start: String
            var end: String
            var lastCp = 0
            var prefixLen = 0
            for (s in source) {
                if (start.isSome()) {
                    if (s.regionMatches(0, start, 0, prefixLen)) {
                        let currentCp = s.codePointAt(prefixLen)
                        if (currentCp == 1 + lastCp && Int32(s.size) == prefixLen + Character.charCount(currentCp)) {
                            end = s
                            lastCp = currentCp
                            continue
                        }
                    }
                    adder.add(start, if (end.isNone()) { None } else { if (!shorterPairs) { end } else { end[Int64(prefixLen)..end.size] } })
                }
                start = s
                end = None
                lastCp = s.codePointBefore(Int32(s.size))
                prefixLen = Int32(s.size) - Character.charCount(lastCp)
            }
            adder.add(start, if (end.isNone()) { None } else { if (!shorterPairs) { end } else { end[Int64(prefixLen)..end.size] } })
        } else {
            let lengthToArrays = Relation.of(TreeMap() as Map<Any, Set<Any>>, TypeInfo.of<TreeSet>() as ClassTypeInfo)
            for (s in source) {
                let item = StringRange_Ranges(s)
                lengthToArrays.put(item.size(), item)
            }
            for (entry in lengthToArrays.keyValuesSet()) {
                let compacted = compact(entry.getKey(), entry.getValue())
                for (ranges in compacted) {
                    adder.add(ranges.start(), ranges.end(shorterPairs))
                }
            }
        }
    }

    public static func compact(source: Set<String>, adder: StringRange_Adder, shorterPairs: Bool): Unit {
        compact(source, adder, shorterPairs, false)
    }

    private static func compact(size: Int32, inputRanges: Set<StringRange_Ranges>): LinkedList<StringRange_Ranges> {
        let ranges = LinkedList<StringRange_Ranges>(inputRanges)
        var i = size - 1
        while (i >= 0) {
            var last: StringRange_Ranges
            let it: Iterator<StringRange_Ranges> = ranges.iterator()
            while (it.hasNext()) {
                let item = it.next()
                if (last.isNone()) {
                    last = item
                } else if (last.merge(i, item)) {
                    it.remove()
                } else {
                    last = item
                }
            }
            i--
        }
        return ranges
    }

    public static func expand(start: String, end: String, requireSameLength: Bool, output: Collection<String>): Collection<String> {
        if (start.isNone() || end.isNone()) {
            throw ICUException("Range must have 2 valid strings")
        }
        let startCps = CharSequences.codePoints(start)
        let endCps = CharSequences.codePoints(end)
        let startOffset = Int32(startCps.size) - Int32(endCps.size)
        if (requireSameLength && startOffset != 0) {
            throw ICUException("Range must have equal-length strings")
        } else if (startOffset < 0) {
            throw ICUException("Range must have start-length \u{2265} end-length")
        } else if (Int32(endCps.size) == 0) {
            throw ICUException("Range must have end-length > 0")
        }
        let builder = StringBuilder()
        var i = 0
        while (i < startOffset) {
            builder.appendCodePoint(startCps[Int64(i)])
            i++
        }
        add(0, startOffset, startCps, endCps, builder, output)
        return output
    }

    private static func add(endIndex: Int32, startOffset: Int32, starts: Array<Int32>, ends: Array<Int32>, builder: StringBuilder, output: Collection<String>): Unit {
        let start = starts[Int64(endIndex + startOffset)]
        let end = ends[Int64(endIndex)]
        if (start > end) {
            throw ICUException("Range must have x\u{1d62} \u{2264} y\u{1d62} for each index i")
        }
        let last = endIndex == Int32(ends.size) - 1
        let startLen = Int32(builder.size)
        var i = start
        while (i <= end) {
            builder.appendCodePoint(i)
            if (last) {
                output.add(builder.toString())
            } else {
                add(endIndex + 1, startOffset, starts, ends, builder, output)
            }
            builder.setLength(Int64(startLen))
            i++
        }
    }
}


public interface StringRange_Adder {
    func add(start: String, end: String): Unit
}

class StringRange_1 <: Comparator {

    public override func compare(o1: Array<Int32>, o2: Array<Int32>): Int32 {
        let minIndex = min(Int32(o1.size), Int32(o2.size))
        var i = 0
        while (i < minIndex) {
            let diff = o1[Int64(i)] - o2[Int64(i)]
            if (diff != 0) {
                return diff
            }
            i++
        }
        return Int32(o1.size) - Int32(o2.size)
    }
}


class StringRange_Range <: Comparable<StringRange_Range> {
    var min: Int32 = 0

    var max: Int32 = 0

    public init(min: Int32, max: Int32) {
        this.min = min
        this.max = max
    }

    public override func equals(obj: Object): Bool {
        return refEq(this, obj) || (obj.isSome() && checkOptionalIs<StringRange_Range, Object>(obj) && compareTo(obj) == 0)
    }

    public override func compareTo(that: StringRange_Range): Int32 {
        let diff = min - that.min
        if (diff != 0) {
            return diff
        }
        return max - that.max
    }

    public override func hashCode(): Int64 {
        return Int64(min * 37 + max)
    }

    public override func toString(): String {
        let result = StringBuilder().appendCodePoint(min)
        return if (min == max) { result.toString() } else { result.append('~').appendCodePoint(max).toString() }
    }
}


class StringRange_Ranges <: Comparable<StringRange_Ranges> {
    private let ranges: Array<StringRange_Range>

    public init(s: String) {
        let array = CharSequences.codePoints(s)
        ranges = Array<StringRange_Range>(array.size)
        var i = 0
        while (i < Int32(array.size)) {
            ranges[Int64(i)] = StringRange_Range(array[Int64(i)], array[Int64(i)])
            i++
        }
    }

    public func merge(pivot: Int32, other: StringRange_Ranges): Bool {
        var i = Int32(ranges.size) - 1
        while (i >= 0) {
            if (i == pivot) {
                if (ranges[Int64(i)].max != other.ranges[Int64(i)].min - 1) {
                    return false
                }
            } else {
                if (!ranges[Int64(i)].equals(other.ranges[Int64(i)])) {
                    return false
                }
            }
            i--
        }
        if (StringRange.DEBUG) {
            print("Merging: " + this.toString() + ", " + other.asString())
        }
        ranges[Int64(pivot)].max = other.ranges[Int64(pivot)].max
        if (StringRange.DEBUG) {
            println(" => " + this.toString())
        }
        return true
    }

    public func start(): String {
        let result = StringBuilder()
        var i = 0
        while (i < Int32(ranges.size)) {
            result.appendCodePoint(ranges[Int64(i)].min)
            i++
        }
        return result.toString()
    }

    public func end(mostCompact: Bool): String {
        let firstDiff = firstDifference()
        if (firstDiff == Int32(ranges.size)) {
            return None
        }
        let result = StringBuilder()
        var i = if (mostCompact) { firstDiff } else { 0 }
        while (i < Int32(ranges.size)) {
            result.appendCodePoint(ranges[Int64(i)].max)
            i++
        }
        return result.toString()
    }

    public func firstDifference(): Int32 {
        var i = 0
        while (i < Int32(ranges.size)) {
            if (ranges[Int64(i)].min != ranges[Int64(i)].max) {
                return i
            }
            i++
        }
        return Int32(ranges.size)
    }

    public func size(): Int32 {
        return Int32(ranges.size)
    }

    public override func compareTo(other: StringRange_Ranges): Int32 {
        var diff = Int32(ranges.size) - Int32(other.ranges.size)
        if (diff != 0) {
            return diff
        }
        var i = 0
        while (i < Int32(ranges.size)) {
            diff = ranges[Int64(i)].compareTo(other.ranges[Int64(i)])
            if (diff != 0) {
                return diff
            }
            i++
        }
        return 0
    }

    public override func toString(): String {
        let start = start()
        let end = end(false)
        return if (end.isNone()) { start } else { (start) + "~" + (end) }
    }
}
