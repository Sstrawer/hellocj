package icu4cj.impl.number


public class SimpleModifier <: Modifier {
    private let compiledPattern: String

    private let field: Format_Field

    private let strong: Bool

    private let parameters: Modifier_Parameters

    private static let ARG_NUM_LIMIT = 256

    public init(compiledPattern: String, field: Format_Field, strong: Bool) {
        this(compiledPattern, field, strong, None)
    }

    public init(compiledPattern: String, field: Format_Field, strong: Bool, parameters: Modifier_Parameters) {
        if (!compiledPattern.isSome()) {
            throw AssertionError()
        }
        this.compiledPattern = compiledPattern
        this.field = field
        this.strong = strong
        this.parameters = parameters
    }

    public override func apply(output: FormattedStringBuilder, leftIndex: Int32, rightIndex: Int32): Int32 {
        return SimpleFormatterImpl.formatPrefixSuffix(compiledPattern, field, leftIndex, rightIndex, output)
    }

    public override func getPrefixLength(): Int32 {
        return SimpleFormatterImpl.getPrefixLength(compiledPattern)
    }

    public override func getCodePointCount(): Int32 {
        return SimpleFormatterImpl.getLength(compiledPattern, true)
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
        return parameters
    }

    public override func strictEquals(other: Modifier): Bool {
        if (!(checkOptionalIs<SimpleModifier, Modifier>(other))) {
            return false
        }
        let _other = other
        return compiledPattern.equals(_other.compiledPattern) && refEq(field, _other.field) && strong == _other.strong
    }

    public static func formatTwoArgPattern(compiledPattern: String, result: FormattedStringBuilder, index: Int32, h: PrefixInfixSuffixLengthHelper, field: Format_Field): Unit {
        let argLimit = SimpleFormatterImpl.getArgumentLimit(compiledPattern)
        if (argLimit != 2) {
            throw ICUException()
        }
        var offset = 1
        var length = 0
        var prefixLength = Int32(UInt32(Char(compiledPattern[Int64(offset)])))
        offset++
        if (prefixLength < ARG_NUM_LIMIT) {
            prefixLength = 0
        } else {
            prefixLength -= ARG_NUM_LIMIT
            result.insert(index + length, compiledPattern, offset, offset + prefixLength, field)
            offset += prefixLength
            length += prefixLength
            offset++
        }
        var infixLength = Int32(UInt32(Char(compiledPattern[Int64(offset)])))
        offset++
        if (infixLength < ARG_NUM_LIMIT) {
            infixLength = 0
        } else {
            infixLength -= ARG_NUM_LIMIT
            result.insert(index + length, compiledPattern, offset, offset + infixLength, field)
            offset += infixLength
            length += infixLength
            offset++
        }
        let suffixLength: Int32
        if (offset == Int32(compiledPattern.size)) {
            suffixLength = 0
        } else {
            suffixLength = Int32(UInt32(Char(compiledPattern[Int64(offset)]))) - ARG_NUM_LIMIT
            offset++
            result.insert(index + length, compiledPattern, offset, offset + suffixLength, field)
            length += suffixLength
        }
        h.lengthPrefix = prefixLength
        h.lengthInfix = infixLength
        h.lengthSuffix = suffixLength
    }
}
