package icu4cj.message2


class MFDataModelValidator {
    private let message: MFDataModel_Message

    private let declaredVars: Set<String> = HashSet<String>()

    init(message: MFDataModel_Message) {
        this.message = message
    }

    public func validate(): Bool {
        if (checkOptionalIs<MFDataModel_PatternMessage, MFDataModel_Message>(message)) {
            validateDeclarations(message.declarations)
        } else if (checkOptionalIs<MFDataModel_SelectMessage, MFDataModel_Message>(message)) {
            let sm = message
            validateDeclarations(sm.declarations)
            validateSelectors(sm.selectors)
            let selectorCount = Int32(sm.selectors.size)
            validateVariants(sm.variants, selectorCount)
        }
        return true
    }

    private func validateVariants(variants: ArrayList<MFDataModel_Variant>, selectorCount: Int32): Bool {
        if (variants.isNone() || variants.isEmpty()) {
            error("Selection messages must have at least one variant")
        }
        var hasUltimateFallback = false
        let fakeKeys: Set<String> = HashSet<String>()
        for (variant in variants) {
            if (variant.keys.isNone() || variant.keys.isEmpty()) {
                error("Selection variants must have at least one key")
            }
            if (Int32(variant.keys.size) != selectorCount) {
                error("Selection variants must have the same number of variants as the selectors.")
            }
            var catchAllCount = 0
            let fakeKey = StringJoiner("<<::>>")
            for (key in variant.keys) {
                if (checkOptionalIs<MFDataModel_CatchallKey, MFDataModel_LiteralOrCatchallKey>(key)) {
                    catchAllCount++
                    fakeKey.add("*")
                } else if (checkOptionalIs<MFDataModel_Literal, MFDataModel_LiteralOrCatchallKey>(key)) {
                    fakeKey.add(key.value)
                }
            }
            if (fakeKeys.contains(toString(fakeKey))) {
                error("Dumplicate combination of keys")
            } else {
                fakeKeys.put(toString(fakeKey))
            }
            if (catchAllCount == selectorCount) {
                hasUltimateFallback = true
            }
        }
        if (!hasUltimateFallback) {
            error("There must be one variant with all the keys being '*'")
        }
        return true
    }

    private func validateSelectors(selectors: ArrayList<MFDataModel_Expression>): Bool {
        if (selectors.isNone() || selectors.isEmpty()) {
            error("Selection messages must have selectors")
        }
        return true
    }

    private func validateDeclarations(declarations: ArrayList<MFDataModel_Declaration>): Bool {
        if (declarations.isNone() || declarations.isEmpty()) {
            return true
        }
        for (declaration in declarations) {
            if (checkOptionalIs<MFDataModel_LocalDeclaration, MFDataModel_Declaration>(declaration)) {
                let ld = declaration
                validateExpression(ld.value, false)
                addVariableDeclaration(ld.name)
            } else if (checkOptionalIs<MFDataModel_InputDeclaration, MFDataModel_Declaration>(declaration)) {
                let id = declaration
                validateExpression(id.value, true)
            }
        }
        return true
    }

    private func validateExpression(expression: MFDataModel_Expression, fromInput: Bool): Unit {
        var argName: String
        var annotation: MFDataModel_Annotation
        if (checkOptionalIs<MFDataModel_Literal, MFDataModel_Expression>(expression)) { } else if (checkOptionalIs<MFDataModel_LiteralExpression, MFDataModel_Expression>(expression)) {
            let le = expression
            argName = le.arg.value
            annotation = le.annotation
        } else if (checkOptionalIs<MFDataModel_VariableExpression, MFDataModel_Expression>(expression)) {
            let ve = expression
            argName = ve.arg.name
            annotation = ve.annotation
        } else if (checkOptionalIs<MFDataModel_FunctionExpression, MFDataModel_Expression>(expression)) {
            let fe = expression
            annotation = fe.annotation
        }
        if (checkOptionalIs<MFDataModel_FunctionAnnotation, MFDataModel_Annotation>(annotation)) {
            let fa = annotation
            if (fa.options.isSome()) {
                for (opt in fa.options.values()) {
                    let val = opt.value
                    if (checkOptionalIs<MFDataModel_VariableRef, MFDataModel_LiteralOrVariableRef>(val)) {
                        addVariableDeclaration(val.name)
                    }
                }
            }
        }
        if (argName.isSome()) {
            if (fromInput) {
                addVariableDeclaration(argName)
            } else {
                declaredVars.put(argName)
            }
        }
    }

    private func addVariableDeclaration(varName: String): Bool {
        if (declaredVars.contains(varName)) {
            error("Variable '" + (varName) + "' already declared")
            return false
        }
        declaredVars.put(varName)
        return true
    }

    private func error(text: String): Unit {
        throw MFParseException(text, -1)
    }
}
