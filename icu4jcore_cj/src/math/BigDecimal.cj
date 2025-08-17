package icu4cj.math


public class BigDecimal <: Number & Serializable & Comparable<BigDecimal> {
    public static let ZERO = BigDecimal(0)

    public static let ONE = BigDecimal(1)

    public static let TEN = BigDecimal(10)

    public static let ROUND_CEILING = MathContext.ROUND_CEILING

    public static let ROUND_DOWN = MathContext.ROUND_DOWN

    public static let ROUND_FLOOR = MathContext.ROUND_FLOOR

    public static let ROUND_HALF_DOWN = MathContext.ROUND_HALF_DOWN

    public static let ROUND_HALF_EVEN = MathContext.ROUND_HALF_EVEN

    public static let ROUND_HALF_UP = MathContext.ROUND_HALF_UP

    public static let ROUND_UNNECESSARY = MathContext.ROUND_UNNECESSARY

    public static let ROUND_UP = MathContext.ROUND_UP

    private static let ispos = 1u8

    private static let iszero = 0u8

    private static let isneg = 255u8

    private static let MinExp = -999999999

    private static let MaxExp = 999999999

    private static let MinArg = -999999999

    private static let MaxArg = 999999999

    private static let plainMC = MathContext(0, MathContext.PLAIN)

    private static let serialVersionUID = 8245355804974198832

    private static var bytecar: Array<UInt8> = Array<UInt8>(Int64((90 + 99) + 1)) { _ => 0 }

    private static var bytedig = diginit()

    private var ind: UInt8 = 0

    private var form = UInt8(MathContext.PLAIN)

    private var mant: Array<UInt8>

    private var exp: Int32 = 0

    public init(bd: BigDecimal) {
        this(toString(bd))
        return
    }

    public init(bi: BigInt) {
        this(bi.toString(10))
        return
    }

    public init(bi: BigInt, scale: Int32) {
        this(bi.toString(10))
        if (scale < 0) {
            throw TimeParseException("Negative scale: " + scale.toString())
        }
        exp = -scale
        return
    }

    public init(inchars: Array<Char>) {
        this(inchars, 0, Int32(inchars.size))
        return
    }

