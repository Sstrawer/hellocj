package icu4cj.impl.number

public class MultiplierFormatHandler <: MicroPropsGenerator {
    let multiplier: Scale

    let parent: MicroPropsGenerator

    public init(multiplier: Scale, parent: MicroPropsGenerator) {
        this.multiplier = multiplier
        this.parent = parent
    }

    public override func processQuantity(quantity: DecimalQuantity): MicroProps {
        let micros = parent.processQuantity(quantity)
        multiplier.applyTo(quantity)
        return micros
    }
}
