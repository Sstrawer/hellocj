package icu4cj.impl.number


public class DecimalFormatProperties <: Cloneable & Serializable {
    private static let DEFAULT = DecimalFormatProperties()

    private static let serialVersionUID = 4095518955889349243

     private var compactCustomData: Map<String, Map<String, String>> = None

     private var compactStyle: CompactDecimalFormat_CompactStyle

     private var currency: Currency

     private var currencyPluralInfo: CurrencyPluralInfo

     private var currencyUsage: Currency_CurrencyUsage

     private var decimalPatternMatchRequired: Bool = false

     private var decimalSeparatorAlwaysShown: Bool = false

     private var exponentSignAlwaysShown: Bool = false

     private var currencyAsDecimal: Bool = false

     private var formatWidth: Int32 = 0

     private var groupingSize: Int32 = 0

     private var groupingUsed: Bool = false

     private var magnitudeMultiplier: Int32 = 0

     private var mathContext: MathContext = None

     private var maximumFractionDigits: Int32 = 0

     private var maximumIntegerDigits: Int32 = 0

     private var maximumSignificantDigits: Int32 = 0

     private var minimumExponentDigits: Int32 = 0

     private var minimumFractionDigits: Int32 = 0

     private var minimumGroupingDigits: Int32 = 0

     private var minimumIntegerDigits: Int32 = 0

     private var minimumSignificantDigits: Int32 = 0

     private var multiplier: BigDecimal = None

     private var negativePrefix: String

     private var negativePrefixPattern: String

     private var negativeSuffix: String

     private var negativeSuffixPattern: String

     private var padPosition: Padder_PadPosition

     private var padString: String

     private var parseCaseSensitive: Bool = false

     private var parseIntegerOnly: Bool = false

     private var parseMode: DecimalFormatProperties_ParseMode

     private var parseNoExponent: Bool = false

     private var parseToBigDecimal: Bool = false

     private var pluralRules: PluralRules

     private var positivePrefix: String

     private var positivePrefixPattern: String

     private var positiveSuffix: String

     private var positiveSuffixPattern: String

     private var roundingIncrement: BigDecimal = None

     private var roundingMode: RoundingMode = None

     private var secondaryGroupingSize: Int32 = 0

     private var signAlwaysShown: Bool = false

    public init() {
        clear()
    }

    private func _clear(): DecimalFormatProperties {
        compactCustomData = None
        compactStyle = None
        currency = None
        currencyPluralInfo = None
        currencyUsage = None
        decimalPatternMatchRequired = false
        decimalSeparatorAlwaysShown = false
        exponentSignAlwaysShown = false
        currencyAsDecimal = false
        formatWidth = -1
        groupingSize = -1
        groupingUsed = true
        magnitudeMultiplier = 0
        mathContext = None
        maximumFractionDigits = -1
        maximumIntegerDigits = -1
        maximumSignificantDigits = -1
        minimumExponentDigits = -1
        minimumFractionDigits = -1
        minimumGroupingDigits = -1
        minimumIntegerDigits = -1
        minimumSignificantDigits = -1
        multiplier = None
        negativePrefix = None
        negativePrefixPattern = None
        negativeSuffix = None
        negativeSuffixPattern = None
        padPosition = None
        padString = None
        parseCaseSensitive = false
        parseIntegerOnly = false
        parseMode = None
        parseNoExponent = false
        parseToBigDecimal = false
        pluralRules = None
        positivePrefix = None
        positivePrefixPattern = None
        positiveSuffix = None
        positiveSuffixPattern = None
        roundingIncrement = None
        roundingMode = None
        secondaryGroupingSize = -1
        signAlwaysShown = false
        return this
    }

