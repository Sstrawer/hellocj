package icu4cj.impl.number


public class UsagePrefsHandler <: MicroPropsGenerator {
    private let fParent: MicroPropsGenerator

    private var fUnitsRouter: UnitsRouter

    public init(locale: ULocale, inputUnit: MeasureUnit, usage: String, parent: MicroPropsGenerator) {
        if (!parent.isSome()) {
            throw AssertionError()
        }
        this.fParent = parent
        this.fUnitsRouter = UnitsRouter(MeasureUnitImpl.forIdentifier(inputUnit.getIdentifier()), locale, usage)
    }

    protected static func mixedMeasuresToMicros(complexConverterResult: ComplexUnitsConverter_ComplexConverterResult, quantity: DecimalQuantity, outMicros: MicroProps): Unit {
        outMicros.mixedMeasures = complexConverterResult.measures
        outMicros.indexOfQuantity = complexConverterResult.indexOfQuantity
        quantity.setToBigDecimal(outMicros.mixedMeasures[Int64(outMicros.indexOfQuantity)].getNumber())
    }

    public func getOutputUnits(): ArrayList<MeasureUnit> {
        return fUnitsRouter.getOutputUnits()
    }

    public override func processQuantity(quantity: DecimalQuantity): MicroProps {
        let micros = this.fParent.processQuantity(quantity)
        quantity.roundToInfinity()
        let routed = fUnitsRouter.route(quantity.toBigDecimal(), micros)
        micros.outputUnit = routed.outputUnit.build()
        UsagePrefsHandler.mixedMeasuresToMicros(routed.complexConverterResult, quantity, micros)
        return micros
    }
}
