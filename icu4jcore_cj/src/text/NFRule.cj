package icu4cj.text

class NFRule {
    static let NEGATIVE_NUMBER_RULE = -1

    static let IMPROPER_FRACTION_RULE = -2

    static let PROPER_FRACTION_RULE = -3

    static let DEFAULT_RULE = -4

    static let INFINITY_RULE = -5

    static let NAN_RULE = -6

    static let ZERO: Int64 = 0

    private var baseValue: Int64 = 0

    private var radix = 10

    private var exponent = 0i16

    private var decimalPoint = Char(0)

    private var ruleText: String

    private var rulePatternFormat: PluralFormat

    private var sub1: NFSubstitution

    private var sub2: NFSubstitution

    let formatter: RuleBasedNumberFormat

    public static func makeRules(description: String, owner: NFRuleSet, predecessor: NFRule, ownersOwner: RuleBasedNumberFormat, returnList: ArrayList<NFRule>): Unit {
        var tempdescription = description
        let rule1 = NFRule(ownersOwner, tempdescription)
        tempdescription = rule1.ruleText
        let brack1 = indexOfWrap(tempdescription.indexOf(UInt8(UInt32('['))))
        let brack2 = if (brack1 < 0) { -1 } else { indexOfWrap(tempdescription.indexOf(UInt8(UInt32(']')))) }
        if (brack2 < 0 || brack1 > brack2 || rule1.baseValue == Int64(PROPER_FRACTION_RULE) || rule1.baseValue == Int64(NEGATIVE_NUMBER_RULE) || rule1.baseValue == Int64(INFINITY_RULE) || rule1.baseValue == Int64(NAN_RULE)) {
            rule1.extractSubstitutions(owner, tempdescription, predecessor)
        } else {
            var rule2: NFRule
            let sbuf = StringBuilder()
            if ((rule1.baseValue > 0 && rule1.baseValue % (power(Int64(rule1.radix), rule1.exponent)) == 0) || rule1.baseValue == Int64(IMPROPER_FRACTION_RULE) || rule1.baseValue == Int64(DEFAULT_RULE)) {
                rule2 = NFRule(ownersOwner, None)
                if (rule1.baseValue >= 0) {
                    rule2.baseValue = rule1.baseValue
                    if (!owner.isFractionSet()) {
                        rule1.baseValue++
                    }
                } else if (rule1.baseValue == Int64(IMPROPER_FRACTION_RULE)) {
                    rule2.baseValue = Int64(PROPER_FRACTION_RULE)
                } else if (rule1.baseValue == Int64(DEFAULT_RULE)) {
                    rule2.baseValue = rule1.baseValue
                    rule1.baseValue = Int64(IMPROPER_FRACTION_RULE)
                }
                rule2.radix = rule1.radix
                rule2.exponent = rule1.exponent
                sbuf.append(tempdescription[0..Int64(brack1)])
                if (brack2 + 1 < Int32(tempdescription.size)) {
                    sbuf.append(tempdescription[Int64(brack2 + 1)..])
                }
                rule2.extractSubstitutions(owner, sbuf.toString(), predecessor)
            }
            sbuf.setLength(0)
            sbuf.append(tempdescription[0..Int64(brack1)])
            sbuf.append(tempdescription[Int64(brack1 + 1)..Int64(brack2)])
            if (brack2 + 1 < Int32(tempdescription.size)) {
                sbuf.append(tempdescription[Int64(brack2 + 1)..])
            }
            rule1.extractSubstitutions(owner, sbuf.toString(), predecessor)
            if (rule2.isSome()) {
                if (rule2.baseValue >= 0) {
                    returnList.append(rule2)
                } else {
                    owner.setNonNumericalRule(rule2)
                }
            }
        }
        if (rule1.baseValue >= 0) {
            returnList.append(rule1)
        } else {
            owner.setNonNumericalRule(rule1)
        }
    }

    public init(formatter: RuleBasedNumberFormat, ruleText: String) {
        this.formatter = formatter
        this.ruleText = if (ruleText.isNone()) { None } else { parseRuleDescriptor(ruleText) }
    }

