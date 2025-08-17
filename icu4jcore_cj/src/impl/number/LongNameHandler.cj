package icu4cj.impl.number


public class LongNameHandler <: MicroPropsGenerator & ModifierStore & LongNameMultiplexer_ParentlessMicroPropsGenerator {
    private static var i = 0

    private static let DNAM_INDEX = StandardPlural.COUNT + match (0) { case _ => i++; i - 1 }

    private static let PER_INDEX = StandardPlural.COUNT + match (0) { case _ => i++; i - 1 }

    private static let GENDER_INDEX = StandardPlural.COUNT + match (0) { case _ => i++; i - 1 }

    static let ARRAY_LENGTH = StandardPlural.COUNT + match (0) { case _ => i++; i - 1 }

    static func getIndex(pluralKeyword: String): Int32 {
        if (pluralKeyword == "dnam") {
            return DNAM_INDEX
        } else if (pluralKeyword == "per") {
            return PER_INDEX
        } else if (pluralKeyword == "gender") {
            return GENDER_INDEX
        } else {
            return StandardPlural.fromString(pluralKeyword).ordinal
        }
    }

    static func getWithPlural(strings: Array<String>, plural: StandardPlural): String {
        var result = strings[Int64(plural.ordinal)]
        if (result.isNone()) {
            result = strings[Int64(StandardPlural.OTHER.ordinal)]
        }
        if (result.isNone()) {
            throw ICUException("Could not find data in 'other' plural variant")
        }
        return result
    }

    private static func extractCorePattern(pattern: String): LongNameHandler_ExtractCorePatternResult {
        let result = LongNameHandler_ExtractCorePatternResult()
        result.joinerChar = Char(0)
        let len = Int32(pattern.size)
        if (pattern.startsWith("{0}")) {
            result.placeholderPosition = LongNameHandler_PlaceholderPosition.BEGINNING
            if (len > 3 && Character.isSpaceChar(Char(pattern[3]))) {
                result.joinerChar = Char(pattern[3])
                result.coreUnit = pattern[4..]
            } else {
                result.coreUnit = pattern[3..]
            }
        } else if (pattern.endsWith("{0}")) {
            result.placeholderPosition = LongNameHandler_PlaceholderPosition.END
            if (Character.isSpaceChar(Char(pattern[Int64(len - 4)]))) {
                result.coreUnit = pattern[0..Int64(len - 4)]
                result.joinerChar = Char(pattern[Int64(len - 4)])
            } else {
                result.coreUnit = pattern[0..Int64(len - 3)]
            }
        } else if (indexOfWrap(pattern.indexOf("{0}", 1)) == -1) {
            result.placeholderPosition = LongNameHandler_PlaceholderPosition.NONE
            result.coreUnit = pattern
        } else {
            result.placeholderPosition = LongNameHandler_PlaceholderPosition.MIDDLE
            result.coreUnit = pattern
        }
        return result
    }

    private static func getGenderForBuiltin(locale: ULocale, builtinUnit: MeasureUnit): String {
        let unitsBundle = UResourceBundle.getBundleInstance(ICUData.ICU_UNIT_BASE_NAME, locale)
        let key = StringBuilder()
        key.append("units/")
        key.append(builtinUnit.getType())
        key.append("/")
        if (builtinUnit.getSubtype().isSome() && builtinUnit.getSubtype().endsWith("-person")) {
            key.append(builtinUnit.getSubtype(), 0, Int32(builtinUnit.getSubtype().size) - 7)
        } else {
            key.append(builtinUnit.getSubtype())
        }
        key.append("/gender")
        try {
            return unitsBundle.getWithFallback(key.toString()).getString()
        } catch (e: MissingResourceException) {
            return ""
        }
    }

    static func getInflectedMeasureData(subKey: String, locale: ULocale, width: NumberFormatter_UnitWidth, gender: String, caseVariant: String, outArray: Array<String>): Unit {
        let sink = LongNameHandler_InflectedPluralSink(gender, caseVariant, outArray)
        let unitsBundle = UResourceBundle.getBundleInstance(ICUData.ICU_UNIT_BASE_NAME, locale)
        let key = StringBuilder()
        key.append("units")
        if (refEq(width, NumberFormatter_UnitWidth.NARROW)) {
            key.append("Narrow")
        } else if (refEq(width, NumberFormatter_UnitWidth.SHORT)) {
            key.append("Short")
        }
        key.append("/")
        key.append(subKey)
        try {
            unitsBundle.getAllItemsWithFallback(key.toString(), sink)
            if (refEq(width, NumberFormatter_UnitWidth.SHORT)) {
                return
            }
        } catch (e: MissingResourceException) { }
        unitsBundle.getAllItemsWithFallback(key.toString(), sink)
    }

