package icu4cj.message2


public class MFSerializer {
    public init() { }

    private var shouldDoubleQuotePattern = false

    private var needSpace = false

    private let result = StringBuilder()

    
    public static func dataModelToString(message: MFDataModel_Message): String {
        return MFSerializer().messageToString(message)
    }

    private func messageToString(message: MFDataModel_Message): String {
        if (checkOptionalIs<MFDataModel_PatternMessage, MFDataModel_Message>(message)) {
            patternMessageToString(message)
        } else if (checkOptionalIs<MFDataModel_SelectMessage, MFDataModel_Message>(message)) {
            selectMessageToString(message)
        } else {
            errorType("Message", message)
        }
        return result.toString()
    }

    private func selectMessageToString(message: MFDataModel_SelectMessage): Unit {
        declarationsToString(message.declarations)
        shouldDoubleQuotePattern = true
        addSpaceIfNeeded()
        result.append(".match")
        for (selector in message.selectors) {
            result.append(' ')
            expressionToString(selector)
        }
        for (variant in message.variants) {
            variantToString(variant)
        }
    }

    private func patternMessageToString(message: MFDataModel_PatternMessage): Unit {
        declarationsToString(message.declarations)
        patternToString(message.pattern)
    }

    private func patternToString(pattern: MFDataModel_Pattern): Unit {
        addSpaceIfNeeded()
        if (shouldDoubleQuotePattern) {
            result.append("{{")
        }
        for (part in pattern.parts) {
            if (checkOptionalIs<MFDataModel_StringPart, MFDataModel_PatternPart>(part)) {
                stringPartToString(part)
            } else {
                expressionToString(part)
            }
        }
        if (shouldDoubleQuotePattern) {
            result.append("}}")
        }
    }

    private func expressionToString(expression: MFDataModel_Expression): Unit {
        if (expression.isNone()) {
            return
        }
        if (checkOptionalIs<MFDataModel_LiteralExpression, MFDataModel_Expression>(expression)) {
            literalExpressionToString(expression)
        } else if (checkOptionalIs<MFDataModel_VariableExpression, MFDataModel_Expression>(expression)) {
            variableExpressionToString(expression)
        } else if (checkOptionalIs<MFDataModel_FunctionExpression, MFDataModel_Expression>(expression)) {
            functionExpressionToString(expression)
        } else if (checkOptionalIs<MFDataModel_Markup, MFDataModel_Expression>(expression)) {
            markupToString(expression)
        } else if (checkOptionalIs<MFDataModel_UnsupportedExpression, MFDataModel_Expression>(expression)) {
            unsupportedExpressionToString(expression)
        } else {
            errorType("Expression", expression)
        }
    }

    private func unsupportedExpressionToString(ue: MFDataModel_UnsupportedExpression): Unit {
        result.append('{')
        annotationToString(ue.annotation)
        attributesToString(ue.attributes)
        result.append('}')
    }

    private func markupToString(markup: MFDataModel_Markup): Unit {
        result.append('{')
        if (refEq(markup.kind, MFDataModel_Markup_Kind.CLOSE)) {
            result.append('/')
        } else {
            result.append('#')
        }
        result.append(markup.name)
        optionsToString(markup.options)
        attributesToString(markup.attributes)
        if (refEq(markup.kind, MFDataModel_Markup_Kind.STANDALONE)) {
            result.append('/')
        }
        result.append('}')
    }

    private func optionsToString(options: Map<String, MFDataModel_Option>): Unit {
        for (option in options.values()) {
            result.append(' ')
            result.append(option.name)
            result.append('=')
            literalOrVariableRefToString(option.value)
        }
    }

    private func functionExpressionToString(fe: MFDataModel_FunctionExpression): Unit {
        result.append('{')
        annotationToString(fe.annotation)
        attributesToString(fe.attributes)
        result.append('}')
    }

    private func attributesToString(attributes: ArrayList<MFDataModel_Attribute>): Unit {
        if (attributes.isNone()) {
            return
        }
        for (attribute in attributes) {
            result.append(" @")
            result.append(attribute.name)
            if (attribute.value.isSome()) {
                result.append('=')
                literalOrVariableRefToString(attribute.value)
            }
        }
    }

    private func annotationToString(annotation: MFDataModel_Annotation): Unit {
        if (annotation.isNone()) {
            return
        }
        if (checkOptionalIs<MFDataModel_FunctionAnnotation, MFDataModel_Annotation>(annotation)) {
            addSpaceIfNeeded()
            result.append(":")
            result.append(annotation.name)
            optionsToString(annotation.options)
        } else if (checkOptionalIs<MFDataModel_UnsupportedAnnotation, MFDataModel_Annotation>(annotation)) {
            addSpaceIfNeeded()
            let value = annotation.source
            var i = 0
            while (i < Int32(value.size)) {
                let c = Char(value[Int64(i)])
                if (c == '\'' || c == '{' || c == '}') {
                    result.append('\'')
                }
                result.append(c)
                i++
            }
        } else {
            errorType("Annotation", annotation)
        }
    }

    private func variableExpressionToString(ve: MFDataModel_VariableExpression): Unit {
        if (ve.isNone()) {
            return
        }
        result.append('{')
        literalOrVariableRefToString(ve.arg)
        needSpace = true
        annotationToString(ve.annotation)
        attributesToString(ve.attributes)
        result.append('}')
        needSpace = false
    }

