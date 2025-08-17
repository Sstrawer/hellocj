package icu4cj.impl.number

public class ConstantAffixModifier <: Modifier {
    public static let EMPTY = ConstantAffixModifier()

    private let prefix: String

    private let suffix: String

    private let field: Format_Field

    private let strong: Bool

    public init(prefix: String, suffix: String, field: Format_Field, strong: Bool) {
        this.prefix = (if (prefix.isNone()) { Some("") } else { prefix })
        this.suffix = (if (suffix.isNone()) { Some("") } else { suffix })
        this.field = field
        this.strong = strong
    }

    public init() {
        prefix = ""
        suffix = ""
        field = None
        strong = false
    }

    public override func apply(output: FormattedStringBuilder, leftIndex: Int32, rightIndex: Int32): Int32 {
        var length = output.insert(rightIndex, suffix, field)
        length += output.insert(leftIndex, prefix, field)
        return length
    }

    public override func getPrefixLength(): Int32 {
        return Int32(prefix.size)
    }

    public override func getCodePointCount(): Int32 {
        return prefix.codePointCount(0, Int32(prefix.size)) + suffix.codePointCount(0, Int32(suffix.size))
    }

    public override func isStrong(): Bool {
        return strong
    }

    public override func containsField(field: Format_Field): Bool {
        if (!false) {
            throw AssertionError()
        }
        return false
    }

    public override func getParameters(): Modifier_Parameters {
        return None
    }

    public override func strictEquals(other: Modifier): Bool {
        if (!(checkOptionalIs<ConstantAffixModifier, Modifier>(other))) {
            return false
        }
        let _other = other
        return prefix.equals(_other.prefix) && suffix.equals(_other.suffix) && refEq(field, _other.field) && strong == _other.strong
    }

    public override func toString(): String {
        return String.format("<ConstantAffixModifier prefix:'%s' suffix:'%s'>", [prefix, suffix])
    }
}
