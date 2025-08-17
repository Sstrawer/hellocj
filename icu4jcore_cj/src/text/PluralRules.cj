package icu4cj.text


public class PluralRules <: Serializable {
    static let ALLOWED_ID = UnicodeSet("[a-z]").freeze()

    static let CATEGORY_SEPARATOR = ";  "

    private static let serialVersionUID = 1

    private let rules: PluralRules_RuleList

     private let keywords: Set<String>

     private let standardPluralRanges: StandardPluralRanges

    public static let KEYWORD_ZERO = "zero"

    public static let KEYWORD_ONE = "one"

    public static let KEYWORD_TWO = "two"

    public static let KEYWORD_FEW = "few"

    public static let KEYWORD_MANY = "many"

    public static let KEYWORD_OTHER = "other"

    public static let NO_UNIQUE_VALUE = -0.00123456777

    
    public static let NO_UNIQUE_VALUE_DECIMAL_QUANTITY: DecimalQuantity = DecimalQuantity_DualStorageBCD(-0.00123456777)

    private static let NO_CONSTRAINT: PluralRules_Constraint = PluralRules_1()

    private static let DEFAULT_RULE = PluralRules_Rule("other", NO_CONSTRAINT, None, None)

    public static func parseDescription(description: String): PluralRules {
        return newInternal(description, None)
    }

    public static func createRules(description: String): PluralRules {
        try {
            return parseDescription(description)
        } catch (e: Exception) {
            return None
        }
    }

    
    public static func newInternal(description: String, ranges: StandardPluralRanges): PluralRules {
        var tempdescription = description
        tempdescription = tempdescription.trimAscii()
        return if (Int32(tempdescription.size) == 0) { DEFAULT } else { PluralRules(parseRuleChain(tempdescription), ranges) }
    }

    public static let DEFAULT = PluralRules(PluralRules_RuleList().addRule(DEFAULT_RULE), StandardPluralRanges.DEFAULT)

    private static func parseConstraint(description: String): PluralRules_Constraint {
        var result: PluralRules_Constraint
        let or_together = OR_SEPARATED.split(description, 0)
        var i = 0
        while (i < Int32(or_together.size)) {
            var andConstraint: PluralRules_Constraint
            let and_together = AND_SEPARATED.split(or_together[Int64(i)], 0)
            var j = 0
            while (j < Int32(and_together.size)) {
                var newConstraint: PluralRules_Constraint = NO_CONSTRAINT
                let condition = and_together[Int64(j)].trimAscii()
                let tokens = PluralRules_SimpleTokenizer.split(condition)
                var mod = 0
                var inRange = true
                var integersOnly = true
                var lowBound = Float64(Int64.Max)
                var highBound = Float64(Int64.Min)
                var vals: Array<Int64>
                var x = 0
                var t = tokens[Int64(match (0) { case _ => x++; x - 1 })]
                var hackForCompatibility = false
                let operand: PluralRules_Operand
                try {
                    operand = PluralRules_FixedDecimal.getOperand(t)
                } catch (e: Exception) {
                    throw unexpected(t, condition)
                }
                if (x < Int32(tokens.size)) {
                    t = tokens[Int64(match (0) { case _ => x++; x - 1 })]
                    if ("mod".equals(t) || "%".equals(t)) {
                        mod = parse<Int32>(tokens[Int64(match (0) { case _ => x++; x - 1 })])
                        t = nextToken(tokens, match (0) { case _ => x++; x - 1 }, condition)
                    }
                    if ("not".equals(t)) {
                        inRange = !inRange
                        t = nextToken(tokens, match (0) { case _ => x++; x - 1 }, condition)
                        if ("=".equals(t)) {
                            throw unexpected(t, condition)
                        }
                    } else if ("!".equals(t)) {
                        inRange = !inRange
                        t = nextToken(tokens, match (0) { case _ => x++; x - 1 }, condition)
                        if (!"=".equals(t)) {
                            throw unexpected(t, condition)
                        }
                    }
                    if ("is".equals(t) || "in".equals(t) || "=".equals(t)) {
                        hackForCompatibility = "is".equals(t)
                        if (hackForCompatibility && !inRange) {
                            throw unexpected(t, condition)
                        }
                        t = nextToken(tokens, match (0) { case _ => x++; x - 1 }, condition)
                    } else if ("within".equals(t)) {
                        integersOnly = false
                        t = nextToken(tokens, match (0) { case _ => x++; x - 1 }, condition)
                    } else {
                        throw unexpected(t, condition)
                    }
                    if ("not".equals(t)) {
                        if (!hackForCompatibility && !inRange) {
                            throw unexpected(t, condition)
                        }
                        inRange = !inRange
                        t = nextToken(tokens, match (0) { case _ => x++; x - 1 }, condition)
                    }
                    let valueList = ArrayList<Int64>()
                    while (true) {
                        let low = parse<Int64>(t)
                        var high = low
                        if (x < Int32(tokens.size)) {
                            t = nextToken(tokens, match (0) { case _ => x++; x - 1 }, condition)
                            if (t == ".") {
                                t = nextToken(tokens, match (0) { case _ => x++; x - 1 }, condition)
                                if (!(t == ".")) {
                                    throw unexpected(t, condition)
                                }
                                t = nextToken(tokens, match (0) { case _ => x++; x - 1 }, condition)
                                high = parse<Int64>(t)
                                if (x < Int32(tokens.size)) {
                                    t = nextToken(tokens, match (0) { case _ => x++; x - 1 }, condition)
                                    if (!(t == ",")) {
                                        throw unexpected(t, condition)
                                    }
                                }
                            } else if (!(t == ",")) {
                                throw unexpected(t, condition)
                            }
                        }
                        if (low > high) {
                            throw unexpected(low.toString() + "~" + high.toString(), condition)
                        } else if (mod != 0 && high >= Int64(mod)) {
                            throw unexpected(high.toString() + ">mod=" + mod.toString(), condition)
                        }
                        valueList.append(low)
                        valueList.append(high)
                        lowBound = Math.min(lowBound, Float64(low))
                        highBound = Math.max(highBound, Float64(high))
                        if (x >= Int32(tokens.size)) {
                            break
                        }
                        t = nextToken(tokens, match (0) { case _ => x++; x - 1 }, condition)
                    }
                    if (t == ",") {
                        throw unexpected(t, condition)
                    }
                    if (Int32(valueList.size) == 2) {
                        vals = None
                    } else {
                        vals = Array<Int64>(valueList.size) { _ => 0 }
                        var k = 0
                        while (k < Int32(vals.size)) {
                            vals[Int64(k)] = valueList[Int64(k)]
                            k++
                        }
                    }
                    if (lowBound != highBound && hackForCompatibility && !inRange) {
                        throw unexpected("is not <range>", condition)
                    }
                    newConstraint = PluralRules_RangeConstraint(mod, inRange, operand, integersOnly, lowBound, highBound, vals)
                }
                if (andConstraint.isNone()) {
                    andConstraint = newConstraint
                } else {
                    andConstraint = PluralRules_AndConstraint(andConstraint, newConstraint)
                }
                j++
            }
            if (result.isNone()) {
                result = andConstraint
            } else {
                result = PluralRules_OrConstraint(result, andConstraint)
            }
            i++
        }
        return result
    }

