package icu4cj.util


public class DangiCalendar <: ChineseCalendar {
    private static let serialVersionUID = 8156297445349501985

    private static let DANGI_EPOCH_YEAR = -2332

    private static let KOREA_ZONE: TimeZone


    
    public init() {
        this(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
    }

    
    public init(date: DateTime) {
        this(TimeZone.getDefault(), ULocale.getDefault(ULocale_Category.FORMAT))
        setTime(date)
    }

    
    public init(zone: TimeZone, locale: ULocale) {
        super(zone, locale, DANGI_EPOCH_YEAR, KOREA_ZONE)
    }

    
    public override func getType(): String {
        return "dangi"
    }
}
