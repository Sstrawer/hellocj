package icu4cj.text



public class TimeUnitFormat <: MeasureFormat {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    
    public static let FULL_NAME = 0

    
    public static let ABBREVIATED_NAME = 1

    private static let TOTAL_STYLES = 2

    private static let serialVersionUID = -3707773153184971529

    private var format: NumberFormat

    private var locale: ULocale

    private var style: Int32 = 0

     private var timeUnitToCountToPatterns: Map<TimeUnit, Map<String, Array<Object>>> = None

     private var pluralRules: PluralRules

     private var isReady: Bool = false

    private static let DEFAULT_PATTERN_FOR_SECOND = "{0} s"

    private static let DEFAULT_PATTERN_FOR_MINUTE = "{0} min"

    private static let DEFAULT_PATTERN_FOR_HOUR = "{0} h"

    private static let DEFAULT_PATTERN_FOR_DAY = "{0} d"

    private static let DEFAULT_PATTERN_FOR_WEEK = "{0} w"

    private static let DEFAULT_PATTERN_FOR_MONTH = "{0} m"

    private static let DEFAULT_PATTERN_FOR_YEAR = "{0} y"

    
    public init() {
        this(ULocale.getDefault(), FULL_NAME)
    }

    
    public init(locale: ULocale) {
        this(locale, FULL_NAME)
    }

    
    public init(locale: Locale) {
        this(locale, FULL_NAME)
    }

    
    public init(locale: ULocale, style: Int32) {
        super(locale, if (style == FULL_NAME) { MeasureFormat_FormatWidth.WIDE } else { MeasureFormat_FormatWidth.SHORT })
        format = super.getNumberFormatInternal()
        if (style < FULL_NAME || style >= TOTAL_STYLES) {
            throw IllegalArgumentException("style should be either FULL_NAME or ABBREVIATED_NAME style")
        }
        this.style = style
        isReady = false
    }

    private init(locale: ULocale, style: Int32, numberFormat: NumberFormat) {
        this(locale, style)
        if (numberFormat.isSome()) {
            setNumberFormat(numberFormat.clone())
        }
    }

    
    public init(locale: Locale, style: Int32) {
        this(ULocale.forLocale(locale), style)
    }

    
    public func setLocale(locale: ULocale): TimeUnitFormat {
        setLocale(locale, locale)
        clearCache()
        return this
    }

    
    public func setLocale(locale: Locale): TimeUnitFormat {
        return setLocale(ULocale.forLocale(locale))
    }

    
    public func setNumberFormat(format: NumberFormat): TimeUnitFormat {
        if (refEq(format, this.format)) {
            return this
        }
        if (format.isNone()) {
            if (locale.isNone()) {
                isReady = false
            } else {
                this.format = NumberFormat.getNumberInstance(locale)
            }
        } else {
            this.format = format
        }
        clearCache()
        return this
    }

    
    public override func getNumberFormat(): NumberFormat {
        return format.clone()
    }

    public override func getNumberFormatInternal(): NumberFormat {
        return format
    }

    public override func getNumberFormatter(): LocalizedNumberFormatter {
        return format.toNumberFormatter()
    }

    
    public override func parseObject(source: String, pos: ParsePosition): TimeUnitAmount {
        if (!isReady) {
            setup()
        }
        var resultNumber: Number = None
        var resultTimeUnit: TimeUnit
        let oldPos = pos.getIndex()
        var newPos = -1
        var longestParseDistance = 0
        var countOfLongestMatch: String
        for (timeUnit in SetCollectionView<TimeUnit>(timeUnitToCountToPatterns.keys())) {
            let countToPattern = timeUnitToCountToPatterns.get(timeUnit)
            for (patternEntry in countToPattern.entrySet()) {
                let count = patternEntry.getKey()
                var styl = FULL_NAME
                while (styl < TOTAL_STYLES) {
                    let pattern = (patternEntry.getValue())[Int64(styl)]
                    pos.setErrorIndex(-1)
                    pos.setIndex(oldPos)
                    let parsed = pattern.parseObject(source, pos)
                    if (pos.getErrorIndex() != -1 || pos.getIndex() == oldPos) {
                        continue
                    }
                    var temp: Number = None
                    if (Int32(parsed.size) != 0) {
                        let tempObj = parsed[0]
                        if (checkOptionalIs<Number, Object>(tempObj)) {
                            temp = tempObj
                        } else {
                            try {
                                temp = format.parse(toString(tempObj))
                            } catch (e: ParseException) {
                                continue
                            }
                        }
                    }
                    let parseDistance = pos.getIndex() - oldPos
                    if (parseDistance > longestParseDistance) {
                        resultNumber = temp
                        resultTimeUnit = timeUnit
                        newPos = pos.getIndex()
                        longestParseDistance = parseDistance
                        countOfLongestMatch = count
                    }
                    styl++
                }
            }
        }
        if (resultNumber.isNone() && longestParseDistance != 0) {
            if (countOfLongestMatch == "zero") {
                resultNumber = 0
            } else if (countOfLongestMatch == "one") {
                resultNumber = 1
            } else if (countOfLongestMatch == "two") {
                resultNumber = 2
            } else {
                resultNumber = 3
            }
        }
        if (longestParseDistance == 0) {
            pos.setIndex(oldPos)
            pos.setErrorIndex(0)
            return None
        } else {
            pos.setIndex(newPos)
            pos.setErrorIndex(-1)
            return TimeUnitAmount(resultNumber, resultTimeUnit)
        }
    }

