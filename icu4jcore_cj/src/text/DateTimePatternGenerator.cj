package icu4cj.text


public class DateTimePatternGenerator <: Freezable<DateTimePatternGenerator> & Cloneable & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private static let DEBUG = false

    public static func getEmptyInstance(): DateTimePatternGenerator {
        let instance = DateTimePatternGenerator()
        instance.addCanonicalItems()
        instance.fillInMissing()
        return instance
    }


    public static func getInstance(): DateTimePatternGenerator {
        return getInstance(ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public static func getInstance(uLocale: ULocale): DateTimePatternGenerator {
        return getFrozenInstance(uLocale).cloneAsThawed()
    }

    public static func getInstance(locale: Locale): DateTimePatternGenerator {
        return getInstance(ULocale.forLocale(locale))
    }

    
    public static func getFrozenInstance(uLocale: ULocale): DateTimePatternGenerator {
        let localeKey: String = uLocale.toString()
        var result = DTPNG_CACHE.get(localeKey)
        if (result.isSome()) {
            return result
        }
        result = DateTimePatternGenerator()
        result.initData(uLocale, false)
        result.freeze()
        DTPNG_CACHE.put(localeKey, result)
        return result
    }

    
    public static func getInstanceNoStdPat(uLocale: ULocale): DateTimePatternGenerator {
        let result = DateTimePatternGenerator()
        result.initData(uLocale, true)
        return result
    }

    private func initData(uLocale: ULocale, skipStdPatterns: Bool): Unit {
        let returnInfo = DateTimePatternGenerator_PatternInfo()
        addCanonicalItems()
        if (!skipStdPatterns) {
            addICUPatterns(returnInfo, uLocale)
        }
        addCLDRData(returnInfo, uLocale)
        if (!skipStdPatterns) {
            setDateTimeFromCalendar(uLocale)
        } else {
            setDateTimeFormat("{1} {0}")
        }
        setDecimalSymbols(uLocale)
        getAllowedHourFormats(uLocale)
        fillInMissing()
    }

    private func addICUPatterns(returnInfo: DateTimePatternGenerator_PatternInfo, uLocale: ULocale): Unit {
        var i = DateFormat.FULL
        while (i <= DateFormat.SHORT) {
            var df = DateFormat.getDateInstance(i, uLocale)
            addPattern(df.toPattern(), false, returnInfo)
            df = DateFormat.getTimeInstance(i, uLocale)
            addPattern(df.toPattern(), false, returnInfo)
            if (i == DateFormat.SHORT) {
                consumeShortTimePattern(df.toPattern(), returnInfo)
            }
            i++
        }
    }

    private func getCalendarTypeToUse(uLocale: ULocale): String {
        var calendarTypeToUse = uLocale.getKeywordValue("calendar")
        if (calendarTypeToUse.isNone()) {
            let preferredCalendarTypes = Calendar.getKeywordValuesForLocale("calendar", uLocale, true)
            calendarTypeToUse = preferredCalendarTypes[0]
        }
        if (calendarTypeToUse.isNone()) {
            calendarTypeToUse = "gregorian"
        }
        return calendarTypeToUse
    }

    private func consumeShortTimePattern(shortTimePattern: String, returnInfo: DateTimePatternGenerator_PatternInfo): Unit {
        hackTimes(returnInfo, shortTimePattern)
    }

    private func fillInMissing(): Unit {
        var i = 0
        while (i < TYPE_LIMIT) {
            if (getAppendItemFormat(i).isNone()) {
                setAppendItemFormat(i, "{0} \u{251c}{2}: {1}\u{2524}")
            }
            if (getFieldDisplayName(i, DateTimePatternGenerator_DisplayWidth.WIDE).isNone()) {
                setFieldDisplayName(i, DateTimePatternGenerator_DisplayWidth.WIDE, "F" + i.toString())
            }
            if (getFieldDisplayName(i, DateTimePatternGenerator_DisplayWidth.ABBREVIATED).isNone()) {
                setFieldDisplayName(i, DateTimePatternGenerator_DisplayWidth.ABBREVIATED, getFieldDisplayName(i, DateTimePatternGenerator_DisplayWidth.WIDE))
            }
            if (getFieldDisplayName(i, DateTimePatternGenerator_DisplayWidth.NARROW).isNone()) {
                setFieldDisplayName(i, DateTimePatternGenerator_DisplayWidth.NARROW, getFieldDisplayName(i, DateTimePatternGenerator_DisplayWidth.ABBREVIATED))
            }
            i++
        }
    }

    private func addCLDRData(returnInfo: DateTimePatternGenerator_PatternInfo, uLocale: ULocale): Unit {
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, uLocale)
        let calendarTypeToUse = getCalendarTypeToUse(uLocale)
        let appendItemFormatsSink = DateTimePatternGenerator_AppendItemFormatsSink(this)
        @AssertThrows[IllegalArgumentException]({
            rb.getAllChildrenWithFallback("calendar/" + (calendarTypeToUse) + "/appendItems", appendItemFormatsSink)
        } catch (e: MissingResourceException) { }
        let appendItemNamesSink = DateTimePatternGenerator_AppendItemNamesSink(this)
        try {
            rb.getAllChildrenWithFallback("fields", appendItemNamesSink)
        } catch (e: MissingResourceException) { }
        let availableFormatsSink = DateTimePatternGenerator_AvailableFormatsSink(this, returnInfo)
        try {
            rb.getAllChildrenWithFallback("calendar/" + (calendarTypeToUse) + "/availableFormats", availableFormatsSink)
        } catch (e: MissingResourceException) { }
    }

    private func setDateTimeFromCalendar(uLocale: ULocale): Unit {
        let cal = Calendar.getInstance(uLocale)
        var style = DateFormat.FULL
        while (style <= DateFormat.SHORT) {
            let dateTimeFormat = Calendar.getDateAtTimePattern(cal, uLocale, style)
            setDateTimeFormat(style, dateTimeFormat)
            style++
        }
    }

    private func setDecimalSymbols(uLocale: ULocale): Unit {
        let dfs = DecimalFormatSymbols(uLocale)
        setDecimal(dfs.getDecimalSeparator().toString())
    }

    static let LAST_RESORT_ALLOWED_HOUR_FORMAT: Array<String> = ["H"]

    private func getAllowedHourFormatsLangCountry(language: String, country: String): Array<String> {
        let langCountry: String = (language) + "_" + (country)
        var list = LOCALE_TO_ALLOWED_HOUR.get(langCountry)
        if (list.isNone()) {
            list = LOCALE_TO_ALLOWED_HOUR.get(country)
        }
        return list
    }

    private func getAllowedHourFormats(uLocale: ULocale): Unit {
        var language = uLocale.getLanguage()
        var country = ULocale.getRegionForSupplementalData(uLocale, false)
        if (language.isEmpty() || country.isEmpty()) {
            let max = ULocale.addLikelySubtags(uLocale)
            language = max.getLanguage()
            country = max.getCountry()
        }
        if (language.isEmpty()) {
            language = "und"
        }
        if (country.isEmpty()) {
            country = "001"
        }
        var list = getAllowedHourFormatsLangCountry(language, country)
        var defaultCharFromLocale: Character = None
        let hourCycle = uLocale.getKeywordValue("hours")
        if (hourCycle.isSome()) {
            match (hourCycle) {
                case "h24" => defaultCharFromLocale = Character.valueOf('k')
                case "h23" => defaultCharFromLocale = Character.valueOf('H')
                case "h12" => defaultCharFromLocale = Character.valueOf('h')
                case "h11" => defaultCharFromLocale = Character.valueOf('K')
                case _ => ()
            }
        }
        if (list.isNone()) {
            try {
                let region = Region.getInstance(country)
                country = region.toString()
                list = getAllowedHourFormatsLangCountry(language, country)
            })
        }
        if (list.isSome()) {
            defaultHourFormatChar = if (defaultCharFromLocale.isSome()) { defaultCharFromLocale.charValue() } else { Char(list[0][0]) }
            allowedHourFormats = list.clone(1..Int32(list.size) - 1)
        } else {
            allowedHourFormats = LAST_RESORT_ALLOWED_HOUR_FORMAT
            defaultHourFormatChar = if (defaultCharFromLocale.isSome()) { defaultCharFromLocale.charValue() } else { Char(allowedHourFormats[0][0]) }
        }
    }

    static let LOCALE_TO_ALLOWED_HOUR: Map<String, Array<String>>


    
    public func getDefaultHourFormatChar(): Char {
        return defaultHourFormatChar
    }

    
    public func setDefaultHourFormatChar(defaultHourFormatChar: Char): Unit {
        this.defaultHourFormatChar = defaultHourFormatChar
    }

    private func hackTimes(returnInfo: DateTimePatternGenerator_PatternInfo, shortTimePattern: String): Unit {
        fp.set(shortTimePattern)
        let mmss = StringBuilder()
        var gotMm = false
                } else {
                    let ch = Char(toString(item)[0])
                    if (ch == 'm') {
                        gotMm = true
                        mmss.append(item)
                    } else if (ch == 's') {
                        if (!gotMm) {
                            break
                        }
                        mmss.append(item)
                        addPattern(mmss.toString(), false, returnInfo)
                        break
                    } else if (gotMm || ch == 'z' || ch == 'Z' || ch == 'v' || ch == 'V') {
                        break
                    }
                }
                i++
            }
        } while (false)
        let variables = BitSet()
        let nuke = BitSet()
                            nuke.set(i)
                            j++
                        }
                    }
                }
                i++
            }
        } while (false)
        let hhmm = getFilteredPattern(fp, nuke)
        addPattern(hhmm, false, returnInfo)
    }

    private static func getFilteredPattern(fp: DateTimePatternGenerator_FormatParser, nuke: BitSet): String {
        let result = StringBuilder()
        var i = 0
        while (i < Int32(fp.items.size)) {
            if (nuke.get(i)) {
                continue
            }
            let item = fp.items[Int64(i)]
            if (item) {
                result.append(fp.quoteLiteral(toString(item)))
            } else {
                result.append(toString(item))
            }
            i++
        }
        return result.toString()
    }

    
    public static func getAppendFormatNumber(key: UResource_Key): Int32 {
        var i = 0
        while (i < Int32(CLDR_FIELD_APPEND.size)) {
            if (key.contentEquals(CLDR_FIELD_APPEND[Int64(i)])) {
                return i
            }
            i++
        }
        return -1
    }

    
    public static func getAppendFormatNumber(string: String): Int32 {
        var i = 0
        while (i < Int32(CLDR_FIELD_APPEND.size)) {
            if (CLDR_FIELD_APPEND[Int64(i)].equals(string)) {
                return i
            }
            i++
        }
        return -1
    }

    static func getCLDRFieldAndWidthNumber(key: UResource_Key): Int32 {
        var i = 0
        while (i < Int32(CLDR_FIELD_NAME.size)) {
            var j = 0
            while (j < DateTimePatternGenerator_DisplayWidth.COUNT) {
                let fullKey = CLDR_FIELD_NAME[Int64(i)].concat(CLDR_FIELD_WIDTH[Int64(j)].cldrKeyMethod())
                if (key.contentEquals(fullKey)) {
                    return i * DateTimePatternGenerator_DisplayWidth.COUNT + j
                }
                j++
            }
            i++
        }
        return -1
    }

    public func getBestPattern(skeleton: String): String {
        return getBestPattern(skeleton, None, MATCH_NO_OPTIONS)
    }

    public func getBestPattern(skeleton: String, options: Int32): String {
        return getBestPattern(skeleton, None, options)
    }

    private func getBestPattern(skeleton: String, skipMatcher: DateTimePatternGenerator_DateTimeMatcher, options: Int32): String {
        let flags = EnumSet.noneOf(TypeInfo.of<DateTimePatternGenerator_DTPGflags>() as ClassTypeInfo)
        let skeletonMapped = mapSkeletonMetacharacters(skeleton, flags)
        let datePattern: String
        let timePattern: String
        synchronized (getMonitorByObject(this)) {
            current.set(skeletonMapped, fp, false)
            let bestWithMatcher = getBestRaw(current, -1, _distanceInfo, skipMatcher)
            if (_distanceInfo.missingFieldMask == 0 && _distanceInfo.extraFieldMask == 0) {
                return adjustFieldTypes(bestWithMatcher, current, flags, options)
            }
            let neededFields = current.getFieldMask()
            datePattern = getBestAppending(current, neededFields & DATE_MASK, _distanceInfo, skipMatcher, flags, options)
            timePattern = getBestAppending(current, neededFields & TIME_MASK, _distanceInfo, skipMatcher, flags, options)
        }
        if (datePattern.isNone()) {
            return if (timePattern.isNone()) { "" } else { timePattern }
        }
        if (timePattern.isNone()) {
            return datePattern
        }
        let canonicalSkeleton = current.toCanonicalString()
        var style = DateFormat.SHORT
        var monthFieldLen = 0
        let monthFieldOffset = indexOfWrap(canonicalSkeleton.indexOf(UInt8(UInt32('M'))))
        if (monthFieldOffset >= 0) {
            monthFieldLen = 1 + indexOfWrap(canonicalSkeleton.lastIndexOf(UInt8(UInt32('M')))) - monthFieldOffset
        }
        if (monthFieldLen == 4) {
            if (indexOfWrap(canonicalSkeleton.indexOf(UInt8(UInt32('E')))) >= 0) {
                style = DateFormat.FULL
            } else {
                style = DateFormat.LONG
            }
        } else if (monthFieldLen == 3) {
            style = DateFormat.MEDIUM
        }
        return SimpleFormatterImpl.formatRawPattern(getDateTimeFormat(style), 2, 2, [timePattern, datePattern])
    }

    private func mapSkeletonMetacharacters(skeleton: String, flags: EnumSet): String {
        let skeletonCopy = StringBuilder()
        var inQuoted = false
        var patPos = 0
        while (patPos < Int32(skeleton.size)) {
            let patChr = Char(skeleton[Int64(patPos)])
            if (patChr == ''') {
                inQuoted = !inQuoted
            } else if (!inQuoted) {
                if (patChr == 'j' || patChr == 'C') {
                    var extraLen = 0
                    while (patPos + 1 < Int32(skeleton.size) && Char(skeleton[Int64(patPos + 1)]) == patChr) {
                        extraLen++
                        patPos++
                    }
                    var hourLen = 1 + (extraLen & 1)
                    var dayPeriodLen = if (extraLen < 2) { 1 } else { 3 + (shr(extraLen, 1)) }
                    var hourChar = 'h'
                    var dayPeriodChar = 'a'
                    if (patChr == 'j') {
                        hourChar = defaultHourFormatChar
                    } else {
                        let bestAllowed = allowedHourFormats[0]
                        hourChar = Char(bestAllowed[0])
                        let last = Char(bestAllowed[Int64(Int32(bestAllowed.size) - 1)])
                        if (last == 'b' || last == 'B') {
                            dayPeriodChar = last
                        }
                    }
                    if (hourChar == 'H' || hourChar == 'k') {
                        dayPeriodLen = 0
                    }
                    while (match (0) { case _ => dayPeriodLen--; dayPeriodLen + 1 } > 0) {
                        skeletonCopy.append(dayPeriodChar)
                    }
                    while (match (0) { case _ => hourLen--; hourLen + 1 } > 0) {
                        skeletonCopy.append(hourChar)
                    }
                } else if (patChr == 'J') {
                    skeletonCopy.append('H')
                    flags.add(DateTimePatternGenerator_DTPGflags.SKELETON_USES_CAP_J)
                } else {
                    skeletonCopy.append(patChr)
                }
            }
            patPos++
        }
        return skeletonCopy.toString()
    }

    public func addPattern(pattern: String, override: Bool, returnInfo: DateTimePatternGenerator_PatternInfo): DateTimePatternGenerator {
        return addPatternWithSkeleton(pattern, None, override, returnInfo)
    }

    
    public func addPatternWithSkeleton(pattern: String, skeletonToUse: String, override: Bool, returnInfo: DateTimePatternGenerator_PatternInfo): DateTimePatternGenerator {
        checkFrozen()
        let matcher: DateTimePatternGenerator_DateTimeMatcher
        if (skeletonToUse.isNone()) {
            matcher = DateTimePatternGenerator_DateTimeMatcher().set(pattern, fp, false)
        } else {
            matcher = DateTimePatternGenerator_DateTimeMatcher().set(skeletonToUse, fp, false)
        }
        let basePattern = matcher.getBasePattern()
        let previousPatternWithSameBase = basePattern_pattern.get(basePattern)
        if (previousPatternWithSameBase.isSome() && (!previousPatternWithSameBase.skeletonWasSpecified || (skeletonToUse.isSome() && !override))) {
            returnInfo.status = DateTimePatternGenerator_PatternInfo.BASE_CONFLICT
            returnInfo.conflictingPattern = previousPatternWithSameBase.pattern
            if (!override) {
                return this
            }
        }
        let previousValue = skeleton2pattern.get(matcher)
        if (previousValue.isSome()) {
            returnInfo.status = DateTimePatternGenerator_PatternInfo.CONFLICT
            returnInfo.conflictingPattern = previousValue.pattern
            if (!override || (skeletonToUse.isSome() && previousValue.skeletonWasSpecified)) {
                return this
            }
        }
        returnInfo.status = DateTimePatternGenerator_PatternInfo.OK
        returnInfo.conflictingPattern = ""
        let patWithSkelFlag = DateTimePatternGenerator_PatternWithSkeletonFlag(pattern, skeletonToUse.isSome())
        if (DEBUG) {
            println(matcher.asString() + " => " + patWithSkelFlag.toString())
        }
        skeleton2pattern.put(matcher, patWithSkelFlag)
        basePattern_pattern.put(basePattern, patWithSkelFlag)
        return this
    }

    public func getSkeleton(pattern: String): String {
        synchronized (getMonitorByObject(this)) {
            current.set(pattern, fp, false)
            return current.toString()
        }
    }

    
    public func getSkeletonAllowingDuplicates(pattern: String): String {
        synchronized (getMonitorByObject(this)) {
            current.set(pattern, fp, true)
            return current.toString()
        }
    }

    
    public func getCanonicalSkeletonAllowingDuplicates(pattern: String): String {
        synchronized (getMonitorByObject(this)) {
            current.set(pattern, fp, true)
            return current.toCanonicalString()
        }
    }

    public func getBaseSkeleton(pattern: String): String {
        synchronized (getMonitorByObject(this)) {
            current.set(pattern, fp, false)
            return current.getBasePattern()
        }
    }

    public func getSkeletons(result: Map<String, String>): Map<String, String> {
        var tempresult = result
        if (tempresult.isNone()) {
            tempresult = LinkedHashMap() as Map<String, String>
        }
        for (item in SetCollectionView<DateTimePatternGenerator_DateTimeMatcher>(skeleton2pattern.keys())) {
            let patternWithSkelFlag = skeleton2pattern.get(item)
            let pattern = patternWithSkelFlag.pattern
            if (CANONICAL_SET.contains(pattern)) {
                continue
            }
            tempresult.put(item.toString(), pattern)
        }
        return tempresult
    }

    public func getBaseSkeletons(result: Set<String>): Set<String> {
        var tempresult = result
        if (tempresult.isNone()) {
            tempresult = HashSet<String>()
        }
        tempresult.putAll(basePattern_pattern.keys())
        return tempresult
    }

    public func replaceFieldTypes(pattern: String, skeleton: String): String {
        return replaceFieldTypes(pattern, skeleton, MATCH_NO_OPTIONS)
    }

    public func replaceFieldTypes(pattern: String, skeleton: String, options: Int32): String {
        synchronized (getMonitorByObject(this)) {
            let patternNoMatcher = DateTimePatternGenerator_PatternWithMatcher(pattern, None)
            return adjustFieldTypes(patternNoMatcher, current.set(skeleton, fp, false), EnumSet.noneOf(TypeInfo.of<DateTimePatternGenerator_DTPGflags>() as ClassTypeInfo), options)
        }
    }

    public func setDateTimeFormat(dateTimeFormat: String): Unit {
        checkFrozen()
        var style = DateFormat.FULL
        while (style <= DateFormat.SHORT) {
            setDateTimeFormat(style, dateTimeFormat)
            style++
        }
    }

    public func getDateTimeFormat(): String {
        return getDateTimeFormat(DateFormat.MEDIUM)
    }

    public func setDateTimeFormat(style: Int32, dateTimeFormat: String): Unit {
        if (style < DateFormat.FULL || style > DateFormat.SHORT) {
            throw IllegalArgumentException("Illegal style here: " + style.toString())
        }
        checkFrozen()
        this.dateTimeFormats[Int64(style)] = dateTimeFormat
    }

    public func getDateTimeFormat(style: Int32): String {
        if (style < DateFormat.FULL || style > DateFormat.SHORT) {
            throw IllegalArgumentException("Illegal style here: " + style.toString())
        }
        return dateTimeFormats[Int64(style)]
    }

    public func setDecimal(decimal: String): Unit {
        checkFrozen()
        this.decimal = decimal
    }

    public func getDecimal(): String {
        return decimal
    }

    
    public func getRedundants(output: Collection<String>): Collection<String> {
        var tempoutput = output
        synchronized (getMonitorByObject(this)) {
            if (tempoutput.isNone()) {
                tempoutput = LinkedHashSet() as Collection<String>
            }
            for (cur in SetCollectionView<DateTimePatternGenerator_DateTimeMatcher>(skeleton2pattern.keys())) {
                let patternWithSkelFlag = skeleton2pattern.get(cur)
                let pattern = patternWithSkelFlag.pattern
                if (CANONICAL_SET.contains(pattern)) {
                    continue
                }
                let trial = getBestPattern(cur.toString(), cur, MATCH_NO_OPTIONS)
                if (trial.equals(pattern)) {
                    tempoutput.add(pattern)
                }
            }
            return tempoutput
        }
    }

    public static let ERA = 0

    public static let YEAR = 1

    public static let QUARTER = 2

    public static let MONTH = 3

    public static let WEEK_OF_YEAR = 4

    public static let WEEK_OF_MONTH = 5

    public static let WEEKDAY = 6

    public static let DAY = 7

    public static let DAY_OF_YEAR = 8

    public static let DAY_OF_WEEK_IN_MONTH = 9

    public static let DAYPERIOD = 10

    public static let HOUR = 11

    public static let MINUTE = 12

    public static let SECOND = 13

    public static let FRACTIONAL_SECOND = 14

    public static let ZONE = 15

    
    public static let TYPE_LIMIT = 16

    private static let APPENDITEM_WIDTH = DateTimePatternGenerator_DisplayWidth.WIDE

    private static let APPENDITEM_WIDTH_INT = APPENDITEM_WIDTH.ordinal

    static let CLDR_FIELD_WIDTH = DateTimePatternGenerator_DisplayWidth.values()

    public static let MATCH_NO_OPTIONS = 0

    public static let MATCH_HOUR_FIELD_LENGTH = shl(1, HOUR)

    
    public static let MATCH_MINUTE_FIELD_LENGTH = shl(1, MINUTE)

    
    public static let MATCH_SECOND_FIELD_LENGTH = shl(1, SECOND)

    public static let MATCH_ALL_FIELDS_LENGTH = (shl(1, TYPE_LIMIT)) - 1

    public func setAppendItemFormat(field: Int32, value: String): Unit {
        checkFrozen()
        appendItemFormats[Int64(field)] = value
    }

    public func getAppendItemFormat(field: Int32): String {
        return appendItemFormats[Int64(field)]
    }

    public func setAppendItemName(field: Int32, value: String): Unit {
        setFieldDisplayName(field, APPENDITEM_WIDTH, value)
    }

    public func getAppendItemName(field: Int32): String {
        return getFieldDisplayName(field, APPENDITEM_WIDTH)
    }

    public func getDefaultHourCycle(): DateFormat_HourCycle {
        match (getDefaultHourFormatChar()) {
            case 'h' => return DateFormat_HourCycle.HOUR_CYCLE_12
            case 'H' => return DateFormat_HourCycle.HOUR_CYCLE_23
            case 'k' => return DateFormat_HourCycle.HOUR_CYCLE_24
            case 'K' => return DateFormat_HourCycle.HOUR_CYCLE_11
            case _ => throw Exception("should be unreachable")
        }
    }

    
    public func setFieldDisplayName(field: Int32, width: DateTimePatternGenerator_DisplayWidth, value: String): Unit {
        checkFrozen()
        if (field < TYPE_LIMIT && field >= 0) {
            fieldDisplayNames[Int64(field)][Int64(width.ordinal)] = value
        }
    }

    public func getFieldDisplayName(field: Int32, width: DateTimePatternGenerator_DisplayWidth): String {
        if (field >= TYPE_LIMIT || field < 0) {
            return ""
        }
        return fieldDisplayNames[Int64(field)][Int64(width.ordinal)]
    }

    
    public static func isSingleField(skeleton: String): Bool {
        let first = Char(skeleton[0])
        var i = 1
        while (i < Int32(skeleton.size)) {
            if (Char(skeleton[Int64(i)]) != first) {
                return false
            }
            i++
        }
        return true
    }

    public func setAvailableFormat(key: String): Unit {
        checkFrozen()
        cldrAvailableFormatKeys.put(key)
    }

    public func isAvailableFormatSet(key: String): Bool {
        return cldrAvailableFormatKeys.contains(key)
    }

    public override func isFrozen(): Bool {
        return frozen
    }

    public override func freeze(): DateTimePatternGenerator {
        frozen = true
        return this
    }

    public override func cloneAsThawed(): DateTimePatternGenerator {
        let result = this.clone()
        frozen = false
        return result
    }

    public override func clone(): Object {
        try {
            let result = super.toString()
            result.skeleton2pattern = skeleton2pattern.clone()
            result.basePattern_pattern = basePattern_pattern.clone()
            result.dateTimeFormats = dateTimeFormats.clone()
            result.appendItemFormats = appendItemFormats.clone()
            result.fieldDisplayNames = fieldDisplayNames.clone()
            result.current = DateTimePatternGenerator_DateTimeMatcher()
            result.fp = DateTimePatternGenerator_FormatParser()
            result._distanceInfo = DateTimePatternGenerator_DistanceInfo()
            result.frozen = false
            return result
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException("Internal Error", e as Exception)
        }
    }

    
    public func skeletonsAreSimilar(id: String, skeleton: String): Bool {
        if (id.equals(skeleton)) {
            return true
        }
        let parser1 = getSet(id)
        let parser2 = getSet(skeleton)
        if (Int32(parser1.size) != Int32(parser2.size)) {
            return false
        }
        let it2: Iterator<String> = parser2.iterator()
        for (item in parser1) {
            let index1 = getCanonicalIndex(item, false)
            let item2 = it2.next()
            let index2 = getCanonicalIndex(item2, false)
            if (types[Int64(index1)][1] != types[Int64(index2)][1]) {
                return false
            }
        }
        return true
    }

    private func getSet(id: String): TreeSet {
        let items = fp.set(id).getItems()
        let result = TreeSet()
        for (obj in items) {
            let item: String = toString(obj)
            if (item.startsWith("G") || item.startsWith("a")) {
                continue
            }
            result.put(item)
        }
        return result
    }

    private var skeleton2pattern: TreeMap = TreeMap()

    private var basePattern_pattern: TreeMap = TreeMap()

    private var decimal: String = '?'

    private var dateTimeFormats: Array<String> = ["{1} {0}", "{1} {0}", "{1} {0}", "{1} {0}"]

    private var appendItemFormats: Array<String> = Array<String>(Int64(TYPE_LIMIT))

    private var fieldDisplayNames: Array<Array<String>> = Array<Array<String>>(Int64(TYPE_LIMIT)) { _ => Array<String>(Int64(DateTimePatternGenerator_DisplayWidth.COUNT)) }

    private var defaultHourFormatChar = 'H'

     private var frozen = false

     private var current: DateTimePatternGenerator_DateTimeMatcher = DateTimePatternGenerator_DateTimeMatcher()

     private var fp: DateTimePatternGenerator_FormatParser = DateTimePatternGenerator_FormatParser()

     private var _distanceInfo: DateTimePatternGenerator_DistanceInfo = DateTimePatternGenerator_DistanceInfo()

    private var allowedHourFormats: Array<String>

    private static let FRACTIONAL_MASK = shl(1, FRACTIONAL_SECOND)

    private static let SECOND_AND_FRACTIONAL_MASK = (shl(1, SECOND)) | (shl(1, FRACTIONAL_SECOND))

    private static var DTPNG_CACHE: ICUCache<String, DateTimePatternGenerator> = SimpleCache<String, DateTimePatternGenerator>()

    private func checkFrozen(): Unit {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify frozen object")
        }
    }

    private func getBestAppending(source: DateTimePatternGenerator_DateTimeMatcher, missingFields: Int32, distInfo: DateTimePatternGenerator_DistanceInfo, skipMatcher: DateTimePatternGenerator_DateTimeMatcher, flags: EnumSet, options: Int32): String {
        var tempflags = flags
        var resultPattern: String
        if (missingFields != 0) {
            let resultPatternWithMatcher = getBestRaw(source, missingFields, distInfo, skipMatcher)
            resultPattern = adjustFieldTypes(resultPatternWithMatcher, source, tempflags, options)
            while (distInfo.missingFieldMask != 0) {
                if ((distInfo.missingFieldMask & SECOND_AND_FRACTIONAL_MASK) == FRACTIONAL_MASK && (missingFields & SECOND_AND_FRACTIONAL_MASK) == SECOND_AND_FRACTIONAL_MASK) {
                    resultPatternWithMatcher.pattern = resultPattern
                    tempflags = EnumSet.copyOf(tempflags)
                    tempflags.add(DateTimePatternGenerator_DTPGflags.FIX_FRACTIONAL_SECONDS)
                    resultPattern = adjustFieldTypes(resultPatternWithMatcher, source, tempflags, options)
                    distInfo.missingFieldMask &= 
                    continue
                }
                let startingMask = distInfo.missingFieldMask
                let tempWithMatcher = getBestRaw(source, distInfo.missingFieldMask, distInfo, skipMatcher)
                let temp = adjustFieldTypes(tempWithMatcher, source, tempflags, options)
                let foundMask = startingMask & 
                let topField = getTopBitNumber(foundMask)
                resultPattern = SimpleFormatterImpl.formatRawPattern(getAppendFormat(topField), 2, 3, [resultPattern, temp, getAppendName(topField)])
            }
        }
        return resultPattern
    }

    private func getAppendName(foundMask: Int32): String {
        return "'" + (fieldDisplayNames[Int64(foundMask)][Int64(APPENDITEM_WIDTH_INT)]) + "'"
    }

    private func getAppendFormat(foundMask: Int32): String {
        return appendItemFormats[Int64(foundMask)]
    }

    private func getTopBitNumber(foundMask: Int32): Int32 {
        var tempfoundMask = foundMask
        var i = 0
        while (tempfoundMask != 0) {
            tempfoundMask = ushr(tempfoundMask, 1)
            i++
        }
        return i - 1
    }

    private func addCanonicalItems(): Unit {
        let patternInfo = DateTimePatternGenerator_PatternInfo()
        var i = 0
        while (i < Int32(CANONICAL_ITEMS.size)) {
            addPattern(String.valueOf(CANONICAL_ITEMS[Int64(i)]), false, patternInfo)
            i++
        }
    }

    private func getBestRaw(source: DateTimePatternGenerator_DateTimeMatcher, includeMask: Int32, missingFields: DateTimePatternGenerator_DistanceInfo, skipMatcher: DateTimePatternGenerator_DateTimeMatcher): DateTimePatternGenerator_PatternWithMatcher {
        var bestDistance = Int32.Max
        var bestMissingFieldMask = Int32.Min
        let bestPatternWithMatcher = DateTimePatternGenerator_PatternWithMatcher("", None)
        let tempInfo = DateTimePatternGenerator_DistanceInfo()
        for (trial in SetCollectionView<DateTimePatternGenerator_DateTimeMatcher>(skeleton2pattern.keys())) {
            if (trial.equals(skipMatcher)) {
                continue
            }
            let distance = source.getDistance(trial, includeMask, tempInfo)
            if (distance < bestDistance || (distance == bestDistance && bestMissingFieldMask < tempInfo.missingFieldMask)) {
                bestDistance = distance
                bestMissingFieldMask = tempInfo.missingFieldMask
                let patternWithSkelFlag = skeleton2pattern.get(trial)
                bestPatternWithMatcher.pattern = patternWithSkelFlag.pattern
                if (patternWithSkelFlag.skeletonWasSpecified) {
                    bestPatternWithMatcher.matcherWithSkeleton = trial
                } else {
                    bestPatternWithMatcher.matcherWithSkeleton = None
                }
                missingFields.setTo(tempInfo)
                if (distance == 0) {
                    break
                }
            }
        }
        return bestPatternWithMatcher
    }

    private func adjustFieldTypes(patternWithMatcher: DateTimePatternGenerator_PatternWithMatcher, inputRequest: DateTimePatternGenerator_DateTimeMatcher, flags: EnumSet, options: Int32): String {
        fp.set(patternWithMatcher.pattern)
        let newPattern = StringBuilder()
        for (item in fp.getItems()) {
            if (item) {
                newPattern.append(fp.quoteLiteral(item))
            } else {
                let variableField = item
                var fieldBuilder: StringBuilder = StringBuilder(variableField.toString())
                let Type = variableField.getType()
                if (flags.contains(DateTimePatternGenerator_DTPGflags.FIX_FRACTIONAL_SECONDS) && Type == SECOND) {
                    fieldBuilder.append(decimal)
                    inputRequest.original.appendFieldTo(FRACTIONAL_SECOND, fieldBuilder)
                } else if (inputRequest.Type[Int64(Type)] != 0) {
                    let reqFieldChar = inputRequest.original.getFieldChar(Type)
                    var reqFieldLen = inputRequest.original.getFieldLength(Type)
                    if (reqFieldChar == 'E' && reqFieldLen < 3) {
                        reqFieldLen = 3
                    }
                    var adjFieldLen = reqFieldLen
                    let matcherWithSkeleton = patternWithMatcher.matcherWithSkeleton
                    if ((Type == HOUR && (options & MATCH_HOUR_FIELD_LENGTH) == 0) || (Type == MINUTE && (options & MATCH_MINUTE_FIELD_LENGTH) == 0) || (Type == SECOND && (options & MATCH_SECOND_FIELD_LENGTH) == 0)) {
                        adjFieldLen = Int32(fieldBuilder.size)
                    } else if (matcherWithSkeleton.isSome() && reqFieldChar != 'c' && reqFieldChar != 'e') {
                        let skelFieldLen = matcherWithSkeleton.original.getFieldLength(Type)
                        let patFieldIsNumeric = variableField.isNumeric()
                        let skelFieldIsNumeric = matcherWithSkeleton.fieldIsNumeric(Type)
                        if (skelFieldLen == reqFieldLen || (patFieldIsNumeric && !skelFieldIsNumeric) || (skelFieldIsNumeric && !patFieldIsNumeric)) {
                            adjFieldLen = Int32(fieldBuilder.size)
                        }
                    }
                    var c = if (Type != HOUR && Type != MONTH && Type != WEEKDAY && (Type != YEAR || reqFieldChar == 'Y')) { reqFieldChar } else { fieldBuilder.get(0) }
                    if (c == 'E' && adjFieldLen < 3) {
                        c = 'e'
                    }
                    if (Type == HOUR) {
                        if (flags.contains(DateTimePatternGenerator_DTPGflags.SKELETON_USES_CAP_J) || reqFieldChar == defaultHourFormatChar) {
                            c = defaultHourFormatChar
                        } else if (reqFieldChar == 'h' && defaultHourFormatChar == 'K') {
                            c = 'K'
                        } else if (reqFieldChar == 'H' && defaultHourFormatChar == 'k') {
                            c = 'k'
                        } else if (reqFieldChar == 'k' && defaultHourFormatChar == 'H') {
                            c = 'H'
                        } else if (reqFieldChar == 'K' && defaultHourFormatChar == 'h') {
                            c = 'h'
                        }
                    }
                    fieldBuilder = StringBuilder()
                    var i = adjFieldLen
                    while (i > 0) {
                        fieldBuilder.append(c)
                        i--
                    }
                }
                newPattern.append(fieldBuilder)
            }
        }
        return newPattern.toString()
    }

    
    public func getFields(pattern: String): String {
        fp.set(pattern)
        let newPattern = StringBuilder()
        for (item in fp.getItems()) {
            if (item) {
                newPattern.append(fp.quoteLiteral(item))
            } else {
                newPattern.append("{" + (getName(toString(item))) + "}")
            }
        }
        return newPattern.toString()
    }

    static func showMask(mask: Int32): String {
        let result = StringBuilder()
        var i = 0
        while (i < TYPE_LIMIT) {
            if ((mask & (shl(1, i))) == 0) {
                continue
            }
            if (Int32(result.size) != 0) {
                result.append(" | ")
            }
            result.append(FIELD_NAME[Int64(i)])
            result.append(" ")
            i++
        }
        return result.toString()
    }

    private static let CLDR_FIELD_APPEND: Array<String> = ["Era", "Year", "Quarter", "Month", "Week", "*", "Day-Of-Week", "Day", "*", "*", "*", "Hour", "Minute", "Second", "*", "Timezone"]

    private static let CLDR_FIELD_NAME: Array<String> = ["era", "year", "quarter", "month", "week", "weekOfMonth", "weekday", "day", "dayOfYear", "weekdayOfMonth", "dayperiod", "hour", "minute", "second", "*", "zone"]

    private static let FIELD_NAME: Array<String> = ["Era", "Year", "Quarter", "Month", "Week_in_Year", "Week_in_Month", "Weekday", "Day", "Day_Of_Year", "Day_of_Week_in_Month", "Dayperiod", "Hour", "Minute", "Second", "Fractional_Second", "Zone"]

    static let CANONICAL_ITEMS: Array<String> = ["G", "y", "Q", "M", "w", "W", "E", "d", "D", "F", "a", "H", "m", "s", "S", "v"]

    private static let CANONICAL_SET: Set<String> = HashSet<String>(CANONICAL_ITEMS)

    private var cldrAvailableFormatKeys: Set<String> = HashSet<String>(20)

    static let DATE_MASK = (shl(1, DAYPERIOD)) - 1

    static let TIME_MASK = (shl(1, TYPE_LIMIT)) - 1 - DATE_MASK

    static let DELTA = 16

    static let NUMERIC = 256

    static let NONE = 0

    static let NARROW = -257

    static let SHORTER = -258

    static let SHORT = -259

    static let LONG = -260

    static let EXTRA_FIELD = 65536

    static let MISSING_FIELD = 4096

    private static func getName(s: String): String {
        let i = getCanonicalIndex(s, true)
        var name = FIELD_NAME[Int64(types[Int64(i)][1])]
        if (types[Int64(i)][2] < 0) {
            name += ":S"
        } else {
            name += ":N"
        }
        return name
    }

    static func getCanonicalIndex(s: String, strict: Bool): Int32 {
        let len = Int32(s.size)
        if (len == 0) {
            return -1
        }
        let ch = Int32(UInt32(Char(s[0])))
                i++
            }
        } while (false)
        var bestRow = -1
                bestRow = i
                if (row[3] > len) {
                    continue
                }
                if (row[Int64(Int32(row.size) - 1)] < len) {
                    continue
                }
                return i
                i++
            }
        } while (false)
        return if (strict) { -1 } else { bestRow }
    }

    static func getCanonicalChar(field: Int32, reference: Char): Char {
        if (reference == 'h' || reference == 'K') {
            return 'h'
        }
        var i = 0
        while (i < Int32(types.size)) {
            let row: Array<Int32> = types[Int64(i)]
            if (row[1] == field) {
                return Char(row[0])
            }
            i++
        }
        throw IllegalArgumentException("Could not find field " + field.toString())
    }

    static let types: Array<Array<Int32>> = [[Int32(UInt32('G')), ERA, SHORT, 1, 3], [Int32(UInt32('G')), ERA, LONG, 4], [Int32(UInt32('G')), ERA, NARROW, 5], [Int32(UInt32('y')), YEAR, NUMERIC, 1, 20], [Int32(UInt32('Y')), YEAR, NUMERIC + DELTA, 1, 20], [Int32(UInt32('u')), YEAR, NUMERIC + 2 * DELTA, 1, 20], [Int32(UInt32('r')), YEAR, NUMERIC + 3 * DELTA, 1, 20], [Int32(UInt32('U')), YEAR, SHORT, 1, 3], [Int32(UInt32('U')), YEAR, LONG, 4], [Int32(UInt32('U')), YEAR, NARROW, 5], [Int32(UInt32('Q')), QUARTER, NUMERIC, 1, 2], [Int32(UInt32('Q')), QUARTER, SHORT, 3], [Int32(UInt32('Q')), QUARTER, LONG, 4], [Int32(UInt32('Q')), QUARTER, NARROW, 5], [Int32(UInt32('q')), QUARTER, NUMERIC + DELTA, 1, 2], [Int32(UInt32('q')), QUARTER, SHORT - DELTA, 3], [Int32(UInt32('q')), QUARTER, LONG - DELTA, 4], [Int32(UInt32('q')), QUARTER, NARROW - DELTA, 5], [Int32(UInt32('M')), MONTH, NUMERIC, 1, 2], [Int32(UInt32('M')), MONTH, SHORT, 3], [Int32(UInt32('M')), MONTH, LONG, 4], [Int32(UInt32('M')), MONTH, NARROW, 5], [Int32(UInt32('L')), MONTH, NUMERIC + DELTA, 1, 2], [Int32(UInt32('L')), MONTH, SHORT - DELTA, 3], [Int32(UInt32('L')), MONTH, LONG - DELTA, 4], [Int32(UInt32('L')), MONTH, NARROW - DELTA, 5], [Int32(UInt32('l')), MONTH, NUMERIC + DELTA, 1, 1], [Int32(UInt32('w')), WEEK_OF_YEAR, NUMERIC, 1, 2], [Int32(UInt32('W')), WEEK_OF_MONTH, NUMERIC, 1], [Int32(UInt32('E')), WEEKDAY, SHORT, 1, 3], [Int32(UInt32('E')), WEEKDAY, LONG, 4], [Int32(UInt32('E')), WEEKDAY, NARROW, 5], [Int32(UInt32('E')), WEEKDAY, SHORTER, 6], [Int32(UInt32('c')), WEEKDAY, NUMERIC + 2 * DELTA, 1, 2], [Int32(UInt32('c')), WEEKDAY, SHORT - 2 * DELTA, 3], [Int32(UInt32('c')), WEEKDAY, LONG - 2 * DELTA, 4], [Int32(UInt32('c')), WEEKDAY, NARROW - 2 * DELTA, 5], [Int32(UInt32('c')), WEEKDAY, SHORTER - 2 * DELTA, 6], [Int32(UInt32('e')), WEEKDAY, NUMERIC + DELTA, 1, 2], [Int32(UInt32('e')), WEEKDAY, SHORT - DELTA, 3], [Int32(UInt32('e')), WEEKDAY, LONG - DELTA, 4], [Int32(UInt32('e')), WEEKDAY, NARROW - DELTA, 5], [Int32(UInt32('e')), WEEKDAY, SHORTER - DELTA, 6], [Int32(UInt32('d')), DAY, NUMERIC, 1, 2], [Int32(UInt32('g')), DAY, NUMERIC + DELTA, 1, 20], [Int32(UInt32('D')), DAY_OF_YEAR, NUMERIC, 1, 3], [Int32(UInt32('F')), DAY_OF_WEEK_IN_MONTH, NUMERIC, 1], [Int32(UInt32('a')), DAYPERIOD, SHORT, 1, 3], [Int32(UInt32('a')), DAYPERIOD, LONG, 4], [Int32(UInt32('a')), DAYPERIOD, NARROW, 5], [Int32(UInt32('b')), DAYPERIOD, SHORT - DELTA, 1, 3], [Int32(UInt32('b')), DAYPERIOD, LONG - DELTA, 4], [Int32(UInt32('b')), DAYPERIOD, NARROW - DELTA, 5], [Int32(UInt32('B')), DAYPERIOD, SHORT - 3 * DELTA, 1, 3], [Int32(UInt32('B')), DAYPERIOD, LONG - 3 * DELTA, 4], [Int32(UInt32('B')), DAYPERIOD, NARROW - 3 * DELTA, 5], [Int32(UInt32('H')), HOUR, NUMERIC + 10 * DELTA, 1, 2], [Int32(UInt32('k')), HOUR, NUMERIC + 11 * DELTA, 1, 2], [Int32(UInt32('h')), HOUR, NUMERIC, 1, 2], [Int32(UInt32('K')), HOUR, NUMERIC + DELTA, 1, 2], [Int32(UInt32('m')), MINUTE, NUMERIC, 1, 2], [Int32(UInt32('s')), SECOND, NUMERIC, 1, 2], [Int32(UInt32('A')), SECOND, NUMERIC + DELTA, 1, 1000], [Int32(UInt32('S')), FRACTIONAL_SECOND, NUMERIC, 1, 1000], [Int32(UInt32('v')), ZONE, SHORT - 2 * DELTA, 1], [Int32(UInt32('v')), ZONE, LONG - 2 * DELTA, 4], [Int32(UInt32('z')), ZONE, SHORT, 1, 3], [Int32(UInt32('z')), ZONE, LONG, 4], [Int32(UInt32('Z')), ZONE, NARROW - DELTA, 1, 3], [Int32(UInt32('Z')), ZONE, LONG - DELTA, 4], [Int32(UInt32('Z')), ZONE, SHORT - DELTA, 5], [Int32(UInt32('O')), ZONE, SHORT - DELTA, 1], [Int32(UInt32('O')), ZONE, LONG - DELTA, 4], [Int32(UInt32('V')), ZONE, SHORT - DELTA, 1], [Int32(UInt32('V')), ZONE, LONG - DELTA, 2], [Int32(UInt32('V')), ZONE, LONG - 1 - DELTA, 3], [Int32(UInt32('V')), ZONE, LONG - 2 - DELTA, 4], [Int32(UInt32('X')), ZONE, NARROW - DELTA, 1], [Int32(UInt32('X')), ZONE, SHORT - DELTA, 2], [Int32(UInt32('X')), ZONE, LONG - DELTA, 4], [Int32(UInt32('x')), ZONE, NARROW - DELTA, 1], [Int32(UInt32('x')), ZONE, SHORT - DELTA, 2], [Int32(UInt32('x')), ZONE, LONG - DELTA, 4]]
}


class DateTimePatternGenerator_AppendItemFormatsSink <: UResource_Sink {
    let this_0: DateTimePatternGenerator

    init(this_0: DateTimePatternGenerator) {
        super()
        this.this_0 = this_0
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let field = DateTimePatternGenerator.getAppendFormatNumber(key)
        if (field < 0) {
            return
        }
        if (this_0.getAppendItemFormat(field).isNone()) {
            this_0.setAppendItemFormat(field, value.toString())
        }
    }
}


class DateTimePatternGenerator_AppendItemNamesSink <: UResource_Sink {
    let this_0: DateTimePatternGenerator

    init(this_0: DateTimePatternGenerator) {
        super()
        this.this_0 = this_0
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let fieldAndWidth = DateTimePatternGenerator.getCLDRFieldAndWidthNumber(key)
        if (fieldAndWidth == -1) {
            return
        }
        let field = fieldAndWidth / DateTimePatternGenerator_DisplayWidth.COUNT
        let width = DateTimePatternGenerator.CLDR_FIELD_WIDTH[Int64(fieldAndWidth % DateTimePatternGenerator_DisplayWidth.COUNT)]
        let detailsTable = value.getTable()
        if (detailsTable.findValue("dn", value)) {
            if (this_0.getFieldDisplayName(field, width).isNone()) {
                this_0.setFieldDisplayName(field, width, value.toString())
            }
        }
    }
}


class DateTimePatternGenerator_AvailableFormatsSink <: UResource_Sink {
    let this_0: DateTimePatternGenerator

    var returnInfo: DateTimePatternGenerator_PatternInfo

    public init(this_0: DateTimePatternGenerator, returnInfo: DateTimePatternGenerator_PatternInfo) {
        super()
        this.this_0 = this_0
        this.returnInfo = returnInfo
    }

    public override func put(key: UResource_Key, value: UResource_Value, isRoot: Bool): Unit {
        let formatKey: String = key.toString()
        if (!this_0.isAvailableFormatSet(formatKey)) {
            this_0.setAvailableFormat(formatKey)
            let formatValue: String = value.toString()
            this_0.addPatternWithSkeleton(formatValue, formatKey, true, returnInfo)
        }
    }
}


class DateTimePatternGenerator_DayPeriodAllowedHoursSink <: UResource_Sink {
    var tempMap: HashMap<String, Array<String>> = None

    init(tempMap: HashMap<String, Array<String>>) {
        super()
        this.tempMap = tempMap
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let timeData = value.getTable()
        var i = 0
        while (timeData.getKeyAndValue(i, key, value)) {
            let regionOrLocale: String = key.toString()
            let formatList = value.getTable()
            var allowed: Array<String>
            var preferred: String
            var j = 0
            while (formatList.getKeyAndValue(j, key, value)) {
                if (key.contentEquals("allowed")) {
                    allowed = value.getStringArrayOrStringAsArray()
                } else if (key.contentEquals("preferred")) {
                    preferred = value.getString()
                }
                j++
            }
            var list: Array<String>
            if (allowed.isSome() && Int32(allowed.size) > 0) {
                list = Array<String>(Int64(Int32(allowed.size) + 1))
                list[0] = if (preferred.isSome()) { preferred } else { allowed[0] }
                arraycopy(allowed, 0, list, 1, allowed.size)
            } else {
                list = Array<String>(2)
                list[0] = if (preferred.isSome()) { preferred } else { DateTimePatternGenerator.LAST_RESORT_ALLOWED_HOUR_FORMAT[0] }
                list[1] = list[0]
            }
            tempMap.put(regionOrLocale, list)
            i++
        }
    }
}


public class DateTimePatternGenerator_PatternInfo {
    public static let OK = 0

    public static let BASE_CONFLICT = 1

    public static let CONFLICT = 2

    public var status: Int32 = 0

    public var conflictingPattern: String

}


public class DateTimePatternGenerator_DisplayWidth <: Enum<DateTimePatternGenerator_DisplayWidth> {
    public static let WIDE = DateTimePatternGenerator_DisplayWidth("WIDE", 0, "")

    public static let ABBREVIATED = DateTimePatternGenerator_DisplayWidth("ABBREVIATED", 1, "-short")

    public static let NARROW = DateTimePatternGenerator_DisplayWidth("NARROW", 2, "-narrow")

    private static func _values(): Array<DateTimePatternGenerator_DisplayWidth> {
        return [DateTimePatternGenerator_DisplayWidth.WIDE, DateTimePatternGenerator_DisplayWidth.ABBREVIATED, DateTimePatternGenerator_DisplayWidth.NARROW]
    }

    private static let _VALUES = DateTimePatternGenerator_DisplayWidth._values()

    public static func values(): Array<DateTimePatternGenerator_DisplayWidth> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DateTimePatternGenerator_DisplayWidth {
        return (TypeInfo.of<DateTimePatternGenerator_DisplayWidth>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DateTimePatternGenerator_DisplayWidth
    }

    
    static var COUNT = Int32(DateTimePatternGenerator_DisplayWidth.values().size)

    private let cldrKey: String

    init(_enum_name: String, _enum_ordinal: Int32, cldrKey: String) {
        super(_enum_name, _enum_ordinal)
        this.cldrKey = cldrKey
    }

    public func cldrKeyMethod(): String {
        return cldrKey
    }
}



public class DateTimePatternGenerator_VariableField {
    private let string: String

    private let canonicalIndex: Int32

    
    public init(string: String) {
        this(string, false)
    }

    
    public init(string: String, strict: Bool) {
        canonicalIndex = DateTimePatternGenerator.getCanonicalIndex(string, strict)
        if (canonicalIndex < 0) {
            throw IllegalArgumentException("Illegal datetime field:\t" + (string))
        }
        this.string = string
    }

    
    public func getType(): Int32 {
        return DateTimePatternGenerator.types[Int64(canonicalIndex)][1]
    }

    
    public static func getCanonicalCode(Type: Int32): String {
        try {
            return DateTimePatternGenerator.CANONICAL_ITEMS[Int64(Type)]
        } catch (e: Exception) {
            return Type.toString()
        }
    }

    
    public func isNumeric(): Bool {
        return DateTimePatternGenerator.types[Int64(canonicalIndex)][2] > 0
    }

    public func getCanonicalIndex(): Int32 {
        return canonicalIndex
    }

    
    public override func toString(): String {
        return string
    }
}



public class DateTimePatternGenerator_FormatParser {
    private static let SYNTAX_CHARS = UnicodeSet("[a-zA-Z]").freeze()

    private static let QUOTING_CHARS = UnicodeSet("[[[:script=Latn:][:script=Cyrl:]]&[[:L:][:M:]]]").freeze()

     private var tokenizer = PatternTokenizer().setSyntaxCharacters(SYNTAX_CHARS).setExtraQuotingCharacters(QUOTING_CHARS).setUsingQuote(true)

    var items: ArrayList<Object> = ArrayList<Object>()

    

    
    public func set(string: String): DateTimePatternGenerator_FormatParser {
        return set(string, false)
    }

    
    public func set(string: String, strict: Bool): DateTimePatternGenerator_FormatParser {
        items.clear()
        if (Int32(string.size) == 0) {
            return this
        }
        tokenizer.setPattern(string)
        let buffer = StringBuffer()
        let variable = StringBuffer()
        while (true) {
            buffer.setLength(0)
            let status = tokenizer.next(buffer)
            if (status == PatternTokenizer.DONE) {
                break
            }
            if (status == PatternTokenizer.SYNTAX) {
                if (Int32(variable.size) != 0 && buffer.get(0) != variable.get(0)) {
                    addVariable(variable, false)
                }
                variable.append(buffer)
            } else {
                addVariable(variable, false)
                items.append(toString(buffer))
            }
        }
        addVariable(variable, false)
        return this
    }

    private func addVariable(variable: StringBuffer, strict: Bool): Unit {
        if (Int32(variable.size) != 0) {
            items.append(DateTimePatternGenerator_VariableField(toString(variable), strict))
            variable.setLength(0)
        }
    }

    
    public func getItems(): ArrayList<Object> {
        return items
    }

    
    public override func toString(): String {
        return toString(0, Int32(items.size))
    }

    
    public func toString(start: Int32, limit: Int32): String {
        let result = StringBuilder()
        var i = start
        while (i < limit) {
            let item = items[Int64(i)]
            if (item) {
                let itemString = item
                result.append(tokenizer.quoteLiteral(itemString))
            } else {
                result.append(toString(items[Int64(i)]))
            }
            i++
        }
        return result.toString()
    }

    
    public func hasDateAndTimeFields(): Bool {
        var foundMask = 0
        for (item in items) {
            if (checkOptionalIs<DateTimePatternGenerator_VariableField, Object>(item)) {
                let Type = item.getType()
                foundMask |= shl(1, Type)
            }
        }
        let isDate = (foundMask & DateTimePatternGenerator.DATE_MASK) != 0
        let isTime = (foundMask & DateTimePatternGenerator.TIME_MASK) != 0
        return isDate && isTime
    }

    
    public func quoteLiteral(string: String): Object {
        return tokenizer.quoteLiteral(string)
    }
}


class DateTimePatternGenerator_PatternWithMatcher {
    public var pattern: String

    public var matcherWithSkeleton: DateTimePatternGenerator_DateTimeMatcher

    public init(pat: String, matcher: DateTimePatternGenerator_DateTimeMatcher) {
        pattern = pat
        matcherWithSkeleton = matcher
    }
}


class DateTimePatternGenerator_PatternWithSkeletonFlag {
    public var pattern: String

    public var skeletonWasSpecified: Bool = false

    public init(pat: String, skelSpecified: Bool) {
        pattern = pat
        skeletonWasSpecified = skelSpecified
    }

    public override func toString(): String {
        return (pattern) + "," + skeletonWasSpecified.toString()
    }
}


class DateTimePatternGenerator_DTPGflags <: Enum<DateTimePatternGenerator_DTPGflags> {
    public static let FIX_FRACTIONAL_SECONDS = DateTimePatternGenerator_DTPGflags("FIX_FRACTIONAL_SECONDS", 0)

    public static let SKELETON_USES_CAP_J = DateTimePatternGenerator_DTPGflags("SKELETON_USES_CAP_J", 1)

    private static func _values(): Array<DateTimePatternGenerator_DTPGflags> {
        return [DateTimePatternGenerator_DTPGflags.FIX_FRACTIONAL_SECONDS, DateTimePatternGenerator_DTPGflags.SKELETON_USES_CAP_J]
    }

    private static let _VALUES = DateTimePatternGenerator_DTPGflags._values()

    public static func values(): Array<DateTimePatternGenerator_DTPGflags> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): DateTimePatternGenerator_DTPGflags {
        return (TypeInfo.of<DateTimePatternGenerator_DTPGflags>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as DateTimePatternGenerator_DTPGflags
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class DateTimePatternGenerator_SkeletonFields {

    private var chars: Array<UInt8> = Array<UInt8>(Int64(DateTimePatternGenerator.TYPE_LIMIT)) { _ => 0 }

    private var lengths: Array<UInt8> = Array<UInt8>(Int64(DateTimePatternGenerator.TYPE_LIMIT)) { _ => 0 }

    private static let DEFAULT_CHAR = UInt8(UInt32('\u{0000}'))

    private static let DEFAULT_LENGTH = 0u8

    public func clear(): Unit {
        Arrays.fill(chars, DEFAULT_CHAR)
        Arrays.fill(lengths, DEFAULT_LENGTH)
    }

    public func copyFieldFrom(other: DateTimePatternGenerator_SkeletonFields, field: Int32): Unit {
        chars[Int64(field)] = other.chars[Int64(field)]
        lengths[Int64(field)] = other.lengths[Int64(field)]
    }

    public func clearField(field: Int32): Unit {
        chars[Int64(field)] = DEFAULT_CHAR
        lengths[Int64(field)] = DEFAULT_LENGTH
    }

    public func getFieldChar(field: Int32): Char {
        return Char(chars[Int64(field)])
    }

    public func getFieldLength(field: Int32): Int32 {
        return Int32(lengths[Int64(field)])
    }

    public func populate(field: Int32, value: String): Unit {
        for (ch in value.toRuneArray()) {
            if (!(ch == Char(value[0]))) {
                throw AssertionError()
            }
        }
        populate(field, Char(value[0]), Int32(value.size))
    }

    public func populate(field: Int32, ch: Char, length: Int32): Unit {
        if (!(Int32(UInt32(ch)) <= Int32(Int8.Max))) {
            throw AssertionError()
        }
        if (!(length <= Int32(Int8.Max))) {
            throw AssertionError()
        }
        chars[Int64(field)] = UInt8(UInt32(ch))
        lengths[Int64(field)] = UInt8(length)
    }

    public func isFieldEmpty(field: Int32): Bool {
        return lengths[Int64(field)] == DEFAULT_LENGTH
    }

    public override func toString(): String {
        return appendTo(StringBuilder(), false, false).toString()
    }

    public func toCanonicalString(): String {
        return appendTo(StringBuilder(), true, false).toString()
    }

    public func toCanonicalString(skipDayPeriod: Bool): String {
        return appendTo(StringBuilder(), true, skipDayPeriod).toString()
    }

    public func appendTo(sb: StringBuilder): StringBuilder {
        return appendTo(sb, false, false)
    }

    private func appendTo(sb: StringBuilder, canonical: Bool, skipDayPeriod: Bool): StringBuilder {
        var i = 0
        while (i < DateTimePatternGenerator.TYPE_LIMIT) {
            if (skipDayPeriod && i == DateTimePatternGenerator.DAYPERIOD) {
                continue
            }
            appendFieldTo(i, sb, canonical)
            i++
        }
        return sb
    }

    public func appendFieldTo(field: Int32, sb: StringBuilder): StringBuilder {
        return appendFieldTo(field, sb, false)
    }

    private func appendFieldTo(field: Int32, sb: StringBuilder, canonical: Bool): StringBuilder {
        var ch = Char(chars[Int64(field)])
        let length = Int32(lengths[Int64(field)])
        if (canonical) {
            ch = DateTimePatternGenerator.getCanonicalChar(field, ch)
        }
        var i = 0
        while (i < length) {
            sb.append(ch)
            i++
        }
        return sb
    }

    public func compareTo(other: DateTimePatternGenerator_SkeletonFields): Int32 {
        var i = 0
        while (i < DateTimePatternGenerator.TYPE_LIMIT) {
            let charDiff = chars[Int64(i)] - other.chars[Int64(i)]
            if (charDiff != 0) {
                return charDiff
            }
            let lengthDiff = lengths[Int64(i)] - other.lengths[Int64(i)]
            if (lengthDiff != 0) {
                return lengthDiff
            }
            i++
        }
        return 0
    }

    public override func equals(other: Object): Bool {
        return refEq(this, other) || (other.isSome() && checkOptionalIs<DateTimePatternGenerator_SkeletonFields, Object>(other) && compareTo(other) == 0)
    }

    public override func hashCode(): Int64 {
        return Int64(Arrays.hashCode(chars) ^ Arrays.hashCode(lengths))
    }
}


class DateTimePatternGenerator_DateTimeMatcher <: Comparable<DateTimePatternGenerator_DateTimeMatcher> {

    var Type: Array<Int32> = Array<Int32>(Int64(DateTimePatternGenerator.TYPE_LIMIT)) { _ => 0 }

    var original: DateTimePatternGenerator_SkeletonFields = DateTimePatternGenerator_SkeletonFields()

    private var baseOriginal: DateTimePatternGenerator_SkeletonFields = DateTimePatternGenerator_SkeletonFields()

    private var addedDefaultDayPeriod = false

    public func fieldIsNumeric(field: Int32): Bool {
        return Type[Int64(field)] > 0
    }

    public override func toString(): String {
        return original.toString(addedDefaultDayPeriod)
    }

    public func toCanonicalString(): String {
        return original.toCanonicalString(addedDefaultDayPeriod)
    }

    public func getBasePattern(): String {
        return baseOriginal.toString(addedDefaultDayPeriod)
    }

    public func set(pattern: String, fp: DateTimePatternGenerator_FormatParser, allowDuplicateFields: Bool): DateTimePatternGenerator_DateTimeMatcher {
        Arrays.fill(Type, DateTimePatternGenerator.NONE)
        original.clear()
        baseOriginal.clear()
        addedDefaultDayPeriod = false
        fp.set(pattern)
        for (obj in fp.getItems()) {
            if (!(checkOptionalIs<DateTimePatternGenerator_VariableField, Object>(obj))) {
                continue
            }
            let item = obj
            let value: String = item.toString()
            let canonicalIndex = item.getCanonicalIndex()
            let row: Array<Int32> = DateTimePatternGenerator.types[Int64(canonicalIndex)]
            let field = row[1]
            if (!original.isFieldEmpty(field)) {
                let ch1 = original.getFieldChar(field)
                let ch2 = Char(value[0])
                if (allowDuplicateFields || (ch1 == 'r' && (ch2 == 'U' || ch2 == 'y')) || ((ch1 == 'U' || ch1 == 'y') && ch2 == 'r')) {
                    continue
                }
                throw IllegalArgumentException("Conflicting fields:\t" + ch1.toString() + ", " + (value) + "\t in " + (pattern))
            }
            original.populate(field, value)
            let repeatChar = Char(row[0])
            var repeatCount = row[3]
            if (indexOfWrap("GEzvQ".indexOf(UInt8(UInt32(repeatChar)))) >= 0) {
                repeatCount = 1
            }
            baseOriginal.populate(field, repeatChar, repeatCount)
            var subField = row[2]
            if (subField > 0) {
                subField += Int32(value.size)
            }
            Type[Int64(field)] = subField
        }
        if (!original.isFieldEmpty(DateTimePatternGenerator.MINUTE) && !original.isFieldEmpty(DateTimePatternGenerator.FRACTIONAL_SECOND) && original.isFieldEmpty(DateTimePatternGenerator.SECOND)) {
                    i++
                }
            } while (false)
        }
        if (!original.isFieldEmpty(DateTimePatternGenerator.HOUR)) {
            if (original.getFieldChar(DateTimePatternGenerator.HOUR) == 'h' || original.getFieldChar(DateTimePatternGenerator.HOUR) == 'K') {
                if (original.isFieldEmpty(DateTimePatternGenerator.DAYPERIOD)) {
                            i++
                        }
                    } while (false)
                }
            } else if (!original.isFieldEmpty(DateTimePatternGenerator.DAYPERIOD)) {
                original.clearField(DateTimePatternGenerator.DAYPERIOD)
                baseOriginal.clearField(DateTimePatternGenerator.DAYPERIOD)
                Type[Int64(DateTimePatternGenerator.DAYPERIOD)] = DateTimePatternGenerator.NONE
            }
        }
        return this
    }

    public func getFieldMask(): Int32 {
        var result = 0
        var i = 0
        while (i < Int32(Type.size)) {
            if (Type[Int64(i)] != 0) {
                result |= (shl(1, i))
            }
            i++
        }
        return result
    }

    public func extractFrom(source: DateTimePatternGenerator_DateTimeMatcher, fieldMask: Int32): Unit {
        var i = 0
        while (i < Int32(Type.size)) {
            if ((fieldMask & (shl(1, i))) != 0) {
                Type[Int64(i)] = source.Type[Int64(i)]
                original.copyFieldFrom(source.original, i)
            } else {
                Type[Int64(i)] = DateTimePatternGenerator.NONE
                original.clearField(i)
            }
            i++
        }
    }

    public func getDistance(other: DateTimePatternGenerator_DateTimeMatcher, includeMask: Int32, distanceInfo: DateTimePatternGenerator_DistanceInfo): Int32 {
        var result = 0
        distanceInfo.clear()
        var i = 0
        while (i < DateTimePatternGenerator.TYPE_LIMIT) {
            let myType = if ((includeMask & (shl(1, i))) == 0) { 0 } else { Type[Int64(i)] }
            let otherType = other.Type[Int64(i)]
            if (myType == otherType) {
                continue
            }
            if (myType == 0) {
                result += DateTimePatternGenerator.EXTRA_FIELD
                distanceInfo.addExtra(i)
            } else if (otherType == 0) {
                result += DateTimePatternGenerator.MISSING_FIELD
                distanceInfo.addMissing(i)
            } else {
                result += abs(myType - otherType)
            }
            i++
        }
        return result
    }

    public override func compareTo(that: DateTimePatternGenerator_DateTimeMatcher): Int32 {
        let result = original.compareTo(that.original)
        return if (result > 0) { -1 } else { if (result < 0) { 1 } else { 0 } }
    }

    public override func equals(other: Object): Bool {
        return refEq(this, other) || (other.isSome() && checkOptionalIs<DateTimePatternGenerator_DateTimeMatcher, Object>(other) && original.equals(other.original))
    }

    public override func hashCode(): Int64 {
        return original.hashCode()
    }
}


class DateTimePatternGenerator_DistanceInfo {

    var missingFieldMask: Int32 = 0

    var extraFieldMask: Int32 = 0

    public func clear(): Unit {
        missingFieldMask = match (0) { case _ => extraFieldMask = 0; extraFieldMask }
    }

    public func setTo(other: DateTimePatternGenerator_DistanceInfo): Unit {
        missingFieldMask = other.missingFieldMask
        extraFieldMask = other.extraFieldMask
    }

    public func addMissing(field: Int32): Unit {
        missingFieldMask |= (shl(1, field))
    }

    public func addExtra(field: Int32): Unit {
        extraFieldMask |= (shl(1, field))
    }

    public override func toString(): String {
        return "missingFieldMask: " + (DateTimePatternGenerator.showMask(missingFieldMask)) + ", extraFieldMask: " + (DateTimePatternGenerator.showMask(extraFieldMask))
    }
}
