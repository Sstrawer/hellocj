package icu4cj.impl.number


public class DecimalQuantity_DualStorageBCD <: DecimalQuantity_AbstractBCD {
    private var bcdBytes: Array<UInt8>

    private var bcdLong = 0

    private var usingBytes = false

    public override func maxRepresentableDigits(): Int32 {
        return Int32.Max
    }

    public init() {
        super()
        setBcdToZero()
        flags = 0
    }

    public init(input: Int64) {
        super()
        setToLong(input)
    }

    public init(input: Int32) {
        super()
        setToInt(input)
    }

    public init(input: Float64) {
        super()
        setToDouble(input)
    }

    public init(input: BigInt) {
        super()
        setToBigInteger(input)
    }

    public init(input: BigDecimal) {
        super()
        setToBigDecimal(input)
    }

    public init(other: DecimalQuantity_DualStorageBCD) {
        super()
        copyFrom(other)
    }

    public init(number: Number) {
        super()
        if (number) {
            setToLong(number.longValue())
        } else if (number) {
            setToInt(number.intValue())
        } else if (number) {
            setToDouble(number.doubleValue())
        } else if (number) {
            setToDouble(number.doubleValue())
        } else if (checkOptionalIs<BigInt, Number>(number)) {
            setToBigInteger(number)
        } else if (checkOptionalIs<BigDecimal, Number>(number)) {
            setToBigDecimal(number)
        } else if (checkOptionalIs<BigDecimal, Number>(number)) {
            setToBigDecimal(number.toBigDecimal())
        } else {
            throw IllegalArgumentException("Number is of an unsupported type: " + TypeInfo.of(number).name)
        }
    }

    public override func createCopy(): DecimalQuantity {
        return DecimalQuantity_DualStorageBCD(this)
    }

    public static func fromExponentString(num: String): DecimalQuantity {
        if (num.contains("e") || num.contains("c") || num.contains("E") || num.contains("C")) {
            var ePos = indexOfWrap(num.lastIndexOf(UInt8(UInt32('e'))))
            if (ePos < 0) {
                ePos = indexOfWrap(num.lastIndexOf(UInt8(UInt32('c'))))
            }
            if (ePos < 0) {
                ePos = indexOfWrap(num.lastIndexOf(UInt8(UInt32('E'))))
            }
            if (ePos < 0) {
                ePos = indexOfWrap(num.lastIndexOf(UInt8(UInt32('C'))))
            }
            let expNumPos = ePos + 1
            let exponentStr: String = num[Int64(expNumPos)..]
            let exponent = parse<Int32>(exponentStr)
            let fractionStr: String = num[0..Int64(ePos)]
            let fraction = Decimal(fractionStr)
            let dq = DecimalQuantity_DualStorageBCD(fraction)
            let numFracDigit = getVisibleFractionCount(fractionStr)
            dq.setMinFraction(numFracDigit)
            dq.adjustExponent(exponent)
            return dq
        } else {
            let numFracDigit = getVisibleFractionCount(num)
            let dq = DecimalQuantity_DualStorageBCD(Decimal(num))
            dq.setMinFraction(numFracDigit)
            return dq
        }
    }

    private static func getVisibleFractionCount(value: String): Int32 {
        let decimalPos = indexOfWrap(value.indexOf(UInt8(UInt32('.')))) + 1
        if (decimalPos == 0) {
            return 0
        } else {
            return Int32(value.size) - decimalPos
        }
    }

    override protected func getDigitPos(position: Int32): UInt8 {
        if (usingBytes) {
            if (position < 0 || position >= precision) {
                return 0
            }
            return bcdBytes[Int64(position)]
        } else {
            if (position < 0 || position >= 16) {
                return 0
            }
            return UInt8((ushr(bcdLong, (Int64(position * 4)))) & 15)
        }
    }

    override protected func setDigitPos(position: Int32, value: UInt8): Unit {
        if (!(position >= 0)) {
            throw AssertionError()
        }
        if (usingBytes) {
            ensureCapacity(position + 1)
            bcdBytes[Int64(position)] = value
        } else if (position >= 16) {
            switchStorage()
            ensureCapacity(position + 1)
            bcdBytes[Int64(position)] = value
        } else {
            let shift = position * 4
            bcdLong = bcdLong &  | (shl(Int64(value), Int64(shift)))
        }
    }

