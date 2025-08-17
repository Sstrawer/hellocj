package icu4cj.message2



public class MFDataModel {
}



public interface MFDataModel_Message {

}


public class MFDataModel_PatternMessage <: MFDataModel_Message {
    public let declarations: ArrayList<MFDataModel_Declaration>

    public let pattern: MFDataModel_Pattern

    
    public init(declarations: ArrayList<MFDataModel_Declaration>, pattern: MFDataModel_Pattern) {
        this.declarations = declarations
        this.pattern = pattern
    }
}



public class MFDataModel_SelectMessage <: MFDataModel_Message {
    public let declarations: ArrayList<MFDataModel_Declaration>

    public let selectors: ArrayList<MFDataModel_Expression>

    public let variants: ArrayList<MFDataModel_Variant>

    
    public init(declarations: ArrayList<MFDataModel_Declaration>, selectors: ArrayList<MFDataModel_Expression>, variants: ArrayList<MFDataModel_Variant>) {
        this.declarations = declarations
        this.selectors = selectors
        this.variants = variants
    }
}



public interface MFDataModel_Declaration {

}


public class MFDataModel_InputDeclaration <: MFDataModel_Declaration {
    public let name: String

    public let value: MFDataModel_VariableExpression

    
    public init(name: String, value: MFDataModel_VariableExpression) {
        this.name = name
        this.value = value
    }
}



public class MFDataModel_LocalDeclaration <: MFDataModel_Declaration {
    public let name: String

    public let value: MFDataModel_Expression

    
    public init(name: String, value: MFDataModel_Expression) {
        this.name = name
        this.value = value
    }
}



public class MFDataModel_UnsupportedStatement <: MFDataModel_Declaration {
    public let keyword: String

    public let body: String

    public let expressions: ArrayList<MFDataModel_Expression>

    
    public init(keyword: String, body: String, expressions: ArrayList<MFDataModel_Expression>) {
        this.keyword = keyword
        this.body = body
        this.expressions = expressions
    }
}



public interface MFDataModel_LiteralOrCatchallKey {

}


public class MFDataModel_Variant <: MFDataModel_LiteralOrCatchallKey {
    public let keys: ArrayList<MFDataModel_LiteralOrCatchallKey>

    public let value: MFDataModel_Pattern

    
    public init(keys: ArrayList<MFDataModel_LiteralOrCatchallKey>, value: MFDataModel_Pattern) {
        this.keys = keys
        this.value = value
    }
}



public class MFDataModel_CatchallKey <: MFDataModel_LiteralOrCatchallKey {
}



public class MFDataModel_Pattern {
    public let parts: ArrayList<MFDataModel_PatternPart>

    init() {
        this.parts = ArrayList<MFDataModel_PatternPart>()
    }
}



public interface MFDataModel_PatternPart {

}


public class MFDataModel_StringPart <: MFDataModel_PatternPart {
    public let value: String

    init(value: String) {
        this.value = value
    }
}



public interface MFDataModel_Expression <: MFDataModel_PatternPart {

}


public class MFDataModel_LiteralExpression <: MFDataModel_Expression {
    public let arg: MFDataModel_Literal

    public let annotation: MFDataModel_Annotation

    public let attributes: ArrayList<MFDataModel_Attribute>

    
    public init(arg: MFDataModel_Literal, annotation: MFDataModel_Annotation, attributes: ArrayList<MFDataModel_Attribute>) {
        this.arg = arg
        this.annotation = annotation
        this.attributes = attributes
    }
}



public class MFDataModel_VariableExpression <: MFDataModel_Expression {
    public let arg: MFDataModel_VariableRef

    public let annotation: MFDataModel_Annotation

    public let attributes: ArrayList<MFDataModel_Attribute>

    
    public init(arg: MFDataModel_VariableRef, annotation: MFDataModel_Annotation, attributes: ArrayList<MFDataModel_Attribute>) {
        this.arg = arg
        this.annotation = annotation
        this.attributes = attributes
    }
}



public interface MFDataModel_Annotation {

}


public class MFDataModel_FunctionExpression <: MFDataModel_Expression {
    public let annotation: MFDataModel_FunctionAnnotation

    public let attributes: ArrayList<MFDataModel_Attribute>

    
    public init(annotation: MFDataModel_FunctionAnnotation, attributes: ArrayList<MFDataModel_Attribute>) {
        this.annotation = annotation
        this.attributes = attributes
    }
}



public class MFDataModel_UnsupportedExpression <: MFDataModel_Expression {
    public let annotation: MFDataModel_UnsupportedAnnotation

    public let attributes: ArrayList<MFDataModel_Attribute>

    
    public init(annotation: MFDataModel_UnsupportedAnnotation, attributes: ArrayList<MFDataModel_Attribute>) {
        this.annotation = annotation
        this.attributes = attributes
    }
}



public class MFDataModel_Attribute {
    public let name: String

    public let value: MFDataModel_LiteralOrVariableRef

    
    public init(name: String, value: MFDataModel_LiteralOrVariableRef) {
        this.name = name
        this.value = value
    }
}



public interface MFDataModel_LiteralOrVariableRef {

}


public class MFDataModel_Literal <: MFDataModel_LiteralOrVariableRef & MFDataModel_LiteralOrCatchallKey {
    public let value: String

    
    public init(value: String) {
        this.value = value
    }
}



public class MFDataModel_VariableRef <: MFDataModel_LiteralOrVariableRef {
    public let name: String

    
    public init(name: String) {
        this.name = name
    }
}



public class MFDataModel_FunctionAnnotation <: MFDataModel_Annotation {
    public let name: String

    public let options: Map<String, MFDataModel_Option>

    
    public init(name: String, options: Map<String, MFDataModel_Option>) {
        this.name = name
        this.options = options
    }
}



public class MFDataModel_Option {
    public let name: String

    public let value: MFDataModel_LiteralOrVariableRef

    
    public init(name: String, value: MFDataModel_LiteralOrVariableRef) {
        this.name = name
        this.value = value
    }
}



public class MFDataModel_UnsupportedAnnotation <: MFDataModel_Annotation {
    public let source: String

    
    public init(source: String) {
        this.source = source
    }
}



public class MFDataModel_Markup <: MFDataModel_Expression {
    public let kind: MFDataModel_Markup_Kind

    public let name: String

    public let options: Map<String, MFDataModel_Option>

    public let attributes: ArrayList<MFDataModel_Attribute>

    
    public init(kind: MFDataModel_Markup_Kind, name: String, options: Map<String, MFDataModel_Option>, attributes: ArrayList<MFDataModel_Attribute>) {
        this.kind = kind
        this.name = name
        this.options = options
        this.attributes = attributes
    }
}


class MFDataModel_Markup_Kind <: Enum<MFDataModel_Markup_Kind> {
    public static let OPEN = MFDataModel_Markup_Kind("OPEN", 0)

    public static let CLOSE = MFDataModel_Markup_Kind("CLOSE", 1)

    public static let STANDALONE = MFDataModel_Markup_Kind("STANDALONE", 2)

    private static func _values(): Array<MFDataModel_Markup_Kind> {
        return [MFDataModel_Markup_Kind.OPEN, MFDataModel_Markup_Kind.CLOSE, MFDataModel_Markup_Kind.STANDALONE]
    }

    private static let _VALUES = MFDataModel_Markup_Kind._values()

    public static func values(): Array<MFDataModel_Markup_Kind> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): MFDataModel_Markup_Kind {
        return (TypeInfo.of<MFDataModel_Markup_Kind>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as MFDataModel_Markup_Kind
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
