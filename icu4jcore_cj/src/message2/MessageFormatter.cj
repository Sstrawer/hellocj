package icu4cj.message2



public class MessageFormatter {
    private let locale: Locale

    private let pattern: String

    private let functionRegistry: MFFunctionRegistry

    private let dataModel: MFDataModel_Message

    private let modelFormatter: MFDataModelFormatter

    init(builder: MessageFormatter_Builder) {
        this.locale = builder.locale
        this.functionRegistry = builder.functionRegistry
        if ((builder.pattern.isNone() && builder.dataModel.isNone()) || (builder.pattern.isSome() && builder.dataModel.isSome())) {
            throw IllegalArgumentException("You need to set either a pattern, or a dataModel, but not both.")
        }
        if (builder.dataModel.isSome()) {
            this.dataModel = builder.dataModel
            this.pattern = MFSerializer.dataModelToString(dataModel)
        } else {
            this.pattern = builder.pattern
            try {
                this.dataModel = MFParser.parse(pattern)
            } catch (pe: MFParseException) {
                throw IllegalArgumentException("Parse error:\nMessage: <<" + (pattern) + ">>\nError: " + (pe.getMessage()) + "\n")
            }
        }
        modelFormatter = MFDataModelFormatter(dataModel, locale, functionRegistry)
    }

    
    public static func builder(): MessageFormatter_Builder {
        return MessageFormatter_Builder()
    }

    
    public func getLocale(): Locale {
        return locale
    }

    
    public func getPattern(): String {
        return pattern
    }

    
    public func getDataModel(): MFDataModel_Message {
        return dataModel
    }

    
    public func formatToString(arguments: Map<String, Object>): String {
        return modelFormatter.format(arguments)
    }

    
    public func format(arguments: Map<String, Object>): FormattedMessage {
        throw Exception("Not yet implemented.")
    }
}



public class MessageFormatter_Builder {
    var locale = Locale.getDefault(Locale_Category.FORMAT)

    var pattern: String

    var functionRegistry = MFFunctionRegistry.builder().build()

    var dataModel: MFDataModel_Message


    
    public func setLocale(locale: Locale): MessageFormatter_Builder {
        this.locale = locale
        return this
    }

    
    public func setPattern(pattern: String): MessageFormatter_Builder {
        this.pattern = pattern
        this.dataModel = None
        return this
    }

    
    public func setFunctionRegistry(functionRegistry: MFFunctionRegistry): MessageFormatter_Builder {
        this.functionRegistry = functionRegistry
        return this
    }

    
    public func setDataModel(dataModel: MFDataModel_Message): MessageFormatter_Builder {
        this.dataModel = dataModel
        this.pattern = None
        return this
    }

    
    public func build(): MessageFormatter {
        return MessageFormatter(this)
    }
}
