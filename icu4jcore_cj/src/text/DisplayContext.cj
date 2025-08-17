package icu4cj.text

public class DisplayContext <: Enum<DisplayContext> {
    public static let STANDARD_NAMES = DisplayContext("STANDARD_NAMES", 0, DisplayContext_Type.DIALECT_HANDLING, 0)

    public static let DIALECT_NAMES = DisplayContext("DIALECT_NAMES", 1, DisplayContext_Type.DIALECT_HANDLING, 1)

    public static let CAPITALIZATION_NONE = DisplayContext("CAPITALIZATION_NONE", 2, DisplayContext_Type.CAPITALIZATION, 0)

    public static let CAPITALIZATION_FOR_MIDDLE_OF_SENTENCE = DisplayContext("CAPITALIZATION_FOR_MIDDLE_OF_SENTENCE", 3, DisplayContext_Type.CAPITALIZATION, 1)

    public static let CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE = DisplayContext("CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE", 4, DisplayContext_Type.CAPITALIZATION, 2)

    public static let CAPITALIZATION_FOR_UI_LIST_OR_MENU = DisplayContext("CAPITALIZATION_FOR_UI_LIST_OR_MENU", 5, DisplayContext_Type.CAPITALIZATION, 3)

    public static let CAPITALIZATION_FOR_STANDALONE = DisplayContext("CAPITALIZATION_FOR_STANDALONE", 6, DisplayContext_Type.CAPITALIZATION, 4)

    public static let LENGTH_FULL = DisplayContext("LENGTH_FULL", 7, DisplayContext_Type.DISPLAY_LENGTH, 0)

    public static let LENGTH_SHORT = DisplayContext("LENGTH_SHORT", 8, DisplayContext_Type.DISPLAY_LENGTH, 1)

    public static let SUBSTITUTE = DisplayContext("SUBSTITUTE", 9, DisplayContext_Type.SUBSTITUTE_HANDLING, 0)

    public static let NO_SUBSTITUTE = DisplayContext("NO_SUBSTITUTE", 10, DisplayContext_Type.SUBSTITUTE_HANDLING, 1)

    private static func _values(): Array<DisplayContext> {
        return [DisplayContext.STANDARD_NAMES, DisplayContext.DIALECT_NAMES, DisplayContext.CAPITALIZATION_NONE, DisplayContext.CAPITALIZATION_FOR_MIDDLE_OF_SENTENCE, DisplayContext.CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE, DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU, DisplayContext.CAPITALIZATION_FOR_STANDALONE, DisplayContext.LENGTH_FULL, DisplayContext.LENGTH_SHORT, DisplayContext.SUBSTITUTE, DisplayContext.NO_SUBSTITUTE]
    }

    private static let _VALUES = DisplayContext._values()

    public static func values(): Array<DisplayContext> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DisplayContext {
        return (TypeInfo.of<DisplayContext>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DisplayContext
    }

    private let Type: DisplayContext_Type

    private let value: Int32

    private init(_enum_name: String, _enum_ordinal: Int32, Type: DisplayContext_Type, value: Int32) {
        super(_enum_name, _enum_ordinal)
        this.Type = Type
        this.value = value
    }

    public func typeMethod(): DisplayContext_Type {
        return Type
    }

    public func valueMethod(): Int32 {
        return value
    }
}


public class DisplayContext_Type <: Enum<DisplayContext_Type> {
    public static let DIALECT_HANDLING = DisplayContext_Type("DIALECT_HANDLING", 0)

    public static let CAPITALIZATION = DisplayContext_Type("CAPITALIZATION", 1)

    public static let DISPLAY_LENGTH = DisplayContext_Type("DISPLAY_LENGTH", 2)

    public static let SUBSTITUTE_HANDLING = DisplayContext_Type("SUBSTITUTE_HANDLING", 3)

    private static func _values(): Array<DisplayContext_Type> {
        return [DisplayContext_Type.DIALECT_HANDLING, DisplayContext_Type.CAPITALIZATION, DisplayContext_Type.DISPLAY_LENGTH, DisplayContext_Type.SUBSTITUTE_HANDLING]
    }

    private static let _VALUES = DisplayContext_Type._values()

    public static func values(): Array<DisplayContext_Type> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DisplayContext_Type {
        return (TypeInfo.of<DisplayContext_Type>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DisplayContext_Type
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