    private func parseRuleDescriptor(description: String): String {
        var tempdescription = description
        let descriptor: String
        var p = indexOfWrap(tempdescription.indexOf(":"))
        if (p != -1) {
            descriptor = tempdescription[0..Int64(p)]
            p++
            while (p < Int32(tempdescription.size) && PatternProps.isWhiteSpace(Int32(UInt32(Char(tempdescription[Int64(p)]))))) {
                p++
            }
            tempdescription = tempdescription[Int64(p)..]
            let descriptorLength = Int32(descriptor.size)
            let firstChar = Char(descriptor[0])
            let lastChar = Char(descriptor[Int64(descriptorLength - 1)])
            if (firstChar >= '0' && firstChar <= '9' && lastChar != 'x') {
                var tempValue = 0
                var c = Char(0)
                p = 0
                while (p < descriptorLength) {
                    c = Char(descriptor[Int64(p)])
                    if (c >= '0' && c <= '9') {
                        tempValue = tempValue * 10 + ()
                    } else if (c == '/' || c == '>') {
                        break
                    } else if (!PatternProps.isWhiteSpace(Int32(UInt32(c))) && c != ',' && c != '.') {
                        throw IllegalArgumentException("Illegal character " + c.toString() + " in rule descriptor")
                    }
                    p++
                }
                setBaseValue(tempValue)
                if (c == '/') {
                    tempValue = 0
                    p++
                    while (p < descriptorLength) {
                        c = Char(descriptor[Int64(p)])
                        if (c >= '0' && c <= '9') {
                            tempValue = tempValue * 10 + ()
                        } else if (c == '>') {
                            break
                        } else if (!PatternProps.isWhiteSpace(Int32(UInt32(c))) && c != ',' && c != '.') {
                            throw IllegalArgumentException("Illegal character " + c.toString() + " in rule descriptor")
                        }
                        p++
                    }
                    radix = Int32(tempValue)
                    if (radix == 0) {
                        throw IllegalArgumentException("Rule can't have radix of 0")
                    }
                    exponent = expectedExponent()
                }
                if (c == '>') {
                    while (p < descriptorLength) {
                        c = Char(descriptor[Int64(p)])
                        if (c == '>' && Int32(exponent) > 0) {
                            exponent--
                        } else {
                            throw IllegalArgumentException("Illegal character in rule descriptor")
                        }
                        p++
                    }
                }
            } else if (descriptor == "-x") {
                setBaseValue(Int64(NEGATIVE_NUMBER_RULE))
            } else if (descriptorLength == 3) {
                if (firstChar == '0' && lastChar == 'x') {
                    setBaseValue(Int64(PROPER_FRACTION_RULE))
                    decimalPoint = Char(descriptor[1])
                } else if (firstChar == 'x' && lastChar == 'x') {
                    setBaseValue(Int64(IMPROPER_FRACTION_RULE))
                    decimalPoint = Char(descriptor[1])
                } else if (firstChar == 'x' && lastChar == '0') {
                    setBaseValue(Int64(DEFAULT_RULE))
                    decimalPoint = Char(descriptor[1])
                } else if (descriptor == "NaN") {
                    setBaseValue(Int64(NAN_RULE))
                } else if (descriptor == "Inf") {
                    setBaseValue(Int64(INFINITY_RULE))
                }
            }
        }
        if (Int32(tempdescription.size) > 0 && Char(tempdescription[0]) == ''') {
            tempdescription = tempdescription[1..]
        }
        return tempdescription
    }

    private func extractSubstitutions(owner: NFRuleSet, ruleText: String, predecessor: NFRule): Unit {
        var tempruleText = ruleText
        this.ruleText = tempruleText
        sub1 = extractSubstitution(owner, predecessor)
        if (sub1.isNone()) {
            sub2 = None
        } else {
            sub2 = extractSubstitution(owner, predecessor)
        }
        tempruleText = this.ruleText
        let pluralRuleStart = indexOfWrap(tempruleText.indexOf("$("))
        let pluralRuleEnd = (if (pluralRuleStart >= 0) { indexOfWrap(tempruleText.indexOf(")$", Int64(pluralRuleStart))) } else { -1 })
        if (pluralRuleEnd >= 0) {
            let endType = indexOfWrap(tempruleText.indexOf(UInt8(UInt32(',')), Int64(pluralRuleStart)))
            if (endType < 0) {
                throw IllegalArgumentException("Rule \"" + (tempruleText) + "\" does not have a defined type")
            }
            let Type: String = this.ruleText[Int64(pluralRuleStart + 2)..Int64(endType)]
            let pluralType: PluralRules_PluralType
            if ("cardinal".equals(Type)) {
                pluralType = PluralRules_PluralType.CARDINAL
            } else if ("ordinal".equals(Type)) {
                pluralType = PluralRules_PluralType.ORDINAL
            } else {
                throw IllegalArgumentException((Type) + " is an unknown type")
            }
            rulePatternFormat = formatter.createPluralFormat(pluralType, tempruleText[Int64(endType + 1)..Int64(pluralRuleEnd)])
        }
    }

    private func extractSubstitution(owner: NFRuleSet, predecessor: NFRule): NFSubstitution {
        let result: NFSubstitution
        let subStart: Int32
        var subEnd: Int32 = 0
        subStart = indexOfAnyRulePrefix(ruleText)
        if (subStart == -1) {
            return None
        }
        if (ruleText.startsWith(">>>", subStart)) {
            subEnd = subStart + 2
        } else {
            let c = Char(ruleText[Int64(subStart)])
            subEnd = indexOfWrap(ruleText.indexOf(UInt8(UInt32(c)), Int64(subStart + 1)))
            if (c == '<' && subEnd != -1 && subEnd < Int32(ruleText.size) - 1 && Char(ruleText[Int64(subEnd + 1)]) == c) {
                subEnd++
            }
        }
        if (subEnd == -1) {
            return None
        }
        result = NFSubstitution.makeSubstitution(subStart, this, predecessor, owner, this.formatter, ruleText[Int64(subStart)..Int64(subEnd + 1)])
        ruleText = ruleText[0..Int64(subStart)] + ruleText[Int64(subEnd + 1)..]
        return result
    }

    func setBaseValue(newBaseValue: Int64): Unit {
        baseValue = newBaseValue
        radix = 10
        if (baseValue >= 1) {
            exponent = expectedExponent()
            if (sub1.isSome()) {
                sub1.setDivisor(radix, exponent)
            }
            if (sub2.isSome()) {
                sub2.setDivisor(radix, exponent)
            }
        } else {
            exponent = 0i16
        }
    }

    private func expectedExponent(): Int16 {
        if (radix == 0 || baseValue < 1) {
            return 0i16
        }
        let tempResult = Int16(Math.log(Float64(baseValue)) / Math.log(Float64(radix)))
        if (power(Int64(radix), Int16(Int32(tempResult) + 1)) <= baseValue) {
            return Int16(Int32(tempResult) + 1)
        } else {
            return tempResult
        }
    }

    private static let RULE_PREFIXES: Array<String> = ["<<", "<%", "<#", "<0", ">>", ">%", ">#", ">0", "=%", "=#", "=0"]

    private static func indexOfAnyRulePrefix(ruleText: String): Int32 {
        var result = -1
        if (Int32(ruleText.size) > 0) {
            var pos: Int32 = 0
            for (string in RULE_PREFIXES) {
                pos = indexOfWrap(ruleText.indexOf(string))
                if (pos != -1 && (result == -1 || pos < result)) {
                    result = pos
                }
            }
        }
        return result
    }

    public override func equals(that: Object): Bool {
        if (checkOptionalIs<NFRule, Object>(that)) {
            let that2 = that
            return baseValue == that2.baseValue && radix == that2.radix && exponent == that2.exponent && ruleText.equals(that2.ruleText) && Objects.equals(sub1, that2.sub1) && Objects.equals(sub2, that2.sub2)
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
        let result = StringBuilder()
        if (baseValue == Int64(NEGATIVE_NUMBER_RULE)) {
            result.append("-x: ")
        } else if (baseValue == Int64(IMPROPER_FRACTION_RULE)) {
            result.append('x').append(if (Int32(UInt32(decimalPoint)) == 0) { '.' } else { decimalPoint }).append("x: ")
        } else if (baseValue == Int64(PROPER_FRACTION_RULE)) {
            result.append('0').append(if (Int32(UInt32(decimalPoint)) == 0) { '.' } else { decimalPoint }).append("x: ")
        } else if (baseValue == Int64(DEFAULT_RULE)) {
            result.append('x').append(if (Int32(UInt32(decimalPoint)) == 0) { '.' } else { decimalPoint }).append("0: ")
        } else if (baseValue == Int64(INFINITY_RULE)) {
            result.append("Inf: ")
        } else if (baseValue == Int64(NAN_RULE)) {
            result.append("NaN: ")
        } else {
            result.append(baseValue.toString())
            if (radix != 10) {
                result.append('/').append(radix)
            }
            let numCarets = expectedExponent() - exponent
            var i = 0
            while (i < numCarets) {
                result.append('>')
                i++
            }
            result.append(": ")
        }
        if (ruleText.startsWith(" ") && (sub1.isNone() || sub1.getPos() != 0)) {
            result.append(''')
        }
        let ruleTextCopy = StringBuilder(ruleText)
        if (sub2.isSome()) {
            ruleTextCopy.insert(Int64(sub2.getPos()), sub2.toString())
        }
        if (sub1.isSome()) {
            ruleTextCopy.insert(Int64(sub1.getPos()), sub1.toString())
        }
        result.append(ruleTextCopy.toString())
        result.append(';')
        return result.toString()
    }

    public func getDecimalPoint(): Char {
        return decimalPoint
    }

    public func getBaseValue(): Int64 {
        return baseValue
    }

    public func getDivisor(): Int64 {
        return power(Int64(radix), exponent)
    }

    public func hasModulusSubstitution(): Bool {
        return (checkOptionalIs<ModulusSubstitution, NFSubstitution>(sub1)) || (checkOptionalIs<ModulusSubstitution, NFSubstitution>(sub2))
    }

    public func doFormat(number: Int64, toInsertInto: StringBuilder, pos: Int32, recursionCount: Int32): Unit {
        var pluralRuleStart = Int32(ruleText.size)
        var lengthOffset = 0
        if (rulePatternFormat.isNone()) {
            toInsertInto.insert(Int64(pos), ruleText)
        } else {
            pluralRuleStart = indexOfWrap(ruleText.indexOf("$("))
            let pluralRuleEnd = indexOfWrap(ruleText.indexOf(")$", Int64(pluralRuleStart)))
            let initialLength = Int32(toInsertInto.size)
            if (pluralRuleEnd < Int32(ruleText.size) - 1) {
                toInsertInto.insert(Int64(pos), ruleText[Int64(pluralRuleEnd + 2)..])
            }
            toInsertInto.insert(Int64(pos), rulePatternFormat.format(Float64(number / power(Int64(radix), exponent))))
            if (pluralRuleStart > 0) {
                toInsertInto.insert(Int64(pos), ruleText[0..Int64(pluralRuleStart)])
            }
            lengthOffset = Int32(ruleText.size) - (Int32(toInsertInto.size) - initialLength)
        }
        if (sub2.isSome()) {
            sub2.doSubstitution(number, toInsertInto, pos - (if (sub2.getPos() > pluralRuleStart) { lengthOffset } else { 0 }), recursionCount)
        }
        if (sub1.isSome()) {
            sub1.doSubstitution(number, toInsertInto, pos - (if (sub1.getPos() > pluralRuleStart) { lengthOffset } else { 0 }), recursionCount)
        }
    }

    public func doFormat(number: Float64, toInsertInto: StringBuilder, pos: Int32, recursionCount: Int32): Unit {
        var pluralRuleStart = Int32(ruleText.size)
        var lengthOffset = 0
        if (rulePatternFormat.isNone()) {
            toInsertInto.insert(Int64(pos), ruleText)
        } else {
            pluralRuleStart = indexOfWrap(ruleText.indexOf("$("))
            let pluralRuleEnd = indexOfWrap(ruleText.indexOf(")$", Int64(pluralRuleStart)))
            let initialLength = Int32(toInsertInto.size)
            if (pluralRuleEnd < Int32(ruleText.size) - 1) {
                toInsertInto.insert(Int64(pos), ruleText[Int64(pluralRuleEnd + 2)..])
            }
            var pluralVal = number
            if (0.0 <= pluralVal && pluralVal < 1.0) {
                pluralVal = Float64(Math.round(pluralVal * Float64(power(Int64(radix), exponent))))
            } else {
                pluralVal = pluralVal / Float64(power(Int64(radix), exponent))
            }
            toInsertInto.insert(Int64(pos), rulePatternFormat.format(Float64(Int64(pluralVal))))
            if (pluralRuleStart > 0) {
                toInsertInto.insert(Int64(pos), ruleText[0..Int64(pluralRuleStart)])
            }
            lengthOffset = Int32(ruleText.size) - (Int32(toInsertInto.size) - initialLength)
        }
        if (sub2.isSome()) {
            sub2.doSubstitution(number, toInsertInto, pos - (if (sub2.getPos() > pluralRuleStart) { lengthOffset } else { 0 }), recursionCount)
        }
        if (sub1.isSome()) {
            sub1.doSubstitution(number, toInsertInto, pos - (if (sub1.getPos() > pluralRuleStart) { lengthOffset } else { 0 }), recursionCount)
        }
    }

    static func power(base: Int64, exponent: Int16): Int64 {
        var tempbase = base
        var tempexponent = exponent
        if (Int32(tempexponent) < 0) {
            throw IllegalArgumentException("Exponent can not be negative")
        }
        if (tempbase < 0) {
            throw IllegalArgumentException("Base can not be negative")
        }
        var result = 1
        while (Int32(tempexponent) > 0) {
            if ((Int32(tempexponent) & 1) == 1) {
                result *= tempbase
            }
            tempbase *= tempbase
            tempexponent >>= 1i16
        }
        return result
    }

    public func shouldRollBack(number: Int64): Bool {
        if (!((sub1.isSome() && sub1.isModulusSubstitution()) || (sub2.isSome() && sub2.isModulusSubstitution()))) {
            return false
        }
        let divisor = power(Int64(radix), exponent)
        return (number % divisor) == 0 && (baseValue % divisor) != 0
    }

    public func doParse(text: String, parsePosition: ParsePosition, isFractionRule: Bool, upperBound: Float64, nonNumericalExecutedRuleMask: Int32): Number {
        let pp = ParsePosition(0)
        let sub1Pos = if (sub1.isSome()) { sub1.getPos() } else { Int32(ruleText.size) }
        let sub2Pos = if (sub2.isSome()) { sub2.getPos() } else { Int32(ruleText.size) }
        let workText = stripPrefix(text, ruleText[0..Int64(sub1Pos)], pp)
        let prefixLength = Int32(text.size) - Int32(workText.size)
        if (pp.getIndex() == 0 && sub1Pos != 0) {
            return ZERO
        }
        if (baseValue == Int64(INFINITY_RULE)) {
            parsePosition.setIndex(pp.getIndex())
            return Float64.POSITIVE_INFINITY
        }
        if (baseValue == Int64(NAN_RULE)) {
            parsePosition.setIndex(pp.getIndex())
            return Float64.NaN
        }
        var highWaterMark = 0
        var result = 0.0
        var start = 0
        let tempBaseValue = Float64(Math.max(0, baseValue))
                }
            }
        } while (sub1Pos != sub2Pos && pp.getIndex() > 0 && pp.getIndex() < Int32(workText.size) && pp.getIndex() != start)
        parsePosition.setIndex(highWaterMark)
        if (isFractionRule && highWaterMark > 0 && sub1.isNone()) {
            result = 1.0 / result
        }
        if (result == Float64(Int64(result))) {
            return Int64(result)
        } else {
            return result
        }
    }

    private func stripPrefix(text: String, prefix: String, pp: ParsePosition): String {
        if (Int32(prefix.size) == 0) {
            return text
        } else {
            let pfl = prefixLength(text, prefix)
            if (pfl != 0) {
                pp.setIndex(pp.getIndex() + pfl)
                return text[Int64(pfl)..]
            } else {
                return text
            }
        }
    }

    private func matchToDelimiter(text: String, startPos: Int32, baseVal: Float64, delimiter: String, pluralFormatDelimiter: PluralFormat, pp: ParsePosition, sub: NFSubstitution, upperBound: Float64, nonNumericalExecutedRuleMask: Int32): Number {
        if (!allIgnorable(delimiter)) {
            let tempPP = ParsePosition(0)
            var tempResult: Number = None
            var temp = findText(text, delimiter, pluralFormatDelimiter, startPos)
            var dPos = temp[0]
            var dLen = temp[1]
            while (dPos >= 0) {
                let subText: String = text[0..Int64(dPos)]
                if (Int32(subText.size) > 0) {
                    tempResult = sub.doParse(subText, tempPP, baseVal, upperBound, formatter.lenientParseEnabled(), nonNumericalExecutedRuleMask)
                    if (tempPP.getIndex() == dPos) {
                        pp.setIndex(dPos + dLen)
                        return tempResult
                    }
                }
                tempPP.setIndex(0)
                temp = findText(text, delimiter, pluralFormatDelimiter, dPos + dLen)
                dPos = temp[0]
                dLen = temp[1]
            }
            pp.setIndex(0)
            return ZERO
        } else if (sub.isNone()) {
            return baseVal
        } else {
            let tempPP = ParsePosition(0)
            var result = ZERO
            let tempResult = sub.doParse(text, tempPP, baseVal, upperBound, formatter.lenientParseEnabled(), nonNumericalExecutedRuleMask)
            if (tempPP.getIndex() != 0) {
                pp.setIndex(tempPP.getIndex())
                if (tempResult.isSome()) {
                    result = tempResult
                }
            }
            return result
        }
    }

    private func prefixLength(str: String, prefix: String): Int32 {
        if (Int32(prefix.size) == 0) {
            return 0
        }
        let scanner = formatter.getLenientScanner()
        if (scanner.isSome()) {
            if (str.startsWith(prefix)) {
                return Int32(prefix.size)
            }
            return scanner.prefixLength(str, prefix)
        }
        if (str.startsWith(prefix)) {
            return Int32(prefix.size)
        }
        return 0
    }

    private func findText(str: String, key: String, pluralFormatKey: PluralFormat, startingAt: Int32): Array<Int32> {
        let scanner = formatter.getLenientScanner()
        if (pluralFormatKey.isSome()) {
            let position = FieldPosition(NumberFormat.INTEGER_FIELD)
            position.setBeginIndex(startingAt)
            pluralFormatKey.parseType(str, scanner, position)
            let start = position.getBeginIndex()
            if (start >= 0) {
                let pluralRuleStart = indexOfWrap(ruleText.indexOf("$("))
                let pluralRuleSuffix = indexOfWrap(ruleText.indexOf(")$", Int64(pluralRuleStart))) + 2
                let matchLen = position.getEndIndex() - start
                let prefix: String = ruleText[0..Int64(pluralRuleStart)]
                let suffix: String = ruleText[Int64(pluralRuleSuffix)..]
                if (str.regionMatches(start - Int32(prefix.size), prefix, 0, Int32(prefix.size)) && str.regionMatches(start + matchLen, suffix, 0, Int32(suffix.size))) {
                    return [start - Int32(prefix.size), matchLen + Int32(prefix.size) + Int32(suffix.size)]
                }
            }
            return [-1, 0]
        }
        if (scanner.isSome()) {
            let pos: Array<Int32> = [indexOfWrap(str.indexOf(key, Int64(startingAt))), Int32(key.size)]
            if (pos[0] >= 0) {
                return pos
            } else {
                return scanner.findText(str, key, startingAt)
            }
        }
        return [indexOfWrap(str.indexOf(key, Int64(startingAt))), Int32(key.size)]
    }

    private func allIgnorable(str: String): Bool {
        if (str.isNone() || Int32(str.size) == 0) {
            return true
        }
        let scanner = formatter.getLenientScanner()
        return scanner.isSome() && scanner.allIgnorable(str)
    }

    public func setDecimalFormatSymbols(newSymbols: DecimalFormatSymbols): Unit {
        if (sub1.isSome()) {
            sub1.setDecimalFormatSymbols(newSymbols)
        }
        if (sub2.isSome()) {
            sub2.setDecimalFormatSymbols(newSymbols)
        }
    }
}
