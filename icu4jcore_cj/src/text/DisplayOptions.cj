package icu4cj.text

public class DisplayOptions {
    let grammaticalCase: DisplayOptions_GrammaticalCase

    let nounClass: DisplayOptions_NounClass

    let pluralCategory: DisplayOptions_PluralCategory

    let capitalization: DisplayOptions_Capitalization

    let nameStyle: DisplayOptions_NameStyle

    let displayLength: DisplayOptions_DisplayLength

    let substituteHandling: DisplayOptions_SubstituteHandling

    init(builder: DisplayOptions_Builder) {
        this.grammaticalCase = builder.grammaticalCase
        this.nounClass = builder.nounClass
        this.pluralCategory = builder.pluralCategory
        this.capitalization = builder.capitalization
        this.nameStyle = builder.nameStyle
        this.displayLength = builder.displayLength
        this.substituteHandling = builder.substituteHandling
    }

    public static func builder(): DisplayOptions_Builder {
        return DisplayOptions_Builder()
    }

    public func copyToBuilder(): DisplayOptions_Builder {
        return DisplayOptions_Builder(this)
    }

    public func getGrammaticalCase(): DisplayOptions_GrammaticalCase {
        return this.grammaticalCase
    }

    public func getNounClass(): DisplayOptions_NounClass {
        return this.nounClass
    }

    public func getPluralCategory(): DisplayOptions_PluralCategory {
        return this.pluralCategory
    }

    public func getCapitalization(): DisplayOptions_Capitalization {
        return this.capitalization
    }

    public func getNameStyle(): DisplayOptions_NameStyle {
        return this.nameStyle
    }

    public func getDisplayLength(): DisplayOptions_DisplayLength {
        return this.displayLength
    }

    public func getSubstituteHandling(): DisplayOptions_SubstituteHandling {
        return this.substituteHandling
    }
}


public class DisplayOptions_Builder {
    var grammaticalCase: DisplayOptions_GrammaticalCase

    var nounClass: DisplayOptions_NounClass

    var pluralCategory: DisplayOptions_PluralCategory

    var capitalization: DisplayOptions_Capitalization

    var nameStyle: DisplayOptions_NameStyle

    var displayLength: DisplayOptions_DisplayLength

    var substituteHandling: DisplayOptions_SubstituteHandling

    init() {
        this.grammaticalCase = DisplayOptions_GrammaticalCase.UNDEFINED
        this.nounClass = DisplayOptions_NounClass.UNDEFINED
        this.pluralCategory = DisplayOptions_PluralCategory.UNDEFINED
        this.capitalization = DisplayOptions_Capitalization.UNDEFINED
        this.nameStyle = DisplayOptions_NameStyle.UNDEFINED
        this.displayLength = DisplayOptions_DisplayLength.UNDEFINED
        this.substituteHandling = DisplayOptions_SubstituteHandling.UNDEFINED
    }

    init(displayOptions: DisplayOptions) {
        this.grammaticalCase = displayOptions.grammaticalCase
        this.nounClass = displayOptions.nounClass
        this.pluralCategory = displayOptions.pluralCategory
        this.capitalization = displayOptions.capitalization
        this.nameStyle = displayOptions.nameStyle
        this.displayLength = displayOptions.displayLength
        this.substituteHandling = displayOptions.substituteHandling
    }

    public func setGrammaticalCase(grammaticalCase: DisplayOptions_GrammaticalCase): DisplayOptions_Builder {
        this.grammaticalCase = grammaticalCase
        return this
    }

    public func setNounClass(nounClass: DisplayOptions_NounClass): DisplayOptions_Builder {
        this.nounClass = nounClass
        return this
    }

    public func setPluralCategory(pluralCategory: DisplayOptions_PluralCategory): DisplayOptions_Builder {
        this.pluralCategory = pluralCategory
        return this
    }

    public func setCapitalization(capitalization: DisplayOptions_Capitalization): DisplayOptions_Builder {
        this.capitalization = capitalization
        return this
    }

    public func setNameStyle(nameStyle: DisplayOptions_NameStyle): DisplayOptions_Builder {
        this.nameStyle = nameStyle
        return this
    }

    public func setDisplayLength(displayLength: DisplayOptions_DisplayLength): DisplayOptions_Builder {
        this.displayLength = displayLength
        return this
    }

    public func setSubstituteHandling(substituteHandling: DisplayOptions_SubstituteHandling): DisplayOptions_Builder {
        this.substituteHandling = substituteHandling
        return this
    }

