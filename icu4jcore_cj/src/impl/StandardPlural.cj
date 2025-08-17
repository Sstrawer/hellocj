package icu4cj.impl

public class StandardPlural <: Enum<StandardPlural> {
    public static let ZERO = StandardPlural("ZERO", 0, "zero")

    public static let ONE = StandardPlural("ONE", 1, "one")

    public static let TWO = StandardPlural("TWO", 2, "two")

    public static let FEW = StandardPlural("FEW", 3, "few")

    public static let MANY = StandardPlural("MANY", 4, "many")

    public static let OTHER = StandardPlural("OTHER", 5, "other")

    public static let EQ_0 = StandardPlural("EQ_0", 6, "=0")

    public static let EQ_1 = StandardPlural("EQ_1", 7, "=1")

    private static func _values(): Array<StandardPlural> {
        return [StandardPlural.ZERO, StandardPlural.ONE, StandardPlural.TWO, StandardPlural.FEW, StandardPlural.MANY, StandardPlural.OTHER, StandardPlural.EQ_0, StandardPlural.EQ_1]
    }

    private static let _VALUES = StandardPlural._values()

    public static func values(): Array<StandardPlural> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): StandardPlural {
        return (TypeInfo.of<StandardPlural>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as StandardPlural
    }

    public static let OTHER_INDEX = OTHER.ordinal

    public static let VALUES = Collections.unmodifiableList(ArrayList(values()))

    public static let COUNT = Int32(VALUES.size)

    private let keyword: String

    private init(_enum_name: String, _enum_ordinal: Int32, kw: String) {
        super(_enum_name, _enum_ordinal)
        keyword = kw
    }

    public func getKeyword(): String {
        return keyword
    }

    public static func orNullFromString(keyword: String): StandardPlural {
        match (keyword.size) {
            case 1 => if (keyword[0] == '0') {
                return EQ_0
            } else if (keyword[0] == '1') {
                return EQ_1
            }
            case 2 => if ("=0".contentEquals(keyword)) {
                return EQ_0
            } else if ("=1".contentEquals(keyword)) {
                return EQ_1
            }
            case 3 => if ("one".contentEquals(keyword)) {
                return ONE
            } else if ("two".contentEquals(keyword)) {
                return TWO
            } else if ("few".contentEquals(keyword)) {
                return FEW
            }
            case 4 => if ("many".contentEquals(keyword)) {
                return MANY
            } else if ("zero".contentEquals(keyword)) {
                return ZERO
            }
            case 5 => if ("other".contentEquals(keyword)) {
                return OTHER
            }
            case _ => ()
        }
        return None
    }

    public static func orOtherFromString(keyword: String): StandardPlural {
        let p = orNullFromString(keyword)
        return if (p.isSome()) { p } else { OTHER }
    }

    public static func fromString(keyword: String): StandardPlural {
        let p = orNullFromString(keyword)
        if (p.isSome()) {
            return p
        } else {
            throw IllegalArgumentException(toString(keyword))
        }
    }

    public static func indexOrNegativeFromString(keyword: String): Int32 {
        let p = orNullFromString(keyword)
        return if (p.isSome()) { p.ordinal } else { -1 }
    }

    public static func indexOrOtherIndexFromString(keyword: String): Int32 {
        let p = orNullFromString(keyword)
        return if (p.isSome()) { p.ordinal } else { OTHER.ordinal }
    }

    public static func indexFromString(keyword: String): Int32 {
        let p = orNullFromString(keyword)
        if (p.isSome()) {
            return p.ordinal
        } else {
            throw IllegalArgumentException(toString(keyword))
        }
    }
}
