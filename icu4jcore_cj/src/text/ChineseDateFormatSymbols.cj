package icu4cj.text



public class ChineseDateFormatSymbols <: DateFormatSymbols {
    static let serialVersionUID = 6827816119783952890

    var isLeapMonth: Array<String>

    
    public init() {
        this(ULocale.getDefault(ULocale_Category.FORMAT))
    }

    
    public init(locale: Locale) {
        super(TypeInfo.of<ChineseCalendar>() as ClassTypeInfo, ULocale.forLocale(locale))
    }

    
    public init(locale: ULocale) {
        super(TypeInfo.of<ChineseCalendar>() as ClassTypeInfo, locale)
    }

    
    public init(cal: Calendar, locale: Locale) {
        super(TypeInfo.of(cal), locale)
    }

    
    public init(cal: Calendar, locale: ULocale) {
        super(TypeInfo.of(cal), locale)
    }

    
    public func getLeapMonth(leap: Int32): String {
        return isLeapMonth[Int64(leap)]
    }

    
    override protected func initializeData(loc: ULocale, b: ICUResourceBundle, calendarType: String): Unit {
        super.initializeData(loc, b, calendarType)
        initializeIsLeapMonth()
    }

    public override func initializeData(dfs: DateFormatSymbols): Unit {
        super.initializeData(dfs)
        if (checkOptionalIs<ChineseDateFormatSymbols, DateFormatSymbols>(dfs)) {
            this.isLeapMonth = dfs.isLeapMonth
        } else {
            initializeIsLeapMonth()
        }
    }

    private func initializeIsLeapMonth(): Unit {
        isLeapMonth = Array<String>(2)
        isLeapMonth[0] = ""
        isLeapMonth[1] = if (leapMonthPatterns.isSome()) { leapMonthPatterns[Int64(DT_LEAP_MONTH_PATTERN_FORMAT_WIDE)].replace("{0}", "") } else { "" }
    }
}
