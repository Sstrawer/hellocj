package icu4cj.text


public class DateIntervalInfo <: Cloneable & Freezable<DateIntervalInfo> & Serializable {
    static let currentSerialVersion = 1

    static let CALENDAR_FIELD_TO_PATTERN_LETTER: Array<String> = ["G", "y", "M", "w", "W", "d", "D", "E", "F", "a", "h", "H", "m", "s", "S", "z", " ", "Y", "e", "u", "g", "A", " ", " "]

    private static let serialVersionUID = 1

    private static let MINIMUM_SUPPORTED_CALENDAR_FIELD = Calendar.MILLISECOND

    static var CALENDAR_KEY: String = "calendar"

    static var INTERVAL_FORMATS_KEY: String = "intervalFormats"

    private static var FALLBACK_STRING: String = "fallback"

    private static var LATEST_FIRST_PREFIX: String = "latestFirst:"

    private static var EARLIEST_FIRST_PREFIX: String = "earliestFirst:"

    private static let DIICACHE: ICUCache<String, DateIntervalInfo> = SimpleCache<String, DateIntervalInfo>()

    private var fFallbackIntervalPattern: String

    private var fFirstDateInPtnIsLaterDate = false

    var fIntervalPatterns: Map<String, Map<String, DateIntervalInfo_PatternInfo>> = None

      private var frozen = false

     private var fIntervalPatternsReadOnly = false

    
    public init() {
        fIntervalPatterns = HashMap<String, Map<String, DateIntervalInfo_PatternInfo>>()
        fFallbackIntervalPattern = "{0} \u{2013} {1}"
    }

    public init(locale: ULocale) {
        initializeData(locale)
    }

    public init(locale: Locale) {
        this(ULocale.forLocale(locale))
    }

    private func initializeData(locale: ULocale): Unit {
        let key: String = locale.toString()
        let dii = DIICACHE.get(key)
        if (dii.isNone()) {
            setup(locale)
            fIntervalPatternsReadOnly = true
            DIICACHE.put(key, clone().freeze())
        } else {
            initializeFromReadOnlyPatterns(dii)
        }
    }

    private func initializeFromReadOnlyPatterns(dii: DateIntervalInfo): Unit {
        fFallbackIntervalPattern = dii.fFallbackIntervalPattern
        fFirstDateInPtnIsLaterDate = dii.fFirstDateInPtnIsLaterDate
        fIntervalPatterns = dii.fIntervalPatterns
        fIntervalPatternsReadOnly = true
    }

