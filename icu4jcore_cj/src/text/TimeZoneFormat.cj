package icu4cj.text


public class TimeZoneFormat <: UFormat & Freezable<TimeZoneFormat> & Serializable & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private static let serialVersionUID = 2281246852693575022

    static let ISO_Z_STYLE_FLAG = 128

    static let ISO_LOCAL_STYLE_FLAG = 256

    private var _locale: ULocale

    private var _tznames: TimeZoneNames

    private var _gmtPattern: String

    private var _gmtOffsetPatterns: Array<String>

    private var _gmtOffsetDigits: Array<String>

    private var _gmtZeroFormat: String

    private var _parseAllStyles: Bool = false

    private var _parseTZDBNames: Bool = false

      private var _gnames: TimeZoneGenericNames

     private var _gmtPatternPrefix: String

     private var _gmtPatternSuffix: String

     private var _gmtOffsetPatternItems: Array<Array<Object>>

     private var _abuttingOffsetHoursAndMinutes: Bool = false

     private var _region: String

      private var _frozen: Bool = false

      private var _tzdbNames: TimeZoneNames

    private static let TZID_GMT = "Etc/GMT"

    private static let ALT_GMT_STRINGS: Array<String> = ["GMT", "UTC", "UT"]

    private static let DEFAULT_GMT_PATTERN = "GMT{0}"

    private static let DEFAULT_GMT_ZERO = "GMT"

    private static let DEFAULT_GMT_DIGITS: Array<String> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

    private static let DEFAULT_GMT_OFFSET_SEP = ':'

    private static let ASCII_DIGITS = "0123456789"

    private static let ISO8601_UTC = "Z"

    private static let UNKNOWN_ZONE_ID = "Etc/Unknown"

    private static let UNKNOWN_SHORT_ZONE_ID = "unk"

    private static let UNKNOWN_LOCATION = "Unknown"

    private static let PARSE_GMT_OFFSET_TYPES: Array<TimeZoneFormat_GMTOffsetPatternType> = [TimeZoneFormat_GMTOffsetPatternType.POSITIVE_HMS, TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_HMS, TimeZoneFormat_GMTOffsetPatternType.POSITIVE_HM, TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_HM, TimeZoneFormat_GMTOffsetPatternType.POSITIVE_H, TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_H]

    private static let MILLIS_PER_HOUR = 60 * 60 * 1000

    private static let MILLIS_PER_MINUTE = 60 * 1000

    private static let MILLIS_PER_SECOND = 1000

    private static let MAX_OFFSET = 24 * MILLIS_PER_HOUR

    private static let MAX_OFFSET_HOUR = 23

    private static let MAX_OFFSET_MINUTE = 59

    private static let MAX_OFFSET_SECOND = 59

    private static let UNKNOWN_OFFSET = Int32.Max

    private static var _tzfCache: TimeZoneFormat_TimeZoneFormatCache = TimeZoneFormat_TimeZoneFormatCache()

    private static let ALL_SIMPLE_NAME_TYPES = EnumSet.of(TimeZoneNames_NameType.LONG_STANDARD, TimeZoneNames_NameType.LONG_DAYLIGHT, TimeZoneNames_NameType.SHORT_STANDARD, TimeZoneNames_NameType.SHORT_DAYLIGHT, TimeZoneNames_NameType.EXEMPLAR_LOCATION)

    private static let ALL_GENERIC_NAME_TYPES = EnumSet.of(TimeZoneGenericNames_GenericNameType.LOCATION, TimeZoneGenericNames_GenericNameType.LONG, TimeZoneGenericNames_GenericNameType.SHORT)

     private static var ZONE_ID_TRIE: TextTrieMap<String>

     private static var SHORT_ZONE_ID_TRIE: TextTrieMap<String>

    protected init(locale: ULocale) {
        super()
        _locale = locale
        _tznames = TimeZoneNames.getInstance(locale)
        var gmtPattern: String
        var hourFormats: String
        _gmtZeroFormat = DEFAULT_GMT_ZERO
        try {
            let bundle = ICUResourceBundle.getBundleInstance(ICUData.ICU_ZONE_BASE_NAME, locale)
            try {
                gmtPattern = bundle.getStringWithFallback("zoneStrings/gmtFormat")
            } catch (e: MissingResourceException) { }
            try {
                hourFormats = bundle.getStringWithFallback("zoneStrings/hourFormat")
            } catch (e: MissingResourceException) { }
            try {
                _gmtZeroFormat = bundle.getStringWithFallback("zoneStrings/gmtZeroFormat")
            } catch (e: MissingResourceException) { }
        } catch (e: MissingResourceException) { }
        if (gmtPattern.isNone()) {
            gmtPattern = DEFAULT_GMT_PATTERN
        }
        initGMTPattern(gmtPattern)
        let gmtOffsetPatterns = Array<String>(TimeZoneFormat_GMTOffsetPatternType.values().size)
        if (hourFormats.isSome()) {
            let hourPatterns = hourFormats.split(";", 2)
            gmtOffsetPatterns[Int64(TimeZoneFormat_GMTOffsetPatternType.POSITIVE_H.ordinal)] = truncateOffsetPattern(hourPatterns[0])
            gmtOffsetPatterns[Int64(TimeZoneFormat_GMTOffsetPatternType.POSITIVE_HM.ordinal)] = hourPatterns[0]
            gmtOffsetPatterns[Int64(TimeZoneFormat_GMTOffsetPatternType.POSITIVE_HMS.ordinal)] = expandOffsetPattern(hourPatterns[0])
            gmtOffsetPatterns[Int64(TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_H.ordinal)] = truncateOffsetPattern(hourPatterns[1])
            gmtOffsetPatterns[Int64(TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_HM.ordinal)] = hourPatterns[1]
            gmtOffsetPatterns[Int64(TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_HMS.ordinal)] = expandOffsetPattern(hourPatterns[1])
        } else {
            for (patType in TimeZoneFormat_GMTOffsetPatternType.values()) {
                gmtOffsetPatterns[Int64(patType.ordinal)] = patType.defaultPattern()
            }
        }
        initGMTOffsetPatterns(gmtOffsetPatterns)
        _gmtOffsetDigits = DEFAULT_GMT_DIGITS
        let ns = NumberingSystem.getInstance(locale)
        if (!ns.isAlgorithmic()) {
            _gmtOffsetDigits = toCodePoints(ns.getDescription())
        }
    }

    public static func getInstance(locale: ULocale): TimeZoneFormat {
        if (locale.isNone()) {
            throw NoneValueException("locale is null")
        }
        return _tzfCache.getInstance(locale, locale)
    }

    public static func getInstance(locale: Locale): TimeZoneFormat {
        return getInstance(ULocale.forLocale(locale))
    }

    public func getTimeZoneNames(): TimeZoneNames {
        return _tznames
    }

    private func getTimeZoneGenericNames(): TimeZoneGenericNames {
        if (_gnames.isNone()) {
            synchronized (getMonitorByObject(this)) {
                if (_gnames.isNone()) {
                    _gnames = TimeZoneGenericNames.getInstance(_locale)
                }
            }
        }
        return _gnames
    }

    private func getTZDBTimeZoneNames(): TimeZoneNames {
        if (_tzdbNames.isNone()) {
            synchronized (getMonitorByObject(this)) {
                if (_tzdbNames.isNone()) {
                    _tzdbNames = TZDBTimeZoneNames(_locale)
                }
            }
        }
        return _tzdbNames
    }

    public func setTimeZoneNames(tznames: TimeZoneNames): TimeZoneFormat {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify frozen object")
        }
        _tznames = tznames
        _gnames = TimeZoneGenericNames(_locale, _tznames)
        return this
    }

    public func getGMTPattern(): String {
        return _gmtPattern
    }

    public func setGMTPattern(pattern: String): TimeZoneFormat {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify frozen object")
        }
        initGMTPattern(pattern)
        return this
    }

    public func getGMTOffsetPattern(Type: TimeZoneFormat_GMTOffsetPatternType): String {
        return _gmtOffsetPatterns[Int64(Type.ordinal)]
    }

    public func setGMTOffsetPattern(Type: TimeZoneFormat_GMTOffsetPatternType, pattern: String): TimeZoneFormat {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify frozen object")
        }
        if (pattern.isNone()) {
            throw NoneValueException("Null GMT offset pattern")
        }
        let parsedItems = parseOffsetPattern(pattern, Type.required())
        _gmtOffsetPatterns[Int64(Type.ordinal)] = pattern
        _gmtOffsetPatternItems[Int64(Type.ordinal)] = parsedItems
        checkAbuttingHoursAndMinutes()
        return this
    }

    public func getGMTOffsetDigits(): String {
        let buf = StringBuilder()
        for (digit in _gmtOffsetDigits) {
            buf.append(digit)
        }
        return buf.toString()
    }

    public func setGMTOffsetDigits(digits: String): TimeZoneFormat {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify frozen object")
        }
        if (digits.isNone()) {
            throw NoneValueException("Null GMT offset digits")
        }
        let digitArray = toCodePoints(digits)
        if (Int32(digitArray.size) != 10) {
            throw IllegalArgumentException("Length of digits must be 10")
        }
        _gmtOffsetDigits = digitArray
        return this
    }

    public func getGMTZeroFormat(): String {
        return _gmtZeroFormat
    }

    public func setGMTZeroFormat(gmtZeroFormat: String): TimeZoneFormat {
        if (isFrozen()) {
            throw UnsupportedOperationException("Attempt to modify frozen object")
        }
        if (gmtZeroFormat.isNone()) {
            throw NoneValueException("Null GMT zero format")
        }
        if (Int32(gmtZeroFormat.size) == 0) {
            throw IllegalArgumentException("Empty GMT zero format")
        }
        _gmtZeroFormat = gmtZeroFormat
        return this
    }

    public func setDefaultParseOptions(options: EnumSet): TimeZoneFormat {
        _parseAllStyles = options.contains(TimeZoneFormat_ParseOption.ALL_STYLES)
        _parseTZDBNames = options.contains(TimeZoneFormat_ParseOption.TZ_DATABASE_ABBREVIATIONS)
        return this
    }

    public func getDefaultParseOptions(): EnumSet {
        if (_parseAllStyles && _parseTZDBNames) {
            return EnumSet.of(TimeZoneFormat_ParseOption.ALL_STYLES, TimeZoneFormat_ParseOption.TZ_DATABASE_ABBREVIATIONS)
        } else if (_parseAllStyles) {
            return EnumSet.of(TimeZoneFormat_ParseOption.ALL_STYLES)
        } else if (_parseTZDBNames) {
            return EnumSet.of(TimeZoneFormat_ParseOption.TZ_DATABASE_ABBREVIATIONS)
        }
        return EnumSet.noneOf(TypeInfo.of<TimeZoneFormat_ParseOption>() as ClassTypeInfo)
    }

    public func formatOffsetISO8601Basic(offset: Int32, useUtcIndicator: Bool, isShort: Bool, ignoreSeconds: Bool): String {
        return formatOffsetISO8601(offset, true, useUtcIndicator, isShort, ignoreSeconds)
    }

    public func formatOffsetISO8601Extended(offset: Int32, useUtcIndicator: Bool, isShort: Bool, ignoreSeconds: Bool): String {
        return formatOffsetISO8601(offset, false, useUtcIndicator, isShort, ignoreSeconds)
    }

    public func formatOffsetLocalizedGMT(offset: Int32): String {
        return formatOffsetLocalizedGMT(offset, false)
    }

    public func formatOffsetShortLocalizedGMT(offset: Int32): String {
        return formatOffsetLocalizedGMT(offset, true)
    }

    public func format(style: TimeZoneFormat_Style, tz: TimeZone, date: Int64): String {
        return format(style, tz, date, None)
    }

    public func format(style: TimeZoneFormat_Style, tz: TimeZone, date: Int64, timeType: Output<TimeZoneFormat_TimeType>): String {
        var result: String
        if (timeType.isSome()) {
            timeType.value = TimeZoneFormat_TimeType.UNKNOWN
        }
        var noOffsetFormatFallback = false
        match (style) {
            case TimeZoneFormat_Style.GENERIC_LOCATION => result = getTimeZoneGenericNames().getGenericLocationName(ZoneMeta.getCanonicalCLDRID(tz))
            case TimeZoneFormat_Style.GENERIC_LONG => result = getTimeZoneGenericNames().getDisplayName(tz, TimeZoneGenericNames_GenericNameType.LONG, date)
            case TimeZoneFormat_Style.GENERIC_SHORT => result = getTimeZoneGenericNames().getDisplayName(tz, TimeZoneGenericNames_GenericNameType.SHORT, date)
            case TimeZoneFormat_Style.SPECIFIC_LONG => result = formatSpecific(tz, TimeZoneNames_NameType.LONG_STANDARD, TimeZoneNames_NameType.LONG_DAYLIGHT, date, timeType)
            case TimeZoneFormat_Style.SPECIFIC_SHORT => result = formatSpecific(tz, TimeZoneNames_NameType.SHORT_STANDARD, TimeZoneNames_NameType.SHORT_DAYLIGHT, date, timeType)
            case TimeZoneFormat_Style.ZONE_ID =>
                result = tz.getID()
                noOffsetFormatFallback = true
            case TimeZoneFormat_Style.ZONE_ID_SHORT =>
                result = ZoneMeta.getShortID(tz)
                if (result.isNone()) {
                    result = UNKNOWN_SHORT_ZONE_ID
                }
                noOffsetFormatFallback = true
            case TimeZoneFormat_Style.EXEMPLAR_LOCATION =>
                result = formatExemplarLocation(tz)
                noOffsetFormatFallback = true
            case _ => ()
        }
        if (result.isNone() && !noOffsetFormatFallback) {
            let offsets = [0, 0]
            tz.getOffset(date, false, offsets)
            let offset = offsets[0] + offsets[1]
            match (style) {
                case TimeZoneFormat_Style.GENERIC_LOCATION | TimeZoneFormat_Style.GENERIC_LONG | TimeZoneFormat_Style.SPECIFIC_LONG | TimeZoneFormat_Style.LOCALIZED_GMT => result = formatOffsetLocalizedGMT(offset)
                case TimeZoneFormat_Style.GENERIC_SHORT | TimeZoneFormat_Style.SPECIFIC_SHORT | TimeZoneFormat_Style.LOCALIZED_GMT_SHORT => result = formatOffsetShortLocalizedGMT(offset)
                case TimeZoneFormat_Style.ISO_BASIC_SHORT => result = formatOffsetISO8601Basic(offset, true, true, true)
                case TimeZoneFormat_Style.ISO_BASIC_LOCAL_SHORT => result = formatOffsetISO8601Basic(offset, false, true, true)
                case TimeZoneFormat_Style.ISO_BASIC_FIXED => result = formatOffsetISO8601Basic(offset, true, false, true)
                case TimeZoneFormat_Style.ISO_BASIC_LOCAL_FIXED => result = formatOffsetISO8601Basic(offset, false, false, true)
                case TimeZoneFormat_Style.ISO_BASIC_FULL => result = formatOffsetISO8601Basic(offset, true, false, false)
                case TimeZoneFormat_Style.ISO_BASIC_LOCAL_FULL => result = formatOffsetISO8601Basic(offset, false, false, false)
                case TimeZoneFormat_Style.ISO_EXTENDED_FIXED => result = formatOffsetISO8601Extended(offset, true, false, true)
                case TimeZoneFormat_Style.ISO_EXTENDED_LOCAL_FIXED => result = formatOffsetISO8601Extended(offset, false, false, true)
                case TimeZoneFormat_Style.ISO_EXTENDED_FULL => result = formatOffsetISO8601Extended(offset, true, false, false)
                case TimeZoneFormat_Style.ISO_EXTENDED_LOCAL_FULL => result = formatOffsetISO8601Extended(offset, false, false, false)
                case _ => if (!false) {
                    throw AssertionError()
                }
            }
            if (timeType.isSome()) {
                timeType.value = if (offsets[1] != 0) { TimeZoneFormat_TimeType.DAYLIGHT } else { TimeZoneFormat_TimeType.STANDARD }
            }
        }
        if (!(result.isSome())) {
            throw AssertionError()
        }
        return result
    }

    public func parseOffsetISO8601(text: String, pos: ParsePosition): Int32 {
        return parseOffsetISO8601Static(text, pos, false, None)
    }

    public func parseOffsetLocalizedGMT(text: String, pos: ParsePosition): Int32 {
        return parseOffsetLocalizedGMT(text, pos, false, None)
    }

    public func parseOffsetShortLocalizedGMT(text: String, pos: ParsePosition): Int32 {
        return parseOffsetLocalizedGMT(text, pos, true, None)
    }

    public func parse(style: TimeZoneFormat_Style, text: String, pos: ParsePosition, options: EnumSet, timeType: Output<TimeZoneFormat_TimeType>): TimeZone {
        var temptimeType = timeType
        if (temptimeType.isNone()) {
            temptimeType = Output<TimeZoneFormat_TimeType>(TimeZoneFormat_TimeType.UNKNOWN)
        } else {
            temptimeType.value = TimeZoneFormat_TimeType.UNKNOWN
        }
        let startIdx = pos.getIndex()
        let maxPos = Int32(text.size)
        var offset: Int32 = 0
        let fallbackLocalizedGMT = (refEq(style, TimeZoneFormat_Style.SPECIFIC_LONG) || refEq(style, TimeZoneFormat_Style.GENERIC_LONG) || refEq(style, TimeZoneFormat_Style.GENERIC_LOCATION))
        let fallbackShortLocalizedGMT = (refEq(style, TimeZoneFormat_Style.SPECIFIC_SHORT) || refEq(style, TimeZoneFormat_Style.GENERIC_SHORT))
        var evaluated = 0
        let tmpPos = ParsePosition(startIdx)
        var parsedOffset = UNKNOWN_OFFSET
        var parsedPos = -1
        if (fallbackLocalizedGMT || fallbackShortLocalizedGMT) {
            let hasDigitOffset = Output<Bool>(Bool.valueOf(false))
            offset = parseOffsetLocalizedGMT(text, tmpPos, fallbackShortLocalizedGMT, hasDigitOffset)
            if (tmpPos.getErrorIndex() == -1) {
                if (tmpPos.getIndex() == maxPos || hasDigitOffset.value.booleanValue()) {
                    pos.setIndex(tmpPos.getIndex())
                    return getTimeZoneForOffset(offset)
                }
                parsedOffset = offset
                parsedPos = tmpPos.getIndex()
            }
            evaluated |= (TimeZoneFormat_Style.LOCALIZED_GMT.flag | TimeZoneFormat_Style.LOCALIZED_GMT_SHORT.flag)
        }
        let parseTZDBAbbrev = if (options.isNone()) { getDefaultParseOptions().contains(TimeZoneFormat_ParseOption.TZ_DATABASE_ABBREVIATIONS) } else { options.contains(TimeZoneFormat_ParseOption.TZ_DATABASE_ABBREVIATIONS) }
        match (style) {
            case TimeZoneFormat_Style.LOCALIZED_GMT =>
                tmpPos.setIndex(startIdx)
                tmpPos.setErrorIndex(-1)
                offset = parseOffsetLocalizedGMT(text, tmpPos)
                if (tmpPos.getErrorIndex() == -1) {
                    pos.setIndex(tmpPos.getIndex())
                    return getTimeZoneForOffset(offset)
                }
                evaluated |= TimeZoneFormat_Style.LOCALIZED_GMT_SHORT.flag
                break
            case TimeZoneFormat_Style.LOCALIZED_GMT_SHORT =>
                tmpPos.setIndex(startIdx)
                tmpPos.setErrorIndex(-1)
                offset = parseOffsetShortLocalizedGMT(text, tmpPos)
                if (tmpPos.getErrorIndex() == -1) {
                    pos.setIndex(tmpPos.getIndex())
                    return getTimeZoneForOffset(offset)
                }
                evaluated |= TimeZoneFormat_Style.LOCALIZED_GMT.flag
                break
            case TimeZoneFormat_Style.ISO_BASIC_SHORT | TimeZoneFormat_Style.ISO_BASIC_FIXED | TimeZoneFormat_Style.ISO_BASIC_FULL | TimeZoneFormat_Style.ISO_EXTENDED_FIXED | TimeZoneFormat_Style.ISO_EXTENDED_FULL =>
                tmpPos.setIndex(startIdx)
                tmpPos.setErrorIndex(-1)
                offset = parseOffsetISO8601(text, tmpPos)
                if (tmpPos.getErrorIndex() == -1) {
                    pos.setIndex(tmpPos.getIndex())
                    return getTimeZoneForOffset(offset)
                }
                break
            case TimeZoneFormat_Style.ISO_BASIC_LOCAL_SHORT | TimeZoneFormat_Style.ISO_BASIC_LOCAL_FIXED | TimeZoneFormat_Style.ISO_BASIC_LOCAL_FULL | TimeZoneFormat_Style.ISO_EXTENDED_LOCAL_FIXED | TimeZoneFormat_Style.ISO_EXTENDED_LOCAL_FULL =>
                tmpPos.setIndex(startIdx)
                tmpPos.setErrorIndex(-1)
                let hasDigitOffset = Output<Bool>(Bool.valueOf(false))
                offset = parseOffsetISO8601Static(text, tmpPos, false, hasDigitOffset)
                if (tmpPos.getErrorIndex() == -1 && hasDigitOffset.value.booleanValue()) {
                    pos.setIndex(tmpPos.getIndex())
                    return getTimeZoneForOffset(offset)
                }
                break
            case TimeZoneFormat_Style.SPECIFIC_LONG | TimeZoneFormat_Style.SPECIFIC_SHORT =>
                var nameTypes: EnumSet = None
                if (refEq(style, TimeZoneFormat_Style.SPECIFIC_LONG)) {
                    nameTypes = EnumSet.of(TimeZoneNames_NameType.LONG_STANDARD, TimeZoneNames_NameType.LONG_DAYLIGHT)
                } else {
                    if (!refEq(style, TimeZoneFormat_Style.SPECIFIC_SHORT)) {
                        throw AssertionError()
                    }
                    nameTypes = EnumSet.of(TimeZoneNames_NameType.SHORT_STANDARD, TimeZoneNames_NameType.SHORT_DAYLIGHT)
                }
                let specificMatches = _tznames.find(text, startIdx, nameTypes)
                if (specificMatches.isSome()) {
                    var specificMatch: TimeZoneNames_MatchInfo
                    for (match in specificMatches) {
                        if (startIdx + match.matchLength() > parsedPos) {
                            specificMatch = match
                            parsedPos = startIdx + match.matchLength()
                        }
                    }
                    if (specificMatch.isSome()) {
                        temptimeType.value = getTimeType(specificMatch.nameType())
                        pos.setIndex(parsedPos)
                        return TimeZone.getTimeZone(getTimeZoneID(specificMatch.tzID(), specificMatch.mzID()))
                    }
                }
                if (parseTZDBAbbrev && refEq(style, TimeZoneFormat_Style.SPECIFIC_SHORT)) {
                    if (!nameTypes.contains(TimeZoneNames_NameType.SHORT_STANDARD)) {
                        throw AssertionError()
                    }
                    if (!nameTypes.contains(TimeZoneNames_NameType.SHORT_DAYLIGHT)) {
                        throw AssertionError()
                    }
                    let tzdbNameMatches = getTZDBTimeZoneNames().find(text, startIdx, nameTypes)
                    if (tzdbNameMatches.isSome()) {
                        var tzdbNameMatch: TimeZoneNames_MatchInfo
                        for (match in tzdbNameMatches) {
                            if (startIdx + match.matchLength() > parsedPos) {
                                tzdbNameMatch = match
                                parsedPos = startIdx + match.matchLength()
                            }
                        }
                        if (tzdbNameMatch.isSome()) {
                            temptimeType.value = getTimeType(tzdbNameMatch.nameType())
                            pos.setIndex(parsedPos)
                            return TimeZone.getTimeZone(getTimeZoneID(tzdbNameMatch.tzID(), tzdbNameMatch.mzID()))
                        }
                    }
                }
                break
            case TimeZoneFormat_Style.GENERIC_LONG | TimeZoneFormat_Style.GENERIC_SHORT | TimeZoneFormat_Style.GENERIC_LOCATION =>
                var genericNameTypes: EnumSet = None
                match (style) {
                    case TimeZoneFormat_Style.GENERIC_LOCATION => genericNameTypes = EnumSet.of(TimeZoneGenericNames_GenericNameType.LOCATION)
                    case TimeZoneFormat_Style.GENERIC_LONG => genericNameTypes = EnumSet.of(TimeZoneGenericNames_GenericNameType.LONG, TimeZoneGenericNames_GenericNameType.LOCATION)
                    case TimeZoneFormat_Style.GENERIC_SHORT => genericNameTypes = EnumSet.of(TimeZoneGenericNames_GenericNameType.SHORT, TimeZoneGenericNames_GenericNameType.LOCATION)
                    case _ => if (!false) {
                        throw AssertionError()
                    }
                }
                let bestGeneric = getTimeZoneGenericNames().findBestMatch(text, startIdx, genericNameTypes)
                if (bestGeneric.isSome() && (startIdx + bestGeneric.matchLengthMethod() > parsedPos)) {
                    temptimeType.value = bestGeneric.timeTypeMethod()
                    pos.setIndex(startIdx + bestGeneric.matchLengthMethod())
                    return TimeZone.getTimeZone(bestGeneric.tzIDMethod())
                }
                break
            case TimeZoneFormat_Style.ZONE_ID =>
                tmpPos.setIndex(startIdx)
                tmpPos.setErrorIndex(-1)
                let id = parseZoneID(text, tmpPos)
                if (tmpPos.getErrorIndex() == -1) {
                    pos.setIndex(tmpPos.getIndex())
                    return TimeZone.getTimeZone(id)
                }
                break
            case TimeZoneFormat_Style.ZONE_ID_SHORT =>
                tmpPos.setIndex(startIdx)
                tmpPos.setErrorIndex(-1)
                let id = parseShortZoneID(text, tmpPos)
                if (tmpPos.getErrorIndex() == -1) {
                    pos.setIndex(tmpPos.getIndex())
                    return TimeZone.getTimeZone(id)
                }
                break
            case TimeZoneFormat_Style.EXEMPLAR_LOCATION =>
                tmpPos.setIndex(startIdx)
                tmpPos.setErrorIndex(-1)
                let id = parseExemplarLocation(text, tmpPos)
                if (tmpPos.getErrorIndex() == -1) {
                    pos.setIndex(tmpPos.getIndex())
                    return TimeZone.getTimeZone(id)
                }
                break
            case _ => ()
        }
        evaluated |= style.flag
        if (parsedPos > startIdx) {
            if (!(parsedOffset != UNKNOWN_OFFSET)) {
                throw AssertionError()
            }
            pos.setIndex(parsedPos)
            return getTimeZoneForOffset(parsedOffset)
        }
        var parsedID: String
        var parsedTimeType: TimeZoneFormat_TimeType = TimeZoneFormat_TimeType.UNKNOWN
        if (!(parsedPos < 0)) {
            throw AssertionError()
        }
        if (!(parsedOffset == UNKNOWN_OFFSET)) {
            throw AssertionError()
        }
        if (parsedPos < maxPos && ((evaluated & ISO_Z_STYLE_FLAG) == 0 || (evaluated & ISO_LOCAL_STYLE_FLAG) == 0)) {
            tmpPos.setIndex(startIdx)
            tmpPos.setErrorIndex(-1)
            let hasDigitOffset = Output<Bool>(Bool.valueOf(false))
            offset = parseOffsetISO8601Static(text, tmpPos, false, hasDigitOffset)
            if (tmpPos.getErrorIndex() == -1) {
                if (tmpPos.getIndex() == maxPos || hasDigitOffset.value.booleanValue()) {
                    pos.setIndex(tmpPos.getIndex())
                    return getTimeZoneForOffset(offset)
                }
                if (parsedPos < tmpPos.getIndex()) {
                    parsedOffset = offset
                    parsedID = None
                    parsedTimeType = TimeZoneFormat_TimeType.UNKNOWN
                    parsedPos = tmpPos.getIndex()
                    if (!(parsedPos == startIdx + 1)) {
                        throw AssertionError()
                    }
                }
            }
        }
        if (parsedPos < maxPos && (evaluated & TimeZoneFormat_Style.LOCALIZED_GMT.flag) == 0) {
            tmpPos.setIndex(startIdx)
            tmpPos.setErrorIndex(-1)
            let hasDigitOffset = Output<Bool>(Bool.valueOf(false))
            offset = parseOffsetLocalizedGMT(text, tmpPos, false, hasDigitOffset)
            if (tmpPos.getErrorIndex() == -1) {
                if (tmpPos.getIndex() == maxPos || hasDigitOffset.value.booleanValue()) {
                    pos.setIndex(tmpPos.getIndex())
                    return getTimeZoneForOffset(offset)
                }
                if (parsedPos < tmpPos.getIndex()) {
                    parsedOffset = offset
                    parsedID = None
                    parsedTimeType = TimeZoneFormat_TimeType.UNKNOWN
                    parsedPos = tmpPos.getIndex()
                }
            }
        }
        if (parsedPos < maxPos && (evaluated & TimeZoneFormat_Style.LOCALIZED_GMT_SHORT.flag) == 0) {
            tmpPos.setIndex(startIdx)
            tmpPos.setErrorIndex(-1)
            let hasDigitOffset = Output<Bool>(Bool.valueOf(false))
            offset = parseOffsetLocalizedGMT(text, tmpPos, true, hasDigitOffset)
            if (tmpPos.getErrorIndex() == -1) {
                if (tmpPos.getIndex() == maxPos || hasDigitOffset.value.booleanValue()) {
                    pos.setIndex(tmpPos.getIndex())
                    return getTimeZoneForOffset(offset)
                }
                if (parsedPos < tmpPos.getIndex()) {
                    parsedOffset = offset
                    parsedID = None
                    parsedTimeType = TimeZoneFormat_TimeType.UNKNOWN
                    parsedPos = tmpPos.getIndex()
                }
            }
        }
        let parseAllStyles = if (options.isNone()) { getDefaultParseOptions().contains(TimeZoneFormat_ParseOption.ALL_STYLES) } else { options.contains(TimeZoneFormat_ParseOption.ALL_STYLES) }
        if (parseAllStyles) {
            if (parsedPos < maxPos) {
                let specificMatches = _tznames.find(text, startIdx, ALL_SIMPLE_NAME_TYPES)
                var specificMatch: TimeZoneNames_MatchInfo
                var matchPos = -1
                if (specificMatches.isSome()) {
                    for (match in specificMatches) {
                        if (startIdx + match.matchLength() > matchPos) {
                            specificMatch = match
                            matchPos = startIdx + match.matchLength()
                        }
                    }
                }
                if (parsedPos < matchPos) {
                    parsedPos = matchPos
                    parsedID = getTimeZoneID(specificMatch.tzID(), specificMatch.mzID())
                    parsedTimeType = getTimeType(specificMatch.nameType())
                    parsedOffset = UNKNOWN_OFFSET
                }
            }
            if (parseTZDBAbbrev && parsedPos < maxPos && (evaluated & TimeZoneFormat_Style.SPECIFIC_SHORT.flag) == 0) {
                let tzdbNameMatches = getTZDBTimeZoneNames().find(text, startIdx, ALL_SIMPLE_NAME_TYPES)
                var tzdbNameMatch: TimeZoneNames_MatchInfo
                var matchPos = -1
                if (tzdbNameMatches.isSome()) {
                    for (match in tzdbNameMatches) {
                        if (startIdx + match.matchLength() > matchPos) {
                            tzdbNameMatch = match
                            matchPos = startIdx + match.matchLength()
                        }
                    }
                    if (parsedPos < matchPos) {
                        parsedPos = matchPos
                        parsedID = getTimeZoneID(tzdbNameMatch.tzID(), tzdbNameMatch.mzID())
                        parsedTimeType = getTimeType(tzdbNameMatch.nameType())
                        parsedOffset = UNKNOWN_OFFSET
                    }
                }
            }
            if (parsedPos < maxPos) {
                let genericMatch = getTimeZoneGenericNames().findBestMatch(text, startIdx, ALL_GENERIC_NAME_TYPES)
                if (genericMatch.isSome() && parsedPos < startIdx + genericMatch.matchLengthMethod()) {
                    parsedPos = startIdx + genericMatch.matchLengthMethod()
                    parsedID = genericMatch.tzIDMethod()
                    parsedTimeType = genericMatch.timeTypeMethod()
                    parsedOffset = UNKNOWN_OFFSET
                }
            }
            if (parsedPos < maxPos && (evaluated & TimeZoneFormat_Style.ZONE_ID.flag) == 0) {
                tmpPos.setIndex(startIdx)
                tmpPos.setErrorIndex(-1)
                let id = parseZoneID(text, tmpPos)
                if (tmpPos.getErrorIndex() == -1 && parsedPos < tmpPos.getIndex()) {
                    parsedPos = tmpPos.getIndex()
                    parsedID = id
                    parsedTimeType = TimeZoneFormat_TimeType.UNKNOWN
                    parsedOffset = UNKNOWN_OFFSET
                }
            }
            if (parsedPos < maxPos && (evaluated & TimeZoneFormat_Style.ZONE_ID_SHORT.flag) == 0) {
                tmpPos.setIndex(startIdx)
                tmpPos.setErrorIndex(-1)
                let id = parseShortZoneID(text, tmpPos)
                if (tmpPos.getErrorIndex() == -1 && parsedPos < tmpPos.getIndex()) {
                    parsedPos = tmpPos.getIndex()
                    parsedID = id
                    parsedTimeType = TimeZoneFormat_TimeType.UNKNOWN
                    parsedOffset = UNKNOWN_OFFSET
                }
            }
        }
        if (parsedPos > startIdx) {
            var parsedTZ: TimeZone
            if (parsedID.isSome()) {
                parsedTZ = TimeZone.getTimeZone(parsedID)
            } else {
                if (!(parsedOffset != UNKNOWN_OFFSET)) {
                    throw AssertionError()
                }
                parsedTZ = getTimeZoneForOffset(parsedOffset)
            }
            temptimeType.value = parsedTimeType
            pos.setIndex(parsedPos)
            return parsedTZ
        }
        pos.setErrorIndex(startIdx)
        return None
    }

    public func parse(style: TimeZoneFormat_Style, text: String, pos: ParsePosition, timeType: Output<TimeZoneFormat_TimeType>): TimeZone {
        return parse(style, text, pos, None, timeType)
    }

    public func parse(text: String, pos: ParsePosition): TimeZone {
        return parse(TimeZoneFormat_Style.GENERIC_LOCATION, text, pos, EnumSet.of(TimeZoneFormat_ParseOption.ALL_STYLES), None)
    }

    public func parse(text: String): TimeZone {
        let pos = ParsePosition(0)
        let tz = parse(text, pos)
        if (pos.getErrorIndex() >= 0) {
            throw ParseException("Unparseable time zone: \"" + (text) + "\"", 0)
        }
        if (!(tz.isSome())) {
            throw AssertionError()
        }
        return tz
    }

    public override func format(obj: Object, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        var tz: TimeZone
        var date = DateTime.now().toUnixTimeStamp().toMilliseconds()
        if (checkOptionalIs<TimeZone, Object>(obj)) {
            tz = obj
        } else if (checkOptionalIs<Calendar, Object>(obj)) {
            tz = obj.getTimeZone()
            date = obj.getTimeInMillis()
        } else {
            throw IllegalArgumentException("Cannot format given Object (" + TypeInfo.of(obj).name + ") as a time zone")
        }
        if (!(tz.isSome())) {
            throw AssertionError()
        }
        let result = formatOffsetLocalizedGMT(tz.getOffset(date))
        toAppendTo.append(result)
        if (refEq(pos.getFieldAttribute(), DateFormat_Field.TIME_ZONE) || pos.getField() == DateFormat.TIMEZONE_FIELD) {
            pos.setBeginIndex(0)
            pos.setEndIndex(Int32(result.size))
        }
        return toAppendTo
    }

    public override func formatToCharacterIterator(obj: Object): AttributedCharacterIterator {
        var toAppendTo: StringBuffer = StringBuffer()
        let pos = FieldPosition(0)
        toAppendTo = format(obj, toAppendTo, pos)
        let `as` = AttributedString(toString(toAppendTo))
        `as`.addAttribute(DateFormat_Field.TIME_ZONE, DateFormat_Field.TIME_ZONE)
        return `as`.getIterator()
    }

    public override func parseObject(source: String, pos: ParsePosition): Object {
        return parse(source, pos)
    }

    private func formatOffsetLocalizedGMT(offset: Int32, isShort: Bool): String {
        var tempoffset = offset
        if (tempoffset == 0) {
            return _gmtZeroFormat
        }
        let buf = StringBuilder()
        var positive = true
        if (tempoffset < 0) {
            tempoffset = -tempoffset
            positive = false
        }
        let offsetH = tempoffset / MILLIS_PER_HOUR
        tempoffset = tempoffset % MILLIS_PER_HOUR
        let offsetM = tempoffset / MILLIS_PER_MINUTE
        tempoffset = tempoffset % MILLIS_PER_MINUTE
        let offsetS = tempoffset / MILLIS_PER_SECOND
        if (offsetH > MAX_OFFSET_HOUR || offsetM > MAX_OFFSET_MINUTE || offsetS > MAX_OFFSET_SECOND) {
            throw IllegalArgumentException("Offset out of range :" + tempoffset.toString())
        }
        let offsetPatternItems: Array<Object>
        if (positive) {
            if (offsetS != 0) {
                offsetPatternItems = _gmtOffsetPatternItems[Int64(TimeZoneFormat_GMTOffsetPatternType.POSITIVE_HMS.ordinal)]
            } else if (offsetM != 0 || !isShort) {
                offsetPatternItems = _gmtOffsetPatternItems[Int64(TimeZoneFormat_GMTOffsetPatternType.POSITIVE_HM.ordinal)]
            } else {
                offsetPatternItems = _gmtOffsetPatternItems[Int64(TimeZoneFormat_GMTOffsetPatternType.POSITIVE_H.ordinal)]
            }
        } else {
            if (offsetS != 0) {
                offsetPatternItems = _gmtOffsetPatternItems[Int64(TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_HMS.ordinal)]
            } else if (offsetM != 0 || !isShort) {
                offsetPatternItems = _gmtOffsetPatternItems[Int64(TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_HM.ordinal)]
            } else {
                offsetPatternItems = _gmtOffsetPatternItems[Int64(TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_H.ordinal)]
            }
        }
        buf.append(_gmtPatternPrefix)
        for (item in offsetPatternItems) {
            if (item) {
                buf.append(item)
            } else if (checkOptionalIs<TimeZoneFormat_GMTOffsetField, Object>(item)) {
                let field = item
                match (field.getType()) {
                    case 'H' => appendOffsetDigits(buf, offsetH, (if (isShort) { 1 } else { 2 }))
                    case 'm' => appendOffsetDigits(buf, offsetM, 2)
                    case 's' => appendOffsetDigits(buf, offsetS, 2)
                    case _ => ()
                }
            }
        }
        buf.append(_gmtPatternSuffix)
        return buf.toString()
    }

    private func formatOffsetISO8601(offset: Int32, isBasic: Bool, useUtcIndicator: Bool, isShort: Bool, ignoreSeconds: Bool): String {
        var absOffset = if (offset < 0) { -offset } else { offset }
        if (useUtcIndicator && (absOffset < MILLIS_PER_SECOND || (ignoreSeconds && absOffset < MILLIS_PER_MINUTE))) {
            return ISO8601_UTC
        }
        let minFields: TimeZoneFormat_OffsetFields = if (isShort) { TimeZoneFormat_OffsetFields.H } else { TimeZoneFormat_OffsetFields.HM }
        let maxFields: TimeZoneFormat_OffsetFields = if (ignoreSeconds) { TimeZoneFormat_OffsetFields.HM } else { TimeZoneFormat_OffsetFields.HMS }
        let sep: Character = if (isBasic) { None } else { Character.valueOf(':') }
        if (absOffset >= MAX_OFFSET) {
            throw IllegalArgumentException("Offset out of range :" + offset.toString())
        }
        let fields = Array<Int32>(3) { _ => 0 }
        fields[0] = absOffset / MILLIS_PER_HOUR
        absOffset = absOffset % MILLIS_PER_HOUR
        fields[1] = absOffset / MILLIS_PER_MINUTE
        absOffset = absOffset % MILLIS_PER_MINUTE
        fields[2] = absOffset / MILLIS_PER_SECOND
        if (!(fields[0] >= 0 && fields[0] <= MAX_OFFSET_HOUR)) {
            throw AssertionError()
        }
        if (!(fields[1] >= 0 && fields[1] <= MAX_OFFSET_MINUTE)) {
            throw AssertionError()
        }
        if (!(fields[2] >= 0 && fields[2] <= MAX_OFFSET_SECOND)) {
            throw AssertionError()
        }
        var lastIdx = maxFields.ordinal
        while (lastIdx > minFields.ordinal) {
            if (fields[Int64(lastIdx)] != 0) {
                break
            }
            lastIdx--
        }
        let buf = StringBuilder()
        var sign = '+'
        if (offset < 0) {
                    idx++
                }
            } while (false)
        }
        buf.append(sign)
                if (fields[Int64(idx)] < 10) {
                    buf.append('0')
                }
                buf.append(fields[Int64(idx)])
                idx++
            }
        } while (false)
        return buf.toString()
    }

    private func formatSpecific(tz: TimeZone, stdType: TimeZoneNames_NameType, dstType: TimeZoneNames_NameType, date: Int64, timeType: Output<TimeZoneFormat_TimeType>): String {
        if (!(refEq(stdType, TimeZoneNames_NameType.LONG_STANDARD) || refEq(stdType, TimeZoneNames_NameType.SHORT_STANDARD))) {
            throw AssertionError()
        }
        if (!(refEq(dstType, TimeZoneNames_NameType.LONG_DAYLIGHT) || refEq(dstType, TimeZoneNames_NameType.SHORT_DAYLIGHT))) {
            throw AssertionError()
        }
        let isDaylight = tz.inDaylightTime(Date(date))
        let name = if (isDaylight) { getTimeZoneNames().getDisplayName(ZoneMeta.getCanonicalCLDRID(tz), dstType, date) } else { getTimeZoneNames().getDisplayName(ZoneMeta.getCanonicalCLDRID(tz), stdType, date) }
        if (name.isSome() && timeType.isSome()) {
            timeType.value = if (isDaylight) { TimeZoneFormat_TimeType.DAYLIGHT } else { TimeZoneFormat_TimeType.STANDARD }
        }
        return name
    }

    private func formatExemplarLocation(tz: TimeZone): String {
        var location = getTimeZoneNames().getExemplarLocationName(ZoneMeta.getCanonicalCLDRID(tz))
        if (location.isNone()) {
            location = getTimeZoneNames().getExemplarLocationName(UNKNOWN_ZONE_ID)
            if (location.isNone()) {
                location = UNKNOWN_LOCATION
            }
        }
        return location
    }

    private func getTimeZoneID(tzID: String, mzID: String): String {
        var id = tzID
        if (id.isNone()) {
            if (!(mzID.isSome())) {
                throw AssertionError()
            }
            id = _tznames.getReferenceZoneID(mzID, getTargetRegion())
            if (id.isNone()) {
                throw IllegalArgumentException("Invalid mzID: " + (mzID))
            }
        }
        return id
    }

    private func getTargetRegion(): String {
        synchronized (GeneratedLockObject) {
            if (_region.isNone()) {
                _region = _locale.getCountry()
                if (Int32(_region.size) == 0) {
                    let tmp = ULocale.addLikelySubtags(_locale)
                    _region = tmp.getCountry()
                    if (Int32(_region.size) == 0) {
                        _region = "001"
                    }
                }
            }
            return _region
        }
    }

    private func getTimeType(nameType: TimeZoneNames_NameType): TimeZoneFormat_TimeType {
        match (nameType) {
            case TimeZoneNames_NameType.LONG_STANDARD | TimeZoneNames_NameType.SHORT_STANDARD => return TimeZoneFormat_TimeType.STANDARD
            case TimeZoneNames_NameType.LONG_DAYLIGHT | TimeZoneNames_NameType.SHORT_DAYLIGHT => return TimeZoneFormat_TimeType.DAYLIGHT
            case _ => return TimeZoneFormat_TimeType.UNKNOWN
        }
    }

    private func initGMTPattern(gmtPattern: String): Unit {
        let idx = indexOfWrap(gmtPattern.indexOf("{0}"))
        if (idx < 0) {
            throw IllegalArgumentException("Bad localized GMT pattern: " + (gmtPattern))
        }
        _gmtPattern = gmtPattern
        _gmtPatternPrefix = unquote(gmtPattern[0..Int64(idx)])
        _gmtPatternSuffix = unquote(gmtPattern[Int64(idx + 3)..])
    }

    private static func unquote(s: String): String {
        if (indexOfWrap(s.indexOf(UInt8(UInt32(''')))) < 0) {
            return s
        }
        var isPrevQuote = false
        var inQuote = false
        let buf = StringBuilder()
        var i = 0
        while (i < Int32(s.size)) {
            let c = Char(s[Int64(i)])
            if (c == ''') {
                if (isPrevQuote) {
                    buf.append(c)
                    isPrevQuote = false
                } else {
                    isPrevQuote = true
                }
                inQuote = !inQuote
            } else {
                isPrevQuote = false
                buf.append(c)
            }
            i++
        }
        return buf.toString()
    }

    private func initGMTOffsetPatterns(gmtOffsetPatterns: Array<String>): Unit {
        let size = Int32(TimeZoneFormat_GMTOffsetPatternType.values().size)
        if (Int32(gmtOffsetPatterns.size) < size) {
            throw IllegalArgumentException("Insufficient number of elements in gmtOffsetPatterns")
        }
        let gmtOffsetPatternItems = Array<Array<Object>>(Int64(size)) { _ => Array<Object>(0) }
        for (t in TimeZoneFormat_GMTOffsetPatternType.values()) {
            let idx = t.ordinal
            let parsedItems = parseOffsetPattern(gmtOffsetPatterns[Int64(idx)], t.required())
            gmtOffsetPatternItems[Int64(idx)] = parsedItems
        }
        _gmtOffsetPatterns = Array<String>(Int64(size))
        arraycopy(gmtOffsetPatterns, 0, _gmtOffsetPatterns, 0, Int64(size))
        _gmtOffsetPatternItems = gmtOffsetPatternItems
        checkAbuttingHoursAndMinutes()
    }

    private func checkAbuttingHoursAndMinutes(): Unit {
        _abuttingOffsetHoursAndMinutes = false
        for (items in _gmtOffsetPatternItems) {
            var afterH = false
            for (item in items) {
                if (checkOptionalIs<TimeZoneFormat_GMTOffsetField, Object>(item)) {
                    let fld = item
                    if (afterH) {
                        _abuttingOffsetHoursAndMinutes = true
                    } else if (fld.getType() == 'H') {
                        afterH = true
                    }
                } else if (afterH) {
                    break
                }
            }
        }
    }

    private static func parseOffsetPattern(pattern: String, letters: String): Array<Object> {
        var isPrevQuote = false
        var inQuote = false
        let text = StringBuilder()
        var itemType = Char(0)
        var itemLength = 1
        var invalidPattern = false
        let items = ArrayList<Object>()
        let checkBits = BitSet(Int32(letters.size))
        var i = 0
        while (i < Int32(pattern.size)) {
            let ch = Char(pattern[Int64(i)])
            if (ch == ''') {
                if (isPrevQuote) {
                    text.append(''')
                    isPrevQuote = false
                } else {
                    isPrevQuote = true
                    if (Int32(UInt32(itemType)) != 0) {
                        if (TimeZoneFormat_GMTOffsetField.isValid(itemType, itemLength)) {
                            items.append(TimeZoneFormat_GMTOffsetField(itemType, itemLength))
                        } else {
                            invalidPattern = true
                            break
                        }
                        itemType = Char(0)
                    }
                }
                inQuote = !inQuote
            } else {
                isPrevQuote = false
                if (inQuote) {
                    text.append(ch)
                } else {
                    let patFieldIdx = indexOfWrap(letters.indexOf(UInt8(UInt32(ch))))
                    if (patFieldIdx >= 0) {
                        if (ch == itemType) {
                            itemLength++
                        } else {
                            if (Int32(UInt32(itemType)) == 0) {
                                if (Int32(text.size) > 0) {
                                    items.append(text.toString())
                                    text.setLength(0)
                                }
                            } else {
                                if (TimeZoneFormat_GMTOffsetField.isValid(itemType, itemLength)) {
                                    items.append(TimeZoneFormat_GMTOffsetField(itemType, itemLength))
                                } else {
                                    invalidPattern = true
                                    break
                                }
                            }
                            itemType = ch
                            itemLength = 1
                            checkBits.set(patFieldIdx)
                        }
                    } else {
                        if (Int32(UInt32(itemType)) != 0) {
                            if (TimeZoneFormat_GMTOffsetField.isValid(itemType, itemLength)) {
                                items.append(TimeZoneFormat_GMTOffsetField(itemType, itemLength))
                            } else {
                                invalidPattern = true
                                break
                            }
                            itemType = Char(0)
                        }
                        text.append(ch)
                    }
                }
            }
            i++
        }
        if (!invalidPattern) {
            if (Int32(UInt32(itemType)) == 0) {
                if (Int32(text.size) > 0) {
                    items.append(text.toString())
                    text.setLength(0)
                }
            } else {
                if (TimeZoneFormat_GMTOffsetField.isValid(itemType, itemLength)) {
                    items.append(TimeZoneFormat_GMTOffsetField(itemType, itemLength))
                } else {
                    invalidPattern = true
                }
            }
        }
        if (invalidPattern || checkBits.cardinality() != Int32(letters.size)) {
            throw Exception("Bad localized GMT offset pattern: " + (pattern))
        }
        return items.toArray(size))
    }

    private static func expandOffsetPattern(offsetHM: String): String {
        let idx_mm = indexOfWrap(offsetHM.indexOf("mm"))
        if (idx_mm < 0) {
            throw Exception("Bad time zone hour pattern data")
        }
        var sep: String = ":"
        let idx_H = indexOfWrap(offsetHM[0..Int64(idx_mm)].lastIndexOf("H"))
        if (idx_H >= 0) {
            sep = offsetHM[Int64(idx_H + 1)..Int64(idx_mm)]
        }
        return offsetHM[0..Int64(idx_mm + 2)] + (sep) + "ss" + offsetHM[Int64(idx_mm + 2)..]
    }

    private static func truncateOffsetPattern(offsetHM: String): String {
        let idx_mm = indexOfWrap(offsetHM.indexOf("mm"))
        if (idx_mm < 0) {
            throw Exception("Bad time zone hour pattern data")
        }
        let idx_HH = indexOfWrap(offsetHM[0..Int64(idx_mm)].lastIndexOf("HH"))
        if (idx_HH >= 0) {
            return offsetHM[0..Int64(idx_HH + 2)]
        }
        let idx_H = indexOfWrap(offsetHM[0..Int64(idx_mm)].lastIndexOf("H"))
        if (idx_H >= 0) {
            return offsetHM[0..Int64(idx_H + 1)]
        }
        throw Exception("Bad time zone hour pattern data")
    }

    private func appendOffsetDigits(buf: StringBuilder, n: Int32, minDigits: Int32): Unit {
        if (!(n >= 0 && n < 60)) {
            throw AssertionError()
        }
        let numDigits = if (n >= 10) { 2 } else { 1 }
        var i = 0
        while (i < minDigits - numDigits) {
            buf.append(_gmtOffsetDigits[0])
            i++
        }
        if (numDigits == 2) {
            buf.append(_gmtOffsetDigits[Int64(n / 10)])
        }
        buf.append(_gmtOffsetDigits[Int64(n % 10)])
    }

    private func getTimeZoneForOffset(offset: Int32): TimeZone {
        if (offset == 0) {
            return TimeZone.getTimeZone(TZID_GMT)
        }
        return ZoneMeta.getCustomTimeZone(offset)
    }

    private func parseOffsetLocalizedGMT(text: String, pos: ParsePosition, isShort: Bool, hasDigitOffset: Output<Bool>): Int32 {
        let start = pos.getIndex()
        var offset = 0
        let parsedLength = [0]
        if (hasDigitOffset.isSome()) {
            hasDigitOffset.value = Bool.valueOf(false)
        }
        offset = parseOffsetLocalizedGMTPattern(text, start, isShort, parsedLength)
        if (parsedLength[0] > 0) {
            if (hasDigitOffset.isSome()) {
                hasDigitOffset.value = Bool.valueOf(true)
            }
            pos.setIndex(start + parsedLength[0])
            return offset
        }
        offset = parseOffsetDefaultLocalizedGMT(text, start, parsedLength)
        if (parsedLength[0] > 0) {
            if (hasDigitOffset.isSome()) {
                hasDigitOffset.value = Bool.valueOf(true)
            }
            pos.setIndex(start + parsedLength[0])
            return offset
        }
        if (text.regionMatches(true, start, _gmtZeroFormat, 0, Int32(_gmtZeroFormat.size))) {
            pos.setIndex(start + Int32(_gmtZeroFormat.size))
            return 0
        }
        for (defGMTZero in ALT_GMT_STRINGS) {
            if (text.regionMatches(true, start, defGMTZero, 0, Int32(defGMTZero.size))) {
                pos.setIndex(start + Int32(defGMTZero.size))
                return 0
            }
        }
        pos.setErrorIndex(start)
        return 0
    }

    private func parseOffsetLocalizedGMTPattern(text: String, start: Int32, isShort: Bool, parsedLen: Array<Int32>): Int32 {
        var idx = start
        var offset = 0
        var parsed = false
            idx += len
            let offsetLen = Array<Int32>(1) { _ => 0 }
            offset = parseOffsetFields(text, idx, false, offsetLen)
            if (offsetLen[0] == 0) {
                break
            }
            idx += offsetLen[0]
            len = Int32(_gmtPatternSuffix.size)
            if (len > 0 && !text.regionMatches(true, idx, _gmtPatternSuffix, 0, len)) {
                break
            }
            idx += len
            parsed = true
        } while (false)
        parsedLen[0] = if (parsed) { idx - start } else { 0 }
        return offset
    }

    private func parseOffsetFields(text: String, start: Int32, isShort: Bool, parsedLen: Array<Int32>): Int32 {
        var outLen = 0
        var offset = 0
        var sign = 1
        if (parsedLen.isSome() && Int32(parsedLen.size) >= 1) {
            parsedLen[0] = 0
        }
        var offsetH: Int32 = 0
        var offsetM: Int32 = 0
        var offsetS: Int32 = 0
        offsetH = match (0) { case _ => offsetM = match (0) { case _ => offsetS = 0; offsetS }; offsetM }
        let fields = [0, 0, 0]
        for (gmtPatType in PARSE_GMT_OFFSET_TYPES) {
            let items: Array<Object> = _gmtOffsetPatternItems[Int64(gmtPatType.ordinal)]
            if (!items.isSome()) {
                throw AssertionError()
            }
            outLen = parseOffsetFieldsWithPattern(text, start, items, false, fields)
            if (outLen > 0) {
                sign = if (gmtPatType.isPositive()) { 1 } else { -1 }
                offsetH = fields[0]
                offsetM = fields[1]
                offsetS = fields[2]
                break
            }
        }
        if (outLen > 0 && _abuttingOffsetHoursAndMinutes) {
            var tmpLen = 0
            var tmpSign = 1
            for (gmtPatType in PARSE_GMT_OFFSET_TYPES) {
                let items: Array<Object> = _gmtOffsetPatternItems[Int64(gmtPatType.ordinal)]
                if (!items.isSome()) {
                    throw AssertionError()
                }
                tmpLen = parseOffsetFieldsWithPattern(text, start, items, true, fields)
                if (tmpLen > 0) {
                    tmpSign = if (gmtPatType.isPositive()) { 1 } else { -1 }
                    break
                }
            }
            if (tmpLen > outLen) {
                outLen = tmpLen
                sign = tmpSign
                offsetH = fields[0]
                offsetM = fields[1]
                offsetS = fields[2]
            }
        }
        if (parsedLen.isSome() && Int32(parsedLen.size) >= 1) {
            parsedLen[0] = outLen
        }
        if (outLen > 0) {
            offset = ((((offsetH * 60) + offsetM) * 60) + offsetS) * 1000 * sign
        }
        return offset
    }

    private func parseOffsetFieldsWithPattern(text: String, start: Int32, patternItems: Array<Object>, forceSingleHourDigit: Bool, fields: Array<Int32>): Int32 {
        if (!(fields.isSome() && Int32(fields.size) >= 3)) {
            throw AssertionError()
        }
        fields[0] = match (0) { case _ => fields[1] = match (0) { case _ => fields[2] = 0; fields[2] }; fields[1] }
        var failed = false
        var offsetH: Int32 = 0
        var offsetM: Int32 = 0
        var offsetS: Int32 = 0
        offsetH = match (0) { case _ => offsetM = match (0) { case _ => offsetS = 0; offsetS }; offsetM }
        var idx = start
        let tmpParsedLen = [0]
        var i = 0
        while (i < Int32(patternItems.size)) {
            if (patternItems[Int64(i)]) {
                let patStr = patternItems[Int64(i)]
                var len = Int32(patStr.size)
                var patIdx = 0
                if (i == 0) {
                    if (idx < Int32(text.size) && !PatternProps.isWhiteSpace(text.codePointAt(idx))) {
                        while (len > 0) {
                            let cp = patStr.codePointAt(patIdx)
                            if (PatternProps.isWhiteSpace(cp)) {
                                let cpLen = Character.charCount(cp)
                                len -= cpLen
                                patIdx += cpLen
                            } else {
                                break
                            }
                        }
                    }
                }
                if (!text.regionMatches(true, idx, patStr, patIdx, len)) {
                    failed = true
                    break
                }
                idx += len
            } else {
                if (!(checkOptionalIs<TimeZoneFormat_GMTOffsetField, Object>(patternItems[Int64(i)]))) {
                    throw AssertionError()
                }
                let field = patternItems[Int64(i)]
                let fieldType = field.getType()
                if (fieldType == 'H') {
                    let maxDigits = if (forceSingleHourDigit) { 1 } else { 2 }
                    offsetH = parseOffsetFieldWithLocalizedDigits(text, idx, 1, maxDigits, 0, MAX_OFFSET_HOUR, tmpParsedLen)
                } else if (fieldType == 'm') {
                    offsetM = parseOffsetFieldWithLocalizedDigits(text, idx, 2, 2, 0, MAX_OFFSET_MINUTE, tmpParsedLen)
                } else if (fieldType == 's') {
                    offsetS = parseOffsetFieldWithLocalizedDigits(text, idx, 2, 2, 0, MAX_OFFSET_SECOND, tmpParsedLen)
                }
                if (tmpParsedLen[0] == 0) {
                    failed = true
                    break
                }
                idx += tmpParsedLen[0]
            }
            i++
        }
        if (failed) {
            return 0
        }
        fields[0] = offsetH
        fields[1] = offsetM
        fields[2] = offsetS
        return idx - start
    }

    private func parseOffsetDefaultLocalizedGMT(text: String, start: Int32, parsedLen: Array<Int32>): Int32 {
        var idx = start
        var offset = 0
        var parsed = 0
            }
            if (gmtLen == 0) {
                break
            }
            idx += gmtLen
            if (idx + 1 >= Int32(text.size)) {
                break
            }
            var sign = 1
            let c = Char(text[Int64(idx)])
            if (c == '+') {
                sign = 1
            } else if (c == '-') {
                sign = -1
            } else {
                break
            }
            idx++
            let lenWithSep = [0]
            let offsetWithSep = parseDefaultOffsetFields(text, idx, DEFAULT_GMT_OFFSET_SEP, lenWithSep)
            if (lenWithSep[0] == Int32(text.size) - idx) {
                offset = offsetWithSep * sign
                idx += lenWithSep[0]
            } else {
                let lenAbut = [0]
                let offsetAbut = parseAbuttingOffsetFields(text, idx, lenAbut)
                if (lenWithSep[0] > lenAbut[0]) {
                    offset = offsetWithSep * sign
                    idx += lenWithSep[0]
                } else {
                    offset = offsetAbut * sign
                    idx += lenAbut[0]
                }
            }
            parsed = idx - start
        } while (false)
        parsedLen[0] = parsed
        return offset
    }

    private func parseDefaultOffsetFields(text: String, start: Int32, separator: Char, parsedLen: Array<Int32>): Int32 {
        let max = Int32(text.size)
        var idx = start
        let len = [0]
        var hour = 0
        var min = 0
        var sec = 0
            idx += len[0]
            if (idx + 1 < max && Char(text[Int64(idx)]) == separator) {
                min = parseOffsetFieldWithLocalizedDigits(text, idx + 1, 2, 2, 0, MAX_OFFSET_MINUTE, len)
                if (len[0] == 0) {
                    break
                }
                idx += (1 + len[0])
                if (idx + 1 < max && Char(text[Int64(idx)]) == separator) {
                    sec = parseOffsetFieldWithLocalizedDigits(text, idx + 1, 2, 2, 0, MAX_OFFSET_SECOND, len)
                    if (len[0] == 0) {
                        break
                    }
                    idx += (1 + len[0])
                }
            }
        } while (false)
        if (idx == start) {
            parsedLen[0] = 0
            return 0
        }
        parsedLen[0] = idx - start
        return hour * MILLIS_PER_HOUR + min * MILLIS_PER_MINUTE + sec * MILLIS_PER_SECOND
    }

    private func parseAbuttingOffsetFields(text: String, start: Int32, parsedLen: Array<Int32>): Int32 {
        let MAXDIGITS = 6
        let digits = Array<Int32>(Int64(MAXDIGITS)) { _ => 0 }
        let parsed = Array<Int32>(Int64(MAXDIGITS)) { _ => 0 }
        var idx = start
        let len = [0]
        var numDigits = 0
        var i = 0
        while (i < MAXDIGITS) {
            digits[Int64(i)] = parseSingleLocalizedDigit(text, idx, len)
            if (digits[Int64(i)] < 0) {
                break
            }
            idx += len[0]
            parsed[Int64(i)] = idx - start
            numDigits++
            i++
        }
        if (numDigits == 0) {
            parsedLen[0] = 0
            return 0
        }
        var offset = 0
        while (numDigits > 0) {
            var hour = 0
            var min = 0
            var sec = 0
            if (!(numDigits > 0 && numDigits <= 6)) {
                throw AssertionError()
            }
            match (numDigits) {
                case 1 => hour = digits[0]
                case 2 => hour = digits[0] * 10 + digits[1]
                case 3 =>
                    hour = digits[0]
                    min = digits[1] * 10 + digits[2]
                case 4 =>
                    hour = digits[0] * 10 + digits[1]
                    min = digits[2] * 10 + digits[3]
                case 5 =>
                    hour = digits[0]
                    min = digits[1] * 10 + digits[2]
                    sec = digits[3] * 10 + digits[4]
                case 6 =>
                    hour = digits[0] * 10 + digits[1]
                    min = digits[2] * 10 + digits[3]
                    sec = digits[4] * 10 + digits[5]
                case _ => ()
            }
            if (hour <= MAX_OFFSET_HOUR && min <= MAX_OFFSET_MINUTE && sec <= MAX_OFFSET_SECOND) {
                offset = hour * MILLIS_PER_HOUR + min * MILLIS_PER_MINUTE + sec * MILLIS_PER_SECOND
                parsedLen[0] = parsed[Int64(numDigits - 1)]
                break
            }
            numDigits--
        }
        return offset
    }

    private func parseOffsetFieldWithLocalizedDigits(text: String, start: Int32, minDigits: Int32, maxDigits: Int32, minVal: Int32, maxVal: Int32, parsedLen: Array<Int32>): Int32 {
        parsedLen[0] = 0
        var decVal = 0
        var numDigits = 0
        var idx = start
        let digitLen = [0]
        while (idx < Int32(text.size) && numDigits < maxDigits) {
            let digit = parseSingleLocalizedDigit(text, idx, digitLen)
            if (digit < 0) {
                break
            }
            let tmpVal = decVal * 10 + digit
            if (tmpVal > maxVal) {
                break
            }
            decVal = tmpVal
            numDigits++
            idx += digitLen[0]
        }
        if (numDigits < minDigits || decVal < minVal) {
            decVal = -1
            numDigits = 0
        } else {
            parsedLen[0] = idx - start
        }
        return decVal
    }

    private func parseSingleLocalizedDigit(text: String, start: Int32, len: Array<Int32>): Int32 {
        var digit = -1
        len[0] = 0
        if (start < Int32(text.size)) {
            let cp = Character.codePointAt(text, start)
            var i = 0
            while (i < Int32(_gmtOffsetDigits.size)) {
                if (cp == _gmtOffsetDigits[Int64(i)].codePointAt(0)) {
                    digit = i
                    break
                }
                i++
            }
            if (digit < 0) {
                digit = UCharacter.digit(cp)
            }
            if (digit >= 0) {
                len[0] = Character.charCount(cp)
            }
        }
        return digit
    }

    private static func toCodePoints(str: String): Array<String> {
        let len = str.codePointCount(0, Int32(str.size))
        let codePoints = Array<String>(Int64(len))
        var i = 0
        var offset = 0
        while (i < len) {
            let code = str.codePointAt(offset)
            let codeLen = Character.charCount(code)
            codePoints[Int64(i)] = str[Int64(offset)..Int64(offset + codeLen)]
            offset += codeLen
            i++
        }
        return codePoints
    }

    private static func parseOffsetISO8601Static(text: String, pos: ParsePosition, extendedOnly: Bool, hasDigitOffset: Output<Bool>): Int32 {
        if (hasDigitOffset.isSome()) {
            hasDigitOffset.value = Bool.valueOf(false)
        }
        let start = pos.getIndex()
        if (start >= Int32(text.size)) {
            pos.setErrorIndex(start)
            return 0
        }
        let firstChar = Char(text[Int64(start)])
        if (firstChar.toTitleCase() == Char(ISO8601_UTC[0])) {
            pos.setIndex(start + 1)
            return 0
        }
        let sign: Int32
        if (firstChar == '+') {
            sign = 1
        } else if (firstChar == '-') {
            sign = -1
        } else {
            pos.setErrorIndex(start)
            return 0
        }
        let posOffset = ParsePosition(start + 1)
        var offset = parseAsciiOffsetFields(text, posOffset, ':', TimeZoneFormat_OffsetFields.H, TimeZoneFormat_OffsetFields.HMS)
        if (posOffset.getErrorIndex() == -1 && !extendedOnly && (posOffset.getIndex() - start <= 3)) {
            let posBasic = ParsePosition(start + 1)
            let tmpOffset = parseAbuttingAsciiOffsetFields(text, posBasic, TimeZoneFormat_OffsetFields.H, TimeZoneFormat_OffsetFields.HMS, false)
            if (posBasic.getErrorIndex() == -1 && posBasic.getIndex() > posOffset.getIndex()) {
                offset = tmpOffset
                posOffset.setIndex(posBasic.getIndex())
            }
        }
        if (posOffset.getErrorIndex() != -1) {
            pos.setErrorIndex(start)
            return 0
        }
        pos.setIndex(posOffset.getIndex())
        if (hasDigitOffset.isSome()) {
            hasDigitOffset.value = Bool.valueOf(true)
        }
        return sign * offset
    }

    private static func parseAbuttingAsciiOffsetFields(text: String, pos: ParsePosition, minFields: TimeZoneFormat_OffsetFields, maxFields: TimeZoneFormat_OffsetFields, fixedHourWidth: Bool): Int32 {
        let start = pos.getIndex()
        let minDigits = 2 * (minFields.ordinal + 1) - (if (fixedHourWidth) { 0 } else { 1 })
        let maxDigits = 2 * (maxFields.ordinal + 1)
        let digits = Array<Int32>(Int64(maxDigits)) { _ => 0 }
        var numDigits = 0
        var idx = start
        while (numDigits < Int32(digits.size) && idx < Int32(text.size)) {
            let digit = indexOfWrap(ASCII_DIGITS.indexOf(UInt8(UInt32(Char(text[Int64(idx)])))))
            if (digit < 0) {
                break
            }
            digits[Int64(numDigits)] = digit
            numDigits++
            idx++
        }
        if (fixedHourWidth && ((numDigits & 1) != 0)) {
            numDigits--
        }
        if (numDigits < minDigits) {
            pos.setErrorIndex(start)
            return 0
        }
        var hour = 0
        var min = 0
        var sec = 0
        var bParsed = false
        while (numDigits >= minDigits) {
            match (numDigits) {
                case 1 => hour = digits[0]
                case 2 => hour = digits[0] * 10 + digits[1]
                case 3 =>
                    hour = digits[0]
                    min = digits[1] * 10 + digits[2]
                case 4 =>
                    hour = digits[0] * 10 + digits[1]
                    min = digits[2] * 10 + digits[3]
                case 5 =>
                    hour = digits[0]
                    min = digits[1] * 10 + digits[2]
                    sec = digits[3] * 10 + digits[4]
                case 6 =>
                    hour = digits[0] * 10 + digits[1]
                    min = digits[2] * 10 + digits[3]
                    sec = digits[4] * 10 + digits[5]
                case _ => ()
            }
            if (hour <= MAX_OFFSET_HOUR && min <= MAX_OFFSET_MINUTE && sec <= MAX_OFFSET_SECOND) {
                bParsed = true
                break
            }
            numDigits -= (if (fixedHourWidth) { 2 } else { 1 })
            hour = match (0) { case _ => min = match (0) { case _ => sec = 0; sec }; min }
        }
        if (!bParsed) {
            pos.setErrorIndex(start)
            return 0
        }
        pos.setIndex(start + numDigits)
        return ((((hour * 60) + min) * 60) + sec) * 1000
    }

    private static func parseAsciiOffsetFields(text: String, pos: ParsePosition, sep: Char, minFields: TimeZoneFormat_OffsetFields, maxFields: TimeZoneFormat_OffsetFields): Int32 {
        let start = pos.getIndex()
        let fieldVal = [0, 0, 0]
        let fieldLen = [0, -1, -1]
        var idx = start
        var fieldIdx = 0
        while (idx < Int32(text.size) && fieldIdx <= maxFields.ordinal) {
            let c = Char(text[Int64(idx)])
            if (c == sep) {
                if (fieldIdx == 0) {
                    if (fieldLen[0] == 0) {
                        break
                    }
                    fieldIdx++
                } else {
                    if (fieldLen[Int64(fieldIdx)] != -1) {
                        break
                    }
                    fieldLen[Int64(fieldIdx)] = 0
                }
                continue
            } else if (fieldLen[Int64(fieldIdx)] == -1) {
                break
            }
            let digit = indexOfWrap(ASCII_DIGITS.indexOf(UInt8(UInt32(c))))
            if (digit < 0) {
                break
            }
            fieldVal[Int64(fieldIdx)] = fieldVal[Int64(fieldIdx)] * 10 + digit
            fieldLen[Int64(fieldIdx)] += 1
            if (fieldLen[Int64(fieldIdx)] >= 2) {
                fieldIdx++
            }
            idx++
        }
        var offset = 0
        var parsedLen = 0
        var parsedFields: TimeZoneFormat_OffsetFields
            if (fieldVal[0] > MAX_OFFSET_HOUR) {
                offset = (fieldVal[0] / 10) * MILLIS_PER_HOUR
                parsedFields = TimeZoneFormat_OffsetFields.H
                parsedLen = 1
                break
            }
            offset = fieldVal[0] * MILLIS_PER_HOUR
            parsedLen = fieldLen[0]
            parsedFields = TimeZoneFormat_OffsetFields.H
            if (fieldLen[1] != 2 || fieldVal[1] > MAX_OFFSET_MINUTE) {
                break
            }
            offset += fieldVal[1] * MILLIS_PER_MINUTE
            parsedLen += (1 + fieldLen[1])
            parsedFields = TimeZoneFormat_OffsetFields.HM
            if (fieldLen[2] != 2 || fieldVal[2] > MAX_OFFSET_SECOND) {
                break
            }
            offset += fieldVal[2] * MILLIS_PER_SECOND
            parsedLen += (1 + fieldLen[2])
            parsedFields = TimeZoneFormat_OffsetFields.HMS
        } while (false)
        if (parsedFields.isNone() || parsedFields.ordinal < minFields.ordinal) {
            pos.setErrorIndex(start)
            return 0
        }
        pos.setIndex(start + parsedLen)
        return offset
    }

    private static func parseZoneID(text: String, pos: ParsePosition): String {
        var resolvedID: String
        if (ZONE_ID_TRIE.isNone()) {
            synchronized (getMonitorByObject(TypeInfo.of<TimeZoneFormat>())) {
                if (ZONE_ID_TRIE.isNone()) {
                    let trie = TextTrieMap<String>(true)
                    let ids = TimeZone.getAvailableIDs()
                    for (id in ids) {
                        trie.put(id, id)
                    }
                    ZONE_ID_TRIE = trie
                }
            }
        }
        let trieOutput = TextTrieMap_Output()
        let itr = ZONE_ID_TRIE.get(text, pos.getIndex(), trieOutput)
        if (itr.isSome()) {
            resolvedID = itr.next()
            pos.setIndex(pos.getIndex() + trieOutput.matchLength)
        } else {
            pos.setErrorIndex(pos.getIndex())
        }
        return resolvedID
    }

    private static func parseShortZoneID(text: String, pos: ParsePosition): String {
        var resolvedID: String
        if (SHORT_ZONE_ID_TRIE.isNone()) {
            synchronized (getMonitorByObject(TypeInfo.of<TimeZoneFormat>())) {
                if (SHORT_ZONE_ID_TRIE.isNone()) {
                    let trie = TextTrieMap<String>(true)
                    let canonicalIDs = TimeZone.getAvailableIDs(TimeZone_SystemTimeZoneType.CANONICAL, None, None)
                    for (id in canonicalIDs) {
                        let shortID = ZoneMeta.getShortID(id)
                        if (shortID.isSome()) {
                            trie.put(shortID, id)
                        }
                    }
                    trie.put(UNKNOWN_SHORT_ZONE_ID, UNKNOWN_ZONE_ID)
                    SHORT_ZONE_ID_TRIE = trie
                }
            }
        }
        let trieOutput = TextTrieMap_Output()
        let itr = SHORT_ZONE_ID_TRIE.get(text, pos.getIndex(), trieOutput)
        if (itr.isSome()) {
            resolvedID = itr.next()
            pos.setIndex(pos.getIndex() + trieOutput.matchLength)
        } else {
            pos.setErrorIndex(pos.getIndex())
        }
        return resolvedID
    }

    private func parseExemplarLocation(text: String, pos: ParsePosition): String {
        let startIdx = pos.getIndex()
        var parsedPos = -1
        var tzID: String
        let nameTypes = EnumSet.of(TimeZoneNames_NameType.EXEMPLAR_LOCATION)
        let exemplarMatches = _tznames.find(text, startIdx, nameTypes)
        if (exemplarMatches.isSome()) {
            var exemplarMatch: TimeZoneNames_MatchInfo
            for (match in exemplarMatches) {
                if (startIdx + match.matchLength() > parsedPos) {
                    exemplarMatch = match
                    parsedPos = startIdx + match.matchLength()
                }
            }
            if (exemplarMatch.isSome()) {
                tzID = getTimeZoneID(exemplarMatch.tzID(), exemplarMatch.mzID())
                pos.setIndex(parsedPos)
            }
        }
        if (tzID.isNone()) {
            pos.setErrorIndex(startIdx)
        }
        return tzID
    }

    private static let serialPersistentFields: Array<ObjectStreamField> = [ObjectStreamField("_locale", TypeInfo.of<ULocale>() as ClassTypeInfo), ObjectStreamField("_tznames", TypeInfo.of<TimeZoneNames>() as ClassTypeInfo), ObjectStreamField("_gmtPattern", TypeInfo.of<String>() as ClassTypeInfo), ObjectStreamField("_gmtOffsetPatterns", TypeInfo.of<Array<String>>() as ClassTypeInfo), ObjectStreamField("_gmtOffsetDigits", TypeInfo.of<Array<String>>() as ClassTypeInfo), ObjectStreamField("_gmtZeroFormat", TypeInfo.of<String>() as ClassTypeInfo), ObjectStreamField("_parseAllStyles", Bool.TYPE)]

    private func writeObject(oos: ObjectOutputStream): Unit {
        let fields = oos.putFields()
        fields.put("_locale", _locale)
        fields.put("_tznames", _tznames)
        fields.put("_gmtPattern", _gmtPattern)
        fields.put("_gmtOffsetPatterns", _gmtOffsetPatterns)
        fields.put("_gmtOffsetDigits", _gmtOffsetDigits)
        fields.put("_gmtZeroFormat", _gmtZeroFormat)
        fields.put("_parseAllStyles", _parseAllStyles)
        oos.writeFields()
    }

    private func readObject(ois: ObjectInputStream): Unit {
        let fields = ois.readFields()
        _locale = fields.get("_locale", None)
        if (_locale.isNone()) {
            throw InvalidObjectException("Missing field: locale")
        }
        _tznames = fields.get("_tznames", None)
        if (_tznames.isNone()) {
            throw InvalidObjectException("Missing field: tznames")
        }
        _gmtPattern = fields.get("_gmtPattern", None)
        if (_gmtPattern.isNone()) {
            throw InvalidObjectException("Missing field: gmtPattern")
        }
        let tmpGmtOffsetPatterns = fields.get("_gmtOffsetPatterns", None)
        if (tmpGmtOffsetPatterns.isNone()) {
            throw InvalidObjectException("Missing field: gmtOffsetPatterns")
        } else if (Int32(tmpGmtOffsetPatterns.size) < 4) {
            throw InvalidObjectException("Incompatible field: gmtOffsetPatterns")
        }
        _gmtOffsetPatterns = Array<String>(6)
        if (Int32(tmpGmtOffsetPatterns.size) == 4) {
            var i = 0
            while (i < 4) {
                _gmtOffsetPatterns[Int64(i)] = tmpGmtOffsetPatterns[Int64(i)]
                i++
            }
            _gmtOffsetPatterns[Int64(TimeZoneFormat_GMTOffsetPatternType.POSITIVE_H.ordinal)] = truncateOffsetPattern(_gmtOffsetPatterns[Int64(TimeZoneFormat_GMTOffsetPatternType.POSITIVE_HM.ordinal)])
            _gmtOffsetPatterns[Int64(TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_H.ordinal)] = truncateOffsetPattern(_gmtOffsetPatterns[Int64(TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_HM.ordinal)])
        } else {
            _gmtOffsetPatterns = tmpGmtOffsetPatterns
        }
        _gmtOffsetDigits = fields.get("_gmtOffsetDigits", None)
        if (_gmtOffsetDigits.isNone()) {
            throw InvalidObjectException("Missing field: gmtOffsetDigits")
        } else if (Int32(_gmtOffsetDigits.size) != 10) {
            throw InvalidObjectException("Incompatible field: gmtOffsetDigits")
        }
        _gmtZeroFormat = fields.get("_gmtZeroFormat", None)
        if (_gmtZeroFormat.isNone()) {
            throw InvalidObjectException("Missing field: gmtZeroFormat")
        }
        _parseAllStyles = fields.get("_parseAllStyles", false)
        if (fields.defaulted("_parseAllStyles")) {
            throw InvalidObjectException("Missing field: parseAllStyles")
        }
        if (checkOptionalIs<TimeZoneNamesImpl, TimeZoneNames>(_tznames)) {
            _tznames = TimeZoneNames.getInstance(_locale)
            _gnames = None
        } else {
            _gnames = TimeZoneGenericNames(_locale, _tznames)
        }
        initGMTPattern(_gmtPattern)
        initGMTOffsetPatterns(_gmtOffsetPatterns)
    }

    public override func isFrozen(): Bool {
        return _frozen
    }

    public override func freeze(): TimeZoneFormat {
        _frozen = true
        return this
    }

    public override func cloneAsThawed(): TimeZoneFormat {
        let copy = super.clone()
        copy._frozen = false
        return copy
    }
}


