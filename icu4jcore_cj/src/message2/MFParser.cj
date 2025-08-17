package icu4cj.message2



public class MFParser {
    private static let EOF = -1

    private let input: InputSource

    init(text: String) {
        this.input = InputSource(text)
    }

    
    public static func parse(input: String): MFDataModel_Message {
        return MFParser(input).parseImpl()
    }

    private func parseImpl(): MFDataModel_Message {
        let result: MFDataModel_Message
        var cp = input.peekChar()
        if (cp == Int32(UInt32('.'))) {
            result = getComplexMessage()
        } else if (cp == Int32(UInt32('{'))) {
            cp = input.readCodePoint()
            cp = input.peekChar()
            if (cp == Int32(UInt32('{'))) {
                input.backup(1)
                let pattern = getQuotedPattern()
                result = MFDataModel_PatternMessage(ArrayList<MFDataModel_Declaration>(), pattern)
            } else {
                input.backup(1)
                let pattern = getPattern()
                result = MFDataModel_PatternMessage(ArrayList<MFDataModel_Declaration>(), pattern)
            }
        } else {
            let pattern = getPattern()
            result = MFDataModel_PatternMessage(ArrayList<MFDataModel_Declaration>(), pattern)
        }
        skipOptionalWhitespaces()
        checkCondition(input.atEnd(), "Content detected after the end of the message.")
        MFDataModelValidator(result).validate()
        return result
    }

    private func getPattern(): MFDataModel_Pattern {
        let pattern = MFDataModel_Pattern()
        while (true) {
            let part = getPatternPart()
            if (part.isNone()) {
                break
            }
            pattern.parts.append(part)
        }
        return pattern
    }

    private func getPatternPart(): MFDataModel_PatternPart {
        let cp = input.peekChar()
        <-- Internal error: switch (cp) {
        case EOF:
            return null;

        case '}':
            return null;

        case '{':
            MFDataModel$Expression ph = getPlaceholder();
            return ph;

        default:
            String plainText = getText();
            MFDataModel$StringPart sp = new MFDataModel$StringPart(plainText);
            return sp;

        } -->
    }

    private func getText(): String {
        let result = StringBuilder()
        while (true) {
            var cp = input.readCodePoint()
            <-- Internal error: switch (cp) {
            case EOF:
                return result.toString();

            case '\'':
                cp = input.readCodePoint();
                if (cp == '\'' || cp == '{' || cp == '|' || cp == '}') {
                    result.appendCodePoint(cp);
                } else {
                    result.appendCodePoint('\'');
                    result.appendCodePoint(cp);
                }
                break;

            case '.':

            case '@':

            case '|':
                result.appendCodePoint(cp);
                break;

            default:
                if (StringUtils.isContentChar(cp) || StringUtils.isWhitespace(cp)) {
                    result.appendCodePoint(cp);
                } else {
                    input.backup(1);
                    return result.toString();
                }

            } -->
        }
        throw Exception()
    }

    private func getPlaceholder(): MFDataModel_Expression {
        var cp = input.peekChar()
        if (cp != Int32(UInt32('{'))) {
            return None
        }
        input.readCodePoint()
        skipOptionalWhitespaces()
        cp = input.peekChar()
        let result: MFDataModel_Expression
        if (cp == Int32(UInt32('#')) || cp == Int32(UInt32('/'))) {
            result = getMarkup()
        } else if (cp == Int32(UInt32('$'))) {
            result = getVariableExpression()
        } else if (StringUtils.isFunctionSigil(cp) || StringUtils.isPrivateAnnotationSigil(cp) || StringUtils.isReservedAnnotationSigil(cp)) {
            result = getAnnotationExpression()
        } else {
            result = getLiteralExpression()
        }
        skipOptionalWhitespaces()
        cp = input.readCodePoint()
        checkCondition(cp == Int32(UInt32('}')), "Unclosed placeholder")
        return result
    }

