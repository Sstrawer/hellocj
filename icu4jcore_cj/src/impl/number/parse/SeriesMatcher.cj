package icu4cj.impl.number.parse


public class SeriesMatcher <: NumberParseMatcher {

    protected var matchers: ArrayList<NumberParseMatcher>

    protected var frozen = false

    public func addMatcher(matcher: NumberParseMatcher): Unit {
        if (!(!frozen)) {
            throw AssertionError()
        }
        if (matchers.isNone()) {
            matchers = ArrayList<NumberParseMatcher>()
        }
        matchers.append(matcher)
    }

    public func freeze(): Unit {
        frozen = true
    }

    public func length(): Int32 {
        return if (matchers.isNone()) { 0 } else { Int32(matchers.size) }
    }

    public override func match(segment: StringSegment, result: ParsedNumber): Bool {
        if (!frozen) {
            throw AssertionError()
        }
        if (matchers.isNone()) {
            return false
        }
        let backup = ParsedNumber()
        backup.copyFrom(result)
        let initialOffset = segment.getOffset()
        var maybeMore = true
        var i = 0
        while (i < Int32(matchers.size)) {
            let matcher = matchers[Int64(i)]
            let matcherOffset = segment.getOffset()
            if (segment.size != 0) {
                maybeMore = matcher.match(segment, result)
            } else {
                maybeMore = true
            }
            let success = (segment.getOffset() != matcherOffset)
            let isFlexible = checkOptionalIs<NumberParseMatcher_Flexible, NumberParseMatcher>(matcher)
            if (success && isFlexible) { } else if (success) {
                i++
                if (i < Int32(matchers.size) && segment.getOffset() != result.charEnd && result.charEnd > matcherOffset) {
                    segment.setOffset(result.charEnd)
                }
            } else if (isFlexible) {
                i++
            } else {
                segment.setOffset(initialOffset)
                result.copyFrom(backup)
                return maybeMore
            }
        }
        return maybeMore
    }

    public override func smokeTest(segment: StringSegment): Bool {
        if (!frozen) {
            throw AssertionError()
        }
        if (matchers.isNone()) {
            return false
        }
        if (!(!(checkOptionalIs<NumberParseMatcher_Flexible, NumberParseMatcher>(matchers[0])))) {
            throw AssertionError()
        }
        return matchers[0].smokeTest(segment)
    }

    public override func postProcess(result: ParsedNumber): Unit {
        if (!frozen) {
            throw AssertionError()
        }
        if (matchers.isNone()) {
            return
        }
        var i = 0
        while (i < Int32(matchers.size)) {
            let matcher = matchers[Int64(i)]
            matcher.postProcess(result)
            i++
        }
    }

    public override func toString(): String {
        return "<SeriesMatcher " + toString(matchers) + ">"
    }
}
