package icu4cj.number

public abstract class FractionPrecision <: Precision {
    init() {
        super()
    }

    public func withSignificantDigits(minSignificantDigits: Int32, maxSignificantDigits: Int32, priority: NumberFormatter_RoundingPriority): Precision {
        if (maxSignificantDigits >= 1 && maxSignificantDigits >= minSignificantDigits && maxSignificantDigits <= RoundingUtils.MAX_INT_FRAC_SIG) {
            return constructFractionSignificant(this, minSignificantDigits, maxSignificantDigits, priority, false)
        } else {
            throw IllegalArgumentException("Significant digits must be between 1 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }

    public func withMinDigits(minSignificantDigits: Int32): Precision {
        if (minSignificantDigits >= 1 && minSignificantDigits <= RoundingUtils.MAX_INT_FRAC_SIG) {
            return constructFractionSignificant(this, 1, minSignificantDigits, NumberFormatter_RoundingPriority.RELAXED, true)
        } else {
            throw IllegalArgumentException("Significant digits must be between 1 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }

    public func withMaxDigits(maxSignificantDigits: Int32): Precision {
        if (maxSignificantDigits >= 1 && maxSignificantDigits <= RoundingUtils.MAX_INT_FRAC_SIG) {
            return constructFractionSignificant(this, 1, maxSignificantDigits, NumberFormatter_RoundingPriority.STRICT, true)
        } else {
            throw IllegalArgumentException("Significant digits must be between 1 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }
}