    override protected func shiftLeft(numDigits: Int32): Unit {
        if (!usingBytes && precision + numDigits > 16) {
            switchStorage()
        }
        if (usingBytes) {
            ensureCapacity(precision + numDigits)
            arraycopy(bcdBytes, 0, bcdBytes, Int64(numDigits), Int64(precision))
            Arrays.fill(bcdBytes, 0, numDigits, 0)
        } else {
            bcdLong <<= (Int64(numDigits * 4))
        }
        scale -= numDigits
        precision += numDigits
    }

    override protected func shiftRight(numDigits: Int32): Unit {
        if (usingBytes) {
            var i = 0
            while (i < precision - numDigits) {
                bcdBytes[Int64(i)] = bcdBytes[Int64(i + numDigits)]
                i++
            }
            while (i < precision) {
                bcdBytes[Int64(i)] = 0
                i++
            }
        } else {
            bcdLong = ushr(bcdLong, (Int64(numDigits * 4)))
        }
        scale += numDigits
        precision -= numDigits
    }

    override protected func popFromLeft(numDigits: Int32): Unit {
        if (!(numDigits <= precision)) {
            throw AssertionError()
        }
        if (usingBytes) {
            var i = precision - 1
            while (i >= precision - numDigits) {
                bcdBytes[Int64(i)] = 0
                i--
            }
        } else {
            bcdLong &= (shl(1, (Int64((precision - numDigits) * 4)))) - 1
        }
        precision -= numDigits
    }

    override protected func setBcdToZero(): Unit {
        if (usingBytes) {
            bcdBytes = None
            usingBytes = false
        }
        bcdLong = 0
        scale = 0
        precision = 0
        isApproximate = false
        origDouble = 0.0
        origDelta = 0
        exponent = 0
    }

    override protected func readIntToBcd(n: Int32): Unit {
        var tempn = n
        if (!(tempn != 0)) {
            throw AssertionError()
        }
        var result = 0
        var i = 16
        while (tempn != 0) {
            result = (ushr(result, 4)) + (shl((Int64(tempn) % 10), 60))
            tempn /= 10
            i--
        }
        if (!(!usingBytes)) {
            throw AssertionError()
        }
        bcdLong = ushr(result, (Int64(i * 4)))
        scale = 0
        precision = 16 - i
    }

    override protected func readLongToBcd(n: Int64): Unit {
        var tempn = n
        if (!(tempn != 0)) {
            throw AssertionError()
        }
        if (tempn >= 10000000000000000) {
            ensureCapacity()
            var i = 0
            while (tempn != 0) {
                bcdBytes[Int64(i)] = UInt8(tempn % 10)
                tempn /= 10
                i++
            }
            if (!usingBytes) {
                throw AssertionError()
            }
            scale = 0
            precision = i
        } else {
            var result = 0
            var i = 16
            while (tempn != 0) {
                result = (ushr(result, 4)) + (shl((tempn % 10), 60))
                tempn /= 10
                i--
            }
            if (!(i >= 0)) {
                throw AssertionError()
            }
            if (!(!usingBytes)) {
                throw AssertionError()
            }
            bcdLong = ushr(result, (Int64(i * 4)))
            scale = 0
            precision = 16 - i
        }
    }

    override protected func readBigIntToBcd(n: BigInt): Unit {
        var tempn = n
        if (!(tempn.signum() != 0)) {
            throw AssertionError()
        }
        ensureCapacity()
        var i = 0
        while (tempn.signum() != 0) {
            let temp = tempn.divideAndRemainder(BigInt.TEN)
            ensureCapacity(i + 1)
            bcdBytes[Int64(i)] = temp[1].byteValue()
            tempn = temp[0]
            i++
        }
        scale = 0
        precision = i
    }

    override protected func bcdToBigDecimal(): BigDecimal {
        if (usingBytes) {
            var result: Decimal = Decimal(toNumberString())
            if (isNegative()) {
                result = result.negate()
            }
            return result
        } else {
            var tempLong = 0
            var shift = (precision - 1)
            while (shift >= 0) {
                tempLong = tempLong * 10 + Int64(getDigitPos(shift))
                shift--
            }
            var result = BigDecimal.valueOf(tempLong)
            let newScale = Int64(result.scale() + scale + exponent)
            if (newScale <= Int64(Int32.Min)) {
                result = BigDecimal.ZERO
            } else {
                result = result.scaleByPowerOfTen(scale + exponent)
            }
            if (isNegative()) {
                result = result.negate()
            }
            return result
        }
    }

