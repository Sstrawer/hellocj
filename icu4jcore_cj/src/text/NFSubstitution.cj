package icu4cj.text


abstract class NFSubstitution {
    let pos: Int32

    let ruleSet: NFRuleSet

    let numberFormat: DecimalFormat

    public static func makeSubstitution(pos: Int32, rule: NFRule, rulePredecessor: NFRule, ruleSet: NFRuleSet, formatter: RuleBasedNumberFormat, description: String): NFSubstitution {
        if (Int32(description.size) == 0) {
            return None
        }
        match (Char(description[0])) {
            case '<' => if (rule.getBaseValue() == Int64(NFRule.NEGATIVE_NUMBER_RULE)) {
                throw IllegalArgumentException("<< not allowed in negative-number rule")
            } else if (rule.getBaseValue() == Int64(NFRule.IMPROPER_FRACTION_RULE) || rule.getBaseValue() == Int64(NFRule.PROPER_FRACTION_RULE) || rule.getBaseValue() == Int64(NFRule.DEFAULT_RULE)) {
                return IntegralPartSubstitution(pos, ruleSet, description)
            } else if (ruleSet.isFractionSet()) {
                return NumeratorSubstitution(pos, Float64(rule.getBaseValue()), formatter.getDefaultRuleSet(), description)
            } else {
                return MultiplierSubstitution(pos, rule, ruleSet, description)
            }
            case '>' => if (rule.getBaseValue() == Int64(NFRule.NEGATIVE_NUMBER_RULE)) {
                return AbsoluteValueSubstitution(pos, ruleSet, description)
            } else if (rule.getBaseValue() == Int64(NFRule.IMPROPER_FRACTION_RULE) || rule.getBaseValue() == Int64(NFRule.PROPER_FRACTION_RULE) || rule.getBaseValue() == Int64(NFRule.DEFAULT_RULE)) {
                return FractionalPartSubstitution(pos, ruleSet, description)
            } else if (ruleSet.isFractionSet()) {
                throw IllegalArgumentException(">> not allowed in fraction rule set")
            } else {
                return ModulusSubstitution(pos, rule, rulePredecessor, ruleSet, description)
            }
            case '=' => return SameValueSubstitution(pos, ruleSet, description)
            case _ => throw IllegalArgumentException("Illegal substitution character")
        }
    }

    init(pos: Int32, ruleSet: NFRuleSet, description: String) {
        var tempdescription = description
        this.pos = pos
        let descriptionLen = Int32(tempdescription.size)
        if (descriptionLen >= 2 && Char(tempdescription[0]) == Char(tempdescription[Int64(descriptionLen - 1)])) {
            tempdescription = tempdescription[1..Int64(descriptionLen - 1)]
        } else if (descriptionLen != 0) {
            throw IllegalArgumentException("Illegal substitution syntax")
        }
        if (Int32(tempdescription.size) == 0) {
            this.ruleSet = ruleSet
            this.numberFormat = None
        } else if (Char(tempdescription[0]) == '%') {
            this.ruleSet = ruleSet.owner.findRuleSet(tempdescription)
            this.numberFormat = None
        } else if (Char(tempdescription[0]) == '#' || Char(tempdescription[0]) == '0') {
            this.ruleSet = None
            this.numberFormat = ruleSet.owner.getDecimalFormat().clone()
            this.numberFormat.applyPattern(tempdescription)
        } else if (Char(tempdescription[0]) == '>') {
            this.ruleSet = ruleSet
            this.numberFormat = None
        } else {
            throw IllegalArgumentException("Illegal substitution syntax")
        }
    }

    public func setDivisor(radix: Int32, exponent: Int16): Unit { }

    public override func equals(that: Object): Bool {
        if (that.isNone()) {
            return false
        }
        if (refEq(this, that)) {
            return true
        }
        if (refEq(TypeInfo.of(this), TypeInfo.of(that))) {
            let that2 = that
            return pos == that2.pos && (ruleSet.isSome() || that2.ruleSet.isNone()) && (if (numberFormat.isNone()) { (that2.numberFormat.isNone()) } else { numberFormat.equals(that2.numberFormat) })
        }
        return false
    }

    public override func hashCode(): Int64 {
        if (!false) {
            throw Exception("hashCode not designed")
        }
        return 42
    }

