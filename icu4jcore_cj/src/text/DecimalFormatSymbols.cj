package icu4cj.text


public class DecimalFormatSymbols <: Cloneable & Serializable {
    public init() {
        this(ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public init(locale: Locale) {
        this(ULocale.forLocale(locale))
    }

    public init(locale: ULocale) {
        initialize(locale, None)
    }

    private init(locale: Locale, ns: NumberingSystem) {
        this(ULocale.forLocale(locale), ns)
    }

    private init(locale: ULocale, ns: NumberingSystem) {
        initialize(locale, ns)
    }

    public static func getInstance(): DecimalFormatSymbols {
        return DecimalFormatSymbols()
    }

    public static func getInstance(locale: Locale): DecimalFormatSymbols {
        return DecimalFormatSymbols(locale)
    }

    public static func getInstance(locale: ULocale): DecimalFormatSymbols {
        return DecimalFormatSymbols(locale)
    }

    public static func forNumberingSystem(locale: Locale, ns: NumberingSystem): DecimalFormatSymbols {
        return DecimalFormatSymbols(locale, ns)
    }

    public static func forNumberingSystem(locale: ULocale, ns: NumberingSystem): DecimalFormatSymbols {
        return DecimalFormatSymbols(locale, ns)
    }

    public static func getAvailableLocales(): Array<Locale> {
        return ICUResourceBundle.getAvailableLocales()
    }

    public static func getAvailableULocales(): Array<ULocale> {
        return ICUResourceBundle.getAvailableULocales()
    }

    public func getZeroDigit(): Char {
        return zeroDigit
    }

    public func getDigits(): Array<Char> {
        return digits.clone()
    }

    public func setZeroDigit(zeroDigit: Char): Unit {
        this.zeroDigit = zeroDigit
        digitStrings = digitStrings.clone()
        digits = digits.clone()
        digitStrings[0] = zeroDigit.toString()
        digits[0] = zeroDigit
        var i = 1
        while (i < 10) {
            let d = Char(Int32(UInt32(zeroDigit)) + i)
            digitStrings[Int64(i)] = d.toString()
            digits[Int64(i)] = d
            i++
        }
        codePointZero = Int32(UInt32(zeroDigit))
    }

    public func getDigitStrings(): Array<String> {
        return digitStrings.clone()
    }

    
    public func getDigitStringsLocal(): Array<String> {
        return digitStrings
    }

    
    public func getCodePointZero(): Int32 {
        return codePointZero
    }

    public func setDigitStrings(digitStrings: Array<String>): Unit {
        if (digitStrings.isNone()) {
            throw NoneValueException("The input digit string array is null")
        }
        if (Int32(digitStrings.size) != 10) {
            throw IllegalArgumentException("Number of digit strings is not 10")
        }
        let tmpDigitStrings = Array<String>(10)
        var tmpDigits: Array<Char> = Array<Char>(10) { _ => '\u{0000}' }
        var tmpCodePointZero = -1
        var i = 0
        while (i < 10) {
            let digitStr = digitStrings[Int64(i)]
            if (digitStr.isNone()) {
                throw IllegalArgumentException("The input digit string array contains a null element")
            }
            tmpDigitStrings[Int64(i)] = digitStr
            let cp: Int32
            let cc: Int32
            if (Int32(digitStr.size) == 0) {
                cp = -1
                cc = 0
            } else {
                cp = Character.codePointAt(digitStrings[Int64(i)], 0)
                cc = Character.charCount(cp)
            }
            if (cc == Int32(digitStr.size)) {
                if (cc == 1 && tmpDigits.isSome()) {
                    tmpDigits[Int64(i)] = Char(cp)
                } else {
                    tmpDigits = None
                }
                if (i == 0) {
                    tmpCodePointZero = cp
                } else if (cp != tmpCodePointZero + i) {
                    tmpCodePointZero = -1
                }
            } else {
                tmpCodePointZero = -1
                tmpDigits = None
            }
            i++
        }
        this.digitStrings = tmpDigitStrings
        this.codePointZero = tmpCodePointZero
        if (tmpDigits.isNone()) {
            this.zeroDigit = DEF_DIGIT_CHARS_ARRAY[0]
            this.digits = DEF_DIGIT_CHARS_ARRAY
        } else {
            this.zeroDigit = tmpDigits[0]
            this.digits = tmpDigits
        }
    }

    public func getSignificantDigit(): Char {
        return sigDigit
    }

    public func setSignificantDigit(sigDigit: Char): Unit {
        this.sigDigit = sigDigit
    }

    public func getGroupingSeparator(): Char {
        return groupingSeparator
    }

    public func setGroupingSeparator(groupingSeparator: Char): Unit {
        this.groupingSeparator = groupingSeparator
        this.groupingSeparatorString = groupingSeparator.toString()
    }

    public func getGroupingSeparatorString(): String {
        return groupingSeparatorString
    }

    public func setGroupingSeparatorString(groupingSeparatorString: String): Unit {
        if (groupingSeparatorString.isNone()) {
            throw NoneValueException("The input grouping separator is null")
        }
        this.groupingSeparatorString = groupingSeparatorString
        if (Int32(groupingSeparatorString.size) == 1) {
            this.groupingSeparator = Char(groupingSeparatorString[0])
        } else {
            this.groupingSeparator = DEF_GROUPING_SEPARATOR
        }
    }

    public func getDecimalSeparator(): Char {
        return decimalSeparator
    }

    public func setDecimalSeparator(decimalSeparator: Char): Unit {
        this.decimalSeparator = decimalSeparator
        this.decimalSeparatorString = decimalSeparator.toString()
    }

    public func getDecimalSeparatorString(): String {
        return decimalSeparatorString
    }

    public func setDecimalSeparatorString(decimalSeparatorString: String): Unit {
        if (decimalSeparatorString.isNone()) {
            throw NoneValueException("The input decimal separator is null")
        }
        this.decimalSeparatorString = decimalSeparatorString
        if (Int32(decimalSeparatorString.size) == 1) {
            this.decimalSeparator = Char(decimalSeparatorString[0])
        } else {
            this.decimalSeparator = DEF_DECIMAL_SEPARATOR
        }
    }

    public func getPerMill(): Char {
        return perMill
    }

    public func setPerMill(perMill: Char): Unit {
        this.perMill = perMill
        this.perMillString = perMill.toString()
    }

    public func getPerMillString(): String {
        return perMillString
    }

    public func setPerMillString(perMillString: String): Unit {
        if (perMillString.isNone()) {
            throw NoneValueException("The input permille string is null")
        }
        this.perMillString = perMillString
        if (Int32(perMillString.size) == 1) {
            this.perMill = Char(perMillString[0])
        } else {
            this.perMill = DEF_PERMILL
        }
    }

    public func getPercent(): Char {
        return percent
    }

    public func setPercent(percent: Char): Unit {
        this.percent = percent
        this.percentString = percent.toString()
    }

    public func getPercentString(): String {
        return percentString
    }

    public func setPercentString(percentString: String): Unit {
        if (percentString.isNone()) {
            throw NoneValueException("The input percent sign is null")
        }
        this.percentString = percentString
        if (Int32(percentString.size) == 1) {
            this.percent = Char(percentString[0])
        } else {
            this.percent = DEF_PERCENT
        }
    }

    public func getDigit(): Char {
        return digit
    }

    public func setDigit(digit: Char): Unit {
        this.digit = digit
    }

    public func getPatternSeparator(): Char {
        return patternSeparator
    }

    public func setPatternSeparator(patternSeparator: Char): Unit {
        this.patternSeparator = patternSeparator
    }

    public func getInfinity(): String {
        return infinity
    }

    public func setInfinity(infinity: String): Unit {
        this.infinity = infinity
    }

    public func getNaN(): String {
        return NaN
    }

    public func setNaN(NaN: String): Unit {
        this.NaN = NaN
    }

    public func getMinusSign(): Char {
        return minusSign
    }

    public func setMinusSign(minusSign: Char): Unit {
        this.minusSign = minusSign
        this.minusString = minusSign.toString()
    }

    public func getMinusSignString(): String {
        return minusString
    }

    public func setMinusSignString(minusSignString: String): Unit {
        if (minusSignString.isNone()) {
            throw NoneValueException("The input minus sign is null")
        }
        this.minusString = minusSignString
        if (Int32(minusSignString.size) == 1) {
            this.minusSign = Char(minusSignString[0])
        } else {
            this.minusSign = DEF_MINUS_SIGN
        }
    }

    public func getPlusSign(): Char {
        return plusSign
    }

    public func setPlusSign(plus: Char): Unit {
        this.plusSign = plus
        this.plusString = plus.toString()
    }

    public func getPlusSignString(): String {
        return plusString
    }

    public func setPlusSignString(plusSignString: String): Unit {
        if (plusSignString.isNone()) {
            throw NoneValueException("The input plus sign is null")
        }
        this.plusString = plusSignString
        if (Int32(plusSignString.size) == 1) {
            this.plusSign = Char(plusSignString[0])
        } else {
            this.plusSign = DEF_PLUS_SIGN
        }
    }

    
    public func getApproximatelySignString(): String {
        return approximatelyString
    }

    
    public func setApproximatelySignString(approximatelySignString: String): Unit {
        if (approximatelySignString.isNone()) {
            throw NoneValueException("The input plus sign is null")
        }
        this.approximatelyString = approximatelySignString
    }

    public func getCurrencySymbol(): String {
        return currencySymbol
    }

    public func setCurrencySymbol(currency: String): Unit {
        currencySymbol = currency
    }

    public func getInternationalCurrencySymbol(): String {
        return intlCurrencySymbol
    }

    public func setInternationalCurrencySymbol(currency: String): Unit {
        intlCurrencySymbol = currency
    }

    public func getCurrency(): Currency {
        return currency
    }

    public func setCurrency(currency: Currency): Unit {
        if (currency.isNone()) {
            throw NoneValueException()
        }
        if (currency.equals(this.currency)) {
            return
        }
        let displayInfo = CurrencyData.provider.getInstance(ulocale, true)
        setCurrencyOrNull(currency, displayInfo)
    }

    private func setCurrencyOrNull(currency: Currency, displayInfo: CurrencyData_CurrencyDisplayInfo): Unit {
        this.currency = currency
        if (currency.isNone()) {
            intlCurrencySymbol = "XXX"
            currencySymbol = "\u{00a4}"
            currencyPattern = None
            return
        }
        intlCurrencySymbol = currency.getCurrencyCode()
        currencySymbol = currency.getSymbol(ulocale)
        let formatInfo = displayInfo.getFormatInfo(currency.getCurrencyCode())
        if (formatInfo.isSome()) {
            setMonetaryDecimalSeparatorString(formatInfo.monetaryDecimalSeparator)
            setMonetaryGroupingSeparatorString(formatInfo.monetaryGroupingSeparator)
            currencyPattern = formatInfo.currencyPattern
        }
    }

    public func getMonetaryDecimalSeparator(): Char {
        return monetarySeparator
    }

    public func setMonetaryDecimalSeparator(sep: Char): Unit {
        this.monetarySeparator = sep
        this.monetarySeparatorString = sep.toString()
    }

    public func getMonetaryDecimalSeparatorString(): String {
        return monetarySeparatorString
    }

    public func setMonetaryDecimalSeparatorString(sep: String): Unit {
        if (sep.isNone()) {
            throw NoneValueException("The input monetary decimal separator is null")
        }
        this.monetarySeparatorString = sep
        if (Int32(sep.size) == 1) {
            this.monetarySeparator = Char(sep[0])
        } else {
            this.monetarySeparator = DEF_DECIMAL_SEPARATOR
        }
    }

    public func getMonetaryGroupingSeparator(): Char {
        return monetaryGroupingSeparator
    }

    public func setMonetaryGroupingSeparator(sep: Char): Unit {
        this.monetaryGroupingSeparator = sep
        this.monetaryGroupingSeparatorString = sep.toString()
    }

    public func getMonetaryGroupingSeparatorString(): String {
        return monetaryGroupingSeparatorString
    }

    public func setMonetaryGroupingSeparatorString(sep: String): Unit {
        if (sep.isNone()) {
            throw NoneValueException("The input monetary grouping separator is null")
        }
        this.monetaryGroupingSeparatorString = sep
        if (Int32(sep.size) == 1) {
            this.monetaryGroupingSeparator = Char(sep[0])
        } else {
            this.monetaryGroupingSeparator = DEF_GROUPING_SEPARATOR
        }
    }

    
    public func getCurrencyPattern(): String {
        return currencyPattern
    }

    public func getExponentMultiplicationSign(): String {
        return exponentMultiplicationSign
    }

    public func setExponentMultiplicationSign(exponentMultiplicationSign: String): Unit {
        this.exponentMultiplicationSign = exponentMultiplicationSign
    }

    public func getExponentSeparator(): String {
        return exponentSeparator
    }

    public func setExponentSeparator(exp: String): Unit {
        exponentSeparator = exp
    }

    public func getPadEscape(): Char {
        return padEscape
    }

    public func setPadEscape(c: Char): Unit {
        padEscape = c
    }

    public static let CURRENCY_SPC_CURRENCY_MATCH = 0

    public static let CURRENCY_SPC_SURROUNDING_MATCH = 1

    public static let CURRENCY_SPC_INSERT = 2

    private var currencySpcBeforeSym: Array<String>

    private var currencySpcAfterSym: Array<String>

    public func getPatternForCurrencySpacing(itemType: Int32, beforeCurrency: Bool): String {
        if (itemType < CURRENCY_SPC_CURRENCY_MATCH || itemType > CURRENCY_SPC_INSERT) {
            throw IllegalArgumentException("unknown currency spacing: " + itemType.toString())
        }
        if (beforeCurrency) {
            return currencySpcBeforeSym[Int64(itemType)]
        }
        return currencySpcAfterSym[Int64(itemType)]
    }

    public func setPatternForCurrencySpacing(itemType: Int32, beforeCurrency: Bool, pattern: String): Unit {
        if (itemType < CURRENCY_SPC_CURRENCY_MATCH || itemType > CURRENCY_SPC_INSERT) {
            throw IllegalArgumentException("unknown currency spacing: " + itemType.toString())
        }
        if (beforeCurrency) {
            currencySpcBeforeSym = currencySpcBeforeSym.clone()
            currencySpcBeforeSym[Int64(itemType)] = pattern
        } else {
            currencySpcAfterSym = currencySpcAfterSym.clone()
            currencySpcAfterSym[Int64(itemType)] = pattern
        }
    }

    public func getLocale(): Locale {
        return requestedLocale
    }

    public func getULocale(): ULocale {
        return ulocale
    }

    public override func clone(): Object {
        try {
            return super.toString()
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException(e as Exception)
        }
    }

    public override func equals(obj: Object): Bool {
        if (!(checkOptionalIs<DecimalFormatSymbols, Object>(obj))) {
            return false
        }
        if (refEq(this, obj)) {
            return true
        }
        let other = obj
                if (!currencySpcAfterSym[Int64(i)].equals(other.currencySpcAfterSym[Int64(i)])) {
                    return false
                }
                i++
            }
        } while (false)
        if (other.digits.isNone()) {
                    i++
                }
            } while (false)
        } else if (!digits == other.digits) {
            return false
        }
        return (groupingSeparator == other.groupingSeparator && decimalSeparator == other.decimalSeparator && percent == other.percent && perMill == other.perMill && digit == other.digit && minusSign == other.minusSign && minusString.equals(other.minusString) && patternSeparator == other.patternSeparator && infinity.equals(other.infinity) && NaN.equals(other.NaN) && currencySymbol.equals(other.currencySymbol) && intlCurrencySymbol.equals(other.intlCurrencySymbol) && padEscape == other.padEscape && plusSign == other.plusSign && plusString.equals(other.plusString) && approximatelyString.equals(other.approximatelyString) && exponentSeparator.equals(other.exponentSeparator) && monetarySeparator == other.monetarySeparator && monetaryGroupingSeparator == other.monetaryGroupingSeparator && exponentMultiplicationSign.equals(other.exponentMultiplicationSign))
    }

    public override func hashCode(): Int64 {
        var result = Int32(UInt32(digits[0]))
        result = result * 37 + Int32(UInt32(groupingSeparator))
        result = result * 37 + Int32(UInt32(decimalSeparator))
        return Int64(result)
    }

    static let SYMBOL_KEYS: Array<String> = ["decimal", "group", "percentSign", "minusSign", "plusSign", "exponential", "perMille", "infinity", "nan", "currencyDecimal", "currencyGroup", "superscriptingExponent", "approximatelySign"]

    private static let DEF_DIGIT_STRINGS_ARRAY: Array<String> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

    private static let DEF_DIGIT_CHARS_ARRAY = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

    private static let DEF_DECIMAL_SEPARATOR = '.'

    private static let DEF_GROUPING_SEPARATOR = ','

    private static let DEF_PERCENT = '%'

    private static let DEF_MINUS_SIGN = '-'

    private static let DEF_PLUS_SIGN = '+'

    private static let DEF_PERMILL = '\u{2030}'

    private static let SYMBOL_DEFAULTS: Array<String> = [DEF_DECIMAL_SEPARATOR.toString(), DEF_GROUPING_SEPARATOR.toString(), DEF_PERCENT.toString(), DEF_MINUS_SIGN.toString(), DEF_PLUS_SIGN.toString(), "E", DEF_PERMILL.toString(), "\u{221e}", "NaN", None, None, "\u{00d7}", "~"]

    private static let LATIN_NUMBERING_SYSTEM = "latn"

    private static let NUMBER_ELEMENTS = "NumberElements"

    private static let SYMBOLS = "symbols"

    private func initialize(locale: ULocale, ns: NumberingSystem): Unit {
        this.requestedLocale = locale.toLocale()
        this.ulocale = locale
        let keyLocale = if (ns.isNone()) { locale } else { locale.setKeywordValue("numbers", ns.getName()) }
        let data = cachedLocaleData.getInstance(keyLocale, None)
        setLocale(data.validLocale, data.validLocale)
        setDigitStrings(data.digits)
        let numberElements = data.numberElements
        setDecimalSeparatorString(numberElements[0])
        setGroupingSeparatorString(numberElements[1])
        patternSeparator = ';'
        setPercentString(numberElements[2])
        setMinusSignString(numberElements[3])
        setPlusSignString(numberElements[4])
        setExponentSeparator(numberElements[5])
        setPerMillString(numberElements[6])
        setInfinity(numberElements[7])
        setNaN(numberElements[8])
        setMonetaryDecimalSeparatorString(numberElements[9])
        setMonetaryGroupingSeparatorString(numberElements[10])
        setExponentMultiplicationSign(numberElements[11])
        setApproximatelySignString(numberElements[12])
        digit = '#'
        padEscape = '*'
        sigDigit = '@'
        let displayInfo = CurrencyData.provider.getInstance(ulocale, true)
        initSpacingInfo(displayInfo.getSpacingInfo())
        setCurrencyOrNull(Currency.getInstance(ulocale), displayInfo)
    }

    static func loadData(locale: ULocale): DecimalFormatSymbols_CacheData {
        let nsName: String
        let ns = NumberingSystem.getInstance(locale)
        var digits: Array<String> = Array<String>(10)
        if (ns.isSome() && ns.getRadix() == 10 && !ns.isAlgorithmic() && NumberingSystem.isValidDigitString(ns.getDescription())) {
            let digitString = ns.getDescription()
            } while (false)
            nsName = ns.getName()
        } else {
            digits = DEF_DIGIT_STRINGS_ARRAY
            nsName = "latn"
        }
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, locale)
        let validLocale = rb.getULocale()
        let numberElements = Array<String>(SYMBOL_KEYS.size)
        let sink = DecimalFormatSymbols_DecFmtDataSink(numberElements)
        try {
            rb.getAllItemsWithFallback(NUMBER_ELEMENTS + "/" + (nsName) + "/" + SYMBOLS, sink)
        } catch (e: MissingResourceException) { }
        var hasNull = false
        for (entry in numberElements) {
            if (entry.isNone()) {
                hasNull = true
                break
            }
        }
        if (hasNull && !nsName.equals(LATIN_NUMBERING_SYSTEM)) {
            rb.getAllItemsWithFallback(NUMBER_ELEMENTS + "/" + LATIN_NUMBERING_SYSTEM + "/" + SYMBOLS, sink)
        }
                i++
            }
        } while (false)
        if (numberElements[9].isNone()) {
            numberElements[9] = numberElements[0]
        }
        if (numberElements[10].isNone()) {
            numberElements[10] = numberElements[1]
        }
        return DecimalFormatSymbols_CacheData(validLocale, digits, numberElements)
    }

    private func initSpacingInfo(spcInfo: CurrencyData_CurrencySpacingInfo): Unit {
        currencySpcBeforeSym = spcInfo.getBeforeSymbols()
        currencySpcAfterSym = spcInfo.getAfterSymbols()
    }

    private func readObject(stream: ObjectInputStream): Unit {
        stream.defaultReadObject()
        if (serialVersionOnStream < 1) {
            monetarySeparator = decimalSeparator
            exponential = 'E'
        }
        if (serialVersionOnStream < 2) {
            padEscape = '*'
            plusSign = '+'
            exponentSeparator = exponential.toString()
        }
        if (serialVersionOnStream < 3) {
            requestedLocale = Locale.getDefault()
        }
        if (serialVersionOnStream < 4) {
            ulocale = ULocale.forLocale(requestedLocale)
        }
        if (serialVersionOnStream < 5) {
            monetaryGroupingSeparator = groupingSeparator
        }
        if (serialVersionOnStream < 6) {
            if (currencySpcBeforeSym.isNone()) {
                currencySpcBeforeSym = Array<String>(Int64(CURRENCY_SPC_INSERT + 1))
            }
            if (currencySpcAfterSym.isNone()) {
                currencySpcAfterSym = Array<String>(Int64(CURRENCY_SPC_INSERT + 1))
            }
            initSpacingInfo(CurrencyData_CurrencySpacingInfo.DEFAULT)
        }
        if (serialVersionOnStream < 7) {
            if (minusString.isNone()) {
                minusString = minusSign.toString()
            }
            if (plusString.isNone()) {
                plusString = plusSign.toString()
            }
        }
        if (serialVersionOnStream < 8) {
            if (exponentMultiplicationSign.isNone()) {
                exponentMultiplicationSign = "\u{00d7}"
            }
        }
        if (serialVersionOnStream < 9) {
            if (digitStrings.isNone()) {
                digitStrings = Array<String>(10)
                if (digits.isSome() && Int32(digits.size) == 10) {
                    zeroDigit = digits[0]
                    } while (false)
                } else {
                    var digit = zeroDigit
                    if (digits.isNone()) {
                        digits = Array<Char>(10) { _ => '\u{0000}' }
                    }
                    } while (false)
                }
            }
            if (decimalSeparatorString.isNone()) {
                decimalSeparatorString = decimalSeparator.toString()
            }
            if (groupingSeparatorString.isNone()) {
                groupingSeparatorString = groupingSeparator.toString()
            }
            if (percentString.isNone()) {
                percentString = percent.toString()
            }
            if (perMillString.isNone()) {
                perMillString = perMill.toString()
            }
            if (monetarySeparatorString.isNone()) {
                monetarySeparatorString = monetarySeparator.toString()
            }
            if (monetaryGroupingSeparatorString.isNone()) {
                monetaryGroupingSeparatorString = monetaryGroupingSeparator.toString()
            }
        }
        if (serialVersionOnStream < 10) {
            approximatelyString = "~"
        }
        serialVersionOnStream = currentSerialVersion
        currency = Currency.getInstance(intlCurrencySymbol)
        setDigitStrings(digitStrings)
    }

    private var zeroDigit: Char = '\u{0000}'

    private var digits: Array<Char>

    private var digitStrings: Array<String>

     private var codePointZero: Int32 = 0

    private var groupingSeparator: Char = '\u{0000}'

    private var groupingSeparatorString: String

    private var decimalSeparator: Char = '\u{0000}'

    private var decimalSeparatorString: String

    private var perMill: Char = '\u{0000}'

    private var perMillString: String

    private var percent: Char = '\u{0000}'

    private var percentString: String

    private var digit: Char = '\u{0000}'

    private var sigDigit: Char = '\u{0000}'

    private var patternSeparator: Char = '\u{0000}'

    private var infinity: String

    private var NaN: String

    private var minusSign: Char = '\u{0000}'

    private var minusString: String

    private var plusSign: Char = '\u{0000}'

    private var plusString: String

    private var approximatelyString: String

    private var currencySymbol: String

    private var intlCurrencySymbol: String

    private var monetarySeparator: Char = '\u{0000}'

    private var monetarySeparatorString: String

    private var monetaryGroupingSeparator: Char = '\u{0000}'

    private var monetaryGroupingSeparatorString: String

    private var exponential: Char = '\u{0000}'

    private var exponentSeparator: String

    private var padEscape: Char = '\u{0000}'

    private var requestedLocale: Locale = None

    private var ulocale: ULocale

    private var exponentMultiplicationSign: String

    private static let serialVersionUID = 5772796243397350300

    private static let currentSerialVersion = 10

    private var serialVersionOnStream = currentSerialVersion

    private static let cachedLocaleData: CacheBase<ULocale, DecimalFormatSymbols_CacheData, Void> = DecimalFormatSymbols_1()

    private var currencyPattern: String

    public func getLocale(Type: ULocale_Type): ULocale {
        return if (refEq(Type, ULocale.ACTUAL_LOCALE)) { this.actualLocale } else { this.validLocale }
    }

    func setLocale(valid: ULocale, actual: ULocale): Unit {
        if ((valid.isNone()) != (actual.isNone())) {
            throw IllegalArgumentException()
        }
        this.validLocale = valid
        this.actualLocale = actual
    }

    private var validLocale: ULocale

    private var actualLocale: ULocale

     private var currency: Currency
}


