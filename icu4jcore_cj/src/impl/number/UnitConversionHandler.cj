package icu4cj.impl.number


public class UnitConversionHandler <: MicroPropsGenerator {
    private let fParent: MicroPropsGenerator

    private var fOutputUnit: MeasureUnit

    private var fComplexUnitConverter: ComplexUnitsConverter

    public init(targetUnit: MeasureUnit, parent: MicroPropsGenerator) {
        this.fOutputUnit = targetUnit
        this.fParent = parent
        let targetUnitImpl = MeasureUnitImpl.forIdentifier(targetUnit.getIdentifier())
        this.fComplexUnitConverter = ComplexUnitsConverter(targetUnitImpl, ConversionRates())
    }

    public override func processQuantity(quantity: DecimalQuantity): MicroProps {
        let result = this.fParent.processQuantity(quantity)
        quantity.roundToInfinity()
        let complexConverterResult = this.fComplexUnitConverter.convert(quantity.toBigDecimal(), result.rounder)
        result.outputUnit = this.fOutputUnit
        UsagePrefsHandler.mixedMeasuresToMicros(complexConverterResult, quantity, result)
        return result
    }
}