    public override func toString(): String {
        if (ruleSet.isSome()) {
            return tokenChar().toString() + (ruleSet.getName()) + tokenChar().toString()
        } else {
            return tokenChar().toString() + (numberFormat.toPattern()) + tokenChar().toString()
        }
    }

    private static let MAX_INT64_IN_DOUBLE = 9007199254740991

    public func doSubstitution(number: Int64, toInsertInto: StringBuilder, position: Int32, recursionCount: Int32): Unit {
        if (ruleSet.isSome()) {
            let numberToFormat = transformNumber(number)
            ruleSet.format(numberToFormat, toInsertInto, position + pos, recursionCount)
        } else {
            if (number <= MAX_INT64_IN_DOUBLE) {
                toInsertInto.insert(Int64(position + pos), numberFormat.format(transformNumber(Float64(number))))
            } else {
                let numberToFormat = transformNumber(number)
                toInsertInto.insert(Int64(position + pos), numberFormat.format(numberToFormat))
            }
        }
    }

    public func doSubstitution(number: Float64, toInsertInto: StringBuilder, position: Int32, recursionCount: Int32): Unit {
        let numberToFormat = transformNumber(number)
        if (Float64.isInfinite(numberToFormat)) {
            let infiniteRule = ruleSet.findRule(Float64.POSITIVE_INFINITY)
            infiniteRule.doFormat(numberToFormat, toInsertInto, position + pos, recursionCount)
            return
        }
        if (numberToFormat == floor(numberToFormat) && ruleSet.isSome()) {
            ruleSet.format(Int64(numberToFormat), toInsertInto, position + pos, recursionCount)
        } else {
            if (ruleSet.isSome()) {
                ruleSet.format(numberToFormat, toInsertInto, position + pos, recursionCount)
            } else {
                toInsertInto.insert(Int64(position + this.pos), numberFormat.format(numberToFormat))
            }
        }
    }

    public func transformNumber(number: Int64): Int64

    public func transformNumber(number: Float64): Float64

    public func doParse(text: String, parsePosition: ParsePosition, baseValue: Float64, upperBound: Float64, lenientParse: Bool, nonNumericalExecutedRuleMask: Int32): Number {
        var tempupperBound = upperBound
        var tempResult: Number = None
        tempupperBound = calcUpperBound(tempupperBound)
        if (ruleSet.isSome()) {
            tempResult = ruleSet.parse(text, parsePosition, tempupperBound, nonNumericalExecutedRuleMask)
            if (lenientParse && !ruleSet.isFractionSet() && parsePosition.getIndex() == 0) {
                tempResult = ruleSet.owner.getDecimalFormat().parse(text, parsePosition)
            }
        } else {
            tempResult = numberFormat.parse(text, parsePosition)
        }
        if (parsePosition.getIndex() != 0) {
            var result = tempResult.doubleValue()
            result = composeRuleValue(result, baseValue)
            if (result == Float64(Int64(result))) {
                return Int64(result)
            } else {
                return result
            }
        } else {
            return tempResult
        }
    }

    public func composeRuleValue(newRuleValue: Float64, oldRuleValue: Float64): Float64

    public func calcUpperBound(oldUpperBound: Float64): Float64

    public func getPos(): Int32 {
        return pos
    }

    public func tokenChar(): Char

    public func isModulusSubstitution(): Bool {
        return false
    }

    public func setDecimalFormatSymbols(newSymbols: DecimalFormatSymbols): Unit {
        if (numberFormat.isSome()) {
            numberFormat.setDecimalFormatSymbols(newSymbols)
        }
    }
}


class SameValueSubstitution <: NFSubstitution {
    init(pos: Int32, ruleSet: NFRuleSet, description: String) {
        super(pos, ruleSet, description)
        if (description == "==") {
            throw IllegalArgumentException("== is not a legal token")
        }
    }

    public override func transformNumber(number: Int64): Int64 {
        return number
    }

    public override func transformNumber(number: Float64): Float64 {
        return number
    }

    public override func composeRuleValue(newRuleValue: Float64, oldRuleValue: Float64): Float64 {
        return newRuleValue
    }

    public override func calcUpperBound(oldUpperBound: Float64): Float64 {
        return oldUpperBound
    }

    public override func tokenChar(): Char {
        return '='
    }
}


class MultiplierSubstitution <: NFSubstitution {
    var divisor: Int64 = 0

    var owningRule: NFRule

