package icu4cj.text


public class DecimalFormat <: NumberFormat & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private static let serialVersionUID = 864413376551465018

    private let serialVersionOnStream = 5

     var properties: DecimalFormatProperties

      var symbols: DecimalFormatSymbols

      var formatter: LocalizedNumberFormatter

      var exportedProperties: DecimalFormatProperties

      var parser: NumberParserImpl

      var currencyParser: NumberParserImpl

    public init() {
        super()
        let def = ULocale.getDefault(ULocale_Category.FORMAT)
        let pattern = getPattern(def, NumberFormat.NUMBERSTYLE)
        symbols = getDefaultSymbols()
        properties = DecimalFormatProperties()
        exportedProperties = DecimalFormatProperties()
        setPropertiesFromPattern(pattern, PatternStringParser.IGNORE_ROUNDING_IF_CURRENCY)
        refreshFormatter()
    }

    public init(pattern: String) {
        super()
        symbols = getDefaultSymbols()
        properties = DecimalFormatProperties()
        exportedProperties = DecimalFormatProperties()
        setPropertiesFromPattern(pattern, PatternStringParser.IGNORE_ROUNDING_IF_CURRENCY)
        refreshFormatter()
    }

    public init(pattern: String, symbols: DecimalFormatSymbols) {
        super()
        this.symbols = symbols.clone()
        properties = DecimalFormatProperties()
        exportedProperties = DecimalFormatProperties()
        setPropertiesFromPattern(pattern, PatternStringParser.IGNORE_ROUNDING_IF_CURRENCY)
        refreshFormatter()
    }

    public init(pattern: String, symbols: DecimalFormatSymbols, infoInput: CurrencyPluralInfo, style: Int32) {
        this(pattern, symbols, style)
        properties.setCurrencyPluralInfo(infoInput)
        refreshFormatter()
    }

    init(pattern: String, symbols: DecimalFormatSymbols, choice: Int32) {
        super()
        this.symbols = symbols.clone()
        properties = DecimalFormatProperties()
        exportedProperties = DecimalFormatProperties()
        if (choice == CURRENCYSTYLE || choice == ISOCURRENCYSTYLE || choice == ACCOUNTINGCURRENCYSTYLE || choice == CASHCURRENCYSTYLE || choice == STANDARDCURRENCYSTYLE || choice == PLURALCURRENCYSTYLE) {
            setPropertiesFromPattern(pattern, PatternStringParser.IGNORE_ROUNDING_ALWAYS)
        } else {
            setPropertiesFromPattern(pattern, PatternStringParser.IGNORE_ROUNDING_IF_CURRENCY)
        }
        refreshFormatter()
    }

    private static func getDefaultSymbols(): DecimalFormatSymbols {
        return DecimalFormatSymbols.getInstance()
    }

    public func applyPattern(pattern: String): Unit {
        synchronized (GeneratedLockObject) {
            setPropertiesFromPattern(pattern, PatternStringParser.IGNORE_ROUNDING_NEVER)
            properties.setPositivePrefix(None)
            properties.setNegativePrefix(None)
            properties.setPositiveSuffix(None)
            properties.setNegativeSuffix(None)
            properties.setCurrencyPluralInfo(None)
            refreshFormatter()
        }
    }

    public func applyLocalizedPattern(localizedPattern: String): Unit {
        synchronized (GeneratedLockObject) {
            let pattern = PatternStringUtils.convertLocalized(localizedPattern, symbols, false)
            applyPattern(pattern)
        }
    }

    public override func clone(): Object {
        let other = super.clone()
        other.symbols = symbols.clone()
        other.properties = properties.clone()
        other.exportedProperties = DecimalFormatProperties()
        other.refreshFormatter()
        return other
    }

    private func writeObject(oos: ObjectOutputStream): Unit {
        synchronized (GeneratedLockObject) {
            oos.defaultWriteObject()
            oos.writeInt(0)
            oos.writeObject(properties)
            oos.writeObject(symbols)
        }
    }

    private func readObject(ois: ObjectInputStream): Unit {
        let fieldGetter = ois.readFields()
        let serializedFields = fieldGetter.getObjectStreamClass().getFields()
        let serialVersion = fieldGetter.get("serialVersionOnStream", -1)
        if (serialVersion > 5) {
            throw IOException("Cannot deserialize newer com.ibm.icu.text.DecimalFormat (v" + serialVersion.toString() + ")")
        } else if (serialVersion == 5) {
            if (Int32(serializedFields.size) > 1) {
                throw IOException("Too many fields when reading serial version 5")
            }
            ois.readInt()
            let serializedProperties = ois.readObject()
            if (checkOptionalIs<DecimalFormatProperties, Object>(serializedProperties)) {
                properties = serializedProperties
            } else {
                properties = serializedProperties.getInstance()
            }
            symbols = ois.readObject()
            exportedProperties = DecimalFormatProperties()
            refreshFormatter()
        } else {
            properties = DecimalFormatProperties()
            var pp: String
            var ppp: String
            var ps: String
            var psp: String
            var np: String
            var npp: String
            var ns: String
            var nsp: String
            for (field in serializedFields) {
                let name = field.getName()
                if (name == "decimalSeparatorAlwaysShown") {
                    setDecimalSeparatorAlwaysShown(fieldGetter.get("decimalSeparatorAlwaysShown", false))
                } else if (name == "exponentSignAlwaysShown") {
                    setExponentSignAlwaysShown(fieldGetter.get("exponentSignAlwaysShown", false))
                } else if (name == "formatWidth") {
                    setFormatWidth(fieldGetter.get("formatWidth", 0))
                } else if (name == "groupingSize") {
                    setGroupingSize(Int32(fieldGetter.get("groupingSize", 3)))
                } else if (name == "groupingSize2") {
                    setSecondaryGroupingSize(Int32(fieldGetter.get("groupingSize2", 0)))
                } else if (name == "maxSignificantDigits") {
                    setMaximumSignificantDigits(fieldGetter.get("maxSignificantDigits", 6))
                } else if (name == "minExponentDigits") {
                    setMinimumExponentDigits(fieldGetter.get("minExponentDigits", 0))
                } else if (name == "minSignificantDigits") {
                    setMinimumSignificantDigits(fieldGetter.get("minSignificantDigits", 1))
                } else if (name == "multiplier") {
                    setMultiplier(fieldGetter.get("multiplier", 1))
                } else if (name == "pad") {
                    setPadCharacter(fieldGetter.get("pad", ' '))
                } else if (name == "padPosition") {
                    setPadPosition(fieldGetter.get("padPosition", 0))
                } else if (name == "parseBigDecimal") {
                    setParseBigDecimal(fieldGetter.get("parseBigDecimal", false))
                } else if (name == "parseRequireDecimalPoint") {
                    setDecimalPatternMatchRequired(fieldGetter.get("parseRequireDecimalPoint", false))
                } else if (name == "roundingMode") {
                    setRoundingMode(fieldGetter.get("roundingMode", 0))
                } else if (name == "useExponentialNotation") {
                    setScientificNotation(fieldGetter.get("useExponentialNotation", false))
                } else if (name == "useSignificantDigits") {
                    setSignificantDigitsUsed(fieldGetter.get("useSignificantDigits", false))
                } else if (name == "currencyPluralInfo") {
                    setCurrencyPluralInfo(fieldGetter.get("currencyPluralInfo", None))
                } else if (name == "mathContext") {
                    setMathContextICU(fieldGetter.get("mathContext", None))
                } else if (name == "negPrefixPattern") {
                    npp = fieldGetter.get("negPrefixPattern", None)
                } else if (name == "negSuffixPattern") {
                    nsp = fieldGetter.get("negSuffixPattern", None)
                } else if (name == "negativePrefix") {
                    np = fieldGetter.get("negativePrefix", None)
                } else if (name == "negativeSuffix") {
                    ns = fieldGetter.get("negativeSuffix", None)
                } else if (name == "posPrefixPattern") {
                    ppp = fieldGetter.get("posPrefixPattern", None)
                } else if (name == "posSuffixPattern") {
                    psp = fieldGetter.get("posSuffixPattern", None)
                } else if (name == "positivePrefix") {
                    pp = fieldGetter.get("positivePrefix", None)
                } else if (name == "positiveSuffix") {
                    ps = fieldGetter.get("positiveSuffix", None)
                } else if (name == "roundingIncrement") {
                    setRoundingIncrement(fieldGetter.get("roundingIncrement", None))
                } else if (name == "symbols") {
                    setDecimalFormatSymbols(fieldGetter.get("symbols", None))
                } else { }
            }
            if (npp.isNone()) {
                properties.setNegativePrefix(np)
            } else {
                properties.setNegativePrefixPattern(npp)
            }
            if (nsp.isNone()) {
                properties.setNegativeSuffix(ns)
            } else {
                properties.setNegativeSuffixPattern(nsp)
            }
            if (ppp.isNone()) {
                properties.setPositivePrefix(pp)
            } else {
                properties.setPositivePrefixPattern(ppp)
            }
            if (psp.isNone()) {
                properties.setPositiveSuffix(ps)
            } else {
                properties.setPositiveSuffixPattern(psp)
            }
            var getter: Field = None
            try {
                getter = TypeInfo.of<NumberFormat>().getDeclaredField("groupingUsed")
                getter.setAccessible(true)
                setGroupingUsed(getter.get(this).booleanValue())
                getter = TypeInfo.of<NumberFormat>().getDeclaredField("parseIntegerOnly")
                getter.setAccessible(true)
                setParseIntegerOnly(getter.get(this).booleanValue())
                getter = TypeInfo.of<NumberFormat>().getDeclaredField("maximumIntegerDigits")
                getter.setAccessible(true)
                setMaximumIntegerDigits(getter.get(this))
                getter = TypeInfo.of<NumberFormat>().getDeclaredField("minimumIntegerDigits")
                getter.setAccessible(true)
                setMinimumIntegerDigits(getter.get(this))
                getter = TypeInfo.of<NumberFormat>().getDeclaredField("maximumFractionDigits")
                getter.setAccessible(true)
                setMaximumFractionDigits(getter.get(this))
                getter = TypeInfo.of<NumberFormat>().getDeclaredField("minimumFractionDigits")
                getter.setAccessible(true)
                setMinimumFractionDigits(getter.get(this))
                getter = TypeInfo.of<NumberFormat>().getDeclaredField("currency")
                getter.setAccessible(true)
                setCurrency(getter.get(this))
                getter = TypeInfo.of<NumberFormat>().getDeclaredField("parseStrict")
                getter.setAccessible(true)
                setParseStrict(getter.get(this).booleanValue())
            } catch (e: IllegalArgumentException) {
                throw IOException()
            } catch (e: IllegalAccessException) {
                throw IOException()
            } catch (e: NoSuchFieldException) {
                throw IOException()
            } catch (e: SecurityException) {
                throw IOException()
            }
            if (symbols.isNone()) {
                symbols = getDefaultSymbols()
            }
            exportedProperties = DecimalFormatProperties()
            refreshFormatter()
        }
    }

    public override func format(number: Float64, result: StringBuffer, fieldPosition: FieldPosition): StringBuffer {
        let dq: DecimalQuantity = DecimalQuantity_DualStorageBCD(number)
        let string = FormattedStringBuilder()
        formatter.formatImpl(dq, string)
        fieldPositionHelper(dq, string, fieldPosition, Int32(result.size))
        Utility.appendTo(string, result)
        return result
    }

    public override func format(number: Int64, result: StringBuffer, fieldPosition: FieldPosition): StringBuffer {
        let dq: DecimalQuantity = DecimalQuantity_DualStorageBCD(number)
        let string = FormattedStringBuilder()
        formatter.formatImpl(dq, string)
        fieldPositionHelper(dq, string, fieldPosition, Int32(result.size))
        Utility.appendTo(string, result)
        return result
    }

    public override func format(number: BigInt, result: StringBuffer, fieldPosition: FieldPosition): StringBuffer {
        let dq: DecimalQuantity = DecimalQuantity_DualStorageBCD(number)
        let string = FormattedStringBuilder()
        formatter.formatImpl(dq, string)
        fieldPositionHelper(dq, string, fieldPosition, Int32(result.size))
        Utility.appendTo(string, result)
        return result
    }

    public override func format(number: BigDecimal, result: StringBuffer, fieldPosition: FieldPosition): StringBuffer {
        let dq: DecimalQuantity = DecimalQuantity_DualStorageBCD(number)
        let string = FormattedStringBuilder()
        formatter.formatImpl(dq, string)
        fieldPositionHelper(dq, string, fieldPosition, Int32(result.size))
        Utility.appendTo(string, result)
        return result
    }

    public override func format(number: BigDecimal, result: StringBuffer, fieldPosition: FieldPosition): StringBuffer {
        let dq: DecimalQuantity = DecimalQuantity_DualStorageBCD(number)
        let string = FormattedStringBuilder()
        formatter.formatImpl(dq, string)
        fieldPositionHelper(dq, string, fieldPosition, Int32(result.size))
        Utility.appendTo(string, result)
        return result
    }

    public override func formatToCharacterIterator(obj: Object): AttributedCharacterIterator {
        if (!(checkOptionalIs<Number, Object>(obj))) {
            throw IllegalArgumentException()
        }
        let number = obj
        let output = formatter.format(number)
        return output.toCharacterIterator()
    }

    public override func format(currAmt: CurrencyAmount, result: StringBuffer, fieldPosition: FieldPosition): StringBuffer {
        let localSymbols = symbols.clone()
        localSymbols.setCurrency(currAmt.getCurrency())
        let dq: DecimalQuantity = DecimalQuantity_DualStorageBCD(currAmt.getNumber())
        let string = FormattedStringBuilder()
        formatter.symbols(localSymbols).unit(currAmt.getCurrency()).formatImpl(dq, string)
        fieldPositionHelper(dq, string, fieldPosition, Int32(result.size))
        Utility.appendTo(string, result)
        return result
    }

    public override func parse(text: String, parsePosition: ParsePosition): Number {
        var tempparsePosition = parsePosition
        if (text.isNone()) {
            throw IllegalArgumentException("Text cannot be null")
        }
        if (tempparsePosition.isNone()) {
            tempparsePosition = ParsePosition(0)
        }
        if (tempparsePosition.getIndex() < 0) {
            throw IllegalArgumentException("Cannot start parsing at a negative offset")
        }
        if (tempparsePosition.getIndex() >= Int32(text.size)) {
            return None
        }
        let result = ParsedNumber()
        let startIndex = tempparsePosition.getIndex()
        let parser = getParser()
        parser.parse(text, startIndex, true, result)
        if (result.success()) {
            tempparsePosition.setIndex(result.charEnd)
            var number = result.getNumber(parser.getParseFlags())
            if (checkOptionalIs<BigDecimal, Number>(number)) {
                number = safeConvertBigDecimal(number)
            }
            return number
        } else {
            tempparsePosition.setErrorIndex(startIndex + result.charEnd)
            return None
        }
    }

    public override func parseCurrency(text: String, parsePosition: ParsePosition): CurrencyAmount {
        var tempparsePosition = parsePosition
        if (text.isNone()) {
            throw IllegalArgumentException("Text cannot be null")
        }
        if (tempparsePosition.isNone()) {
            tempparsePosition = ParsePosition(0)
        }
        if (tempparsePosition.getIndex() < 0) {
            throw IllegalArgumentException("Cannot start parsing at a negative offset")
        }
        if (tempparsePosition.getIndex() >= text.size) {
            return None
        }
        let result = ParsedNumber()
        let startIndex = tempparsePosition.getIndex()
        let parser = getCurrencyParser()
        parser.parse(toString(text), startIndex, true, result)
        if (result.success()) {
            tempparsePosition.setIndex(result.charEnd)
            var number = result.getNumber(parser.getParseFlags())
            if (checkOptionalIs<BigDecimal, Number>(number)) {
                number = safeConvertBigDecimal(number)
            }
            let currency = Currency.getInstance(result.currencyCode)
            return CurrencyAmount(number, currency)
        } else {
            tempparsePosition.setErrorIndex(startIndex + result.charEnd)
            return None
        }
    }

    public func getDecimalFormatSymbols(): DecimalFormatSymbols {
        synchronized (GeneratedLockObject) {
            return symbols.clone()
        }
    }

    public func setDecimalFormatSymbols(newSymbols: DecimalFormatSymbols): Unit {
        synchronized (GeneratedLockObject) {
            symbols = newSymbols.clone()
            refreshFormatter()
        }
    }

    public func getPositivePrefix(): String {
        synchronized (GeneratedLockObject) {
            return formatter.getAffixImpl(true, false)
        }
    }

    public func setPositivePrefix(prefix: String): Unit {
        synchronized (GeneratedLockObject) {
            if (prefix.isNone()) {
                throw NoneValueException()
            }
            properties.setPositivePrefix(prefix)
            refreshFormatter()
        }
    }

    public func getNegativePrefix(): String {
        synchronized (GeneratedLockObject) {
            return formatter.getAffixImpl(true, true)
        }
    }

    public func setNegativePrefix(prefix: String): Unit {
        synchronized (GeneratedLockObject) {
            if (prefix.isNone()) {
                throw NoneValueException()
            }
            properties.setNegativePrefix(prefix)
            refreshFormatter()
        }
    }

    public func getPositiveSuffix(): String {
        synchronized (GeneratedLockObject) {
            return formatter.getAffixImpl(false, false)
        }
    }

    public func setPositiveSuffix(suffix: String): Unit {
        synchronized (GeneratedLockObject) {
            if (suffix.isNone()) {
                throw NoneValueException()
            }
            properties.setPositiveSuffix(suffix)
            refreshFormatter()
        }
    }

    public func getNegativeSuffix(): String {
        synchronized (GeneratedLockObject) {
            return formatter.getAffixImpl(false, true)
        }
    }

    public func setNegativeSuffix(suffix: String): Unit {
        synchronized (GeneratedLockObject) {
            if (suffix.isNone()) {
                throw NoneValueException()
            }
            properties.setNegativeSuffix(suffix)
            refreshFormatter()
        }
    }

    public func isSignAlwaysShown(): Bool {
        synchronized (GeneratedLockObject) {
            return properties.getSignAlwaysShown()
        }
    }

    public func setSignAlwaysShown(value: Bool): Unit {
        synchronized (GeneratedLockObject) {
            properties.setSignAlwaysShown(value)
            refreshFormatter()
        }
    }

    public func getMultiplier(): Int32 {
        synchronized (GeneratedLockObject) {
            if (properties.getMultiplier().isSome()) {
                return properties.getMultiplier().intValue()
            } else {
                return Int32(Math.pow(10.0, Float64(properties.getMagnitudeMultiplier())))
            }
        }
    }

    public func setMultiplier(multiplier: Int32): Unit {
        synchronized (GeneratedLockObject) {
            if (multiplier == 0) {
                throw IllegalArgumentException("Multiplier must be nonzero.")
            }
            var delta = 0
            var value = multiplier
            while (value != 1) {
                delta++
                let temp = value / 10
                if (temp * 10 != value) {
                    delta = -1
                    break
                }
                value = temp
            }
            if (delta != -1) {
                properties.setMagnitudeMultiplier(delta)
                properties.setMultiplier(None)
            } else {
                properties.setMagnitudeMultiplier(0)
                properties.setMultiplier(BigDecimal.valueOf(Int64(multiplier)))
            }
            refreshFormatter()
        }
    }

    public func getRoundingIncrement(): BigDecimal {
        synchronized (GeneratedLockObject) {
            return exportedProperties.getRoundingIncrement()
        }
    }

    public func setRoundingIncrement(increment: BigDecimal): Unit {
        synchronized (GeneratedLockObject) {
            if (increment.isSome() && increment.compare(<--.ZERO) : Any => Int32 --> == 0) {
                properties.setMaximumFractionDigits(Int32.Max)
                return
            }
            properties.setRoundingIncrement(increment)
            refreshFormatter()
        }
    }

    public func setRoundingIncrement(increment: BigDecimal): Unit {
        synchronized (GeneratedLockObject) {
            let javaBigDecimal: BigDecimal = if (increment.isNone()) { None } else { increment.toBigDecimal() }
            setRoundingIncrement(javaBigDecimal)
        }
    }

    public func setRoundingIncrement(increment: Float64): Unit {
        synchronized (GeneratedLockObject) {
            if (increment == 0.0) {
                setRoundingIncrement(None)
            } else {
                let javaBigDecimal = BigDecimal.valueOf(increment).stripTrailingZeros()
                setRoundingIncrement(javaBigDecimal)
            }
        }
    }

    public override func getRoundingMode(): Int32 {
        synchronized (GeneratedLockObject) {
            let mode = exportedProperties.getRoundingMode()
            return if (mode.isNone()) { 0 } else { mode.ordinal() }
        }
    }

    public override func setRoundingMode(roundingMode: Int32): Unit {
        synchronized (GeneratedLockObject) {
            properties.setRoundingMode(RoundingMode.valueOf(roundingMode))
            refreshFormatter()
        }
    }

    public func getMathContext(): MathContext {
        synchronized (GeneratedLockObject) {
            let mathContext = exportedProperties.getMathContext()
            if (!mathContext.isSome()) {
                throw AssertionError()
            }
            return mathContext
        }
    }

    public func setMathContext(mathContext: MathContext): Unit {
        synchronized (GeneratedLockObject) {
            properties.setMathContext(mathContext)
            refreshFormatter()
        }
    }

     private var icuMathContextForm = MathContext.PLAIN

    public func getMathContextICU(): MathContext {
        synchronized (GeneratedLockObject) {
            let mathContext = getMathContext()
            return MathContext(mathContext.getPrecision(), icuMathContextForm, false, mathContext.getRoundingMode().ordinal())
        }
    }

    public func setMathContextICU(mathContextICU: MathContext): Unit {
        synchronized (GeneratedLockObject) {
            icuMathContextForm = mathContextICU.getForm()
            let mathContext: MathContext
            if (mathContextICU.getLostDigits()) {
                mathContext = MathContext(mathContextICU.getDigits(), RoundingMode.UNNECESSARY)
            } else {
                mathContext = MathContext(mathContextICU.getDigits(), RoundingMode.valueOf(mathContextICU.getRoundingMode()))
            }
            setMathContext(mathContext)
        }
    }

    public override func getMinimumIntegerDigits(): Int32 {
        synchronized (GeneratedLockObject) {
            return exportedProperties.getMinimumIntegerDigits()
        }
    }

    public override func setMinimumIntegerDigits(value: Int32): Unit {
        synchronized (GeneratedLockObject) {
            let max = properties.getMaximumIntegerDigits()
            if (max >= 0 && max < value) {
                properties.setMaximumIntegerDigits(value)
            }
            properties.setMinimumIntegerDigits(value)
            refreshFormatter()
        }
    }

    public override func getMaximumIntegerDigits(): Int32 {
        synchronized (GeneratedLockObject) {
            return exportedProperties.getMaximumIntegerDigits()
        }
    }

    public override func setMaximumIntegerDigits(value: Int32): Unit {
        synchronized (GeneratedLockObject) {
            let min = properties.getMinimumIntegerDigits()
            if (min >= 0 && min > value) {
                properties.setMinimumIntegerDigits(value)
            }
            properties.setMaximumIntegerDigits(value)
            refreshFormatter()
        }
    }

    public override func getMinimumFractionDigits(): Int32 {
        synchronized (GeneratedLockObject) {
            return exportedProperties.getMinimumFractionDigits()
        }
    }

    public override func setMinimumFractionDigits(value: Int32): Unit {
        synchronized (GeneratedLockObject) {
            let max = properties.getMaximumFractionDigits()
            if (max >= 0 && max < value) {
                properties.setMaximumFractionDigits(value)
            }
            properties.setMinimumFractionDigits(value)
            refreshFormatter()
        }
    }

    public override func getMaximumFractionDigits(): Int32 {
        synchronized (GeneratedLockObject) {
            return exportedProperties.getMaximumFractionDigits()
        }
    }

    public override func setMaximumFractionDigits(value: Int32): Unit {
        synchronized (GeneratedLockObject) {
            let min = properties.getMinimumFractionDigits()
            if (min >= 0 && min > value) {
                properties.setMinimumFractionDigits(value)
            }
            properties.setMaximumFractionDigits(value)
            refreshFormatter()
        }
    }

    public func areSignificantDigitsUsed(): Bool {
        synchronized (GeneratedLockObject) {
            return properties.getMinimumSignificantDigits() != -1 || properties.getMaximumSignificantDigits() != -1
        }
    }

    public func setSignificantDigitsUsed(useSignificantDigits: Bool): Unit {
        synchronized (GeneratedLockObject) {
            let oldMinSig = properties.getMinimumSignificantDigits()
            let oldMaxSig = properties.getMaximumSignificantDigits()
            if (useSignificantDigits) {
                if (oldMinSig != -1 || oldMaxSig != -1) {
                    return
                }
            } else {
                if (oldMinSig == -1 && oldMaxSig == -1) {
                    return
                }
            }
            let minSig = if (useSignificantDigits) { 1 } else { -1 }
            let maxSig = if (useSignificantDigits) { 6 } else { -1 }
            properties.setMinimumSignificantDigits(minSig)
            properties.setMaximumSignificantDigits(maxSig)
            refreshFormatter()
        }
    }

    public func getMinimumSignificantDigits(): Int32 {
        synchronized (GeneratedLockObject) {
            return exportedProperties.getMinimumSignificantDigits()
        }
    }

    public func setMinimumSignificantDigits(value: Int32): Unit {
        synchronized (GeneratedLockObject) {
            let max = properties.getMaximumSignificantDigits()
            if (max >= 0 && max < value) {
                properties.setMaximumSignificantDigits(value)
            }
            properties.setMinimumSignificantDigits(value)
            refreshFormatter()
        }
    }

    public func getMaximumSignificantDigits(): Int32 {
        synchronized (GeneratedLockObject) {
            return exportedProperties.getMaximumSignificantDigits()
        }
    }

    public func setMaximumSignificantDigits(value: Int32): Unit {
        synchronized (GeneratedLockObject) {
            let min = properties.getMinimumSignificantDigits()
            if (min >= 0 && min > value) {
                properties.setMinimumSignificantDigits(value)
            }
            properties.setMaximumSignificantDigits(value)
            refreshFormatter()
        }
    }

    public func getFormatWidth(): Int32 {
        synchronized (GeneratedLockObject) {
            return properties.getFormatWidth()
        }
    }

    public func setFormatWidth(width: Int32): Unit {
        synchronized (GeneratedLockObject) {
            properties.setFormatWidth(width)
            refreshFormatter()
        }
    }

    public func getPadCharacter(): Char {
        synchronized (GeneratedLockObject) {
            let paddingString = properties.getPadString()
            if (paddingString.isNone()) {
                return Char(Padder.FALLBACK_PADDING_STRING[0])
            } else {
                return paddingString[0]
            }
        }
    }

    public func setPadCharacter(padChar: Char): Unit {
        synchronized (GeneratedLockObject) {
            properties.setPadString(Character.toString(padChar))
            refreshFormatter()
        }
    }

    public func getPadPosition(): Int32 {
        synchronized (GeneratedLockObject) {
            let loc = properties.getPadPosition()
            return if (loc.isNone()) { PAD_BEFORE_PREFIX } else { loc.toOld() }
        }
    }

    public func setPadPosition(padPos: Int32): Unit {
        synchronized (GeneratedLockObject) {
            properties.setPadPosition(Padder_PadPosition.fromOld(padPos))
            refreshFormatter()
        }
    }

    public func isScientificNotation(): Bool {
        synchronized (GeneratedLockObject) {
            return properties.getMinimumExponentDigits() != -1
        }
    }

    public func setScientificNotation(useScientific: Bool): Unit {
        synchronized (GeneratedLockObject) {
            if (useScientific) {
                properties.setMinimumExponentDigits(1)
            } else {
                properties.setMinimumExponentDigits(-1)
            }
            refreshFormatter()
        }
    }

    public func getMinimumExponentDigits(): UInt8 {
        synchronized (GeneratedLockObject) {
            return UInt8(properties.getMinimumExponentDigits())
        }
    }

    public func setMinimumExponentDigits(minExpDig: UInt8): Unit {
        synchronized (GeneratedLockObject) {
            properties.setMinimumExponentDigits(Int32(minExpDig))
            refreshFormatter()
        }
    }

    public func isExponentSignAlwaysShown(): Bool {
        synchronized (GeneratedLockObject) {
            return properties.getExponentSignAlwaysShown()
        }
    }

    public func setExponentSignAlwaysShown(expSignAlways: Bool): Unit {
        synchronized (GeneratedLockObject) {
            properties.setExponentSignAlwaysShown(expSignAlways)
            refreshFormatter()
        }
    }

    public override func isGroupingUsed(): Bool {
        synchronized (GeneratedLockObject) {
            return properties.getGroupingUsed()
        }
    }

    public override func setGroupingUsed(enabled: Bool): Unit {
        synchronized (GeneratedLockObject) {
            properties.setGroupingUsed(enabled)
            refreshFormatter()
        }
    }

    public func getGroupingSize(): Int32 {
        synchronized (GeneratedLockObject) {
            if (properties.getGroupingSize() < 0) {
                return 0
            }
            return properties.getGroupingSize()
        }
    }

    public func setGroupingSize(width: Int32): Unit {
        synchronized (GeneratedLockObject) {
            properties.setGroupingSize(width)
            refreshFormatter()
        }
    }

    public func getSecondaryGroupingSize(): Int32 {
        synchronized (GeneratedLockObject) {
            let grouping2 = properties.getSecondaryGroupingSize()
            if (grouping2 < 0) {
                return 0
            }
            return grouping2
        }
    }

    public func setSecondaryGroupingSize(width: Int32): Unit {
        synchronized (GeneratedLockObject) {
            properties.setSecondaryGroupingSize(width)
            refreshFormatter()
        }
    }

    public func getMinimumGroupingDigits(): Int32 {
        synchronized (GeneratedLockObject) {
            if (properties.getMinimumGroupingDigits() > 0) {
                return properties.getMinimumGroupingDigits()
            }
            return 1
        }
    }

    public func setMinimumGroupingDigits(number: Int32): Unit {
        synchronized (GeneratedLockObject) {
            properties.setMinimumGroupingDigits(number)
            refreshFormatter()
        }
    }

    public static let MINIMUM_GROUPING_DIGITS_AUTO = -2

    public static let MINIMUM_GROUPING_DIGITS_MIN2 = -3

    public func isDecimalSeparatorAlwaysShown(): Bool {
        synchronized (GeneratedLockObject) {
            return properties.getDecimalSeparatorAlwaysShown()
        }
    }

    public func setDecimalSeparatorAlwaysShown(value: Bool): Unit {
        synchronized (GeneratedLockObject) {
            properties.setDecimalSeparatorAlwaysShown(value)
            refreshFormatter()
        }
    }

    public override func getCurrency(): Currency {
        synchronized (GeneratedLockObject) {
            return exportedProperties.getCurrency()
        }
    }

    public override func setCurrency(currency: Currency): Unit {
        synchronized (GeneratedLockObject) {
            properties.setCurrency(currency)
            if (currency.isSome()) {
                symbols.setCurrency(currency)
            }
            refreshFormatter()
        }
    }

    public func getCurrencyUsage(): Currency_CurrencyUsage {
        synchronized (GeneratedLockObject) {
            var usage = properties.getCurrencyUsage()
            if (usage.isNone()) {
                usage = Currency_CurrencyUsage.STANDARD
            }
            return usage
        }
    }

    public func setCurrencyUsage(usage: Currency_CurrencyUsage): Unit {
        synchronized (GeneratedLockObject) {
            properties.setCurrencyUsage(usage)
            refreshFormatter()
        }
    }

    public func getCurrencyPluralInfo(): CurrencyPluralInfo {
        synchronized (GeneratedLockObject) {
            return properties.getCurrencyPluralInfo()
        }
    }

    public func setCurrencyPluralInfo(newInfo: CurrencyPluralInfo): Unit {
        synchronized (GeneratedLockObject) {
            properties.setCurrencyPluralInfo(newInfo)
            refreshFormatter()
        }
    }

    public func isParseBigDecimal(): Bool {
        synchronized (GeneratedLockObject) {
            return properties.getParseToBigDecimal()
        }
    }

    public func setParseBigDecimal(value: Bool): Unit {
        synchronized (GeneratedLockObject) {
            properties.setParseToBigDecimal(value)
            refreshFormatter()
        }
    }

    
    public func getParseMaxDigits(): Int32 {
        return 1000
    }

    
    public func setParseMaxDigits(maxDigits: Int32): Unit { }

    public override func isParseStrict(): Bool {
        synchronized (GeneratedLockObject) {
            return refEq(properties.getParseMode(), DecimalFormatProperties_ParseMode.STRICT)
        }
    }

    public override func setParseStrict(parseStrict: Bool): Unit {
        synchronized (GeneratedLockObject) {
            let mode: DecimalFormatProperties_ParseMode = if (parseStrict) { DecimalFormatProperties_ParseMode.STRICT } else { DecimalFormatProperties_ParseMode.LENIENT }
            properties.setParseMode(mode)
            refreshFormatter()
        }
    }

    
    public func setParseStrictMode(parseMode: DecimalFormatProperties_ParseMode): Unit {
        synchronized (GeneratedLockObject) {
            properties.setParseMode(parseMode)
            refreshFormatter()
        }
    }

    public override func isParseIntegerOnly(): Bool {
        synchronized (GeneratedLockObject) {
            return properties.getParseIntegerOnly()
        }
    }

    public override func setParseIntegerOnly(parseIntegerOnly: Bool): Unit {
        synchronized (GeneratedLockObject) {
            properties.setParseIntegerOnly(parseIntegerOnly)
            refreshFormatter()
        }
    }

    public func isDecimalPatternMatchRequired(): Bool {
        synchronized (GeneratedLockObject) {
            return properties.getDecimalPatternMatchRequired()
        }
    }

    public func setDecimalPatternMatchRequired(value: Bool): Unit {
        synchronized (GeneratedLockObject) {
            properties.setDecimalPatternMatchRequired(value)
            refreshFormatter()
        }
    }

    public func isParseNoExponent(): Bool {
        synchronized (GeneratedLockObject) {
            return properties.getParseNoExponent()
        }
    }

    public func setParseNoExponent(value: Bool): Unit {
        synchronized (GeneratedLockObject) {
            properties.setParseNoExponent(value)
            refreshFormatter()
        }
    }

    public func isParseCaseSensitive(): Bool {
        synchronized (GeneratedLockObject) {
            return properties.getParseCaseSensitive()
        }
    }

    public func setParseCaseSensitive(value: Bool): Unit {
        synchronized (GeneratedLockObject) {
            properties.setParseCaseSensitive(value)
            refreshFormatter()
        }
    }

    public override func equals(obj: Object): Bool {
        synchronized (GeneratedLockObject) {
            if (obj.isNone()) {
                return false
            }
            if (refEq(obj, this)) {
                return true
            }
            if (!(checkOptionalIs<DecimalFormat, Object>(obj))) {
                return false
            }
            let other = obj
            return properties.equals(other.properties) && symbols.equals(other.symbols)
        }
    }

    public override func hashCode(): Int64 {
        synchronized (GeneratedLockObject) {
            return Int64(Int32(properties.hashCode()) ^ Int32(symbols.hashCode()))
        }
    }

    public override func toString(): String {
        let result = StringBuilder()
        result.append(TypeInfo.of(this).name)
        result.append("@")
        result.append(hashCode().format("x"))
        result.append(" { symbols@")
        result.append(symbols.hashCode().format("x"))
        synchronized (getMonitorByObject(this)) {
            properties.toStringBare(result)
        }
        result.append(" }")
        return result.toString()
    }

    public func toPattern(): String {
        synchronized (GeneratedLockObject) {
            let tprops = DecimalFormatProperties().copyFrom(properties)
            let useCurrency = ((tprops.getCurrency().isSome()) || tprops.getCurrencyPluralInfo().isSome() || tprops.getCurrencyUsage().isSome() || tprops.getCurrencyAsDecimal() || AffixUtils.hasCurrencySymbols(tprops.getPositivePrefixPattern()) || AffixUtils.hasCurrencySymbols(tprops.getPositiveSuffixPattern()) || AffixUtils.hasCurrencySymbols(tprops.getNegativePrefixPattern()) || AffixUtils.hasCurrencySymbols(tprops.getNegativeSuffixPattern()))
            if (useCurrency) {
                tprops.setMinimumFractionDigits(exportedProperties.getMinimumFractionDigits())
                tprops.setMaximumFractionDigits(exportedProperties.getMaximumFractionDigits())
                tprops.setRoundingIncrement(exportedProperties.getRoundingIncrement())
            }
            return PatternStringUtils.propertiesToPatternString(tprops)
        }
    }

    public func toLocalizedPattern(): String {
        synchronized (GeneratedLockObject) {
            let pattern = toPattern()
            return PatternStringUtils.convertLocalized(pattern, symbols, true)
        }
    }

    public func toNumberFormatter(): LocalizedNumberFormatter {
        return formatter
    }

    
    public func getFixedDecimal(number: Float64): PluralRules_IFixedDecimal {
        return formatter.format(number).getFixedDecimal()
    }

    public func refreshFormatter(): Unit {
        if (exportedProperties.isNone()) {
            return
        }
        var locale = this.getLocale(ULocale.ACTUAL_LOCALE)
        if (locale.isNone()) {
            locale = symbols.getLocale(ULocale.ACTUAL_LOCALE)
        }
        if (locale.isNone()) {
            locale = symbols.getULocale()
        }
        if (!locale.isSome()) {
            throw AssertionError()
        }
        formatter = NumberFormatter.fromDecimalFormat(properties, symbols, exportedProperties).locale(locale)
        parser = None
        currencyParser = None
    }

    public func getParser(): NumberParserImpl {
        if (parser.isNone()) {
            parser = NumberParserImpl.createParserFromProperties(properties, symbols, false)
        }
        return parser
    }

    public func getCurrencyParser(): NumberParserImpl {
        if (currencyParser.isNone()) {
            currencyParser = NumberParserImpl.createParserFromProperties(properties, symbols, true)
        }
        return currencyParser
    }

    private func safeConvertBigDecimal(number: BigDecimal): Number {
        try {
            return BigDecimal(number)
        } catch (e: TimeParseException) {
            if (number.signum() > 0 && number.scale() < 0) {
                return Float64.POSITIVE_INFINITY
            } else if (number.scale() < 0) {
                return Float64.NEGATIVE_INFINITY
            } else if (number.signum() < 0) {
                return -0.0
            } else {
                return 0.0
            }
        }
    }

    public func setPropertiesFromPattern(pattern: String, ignoreRounding: Int32): Unit {
        if (pattern.isNone()) {
            throw NoneValueException()
        }
        PatternStringParser.parseToExistingProperties(pattern, properties, ignoreRounding)
    }

    static func fieldPositionHelper(dq: DecimalQuantity, string: FormattedStringBuilder, fieldPosition: FieldPosition, offset: Int32): Unit {
        fieldPosition.setBeginIndex(0)
        fieldPosition.setEndIndex(0)
        dq.populateUFieldPosition(fieldPosition)
        let found = FormattedValueStringBuilderImpl.nextFieldPosition(string, fieldPosition)
        if (found && offset != 0) {
            fieldPosition.setBeginIndex(fieldPosition.getBeginIndex() + offset)
            fieldPosition.setEndIndex(fieldPosition.getEndIndex() + offset)
        }
    }

    
    public func setProperties(func: DecimalFormat_PropertySetter): Unit {
        synchronized (GeneratedLockObject) {
            func.set(properties)
            refreshFormatter()
        }
    }

    public static let PAD_BEFORE_PREFIX = 0

    public static let PAD_AFTER_PREFIX = 1

    public static let PAD_BEFORE_SUFFIX = 2

    public static let PAD_AFTER_SUFFIX = 3
}



public interface DecimalFormat_PropertySetter {
    
    public func set(props: DecimalFormatProperties): Unit
}