    private func setup(locale: ULocale): Unit {
        let DEFAULT_HASH_SIZE = 19
        fIntervalPatterns = HashMap<String, Map<String, DateIntervalInfo_PatternInfo>>(Int64(DEFAULT_HASH_SIZE))
        fFallbackIntervalPattern = "{0} \u{2013} {1}"
        try {
            var calendarTypeToUse = locale.getKeywordValue("calendar")
            if (calendarTypeToUse.isNone()) {
                let preferredCalendarTypes = Calendar.getKeywordValuesForLocale("calendar", locale, true)
                calendarTypeToUse = preferredCalendarTypes[0]
            }
            if (calendarTypeToUse.isNone()) {
                calendarTypeToUse = "gregorian"
            }
            let sink = DateIntervalInfo_DateIntervalSink(this)
            let resource = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, locale)
            let fallbackPattern = resource.getStringWithFallback((CALENDAR_KEY) + "/" + (calendarTypeToUse) + "/" + (INTERVAL_FORMATS_KEY) + "/" + (FALLBACK_STRING))
            setFallbackIntervalPattern(fallbackPattern)
            let loadedCalendarTypes: Set<String> = HashSet<String>()
            while (calendarTypeToUse.isSome()) {
                if (loadedCalendarTypes.contains(calendarTypeToUse)) {
                    throw ICUException("Loop in calendar type fallback: " + (calendarTypeToUse))
                }
                loadedCalendarTypes.put(calendarTypeToUse)
                let pathToIntervalFormats: String = (CALENDAR_KEY) + "/" + (calendarTypeToUse)
                resource.getAllItemsWithFallback(pathToIntervalFormats, sink)
                calendarTypeToUse = sink.getAndResetNextCalendarType()
            }
        } catch (e: MissingResourceException) { }
    }

    private static func splitPatternInto2Part(intervalPattern: String): Int32 {
        var inQuote = false
        var prevCh = Char(0)
        var count = 0
        let patternRepeated = Array<Int32>(58) { _ => 0 }
        let PATTERN_CHAR_BASE = 65
        var i: Int32 = 0
        var foundRepetition = false
        i = 0
        while (i < Int32(intervalPattern.size)) {
            let ch = Char(intervalPattern[Int64(i)])
            if (ch != prevCh && count > 0) {
                let repeated = patternRepeated[Int64(Int32(UInt32(prevCh)) - PATTERN_CHAR_BASE)]
                if (repeated == 0) {
                    patternRepeated[Int64(Int32(UInt32(prevCh)) - PATTERN_CHAR_BASE)] = 1
                } else {
                    foundRepetition = true
                    break
                }
                count = 0
            }
            if (ch == ''') {
                if ((i + 1) < Int32(intervalPattern.size) && Char(intervalPattern[Int64(i + 1)]) == ''') {
                    i++
                } else {
                    inQuote = !inQuote
                }
            } else if (!inQuote && ((Int32(UInt32(ch)) >= 97 && Int32(UInt32(ch)) <= 122) || (Int32(UInt32(ch)) >= 65 && Int32(UInt32(ch)) <= 90))) {
                prevCh = ch
                count++
            }
            i++
        }
        if (count > 0 && foundRepetition == false) {
            if (patternRepeated[Int64(Int32(UInt32(prevCh)) - PATTERN_CHAR_BASE)] == 0) {
                count = 0
            }
        }
        return (i - count)
    }

    public func setIntervalPattern(skeleton: String, lrgDiffCalUnit: Int32, intervalPattern: String): Unit {
        if (frozen) {
            throw UnsupportedOperationException("no modification is allowed after DII is frozen")
        }
        if (lrgDiffCalUnit > MINIMUM_SUPPORTED_CALENDAR_FIELD) {
            throw IllegalArgumentException("calendar field is larger than MINIMUM_SUPPORTED_CALENDAR_FIELD")
        }
        if (fIntervalPatternsReadOnly) {
            fIntervalPatterns = cloneIntervalPatterns(fIntervalPatterns)
            fIntervalPatternsReadOnly = false
        }
        let ptnInfo = setIntervalPatternInternally(skeleton, CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(lrgDiffCalUnit)], intervalPattern)
        if (lrgDiffCalUnit == Calendar.HOUR_OF_DAY) {
            setIntervalPattern(skeleton, CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.AM_PM)], ptnInfo)
            setIntervalPattern(skeleton, CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.HOUR)], ptnInfo)
        } else if (lrgDiffCalUnit == Calendar.DAY_OF_MONTH || lrgDiffCalUnit == Calendar.DAY_OF_WEEK) {
            setIntervalPattern(skeleton, CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.DATE)], ptnInfo)
        }
    }

    public func setIntervalPatternInternally(skeleton: String, lrgDiffCalUnit: String, intervalPattern: String): DateIntervalInfo_PatternInfo {
        var tempintervalPattern = intervalPattern
        var patternsOfOneSkeleton = fIntervalPatterns.get(skeleton)
        var emptyHash = false
        if (patternsOfOneSkeleton.isNone()) {
            patternsOfOneSkeleton = HashMap<String, DateIntervalInfo_PatternInfo>()
            emptyHash = true
        }
        var order = fFirstDateInPtnIsLaterDate
        if (tempintervalPattern.startsWith(LATEST_FIRST_PREFIX)) {
            order = true
            let prefixLength = Int32(LATEST_FIRST_PREFIX.size)
            tempintervalPattern = tempintervalPattern[Int64(prefixLength)..tempintervalPattern.size]
        } else if (tempintervalPattern.startsWith(EARLIEST_FIRST_PREFIX)) {
            order = false
            let earliestFirstLength = Int32(EARLIEST_FIRST_PREFIX.size)
            tempintervalPattern = tempintervalPattern[Int64(earliestFirstLength)..tempintervalPattern.size]
        }
        let itvPtnInfo = genPatternInfo(tempintervalPattern, order)
        patternsOfOneSkeleton.put(lrgDiffCalUnit, itvPtnInfo)
        if (emptyHash == true) {
            fIntervalPatterns.put(skeleton, patternsOfOneSkeleton)
        }
        return itvPtnInfo
    }

    private func setIntervalPattern(skeleton: String, lrgDiffCalUnit: String, ptnInfo: DateIntervalInfo_PatternInfo): Unit {
        let patternsOfOneSkeleton = fIntervalPatterns.get(skeleton)
        patternsOfOneSkeleton.put(lrgDiffCalUnit, ptnInfo)
    }

    
    public static func genPatternInfo(intervalPattern: String, laterDateFirst: Bool): DateIntervalInfo_PatternInfo {
        let splitPoint = splitPatternInto2Part(intervalPattern)
        let firstPart: String = intervalPattern[0..Int64(splitPoint)]
        var secondPart: String
        if (splitPoint < Int32(intervalPattern.size)) {
            secondPart = intervalPattern[Int64(splitPoint)..intervalPattern.size]
        }
        return DateIntervalInfo_PatternInfo(firstPart, secondPart, laterDateFirst)
    }

    public func getIntervalPattern(skeleton: String, field: Int32): DateIntervalInfo_PatternInfo {
        if (field > MINIMUM_SUPPORTED_CALENDAR_FIELD) {
            throw IllegalArgumentException("no support for field less than MILLISECOND")
        }
        let patternsOfOneSkeleton = fIntervalPatterns.get(skeleton)
        if (patternsOfOneSkeleton.isSome()) {
            let intervalPattern = patternsOfOneSkeleton.get(CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(field)])
            if (intervalPattern.isSome()) {
                return intervalPattern
            }
        }
        return None
    }

    public func getFallbackIntervalPattern(): String {
        return fFallbackIntervalPattern
    }

    public func setFallbackIntervalPattern(fallbackPattern: String): Unit {
        if (frozen) {
            throw UnsupportedOperationException("no modification is allowed after DII is frozen")
        }
        let firstPatternIndex = indexOfWrap(fallbackPattern.indexOf("{0}"))
        let secondPatternIndex = indexOfWrap(fallbackPattern.indexOf("{1}"))
        if (firstPatternIndex == -1 || secondPatternIndex == -1) {
            throw IllegalArgumentException("no pattern {0} or pattern {1} in fallbackPattern")
        }
        if (firstPatternIndex > secondPatternIndex) {
            fFirstDateInPtnIsLaterDate = true
        }
        fFallbackIntervalPattern = fallbackPattern
    }

    public func getDefaultOrder(): Bool {
        return fFirstDateInPtnIsLaterDate
    }

    public override func clone(): Object {
        if (frozen) {
            return this
        }
        return cloneUnfrozenDII()
    }

    private func cloneUnfrozenDII(): Object {
        try {
            let other = super.toString()
            other.fFallbackIntervalPattern = fFallbackIntervalPattern
            other.fFirstDateInPtnIsLaterDate = fFirstDateInPtnIsLaterDate
            if (fIntervalPatternsReadOnly) {
                other.fIntervalPatterns = fIntervalPatterns
                other.fIntervalPatternsReadOnly = true
            } else {
                other.fIntervalPatterns = cloneIntervalPatterns(fIntervalPatterns)
                other.fIntervalPatternsReadOnly = false
            }
            other.frozen = false
            return other
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException("clone is not supported", e as Exception)
        }
    }

    private static func cloneIntervalPatterns(patterns: Map<String, Map<String, DateIntervalInfo_PatternInfo>>): Map<String, Map<String, DateIntervalInfo_PatternInfo>> {
        let result: Map<String, Map<String, DateIntervalInfo_PatternInfo>> = HashMap<String, Map<String, DateIntervalInfo_PatternInfo>>()
        for (skeletonEntry in patterns.entrySet()) {
            let skeleton = skeletonEntry.getKey()
            let patternsOfOneSkeleton = skeletonEntry.getValue()
            let oneSetPtn: Map<String, DateIntervalInfo_PatternInfo> = HashMap<String, DateIntervalInfo_PatternInfo>()
            for (calEntry in patternsOfOneSkeleton.entrySet()) {
                let calField = calEntry.getKey()
                let value = calEntry.getValue()
                oneSetPtn.put(calField, value)
            }
            result.put(skeleton, oneSetPtn)
        }
        return result
    }

    public override func isFrozen(): Bool {
        return frozen
    }

    public override func freeze(): DateIntervalInfo {
        fIntervalPatternsReadOnly = true
        frozen = true
        return this
    }

    public override func cloneAsThawed(): DateIntervalInfo {
        let result = this.cloneUnfrozenDII()
        return result
    }

    static func parseSkeleton(skeleton: String, skeletonFieldWidth: Array<Int32>): Unit {
        let PATTERN_CHAR_BASE = 65
        var i = 0
        while (i < Int32(skeleton.size)) {
            skeletonFieldWidth[Int64(Int32(UInt32(Char(skeleton[Int64(i)]))) - PATTERN_CHAR_BASE)] += 1
            i++
        }
    }

    private static func stringNumeric(fieldWidth: Int32, anotherFieldWidth: Int32, patternLetter: Char): Bool {
        if (patternLetter == 'M') {
            if (fieldWidth <= 2 && anotherFieldWidth > 2 || fieldWidth > 2 && anotherFieldWidth <= 2) {
                return true
            }
        }
        return false
    }

    public func getBestSkeleton(inputSkeleton: String): DateIntervalFormat_BestMatchInfo {
        var tempinputSkeleton = inputSkeleton
        var bestSkeleton = tempinputSkeleton
        let inputSkeletonFieldWidth = Array<Int32>(58) { _ => 0 }
        let skeletonFieldWidth = Array<Int32>(58) { _ => 0 }
        let DIFFERENT_FIELD = 4096
        let STRING_NUMERIC_DIFFERENCE = 256
        let BASE = 65
        var replacedAlternateChars = false
        if (indexOfWrap(tempinputSkeleton.indexOf(UInt8(UInt32('z')))) != -1 || indexOfWrap(tempinputSkeleton.indexOf(UInt8(UInt32('k')))) != -1 || indexOfWrap(tempinputSkeleton.indexOf(UInt8(UInt32('K')))) != -1 || indexOfWrap(tempinputSkeleton.indexOf(UInt8(UInt32('a')))) != -1 || indexOfWrap(tempinputSkeleton.indexOf(UInt8(UInt32('b')))) != -1) {
            tempinputSkeleton = tempinputSkeleton.replace('z'.toString(), 'v'.toString())
            tempinputSkeleton = tempinputSkeleton.replace('k'.toString(), 'H'.toString())
            tempinputSkeleton = tempinputSkeleton.replace('K'.toString(), 'h'.toString())
            tempinputSkeleton = tempinputSkeleton.replace("a", "")
            tempinputSkeleton = tempinputSkeleton.replace("b", "")
            replacedAlternateChars = true
        }
        parseSkeleton(tempinputSkeleton, inputSkeletonFieldWidth)
        var bestDistance = Int32.Max
        var bestFieldDifference = 0
        for (skeleton in SetCollectionView<String>(fIntervalPatterns.keys())) {
            } while (false)
            parseSkeleton(skeleton, skeletonFieldWidth)
            var distance = 0
            var fieldDifference = 1
                    if (inputFieldWidth == 0) {
                        fieldDifference = -1
                        distance += DIFFERENT_FIELD
                    } else if (fieldWidth == 0) {
                        fieldDifference = -1
                        distance += DIFFERENT_FIELD
                    } else if (stringNumeric(inputFieldWidth, fieldWidth, Char(i + BASE))) {
                        distance += STRING_NUMERIC_DIFFERENCE
                    } else {
                        distance += abs(inputFieldWidth - fieldWidth)
                    }
                    i++
                }
            } while (false)
            if (distance < bestDistance) {
                bestSkeleton = skeleton
                bestDistance = distance
                bestFieldDifference = fieldDifference
            }
            if (distance == 0) {
                bestFieldDifference = 0
                break
            }
        }
        if (replacedAlternateChars && bestFieldDifference != -1) {
            bestFieldDifference = 2
        }
        return DateIntervalFormat_BestMatchInfo(bestSkeleton, bestFieldDifference)
    }

    public override func equals(a: Object): Bool {
        if (checkOptionalIs<DateIntervalInfo, Object>(a)) {
            let dtInfo = a
            return // Мapping is present but failed: refEq(fIntervalPatterns, dtInfo.fIntervalPatterns)
        }
        return false
    }

    public override func hashCode(): Int64 {
        return fIntervalPatterns.hashCode()
    }

    
    public func getPatterns(): Map<String, Set<String>> {
        let result = LinkedHashMap()
        for (entry in fIntervalPatterns.entrySet()) {
            result.put(entry.getKey(), LinkedHashSet(entry.getValue().keys() as Collection<??String>) as Set<String>)
        }
        return result as Map<String, Set<String>>
    }

    
    public func getRawPatterns(): Map<String, Map<String, DateIntervalInfo_PatternInfo>> {
        let result = LinkedHashMap()
        for (entry in fIntervalPatterns.entrySet()) {
            result.put(entry.getKey(), LinkedHashMap(entry.getValue()) as Map<String, DateIntervalInfo_PatternInfo>)
        }
        return result as Map<String, Map<String, DateIntervalInfo_PatternInfo>>
    }
}


