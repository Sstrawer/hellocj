package icu4cj.number


public abstract class NumberRangeFormatter {
    private static let BASE = UnlocalizedNumberRangeFormatter()

    public static func `with`(): UnlocalizedNumberRangeFormatter {
        return BASE
    }

    public static func withLocale(locale: Locale): LocalizedNumberRangeFormatter {
        return BASE.locale(locale)
    }

    public static func withLocale(locale: ULocale): LocalizedNumberRangeFormatter {
        return BASE.locale(locale)
    }

}


public class NumberRangeFormatter_RangeCollapse <: Enum<NumberRangeFormatter_RangeCollapse> {
    public static let AUTO = NumberRangeFormatter_RangeCollapse("AUTO", 0)

    public static let NONE = NumberRangeFormatter_RangeCollapse("NONE", 1)

    public static let UNIT = NumberRangeFormatter_RangeCollapse("UNIT", 2)

    public static let ALL = NumberRangeFormatter_RangeCollapse("ALL", 3)

    private static func _values(): Array<NumberRangeFormatter_RangeCollapse> {
        return [NumberRangeFormatter_RangeCollapse.AUTO, NumberRangeFormatter_RangeCollapse.NONE, NumberRangeFormatter_RangeCollapse.UNIT, NumberRangeFormatter_RangeCollapse.ALL]
    }

    private static let _VALUES = NumberRangeFormatter_RangeCollapse._values()

    public static func values(): Array<NumberRangeFormatter_RangeCollapse> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): NumberRangeFormatter_RangeCollapse {
        return (TypeInfo.of<NumberRangeFormatter_RangeCollapse>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as NumberRangeFormatter_RangeCollapse
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class NumberRangeFormatter_RangeIdentityFallback <: Enum<NumberRangeFormatter_RangeIdentityFallback> {
    public static let SINGLE_VALUE = NumberRangeFormatter_RangeIdentityFallback("SINGLE_VALUE", 0)

    public static let APPROXIMATELY_OR_SINGLE_VALUE = NumberRangeFormatter_RangeIdentityFallback("APPROXIMATELY_OR_SINGLE_VALUE", 1)

    public static let APPROXIMATELY = NumberRangeFormatter_RangeIdentityFallback("APPROXIMATELY", 2)

    public static let RANGE = NumberRangeFormatter_RangeIdentityFallback("RANGE", 3)

    private static func _values(): Array<NumberRangeFormatter_RangeIdentityFallback> {
        return [NumberRangeFormatter_RangeIdentityFallback.SINGLE_VALUE, NumberRangeFormatter_RangeIdentityFallback.APPROXIMATELY_OR_SINGLE_VALUE, NumberRangeFormatter_RangeIdentityFallback.APPROXIMATELY, NumberRangeFormatter_RangeIdentityFallback.RANGE]
    }

    private static let _VALUES = NumberRangeFormatter_RangeIdentityFallback._values()

    public static func values(): Array<NumberRangeFormatter_RangeIdentityFallback> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): NumberRangeFormatter_RangeIdentityFallback {
        return (TypeInfo.of<NumberRangeFormatter_RangeIdentityFallback>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as NumberRangeFormatter_RangeIdentityFallback
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class NumberRangeFormatter_RangeIdentityResult <: Enum<NumberRangeFormatter_RangeIdentityResult> {
    public static let EQUAL_BEFORE_ROUNDING = NumberRangeFormatter_RangeIdentityResult("EQUAL_BEFORE_ROUNDING", 0)

    public static let EQUAL_AFTER_ROUNDING = NumberRangeFormatter_RangeIdentityResult("EQUAL_AFTER_ROUNDING", 1)

    public static let NOT_EQUAL = NumberRangeFormatter_RangeIdentityResult("NOT_EQUAL", 2)

    private static func _values(): Array<NumberRangeFormatter_RangeIdentityResult> {
        return [NumberRangeFormatter_RangeIdentityResult.EQUAL_BEFORE_ROUNDING, NumberRangeFormatter_RangeIdentityResult.EQUAL_AFTER_ROUNDING, NumberRangeFormatter_RangeIdentityResult.NOT_EQUAL]
    }

    private static let _VALUES = NumberRangeFormatter_RangeIdentityResult._values()

    public static func values(): Array<NumberRangeFormatter_RangeIdentityResult> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): NumberRangeFormatter_RangeIdentityResult {
        return (TypeInfo.of<NumberRangeFormatter_RangeIdentityResult>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as NumberRangeFormatter_RangeIdentityResult
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class NumberRangeFormatter_SpanField <: UFormat_SpanField {
    private static let serialVersionUID = 8750397196515368729

    public static let NUMBER_RANGE_SPAN = NumberRangeFormatter_SpanField("number-range-span")

    private init(name: String) {
        super(name)
    }

    
    override protected func readResolve(): Object {
        if (this.getName().equals(NUMBER_RANGE_SPAN.getName())) {
            return NUMBER_RANGE_SPAN
        }
        throw InvalidObjectException("An invalid object.")
    }
}
