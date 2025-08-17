package icu4cj.impl.units


public class UnitsRouter {
    private var outputUnits_: ArrayList<MeasureUnit> = ArrayList<MeasureUnit>()

    private var converterPreferences_: ArrayList<UnitsRouter_ConverterPreference> = ArrayList<UnitsRouter_ConverterPreference>()

    public init(inputUnitIdentifier: String, locale: ULocale, usage: String) {
        this(MeasureUnitImpl.forIdentifier(inputUnitIdentifier), locale, usage)
    }

    public init(inputUnit: MeasureUnitImpl, locale: ULocale, usage: String) {
        let data = UnitsData()
        let category = data.getCategory(inputUnit)
        let unitPreferences = data.getPreferencesFor(category, usage, locale)
        var i = 0
        while (i < Int32(unitPreferences.size)) {
            let preference = unitPreferences[Int64(i)]
            let complexTargetUnitImpl = MeasureUnitImpl_UnitsParser.parseForIdentifier(preference.getUnit())
            let precision = preference.getSkeleton()
            if (!precision.isEmpty() && !precision.startsWith("precision-increment")) {
                throw Exception("Only `precision-increment` is allowed")
            }
            outputUnits_.append(complexTargetUnitImpl.build())
            converterPreferences_.append(UnitsRouter_ConverterPreference(inputUnit, complexTargetUnitImpl, preference.getGeq(), precision, data.getConversionRates()))
            i++
        }
    }

    public func route(quantity: BigDecimal, micros: MicroProps): UnitsRouter_RouteResult {
        var rounder: Precision = if (micros.isNone()) { None } else { micros.rounder }
        var converterPreference: UnitsRouter_ConverterPreference
        for (itr in converterPreferences_) {
            converterPreference = itr
            if (converterPreference.converter.greaterThanOrEqual(quantity.abs(), converterPreference.limit)) {
                break
            }
        }
        if (!converterPreference.isSome()) {
            throw AssertionError()
        }
        if (!converterPreference.precision.isSome()) {
            throw AssertionError()
        }
        if (rounder.isSome() && checkOptionalIs<Precision_BogusRounder, Precision>(rounder)) {
            let bogus = rounder
            if (Int32(converterPreference.precision.size) > 0) {
                rounder = bogus.into(parseSkeletonToPrecision(converterPreference.precision))
            } else {
                rounder = bogus.into(Precision.integer().withMinDigits(2))
            }
        }
        if (micros.isSome()) {
            micros.rounder = rounder
        }
        return UnitsRouter_RouteResult(this, converterPreference.converter.convert(quantity, rounder), converterPreference.targetUnit)
    }

    private static func parseSkeletonToPrecision(precisionSkeleton: String): Precision {
        let kSkeletonPrefix = "precision-increment/"
        if (!precisionSkeleton.startsWith(kSkeletonPrefix)) {
            throw IllegalIcuArgumentException("precisionSkeleton is only precision-increment")
        }
        let incrementValue: String = precisionSkeleton[kSkeletonPrefix.size..]
        return Precision.increment(Decimal(incrementValue))
    }

    public func getOutputUnits(): ArrayList<MeasureUnit> {
        return this.outputUnits_
    }
}


public class UnitsRouter_ConverterPreference {
    let targetUnit: MeasureUnitImpl

    let converter: ComplexUnitsConverter

    let limit: BigDecimal

    let precision: String

    public init(source: MeasureUnitImpl, targetUnit: MeasureUnitImpl, precision: String, conversionRates: ConversionRates) {
        this(source, targetUnit, BigDecimal.valueOf(Float64.Min), precision, conversionRates)
    }

    public init(source: MeasureUnitImpl, targetUnit: MeasureUnitImpl, limit: BigDecimal, precision: String, conversionRates: ConversionRates) {
        this.converter = ComplexUnitsConverter(source, targetUnit, conversionRates)
        this.limit = limit
        this.precision = precision
        this.targetUnit = targetUnit
    }
}


public class UnitsRouter_RouteResult {
    public let complexConverterResult: ComplexUnitsConverter_ComplexConverterResult

    public let outputUnit: MeasureUnitImpl

    init(this_0: UnitsRouter, complexConverterResult: ComplexUnitsConverter_ComplexConverterResult, outputUnit: MeasureUnitImpl) {
        this.complexConverterResult = complexConverterResult
        this.outputUnit = outputUnit
    }
}
