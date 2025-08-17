package icu4cj.impl


public class FormattedValueStringBuilderImpl {

    public static func findSpan(self: FormattedStringBuilder, value: Object): Int32 {
        var i = self.zero
        while (i < self.zero + self.length) {
            if (!(checkOptionalIs<FormattedValueStringBuilderImpl_SpanFieldPlaceholder, Object>(self.fields[Int64(i)]))) {
                continue
            }
            if (refEq(self.fields[Int64(i)].value, value)) {
                return i - self.zero
            }
            i++
        }
        return -1
    }

    public static func applySpanRange(self: FormattedStringBuilder, spanField: UFormat_SpanField, value: Object, start: Int32, end: Int32): Unit {
        var i = start + self.zero
        while (i < end + self.zero) {
            let oldField = self.fields[Int64(i)]
            let newField = FormattedValueStringBuilderImpl_SpanFieldPlaceholder()
            newField.spanField = spanField
            newField.normalField = oldField
            newField.value = value
            newField.start = start
            newField.length = end - start
            self.fields[Int64(i)] = newField
            i++
        }
    }

    public static func nextFieldPosition(self: FormattedStringBuilder, fp: FieldPosition): Bool {
        var rawField = fp.getFieldAttribute()
        if (rawField.isNone()) {
            if (fp.getField() == NumberFormat.INTEGER_FIELD) {
                rawField = NumberFormat_Field.INTEGER
            } else if (fp.getField() == NumberFormat.FRACTION_FIELD) {
                rawField = NumberFormat_Field.FRACTION
            } else {
                return false
            }
        }
        if (!(checkOptionalIs<NumberFormat_Field, Format_Field>(rawField))) {
            throw IllegalArgumentException("You must pass an instance of com.ibm.icu.text.NumberFormat.Field as your FieldPosition attribute.  You passed: " + toString(TypeInfo.of(rawField)))
        }
        let cfpos = ConstrainedFieldPosition()
        cfpos.constrainField(rawField)
        cfpos.setState(rawField, None, fp.getBeginIndex(), fp.getEndIndex())
        if (nextPosition(self, cfpos, None)) {
            fp.setBeginIndex(cfpos.getStart())
            fp.setEndIndex(cfpos.getLimit())
            return true
        }
        if (refEq(rawField, NumberFormat_Field.FRACTION) && fp.getEndIndex() == 0) {
            var inside = false
            var i = self.zero
            while (i < self.zero + self.length) {
                if (isIntOrGroup(self.fields[Int64(i)]) || refEq(self.fields[Int64(i)], NumberFormat_Field.DECIMAL_SEPARATOR)) {
                    inside = true
                } else if (inside) {
                    break
                }
                i++
            }
            fp.setBeginIndex(i - self.zero)
            fp.setEndIndex(i - self.zero)
        }
        return false
    }

    public static func toCharacterIterator(self: FormattedStringBuilder, numericField: Format_Field): AttributedCharacterIterator {
        let cfpos = ConstrainedFieldPosition()
        let `as` = AttributedString(self.toString())
        while (nextPosition(self, cfpos, numericField)) {
            var value = cfpos.getFieldValue()
            if (value.isNone()) {
                value = cfpos.getField()
            }
            `as`.addAttribute(cfpos.getField(), value, cfpos.getStart(), cfpos.getLimit())
        }
        return `as`.getIterator()
    }