    public func build(): DisplayOptions {
        let displayOptions = DisplayOptions(this)
        return displayOptions
    }
}


public class DisplayOptions_NounClass <: Enum<DisplayOptions_NounClass> {
    public static let UNDEFINED = DisplayOptions_NounClass("UNDEFINED", 0, "undefined")

    public static let OTHER = DisplayOptions_NounClass("OTHER", 1, "other")

    public static let NEUTER = DisplayOptions_NounClass("NEUTER", 2, "neuter")

    public static let FEMININE = DisplayOptions_NounClass("FEMININE", 3, "feminine")

    public static let MASCULINE = DisplayOptions_NounClass("MASCULINE", 4, "masculine")

    public static let ANIMATE = DisplayOptions_NounClass("ANIMATE", 5, "animate")

    public static let INANIMATE = DisplayOptions_NounClass("INANIMATE", 6, "inanimate")

    public static let PERSONAL = DisplayOptions_NounClass("PERSONAL", 7, "personal")

    public static let COMMON = DisplayOptions_NounClass("COMMON", 8, "common")

    private static func _values(): Array<DisplayOptions_NounClass> {
        return [DisplayOptions_NounClass.UNDEFINED, DisplayOptions_NounClass.OTHER, DisplayOptions_NounClass.NEUTER, DisplayOptions_NounClass.FEMININE, DisplayOptions_NounClass.MASCULINE, DisplayOptions_NounClass.ANIMATE, DisplayOptions_NounClass.INANIMATE, DisplayOptions_NounClass.PERSONAL, DisplayOptions_NounClass.COMMON]
    }

    private static let _VALUES = DisplayOptions_NounClass._values()

    public static func values(): Array<DisplayOptions_NounClass> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DisplayOptions_NounClass {
        return (TypeInfo.of<DisplayOptions_NounClass>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DisplayOptions_NounClass
    }

    private let identifier: String

    private init(_enum_name: String, _enum_ordinal: Int32, identifier: String) {
        super(_enum_name, _enum_ordinal)
        this.identifier = identifier
    }

    public static let VALUES = Collections.unmodifiableList(ArrayList(values()))

    public func getIdentifier(): String {
        return this.identifier
    }

    public static func fromIdentifier(identifier: String): DisplayOptions_NounClass {
        if (identifier.isNone()) {
            return DisplayOptions_NounClass.UNDEFINED
        }
        for (nounClass in VALUES) {
            if (identifier.equals(nounClass.getIdentifier())) {
                return nounClass
            }
        }
        return DisplayOptions_NounClass.UNDEFINED
    }
}


public class DisplayOptions_NameStyle <: Enum<DisplayOptions_NameStyle> {
    public static let UNDEFINED = DisplayOptions_NameStyle("UNDEFINED", 0)

    public static let STANDARD_NAMES = DisplayOptions_NameStyle("STANDARD_NAMES", 1)

    public static let DIALECT_NAMES = DisplayOptions_NameStyle("DIALECT_NAMES", 2)

    private static func _values(): Array<DisplayOptions_NameStyle> {
        return [DisplayOptions_NameStyle.UNDEFINED, DisplayOptions_NameStyle.STANDARD_NAMES, DisplayOptions_NameStyle.DIALECT_NAMES]
    }

    private static let _VALUES = DisplayOptions_NameStyle._values()