    private func _copyFrom(other: DecimalFormatProperties): DecimalFormatProperties {
        compactCustomData = other.compactCustomData
        compactStyle = other.compactStyle
        currency = other.currency
        currencyPluralInfo = other.currencyPluralInfo
        currencyUsage = other.currencyUsage
        decimalPatternMatchRequired = other.decimalPatternMatchRequired
        decimalSeparatorAlwaysShown = other.decimalSeparatorAlwaysShown
        exponentSignAlwaysShown = other.exponentSignAlwaysShown
        currencyAsDecimal = other.currencyAsDecimal
        formatWidth = other.formatWidth
        groupingSize = other.groupingSize
        groupingUsed = other.groupingUsed
        magnitudeMultiplier = other.magnitudeMultiplier
        mathContext = other.mathContext
        maximumFractionDigits = other.maximumFractionDigits
        maximumIntegerDigits = other.maximumIntegerDigits
        maximumSignificantDigits = other.maximumSignificantDigits
        minimumExponentDigits = other.minimumExponentDigits
        minimumFractionDigits = other.minimumFractionDigits
        minimumGroupingDigits = other.minimumGroupingDigits
        minimumIntegerDigits = other.minimumIntegerDigits
        minimumSignificantDigits = other.minimumSignificantDigits
        multiplier = other.multiplier
        negativePrefix = other.negativePrefix
        negativePrefixPattern = other.negativePrefixPattern
        negativeSuffix = other.negativeSuffix
        negativeSuffixPattern = other.negativeSuffixPattern
        padPosition = other.padPosition
        padString = other.padString
        parseCaseSensitive = other.parseCaseSensitive
        parseIntegerOnly = other.parseIntegerOnly
        parseMode = other.parseMode
        parseNoExponent = other.parseNoExponent
        parseToBigDecimal = other.parseToBigDecimal
        pluralRules = other.pluralRules
        positivePrefix = other.positivePrefix
        positivePrefixPattern = other.positivePrefixPattern
        positiveSuffix = other.positiveSuffix
        positiveSuffixPattern = other.positiveSuffixPattern
        roundingIncrement = other.roundingIncrement
        roundingMode = other.roundingMode
        secondaryGroupingSize = other.secondaryGroupingSize
        signAlwaysShown = other.signAlwaysShown
        return this
    }

    private func _equals(other: DecimalFormatProperties): Bool {
        var eq = true
        eq = eq && _equalsHelper(compactCustomData, other.compactCustomData)
        eq = eq && _equalsHelper(compactStyle, other.compactStyle)
        eq = eq && _equalsHelper(currency, other.currency)
        eq = eq && _equalsHelper(currencyPluralInfo, other.currencyPluralInfo)
        eq = eq && _equalsHelper(currencyUsage, other.currencyUsage)
        eq = eq && _equalsHelper(decimalPatternMatchRequired, other.decimalPatternMatchRequired)
        eq = eq && _equalsHelper(decimalSeparatorAlwaysShown, other.decimalSeparatorAlwaysShown)
        eq = eq && _equalsHelper(exponentSignAlwaysShown, other.exponentSignAlwaysShown)
        eq = eq && _equalsHelper(currencyAsDecimal, other.currencyAsDecimal)
        eq = eq && _equalsHelper(formatWidth, other.formatWidth)
        eq = eq && _equalsHelper(groupingSize, other.groupingSize)
        eq = eq && _equalsHelper(groupingUsed, other.groupingUsed)
        eq = eq && _equalsHelper(magnitudeMultiplier, other.magnitudeMultiplier)
        eq = eq && _equalsHelper(mathContext, other.mathContext)
        eq = eq && _equalsHelper(maximumFractionDigits, other.maximumFractionDigits)
        eq = eq && _equalsHelper(maximumIntegerDigits, other.maximumIntegerDigits)
        eq = eq && _equalsHelper(maximumSignificantDigits, other.maximumSignificantDigits)
        eq = eq && _equalsHelper(minimumExponentDigits, other.minimumExponentDigits)
        eq = eq && _equalsHelper(minimumFractionDigits, other.minimumFractionDigits)
        eq = eq && _equalsHelper(minimumGroupingDigits, other.minimumGroupingDigits)
        eq = eq && _equalsHelper(minimumIntegerDigits, other.minimumIntegerDigits)
        eq = eq && _equalsHelper(minimumSignificantDigits, other.minimumSignificantDigits)
        eq = eq && _equalsHelper(multiplier, other.multiplier)
        eq = eq && _equalsHelper(negativePrefix, other.negativePrefix)
        eq = eq && _equalsHelper(negativePrefixPattern, other.negativePrefixPattern)
        eq = eq && _equalsHelper(negativeSuffix, other.negativeSuffix)
        eq = eq && _equalsHelper(negativeSuffixPattern, other.negativeSuffixPattern)
        eq = eq && _equalsHelper(padPosition, other.padPosition)
        eq = eq && _equalsHelper(padString, other.padString)
        eq = eq && _equalsHelper(parseCaseSensitive, other.parseCaseSensitive)
        eq = eq && _equalsHelper(parseIntegerOnly, other.parseIntegerOnly)
        eq = eq && _equalsHelper(parseMode, other.parseMode)
        eq = eq && _equalsHelper(parseNoExponent, other.parseNoExponent)
        eq = eq && _equalsHelper(parseToBigDecimal, other.parseToBigDecimal)
        eq = eq && _equalsHelper(pluralRules, other.pluralRules)
        eq = eq && _equalsHelper(positivePrefix, other.positivePrefix)
        eq = eq && _equalsHelper(positivePrefixPattern, other.positivePrefixPattern)
        eq = eq && _equalsHelper(positiveSuffix, other.positiveSuffix)
        eq = eq && _equalsHelper(positiveSuffixPattern, other.positiveSuffixPattern)
        eq = eq && _equalsHelper(roundingIncrement, other.roundingIncrement)
        eq = eq && _equalsHelper(roundingMode, other.roundingMode)
        eq = eq && _equalsHelper(secondaryGroupingSize, other.secondaryGroupingSize)
        eq = eq && _equalsHelper(signAlwaysShown, other.signAlwaysShown)
        return eq
    }