    static let AT_SEPARATED = Pattern.compile("\\s*\\Q\\E@\\s*")

    static let OR_SEPARATED = Pattern.compile("\\s*or\\s*")

    static let AND_SEPARATED = Pattern.compile("\\s*and\\s*")

    static let COMMA_SEPARATED = Pattern.compile("\\s*,\\s*")

    static let DOTDOT_SEPARATED = Pattern.compile("\\s*\\Q..\\E\\s*")

    static let TILDE_SEPARATED = Pattern.compile("\\s*~\\s*")

    static let SEMI_SEPARATED = Pattern.compile("\\s*;\\s*")

    private static func unexpected(token: String, context: String): ParseException {
        return ParseException("unexpected token '" + (token) + "' in '" + (context) + "'", -1)
    }

    private static func nextToken(tokens: Array<String>, x: Int32, context: String): String {
        if (x < Int32(tokens.size)) {
            return tokens[Int64(x)]
        }
        throw ParseException("missing token at end of '" + (context) + "'", -1)
    }

    static func parseRule(description: String): PluralRules_Rule {
        var tempdescription = description
        if (Int32(tempdescription.size) == 0) {
            return DEFAULT_RULE
        }
        tempdescription = tempdescription.toLowerCase(Locale.ENGLISH)
        let x = indexOfWrap(tempdescription.indexOf(UInt8(UInt32(':'))))
        if (x == -1) {
            throw ParseException("missing ':' in rule description '" + (tempdescription) + "'", 0)
        }
        let keyword = tempdescription[0..Int64(x)].trimAscii()
        if (!isValidKeyword(keyword)) {
            throw ParseException("keyword '" + keyword + " is not valid", 0)
        }
        tempdescription = tempdescription[Int64(x + 1)..].trimAscii()
        let constraintOrSamples = AT_SEPARATED.split(tempdescription, 0)
        let sampleFailure = false
        var integerSamples: PluralRules_DecimalQuantitySamples
        var decimalSamples: PluralRules_DecimalQuantitySamples
        match (Int32(constraintOrSamples.size)) {
            case 1 => ()
            case 2 =>
                integerSamples = PluralRules_DecimalQuantitySamples.parse(constraintOrSamples[1])
                if (refEq(integerSamples.sampleType, PluralRules_SampleType.DECIMAL)) {
                    decimalSamples = integerSamples
                    integerSamples = None
                }
            case 3 =>
                integerSamples = PluralRules_DecimalQuantitySamples.parse(constraintOrSamples[1])
                decimalSamples = PluralRules_DecimalQuantitySamples.parse(constraintOrSamples[2])
                if (!refEq(integerSamples.sampleType, PluralRules_SampleType.INTEGER) || !refEq(decimalSamples.sampleType, PluralRules_SampleType.DECIMAL)) {
                    throw IllegalArgumentException("Must have @integer then @decimal in " + (tempdescription))
                }
            case _ => throw IllegalArgumentException("Too many samples in " + (tempdescription))
        }
        if (sampleFailure) {
            throw IllegalArgumentException("Ill-formed samples\u{2014}'@' characters.")
        }
        let isOther = keyword == "other"
        if (isOther != (Int32(constraintOrSamples[0].size) == 0)) {
            throw IllegalArgumentException("The keyword 'other' must have no constraints, just samples.")
        }
        let constraint: PluralRules_Constraint
        if (isOther) {
            constraint = NO_CONSTRAINT
        } else {
            constraint = parseConstraint(constraintOrSamples[0])
        }
        return PluralRules_Rule(keyword, constraint, integerSamples, decimalSamples)
    }

    private static func parseRuleChain(description: String): PluralRules_RuleList {
        var tempdescription = description
        let result = PluralRules_RuleList()
        if (tempdescription.endsWith(";")) {
            tempdescription = tempdescription[0..Int64(Int32(tempdescription.size) - 1)]
        }
        let rules = SEMI_SEPARATED.split(tempdescription, 0)
        var i = 0
        while (i < Int32(rules.size)) {
            let rule = parseRule(rules[Int64(i)].trimAscii())
            result.hasExplicitBoundingInfo |= rule.integerSamples.isSome() || rule.decimalSamples.isSome()
            result.addRule(rule)
            i++
        }
        return result.finish()
    }

    static func addRange(result: StringBuilder, lb: Float64, ub: Float64, addSeparator: Bool): Unit {
        if (addSeparator) {
            result.append(",")
        }
        if (lb == ub) {
            result.append(format(lb))
        } else {
            result.append((format(lb)) + ".." + (format(ub)))
        }
    }

    private static func format(lb: Float64): String {
        let lbi = Int64(lb)
        return if (lb == Float64(lbi)) { lbi.toString() } else { lb.toString() }
    }

    private func addConditional(toAddTo: Set<PluralRules_IFixedDecimal>, others: Set<PluralRules_IFixedDecimal>, trial: Float64): Bool {
        let added: Bool
        let toAdd: PluralRules_IFixedDecimal = PluralRules_FixedDecimal(trial)
        if (!toAddTo.contains(toAdd) && !others.contains(toAdd)) {
            others.put(toAdd)
            added = true
        } else {
            added = false
        }
        return added
    }

    public static func forLocale(locale: ULocale): PluralRules {
        return PluralRules_Factory.getDefaultFactory().forLocale(locale, PluralRules_PluralType.CARDINAL)
    }

    public static func forLocale(locale: Locale): PluralRules {
        return forLocale(ULocale.forLocale(locale))
    }

    public static func forLocale(locale: ULocale, Type: PluralRules_PluralType): PluralRules {
        return PluralRules_Factory.getDefaultFactory().forLocale(locale, Type)
    }

    public static func forLocale(locale: Locale, Type: PluralRules_PluralType): PluralRules {
        return forLocale(ULocale.forLocale(locale), Type)
    }

    private static func isValidKeyword(token: String): Bool {
        return ALLOWED_ID.containsAll(token)
    }

    private init(rules: PluralRules_RuleList, standardPluralRanges: StandardPluralRanges) {
        this.rules = rules
        this.keywords = Collections.unmodifiableSet(rules.getKeywords())
        this.standardPluralRanges = standardPluralRanges
    }

    public override func hashCode(): Int64 {
        return rules.toString()
    }

    public func select(number: Float64): String {
        return rules.select(PluralRules_FixedDecimal(number))
    }

