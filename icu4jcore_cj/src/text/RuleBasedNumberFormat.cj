package icu4cj.text

public class RuleBasedNumberFormat <: NumberFormat {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    static let serialVersionUID = -7664252765575395068

    public static let SPELLOUT = 1

    public static let ORDINAL = 2

    
    public static let DURATION = 3

    public static let NUMBERING_SYSTEM = 4

     private var ruleSets: Array<NFRuleSet>

     private var ruleSetsMap: Map<String, NFRuleSet> = None

     private var defaultRuleSet: NFRuleSet

    private var locale: ULocale

    private var roundingMode = BigDecimal.ROUND_UNNECESSARY

     private var scannerProvider: RbnfLenientScannerProvider

     private var lookedForScanner: Bool = false

     private var decimalFormatSymbols: DecimalFormatSymbols

     private var decimalFormat: DecimalFormat

     private var defaultInfinityRule: NFRule

     private var defaultNaNRule: NFRule

    private var lenientParse = false

     private var lenientParseRules: String

     private var postProcessRules: String

     private var postProcessor: RBNFPostProcessor

    private var ruleSetDisplayNames: Map<String, Array<String>> = None

    private var publicRuleSetNames: Array<String>

    private var capitalizationInfoIsSet = false

    private var capitalizationForListOrMenu = false

    private var capitalizationForStandAlone = false

     private var capitalizationBrkIter: BreakIterator

    private static let DEBUG = ICUDebug.enabled("rbnf")

    public init(description: String) {
        super()
        locale = ULocale.getDefault(ULocale_Category.FORMAT)
        initself(description, None)
    }

    public init(description: String, localizations: Array<Array<String>>) {
        super()
        locale = ULocale.getDefault(ULocale_Category.FORMAT)
        initself(description, localizations)
    }

    public init(description: String, locale: Locale) {
        this(description, ULocale.forLocale(locale))
    }

    public init(description: String, locale: ULocale) {
        super()
        this.locale = locale
        initself(description, None)
    }

    public init(description: String, localizations: Array<Array<String>>, locale: ULocale) {
        super()
        this.locale = locale
        initself(description, localizations)
    }

    public init(locale: Locale, format: Int32) {
        this(ULocale.forLocale(locale), format)
    }