    private func getAnnotation(): MFDataModel_Annotation {
        let position = input.getPosition()
        skipOptionalWhitespaces()
        var cp = input.peekChar()
        <-- Internal error: switch (cp) {
        case '}':
            return null;

        case ':':
            input.readCodePoint();
            String identifier = getIdentifier();
            checkCondition(identifier != null, "Annotation / function name missing");
            Map<String, MFDataModel$Option> options = getOptions();
            return new MFDataModel$FunctionAnnotation(identifier, options);

        default:
            if (StringUtils.isReservedAnnotationSigil(cp) || StringUtils.isPrivateAnnotationSigil(cp)) {
                cp = input.readCodePoint();
                identifier = (char)cp + getIdentifier();
                String body = getReservedBody();
                return new MFDataModel$UnsupportedAnnotation(identifier + body);
            }

        } -->
        input.gotoPosition(position)
        return None
    }

    private func getMarkupAnnotation(): MFDataModel_Annotation {
        skipOptionalWhitespaces()
        let cp = input.peekChar()
        <-- Internal error: switch (cp) {
        case '}':
            return null;

        case '#':

        case '/':
            input.readCodePoint();
            String identifier = getIdentifier();
            checkCondition(identifier != null, "Annotation / function name missing");
            Map<String, MFDataModel$Option> options = getOptions();
            return new MFDataModel$FunctionAnnotation(identifier, options);

        default:
            return null;

        } -->
    }

    private func getLiteralExpression(): MFDataModel_Expression {
        let literal = getLiteral()
        checkCondition(literal.isSome(), "Literal expression expected.")
        var annotation: MFDataModel_Annotation
        let wsCount = skipWhitespaces()
        if (wsCount > 0) {
            annotation = getAnnotation()
            if (annotation.isNone()) {
                input.backup(1)
            }
        }
        let attributes = getAttributes()
        return MFDataModel_LiteralExpression(literal, annotation, attributes)
    }

    private func getVariableExpression(): MFDataModel_VariableExpression {
        let variableRef = getVariableRef()
        let annotation = getAnnotation()
        let attributes = getAttributes()
        return MFDataModel_VariableExpression(variableRef, annotation, attributes)
    }

    private func getAnnotationExpression(): MFDataModel_Expression {
        let annotation = getAnnotation()
        let attributes = getAttributes()
        if (checkOptionalIs<MFDataModel_FunctionAnnotation, MFDataModel_Annotation>(annotation)) {
            return MFDataModel_FunctionExpression(annotation, attributes)
        } else if (checkOptionalIs<MFDataModel_UnsupportedAnnotation, MFDataModel_Annotation>(annotation)) {
            return MFDataModel_UnsupportedExpression(annotation, attributes)
        } else {
            error("Unexpected annotation : " + toString(annotation))
        }
        return None
    }

    private func getMarkup(): MFDataModel_Markup {
        var cp = input.peekChar()
        checkCondition(cp == Int32(UInt32('#')) || cp == Int32(UInt32('/')), "Should not happen. Expecting a markup.")
        var kind: MFDataModel_Markup_Kind = if (cp == Int32(UInt32('/'))) { MFDataModel_Markup_Kind.CLOSE } else { MFDataModel_Markup_Kind.OPEN }
        let annotation = getMarkupAnnotation()
        let attributes = getAttributes()
        cp = input.peekChar()
        if (cp == Int32(UInt32('/'))) {
            kind = MFDataModel_Markup_Kind.STANDALONE
            input.readCodePoint()
        }
        if (checkOptionalIs<MFDataModel_FunctionAnnotation, MFDataModel_Annotation>(annotation)) {
            let fa = annotation
            return MFDataModel_Markup(kind, fa.name, fa.options, attributes)
        }
        return None
    }

    private func getAttributes(): ArrayList<MFDataModel_Attribute> {
        let result = ArrayList<MFDataModel_Attribute>()
        while (true) {
            let attribute = getAttribute()
            if (attribute.isNone()) {
                break
            }
            result.append(attribute)
        }
        return result
    }

    private func getAttribute(): MFDataModel_Attribute {
        let position = input.getPosition()
        if (skipWhitespaces() == 0) {
            input.gotoPosition(position)
            return None
        }
        var cp = input.peekChar()
        if (cp == Int32(UInt32('@'))) {
            input.readCodePoint()
            let id = getIdentifier()
            let wsCount = skipWhitespaces()
            cp = input.peekChar()
            var literalOrVariable: MFDataModel_LiteralOrVariableRef
            if (cp == Int32(UInt32('='))) {
                input.readCodePoint()
                skipOptionalWhitespaces()
                literalOrVariable = getLiteralOrVariableRef()
                checkCondition(literalOrVariable.isSome(), "Attributes must have a value after `=`")
            } else {
                input.backup(wsCount)
            }
            return MFDataModel_Attribute(id, literalOrVariable)
        } else {
            input.gotoPosition(position)
        }
        return None
    }

