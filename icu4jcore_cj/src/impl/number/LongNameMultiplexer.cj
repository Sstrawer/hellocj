package icu4cj.impl.number

public class LongNameMultiplexer <: MicroPropsGenerator {
    private let fParent: MicroPropsGenerator

    private var fHandlers: ArrayList<LongNameMultiplexer_ParentlessMicroPropsGenerator>

    private var fMeasureUnits: ArrayList<MeasureUnit>

    public init(fParent: MicroPropsGenerator) {
        this.fParent = fParent
    }

    public static func forMeasureUnits(locale: ULocale, units: ArrayList<MeasureUnit>, width: NumberFormatter_UnitWidth, unitDisplayCase: String, rules: PluralRules, parent: MicroPropsGenerator): LongNameMultiplexer {
        let result = LongNameMultiplexer(parent)
        if (!(Int32(units.size) > 0)) {
            throw AssertionError()
        }
        result.fMeasureUnits = ArrayList<MeasureUnit>()
        result.fHandlers = ArrayList<LongNameMultiplexer_ParentlessMicroPropsGenerator>()
        var i = 0
        while (i < Int32(units.size)) {
            let unit = units[Int64(i)]
            result.fMeasureUnits.append(unit)
            if (refEq(unit.getComplexity(), MeasureUnit_Complexity.MIXED)) {
                let mlnh = MixedUnitLongNameHandler.forMeasureUnit(locale, unit, width, unitDisplayCase, rules, None)
                result.fHandlers.append(mlnh)
            } else {
                let lnh = LongNameHandler.forMeasureUnit(locale, unit, width, unitDisplayCase, rules, None)
                result.fHandlers.append(lnh)
            }
            i++
        }
        return result
    }

    public override func processQuantity(quantity: DecimalQuantity): MicroProps {
        let micros = this.fParent.processQuantity(quantity)
        var i = 0
        while (i < Int32(this.fHandlers.size)) {
            if (fMeasureUnits[Int64(i)].equals(micros.outputUnit)) {
                let handler = fHandlers[Int64(i)]
                return handler.processQuantityWithMicros(quantity, micros)
            }
            i++
        }
        throw Exception(" We shouldn't receive any outputUnit for which we haven't already got a LongNameHandler")
    }
}


public interface LongNameMultiplexer_ParentlessMicroPropsGenerator {
    public func processQuantityWithMicros(quantity: DecimalQuantity, micros: MicroProps): MicroProps
}