    static func getMeasureData(locale: ULocale, unit: MeasureUnit, width: NumberFormatter_UnitWidth, unitDisplayCase: String, outArray: Array<String>): Unit {
        let sink = LongNameHandler_PluralTableSink(outArray)
        let resource: ICUResourceBundle
        resource = UResourceBundle.getBundleInstance(ICUData.ICU_UNIT_BASE_NAME, locale)
        let subKey = StringBuilder()
        subKey.append("/")
        subKey.append(unit.getType())
        subKey.append("/")
        var unitSubType = unit.getSubtype()
        let metadataResource = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "metadata")
        let aliasSink = LongNameHandler_AliasSink()
        metadataResource.getAllItemsWithFallbackNoFail("alias/unit/" + (unitSubType), aliasSink)
        if (aliasSink.replacement.isSome()) {
            unitSubType = aliasSink.replacement
        }
        if (unitSubType.isSome() && unitSubType.endsWith("-person")) {
            subKey.append(unitSubType, 0, Int32(unitSubType.size) - 7)
        } else {
            subKey.append(unitSubType)
        }
        if (!refEq(width, NumberFormatter_UnitWidth.FULL_NAME)) {
            let genderKey = StringBuilder()
            genderKey.append("units")
            genderKey.append(subKey)
            genderKey.append("/gender")
            try {
                outArray[Int64(GENDER_INDEX)] = resource.getWithFallback(genderKey.toString()).getString()
            } catch (e: MissingResourceException) { }
        }
        let key = StringBuilder()
        key.append("units")
        if (refEq(width, NumberFormatter_UnitWidth.NARROW)) {
            key.append("Narrow")
        } else if (refEq(width, NumberFormatter_UnitWidth.SHORT)) {
            key.append("Short")
        }
        key.append(subKey)
        if (refEq(width, NumberFormatter_UnitWidth.FULL_NAME) && unitDisplayCase.isSome() && !unitDisplayCase.isEmpty()) {
            let caseKey = StringBuilder()
            caseKey.append(key)
            caseKey.append("/case/")
            caseKey.append(unitDisplayCase)
            try {
                resource.getAllItemsWithFallback(caseKey.toString(), sink)
            } catch (e: MissingResourceException) { }
        }
        try {
            resource.getAllItemsWithFallback(key.toString(), sink)
        } catch (e: MissingResourceException) {
            throw IllegalArgumentException("No data for unit " + unit.asString() + ", width " + width.asString())
        }
    }

    private static func getCurrencyLongNameData(locale: ULocale, currency: Currency, outArray: Array<String>): Unit {
        let data = CurrencyData.provider.getInstance(locale, true).getUnitPatterns()
        for (e in data.entrySet()) {
            let pluralKeyword = e.getKey()
            let index = getIndex(pluralKeyword)
            let longName = currency.getName(locale, Currency.PLURAL_LONG_NAME, pluralKeyword, None)
            var simpleFormat = e.getValue()
            simpleFormat = simpleFormat.replace("{1}", longName)
            outArray[Int64(index)] = simpleFormat
        }
    }

    private static func getCompoundValue(compoundKey: String, locale: ULocale, width: NumberFormatter_UnitWidth): String {
        let resource: ICUResourceBundle
        resource = UResourceBundle.getBundleInstance(ICUData.ICU_UNIT_BASE_NAME, locale)
        let key = StringBuilder()
        key.append("units")
        if (refEq(width, NumberFormatter_UnitWidth.NARROW)) {
            key.append("Narrow")
        } else if (refEq(width, NumberFormatter_UnitWidth.SHORT)) {
            key.append("Short")
        }
        key.append("/compound/")
        key.append(compoundKey)
        try {
            return resource.getStringWithFallback(key.toString())
        } catch (e: MissingResourceException) {
            if (refEq(width, NumberFormatter_UnitWidth.SHORT)) {
                return ""
            }
        }
        try {
            return resource.getStringWithFallback(key.toString())
        } catch (e: MissingResourceException) {
            return ""
        }
    }

    private static func getDeriveCompoundRule(locale: ULocale, feature: String, structure: String): String {
        var derivationsBundle = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "grammaticalFeatures")
        derivationsBundle = derivationsBundle.get("grammaticalData")
        derivationsBundle = derivationsBundle.get("derivations")
        var stackBundle: ICUResourceBundle
        try {
            stackBundle = derivationsBundle.get(locale.getLanguage())
        } catch (e: MissingResourceException) {
            stackBundle = derivationsBundle.get("root")
        }
        stackBundle = stackBundle.get("compound")
        stackBundle = stackBundle.get(feature)
        return stackBundle.getString(structure)
    }

    private static func getDerivedGender(locale: ULocale, structure: String, data0: Array<String>, data1: Array<String>): String {
        let val = getDeriveCompoundRule(locale, "gender", structure)
        if (Int32(val.size) == 1) {
            match (Char(val[0])) {
                case '0' => return data0[Int64(GENDER_INDEX)]
                case '1' =>
                    if (data1.isNone()) {
                        return None
                    }
                    return data1[Int64(GENDER_INDEX)]
                case _ => ()
            }
        }
        return val
    }

    private static func calculateGenderForUnit(locale: ULocale, unit: MeasureUnit): String {
        let mui = unit.getCopyOfMeasureUnitImpl()
        let singleUnits = mui.getSingleUnits()
        var singleUnitIndex = 0
        if (refEq(mui.getComplexity(), MeasureUnit_Complexity.COMPOUND)) {
            var startSlice = 0
            var endSlice = Int32(singleUnits.size) - 1
            if (!(endSlice > 0)) {
                throw Exception("COMPOUND units have more than one single unit")
            }
            if (singleUnits[Int64(endSlice)].getDimensionality() < 0) {
                let perRule = getDeriveCompoundRule(locale, "gender", "per")
                if (Int32(perRule.size) != 1) {
                    return perRule
                }
                if (Char(perRule[0]) == '1') {
                    while (singleUnits[Int64(startSlice)].getDimensionality() >= 0) {
                        startSlice++
                    }
                } else {
                    while (endSlice >= 0 && singleUnits[Int64(endSlice)].getDimensionality() < 0) {
                        endSlice--
                    }
                    if (endSlice < 0) {
                        return ""
                    }
                }
            }
            if (endSlice > startSlice) {
                let timesRule = getDeriveCompoundRule(locale, "gender", "times")
                if (Int32(timesRule.size) != 1) {
                    return timesRule
                }
                if (Char(timesRule[0]) == '0') {
                    endSlice = startSlice
                } else {
                    startSlice = endSlice
                }
            }
            if (!(startSlice == endSlice)) {
                throw AssertionError()
            }
            singleUnitIndex = startSlice
        } else if (refEq(mui.getComplexity(), MeasureUnit_Complexity.MIXED)) {
            throw ICUException("calculateGenderForUnit does not support MIXED units")
        } else {
            if (!refEq(mui.getComplexity(), MeasureUnit_Complexity.SINGLE)) {
                throw AssertionError()
            }
            if (!(Int32(singleUnits.size) == 1)) {
                throw AssertionError()
            }
        }
        let singleUnit = singleUnits[Int64(singleUnitIndex)]
        if (abs(singleUnit.getDimensionality()) != 1) {
            let powerRule = getDeriveCompoundRule(locale, "gender", "power")
            if (Int32(powerRule.size) != 1) {
                return powerRule
            }
        }
        if (abs(singleUnit.getDimensionality()) != 1) {
            let prefixRule = getDeriveCompoundRule(locale, "gender", "prefix")
            if (Int32(prefixRule.size) != 1) {
                return prefixRule
            }
        }
        return getGenderForBuiltin(locale, MeasureUnit.forIdentifier(singleUnit.getSimpleUnitID()))
    }

    private static func maybeCalculateGender(locale: ULocale, unit: MeasureUnit, outArray: Array<String>): Unit {
        if (outArray[Int64(GENDER_INDEX)].isNone()) {
            let meterGender = getGenderForBuiltin(locale, MeasureUnit.METER)
            if (meterGender.isEmpty()) {
                return
            }
            outArray[Int64(GENDER_INDEX)] = calculateGenderForUnit(locale, unit)
        }
    }

    private let modifiers: Map<StandardPlural, SimpleModifier>

    private let rules: PluralRules

    private let parent: MicroPropsGenerator

    private var gender: String = ""

    private init(modifiers: Map<StandardPlural, SimpleModifier>, rules: PluralRules, parent: MicroPropsGenerator) {
        this.modifiers = modifiers
        this.rules = rules
        this.parent = parent
    }

    public static func getUnitDisplayName(locale: ULocale, unit: MeasureUnit, width: NumberFormatter_UnitWidth): String {
        let measureData = Array<String>(Int64(ARRAY_LENGTH))
        getMeasureData(locale, unit, width, "", measureData)
        return measureData[Int64(DNAM_INDEX)]
    }

    public static func forCurrencyLongNames(locale: ULocale, currency: Currency, rules: PluralRules, parent: MicroPropsGenerator): LongNameHandler {
        let simpleFormats = Array<String>(Int64(ARRAY_LENGTH))
        getCurrencyLongNameData(locale, currency, simpleFormats)
        let modifiers = EnumMap(TypeInfo.of<StandardPlural>() as ClassTypeInfo)
        let result = LongNameHandler(modifiers, rules, parent)
        result.simpleFormatsToModifiers(simpleFormats, NumberFormat_Field.CURRENCY)
        return result
    }

    public static func forMeasureUnit(locale: ULocale, unit: MeasureUnit, width: NumberFormatter_UnitWidth, unitDisplayCase: String, rules: PluralRules, parent: MicroPropsGenerator): LongNameHandler {
        if (unit.getType().isSome()) {
            let simpleFormats = Array<String>(Int64(ARRAY_LENGTH))
            getMeasureData(locale, unit, width, unitDisplayCase, simpleFormats)
            maybeCalculateGender(locale, unit, simpleFormats)
            let modifiers = EnumMap(TypeInfo.of<StandardPlural>() as ClassTypeInfo)
            let result = LongNameHandler(modifiers, rules, parent)
            result.simpleFormatsToModifiers(simpleFormats, NumberFormat_Field.MEASURE_UNIT)
            if (simpleFormats[Int64(GENDER_INDEX)].isSome()) {
                result.gender = simpleFormats[Int64(GENDER_INDEX)]
            }
            return result
        } else {
            if (!(!refEq(unit.getComplexity(), MeasureUnit_Complexity.MIXED))) {
                throw Exception("Mixed units not supported by LongNameHandler: use MixedUnitLongNameHandler")
            }
            return forArbitraryUnit(locale, unit, width, unitDisplayCase, rules, parent)
        }
    }

    private static func forArbitraryUnit(loc: ULocale, unit: MeasureUnit, width: NumberFormatter_UnitWidth, unitDisplayCase: String, rules: PluralRules, parent: MicroPropsGenerator): LongNameHandler {
        var tempunit = unit
        let fullUnit = tempunit.getCopyOfMeasureUnitImpl()
        tempunit = None
        var perUnit: MeasureUnit
        for (subUnit in fullUnit.getSingleUnits()) {
            if (subUnit.getDimensionality() > 0) {
                if (tempunit.isNone()) {
                    tempunit = subUnit.build()
                } else {
                    tempunit = tempunit.product(subUnit.build())
                }
            } else {
                subUnit.setDimensionality(subUnit.getDimensionality() * -1)
                if (perUnit.isNone()) {
                    perUnit = subUnit.build()
                } else {
                    perUnit = perUnit.product(subUnit.build())
                }
            }
        }
        let unitImpl: MeasureUnitImpl = if (tempunit.isNone()) { None } else { tempunit.getCopyOfMeasureUnitImpl() }
        let perUnitImpl: MeasureUnitImpl = if (perUnit.isNone()) { None } else { perUnit.getCopyOfMeasureUnitImpl() }
        let derivedPerCases = LongNameHandler_DerivedComponents(loc, "case", "per")
        let numeratorUnitData = Array<String>(Int64(ARRAY_LENGTH))
        processPatternTimes(unitImpl, loc, width, derivedPerCases.value0Method(unitDisplayCase), numeratorUnitData)
        let denominatorUnitData = Array<String>(Int64(ARRAY_LENGTH))
        processPatternTimes(perUnitImpl, loc, width, derivedPerCases.value1Method(unitDisplayCase), denominatorUnitData)
        var perUnitPattern: String
        if (denominatorUnitData[Int64(PER_INDEX)].isSome()) {
            perUnitPattern = denominatorUnitData[Int64(PER_INDEX)]
        } else {
            let sb = StringBuilder()
            let rawPerUnitFormat = getCompoundValue("per", loc, width)
            let perPatternFormatter = SimpleFormatterImpl.compileToStringMinMaxArguments(rawPerUnitFormat, sb, 2, 2)
            let rawDenominatorFormat = getWithPlural(denominatorUnitData, StandardPlural.ONE)
            let denominatorFormatter = SimpleFormatterImpl.compileToStringMinMaxArguments(rawDenominatorFormat, sb, 0, 1)
            let denominatorString = PatternProps.trimSpaceChar(SimpleFormatterImpl.getTextWithNoArguments(denominatorFormatter))
            perUnitPattern = SimpleFormatterImpl.formatCompiledPattern(perPatternFormatter, ["{0}", denominatorString])
        }
        let modifiers = EnumMap(TypeInfo.of<StandardPlural>() as ClassTypeInfo)
        let result = LongNameHandler(modifiers, rules, parent)
        if (Int32(perUnitPattern.size) == 0) {
            result.simpleFormatsToModifiers(numeratorUnitData, NumberFormat_Field.MEASURE_UNIT)
        } else {
            result.multiSimpleFormatsToModifiers(numeratorUnitData, perUnitPattern, NumberFormat_Field.MEASURE_UNIT)
        }
        result.gender = getDerivedGender(loc, "per", numeratorUnitData, denominatorUnitData)
        return result
    }

    private static func processPatternTimes(productUnit: MeasureUnitImpl, loc: ULocale, width: NumberFormatter_UnitWidth, caseVariant: String, outArray: Array<String>): Unit {
        var tempcaseVariant = caseVariant
        if (!outArray[Int64(StandardPlural.OTHER.ordinal)].isNone()) {
            throw Exception("outArray must have only null values!")
        }
        if (!outArray[Int64(PER_INDEX)].isNone()) {
            throw Exception("outArray must have only null values!")
        }
        if (productUnit.isNone()) {
            outArray[Int64(StandardPlural.OTHER.ordinal)] = ""
            outArray[Int64(PER_INDEX)] = ""
            return
        }
        if (refEq(productUnit.getComplexity(), MeasureUnit_Complexity.MIXED)) {
            throw UnsupportedOperationException("Mixed units not supported by LongNameHandler")
        }
        if (productUnit.getIdentifier().isNone()) {
            productUnit.serialize()
        }
        if (Int32(productUnit.getIdentifier().size) == 0) {
            return
        }
        var simpleUnit = MeasureUnit.findBySubType(productUnit.getIdentifier())
        if (simpleUnit.isSome()) {
            getMeasureData(loc, simpleUnit, width, tempcaseVariant, outArray)
            maybeCalculateGender(loc, simpleUnit, outArray)
            return
        }
        let timesPattern = getCompoundValue("times", loc, width)
        let sb = StringBuilder()
        let timesPatternFormatter = SimpleFormatterImpl.compileToStringMinMaxArguments(timesPattern, sb, 2, 2)
        let globalPlaceholder = Array<LongNameHandler_PlaceholderPosition>(Int64(ARRAY_LENGTH))
        var globalJoinerChar = Char(0)
        for (plural in StandardPlural.values()) {
            let pluralIndex = plural.ordinal
            if (refEq(plural, StandardPlural.OTHER)) {
                outArray[Int64(pluralIndex)] = ""
            } else {
                outArray[Int64(pluralIndex)] = None
            }
            globalPlaceholder[Int64(pluralIndex)] = None
        }
        var pluralCategory: String
        let derivedTimesPlurals = LongNameHandler_DerivedComponents(loc, "plural", "times")
        let derivedTimesCases = LongNameHandler_DerivedComponents(loc, "case", "times")
        let derivedPowerCases = LongNameHandler_DerivedComponents(loc, "case", "power")
        let singleUnits = productUnit.getSingleUnits()
        var singleUnitIndex = 0
        while (singleUnitIndex < Int32(singleUnits.size)) {
            let singleUnit = singleUnits[Int64(singleUnitIndex)]
            let singlePluralCategory: String
            var singleCaseVariant: String
            if (singleUnitIndex < Int32(singleUnits.size) - 1) {
                singlePluralCategory = derivedTimesPlurals.value0Method(pluralCategory)
                singleCaseVariant = derivedTimesCases.value0Method(tempcaseVariant)
                pluralCategory = derivedTimesPlurals.value1Method(pluralCategory)
                tempcaseVariant = derivedTimesCases.value1Method(tempcaseVariant)
            } else {
                singlePluralCategory = derivedTimesPlurals.value1Method(pluralCategory)
                singleCaseVariant = derivedTimesCases.value1Method(tempcaseVariant)
            }
            simpleUnit = MeasureUnit.findBySubType(singleUnit.getSimpleUnitID())
            if (simpleUnit.isNone()) {
                throw UnsupportedOperationException("Unsupported sinlgeUnit: " + (singleUnit.getSimpleUnitID()))
            }
            let gender = getGenderForBuiltin(loc, simpleUnit)
            if (!(singleUnit.getDimensionality() > 0)) {
                throw AssertionError()
            }
            let dimensionality = singleUnit.getDimensionality()
            let dimensionalityPrefixPatterns = Array<String>(Int64(ARRAY_LENGTH))
            if (dimensionality != 1) {
                let dimensionalityKey = StringBuilder("compound/power")
                dimensionalityKey.append(dimensionality)
                try {
                    getInflectedMeasureData(dimensionalityKey.toString(), loc, width, gender, singleCaseVariant, dimensionalityPrefixPatterns)
                } catch (e: MissingResourceException) {
                    if (dimensionality > 3) {
                        throw UnsupportedOperationException("powerN not supported for N > 3: " + (productUnit.getIdentifier()))
                    } else {
                        throw e
                    }
                }
                singleCaseVariant = derivedPowerCases.value0Method(singleCaseVariant)
                singleUnit.setDimensionality(1)
            }
            let prefix = singleUnit.getPrefix()
            var prefixPattern: String = ""
            if (!refEq(prefix, MeasureUnit_MeasurePrefix.ONE)) {
                let prefixKey = StringBuilder()
                prefixKey.append(prefix.getBase())
                prefixKey.append('p')
                prefixKey.append(prefix.getPower())
                prefixPattern = getCompoundValue(prefixKey.toString(), loc, width)
                singleUnit.setPrefix(MeasureUnit_MeasurePrefix.ONE)
            }
            let singleUnitArray = Array<String>(Int64(ARRAY_LENGTH))
            if (!singleUnit.build().getIdentifier().equals(singleUnit.getSimpleUnitID())) {
                throw Exception("Should be equal: singleUnit.build().getIdentifier() produced " + (singleUnit.build().getIdentifier()) + ", singleUnit.getSimpleUnitID() produced " + (singleUnit.getSimpleUnitID()))
            }
            getMeasureData(loc, singleUnit.build(), width, singleCaseVariant, singleUnitArray)
            if (singleUnitArray[Int64(GENDER_INDEX)].isSome()) {
                if (!(!singleUnitArray[Int64(GENDER_INDEX)].isEmpty())) {
                    throw AssertionError()
                }
                if (!refEq(prefix, MeasureUnit_MeasurePrefix.ONE)) {
                    singleUnitArray[Int64(GENDER_INDEX)] = getDerivedGender(loc, "prefix", singleUnitArray, None)
                }
                if (dimensionality != 1) {
                    singleUnitArray[Int64(GENDER_INDEX)] = getDerivedGender(loc, "power", singleUnitArray, None)
                }
                let timesGenderRule = getDeriveCompoundRule(loc, "gender", "times")
                if (Int32(timesGenderRule.size) == 1) {
                    match (Char(timesGenderRule[0])) {
                        case '0' => if (singleUnitIndex == 0) {
                            if (!outArray[Int64(GENDER_INDEX)].isNone()) {
                                throw AssertionError()
                            }
                            outArray[Int64(GENDER_INDEX)] = singleUnitArray[Int64(GENDER_INDEX)]
                        }
                        case '1' => if (singleUnitIndex == Int32(singleUnits.size) - 1) {
                            if (!outArray[Int64(GENDER_INDEX)].isNone()) {
                                throw AssertionError()
                            }
                            outArray[Int64(GENDER_INDEX)] = singleUnitArray[Int64(GENDER_INDEX)]
                        }
                        case _ => ()
                    }
                } else {
                    if (outArray[Int64(GENDER_INDEX)].isNone()) {
                        outArray[Int64(GENDER_INDEX)] = timesGenderRule
                    }
                }
            }
            for (plural_ in StandardPlural.values()) {
                var plural = plural_
                let pluralIndex = plural.ordinal
                if (outArray[Int64(pluralIndex)].isNone()) {
                    if (singleUnitArray[Int64(pluralIndex)].isNone()) {
                        continue
                    } else {
                        outArray[Int64(pluralIndex)] = getWithPlural(outArray, plural)
                    }
                }
                if (singlePluralCategory.isSome()) {
                    plural = StandardPlural.fromString(singlePluralCategory)
                }
                let r = extractCorePattern(getWithPlural(singleUnitArray, plural))
                if (refEq(r.placeholderPosition, LongNameHandler_PlaceholderPosition.MIDDLE)) {
                    throw UnsupportedOperationException()
                }
                if (globalPlaceholder[Int64(pluralIndex)].isNone()) {
                    globalPlaceholder[Int64(pluralIndex)] = r.placeholderPosition
                    globalJoinerChar = r.joinerChar
                } else {
                    if (!refEq(globalPlaceholder[Int64(pluralIndex)], r.placeholderPosition)) {
                        throw AssertionError()
                    }
                }
                if (!refEq(prefix, MeasureUnit_MeasurePrefix.ONE)) {
                    let prefixCompiled = SimpleFormatterImpl.compileToStringMinMaxArguments(prefixPattern, sb, 1, 1)
                    if (refEq(width, NumberFormatter_UnitWidth.FULL_NAME)) {
                        r.coreUnit = UCharacter.toLowerCase(loc, r.coreUnit)
                    }
                    r.coreUnit = SimpleFormatterImpl.formatCompiledPattern(prefixCompiled, [r.coreUnit])
                }
                if (dimensionality != 1) {
                    let dimensionalityCompiled = SimpleFormatterImpl.compileToStringMinMaxArguments(getWithPlural(dimensionalityPrefixPatterns, plural), sb, 1, 1)
                    if (refEq(width, NumberFormatter_UnitWidth.FULL_NAME)) {
                        r.coreUnit = UCharacter.toLowerCase(loc, r.coreUnit)
                    }
                    r.coreUnit = SimpleFormatterImpl.formatCompiledPattern(dimensionalityCompiled, [r.coreUnit])
                }
                if (Int32(outArray[Int64(pluralIndex)].size) == 0) {
                    outArray[Int64(pluralIndex)] = r.coreUnit
                } else {
                    outArray[Int64(pluralIndex)] = SimpleFormatterImpl.formatCompiledPattern(timesPatternFormatter, [outArray[Int64(pluralIndex)], r.coreUnit])
                }
            }
            singleUnitIndex++
        }
        for (plural in StandardPlural.values()) {
            let pluralIndex = plural.ordinal
            if (refEq(globalPlaceholder[Int64(pluralIndex)], LongNameHandler_PlaceholderPosition.BEGINNING)) {
                let tmp = StringBuilder()
                tmp.append("{0}")
                if (Int32(UInt32(globalJoinerChar)) != 0) {
                    tmp.append(globalJoinerChar)
                }
                tmp.append(outArray[Int64(pluralIndex)])
                outArray[Int64(pluralIndex)] = tmp.toString()
            } else if (refEq(globalPlaceholder[Int64(pluralIndex)], LongNameHandler_PlaceholderPosition.END)) {
                if (Int32(UInt32(globalJoinerChar)) != 0) {
                    outArray[Int64(pluralIndex)] = (outArray[Int64(pluralIndex)]) + globalJoinerChar.toString()
                }
                outArray[Int64(pluralIndex)] = (outArray[Int64(pluralIndex)]) + "{0}"
            }
        }
    }

    private func simpleFormatsToModifiers(simpleFormats: Array<String>, field: NumberFormat_Field): Unit {
        let sb = StringBuilder()
        for (plural in StandardPlural.VALUES) {
            let simpleFormat = getWithPlural(simpleFormats, plural)
            let compiled = SimpleFormatterImpl.compileToStringMinMaxArguments(simpleFormat, sb, 0, 1)
            let parameters = Modifier_Parameters()
            parameters.obj = this
            parameters.signum = None
            parameters.plural = plural
            modifiers.put(plural, SimpleModifier(compiled, field, false, parameters))
        }
    }

    private func multiSimpleFormatsToModifiers(leadFormats: Array<String>, trailFormat: String, field: NumberFormat_Field): Unit {
        let sb = StringBuilder()
        let trailCompiled = SimpleFormatterImpl.compileToStringMinMaxArguments(trailFormat, sb, 1, 1)
        for (plural in StandardPlural.VALUES) {
            let leadFormat = getWithPlural(leadFormats, plural)
            let compoundFormat: String
            if (Int32(leadFormat.size) == 0) {
                compoundFormat = trailFormat
            } else {
                compoundFormat = SimpleFormatterImpl.formatCompiledPattern(trailCompiled, [leadFormat])
            }
            let compoundCompiled = SimpleFormatterImpl.compileToStringMinMaxArguments(compoundFormat, sb, 0, 1)
            let parameters = Modifier_Parameters()
            parameters.obj = this
            parameters.signum = None
            parameters.plural = plural
            modifiers.put(plural, SimpleModifier(compoundCompiled, field, false, parameters))
        }
    }

    public override func processQuantity(quantity: DecimalQuantity): MicroProps {
        let micros = parent.processQuantity(quantity)
        let pluralForm = RoundingUtils.getPluralSafe(micros.rounder, rules, quantity)
        micros.modOuter = modifiers.get(pluralForm)
        micros.gender = this.gender
        return micros
    }

    public override func processQuantityWithMicros(quantity: DecimalQuantity, micros: MicroProps): MicroProps {
        let pluralForm = RoundingUtils.getPluralSafe(micros.rounder, rules, quantity)
        micros.modOuter = modifiers.get(pluralForm)
        return micros
    }

    public override func getModifier(signum: Modifier_Signum, plural: StandardPlural): Modifier {
        return modifiers.get(plural)
    }
}


