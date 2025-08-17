package icu4cj.text


public class PersonNameFormatter {
    private let impl: PersonNameFormatterImpl

    public static func builder(): PersonNameFormatter_Builder {
        return PersonNameFormatter_Builder()
    }

    public func toBuilder(): PersonNameFormatter_Builder {
        let builder = builder()
        builder.setLocale(impl.getLocale())
        builder.setLength(impl.getLength())
        builder.setUsage(impl.getUsage())
        builder.setFormality(impl.getFormality())
        builder.setDisplayOrder(impl.getDisplayOrder())
        builder.setSurnameAllCaps(impl.getSurnameAllCaps())
        return builder
    }

    public func formatToString(name: PersonName): String {
        return impl.formatToString(name)
    }

    init(locale: Locale, length: PersonNameFormatter_Length, usage: PersonNameFormatter_Usage, formality: PersonNameFormatter_Formality, displayOrder: PersonNameFormatter_DisplayOrder, surnameAllCaps: Bool) {
        this.impl = PersonNameFormatterImpl(locale, length, usage, formality, displayOrder, surnameAllCaps)
    }

    
    public init(locale: Locale, gnFirstPatterns: Array<String>, snFirstPatterns: Array<String>, gnFirstLocales: Array<String>, snFirstLocales: Array<String>) {
        this.impl = PersonNameFormatterImpl(locale, gnFirstPatterns, snFirstPatterns, gnFirstLocales, snFirstLocales)
    }

    
    public override func toString(): String {
        return impl.toString()
    }
}


public class PersonNameFormatter_Length <: Enum<PersonNameFormatter_Length> {
    public static let LONG = PersonNameFormatter_Length("LONG", 0)

    public static let MEDIUM = PersonNameFormatter_Length("MEDIUM", 1)

    public static let SHORT = PersonNameFormatter_Length("SHORT", 2)

    public static let DEFAULT = PersonNameFormatter_Length("DEFAULT", 3)

    private static func _values(): Array<PersonNameFormatter_Length> {
        return [PersonNameFormatter_Length.LONG, PersonNameFormatter_Length.MEDIUM, PersonNameFormatter_Length.SHORT, PersonNameFormatter_Length.DEFAULT]
    }

    private static let _VALUES = PersonNameFormatter_Length._values()

    public static func values(): Array<PersonNameFormatter_Length> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): PersonNameFormatter_Length {
        return (TypeInfo.of<PersonNameFormatter_Length>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as PersonNameFormatter_Length
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class PersonNameFormatter_Usage <: Enum<PersonNameFormatter_Usage> {
    public static let ADDRESSING = PersonNameFormatter_Usage("ADDRESSING", 0)

    public static let REFERRING = PersonNameFormatter_Usage("REFERRING", 1)

    public static let MONOGRAM = PersonNameFormatter_Usage("MONOGRAM", 2)

    private static func _values(): Array<PersonNameFormatter_Usage> {
        return [PersonNameFormatter_Usage.ADDRESSING, PersonNameFormatter_Usage.REFERRING, PersonNameFormatter_Usage.MONOGRAM]
    }

    private static let _VALUES = PersonNameFormatter_Usage._values()

    public static func values(): Array<PersonNameFormatter_Usage> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): PersonNameFormatter_Usage {
        return (TypeInfo.of<PersonNameFormatter_Usage>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as PersonNameFormatter_Usage
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class PersonNameFormatter_Formality <: Enum<PersonNameFormatter_Formality> {
    public static let FORMAL = PersonNameFormatter_Formality("FORMAL", 0)

    public static let INFORMAL = PersonNameFormatter_Formality("INFORMAL", 1)

    public static let DEFAULT = PersonNameFormatter_Formality("DEFAULT", 2)

    private static func _values(): Array<PersonNameFormatter_Formality> {
        return [PersonNameFormatter_Formality.FORMAL, PersonNameFormatter_Formality.INFORMAL, PersonNameFormatter_Formality.DEFAULT]
    }

    private static let _VALUES = PersonNameFormatter_Formality._values()

    public static func values(): Array<PersonNameFormatter_Formality> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): PersonNameFormatter_Formality {
        return (TypeInfo.of<PersonNameFormatter_Formality>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as PersonNameFormatter_Formality
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class PersonNameFormatter_DisplayOrder <: Enum<PersonNameFormatter_DisplayOrder> {
    public static let DEFAULT = PersonNameFormatter_DisplayOrder("DEFAULT", 0)

    public static let SORTING = PersonNameFormatter_DisplayOrder("SORTING", 1)

    public static let FORCE_GIVEN_FIRST = PersonNameFormatter_DisplayOrder("FORCE_GIVEN_FIRST", 2)

    public static let FORCE_SURNAME_FIRST = PersonNameFormatter_DisplayOrder("FORCE_SURNAME_FIRST", 3)

    private static func _values(): Array<PersonNameFormatter_DisplayOrder> {
        return [PersonNameFormatter_DisplayOrder.DEFAULT, PersonNameFormatter_DisplayOrder.SORTING, PersonNameFormatter_DisplayOrder.FORCE_GIVEN_FIRST, PersonNameFormatter_DisplayOrder.FORCE_SURNAME_FIRST]
    }

    private static let _VALUES = PersonNameFormatter_DisplayOrder._values()

    public static func values(): Array<PersonNameFormatter_DisplayOrder> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): PersonNameFormatter_DisplayOrder {
        return (TypeInfo.of<PersonNameFormatter_DisplayOrder>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as PersonNameFormatter_DisplayOrder
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class PersonNameFormatter_Builder {
    public func setLocale(locale: Locale): PersonNameFormatter_Builder {
        if (locale.isSome()) {
            this.locale = locale
        }
        return this
    }

    public func setLength(length: PersonNameFormatter_Length): PersonNameFormatter_Builder {
        this.length = length
        return this
    }

    public func setUsage(usage: PersonNameFormatter_Usage): PersonNameFormatter_Builder {
        this.usage = usage
        return this
    }

    public func setFormality(formality: PersonNameFormatter_Formality): PersonNameFormatter_Builder {
        this.formality = formality
        return this
    }

    public func setDisplayOrder(order: PersonNameFormatter_DisplayOrder): PersonNameFormatter_Builder {
        this.displayOrder = order
        return this
    }

    public func setSurnameAllCaps(allCaps: Bool): PersonNameFormatter_Builder {
        this.surnameAllCaps = allCaps
        return this
    }

    public func build(): PersonNameFormatter {
        return PersonNameFormatter(locale, length, usage, formality, displayOrder, surnameAllCaps)
    }


    private var locale = Locale.getDefault()

    private var length: PersonNameFormatter_Length = PersonNameFormatter_Length.DEFAULT

    private var usage: PersonNameFormatter_Usage = PersonNameFormatter_Usage.REFERRING

    private var formality: PersonNameFormatter_Formality = PersonNameFormatter_Formality.DEFAULT

    private var displayOrder: PersonNameFormatter_DisplayOrder = PersonNameFormatter_DisplayOrder.DEFAULT

    private var surnameAllCaps = false
}