    private func _equalsHelper(mine: Bool, theirs: Bool): Bool {
        return mine == theirs
    }

    private func _equalsHelper(mine: Int32, theirs: Int32): Bool {
        return mine == theirs
    }

    private func _equalsHelper(mine: Object, theirs: Object): Bool {
        if (refEq(mine, theirs)) {
            return true
        }
        if (mine.isNone()) {
            return false
        }
        return refEq(mine, theirs)
    }

    private func _hashCode(): Int32 {
        var hashCode = 0
        hashCode ^= _hashCodeHelper(compactCustomData)
        hashCode ^= _hashCodeHelper(compactStyle)
        hashCode ^= _hashCodeHelper(currency)
        hashCode ^= _hashCodeHelper(currencyPluralInfo)
        hashCode ^= _hashCodeHelper(currencyUsage)
        hashCode ^= _hashCodeHelper(decimalPatternMatchRequired)
        hashCode ^= _hashCodeHelper(decimalSeparatorAlwaysShown)
        hashCode ^= _hashCodeHelper(exponentSignAlwaysShown)
        hashCode ^= _hashCodeHelper(currencyAsDecimal)
        hashCode ^= _hashCodeHelper(formatWidth)
        hashCode ^= _hashCodeHelper(groupingSize)
        hashCode ^= _hashCodeHelper(groupingUsed)
        hashCode ^= _hashCodeHelper(magnitudeMultiplier)
        hashCode ^= _hashCodeHelper(mathContext)
        hashCode ^= _hashCodeHelper(maximumFractionDigits)
        hashCode ^= _hashCodeHelper(maximumIntegerDigits)
        hashCode ^= _hashCodeHelper(maximumSignificantDigits)
        hashCode ^= _hashCodeHelper(minimumExponentDigits)
        hashCode ^= _hashCodeHelper(minimumFractionDigits)
        hashCode ^= _hashCodeHelper(minimumGroupingDigits)
        hashCode ^= _hashCodeHelper(minimumIntegerDigits)
        hashCode ^= _hashCodeHelper(minimumSignificantDigits)
        hashCode ^= _hashCodeHelper(multiplier)
        hashCode ^= _hashCodeHelper(negativePrefix)
        hashCode ^= _hashCodeHelper(negativePrefixPattern)
        hashCode ^= _hashCodeHelper(negativeSuffix)
        hashCode ^= _hashCodeHelper(negativeSuffixPattern)
        hashCode ^= _hashCodeHelper(padPosition)
        hashCode ^= _hashCodeHelper(padString)
        hashCode ^= _hashCodeHelper(parseCaseSensitive)
        hashCode ^= _hashCodeHelper(parseIntegerOnly)
        hashCode ^= _hashCodeHelper(parseMode)
        hashCode ^= _hashCodeHelper(parseNoExponent)
        hashCode ^= _hashCodeHelper(parseToBigDecimal)
        hashCode ^= _hashCodeHelper(pluralRules)
        hashCode ^= _hashCodeHelper(positivePrefix)
        hashCode ^= _hashCodeHelper(positivePrefixPattern)
        hashCode ^= _hashCodeHelper(positiveSuffix)
        hashCode ^= _hashCodeHelper(positiveSuffixPattern)
        hashCode ^= _hashCodeHelper(roundingIncrement)
        hashCode ^= _hashCodeHelper(roundingMode)
        hashCode ^= _hashCodeHelper(secondaryGroupingSize)
        hashCode ^= _hashCodeHelper(signAlwaysShown)
        return hashCode
    }