    public static func nextPosition(self: FormattedStringBuilder, cfpos: ConstrainedFieldPosition, numericField: Format_Field): Bool {
        var fieldStart = -1
        var currField: Object
        var prevIsSpan = false
        if (cfpos.getLimit() > 0) {
            prevIsSpan = checkOptionalIs<UFormat_SpanField, Format_Field>(cfpos.getField()) && cfpos.getStart() < cfpos.getLimit()
        }
        var prevIsNumeric = false
        if (numericField.isSome()) {
            prevIsNumeric = refEq(cfpos.getField(), numericField)
        }
        var prevIsInteger = refEq(cfpos.getField(), NumberFormat_Field.INTEGER)
        var i = self.zero + cfpos.getLimit()
        while (i <= self.zero + self.length) {
            var _field: Object = if (i < self.zero + self.length) { self.fields[Int64(i)] } else { FormattedValueStringBuilderImpl_NullField.END }
            if (currField.isSome()) {
                if (!refEq(currField, _field)) {
                    var end = i - self.zero
                    if (isTrimmable(currField)) {
                        end = trimBack(self, end)
                    }
                    if (end <= fieldStart) {
                        fieldStart = -1
                        currField = None
                        i--
                        continue
                    }
                    var start = fieldStart
                    if (isTrimmable(currField)) {
                        start = trimFront(self, start)
                    }
                    cfpos.setState(currField, None, start, end)
                    return true
                }
                continue
            }
            if (i > self.zero && prevIsSpan) {
                if (!checkOptionalIs<FormattedValueStringBuilderImpl_SpanFieldPlaceholder, Object>(self.fields[Int64(i - 1)])) {
                    throw AssertionError()
                }
                let ph = self.fields[Int64(i - 1)]
                if (refEq(ph.normalField, ListFormatter_Field.ELEMENT)) {
                    if (cfpos.matchesField(ListFormatter_Field.ELEMENT, None)) {
                        fieldStart = i - self.zero - ph.length
                        let end = fieldStart + ph.length
                        cfpos.setState(ListFormatter_Field.ELEMENT, None, fieldStart, end)
                        return true
                    }
                } else {
                    i -= ph.length
                    if (!(i >= self.zero)) {
                        throw AssertionError()
                    }
                    _field = self.fields[Int64(i)].normalField
                }
            }
            if (cfpos.matchesField(NumberFormat_Field.INTEGER, None) && i > self.zero && !prevIsInteger && !prevIsNumeric && isIntOrGroup(self.fields[Int64(i - 1)]) && !isIntOrGroup(_field)) {
                var j = i - 1
                while (j >= self.zero && isIntOrGroup(self.fields[Int64(j)])) {
                    j--
                }
                cfpos.setState(NumberFormat_Field.INTEGER, None, j - self.zero + 1, i - self.zero)
                return true
            }
            if (numericField.isSome() && cfpos.matchesField(numericField, None) && i > self.zero && !prevIsNumeric && isNumericField(self.fields[Int64(i - 1)]) && !isNumericField(_field)) {
                var j = i - 1
                while (j >= self.zero && isNumericField(self.fields[Int64(j)])) {
                    j--
                }
                cfpos.setState(numericField, None, j - self.zero + 1, i - self.zero)
                return true
            }
            var ph: FormattedValueStringBuilderImpl_SpanFieldPlaceholder
            if (checkOptionalIs<FormattedValueStringBuilderImpl_SpanFieldPlaceholder, Object>(_field)) {
                ph = _field
                _field = ph.normalField
            }
            if (ph.isSome() && (ph.start == -1 || ph.start == i - self.zero)) {
                if (cfpos.matchesField(ph.spanField, ph.value)) {
                    fieldStart = i - self.zero
                    let end = fieldStart + ph.length
                    cfpos.setState(ph.spanField, ph.value, fieldStart, end)
                    return true
                } else if (refEq(ph.normalField, ListFormatter_Field.ELEMENT)) {
                    if (cfpos.matchesField(ListFormatter_Field.ELEMENT, None)) {
                        fieldStart = i - self.zero
                        let end = fieldStart + ph.length
                        cfpos.setState(ListFormatter_Field.ELEMENT, None, fieldStart, end)
                        return true
                    } else {
                        i += ph.length - 1
                    }
                }
            } else if (refEq(_field, NumberFormat_Field.INTEGER)) {
                _field = None
            } else if (_field.isNone() || refEq(_field, FormattedValueStringBuilderImpl_NullField.END)) { } else if (cfpos.matchesField(_field, None)) {
                fieldStart = i - self.zero
                currField = _field
            }
            prevIsSpan = false
            prevIsNumeric = false
            prevIsInteger = false
            i++
        }
        if (!currField.isNone()) {
            throw AssertionError()
        }
        cfpos.setState(cfpos.getField(), cfpos.getFieldValue(), self.length, self.length)
        return false
    }

    private static func isIntOrGroup(field: Object): Bool {
        var tempfield = field
        tempfield = FormattedStringBuilder.unwrapField(tempfield)
        return refEq(tempfield, NumberFormat_Field.INTEGER) || refEq(tempfield, NumberFormat_Field.GROUPING_SEPARATOR)
    }

    private static func isNumericField(field: Object): Bool {
        var tempfield = field
        tempfield = FormattedStringBuilder.unwrapField(tempfield)
        return tempfield.isNone() || TypeInfo.of<NumberFormat_Field>().isAssignableFrom(TypeInfo.of(tempfield))
    }

    private static func isTrimmable(field: Object): Bool {
        return !refEq(field, NumberFormat_Field.GROUPING_SEPARATOR) && !(checkOptionalIs<ListFormatter_Field, Object>(field))
    }

    private static func trimBack(self: FormattedStringBuilder, limit: Int32): Int32 {
        return StaticUnicodeSets.get(StaticUnicodeSets_Key.DEFAULT_IGNORABLES).spanBack(self, limit, UnicodeSet_SpanCondition.CONTAINED)
    }

    private static func trimFront(self: FormattedStringBuilder, start: Int32): Int32 {
        return StaticUnicodeSets.get(StaticUnicodeSets_Key.DEFAULT_IGNORABLES).span(self, start, UnicodeSet_SpanCondition.CONTAINED)
    }
}


public class FormattedValueStringBuilderImpl_SpanFieldPlaceholder <: FormattedStringBuilder_FieldWrapper {

    public var spanField: UFormat_SpanField

    public var normalField: Format_Field = None

    public var value: Object

    public var start: Int32 = 0

    public var length: Int32 = 0

    public override func unwrap(): Format_Field {
        return normalField
    }
}


class FormattedValueStringBuilderImpl_NullField <: Format_Field {
    private static let serialVersionUID = 1

    static let END = FormattedValueStringBuilderImpl_NullField("end")

    private init(name: String) {
        Format_Field(name)
    }
}
