package icu4cj.number


public abstract class Precision {
    var mathContext: MathContext = None

    var trailingZeroDisplay: NumberFormatter_TrailingZeroDisplay

    init() {
        mathContext = RoundingUtils.DEFAULT_MATH_CONTEXT_UNLIMITED
    }

    public static func unlimited(): Precision {
        return constructInfinite()
    }

    public static func integer(): FractionPrecision {
        return constructFraction(0, 0)
    }

    public static func fixedFraction(minMaxFractionPlaces: Int32): FractionPrecision {
        if (minMaxFractionPlaces >= 0 && minMaxFractionPlaces <= RoundingUtils.MAX_INT_FRAC_SIG) {
            return constructFraction(minMaxFractionPlaces, minMaxFractionPlaces)
        } else {
            throw IllegalArgumentException("Fraction length must be between 0 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }

    public static func minFraction(minFractionPlaces: Int32): FractionPrecision {
        if (minFractionPlaces >= 0 && minFractionPlaces <= RoundingUtils.MAX_INT_FRAC_SIG) {
            return constructFraction(minFractionPlaces, -1)
        } else {
            throw IllegalArgumentException("Fraction length must be between 0 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }

    public static func maxFraction(maxFractionPlaces: Int32): FractionPrecision {
        if (maxFractionPlaces >= 0 && maxFractionPlaces <= RoundingUtils.MAX_INT_FRAC_SIG) {
            return constructFraction(0, maxFractionPlaces)
        } else {
            throw IllegalArgumentException("Fraction length must be between 0 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }

    public static func minMaxFraction(minFractionPlaces: Int32, maxFractionPlaces: Int32): FractionPrecision {
        if (minFractionPlaces >= 0 && maxFractionPlaces <= RoundingUtils.MAX_INT_FRAC_SIG && minFractionPlaces <= maxFractionPlaces) {
            return constructFraction(minFractionPlaces, maxFractionPlaces)
        } else {
            throw IllegalArgumentException("Fraction length must be between 0 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }

    public static func fixedSignificantDigits(minMaxSignificantDigits: Int32): Precision {
        if (minMaxSignificantDigits >= 1 && minMaxSignificantDigits <= RoundingUtils.MAX_INT_FRAC_SIG) {
            return constructSignificant(minMaxSignificantDigits, minMaxSignificantDigits)
        } else {
            throw IllegalArgumentException("Significant digits must be between 1 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }

    public static func minSignificantDigits(minSignificantDigits: Int32): Precision {
        if (minSignificantDigits >= 1 && minSignificantDigits <= RoundingUtils.MAX_INT_FRAC_SIG) {
            return constructSignificant(minSignificantDigits, -1)
        } else {
            throw IllegalArgumentException("Significant digits must be between 1 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }

    public static func maxSignificantDigits(maxSignificantDigits: Int32): Precision {
        if (maxSignificantDigits >= 1 && maxSignificantDigits <= RoundingUtils.MAX_INT_FRAC_SIG) {
            return constructSignificant(1, maxSignificantDigits)
        } else {
            throw IllegalArgumentException("Significant digits must be between 1 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }

    public static func minMaxSignificantDigits(minSignificantDigits: Int32, maxSignificantDigits: Int32): Precision {
        if (minSignificantDigits >= 1 && maxSignificantDigits <= RoundingUtils.MAX_INT_FRAC_SIG && minSignificantDigits <= maxSignificantDigits) {
            return constructSignificant(minSignificantDigits, maxSignificantDigits)
        } else {
            throw IllegalArgumentException("Significant digits must be between 1 and " + RoundingUtils.MAX_INT_FRAC_SIG.toString() + " (inclusive)")
        }
    }

    public static func increment(roundingIncrement: BigDecimal): Precision {
        if (roundingIncrement.isSome() && roundingIncrement.compare(BigDecimal.ZERO) > 0) {
            return constructIncrement(roundingIncrement)
        } else {
            throw IllegalArgumentException("Rounding increment must be positive and non-null")
        }
    }

    public static func currency(currencyUsage: Currency_CurrencyUsage): CurrencyPrecision {
        if (currencyUsage.isSome()) {
            return constructCurrency(currencyUsage)
        } else {
            throw IllegalArgumentException("CurrencyUsage must be non-null")
        }
    }

    public func trailingZeroDisplayMethod(trailingZeroDisplay: NumberFormatter_TrailingZeroDisplay): Precision {
        let result = this.createCopy()
        result.trailingZeroDisplay = trailingZeroDisplay
        return result
    }

    
    public func withMode(mathContext: MathContext): Precision {
        if (refEq(this.mathContext, mathContext)) {
            return this
        }
        let other = createCopy()
        other.mathContext = mathContext
        return other
    }

    public func createCopy(): Precision

    public func createCopyHelper(copy: Precision): Unit {
        copy.mathContext = mathContext
        copy.trailingZeroDisplay = trailingZeroDisplay
    }

    
    public func apply(value: DecimalQuantity): Unit

    
    public static let BOGUS_PRECISION = Precision_BogusRounder()

    static let NONE = Precision_InfiniteRounderImpl()

    static let FIXED_FRAC_0 = Precision_FractionRounderImpl(0, 0)

    static let FIXED_FRAC_2 = Precision_FractionRounderImpl(2, 2)

    static let DEFAULT_MAX_FRAC_6 = Precision_FractionRounderImpl(0, 6)

    static let FIXED_SIG_2 = Precision_SignificantRounderImpl(2, 2)

    static let FIXED_SIG_3 = Precision_SignificantRounderImpl(3, 3)

    static let RANGE_SIG_2_3 = Precision_SignificantRounderImpl(2, 3)

    static let COMPACT_STRATEGY = Precision_FracSigRounderImpl(0, 0, 1, 2, NumberFormatter_RoundingPriority.RELAXED, false)

    static let NICKEL = Precision_IncrementFiveRounderImpl(Decimal("0.05"), 2, 2)

    static let MONETARY_STANDARD = Precision_CurrencyRounderImpl(Currency_CurrencyUsage.STANDARD)

    static let MONETARY_CASH = Precision_CurrencyRounderImpl(Currency_CurrencyUsage.CASH)

    static func constructInfinite(): Precision {
        return NONE
    }

    static func constructFraction(minFrac: Int32, maxFrac: Int32): FractionPrecision {
        if (minFrac == 0 && maxFrac == 0) {
            return FIXED_FRAC_0
        } else if (minFrac == 2 && maxFrac == 2) {
            return FIXED_FRAC_2
        } else if (minFrac == 0 && maxFrac == 6) {
            return DEFAULT_MAX_FRAC_6
        } else {
            return Precision_FractionRounderImpl(minFrac, maxFrac)
        }
    }

    static func constructSignificant(minSig: Int32, maxSig: Int32): Precision {
        if (minSig == 2 && maxSig == 2) {
            return FIXED_SIG_2
        } else if (minSig == 3 && maxSig == 3) {
            return FIXED_SIG_3
        } else if (minSig == 2 && maxSig == 3) {
            return RANGE_SIG_2_3
        } else {
            return Precision_SignificantRounderImpl(minSig, maxSig)
        }
    }

    static func constructFractionSignificant(base_: FractionPrecision, minSig: Int32, maxSig: Int32, priority: NumberFormatter_RoundingPriority, retain: Bool): Precision {
        if (!checkOptionalIs<Precision_FractionRounderImpl, FractionPrecision>(base_)) {
            throw AssertionError()
        }
        let base = base_
        let returnValue: Precision
        if (base.minFrac == 0 && base.maxFrac == 0 && minSig == 1 && maxSig == 2 && refEq(priority, NumberFormatter_RoundingPriority.RELAXED) && !retain) {
            returnValue = COMPACT_STRATEGY
        } else {
            returnValue = Precision_FracSigRounderImpl(base.minFrac, base.maxFrac, minSig, maxSig, priority, retain)
        }
        return returnValue.withMode(base.mathContext)
    }

    static func constructIncrement(increment: BigDecimal): Precision {
        if (refEq(increment, NICKEL.increment)) {
            return NICKEL
        }
        let reduced = increment.stripTrailingZeros()
        if (reduced.precision() == 1) {
            let minFrac = increment.scale()
            let maxFrac = reduced.scale()
            let digit = reduced.unscaledValue()
            if (digit.intValue() == 1) {
                return Precision_IncrementOneRounderImpl(increment, minFrac, maxFrac)
            } else if (digit.intValue() == 5) {
                return Precision_IncrementFiveRounderImpl(increment, minFrac, maxFrac)
            }
        }
        return Precision_IncrementRounderImpl(increment)
    }

    static func constructCurrency(usage: Currency_CurrencyUsage): CurrencyPrecision {
        if (refEq(usage, Currency_CurrencyUsage.STANDARD)) {
            return MONETARY_STANDARD
        } else if (refEq(usage, Currency_CurrencyUsage.CASH)) {
            return MONETARY_CASH
        } else {
            throw AssertionError()
        }
    }

    static func constructFromCurrency(base_: CurrencyPrecision, currency: Currency): Precision {
        if (!checkOptionalIs<Precision_CurrencyRounderImpl, CurrencyPrecision>(base_)) {
            throw AssertionError()
        }
        let base = base_
        let incrementDouble = currency.getRoundingIncrement(base.usage)
        let returnValue: Precision
        if (incrementDouble != 0.0) {
            let increment = BigDecimal.valueOf(incrementDouble)
            returnValue = constructIncrement(increment)
        } else {
            let minMaxFrac = currency.getDefaultFractionDigits(base.usage)
            returnValue = constructFraction(minMaxFrac, minMaxFrac)
        }
        return returnValue.withMode(base.mathContext)
    }

    public func withLocaleData(currency: Currency): Precision {
        if (checkOptionalIs<CurrencyPrecision, Precision>(this)) {
            return (this as CurrencyPrecision).withCurrency(currency)
        } else {
            return this
        }
    }

    public func chooseMultiplierAndApply(input: DecimalQuantity, producer: MultiplierProducer): Int32 {
        if (!(!input.isZeroish())) {
            throw AssertionError()
        }
        let magnitude = input.getMagnitude()
        let multiplier = producer.getMultiplier(magnitude)
        input.adjustMagnitude(multiplier)
        apply(input)
        if (input.isZeroish()) {
            return multiplier
        }
        if (input.getMagnitude() == magnitude + multiplier) {
            return multiplier
        }
        let _multiplier = producer.getMultiplier(magnitude + 1)
        if (multiplier == _multiplier) {
            return multiplier
        }
        input.adjustMagnitude(_multiplier - multiplier)
        apply(input)
        return _multiplier
    }

    static func getRoundingMagnitudeFraction(maxFrac: Int32): Int32 {
        if (maxFrac == -1) {
            return Int32.Min
        }
        return -maxFrac
    }

    static func getRoundingMagnitudeSignificant(value: DecimalQuantity, maxSig: Int32): Int32 {
        if (maxSig == -1) {
            return Int32.Min
        }
        let magnitude = if (value.isZeroish()) { 0 } else { value.getMagnitude() }
        return magnitude - maxSig + 1
    }

    static func getDisplayMagnitudeFraction(minFrac: Int32): Int32 {
        if (minFrac == 0) {
            return Int32.Max
        }
        return -minFrac
    }

    public func setResolvedMinFraction(value: DecimalQuantity, resolvedMinFraction: Int32): Unit {
        if (trailingZeroDisplay.isNone() || refEq(trailingZeroDisplay, NumberFormatter_TrailingZeroDisplay.AUTO) || value.getPluralOperand(PluralRules_Operand.t) != 0.0) {
            value.setMinFraction(resolvedMinFraction)
        }
    }

    static func getDisplayMagnitudeSignificant(value: DecimalQuantity, minSig: Int32): Int32 {
        let magnitude = if (value.isZeroish()) { 0 } else { value.getMagnitude() }
        return magnitude - minSig + 1
    }
}



public class Precision_BogusRounder <: Precision {
    
    public init() {
        super()
    }

    
    public override func apply(value: DecimalQuantity): Unit {
        throw Exception("BogusRounder must not be applied")
    }

    public override func createCopy(): Precision_BogusRounder {
        let copy = Precision_BogusRounder()
        createCopyHelper(copy)
        return copy
    }

    
    public func into(precision: Precision): Precision {
        let copy = precision.createCopy()
        createCopyHelper(copy)
        return copy
    }
}


class Precision_InfiniteRounderImpl <: Precision {
    public init() {
        super()
    }

    public override func apply(value: DecimalQuantity): Unit {
        value.roundToInfinity()
        setResolvedMinFraction(value, 0)
    }

    public override func createCopy(): Precision_InfiniteRounderImpl {
        let copy = Precision_InfiniteRounderImpl()
        createCopyHelper(copy)
        return copy
    }
}


class Precision_FractionRounderImpl <: FractionPrecision {
    let minFrac: Int32

    let maxFrac: Int32

    public init(minFrac: Int32, maxFrac: Int32) {
        super()
        this.minFrac = minFrac
        this.maxFrac = maxFrac
    }

    public override func apply(value: DecimalQuantity): Unit {
        value.roundToMagnitude(Precision.getRoundingMagnitudeFraction(maxFrac), mathContext)
        setResolvedMinFraction(value, max(0, -Precision.getDisplayMagnitudeFraction(minFrac)))
    }

    public override func createCopy(): Precision_FractionRounderImpl {
        let copy = Precision_FractionRounderImpl(minFrac, maxFrac)
        createCopyHelper(copy)
        return copy
    }
}


class Precision_SignificantRounderImpl <: Precision {
    let minSig: Int32

    let maxSig: Int32

    public init(minSig: Int32, maxSig: Int32) {
        super()
        this.minSig = minSig
        this.maxSig = maxSig
    }

    public override func apply(value: DecimalQuantity): Unit {
        value.roundToMagnitude(Precision.getRoundingMagnitudeSignificant(value, maxSig), mathContext)
        setResolvedMinFraction(value, max(0, -Precision.getDisplayMagnitudeSignificant(value, minSig)))
        if (value.isZeroish() && minSig > 0) {
            value.setMinInteger(1)
        }
    }

    public func apply(quantity: DecimalQuantity, minInt: Int32): Unit {
        if (!quantity.isZeroish()) {
            throw AssertionError()
        }
        setResolvedMinFraction(quantity, minSig - minInt)
    }

    public override func createCopy(): Precision_SignificantRounderImpl {
        let copy = Precision_SignificantRounderImpl(minSig, maxSig)
        createCopyHelper(copy)
        return copy
    }
}


class Precision_FracSigRounderImpl <: Precision {
    let minFrac: Int32

    let maxFrac: Int32

    let minSig: Int32

    let maxSig: Int32

    let priority: NumberFormatter_RoundingPriority

    let retain: Bool

    public init(minFrac: Int32, maxFrac: Int32, minSig: Int32, maxSig: Int32, priority: NumberFormatter_RoundingPriority, retain: Bool) {
        super()
        this.minFrac = minFrac
        this.maxFrac = maxFrac
        this.minSig = minSig
        this.maxSig = maxSig
        this.priority = priority
        this.retain = retain
    }

    public override func apply(value: DecimalQuantity): Unit {
        let roundingMag1 = getRoundingMagnitudeFraction(maxFrac)
        var roundingMag2 = getRoundingMagnitudeSignificant(value, maxSig)
        let roundingMag: Int32
        if (refEq(priority, NumberFormatter_RoundingPriority.RELAXED)) {
            roundingMag = min(roundingMag1, roundingMag2)
        } else {
            roundingMag = max(roundingMag1, roundingMag2)
        }
        if (!value.isZeroish()) {
            let upperMag = value.getMagnitude()
            value.roundToMagnitude(roundingMag, mathContext)
            if (!value.isZeroish() && value.getMagnitude() != upperMag && roundingMag1 == roundingMag2) {
                roundingMag2 += 1
            }
        }
        let displayMag1 = getDisplayMagnitudeFraction(minFrac)
        let displayMag2 = getDisplayMagnitudeSignificant(value, minSig)
        let displayMag: Int32
        if (retain) {
            displayMag = min(displayMag1, displayMag2)
        } else if (refEq(priority, NumberFormatter_RoundingPriority.RELAXED)) {
            if (roundingMag2 <= roundingMag1) {
                displayMag = displayMag2
            } else {
                displayMag = displayMag1
            }
        } else {
            if (!(refEq(priority, NumberFormatter_RoundingPriority.STRICT))) {
                throw AssertionError()
            }
            if (roundingMag2 <= roundingMag1) {
                displayMag = displayMag1
            } else {
                displayMag = displayMag2
            }
        }
        setResolvedMinFraction(value, max(0, -displayMag))
    }

    public override func createCopy(): Precision_FracSigRounderImpl {
        let copy = Precision_FracSigRounderImpl(minFrac, maxFrac, minSig, maxSig, priority, retain)
        createCopyHelper(copy)
        return copy
    }
}


class Precision_IncrementRounderImpl <: Precision {
    let increment: BigDecimal

    public init(increment: BigDecimal) {
        super()
        this.increment = increment
    }

    public override func apply(value: DecimalQuantity): Unit {
        value.roundToIncrement(increment, mathContext)
        setResolvedMinFraction(value, max(0, increment.scale()))
    }

    public override func createCopy(): Precision_IncrementRounderImpl {
        let copy = Precision_IncrementRounderImpl(increment)
        createCopyHelper(copy)
        return copy
    }
}


class Precision_IncrementOneRounderImpl <: Precision_IncrementRounderImpl {
    let minFrac: Int32

    let maxFrac: Int32

    public init(increment: BigDecimal, minFrac: Int32, maxFrac: Int32) {
        super(increment)
        this.minFrac = minFrac
        this.maxFrac = maxFrac
    }

    public override func apply(value: DecimalQuantity): Unit {
        value.roundToMagnitude(-maxFrac, mathContext)
        setResolvedMinFraction(value, minFrac)
    }

    public override func createCopy(): Precision_IncrementOneRounderImpl {
        let copy = Precision_IncrementOneRounderImpl(increment, minFrac, maxFrac)
        createCopyHelper(copy)
        return copy
    }
}


class Precision_IncrementFiveRounderImpl <: Precision_IncrementRounderImpl {
    let minFrac: Int32

    let maxFrac: Int32

    public init(increment: BigDecimal, minFrac: Int32, maxFrac: Int32) {
        super(increment)
        this.minFrac = minFrac
        this.maxFrac = maxFrac
    }

    public override func apply(value: DecimalQuantity): Unit {
        value.roundToNickel(-maxFrac, mathContext)
        setResolvedMinFraction(value, minFrac)
    }

    public override func createCopy(): Precision_IncrementFiveRounderImpl {
        let copy = Precision_IncrementFiveRounderImpl(increment, minFrac, maxFrac)
        createCopyHelper(copy)
        return copy
    }
}


class Precision_CurrencyRounderImpl <: CurrencyPrecision {
    let usage: Currency_CurrencyUsage

    public init(usage: Currency_CurrencyUsage) {
        super()
        this.usage = usage
    }

    public override func apply(value: DecimalQuantity): Unit {
        throw AssertionError()
    }

    public override func createCopy(): Precision_CurrencyRounderImpl {
        let copy = Precision_CurrencyRounderImpl(usage)
        createCopyHelper(copy)
        return copy
    }
}
