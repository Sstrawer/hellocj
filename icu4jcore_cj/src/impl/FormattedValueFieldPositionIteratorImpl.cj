package icu4cj.impl


public class FormattedValueFieldPositionIteratorImpl {

    public static func nextPosition(attributes: ArrayList<FieldPosition>, cfpos: ConstrainedFieldPosition): Bool {
        let numFields = Int32(attributes.size)
        var i = Int32(cfpos.getInt64IterationContext())
        while (i < numFields) {
            let fpos = attributes[Int64(i)]
            var field = fpos.getFieldAttribute()
            var value: Object
            if (checkOptionalIs<FormattedValueFieldPositionIteratorImpl_FieldWithValue, Format_Field>(field)) {
                value = field.value
                field = field.field
            }
            if (cfpos.matchesField(field, value)) {
                let start = fpos.getBeginIndex()
                let limit = fpos.getEndIndex()
                cfpos.setState(field, value, start, limit)
                break
            }
            i++
        }
        cfpos.setInt64IterationContext(if (i == numFields) { Int64(i) } else { Int64(i + 1) })
        return i < numFields
    }

    public static func toCharacterIterator(cs: String, attributes: ArrayList<FieldPosition>): AttributedCharacterIterator {
        let `as` = AttributedString(toString(cs))
        var i = 0
        while (i < Int32(attributes.size)) {
            let fp = attributes[Int64(i)]
            var field = fp.getFieldAttribute()
            var value = field
            if (checkOptionalIs<FormattedValueFieldPositionIteratorImpl_FieldWithValue, Format_Field>(field)) {
                value = field.value
                field = field.field
            }
            `as`.addAttribute(field, value, fp.getBeginIndex(), fp.getEndIndex())
            i++
        }
        return `as`.getIterator()
    }

    public static func addOverlapSpans(attributes: ArrayList<FieldPosition>, spanField: Format_Field, firstIndex: Int32): Unit {
        var s1a = Int32.Max
        var s1b = 0
        var s2a = Int32.Max
        var s2b = 0
        let numFields = Int32(attributes.size)
        var i = 0
        while (i < numFields) {
            let fp1 = attributes[Int64(i)]
            var j = i + 1
            while (j < numFields) {
                let fp2 = attributes[Int64(j)]
                if (!refEq(fp1.getFieldAttribute(), fp2.getFieldAttribute())) {
                    continue
                }
                s1a = min(s1a, fp1.getBeginIndex())
                s1b = max(s1b, fp1.getEndIndex())
                s2a = min(s2a, fp2.getBeginIndex())
                s2b = max(s2b, fp2.getEndIndex())
                break
                j++
            }
            i++
        }
        if (s1a != Int32.Max) {
            var newPos: FieldPosition = FieldPosition(FormattedValueFieldPositionIteratorImpl_FieldWithValue(spanField, firstIndex))
            newPos.setBeginIndex(s1a)
            newPos.setEndIndex(s1b)
            attributes.append(newPos)
            newPos = FieldPosition(FormattedValueFieldPositionIteratorImpl_FieldWithValue(spanField, 1 - firstIndex))
            newPos.setBeginIndex(s2a)
            newPos.setEndIndex(s2b)
            attributes.append(newPos)
        }
    }

    public static func sort(attributes: ArrayList<FieldPosition>): Unit {
        let numFields = Int32(attributes.size)
        while (true) {
            var isSorted = true
            var i = 0
            while (i < numFields - 1) {
                let fp1 = attributes[Int64(i)]
                let fp2 = attributes[Int64(i + 1)]
                var comparison = 0
                if (fp1.getBeginIndex() != fp2.getBeginIndex()) {
                    comparison = Int64(fp2.getBeginIndex() - fp1.getBeginIndex())
                } else if (fp1.getEndIndex() != fp2.getEndIndex()) {
                    comparison = Int64(fp1.getEndIndex() - fp2.getEndIndex())
                } else if (!refEq(fp1.getFieldAttribute(), fp2.getFieldAttribute())) {
                    let fp1isSpan = checkOptionalIs<FormattedValueFieldPositionIteratorImpl_FieldWithValue, Format_Field>(fp1.getFieldAttribute())
                    let fp2isSpan = checkOptionalIs<FormattedValueFieldPositionIteratorImpl_FieldWithValue, Format_Field>(fp2.getFieldAttribute())
                    if (fp1isSpan && !fp2isSpan) {
                        comparison = 1
                    } else if (fp2isSpan && !fp1isSpan) {
                        comparison = -1
                    } else {
                        comparison = Int64(Int32(fp1.hashCode()) - Int32(fp2.hashCode()))
                    }
                }
                if (comparison < 0) {
                    isSorted = false
                    attributes.set(Int64(i), fp2)
                    attributes.set(Int64(i + 1), fp1)
                }
                i++
            }
            if (isSorted) {
                break
            }
        }
    }
}


class FormattedValueFieldPositionIteratorImpl_FieldWithValue <: Format_Field {
    private static let serialVersionUID = -3850076447157793465

    public let field: Format_Field

    public let value: Int32

    public init(field: Format_Field, value: Int32) {
        Format_Field(toString(field))
        this.field = field
        this.value = value
    }
}
