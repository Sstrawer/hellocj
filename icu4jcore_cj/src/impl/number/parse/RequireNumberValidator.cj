package icu4cj.impl.number.parse

public class RequireNumberValidator <: ValidationMatcher {
    public init() {
        super()
    }

    public override func postProcess(result: ParsedNumber): Unit {
        if (!result.seenNumber()) {
            result.flags |= ParsedNumber.FLAG_FAIL
        }
    }

    public override func toString(): String {
        return "<RequireNumber>"
    }
}
