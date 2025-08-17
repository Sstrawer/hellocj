package icu4cj.text

public interface PersonName {
    public func getNameLocale(): Locale

    public func getPreferredOrder(): PersonName_PreferredOrder

    public func getFieldValue(identifier: PersonName_NameField, modifiers: Set<PersonName_FieldModifier>): String
}

public static class PersonName_NameField <: Enum<PersonName_NameField> {
    public static let TITLE = PersonName_NameField("TITLE", 0, "title")

    public static let GIVEN = PersonName_NameField("GIVEN", 1, "given")

    public static let GIVEN2 = PersonName_NameField("GIVEN2", 2, "given2")

    public static let SURNAME = PersonName_NameField("SURNAME", 3, "surname")

    public static let SURNAME2 = PersonName_NameField("SURNAME2", 4, "surname2")

    public static let GENERATION = PersonName_NameField("GENERATION", 5, "generation")

    public static let CREDENTIALS = PersonName_NameField("CREDENTIALS", 6, "credentials")

    private static func _values(): Array<PersonName_NameField> {
        return [PersonName_NameField.TITLE, PersonName_NameField.GIVEN, PersonName_NameField.GIVEN2, PersonName_NameField.SURNAME, PersonName_NameField.SURNAME2, PersonName_NameField.GENERATION, PersonName_NameField.CREDENTIALS]
    }

    private static let _VALUES = PersonName_NameField._values()

    public static func values(): Array<PersonName_NameField> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): PersonName_NameField {
        return (TypeInfo.of<PersonName_NameField>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as PersonName_NameField
    }

    private let name: String

    private init(_enum_name: String, _enum_ordinal: Int32, name: String) {
        super(_enum_name, _enum_ordinal)
        this.name = name
    }

    public override func toString(): String {
        return name
    }

    
    public static func forString(name: String): PersonName_NameField {
        for (field in values()) {
            if (field.name.equals(name)) {
                return field
            }
        }
        throw IllegalArgumentException("Invalid field name " + (name))
    }
}


public static class PersonName_FieldModifier <: Enum<PersonName_FieldModifier> {
    public static let INFORMAL = PersonName_FieldModifier("INFORMAL", 0, "informal")

    public static let PREFIX = PersonName_FieldModifier("PREFIX", 1, "prefix")

    public static let CORE = PersonName_FieldModifier("CORE", 2, "core")

    public static let INITIAL = PersonName_FieldModifier("INITIAL", 3, "initial")

    public static let MONOGRAM = PersonName_FieldModifier("MONOGRAM", 4, "monogram")

    public static let ALL_CAPS = PersonName_FieldModifier("ALL_CAPS", 5, "allCaps")

    
    public static let RETAIN = PersonName_FieldModifier("RETAIN", 6, "retain")

    public static let INITIAL_CAP = PersonName_FieldModifier("INITIAL_CAP", 7, "initialCap")

    public static let GENITIVE = PersonName_FieldModifier("GENITIVE", 8, "genitive")

    public static let VOCATIVE = PersonName_FieldModifier("VOCATIVE", 9, "vocative")

    private static func _values(): Array<PersonName_FieldModifier> {
        return [PersonName_FieldModifier.INFORMAL, PersonName_FieldModifier.PREFIX, PersonName_FieldModifier.CORE, PersonName_FieldModifier.INITIAL, PersonName_FieldModifier.MONOGRAM, PersonName_FieldModifier.ALL_CAPS, PersonName_FieldModifier.RETAIN, PersonName_FieldModifier.INITIAL_CAP, PersonName_FieldModifier.GENITIVE, PersonName_FieldModifier.VOCATIVE]
    }

    private static let _VALUES = PersonName_FieldModifier._values()

    public static func values(): Array<PersonName_FieldModifier> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): PersonName_FieldModifier {
        return (TypeInfo.of<PersonName_FieldModifier>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as PersonName_FieldModifier
    }

    private let name: String

    private init(_enum_name: String, _enum_ordinal: Int32, name: String) {
        super(_enum_name, _enum_ordinal)
        this.name = name
    }

    public override func toString(): String {
        return name
    }

    public static func forString(name: String): PersonName_FieldModifier {
        for (modifier in values()) {
            if (modifier.name.equals(name)) {
                return modifier
            }
        }
        throw IllegalArgumentException("Invalid modifier name " + (name))
    }
}


public static class PersonName_PreferredOrder <: Enum<PersonName_PreferredOrder> {
    public static let DEFAULT = PersonName_PreferredOrder("DEFAULT", 0)

    public static let GIVEN_FIRST = PersonName_PreferredOrder("GIVEN_FIRST", 1)

    public static let SURNAME_FIRST = PersonName_PreferredOrder("SURNAME_FIRST", 2)

    private static func _values(): Array<PersonName_PreferredOrder> {
        return [PersonName_PreferredOrder.DEFAULT, PersonName_PreferredOrder.GIVEN_FIRST, PersonName_PreferredOrder.SURNAME_FIRST]
    }

    private static let _VALUES = PersonName_PreferredOrder._values()

    public static func values(): Array<PersonName_PreferredOrder> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): PersonName_PreferredOrder {
        return (TypeInfo.of<PersonName_PreferredOrder>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as PersonName_PreferredOrder
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