    private func literalOrVariableRefToString(literalOrVarRef: MFDataModel_LiteralOrVariableRef): Unit {
        if (checkOptionalIs<MFDataModel_Literal, MFDataModel_LiteralOrVariableRef>(literalOrVarRef)) {
            literalToString(literalOrVarRef)
        } else if (checkOptionalIs<MFDataModel_VariableRef, MFDataModel_LiteralOrVariableRef>(literalOrVarRef)) {
            result.append("$" + (literalOrVarRef.name))
        } else {
            errorType("LiteralOrVariableRef", literalOrVarRef)
        }
    }

    private static let RE_NUMBER_LITERAL = Pattern.compile("^-(0|[1-9][0-9]*)(\\.[0-9]+)([eE][+\\-][0-9]+)$")

    private func literalToString(literal: MFDataModel_Literal): Unit {
        let value = literal.value
        let matcher = RE_NUMBER_LITERAL.matcher(value)
        if (matcher.find()) {
            result.append(value)
        } else {
            let literalBuffer = StringBuilder()
            var wasName = true
            var i = 0
            while (i < Int32(value.size)) {
                let c = Char(value[Int64(i)])
                if (c == '\'' || c == '|') {
                    literalBuffer.append('\'')
                }
                literalBuffer.append(c)
                if (i == 0 && !StringUtils.isNameStart(Int32(UInt32(c)))) {
                    wasName = false
                } else if (!StringUtils.isNameChar(Int32(UInt32(c)))) {
                    wasName = false
                }
                i++
            }
            if (wasName && Int32(literalBuffer.size) != 0) {
                result.append(literalBuffer)
            } else {
                result.append('|')
                result.append(literalBuffer)
                result.append('|')
            }
        }
    }

    private func literalExpressionToString(le: MFDataModel_LiteralExpression): Unit {
        result.append('{')
        literalOrVariableRefToString(le.arg)
        needSpace = true
        annotationToString(le.annotation)
        attributesToString(le.attributes)
        result.append('}')
    }

    private func stringPartToString(part: MFDataModel_StringPart): Unit {
        if (part.value.startsWith(".")) {
            if (!shouldDoubleQuotePattern) {
                shouldDoubleQuotePattern = true
                result.append("{{")
            }
        }
        var i = 0
        while (i < Int32(part.value.size)) {
            let c = Char(part.value[Int64(i)])
            if (c == '\'' || c == '{' || c == '}') {
                result.append('\'')
            }
            result.append(c)
            i++
        }
    }

    private func declarationsToString(declarations: ArrayList<MFDataModel_Declaration>): Unit {
        if (declarations.isNone() || declarations.isEmpty()) {
            return
        }
        shouldDoubleQuotePattern = true
        for (declaration in declarations) {
            if (checkOptionalIs<MFDataModel_LocalDeclaration, MFDataModel_Declaration>(declaration)) {
                localDeclarationToString(declaration)
            } else if (checkOptionalIs<MFDataModel_InputDeclaration, MFDataModel_Declaration>(declaration)) {
                inputDeclarationToString(declaration)
            } else if (checkOptionalIs<MFDataModel_UnsupportedStatement, MFDataModel_Declaration>(declaration)) {
                unsupportedStatementToString(declaration)
            } else {
                errorType("Declaration", declaration)
            }
        }
    }

    private func unsupportedStatementToString(declaration: MFDataModel_UnsupportedStatement): Unit {
        addSpaceIfNeeded()
        result.append('.')
        result.append(declaration.keyword)
        if (!declaration.body.isEmpty()) {
            result.append(' ')
        }
        result.append('|')
        result.append(declaration.body)
        result.append('|')
        needSpace = true
        for (expression in declaration.expressions) {
            addSpaceIfNeeded()
            expressionToString(expression)
            needSpace = true
        }
    }

    private func inputDeclarationToString(declaration: MFDataModel_InputDeclaration): Unit {
        addSpaceIfNeeded()
        result.append(".input ")
        variableExpressionToString(declaration.value)
        needSpace = true
    }

    private func localDeclarationToString(declaration: MFDataModel_LocalDeclaration): Unit {
        addSpaceIfNeeded()
        result.append(".local $")
        result.append(declaration.name)
        result.append(" = ")
        expressionToString(declaration.value)
        needSpace = true
    }

    private func variantToString(variant: MFDataModel_Variant): Unit {
        for (key in variant.keys) {
            result.append(' ')
            if (checkOptionalIs<MFDataModel_CatchallKey, MFDataModel_LiteralOrCatchallKey>(key)) {
                result.append('*')
            } else {
                literalToString(key)
            }
        }
        result.append(' ')
        patternToString(variant.value)
    }

    private func addSpaceIfNeeded(): Unit {
        if (needSpace) {
            result.append(' ')
            needSpace = false
        }
    }

    private func errorType(expectedType: String, obj: Object): Unit {
        error("Unexpected '" + (expectedType) + "' type: ", obj)
    }

    private func error(text: String, obj: Object): Unit {
        error((text) + TypeInfo.of(obj).name)
    }

    private func error(text: String): Unit {
        throw Exception(text)
    }
}