    init(pos: Int32, rule: NFRule, ruleSet: NFRuleSet, description: String) {
        super(pos, ruleSet, description)
        this.divisor = rule.getDivisor()
        this.owningRule = rule
        if (divisor == 0) {
            throw Exception("Substitution with divisor 0 " + description[0..Int64(pos)] + " | " + description[Int64(pos)..])
        }
    }

    public override func setDivisor(radix: Int32, exponent: Int16): Unit {
        divisor = NFRule.power(Int64(radix), exponent)
        if (divisor == 0) {
            throw Exception("Substitution with divisor 0")
        }
    }

    public override func equals(that: Object): Bool {
        return super.equals(that) && divisor == that.divisor
    }

    public override func transformNumber(number: Int64): Int64 {
        return Int64(Math.floor(Float64(number / divisor)))
    }

    public override func transformNumber(number: Float64): Float64 {
        if (ruleSet.isSome() || owningRule.hasModulusSubstitution() || owningRule.formatter.getRoundingMode() == BigDecimal.ROUND_FLOOR) {
            return floor(number / Float64(divisor))
        } else {
            return number / Float64(divisor)
        }
    }

    public override func composeRuleValue(newRuleValue: Float64, oldRuleValue: Float64): Float64 {
        return newRuleValue * Float64(divisor)
    }

    public override func calcUpperBound(oldUpperBound: Float64): Float64 {
        return Float64(divisor)
    }

    public override func tokenChar(): Char {
        return '<'
    }
}


class ModulusSubstitution <: NFSubstitution {
    var divisor: Int64 = 0

    private let ruleToUse: NFRule

    init(pos: Int32, rule: NFRule, rulePredecessor: NFRule, ruleSet: NFRuleSet, description: String) {
        super(pos, ruleSet, description)
        this.divisor = rule.getDivisor()
        if (divisor == 0) {
            throw Exception("Substitution with bad divisor (" + divisor.toString() + ") " + description[0..Int64(pos)] + " | " + description[Int64(pos)..])
        }
        if (description == ">>>") {
            ruleToUse = rulePredecessor
        } else {
            ruleToUse = None
        }
    }

    public override func setDivisor(radix: Int32, exponent: Int16): Unit {
        divisor = NFRule.power(Int64(radix), exponent)
        if (divisor == 0) {
            throw Exception("Substitution with bad divisor")
        }
    }

    public override func equals(that: Object): Bool {
        if (super.equals(that)) {
            let that2 = that
            return divisor == that2.divisor
        } else {
            return false
        }
    }

    public override func doSubstitution(number: Int64, toInsertInto: StringBuilder, position: Int32, recursionCount: Int32): Unit {
        if (ruleToUse.isNone()) {
            super.doSubstitution(number, toInsertInto, position, recursionCount)
        } else {
            let numberToFormat = transformNumber(number)
            ruleToUse.doFormat(numberToFormat, toInsertInto, position + pos, recursionCount)
        }
    }

    public override func doSubstitution(number: Float64, toInsertInto: StringBuilder, position: Int32, recursionCount: Int32): Unit {
        if (ruleToUse.isNone()) {
            super.doSubstitution(number, toInsertInto, position, recursionCount)
        } else {
            let numberToFormat = transformNumber(number)
            ruleToUse.doFormat(numberToFormat, toInsertInto, position + pos, recursionCount)
        }
    }

    public override func transformNumber(number: Int64): Int64 {
        return number % divisor
    }

    public override func transformNumber(number: Float64): Float64 {
        return rem(number, Float64(divisor))
    }

    public override func doParse(text: String, parsePosition: ParsePosition, baseValue: Float64, upperBound: Float64, lenientParse: Bool, nonNumericalExecutedRuleMask: Int32): Number {
        if (ruleToUse.isNone()) {
            return super.doParse(text, parsePosition, baseValue, upperBound, lenientParse, nonNumericalExecutedRuleMask)
        } else {
            let tempResult = ruleToUse.doParse(text, parsePosition, false, upperBound, nonNumericalExecutedRuleMask)
            if (parsePosition.getIndex() != 0) {
                var result = tempResult.doubleValue()
                result = composeRuleValue(result, baseValue)
                if (result == Float64(Int64(result))) {
                    return Int64(result)
                } else {
                    return result
                }
            } else {
                return tempResult
            }
        }
    }

    public override func composeRuleValue(newRuleValue: Float64, oldRuleValue: Float64): Float64 {
        return (oldRuleValue - (rem(oldRuleValue, Float64(divisor)))) + newRuleValue
    }

