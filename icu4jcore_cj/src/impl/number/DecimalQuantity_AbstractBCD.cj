package icu4cj.impl.number


public abstract class DecimalQuantity_AbstractBCD <: DecimalQuantity {

    protected var scale: Int32 = 0

    protected var precision: Int32 = 0

    protected var flags: UInt8 = 0

    protected static let NEGATIVE_FLAG = 1

    protected static let INFINITY_FLAG = 2

    protected static let NAN_FLAG = 4

    protected var origDouble: Float64 = 0.0

    protected var origDelta: Int32 = 0

    protected var isApproximate: Bool = false

    protected var lReqPos = 0

    protected var rReqPos = 0

    protected var exponent = 0

    public override func copyFrom(_other: DecimalQuantity): Unit {
        copyBcdFrom(_other)
        let other = _other
        lReqPos = other.lReqPos
        rReqPos = other.rReqPos
        scale = other.scale
        precision = other.precision
        flags = other.flags
        origDouble = other.origDouble
        origDelta = other.origDelta
        isApproximate = other.isApproximate
        exponent = other.exponent
    }

    public func clear(): DecimalQuantity_AbstractBCD {
        lReqPos = 0
        rReqPos = 0
        flags = 0
        setBcdToZero()
        return this
    }

    public override func setMinInteger(minInt: Int32): Unit {
        var tempminInt = minInt
        if (!(tempminInt >= 0)) {
            throw AssertionError()
        }
        if (tempminInt < lReqPos) {
            tempminInt = lReqPos
        }
        lReqPos = tempminInt
    }

    public override func setMinFraction(minFrac: Int32): Unit {
        if (!(minFrac >= 0)) {
            throw AssertionError()
        }
        rReqPos = -minFrac
    }

    public override func applyMaxInteger(maxInt: Int32): Unit {
        if (!(maxInt >= 0)) {
            throw AssertionError()
        }
        if (precision == 0) {
            return
        }
        if (maxInt <= scale) {
            setBcdToZero()
            return
        }
        let magnitude = getMagnitude()
        if (maxInt <= magnitude) {
            popFromLeft(magnitude - maxInt + 1)
            compact()
        }
    }

    public override func getPositionFingerprint(): Int64 {
        var fingerprint = 0
        fingerprint ^= (Int64(shl(lReqPos, 16)))
        fingerprint ^= (shl(Int64(rReqPos), 32))
        return fingerprint
    }

    public override func roundToIncrement(roundingIncrement: BigDecimal, mathContext: MathContext): Unit {
        if (!(roundingIncrement.stripTrailingZeros().precision() != 1 || roundingIncrement.stripTrailingZeros().unscaledValue().intValue() != 5 || roundingIncrement.stripTrailingZeros().unscaledValue().intValue() != 1)) {
            throw AssertionError()
        }
        var temp = toBigDecimal()
        temp = temp.divide(roundingIncrement, 0, mathContext.getRoundingMode()).multiply(roundingIncrement).round(mathContext)
        if (temp.signum() == 0) {
            setBcdToZero()
        } else {
            setToBigDecimal(temp)
        }
    }

    public override func multiplyBy(multiplicand: BigDecimal): Unit {
        if (isZeroish()) {
            return
        }
        var temp = toBigDecimal()
        temp = temp.multiply(multiplicand)
        setToBigDecimal(temp)
    }

    public override func negate(): Unit {
        flags ^= UInt8(NEGATIVE_FLAG)
    }

    public override func getMagnitude(): Int32 {
        if (precision == 0) {
            throw ArithmeticException("Magnitude is not well-defined for zero")
        } else {
            return scale + precision - 1
        }
    }

    public override func adjustMagnitude(delta: Int32): Unit {
        if (precision != 0) {
            scale = Utility.addExact(scale, delta)
            origDelta = Utility.addExact(origDelta, delta)
            Utility.addExact(scale, precision)
        }
    }

    public override func getExponent(): Int32 {
        return exponent
    }

    public override func adjustExponent(delta: Int32): Unit {
        exponent = exponent + delta
    }

    public override func resetExponent(): Unit {
        adjustMagnitude(exponent)
        exponent = 0
    }

    public override func isHasIntegerValue(): Bool {
        return scale >= 0
    }

