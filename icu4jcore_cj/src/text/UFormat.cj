package icu4cj.text


public abstract class UFormat <: Format {
    private static let serialVersionUID = -4964390515840164416

    public init() {
        Format()
    }

    public func getLocale(Type: ULocale_Type): ULocale {
        return if (refEq(Type, ULocale.ACTUAL_LOCALE)) { this.actualLocale } else { this.validLocale }
    }

    func setLocale(valid: ULocale, actual: ULocale): Unit {
        if ((valid.isNone()) != (actual.isNone())) {
            throw IllegalArgumentException()
        }
        this.validLocale = valid
        this.actualLocale = actual
    }

    private var validLocale: ULocale

    private var actualLocale: ULocale
}


public abstract class UFormat_SpanField <: Format_Field {
    private static let serialVersionUID = -4732719509273350606

    protected init(name: String) {
        Format_Field(name)
    }
}