    private func getReservedBody(): String {
        let spaceCount = skipWhitespaces()
        let result = StringBuilder()
        while (true) {
            var cp = input.readCodePoint()
            if (StringUtils.isReservedChar(cp)) {
                result.appendCodePoint(cp)
            } else if (cp == Int32(UInt32('\''))) {
                cp = input.readCodePoint()
                checkCondition(cp == Int32(UInt32('{')) || cp == Int32(UInt32('|')) || cp == Int32(UInt32('}')), "Invalid escape sequence. Only \\{, \\| and \\} are valid here.")
                result.append(cp)
            } else if (cp == Int32(UInt32('|'))) {
                input.backup(1)
                let quoted = getQuotedLiteral()
                result.append(quoted.value)
            } else if (cp == EOF) {
                return result.toString()
            } else {
                if (Int32(result.size) == 0) {
                    input.backup(spaceCount + 1)
                    return ""
                } else {
                    input.backup(1)
                    return result.toString()
                }
            }
        }
        throw Exception()
    }

    private func getIdentifier(): String {
        let namespace = getName()
        if (namespace.isNone()) {
            return None
        }
        let cp = input.readCodePoint()
        if (cp == Int32(UInt32(':'))) {
            let name = getName()
            checkCondition(name.isSome(), "Expected name after namespace '" + (namespace) + "'")
            return (namespace) + ":" + (name)
        } else {
            input.backup(1)
        }
        return namespace
    }

    private func getOptions(): Map<String, MFDataModel_Option> {
        let options = LinkedHashMap()
        while (true) {
            let option = getOption()
            if (option.isNone()) {
                break
            }
            if (options.contains(option.name)) {
                error("Duplicated option '" + (option.name) + "'")
            }
            options.put(option.name, option)
        }
        return options
    }

    private func getOption(): MFDataModel_Option {
        let position = input.getPosition()
        skipOptionalWhitespaces()
        let identifier = getIdentifier()
        if (identifier.isNone()) {
            input.gotoPosition(position)
            return None
        }
        skipOptionalWhitespaces()
        let cp = input.readCodePoint()
        checkCondition(cp == Int32(UInt32('=')), "Expected '='")
        let litOrVar = getLiteralOrVariableRef()
        if (litOrVar.isNone()) {
            error("Options must have a value. An empty string should be quoted.")
        }
        return MFDataModel_Option(identifier, litOrVar)
    }

    private func getLiteralOrVariableRef(): MFDataModel_LiteralOrVariableRef {
        let cp = input.peekChar()
        if (cp == Int32(UInt32('$'))) {
            return getVariableRef()
        }
        return getLiteral()
    }

    private func getLiteral(): MFDataModel_Literal {
        let cp = input.readCodePoint()
        <-- Internal error: switch (cp) {
        case '|':
            input.backup(1);
            MFDataModel$Literal ql = getQuotedLiteral();
            return ql;

        default:
            input.backup(1);
            MFDataModel$Literal unql = getUnQuotedLiteral();
            return unql;

        } -->
    }

    private func getVariableRef(): MFDataModel_VariableRef {
        let cp = input.readCodePoint()
        if (cp != Int32(UInt32('$'))) {
            checkCondition(cp == Int32(UInt32('$')), "We can't get here")
        }
        let name = getName()
        checkCondition(name.isSome(), "Invalid variable reference following $")
        return MFDataModel_VariableRef(name)
    }

    private func getQuotedLiteral(): MFDataModel_Literal {
        let result = StringBuilder()
        var cp = input.readCodePoint()
        checkCondition(cp == Int32(UInt32('|')), "expected starting '|'")
        while (true) {
            cp = input.readCodePoint()
            if (cp == EOF) {
                break
            } else if (StringUtils.isQuotedChar(cp)) {
                result.appendCodePoint(cp)
            } else if (cp == Int32(UInt32('\''))) {
                cp = input.readCodePoint()
                checkCondition(cp == Int32(UInt32('|')), "Invalid escape sequence, only \"\\|\" is valid here")
                result.appendCodePoint(Int32(UInt32('|')))
            } else {
                break
            }
        }
        checkCondition(cp == Int32(UInt32('|')), "expected ending '|'")
        return MFDataModel_Literal(result.toString())
    }

