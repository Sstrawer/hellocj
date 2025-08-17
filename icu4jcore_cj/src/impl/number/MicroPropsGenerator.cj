package icu4cj.impl.number

public interface MicroPropsGenerator {
    public func processQuantity(quantity: DecimalQuantity): MicroProps
}