    public override func getStandardPlural(rules: PluralRules): StandardPlural {
        if (rules.isNone()) {
            return StandardPlural.OTHER
        } else {
            let ruleString = rules.select(this)
            return StandardPlural.orOtherFromString(ruleString)
        }
    }

    public override func getPluralOperand(operand: PluralRules_Operand): Float64 {
        if (!(!isApproximate)) {
            throw AssertionError()
        }
        match (operand) {
            case PluralRules_Operand.i => return if (isNegative()) { Float64(-toLong(true)) } else { Float64(toLong(true)) }
            case PluralRules_Operand.f => return Float64(toFractionLong(true))
            case PluralRules_Operand.t => return Float64(toFractionLong(false))
            case PluralRules_Operand.v => return Float64(fractionCount())
            case PluralRules_Operand.w => return Float64(fractionCountWithoutTrailingZeros())
            case PluralRules_Operand.e => return Float64(getExponent())
            case PluralRules_Operand.c => return Float64(getExponent())
            case _ => return abs(toDouble())
        }
    }

    public override func populateUFieldPosition(fp: FieldPosition): Unit {
        if (checkOptionalIs<UFieldPosition, FieldPosition>(fp)) {
            fp.setFractionDigits(Int32(getPluralOperand(PluralRules_Operand.v)), Int64(getPluralOperand(PluralRules_Operand.f)))
        }
    }

    public override func getUpperDisplayMagnitude(): Int32 {
        if (!(!isApproximate)) {
            throw AssertionError()
        }
        let magnitude = scale + precision
        let result = if (lReqPos > magnitude) { lReqPos } else { magnitude }
        return result - 1
    }

    public override func getLowerDisplayMagnitude(): Int32 {
        if (!(!isApproximate)) {
            throw AssertionError()
        }
        let magnitude = scale
        let result = if (rReqPos < magnitude) { rReqPos } else { magnitude }
        return result
    }

    public override func getDigit(magnitude: Int32): UInt8 {
        if (!(!isApproximate)) {
            throw AssertionError()
        }
        return getDigitPos(magnitude - scale)
    }

    private func fractionCount(): Int32 {
        return max(0, -getLowerDisplayMagnitude() - exponent)
    }

    private func fractionCountWithoutTrailingZeros(): Int32 {
        return max(-scale - exponent, 0)
    }

    public override func isNegative(): Bool {
        return (Int32(flags) & NEGATIVE_FLAG) != 0
    }

    public override func signum(): Modifier_Signum {
        let isZero = (isZeroish() && !isInfinite())
        let isNeg = isNegative()
        if (isZero && isNeg) {
            return Modifier_Signum.NEG_ZERO
        } else if (isZero) {
            return Modifier_Signum.POS_ZERO
        } else if (isNeg) {
            return Modifier_Signum.NEG
        } else {
            return Modifier_Signum.POS
        }
    }

    public override func isInfinite(): Bool {
        return (Int32(flags) & INFINITY_FLAG) != 0
    }

    public override func isNaN(): Bool {
        return (Int32(flags) & NAN_FLAG) != 0
    }

    public override func isZeroish(): Bool {
        return precision == 0
    }

    public func setToInt(n: Int32): Unit {
        var tempn = n
        setBcdToZero()
        flags = 0
        if (tempn < 0) {
            flags |= UInt8(NEGATIVE_FLAG)
            tempn = -tempn
        }
        if (tempn != 0) {
            _setToInt(tempn)
            compact()
        }
    }

    private func _setToInt(n: Int32): Unit {
        if (n == Int32.Min) {
            readLongToBcd(-Int64(n))
        } else {
            readIntToBcd(n)
        }
    }

    public func setToLong(n: Int64): Unit {
        var tempn = n
        setBcdToZero()
        flags = 0
        if (tempn < 0) {
            flags |= UInt8(NEGATIVE_FLAG)
            tempn = -tempn
        }
        if (tempn != 0) {
            _setToLong(tempn)
            compact()
        }
    }

    private func _setToLong(n: Int64): Unit {
        if (n == Int64.Min) {
            readBigIntToBcd(BigInt.valueOf(n).negate())
        } else if (n <= Int64(Int32.Max)) {
            readIntToBcd(Int32(n))
        } else {
            readLongToBcd(n)
        }
    }

