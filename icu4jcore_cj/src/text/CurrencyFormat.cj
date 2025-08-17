package icu4cj.text

class CurrencyFormat <: MeasureFormat {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    static let serialVersionUID = -931679363692504634

    public init(locale: ULocale) {
        super(locale, MeasureFormat_FormatWidth.DEFAULT_CURRENCY)
    }

    public override func format(obj: Object, toAppendTo: StringBuffer, pos: FieldPosition): StringBuffer {
        if (!(checkOptionalIs<CurrencyAmount, Object>(obj))) {
            throw IllegalArgumentException("Invalid type: " + TypeInfo.of(obj).name)
        }
        return super.format(obj, toAppendTo, pos)
    }

    public override func parseObject(source: String, pos: ParsePosition): CurrencyAmount {
        return getNumberFormatInternal().parseCurrency(source, pos)
    }

    private func writeReplace(): Object {
        return toCurrencyProxy()
    }

    private func readResolve(): Object {
        return CurrencyFormat(getLocale(ULocale.ACTUAL_LOCALE))
    }
}
