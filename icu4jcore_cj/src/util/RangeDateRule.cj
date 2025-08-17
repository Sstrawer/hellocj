package icu4cj.util

public class RangeDateRule <: DateRule {

    public func add(rule: DateRule): Unit {
        add(Date(Int64.Min), rule)
    }

    public func add(start: DateTime, rule: DateTimeRule): Unit {
        ranges.append(Range(start, rule))
    }

    public override func firstAfter(start: DateTime): DateTime {
        var index = startIndex(start)
        if (index == Int32(ranges.size)) {
            index = 0
        }
        var result: DateTime = None
        let r = rangeAt(index)
        let e = rangeAt(index + 1)
        if (r.isSome() && r.rule.isSome()) {
            if (e.isSome()) {
                result = r.rule.firstBetween(start, e.start)
            } else {
                result = r.rule.firstAfter(start)
            }
        }
        return result
    }

    public override func firstBetween(start: DateTime, end: DateTime): DateTime {
        if (end.isNone()) {
            return firstAfter(start)
        }
        let index = startIndex(start)
        var result: DateTime = None
        var next = rangeAt(index)
        while (result.isNone() && next.isSome() && !next.start.after(end)) {
            let r = next
            next = rangeAt(index + 1)
            if (r.rule.isSome()) {
                let e = if (next.isSome() && !next.start.after(end)) { next.start } else { end }
                result = r.rule.firstBetween(start, e)
            }
        }
        return result
    }

    public override func isOn(date: DateTime): Bool {
        let r = rangeAt(startIndex(date))
        return r.isSome() && r.rule.isSome() && r.rule.isOn(date)
    }

    public override func isBetween(start: DateTime, end: DateTime): Bool {
        return firstBetween(start, end).isNone()
    }

    private func startIndex(start: DateTime): Int32 {
        var lastIndex = Int32(ranges.size)
        var i = 0
        while (i < Int32(ranges.size)) {
            let r = ranges[Int64(i)]
            if (start.before(r.start)) {
                break
            }
            lastIndex = i
            i++
        }
        return lastIndex
    }

    private func rangeAt(index: Int32): Range {
        return if (index < Int32(ranges.size)) { ranges[Int64(index)] } else { None }
    }

    var ranges: ArrayList<Range> = ArrayList<Range>(2)
}


class Range {
    public init(start: DateTime, rule: DateTimeRule) {
        this.start = start
        this.rule = rule
    }

    public var start: DateTime = None

    public var rule: DateRule
}