    public func setToBigInt(n: BigInt): Unit {
        var tempn = n
        setBcdToZero()
        flags = 0
        if (tempn.signum() == -1) {
            flags |= UInt8(NEGATIVE_FLAG)
            tempn = tempn.negate()
        }
        if (tempn.signum() != 0) {
            _setToBigInteger(tempn)
            compact()
        }
    }

    private func _setToBigInt(n: BigInt): Unit {
        if (n.bitLength() < 32) {
            readIntToBcd(n.intValue())
        } else if (n.bitLength() < 64) {
            readLongToBcd(n.toInt64())
        } else {
            readBigIntegerToBcd(n)
        }
    }

    public func setToDouble(n: Float64): Unit {
        var tempn = n
        setBcdToZero()
        flags = 0
        if (Float64.doubleToRawLongBits(tempn) < 0) {
            flags |= UInt8(NEGATIVE_FLAG)
            tempn = -tempn
        }
        if (Float64.isNaN(tempn)) {
            flags |= UInt8(NAN_FLAG)
        } else if (Float64.isInfinite(tempn)) {
            flags |= UInt8(INFINITY_FLAG)
        } else if (tempn != 0.0) {
            _setToDoubleFast(tempn)
            compact()
        }
    }

    private static let DOUBLE_MULTIPLIERS = [1.0, 10.0, 100.0, 1000.0, 10000.0, 100000.0, 1000000.0, 1.0E7, 1.0E8, 1.0E9, 1.0E10, 1.0E11, 1.0E12, 1.0E13, 1.0E14, 1.0E15, 1.0E16, 1.0E17, 1.0E18, 1.0E19, 1.0E20, 1.0E21]

    private func _setToDoubleFast(n: Float64): Unit {
        var tempn = n
        isApproximate = true
        origDouble = tempn
        origDelta = 0
        let ieeeBits = Float64.doubleToLongBits(tempn)
        let exponent = Int32(shr((ieeeBits & 9218868437227405312), 52)) - 1023
        if (exponent <= 52 && Float64(Int64(tempn)) == tempn) {
            _setToLong(Int64(tempn))
            return
        }
        if (exponent == -1023 || exponent == 1024) {
            convertToAccurateDouble()
            return
        }
        let fracLength = Int32((Float64(52 - exponent)) / 3.321928094887362)
        if (fracLength >= 0) {
            var i = fracLength
            while (i >= 22) {
                tempn *= 1.0E22
                i -= 22
            }
            tempn *= DOUBLE_MULTIPLIERS[Int64(i)]
        } else {
            var i = fracLength
            while (i <= -22) {
                tempn /= 1.0E22
                i += 22
            }
            tempn /= DOUBLE_MULTIPLIERS[Int64(-i)]
        }
        let result = Math.round(tempn)
        if (result != 0) {
            _setToLong(result)
            scale -= fracLength
        }
    }

    private func convertToAccurateDouble(): Unit {
        let n = origDouble
        if (!(n != 0.0)) {
            throw AssertionError()
        }
        let delta = origDelta
        setBcdToZero()
        let dstr: String = n.toString()
        if (indexOfWrap(dstr.indexOf(UInt8(UInt32('E')))) != -1) {
            if (!(indexOfWrap(dstr.indexOf(UInt8(UInt32('.')))) == 1)) {
                throw AssertionError()
            }
            let expPos = indexOfWrap(dstr.indexOf(UInt8(UInt32('E'))))
            _setToLong(parse<Int64>((Char(dstr[0])).toString() + dstr[2..Int64(expPos)]))
            scale += parse<Int32>(dstr[Int64(expPos + 1)..]) - (expPos - 1) + 1
        } else if (Char(dstr[0]) == '0') {
            if (!(indexOfWrap(dstr.indexOf(UInt8(UInt32('.')))) == 1)) {
                throw AssertionError()
            }
            _setToLong(parse<Int64>(dstr[2..]))
            scale += 2 - Int32(dstr.size)
        } else if (Char(dstr[Int64(Int32(dstr.size) - 1)]) == '0') {
            if (!(indexOfWrap(dstr.indexOf(UInt8(UInt32('.')))) == Int32(dstr.size) - 2)) {
                throw AssertionError()
            }
            if (!(Int32(dstr.size) - 2 <= 18)) {
                throw AssertionError()
            }
            _setToLong(parse<Int64>(dstr[0..Int64(Int32(dstr.size) - 2)]))
        } else {
            let decimalPos = indexOfWrap(dstr.indexOf(UInt8(UInt32('.'))))
            _setToLong(parse<Int64>(dstr[0..Int64(decimalPos)] + dstr[Int64(decimalPos + 1)..]))
            scale += decimalPos - Int32(dstr.size) + 1
        }
        scale += delta
        compact()
        explicitExactDouble = true
    }

    
    public var explicitExactDouble = false

