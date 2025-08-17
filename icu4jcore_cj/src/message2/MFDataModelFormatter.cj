package icu4cj.message2


class MFDataModelFormatter {
    private let locale: Locale

    private let dm: MFDataModel_Message

    private let standardFunctions: MFFunctionRegistry

    private let customFunctions: MFFunctionRegistry

    private static let EMPTY_REGISTY = MFFunctionRegistry.builder().build()

    init(dm: MFDataModel_Message, locale: Locale, customFunctionRegistry: MFFunctionRegistry) {
        this.locale = locale
        this.dm = dm
        this.customFunctions = if (customFunctionRegistry.isNone()) { EMPTY_REGISTY } else { customFunctionRegis@AssertThrows[Exception](}
        standardFunctions = MFFunctionRegistry.builder().setFormatter("datetime", DateTimeFormatterFactory("datetime")).setFormatter("date", DateTimeFormatterFactory("date")).setFormatter("time", DateTimeFormatterFactory("time")).setDefaultFormatterNameForType(TypeInfo.of<Date>() as ClassTypeInfo, "datetime").setDefaultFormatterNameForType(TypeInfo.of<Calendar>() as ClassTypeInfo, "datetime").setDefaultFormatterNameForType(TypeInfo.of<Calendar>() as ClassTypeInfo, "datetime").setFormatter("number", NumberFormatterFactory("number")).setFormatter("integer", NumberFormatterFactory("integer")).setDefaultFormatterNameForType(TypeInfo.of<Int32>() as ClassTypeInfo, "number").setDefaultFormatterNameForType(TypeInfo.of<Float64>() as ClassTypeInfo, "number").setDefaultFormatterNameForType(TypeInfo.of<Number>() as ClassTypeInfo, "number").setDefaultFormatterNameForType(TypeInfo.of<CurrencyAmount>() as ClassTypeInfo, "number").setFormatter("string", IdentityFormatterFactory()).setDefaultFormatterNameForType(TypeInfo.of<String>() as ClassTypeInfo, "string").setDefaultFormatterNameForType(TypeInfo.of<String>() as ClassTypeInfo, "string").setSelector("number", NumberFormatterFactory("number")).setSelector("integer", NumberFormatterFactory("integer")).setSelector("string", TextSelectorFactory()).setSelector("icu:gender", TextSelectorFactory()).build()
    }

    public func format(arguments: Map<String, Object>): String {
        var temparguments = arguments
        var patternToRender: MFDataModel_Pattern
        if (temparguments.isNone()) {
            temparguments = HashMap<String, Object>()
        }
        let variables: Map<String, Object>
        if (checkOptionalIs<MFDataModel_PatternMessage, MFDataModel_Message>(dm)) {
            let pm = dm
            variables = resolveDeclarations(pm.declarations, temparguments)
            patternToRender = pm.pattern
        } else if (checkOptionalIs<MFDataModel_SelectMessage, MFDataModel_Message>(dm)) {
            let sm = dm
            variables = resolveDeclarations(sm.declarations, temparguments)
            patternToRender = findBestMatchingPattern(sm, variables, temparguments)
        } else {
            formattingError("")
            return "ERROR!"
        }
        if (patternToRender.isNone()) {
            return "ERROR!"
        }
        let result = StringBuilder()
        for (part in patternToRender.parts) {
            if (checkOptionalIs<MFDataModel_StringPart, MFDataModel_PatternPart>(part)) {
                let strPart = part
                result.append(strPart.value)
            } else if (checkOptionalIs<MFDataModel_Expression, MFDataModel_PatternPart>(part)) {
                let formattedExpression = formatExpression(part, variables, temparguments)
                result.append(formattedExpression.getFormattedValue().toString())
            } else if (checkOptionalIs<MFDataModel_Markup, MFDataModel_PatternPart>(part)) { } else if (checkOptionalIs<MFDataModel_UnsupportedExpression, MFDataModel_PatternPart>(part)) { } else {
                formattingError("Unknown part type: " + toString(part))
            }
        }
        return result.toString()
    }

    private func findBestMatchingPattern(sm: MFDataModel_SelectMessage, variables: Map<String, Object>, arguments: Map<String, Object>): MFDataModel_Pattern {
        var patternToRender: MFDataModel_Pattern
        let selectors = sm.selectors
        let res = ArrayList<MFDataModelFormatter_ResolvedSelector>(selectors.size)
        for (sel in selectors) {
            let fph = formatExpression(sel, variables, arguments)
            var functionName: String
            var argument: Object
            let options: Map<String, Object> = HashMap<String, Object>()
            if (checkOptionalIs<MFDataModelFormatter_ResolvedExpression, Object>(fph.getInput())) {
                let re = fph.getInput()
                argument = re.argument
                functionName = re.functionName
                options.putAll(re.options)
            } else if (checkOptionalIs<MFDataModel_VariableExpression, Object>(fph.getInput())) {
                let ve = fph.getInput()
                argument = resolveLiteralOrVariable(ve.arg, variables, arguments)
                if (checkOptionalIs<MFDataModel_FunctionAnnotation, MFDataModel_Annotation>(ve.annotation)) {
                    functionName = ve.annotation.name
                }
            } else if (checkOptionalIs<MFDataModel_LiteralExpression, Object>(fph.getInput())) {
                let le = fph.getInput()
                argument = le.arg
                if (checkOptionalIs<MFDataModel_FunctionAnnotation, MFDataModel_Annotation>(le.annotation)) {
                    functionName = le.annotation.name
                }
            }
            var funcFactory = standardFunctions.getSelector(functionName)
            if (funcFactory.isNone()) {
                funcFactory = customFunctions.getSelector(functionName)
            }
            if (funcFactory.isSome()) {
                let selectorFunction = funcFactory.createSelector(locale, options)
                let rs = MFDataModelFormatter_ResolvedSelector(argument, options, selectorFunction)
                res.append(rs)
            } else {
                throw IllegalArgumentException("Unknown selector type: " + (functionName))
            }
        }
        if (Int32(res.size) != Int32(selectors.size)) {
            throw IllegalArgumentException("Something went wrong, not enough selector functions, " + res.size.toString() + " vs. " + selectors.size.toString())
        }
        let pref = ArrayList<ArrayList<String>>()
                        let ks = key.value
                        keys.append(ks)
                    } else {
                        formattingError("Literal expected, but got " + toString(key))
                    }
                }
                let rv = res[Int64(i)]
                let matches = matchSelectorKeys(rv, keys)
                pref.append(matches)
                i++
            }
        } while (false)
        let vars = ArrayList<MFDataModel_Variant>()
        for (var in sm.variants) {
            var found = 0
                    if (!(checkOptionalIs<MFDataModel_Literal, MFDataModel_LiteralOrCatchallKey>(key))) {
                        formattingError("Literal expected")
                    }
                    let ks = key.value
                    let matches = pref[Int64(i)]
                    if (matches.contains(ks)) {
                        found++
                        continue
                    } else {
                        break
                    }
                    i++
                }
            } while (false)
            if (found == Int32(pref.size)) {
                vars.append(var)
            }
        }
        let sortable = ArrayList<MFDataModelFormatter_IntVarTuple>()
        for (var in vars) {
            let tuple = MFDataModelFormatter_IntVarTuple(-1, var)
            sortable.append(tuple)
        }
        let len = Int32(pref.size)
        var i = len - 1
        while (i >= 0) {
            let matches = pref[Int64(i)]
            let minpref = Int32(matches.size)
            for (tuple in sortable) {
                var matchpref = minpref
                let key = tuple.variant.keys[Int64(i)]
                if (!(checkOptionalIs<MFDataModel_CatchallKey, MFDataModel_LiteralOrCatchallKey>(key))) {
                    if (!(checkOptionalIs<MFDataModel_Literal, MFDataModel_LiteralOrCatchallKey>(key))) {
                        formattingError("Literal expected")
                    }
                    let ks = key.value
                    matchpref = matches.indexOf(ks)
                }
                tuple.integer = matchpref
            }
            sortable.sort(// Unimplemented feature MEMBER_REFERENCE: MFDataModelFormatter::sortVariants)
            i--
        }
        let variant = sortable[0]
        patternToRender = var.variant.value
        if (patternToRender.isNone()) {
            throw IllegalArgumentException("The selection went wrong, cannot select any option.")
        }
        return patternToRender
    }

    private static func sortVariants(o1: MFDataModelFormatter_IntVarTuple, o2: MFDataModelFormatter_IntVarTuple): Int32 {
        let result = Int32.compare(o1.integer, o2.integer)
        if (result != 0) {
            return result
        }
        let v1 = o1.variant.keys
        let v2 = o1.variant.keys
        if (Int32(v1.size) != Int32(v2.size)) {
            formattingError("The number of keys is not equal.")
        }
        var i = 0
        while (i < Int32(v1.size)) {
            let k1 = v1[Int64(i)]
            let k2 = v2[Int64(i)]
            let s1 = if (checkOptionalIs<MFDataModel_Literal, MFDataModel_LiteralOrCatchallKey>(k1)) { k1.value } else { Some("*") }
            let s2 = if (checkOptionalIs<MFDataModel_Literal, MFDataModel_LiteralOrCatchallKey>(k2)) { k2.value } else { Some("*") }
            let cmp = s1.compare(s2).value()
            if (cmp != 0) {
                return cmp
            }
            i++
        }
        return 0
    }

    private func matchSelectorKeys(rv: MFDataModelFormatter_ResolvedSelector, keys: ArrayList<String>): ArrayList<String> {
        return rv.selectorFunction.matches(rv.argument, keys, rv.options)
    }

    private static func formattingError(message: String): Unit {
        throw IllegalArgumentException(message)
    }

    private func getFormattingFunctionFactoryByName(toFormat: Object, functionName: String): FormatterFactory {
        var tempfunctionName = functionName
        if (tempfunctionName.isNone() || tempfunctionName.isEmpty()) {
            if (toFormat.isNone()) {
                return None
            }
            let clazz: ClassTypeInfo = TypeInfo.of(toFormat)
            tempfunctionName = standardFunctions.getDefaultFormatterNameForType(clazz)
            if (tempfunctionName.isNone()) {
                tempfunctionName = customFunctions.getDefaultFormatterNameForType(clazz)
            }
            if (tempfunctionName.isNone()) {
                throw IllegalArgumentException("Object to format without a function, and unknown type: " + TypeInfo.of(toFormat).name)
            }
        }
        var func = standardFunctions.getFormatter(tempfunctionName)
        if (func.isNone()) {
            func = customFunctions.getFormatter(tempfunctionName)
        }
        return func
    }

    private static func resolveLiteralOrVariable(value: MFDataModel_LiteralOrVariableRef, localVars: Map<String, Object>, arguments: Map<String, Object>): Object {
        if (checkOptionalIs<MFDataModel_Literal, MFDataModel_LiteralOrVariableRef>(value)) {
            let val = value.value
            let nr = OptUtils.asNumber(val)
            if (nr.isSome()) {
                return nr
            }
            return val
        } else if (checkOptionalIs<MFDataModel_VariableRef, MFDataModel_LiteralOrVariableRef>(value)) {
            let varName = value.name
            var val = localVars.get(varName)
            if (val.isNone()) {
                val = localVars.get(varName)
            }
            if (val.isNone()) {
                val = arguments.get(varName)
            }
            return val
        }
        return value
    }

    private static func convertOptions(options: Map<String, MFDataModel_Option>, localVars: Map<String, Object>, arguments: Map<String, Object>): Map<String, Object> {
        let result: Map<String, Object> = HashMap<String, Object>()
        for (option in options.values()) {
            result.put(option.name, resolveLiteralOrVariable(option.value, localVars, arguments))
        }
        return result
    }

    private func formatExpression(expression: MFDataModel_Expression, variables: Map<String, Object>, arguments: Map<String, Object>): FormattedPlaceholder {
        var annotation: MFDataModel_Annotation
        var functionName: String
        var toFormat: Object
        let options: Map<String, Object> = HashMap<String, Object>()
        var fallbackString: String = "{\u{fffd}}"
        if (checkOptionalIs<MFDataModel_VariableExpression, MFDataModel_Expression>(expression)) {
            let varPart = expression
            fallbackString = "{$" + (varPart.arg.name) + "}"
            annotation = varPart.annotation
            let resolved = resolveLiteralOrVariable(varPart.arg, variables, arguments)
            if (checkOptionalIs<FormattedPlaceholder, Object>(resolved)) {
                let input = resolved.getInput()
                if (checkOptionalIs<MFDataModelFormatter_ResolvedExpression, Object>(input)) {
                    let re = input
                    toFormat = re.argument
                    functionName = re.functionName
                    options.putAll(re.options)
                } else {
                    toFormat = input
                }
            } else {
                toFormat = resolved
            }
        } else if (checkOptionalIs<MFDataModel_FunctionExpression, MFDataModel_Expression>(expression)) {
            let fe = expression
            fallbackString = "{:" + (fe.annotation.name) + "}"
            annotation = fe.annotation
        } else if (checkOptionalIs<MFDataModel_LiteralExpression, MFDataModel_Expression>(expression)) {
            let le = expression
            annotation = le.annotation
            fallbackString = "{|" + (le.arg.value) + "|}"
            toFormat = resolveLiteralOrVariable(le.arg, variables, arguments)
        } else if (checkOptionalIs<MFDataModel_Markup, MFDataModel_Expression>(expression)) {
            return FormattedPlaceholder(expression, PlainStringFormattedValue(""))
        } else {
            let ue = expression
            let sigil = Char(ue.annotation.source[0])
            return FormattedPlaceholder(expression, PlainStringFormattedValue("{" + sigil.toString() + "}"))
        }
        if (checkOptionalIs<MFDataModel_FunctionAnnotation, MFDataModel_Annotation>(annotation)) {
            let fa = annotation
            if (functionName.isSome() && !functionName.equals(fa.name)) {
                formattingError("invalid function overrides, '" + (functionName) + "' <> '" + (fa.name) + "'")
            }
            functionName = fa.name
            let newOptions = convertOptions(fa.options, variables, arguments)
            options.putAll(newOptions)
        } else if (checkOptionalIs<MFDataModel_UnsupportedAnnotation, MFDataModel_Annotation>(annotation)) {
            return FormattedPlaceholder(expression, PlainStringFormattedValue(fallbackString))
        }
        let funcFactory = getFormattingFunctionFactoryByName(toFormat, functionName)
        if (funcFactory.isNone()) {
            return FormattedPlaceholder(expression, PlainStringFormattedValue(fallbackString))
        }
        let ff = funcFactory.createFormatter(locale, options)
        var res = ff.formatToString(toFormat, arguments)
        if (res.isNone()) {
            res = fallbackString
        }
        let resExpression = MFDataModelFormatter_ResolvedExpression(toFormat, functionName, options)
        return FormattedPlaceholder(resExpression, PlainStringFormattedValue(res))
    }

    private func resolveDeclarations(declarations: ArrayList<MFDataModel_Declaration>, arguments: Map<String, Object>): Map<String, Object> {
        let variables: Map<String, Object> = HashMap<String, Object>()
        var name: String
        var value: MFDataModel_Expression
        if (declarations.isSome()) {
            for (declaration in declarations) {
                if (checkOptionalIs<MFDataModel_InputDeclaration, MFDataModel_Declaration>(declaration)) {
                    name = declaration.name
                    value = declaration.value
                } else if (checkOptionalIs<MFDataModel_LocalDeclaration, MFDataModel_Declaration>(declaration)) {
                    name = declaration.name
                    value = declaration.value
                } else {
                    continue
                }
                try {
                    let fmt = formatExpression(value, variables, arguments)
                    variables.put(name, fmt)
                })
            }
        }
        return variables
    }
}


class MFDataModelFormatter_ResolvedSelector {
    let argument: Object

    let options: Map<String, Object>

    let selectorFunction: Selector

    public init(argument: Object, options: Map<String, Object>, selectorFunction: Selector) {
        this.argument = argument
        this.options = HashMap<String, Object>(options)
        this.selectorFunction = selectorFunction
    }
}


class MFDataModelFormatter_ResolvedExpression <: MFDataModel_Expression {
    let argument: Object

    let functionName: String

    let options: Map<String, Object>

    public init(argument: Object, functionName: String, options: Map<String, Object>) {
        this.argument = argument
        this.functionName = functionName
        this.options = options
    }
}


class MFDataModelFormatter_IntVarTuple {
    var integer: Int32 = 0

    let variant: MFDataModel_Variant

    public init(integer: Int32, variant: MFDataModel_Variant) {
        this.integer = integer
        this.variant = variant
    }
}
