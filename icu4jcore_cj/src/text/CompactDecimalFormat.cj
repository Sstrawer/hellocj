package icu4cj.text


public class CompactDecimalFormat <: DecimalFormat {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private static let serialVersionUID = 4716293295276629682

    public static func getInstance(locale: ULocale, style: CompactDecimalFormat_CompactStyle): CompactDecimalFormat {
        return CompactDecimalFormat(locale, style)
    }

    public static func getInstance(locale: Locale, style: CompactDecimalFormat_CompactStyle): CompactDecimalFormat {
        return CompactDecimalFormat(ULocale.forLocale(locale), style)
    }

    init(locale: ULocale, style: CompactDecimalFormat_CompactStyle) {
        super()
        symbols = DecimalFormatSymbols.getInstance(locale)
        properties = DecimalFormatProperties()
        properties.setCompactStyle(style)
        properties.setGroupingSize(-2)
        properties.setMinimumGroupingDigits(2)
        exportedProperties = DecimalFormatProperties()
        refreshFormatter()
    }

    public override func parse(text: String, parsePosition: ParsePosition): Number {
        throw UnsupportedOperationException()
    }

    public override func parseCurrency(text: String, parsePosition: ParsePosition): CurrencyAmount {
        throw UnsupportedOperationException()
    }
}


public class CompactDecimalFormat_CompactStyle <: Enum<CompactDecimalFormat_CompactStyle> {
    public static let SHORT = CompactDecimalFormat_CompactStyle("SHORT", 0)

    public static let LONG = CompactDecimalFormat_CompactStyle("LONG", 1)

    private static func _values(): Array<CompactDecimalFormat_CompactStyle> {
        return [CompactDecimalFormat_CompactStyle.SHORT, CompactDecimalFormat_CompactStyle.LONG]
    }

    private static let _VALUES = CompactDecimalFormat_CompactStyle._values()

    public static func values(): Array<CompactDecimalFormat_CompactStyle> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): CompactDecimalFormat_CompactStyle {
        return (TypeInfo.of<CompactDecimalFormat_CompactStyle>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as CompactDecimalFormat_CompactStyle
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
