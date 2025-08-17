package icu4cj.impl.number.parse


public class MultiplierParseHandler <: ValidationMatcher {
    private let multiplier: Scale

    public init(multiplier: Scale) {
        super()
        this.multiplier = multiplier
    }

    public override func postProcess(result: ParsedNumber): Unit {
        if (result.quantity.isSome()) {
            multiplier.applyReciprocalTo(result.quantity)
        }
    }

    public override func toString(): String {
        return "<MultiplierHandler " + multiplier.asString() + ">"
    }
}