public class DateIntervalInfo_PatternInfo <: Cloneable & Serializable {
    static let currentSerialVersion = 1

    private static let serialVersionUID = 1

    private let fIntervalPatternFirstPart: String

    private let fIntervalPatternSecondPart: String

    private let fFirstDateInPtnIsLaterDate: Bool

    public init(firstPart: String, secondPart: String, firstDateInPtnIsLaterDate: Bool) {
        fIntervalPatternFirstPart = firstPart
        fIntervalPatternSecondPart = secondPart
        fFirstDateInPtnIsLaterDate = firstDateInPtnIsLaterDate
    }

    public func getFirstPart(): String {
        return fIntervalPatternFirstPart
    }

    public func getSecondPart(): String {
        return fIntervalPatternSecondPart
    }

    public func firstDateInPtnIsLaterDate(): Bool {
        return fFirstDateInPtnIsLaterDate
    }

    public override func equals(a: Object): Bool {
        if (checkOptionalIs<DateIntervalInfo_PatternInfo, Object>(a)) {
            let patternInfo = a
            return Objects.equals(fIntervalPatternFirstPart, patternInfo.fIntervalPatternFirstPart) && Objects.equals(fIntervalPatternSecondPart, patternInfo.fIntervalPatternSecondPart) && fFirstDateInPtnIsLaterDate == patternInfo.fFirstDateInPtnIsLaterDate
        }
        return false
    }