    public override func calcUpperBound(oldUpperBound: Float64): Float64 {
        return Float64(divisor)
    }

    public override func isModulusSubstitution(): Bool {
        return true
    }

    public override func tokenChar(): Char {
        return '>'
    }
}


class IntegralPartSubstitution <: NFSubstitution {
    init(pos: Int32, ruleSet: NFRuleSet, description: String) {
        super(pos, ruleSet, description)
    }

    public override func transformNumber(number: Int64): Int64 {
        return number
    }

    public override func transformNumber(number: Float64): Float64 {
        return floor(number)
    }

    public override func composeRuleValue(newRuleValue: Float64, oldRuleValue: Float64): Float64 {
        return newRuleValue + oldRuleValue
    }

    public override func calcUpperBound(oldUpperBound: Float64): Float64 {
        return Float64.Max
    }

    public override func tokenChar(): Char {
        return '<'
    }
}


class FractionalPartSubstitution <: NFSubstitution {
    private let byDigits: Bool

    private let useSpaces: Bool

    init(pos: Int32, ruleSet: NFRuleSet, description: String) {
        super(pos, ruleSet, description)
        if (description == ">>" || description == ">>>" || refEq(ruleSet, this.ruleSet)) {
            byDigits = true
            useSpaces = !(description == ">>>")
        } else {
            byDigits = false
            useSpaces = true
            this.ruleSet.makeIntoFractionRuleSet()
        }
    }

    public override func doSubstitution(number: Float64, toInsertInto: StringBuilder, position: Int32, recursionCount: Int32): Unit {
        if (!byDigits) {
            super.doSubstitution(number, toInsertInto, position, recursionCount)
        } else {
            let fq = DecimalQuantity_DualStorageBCD(number)
            fq.roundToInfinity()
            var pad = false
            var mag = fq.getLowerDisplayMagnitude()
            while (mag < 0) {
                if (pad && useSpaces) {
                    toInsertInto.insert(Int64(position + pos), ' ')
                } else {
                    pad = true
                }
                ruleSet.format(Int64(fq.getDigit(match (0) { case _ => mag++; mag - 1 })), toInsertInto, position + pos, recursionCount)
            }
        }
    }

    public override func transformNumber(number: Int64): Int64 {
        return 0
    }

    public override func transformNumber(number: Float64): Float64 {
        return number - floor(number)
    }

    public override func doParse(text: String, parsePosition: ParsePosition, baseValue: Float64, upperBound: Float64, lenientParse: Bool, nonNumericalExecutedRuleMask: Int32): Number {
        if (!byDigits) {
            return super.doParse(text, parsePosition, baseValue, 0.0, lenientParse, nonNumericalExecutedRuleMask)
        } else {
            var workText = text
            let workPos = ParsePosition(1)
            var result: Float64 = 0.0
            var digit: Int32 = 0
            let fq = DecimalQuantity_DualStorageBCD()
            var totalDigits = 0
            while (Int32(workText.size) > 0 && workPos.getIndex() != 0) {
                workPos.setIndex(0)
                digit = ruleSet.parse(workText, workPos, 10.0, nonNumericalExecutedRuleMask).intValue()
                if (lenientParse && workPos.getIndex() == 0) {
                    let n = ruleSet.owner.getDecimalFormat().parse(workText, workPos)
                    if (n.isSome()) {
                        digit = n.intValue()
                    }
                }
                if (workPos.getIndex() != 0) {
                    fq.appendDigit(UInt8(digit), 0, true)
                    totalDigits++
                    parsePosition.setIndex(parsePosition.getIndex() + workPos.getIndex())
                    workText = workText[Int64(workPos.getIndex())..]
                    while (Int32(workText.size) > 0 && Char(workText[0]) == ' ') {
                        workText = workText[1..]
                        parsePosition.setIndex(parsePosition.getIndex() + 1)
                    }
                }
            }
            fq.adjustMagnitude(-totalDigits)
            result = fq.toDouble()
            result = composeRuleValue(result, baseValue)
            return result
        }
    }

    public override func composeRuleValue(newRuleValue: Float64, oldRuleValue: Float64): Float64 {
        return newRuleValue + oldRuleValue
    }

    public override func calcUpperBound(oldUpperBound: Float64): Float64 {
        return 0.0
    }

    public override func tokenChar(): Char {
        return '>'
    }
}