    private func _hashCodeHelper(value: Bool): Int32 {
        return if (value) { 1 } else { 0 }
    }

    private func _hashCodeHelper(value: Int32): Int32 {
        return value * 13
    }

    private func _hashCodeHelper(value: Object): Int32 {
        if (value.isNone()) {
            return 0
        }
        return Int32(value.toString())
    }

    public func clear(): DecimalFormatProperties {
        return _clear()
    }

    public override func clone(): DecimalFormatProperties {
        try {
            return super.toString()
        } catch (e: CloneNotSupportedException) {
            throw UnsupportedOperationException(e as Exception)
        }
    }

    public func copyFrom(other: DecimalFormatProperties): DecimalFormatProperties {
        return _copyFrom(other)
    }

    public override func equals(other: Object): Bool {
        if (other.isNone()) {
            return false
        }
        if (refEq(this, other)) {
            return true
        }
        if (!(checkOptionalIs<DecimalFormatProperties, Object>(other))) {
            return false
        }
        return _equals(other)
    }

    public func getCompactCustomData(): Map<String, Map<String, String>> {
        return compactCustomData
    }

    public func getCompactStyle(): CompactDecimalFormat_CompactStyle {
        return compactStyle
    }

    public func getCurrency(): Currency {
        return currency
    }

    public func getCurrencyPluralInfo(): CurrencyPluralInfo {
        return currencyPluralInfo
    }

    public func getCurrencyUsage(): Currency_CurrencyUsage {
        return currencyUsage
    }

    public func getDecimalPatternMatchRequired(): Bool {
        return decimalPatternMatchRequired
    }

    public func getDecimalSeparatorAlwaysShown(): Bool {
        return decimalSeparatorAlwaysShown
    }

    public func getExponentSignAlwaysShown(): Bool {
        return exponentSignAlwaysShown
    }

    public func getCurrencyAsDecimal(): Bool {
        return currencyAsDecimal
    }

    public func getFormatWidth(): Int32 {
        return formatWidth
    }

    public func getGroupingSize(): Int32 {
        return groupingSize
    }

    public func getGroupingUsed(): Bool {
        return groupingUsed
    }

    public func getMagnitudeMultiplier(): Int32 {
        return magnitudeMultiplier
    }

    public func getMathContext(): MathContext {
        return mathContext
    }

    public func getMaximumFractionDigits(): Int32 {
        return maximumFractionDigits
    }

    public func getMaximumIntegerDigits(): Int32 {
        return maximumIntegerDigits
    }

    public func getMaximumSignificantDigits(): Int32 {
        return maximumSignificantDigits
    }

    public func getMinimumExponentDigits(): Int32 {
        return minimumExponentDigits
    }

    public func getMinimumFractionDigits(): Int32 {
        return minimumFractionDigits
    }

    public func getMinimumGroupingDigits(): Int32 {
        return minimumGroupingDigits
    }

    public func getMinimumIntegerDigits(): Int32 {
        return minimumIntegerDigits
    }

    public func getMinimumSignificantDigits(): Int32 {
        return minimumSignificantDigits
    }

    public func getMultiplier(): BigDecimal {
        return multiplier
    }

    public func getNegativePrefix(): String {
        return negativePrefix
    }

    public func getNegativePrefixPattern(): String {
        return negativePrefixPattern
    }

    public func getNegativeSuffix(): String {
        return negativeSuffix
    }

    public func getNegativeSuffixPattern(): String {
        return negativeSuffixPattern
    }

    public func getPadPosition(): Padder_PadPosition {
        return padPosition
    }

    public func getPadString(): String {
        return padString
    }

    public func getParseCaseSensitive(): Bool {
        return parseCaseSensitive
    }

