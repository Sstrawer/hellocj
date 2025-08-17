package icu4cj.text


public class DateIntervalFormat <: UFormat & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private static let serialVersionUID = 1

    private static var LOCAL_PATTERN_CACHE: ICUCache<String, Map<String, DateIntervalInfo_PatternInfo>> = SimpleCache<String, Map<String, DateIntervalInfo_PatternInfo>>()

    private var fInfo: DateIntervalInfo

    private var fDateFormat: SimpleDateFormat

    private var fFromCalendar: Calendar

    private var fToCalendar: Calendar

    private var fSkeleton: String

    private var isDateIntervalInfoDefault: Bool = false

     private var fIntervalPatterns: Map<String, DateIntervalInfo_PatternInfo> = None

    private var fDatePattern: String

    private var fTimePattern: String

    private var fDateTimeFormat: String

    private var fCapitalizationSetting: DisplayContext = DisplayContext.CAPITALIZATION_NONE

    private init() {
        super()
    }

    
    public init(skeleton: String, dtItvInfo: DateIntervalInfo, simpleDateFormat: SimpleDateFormat) {
        super()
        fDateFormat = simpleDateFormat
        dtItvInfo.freeze()
        fSkeleton = skeleton
        fInfo = dtItvInfo
        isDateIntervalInfoDefault = false
        fFromCalendar = fDateFormat.getCalendar().clone()
        fToCalendar = fDateFormat.getCalendar().clone()
        initializePattern(None)
    }

    private init(skeleton: String, locale: ULocale, simpleDateFormat: SimpleDateFormat) {
        super()
        fDateFormat = simpleDateFormat
        fSkeleton = skeleton
        fInfo = DateIntervalInfo(locale).freeze()
        isDateIntervalInfoDefault = true
        fFromCalendar = fDateFormat.getCalendar().clone()
        fToCalendar = fDateFormat.getCalendar().clone()
        initializePattern(LOCAL_PATTERN_CACHE)
    }

    public static func getInstance(skeleton: String): DateIntervalFormat {
        return getInstance(skeleton, ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public static func getInstance(skeleton: String, locale: Locale): DateIntervalFormat {
        return getInstance(skeleton, ULocale.forLocale(locale))
    }

    public static func getInstance(skeleton: String, locale: ULocale): DateIntervalFormat {
        let generator = DateTimePatternGenerator.getInstance(locale)
        return DateIntervalFormat(skeleton, locale, SimpleDateFormat(generator.getBestPattern(skeleton), locale))
    }

    public static func getInstance(skeleton: String, dtitvinf: DateIntervalInfo): DateIntervalFormat {
        return getInstance(skeleton, ULocale.getDefault(ULocale_Category.FORMAT), dtitvinf)
    }

    public static func getInstance(skeleton: String, locale: Locale, dtitvinf: DateIntervalInfo): DateIntervalFormat {
        return getInstance(skeleton, ULocale.forLocale(locale), dtitvinf)
    }

    public static func getInstance(skeleton: String, locale: ULocale, dtitvinf: DateIntervalInfo): DateIntervalFormat {
        var tempdtitvinf = dtitvinf
        tempdtitvinf = tempdtitvinf.clone()
        let generator = DateTimePatternGenerator.getInstance(locale)
        return DateIntervalFormat(skeleton, tempdtitvinf, SimpleDateFormat(generator.getBestPattern(skeleton), locale))
    }

    public override func clone(): Object {
        synchronized (GeneratedLockObject) {
            let other = super.clone()
            other.fDateFormat = fDateFormat.clone()
            other.fInfo = fInfo.clone()
            other.fFromCalendar = fFromCalendar.clone()
            other.fToCalendar = fToCalendar.clone()
            other.fDatePattern = fDatePattern
            other.fTimePattern = fTimePattern
            other.fDateTimeFormat = fDateTimeFormat
            other.fCapitalizationSetting = fCapitalizationSetting
            return other
        }
    }

    public override func format(obj: Object, appendTo: StringBuffer, fieldPosition: FieldPosition): StringBuffer {
        if (checkOptionalIs<DateInterval, Object>(obj)) {
            return format(obj, appendTo, fieldPosition)
        } else {
            throw IllegalArgumentException("Cannot format given Object (" + TypeInfo.of(obj).name + ") as a DateInterval")
        }
    }

    public func format(dtInterval: DateInterval, appendTo: StringBuffer, fieldPosition: FieldPosition): StringBuffer {
        return formatIntervalImpl(dtInterval, appendTo, fieldPosition, None, None)
    }

    public func formatToValue(dtInterval: DateInterval): DateIntervalFormat_FormattedDateInterval {
        let sb = StringBuffer()
        let ignore = FieldPosition(0)
        let output = DateIntervalFormat_FormatOutput()
        let attributes = ArrayList<FieldPosition>()
        formatIntervalImpl(dtInterval, sb, ignore, output, attributes)
        if (output.firstIndex != -1) {
            FormattedValueFieldPositionIteratorImpl.addOverlapSpans(attributes, DateIntervalFormat_SpanField.DATE_INTERVAL_SPAN, output.firstIndex)
            FormattedValueFieldPositionIteratorImpl.sort(attributes)
        }
        return DateIntervalFormat_FormattedDateInterval(sb, attributes)
    }

    private func formatIntervalImpl(dtInterval: DateInterval, appendTo: StringBuffer, pos: FieldPosition, output: DateIntervalFormat_FormatOutput, attributes: ArrayList<FieldPosition>): StringBuffer {
        synchronized (GeneratedLockObject) {
            fFromCalendar.setTimeInMillis(dtInterval.getFromDate())
            fToCalendar.setTimeInMillis(dtInterval.getToDate())
            return formatImpl(fFromCalendar, fToCalendar, appendTo, pos, output, attributes)
        }
    }

    
    public func getPatterns(fromCalendar: Calendar, toCalendar: Calendar, part2: Output<String>): String {
        let field: Int32
        if (fromCalendar.get(Calendar.ERA) != toCalendar.get(Calendar.ERA)) {
            field = Calendar.ERA
        } else if (fromCalendar.get(Calendar.YEAR) != toCalendar.get(Calendar.YEAR)) {
            field = Calendar.YEAR
        } else if (fromCalendar.get(Calendar.MONTH) != toCalendar.get(Calendar.MONTH)) {
            field = Calendar.MONTH
        } else if (fromCalendar.get(Calendar.DATE) != toCalendar.get(Calendar.DATE)) {
            field = Calendar.DATE
        } else if (fromCalendar.get(Calendar.AM_PM) != toCalendar.get(Calendar.AM_PM)) {
            field = Calendar.AM_PM
        } else if (fromCalendar.get(Calendar.HOUR) != toCalendar.get(Calendar.HOUR)) {
            field = Calendar.HOUR
        } else if (fromCalendar.get(Calendar.MINUTE) != toCalendar.get(Calendar.MINUTE)) {
            field = Calendar.MINUTE
        } else if (fromCalendar.get(Calendar.SECOND) != toCalendar.get(Calendar.SECOND)) {
            field = Calendar.SECOND
        } else if (fromCalendar.get(Calendar.MILLISECOND) != toCalendar.get(Calendar.MILLISECOND)) {
            field = Calendar.MILLISECOND
        } else {
            return None
        }
        let intervalPattern = fIntervalPatterns.get(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(field)])
        part2.value = intervalPattern.getSecondPart()
        return intervalPattern.getFirstPart()
    }

    public func format(fromCalendar: Calendar, toCalendar: Calendar, appendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        return formatImpl(fromCalendar, toCalendar, appendTo, pos, None, None)
    }

    public func formatToValue(fromCalendar: Calendar, toCalendar: Calendar): DateIntervalFormat_FormattedDateInterval {
        let sb = StringBuffer()
        let ignore = FieldPosition(0)
        let output = DateIntervalFormat_FormatOutput()
        let attributes = ArrayList<FieldPosition>()
        formatImpl(fromCalendar, toCalendar, sb, ignore, output, attributes)
        if (output.firstIndex != -1) {
            FormattedValueFieldPositionIteratorImpl.addOverlapSpans(attributes, DateIntervalFormat_SpanField.DATE_INTERVAL_SPAN, output.firstIndex)
            FormattedValueFieldPositionIteratorImpl.sort(attributes)
        }
        return DateIntervalFormat_FormattedDateInterval(sb, attributes)
    }

    private func formatImpl(fromCalendar: Calendar, toCalendar: Calendar, appendTo: StringBuffer, pos: FieldPosition, output: DateIntervalFormat_FormatOutput, attributes: ArrayList<FieldPosition>): StringBuffer {
        synchronized (GeneratedLockObject) {
            var temppos = pos
            if (!fromCalendar.isEquivalentTo(toCalendar)) {
                throw IllegalArgumentException("can not format on two different calendars")
            }
            fDateFormat.setContext(fCapitalizationSetting)
            var field = -1
            if (fromCalendar.get(Calendar.ERA) != toCalendar.get(Calendar.ERA)) {
                field = Calendar.ERA
            } else if (fromCalendar.get(Calendar.YEAR) != toCalendar.get(Calendar.YEAR)) {
                field = Calendar.YEAR
            } else if (fromCalendar.get(Calendar.MONTH) != toCalendar.get(Calendar.MONTH)) {
                field = Calendar.MONTH
            } else if (fromCalendar.get(Calendar.DATE) != toCalendar.get(Calendar.DATE)) {
                field = Calendar.DATE
            } else if (fromCalendar.get(Calendar.AM_PM) != toCalendar.get(Calendar.AM_PM)) {
                field = Calendar.AM_PM
            } else if (fromCalendar.get(Calendar.HOUR) != toCalendar.get(Calendar.HOUR)) {
                field = Calendar.HOUR
            } else if (fromCalendar.get(Calendar.MINUTE) != toCalendar.get(Calendar.MINUTE)) {
                field = Calendar.MINUTE
            } else if (fromCalendar.get(Calendar.SECOND) != toCalendar.get(Calendar.SECOND)) {
                field = Calendar.SECOND
            } else if (fromCalendar.get(Calendar.MILLISECOND) != toCalendar.get(Calendar.MILLISECOND)) {
                field = Calendar.MILLISECOND
            } else {
                return fDateFormat.format(fromCalendar, appendTo, temppos, attributes)
            }
            let fromToOnSameDay = (field == Calendar.AM_PM || field == Calendar.HOUR || field == Calendar.MINUTE || field == Calendar.SECOND || field == Calendar.MILLISECOND)
            let intervalPattern = fIntervalPatterns.get(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(field)])
            if (intervalPattern.isNone()) {
                if (fDateFormat.isFieldUnitIgnored(field)) {
                    return fDateFormat.format(fromCalendar, appendTo, temppos, attributes)
                }
                return fallbackFormat(fromCalendar, toCalendar, fromToOnSameDay, appendTo, temppos, output, attributes)
            }
            if (intervalPattern.getFirstPart().isNone()) {
                return fallbackFormat(fromCalendar, toCalendar, fromToOnSameDay, appendTo, temppos, output, attributes, intervalPattern.getSecondPart())
            }
            let firstCal: Calendar
            let secondCal: Calendar
            if (intervalPattern.firstDateInPtnIsLaterDate()) {
                if (output.isSome()) {
                    output.register(1)
                }
                firstCal = toCalendar
                secondCal = fromCalendar
            } else {
                if (output.isSome()) {
                    output.register(0)
                }
                firstCal = fromCalendar
                secondCal = toCalendar
            }
            let originalPattern = fDateFormat.toPattern()
            fDateFormat.applyPattern(intervalPattern.getFirstPart())
            fDateFormat.format(firstCal, appendTo, temppos, attributes)
            if (temppos.getEndIndex() > 0) {
                temppos = FieldPosition(0)
            }
            if (intervalPattern.getSecondPart().isSome()) {
                fDateFormat.applyPattern(intervalPattern.getSecondPart())
                fDateFormat.setContext(DisplayContext.CAPITALIZATION_NONE)
                fDateFormat.format(secondCal, appendTo, temppos, attributes)
            }
            fDateFormat.applyPattern(originalPattern)
            return appendTo
        }
    }

    private func fallbackFormatRange(fromCalendar: Calendar, toCalendar: Calendar, appendTo: StringBuffer, patternSB: StringBuilder, pos: FieldPosition, output: DateIntervalFormat_FormatOutput, attributes: ArrayList<FieldPosition>): Unit {
        var temppos = pos
        let compiledPattern = SimpleFormatterImpl.compileToStringMinMaxArguments(fInfo.getFallbackIntervalPattern(), patternSB, 2, 2)
        var state = 0
        while (true) {
            state = SimpleFormatterImpl_IterInternal.step(state, compiledPattern, appendTo)
            if (state == SimpleFormatterImpl_IterInternal.DONE) {
                break
            }
            if (SimpleFormatterImpl_IterInternal.getArgIndex(state) == 0) {
                if (output.isSome()) {
                    output.register(0)
                }
                fDateFormat.format(fromCalendar, appendTo, temppos, attributes)
            } else {
                if (output.isSome()) {
                    output.register(1)
                }
                fDateFormat.format(toCalendar, appendTo, temppos, attributes)
            }
            if (temppos.getEndIndex() > 0) {
                temppos = FieldPosition(0)
            }
            fDateFormat.setContext(DisplayContext.CAPITALIZATION_NONE)
        }
    }

    private func fallbackFormat(fromCalendar: Calendar, toCalendar: Calendar, fromToOnSameDay: Bool, appendTo: StringBuffer, pos: FieldPosition, output: DateIntervalFormat_FormatOutput, attributes: ArrayList<FieldPosition>): StringBuffer {
        var temppos = pos
        let patternSB = StringBuilder()
        let formatDatePlusTimeRange = (fromToOnSameDay && fDatePattern.isSome() && fTimePattern.isSome())
        if (formatDatePlusTimeRange) {
            let compiledPattern = SimpleFormatterImpl.compileToStringMinMaxArguments(fDateTimeFormat, patternSB, 2, 2)
            let fullPattern: String
            fullPattern = fDateFormat.toPattern()
            var state = 0
            while (true) {
                state = SimpleFormatterImpl_IterInternal.step(state, compiledPattern, appendTo)
                if (state == SimpleFormatterImpl_IterInternal.DONE) {
                    break
                }
                if (SimpleFormatterImpl_IterInternal.getArgIndex(state) == 0) {
                    fDateFormat.applyPattern(fTimePattern)
                    fallbackFormatRange(fromCalendar, toCalendar, appendTo, patternSB, temppos, output, attributes)
                } else {
                    fDateFormat.applyPattern(fDatePattern)
                    fDateFormat.format(fromCalendar, appendTo, temppos, attributes)
                }
                if (temppos.getEndIndex() > 0) {
                    temppos = FieldPosition(0)
                }
                fDateFormat.setContext(DisplayContext.CAPITALIZATION_NONE)
            }
            fDateFormat.applyPattern(fullPattern)
        } else {
            fallbackFormatRange(fromCalendar, toCalendar, appendTo, patternSB, temppos, output, attributes)
        }
        return appendTo
    }

    private func fallbackFormat(fromCalendar: Calendar, toCalendar: Calendar, fromToOnSameDay: Bool, appendTo: StringBuffer, pos: FieldPosition, output: DateIntervalFormat_FormatOutput, attributes: ArrayList<FieldPosition>, fullPattern: String): StringBuffer {
        let originalPattern = fDateFormat.toPattern()
        fDateFormat.applyPattern(fullPattern)
        fallbackFormat(fromCalendar, toCalendar, fromToOnSameDay, appendTo, pos, output, attributes)
        fDateFormat.applyPattern(originalPattern)
        return appendTo
    }

    
    public override func parseObject(source: String, parse_pos: ParsePosition): Object {
        throw UnsupportedOperationException("parsing is not supported")
    }

    public func getDateIntervalInfo(): DateIntervalInfo {
        return fInfo.clone()
    }

    public func setDateIntervalInfo(newItvPattern: DateIntervalInfo): Unit {
        fInfo = newItvPattern.clone()
        this.isDateIntervalInfoDefault = false
        fInfo.freeze()
        if (fDateFormat.isSome()) {
            initializePattern(None)
        }
    }

    public func getTimeZone(): TimeZone {
        if (fDateFormat.isSome()) {
            return fDateFormat.getTimeZone().clone()
        }
        return TimeZone.getDefault()
    }

    public func setTimeZone(zone: TimeZone): Unit {
        let zoneToSet = zone.clone()
        if (fDateFormat.isSome()) {
            fDateFormat.setTimeZone(zoneToSet)
        }
        if (fFromCalendar.isSome()) {
            fFromCalendar.setTimeZone(zoneToSet)
        }
        if (fToCalendar.isSome()) {
            fToCalendar.setTimeZone(zoneToSet)
        }
    }

    public func setContext(context: DisplayContext): Unit {
        if (refEq(context.typeMethod(), DisplayContext_Type.CAPITALIZATION)) {
            fCapitalizationSetting = context
        }
    }

    public func getContext(Type: DisplayContext_Type): DisplayContext {
        return if (refEq(Type, DisplayContext_Type.CAPITALIZATION) && fCapitalizationSetting.isSome()) { fCapitalizationSetting } else { DisplayContext.CAPITALIZATION_NONE }
    }

    public func getDateFormat(): DateFormat {
        synchronized (GeneratedLockObject) {
            return fDateFormat.clone()
        }
    }

    private func initializePattern(cache: ICUCache<String, Map<String, DateIntervalInfo_PatternInfo>>): Unit {
        let fullPattern = fDateFormat.toPattern()
        let locale = fDateFormat.getLocale()
        var key: String
        var patterns: Map<String, DateIntervalInfo_PatternInfo> = None
        if (cache.isSome()) {
            if (fSkeleton.isSome()) {
                key = locale.toString() + "+" + (fullPattern) + "+" + (fSkeleton)
            } else {
                key = locale.toString() + "+" + (fullPattern)
            }
            patterns = cache.get(key)
        }
        if (patterns.isNone()) {
            let intervalPatterns = initializeIntervalPattern(fullPattern, locale)
            patterns = Collections.unmodifiableMap(intervalPatterns)
            if (cache.isSome()) {
                cache.put(key, patterns)
            }
        }
        fIntervalPatterns = patterns
    }

    private func initializeIntervalPattern(fullPattern: String, locale: ULocale): Map<String, DateIntervalInfo_PatternInfo> {
        let dtpng = DateTimePatternGenerator.getInstance(locale)
        if (fSkeleton.isNone()) {
            fSkeleton = dtpng.getSkeleton(fullPattern)
        }
        var skeleton = normalizeHourMetacharacters(fSkeleton, locale)
        let intervalPatterns = HashMap<String, DateIntervalInfo_PatternInfo>()
        let date = StringBuilder()
        let normalizedDate = StringBuilder()
        let time = StringBuilder()
        let normalizedTime = StringBuilder()
        getDateTimeSkeleton(skeleton, date, normalizedDate, time, normalizedTime)
        let dateSkeleton: String = date.toString()
        var timeSkeleton: String = time.toString()
        let normalizedDateSkeleton: String = normalizedDate.toString()
        let normalizedTimeSkeleton: String = normalizedTime.toString()
        if (Int32(time.size) != 0 && Int32(date.size) != 0) {
            fDateTimeFormat = getConcatenationPattern(locale)
        }
        let found = genSeparateDateTimePtn(normalizedDateSkeleton, normalizedTimeSkeleton, intervalPatterns, dtpng)
        if (found == false) {
            if (Int32(time.size) != 0) {
                if (Int32(date.size) == 0) {
                    timeSkeleton = DateFormat.YEAR_NUM_MONTH_DAY + (timeSkeleton)
                    var pattern = dtpng.getBestPattern(timeSkeleton)
                    var ptn: DateIntervalInfo_PatternInfo = DateIntervalInfo_PatternInfo(None, pattern, fInfo.getDefaultOrder())
                    intervalPatterns.put(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.DATE)], ptn)
                    intervalPatterns.put(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.MONTH)], ptn)
                    intervalPatterns.put(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.YEAR)], ptn)
                    pattern = dtpng.getBestPattern((timeSkeleton) + "G")
                    ptn = DateIntervalInfo_PatternInfo(None, pattern, fInfo.getDefaultOrder())
                    intervalPatterns.put(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.ERA)], ptn)
                } else { }
            } else { }
            return intervalPatterns
        }
        if (Int32(time.size) == 0) { } else if (Int32(date.size) == 0) {
            timeSkeleton = DateFormat.YEAR_NUM_MONTH_DAY + (timeSkeleton)
            var pattern = dtpng.getBestPattern(timeSkeleton)
            var ptn: DateIntervalInfo_PatternInfo = DateIntervalInfo_PatternInfo(None, pattern, fInfo.getDefaultOrder())
            intervalPatterns.put(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.DATE)], ptn)
            intervalPatterns.put(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.MONTH)], ptn)
            intervalPatterns.put(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.YEAR)], ptn)
            pattern = dtpng.getBestPattern((timeSkeleton) + "G")
            ptn = DateIntervalInfo_PatternInfo(None, pattern, fInfo.getDefaultOrder())
            intervalPatterns.put(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.ERA)], ptn)
        } else {
            if (!fieldExistsInSkeleton(Calendar.DATE, dateSkeleton)) {
                skeleton = (DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.DATE)]) + (skeleton)
                genFallbackPattern(Calendar.DATE, skeleton, intervalPatterns, dtpng)
            }
            if (!fieldExistsInSkeleton(Calendar.MONTH, dateSkeleton)) {
                skeleton = (DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.MONTH)]) + (skeleton)
                genFallbackPattern(Calendar.MONTH, skeleton, intervalPatterns, dtpng)
            }
            if (!fieldExistsInSkeleton(Calendar.YEAR, dateSkeleton)) {
                skeleton = (DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.YEAR)]) + (skeleton)
                genFallbackPattern(Calendar.YEAR, skeleton, intervalPatterns, dtpng)
            }
            if (!fieldExistsInSkeleton(Calendar.ERA, dateSkeleton)) {
                skeleton = (DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(Calendar.ERA)]) + (skeleton)
                genFallbackPattern(Calendar.ERA, skeleton, intervalPatterns, dtpng)
            }
            if (fDateTimeFormat.isNone()) {
                fDateTimeFormat = "{1} {0}"
            }
            let datePattern = dtpng.getBestPattern(dateSkeleton)
            concatSingleDate2TimeInterval(fDateTimeFormat, datePattern, Calendar.AM_PM, intervalPatterns)
            concatSingleDate2TimeInterval(fDateTimeFormat, datePattern, Calendar.HOUR, intervalPatterns)
            concatSingleDate2TimeInterval(fDateTimeFormat, datePattern, Calendar.MINUTE, intervalPatterns)
        }
        return intervalPatterns
    }

    private func getConcatenationPattern(locale: ULocale): String {
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, locale)
        let dtPatternsRb = rb.getWithFallback("calendar/gregorian/DateTimePatterns")
        let concatenationPatternRb = dtPatternsRb.get(8)
        if (concatenationPatternRb.getType() == UResourceBundle.STRING) {
            return concatenationPatternRb.getString()
        } else {
            return concatenationPatternRb.getString(0)
        }
    }

    private func genFallbackPattern(field: Int32, skeleton: String, intervalPatterns: Map<String, DateIntervalInfo_PatternInfo>, dtpng: DateTimePatternGenerator): Unit {
        let pattern = dtpng.getBestPattern(skeleton)
        let ptn = DateIntervalInfo_PatternInfo(None, pattern, fInfo.getDefaultOrder())
        intervalPatterns.put(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(field)], ptn)
    }

    private func normalizeHourMetacharacters(skeleton: String, locale: ULocale): String {
        let result = StringBuilder(skeleton)
        var hourMetachar = '\u{0000}'
        var dayPeriodChar = '\u{0000}'
        var hourFieldStart = 0
        var hourFieldLength = 0
        var dayPeriodStart = 0
        var dayPeriodLength = 0
                    hourFieldLength++
                } else if (c == 'a' || c == 'b' || c == 'B') {
                    if (dayPeriodChar == '\u{0000}') {
                        dayPeriodChar = c
                        dayPeriodStart = i
                    }
                    dayPeriodLength++
                } else {
                    if (hourMetachar != '\u{0000}' && dayPeriodChar != '\u{0000}') {
                        break
                    }
                }
                i++
            }
        } while (false)
        if (hourMetachar != '\u{0000}') {
            var hourChar = 'H'
            let dtptng = DateTimePatternGenerator.getInstance(locale)
            var convertedPattern = dtptng.getBestPattern(hourMetachar.toString())
            var firstQuotePos: Int32 = 0
            while ((match (0) { case _ => firstQuotePos = indexOfWrap(convertedPattern.indexOf(UInt8(UInt32(''')))); firstQuotePos }) != -1) {
                var secondQuotePos = indexOfWrap(convertedPattern.indexOf(UInt8(UInt32(''')), Int64(firstQuotePos + 1)))
                if (secondQuotePos == -1) {
                    secondQuotePos = firstQuotePos
                }
                convertedPattern = convertedPattern[0..Int64(firstQuotePos)] + convertedPattern[Int64(secondQuotePos + 1)..]
            }
            if (indexOfWrap(convertedPattern.indexOf(UInt8(UInt32('h')))) != -1) {
                hourChar = 'h'
            } else if (indexOfWrap(convertedPattern.indexOf(UInt8(UInt32('K')))) != -1) {
                hourChar = 'K'
            } else if (indexOfWrap(convertedPattern.indexOf(UInt8(UInt32('k')))) != -1) {
                hourChar = 'k'
            }
            if (indexOfWrap(convertedPattern.indexOf(UInt8(UInt32('b')))) != -1) {
                dayPeriodChar = 'b'
            } else if (indexOfWrap(convertedPattern.indexOf(UInt8(UInt32('B')))) != -1) {
                dayPeriodChar = 'B'
            } else if (dayPeriodChar == '\u{0000}') {
                dayPeriodChar = 'a'
            }
            let hourAndDayPeriod = StringBuilder()
            hourAndDayPeriod.append(hourChar)
            if (hourChar != 'H' && hourChar != 'k') {
                var newDayPeriodLength = 0
                if (dayPeriodLength >= 5 || hourFieldLength >= 5) {
                    newDayPeriodLength = 5
                } else if (dayPeriodLength >= 3 || hourFieldLength >= 3) {
                    newDayPeriodLength = 3
                } else {
                    newDayPeriodLength = 1
                }
                } while (false)
            }
            result.replace(Int64(hourFieldStart), Int64(hourFieldStart + hourFieldLength), hourAndDayPeriod.toString())
            if (dayPeriodStart > hourFieldStart) {
                dayPeriodStart += Int32(hourAndDayPeriod.size) - hourFieldLength
            }
            result.delete(dayPeriodStart, dayPeriodStart + dayPeriodLength)
        }
        return result.toString()
    }

    private static func getDateTimeSkeleton(skeleton: String, dateSkeleton: StringBuilder, normalizedDateSkeleton: StringBuilder, timeSkeleton: StringBuilder, normalizedTimeSkeleton: StringBuilder): Unit {
        var i: Int32 = 0
        var ECount = 0
        var dCount = 0
        var MCount = 0
        var yCount = 0
        var mCount = 0
        var vCount = 0
        var zCount = 0
        var hourChar = '\u{0000}'
        i = 0
        while (i < Int32(skeleton.size)) {
            let ch = Char(skeleton[Int64(i)])
            match (ch) {
                case 'E' =>
                    dateSkeleton.append(ch)
                    ECount++
                case 'd' =>
                    dateSkeleton.append(ch)
                    dCount++
                case 'M' =>
                    dateSkeleton.append(ch)
                    MCount++
                case 'y' =>
                    dateSkeleton.append(ch)
                    yCount++
                case 'G' | 'Y' | 'u' | 'Q' | 'q' | 'L' | 'l' | 'W' | 'w' | 'D' | 'F' | 'g' | 'e' | 'c' | 'U' | 'r' =>
                    normalizedDateSkeleton.append(ch)
                    dateSkeleton.append(ch)
                case 'h' | 'H' | 'k' | 'K' =>
                    timeSkeleton.append(ch)
                    if (hourChar == '\u{0000}') {
                        hourChar = ch
                    }
                case 'm' =>
                    timeSkeleton.append(ch)
                    mCount++
                case 'z' =>
                    zCount++
                    timeSkeleton.append(ch)
                case 'v' =>
                    vCount++
                    timeSkeleton.append(ch)
                case 'a' | 'V' | 'Z' | 'j' | 's' | 'S' | 'A' | 'b' | 'B' =>
                    timeSkeleton.append(ch)
                    normalizedTimeSkeleton.append(ch)
                case _ => ()
            }
            i++
        }
        if (yCount != 0) {
            i = 0
            while (i < yCount) {
                normalizedDateSkeleton.append('y')
                i++
            }
        }
        if (MCount != 0) {
            if (MCount < 3) {
                normalizedDateSkeleton.append('M')
            } else {
                i = 0
                while (i < MCount && i < 5) {
                    normalizedDateSkeleton.append('M')
                    i++
                }
            }
        }
        if (ECount != 0) {
            if (ECount <= 3) {
                normalizedDateSkeleton.append('E')
            } else {
                i = 0
                while (i < ECount && i < 5) {
                    normalizedDateSkeleton.append('E')
                    i++
                }
            }
        }
        if (dCount != 0) {
            normalizedDateSkeleton.append('d')
        }
        if (hourChar != '\u{0000}') {
            normalizedTimeSkeleton.append(hourChar)
        }
        if (mCount != 0) {
            normalizedTimeSkeleton.append('m')
        }
        if (zCount != 0) {
            normalizedTimeSkeleton.append('z')
        }
        if (vCount != 0) {
            normalizedTimeSkeleton.append('v')
        }
    }

    private func genSeparateDateTimePtn(dateSkeleton: String, timeSkeleton: String, intervalPatterns: Map<String, DateIntervalInfo_PatternInfo>, dtpng: DateTimePatternGenerator): Bool {
        var skeleton: String
        if (Int32(timeSkeleton.size) != 0) {
            skeleton = timeSkeleton
        } else {
            skeleton = dateSkeleton
        }
        let retValue = fInfo.getBestSkeleton(skeleton)
        var bestSkeleton = retValue.bestMatchSkeleton
        let differenceInfo = retValue.bestMatchDistanceInfo
        if (Int32(dateSkeleton.size) != 0) {
            fDatePattern = dtpng.getBestPattern(dateSkeleton)
        }
        if (Int32(timeSkeleton.size) != 0) {
            fTimePattern = dtpng.getBestPattern(timeSkeleton)
        }
        if (differenceInfo == -1) {
            return false
        }
        if (Int32(timeSkeleton.size) == 0) {
            genIntervalPattern(Calendar.DATE, skeleton, bestSkeleton, differenceInfo, intervalPatterns)
            let skeletons = genIntervalPattern(Calendar.MONTH, skeleton, bestSkeleton, differenceInfo, intervalPatterns)
            if (skeletons.isSome()) {
                bestSkeleton = skeletons.skeleton
                skeleton = skeletons.bestMatchSkeleton
            }
            genIntervalPattern(Calendar.YEAR, skeleton, bestSkeleton, differenceInfo, intervalPatterns)
            genIntervalPattern(Calendar.ERA, skeleton, bestSkeleton, differenceInfo, intervalPatterns)
        } else {
            genIntervalPattern(Calendar.MINUTE, skeleton, bestSkeleton, differenceInfo, intervalPatterns)
            genIntervalPattern(Calendar.HOUR, skeleton, bestSkeleton, differenceInfo, intervalPatterns)
            genIntervalPattern(Calendar.AM_PM, skeleton, bestSkeleton, differenceInfo, intervalPatterns)
        }
        return true
    }

    private func genIntervalPattern(field: Int32, skeleton: String, bestSkeleton: String, differenceInfo: Int32, intervalPatterns: Map<String, DateIntervalInfo_PatternInfo>): DateIntervalFormat_SkeletonAndItsBestMatch {
        var tempbestSkeleton = bestSkeleton
        var tempskeleton = skeleton
        var tempdifferenceInfo = differenceInfo
        var retValue: DateIntervalFormat_SkeletonAndItsBestMatch
        var pattern = fInfo.getIntervalPattern(tempbestSkeleton, field)
        if (pattern.isNone()) {
            if (SimpleDateFormat.isFieldUnitIgnoredStatic(tempbestSkeleton, field)) {
                let ptnInfo = DateIntervalInfo_PatternInfo(fDateFormat.toPattern(), None, fInfo.getDefaultOrder())
                intervalPatterns.put(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(field)], ptnInfo)
                return None
            }
            if (field == Calendar.AM_PM) {
                pattern = fInfo.getIntervalPattern(tempbestSkeleton, Calendar.HOUR)
                if (pattern.isSome()) {
                    let suppressDayPeriodField = indexOfWrap(fSkeleton.indexOf(UInt8(UInt32('J')))) != -1
                    let part1 = adjustFieldWidth(tempskeleton, tempbestSkeleton, pattern.getFirstPart(), tempdifferenceInfo, suppressDayPeriodField)
                    let part2 = adjustFieldWidth(tempskeleton, tempbestSkeleton, pattern.getSecondPart(), tempdifferenceInfo, suppressDayPeriodField)
                    pattern = DateIntervalInfo_PatternInfo(part1, part2, pattern.firstDateInPtnIsLaterDate())
                    intervalPatterns.put(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(field)], pattern)
                }
                return None
            }
            let fieldLetter = DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(field)]
            tempbestSkeleton = (fieldLetter) + (tempbestSkeleton)
            tempskeleton = (fieldLetter) + (tempskeleton)
            pattern = fInfo.getIntervalPattern(tempbestSkeleton, field)
            if (pattern.isNone() && tempdifferenceInfo == 0) {
                let tmpRetValue = fInfo.getBestSkeleton(tempskeleton)
                let tmpBestSkeleton = tmpRetValue.bestMatchSkeleton
                tempdifferenceInfo = tmpRetValue.bestMatchDistanceInfo
                if (Int32(tmpBestSkeleton.size) != 0 && tempdifferenceInfo != -1) {
                    pattern = fInfo.getIntervalPattern(tmpBestSkeleton, field)
                    tempbestSkeleton = tmpBestSkeleton
                }
            }
            if (pattern.isSome()) {
                retValue = DateIntervalFormat_SkeletonAndItsBestMatch(tempskeleton, tempbestSkeleton)
            }
        }
        if (pattern.isSome()) {
            if (tempdifferenceInfo != 0) {
                let suppressDayPeriodField = indexOfWrap(fSkeleton.indexOf(UInt8(UInt32('J')))) != -1
                let part1 = adjustFieldWidth(tempskeleton, tempbestSkeleton, pattern.getFirstPart(), tempdifferenceInfo, suppressDayPeriodField)
                let part2 = adjustFieldWidth(tempskeleton, tempbestSkeleton, pattern.getSecondPart(), tempdifferenceInfo, suppressDayPeriodField)
                pattern = DateIntervalInfo_PatternInfo(part1, part2, pattern.firstDateInPtnIsLaterDate())
            } else { }
            intervalPatterns.put(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(field)], pattern)
        }
        return retValue
    }

    private static func adjustFieldWidth(inputSkeleton: String, bestMatchSkeleton: String, bestMatchIntervalPattern: String, differenceInfo: Int32, suppressDayPeriodField: Bool): String {
        var tempbestMatchIntervalPattern = bestMatchIntervalPattern
        if (tempbestMatchIntervalPattern.isNone()) {
            return None
        }
        let inputSkeletonFieldWidth = Array<Int32>(58) { _ => 0 }
        let bestMatchSkeletonFieldWidth = Array<Int32>(58) { _ => 0 }
        let PATTERN_CHAR_BASE = 65
        DateIntervalInfo.parseSkeleton(inputSkeleton, inputSkeletonFieldWidth)
        DateIntervalInfo.parseSkeleton(bestMatchSkeleton, bestMatchSkeletonFieldWidth)
        if (suppressDayPeriodField) {
            if (indexOfWrap(tempbestMatchIntervalPattern.indexOf(" a")) != -1) {
                tempbestMatchIntervalPattern = findReplaceInPattern(tempbestMatchIntervalPattern, " a", "")
            } else if (indexOfWrap(tempbestMatchIntervalPattern.indexOf("\u{00a0}a")) != -1) {
                tempbestMatchIntervalPattern = findReplaceInPattern(tempbestMatchIntervalPattern, "\u{00a0}a", "")
            } else if (indexOfWrap(tempbestMatchIntervalPattern.indexOf("\u{202f}a")) != -1) {
                tempbestMatchIntervalPattern = findReplaceInPattern(tempbestMatchIntervalPattern, "\u{202f}a", "")
            } else if (indexOfWrap(tempbestMatchIntervalPattern.indexOf("a ")) != -1) {
                tempbestMatchIntervalPattern = findReplaceInPattern(tempbestMatchIntervalPattern, "a ", "")
            } else if (indexOfWrap(tempbestMatchIntervalPattern.indexOf("a\u{00a0}")) != -1) {
                tempbestMatchIntervalPattern = findReplaceInPattern(tempbestMatchIntervalPattern, "a\u{00a0}", "")
            } else if (indexOfWrap(tempbestMatchIntervalPattern.indexOf("a\u{202f}")) != -1) {
                tempbestMatchIntervalPattern = findReplaceInPattern(tempbestMatchIntervalPattern, "a\u{202f}", "")
            }
            tempbestMatchIntervalPattern = findReplaceInPattern(tempbestMatchIntervalPattern, "a", "")
        }
        if (differenceInfo == 2) {
            if (indexOfWrap(inputSkeleton.indexOf(UInt8(UInt32('z')))) != -1) {
                tempbestMatchIntervalPattern = findReplaceInPattern(tempbestMatchIntervalPattern, "v", "z")
            }
            if (indexOfWrap(inputSkeleton.indexOf(UInt8(UInt32('K')))) != -1) {
                tempbestMatchIntervalPattern = findReplaceInPattern(tempbestMatchIntervalPattern, "h", "K")
            }
            if (indexOfWrap(inputSkeleton.indexOf(UInt8(UInt32('k')))) != -1) {
                tempbestMatchIntervalPattern = findReplaceInPattern(tempbestMatchIntervalPattern, "H", "k")
            }
            if (indexOfWrap(inputSkeleton.indexOf(UInt8(UInt32('b')))) != -1) {
                tempbestMatchIntervalPattern = findReplaceInPattern(tempbestMatchIntervalPattern, "a", "b")
            }
        }
        if (indexOfWrap(tempbestMatchIntervalPattern.indexOf(UInt8(UInt32('a')))) != -1 && bestMatchSkeletonFieldWidth[Int64(Int32(UInt32('a')) - PATTERN_CHAR_BASE)] == 0) {
            bestMatchSkeletonFieldWidth[Int64(Int32(UInt32('a')) - PATTERN_CHAR_BASE)] = 1
        }
        if (indexOfWrap(tempbestMatchIntervalPattern.indexOf(UInt8(UInt32('b')))) != -1 && bestMatchSkeletonFieldWidth[Int64(Int32(UInt32('b')) - PATTERN_CHAR_BASE)] == 0) {
            bestMatchSkeletonFieldWidth[Int64(Int32(UInt32('b')) - PATTERN_CHAR_BASE)] = 1
        }
        let adjustedPtn = StringBuilder(tempbestMatchIntervalPattern)
        var inQuote = false
        var prevCh = Char(0)
        var count = 0
        var adjustedPtnLength = Int32(adjustedPtn.size)
        var i = 0
        while (i < adjustedPtnLength) {
            let ch = adjustedPtn.get(Int64(i))
            if (ch != prevCh && count > 0) {
                var skeletonChar = prevCh
                if (skeletonChar == 'L') {
                    skeletonChar = 'M'
                }
                let fieldCount = bestMatchSkeletonFieldWidth[Int64(Int32(UInt32(skeletonChar)) - PATTERN_CHAR_BASE)]
                let inputFieldCount = inputSkeletonFieldWidth[Int64(Int32(UInt32(skeletonChar)) - PATTERN_CHAR_BASE)]
                if (fieldCount == count && inputFieldCount > fieldCount) {
                    count = inputFieldCount - fieldCount
                    } while (false)
                    i += count
                    adjustedPtnLength += count
                }
                count = 0
            }
            if (ch == ''') {
                if ((i + 1) < Int32(adjustedPtn.size) && adjustedPtn.get(Int64(i + 1)) == ''') {
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
        if (count > 0) {
            var skeletonChar = prevCh
            if (skeletonChar == 'L') {
                skeletonChar = 'M'
            }
            let fieldCount = bestMatchSkeletonFieldWidth[Int64(Int32(UInt32(skeletonChar)) - PATTERN_CHAR_BASE)]
            let inputFieldCount = inputSkeletonFieldWidth[Int64(Int32(UInt32(skeletonChar)) - PATTERN_CHAR_BASE)]
            if (fieldCount == count && inputFieldCount > fieldCount) {
                count = inputFieldCount - fieldCount
                } while (false)
            }
        }
        return adjustedPtn.toString()
    }

    private static func findReplaceInPattern(targetString: String, strToReplace: String, strToReplaceWith: String): String {
        var firstQuoteIndex = indexOfWrap(targetString.indexOf("'"))
        if (firstQuoteIndex < 0) {
            return targetString.replace(strToReplace, strToReplaceWith)
        } else {
            let result = StringBuilder()
            var source = targetString
            while (firstQuoteIndex >= 0) {
                var secondQuoteIndex = indexOfWrap(source.indexOf("'", Int64(firstQuoteIndex + 1)))
                if (secondQuoteIndex < 0) {
                    secondQuoteIndex = Int32(source.size) - 1
                }
                let unquotedText: String = source[0..Int64(firstQuoteIndex)]
                let quotedText: String = source[Int64(firstQuoteIndex)..Int64(secondQuoteIndex + 1)]
                result.append(unquotedText.replace(strToReplace, strToReplaceWith))
                result.append(quotedText)
                source = source[Int64(secondQuoteIndex + 1)..]
                firstQuoteIndex = indexOfWrap(source.indexOf("'"))
            }
            result.append(source.replace(strToReplace, strToReplaceWith))
            return result.toString()
        }
    }

    private func concatSingleDate2TimeInterval(dtfmt: String, datePattern: String, field: Int32, intervalPatterns: Map<String, DateIntervalInfo_PatternInfo>): Unit {
        var timeItvPtnInfo = intervalPatterns.get(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(field)])
        if (timeItvPtnInfo.isSome()) {
            let timeIntervalPattern: String = (timeItvPtnInfo.getFirstPart()) + (timeItvPtnInfo.getSecondPart())
            let pattern = SimpleFormatterImpl.formatRawPattern(dtfmt, 2, 2, [timeIntervalPattern, datePattern])
            timeItvPtnInfo = DateIntervalInfo.genPatternInfo(pattern, timeItvPtnInfo.firstDateInPtnIsLaterDate())
            intervalPatterns.put(DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(field)], timeItvPtnInfo)
        }
    }

    private static func fieldExistsInSkeleton(field: Int32, skeleton: String): Bool {
        let fieldChar = DateIntervalInfo.CALENDAR_FIELD_TO_PATTERN_LETTER[Int64(field)]
        var result = skeleton.contains(fieldChar)
        if (!result) {
            if (fieldChar == "M") {
                result = skeleton.contains("L")
            } else if (fieldChar == "y") {
                result = skeleton.contains("U") || skeleton.contains("Y") || skeleton.contains("u") || skeleton.contains("r")
            }
        }
        return result
    }

    private func readObject(stream: ObjectInputStream): Unit {
        stream.defaultReadObject()
        initializePattern(if (isDateIntervalInfoDefault) { LOCAL_PATTERN_CACHE } else { None })
        if (fCapitalizationSetting.isNone()) {
            fCapitalizationSetting = DisplayContext.CAPITALIZATION_NONE
        }
    }

    
    public func getRawPatterns(): Map<String, DateIntervalInfo_PatternInfo> {
        return fIntervalPatterns
    }
}