public class TimeZoneFormat_Style <: Enum<TimeZoneFormat_Style> {
    public static let GENERIC_LOCATION = TimeZoneFormat_Style("GENERIC_LOCATION", 0, 1)

    public static let GENERIC_LONG = TimeZoneFormat_Style("GENERIC_LONG", 1, 2)

    public static let GENERIC_SHORT = TimeZoneFormat_Style("GENERIC_SHORT", 2, 4)

    public static let SPECIFIC_LONG = TimeZoneFormat_Style("SPECIFIC_LONG", 3, 8)

    public static let SPECIFIC_SHORT = TimeZoneFormat_Style("SPECIFIC_SHORT", 4, 16)

    public static let LOCALIZED_GMT = TimeZoneFormat_Style("LOCALIZED_GMT", 5, 32)

    public static let LOCALIZED_GMT_SHORT = TimeZoneFormat_Style("LOCALIZED_GMT_SHORT", 6, 64)

    public static let ISO_BASIC_SHORT = TimeZoneFormat_Style("ISO_BASIC_SHORT", 7, TimeZoneFormat.ISO_Z_STYLE_FLAG)

    public static let ISO_BASIC_LOCAL_SHORT = TimeZoneFormat_Style("ISO_BASIC_LOCAL_SHORT", 8, TimeZoneFormat.ISO_LOCAL_STYLE_FLAG)

