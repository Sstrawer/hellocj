package icu4cj.text

public class FilteredNormalizer2 <: Normalizer2 {
    public init(n2: Normalizer2, filterSet: UnicodeSet) {
        super()
        norm2 = n2
        set = filterSet
    }

    public override func normalize(src: String, dest: StringBuilder): StringBuilder {
        if (refEq(dest, src)) {
            throw IllegalArgumentException()
        }
        dest.setLength(0)
        normalize(src, dest, UnicodeSet_SpanCondition.SIMPLE)
        return dest
    }

    public override func normalize(src: String, dest: Appendable): Appendable {
        if (refEq(dest, src)) {
            throw IllegalArgumentException()
        }
        return normalize(src, dest, UnicodeSet_SpanCondition.SIMPLE)
    }

    public override func normalizeSecondAndAppend(first: StringBuilder, second: String): StringBuilder {
        return normalizeSecondAndAppend(first, second, true)
    }

    public override func append(first: StringBuilder, second: String): StringBuilder {
        return normalizeSecondAndAppend(first, second, false)
    }

    public override func getDecomposition(c: Int32): String {
        return if (set.contains(c)) { norm2.getDecomposition(c) } else { None }
    }

    public override func getRawDecomposition(c: Int32): String {
        return if (set.contains(c)) { norm2.getRawDecomposition(c) } else { None }
    }

    public override func composePair(a: Int32, b: Int32): Int32 {
        return if (set.contains(a) && set.contains(b)) { norm2.composePair(a, b) } else { -1 }
    }

    public override func getCombiningClass(c: Int32): Int32 {
        return if (set.contains(c)) { norm2.getCombiningClass(c) } else { 0 }
    }

    public override func isNormalized(s: String): Bool {
        var spanCondition: UnicodeSet_SpanCondition = UnicodeSet_SpanCondition.SIMPLE
        var prevSpanLimit = 0
        while (prevSpanLimit < s.size) {
            let spanLimit = set.span(s, prevSpanLimit, spanCondition)
            if (refEq(spanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED)) {
                spanCondition = UnicodeSet_SpanCondition.SIMPLE
            } else {
                if (!norm2.isNormalized(s.subSequence(prevSpanLimit, spanLimit))) {
                    return false
                }
                spanCondition = UnicodeSet_SpanCondition.NOT_CONTAINED
            }
            prevSpanLimit = spanLimit
        }
        return true
    }

    public override func quickCheck(s: String): Normalizer_QuickCheckResult {
        var result: Normalizer_QuickCheckResult = Normalizer.YES
        var spanCondition: UnicodeSet_SpanCondition = UnicodeSet_SpanCondition.SIMPLE
        var prevSpanLimit = 0
        while (prevSpanLimit < s.size) {
            let spanLimit = set.span(s, prevSpanLimit, spanCondition)
            if (refEq(spanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED)) {
                spanCondition = UnicodeSet_SpanCondition.SIMPLE
            } else {
                let qcResult = norm2.quickCheck(s.subSequence(prevSpanLimit, spanLimit))
                if (refEq(qcResult, Normalizer.NO)) {
                    return qcResult
                } else if (refEq(qcResult, Normalizer.MAYBE)) {
                    result = qcResult
                }
                spanCondition = UnicodeSet_SpanCondition.NOT_CONTAINED
            }
            prevSpanLimit = spanLimit
        }
        return result
    }

    public override func spanQuickCheckYes(s: String): Int32 {
        var spanCondition: UnicodeSet_SpanCondition = UnicodeSet_SpanCondition.SIMPLE
        var prevSpanLimit = 0
        while (prevSpanLimit < s.size) {
            let spanLimit = set.span(s, prevSpanLimit, spanCondition)
            if (refEq(spanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED)) {
                spanCondition = UnicodeSet_SpanCondition.SIMPLE
            } else {
                let yesLimit = prevSpanLimit + norm2.spanQuickCheckYes(s.subSequence(prevSpanLimit, spanLimit))
                if (yesLimit < spanLimit) {
                    return yesLimit
                }
                spanCondition = UnicodeSet_SpanCondition.NOT_CONTAINED
            }
            prevSpanLimit = spanLimit
        }
        return s.size
    }

    public override func hasBoundaryBefore(c: Int32): Bool {
        return !set.contains(c) || norm2.hasBoundaryBefore(c)
    }

    public override func hasBoundaryAfter(c: Int32): Bool {
        return !set.contains(c) || norm2.hasBoundaryAfter(c)
    }

    public override func isInert(c: Int32): Bool {
        return !set.contains(c) || norm2.isInert(c)
    }

    private func normalize(src: String, dest: Appendable, spanCondition: UnicodeSet_SpanCondition): Appendable {
        var tempspanCondition = spanCondition
        let tempDest = StringBuilder()
        try {
            var prevSpanLimit = 0
            while (prevSpanLimit < src.size) {
                let spanLimit = set.span(src, prevSpanLimit, tempspanCondition)
                let spanLength = spanLimit - prevSpanLimit
                if (refEq(tempspanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED)) {
                    if (spanLength != 0) {
                        dest.append(src, prevSpanLimit, spanLimit)
                    }
                    tempspanCondition = UnicodeSet_SpanCondition.SIMPLE
                } else {
                    if (spanLength != 0) {
                        dest.append(norm2.normalize(src.subSequence(prevSpanLimit, spanLimit), tempDest).asString())
                    }
                    tempspanCondition = UnicodeSet_SpanCondition.NOT_CONTAINED
                }
                prevSpanLimit = spanLimit
            }
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
        return dest
    }

    private func normalizeSecondAndAppend(first: StringBuilder, second: String, doNormalize: Bool): StringBuilder {
        if (refEq(first, second)) {
            throw IllegalArgumentException()
        }
        if (Int32(first.size) == 0) {
            if (doNormalize) {
                return normalize(second, first)
            } else {
                return first.append(second)
            }
        }
        let prefixLimit = set.span(second, 0, UnicodeSet_SpanCondition.SIMPLE)
        if (prefixLimit != 0) {
            let prefix = second.subSequence(0, prefixLimit)
            let suffixStart = set.spanBack(first.asString(), 2147483647, UnicodeSet_SpanCondition.SIMPLE)
            if (suffixStart == 0) {
                if (doNormalize) {
                    norm2.normalizeSecondAndAppend(first, prefix)
                } else {
                    norm2.append(first, prefix)
                }
            } else {
                let middle = StringBuilder(first.subSequence(suffixStart, Int32(first.size)))
                if (doNormalize) {
                    norm2.normalizeSecondAndAppend(middle, prefix)
                } else {
                    norm2.append(middle, prefix)
                }
                first.delete(suffixStart, 2147483647).append(middle)
            }
        }
        if (prefixLimit < second.size) {
            let rest = second.subSequence(prefixLimit, second.size)
            if (doNormalize) {
                normalize(rest, first, UnicodeSet_SpanCondition.NOT_CONTAINED)
            } else {
                first.append(rest)
            }
        }
        return first
    }

    private var norm2: Normalizer2

    private var set: UnicodeSet
}