    public init(locale: ULocale, format: Int32) {
        super()
        this.locale = locale
        let bundle = UResourceBundle.getBundleInstance(ICUData.ICU_RBNF_BASE_NAME, locale)
        let uloc = bundle.getULocale()
        setLocale(uloc, uloc)
        let description = StringBuilder()
        var localizations: Array<Array<String>>
        @AssertThrows[Exception]({
            let rules = bundle.getWithFallback("RBNFRules/" + (rulenames[Int64(format - 1)]))
            let it = rules.getIterator()
            while (it.hasNext()) {
                description.append(it.nextString())
            }
        } catch (e1: MissingResourceException) { }
        let locNamesBundle = bundle.findTopLevel(locnames[Int64(format - 1)])
        if (locNamesBundle.isSome()) {
            localizations = Array<Array<String>>(Int64(locNamesBundle.getSize())) { _ => Array<String>(0) }
            var i = 0
            while (i < Int32(localizations.size)) {
                localizations[Int64(i)] = locNamesBundle.get(i).getStringArray()
                i++
            }
        }
        initself(description.toString(), localizations)
    }

    private static let rulenames: Array<String> = ["SpelloutRules", "OrdinalRules", "DurationRules", "NumberingSystemRules"]

    private static let locnames: Array<String> = ["SpelloutLocalizations", "OrdinalLocalizations", "DurationLocalizations", "NumberingSystemLocalizations"]

    public init(format: Int32) {
        this(ULocale.getDefault(ULocale_Category.FORMAT), format)
    }

    public override func clone(): Object {
        return super.clone()
    }

    public override func equals(that: Object): Bool {
        if (!(checkOptionalIs<RuleBasedNumberFormat, Object>(that))) {
            return false
        } else {
            let that2 = that
            if (!locale.equals(that2.locale) || lenientParse != that2.lenientParse) {
                return false
            }
            if (Int32(ruleSets.size) != Int32(that2.ruleSets.size)) {
                return false
            }
            var i = 0
            while (i < Int32(ruleSets.size)) {
                if (!ruleSets[Int64(i)].equals(that2.ruleSets[Int64(i)])) {
                    return false
                }
                i++
            }
            return true
        }
    }

    public override func hashCode(): Int64 {
        return super.hashCode()
    }

    public override func toString(): String {
        let result = StringBuilder()
        for (ruleSet in ruleSets) {
            result.append(ruleSet.toString())
        }
        return result.toString()
    }

    private func writeObject(out: ObjectOutputStream): Unit {
        out.writeUTF(this.toString())
        out.writeObject(this.locale)
        out.writeInt(this.roundingMode)
    }

    private func readObject(input: ObjectInputStream): Unit {
        let description = input.readUTF()
        var loc: ULocale
        try {
            loc = input.readObject()
        } catch (e: Exception) {
            loc = ULocale.getDefault(ULocale_Category.FORMAT)
        }
        try {
            roundingMode = input.readInt()
        } catch (ignored: Exception) { }
        let temp = RuleBasedNumberFormat(description, loc)
        ruleSets = temp.ruleSets
        ruleSetsMap = temp.ruleSetsMap
        defaultRuleSet = temp.defaultRuleSet
        publicRuleSetNames = temp.publicRuleSetNames
        decimalFormatSymbols = temp.decimalFormatSymbols
        decimalFormat = temp.decimalFormat
        locale = temp.locale
        defaultInfinityRule = temp.defaultInfinityRule
        defaultNaNRule = temp.defaultNaNRule
    }

    public func getRuleSetNames(): Array<String> {
        return publicRuleSetNames.clone()
    }

    public func getRuleSetDisplayNameLocales(): Array<ULocale> {
        if (ruleSetDisplayNames.isSome()) {
            let s: Set<String> = SetCollectionView<String>(ruleSetDisplayNames.keys())
            let locales = s.toArray(size))
            stableSort(locales, String.CASE_INSENSITIVE_ORDER)
            let result = Array<ULocale>(locales.size)
            var i = 0
            while (i < Int32(locales.size)) {
                result[Int64(i)] = ULocale(locales[Int64(i)])
                i++
            }
            return result
        }
        return None
    }

    private func getNameListForLocale(loc: ULocale): Array<String> {
        if (loc.isSome() && ruleSetDisplayNames.isSome()) {
            let localeNames = [loc.getBaseName(), ULocale.getDefault(ULocale_Category.DISPLAY).getBaseName()]
            for (lname in localeNames) {
                while (Int32(lname.size) > 0) {
                    let names = ruleSetDisplayNames.get(lname)
                    if (names.isSome()) {
                        return names
                    }
                    lname = ULocale.getFallbackStatic(lname)
                }
            }
        }
        return None
    }

    public func getRuleSetDisplayNames(loc: ULocale): Array<String> {
        var names = getNameListForLocale(loc)
        if (names.isSome()) {
            return names.clone()
        }
        names = getRuleSetNames()
        var i = 0
        while (i < Int32(names.size)) {
            names[Int64(i)] = names[Int64(i)][1..]
            i++
        }
        return names
    }

    public func getRuleSetDisplayNames(): Array<String> {
        return getRuleSetDisplayNames(ULocale.getDefault(ULocale_Category.DISPLAY))
    }

    public func getRuleSetDisplayName(ruleSetName: String, loc: ULocale): String {
        let rsnames = publicRuleSetNames
        var ix = 0
        while (ix < Int32(rsnames.size)) {
            if (rsnames[Int64(ix)].equals(ruleSetName)) {
                let names = getNameListForLocale(loc)
                if (names.isSome()) {
                    return names[Int64(ix)]
                }
                return rsnames[Int64(ix)][1..]
            }
            ix++
        }
        throw IllegalArgumentException("unrecognized rule set name: " + (ruleSetName))
    }

    public func getRuleSetDisplayName(ruleSetName: String): String {
        return getRuleSetDisplayName(ruleSetName, ULocale.getDefault(ULocale_Category.DISPLAY))
    }

    public func format(number: Float64, ruleSet: String): String {
        if (ruleSet.startsWith("%%")) {
            throw IllegalArgumentException("Can't use internal rule set")
        }
        return adjustForContext(format(number, findRuleSet(ruleSet)))
    }