    public static let ISO_BASIC_FIXED = TimeZoneFormat_Style("ISO_BASIC_FIXED", 9, TimeZoneFormat.ISO_Z_STYLE_FLAG)

    public static let ISO_BASIC_LOCAL_FIXED = TimeZoneFormat_Style("ISO_BASIC_LOCAL_FIXED", 10, TimeZoneFormat.ISO_LOCAL_STYLE_FLAG)

    public static let ISO_BASIC_FULL = TimeZoneFormat_Style("ISO_BASIC_FULL", 11, TimeZoneFormat.ISO_Z_STYLE_FLAG)

    public static let ISO_BASIC_LOCAL_FULL = TimeZoneFormat_Style("ISO_BASIC_LOCAL_FULL", 12, TimeZoneFormat.ISO_LOCAL_STYLE_FLAG)

    public static let ISO_EXTENDED_FIXED = TimeZoneFormat_Style("ISO_EXTENDED_FIXED", 13, TimeZoneFormat.ISO_Z_STYLE_FLAG)

    public static let ISO_EXTENDED_LOCAL_FIXED = TimeZoneFormat_Style("ISO_EXTENDED_LOCAL_FIXED", 14, TimeZoneFormat.ISO_LOCAL_STYLE_FLAG)

    public static let ISO_EXTENDED_FULL = TimeZoneFormat_Style("ISO_EXTENDED_FULL", 15, TimeZoneFormat.ISO_Z_STYLE_FLAG)

