package icu4cj.impl


public class DateNumberFormat <: NumberFormat {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private static let serialVersionUID = -6315692826916346953

    private var digits: Array<Char>

    private var zeroDigit: Char = '\u{0000}'

    private var minusSign: Char = '\u{0000}'

    private var positiveOnly = false

    private static let DECIMAL_BUF_SIZE = 20

     private var decimalBuf: Array<Char> = Array<Char>(Int64(DECIMAL_BUF_SIZE)) { _ => '\u{0000}' }

    private static var CACHE: SimpleCache<ULocale, Array<Char>> = SimpleCache<ULocale, Array<Char>>()

    private var maxIntDigits: Int32 = 0

    private var minIntDigits: Int32 = 0

    public init(loc: ULocale, digitString: String, nsName: String) {
        super()
        if (Int32(digitString.size) > 10) {
            throw UnsupportedOperationException("DateNumberFormat does not support digits out of BMP.")
        }
        initialize(loc, digitString, nsName)
    }

    public init(loc: ULocale, zeroDigit: Char, nsName: String) {
        super()
        let buf = StringBuffer()
        var i = 0
        while (i < 10) {
            buf.append(Char(Int32(UInt32(zeroDigit)) + i))
            i++
        }
        initialize(loc, toString(buf), nsName)
    }

    private func initialize(loc: ULocale, digitString: String, nsName: String): Unit {
        var elems = CACHE.get(loc)
        if (elems.isNone()) {
            var minusString: String
            let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, loc)
            try {
                minusString = rb.getStringWithFallback("NumberElements/" + (nsName) + "/symbols/minusSign")
            } catch (ex: MissingResourceException) {
                if (!(nsName == "latn")) {
                    try {
                        minusString = rb.getStringWithFallback("NumberElements/latn/symbols/minusSign")
                    } catch (ex1: MissingResourceException) {
                        minusString = "-"
                    }
                } else {
                    minusString = "-"
                }
            }
            elems = Array<Char>(11) { _ => '\u{0000}' }
            var i = 0
            while (i < 10) {
                elems[Int64(i)] = Char(digitString[Int64(i)])
                i++
            }
            elems[10] = Char(minusString[0])
            CACHE.put(loc, elems)
        }
        digits = Array<Char>(10) { _ => '\u{0000}' }
        arraycopy(elems, 0, digits, 0, 10)
        zeroDigit = digits[0]
        minusSign = elems[10]
    }

    public override func setMaximumIntegerDigits(newValue: Int32): Unit {
        maxIntDigits = newValue
    }

    public override func getMaximumIntegerDigits(): Int32 {
        return maxIntDigits
    }

    public override func setMinimumIntegerDigits(newValue: Int32): Unit {
        minIntDigits = newValue
    }

    public override func getMinimumIntegerDigits(): Int32 {
        return minIntDigits
    }

    public func setParsePositiveOnly(isPositiveOnly: Bool): Unit {
        positiveOnly = isPositiveOnly
    }

    public func getZeroDigit(): Char {
        return zeroDigit
    }

    public func setZeroDigit(zero: Char): Unit {
        zeroDigit = zero
        if (digits.isNone()) {
            digits = Array<Char>(10) { _ => '\u{0000}' }
        }
        digits[0] = zero
        var i = 1
        while (i < 10) {
            digits[Int64(i)] = Char(Int32(UInt32(zero)) + i)
            i++
        }
    }

    public func getDigits(): Array<Char> {
        return digits.clone()
    }

    public override func format(number: Float64, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        throw UnsupportedOperationException("StringBuffer format(double, StringBuffer, FieldPosition) is not implemented")
    }

    public override func format(numberL: Int64, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        var tempnumberL = numberL
        if (tempnumberL < 0) {
            toAppendTo.append(minusSign)
            tempnumberL = -tempnumberL
        }
        var number = Int32(tempnumberL)
        let limit = if (Int32(decimalBuf.size) < maxIntDigits) { Int32(decimalBuf.size) } else { maxIntDigits }
        var index = limit - 1
        while (true) {
            decimalBuf[Int64(index)] = digits[(Int64(number % 10))]
            number /= 10
            if (index == 0 || number == 0) {
                break
            }
            index--
        }
        var padding = minIntDigits - (limit - index)
        while (padding > 0) {
            decimalBuf[Int64(match (0) { case _ => index--; index })] = digits[0]
            padding--
        }
        let length = limit - index
        toAppendTo.append(decimalBuf, index, length)
        pos.setBeginIndex(0)
        if (pos.getField() == NumberFormat.INTEGER_FIELD) {
            pos.setEndIndex(length)
        } else {
            pos.setEndIndex(0)
        }
        return toAppendTo
    }

    public override func format(number: BigInt, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        throw UnsupportedOperationException("StringBuffer format(BigInteger, StringBuffer, FieldPosition) is not implemented")
    }

    public override func format(number: BigDecimal, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        throw UnsupportedOperationException("StringBuffer format(BigDecimal, StringBuffer, FieldPosition) is not implemented")
    }

    public override func format(number: BigDecimal, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        throw UnsupportedOperationException("StringBuffer format(BigDecimal, StringBuffer, FieldPosition) is not implemented")
    }

    private static let PARSE_THRESHOLD = 922337203685477579

    public override func parse(text: String, parsePosition: ParsePosition): Number {
        var num = 0
        var sawNumber = false
        var negative = false
        let base = parsePosition.getIndex()
        var offset = 0
        while (base + offset < Int32(text.size)) {
            let ch = Char(text[Int64(base + offset)])
            if (offset == 0 && ch == minusSign) {
                if (positiveOnly) {
                    break
                }
                negative = true
            } else {
                var digit = 
                if (digit < 0 || 9 < digit) {
                    digit = UCharacter.digit(Int32(UInt32(ch)))
                }
                if (digit < 0 || 9 < digit) {
                    digit = 0
                    while (digit < 10) {
                        if (ch == digits[Int64(digit)]) {
                            break
                        }
                        digit++
                    }
                }
                if (0 <= digit && digit <= 9 && num < PARSE_THRESHOLD) {
                    sawNumber = true
                    num = num * 10 + Int64(digit)
                } else {
                    break
                }
            }
            offset++
        }
        var result: Number = None
        if (sawNumber) {
            num = if (negative) { num * (-1) } else { num }
            result = num
            parsePosition.setIndex(base + offset)
        }
        return result
    }

    public override func equals(obj: Object): Bool {
        if (obj.isNone() || !super.equals(obj) || !(checkOptionalIs<DateNumberFormat, Object>(obj))) {
            return false
        }
        let other = obj
        return (this.maxIntDigits == other.maxIntDigits && this.minIntDigits == other.minIntDigits && this.minusSign == other.minusSign && this.positiveOnly == other.positiveOnly && this.digits == other.digits)
    }

    public override func hashCode(): Int64 {
        return super.hashCode()
    }

    private func readObject(stream: ObjectInputStream): Unit {
        stream.defaultReadObject()
        if (digits.isNone()) {
            setZeroDigit(zeroDigit)
        }
        decimalBuf = Array<Char>(Int64(DECIMAL_BUF_SIZE)) { _ => '\u{0000}' }
    }

    public override func clone(): Object {
        let dnfmt = super.clone()
        dnfmt.digits = this.digits.clone()
        dnfmt.decimalBuf = Array<Char>(Int64(DECIMAL_BUF_SIZE)) { _ => '\u{0000}' }
        return dnfmt
    }
}