class DecimalFormatSymbols_DecFmtDataSink <: UResource_Sink {
    private var numberElements: Array<String>

    public init(numberElements: Array<String>) {
        super()
        this.numberElements = numberElements
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let symbolsTable = value.getTable()
        var j = 0
        while (symbolsTable.getKeyAndValue(j, key, value)) {
            var i = 0
            while (i < Int32(DecimalFormatSymbols.SYMBOL_KEYS.size)) {
                if (key.contentEquals(DecimalFormatSymbols.SYMBOL_KEYS[Int64(i)])) {
                    if (numberElements[Int64(i)].isNone()) {
                        numberElements[Int64(i)] = value.toString()
                    }
                    break
                }
                i++
            }
            j++
        }
    }
}


class DecimalFormatSymbols_1 <: SoftCache<ULocale, DecimalFormatSymbols_CacheData, Void> {
    init() {
        super()
    }

    override protected func createInstance(locale: ULocale, unused: Void): DecimalFormatSymbols_CacheData {
        return DecimalFormatSymbols.loadData(locale)
    }
}


class DecimalFormatSymbols_CacheData {
    let validLocale: ULocale

    let digits: Array<String>

    let numberElements: Array<String>

    public init(loc: ULocale, digits: Array<String>, numberElements: Array<String>) {
        validLocale = loc
        this.digits = digits
        this.numberElements = numberElements
    }
}
