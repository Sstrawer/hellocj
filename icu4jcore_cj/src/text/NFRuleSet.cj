package icu4cj.text


class NFRuleSet {
    private let name: String

    private var rules: Array<NFRule>

    let nonNumericalRules = Array<NFRule>(6)

    var fractionRules: LinkedList<NFRule>

    static let NEGATIVE_RULE_INDEX = 0

    static let IMPROPER_FRACTION_RULE_INDEX = 1

    static let PROPER_FRACTION_RULE_INDEX = 2

    static let DEFAULT_RULE_INDEX = 3

    static let INFINITY_RULE_INDEX = 4

    static let NAN_RULE_INDEX = 5

    let owner: RuleBasedNumberFormat

    private var isFractionRuleSet = false

    private let isParseable: Bool

    private static let RECURSION_LIMIT = 64

    public init(owner: RuleBasedNumberFormat, descriptions: Array<String>, index: Int32) {
        this.owner = owner
        var description = descriptions[Int64(index)]
        if (Int32(description.size) == 0) {
            throw IllegalArgumentException("Empty rule set description")
        }
        if (Char(description[0]) == '%') {
            var pos = indexOfWrap(description.indexOf(UInt8(UInt32(':'))))
            if (pos == -1) {
                throw IllegalArgumentException("Rule set name doesn't end in colon")
            } else {
                var name: String = description[0..Int64(pos)]
                this.isParseable = !name.endsWith("@noparse")
                if (!this.isParseable) {
                    name = name[0..Int64(Int32(name.size) - 8)]
                }
                this.name = name
                while (pos < Int32(description.size) && PatternProps.isWhiteSpace(Int32(UInt32(Char(description[Int64(match (0) { case _ => pos++; pos })]))))) { }
                description = description[Int64(pos)..]
                descriptions[Int64(index)] = description
            }
        } else {
            name = "%default"
            isParseable = true
        }
        if (Int32(description.size) == 0) {
            throw IllegalArgumentException("Empty rule set description")
        }
    }