    public static let ISO_EXTENDED_LOCAL_FULL = TimeZoneFormat_Style("ISO_EXTENDED_LOCAL_FULL", 16, TimeZoneFormat.ISO_LOCAL_STYLE_FLAG)

    public static let ZONE_ID = TimeZoneFormat_Style("ZONE_ID", 17, 512)

    public static let ZONE_ID_SHORT = TimeZoneFormat_Style("ZONE_ID_SHORT", 18, 1024)

    public static let EXEMPLAR_LOCATION = TimeZoneFormat_Style("EXEMPLAR_LOCATION", 19, 2048)

    private static func _values(): Array<TimeZoneFormat_Style> {
        return [TimeZoneFormat_Style.GENERIC_LOCATION, TimeZoneFormat_Style.GENERIC_LONG, TimeZoneFormat_Style.GENERIC_SHORT, TimeZoneFormat_Style.SPECIFIC_LONG, TimeZoneFormat_Style.SPECIFIC_SHORT, TimeZoneFormat_Style.LOCALIZED_GMT, TimeZoneFormat_Style.LOCALIZED_GMT_SHORT, TimeZoneFormat_Style.ISO_BASIC_SHORT, TimeZoneFormat_Style.ISO_BASIC_LOCAL_SHORT, TimeZoneFormat_Style.ISO_BASIC_FIXED, TimeZoneFormat_Style.ISO_BASIC_LOCAL_FIXED, TimeZoneFormat_Style.ISO_BASIC_FULL, TimeZoneFormat_Style.ISO_BASIC_LOCAL_FULL, TimeZoneFormat_Style.ISO_EXTENDED_FIXED, TimeZoneFormat_Style.ISO_EXTENDED_LOCAL_FIXED, TimeZoneFormat_Style.ISO_EXTENDED_FULL, TimeZoneFormat_Style.ISO_EXTENDED_LOCAL_FULL, TimeZoneFormat_Style.ZONE_ID, TimeZoneFormat_Style.ZONE_ID_SHORT, TimeZoneFormat_Style.EXEMPLAR_LOCATION]
    }