    public override func hashCode(): Int64 {
        var hash = if (fIntervalPatternFirstPart.isSome()) { Int32(fIntervalPatternFirstPart.hashCode()) } else { 0 }
        if (fIntervalPatternSecondPart.isSome()) {
            hash ^= Int32(fIntervalPatternSecondPart.hashCode())
        }
        if (fFirstDateInPtnIsLaterDate) {
            hash ^= -1
        }
        return Int64(hash)
    }

    public override func toString(): String {
        return "{first=\u{00ab}" + (fIntervalPatternFirstPart) + "\u{00bb}, second=\u{00ab}" + (fIntervalPatternSecondPart) + "\u{00bb}, reversed:" + fFirstDateInPtnIsLaterDate.toString() + "}"
    }
}


class DateIntervalInfo_DateIntervalSink <: UResource_Sink {
    private static let ACCEPTED_PATTERN_LETTERS = "GyMdahHmsS"

    var dateIntervalInfo: DateIntervalInfo

    var nextCalendarType: String

    public init(dateIntervalInfo: DateIntervalInfo) {
        super()
        this.dateIntervalInfo = dateIntervalInfo
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let dateIntervalData = value.getTable()
        var i = 0
        while (dateIntervalData.getKeyAndValue(i, key, value)) {
            if (!key.contentEquals(DateIntervalInfo.INTERVAL_FORMATS_KEY)) {
                continue
            }
            if (value.getType() == ICUResourceBundle.ALIAS) {
                nextCalendarType = getCalendarTypeFromPath(value.getAliasString())
                break
            } else if (value.getType() == ICUResourceBundle.TABLE) {
                let skeletonData = value.getTable()
                var j = 0
                while (skeletonData.getKeyAndValue(j, key, value)) {
                    if (value.getType() == ICUResourceBundle.TABLE) {
                        processSkeletonTable(key, value)
                    }
                    j++
                }
                break
            }
            i++
        }
    }