    private func getUnQuotedLiteral(): MFDataModel_Literal {
        let name = getName()
        if (name.isSome()) {
            return MFDataModel_Literal(name)
        }
        return getNumberLiteral()
    }

    private static let RE_NUMBER_LITERAL = Pattern.compile("^-(0|[1-9][0-9]*)(\\.[0-9]+)([eE][+\\-][0-9]+)")

    private func getNumberLiteral(): MFDataModel_Literal {
        let numberString = peekWithRegExp(RE_NUMBER_LITERAL)
        if (numberString.isSome()) {
            return MFDataModel_Literal(numberString)
        }
        return None
    }

    private func skipMandatoryWhitespaces(): Unit {
        let count = skipWhitespaces()
        checkCondition(count > 0, "Space expected")
    }

    private func skipOptionalWhitespaces(): Unit {
        skipWhitespaces()
    }

    private func skipWhitespaces(): Int32 {
        var skipCount = 0
        while (true) {
            let cp = input.readCodePoint()
            if (cp == EOF) {
                return skipCount
            }
            if (!StringUtils.isWhitespace(cp)) {
                input.backup(1)
                return skipCount
            }
            skipCount++
        }
        throw Exception()
    }

    private func getComplexMessage(): MFDataModel_Message {
        let declarations = ArrayList<MFDataModel_Declaration>()
        var foundMatch = false
        while (true) {
            let declaration = getDeclaration()
            if (declaration.isNone()) {
                break
            }
            if (checkOptionalIs<MFParser_MatchDeclaration, MFDataModel_Declaration>(declaration)) {
                foundMatch = true
                break
            }
            declarations.append(declaration)
        }
        if (foundMatch) {
            return getMatch(declarations)
        } else {
            skipOptionalWhitespaces()
            let cp = input.peekChar()
            if (cp == EOF) {
                return MFDataModel_PatternMessage(declarations, None)
            } else {
                let pattern = getQuotedPattern()
                return MFDataModel_PatternMessage(declarations, pattern)
            }
        }
    }

    private func getMatch(declarations: ArrayList<MFDataModel_Declaration>): MFDataModel_SelectMessage {
        let expressions = ArrayList<MFDataModel_Expression>()
        while (true) {
            skipMandatoryWhitespaces()
            let expression = getPlaceholder()
            if (expression.isNone()) {
                break
            }
            checkCondition(!(checkOptionalIs<MFDataModel_Markup, MFDataModel_Expression>(expression)), "Cannot do selection on markup")
            expressions.append(expression)
        }
        checkCondition(!expressions.isEmpty(), "There should be at least one selector expression.")
        let variants = ArrayList<MFDataModel_Variant>()
        while (true) {
            let variant = getVariant()
            if (variant.isNone()) {
                break
            }
            variants.append(variant)
        }
        return MFDataModel_SelectMessage(declarations, expressions, variants)
    }

    private func getVariant(): MFDataModel_Variant {
        let keys = ArrayList<MFDataModel_LiteralOrCatchallKey>()
        while (true) {
            let key = getKey(!keys.isEmpty())
            if (key.isNone()) {
                break
            }
            keys.append(key)
        }
        skipOptionalWhitespaces()
        if (input.atEnd()) {
            checkCondition(keys.isEmpty(), "After selector keys it is mandatory to have a pattern.")
            return None
        }
        let pattern = getQuotedPattern()
        return MFDataModel_Variant(keys, pattern)
    }

    private func getKey(requireSpaces: Bool): MFDataModel_LiteralOrCatchallKey {
        if (requireSpaces) {
            skipMandatoryWhitespaces()
        } else {
            skipOptionalWhitespaces()
        }
        let cp = input.peekChar()
        if (cp == Int32(UInt32('*'))) {
            input.readCodePoint()
            return MFDataModel_CatchallKey()
        }
        if (cp == EOF) {
            return None
        }
        return getLiteral()
    }