    private static let _VALUES = TimeZoneFormat_Style._values()

    public static func values(): Array<TimeZoneFormat_Style> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): TimeZoneFormat_Style {
        return (TypeInfo.of<TimeZoneFormat_Style>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as TimeZoneFormat_Style
    }

    let flag: Int32

    private init(_enum_name: String, _enum_ordinal: Int32, flag: Int32) {
        super(_enum_name, _enum_ordinal)
        this.flag = flag
    }
}


public class TimeZoneFormat_GMTOffsetPatternType <: Enum<TimeZoneFormat_GMTOffsetPatternType> {
    public static let POSITIVE_HM = TimeZoneFormat_GMTOffsetPatternType("POSITIVE_HM", 0, "+H:mm", "Hm", true)

    public static let POSITIVE_HMS = TimeZoneFormat_GMTOffsetPatternType("POSITIVE_HMS", 1, "+H:mm:ss", "Hms", true)

    public static let NEGATIVE_HM = TimeZoneFormat_GMTOffsetPatternType("NEGATIVE_HM", 2, "-H:mm", "Hm", false)

    public static let NEGATIVE_HMS = TimeZoneFormat_GMTOffsetPatternType("NEGATIVE_HMS", 3, "-H:mm:ss", "Hms", false)

    public static let POSITIVE_H = TimeZoneFormat_GMTOffsetPatternType("POSITIVE_H", 4, "+H", "H", true)