    public func select(number: FormattedNumber): String {
        return rules.select(number.getFixedDecimal())
    }

    public func select(range: FormattedNumberRange): String {
        if (standardPluralRanges.isNone()) {
            throw UnsupportedOperationException("Plural ranges are unavailable on this instance")
        }
        let form1 = StandardPlural.fromString(select(range.getFirstFixedDecimal()))
        let form2 = StandardPlural.fromString(select(range.getSecondFixedDecimal()))
        let result = standardPluralRanges.resolve(form1, form2)
        return result.getKeyword()
    }

    
    public func select(number: Float64, countVisibleFractionDigits: Int32, fractionaldigits: Int64): String {
        return rules.select(PluralRules_FixedDecimal(number, countVisibleFractionDigits, fractionaldigits))
    }

    
    public func select(number: PluralRules_IFixedDecimal): String {
        return rules.select(number)
    }

    
    public func matches(sample: PluralRules_FixedDecimal, keyword: String): Bool {
        return rules.select(sample, keyword)
    }

    public func getKeywords(): Set<String> {
        return keywords
    }

    public func getUniqueKeywordValue(keyword: String): Float64 {
        let uniqValDq = getUniqueKeywordDecimalQuantityValue(keyword)
        if (refEq(uniqValDq, NO_UNIQUE_VALUE_DECIMAL_QUANTITY)) {
            return NO_UNIQUE_VALUE
        } else {
            return uniqValDq.toDouble()
        }
    }

    
    public func getUniqueKeywordDecimalQuantityValue(keyword: String): DecimalQuantity {
        let values = getAllKeywordDecimalQuantityValues(keyword)
        if (values.isSome() && Int32(values.size) == 1) {
            return values.iterator().next()
        }
        return NO_UNIQUE_VALUE_DECIMAL_QUANTITY
    }

    public func getAllKeywordValues(keyword: String): Collection<Float64> {
        let samples = getAllKeywordDecimalQuantityValues(keyword)
        if (samples.isNone()) {
            return None
        } else {
            let result = LinkedHashSet()
            for (dq in samples) {
                result.add(dq.toDouble())
            }
            return result
        }
    }

    
    public func getAllKeywordDecimalQuantityValues(keyword: String): Collection<DecimalQuantity> {
        return getAllKeywordValues(keyword, PluralRules_SampleType.INTEGER)
    }

    
    public func getAllKeywordValues(keyword: String, Type: PluralRules_SampleType): Collection<DecimalQuantity> {
        if (!isLimited(keyword, Type)) {
            return None
        }
        return getDecimalQuantitySamples(keyword, Type)
    }

    public func getSamples(keyword: String): Collection<Float64> {
        return getSamples(keyword, PluralRules_SampleType.INTEGER)
    }

    
    public func getDecimalQuantitySamples(keyword: String): Collection<DecimalQuantity> {
        return getDecimalQuantitySamples(keyword, PluralRules_SampleType.INTEGER)
    }

    
    public func getSamples(keyword: String, sampleType: PluralRules_SampleType): Collection<Float64> {
        let samples = getDecimalQuantitySamples(keyword, sampleType)
        if (samples.isNone()) {
            return None
        } else {
            let result = LinkedHashSet()
            for (dq in samples) {
                result.add(dq.toDouble())
            }
            return result
        }
    }

    
    public func getDecimalQuantitySamples(keyword: String, sampleType: PluralRules_SampleType): Collection<DecimalQuantity> {
        if (!keywords.contains(keyword)) {
            return None
        }
        let result = LinkedHashSet()
        if (rules.hasExplicitBoundingInfo) {
            let samples = rules.getDecimalSamples(keyword, sampleType)
            return if (samples.isNone()) { Collections.unmodifiableSet(result as Set<T>) } else { Collections.unmodifiableCollection(samples.addDecimalQuantitySamples(result as Collection<DecimalQuantity>)) }
        }
        let maxCount = if (isLimited(keyword, sampleType)) { Int32.Max } else { 20 }
        match (sampleType) {
            case PluralRules_SampleType.INTEGER =>
                        i++
                    }
                } while (false)
                addSample(keyword, DecimalQuantity_DualStorageBCD(1000000), maxCount, result)
            case PluralRules_SampleType.DECIMAL =>
                        i++
                    }
                } while (false)
                addSample(keyword, DecimalQuantity_DualStorageBCD.fromExponentString("1000000.0"), maxCount, result)
            case _ => ()
        }
        return if (result.size() == 0) { None } else { Collections.unmodifiableSet(result as Set<T>) }
    }

    private func addSample(keyword: String, sample: DecimalQuantity, maxCount: Int32, result: Set<DecimalQuantity>): Bool {
        var tempmaxCount = maxCount
        let selectedKeyword = select(sample)
        if (selectedKeyword.equals(keyword)) {
            result.put(sample)
            if (match (0) { case _ => tempmaxCount--; tempmaxCount } < 0) {
                return false
            }
        }
        return true
    }

    
    public func getDecimalSamples(keyword: String, sampleType: PluralRules_SampleType): PluralRules_DecimalQuantitySamples {
        return rules.getDecimalSamples(keyword, sampleType)
    }

    public static func getAvailableULocales(): Array<ULocale> {
        return PluralRules_Factory.getDefaultFactory().getAvailableULocales()
    }

    public static func getFunctionalEquivalent(locale: ULocale, isAvailable: Array<Bool>): ULocale {
        return PluralRules_Factory.getDefaultFactory().getFunctionalEquivalent(locale, isAvailable)
    }

    public override func toString(): String {
        return rules.toString()
    }

    public override func equals(rhs: Object): Bool {
        return checkOptionalIs<PluralRules, Object>(rhs) && equals(rhs)
    }

    public func equals(rhs: PluralRules): Bool {
        return rhs.isSome() && toString().append(rhs.toString())
    }

    public func getKeywordStatus(keyword: String, offset: Int32, explicits: Set<DecimalQuantity>, uniqueValue: Output<DecimalQuantity>): PluralRules_KeywordStatus {
        return getKeywordStatus(keyword, offset, explicits, uniqueValue, PluralRules_SampleType.INTEGER)
    }

    
    public func getKeywordStatus(keyword: String, offset: Int32, explicits: Set<DecimalQuantity>, uniqueValue: Output<DecimalQuantity>, sampleType: PluralRules_SampleType): PluralRules_KeywordStatus {
        var tempexplicits = explicits
        if (uniqueValue.isSome()) {
            uniqueValue.value = None
        }
        if (!keywords.contains(keyword)) {
            return PluralRules_KeywordStatus.INVALID
        }
        if (!isLimited(keyword, sampleType)) {
            return PluralRules_KeywordStatus.UNBOUNDED
        }
        let values = getDecimalQuantitySamples(keyword, sampleType)
        let originalSize = Int32(values.size)
        if (tempexplicits.isNone()) {
            tempexplicits = Collections.emptySet<<--> -->()
        }
        if (originalSize > tempexplicits.size()) {
            if (originalSize == 1) {
                if (uniqueValue.isSome()) {
                    uniqueValue.value = values.iterator().next()
                }
                return PluralRules_KeywordStatus.UNIQUE
            }
            return PluralRules_KeywordStatus.BOUNDED
        }
        let subtractedSet = ArrayList<DecimalQuantity>(values)
        for (explicit in tempexplicits) {
            let explicitBd = explicit.toBigDecimal()
            let valToRemoveBd = explicitBd.subtract(Decimal(offset))
            let valToRemove = DecimalQuantity_DualStorageBCD(valToRemoveBd)
            subtractedSet.removeObject(valToRemove)
        }
        if (Int32(subtractedSet.size) == 0) {
            return PluralRules_KeywordStatus.SUPPRESSED
        }
        if (uniqueValue.isSome() && Int32(subtractedSet.size) == 1) {
            uniqueValue.value = subtractedSet.iterator().next()
        }
        return if (originalSize == 1) { PluralRules_KeywordStatus.UNIQUE } else { PluralRules_KeywordStatus.BOUNDED }
    }

    
    public func getRules(keyword: String): String {
        return rules.getRules(keyword)
    }

    private func writeObject(out: ObjectOutputStream): Unit {
        throw NotSerializableException()
    }

    private func readObject(input: ObjectInputStream): Unit {
        throw NotSerializableException()
    }

    private func writeReplace(): Object {
        return PluralRulesSerialProxy(toString())
    }

    
    public func compareTo(other: PluralRules): Int32 {
        return toString().compare(other.toString()).value()
    }

    public func isLimited(keyword: String): Bool {
        return Bool.valueOf(rules.isLimited(keyword, PluralRules_SampleType.INTEGER))
    }

    
    public func isLimited(keyword: String, sampleType: PluralRules_SampleType): Bool {
        return rules.isLimited(keyword, sampleType)
    }

    
    public func computeLimited(keyword: String, sampleType: PluralRules_SampleType): Bool {
        return rules.computeLimited(keyword, sampleType)
    }
}



