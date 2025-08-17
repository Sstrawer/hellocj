package icu4cj.text



public abstract class DurationFormat <: UFormat {
    private static let serialVersionUID = -2076961954727774282

    
    public static func getInstance(locale: ULocale): DurationFormat {
        return BasicDurationFormat.getInstance(locale)
    }

    
    protected init() {
        super()
    }

    
    protected init(locale: ULocale) {
        super()
        setLocale(locale, locale)
    }

    
    public override func format(object: Object, toAppend: StringBuffer, pos: FieldPosition): StringBuffer

    
    public override func parseObject(source: String, pos: ParsePosition): Object {
        throw UnsupportedOperationException()
    }

    
    public func formatDurationFromNowTo(targetDate: DateTime): String

    
    public func formatDurationFromNow(duration: Int64): String

    
    public func formatDurationFrom(duration: Int64, referenceDate: Int64): String
}