    public func getParseIntegerOnly(): Bool {
        return parseIntegerOnly
    }

    public func getParseMode(): DecimalFormatProperties_ParseMode {
        return parseMode
    }

    public func getParseNoExponent(): Bool {
        return parseNoExponent
    }

    public func getParseToBigDecimal(): Bool {
        return parseToBigDecimal
    }

    public func getPluralRules(): PluralRules {
        return pluralRules
    }

    public func getPositivePrefix(): String {
        return positivePrefix
    }

    public func getPositivePrefixPattern(): String {
        return positivePrefixPattern
    }

    public func getPositiveSuffix(): String {
        return positiveSuffix
    }

    public func getPositiveSuffixPattern(): String {
        return positiveSuffixPattern
    }

    public func getRoundingIncrement(): BigDecimal {
        return roundingIncrement
    }

    public func getRoundingMode(): RoundingMode {
        return roundingMode
    }

    public func getSecondaryGroupingSize(): Int32 {
        return secondaryGroupingSize
    }

    public func getSignAlwaysShown(): Bool {
        return signAlwaysShown
    }

    public override func hashCode(): Int64 {
        return Int64(_hashCode())
    }

    private func readObject(ois: ObjectInputStream): Unit {
        readObjectImpl(ois)
    }

    public func readObjectImpl(ois: ObjectInputStream): Unit {
        ois.defaultReadObject()
        clear()
        ois.readInt()
        let count = ois.readInt()
        var i = 0
        while (i < count) {
            let name = ois.readObject()
            let value = ois.readObject()
            var field: Field = None
            try {
                field = TypeInfo.of<DecimalFormatProperties>().getDeclaredField(name)
            } catch (e: NoSuchFieldException) {
                continue
            } catch (e: SecurityException) {
                throw AssertionError(e)
            }
            try {
                field.set(this, value)
            } catch (e: IllegalArgumentException) {
                throw AssertionError(e)
            } catch (e: IllegalAccessException) {
                throw AssertionError(e)
            }
            i++
        }
    }

    public func setCompactCustomData(compactCustomData: Map<String, Map<String, String>>): DecimalFormatProperties {
        this.compactCustomData = compactCustomData
        return this
    }

    public func setCompactStyle(compactStyle: CompactDecimalFormat_CompactStyle): DecimalFormatProperties {
        this.compactStyle = compactStyle
        return this
    }

    public func setCurrency(currency: Currency): DecimalFormatProperties {
        this.currency = currency
        return this
    }

    public func setCurrencyPluralInfo(currencyPluralInfo: CurrencyPluralInfo): DecimalFormatProperties {
        var tempcurrencyPluralInfo = currencyPluralInfo
        if (tempcurrencyPluralInfo.isSome()) {
            tempcurrencyPluralInfo = tempcurrencyPluralInfo.clone()
        }
        this.currencyPluralInfo = tempcurrencyPluralInfo
        return this
    }

    public func setCurrencyUsage(currencyUsage: Currency_CurrencyUsage): DecimalFormatProperties {
        this.currencyUsage = currencyUsage
        return this
    }

    public func setDecimalPatternMatchRequired(decimalPatternMatchRequired: Bool): DecimalFormatProperties {
        this.decimalPatternMatchRequired = decimalPatternMatchRequired
        return this
    }

    public func setDecimalSeparatorAlwaysShown(alwaysShowDecimal: Bool): DecimalFormatProperties {
        this.decimalSeparatorAlwaysShown = alwaysShowDecimal
        return this
    }

    public func setExponentSignAlwaysShown(exponentSignAlwaysShown: Bool): DecimalFormatProperties {
        this.exponentSignAlwaysShown = exponentSignAlwaysShown
        return this
    }

    public func setCurrencyAsDecimal(currencyAsDecimal: Bool): DecimalFormatProperties {
        this.currencyAsDecimal = currencyAsDecimal
        return this
    }

    public func setFormatWidth(paddingWidth: Int32): DecimalFormatProperties {
        this.formatWidth = paddingWidth
        return this
    }

    public func setGroupingSize(groupingSize: Int32): DecimalFormatProperties {
        this.groupingSize = groupingSize
        return this
    }

    public func setGroupingUsed(groupingUsed: Bool): DecimalFormatProperties {
        this.groupingUsed = groupingUsed
        return this
    }