    public func format(number: Int64, ruleSet: String): String {
        if (ruleSet.startsWith("%%")) {
            throw IllegalArgumentException("Can't use internal rule set")
        }
        return adjustForContext(format(number, findRuleSet(ruleSet)))
    }

    public override func format(number: Float64, toAppendTo: StringBuffer, ignore: FieldPosition): StringBuffer {
        if (Int32(toAppendTo.size) == 0) {
            toAppendTo.append(adjustForContext(format(number, defaultRuleSet)))
        } else {
            toAppendTo.append(format(number, defaultRuleSet))
        }
        return toAppendTo
    }

    public override func format(number: Int64, toAppendTo: StringBuffer, ignore: FieldPosition): StringBuffer {
        if (Int32(toAppendTo.size) == 0) {
            toAppendTo.append(adjustForContext(format(number, defaultRuleSet)))
        } else {
            toAppendTo.append(format(number, defaultRuleSet))
        }
        return toAppendTo
    }

    public override func format(number: BigInt, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        return format(BigDecimal(number), toAppendTo, pos)
    }

    public override func format(number: BigDecimal, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        return format(BigDecimal(number), toAppendTo, pos)
    }

    private static let MAX_VALUE = BigDecimal.valueOf(Int64.Max)

    private static let MIN_VALUE = BigDecimal.valueOf(Int64.Min)

    public override func format(number: BigDecimal, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        if (MIN_VALUE.compareTo(number) > 0 || MAX_VALUE.compareTo(number) < 0) {
            return getDecimalFormat().format(number, toAppendTo, pos)
        }
        if (number.scale() == 0) {
            return format(number.longValue(), toAppendTo, pos)
        }
        return format(number.doubleValue(), toAppendTo, pos)
    }

    public override func parse(text: String, parsePosition: ParsePosition): Number {
        let workingText: String = text[Int64(parsePosition.getIndex())..]
        let workingPos = ParsePosition(0)
        var tempResult: Number = None
        var result = NFRule.ZERO
        let highWaterMark = ParsePosition(workingPos.getIndex())
        var i = Int32(ruleSets.size) - 1
        while (i >= 0) {
            if (!ruleSets[Int64(i)].isPublic() || !ruleSets[Int64(i)].isParseableMethod()) {
                continue
            }
            tempResult = ruleSets[Int64(i)].parse(workingText, workingPos, Float64.Max, 0)
            if (workingPos.getIndex() > highWaterMark.getIndex()) {
                result = tempResult
                highWaterMark.setIndex(workingPos.getIndex())
            }
            if (highWaterMark.getIndex() == Int32(workingText.size)) {
                break
            }
            workingPos.setIndex(0)
            i--
        }
        parsePosition.setIndex(parsePosition.getIndex() + highWaterMark.getIndex())
        return result
    }

    public func setLenientParseMode(enabled: Bool): Unit {
        lenientParse = enabled
    }

    public func lenientParseEnabled(): Bool {
        return lenientParse
    }

    public func setLenientScannerProvider(scannerProvider: RbnfLenientScannerProvider): Unit {
        this.scannerProvider = scannerProvider
    }

