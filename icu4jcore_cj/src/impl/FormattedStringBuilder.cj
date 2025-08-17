package icu4cj.impl


public class FormattedStringBuilder <: String & Appendable {
    public static func unwrapField(field: Object): Format_Field {
        if (field.isNone()) {
            return None
        } else if (checkOptionalIs<FormattedStringBuilder_FieldWrapper, Object>(field)) {
            return field.unwrap()
        } else if (checkOptionalIs<Format_Field, Object>(field)) {
            return field
        } else {
            throw Exception("Not a field: " + toString(field))
        }
    }

    public static let EMPTY = FormattedStringBuilder()

    var chars: Array<Char>

    var fields: Array<Object>

    var zero: Int32 = 0

    var length: Int32 = 0

    var appendOffset = 0

    var appendableField: Object

    public init() {
        this(40)
    }

    public init(capacity: Int32) {
        chars = Array<Char>(Int64(capacity)) { _ => '\u{0000}' }
        fields = Array<Object>(Int64(capacity))
        zero = capacity / 2
        length = 0
    }

    public init(source: FormattedStringBuilder) {
        copyFrom(source)
    }

    public func copyFrom(source: FormattedStringBuilder): Unit {
        chars = source.chars.clone(0.. Int32(source.chars.size))
        fields = source.fields.clone(0.. Int32(source.fields.size))
        zero = source.zero
        length = source.length
    }

    public override func lengthMethod(): Int32 {
        return length
    }

    public func codePointCount(): Int32 {
        return Character.codePointCount(this, 0, lengthMethod())
    }

    public override func charAt(index: Int32): Char {
        if (!(index >= 0)) {
            throw AssertionError()
        }
        if (!(index < length)) {
            throw AssertionError()
        }
        return chars[Int64(zero + index)]
    }

    public func fieldAt(index: Int32): Object {
        if (!(index >= 0)) {
            throw AssertionError()
        }
        if (!(index < length)) {
            throw AssertionError()
        }
        return fields[Int64(zero + index)]
    }

    public func getFirstCodePoint(): Int32 {
        if (length == 0) {
            return -1
        }
        return Character.codePointAt(chars, zero, zero + length)
    }

    public func getLastCodePoint(): Int32 {
        if (length == 0) {
            return -1
        }
        return Character.codePointBefore(chars, zero + length, zero)
    }

    public func codePointAt(index: Int32): Int32 {
        return Character.codePointAt(chars, zero + index, zero + length)
    }

    public func codePointBefore(index: Int32): Int32 {
        return Character.codePointBefore(chars, zero + index, zero)
    }

    public func clear(): FormattedStringBuilder {
        zero = getCapacity() / 2
        length = 0
        return this
    }

    public func setAppendIndex(index: Int32): Unit {
        appendOffset = length - index
    }

    public func appendChar16(codeUnit: Char, field: Object): Int32 {
        return insertChar16(length - appendOffset, codeUnit, field)
    }

    public func insertChar16(index: Int32, codeUnit: Char, field: Object): Int32 {
        let count = 1
        let position = prepareForInsert(index, count)
        chars[Int64(position)] = codeUnit
        fields[Int64(position)] = field
        return count
    }

    public func appendCodePoint(codePoint: Int32, field: Object): Int32 {
        return insertCodePoint(length - appendOffset, codePoint, field)
    }

    public func insertCodePoint(index: Int32, codePoint: Int32, field: Object): Int32 {
        let count = Character.charCount(codePoint)
        let position = prepareForInsert(index, count)
        Character.toChars(codePoint, chars, position)
        fields[Int64(position)] = field
        if (count == 2) {
            fields[Int64(position + 1)] = field
        }
        return count
    }

    public func append(sequence: String, field: Object): Int32 {
        return insert(length - appendOffset, sequence, field)
    }

    public func insert(index: Int32, sequence: String, field: Object): Int32 {
        if (sequence.size == 0) {
            return 0
        } else if (sequence.size == 1) {
            return insertCodePoint(index, Int32(UInt32(sequence[0])), field)
        } else {
            return insert(index, sequence, 0, sequence.size, field)
        }
    }