    private func setup(): Unit {
        if (locale.isNone()) {
            if (format.isSome()) {
                locale = format.getLocale(None)
            } else {
                locale = ULocale.getDefault(ULocale_Category.FORMAT)
            }
            setLocale(locale, locale)
        }
        if (format.isNone()) {
            format = NumberFormat.getNumberInstance(locale)
        }
        pluralRules = PluralRules.forLocale(locale)
        timeUnitToCountToPatterns = HashMap<TimeUnit, Map<String, Array<Object>>>()
        let pluralKeywords = pluralRules.getKeywords()
        setup("units/duration", timeUnitToCountToPatterns, FULL_NAME, pluralKeywords)
        setup("unitsShort/duration", timeUnitToCountToPatterns, ABBREVIATED_NAME, pluralKeywords)
        isReady = true
    }

    private func setup(resourceKey: String, timeUnitToCountToPatterns: Map<TimeUnit, Map<String, Array<Object>>>, style: Int32, pluralKeywords: Set<String>): Unit {
        try {
            let resource = UResourceBundle.getBundleInstance(ICUData.ICU_UNIT_BASE_NAME, locale)
            let sink = TimeUnitFormat_TimeUnitFormatSetupSink(timeUnitToCountToPatterns, style, pluralKeywords, locale)
            resource.getAllItemsWithFallback(resourceKey, sink)
        } catch (e: MissingResourceException) { }
        let timeUnits = TimeUnit.values()
        let keywords = pluralRules.getKeywords()
        var i = 0
        while (i < Int32(timeUnits.size)) {
            let timeUnit = timeUnits[Int64(i)]
            var countToPatterns = timeUnitToCountToPatterns.get(timeUnit)
            if (countToPatterns.isNone()) {
                countToPatterns = TreeMap() as Map<String, Array<Object>>
                timeUnitToCountToPatterns.put(timeUnit, countToPatterns)
            }
            for (pluralCount in keywords) {
                if (countToPatterns.get(pluralCount).isNone() || countToPatterns.get(pluralCount)[Int64(style)].isNone()) {
                    searchInTree(resourceKey, style, timeUnit, pluralCount, pluralCount, countToPatterns)
                }
            }
            i++
        }
    }

