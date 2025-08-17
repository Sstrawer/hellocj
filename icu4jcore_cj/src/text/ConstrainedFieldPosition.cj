package icu4cj.text

public class ConstrainedFieldPosition {
    private var fConstraint: ConstrainedFieldPosition_ConstraintType

    private var fClassConstraint: ClassTypeInfo

    private var fField: Format_Field = None

    private var fValue: Object

    private var fStart: Int32 = 0

    private var fLimit: Int32 = 0

    private var fContext: Int64 = 0

    public init() {
        reset()
    }

    public func reset(): Unit {
        fConstraint = ConstrainedFieldPosition_ConstraintType.NONE
        fClassConstraint = TypeInfo.of<Object>() as ClassTypeInfo
        fField = None
        fValue = None
        fStart = 0
        fLimit = 0
        fContext = 0
    }

    public func constrainField(field: Format_Field): Unit {
        if (field.isNone()) {
            throw IllegalArgumentException("Cannot constrain on null field")
        }
        fConstraint = ConstrainedFieldPosition_ConstraintType.FIELD
        fClassConstraint = TypeInfo.of<Object>() as ClassTypeInfo
        fField = field
        fValue = None
    }

    public func constrainClass(classConstraint: ClassTypeInfo): Unit {
        if (classConstraint.isNone()) {
            throw IllegalArgumentException("Cannot constrain on null field class")
        }
        fConstraint = ConstrainedFieldPosition_ConstraintType.CLASS
        fClassConstraint = classConstraint
        fField = None
        fValue = None
    }

    
    public func constrainFieldAndValue(field: Format_Field, fieldValue: Object): Unit {
        fConstraint = ConstrainedFieldPosition_ConstraintType.VALUE
        fClassConstraint = TypeInfo.of<Object>() as ClassTypeInfo
        fField = field
        fValue = fieldValue
    }

    public func getField(): Format_Field {
        return fField
    }

    public func getStart(): Int32 {
        return fStart
    }

    public func getLimit(): Int32 {
        return fLimit
    }

    public func getFieldValue(): Object {
        return fValue
    }

    public func getInt64IterationContext(): Int64 {
        return fContext
    }

    public func setInt64IterationContext(context: Int64): Unit {
        fContext = context
    }

    public func setState(field: Format_Field, value: Object, start: Int32, limit: Int32): Unit {
        if (field.isSome()) {
            if (!matchesField(field, value)) {
                throw AssertionError()
            }
        }
        fField = field
        fValue = value
        fStart = start
        fLimit = limit
    }

    public func matchesField(field: Format_Field, fieldValue: Object): Bool {
        if (field.isNone()) {
            throw IllegalArgumentException("field must not be null")
        }
        match (fConstraint) {
            case ConstrainedFieldPosition_ConstraintType.NONE => return true
            case ConstrainedFieldPosition_ConstraintType.CLASS => return fClassConstraint.isAssignableFrom(TypeInfo.of(field))
            case ConstrainedFieldPosition_ConstraintType.FIELD => return refEq(fField, field)
            case ConstrainedFieldPosition_ConstraintType.VALUE => return refEq(fField, field) && Objects.equals(fValue, fieldValue)
            case _ => throw AssertionError()
        }
    }

    public override func toString(): String {
        let sb = StringBuilder()
        sb.append("CFPos[")
        sb.append(fStart)
        sb.append('-')
        sb.append(fLimit)
        sb.append(' ')
        sb.append(fField)
        sb.append(']')
        return sb.toString()
    }
}


class ConstrainedFieldPosition_ConstraintType <: Enum<ConstrainedFieldPosition_ConstraintType> {
    public static let NONE = ConstrainedFieldPosition_ConstraintType("NONE", 0)

    public static let CLASS = ConstrainedFieldPosition_ConstraintType("CLASS", 1)

    public static let FIELD = ConstrainedFieldPosition_ConstraintType("FIELD", 2)

    public static let VALUE = ConstrainedFieldPosition_ConstraintType("VALUE", 3)

    private static func _values(): Array<ConstrainedFieldPosition_ConstraintType> {
        return [ConstrainedFieldPosition_ConstraintType.NONE, ConstrainedFieldPosition_ConstraintType.CLASS, ConstrainedFieldPosition_ConstraintType.FIELD, ConstrainedFieldPosition_ConstraintType.VALUE]
    }

    private static let _VALUES = ConstrainedFieldPosition_ConstraintType._values()

    public static func values(): Array<ConstrainedFieldPosition_ConstraintType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): ConstrainedFieldPosition_ConstraintType {
        return (TypeInfo.of<ConstrainedFieldPosition_ConstraintType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as ConstrainedFieldPosition_ConstraintType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
