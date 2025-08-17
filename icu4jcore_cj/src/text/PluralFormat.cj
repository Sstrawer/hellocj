package icu4cj.text

public class PluralFormat <: UFormat {
    private static let serialVersionUID = 1

    private var ulocale: ULocale

    var pluralRules: PluralRules

    private var pattern: String

     private var msgPattern: MessagePattern

    private var parsedValues: Map<String, String> = None

    private var numberFormat: NumberFormat

     private var offset = 0.0

    public init() {
        super()
        initself(None, PluralRules_PluralType.CARDINAL, ULocale.getDefault(ULocale_Category.FORMAT), None)
    }

    public init(ulocale: ULocale) {
        super()
        initself(None, PluralRules_PluralType.CARDINAL, ulocale, None)
    }

    public init(locale: Locale) {
        this(ULocale.forLocale(locale))
    }

    public init(rules: PluralRules) {
        super()
        initself(rules, PluralRules_PluralType.CARDINAL, ULocale.getDefault(ULocale_Category.FORMAT), None)
    }

    public init(ulocale: ULocale, rules: PluralRules) {
        super()
        initself(rules, PluralRules_PluralType.CARDINAL, ulocale, None)
    }

    public init(locale: Locale, rules: PluralRules) {
        this(ULocale.forLocale(locale), rules)
    }

    public init(ulocale: ULocale, Type: PluralRules_PluralType) {
        super()
        initself(None, Type, ulocale, None)
    }

    public init(locale: Locale, Type: PluralRules_PluralType) {
        this(ULocale.forLocale(locale), Type)
    }

    public init(pattern: String) {
        super()
        initself(None, PluralRules_PluralType.CARDINAL, ULocale.getDefault(ULocale_Category.FORMAT), None)
        applyPattern(pattern)
    }

    public init(ulocale: ULocale, pattern: String) {
        super()
        initself(None, PluralRules_PluralType.CARDINAL, ulocale, None)
        applyPattern(pattern)
    }

    public init(rules: PluralRules, pattern: String) {
        super()
        initself(rules, PluralRules_PluralType.CARDINAL, ULocale.getDefault(ULocale_Category.FORMAT), None)
        applyPattern(pattern)
    }

    public init(ulocale: ULocale, rules: PluralRules, pattern: String) {
        super()
        initself(rules, PluralRules_PluralType.CARDINAL, ulocale, None)
        applyPattern(pattern)
    }

    public init(ulocale: ULocale, Type: PluralRules_PluralType, pattern: String) {
        super()
        initself(None, Type, ulocale, None)
        applyPattern(pattern)
    }

    init(ulocale: ULocale, Type: PluralRules_PluralType, pattern: String, numberFormat: NumberFormat) {
        super()
        initself(None, Type, ulocale, numberFormat)
        applyPattern(pattern)
    }

    private func initself(rules: PluralRules, Type: PluralRules_PluralType, locale: ULocale, numberFormat: NumberFormat): Unit {
        ulocale = locale
        pluralRules = if (rules.isNone()) { PluralRules.forLocale(ulocale, Type) } else { rules }
        resetPattern()
        this.numberFormat = if (numberFormat.isNone()) { NumberFormat.getInstance(ulocale) } else { numberFormat }
    }

    private func resetPattern(): Unit {
        pattern = None
        if (msgPattern.isSome()) {
            msgPattern.clear()
        }
        offset = 0.0
    }

    public func applyPattern(pattern: String): Unit {
        this.pattern = pattern
        if (msgPattern.isNone()) {
            msgPattern = MessagePattern()
        }
        try {
            msgPattern.parsePluralStyle(pattern)
            offset = msgPattern.getPluralOffset(0)
        } catch (e: Exception) {
            resetPattern()
            throw e
        }
    }

    public func toPattern(): String {
        return pattern
    }