    public func getLenientScannerProvider(): RbnfLenientScannerProvider {
        if (scannerProvider.isNone() && lenientParse && !lookedForScanner) {
            try {
                lookedForScanner = true
                let cls: ClassTypeInfo = TypeInfo.get("com.ibm.icu.impl.text.RbnfScannerProviderImpl") as ClassTypeInfo
                let provider = cls.construct([0]) as RbnfLenientScannerProvider
                setLenientScannerProvider(provider)
            })
        }
        return scannerProvider
    }

    public func setDefaultRuleSet(ruleSetName: String): Unit {
        if (ruleSetName.isNone()) {
            if (Int32(publicRuleSetNames.size) > 0) {
                defaultRuleSet = findRuleSet(publicRuleSetNames[0])
            } else {
                defaultRuleSet = None
                var n = Int32(ruleSets.size)
                while (match (0) { case _ => n--; n } >= 0) {
                    let currentName = ruleSets[Int64(n)].getName()
                    if (currentName == "%spellout-numbering" || currentName == "%digits-ordinal" || currentName == "%duration") {
                        defaultRuleSet = ruleSets[Int64(n)]
                        return
                    }
                }
                n = Int32(ruleSets.size)
                while (match (0) { case _ => n--; n } >= 0) {
                    if (ruleSets[Int64(n)].isPublic()) {
                        defaultRuleSet = ruleSets[Int64(n)]
                        break
                    }
                }
            }
        } else if (ruleSetName.startsWith("%%")) {
            throw IllegalArgumentException("cannot use private rule set: " + (ruleSetName))
        } else {
            defaultRuleSet = findRuleSet(ruleSetName)
        }
    }

    public func getDefaultRuleSetName(): String {
        if (defaultRuleSet.isSome() && defaultRuleSet.isPublic()) {
            return defaultRuleSet.getName()
        }
        return ""
    }

    public func setDecimalFormatSymbols(newSymbols: DecimalFormatSymbols): Unit {
        if (newSymbols.isSome()) {
            decimalFormatSymbols = newSymbols.clone()
            if (decimalFormat.isSome()) {
                decimalFormat.setDecimalFormatSymbols(decimalFormatSymbols)
            }
            if (defaultInfinityRule.isSome()) {
                defaultInfinityRule = None
                getDefaultInfinityRule()
            }
            if (defaultNaNRule.isSome()) {
                defaultNaNRule = None
                getDefaultNaNRule()
            }
            for (ruleSet in ruleSets) {
                ruleSet.setDecimalFormatSymbols(decimalFormatSymbols)
            }
        }
    }

    public override func setContext(context: DisplayContext): Unit {
        super.setContext(context)
        if (!capitalizationInfoIsSet && (refEq(context, DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU) || refEq(context, DisplayContext.CAPITALIZATION_FOR_STANDALONE))) {
            initCapitalizationContextInfo(locale)
            capitalizationInfoIsSet = true
        }
        if (capitalizationBrkIter.isNone() && (refEq(context, DisplayContext.CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE) || (refEq(context, DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU) && capitalizationForListOrMenu) || (refEq(context, DisplayContext.CAPITALIZATION_FOR_STANDALONE) && capitalizationForStandAlone))) {
            capitalizationBrkIter = BreakIterator.getSentenceInstance(locale)
        }
    }

    public override func getRoundingMode(): Int32 {
        return roundingMode
    }

    public override func setRoundingMode(roundingMode: Int32): Unit {
        if (roundingMode < BigDecimal.ROUND_UP || roundingMode > BigDecimal.ROUND_UNNECESSARY) {
            throw IllegalArgumentException("Invalid rounding mode: " + roundingMode.toString())
        }
        this.roundingMode = roundingMode
    }

    public func getDefaultRuleSet(): NFRuleSet {
        return defaultRuleSet
    }

    public func getLenientScanner(): RbnfLenientScanner {
        if (lenientParse) {
            let provider = getLenientScannerProvider()
            if (provider.isSome()) {
                return provider.get(locale, lenientParseRules)
            }
        }
        return None
    }

    public func getDecimalFormatSymbols(): DecimalFormatSymbols {
        if (decimalFormatSymbols.isNone()) {
            decimalFormatSymbols = DecimalFormatSymbols(locale)
        }
        return decimalFormatSymbols
    }

    public func getDecimalFormat(): DecimalFormat {
        if (decimalFormat.isNone()) {
            let pattern = getPattern(locale, NUMBERSTYLE)
            decimalFormat = DecimalFormat(pattern, getDecimalFormatSymbols())
        }
        return decimalFormat
    }

    public func createPluralFormat(pluralType: PluralRules_PluralType, pattern: String): PluralFormat {
        return PluralFormat(locale, pluralType, pattern, getDecimalFormat())
    }

    public func getDefaultInfinityRule(): NFRule {
        if (defaultInfinityRule.isNone()) {
            defaultInfinityRule = NFRule(this, "Inf: " + (getDecimalFormatSymbols().getInfinity()))
        }
        return defaultInfinityRule
    }

    public func getDefaultNaNRule(): NFRule {
        if (defaultNaNRule.isNone()) {
            defaultNaNRule = NFRule(this, "NaN: " + (getDecimalFormatSymbols().getNaN()))
        }
        return defaultNaNRule
    }

    private func extractSpecial(description: StringBuilder, specialName: String): String {
        var result: String
        let lp = description.indexOf(specialName)
        if (lp != -1) {
            if (lp == 0 || description.get(Int64(lp - 1)) == ';') {
                var lpEnd = description.indexOf(";%", lp)
                if (lpEnd == -1) {
                    lpEnd = Int32(description.size) - 1
                }
                var lpStart = lp + Int32(specialName.size)
                while (lpStart < lpEnd && PatternProps.isWhiteSpace(Int32(UInt32(description.get(Int64(lpStart)))))) {
                    lpStart++
                }
                result = description.substring(lpStart, lpEnd)
                description.delete(lp, lpEnd + 1)
            }
        }
        return result
    }

    private func initself(description: String, localizations: Array<Array<String>>): Unit {
        initLocalizations(localizations)
        let descBuf = stripWhitespace(description)
        lenientParseRules = extractSpecial(descBuf, "%%lenient-parse:")
        postProcessRules = extractSpecial(descBuf, "%%post-process:")
        var numRuleSets = 1
        var p = 0
        while ((match (0) { case _ => p = descBuf.indexOf(";%", p); p }) != -1) {
            numRuleSets++
            p += 2
        }
        ruleSets = Array<NFRuleSet>(Int64(numRuleSets))
        ruleSetsMap = HashMap<String, NFRuleSet>(Int64(numRuleSets * 2 + 1))
        defaultRuleSet = None
        var publicRuleSetCount = 0
        let ruleSetDescriptions = Array<String>(Int64(numRuleSets))
        var curRuleSet = 0
        var start = 0
        while (curRuleSet < Int32(ruleSets.size)) {
            p = descBuf.indexOf(";%", start)
            if (p < 0) {
                p = Int32(descBuf.size) - 1
            }
            ruleSetDescriptions[Int64(curRuleSet)] = descBuf.substring(start, p + 1)
            let ruleSet = NFRuleSet(this, ruleSetDescriptions, curRuleSet)
            ruleSets[Int64(curRuleSet)] = ruleSet
            let currentName = ruleSet.getName()
            ruleSetsMap.put(currentName, ruleSet)
            if (!currentName.startsWith("%%")) {
                publicRuleSetCount++
                if (defaultRuleSet.isNone() && currentName == "%spellout-numbering" || currentName == "%digits-ordinal" || currentName == "%duration") {
                    defaultRuleSet = ruleSet
                }
            }
            curRuleSet++
            start = p + 1
        }
        if (defaultRuleSet.isNone()) {
                    i--
                }
            } while (false)
        }
        if (defaultRuleSet.isNone()) {
            defaultRuleSet = ruleSets[Int64(Int32(ruleSets.size) - 1)]
        }
        } while (false)
        let publicRuleSetTemp = Array<String>(Int64(publicRuleSetCount))
        publicRuleSetCount = 0
                i--
            }
        } while (false)
        if (publicRuleSetNames.isSome()) {
    private func initLocalizations(localizations: Array<Array<String>>): Unit {
        if (localizations.isSome()) {
            publicRuleSetNames = localizations[0].clone()
            let m: Map<String, Array<String>> = HashMap<String, Array<String>>()
            var i = 1
            while (i < Int32(localizations.size)) {
                let data: Array<String> = localizations[Int64(i)]
                let loc = data[0]
                let names = Array<String>(Int64(Int32(data.size) - 1))
                if (Int32(names.size) != Int32(publicRuleSetNames.size)) {
                    throw IllegalArgumentException("public name length: " + Int32(publicRuleSetNames.size).toString() + " != localized names[" + i.toString() + "] length: " + Int32(names.size).toString())
                }
                arraycopy(data, 1, names, 0, names.size)
                m.put(loc, names)
                i++
            }
            if (!m.isEmpty()) {
                ruleSetDisplayNames = m
            }
        }
    }

    private func initCapitalizationContextInfo(theLocale: ULocale): Unit {
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, theLocale)
        try {
            let rdb = rb.getWithFallback("contextTransforms/number-spellout")
            let intVector = rdb.getIntVector()
            if (Int32(intVector.size) >= 2) {
                capitalizationForListOrMenu = (intVector[0] != 0)
                capitalizationForStandAlone = (intVector[1] != 0)
            }
        } catch (e: MissingResourceException) { }
    }

    private func stripWhitespace(description: String): StringBuilder {
        let result = StringBuilder()
        let descriptionLength = Int32(description.size)
        var start = 0
        while (start < descriptionLength) {
            while (start < descriptionLength && PatternProps.isWhiteSpace(Int32(UInt32(Char(description[Int64(start)]))))) {
                start++
            }
            if (start < descriptionLength && Char(description[Int64(start)]) == ';') {
                start += 1
                continue
            }
            let p = indexOfWrap(description.indexOf(UInt8(UInt32(';')), Int64(start)))
            if (p == -1) {
                result.append(description[Int64(start)..])
                break
            } else if (p < descriptionLength) {
                result.append(description[Int64(start)..Int64(p + 1)])
                start = p + 1
            } else {
                break
            }
        }
        return result
    }

    private func format(number: Float64, ruleSet: NFRuleSet): String {
        var tempnumber = number
        let result = StringBuilder()
        if (getRoundingMode() != BigDecimal.ROUND_UNNECESSARY && !Float64.isNaN(tempnumber) && !Float64.isInfinite(tempnumber)) {
            tempnumber = BigDecimal(tempnumber.toString()).setScale(getMaximumFractionDigits(), roundingMode).doubleValue()
        }
        ruleSet.format(tempnumber, result, 0, 0)
        postProcess(result, ruleSet)
        return result.toString()
    }

    private func format(number: Int64, ruleSet: NFRuleSet): String {
        let result = StringBuilder()
        if (number == Int64.Min) {
            result.append(getDecimalFormat().format(Int64.Min))
        } else {
            ruleSet.format(number, result, 0, 0)
        }
        postProcess(result, ruleSet)
        return result.toString()
    }

    private func postProcess(result: StringBuilder, ruleSet: NFRuleSet): Unit {
        if (postProcessRules.isSome()) {
            if (postProcessor.isNone()) {
                var ix = indexOfWrap(postProcessRules.indexOf(";"))
                if (ix == -1) {
                    ix = Int32(postProcessRules.size)
                }
                let ppClassName = postProcessRules[0..Int64(ix)].trimAscii()
                try {
                    let cls: ClassTypeInfo = TypeInfo.get(ppClassName) as ClassTypeInfo
                    postProcessor = cls.construct([0]) as RBNFPostProcessor
                    postProcessor.initself(this, postProcessRules)
                } catch (e: Exception) {
                    if (DEBUG) {
                        println("could not locate " + ppClassName + ", error " + TypeInfo.of(e).name + ", " + e.message)
                    }
                    postProcessor = None
                    postProcessRules = None
                    return
                }
            }
            postProcessor.process(result, ruleSet)
        }
    }

    private func adjustForContext(result: String): String {
        let capitalization = getContext(DisplayContext_Type.CAPITALIZATION)
        if (!refEq(capitalization, DisplayContext.CAPITALIZATION_NONE) && result.isSome() && Int32(result.size) > 0 && UCharacter.isLowerCase(result.codePointAt(0))) {
            if (refEq(capitalization, DisplayContext.CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE) || (refEq(capitalization, DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU) && capitalizationForListOrMenu) || (refEq(capitalization, DisplayContext.CAPITALIZATION_FOR_STANDALONE) && capitalizationForStandAlone)) {
                if (capitalizationBrkIter.isNone()) {
                    capitalizationBrkIter = BreakIterator.getSentenceInstance(locale)
                }
                return UCharacter.toTitleCase(locale, result, capitalizationBrkIter, UCharacter.TITLECASE_NO_LOWERCASE | UCharacter.TITLECASE_NO_BREAK_ADJUSTMENT)
            }
        }
        return result
    }

    public func findRuleSet(name: String): NFRuleSet {
        let result = ruleSetsMap.get(name)
        if (result.isNone()) {
            throw IllegalArgumentException("No rule set named " + (name))
        }
        return result
    }
}