    public static let NEGATIVE_H = TimeZoneFormat_GMTOffsetPatternType("NEGATIVE_H", 5, "-H", "H", false)

    private static func _values(): Array<TimeZoneFormat_GMTOffsetPatternType> {
        return [TimeZoneFormat_GMTOffsetPatternType.POSITIVE_HM, TimeZoneFormat_GMTOffsetPatternType.POSITIVE_HMS, TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_HM, TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_HMS, TimeZoneFormat_GMTOffsetPatternType.POSITIVE_H, TimeZoneFormat_GMTOffsetPatternType.NEGATIVE_H]
    }

    private static let _VALUES = TimeZoneFormat_GMTOffsetPatternType._values()

    public static func values(): Array<TimeZoneFormat_GMTOffsetPatternType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): TimeZoneFormat_GMTOffsetPatternType {
        return (TypeInfo.of<TimeZoneFormat_GMTOffsetPatternType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as TimeZoneFormat_GMTOffsetPatternType
    }

    private var _defaultPattern: String

    private var _required: String

    private var _isPositive: Bool = false

    private init(_enum_name: String, _enum_ordinal: Int32, defaultPattern: String, required: String, isPositive: Bool) {
        super(_enum_name, _enum_ordinal)
        _defaultPattern = defaultPattern
        _required = required
        _isPositive = isPositive
    }

    public func defaultPattern(): String {
        return _defaultPattern
    }

    public func required(): String {
        return _required
    }

    public func isPositive(): Bool {
        return _isPositive
    }
}