    public func setMagnitudeMultiplier(magnitudeMultiplier: Int32): DecimalFormatProperties {
        this.magnitudeMultiplier = magnitudeMultiplier
        return this
    }

    public func setMathContext(mathContext: MathContext): DecimalFormatProperties {
        this.mathContext = mathContext
        return this
    }

    public func setMaximumFractionDigits(maximumFractionDigits: Int32): DecimalFormatProperties {
        this.maximumFractionDigits = maximumFractionDigits
        return this
    }

    public func setMaximumIntegerDigits(maximumIntegerDigits: Int32): DecimalFormatProperties {
        this.maximumIntegerDigits = maximumIntegerDigits
        return this
    }

    public func setMaximumSignificantDigits(maximumSignificantDigits: Int32): DecimalFormatProperties {
        this.maximumSignificantDigits = maximumSignificantDigits
        return this
    }

    public func setMinimumExponentDigits(minimumExponentDigits: Int32): DecimalFormatProperties {
        this.minimumExponentDigits = minimumExponentDigits
        return this
    }

    public func setMinimumFractionDigits(minimumFractionDigits: Int32): DecimalFormatProperties {
        this.minimumFractionDigits = minimumFractionDigits
        return this
    }

    public func setMinimumGroupingDigits(minimumGroupingDigits: Int32): DecimalFormatProperties {
        this.minimumGroupingDigits = minimumGroupingDigits
        return this
    }

    public func setMinimumIntegerDigits(minimumIntegerDigits: Int32): DecimalFormatProperties {
        this.minimumIntegerDigits = minimumIntegerDigits
        return this
    }

    public func setMinimumSignificantDigits(minimumSignificantDigits: Int32): DecimalFormatProperties {
        this.minimumSignificantDigits = minimumSignificantDigits
        return this
    }

    public func setMultiplier(multiplier: BigDecimal): DecimalFormatProperties {
        this.multiplier = multiplier
        return this
    }

    public func setNegativePrefix(negativePrefix: String): DecimalFormatProperties {
        this.negativePrefix = negativePrefix
        return this
    }

    public func setNegativePrefixPattern(negativePrefixPattern: String): DecimalFormatProperties {
        this.negativePrefixPattern = negativePrefixPattern
        return this
    }

    public func setNegativeSuffix(negativeSuffix: String): DecimalFormatProperties {
        this.negativeSuffix = negativeSuffix
        return this
    }

    public func setNegativeSuffixPattern(negativeSuffixPattern: String): DecimalFormatProperties {
        this.negativeSuffixPattern = negativeSuffixPattern
        return this
    }

    public func setPadPosition(paddingLocation: Padder_PadPosition): DecimalFormatProperties {
        this.padPosition = paddingLocation
        return this
    }

    public func setPadString(paddingString: String): DecimalFormatProperties {
        this.padString = paddingString
        return this
    }

    public func setParseCaseSensitive(parseCaseSensitive: Bool): DecimalFormatProperties {
        this.parseCaseSensitive = parseCaseSensitive
        return this
    }

    public func setParseIntegerOnly(parseIntegerOnly: Bool): DecimalFormatProperties {
        this.parseIntegerOnly = parseIntegerOnly
        return this
    }

    public func setParseMode(parseMode: DecimalFormatProperties_ParseMode): DecimalFormatProperties {
        this.parseMode = parseMode
        return this
    }

    public func setParseNoExponent(parseNoExponent: Bool): DecimalFormatProperties {
        this.parseNoExponent = parseNoExponent
        return this
    }

    public func setParseToBigDecimal(parseToBigDecimal: Bool): DecimalFormatProperties {
        this.parseToBigDecimal = parseToBigDecimal
        return this
    }

    public func setPluralRules(pluralRules: PluralRules): DecimalFormatProperties {
        this.pluralRules = pluralRules
        return this
    }

    public func setPositivePrefix(positivePrefix: String): DecimalFormatProperties {
        this.positivePrefix = positivePrefix
        return this
    }

    public func setPositivePrefixPattern(positivePrefixPattern: String): DecimalFormatProperties {
        this.positivePrefixPattern = positivePrefixPattern
        return this
    }

    public func setPositiveSuffix(positiveSuffix: String): DecimalFormatProperties {
        this.positiveSuffix = positiveSuffix
        return this
    }

