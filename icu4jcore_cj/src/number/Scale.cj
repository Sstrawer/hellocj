package icu4cj.number

public class Scale {
    private static let DEFAULT = Scale(0, None)

    private static let HUNDRED = Scale(2, None)

    private static let THOUSAND = Scale(3, None)

    private static let BIG_DECIMAL_100 = BigDecimal.valueOf(100)

    private static let BIG_DECIMAL_1000 = BigDecimal.valueOf(1000)

    let magnitude: Int32

    let arbitrary: BigDecimal

    let reciprocal: BigDecimal

    let mc: MathContext

    private init(magnitude: Int32, arbitrary: BigDecimal) {
        this(magnitude, arbitrary, RoundingUtils.DEFAULT_MATH_CONTEXT_34_DIGITS)
    }

    private init(magnitude: Int32, arbitrary: BigDecimal, mc: MathContext) {
        var temparbitrary = arbitrary
        var tempmagnitude = magnitude
        if (temparbitrary.isSome()) {
            temparbitrary = if (temparbitrary.compare(BigDecimal.ZERO) == 0) { BigDecimal.ZERO } else { temparbitrary.stripTrailingZeros() }
            if (temparbitrary.precision() == 1 && refEq(temparbitrary.unscaledValue(), BigInt.ONE)) {
                tempmagnitude -= temparbitrary.scale()
                temparbitrary = None
            }
        }
        this.magnitude = tempmagnitude
        this.arbitrary = temparbitrary
        this.mc = mc
        if (temparbitrary.isSome() && BigDecimal.ZERO.compare(temparbitrary) != 0) {
            this.reciprocal = BigDecimal.ONE.divide(temparbitrary, mc)
        } else {
            this.reciprocal = None
        }
    }

    public static func none(): Scale {
        return DEFAULT
    }

    public static func powerOfTen(power: Int32): Scale {
        if (power == 0) {
            return DEFAULT
        } else if (power == 2) {
            return HUNDRED
        } else if (power == 3) {
            return THOUSAND
        } else {
            return Scale(power, None)
        }
    }

    public static func byBigDecimal(multiplicand: BigDecimal): Scale {
        if (multiplicand.compare(BigDecimal.ONE) == 0) {
            return DEFAULT
        } else if (multiplicand.compare(BIG_DECIMAL_100) == 0) {
            return HUNDRED
        } else if (multiplicand.compare(BIG_DECIMAL_1000) == 0) {
            return THOUSAND
        } else {
            return Scale(0, multiplicand)
        }
    }

    public static func byDouble(multiplicand: Float64): Scale {
        if (multiplicand == 1.0) {
            return DEFAULT
        } else if (multiplicand == 100.0) {
            return HUNDRED
        } else if (multiplicand == 1000.0) {
            return THOUSAND
        } else {
            return Scale(0, BigDecimal.valueOf(multiplicand))
        }
    }

    public static func byDoubleAndPowerOfTen(multiplicand: Float64, power: Int32): Scale {
        return Scale(power, BigDecimal.valueOf(multiplicand))
    }

    public func isValid(): Bool {
        return magnitude != 0 || arbitrary.isSome()
    }

    
    public func withMathContext(mc: MathContext): Scale {
        if (refEq(this.mc, mc)) {
            return this
        }
        return Scale(magnitude, arbitrary, mc)
    }

    
    public func applyTo(quantity: DecimalQuantity): Unit {
        quantity.adjustMagnitude(magnitude)
        if (arbitrary.isSome()) {
            quantity.multiplyBy(arbitrary)
        }
    }

    
    public func applyReciprocalTo(quantity: DecimalQuantity): Unit {
        quantity.adjustMagnitude(-magnitude)
        if (reciprocal.isSome()) {
            quantity.multiplyBy(reciprocal)
            quantity.roundToMagnitude(quantity.getMagnitude() - mc.getPrecision(), mc)
        }
    }
}
