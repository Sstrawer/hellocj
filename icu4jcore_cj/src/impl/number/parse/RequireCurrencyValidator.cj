package icu4cj.impl.number.parse

public class RequireCurrencyValidator <: ValidationMatcher {
    public init() {
        super()
    }

    public override func postProcess(result: ParsedNumber): Unit {
        if (result.currencyCode.isNone()) {
            result.flags |= ParsedNumber.FLAG_FAIL
        }
    }

    public override func toString(): String {
        return "<RequireCurrency>"
    }
}