    static func findSubMessage(pattern: MessagePattern, partIndex: Int32, selector: PluralFormat_PluralSelector, context: Object, number: Float64): Int32 {
        var temppartIndex = partIndex
        let count = pattern.countParts()
        let offset: Float64
        var part = pattern.getPart(temppartIndex)
        if (part.getType().hasNumericValue()) {
            offset = pattern.getNumericValue(part)
            temppartIndex++
        } else {
            offset = 0.0
        }
        var keyword: String
        var haveKeywordMatch = false
        var msgStart = 0
            if (!refEq(Type, MessagePattern_Part_Type.ARG_SELECTOR)) {
                throw AssertionError()
            }
            if (pattern.getPartType(temppartIndex).hasNumericValue()) {
                part = pattern.getPart(match (0) { case _ => temppartIndex++; temppartIndex - 1 })
                if (number == pattern.getNumericValue(part)) {
                    return temppartIndex
                }
            } else if (!haveKeywordMatch) {
                if (pattern.partSubstringMatches(part, "other")) {
                    if (msgStart == 0) {
                        msgStart = temppartIndex
                        if (keyword.isSome() && keyword == "other") {
                            haveKeywordMatch = true
                        }
                    }
                } else {
                    if (keyword.isNone()) {
                        keyword = selector.select(context, number - offset)
                        if (msgStart != 0 && keyword == "other") {
                            haveKeywordMatch = true
                        }
                    }
                    if (!haveKeywordMatch && pattern.partSubstringMatches(part, keyword)) {
                        msgStart = temppartIndex
                        haveKeywordMatch = true
                    }
                }
            }
            temppartIndex = pattern.getLimitPartIndex(temppartIndex)
        } while (match (0) { case _ => temppartIndex++; temppartIndex } < count)
        return msgStart
    }

     private var pluralRulesWrapper: PluralFormat_PluralSelectorAdapter = PluralFormat_PluralSelectorAdapter(this)

    public func format(number: Float64): String {
        return format(number, number)
    }

    public override func format(number: Object, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        if (!(checkOptionalIs<Number, Object>(number))) {
            throw IllegalArgumentException("'" + toString(number) + "' is not a Number")
        }
        let numberObject = number
        toAppendTo.append(format(numberObject, numberObject.doubleValue()))
        return toAppendTo
    }

    private func format(numberObject: Number, number: Float64): String {
        if (msgPattern.isNone() || msgPattern.countParts() == 0) {
            return numberFormat.format(numberObject)
        }
        let numberMinusOffset = number - offset
        let numberString: String
        let dec: PluralRules_IFixedDecimal
        if (checkOptionalIs<DecimalFormat, NumberFormat>(numberFormat)) {
            let f = numberFormat.toNumberFormatter()
            let result: FormattedNumber
            if (offset == 0.0) {
                result = f.format(numberObject)
            } else {
                result = f.format(numberMinusOffset)
            }
            numberString = result.toString()
            dec = result.getFixedDecimal()
        } else {
            if (offset == 0.0) {
                numberString = numberFormat.format(numberObject)
            } else {
                numberString = numberFormat.format(numberMinusOffset)
            }
            dec = PluralRules_FixedDecimal(numberMinusOffset)
        }
        var partIndex = findSubMessage(msgPattern, 0, pluralRulesWrapper, dec, number)
        var result: StringBuilder
        var prevIndex = msgPattern.getPart(partIndex).getLimit()
        while (true) {
            let part = msgPattern.getPart(match (0) { case _ => partIndex++; partIndex })
            let Type = part.getType()
            var index = part.getIndex()
            if (refEq(Type, MessagePattern_Part_Type.MSG_LIMIT)) {
                if (result.isNone()) {
                    return pattern[Int64(prevIndex)..Int64(index)]
                } else {
                    return result.append(pattern, prevIndex, index).toString()
                }
            } else if (refEq(Type, MessagePattern_Part_Type.REPLACE_NUMBER) || (refEq(Type, MessagePattern_Part_Type.SKIP_SYNTAX) && msgPattern.jdkAposMode())) {
                if (result.isNone()) {
                    result = StringBuilder()
                }
                result.append(pattern, prevIndex, index)
                if (refEq(Type, MessagePattern_Part_Type.REPLACE_NUMBER)) {
                    result.append(numberString)
                }
                prevIndex = part.getLimit()
            } else if (refEq(Type, MessagePattern_Part_Type.ARG_START)) {
                if (result.isNone()) {
                    result = StringBuilder()
                }
                result.append(pattern, prevIndex, index)
                prevIndex = index
                partIndex = msgPattern.getLimitPartIndex(partIndex)
                index = msgPattern.getPart(partIndex).getLimit()
                MessagePattern.appendReducedApostrophes(pattern, prevIndex, index, result)
                prevIndex = index
            }
        }
    }

    public func parse(text: String, parsePosition: ParsePosition): Number {
        throw UnsupportedOperationException()
    }

    public override func parseObject(source: String, pos: ParsePosition): Object {
        throw UnsupportedOperationException()
    }

    public func parseType(source: String, scanner: RbnfLenientScanner, pos: FieldPosition): String {
        if (msgPattern.isNone() || msgPattern.countParts() == 0) {
            pos.setBeginIndex(-1)
            pos.setEndIndex(-1)
            return None
        }
        var partIndex = 0
        var currMatchIndex: Int32 = 0
        let count = msgPattern.countParts()
        var startingAt = pos.getBeginIndex()
        if (startingAt < 0) {
            startingAt = 0
        }
        var keyword: String
        var matchedWord: String
        var matchedIndex = -1
        while (partIndex < count) {
            let partSelector = msgPattern.getPart(match (0) { case _ => partIndex++; partIndex - 1 })
            if (!refEq(partSelector.getType(), MessagePattern_Part_Type.ARG_SELECTOR)) {
                continue
            }
            let partStart = msgPattern.getPart(match (0) { case _ => partIndex++; partIndex - 1 })
            if (!refEq(partStart.getType(), MessagePattern_Part_Type.MSG_START)) {
                continue
            }
            let partLimit = msgPattern.getPart(match (0) { case _ => partIndex++; partIndex - 1 })
            if (!refEq(partLimit.getType(), MessagePattern_Part_Type.MSG_LIMIT)) {
                continue
            }
            let currArg: String = pattern[Int64(partStart.getLimit())..Int64(partLimit.getIndex())]
            if (scanner.isSome()) {
                let tempPos = indexOfWrap(source.indexOf(currArg, Int64(startingAt)))
                if (tempPos >= 0) {
                    currMatchIndex = tempPos
                } else {
                    let scannerMatchResult = scanner.findText(source, currArg, startingAt)
                    currMatchIndex = scannerMatchResult[0]
                }
            } else {
                currMatchIndex = indexOfWrap(source.indexOf(currArg, Int64(startingAt)))
            }
            if (currMatchIndex >= 0 && currMatchIndex >= matchedIndex && (matchedWord.isNone() || Int32(currArg.size) > Int32(matchedWord.size))) {
                matchedIndex = currMatchIndex
                matchedWord = currArg
                keyword = pattern[Int64(partStart.getLimit())..Int64(partLimit.getIndex())]
            }
        }
        if (keyword.isSome()) {
            pos.setBeginIndex(matchedIndex)
            pos.setEndIndex(matchedIndex + Int32(matchedWord.size))
            return keyword
        }
        pos.setBeginIndex(-1)
        pos.setEndIndex(-1)
        return None
    }

    
    public func setLocale(ulocale: ULocale): Unit {
        var tempulocale = ulocale
        if (tempulocale.isNone()) {
            tempulocale = ULocale.getDefault(ULocale_Category.FORMAT)
        }
        initself(None, PluralRules_PluralType.CARDINAL, tempulocale, None)
    }

    public func setNumberFormat(format: NumberFormat): Unit {
        numberFormat = format
    }

    public override func equals(rhs: Object): Bool {
        if (refEq(this, rhs)) {
            return true
        }
        if (rhs.isNone() || !refEq(TypeInfo.of(this), TypeInfo.of(rhs))) {
            return false
        }
        let pf = rhs
        return Objects.equals(ulocale, pf.ulocale) && Objects.equals(pluralRules, pf.pluralRules) && Objects.equals(msgPattern, pf.msgPattern) && Objects.equals(numberFormat, pf.numberFormat)
    }

    public func equals(rhs: PluralFormat): Bool {
        return equals(rhs)
    }

    public override func hashCode(): Int64 {
        return Int64(Int32(pluralRules.hashCode()) ^ Int32(parsedValues.hashCode()))
    }

    public override func toString(): String {
        let buf = StringBuilder()
        buf.append("locale=" + ulocale.asString())
        buf.append(", rules='" + pluralRules.asString() + "'")
        buf.append(", pattern='" + (pattern) + "'")
        buf.append(", format='" + numberFormat.asString() + "'")
        return buf.toString()
    }

    private func readObject(input: ObjectInputStream): Unit {
        input.defaultReadObject()
        pluralRulesWrapper = PluralFormat_PluralSelectorAdapter(this)
        parsedValues = None
        if (pattern.isSome()) {
            applyPattern(pattern)
        }
    }
}


interface PluralFormat_PluralSelector {
    public func select(context: Object, number: Float64): String
}

class PluralFormat_PluralSelectorAdapter <: PluralFormat_PluralSelector {
    let this_0: PluralFormat

    init(this_0: PluralFormat) {
        this.this_0 = this_0
    }

    public override func select(context: Object, number: Float64): String {
        let dec = context
        return this_0.pluralRules.select(dec)
    }
}