public class DateIntervalFormat_FormattedDateInterval <: FormattedValue {
    private let string: String

    private let attributes: ArrayList<FieldPosition>

    init(cs: String, attributes: ArrayList<FieldPosition>) {
        this.string = toString(cs)
        this.attributes = Collections.unmodifiableList(attributes)
    }

    public override func toString(): String {
        return string
    }

    public override func length(): Int32 {
        return Int32(string.size)
    }

    public override func charAt(index: Int32): Char {
        return Char(string[Int64(index)])
    }

    public override func subSequence(start: Int32, end: Int32): String {
        return string.subSequence(start, end)
    }

    public override func appendTo<A>(appendable: A): A {
        return Utility.appendTo(string, appendable)
    }

    public override func nextPosition(cfpos: ConstrainedFieldPosition): Bool {
        return FormattedValueFieldPositionIteratorImpl.nextPosition(attributes, cfpos)
    }

    public override func toCharacterIterator(): AttributedCharacterIterator {
        return FormattedValueFieldPositionIteratorImpl.toCharacterIterator(string, attributes)
    }
}


public class DateIntervalFormat_SpanField <: UFormat_SpanField {
    private static let serialVersionUID = -6330879259553618133

    public static let DATE_INTERVAL_SPAN = DateIntervalFormat_SpanField("date-interval-span")

    private init(name: String) {
        super(name)
    }

    
    override protected func readResolve(): Object {
        if (this.getName().equals(DATE_INTERVAL_SPAN.getName())) {
            return DATE_INTERVAL_SPAN
        }
        throw InvalidObjectException("An invalid object.")
    }
}


class DateIntervalFormat_BestMatchInfo {
    let bestMatchSkeleton: String

    let bestMatchDistanceInfo: Int32

    init(bestSkeleton: String, difference: Int32) {
        bestMatchSkeleton = bestSkeleton
        bestMatchDistanceInfo = difference
    }
}


class DateIntervalFormat_SkeletonAndItsBestMatch {
    let skeleton: String

    let bestMatchSkeleton: String

    init(skeleton: String, bestMatch: String) {
        this.skeleton = skeleton
        bestMatchSkeleton = bestMatch
    }
}


class DateIntervalFormat_FormatOutput {

    var firstIndex = -1

    public func register(i: Int32): Unit {
        if (firstIndex == -1) {
            firstIndex = i
        }
    }
}