    public func processSkeletonTable(key: UResource_Key, value: UResource_Value): Unit {
        let currentSkeleton: String = key.toString()
        let patternData = value.getTable()
        var k = 0
        while (patternData.getKeyAndValue(k, key, value)) {
            if (value.getType() == ICUResourceBundle.STRING) {
                let patternLetter = validateAndProcessPatternLetter(key)
                if (patternLetter.isSome()) {
                    let lrgDiffCalUnit: String = toString(patternLetter)
                    setIntervalPatternIfAbsent(currentSkeleton, lrgDiffCalUnit, value)
                }
            }
            k++
        }
    }

    public func getAndResetNextCalendarType(): String {
        let tmpCalendarType = nextCalendarType
        nextCalendarType = None
        return tmpCalendarType
    }

    private static let DATE_INTERVAL_PATH_PREFIX: String = "/LOCALE/" + (DateIntervalInfo.CALENDAR_KEY) + "/"

    private static let DATE_INTERVAL_PATH_SUFFIX: String = "/" + (DateIntervalInfo.INTERVAL_FORMATS_KEY)

    private func getCalendarTypeFromPath(path: String): String {
        if (path.startsWith(DATE_INTERVAL_PATH_PREFIX) && path.endsWith(DATE_INTERVAL_PATH_SUFFIX)) {
            return path[DATE_INTERVAL_PATH_PREFIX.size..Int64(Int32(path.size) - Int32(DATE_INTERVAL_PATH_SUFFIX.size))]
        }
        throw ICUException("Malformed 'intervalFormat' alias path: " + (path))
    }

    private func validateAndProcessPatternLetter(patternLetter: String): String {
        var temppatternLetter = patternLetter
        if (temppatternLetter.size != 1) {
            return None
        }
        let letter = temppatternLetter[0]
        if (indexOfWrap(ACCEPTED_PATTERN_LETTERS.indexOf(UInt8(UInt32(letter)))) < 0 && letter != 'B') {
            return None
        }
        if (letter == Char(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.HOUR_OF_DAY)][0])) {
            temppatternLetter = DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.HOUR)]
        }
        if (letter == 'B') {
            temppatternLetter = DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.AM_PM)]
        }
        return temppatternLetter
    }

    private func setIntervalPatternIfAbsent(currentSkeleton: String, lrgDiffCalUnit: String, intervalPattern: UResource_Value): Unit {
        let patternsOfOneSkeleton = dateIntervalInfo.fIntervalPatterns.get(currentSkeleton)
        if (patternsOfOneSkeleton.isNone() || !patternsOfOneSkeleton.contains(lrgDiffCalUnit)) {
            dateIntervalInfo.setIntervalPatternInternally(currentSkeleton, lrgDiffCalUnit, intervalPattern.toString())
        }
    }
}