public class TimeZoneFormat_TimeType <: Enum<TimeZoneFormat_TimeType> {
    public static let UNKNOWN = TimeZoneFormat_TimeType("UNKNOWN", 0)

    public static let STANDARD = TimeZoneFormat_TimeType("STANDARD", 1)

    public static let DAYLIGHT = TimeZoneFormat_TimeType("DAYLIGHT", 2)

    private static func _values(): Array<TimeZoneFormat_TimeType> {
        return [TimeZoneFormat_TimeType.UNKNOWN, TimeZoneFormat_TimeType.STANDARD, TimeZoneFormat_TimeType.DAYLIGHT]
    }

    private static let _VALUES = TimeZoneFormat_TimeType._values()

    public static func values(): Array<TimeZoneFormat_TimeType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): TimeZoneFormat_TimeType {
        return (TypeInfo.of<TimeZoneFormat_TimeType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as TimeZoneFormat_TimeType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class TimeZoneFormat_ParseOption <: Enum<TimeZoneFormat_ParseOption> {
    public static let ALL_STYLES = TimeZoneFormat_ParseOption("ALL_STYLES", 0)

    public static let TZ_DATABASE_ABBREVIATIONS = TimeZoneFormat_ParseOption("TZ_DATABASE_ABBREVIATIONS", 1)

    private static func _values(): Array<TimeZoneFormat_ParseOption> {
        return [TimeZoneFormat_ParseOption.ALL_STYLES, TimeZoneFormat_ParseOption.TZ_DATABASE_ABBREVIATIONS]
    }

    private static let _VALUES = TimeZoneFormat_ParseOption._values()

    public static func values(): Array<TimeZoneFormat_ParseOption> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): TimeZoneFormat_ParseOption {
        return (TypeInfo.of<TimeZoneFormat_ParseOption>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as TimeZoneFormat_ParseOption
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class TimeZoneFormat_OffsetFields <: Enum<TimeZoneFormat_OffsetFields> {
    public static let H = TimeZoneFormat_OffsetFields("H", 0)

    public static let HM = TimeZoneFormat_OffsetFields("HM", 1)

    public static let HMS = TimeZoneFormat_OffsetFields("HMS", 2)

    private static func _values(): Array<TimeZoneFormat_OffsetFields> {
        return [TimeZoneFormat_OffsetFields.H, TimeZoneFormat_OffsetFields.HM, TimeZoneFormat_OffsetFields.HMS]
    }

    private static let _VALUES = TimeZoneFormat_OffsetFields._values()

    public static func values(): Array<TimeZoneFormat_OffsetFields> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): TimeZoneFormat_OffsetFields {
        return (TypeInfo.of<TimeZoneFormat_OffsetFields>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as TimeZoneFormat_OffsetFields
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class TimeZoneFormat_GMTOffsetField {
    let _type: Char

    let _width: Int32

    init(Type: Char, width: Int32) {
        _type = Type
        _width = width
    }

    public func getType(): Char {
        return _type
    }

    public func getWidth(): Int32 {
        return _width
    }

    static func isValid(Type: Char, width: Int32): Bool {
        return (width == 1 || width == 2)
    }
}


class TimeZoneFormat_TimeZoneFormatCache <: SoftCache<ULocale, TimeZoneFormat, ULocale> {
    init() {
        super()
    }

    override protected func createInstance(key: ULocale, data: ULocale): TimeZoneFormat {
        let fmt = TimeZoneFormat(data)
        fmt.freeze()
        return fmt
    }
}