    public override func setToBigDecimal(n: BigDecimal): Unit {
        var tempn = n
        setBcdToZero()
        flags = 0
        if (tempn.signum() == -1) {
            flags |= UInt8(NEGATIVE_FLAG)
            tempn = tempn.negate()
        }
        if (tempn.signum() != 0) {
            _setToBigDecimal(tempn)
            compact()
        }
    }

    private func _setToBigDecimal(n: BigDecimal): Unit {
        var tempn = n
        let fracLength = tempn.scale()
        tempn = tempn.scaleByPowerOfTen(fracLength)
        let bi = tempn.toBigInt()
        _setToBigInteger(bi)
        scale -= fracLength
    }

    public override func toLong(truncateIfOverflow: Bool): Int64 {
        if (!(truncateIfOverflow || fitsInLong())) {
            throw AssertionError()
        }
        var result = 0
        var upperMagnitude = exponent + scale + precision - 1
        if (truncateIfOverflow) {
            upperMagnitude = min(upperMagnitude, 17)
        }
        var magnitude = upperMagnitude
        while (magnitude >= 0) {
            result = result * 10 + Int64(getDigitPos(magnitude - scale - exponent))
            magnitude--
        }
        if (isNegative()) {
            result = -result
        }
        return result
    }

    public func toFractionLong(includeTrailingZeros: Bool): Int64 {
        var result = 0
        var magnitude = -1 - exponent
        var lowerMagnitude = scale
        if (includeTrailingZeros) {
            lowerMagnitude = min(lowerMagnitude, rReqPos)
        }
        while (magnitude >= lowerMagnitude && Float64(result) <= 1.0E17) {
            result = result * 10 + Int64(getDigitPos(magnitude - scale))
            magnitude--
        }
        if (!includeTrailingZeros) {
            while (result > 0 && (result % 10) == 0) {
                result /= 10
            }
        }
        return result
    }

    static let INT64_BCD: Array<UInt8> = [9, 2, 2, 3, 3, 7, 2, 0, 3, 6, 8, 5, 4, 7, 7, 5, 8, 0, 8]

    public func fitsInLong(): Bool {
        if (isInfinite() || isNaN()) {
            return false
        }
        if (isZeroish()) {
            return true
        }
        if (exponent + scale < 0) {
            return false
        }
        let magnitude = getMagnitude()
        if (magnitude < 18) {
            return true
        }
        if (magnitude > 18) {
            return false
        }
        var p = 0
        while (p < precision) {
            let digit = getDigit(18 - p)
            if (digit < INT64_BCD[Int64(p)]) {
                return true
            } else if (digit > INT64_BCD[Int64(p)]) {
                return false
            }
            p++
        }
        return isNegative()
    }

    public override func toDouble(): Float64 {
        if (!(!isApproximate)) {
            throw AssertionError()
        }
        if (isNaN()) {
            return Float64.NaN
        } else if (isInfinite()) {
            return if (isNegative()) { Float64.NEGATIVE_INFINITY } else { Float64.POSITIVE_INFINITY }
        }
        let sb = StringBuilder()
        toScientificString(sb)
        return parse<Float64>(sb.toString())
    }

    public override func toBigDecimal(): BigDecimal {
        if (isApproximate) {
            convertToAccurateDouble()
        }
        return bcdToBigDecimal()
    }

    private static func safeSubtract(a: Int32, b: Int32): Int32 {
        let diff = a - b
        if (b < 0 && diff < a) {
            return Int32.Max
        }
        if (b > 0 && diff > a) {
            return Int32.Min
        }
        return diff
    }

    private static let SECTION_LOWER_EDGE = -1

