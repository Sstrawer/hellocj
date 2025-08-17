package icu4cj.text

public class UnicodeSetSpanner {
    private let unicodeSet: UnicodeSet

    public init(source: UnicodeSet) {
        unicodeSet = source
    }

    public func getUnicodeSet(): UnicodeSet {
        return unicodeSet
    }

    public override func equals(other: Object): Bool {
        return checkOptionalIs<UnicodeSetSpanner, Object>(other) && unicodeSet.equals(other.unicodeSet)
    }

    public override func hashCode(): Int64 {
        return unicodeSet.hashCode()
    }

    public func countIn(sequence: String): Int32 {
        return countIn(sequence, UnicodeSetSpanner_CountMethod.MIN_ELEMENTS, UnicodeSet_SpanCondition.SIMPLE)
    }

    public func countIn(sequence: String, countMethod: UnicodeSetSpanner_CountMethod): Int32 {
        return countIn(sequence, countMethod, UnicodeSet_SpanCondition.SIMPLE)
    }

    public func countIn(sequence: String, countMethod: UnicodeSetSpanner_CountMethod, spanCondition: UnicodeSet_SpanCondition): Int32 {
        var count = 0
        var start = 0
        let skipSpan: UnicodeSet_SpanCondition = if (refEq(spanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED)) { UnicodeSet_SpanCondition.SIMPLE } else { UnicodeSet_SpanCondition.NOT_CONTAINED }
        let length = sequence.size
        var spanCount: OutputInt
        while (start != length) {
            let endOfSpan = unicodeSet.span(sequence, start, skipSpan)
            if (endOfSpan == length) {
                break
            }
            if (refEq(countMethod, UnicodeSetSpanner_CountMethod.WHOLE_SPAN)) {
                start = unicodeSet.span(sequence, endOfSpan, spanCondition)
                count += 1
            } else {
                if (spanCount.isNone()) {
                    spanCount = OutputInt()
                }
                start = unicodeSet.spanAndCount(sequence, endOfSpan, spanCondition, spanCount)
                count += spanCount.value
            }
        }
        return count
    }

    public func deleteFrom(sequence: String): String {
        return replaceFrom(sequence, "", UnicodeSetSpanner_CountMethod.WHOLE_SPAN, UnicodeSet_SpanCondition.SIMPLE)
    }

    public func deleteFrom(sequence: String, spanCondition: UnicodeSet_SpanCondition): String {
        return replaceFrom(sequence, "", UnicodeSetSpanner_CountMethod.WHOLE_SPAN, spanCondition)
    }

    public func replaceFrom(sequence: String, replacement: String): String {
        return replaceFrom(sequence, replacement, UnicodeSetSpanner_CountMethod.MIN_ELEMENTS, UnicodeSet_SpanCondition.SIMPLE)
    }

    public func replaceFrom(sequence: String, replacement: String, countMethod: UnicodeSetSpanner_CountMethod): String {
        return replaceFrom(sequence, replacement, countMethod, UnicodeSet_SpanCondition.SIMPLE)
    }

    public func replaceFrom(sequence: String, replacement: String, countMethod: UnicodeSetSpanner_CountMethod, spanCondition: UnicodeSet_SpanCondition): String {
        let copySpan: UnicodeSet_SpanCondition = if (refEq(spanCondition, UnicodeSet_SpanCondition.NOT_CONTAINED)) { UnicodeSet_SpanCondition.SIMPLE } else { UnicodeSet_SpanCondition.NOT_CONTAINED }
        let remove = replacement.size == 0
        let result = StringBuilder()
        let length = sequence.size
        var spanCount: OutputInt
        var endCopy = 0
        while (endCopy != length) {
            let endModify: Int32
            if (refEq(countMethod, UnicodeSetSpanner_CountMethod.WHOLE_SPAN)) {
                endModify = unicodeSet.span(sequence, endCopy, spanCondition)
            } else {
                if (spanCount.isNone()) {
                    spanCount = OutputInt()
                }
                endModify = unicodeSet.spanAndCount(sequence, endCopy, spanCondition, spanCount)
            }
            if (remove || endModify == 0) { } else if (refEq(countMethod, UnicodeSetSpanner_CountMethod.WHOLE_SPAN)) {
                result.append(replacement)
            } else {
                var i = spanCount.value
                while (i > 0) {
                    result.append(replacement)
                    i--
                }
            }
            if (endModify == length) {
                break
            }
            endCopy = unicodeSet.span(sequence, endModify, copySpan)
            result.append(sequence.subSequence(endModify, endCopy))
        }
        return result.toString()
    }

