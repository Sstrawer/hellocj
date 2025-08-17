package icu4cj.impl.number


public class MixedUnitLongNameHandler <: MicroPropsGenerator & ModifierStore & LongNameMultiplexer_ParentlessMicroPropsGenerator {
    private let rules: PluralRules

    private let parent: MicroPropsGenerator

    private var fMixedUnitData: ArrayList<Array<String>>

    private var fIntegerFormatter: LocalizedNumberFormatter

    private var fListFormatter: ListFormatter

    private init(rules: PluralRules, parent: MicroPropsGenerator) {
        this.rules = rules
        this.parent = parent
    }

    public static func forMeasureUnit(locale: ULocale, mixedUnit: MeasureUnit, width: NumberFormatter_UnitWidth, unitDisplayCase: String, rules: PluralRules, parent: MicroPropsGenerator): MixedUnitLongNameHandler {
        if (!refEq(mixedUnit.getComplexity(), MeasureUnit_Complexity.MIXED)) {
            throw Exception("MixedUnitLongNameHandler only supports MIXED units")
        }
        let result = MixedUnitLongNameHandler(rules, parent)
        let individualUnits = mixedUnit.splitToSingleUnits()
        result.fMixedUnitData = ArrayList<Array<String>>()
        var i = 0
        while (i < Int32(individualUnits.size)) {
            let unitData = Array<String>(Int64(LongNameHandler.ARRAY_LENGTH))
            LongNameHandler.getMeasureData(locale, individualUnits[Int64(i)], width, unitDisplayCase, unitData)
            result.fMixedUnitData.append(unitData)
            i++
        }
        var listWidth: ListFormatter_Width = ListFormatter_Width.SHORT
        if (refEq(width, NumberFormatter_UnitWidth.NARROW)) {
            listWidth = ListFormatter_Width.NARROW
        } else if (refEq(width, NumberFormatter_UnitWidth.FULL_NAME)) {
            listWidth = ListFormatter_Width.WIDE
        }
        result.fListFormatter = ListFormatter.getInstance(locale, ListFormatter_Type.UNITS, listWidth)
        result.fIntegerFormatter = NumberFormatter.withLocale(locale)
        return result
    }

    public override func processQuantity(quantity: DecimalQuantity): MicroProps {
        if (!(Int32(fMixedUnitData.size) > 1)) {
            throw AssertionError()
        }
        let micros: MicroProps
        micros = parent.processQuantity(quantity)
        micros.modOuter = getMixedUnitModifier(quantity, micros)
        return micros
    }

    public override func processQuantityWithMicros(quantity: DecimalQuantity, micros: MicroProps): MicroProps {
        if (!(Int32(fMixedUnitData.size) > 1)) {
            throw AssertionError()
        }
        micros.modOuter = getMixedUnitModifier(quantity, micros)
        return micros
    }

    public override func getModifier(signum: Modifier_Signum, plural: StandardPlural): Modifier {
        if (!false) {
            throw Exception("should be unreachable")
        }
        return None
    }

    private func getMixedUnitModifier(quantity: DecimalQuantity, micros: MicroProps): Modifier {
        if (Int32(micros.mixedMeasures.size) == 0) {
            if (!false) {
                throw Exception("Mixed unit: we must have more than one unit value")
            }
            throw UnsupportedOperationException()
        }
        let outputMeasuresList = ArrayList<String>()
        var quantityPlural: StandardPlural = StandardPlural.OTHER
        var i = 0
        while (i < Int32(micros.mixedMeasures.size)) {
            if (i == micros.indexOfQuantity) {
                if (i > 0 && quantity.isNegative()) {
                    quantity.negate()
                }
                quantityPlural = RoundingUtils.getPluralSafe(micros.rounder, rules, quantity)
                let quantitySimpleFormat = LongNameHandler.getWithPlural(this.fMixedUnitData[Int64(i)], quantityPlural)
                let finalFormatter = SimpleFormatter.compileMinMaxArguments(quantitySimpleFormat, 0, 1)
                outputMeasuresList.append(finalFormatter.format(["{0}"]))
                continue
            }
            let fdec: DecimalQuantity = DecimalQuantity_DualStorageBCD(micros.mixedMeasures[Int64(i)].getNumber())
            if (i > 0 && fdec.isNegative()) {
                fdec.negate()
            }
            let pluralForm = RoundingUtils.getPluralSafe(micros.rounder, rules, fdec)
            let simpleFormat = LongNameHandler.getWithPlural(this.fMixedUnitData[Int64(i)], pluralForm)
            let compiledFormatter = SimpleFormatter.compileMinMaxArguments(simpleFormat, 0, 1)
            let appendable = FormattedStringBuilder()
            this.fIntegerFormatter.formatImpl(fdec, appendable)
            outputMeasuresList.append(compiledFormatter.format([appendable.toString()]))
            i++
        }
        let premixedFormatPattern = this.fListFormatter.format(outputMeasuresList as Collection<Object>)
        let sb = StringBuilder()
        let premixedCompiled = SimpleFormatterImpl.compileToStringMinMaxArguments(premixedFormatPattern, sb, 0, 1)
        let params = Modifier_Parameters()
        params.obj = this
        params.signum = Modifier_Signum.POS_ZERO
        params.plural = quantityPlural
        return SimpleModifier(premixedCompiled, None, false, params)
    }
}