    private static let SECTION_UPPER_EDGE = -2

    public func truncate(): Unit {
        if (scale < 0) {
            shiftRight(-scale)
            scale = 0
            compact()
        }
    }

    public override func roundToNickel(magnitude: Int32, mathContext: MathContext): Unit {
        roundToMagnitude(magnitude, mathContext, true)
    }

    public override func roundToMagnitude(magnitude: Int32, mathContext: MathContext): Unit {
        roundToMagnitude(magnitude, mathContext, false)
    }

    private func roundToMagnitude(magnitude: Int32, mathContext: MathContext, nickel: Bool): Unit {
        var position = safeSubtract(magnitude, scale)
        let _mcPrecision = mathContext.getPrecision()
        if (_mcPrecision > 0 && precision - _mcPrecision > position) {
            position = precision - _mcPrecision
        }
        var trailingDigit = getDigitPos(position)
        if (position <= 0 && !isApproximate && (!nickel || Int32(trailingDigit) == 0 || Int32(trailingDigit) == 5)) { } else if (precision == 0) { } else {
            let leadingDigit = getDigitPos(safeSubtract(position, 1))
            var section: Int32 = 0
            if (!isApproximate) {
                if (nickel && Int32(trailingDigit) != 2 && Int32(trailingDigit) != 7) {
                    if (Int32(trailingDigit) < 2) {
                        section = RoundingUtils.SECTION_LOWER
                    } else if (Int32(trailingDigit) < 5) {
                        section = RoundingUtils.SECTION_UPPER
                    } else if (Int32(trailingDigit) < 7) {
                        section = RoundingUtils.SECTION_LOWER
                    } else {
                        section = RoundingUtils.SECTION_UPPER
                    }
                } else if (Int32(leadingDigit) < 5) {
                    section = RoundingUtils.SECTION_LOWER
                } else if (Int32(leadingDigit) > 5) {
                    section = RoundingUtils.SECTION_UPPER
                } else {
                    section = RoundingUtils.SECTION_MIDPOINT
                            p--
                        }
                    } while (false)
                }
            } else {
                var p = safeSubtract(position, 2)
                let minP = max(0, precision - 14)
                if (Int32(leadingDigit) == 0 && (!nickel || Int32(trailingDigit) == 0 || Int32(trailingDigit) == 5)) {
                    section = SECTION_LOWER_EDGE
                    while (p >= minP) {
                        if (Int32(getDigitPos(p)) != 0) {
                            section = RoundingUtils.SECTION_LOWER
                            break
                        }
                        p--
                    }
                } else if (Int32(leadingDigit) == 4 && (!nickel || Int32(trailingDigit) == 2 || Int32(trailingDigit) == 7)) {
                    section = RoundingUtils.SECTION_MIDPOINT
                    while (p >= minP) {
                        if (Int32(getDigitPos(p)) != 9) {
                            section = RoundingUtils.SECTION_LOWER
                            break
                        }
                        p--
                    }
                } else if (Int32(leadingDigit) == 5 && (!nickel || Int32(trailingDigit) == 2 || Int32(trailingDigit) == 7)) {
                    section = RoundingUtils.SECTION_MIDPOINT
                    while (p >= minP) {
                        if (Int32(getDigitPos(p)) != 0) {
                            section = RoundingUtils.SECTION_UPPER
                            break
                        }
                        p--
                    }
                } else if (Int32(leadingDigit) == 9 && (!nickel || Int32(trailingDigit) == 4 || Int32(trailingDigit) == 9)) {
                    section = SECTION_UPPER_EDGE
                    while (p >= minP) {
                        if (Int32(getDigitPos(p)) != 9) {
                            section = RoundingUtils.SECTION_UPPER
                            break
                        }
                        p--
                    }
                } else if (nickel && Int32(trailingDigit) != 2 && Int32(trailingDigit) != 7) {
                    if (Int32(trailingDigit) < 2) {
                        section = RoundingUtils.SECTION_LOWER
                    } else if (Int32(trailingDigit) < 5) {
                        section = RoundingUtils.SECTION_UPPER
                    } else if (Int32(trailingDigit) < 7) {
                        section = RoundingUtils.SECTION_LOWER
                    } else {
                        section = RoundingUtils.SECTION_UPPER
                    }
                } else if (Int32(leadingDigit) < 5) {
                    section = RoundingUtils.SECTION_LOWER
                } else {
                    section = RoundingUtils.SECTION_UPPER
                }
                let roundsAtMidpoint = RoundingUtils.roundsAtMidpoint(mathContext.getRoundingMode().ordinal())
                if (safeSubtract(position, 1) < precision - 14 || (roundsAtMidpoint && section == RoundingUtils.SECTION_MIDPOINT) || (!roundsAtMidpoint && section < 0)) {
                    convertToAccurateDouble()
                    roundToMagnitude(magnitude, mathContext, nickel)
                    return
                }
                isApproximate = false
                origDouble = 0.0
                origDelta = 0
                if (position <= 0 && (!nickel || Int32(trailingDigit) == 0 || Int32(trailingDigit) == 5)) {
                    return
                }
                if (section == SECTION_LOWER_EDGE) {
                    section = RoundingUtils.SECTION_LOWER
                }
                if (section == SECTION_UPPER_EDGE) {
                    section = RoundingUtils.SECTION_UPPER
                }
            }
            let isEven = if (nickel) { (Int32(trailingDigit) < 2 || Int32(trailingDigit) > 7 || (Int32(trailingDigit) == 2 && section != RoundingUtils.SECTION_UPPER) || (Int32(trailingDigit) == 7 && section == RoundingUtils.SECTION_UPPER)) } else { (Int32(trailingDigit) % 2) == 0 }
            let roundDown = RoundingUtils.getRoundingDirection(isEven, isNegative(), section, mathContext.getRoundingMode().ordinal(), this)
            if (position >= precision) {
                if (!(Int32(trailingDigit) == 0)) {
                    throw AssertionError()
                }
                setBcdToZero()
                scale = magnitude
            } else {
                shiftRight(position)
            }
            if (nickel) {
                if (Int32(trailingDigit) < 5 && roundDown) {
                    setDigitPos(0, 0)
                    compact()
                    return
                } else if (Int32(trailingDigit) >= 5 && !roundDown) {
                    setDigitPos(0, 9)
                    trailingDigit = 9
                } else {
                    setDigitPos(0, 5)
                    if (precision == 0) {
                        precision = 1
                    }
                    return
                }
            }
            if (!roundDown) {
                if (Int32(trailingDigit) == 9) {
                    var bubblePos = 0
                    while (Int32(getDigitPos(bubblePos)) == 9) {
                        bubblePos++
                    }
                    shiftRight(bubblePos)
                }
                let digit0 = getDigitPos(0)
                if (!(Int32(digit0) != 9)) {
                    throw AssertionError()
                }
                setDigitPos(0, UInt8(Int32(digit0) + 1))
                precision += 1
            }
            compact()
        }
    }

    public override func roundToInfinity(): Unit {
        if (isApproximate) {
            convertToAccurateDouble()
        }
    }

    
    public func appendDigit(value: UInt8, leadingZeros: Int32, appendAsInteger: Bool): Unit {
        var templeadingZeros = leadingZeros
        if (!(templeadingZeros >= 0)) {
            throw AssertionError()
        }
        if (Int32(value) == 0) {
            if (appendAsInteger && precision != 0) {
                scale += templeadingZeros + 1
            }
            return
        }
        if (scale > 0) {
            templeadingZeros += scale
            if (appendAsInteger) {
                scale = 0
            }
        }
        shiftLeft(templeadingZeros + 1)
        setDigitPos(0, value)
        if (appendAsInteger) {
            scale += templeadingZeros + 1
        }
    }

    public override func toPlainString(): String {
        let sb = StringBuilder()
        toPlainString(sb)
        return sb.toString()
    }

    public func toPlainString(result: StringBuilder): Unit {
        if (!(!isApproximate)) {
            throw AssertionError()
        }
        if (isNegative()) {
            result.append('-')
        }
        if (precision == 0) {
            result.append('0')
            return
        }
        var upper = scale + precision + exponent - 1
        var lower = scale + exponent
        if (upper < lReqPos - 1) {
            upper = lReqPos - 1
        }
        if (lower > rReqPos) {
            lower = rReqPos
        }
        var p = upper
        if (p < 0) {
            result.append('0')
        }
        while (p >= 0) {
            result.append(Char(Int32(UInt32('0')) + Int32(getDigitPos(p - scale - exponent))))
            p--
        }
        if (lower < 0) {
            result.append('.')
        }
        while (p >= lower) {
            result.append(Char(Int32(UInt32('0')) + Int32(getDigitPos(p - scale - exponent))))
            p--
        }
    }

    public func toScientificString(): String {
        let sb = StringBuilder()
        toScientificString(sb)
        return sb.toString()
    }

    public func toScientificString(result: StringBuilder): Unit {
        if (!(!isApproximate)) {
            throw AssertionError()
        }
        if (isNegative()) {
            result.append('-')
        }
        if (precision == 0) {
            result.append("0E+0")
            return
        }
        let upperPos = precision - 1
        let lowerPos = 0
        var p = upperPos
        result.append(Char(Int32(UInt32('0')) + Int32(getDigitPos(p))))
        if ((match (0) { case _ => p--; p }) >= lowerPos) {
            result.append('.')
            while (p >= lowerPos) {
                result.append(Char(Int32(UInt32('0')) + Int32(getDigitPos(p))))
                p--
            }
        }
        result.append('E')
        var _scale = upperPos + scale + exponent
        if (_scale == Int32.Min) {
            result.append("-2147483648")
            return
        } else if (_scale < 0) {
            _scale *= -1
            result.append('-')
        } else {
            result.append('+')
        }
        if (_scale == 0) {
            result.append('0')
        }
        let insertIndex = Int32(result.size)
        while (_scale > 0) {
            let quot = _scale / 10
            let rem = _scale % 10
            result.insert(Int64(insertIndex), Char(Int32(UInt32('0')) + rem))
            _scale = quot
        }
    }

    public override func toExponentString(): String {
        let sb = StringBuilder()
        toExponentString(sb)
        return sb.toString()
    }

    private func toExponentString(result: StringBuilder): Unit {
        if (!(!isApproximate)) {
            throw AssertionError()
        }
        if (isNegative()) {
            result.append('-')
        }
        var upper = scale + precision - 1
        var lower = scale
        if (upper < lReqPos - 1) {
            upper = lReqPos - 1
        }
        if (lower > rReqPos) {
            lower = rReqPos
        }
        var p = upper
        if (p < 0) {
            result.append('0')
        }
        while (p >= 0) {
            result.append(Char(Int32(UInt32('0')) + Int32(getDigitPos(p - scale))))
            p--
        }
        if (lower < 0) {
            result.append('.')
        }
        while (p >= lower) {
            result.append(Char(Int32(UInt32('0')) + Int32(getDigitPos(p - scale))))
            p--
        }
        if (exponent != 0) {
            result.append('c')
            result.append(exponent)
        }
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (other.isNone()) {
            return false
        }
        if (!(checkOptionalIs<DecimalQuantity_AbstractBCD, Object>(other))) {
            return false
        }
        let _other = other
        let basicEquals = scale == _other.scale && precision == _other.precision && flags == _other.flags && lReqPos == _other.lReqPos && rReqPos == _other.rReqPos && isApproximate == _other.isApproximate
        if (!basicEquals) {
            return false
        }
        if (precision == 0) {
            return true
        } else if (isApproximate) {
            return origDouble == _other.origDouble && origDelta == _other.origDelta
        } else {
            var m = getUpperDisplayMagnitude()
            while (m >= getLowerDisplayMagnitude()) {
                if (getDigit(m) != _other.getDigit(m)) {
                    return false
                }
                m--
            }
            return true
        }
    }

    protected func getDigitPos(position: Int32): UInt8

    protected func setDigitPos(position: Int32, value: UInt8): Unit

    protected func shiftLeft(numDigits: Int32): Unit

    protected func shiftRight(numDigits: Int32): Unit

    protected func popFromLeft(numDigits: Int32): Unit

    protected func setBcdToZero(): Unit

    protected func readIntToBcd(input: Int32): Unit

    protected func readLongToBcd(input: Int64): Unit

    protected func readBigIntToBcd(input: BigInt): Unit

    protected func bcdToBigDecimal(): BigDecimal

    protected func copyBcdFrom(_other: DecimalQuantity): Unit

    protected func compact(): Unit
}