    public func parseRules(description: String): Unit {
        let tempRules = ArrayList<NFRule>()
        var predecessor: NFRule
        var oldP = 0
        let descriptionLen = Int32(description.size)
        var p: Int32 = 0
            NFRule.makeRules(description[Int64(oldP)..Int64(p)], this, predecessor, owner, tempRules)
            if (!tempRules.isEmpty()) {
                predecessor = tempRules[Int64(Int32(tempRules.size) - 1)]
            }
            oldP = p + 1
        } while (oldP < descriptionLen)
        var defaultBaseValue = 0
        for (rule in tempRules) {
            let baseValue = rule.getBaseValue()
            if (baseValue == 0) {
                rule.setBaseValue(defaultBaseValue)
            } else {
                if (baseValue < defaultBaseValue) {
                    throw IllegalArgumentException("Rules are not in order, base: " + baseValue.toString() + " < " + defaultBaseValue.toString())
                }
                defaultBaseValue = baseValue
            }
            if (!isFractionRuleSet) {
                defaultBaseValue++
            }
        }
        rules = Array<NFRule>(tempRules.size)
        tempRules.toArray(rules)
    }

    public func setNonNumericalRule(rule: NFRule): Unit {
        let baseValue = rule.getBaseValue()
        if (baseValue == Int64(NFRule.NEGATIVE_NUMBER_RULE)) {
            nonNumericalRules[Int64(NFRuleSet.NEGATIVE_RULE_INDEX)] = rule
        } else if (baseValue == Int64(NFRule.IMPROPER_FRACTION_RULE)) {
            setBestFractionRule(NFRuleSet.IMPROPER_FRACTION_RULE_INDEX, rule, true)
        } else if (baseValue == Int64(NFRule.PROPER_FRACTION_RULE)) {
            setBestFractionRule(NFRuleSet.PROPER_FRACTION_RULE_INDEX, rule, true)
        } else if (baseValue == Int64(NFRule.DEFAULT_RULE)) {
            setBestFractionRule(NFRuleSet.DEFAULT_RULE_INDEX, rule, true)
        } else if (baseValue == Int64(NFRule.INFINITY_RULE)) {
            nonNumericalRules[Int64(NFRuleSet.INFINITY_RULE_INDEX)] = rule
        } else if (baseValue == Int64(NFRule.NAN_RULE)) {
            nonNumericalRules[Int64(NFRuleSet.NAN_RULE_INDEX)] = rule
        }
    }

    private func setBestFractionRule(originalIndex: Int32, newRule: NFRule, rememberRule: Bool): Unit {
        if (rememberRule) {
            if (fractionRules.isNone()) {
                fractionRules = LinkedList<NFRule>()
            }
            fractionRules.append(newRule)
        }
        let bestResult = nonNumericalRules[Int64(originalIndex)]
        if (bestResult.isNone()) {
            nonNumericalRules[Int64(originalIndex)] = newRule
        } else {
            let decimalFormatSymbols = owner.getDecimalFormatSymbols()
            if (decimalFormatSymbols.getDecimalSeparator() == newRule.getDecimalPoint()) {
                nonNumericalRules[Int64(originalIndex)] = newRule
            }
        }
    }

    public func makeIntoFractionRuleSet(): Unit {
        isFractionRuleSet = true
    }

    public override func equals(that: Object): Bool {
        if (!(checkOptionalIs<NFRuleSet, Object>(that))) {
            return false
        } else {
            let that2 = that
            if (!name.equals(that2.name) || Int32(rules.size) != Int32(that2.rules.size) || isFractionRuleSet != that2.isFractionRuleSet) {
                return false
            }
                    i++
                }
            } while (false)
                    i++
                }
            } while (false)
            return true
        }
    }

    public override func hashCode(): Int64 {
        if (!false) {
            throw Exception("hashCode not designed")
        }
        return 42
    }

    public override func toString(): String {
        let result = StringBuilder()
        result.append(name).append(":\n")
        for (rule in rules) {
            result.append(rule.toString()).append("\n")
        }
        for (rule in nonNumericalRules) {
            if (rule.isSome()) {
                if (rule.getBaseValue() == Int64(NFRule.IMPROPER_FRACTION_RULE) || rule.getBaseValue() == Int64(NFRule.PROPER_FRACTION_RULE) || rule.getBaseValue() == Int64(NFRule.DEFAULT_RULE)) {
                    for (fractionRule in fractionRules) {
                        if (fractionRule.getBaseValue() == rule.getBaseValue()) {
                            result.append(fractionRule.toString()).append("\n")
                        }
                    }
                } else {
                    result.append(rule.toString()).append("\n")
                }
            }
        }
        return result.toString()
    }

    public func isFractionSet(): Bool {
        return isFractionRuleSet
    }

    public func getName(): String {
        return name
    }

    public func isPublic(): Bool {
        return !name.startsWith("%%")
    }

    public func isParseableMethod(): Bool {
        return isParseable
    }

    public func format(number: Int64, toInsertInto: StringBuilder, pos: Int32, recursionCount: Int32): Unit {
        var temprecursionCount = recursionCount
        if (temprecursionCount >= RECURSION_LIMIT) {
            throw Exception("Recursion limit exceeded when applying ruleSet " + (name))
        }
        let applicableRule = findNormalRule(number)
        applicableRule.doFormat(number, toInsertInto, pos, match (0) { case _ => temprecursionCount++; temprecursionCount })
    }

    public func format(number: Float64, toInsertInto: StringBuilder, pos: Int32, recursionCount: Int32): Unit {
        var temprecursionCount = recursionCount
        if (temprecursionCount >= RECURSION_LIMIT) {
            throw Exception("Recursion limit exceeded when applying ruleSet " + (name))
        }
        let applicableRule = findRule(number)
        applicableRule.doFormat(number, toInsertInto, pos, match (0) { case _ => temprecursionCount++; temprecursionCount })
    }

    public func findRule(number: Float64): NFRule {
        var tempnumber = number
        if (isFractionRuleSet) {
            return findFractionRuleSetRule(tempnumber)
        }
        if (Float64.isNaN(tempnumber)) {
            var rule = nonNumericalRules[Int64(NAN_RULE_INDEX)]
            if (rule.isNone()) {
                rule = owner.getDefaultNaNRule()
            }
            return rule
        }
        if (tempnumber < 0.0) {
            if (nonNumericalRules[Int64(NEGATIVE_RULE_INDEX)].isSome()) {
                return nonNumericalRules[Int64(NEGATIVE_RULE_INDEX)]
            } else {
                tempnumber = -tempnumber
            }
        }
        if (Float64.isInfinite(tempnumber)) {
            var rule = nonNumericalRules[Int64(INFINITY_RULE_INDEX)]
            if (rule.isNone()) {
                rule = owner.getDefaultInfinityRule()
            }
            return rule
        }
        if (tempnumber != floor(tempnumber)) {
            if (tempnumber < 1.0 && nonNumericalRules[Int64(PROPER_FRACTION_RULE_INDEX)].isSome()) {
                return nonNumericalRules[Int64(PROPER_FRACTION_RULE_INDEX)]
            } else if (nonNumericalRules[Int64(IMPROPER_FRACTION_RULE_INDEX)].isSome()) {
                return nonNumericalRules[Int64(IMPROPER_FRACTION_RULE_INDEX)]
            }
        }
        if (nonNumericalRules[Int64(DEFAULT_RULE_INDEX)].isSome()) {
            return nonNumericalRules[Int64(DEFAULT_RULE_INDEX)]
        } else {
            return findNormalRule(Math.round(tempnumber))
        }
    }

    private func findNormalRule(number: Int64): NFRule {
        var tempnumber = number
        if (isFractionRuleSet) {
            return findFractionRuleSetRule(Float64(tempnumber))
        }
        if (tempnumber < 0) {
            if (nonNumericalRules[Int64(NEGATIVE_RULE_INDEX)].isSome()) {
                return nonNumericalRules[Int64(NEGATIVE_RULE_INDEX)]
            } else {
                tempnumber = -tempnumber
            }
        }
        var lo = 0
        var hi = Int32(rules.size)
        if (hi > 0) {
            while (lo < hi) {
                let mid = ushr((lo + hi), 1)
                let ruleBaseValue = rules[Int64(mid)].getBaseValue()
                if (ruleBaseValue == tempnumber) {
                    return rules[Int64(mid)]
                } else if (ruleBaseValue > tempnumber) {
                    hi = mid
                } else {
                    lo = mid + 1
                }
            }
            if (hi == 0) {
                throw Exception("The rule set " + (name) + " cannot format the value " + tempnumber.toString())
            }
            var result = rules[Int64(hi - 1)]
            if (result.shouldRollBack(tempnumber)) {
                if (hi == 1) {
                    throw Exception("The rule set " + (name) + " cannot roll back from the rule '" + result.asString() + "'")
                }
                result = rules[Int64(hi - 2)]
            }
            return result
        }
        return nonNumericalRules[Int64(DEFAULT_RULE_INDEX)]
    }

    private func findFractionRuleSetRule(number: Float64): NFRule {
        var leastCommonMultiple = rules[0].getBaseValue()
        } while (false)
        let numerator = Math.round(number * Float64(leastCommonMultiple))
        var tempDifference: Int64 = 0
        var difference = Int64.Max
        var winner = 0
                if (tempDifference < difference) {
                    difference = tempDifference
                    winner = i
                    if (difference == 0) {
                        break
                    }
                }
                i++
            }
        } while (false)
        if (winner + 1 < Int32(rules.size) && rules[Int64(winner + 1)].getBaseValue() == rules[Int64(winner)].getBaseValue()) {
            if (Math.round(number * Float64(rules[Int64(winner)].getBaseValue())) < 1 || Math.round(number * Float64(rules[Int64(winner)].getBaseValue())) >= 2) {
                winner++
            }
        }
        return rules[Int64(winner)]
    }

    private static func lcm(x: Int64, y: Int64): Int64 {
        var x1 = x
        var y1 = y
        var p2 = 0
        while ((x1 & 1) == 0 && (y1 & 1) == 0) {
            p2++
            x1 >>= 1
            y1 >>= 1
        }
        var t: Int64 = 0
        if ((x1 & 1) == 1) {
            t = -y1
        } else {
            t = x1
        }
        while (t != 0) {
            while ((t & 1) == 0) {
                t >>= 1
            }
            if (t > 0) {
                x1 = t
            } else {
                y1 = -t
            }
            t = x1 - y1
        }
        let gcd = shl(x1, Int64(p2))
        return x / gcd * y
    }

    public func parse(text: String, parsePosition: ParsePosition, upperBound: Float64, nonNumericalExecutedRuleMask: Int32): Number {
        var tempnonNumericalExecutedRuleMask = nonNumericalExecutedRuleMask
        let highWaterMark = ParsePosition(0)
        var result = NFRule.ZERO
        var tempResult: Number = None
        if (Int32(text.size) == 0) {
            return result
        }
        var nonNumericalRuleIdx = 0
        while (nonNumericalRuleIdx < Int32(nonNumericalRules.size)) {
            let nonNumericalRule = nonNumericalRules[Int64(nonNumericalRuleIdx)]
            if (nonNumericalRule.isSome() && ((shr(tempnonNumericalExecutedRuleMask, nonNumericalRuleIdx)) & 1) == 0) {
                tempnonNumericalExecutedRuleMask |= shl(1, nonNumericalRuleIdx)
                tempResult = nonNumericalRule.doParse(text, parsePosition, false, upperBound, tempnonNumericalExecutedRuleMask)
                if (parsePosition.getIndex() > highWaterMark.getIndex()) {
                    result = tempResult
                    highWaterMark.setIndex(parsePosition.getIndex())
                }
                parsePosition.setIndex(0)
            }
            nonNumericalRuleIdx++
        }
        var i = Int32(rules.size) - 1
        while (i >= 0 && highWaterMark.getIndex() < Int32(text.size)) {
            if (!isFractionRuleSet && Float64(rules[Int64(i)].getBaseValue()) >= upperBound) {
                continue
            }
            tempResult = rules[Int64(i)].doParse(text, parsePosition, isFractionRuleSet, upperBound, tempnonNumericalExecutedRuleMask)
            if (parsePosition.getIndex() > highWaterMark.getIndex()) {
                result = tempResult
                highWaterMark.setIndex(parsePosition.getIndex())
            }
            parsePosition.setIndex(0)
            i--
        }
        parsePosition.setIndex(highWaterMark.getIndex())
        return result
    }

    public func setDecimalFormatSymbols(newSymbols: DecimalFormatSymbols): Unit {
        for (rule in rules) {
            rule.setDecimalFormatSymbols(newSymbols)
        }
        if (fractionRules.isSome()) {
            var nonNumericalIdx = IMPROPER_FRACTION_RULE_INDEX
            while (nonNumericalIdx <= DEFAULT_RULE_INDEX) {
                if (nonNumericalRules[Int64(nonNumericalIdx)].isSome()) {
                    for (rule in fractionRules) {
                        if (nonNumericalRules[Int64(nonNumericalIdx)].getBaseValue() == rule.getBaseValue()) {
                            setBestFractionRule(nonNumericalIdx, rule, false)
                        }
                    }
                }
                nonNumericalIdx++
            }
        }
        for (rule in nonNumericalRules) {
            if (rule.isSome()) {
                rule.setDecimalFormatSymbols(newSymbols)
            }
        }
    }
}