    public func insert(index: Int32, sequence: String, start: Int32, end: Int32, field: Object): Int32 {
        let count = end - start
        let position = prepareForInsert(index, count)
        var i = 0
        while (i < count) {
            chars[Int64(position + i)] = sequence[start + i]
            fields[Int64(position + i)] = field
            i++
        }
        return count
    }

    public func splice(startThis: Int32, endThis: Int32, sequence: String, startOther: Int32, endOther: Int32, field: Object): Int32 {
        let thisLength = endThis - startThis
        let otherLength = endOther - startOther
        let count = otherLength - thisLength
        let position: Int32
        if (count > 0) {
            position = prepareForInsert(startThis, count)
        } else {
            position = remove(startThis, -count)
        }
        var i = 0
        while (i < otherLength) {
            chars[Int64(position + i)] = sequence[startOther + i]
            fields[Int64(position + i)] = field
            i++
        }
        return count
    }

    public func append(chars: Array<Char>, fields: Array<Object>): Int32 {
        return insert(length - appendOffset, chars, fields)
    }

    public func insert(index: Int32, chars: Array<Char>, fields: Array<Object>): Int32 {
        if (!(fields.isNone() || Int32(chars.size) == Int32(fields.size))) {
            throw AssertionError()
        }
        let count = Int32(chars.size)
        if (count == 0) {
            return 0
        }
        let position = prepareForInsert(index, count)
        var i = 0
        while (i < count) {
            this.chars[Int64(position + i)] = chars[Int64(i)]
            this.fields[Int64(position + i)] = if (fields.isNone()) { None } else { fields[Int64(i)] }
            i++
        }
        return count
    }

    public func append(other: FormattedStringBuilder): Int32 {
        return insert(length - appendOffset, other)
    }

    public func insert(index: Int32, other: FormattedStringBuilder): Int32 {
        if (refEq(this, other)) {
            throw IllegalArgumentException("Cannot call insert/append on myself")
        }
        let count = other.length
        if (count == 0) {
            return 0
        }
        let position = prepareForInsert(index, count)
        var i = 0
        while (i < count) {
            this.chars[Int64(position + i)] = other.toRuneArray()[i]
            this.fields[Int64(position + i)] = other.fieldAt(i)
            i++
        }
        return count
    }

    private func prepareForInsert(index: Int32, count: Int32): Int32 {
        var tempindex = index
        if (tempindex == -1) {
            tempindex = length
        }
        if (tempindex == 0 && zero - count >= 0) {
            zero -= count
            length += count
            return zero
        } else if (tempindex == length && zero + length + count < getCapacity()) {
            length += count
            return zero + length - count
        } else {
            return prepareForInsertHelper(tempindex, count)
        }
    }

    private func prepareForInsertHelper(index: Int32, count: Int32): Int32 {
        let oldCapacity = getCapacity()
        let oldZero = zero
        let oldChars = chars
        let oldFields = fields
        if (length + count > oldCapacity) {
            let newCapacity = (length + count) * 2
            let newZero = newCapacity / 2 - (length + count) / 2
            let newChars = Array<Char>(Int64(newCapacity)) { _ => '\u{0000}' }
            let newFields = Array<Object>(Int64(newCapacity))
            arraycopy(oldChars, Int64(oldZero), newChars, Int64(newZero), Int64(index))
            arraycopy(oldChars, Int64(oldZero + index), newChars, Int64(newZero + index + count), Int64(length - index))
            arraycopy(oldFields, Int64(oldZero), newFields, Int64(newZero), Int64(index))
            arraycopy(oldFields, Int64(oldZero + index), newFields, Int64(newZero + index + count), Int64(length - index))
            chars = newChars
            fields = newFields
            zero = newZero
            length += count
        } else {
            let newZero = oldCapacity / 2 - (length + count) / 2
            arraycopy(oldChars, Int64(oldZero), oldChars, Int64(newZero), Int64(length))
            arraycopy(oldChars, Int64(newZero + index), oldChars, Int64(newZero + index + count), Int64(length - index))
            arraycopy(oldFields, Int64(oldZero), oldFields, Int64(newZero), Int64(length))
            arraycopy(oldFields, Int64(newZero + index), oldFields, Int64(newZero + index + count), Int64(length - index))
            zero = newZero
            length += count
        }
        return zero + index
    }