class AbsoluteValueSubstitution <: NFSubstitution {
    init(pos: Int32, ruleSet: NFRuleSet, description: String) {
        super(pos, ruleSet, description)
    }

    public override func transformNumber(number: Int64): Int64 {
        return abs(number)
    }

    public override func transformNumber(number: Float64): Float64 {
        return abs(number)
    }

    public override func composeRuleValue(newRuleValue: Float64, oldRuleValue: Float64): Float64 {
        return -newRuleValue
    }

    public override func calcUpperBound(oldUpperBound: Float64): Float64 {
        return Float64.Max
    }

    public override func tokenChar(): Char {
        return '>'
    }
}


class NumeratorSubstitution <: NFSubstitution {
    private let denominator: Float64

    private let withZeros: Bool

    init(pos: Int32, denominator: Float64, ruleSet: NFRuleSet, description: String) {
        super(pos, ruleSet, fixdesc(description))
        this.denominator = denominator
        this.withZeros = description.endsWith("<<")
    }

    static func fixdesc(description: String): String {
        return if (description.endsWith("<<")) { description[0..Int64(Int32(description.size) - 1)] } else { description }
    }

    public override func equals(that: Object): Bool {
        if (super.equals(that)) {
            let that2 = that
            return denominator == that2.denominator && withZeros == that2.withZeros
        } else {
            return false
        }
    }

    public override func doSubstitution(number: Float64, toInsertInto: StringBuilder, position: Int32, recursionCount: Int32): Unit {
        var tempposition = position
        let numberToFormat = transformNumber(number)
        if (withZeros && ruleSet.isSome()) {
            var nf = Int64(numberToFormat)
            let len = Int32(toInsertInto.size)
            while ((nf < denominator) {
                toInsertInto.insert(Int64(tempposition + pos), ' ')
                ruleSet.format(0, toInsertInto, tempposition + pos, recursionCount)
            }
            tempposition += Int32(toInsertInto.size) - len
        }
        if (numberToFormat == floor(numberToFormat) && ruleSet.isSome()) {
            ruleSet.format(Int64(numberToFormat), toInsertInto, tempposition + pos, recursionCount)
        } else {
            if (ruleSet.isSome()) {
                ruleSet.format(numberToFormat, toInsertInto, tempposition + pos, recursionCount)
            } else {
                toInsertInto.insert(Int64(tempposition + pos), numberFormat.format(numberToFormat))
            }
        }
    }

    public override func transformNumber(number: Int64): Int64 {
        return Math.round(Float64(number) * denominator)
    }

    public override func transformNumber(number: Float64): Float64 {
        return Float64(Math.round(number * denominator))
    }

    public override func doParse(text: String, parsePosition: ParsePosition, baseValue: Float64, upperBound: Float64, lenientParse: Bool, nonNumericalExecutedRuleMask: Int32): Number {
        var temptext = text
        var zeroCount = 0
        if (withZeros) {
            var workText = temptext
            let workPos = ParsePosition(1)
            while (Int32(workText.size) > 0 && workPos.getIndex() != 0) {
                workPos.setIndex(0)
                ruleSet.parse(workText, workPos, 1.0, nonNumericalExecutedRuleMask).intValue()
                if (workPos.getIndex() == 0) {
                    break
                }
                zeroCount++
                parsePosition.setIndex(parsePosition.getIndex() + workPos.getIndex())
                workText = workText[Int64(workPos.getIndex())..]
                while (Int32(workText.size) > 0 && Char(workText[0]) == ' ') {
                    workText = workText[1..]
                    parsePosition.setIndex(parsePosition.getIndex() + 1)
                }
            }
            temptext = temptext[Int64(parsePosition.getIndex())..]
            parsePosition.setIndex(0)
        }
        var result = super.doParse(temptext, parsePosition, if (withZeros) { 1.0 } else { baseValue }, upperBound, false, nonNumericalExecutedRuleMask)
        if (withZeros) {
            let n = result.longValue()
            var d = 1
            while (d <= n) {
                d *= 10
            }
            while (zeroCount > 0) {
                d *= 10
                zeroCount--
            }
            result = Float64(n) / Float64(d)
        }
        return result
    }

    public override func composeRuleValue(newRuleValue: Float64, oldRuleValue: Float64): Float64 {
        return newRuleValue / oldRuleValue
    }

    public override func calcUpperBound(oldUpperBound: Float64): Float64 {
        return denominator
    }

    public override func tokenChar(): Char {
        return '<'
    }
}
