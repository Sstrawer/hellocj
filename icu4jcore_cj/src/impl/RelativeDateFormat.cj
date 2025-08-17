package icu4cj.impl


public class RelativeDateFormat <: DateFormat & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    public init(timeStyle: Int32, dateStyle: Int32, locale: ULocale, cal: Calendar) {
        super()
        calendar = cal
        fLocale = locale
        fTimeStyle = timeStyle
        fDateStyle = dateStyle
        if (fDateStyle != DateFormat.NONE) {
            var newStyle = fDateStyle & 
            var df = DateFormat.getDateInstance(newStyle, locale)
            if (checkOptionalIs<SimpleDateFormat, DateFormat>(df)) {
                fDateTimeFormat = df
            } else {
                throw IllegalArgumentException("Can't create SimpleDateFormat for date style")
            }
            fDatePattern = fDateTimeFormat.toPattern()
            if (fTimeStyle != DateFormat.NONE) {
                newStyle = fTimeStyle & 
                df = DateFormat.getTimeInstance(newStyle, locale)
                if (checkOptionalIs<SimpleDateFormat, DateFormat>(df)) {
                    fTimePattern = df.toPattern()
                }
            }
        } else {
            let newStyle = fTimeStyle & 
            let df = DateFormat.getTimeInstance(newStyle, locale)
            if (checkOptionalIs<SimpleDateFormat, DateFormat>(df)) {
                fDateTimeFormat = df
            } else {
                throw IllegalArgumentException("Can't create SimpleDateFormat for time style")
            }
            fTimePattern = fDateTimeFormat.toPattern()
        }
        initializeCalendar(None, fLocale)
        loadDates()
        initializeCombinedFormat(calendar, fLocale)
    }

    private static let serialVersionUID = 1131984966440549435

    public override func format(cal: Calendar, toAppendTo: StringBuffer, fieldPosition: FieldPosition): StringBuffer {
        var relativeDayString: String
        let capitalizationContext = getContext(DisplayContext_Type.CAPITALIZATION)
        if (fDateStyle != DateFormat.NONE) {
            let dayDiff = dayDifference(cal)
            relativeDayString = getStringForDay(dayDiff)
        }
        if (fDateTimeFormat.isSome()) {
            if (relativeDayString.isSome() && fDatePattern.isSome() && (fTimePattern.isNone() || fCombinedFormat.isNone() || combinedFormatHasDateAtStart)) {
                if (Int32(relativeDayString.size) > 0 && UCharacter.isLowerCase(relativeDayString.codePointAt(0)) && (refEq(capitalizationContext, DisplayContext.CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE) || (refEq(capitalizationContext, DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU) && capitalizationOfRelativeUnitsForListOrMenu) || (refEq(capitalizationContext, DisplayContext.CAPITALIZATION_FOR_STANDALONE) && capitalizationOfRelativeUnitsForStandAlone))) {
                    if (capitalizationBrkIter.isNone()) {
                        capitalizationBrkIter = BreakIterator.getSentenceInstance(fLocale)
                    }
                    relativeDayString = UCharacter.toTitleCase(fLocale, relativeDayString, capitalizationBrkIter, UCharacter.TITLECASE_NO_LOWERCASE | UCharacter.TITLECASE_NO_BREAK_ADJUSTMENT)
                }
                fDateTimeFormat.setContext(DisplayContext.CAPITALIZATION_NONE)
            } else {
                fDateTimeFormat.setContext(capitalizationContext)
            }
        }
        if (fDateTimeFormat.isSome() && (fDatePattern.isSome() || fTimePattern.isSome())) {
            if (fDatePattern.isNone()) {
                fDateTimeFormat.applyPattern(fTimePattern)
                fDateTimeFormat.format(cal, toAppendTo, fieldPosition)
            } else if (fTimePattern.isNone()) {
                if (relativeDayString.isSome()) {
                    toAppendTo.append(relativeDayString)
                } else {
                    fDateTimeFormat.applyPattern(fDatePattern)
                    fDateTimeFormat.format(cal, toAppendTo, fieldPosition)
                }
            } else {
                var datePattern = fDatePattern
                if (relativeDayString.isSome()) {
                    datePattern = "'" + relativeDayString.replace("'", "''") + "'"
                }
                let combinedPattern = StringBuffer("")
                fCombinedFormat.format([fTimePattern, datePattern], combinedPattern, FieldPosition(0))
                fDateTimeFormat.applyPattern(toString(combinedPattern))
                fDateTimeFormat.format(cal, toAppendTo, fieldPosition)
            }
        } else if (fDateFormat.isSome()) {
            if (relativeDayString.isSome()) {
                toAppendTo.append(relativeDayString)
            } else {
                fDateFormat.format(cal, toAppendTo, fieldPosition)
            }
        }
        return toAppendTo
    }

    public override func parse(text: String, cal: Calendar, pos: ParsePosition): Unit {
        throw UnsupportedOperationException("Relative Date parse is not implemented yet")
    }

    public override func setContext(context: DisplayContext): Unit {
        super.setContext(context)
        if (!capitalizationInfoIsSet && (refEq(context, DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU) || refEq(context, DisplayContext.CAPITALIZATION_FOR_STANDALONE))) {
            initCapitalizationContextInfo(fLocale)
            capitalizationInfoIsSet = true
        }
        if (capitalizationBrkIter.isNone() && (refEq(context, DisplayContext.CAPITALIZATION_FOR_BEGINNING_OF_SENTENCE) || (refEq(context, DisplayContext.CAPITALIZATION_FOR_UI_LIST_OR_MENU) && capitalizationOfRelativeUnitsForListOrMenu) || (refEq(context, DisplayContext.CAPITALIZATION_FOR_STANDALONE) && capitalizationOfRelativeUnitsForStandAlone))) {
            capitalizationBrkIter = BreakIterator.getSentenceInstance(fLocale)
        }
    }

    private var fDateFormat: DateFormat

    private var fTimeFormat: DateFormat

    private var fCombinedFormat: MessageFormat

    private var fDateTimeFormat: SimpleDateFormat

    private var fDatePattern: String

    private var fTimePattern: String

    var fDateStyle: Int32 = 0

    var fTimeStyle: Int32 = 0

    var fLocale: ULocale

     var fDates: ArrayList<RelativeDateFormat_URelativeString>

    private var combinedFormatHasDateAtStart = false

    private var capitalizationInfoIsSet = false

    private var capitalizationOfRelativeUnitsForListOrMenu = false

    private var capitalizationOfRelativeUnitsForStandAlone = false

     private var capitalizationBrkIter: BreakIterator

    public func getStringForDay(day: Int32): String {
        if (fDates.isNone()) {
            loadDates()
        }
        for (dayItem in fDates) {
            if (dayItem.offset == day) {
                return dayItem.string
            }
        }
        return None
    }

    private func loadDates(): Unit {
        synchronized (GeneratedLockObject) {
            let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, fLocale)
            fDates = ArrayList<RelativeDateFormat_URelativeString>()
            let sink = RelativeDateFormat_RelDateFmtDataSink(this)
            rb.getAllItemsWithFallback("fields/day/relative", sink)
        }
    }

    private func initCapitalizationContextInfo(locale: ULocale): Unit {
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, locale)
        try {
            let rdb = rb.getWithFallback("contextTransforms/relative")
            let intVector = rdb.getIntVector()
            if (Int32(intVector.size) >= 2) {
                capitalizationOfRelativeUnitsForListOrMenu = (intVector[0] != 0)
                capitalizationOfRelativeUnitsForStandAlone = (intVector[1] != 0)
            }
        } catch (e: MissingResourceException) { }
    }

    private static func dayDifference(until: Calendar): Int32 {
        let nowCal = until.clone()
        let nowDate = Date(DateTime.now().toUnixTimeStamp().toMilliseconds())
        nowCal.clear()
        nowCal.setTime(nowDate)
        let dayDiff = until.get(Calendar.JULIAN_DAY) - nowCal.get(Calendar.JULIAN_DAY)
        return dayDiff
    }

    private func initializeCalendar(zone: TimeZone, locale: ULocale): Calendar {
        if (calendar.isNone()) {
            if (zone.isNone()) {
                calendar = Calendar.getInstance(locale)
            } else {
                calendar = Calendar.getInstance(zone, locale)
            }
        }
        return calendar
    }

    private func initializeCombinedFormat(cal: Calendar, locale: ULocale): MessageFormat {
        let pattern: String
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, locale)
        let resourcePath: String = "calendar/" + (cal.getType()) + "/DateTimePatterns"
        var patternsRb = rb.findWithFallback(resourcePath)
        if (patternsRb.isNone() && !(cal.getType() == "gregorian")) {
            patternsRb = rb.findWithFallback("calendar/gregorian/DateTimePatterns")
        }
        if (patternsRb.isNone() || patternsRb.getSize() < 9) {
            pattern = "{1} {0}"
        } else {
            var glueIndex = 8
            if (patternsRb.getSize() >= 13) {
                if (fDateStyle >= DateFormat.FULL && fDateStyle <= DateFormat.SHORT) {
                    glueIndex += fDateStyle + 1
                } else if (fDateStyle >= DateFormat.RELATIVE_FULL && fDateStyle <= DateFormat.RELATIVE_SHORT) {
                    glueIndex += fDateStyle + 1 - DateFormat.RELATIVE
                }
            }
            let elementType = patternsRb.get(glueIndex).getType()
            if (elementType == UResourceBundle.ARRAY) {
                pattern = patternsRb.get(glueIndex).getString(0)
            } else {
                pattern = patternsRb.getString(glueIndex)
            }
        }
        combinedFormatHasDateAtStart = pattern.startsWith("{1}")
        fCombinedFormat = MessageFormat(pattern, locale)
        return fCombinedFormat
    }
}


public class RelativeDateFormat_URelativeString {
    init(offset: Int32, string: String) {
        this.offset = offset
        this.string = string
    }

    init(offset: String, string: String) {
        this.offset = parse<Int32>(offset)
        this.string = string
    }

    public var offset: Int32 = 0

    public var string: String
}


class RelativeDateFormat_RelDateFmtDataSink <: UResource_Sink {
    let this_0: RelativeDateFormat

    init(this_0: RelativeDateFormat) {
        super()
        this.this_0 = this_0
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        if (value.getType() == ICUResourceBundle.ALIAS) {
            return
        }
        let table = value.getTable()
        var i = 0
        while (table.getKeyAndValue(i, key, value)) {
            let keyOffset: Int32
            try {
                keyOffset = parse<Int32>(key.toString())
            } catch (nfe: TimeParseException) {
                return
            }
            if (this_0.getStringForDay(keyOffset).isNone()) {
                let newDayInfo = RelativeDateFormat_URelativeString(keyOffset, value.getString())
                this_0.fDates.append(newDayInfo)
            }
            i++
        }
    }
}
