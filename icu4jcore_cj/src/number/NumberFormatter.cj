package icu4cj.number


public class NumberFormatter {
    private static let BASE = UnlocalizedNumberFormatter()

    static let DEFAULT_THRESHOLD = 3


    public static func `with`(): UnlocalizedNumberFormatter {
        return BASE
    }

    public static func withLocale(locale: Locale): LocalizedNumberFormatter {
        return BASE.locale(locale)
    }

    public static func withLocale(locale: ULocale): LocalizedNumberFormatter {
        return BASE.locale(locale)
    }

    public static func forSkeleton(skeleton: String): UnlocalizedNumberFormatter {
        return NumberSkeletonImpl.getOrCreate(skeleton)
    }

    
    public static func fromDecimalFormat(properties: DecimalFormatProperties, symbols: DecimalFormatSymbols, exportedProperties: DecimalFormatProperties): UnlocalizedNumberFormatter {
        return NumberPropertyMapper.create(properties, symbols, exportedProperties)
    }
}


public class NumberFormatter_RoundingPriority <: Enum<NumberFormatter_RoundingPriority> {
    public static let RELAXED = NumberFormatter_RoundingPriority("RELAXED", 0)

    public static let STRICT = NumberFormatter_RoundingPriority("STRICT", 1)

    private static func _values(): Array<NumberFormatter_RoundingPriority> {
        return [NumberFormatter_RoundingPriority.RELAXED, NumberFormatter_RoundingPriority.STRICT]
    }

    private static let _VALUES = NumberFormatter_RoundingPriority._values()

