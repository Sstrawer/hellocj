package icu4cj.impl.number.parse

public class RequireAffixValidator <: ValidationMatcher {
    public init() {
        super()
    }

    public override func postProcess(result: ParsedNumber): Unit {
        if (result.prefix.isNone() || result.suffix.isNone()) {
            result.flags |= ParsedNumber.FLAG_FAIL
        }
    }

    public override func toString(): String {
        return "<RequireAffix>"
    }
}
