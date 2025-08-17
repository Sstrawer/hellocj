package icu4cj.number

public class IntegerWidth {
    static let DEFAULT = IntegerWidth(1, -1)

    let minInt: Int32

    let maxInt: Int32

    private init(minInt: Int32, maxInt: Int32) {
        this.minInt = minInt
        this.maxInt = maxInt
    }

    public static func zeroFillTo(minInt: Int32): IntegerWidth {
        if (minInt == 1) {
            return DEFAULT
        } else if (minInt >= 0 && minInt <= RoundingUtils.MAX_INT_FRAC_SIG) {
            return IntegerWidth(minInt, -1)
        } else {
            throw IllegalArgumentException("Integer digits must be between 0 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }

    public func truncateAt(maxInt: Int32): IntegerWidth {
        if (maxInt == this.maxInt) {
            return this
        } else if (maxInt >= 0 && maxInt <= RoundingUtils.MAX_INT_FRAC_SIG && maxInt >= minInt) {
            return IntegerWidth(minInt, maxInt)
        } else if (minInt == 1 && maxInt == -1) {
            return DEFAULT
        } else if (maxInt == -1) {
            return IntegerWidth(minInt, -1)
        } else {
            throw IllegalArgumentException("Integer digits must be between -1 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }
}
