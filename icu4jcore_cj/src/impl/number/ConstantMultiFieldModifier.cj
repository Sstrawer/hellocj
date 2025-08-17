package icu4cj.impl.number

public class ConstantMultiFieldModifier <: Modifier {
    protected let prefixChars: Array<Char>

    protected let suffixChars: Array<Char>

    protected let prefixFields: Array<Object>

    protected let suffixFields: Array<Object>

    private let overwrite: Bool

    private let strong: Bool

    private let parameters: Modifier_Parameters

    public init(prefix: FormattedStringBuilder, suffix: FormattedStringBuilder, overwrite: Bool, strong: Bool) {
        this(prefix, suffix, overwrite, strong, None)
    }

    public init(prefix: FormattedStringBuilder, suffix: FormattedStringBuilder, overwrite: Bool, strong: Bool, parameters: Modifier_Parameters) {
        prefixChars = prefix.toCharArray()
        suffixChars = suffix.toCharArray()
        prefixFields = prefix.toFieldArray()
        suffixFields = suffix.toFieldArray()
        this.overwrite = overwrite
        this.strong = strong
        this.parameters = parameters
    }

    public override func apply(output: FormattedStringBuilder, leftIndex: Int32, rightIndex: Int32): Int32 {
        var length = output.insert(leftIndex, prefixChars, prefixFields)
        if (overwrite) {
            length += output.splice(leftIndex + length, rightIndex + length, "", 0, 0, None)
        }
        length += output.insert(rightIndex + length, suffixChars, suffixFields)
        return length
    }

    public override func getPrefixLength(): Int32 {
        return Int32(prefixChars.size)
    }

    public override func getCodePointCount(): Int32 {
        return Character.codePointCount(prefixChars, 0, Int32(prefixChars.size)) + Character.codePointCount(suffixChars, 0, Int32(suffixChars.size))
    }

    public override func isStrong(): Bool {
        return strong
    }

    public override func containsField(field: Format_Field): Bool {
        var i = 0
        while (i < Int32(prefixFields.size)) {
            if (prefixFields[Int64(i)] == field) {
                return true
            }
            i++
        }
        i = 0
        while (i < Int32(suffixFields.size)) {
            if (suffixFields[Int64(i)] == field) {
                return true
            }
            i++
        }
        return false
    }

    public override func getParameters(): Modifier_Parameters {
        return parameters
    }

    public override func strictEquals(other: Modifier): Bool {
        if (!(checkOptionalIs<ConstantMultiFieldModifier, Modifier>(other))) {
            return false
        }
        let _other = other
        return prefixChars == _other.prefixChars && prefixFields == _other.prefixFields && suffixChars == _other.suffixChars && suffixFields == _other.suffixFields && overwrite == _other.overwrite && strong == _other.strong
    }

    public override func toString(): String {
        let temp = FormattedStringBuilder()
        apply(temp, 0, 0)
        let prefixLength = getPrefixLength()
        return String.format("<ConstantMultiFieldModifier prefix:'%s' suffix:'%s'>", [temp.subSequence(0, prefixLength), temp.subSequence(prefixLength, temp.lengthMethod())])
    }
}