public abstract class PluralRules_Factory {
    

    
    public func forLocale(locale: ULocale, Type: PluralRules_PluralType): PluralRules

    
    public func forLocale(locale: ULocale): PluralRules {
        return forLocale(locale, PluralRules_PluralType.CARDINAL)
    }

    
    public func getAvailableULocales(): Array<ULocale>

    
    public func getFunctionalEquivalent(locale: ULocale, isAvailable: Array<Bool>): ULocale

    
    public static func getDefaultFactory(): PluralRulesLoader {
        return PluralRulesLoader.loader
    }

    
    public func hasOverride(locale: ULocale): Bool
}


public class PluralRules_PluralType <: Enum<PluralRules_PluralType> {
    public static let CARDINAL = PluralRules_PluralType("CARDINAL", 0)

    public static let ORDINAL = PluralRules_PluralType("ORDINAL", 1)

    private static func _values(): Array<PluralRules_PluralType> {
        return [PluralRules_PluralType.CARDINAL, PluralRules_PluralType.ORDINAL]
    }

    private static let _VALUES = PluralRules_PluralType._values()

    public static func values(): Array<PluralRules_PluralType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): PluralRules_PluralType {
        return (TypeInfo.of<PluralRules_PluralType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as PluralRules_PluralType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class PluralRules_1 <: PluralRules_Constraint {

    private static let serialVersionUID = 9163464945387899416

    public override func isFulfilled(n: PluralRules_IFixedDecimal): Bool {
        return true
    }

    public override func isLimited(sampleType: PluralRules_SampleType): Bool {
        return false
    }

    public override func toString(): String {
        return ""
    }
}



public class PluralRules_Operand <: Enum<PluralRules_Operand> {
    
    public static let n = PluralRules_Operand("n", 0)

    
    public static let i = PluralRules_Operand("i", 1)

    
    public static let f = PluralRules_Operand("f", 2)

    
    public static let t = PluralRules_Operand("t", 3)

    
    public static let v = PluralRules_Operand("v", 4)

    
    public static let w = PluralRules_Operand("w", 5)

    
    public static let e = PluralRules_Operand("e", 6)

    
    public static let c = PluralRules_Operand("c", 7)

    
    public static let j = PluralRules_Operand("j", 8)

    private static func _values(): Array<PluralRules_Operand> {
        return [PluralRules_Operand.n, PluralRules_Operand.i, PluralRules_Operand.f, PluralRules_Operand.t, PluralRules_Operand.v, PluralRules_Operand.w, PluralRules_Operand.e, PluralRules_Operand.c, PluralRules_Operand.j]
    }

    private static let _VALUES = PluralRules_Operand._values()

    public static func values(): Array<PluralRules_Operand> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): PluralRules_Operand {
        return (TypeInfo.of<PluralRules_Operand>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as PluralRules_Operand
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}



public interface PluralRules_IFixedDecimal {
    
    public func getPluralOperand(operand: PluralRules_Operand): Float64

    
    public func isNaN(): Bool

    
    public func isInfinite(): Bool

    
    public func isHasIntegerValue(): Bool
}


public class PluralRules_FixedDecimal <: Number & Comparable<PluralRules_FixedDecimal> & PluralRules_IFixedDecimal {
    private static let serialVersionUID = -4756200506571685661

    let source: Float64

    let visibleDecimalDigitCount: Int32

    let visibleDecimalDigitCountWithoutTrailingZeros: Int32

    let decimalDigits: Int64

    let decimalDigitsWithoutTrailingZeros: Int64

    let integerValue: Int64

    let hasIntegerValue: Bool

    let isNegative: Bool

    let exponent: Int32

    private let baseFactor: Int32

    
    public func getSource(): Float64 {
        return source
    }

    
    public func getVisibleDecimalDigitCount(): Int32 {
        return visibleDecimalDigitCount
    }

    
    public func getVisibleDecimalDigitCountWithoutTrailingZeros(): Int32 {
        return visibleDecimalDigitCountWithoutTrailingZeros
    }

    
    public func getDecimalDigits(): Int64 {
        return decimalDigits
    }

    
    public func getDecimalDigitsWithoutTrailingZeros(): Int64 {
        return decimalDigitsWithoutTrailingZeros
    }

    
    public func getIntegerValue(): Int64 {
        return integerValue
    }

    
    public override func isHasIntegerValue(): Bool {
        return hasIntegerValue
    }

    
    public func isNegativeMethod(): Bool {
        return isNegative
    }

    
    public func getBaseFactor(): Int32 {
        return baseFactor
    }

    static let MAX = 1.0E18

    
    public init(n: Float64, v: Int32, f: Int64, e: Int32, c: Int32) {
        Number()
        isNegative = n < 0.0
        source = if (isNegative) { -n } else { n }
        visibleDecimalDigitCount = v
        decimalDigits = f
        integerValue = if (n > Float64(MAX)) { MAX } else { Int64(source) }
        var initExpVal = e
        if (initExpVal == 0) {
            initExpVal = c
        }
        exponent = initExpVal
        hasIntegerValue = source == Float64(integerValue)
        if (f == 0) {
            decimalDigitsWithoutTrailingZeros = 0
            visibleDecimalDigitCountWithoutTrailingZeros = 0
        } else {
            var fdwtz = f
            var trimmedCount = v
            while ((fdwtz % 10) == 0) {
                fdwtz /= 10
                trimmedCount--
            }
            decimalDigitsWithoutTrailingZeros = fdwtz
            visibleDecimalDigitCountWithoutTrailingZeros = trimmedCount
        }
        baseFactor = Int32(Math.pow(10.0, Float64(v)))
    }

    
    public init(n: Float64, v: Int32, f: Int64, e: Int32) {
        this(n, v, f, e, e)
    }

    
    public init(n: Float64, v: Int32, f: Int64) {
        this(n, v, f, 0)
    }

    
    public static func createWithExponent(n: Float64, v: Int32, e: Int32): PluralRules_FixedDecimal {
        return PluralRules_FixedDecimal(n, v, Int64(getFractionalDigits(n, v)), e)
    }

    
    public init(n: Float64, v: Int32) {
        this(n, v, Int64(getFractionalDigits(n, v)))
    }

    private static func getFractionalDigits(n: Float64, v: Int32): Int32 {
        var tempn = n
        if (v == 0) {
            return 0
        } else {
            if (tempn < 0.0) {
                tempn = -tempn
            }
            let baseFactor = Int32(Math.pow(10.0, Float64(v)))
            let scaled = Math.round(tempn * Float64(baseFactor))
            return Int32(scaled % Int64(baseFactor))
        }
    }

    
    public init(n: Float64) {
        this(n, decimals(n))
    }

    
    public init(n: Int64) {
        this(Float64(n), 0)
    }

    private static let MAX_INTEGER_PART = 1000000000

    
    public static func decimals(n: Float64): Int32 {
        var tempn = n
        if (Float64.isInfinite(tempn) || Float64.isNaN(tempn)) {
            return 0
        }
        if (tempn < 0.0) {
            tempn = -tempn
        }
        if (tempn == floor(tempn)) {
            return 0
        }
        if (tempn < Float64(MAX_INTEGER_PART)) {
            let temp = Int64(tempn * 1000000.0) % 1000000
            var mask = 10
            var digits = 6
            while (digits > 0) {
                if ((temp % Int64(mask)) != 0) {
                    return digits
                }
                mask *= 10
                digits--
            }
            return 0
        } else {
            let buf = String.format(Locale.ENGLISH, "%1.15e", [tempn])
            let ePos = indexOfWrap(buf.lastIndexOf(UInt8(UInt32('e'))))
            var expNumPos = ePos + 1
            if (Char(buf[Int64(expNumPos)]) == '+') {
                expNumPos++
            }
            let exponentStr: String = buf[Int64(expNumPos)..]
            let exponent = parse<Int32>(exponentStr)
            var numFractionDigits = ePos - 2 - exponent
            if (numFractionDigits < 0) {
                return 0
            }
            var i = ePos - 1
            while (numFractionDigits > 0) {
                if (Char(buf[Int64(i)]) != '0') {
                    break
                }
                numFractionDigits--
                i--
            }
            return numFractionDigits
        }
    }

    
    private init(other: PluralRules_FixedDecimal) {
        Number()
        this.source = other.source
        this.visibleDecimalDigitCount = other.visibleDecimalDigitCount
        this.visibleDecimalDigitCountWithoutTrailingZeros = other.visibleDecimalDigitCountWithoutTrailingZeros
        this.decimalDigits = other.decimalDigits
        this.decimalDigitsWithoutTrailingZeros = other.decimalDigitsWithoutTrailingZeros
        this.integerValue = other.integerValue
        this.hasIntegerValue = other.hasIntegerValue
        this.isNegative = other.isNegative
        this.exponent = other.exponent
        this.baseFactor = other.baseFactor
    }

    
    public override func getPluralOperand(operand: PluralRules_Operand): Float64 {
        match (operand) {
            case PluralRules_Operand.n => return (if (exponent == 0) { source } else { source * Math.pow(10.0, Float64(exponent)) })
            case PluralRules_Operand.i => return Float64(intValue())
            case PluralRules_Operand.f => return Float64(decimalDigits)
            case PluralRules_Operand.t => return Float64(decimalDigitsWithoutTrailingZeros)
            case PluralRules_Operand.v => return Float64(visibleDecimalDigitCount)
            case PluralRules_Operand.w => return Float64(visibleDecimalDigitCountWithoutTrailingZeros)
            case PluralRules_Operand.e => return Float64(exponent)
            case PluralRules_Operand.c => return Float64(exponent)
            case _ => return doubleValue()
        }
    }

    
    public static func getOperand(t: String): PluralRules_Operand {
        return PluralRules_Operand.valueOf(t)
    }

    
    public override func compareTo(other: PluralRules_FixedDecimal): Int32 {
        if (exponent != other.exponent) {
            return if (doubleValue() < other.doubleValue()) { -1 } else { 1 }
        }
        if (integerValue != other.integerValue) {
            return if (integerValue < other.integerValue) { -1 } else { 1 }
        }
        if (source != other.source) {
            return if (source < other.source) { -1 } else { 1 }
        }
        if (visibleDecimalDigitCount != other.visibleDecimalDigitCount) {
            return if (visibleDecimalDigitCount < other.visibleDecimalDigitCount) { -1 } else { 1 }
        }
        let diff = decimalDigits - other.decimalDigits
        if (diff != 0) {
            return if (diff < 0) { -1 } else { 1 }
        }
        return 0
    }

    
    public override func equals(arg0: Object): Bool {
        if (arg0.isNone()) {
            return false
        }
        if (refEq(arg0, this)) {
            return true
        }
        if (!(checkOptionalIs<PluralRules_FixedDecimal, Object>(arg0))) {
            return false
        }
        let other = arg0
        return source == other.source && visibleDecimalDigitCount == other.visibleDecimalDigitCount && decimalDigits == other.decimalDigits && exponent == other.exponent
    }

    
    public override func hashCode(): Int64 {
        return Int64(Int32(decimalDigits + Int64(37 * (visibleDecimalDigitCount + Int32(37.0 * source)))))
    }

    
    public override func toString(): String {
        let baseString = String.format(Locale.ROOT, "%." + visibleDecimalDigitCount.toString() + "f", [source])
        if (exponent != 0) {
            return (baseString) + "e" + exponent.toString()
        } else {
            return baseString
        }
    }

    
    public func hasIntegerValueMethod(): Bool {
        return hasIntegerValue
    }

    
    public override func intValue(): Int32 {
        return Int32(longValue())
    }

    
    public override func longValue(): Int64 {
        if (exponent == 0) {
            return integerValue
        } else {
            return Int64(Math.pow(10.0, Float64(exponent)) * Float64(integerValue))
        }
    }

    
    public override func floatValue(): Float32 {
        return Float32(source * Math.pow(10.0, Float64(exponent)))
    }

    
    public override func doubleValue(): Float64 {
        return (if (isNegative) { -source } else { source }) * Math.pow(10.0, Float64(exponent))
    }

    private func writeObject(out: ObjectOutputStream): Unit {
        throw NotSerializableException()
    }

    private func readObject(input: ObjectInputStream): Unit {
        throw NotSerializableException()
    }

    
    public override func isNaN(): Bool {
        return Float64.isNaN(source)
    }

    
    public override func isInfinite(): Bool {
        return Float64.isInfinite(source)
    }
}



public class PluralRules_SampleType <: Enum<PluralRules_SampleType> {
    
    public static let INTEGER = PluralRules_SampleType("INTEGER", 0)

    
    public static let DECIMAL = PluralRules_SampleType("DECIMAL", 1)

    private static func _values(): Array<PluralRules_SampleType> {
        return [PluralRules_SampleType.INTEGER, PluralRules_SampleType.DECIMAL]
    }

    private static let _VALUES = PluralRules_SampleType._values()

    public static func values(): Array<PluralRules_SampleType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): PluralRules_SampleType {
        return (TypeInfo.of<PluralRules_SampleType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as PluralRules_SampleType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}



public class PluralRules_DecimalQuantitySamplesRange {
    
    public let start: DecimalQuantity

    
    public let end: DecimalQuantity

    
    public init(start: DecimalQuantity, end: DecimalQuantity) {
        if (start.getPluralOperand(PluralRules_Operand.v) != end.getPluralOperand(PluralRules_Operand.v)) {
            throw IllegalArgumentException("Ranges must have the same number of visible decimals: " + toString(start) + "~" + toString(end))
        }
        this.start = start
        this.end = end
    }

    
    public override func toString(): String {
        return (start.toExponentString()) + (if (refEq(end, start)) { "" } else { "~" + (end.toExponentString()) })
    }
}



public class PluralRules_DecimalQuantitySamples {
    
    public let sampleType: PluralRules_SampleType

    
    public let samples: Set<PluralRules_DecimalQuantitySamplesRange>

    
    public let bounded: Bool

    private init(sampleType: PluralRules_SampleType, samples: Set<PluralRules_DecimalQuantitySamplesRange>, bounded: Bool) {
        this.sampleType = sampleType
        this.samples = samples
        this.bounded = bounded
    }

    static func parse(source: String): PluralRules_DecimalQuantitySamples {
        var tempsource = source
        let sampleType2: PluralRules_SampleType
        var bounded2 = true
        var haveBound = false
        let samples2 = LinkedHashSet()
        if (tempsource.startsWith("integer")) {
            sampleType2 = PluralRules_SampleType.INTEGER
        } else if (tempsource.startsWith("decimal")) {
            sampleType2 = PluralRules_SampleType.DECIMAL
        } else {
            throw IllegalArgumentException("Samples must start with 'integer' or 'decimal'")
        }
        tempsource = tempsource[7..].trimAscii()
        for (range in PluralRules.COMMA_SEPARATED.split(tempsource, 0)) {
            if (range == "\u{2026}" || range == "...") {
                bounded2 = false
                haveBound = true
                continue
            }
            if (haveBound) {
                throw IllegalArgumentException("Can only have \u{2026} at the end of samples: " + (range))
            }
            let rangeParts = PluralRules.TILDE_SEPARATED.split(range, 0)
            match (Int32(rangeParts.size)) {
                case 1 =>
                    let sample = DecimalQuantity_DualStorageBCD.fromExponentString(rangeParts[0])
                    checkDecimal(sampleType2, sample)
                    samples2.put(PluralRules_DecimalQuantitySamplesRange(sample, sample))
                case 2 =>
                    let start = DecimalQuantity_DualStorageBCD.fromExponentString(rangeParts[0])
                    let end = DecimalQuantity_DualStorageBCD.fromExponentString(rangeParts[1])
                    checkDecimal(sampleType2, start)
                    checkDecimal(sampleType2, end)
                    samples2.put(PluralRules_DecimalQuantitySamplesRange(start, end))
                case _ => throw IllegalArgumentException("Ill-formed number range: " + (range))
            }
        }
        return PluralRules_DecimalQuantitySamples(sampleType2, Collections.unmodifiableSet(samples2 as Set<T>), bounded2)
    }

    private static func checkDecimal(sampleType2: PluralRules_SampleType, sample: DecimalQuantity): Unit {
        if ((refEq(sampleType2, PluralRules_SampleType.INTEGER) && sample.getPluralOperand(PluralRules_Operand.v) != 0.0) || (refEq(sampleType2, PluralRules_SampleType.DECIMAL) && sample.getPluralOperand(PluralRules_Operand.v) == 0.0 && sample.getPluralOperand(PluralRules_Operand.e) == 0.0)) {
            throw IllegalArgumentException("Ill-formed number range: " + toString(sample))
        }
    }

    
    public func addSamples(result: Collection<Float64>): Collection<Float64> {
        addSamples(result, None)
        return result
    }

    
    public func addDecimalQuantitySamples(result: Collection<DecimalQuantity>): Collection<DecimalQuantity> {
        addSamples(None, result)
        return result
    }

    
    public func addSamples(doubleResult: Collection<Float64>, dqResult: Collection<DecimalQuantity>): Unit {
        if ((doubleResult.isNone() && dqResult.isNone()) || (doubleResult.isSome() && dqResult.isSome())) {
            return
        }
        let isDouble = doubleResult.isSome()
        for (range in samples) {
            let start = range.start
            let end = range.end
            let lowerDispMag = start.getLowerDisplayMagnitude()
            let exponent = start.getExponent()
            let incrementScale = lowerDispMag + exponent
            let incrementBd = BigDecimal.ONE.movePointRight(incrementScale)
            var dq = start.createCopy()
            while (dq.toDouble() <= end.toDouble()) {
                if (isDouble) {
                    let dblValue = dq.toDouble()
                    if (!(dblValue == floor(dblValue)) && dq.getPluralOperand(PluralRules_Operand.v) > 0.0) {
                        doubleResult.add(dblValue)
                    }
                } else {
                    dqResult.add(dq)
                }
                let dqBd = dq.toBigDecimal()
                let newDqBd = dqBd.add(incrementBd)
                dq = DecimalQuantity_DualStorageBCD(newDqBd)
                dq.setMinFraction(-lowerDispMag)
                dq.adjustMagnitude(-exponent)
                dq.adjustExponent(exponent)
            }
        }
    }

    
    public override func toString(): String {
        let b: StringBuilder = StringBuilder("@").append(sampleType.toString().toLowerCase(Locale.ENGLISH))
        var first = true
        for (item in samples) {
            if (first) {
                first = false
            } else {
                b.append(",")
            }
            b.append(' ').append(item.asString())
        }
        if (!bounded) {
            b.append(", \u{2026}")
        }
        return b.toString()
    }

    
    public func getSamples(): Set<PluralRules_DecimalQuantitySamplesRange> {
        return samples
    }

    
    public func getStartEndSamples(target: Set<DecimalQuantity>): Unit {
        for (range in samples) {
            target.put(range.start)
            target.put(range.end)
        }
    }
}


interface PluralRules_Constraint <: Serializable {
    func isFulfilled(n: PluralRules_IFixedDecimal): Bool

    func isLimited(sampleType: PluralRules_SampleType): Bool
}

class PluralRules_SimpleTokenizer {

    static let BREAK_AND_IGNORE = UnicodeSet([9, 10, 12, 13, 32, 32]).freeze()

    static let BREAK_AND_KEEP = UnicodeSet([Int32(UInt32('!')), Int32(UInt32('!')), Int32(UInt32('%')), Int32(UInt32('%')), Int32(UInt32(',')), Int32(UInt32(',')), Int32(UInt32('.')), Int32(UInt32('.')), Int32(UInt32('=')), Int32(UInt32('='))]).freeze()

    static func split(source: String): Array<String> {
        var last = -1
        let result = ArrayList<String>()
        var i = 0
        while (i < Int32(source.size)) {
            let ch = Char(source[Int64(i)])
            if (BREAK_AND_IGNORE.contains(Int32(UInt32(ch)))) {
                if (last >= 0) {
                    result.append(source[Int64(last)..Int64(i)])
                    last = -1
                }
            } else if (BREAK_AND_KEEP.contains(Int32(UInt32(ch)))) {
                if (last >= 0) {
                    result.append(source[Int64(last)..Int64(i)])
                }
                result.append(source[Int64(i)..Int64(i + 1)])
                last = -1
            } else if (last < 0) {
                last = i
            }
            i++
        }
        if (last >= 0) {
            result.append(source[Int64(last)..])
        }
        return result.toArray(size))
    }
}


class PluralRules_RangeConstraint <: PluralRules_Constraint & Serializable {
    private static let serialVersionUID = 1

    private let mod: Int32

    private let inRange: Bool

    private let integersOnly: Bool

    private let lowerBound: Float64

    private let upperBound: Float64

    private let range_list: Array<Int64>

    private let operand: PluralRules_Operand

    init(mod: Int32, inRange: Bool, operand: PluralRules_Operand, integersOnly: Bool, lowBound: Float64, highBound: Float64, vals: Array<Int64>) {
        this.mod = mod
        this.inRange = inRange
        this.integersOnly = integersOnly
        this.lowerBound = lowBound
        this.upperBound = highBound
        this.range_list = vals
        this.operand = operand
    }

    public override func isFulfilled(number: PluralRules_IFixedDecimal): Bool {
        var n = number.getPluralOperand(operand)
        if (integersOnly && (n - Float64(Int64(n))) != 0.0 || refEq(operand, PluralRules_Operand.j) && number.getPluralOperand(PluralRules_Operand.v) != 0.0) {
            return !inRange
        }
        if (mod != 0) {
            n = rem(n, Float64(mod))
        }
        var test = n >= lowerBound && n <= upperBound
        if (test && range_list.isSome()) {
            test = false
            var i = 0
            while (!test && i < Int32(range_list.size)) {
                test = n >= Float64(range_list[Int64(i)]) && n <= Float64(range_list[Int64(i + 1)])
                i += 2
            }
        }
        return inRange == test
    }

    public override func isLimited(sampleType: PluralRules_SampleType): Bool {
        let valueIsZero = lowerBound == upperBound && lowerBound == 0.0
        let hasDecimals = (refEq(operand, PluralRules_Operand.v) || refEq(operand, PluralRules_Operand.w) || refEq(operand, PluralRules_Operand.f) || refEq(operand, PluralRules_Operand.t)) && inRange != valueIsZero
        match (sampleType) {
            case PluralRules_SampleType.INTEGER => return hasDecimals || (refEq(operand, PluralRules_Operand.n) || refEq(operand, PluralRules_Operand.i) || refEq(operand, PluralRules_Operand.j)) && mod == 0 && inRange
            case PluralRules_SampleType.DECIMAL => return (!hasDecimals || refEq(operand, PluralRules_Operand.n) || refEq(operand, PluralRules_Operand.j)) && (integersOnly || lowerBound == upperBound) && mod == 0 && inRange
            case _ => ()
        }
        return false
    }

    public override func toString(): String {
        let result = StringBuilder()
        result.append(operand.asString())
        if (mod != 0) {
            result.append(" % ").append(mod)
        }
        let isList = lowerBound != upperBound
        result.append(if (!isList) { (if (inRange) { " = " } else { " != " }) } else { if (integersOnly) { (if (inRange) { " = " } else { " != " }) } else { (if (inRange) { " within " } else { " not within " }) } })
        if (range_list.isSome()) {
            var i = 0
            while (i < Int32(range_list.size)) {
                PluralRules.addRange(result, Float64(range_list[Int64(i)]), Float64(range_list[Int64(i + 1)]), i != 0)
                i += 2
            }
        } else {
            PluralRules.addRange(result, lowerBound, upperBound, false)
        }
        return result.toString()
    }
}


abstract class PluralRules_BinaryConstraint <: PluralRules_Constraint & Serializable {
    private static let serialVersionUID = 1

    protected let a: PluralRules_Constraint

    protected let b: PluralRules_Constraint

    protected init(a: PluralRules_Constraint, b: PluralRules_Constraint) {
        this.a = a
        this.b = b
    }
}


class PluralRules_AndConstraint <: PluralRules_BinaryConstraint {
    private static let serialVersionUID = 7766999779862263523

    init(a: PluralRules_Constraint, b: PluralRules_Constraint) {
        super(a, b)
    }

    public override func isFulfilled(n: PluralRules_IFixedDecimal): Bool {
        return a.isFulfilled(n) && b.isFulfilled(n)
    }

    public override func isLimited(sampleType: PluralRules_SampleType): Bool {
        return a.isLimited(sampleType) || b.isLimited(sampleType)
    }

    public override func toString(): String {
        return toString(a) + " and " + toString(b)
    }
}


class PluralRules_OrConstraint <: PluralRules_BinaryConstraint {
    private static let serialVersionUID = 1405488568664762222

    init(a: PluralRules_Constraint, b: PluralRules_Constraint) {
        super(a, b)
    }

    public override func isFulfilled(n: PluralRules_IFixedDecimal): Bool {
        return a.isFulfilled(n) || b.isFulfilled(n)
    }

    public override func isLimited(sampleType: PluralRules_SampleType): Bool {
        return a.isLimited(sampleType) && b.isLimited(sampleType)
    }

    public override func toString(): String {
        return toString(a) + " or " + toString(b)
    }
}


class PluralRules_Rule <: Serializable {
    private static let serialVersionUID = 1

    private let keyword: String

    private let constraint: PluralRules_Constraint

    let integerSamples: PluralRules_DecimalQuantitySamples

    let decimalSamples: PluralRules_DecimalQuantitySamples

    public init(keyword: String, constraint: PluralRules_Constraint, integerSamples: PluralRules_DecimalQuantitySamples, decimalSamples: PluralRules_DecimalQuantitySamples) {
        this.keyword = keyword
        this.constraint = constraint
        this.integerSamples = integerSamples
        this.decimalSamples = decimalSamples
    }

    public func and(c: PluralRules_Constraint): PluralRules_Rule {
        return PluralRules_Rule(keyword, PluralRules_AndConstraint(constraint, c), integerSamples, decimalSamples)
    }

    public func or(c: PluralRules_Constraint): PluralRules_Rule {
        return PluralRules_Rule(keyword, PluralRules_OrConstraint(constraint, c), integerSamples, decimalSamples)
    }

    public func getKeyword(): String {
        return keyword
    }

    public func appliesTo(n: PluralRules_IFixedDecimal): Bool {
        return constraint.isFulfilled(n)
    }

    public func isLimited(sampleType: PluralRules_SampleType): Bool {
        return constraint.isLimited(sampleType)
    }

    public override func toString(): String {
        return (keyword) + ": " + toString(constraint) + (if (integerSamples.isNone()) { "" } else { " " + integerSamples.toString() }) + (if (decimalSamples.isNone()) { "" } else { " " + decimalSamples.toString() })
    }

    public override func hashCode(): Int64 {
        return Int64(Int32(keyword.hashCode()) ^ Int32(constraint.toString()))
    }

    public func getConstraint(): String {
        return toString(constraint)
    }
}


class PluralRules_RuleList <: Serializable {

    var hasExplicitBoundingInfo = false

    private static let serialVersionUID = 1

    private let rules = ArrayList<PluralRules_Rule>()

    public func addRule(nextRule: PluralRules_Rule): PluralRules_RuleList {
        let keyword = nextRule.getKeyword()
        for (rule in rules) {
            if (keyword.equals(rule.getKeyword())) {
                throw IllegalArgumentException("Duplicate keyword: " + (keyword))
            }
        }
        rules.append(nextRule)
        return this
    }

    public func finish(): PluralRules_RuleList {
        var otherRule: PluralRules_Rule
        let it: Iterator<PluralRules_Rule> = rules.iterator()
        while (it.hasNext()) {
            let rule = it.next()
            if ("other".equals(rule.getKeyword())) {
                otherRule = rule
                it.remove()
            }
        }
        if (otherRule.isNone()) {
            otherRule = PluralRules.parseRule("other:")
        }
        rules.append(otherRule)
        return this
    }

    private func selectRule(n: PluralRules_IFixedDecimal): PluralRules_Rule {
        for (rule in rules) {
            if (rule.appliesTo(n)) {
                return rule
            }
        }
        return None
    }

    public func select(n: PluralRules_IFixedDecimal): String {
        if (n.isInfinite() || n.isNaN()) {
            return PluralRules.KEYWORD_OTHER
        }
        let r = selectRule(n)
        return r.getKeyword()
    }

    public func getKeywords(): Set<String> {
        let result = LinkedHashSet()
        for (rule in rules) {
            result.put(rule.getKeyword())
        }
        return result
    }

    public func isLimited(keyword: String, sampleType: PluralRules_SampleType): Bool {
        if (hasExplicitBoundingInfo) {
            let mySamples = getDecimalSamples(keyword, sampleType)
            return if (mySamples.isNone()) { true } else { mySamples.bounded }
        }
        return computeLimited(keyword, sampleType)
    }

    public func computeLimited(keyword: String, sampleType: PluralRules_SampleType): Bool {
        var result = false
        for (rule in rules) {
            if (keyword.equals(rule.getKeyword())) {
                if (!rule.isLimited(sampleType)) {
                    return false
                }
                result = true
            }
        }
        return result
    }

    public override func toString(): String {
        let builder = StringBuilder()
        for (rule in rules) {
            if (Int32(builder.size) != 0) {
                builder.append(PluralRules.CATEGORY_SEPARATOR)
            }
            builder.append(rule.asString())
        }
        return builder.toString()
    }

    public func getRules(keyword: String): String {
        for (rule in rules) {
            if (rule.getKeyword().equals(keyword)) {
                return rule.getConstraint()
            }
        }
        return None
    }

    public func select(sample: PluralRules_IFixedDecimal, keyword: String): Bool {
        for (rule in rules) {
            if (rule.getKeyword().equals(keyword) && rule.appliesTo(sample)) {
                return true
            }
        }
        return false
    }

    public func getDecimalSamples(keyword: String, sampleType: PluralRules_SampleType): PluralRules_DecimalQuantitySamples {
        for (rule in rules) {
            if (rule.getKeyword().equals(keyword)) {
                return if (refEq(sampleType, PluralRules_SampleType.INTEGER)) { rule.integerSamples } else { rule.decimalSamples }
            }
        }
        return None
    }
}


public class PluralRules_KeywordStatus <: Enum<PluralRules_KeywordStatus> {
    public static let INVALID = PluralRules_KeywordStatus("INVALID", 0)

    public static let SUPPRESSED = PluralRules_KeywordStatus("SUPPRESSED", 1)

    public static let UNIQUE = PluralRules_KeywordStatus("UNIQUE", 2)

    public static let BOUNDED = PluralRules_KeywordStatus("BOUNDED", 3)

    public static let UNBOUNDED = PluralRules_KeywordStatus("UNBOUNDED", 4)

    private static func _values(): Array<PluralRules_KeywordStatus> {
        return [PluralRules_KeywordStatus.INVALID, PluralRules_KeywordStatus.SUPPRESSED, PluralRules_KeywordStatus.UNIQUE, PluralRules_KeywordStatus.BOUNDED, PluralRules_KeywordStatus.UNBOUNDED]
    }

    private static let _VALUES = PluralRules_KeywordStatus._values()

    public static func values(): Array<PluralRules_KeywordStatus> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): PluralRules_KeywordStatus {
        return (TypeInfo.of<PluralRules_KeywordStatus>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as PluralRules_KeywordStatus
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
