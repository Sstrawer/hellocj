package icu4cj.impl.number.parse


public class ParsedNumber {
    public var quantity: DecimalQuantity_DualStorageBCD

    public var charEnd: Int32 = 0

    public var flags: Int32 = 0

    public var prefix: String

    public var suffix: String

    public var currencyCode: String

    public static let FLAG_NEGATIVE = 1

    public static let FLAG_PERCENT = 2

    public static let FLAG_PERMILLE = 4

    public static let FLAG_HAS_EXPONENT = 8

    public static let FLAG_HAS_DECIMAL_SEPARATOR = 32

    public static let FLAG_NAN = 64

    public static let FLAG_INFINITY = 128

    public static let FLAG_FAIL = 256

    public static let COMPARATOR = ParsedNumber_1()

    public init() {
        clear()
    }

    public func clear(): Unit {
        quantity = None
        charEnd = 0
        flags = 0
        prefix = None
        suffix = None
        currencyCode = None
    }

    public func copyFrom(other: ParsedNumber): Unit {
        quantity = if (other.quantity.isNone()) { None } else { other.quantity.createCopy() }
        charEnd = other.charEnd
        flags = other.flags
        prefix = other.prefix
        suffix = other.suffix
        currencyCode = other.currencyCode
    }

    public func setCharsConsumed(segment: StringSegment): Unit {
        charEnd = segment.getOffset()
    }

    public func postProcess(): Unit {
        if (quantity.isSome() && 0 != (flags & FLAG_NEGATIVE)) {
            quantity.negate()
        }
    }

    public func success(): Bool {
        return charEnd > 0 && 0 == (flags & FLAG_FAIL)
    }

    public func seenNumber(): Bool {
        return quantity.isSome() || 0 != (flags & FLAG_NAN) || 0 != (flags & FLAG_INFINITY)
    }

    public func getNumber(): Number {
        return getNumber(0)
    }

    public func getNumber(parseFlags: Int32): Number {
        let sawNaN = 0 != (flags & FLAG_NAN)
        let sawInfinity = 0 != (flags & FLAG_INFINITY)
        let forceBigDecimal = 0 != (parseFlags & ParsingUtils.PARSE_FLAG_FORCE_BIG_DECIMAL)
        let integerOnly = 0 != (parseFlags & ParsingUtils.PARSE_FLAG_INTEGER_ONLY)
        if (sawNaN) {
            return Float64.NaN
        }
        if (sawInfinity) {
            if (0 != (flags & FLAG_NEGATIVE)) {
                return Float64.NEGATIVE_INFINITY
            } else {
                return Float64.POSITIVE_INFINITY
            }
        }
        if (!quantity.isSome()) {
            throw AssertionError()
        }
        if (quantity.isZeroish() && quantity.isNegative() && !integerOnly) {
            return -0.0
        }
        if (quantity.fitsInLong() && !forceBigDecimal) {
            return quantity.toLong(false)
        } else {
            return quantity.toBigDecimal()
        }
    }

    public func isBetterThan(other: ParsedNumber): Bool {
        return COMPARATOR.compare(this, other) > 0
    }
}


class ParsedNumber_1 <: Comparator {

    public override func compare(o1: ParsedNumber, o2: ParsedNumber): Int32 {
        return o1.charEnd - o2.charEnd
    }
}
