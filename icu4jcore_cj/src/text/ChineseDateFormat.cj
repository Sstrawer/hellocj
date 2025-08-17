package icu4cj.text


public class ChineseDateFormat <: SimpleDateFormat {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    static let serialVersionUID = -4610300753104099899

    
    public init(pattern: String, locale: Locale) {
        this(pattern, ULocale.forLocale(locale))
    }

    
    public init(pattern: String, locale: ULocale) {
        this(pattern, None, locale)
    }

    
    public init(pattern: String, override: String, locale: ULocale) {
        super(pattern, ChineseDateFormatSymbols(locale), ChineseCalendar(TimeZone.getDefault(), locale), locale, true, override)
    }

    
    override protected func subFormat(buf: StringBuffer, ch: Char, count: Int32, beginOffset: Int32, fieldNum: Int32, capitalizationContext: DisplayContext, pos: FieldPosition, patternCharToOutput: Char, cal: Calendar): Unit {
        super.subFormat(buf, ch, count, beginOffset, fieldNum, capitalizationContext, pos, patternCharToOutput, cal)
    }

    
    override protected func subParse(text: String, start: Int32, ch: Char, count: Int32, obeyCount: Bool, allowNegative: Bool, ambiguousYear: Array<Bool>, cal: Calendar): Int32 {
        return super.subParse(text, start, ch, count, obeyCount, allowNegative, ambiguousYear, cal)
    }

    
    override protected func patternCharToDateFormatField(ch: Char): DateFormat_Field {
        return super.patternCharToDateFormatField(ch)
    }
}



public class ChineseDateFormat_Field <: DateFormat_Field {
    private static let serialVersionUID = -5102130532751400330

    
    public static let IS_LEAP_MONTH = ChineseDateFormat_Field("is leap month", ChineseCalendar.IS_LEAP_MONTH)

    
    protected init(name: String, calendarField: Int32) {
        super(name, calendarField)
    }

    
    public static func ofCalendarField(calendarField: Int32): DateFormat_Field {
        if (calendarField == ChineseCalendar.IS_LEAP_MONTH) {
            return IS_LEAP_MONTH
        }
        return DateFormat_Field.ofCalendarField(calendarField)
    }

    
    override protected func readResolve(): Object {
        if (!refEq(TypeInfo.of(this), TypeInfo.of<ChineseDateFormat_Field>())) {
            throw InvalidObjectException("A subclass of ChineseDateFormat.Field must implement readResolve.")
        }
        if (this.getName().equals(IS_LEAP_MONTH.getName())) {
            return IS_LEAP_MONTH
        } else {
            throw InvalidObjectException("Unknown attribute name.")
        }
    }
}