    public init(inchars: Array<Char>, offset: Int32, length: Int32) {
        Number()
        var templength = length
        var tempoffset = offset
        var exotic: Bool = false
        var hadexp: Bool = false
        var d: Int32 = 0
        var dotoff: Int32 = 0
        var last: Int32 = 0
        var i = 0
        var si = Char(0)
        var eneg = false
        var k = 0
        var elen = 0
        var j = 0
        var sj = Char(0)
        var dvalue = 0
        var mag = 0
        if (templength <= 0) {
            bad(inchars)
        }
        ind = ispos
        if (inchars[Int64(tempoffset)] == ('-')) {
            templength--
            if (templength == 0) {
                bad(inchars)
            }
            ind = isneg
            tempoffset++
        } else if (inchars[Int64(tempoffset)] == ('+')) {
            templength--
            if (templength == 0) {
                bad(inchars)
            }
            tempoffset++
        }
        exotic = false
        hadexp = false
        d = 0
        dotoff = -1
        last = -1

    public init(num: Int32) {
        Number()
        var tempnum = num
        var mun: Int32 = 0
        var i = 0
        if (tempnum <= 9) {
            if (tempnum >= (-9)) {
                            mant = ONE.mant
                            ind = ispos
                        } else if (tempnum == (-1)) {
                            mant = ONE.mant
                            ind = isneg
                        } else {
                                    mant[0] = UInt8(-tempnum)
                                    ind = isneg
                                }
                            // End of do-while loop
                        }
                    // End of do-while loop
                    return
                // End of do-while loop
            }
        }
        if (tempnum > 0) {
            ind = ispos
            tempnum = -tempnum
        } else {
            ind = isneg
        }
        mun = tempnum
            ind = iszero
        } else {
            ind = isneg
        }
        mun = tempnum

    private init() {
        Number()
        return
    }

    public func abs(): BigDecimal {
        return this.abs(plainMC)
    }

    public func abs(set: MathContext): BigDecimal {
        if (this.ind == isneg) {
            return this.negate(set)
        }
        return this.plus(set)
    }

    public func add(rhs: BigDecimal): BigDecimal {
        return this.add(rhs, plainMC)
    }

    public func add(rhs: BigDecimal, set: MathContext): BigDecimal {
        var temprhs = rhs
        var lhs: BigDecimal
        let reqdig: Int32
        let res: BigDecimal
        var usel: Array<UInt8>
        var usellen: Int32 = 0
        var user: Array<UInt8>
        var userlen: Int32 = 0
        var newlen = 0
        var tlen = 0
        var mult = 0
        var t: Array<UInt8>
        var ia = 0
        var ib = 0
        var ea = 0
        var eb = 0
        var ca = 0u8
        var cb = 0u8
        if (set.lostDigits) {
            checkdigits(temprhs, set.digits)
        }
        lhs = this
        if (Int32(lhs.ind) == 0) {
            if (set.form != MathContext.PLAIN) {
                return temprhs.plus(set)
            }
        }
        if (Int32(temprhs.ind) == 0) {
            if (set.form != MathContext.PLAIN) {
                return lhs.plus(set)
            }
        }
        reqdig = set.digits
        if (reqdig > 0) {
            if (Int32(lhs.mant.size) > reqdig) {
                lhs = clone(lhs).round(set)
            }
            if (Int32(temprhs.mant.size) > reqdig) {
                temprhs = clone(temprhs).round(set)
            }
        }
        res = BigDecimal()
        usel = lhs.mant
        usellen = Int32(lhs.mant.size)
        user = temprhs.mant
        userlen = Int32(temprhs.mant.size)
                    newlen = (usellen + lhs.exp) - temprhs.exp
                    if (newlen >= ((userlen + reqdig) + 1)) {
                        if (reqdig > 0) {
                            res.mant = usel
                            res.exp = lhs.exp
                            res.ind = lhs.ind
                            if (usellen < reqdig) {
                                res.mant = `extend`(lhs.mant, reqdig)
                                res.exp = res.exp - ((reqdig - usellen))
                            }
                            return res.finish(set, false)
                        }
                    }
                    res.exp = temprhs.exp
                    if (newlen > (reqdig + 1)) {
                        if (reqdig > 0) {
                            tlen = (newlen - reqdig) - 1
                            userlen = userlen - tlen
                            res.exp = res.exp + tlen
                            newlen = reqdig + 1
                        }
                    }
                    if (newlen > usellen) {
                        usellen = newlen
                    }
                } else {
                    newlen = (userlen + temprhs.exp) - lhs.exp
                    if (newlen >= ((usellen + reqdig) + 1)) {
                        if (reqdig > 0) {
                            res.mant = user
                            res.exp = temprhs.exp
                            res.ind = temprhs.ind
                            if (userlen < reqdig) {
                                res.mant = `extend`(temprhs.mant, reqdig)
                                res.exp = res.exp - ((reqdig - userlen))
                            }
                            return res.finish(set, false)
                        }
                    }
                    res.exp = lhs.exp
                    if (newlen > (reqdig + 1)) {
                        if (reqdig > 0) {
                            tlen = (newlen - reqdig) - 1
                            usellen = usellen - tlen
                            res.exp = res.exp + tlen
                            newlen = reqdig + 1
                        }
                    }
                    if (newlen > userlen) {
                        userlen = newlen
                    }
                }
            } while (false)
        } while (false)
        if (lhs.ind == iszero) {
            res.ind = ispos
        } else {
            res.ind = lhs.ind
        }
        if ((if (lhs.ind == isneg) { 1 } else { 0 }) == (if (temprhs.ind == isneg) { 1 } else { 0 })) {
            mult = 1
        } else {

    public func compareTo(rhs: BigDecimal, set: MathContext): Int32 {
        var thislength = 0
        var i = 0
        let newrhs: BigDecimal
        if (set.lostDigits) {
            checkdigits(rhs, set.digits)
        }
        if ((this.ind == rhs.ind) & (this.exp == rhs.exp)) {
            thislength = Int32(this.mant.size)
            if (thislength < Int32(rhs.mant.size)) {
                return Int32(-this.ind)
            }
            if (thislength > Int32(rhs.mant.size)) {
                return Int32(this.ind)
            }
            if ((thislength <= set.digits) | (set.digits == 0)) {
                        if (this.mant[Int64(i)] > rhs.mant[Int64(i)]) {
                            return Int32(this.ind)
                        }
                        _6--
                        i++
                    }
                } while (false)
                return 0
            }
        } else {
            if (this.ind < rhs.ind) {
                return -1
            }
            if (this.ind > rhs.ind) {
                return 1
            }
        }
        newrhs = clone(rhs)
        newrhs.ind = -newrhs.ind
        return Int32(this.add(newrhs, set).ind)
    }

    public func divide(rhs: BigDecimal): BigDecimal {
        return this.dodivide('D', rhs, plainMC, -1)
    }

    public func divide(rhs: BigDecimal, round: Int32): BigDecimal {
        let set: MathContext
        set = MathContext(0, MathContext.PLAIN, false, round)
        return this.dodivide('D', rhs, set, -1)
    }

    public func divide(rhs: BigDecimal, scale: Int32, round: Int32): BigDecimal {
        let set: MathContext
        if (scale < 0) {
            throw ArithmeticException("Negative scale: " + scale.toString())
        }
        set = MathContext(0, MathContext.PLAIN, false, round)
        return this.dodivide('D', rhs, set, scale)
    }

    public func divide(rhs: BigDecimal, set: MathContext): BigDecimal {
        return this.dodivide('D', rhs, set, -1)
    }

    public func divideInteger(rhs: BigDecimal): BigDecimal {
        return this.dodivide('I', rhs, plainMC, 0)
    }

    public func divideInteger(rhs: BigDecimal, set: MathContext): BigDecimal {
        return this.dodivide('I', rhs, set, 0)
    }

    public func max(rhs: BigDecimal): BigDecimal {
        return this.max(rhs, plainMC)
    }

    public func max(rhs: BigDecimal, set: MathContext): BigDecimal {
        if ((this.compareTo(rhs, set)) >= 0) {
            return this.plus(set)
        } else {
            return rhs.plus(set)
        }
    }

    public func min(rhs: BigDecimal): BigDecimal {
        return this.min(rhs, plainMC)
    }

    public func min(rhs: BigDecimal, set: MathContext): BigDecimal {
        if ((this.compareTo(rhs, set)) <= 0) {
            return this.plus(set)
        } else {
            return rhs.plus(set)
        }
    }

    public func multiply(rhs: BigDecimal): BigDecimal {
        return this.multiply(rhs, plainMC)
    }

    public func multiply(rhs: BigDecimal, set: MathContext): BigDecimal {
        var temprhs = rhs
        var lhs: BigDecimal
        var padding: Int32 = 0
        let reqdig: Int32
        var multer: Array<UInt8>
        var multand: Array<UInt8>
        var multandlen: Int32 = 0
        var acclen = 0
        let res: BigDecimal
        var acc: Array<UInt8>
        var n = 0
        var mult = 0u8
        if (set.lostDigits) {
            checkdigits(temprhs, set.digits)
        }
        lhs = this
        padding = 0
        reqdig = set.digits
        if (reqdig > 0) {
            if (Int32(lhs.mant.size) > reqdig) {
                lhs = clone(lhs).round(set)
            }
            if (Int32(temprhs.mant.size) > reqdig) {
                temprhs = clone(temprhs).round(set)
            }
        } else {
            if (lhs.exp > 0) {
                padding = padding + lhs.exp
            }
            if (temprhs.exp > 0) {
                padding = padding + temprhs.exp
            }
        }
        if (Int32(lhs.mant.size) < Int32(temprhs.mant.size)) {
            multer = lhs.mant
            multand = temprhs.mant
        } else {
            multer = temprhs.mant
            multand = lhs.mant
        }
        multandlen = (Int32(multer.size) + Int32(multand.size)) - 1
        if ((multer[0] * multand[0]) > 9) {
            acclen = multandlen + 1
        } else {
            acclen = multandlen
        }
        res = BigDecimal()
        acc = Array<UInt8>(Int64(acclen)) { _ => 0 }
                multandlen--
                _7--
                n++
            }
        } while (false)
        res.ind = UInt8(lhs.ind * temprhs.ind)
        res.exp = (lhs.exp + temprhs.exp) - padding
        if (padding == 0) {
            res.mant = acc
        } else {
            res.mant = `extend`(acc, Int32(acc.size) + padding)
        }
        return res.finish(set, false)
    }

    public func negate(): BigDecimal {
        return this.negate(plainMC)
    }

    public func negate(set: MathContext): BigDecimal {
        let res: BigDecimal
        if (set.lostDigits) {
            checkdigits(None, set.digits)
        }
        res = clone(this)
        res.ind = -res.ind
        return res.finish(set, false)
    }

    public func plus(): BigDecimal {
        return this.plus(plainMC)
    }

    public func plus(set: MathContext): BigDecimal {
        if (set.lostDigits) {
            checkdigits(None, set.digits)
        }
        if (set.form == MathContext.PLAIN) {
            if (Int32(this.form) == MathContext.PLAIN) {
                if (Int32(this.mant.size) <= set.digits) {
                    return this
                }
                if (set.digits == 0) {
                    return this
                }
            }
        }
        return clone(this).finish(set, false)
    }

    public func pow(rhs: BigDecimal): BigDecimal {
        return this.pow(rhs, plainMC)
    }

    public func pow(rhs: BigDecimal, set: MathContext): BigDecimal {
        var n: Int32 = 0
        var lhs: BigDecimal
        let reqdig: Int32
        var workdigits = 0
        var L = 0
        let workset: MathContext
        var res: BigDecimal
        var seenbit: Bool = false
        var i = 0
        if (set.lostDigits) {
            checkdigits(rhs, set.digits)
        }
        n = rhs.intcheck(MinArg, MaxArg)
        lhs = this
        reqdig = set.digits
        if (reqdig == 0) {
            if (rhs.ind == isneg) {
                throw ArithmeticException("Negative power: " + rhs.toString())
            }
            workdigits = 0
        } else {
            if ((Int32(rhs.mant.size) + rhs.exp) > reqdig) {
                throw ArithmeticException("Too many digits: " + rhs.toString())
            }
            if (Int32(lhs.mant.size) > reqdig) {
                lhs = clone(lhs).round(set)
            }
            L = Int32(rhs.mant.size) + rhs.exp
            workdigits = (reqdig + L) + 1
        }
        workset = MathContext(workdigits, set.form, false, set.roundingMode)
        res = ONE
        if (n == 0) {
            return res
        }
        if (n < 0) {
            n = -n
        }
        seenbit = false

    public func remainder(rhs: BigDecimal, set: MathContext): BigDecimal {
        return this.dodivide('R', rhs, set, -1)
    }

    public func subtract(rhs: BigDecimal): BigDecimal {
        return this.subtract(rhs, plainMC)
    }

    public func subtract(rhs: BigDecimal, set: MathContext): BigDecimal {
        let newrhs: BigDecimal
        if (set.lostDigits) {
            checkdigits(rhs, set.digits)
        }
        newrhs = clone(rhs)
        newrhs.ind = -newrhs.ind
        return this.add(newrhs, set)
    }

    public func byteValueExact(): UInt8 {
        let num: Int32
        num = this.intValueExact()
        if ((num > 127) | (num < (-128))) {
            throw ArithmeticException("Conversion overflow: " + this.toString())
        }
        return UInt8(num)
    }

    public override func doubleValue(): Float64 {
        return parse<Float64>(this.toString())
    }

    public override func equals(obj: Object): Bool {
        let rhs: BigDecimal
        var i = 0
        var lca: Array<Char>
        var rca: Array<Char>
        if (obj.isNone()) {
            return false
        }
        if (!(((checkOptionalIs<BigDecimal, Object>(obj))))) {
            return false
        }
        rhs = obj
        if (this.ind != rhs.ind) {
            return false
        }
        if (((Int32(this.mant.size) == Int32(rhs.mant.size)) & (this.exp == rhs.exp)) & (this.form == rhs.form)) {
                    _8--
                    i++
                }
            } while (false)
        } else {
            lca = this.layout()
            rca = rhs.layout()
            if (Int32(lca.size) != Int32(rca.size)) {
                return false
            }
                    _9--
                    i++
                }
            } while (false)
        }
        return true
    }

    public override func floatValue(): Float32 {
        return parse<Float32>(this.toString())
    }

    public func format(before: Int32, after: Int32): String {
        return format(before, after, -1, -1, MathContext.SCIENTIFIC, ROUND_HALF_UP)
    }

    public func format(before: Int32, after: Int32, explaces: Int32, exdigits: Int32, exformint: Int32, exround: Int32): String {
        var tempexformint = exformint
        var tempexround = exround
        let num: BigDecimal
        var mag = 0
        var thisafter = 0
        var lead = 0
        var newmant: Array<UInt8>
        var chop = 0
        var need = 0
        var oldexp = 0
        var a: Array<Char>
        var p = 0
        var newa: Array<Char>
        var i = 0
        var places = 0
        if ((before < (-1)) | (before == 0)) {
            badarg("format", 1, before.toString())
        }
        if (after < (-1)) {
            badarg("format", 2, after.toString())
        }
        if ((explaces < (-1)) | (explaces == 0)) {
            badarg("format", 3, explaces.toString())
        }
        if (exdigits < (-1)) {
            badarg("format", 4, explaces.toString())
        }
                badarg("format", 5, tempexformint.toString())
            }
        } while (false)
        if (tempexround != ROUND_HALF_UP) {
            try {
                if (tempexround == (-1)) {
                    tempexround = ROUND_HALF_UP
                } else {
                    MathContext(9, MathContext.SCIENTIFIC, false, tempexround)
                }
            } catch (_10: IllegalArgumentException) {
                badarg("format", 6, tempexround.toString())
            }
        }
        num = clone(this)
                    num.form = UInt8(MathContext.PLAIN)
                } else {
                    mag = num.exp + Int32(num.mant.size)
                    if (mag > exdigits) {
                        num.form = UInt8(tempexformint)
                    } else if (mag < (-5)) {
                        num.form = UInt8(tempexformint)
                    } else {
                        num.form = UInt8(MathContext.PLAIN)
                    }
                }
            } while (false)
        } while (false)
        if (after >= 0) {
    public override func hashCode(): Int64 {
        return this.toString().hashCode()
    }

    public override func intValue(): Int32 {
        return toBigInteger().intValue()
    }

    public func intValueExact(): Int32 {
        var lodigit: Int32 = 0
        var useexp = 0
        var result: Int32 = 0
        var i = 0
        var topdig = 0
        if (ind == iszero) {
            return 0
        }
        lodigit = Int32(mant.size) - 1
        if (exp < 0) {
            lodigit = lodigit + exp
            if (!(allzero(mant, lodigit + 1))) {
                throw ArithmeticException("Decimal part non-zero: " + this.toString())
            }
            if (lodigit < 0) {
                return 0
            }
            useexp = 0
        } else {
            if ((exp + lodigit) > 9) {
                throw ArithmeticException("Conversion overflow: " + this.toString())
            }
            useexp = exp
        }
        result = 0
                i++
            }
        } while (false)
        if ((lodigit + useexp) == 9) {
            topdig = result / 1000000000
            if (topdig != Int32(mant[0])) {
                if (result == Int32.Min) {
                    if (ind == isneg) {
                        if (Int32(mant[0]) == 2) {
                            return result
                        }
                    }
                }
                throw ArithmeticException("Conversion overflow: " + this.toString())
            }
        }
        if (ind == ispos) {
            return result
        }
        return -result
    }

    public override func longValue(): Int64 {
        return toBigInteger().toInt64()
    }

    public func longValueExact(): Int64 {
        var lodigit: Int32 = 0
        var cstart = 0
        var useexp = 0
        var result: Int64 = 0
        var i = 0
        var topdig = 0
        if (Int32(ind) == 0) {
            return 0
        }
        lodigit = Int32(mant.size) - 1
        if (exp < 0) {
            lodigit = lodigit + exp
            if (lodigit < 0) {
                cstart = 0
            } else {
                cstart = lodigit + 1
            }
            if (!(allzero(mant, cstart))) {
                throw ArithmeticException("Decimal part non-zero: " + this.toString())
            }
            if (lodigit < 0) {
                return 0
            }
            useexp = 0
        } else {
            if ((exp + Int32(mant.size)) > 18) {
                throw ArithmeticException("Conversion overflow: " + this.toString())
            }
            useexp = exp
        }
        result = 0
                i++
            }
        } while (false)
        if ((lodigit + useexp) == 18) {
            topdig = result / 1000000000000000000
            if (topdig != Int64(mant[0])) {
                if (result == Int64.Min) {
                    if (ind == isneg) {
                        if (Int32(mant[0]) == 9) {
                            return result
                        }
                    }
                }
                throw ArithmeticException("Conversion overflow: " + this.toString())
            }
        }
        if (ind == ispos) {
            return result
        }
        return -result
    }

    public func movePointLeft(n: Int32): BigDecimal {
        let res: BigDecimal
        res = clone(this)
        res.exp = res.exp - n
        return res.finish(plainMC, false)
    }

    public func movePointRight(n: Int32): BigDecimal {
        let res: BigDecimal
        res = clone(this)
        res.exp = res.exp + n
        return res.finish(plainMC, false)
    }

    public func scale(): Int32 {
        if (exp >= 0) {
            return 0
        }
        return -exp
    }

    public func setScale(scale: Int32): BigDecimal {
        return setScale(scale, ROUND_UNNECESSARY)
    }

    public func setScale(scale: Int32, round: Int32): BigDecimal {
        let ourscale: Int32
        var res: BigDecimal
        var padding = 0
        var newlen = 0
        ourscale = this.scale()
        if (ourscale == scale) {
            if (Int32(this.form) == MathContext.PLAIN) {
                return this
            }
        }
        res = clone(this)
        if (ourscale <= scale) {
            if (ourscale == 0) {
                padding = res.exp + scale
            } else {
                padding = scale - ourscale
            }
            res.mant = `extend`(res.mant, Int32(res.mant.size) + padding)
            res.exp = -scale
        } else {
            if (scale < 0) {
                throw ArithmeticException("Negative scale: " + scale.toString())
            }
            newlen = Int32(res.mant.size) - ((ourscale - scale))
            res = res.round(newlen, round)
            if (res.exp != -scale) {
                res.mant = `extend`(res.mant, Int32(res.mant.size) + 1)
                res.exp = res.exp - 1
            }
        }
        res.form = UInt8(MathContext.PLAIN)
        return res
    }

    public func shortValueExact(): Int16 {
        let num: Int32
        num = this.intValueExact()
        if ((num > 32767) | (num < (-32768))) {
            throw ArithmeticException("Conversion overflow: " + this.toString())
        }
        return Int16(num)
    }

    public func signum(): Int32 {
        return Int32(this.ind)
    }

    public func toBigDecimal(): BigDecimal {
        return Decimal(this.unscaledValue(), this.scale())
    }

    public func toBigInt(): BigInt {
        var res: BigDecimal
        var newlen = 0
        var newmant: Array<UInt8>
                res = clone(this)
                res.form = UInt8(MathContext.PLAIN)
            } else {
                        res = clone(this)
                        newlen = Int32(res.mant.size) + res.exp
                        newmant = Array<UInt8>(Int64(newlen)) { _ => 0 }
                        arraycopy(res.mant, 0, newmant, 0, Int64(newlen))
                        res.mant = newmant
                        res.form = UInt8(MathContext.PLAIN)
                        res.exp = 0
                    }
                } while (false)
            }
        } while (false)
        return BigInteger(String(res.layout()))
    }

    public func toBigIntExact(): BigInt {
        if (exp < 0) {
            if (!(allzero(mant, Int32(mant.size) + exp))) {
                throw ArithmeticException("Decimal part non-zero: " + this.toString())
            }
        }
        return toBigInteger()
    }

    public func toCharArray(): Array<Char> {
        return layout()
    }

    public override func toString(): String {
        return String(layout())
    }

    public func unscaledValue(): BigInt {
        var res: BigDecimal
        if (exp >= 0) {
            res = this
        } else {
            res = clone(this)
            res.exp = 0
        }
        return res.toBigInteger()
    }

    public static func valueOf(dub: Float64): BigDecimal {
        return BigDecimal(dub.toString())
    }

    public static func valueOf(lint: Int64): BigDecimal {
        return valueOf(lint, 0)
    }

    public static func valueOf(lint: Int64, scale: Int32): BigDecimal {
        var res: BigDecimal
                res = ONE
            } else if (lint == 10) {
                res = TEN
            } else {
                res = BigDecimal(lint)
            }
        } while (false)
        if (scale == 0) {
            return res
        }
        if (scale < 0) {
            throw TimeParseException("Negative scale: " + scale.toString())
        }
        res = clone(res)
        res.exp = -scale
        return res
    }

    private func layout(): Array<Char> {
        let cmant: Array<Char>
        var i = 0
        var sb: StringBuilder
        var euse = 0
        var sig = 0
        var csign = Char(0)
        var rec: Array<Char>
        let needsign: Int32
        let mag: Int32
        var len = 0
        cmant = Array<Char>(mant.size) { _ => '\u{0000}' }
        } while (false)
        if (Int32(form) != MathContext.PLAIN) {
            sb = StringBuilder()
            if (ind == isneg) {
                sb.append('-')
            }
            euse = (exp + Int32(cmant.size)) - 1
            if (Int32(form) == MathContext.SCIENTIFIC) {
                sb.append(cmant[0])
                if (Int32(cmant.size) > 1) {
                    sb.append('.').append(cmant, 1, Int32(cmant.size) - 1)
                }
            } else {
                    euse = euse - sig
                    sig++
                    if (sig >= Int32(cmant.size)) {
                        sb.append(cmant, 0, Int32(cmant.size))
                        } while (false)
                    } else {
                        sb.append(cmant, 0, sig).append('.').append(cmant, sig, Int32(cmant.size) - sig)
                    }
                } while (false)
            }
            if (euse != 0) {
                if (euse < 0) {
                    csign = '-'
                    euse = -euse
                } else {
                    csign = '+'
                }
                sb.append('E').append(csign).append(euse)
            }
            rec = Array<Char>(sb.size) { _ => '\u{0000}' }
            let srcEnd = Int32(sb.size)
            if (0 != srcEnd) {
                sb.getChars(0, srcEnd, rec, 0)
            }
            return rec
        }
        if (exp == 0) {
            if (Int32(ind) >= 0) {
                return cmant
            }
            rec = Array<Char>(Int64(Int32(cmant.size) + 1)) { _ => '\u{0000}' }
            rec[0] = '-'
            arraycopy(cmant, 0, rec, 1, cmant.size)
            return rec
        }
        needsign = if (ind == isneg) { 1 } else { 0 }
        mag = exp + Int32(cmant.size)
        if (mag < 1) {
            len = (needsign + 2) - exp
            rec = Array<Char>(Int64(len)) { _ => '\u{0000}' }
            if (needsign != 0) {
                rec[0] = '-'
            }
            rec[Int64(needsign)] = '0'
            rec[Int64(needsign + 1)] = '.'
            } while (false)
            arraycopy(cmant, 0, rec, Int64((needsign + 2) - mag), cmant.size)
            return rec
        }
        if (mag > Int32(cmant.size)) {
            len = needsign + mag
            rec = Array<Char>(Int64(len)) { _ => '\u{0000}' }
            if (needsign != 0) {
                rec[0] = '-'
            }
            arraycopy(cmant, 0, rec, Int64(needsign), cmant.size)
            } while (false)
            return rec
        }
        len = (needsign + 1) + Int32(cmant.size)
        rec = Array<Char>(Int64(len)) { _ => '\u{0000}' }
        if (needsign != 0) {
            rec[0] = '-'
        }
        arraycopy(cmant, 0, rec, Int64(needsign), Int64(mag))
        rec[Int64(needsign + mag)] = '.'
        arraycopy(cmant, Int64(mag), rec, Int64((needsign + mag) + 1), Int64(Int32(cmant.size) - mag))
        return rec
    }

    private func intcheck(min: Int32, max: Int32): Int32 {
        let i: Int32
        i = this.intValueExact()
        if ((i < min) | (i > max)) {
            throw ArithmeticException("Conversion overflow: " + i.toString())
        }
        return i
    }

    private func dodivide(code: Char, rhs: BigDecimal, set: MathContext, scale: Int32): BigDecimal {
        var temprhs = rhs
        var tempscale = scale
        var lhs: BigDecimal
        var reqdig: Int32 = 0
        let newexp: Int32
        let res: BigDecimal
        let newlen: Int32
        var var1: Array<UInt8>
        var var1len: Int32 = 0
        let var2: Array<UInt8>
        var var2len: Int32 = 0
        var b2b: Int32 = 0
        var have: Int32 = 0
        var thisdigit = 0
        var i = 0
        var v2 = 0u8
        var ba = 0
        var mult = 0
        var start = 0
        var padding = 0
        var d = 0
        var newvar1: Array<UInt8>
        var lasthave = 0u8
        var actdig = 0
        var newmant: Array<UInt8>
        if (set.lostDigits) {
            checkdigits(temprhs, set.digits)
        }
        lhs = this
        if (Int32(temprhs.ind) == 0) {
            throw ArithmeticException("Divide by 0")
        }
        if (Int32(lhs.ind) == 0) {
            if (set.form != MathContext.PLAIN) {
                return ZERO
            }
            if (tempscale == (-1)) {
                return lhs
            }
            return lhs.setScale(tempscale)
        }
        reqdig = set.digits
        if (reqdig > 0) {
            if (Int32(lhs.mant.size) > reqdig) {
                lhs = clone(lhs).round(set)
            }
            if (Int32(temprhs.mant.size) > reqdig) {
                temprhs = clone(temprhs).round(set)
            }
        } else {
            if (tempscale == (-1)) {
                tempscale = lhs.scale()
            }
            reqdig = Int32(lhs.mant.size)
            if (tempscale != -lhs.exp) {
                reqdig = (reqdig + tempscale) + lhs.exp
            }
            reqdig = (reqdig - ((Int32(temprhs.mant.size) - 1))) - temprhs.exp
            if (reqdig < Int32(lhs.mant.size)) {
                reqdig = Int32(lhs.mant.size)
            }
            if (reqdig < Int32(temprhs.mant.size)) {
                reqdig = Int32(temprhs.mant.size)
            }
        }
        newexp = ((lhs.exp - temprhs.exp) + Int32(lhs.mant.size)) - Int32(temprhs.mant.size)
        if (newexp < 0) {
            if (code != 'D') {
                if (code == 'I') {
                    return ZERO
                }
                return clone(lhs).finish(set, false)
            }
        }
        res = BigDecimal()
        res.ind = UInt8(lhs.ind * temprhs.ind)
        res.exp = newexp
        res.mant = Array<UInt8>(Int64(reqdig + 1)) { _ => 0 }
        newlen = (reqdig + reqdig) + 1
        var1 = `extend`(lhs.mant, newlen)
        var1len = newlen
        var2 = temprhs.mant
        var2len = newlen
        b2b = (Int32(var2[0]) * 10) + 1
        if (Int32(var2.size) > 1) {
            b2b = b2b + Int32(var2[1])
        }
        have = 0

    private func badarg(name: String, pos: Int32, value: String): Unit {
        throw IllegalArgumentException("Bad argument " + pos.toString() + " to " + (name) + ": " + (value))
    }

    private static func `extend`(inarr: Array<UInt8>, newlen: Int32): Array<UInt8> {
        let newarr: Array<UInt8>
        if (Int32(inarr.size) == newlen) {
            return inarr
        }
        newarr = Array<UInt8>(Int64(newlen)) { _ => 0 }
        arraycopy(inarr, 0, newarr, 0, inarr.size)
        return newarr
    }

    private static func byteaddsub(a: Array<UInt8>, avlen: Int32, b: Array<UInt8>, bvlen: Int32, m: Int32, reuse: Bool): Array<UInt8> {
        let alength: Int32
        let blength: Int32
        var ap: Int32 = 0
        var bp: Int32 = 0
        var maxarr: Int32 = 0
        var reb: Array<UInt8>
        var quickm: Bool = false
        var digit: Int32 = 0
        var op = 0
        var dp90 = 0
        var newarr: Array<UInt8>
        var i = 0
        alength = Int32(a.size)
        blength = Int32(b.size)
        ap = avlen - 1
        bp = bvlen - 1
        maxarr = bp
        if (maxarr < ap) {
            maxarr = ap
        }
        reb = None
        if (reuse) {
            if ((maxarr + 1) == alength) {
                reb = a
            }
        }
        if (reb.isNone()) {
            reb = Array<UInt8>(Int64(maxarr + 1)) { _ => 0 }
        }
        quickm = false
        if (m == 1) {
            quickm = true
        } else if (m == (-1)) {
            quickm = true
        }
        digit = 0

    private func checkdigits(rhs: BigDecimal, dig: Int32): Unit {
        if (dig == 0) {
            return
        }
        if (Int32(this.mant.size) > dig) {
            if (!(allzero(this.mant, dig))) {
                throw ArithmeticException("Too many digits: " + this.toString())
            }
        }
        if (rhs.isNone()) {
            return
        }
        if (Int32(rhs.mant.size) > dig) {
            if (!(allzero(rhs.mant, dig))) {
                throw ArithmeticException("Too many digits: " + rhs.toString())
            }
        }
    }

    private func round(set: MathContext): BigDecimal {
        return round(set.digits, set.roundingMode)
    }

    private func round(len: Int32, mode: Int32): BigDecimal {
        let adjust: Int32
        let sign: Int32
        let oldmant: Array<UInt8>
        var reuse = false
        var first = 0u8
        var increment: Int32 = 0
        var newmant: Array<UInt8>
        adjust = Int32(mant.size) - len
        if (adjust <= 0) {
            return this
        }
        exp = exp + adjust
        sign = Int32(ind)
        oldmant = mant
        if (len > 0) {
            mant = Array<UInt8>(Int64(len)) { _ => 0 }
            arraycopy(oldmant, 0, mant, 0, Int64(len))
            reuse = true
            first = oldmant[Int64(len)]
        } else {
            mant = ZERO.mant
            ind = iszero
            reuse = false
            if (len == 0) {
                first = oldmant[0]
            } else {
                first = 0
            }
        }
        increment = 0
                } else if (mode == ROUND_UNNECESSARY) {
                    if (!(allzero(oldmant, len))) {
                        throw ArithmeticException("Rounding necessary")
                    }
                } else if (mode == ROUND_HALF_DOWN) {
                    if (Int32(first) > 5) {
                        increment = sign
                    } else if (Int32(first) == 5) {
                        if (!(allzero(oldmant, len + 1))) {
                            increment = sign
                        }
                    }
                } else if (mode == ROUND_HALF_EVEN) {
                    if (Int32(first) > 5) {
                        increment = sign
                    } else if (Int32(first) == 5) {
                        if (!(allzero(oldmant, len + 1))) {
                            increment = sign
                        } else if ((((Int32(mant[Int64(Int32(mant.size) - 1)])) % 2)) != 0) {
                            increment = sign
                        }
                    }
                } else if (mode == ROUND_DOWN) { } else if (mode == ROUND_UP) {
                    if (!(allzero(oldmant, len))) {
                        increment = sign
                    }
                } else if (mode == ROUND_CEILING) {
                    if (sign > 0) {
                        if (!(allzero(oldmant, len))) {
                            increment = sign
                        }
                    }
                } else if (mode == ROUND_FLOOR) {
                    if (sign < 0) {
                        if (!(allzero(oldmant, len))) {
                            increment = sign
                        }
                    }
                } else {
                    throw IllegalArgumentException("Bad round value: " + mode.toString())
                }
            } while (false)
        } while (false)
        if (increment != 0) {
                    if (ind == isneg) {
                        increment = -increment
                    }
                    newmant = byteaddsub(mant, Int32(mant.size), ONE.mant, 1, increment, reuse)
                    if (Int32(newmant.size) > Int32(mant.size)) {
                        exp++
                        arraycopy(newmant, 0, mant, 0, mant.size)
                    } else {
                        mant = newmant
                    }
                }
            } while (false)
        }
        if (exp > MaxExp) {
            throw ArithmeticException("Exponent Overflow: " + exp.toString())
        }
        return this
    }

    private static func allzero(array: Array<UInt8>, start: Int32): Bool {
        var tempstart = start
        var i = 0
        if (tempstart < 0) {
            tempstart = 0
        }
                i++
            }
        } while (false)
        return true
    }

    private func finish(set: MathContext, strip: Bool): BigDecimal {
        var d = 0
        var i = 0
        var newmant: Array<UInt8>
        var mag = 0
        var sig = 0
        if (set.digits != 0) {
            if (Int32(this.mant.size) > set.digits) {
                this.round(set)
            }
        }
        if (strip) {
            if (set.form != MathContext.PLAIN) {
                d = Int32(this.mant.size)