    public func trim(sequence: String): String {
        return trim(sequence, UnicodeSetSpanner_TrimOption.BOTH, UnicodeSet_SpanCondition.SIMPLE)
    }

    public func trim(sequence: String, trimOption: UnicodeSetSpanner_TrimOption): String {
        return trim(sequence, trimOption, UnicodeSet_SpanCondition.SIMPLE)
    }

    public func trim(sequence: String, trimOption: UnicodeSetSpanner_TrimOption, spanCondition: UnicodeSet_SpanCondition): String {
        let endLeadContained: Int32
        let startTrailContained: Int32
        let length = sequence.size
        if (!refEq(trimOption, UnicodeSetSpanner_TrimOption.TRAILING)) {
            endLeadContained = unicodeSet.span(sequence, spanCondition)
            if (endLeadContained == length) {
                return ""
            }
        } else {
            endLeadContained = 0
        }
        if (!refEq(trimOption, UnicodeSetSpanner_TrimOption.LEADING)) {
            startTrailContained = unicodeSet.spanBack(sequence, spanCondition)
        } else {
            startTrailContained = length
        }
        return if (endLeadContained == 0 && startTrailContained == length) { sequence } else { sequence.subSequence(endLeadContained, startTrailContained) }
    }
}


public class UnicodeSetSpanner_CountMethod <: Enum<UnicodeSetSpanner_CountMethod> {
    public static let WHOLE_SPAN = UnicodeSetSpanner_CountMethod("WHOLE_SPAN", 0)

    public static let MIN_ELEMENTS = UnicodeSetSpanner_CountMethod("MIN_ELEMENTS", 1)

    private static func _values(): Array<UnicodeSetSpanner_CountMethod> {
        return [UnicodeSetSpanner_CountMethod.WHOLE_SPAN, UnicodeSetSpanner_CountMethod.MIN_ELEMENTS]
    }

    private static let _VALUES = UnicodeSetSpanner_CountMethod._values()

    public static func values(): Array<UnicodeSetSpanner_CountMethod> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): UnicodeSetSpanner_CountMethod {
        return (TypeInfo.of<UnicodeSetSpanner_CountMethod>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as UnicodeSetSpanner_CountMethod
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class UnicodeSetSpanner_TrimOption <: Enum<UnicodeSetSpanner_TrimOption> {
    public static let LEADING = UnicodeSetSpanner_TrimOption("LEADING", 0)

    public static let BOTH = UnicodeSetSpanner_TrimOption("BOTH", 1)

    public static let TRAILING = UnicodeSetSpanner_TrimOption("TRAILING", 2)

    private static func _values(): Array<UnicodeSetSpanner_TrimOption> {
        return [UnicodeSetSpanner_TrimOption.LEADING, UnicodeSetSpanner_TrimOption.BOTH, UnicodeSetSpanner_TrimOption.TRAILING]
    }

    private static let _VALUES = UnicodeSetSpanner_TrimOption._values()

    public static func values(): Array<UnicodeSetSpanner_TrimOption> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): UnicodeSetSpanner_TrimOption {
        return (TypeInfo.of<UnicodeSetSpanner_TrimOption>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as UnicodeSetSpanner_TrimOption
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
