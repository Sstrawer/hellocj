package icu4cj.number


public abstract class NumberFormatterSettings<T> {
    static let KEY_MACROS = 0

    static let KEY_LOCALE = 1

    static let KEY_NOTATION = 2

    static let KEY_UNIT = 3

    static let KEY_PRECISION = 4

    static let KEY_ROUNDING_MODE = 5

    static let KEY_GROUPING = 6

    static let KEY_PADDER = 7

    static let KEY_INTEGER = 8

    static let KEY_SYMBOLS = 9

    static let KEY_UNIT_WIDTH = 10

    static let KEY_SIGN = 11

    static let KEY_DECIMAL = 12

    static let KEY_SCALE = 13

    static let KEY_THRESHOLD = 14

    static let KEY_PER_UNIT = 15

    static let KEY_USAGE = 16

    static let KEY_UNIT_DISPLAY_CASE = 17

    static let KEY_MAX = 18

    private let parent: NumberFormatterSettings<NumberFormatterSettings>

    private let key: Int32

    private let value: Object

     private var resolvedMacros: MacroProps

    public init(parent: NumberFormatterSettings<NumberFormatterSettings>, key: Int32, value: Object) {
        this.parent = parent
        this.key = key
        this.value = value
    }

    public func notation(notation: Notation): T {
        return create(KEY_NOTATION, notation)
    }

    public func unit(unit: MeasureUnit): T {
        return create(KEY_UNIT, unit)
    }

    public func perUnit(perUnit: MeasureUnit): T {
        return create(KEY_PER_UNIT, perUnit)
    }

    public func precision(precision: Precision): T {
        return create(KEY_PRECISION, precision)
    }

    public func roundingMode(roundingMode: RoundingMode): T {
        return create(KEY_ROUNDING_MODE, roundingMode)
    }

    public func grouping(strategy: NumberFormatter_GroupingStrategy): T {
        return create(KEY_GROUPING, strategy)
    }

    public func integerWidth(style: IntegerWidth): T {
        return create(KEY_INTEGER, style)
    }

    public func symbols(symbols: DecimalFormatSymbols): T {
        var tempsymbols = symbols
        tempsymbols = tempsymbols.clone()
        return create(KEY_SYMBOLS, tempsymbols)
    }

    public func symbols(ns: NumberingSystem): T {
        return create(KEY_SYMBOLS, ns)
    }

    public func unitWidth(style: NumberFormatter_UnitWidth): T {
        return create(KEY_UNIT_WIDTH, style)
    }

    public func sign(style: NumberFormatter_SignDisplay): T {
        return create(KEY_SIGN, style)
    }

    public func decimal(style: NumberFormatter_DecimalSeparatorDisplay): T {
        return create(KEY_DECIMAL, style)
    }

    public func scale(scale: Scale): T {
        return create(KEY_SCALE, scale)
    }

    public func usage(usage: String): T {
        if (usage.isSome() && usage.isEmpty()) {
            return create(KEY_USAGE, None)
        }
        return create(KEY_USAGE, usage)
    }

    public func displayOptions(displayOptions: DisplayOptions): T {
        if (refEq(displayOptions.getGrammaticalCase(), DisplayOptions_GrammaticalCase.UNDEFINED)) {
            return create(KEY_UNIT_DISPLAY_CASE, None)
        }
        return create(KEY_UNIT_DISPLAY_CASE, displayOptions.getGrammaticalCase().getIdentifier())
    }

    
    public func unitDisplayCase(unitDisplayCase: String): T {
        return create(KEY_UNIT_DISPLAY_CASE, unitDisplayCase)
    }

    
    public func macros(macros: MacroProps): T {
        return create(KEY_MACROS, macros)
    }

    
    public func padding(padder: Padder): T {
        return create(KEY_PADDER, padder)
    }

    
    public func threshold(threshold: Int64): T {
        return create(KEY_THRESHOLD, threshold)
    }

    public func toSkeleton(): String {
        return NumberSkeletonImpl.generate(resolve())
    }

    public func create(key: Int32, value: Object): T

    public func resolve(): MacroProps {
        if (resolvedMacros.isSome()) {
            return resolvedMacros
        }
        let macros = MacroProps()
        var seen = 0
        var current: NumberFormatterSettings<NumberFormatterSettings> = this
        while ((current).isSome()) {
            let keyBitmask = (shl(1, Int64(current.key)))
            if (0 != (seen & keyBitmask)) {
                current = current.parent
                continue
            }
            seen |= keyBitmask
            match (current.key) {
                case 0 => macros.fallback(current.value)
                case 1 => macros.loc = current.value
                case 2 => macros.notation = current.value
                case 3 => macros.unit = current.value
                case 4 => macros.precision = current.value
                case 5 => macros.roundingMode = current.value
                case 6 => macros.grouping = current.value
                case 7 => macros.padder = current.value
                case 8 => macros.integerWidth = current.value
                case 9 => macros.symbols = current.value
                case 10 => macros.unitWidth = current.value
                case 11 => macros.sign = current.value
                case 12 => macros.decimal = current.value
                case 13 => macros.scale = current.value
                case 14 => macros.threshold = current.value
                case 15 => macros.perUnit = current.value
                case 16 => macros.usage = current.value
                case 17 => macros.unitDisplayCase = current.value
                case _ => throw Exception("Unknown key: " + current.key.toString())
            }
            current = current.parent
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
        if (!(checkOptionalIs<NumberFormatterSettings<Any>, Object>(other))) {
            return false
        }
        return resolve().equals((other).resolve())
    }
}