    private func remove(index: Int32, count: Int32): Int32 {
        let position = index + zero
        arraycopy(chars, Int64(position + count), chars, Int64(position), Int64(length - index - count))
        arraycopy(fields, Int64(position + count), fields, Int64(position), Int64(length - index - count))
        length -= count
        return position
    }

    private func getCapacity(): Int32 {
        return Int32(chars.size)
    }

    
    public override func subSequence(start: Int32, end: Int32): String {
        if (!(start >= 0)) {
            throw AssertionError()
        }
        if (!(end <= length)) {
            throw AssertionError()
        }
        if (!(end >= start)) {
            throw AssertionError()
        }
        let other = FormattedStringBuilder(this)
        other.zero = zero + start
        other.length = end - start
        return other
    }

    public func subString(start: Int32, end: Int32): String {
        if (start < 0 || end > length || end < start) {
            throw IndexOutOfBoundsException()
        }
        return String(chars)[Int64(start + zero)..Int64(start + zero) + Int64(end - start)]
    }

    public override func toString(): String {
        return String(chars)[Int64(zero)..Int64(zero) + Int64(length)]
    }

    private static let fieldToDebugChar = HashMap<Object, Character>()


    public func toDebugString(): String {
        let sb = StringBuilder()
        sb.append("<FormattedStringBuilder [")
        sb.append(this.toString())
        sb.append("] [")
        var i = zero
        while (i < zero + length) {
            if (fields[Int64(i)].isNone()) {
                sb.append('n')
            } else if (fieldToDebugChar.contains(fields[Int64(i)])) {
                sb.append(fieldToDebugChar.get(fields[Int64(i)]))
            } else {
                sb.append('?')
            }
            i++
        }
        sb.append("]>")
        return sb.toString()
    }

    public func toCharArray(): Array<Char> {
        return chars.clone(zero..zero + length)
    }

    public func toFieldArray(): Array<Object> {
        return fields.clone(zero..zero + length)
    }

    public func setAppendableField(field: Object): Unit {
        appendableField = field
    }

    public override func append(csq: String): Appendable {
        if (!appendableField.isSome()) {
            throw AssertionError()
        }
        insert(length - appendOffset, csq, appendableField)
        return this
    }

    public override func append(csq: String, start: Int32, end: Int32): Appendable {
        if (!appendableField.isSome()) {
            throw AssertionError()
        }
        insert(length - appendOffset, csq, start, end, appendableField)
        return this
    }

    public override func append(c: Char): Appendable {
        if (!appendableField.isSome()) {
            throw AssertionError()
        }
        insertChar16(length - appendOffset, c, appendableField)
        return this
    }

    public func contentEquals(chars: Array<Char>, fields: Array<Object>): Bool {
        if (Int32(chars.size) != length) {
            return false
        }
        if (Int32(fields.size) != length) {
            return false
        }
        var i = 0
        while (i < length) {
            if (this.chars[Int64(zero + i)] != chars[Int64(i)]) {
                return false
            }
            if (!refEq(unwrapField(this.fields[Int64(zero + i)]), unwrapField(fields[Int64(i)]))) {
                return false
            }
            i++
        }
        return true
    }

    public func contentEquals(other: FormattedStringBuilder): Bool {
        if (length != other.length) {
            return false
        }
        var i = 0
        while (i < length) {
            if (charAt(i) != other.toRuneArray()[i]) {
                return false
            }
            if (!refEq(unwrapField(fieldAt(i)), unwrapField(other.fieldAt(i)))) {
                return false
            }
            i++
        }
        return true
    }

    public override func hashCode(): Int64 {
        throw UnsupportedOperationException("Don't call #hashCode() or #equals() on a mutable.")
    }

    public override func equals(other: Object): Bool {
        throw UnsupportedOperationException("Don't call #hashCode() or #equals() on a mutable.")
    }
}


public interface FormattedStringBuilder_FieldWrapper {
    func unwrap(): Format_Field
}