    public static func values(): Array<DisplayOptions_NameStyle> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DisplayOptions_NameStyle {
        return (TypeInfo.of<DisplayOptions_NameStyle>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DisplayOptions_NameStyle
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public static let VALUES = Collections.unmodifiableList(ArrayList(values()))
}


public class DisplayOptions_SubstituteHandling <: Enum<DisplayOptions_SubstituteHandling> {
    public static let UNDEFINED = DisplayOptions_SubstituteHandling("UNDEFINED", 0)

    public static let SUBSTITUTE = DisplayOptions_SubstituteHandling("SUBSTITUTE", 1)

    public static let NO_SUBSTITUTE = DisplayOptions_SubstituteHandling("NO_SUBSTITUTE", 2)

    private static func _values(): Array<DisplayOptions_SubstituteHandling> {
        return [DisplayOptions_SubstituteHandling.UNDEFINED, DisplayOptions_SubstituteHandling.SUBSTITUTE, DisplayOptions_SubstituteHandling.NO_SUBSTITUTE]
    }

    private static let _VALUES = DisplayOptions_SubstituteHandling._values()

    public static func values(): Array<DisplayOptions_SubstituteHandling> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DisplayOptions_SubstituteHandling {
        return (TypeInfo.of<DisplayOptions_SubstituteHandling>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DisplayOptions_SubstituteHandling
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public static let VALUES = Collections.unmodifiableList(ArrayList(values()))
}


public class DisplayOptions_DisplayLength <: Enum<DisplayOptions_DisplayLength> {
    public static let UNDEFINED = DisplayOptions_DisplayLength("UNDEFINED", 0)

    public static let LENGTH_FULL = DisplayOptions_DisplayLength("LENGTH_FULL", 1)

    public static let LENGTH_SHORT = DisplayOptions_DisplayLength("LENGTH_SHORT", 2)

    private static func _values(): Array<DisplayOptions_DisplayLength> {
        return [DisplayOptions_DisplayLength.UNDEFINED, DisplayOptions_DisplayLength.LENGTH_FULL, DisplayOptions_DisplayLength.LENGTH_SHORT]
    }

    private static let _VALUES = DisplayOptions_DisplayLength._values()

    public static func values(): Array<DisplayOptions_DisplayLength> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DisplayOptions_DisplayLength {
        return (TypeInfo.of<DisplayOptions_DisplayLength>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DisplayOptions_DisplayLength
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public static let VALUES = Collections.unmodifiableList(ArrayList(values()))
}


public class DisplayOptions_Capitalization <: Enum<DisplayOptions_Capitalization> {
    public static let UNDEFINED = DisplayOptions_Capitalization("UNDEFINED", 0)

    public static let BEGINNING_OF_SENTENCE = DisplayOptions_Capitalization("BEGINNING_OF_SENTENCE", 1)

    public static let MIDDLE_OF_SENTENCE = DisplayOptions_Capitalization("MIDDLE_OF_SENTENCE", 2)

    public static let STANDALONE = DisplayOptions_Capitalization("STANDALONE", 3)

    public static let UI_LIST_OR_MENU = DisplayOptions_Capitalization("UI_LIST_OR_MENU", 4)

    private static func _values(): Array<DisplayOptions_Capitalization> {
        return [DisplayOptions_Capitalization.UNDEFINED, DisplayOptions_Capitalization.BEGINNING_OF_SENTENCE, DisplayOptions_Capitalization.MIDDLE_OF_SENTENCE, DisplayOptions_Capitalization.STANDALONE, DisplayOptions_Capitalization.UI_LIST_OR_MENU]
    }

    private static let _VALUES = DisplayOptions_Capitalization._values()

    public static func values(): Array<DisplayOptions_Capitalization> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DisplayOptions_Capitalization {
        return (TypeInfo.of<DisplayOptions_Capitalization>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DisplayOptions_Capitalization
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    public static let VALUES = Collections.unmodifiableList(ArrayList(values()))
}


public class DisplayOptions_PluralCategory <: Enum<DisplayOptions_PluralCategory> {
    public static let UNDEFINED = DisplayOptions_PluralCategory("UNDEFINED", 0, "undefined")

    public static let ZERO = DisplayOptions_PluralCategory("ZERO", 1, "zero")

    public static let ONE = DisplayOptions_PluralCategory("ONE", 2, "one")

    public static let TWO = DisplayOptions_PluralCategory("TWO", 3, "two")

    public static let FEW = DisplayOptions_PluralCategory("FEW", 4, "few")

    public static let MANY = DisplayOptions_PluralCategory("MANY", 5, "many")

    public static let OTHER = DisplayOptions_PluralCategory("OTHER", 6, "other")

    private static func _values(): Array<DisplayOptions_PluralCategory> {
        return [DisplayOptions_PluralCategory.UNDEFINED, DisplayOptions_PluralCategory.ZERO, DisplayOptions_PluralCategory.ONE, DisplayOptions_PluralCategory.TWO, DisplayOptions_PluralCategory.FEW, DisplayOptions_PluralCategory.MANY, DisplayOptions_PluralCategory.OTHER]
    }

    private static let _VALUES = DisplayOptions_PluralCategory._values()

    public static func values(): Array<DisplayOptions_PluralCategory> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DisplayOptions_PluralCategory {
        return (TypeInfo.of<DisplayOptions_PluralCategory>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DisplayOptions_PluralCategory
    }

    private let identifier: String

    private init(_enum_name: String, _enum_ordinal: Int32, identifier: String) {
        super(_enum_name, _enum_ordinal)
        this.identifier = identifier
    }

    public static let VALUES = Collections.unmodifiableList(ArrayList(values()))

    public func getIdentifier(): String {
        return this.identifier
    }

    public static func fromIdentifier(identifier: String): DisplayOptions_PluralCategory {
        if (identifier.isNone()) {
            return DisplayOptions_PluralCategory.UNDEFINED
        }
        for (pluralCategory in VALUES) {
            if (identifier.equals(pluralCategory.getIdentifier())) {
                return pluralCategory
            }
        }
        return DisplayOptions_PluralCategory.UNDEFINED
    }
}


public class DisplayOptions_GrammaticalCase <: Enum<DisplayOptions_GrammaticalCase> {
    public static let UNDEFINED = DisplayOptions_GrammaticalCase("UNDEFINED", 0, "undefined")

    public static let ABLATIVE = DisplayOptions_GrammaticalCase("ABLATIVE", 1, "ablative")

    public static let ACCUSATIVE = DisplayOptions_GrammaticalCase("ACCUSATIVE", 2, "accusative")

    public static let COMITATIVE = DisplayOptions_GrammaticalCase("COMITATIVE", 3, "comitative")

    public static let DATIVE = DisplayOptions_GrammaticalCase("DATIVE", 4, "dative")

    public static let ERGATIVE = DisplayOptions_GrammaticalCase("ERGATIVE", 5, "ergative")

    public static let GENITIVE = DisplayOptions_GrammaticalCase("GENITIVE", 6, "genitive")

    public static let INSTRUMENTAL = DisplayOptions_GrammaticalCase("INSTRUMENTAL", 7, "instrumental")

    public static let LOCATIVE = DisplayOptions_GrammaticalCase("LOCATIVE", 8, "locative")

    public static let LOCATIVE_COPULATIVE = DisplayOptions_GrammaticalCase("LOCATIVE_COPULATIVE", 9, "locative_copulative")

    public static let NOMINATIVE = DisplayOptions_GrammaticalCase("NOMINATIVE", 10, "nominative")

    public static let OBLIQUE = DisplayOptions_GrammaticalCase("OBLIQUE", 11, "oblique")

    public static let PREPOSITIONAL = DisplayOptions_GrammaticalCase("PREPOSITIONAL", 12, "prepositional")

    public static let SOCIATIVE = DisplayOptions_GrammaticalCase("SOCIATIVE", 13, "sociative")

    public static let VOCATIVE = DisplayOptions_GrammaticalCase("VOCATIVE", 14, "vocative")

    private static func _values(): Array<DisplayOptions_GrammaticalCase> {
        return [DisplayOptions_GrammaticalCase.UNDEFINED, DisplayOptions_GrammaticalCase.ABLATIVE, DisplayOptions_GrammaticalCase.ACCUSATIVE, DisplayOptions_GrammaticalCase.COMITATIVE, DisplayOptions_GrammaticalCase.DATIVE, DisplayOptions_GrammaticalCase.ERGATIVE, DisplayOptions_GrammaticalCase.GENITIVE, DisplayOptions_GrammaticalCase.INSTRUMENTAL, DisplayOptions_GrammaticalCase.LOCATIVE, DisplayOptions_GrammaticalCase.LOCATIVE_COPULATIVE, DisplayOptions_GrammaticalCase.NOMINATIVE, DisplayOptions_GrammaticalCase.OBLIQUE, DisplayOptions_GrammaticalCase.PREPOSITIONAL, DisplayOptions_GrammaticalCase.SOCIATIVE, DisplayOptions_GrammaticalCase.VOCATIVE]
    }

    private static let _VALUES = DisplayOptions_GrammaticalCase._values()

    public static func values(): Array<DisplayOptions_GrammaticalCase> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DisplayOptions_GrammaticalCase {
        return (TypeInfo.of<DisplayOptions_GrammaticalCase>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DisplayOptions_GrammaticalCase
    }

    private let identifier: String

    private init(_enum_name: String, _enum_ordinal: Int32, identifier: String) {
        super(_enum_name, _enum_ordinal)
        this.identifier = identifier
    }

    public static let VALUES = Collections.unmodifiableList(ArrayList(values()))

    public func getIdentifier(): String {
        return this.identifier
    }

    public static func fromIdentifier(identifier: String): DisplayOptions_GrammaticalCase {
        if (identifier.isNone()) {
            return DisplayOptions_GrammaticalCase.UNDEFINED
        }
        for (grammaticalCase in VALUES) {
            if (identifier.equals(grammaticalCase.getIdentifier())) {
                return grammaticalCase
            }
        }
        return DisplayOptions_GrammaticalCase.UNDEFINED
    }
}
