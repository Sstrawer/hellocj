package icu4cj.impl.number

public class RoundingUtils {

    public static let SECTION_LOWER = 1

    public static let SECTION_MIDPOINT = 2

    public static let SECTION_UPPER = 3

    public static let DEFAULT_ROUNDING_MODE = RoundingMode.HALF_EVEN

    public static let MAX_INT_FRAC_SIG = 999

    public static func getRoundingDirection(isEven: Bool, isNegative: Bool, section: Int32, roundingMode: Int32, reference: Object): Bool {
        match (roundingMode) {
            case 0 => return false
            case 1 => return true
            case 2 => return isNegative
            case 3 => return !isNegative
            case 4 => match (section) {
                case 2 => return false
                case 1 => return true
                case 3 => return false
                case _ => ()
            }
            case 5 => match (section) {
                case 2 => return true
                case 1 => return true
                case 3 => return false
                case _ => ()
            }
            case 6 => match (section) {
                case 2 => return isEven
                case 1 => return true
                case 3 => return false
                case _ => ()
            }
            case _ => ()
        }
        throw ArithmeticException("Rounding is required on " + toString(reference))
    }

    public static func roundsAtMidpoint(roundingMode: Int32): Bool {
        match (roundingMode) {
            case 0 | 1 | 2 | 3 => return false
            case _ => return true
        }
    }

    private static let MATH_CONTEXT_BY_ROUNDING_MODE_UNLIMITED = Array<MathContext>(RoundingMode.values().size)

    private static let MATH_CONTEXT_BY_ROUNDING_MODE_34_DIGITS = Array<MathContext>(RoundingMode.values().size)


    public static let DEFAULT_MATH_CONTEXT_UNLIMITED = MATH_CONTEXT_BY_ROUNDING_MODE_UNLIMITED[Int64(DEFAULT_ROUNDING_MODE.ordinal())]

    public static let DEFAULT_MATH_CONTEXT_34_DIGITS = MATH_CONTEXT_BY_ROUNDING_MODE_34_DIGITS[Int64(DEFAULT_ROUNDING_MODE.ordinal())]

    public static func getMathContextOrUnlimited(properties: DecimalFormatProperties): MathContext {
        var mathContext = properties.getMathContext()
        if (mathContext.isNone()) {
            var roundingMode = properties.getRoundingMode()
            if (roundingMode.isNone()) {
                roundingMode = RoundingMode.HALF_EVEN
            }
            mathContext = MATH_CONTEXT_BY_ROUNDING_MODE_UNLIMITED[Int64(roundingMode.ordinal())]
        }
        return mathContext
    }

    public static func getMathContextOr34Digits(properties: DecimalFormatProperties): MathContext {
        var mathContext = properties.getMathContext()
        if (mathContext.isNone()) {
            var roundingMode = properties.getRoundingMode()
            if (roundingMode.isNone()) {
                roundingMode = RoundingMode.HALF_EVEN
            }
            mathContext = MATH_CONTEXT_BY_ROUNDING_MODE_34_DIGITS[Int64(roundingMode.ordinal())]
        }
        return mathContext
    }

    public static func mathContextUnlimited(roundingMode: RoundingMode): MathContext {
        return MATH_CONTEXT_BY_ROUNDING_MODE_UNLIMITED[Int64(roundingMode.ordinal())]
    }

    public static func scaleFromProperties(properties: DecimalFormatProperties): Scale {
        let mc = getMathContextOr34Digits(properties)
        if (properties.getMagnitudeMultiplier() != 0) {
            return Scale.powerOfTen(properties.getMagnitudeMultiplier()).withMathContext(mc)
        } else if (properties.getMultiplier().isSome()) {
            return Scale.byBigDecimal(properties.getMultiplier()).withMathContext(mc)
        } else {
            return None
        }
    }

    public static func getPluralSafe(rounder: Precision, rules: PluralRules, dq: DecimalQuantity): StandardPlural {
        if (rounder.isNone()) {
            return dq.getStandardPlural(rules)
        }
        let copy = dq.createCopy()
        rounder.apply(copy)
        return copy.getStandardPlural(rules)
    }
}