    private func getDeclaration(): MFDataModel_Declaration {
        let position = input.getPosition()
        skipOptionalWhitespaces()
        var cp = input.readCodePoint()
        if (cp != Int32(UInt32('.'))) {
            input.gotoPosition(position)
            return None
        }
        let declName = getName()
        checkCondition(declName.isSome(), "Expected a declaration after the '.'")
        var expression: MFDataModel_Expression
        match (declName) {
            case "input" =>
                skipMandatoryWhitespaces()
                expression = getPlaceholder()
                var inputVarName: String
                if (checkOptionalIs<MFDataModel_VariableExpression, MFDataModel_Expression>(expression)) {
                    inputVarName = expression.arg.name
                }
                if (checkOptionalIs<MFDataModel_VariableExpression, MFDataModel_Expression>(expression)) {
                    return MFDataModel_InputDeclaration(inputVarName, expression)
                }
            case "local" =>
                skipMandatoryWhitespaces()
                let varName = getVariableRef()
                skipOptionalWhitespaces()
                cp = input.readCodePoint()
                checkCondition(cp == Int32(UInt32('=')), declName)
                skipOptionalWhitespaces()
                expression = getPlaceholder()
                if (checkOptionalIs<MFDataModel_VariableRef, MFDataModel_LiteralOrVariableRef>(varName)) {
                    return MFDataModel_LocalDeclaration(varName.name, expression)
                }
            case "match" => return MFParser_MatchDeclaration()
            case _ =>
                skipOptionalWhitespaces()
                let body = getReservedBody()
                let expressions = ArrayList<MFDataModel_Expression>()
                while (true) {
                    skipOptionalWhitespaces()
                    expression = getPlaceholder()
                    if (checkOptionalIs<MFDataModel_VariableExpression, MFDataModel_Expression>(expression)) {
                        expressions.append(expression)
                    } else {
                        break
                    }
                }
                return MFDataModel_UnsupportedStatement(declName, body, expressions)
        }
        return None
    }

    private func getQuotedPattern(): MFDataModel_Pattern {
        var cp = input.readCodePoint()
        checkCondition(cp == Int32(UInt32('{')), "Expected { for a complex body")
        cp = input.readCodePoint()
        checkCondition(cp == Int32(UInt32('{')), "Expected second { for a complex body")
        let pattern = getPattern()
        cp = input.readCodePoint()
        checkCondition(cp == Int32(UInt32('}')), "Expected } to end a complex body")
        cp = input.readCodePoint()
        checkCondition(cp == Int32(UInt32('}')), "Expected second } to end a complex body")
        return pattern
    }

    private func getName(): String {
        let result = StringBuilder()
        var cp = input.readCodePoint()
        checkCondition(cp != EOF, "Expected name or namespace.")
        if (!StringUtils.isNameStart(cp)) {
            input.backup(1)
            return None
        }
        result.appendCodePoint(cp)
        while (true) {
            cp = input.readCodePoint()
            if (StringUtils.isNameChar(cp)) {
                result.appendCodePoint(cp)
            } else if (cp == EOF) {
                break
            } else {
                input.backup(1)
                break
            }
        }
        return result.toString()
    }

    private func checkCondition(condition: Bool, message: String): Unit {
        if (!condition) {
            error(message)
        }
    }

    private func error(message: String): Unit {
        let finalMsg = StringBuilder()
        if (input.isNone()) {
            finalMsg.append("Parse error: ")
            finalMsg.append(message)
        } else {
            let position = input.getPosition()
            finalMsg.append("Parse error [" + input.getPosition().toString() + "]: ")
            finalMsg.append(message)
            finalMsg.append("\n")
            if (position != EOF) {
                finalMsg.append(input.buffer[0..Int64(position)])
                finalMsg.append("^^^")
                finalMsg.append(input.buffer[Int64(position)..])
            } else {
                finalMsg.append(input.buffer)
                finalMsg.append("^^^")
            }
        }
        throw MFParseException(finalMsg.toString(), input.getPosition())
    }

    private func peekWithRegExp(pattern: Pattern): String {
        let sv = StringView(input.buffer, input.getPosition())
        let m = pattern.matcher(sv)
        let found = m.find()
        if (found) {
            input.skip(Int32(m.group().size))
            return m.group()
        }
        return None
    }
}


class MFParser_MatchDeclaration <: MFDataModel_Declaration {
}