    public func setPositiveSuffixPattern(positiveSuffixPattern: String): DecimalFormatProperties {
        this.positiveSuffixPattern = positiveSuffixPattern
        return this
    }

    public func setRoundingIncrement(roundingIncrement: BigDecimal): DecimalFormatProperties {
        this.roundingIncrement = roundingIncrement
        return this
    }

    public func setRoundingMode(roundingMode: RoundingMode): DecimalFormatProperties {
        this.roundingMode = roundingMode
        return this
    }

    public func setSecondaryGroupingSize(secondaryGroupingSize: Int32): DecimalFormatProperties {
        this.secondaryGroupingSize = secondaryGroupingSize
        return this
    }

    public func setSignAlwaysShown(signAlwaysShown: Bool): DecimalFormatProperties {
        this.signAlwaysShown = signAlwaysShown
        return this
    }

    public override func toString(): String {
        let result = StringBuilder()
        result.append("<Properties")
        toStringBare(result)
        result.append(">")
        return result.toString()
    }

    public func toStringBare(result: StringBuilder): Unit {
        let fields = TypeInfo.of<DecimalFormatProperties>().getDeclaredFields()
        for (field in fields) {
            let myValue: Object
            let defaultValue: Object
            try {
                myValue = field.get(this)
                defaultValue = field.get(DEFAULT)
            } catch (e: IllegalArgumentException) {
                e.printStackTrace()
                continue
            } catch (e: IllegalAccessException) {
                e.printStackTrace()
                continue
            }
            if (myValue.isNone() && defaultValue.isNone()) {
                continue
            } else if (myValue.isNone() || defaultValue.isNone()) {
                result.append(" " + (field.getName()) + ":" + toString(myValue))
            } else if (!refEq(myValue, defaultValue)) {
                result.append(" " + (field.getName()) + ":" + toString(myValue))
            }
        }
    }

    private func writeObject(oos: ObjectOutputStream): Unit {
        writeObjectImpl(oos)
    }

    public func writeObjectImpl(oos: ObjectOutputStream): Unit {
        oos.defaultWriteObject()
        oos.writeInt(0)
        let fieldsToSerialize = ArrayList<Field>()
        let valuesToSerialize = ArrayList<Object>()
        let fields = TypeInfo.of<DecimalFormatProperties>().getDeclaredFields()
        for (field in fields) {
            if (Modifier.isStatic(field.getModifiers())) {
                continue
            }
            try {
                let myValue = field.get(this)
                if (myValue.isNone()) {
                    continue
                }
                let defaultValue = field.get(DEFAULT)
                if (!refEq(myValue, defaultValue)) {
                    fieldsToSerialize.append(field)
                    valuesToSerialize.append(myValue)
                }
            } catch (e: IllegalArgumentException) {
                throw AssertionError(e)
            } catch (e: IllegalAccessException) {
                throw AssertionError(e)
            }
        }
        let count = Int32(fieldsToSerialize.size)
        oos.writeInt(count)
        var i = 0
        while (i < count) {
            let field = fieldsToSerialize[Int64(i)]
            let value = valuesToSerialize[Int64(i)]
            oos.writeObject(field.getName())
            oos.writeObject(value)
            i++
        }
    }
}


public class DecimalFormatProperties_ParseMode <: Enum<DecimalFormatProperties_ParseMode> {
    public static let LENIENT = DecimalFormatProperties_ParseMode("LENIENT", 0)

    public static let STRICT = DecimalFormatProperties_ParseMode("STRICT", 1)

    public static let JAVA_COMPATIBILITY = DecimalFormatProperties_ParseMode("JAVA_COMPATIBILITY", 2)

    private static func _values(): Array<DecimalFormatProperties_ParseMode> {
        return [DecimalFormatProperties_ParseMode.LENIENT, DecimalFormatProperties_ParseMode.STRICT, DecimalFormatProperties_ParseMode.JAVA_COMPATIBILITY]
    }

    private static let _VALUES = DecimalFormatProperties_ParseMode._values()

    public static func values(): Array<DecimalFormatProperties_ParseMode> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DecimalFormatProperties_ParseMode {
        return (TypeInfo.of<DecimalFormatProperties_ParseMode>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DecimalFormatProperties_ParseMode
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
