package icu4cj.number


public abstract class NumberRangeFormatterSettings<T> {
    static let KEY_MACROS = 0

    static let KEY_LOCALE = 1

    static let KEY_FORMATTER_1 = 2

    static let KEY_FORMATTER_2 = 3

    static let KEY_SAME_FORMATTERS = 4

    static let KEY_COLLAPSE = 5

    static let KEY_IDENTITY_FALLBACK = 6

    static let KEY_MAX = 7

    private let parent: NumberRangeFormatterSettings<NumberRangeFormatterSettings>

    private let key: Int32

    private let value: Object

     private var resolvedMacros: RangeMacroProps

    public init(parent: NumberRangeFormatterSettings<NumberRangeFormatterSettings>, key: Int32, value: Object) {
        this.parent = parent
        this.key = key
        this.value = value
    }

    public func numberFormatterBoth(formatter: UnlocalizedNumberFormatter): T {
        return create(KEY_SAME_FORMATTERS, Bool.valueOf(true)).create(KEY_FORMATTER_1, formatter)
    }

    public func numberFormatterFirst(formatterFirst: UnlocalizedNumberFormatter): T {
        return create(KEY_SAME_FORMATTERS, Bool.valueOf(false)).create(KEY_FORMATTER_1, formatterFirst)
    }

    public func numberFormatterSecond(formatterSecond: UnlocalizedNumberFormatter): T {
        return create(KEY_SAME_FORMATTERS, Bool.valueOf(false)).create(KEY_FORMATTER_2, formatterSecond)
    }

    public func collapse(collapse: NumberRangeFormatter_RangeCollapse): T {
        return create(KEY_COLLAPSE, collapse)
    }

    public func identityFallback(identityFallback: NumberRangeFormatter_RangeIdentityFallback): T {
        return create(KEY_IDENTITY_FALLBACK, identityFallback)
    }

    public func create(key: Int32, value: Object): T

    public func resolve(): RangeMacroProps {
        if (resolvedMacros.isSome()) {
            return resolvedMacros
        }
        let macros = RangeMacroProps()
        var seen = 0
        var current: NumberRangeFormatterSettings<NumberRangeFormatterSettings> = this
        while ((current).isSome()) {
            let keyBitmask = (shl(1, Int64(current.key)))
            if (0 != (seen & keyBitmask)) {
                current = current.parent
                continue
            }
            seen |= keyBitmask
            match (current.key) {
                case 0 => ()
                case 1 => macros.loc = current.value
                case 2 => macros.formatter1 = current.value
                case 3 => macros.formatter2 = current.value
                case 4 => macros.sameFormatters = if (current.value.booleanValue()) { 1 } else { 0 }
                case 5 => macros.collapse = current.value
                case 6 => macros.identityFallback = current.value
                case _ => throw Exception("Unknown key: " + current.key.toString())
            }
            current = current.parent
        }
        if (macros.formatter1.isSome()) {
            macros.formatter1.resolve().loc = macros.loc
        }
        if (macros.formatter2.isSome()) {
            macros.formatter2.resolve().loc = macros.loc
        }
        resolvedMacros = macros
        return macros
    }

    public override func hashCode(): Int64 {
        return resolve().hashCode()
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (other.isNone()) {
            return false
        }
        if (!(checkOptionalIs<NumberRangeFormatterSettings<Any>, Object>(other))) {
            return false
        }
        return resolve().equals((other).resolve())
    }
}