package icu4cj.text

public abstract class NumberFormat <: UFormat & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public static let NUMBERSTYLE = 0

    public static let CURRENCYSTYLE = 1

    public static let PERCENTSTYLE = 2

    public static let SCIENTIFICSTYLE = 3

    public static let INTEGERSTYLE = 4

    public static let ISOCURRENCYSTYLE = 5

    public static let PLURALCURRENCYSTYLE = 6

    public static let ACCOUNTINGCURRENCYSTYLE = 7

    public static let CASHCURRENCYSTYLE = 8

    public static let STANDARDCURRENCYSTYLE = 9

    public static let INTEGER_FIELD = 0

    public static let FRACTION_FIELD = 1

    public override func format(number: Object, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        if (number) {
            return format(number, toAppendTo, pos)
        } else if (checkOptionalIs<BigInt, Object>(number)) {
            return format(number, toAppendTo, pos)
        } else if (checkOptionalIs<BigDecimal, Object>(number)) {
            return format(number, toAppendTo, pos)
        } else if (checkOptionalIs<BigDecimal, Object>(number)) {
            return format(number, toAppendTo, pos)
        } else if (checkOptionalIs<CurrencyAmount, Object>(number)) {
            return format(number, toAppendTo, pos)
        } else if (checkOptionalIs<Number, Object>(number)) {
            return format(number.doubleValue(), toAppendTo, pos)
        } else {
            throw IllegalArgumentException("Cannot format given Object as a Number")
        }
    }

    public override func parseObject(source: String, parsePosition: ParsePosition): Object {
        return parse(source, parsePosition)
    }

    public func format(number: Float64): String {
        return toString(format(number, StringBuffer(), FieldPosition(0)))
    }

    public func format(number: Int64): String {
        let buf = StringBuffer(19)
        let pos = FieldPosition(0)
        format(number, buf, pos)
        return toString(buf)
    }

    public func format(number: BigInt): String {
        return toString(format(number, StringBuffer(), FieldPosition(0)))
    }

    public func format(number: BigDecimal): String {
        return toString(format(number, StringBuffer(), FieldPosition(0)))
    }

    public func format(number: BigDecimal): String {
        return toString(format(number, StringBuffer(), FieldPosition(0)))
    }

    public func format(currAmt: CurrencyAmount): String {
        return toString(format(currAmt, StringBuffer(), FieldPosition(0)))
    }

    public func format(number: Float64, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer

    public func format(number: Int64, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer

    public func format(number: BigInt, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer

    public func format(number: BigDecimal, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer

    public func format(number: BigDecimal, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer

    public func format(currAmt: CurrencyAmount, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        synchronized (getMonitorByObject(this)) {
            let save = getCurrency()
            let curr = currAmt.getCurrency()
            let same = curr.equals(save)
            if (!same) {
                setCurrency(curr)
            }
            format(currAmt.getNumber(), toAppendTo, pos)
            if (!same) {
                setCurrency(save)
            }
        }
        return toAppendTo
    }

    public func parse(text: String, parsePosition: ParsePosition): Number

    public func parse(text: String): Number {
        let parsePosition = ParsePosition(0)
        let result = parse(text, parsePosition)
        if (parsePosition.getIndex() == 0) {
            throw ParseException("Unparseable number: \"" + (text) + '\"'.toString(), parsePosition.getErrorIndex())
        }
        return result
    }

    public func parseCurrency(text: String, pos: ParsePosition): CurrencyAmount {
        let n = parse(toString(text), pos)
        return if (n.isNone()) { None } else { CurrencyAmount(n, getEffectiveCurrency()) }
    }

    public func isParseIntegerOnly(): Bool {
        return parseIntegerOnly
    }

    public func setParseIntegerOnly(value: Bool): Unit {
        parseIntegerOnly = value
    }

    public func setParseStrict(value: Bool): Unit {
        parseStrict = value
    }

    public func isParseStrict(): Bool {
        return parseStrict
    }

    public func setContext(context: DisplayContext): Unit {
        if (refEq(context.typeMethod(), DisplayContext_Type.CAPITALIZATION)) {
            capitalizationSetting = context
        }
    }

    public func getContext(Type: DisplayContext_Type): DisplayContext {
        return if (refEq(Type, DisplayContext_Type.CAPITALIZATION) && capitalizationSetting.isSome()) { capitalizationSetting } else { DisplayContext.CAPITALIZATION_NONE }
    }

    public static func getInstance(): NumberFormat {
        return getInstance(ULocale.getDefault(ULocale_Category.FORMAT), NUMBERSTYLE)
    }

    public static func getInstance(inLocale: Locale): NumberFormat {
        return getInstance(ULocale.forLocale(inLocale), NUMBERSTYLE)
    }

    public static func getInstance(inLocale: ULocale): NumberFormat {
        return getInstance(inLocale, NUMBERSTYLE)
    }

    public static func getInstance(style: Int32): NumberFormat {
        return getInstance(ULocale.getDefault(ULocale_Category.FORMAT), style)
    }

    public static func getInstance(inLocale: Locale, style: Int32): NumberFormat {
        return getInstance(ULocale.forLocale(inLocale), style)
    }

    public static func getNumberInstance(): NumberFormat {
        return getInstance(ULocale.getDefault(ULocale_Category.FORMAT), NUMBERSTYLE)
    }

    public static func getNumberInstance(inLocale: Locale): NumberFormat {
        return getInstance(ULocale.forLocale(inLocale), NUMBERSTYLE)
    }

    public static func getNumberInstance(inLocale: ULocale): NumberFormat {
        return getInstance(inLocale, NUMBERSTYLE)
    }

    public static func getIntegerInstance(): NumberFormat {
        return getInstance(ULocale.getDefault(ULocale_Category.FORMAT), INTEGERSTYLE)
    }

    public static func getIntegerInstance(inLocale: Locale): NumberFormat {
        return getInstance(ULocale.forLocale(inLocale), INTEGERSTYLE)
    }

    public static func getIntegerInstance(inLocale: ULocale): NumberFormat {
        return getInstance(inLocale, INTEGERSTYLE)
    }

    public static func getCurrencyInstance(): NumberFormat {
        return getInstance(ULocale.getDefault(ULocale_Category.FORMAT), CURRENCYSTYLE)
    }

    public static func getCurrencyInstance(inLocale: Locale): NumberFormat {
        return getInstance(ULocale.forLocale(inLocale), CURRENCYSTYLE)
    }

    public static func getCurrencyInstance(inLocale: ULocale): NumberFormat {
        return getInstance(inLocale, CURRENCYSTYLE)
    }

    public static func getPercentInstance(): NumberFormat {
        return getInstance(ULocale.getDefault(ULocale_Category.FORMAT), PERCENTSTYLE)
    }

    public static func getPercentInstance(inLocale: Locale): NumberFormat {
        return getInstance(ULocale.forLocale(inLocale), PERCENTSTYLE)
    }

    public static func getPercentInstance(inLocale: ULocale): NumberFormat {
        return getInstance(inLocale, PERCENTSTYLE)
    }

    public static func getScientificInstance(): NumberFormat {
        return getInstance(ULocale.getDefault(ULocale_Category.FORMAT), SCIENTIFICSTYLE)
    }

    public static func getScientificInstance(inLocale: Locale): NumberFormat {
        return getInstance(ULocale.forLocale(inLocale), SCIENTIFICSTYLE)
    }

    public static func getScientificInstance(inLocale: ULocale): NumberFormat {
        return getInstance(inLocale, SCIENTIFICSTYLE)
    }

    private static var shim: NumberFormat_NumberFormatShim

    private static func getShim(): NumberFormat_NumberFormatShim {
        if (shim.isNone()) {
            try {
                let cls: ClassTypeInfo = TypeInfo.get("com.ibm.icu.text.NumberFormatServiceShim") as ClassTypeInfo
                shim = cls.construct([0]) as NumberFormat_NumberFormatShim
            } catch (e: MissingResourceException) {
                throw e
            } catch (e: Exception) {
                throw Exception(e.message)
            }
        }
        return shim
    }

    public static func getAvailableLocales(): Array<Locale> {
        if (shim.isNone()) {
            return ICUResourceBundle.getAvailableLocales()
        }
        return getShim().getAvailableLocales()
    }

    public static func getAvailableULocales(): Array<ULocale> {
        if (shim.isNone()) {
            return ICUResourceBundle.getAvailableULocales()
        }
        return getShim().getAvailableULocales()
    }

    public static func registerFactory(factory: NumberFormat_NumberFormatFactory): Object {
        if (factory.isNone()) {
            throw IllegalArgumentException("factory must not be null")
        }
        return getShim().registerFactory(factory)
    }

    public static func unregister(registryKey: Object): Bool {
        if (registryKey.isNone()) {
            throw IllegalArgumentException("registryKey must not be null")
        }
        if (shim.isNone()) {
            return false
        }
        return shim.unregister(registryKey)
    }

    public override func hashCode(): Int64 {
        return Int64(maximumIntegerDigits * 37 + Int32(maxFractionDigits))
    }

    public override func equals(obj: Object): Bool {
        if (obj.isNone()) {
            return false
        }
        if (refEq(this, obj)) {
            return true
        }
        if (!refEq(TypeInfo.of(this), TypeInfo.of(obj))) {
            return false
        }
        let other = obj
        return maximumIntegerDigits == other.maximumIntegerDigits && minimumIntegerDigits == other.minimumIntegerDigits && maximumFractionDigits == other.maximumFractionDigits && minimumFractionDigits == other.minimumFractionDigits && groupingUsed == other.groupingUsed && parseIntegerOnly == other.parseIntegerOnly && parseStrict == other.parseStrict && refEq(capitalizationSetting, other.capitalizationSetting)
    }

    public override func clone(): Object {
        let other = super.clone()
        return other
    }

    public func isGroupingUsed(): Bool {
        return groupingUsed
    }

    public func setGroupingUsed(newValue: Bool): Unit {
        groupingUsed = newValue
    }

    public func getMaximumIntegerDigits(): Int32 {
        return maximumIntegerDigits
    }

    public func setMaximumIntegerDigits(newValue: Int32): Unit {
        maximumIntegerDigits = max(0, newValue)
        if (minimumIntegerDigits > maximumIntegerDigits) {
            minimumIntegerDigits = maximumIntegerDigits
        }
    }

    public func getMinimumIntegerDigits(): Int32 {
        return minimumIntegerDigits
    }

    public func setMinimumIntegerDigits(newValue: Int32): Unit {
        minimumIntegerDigits = max(0, newValue)
        if (minimumIntegerDigits > maximumIntegerDigits) {
            maximumIntegerDigits = minimumIntegerDigits
        }
    }

    public func getMaximumFractionDigits(): Int32 {
        return maximumFractionDigits
    }

    public func setMaximumFractionDigits(newValue: Int32): Unit {
        maximumFractionDigits = max(0, newValue)
        if (maximumFractionDigits < minimumFractionDigits) {
            minimumFractionDigits = maximumFractionDigits
        }
    }

    public func getMinimumFractionDigits(): Int32 {
        return minimumFractionDigits
    }

    public func setMinimumFractionDigits(newValue: Int32): Unit {
        minimumFractionDigits = max(0, newValue)
        if (maximumFractionDigits < minimumFractionDigits) {
            maximumFractionDigits = minimumFractionDigits
        }
    }

    public func setCurrency(theCurrency: Currency): Unit {
        currency = theCurrency
    }

    public func getCurrency(): Currency {
        return currency
    }

    
    protected func getEffectiveCurrency(): Currency {
        var c = getCurrency()
        if (c.isNone()) {
            var uloc = getLocale(ULocale.VALID_LOCALE)
            if (uloc.isNone()) {
                uloc = ULocale.getDefault(ULocale_Category.FORMAT)
            }
            c = Currency.getInstance(uloc)
        }
        return c
    }

    public func getRoundingMode(): Int32 {
        throw UnsupportedOperationException("getRoundingMode must be implemented by the subclass implementation.")
    }

    public func setRoundingMode(roundingMode: Int32): Unit {
        throw UnsupportedOperationException("setRoundingMode must be implemented by the subclass implementation.")
    }

    public static func getInstance(desiredLocale: ULocale, choice: Int32): NumberFormat {
        if (choice < NUMBERSTYLE || choice > STANDARDCURRENCYSTYLE) {
            throw IllegalArgumentException("choice should be from NUMBERSTYLE to STANDARDCURRENCYSTYLE")
        }
        return getShim().createInstance(desiredLocale, choice)
    }

    static func createInstance(desiredLocale: ULocale, choice: Int32): NumberFormat {
        var pattern = getPattern(desiredLocale, choice)
        let symbols = DecimalFormatSymbols(desiredLocale)
        if (choice == CURRENCYSTYLE || choice == ISOCURRENCYSTYLE || choice == ACCOUNTINGCURRENCYSTYLE || choice == CASHCURRENCYSTYLE || choice == STANDARDCURRENCYSTYLE) {
            let temp = symbols.getCurrencyPattern()
            if (temp.isSome()) {
                pattern = temp
            }
        }
        if (choice == ISOCURRENCYSTYLE) {
            pattern = pattern.replace("\u{00a4}", doubleCurrencyStr)
        }
        let ns = NumberingSystem.getInstance(desiredLocale)
        if (ns.isNone()) {
            return None
        }
        let format: NumberFormat
        if (ns.isSome() && ns.isAlgorithmic()) {
            let nsDesc: String
            let nsRuleSetGroup: String
            let nsRuleSetName: String
            let nsLoc: ULocale
            var desiredRulesType = RuleBasedNumberFormat.NUMBERING_SYSTEM
            nsDesc = ns.getDescription()
            let firstSlash = indexOfWrap(nsDesc.indexOf("/"))
            let lastSlash = indexOfWrap(nsDesc.lastIndexOf("/"))
            if (lastSlash > firstSlash) {
                let nsLocID: String = nsDesc[0..Int64(firstSlash)]
                nsRuleSetGroup = nsDesc[Int64(firstSlash + 1)..Int64(lastSlash)]
                nsRuleSetName = nsDesc[Int64(lastSlash + 1)..]
                nsLoc = ULocale(nsLocID)
                if (nsRuleSetGroup == "SpelloutRules") {
                    desiredRulesType = RuleBasedNumberFormat.SPELLOUT
                }
            } else {
                nsLoc = desiredLocale
                nsRuleSetName = nsDesc
            }
            let r = RuleBasedNumberFormat(nsLoc, desiredRulesType)
            r.setDefaultRuleSet(nsRuleSetName)
            format = r
        } else {
            let f = DecimalFormat(pattern, symbols, choice)
            if (choice == INTEGERSTYLE) {
                f.setMaximumFractionDigits(0)
                f.setDecimalSeparatorAlwaysShown(false)
                f.setParseIntegerOnly(true)
            }
            if (choice == CASHCURRENCYSTYLE) {
                f.setCurrencyUsage(Currency_CurrencyUsage.CASH)
            }
            if (choice == PLURALCURRENCYSTYLE) {
                f.setCurrencyPluralInfo(CurrencyPluralInfo.getInstance(desiredLocale))
            }
            format = f
        }
        let valid = symbols.getLocale(ULocale.VALID_LOCALE)
        let actual = symbols.getLocale(ULocale.ACTUAL_LOCALE)
        format.setLocale(valid, actual)
        return format
    }

    
    protected static func getPattern(forLocale: Locale, choice: Int32): String {
        return getPattern(ULocale.forLocale(forLocale), choice)
    }

    protected static func getPattern(forLocale: ULocale, choice: Int32): String {
        return getPatternForStyle(forLocale, choice)
    }

    
    public static func getPatternForStyle(forLocale: ULocale, choice: Int32): String {
        let ns = NumberingSystem.getInstance(forLocale)
        let nsName = ns.getName()
        return getPatternForStyleAndNumberingSystem(forLocale, nsName, choice)
    }

    
    public static func getPatternForStyleAndNumberingSystem(forLocale: ULocale, nsName: String, choice: Int32): String {
        var patternKey: String
        match (choice) {
            case 0 | 4 | 6 => patternKey = "decimalFormat"
            case 1 =>
                let cfKeyValue = forLocale.getKeywordValue("cf")
                patternKey = if (cfKeyValue.isSome() && cfKeyValue == "account") { "accountingFormat" } else { "currencyFormat" }
            case 8 | 5 | 9 => patternKey = "currencyFormat"
            case 2 => patternKey = "percentFormat"
            case 3 => patternKey = "scientificFormat"
            case 7 => patternKey = "accountingFormat"
            case _ =>
                if (!false) {
                    throw AssertionError()
                }
                patternKey = "decimalFormat"
        }
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, forLocale)
        var result = rb.findStringWithFallback("NumberElements/" + (nsName) + "/patterns/" + (patternKey))
        if (result.isNone()) {
            result = rb.getStringWithFallback("NumberElements/latn/patterns/" + (patternKey))
        }
        return result
    }

    private func readObject(stream: ObjectInputStream): Unit {
        stream.defaultReadObject()
        if (serialVersionOnStream < 1) {
            maximumIntegerDigits = Int32(maxIntegerDigits)
            minimumIntegerDigits = Int32(minIntegerDigits)
            maximumFractionDigits = Int32(maxFractionDigits)
            minimumFractionDigits = Int32(minFractionDigits)
        }
        if (serialVersionOnStream < 2) {
            capitalizationSetting = DisplayContext.CAPITALIZATION_NONE
        }
        if (minimumIntegerDigits > maximumIntegerDigits || minimumFractionDigits > maximumFractionDigits || minimumIntegerDigits < 0 || minimumFractionDigits < 0) {
            throw InvalidObjectException("Digit count range invalid")
        }
        serialVersionOnStream = currentSerialVersion
    }

    private func writeObject(stream: ObjectOutputStream): Unit {
        maxIntegerDigits = if (maximumIntegerDigits > Int32(Int8.Max)) { UInt8(Int8.Max) } else { UInt8(maximumIntegerDigits) }
        minIntegerDigits = if (minimumIntegerDigits > Int32(Int8.Max)) { UInt8(Int8.Max) } else { UInt8(minimumIntegerDigits) }
        maxFractionDigits = if (maximumFractionDigits > Int32(Int8.Max)) { UInt8(Int8.Max) } else { UInt8(maximumFractionDigits) }
        minFractionDigits = if (minimumFractionDigits > Int32(Int8.Max)) { UInt8(Int8.Max) } else { UInt8(minimumFractionDigits) }
        stream.defaultWriteObject()
    }

    private static let doubleCurrencySign: Array<Char> = [Char(164), Char(164)]

    private static let doubleCurrencyStr = String(doubleCurrencySign)

    private var groupingUsed = true

    private var maxIntegerDigits = 40u8

    private var minIntegerDigits = 1u8

    private var maxFractionDigits = 3u8

    private var minFractionDigits = 0u8

    private var parseIntegerOnly = false

    private var maximumIntegerDigits = 40

    private var minimumIntegerDigits = 1

    private var maximumFractionDigits = 3

    private var minimumFractionDigits = 0

    private var currency: Currency

    static let currentSerialVersion = 2

    private var serialVersionOnStream = currentSerialVersion

    private static let serialVersionUID = -2308460125733713944

    public init() {
        super()
    }

    private var parseStrict: Bool = false

    private var capitalizationSetting: DisplayContext = DisplayContext.CAPITALIZATION_NONE
}


public abstract class NumberFormat_NumberFormatFactory {
    public static let FORMAT_NUMBER = NumberFormat.NUMBERSTYLE

    public static let FORMAT_CURRENCY = NumberFormat.CURRENCYSTYLE

    public static let FORMAT_PERCENT = NumberFormat.PERCENTSTYLE

    public static let FORMAT_SCIENTIFIC = NumberFormat.SCIENTIFICSTYLE

    public static let FORMAT_INTEGER = NumberFormat.INTEGERSTYLE

    public func visible(): Bool {
        return true
    }

    public func getSupportedLocaleNames(): Set<String>

    public func createFormat(loc: ULocale, formatType: Int32): NumberFormat {
        return createFormat(loc.toLocale(), formatType)
    }

    public func createFormat(loc: Locale, formatType: Int32): NumberFormat {
        return createFormat(ULocale.forLocale(loc), formatType)
    }

}


public abstract class NumberFormat_SimpleNumberFormatFactory <: NumberFormat_NumberFormatFactory {
    let localeNames: Set<String>

    let visible: Bool

    public init(locale: Locale) {
        this(locale, true)
    }

    public init(locale: Locale, visible: Bool) {
        super()
        localeNames = Collections.singleton(ULocale.forLocale(locale).getBaseName())
        this.visible = visible
    }

    public init(locale: ULocale) {
        this(locale, true)
    }

    public init(locale: ULocale, visible: Bool) {
        super()
        localeNames = Collections.singleton(locale.getBaseName())
        this.visible = visible
    }

    public override func visibleMethod(): Bool {
        return visible
    }

    public override func getSupportedLocaleNames(): Set<String> {
        return localeNames
    }
}


abstract class NumberFormat_NumberFormatShim {

    public func getAvailableLocales(): Array<Locale>

    public func getAvailableULocales(): Array<ULocale>

    public func registerFactory(f: NumberFormat_NumberFormatFactory): Object

    public func unregister(k: Object): Bool

    public func createInstance(l: ULocale, k: Int32): NumberFormat
}


public class NumberFormat_Field <: Format_Field {
    static let serialVersionUID = -4516273749929385842

    public static let SIGN = NumberFormat_Field("sign")

    public static let INTEGER = NumberFormat_Field("integer")

    public static let FRACTION = NumberFormat_Field("fraction")

    public static let EXPONENT = NumberFormat_Field("exponent")

    public static let EXPONENT_SIGN = NumberFormat_Field("exponent sign")

    public static let EXPONENT_SYMBOL = NumberFormat_Field("exponent symbol")

    public static let DECIMAL_SEPARATOR = NumberFormat_Field("decimal separator")

    public static let GROUPING_SEPARATOR = NumberFormat_Field("grouping separator")

    public static let PERCENT = NumberFormat_Field("percent")

    public static let PERMILLE = NumberFormat_Field("per mille")

    public static let CURRENCY = NumberFormat_Field("currency")

    public static let MEASURE_UNIT = NumberFormat_Field("measure unit")

    public static let COMPACT = NumberFormat_Field("compact")

    public static let APPROXIMATELY_SIGN = NumberFormat_Field("approximately sign")

    protected init(fieldName: String) {
        Format_Field(fieldName)
    }

    override protected func readResolve(): Object {
        if (this.getName().equals(INTEGER.getName())) {
            return INTEGER
        }
        if (this.getName().equals(FRACTION.getName())) {
            return FRACTION
        }
        if (this.getName().equals(EXPONENT.getName())) {
            return EXPONENT
        }
        if (this.getName().equals(EXPONENT_SIGN.getName())) {
            return EXPONENT_SIGN
        }
        if (this.getName().equals(EXPONENT_SYMBOL.getName())) {
            return EXPONENT_SYMBOL
        }
        if (this.getName().equals(CURRENCY.getName())) {
            return CURRENCY
        }
        if (this.getName().equals(DECIMAL_SEPARATOR.getName())) {
            return DECIMAL_SEPARATOR
        }
        if (this.getName().equals(GROUPING_SEPARATOR.getName())) {
            return GROUPING_SEPARATOR
        }
        if (this.getName().equals(PERCENT.getName())) {
            return PERCENT
        }
        if (this.getName().equals(PERMILLE.getName())) {
            return PERMILLE
        }
        if (this.getName().equals(SIGN.getName())) {
            return SIGN
        }
        if (this.getName().equals(MEASURE_UNIT.getName())) {
            return MEASURE_UNIT
        }
        if (this.getName().equals(COMPACT.getName())) {
            return COMPACT
        }
        throw InvalidObjectException("An invalid object.")
    }
}