class LongNameHandler_PlaceholderPosition <: Enum<LongNameHandler_PlaceholderPosition> {
    public static let NONE = LongNameHandler_PlaceholderPosition("NONE", 0)

    public static let BEGINNING = LongNameHandler_PlaceholderPosition("BEGINNING", 1)

    public static let MIDDLE = LongNameHandler_PlaceholderPosition("MIDDLE", 2)

    public static let END = LongNameHandler_PlaceholderPosition("END", 3)

    private static func _values(): Array<LongNameHandler_PlaceholderPosition> {
        return [LongNameHandler_PlaceholderPosition.NONE, LongNameHandler_PlaceholderPosition.BEGINNING, LongNameHandler_PlaceholderPosition.MIDDLE, LongNameHandler_PlaceholderPosition.END]
    }

    private static let _VALUES = LongNameHandler_PlaceholderPosition._values()

    public static func values(): Array<LongNameHandler_PlaceholderPosition> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): LongNameHandler_PlaceholderPosition {
        return (TypeInfo.of<LongNameHandler_PlaceholderPosition>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as LongNameHandler_PlaceholderPosition
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class LongNameHandler_ExtractCorePatternResult {

    var coreUnit: String

    var placeholderPosition: LongNameHandler_PlaceholderPosition

    var joinerChar: Char = '\u{0000}'
}


class LongNameHandler_InflectedPluralSink <: UResource_Sink {
    public init(gender: String, caseVariant: String, outArray: Array<String>) {
        super()
        this.gender = gender
        this.caseVariant = caseVariant
        this.outArray = outArray
        var i = 0
        while (i < LongNameHandler.ARRAY_LENGTH) {
            outArray[Int64(i)] = None
            i++
        }
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let pluralsTable = value.getTable()
        var i = 0
        while (pluralsTable.getKeyAndValue(i, key, value)) {
            let keyString: String = key.toString()
            let pluralIndex = LongNameHandler.getIndex(keyString)
            if (outArray[Int64(pluralIndex)].isSome()) {
                continue
            }
            let genderTable = value.getTable()
            if (loadForPluralForm(genderTable, value)) {
                outArray[Int64(pluralIndex)] = value.getString()
            }
            i++
        }
    }

    private func loadForPluralForm(genderTable: UResource_Table, value: UResource_Value): Bool {
        if (gender.isSome() && !gender.isEmpty()) {
            if (loadForGender(genderTable, gender, value)) {
                return true
            }
            if (!refEq(gender, "neuter")) {
                if (loadForGender(genderTable, "neuter", value)) {
                    return true
                }
            }
        }
        if (loadForGender(genderTable, "_", value)) {
            return true
        }
        return false
    }

    private func loadForGender(genderTable: UResource_Table, genderVal: String, value: UResource_Value): Bool {
        if (!genderTable.findValue(genderVal, value)) {
            return false
        }
        let caseTable = value.getTable()
        if (caseVariant.isSome() && !caseVariant.isEmpty()) {
            if (loadForCase(caseTable, caseVariant, value)) {
                return true
            }
            if (!refEq(caseVariant, "nominative")) {
                if (loadForCase(caseTable, "nominative", value)) {
                    return true
                }
            }
        }
        if (loadForCase(caseTable, "_", value)) {
            return true
        }
        return false
    }

    private func loadForCase(caseTable: UResource_Table, caseValue: String, value: UResource_Value): Bool {
        if (!caseTable.findValue(caseValue, value)) {
            return false
        }
        return true
    }

    var gender: String

    var caseVariant: String

    var outArray: Array<String>
}


class LongNameHandler_PluralTableSink <: UResource_Sink {
    var outArray: Array<String>

    public init(outArray: Array<String>) {
        super()
        this.outArray = outArray
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let pluralsTable = value.getTable()
        var i = 0
        while (pluralsTable.getKeyAndValue(i, key, value)) {
            let keyString: String = key.toString()
            if (keyString == "case") {
                continue
            }
            let index = LongNameHandler.getIndex(keyString)
            if (outArray[Int64(index)].isSome()) {
                continue
            }
            let formatString = value.getString()
            outArray[Int64(index)] = formatString
            i++
        }
    }
}


class LongNameHandler_AliasSink <: UResource_Sink {
    init() {
        super()
    }

    var replacement: String

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let aliasTable = value.getTable()
        var i = 0
        while (aliasTable.getKeyAndValue(i, key, value)) {
            let keyString: String = key.toString()
            if (keyString == "replacement") {
                this.replacement = value.toString()
            }
            i++
        }
    }
}


class LongNameHandler_DerivedComponents {
    init(locale: ULocale, feature: String, structure: String) {
        try {
            var derivationsBundle = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "grammaticalFeatures")
            derivationsBundle = derivationsBundle.get("grammaticalData")
            derivationsBundle = derivationsBundle.get("derivations")
            var stackBundle: ICUResourceBundle
            try {
                stackBundle = derivationsBundle.get(locale.getLanguage())
            } catch (e: MissingResourceException) {
                stackBundle = derivationsBundle.get("root")
            }
            stackBundle = stackBundle.get("component")
            stackBundle = stackBundle.get(feature)
            stackBundle = stackBundle.get(structure)
            var value = stackBundle.getString(0)
            if (value.compare("compound").value() == 0) {
                this.value0 = None
            } else {
                this.value0 = value
            }
            value = stackBundle.getString(1)
            if (value.compare("compound").value() == 0) {
                this.value1 = None
            } else {
                this.value1 = value
            }
        } catch (e: MissingResourceException) { }
    }

    public func value0Method(compoundValue: String): String {
        return if (this.value0.isSome()) { this.value0 } else { compoundValue }
    }

    public func value1Method(compoundValue: String): String {
        return if (this.value1.isSome()) { this.value1 } else { compoundValue }
    }

    private var value0: String = ""

    private var value1: String = ""
}