    private func searchInTree(resourceKey: String, styl: Int32, timeUnit: TimeUnit, srcPluralCount: String, searchPluralCount: String, countToPatterns: Map<String, Array<Object>>): Unit {
        var parentLocale = locale
        let srcTimeUnitName: String = timeUnit.toString()
        while (parentLocale.isSome()) {
            try {
                var unitsRes = UResourceBundle.getBundleInstance(ICUData.ICU_UNIT_BASE_NAME, parentLocale)
                unitsRes = unitsRes.getWithFallback(resourceKey)
                let oneUnitRes = unitsRes.getWithFallback(srcTimeUnitName)
                let pattern = oneUnitRes.getStringWithFallback(searchPluralCount)
                let messageFormat = MessageFormat(pattern, locale)
                var pair = countToPatterns.get(srcPluralCount)
                if (pair.isNone()) {
                    pair = Array<Object>(2)
                    countToPatterns.put(srcPluralCount, pair)
                }
                pair[Int64(styl)] = messageFormat
                return
            } catch (e: MissingResourceException) { }
            parentLocale = parentLocale.getFallback()
        }
        if (parentLocale.isNone() && resourceKey == "unitsShort") {
            searchInTree("units", styl, timeUnit, srcPluralCount, searchPluralCount, countToPatterns)
            if (countToPatterns.get(srcPluralCount).isSome() && countToPatterns.get(srcPluralCount)[Int64(styl)].isSome()) {
                return
            }
        }
        if (searchPluralCount == "other") {
            var messageFormat: MessageFormat
            if (refEq(timeUnit, TimeUnit.SECOND)) {
                messageFormat = MessageFormat(DEFAULT_PATTERN_FOR_SECOND, locale)
            } else if (refEq(timeUnit, TimeUnit.MINUTE)) {
                messageFormat = MessageFormat(DEFAULT_PATTERN_FOR_MINUTE, locale)
            } else if (refEq(timeUnit, TimeUnit.HOUR)) {
                messageFormat = MessageFormat(DEFAULT_PATTERN_FOR_HOUR, locale)
            } else if (refEq(timeUnit, TimeUnit.WEEK)) {
                messageFormat = MessageFormat(DEFAULT_PATTERN_FOR_WEEK, locale)
            } else if (refEq(timeUnit, TimeUnit.DAY)) {
                messageFormat = MessageFormat(DEFAULT_PATTERN_FOR_DAY, locale)
            } else if (refEq(timeUnit, TimeUnit.MONTH)) {
                messageFormat = MessageFormat(DEFAULT_PATTERN_FOR_MONTH, locale)
            } else if (refEq(timeUnit, TimeUnit.YEAR)) {
                messageFormat = MessageFormat(DEFAULT_PATTERN_FOR_YEAR, locale)
            }
            var pair = countToPatterns.get(srcPluralCount)
            if (pair.isNone()) {
                pair = Array<Object>(2)
                countToPatterns.put(srcPluralCount, pair)
            }
            pair[Int64(styl)] = messageFormat
        } else {
            searchInTree(resourceKey, styl, timeUnit, srcPluralCount, "other", countToPatterns)
        }
    }

    
    public override func clone(): Object {
        let result = super.clone()
        result.format = format.clone()
        return result
    }

    private func writeReplace(): Object {
        return super.toTimeUnitProxy()
    }

    private func readResolve(): Object {
        return TimeUnitFormat(locale, style, format)
    }
}


class TimeUnitFormat_TimeUnitFormatSetupSink <: UResource_Sink {
    var timeUnitToCountToPatterns: Map<TimeUnit, Map<String, Array<Object>>> = None

    var style: Int32 = 0

    var pluralKeywords: Set<String>

    var locale: ULocale

    var beenHere: Bool = false

    init(timeUnitToCountToPatterns: Map<TimeUnit, Map<String, Array<Object>>>, style: Int32, pluralKeywords: Set<String>, locale: ULocale) {
        super()
        this.timeUnitToCountToPatterns = timeUnitToCountToPatterns
        this.style = style
        this.pluralKeywords = pluralKeywords
        this.locale = locale
        this.beenHere = false
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        if (beenHere) {
            return
        } else {
            beenHere = true
        }
        let units = value.getTable()
        var i = 0
        while (units.getKeyAndValue(i, key, value)) {
            let timeUnitName: String = key.toString()
            var timeUnit: TimeUnit
            if (timeUnitName == "year") {
                timeUnit = TimeUnit.YEAR
            } else if (timeUnitName == "month") {
                timeUnit = TimeUnit.MONTH
            } else if (timeUnitName == "day") {
                timeUnit = TimeUnit.DAY
            } else if (timeUnitName == "hour") {
                timeUnit = TimeUnit.HOUR
            } else if (timeUnitName == "minute") {
                timeUnit = TimeUnit.MINUTE
            } else if (timeUnitName == "second") {
                timeUnit = TimeUnit.SECOND
            } else if (timeUnitName == "week") {
                timeUnit = TimeUnit.WEEK
            } else {
                continue
            }
            var countToPatterns = timeUnitToCountToPatterns.get(timeUnit)
            if (countToPatterns.isNone()) {
                countToPatterns = TreeMap() as Map<String, Array<Object>>
                timeUnitToCountToPatterns.put(timeUnit, countToPatterns)
            }
            let countsToPatternTable = value.getTable()
            var j = 0
            while (countsToPatternTable.getKeyAndValue(j, key, value)) {
                let pluralCount: String = key.toString()
                if (!pluralKeywords.contains(pluralCount)) {
                    continue
                }
                var pair = countToPatterns.get(pluralCount)
                if (pair.isNone()) {
                    pair = Array<Object>(2)
                    countToPatterns.put(pluralCount, pair)
                }
                if (pair[Int64(style)].isNone()) {
                    let pattern = value.getString()
                    let messageFormat = MessageFormat(pattern, locale)
                    pair[Int64(style)] = messageFormat
                }
                j++
            }
            i++
        }
    }
}
