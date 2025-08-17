package icu4cj.impl.number.parse

public class RequireDecimalSeparatorValidator <: ValidationMatcher {
    private static let A = RequireDecimalSeparatorValidator(true)

    private static let B = RequireDecimalSeparatorValidator(false)

    private let patternHasDecimalSeparator: Bool

    public static func getInstance(patternHasDecimalSeparator: Bool): RequireDecimalSeparatorValidator {
        return if (patternHasDecimalSeparator) { A } else { B }
    }

    private init(patternHasDecimalSeparator: Bool) {
        super()
        this.patternHasDecimalSeparator = patternHasDecimalSeparator
    }

    public override func postProcess(result: ParsedNumber): Unit {
        let parseHasDecimalSeparator = 0 != (result.flags & ParsedNumber.FLAG_HAS_DECIMAL_SEPARATOR)
        if (parseHasDecimalSeparator != patternHasDecimalSeparator) {
            result.flags |= ParsedNumber.FLAG_FAIL
        }
    }

    public override func toString(): String {
        return "<RequireDecimalSeparator>"
    }
}
