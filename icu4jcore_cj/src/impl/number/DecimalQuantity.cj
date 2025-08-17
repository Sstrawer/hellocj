package icu4cj.impl.number


public interface DecimalQuantity <: PluralRules_IFixedDecimal {
    public func setMinInteger(minInt: Int32): Unit

    public func setMinFraction(minFrac: Int32): Unit

    public func applyMaxInteger(maxInt: Int32): Unit

    public func roundToIncrement(roundingInterval: BigDecimal, mathContext: MathContext): Unit

    public func roundToNickel(magnitude: Int32, mathContext: MathContext): Unit

    public func roundToMagnitude(roundingMagnitude: Int32, mathContext: MathContext): Unit

    public func roundToInfinity(): Unit

    public func multiplyBy(multiplicand: BigDecimal): Unit

    func negate(): Unit

    public func adjustMagnitude(delta: Int32): Unit

    public func getMagnitude(): Int32

    public func getExponent(): Int32

    public func adjustExponent(delta: Int32): Unit

    public func resetExponent(): Unit

    public func isZeroish(): Bool

    public func isNegative(): Bool

    public func signum(): Modifier_Signum

    public override func isInfinite(): Bool

    public override func isNaN(): Bool

    public func toDouble(): Float64

    public func toBigDecimal(): BigDecimal

    public func toLong(truncateIfOverflow: Bool): Int64

    public func setToBigDecimal(input: BigDecimal): Unit

    public func maxRepresentableDigits(): Int32

    public func getStandardPlural(rules: PluralRules): StandardPlural

    public func getDigit(magnitude: Int32): UInt8

    public func getUpperDisplayMagnitude(): Int32

    public func getLowerDisplayMagnitude(): Int32

    public func toPlainString(): String

    public func toExponentString(): String

    public func createCopy(): DecimalQuantity

    public func copyFrom(other: DecimalQuantity): Unit

    public func getPositionFingerprint(): Int64

    public func populateUFieldPosition(fp: FieldPosition): Unit
}