    override protected func compact(): Unit {
        if (usingBytes) {
            var delta = 0
            while (delta < precision && Int32(bcdBytes[Int64(delta)]) == 0) {
                delta++
            }
            if (delta == precision) {
                setBcdToZero()
                return
            } else {
                shiftRight(delta)
            }
            var leading = precision - 1
            while (leading >= 0 && Int32(bcdBytes[Int64(leading)]) == 0) {
                leading--
            }
            precision = leading + 1
            if (precision <= 16) {
                switchStorage()
            }
        } else {
            if (bcdLong == 0) {
                setBcdToZero()
                return
            }
            let delta = Int64.numberOfTrailingZeros(bcdLong) / 4
            bcdLong = ushr(bcdLong, Int64(delta * 4))
            scale += delta
            precision = 16 - (Int64.numberOfLeadingZeros(bcdLong) / 4)
        }
    }

    private func ensureCapacity(): Unit {
        ensureCapacity(40)
    }

    private func ensureCapacity(capacity: Int32): Unit {
        if (capacity == 0) {
            return
        }
        let oldCapacity = if (usingBytes) { Int32(bcdBytes.size) } else { 0 }
        if (!usingBytes) {
            bcdBytes = Array<UInt8>(Int64(capacity)) { _ => 0 }
        } else if (oldCapacity < capacity) {
            let bcd1 = Array<UInt8>(Int64(capacity * 2)) { _ => 0 }
            arraycopy(bcdBytes, 0, bcd1, 0, Int64(oldCapacity))
            bcdBytes = bcd1
        }
        usingBytes = true
    }

    private func switchStorage(): Unit {
        if (usingBytes) {
            bcdLong = 0
            } while (false)
            bcdBytes = None
            usingBytes = false
        } else {
            ensureCapacity()
            } while (false)
            if (!usingBytes) {
                throw AssertionError()
            }
        }
    }

    override protected func copyBcdFrom(_other: DecimalQuantity): Unit {
        let other = _other
        setBcdToZero()
        if (other.usingBytes) {
            ensureCapacity(other.precision)
            arraycopy(other.bcdBytes, 0, bcdBytes, 0, Int64(other.precision))
        } else {
            bcdLong = other.bcdLong
        }
    }

    
    public func checkHealth(): String {
        if (usingBytes) {
            if (bcdLong != 0) {
                return "Value in bcdLong but we are in byte mode"
            }
            if (precision == 0) {
                return "Zero precision but we are in byte mode"
            }
            if (precision > Int32(bcdBytes.size)) {
                return "Precision exceeds length of byte array"
            }
            if (Int32(getDigitPos(precision - 1)) == 0) {
                return "Most significant digit is zero in byte mode"
            }
            if (Int32(getDigitPos(0)) == 0) {
                return "Least significant digit is zero in long mode"
            }
                    if (Int32(getDigitPos(i)) < 0) {
                        return "Digit below 0 in byte array"
                    }
                    i++
                }
            } while (false)
                    i++
                }
            } while (false)
        } else {
            if (bcdBytes.isSome()) {
                        i++
                    }
                } while (false)
            }
            if (precision == 0 && bcdLong != 0) {
                return "Value in bcdLong even though precision is zero"
            }
            if (precision > 16) {
                return "Precision exceeds length of long"
            }
            if (precision != 0 && Int32(getDigitPos(precision - 1)) == 0) {
                return "Most significant digit is zero in long mode"
            }
            if (precision != 0 && Int32(getDigitPos(0)) == 0) {
                return "Least significant digit is zero in long mode"
            }
                    if (Int32(getDigitPos(i)) < 0) {
                        return "Digit below 0 in long (!)"
                    }
                    i++
                }
            } while (false)
                    i++
                }
            } while (false)
        }
        return None
    }

    
    public func isUsingBytes(): Bool {
        return usingBytes
    }

    public override func toString(): String {
        return String.format("<DecimalQuantity %d:%d %s %s%s>", [lReqPos, rReqPos, (if (usingBytes) { Some<Object>(Some("bytes")) } else { Some<Object>(Some("long")) }), (if (isNegative()) { Some<Object>(Some("-")) } else { Some<Object>(Some("")) }), toNumberString()])
    }

    private func toNumberString(): String {
        let sb = StringBuilder()
        if (usingBytes) {
            if (precision == 0) {
                sb.append('0')
            }
            var i = precision - 1
            while (i >= 0) {
                sb.append(bcdBytes[Int64(i)])
                i--
            }
        } else {
            sb.append(bcdLong.format("x"))
        }
        sb.append("E")
        sb.append(scale)
        return sb.toString()
    }
}