    public static func values(): Array<NumberFormatter_RoundingPriority> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): NumberFormatter_RoundingPriority {
        return (TypeInfo.of<NumberFormatter_RoundingPriority>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as NumberFormatter_RoundingPriority
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class NumberFormatter_UnitWidth <: Enum<NumberFormatter_UnitWidth> {
    public static let NARROW = NumberFormatter_UnitWidth("NARROW", 0)

    public static let SHORT = NumberFormatter_UnitWidth("SHORT", 1)

    public static let FULL_NAME = NumberFormatter_UnitWidth("FULL_NAME", 2)

    public static let ISO_CODE = NumberFormatter_UnitWidth("ISO_CODE", 3)

    public static let FORMAL = NumberFormatter_UnitWidth("FORMAL", 4)

    public static let VARIANT = NumberFormatter_UnitWidth("VARIANT", 5)

    public static let HIDDEN = NumberFormatter_UnitWidth("HIDDEN", 6)

    private static func _values(): Array<NumberFormatter_UnitWidth> {
        return [NumberFormatter_UnitWidth.NARROW, NumberFormatter_UnitWidth.SHORT, NumberFormatter_UnitWidth.FULL_NAME, NumberFormatter_UnitWidth.ISO_CODE, NumberFormatter_UnitWidth.FORMAL, NumberFormatter_UnitWidth.VARIANT, NumberFormatter_UnitWidth.HIDDEN]
    }

    private static let _VALUES = NumberFormatter_UnitWidth._values()

    public static func values(): Array<NumberFormatter_UnitWidth> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): NumberFormatter_UnitWidth {
        return (TypeInfo.of<NumberFormatter_UnitWidth>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as NumberFormatter_UnitWidth
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class NumberFormatter_GroupingStrategy <: Enum<NumberFormatter_GroupingStrategy> {
    public static let OFF = NumberFormatter_GroupingStrategy("OFF", 0)

    public static let MIN2 = NumberFormatter_GroupingStrategy("MIN2", 1)

    public static let AUTO = NumberFormatter_GroupingStrategy("AUTO", 2)

    public static let ON_ALIGNED = NumberFormatter_GroupingStrategy("ON_ALIGNED", 3)

    public static let THOUSANDS = NumberFormatter_GroupingStrategy("THOUSANDS", 4)

    private static func _values(): Array<NumberFormatter_GroupingStrategy> {
        return [NumberFormatter_GroupingStrategy.OFF, NumberFormatter_GroupingStrategy.MIN2, NumberFormatter_GroupingStrategy.AUTO, NumberFormatter_GroupingStrategy.ON_ALIGNED, NumberFormatter_GroupingStrategy.THOUSANDS]
    }

    private static let _VALUES = NumberFormatter_GroupingStrategy._values()

    public static func values(): Array<NumberFormatter_GroupingStrategy> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): NumberFormatter_GroupingStrategy {
        return (TypeInfo.of<NumberFormatter_GroupingStrategy>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as NumberFormatter_GroupingStrategy
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class NumberFormatter_SignDisplay <: Enum<NumberFormatter_SignDisplay> {
    public static let AUTO = NumberFormatter_SignDisplay("AUTO", 0)

    public static let ALWAYS = NumberFormatter_SignDisplay("ALWAYS", 1)

    public static let NEVER = NumberFormatter_SignDisplay("NEVER", 2)

    public static let ACCOUNTING = NumberFormatter_SignDisplay("ACCOUNTING", 3)

    public static let ACCOUNTING_ALWAYS = NumberFormatter_SignDisplay("ACCOUNTING_ALWAYS", 4)

    public static let EXCEPT_ZERO = NumberFormatter_SignDisplay("EXCEPT_ZERO", 5)

    public static let ACCOUNTING_EXCEPT_ZERO = NumberFormatter_SignDisplay("ACCOUNTING_EXCEPT_ZERO", 6)

    public static let NEGATIVE = NumberFormatter_SignDisplay("NEGATIVE", 7)

    public static let ACCOUNTING_NEGATIVE = NumberFormatter_SignDisplay("ACCOUNTING_NEGATIVE", 8)

    private static func _values(): Array<NumberFormatter_SignDisplay> {
        return [NumberFormatter_SignDisplay.AUTO, NumberFormatter_SignDisplay.ALWAYS, NumberFormatter_SignDisplay.NEVER, NumberFormatter_SignDisplay.ACCOUNTING, NumberFormatter_SignDisplay.ACCOUNTING_ALWAYS, NumberFormatter_SignDisplay.EXCEPT_ZERO, NumberFormatter_SignDisplay.ACCOUNTING_EXCEPT_ZERO, NumberFormatter_SignDisplay.NEGATIVE, NumberFormatter_SignDisplay.ACCOUNTING_NEGATIVE]
    }

    private static let _VALUES = NumberFormatter_SignDisplay._values()

    public static func values(): Array<NumberFormatter_SignDisplay> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): NumberFormatter_SignDisplay {
        return (TypeInfo.of<NumberFormatter_SignDisplay>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as NumberFormatter_SignDisplay
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class NumberFormatter_DecimalSeparatorDisplay <: Enum<NumberFormatter_DecimalSeparatorDisplay> {
    public static let AUTO = NumberFormatter_DecimalSeparatorDisplay("AUTO", 0)

    public static let ALWAYS = NumberFormatter_DecimalSeparatorDisplay("ALWAYS", 1)

    private static func _values(): Array<NumberFormatter_DecimalSeparatorDisplay> {
        return [NumberFormatter_DecimalSeparatorDisplay.AUTO, NumberFormatter_DecimalSeparatorDisplay.ALWAYS]
    }

    private static let _VALUES = NumberFormatter_DecimalSeparatorDisplay._values()

    public static func values(): Array<NumberFormatter_DecimalSeparatorDisplay> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): NumberFormatter_DecimalSeparatorDisplay {
        return (TypeInfo.of<NumberFormatter_DecimalSeparatorDisplay>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as NumberFormatter_DecimalSeparatorDisplay
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class NumberFormatter_TrailingZeroDisplay <: Enum<NumberFormatter_TrailingZeroDisplay> {
    public static let AUTO = NumberFormatter_TrailingZeroDisplay("AUTO", 0)

    public static let HIDE_IF_WHOLE = NumberFormatter_TrailingZeroDisplay("HIDE_IF_WHOLE", 1)

    private static func _values(): Array<NumberFormatter_TrailingZeroDisplay> {
        return [NumberFormatter_TrailingZeroDisplay.AUTO, NumberFormatter_TrailingZeroDisplay.HIDE_IF_WHOLE]
    }

    private static let _VALUES = NumberFormatter_TrailingZeroDisplay._values()

    public static func values(): Array<NumberFormatter_TrailingZeroDisplay> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): NumberFormatter_TrailingZeroDisplay {
        return (TypeInfo.of<NumberFormatter_TrailingZeroDisplay>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as NumberFormatter_TrailingZeroDisplay
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
