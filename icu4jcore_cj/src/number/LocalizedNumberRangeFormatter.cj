package icu4cj.number

public class LocalizedNumberRangeFormatter <: NumberRangeFormatterSettings<LocalizedNumberRangeFormatter> {
     private var fImpl: NumberRangeFormatterImpl

    <-- Internal error: 
    <init>(NumberRangeFormatterSettings<> parent, int key, Object value) {
        super(parent, key, value);
    } -->

    public func formatRange(first: Int32, second: Int32): FormattedNumberRange {
        let dq1: DecimalQuantity = DecimalQuantity_DualStorageBCD(first)
        let dq2: DecimalQuantity = DecimalQuantity_DualStorageBCD(second)
        return formatImpl(dq1, dq2, first == second)
    }

    public func formatRange(first: Float64, second: Float64): FormattedNumberRange {
        let dq1: DecimalQuantity = DecimalQuantity_DualStorageBCD(first)
        let dq2: DecimalQuantity = DecimalQuantity_DualStorageBCD(second)
        return formatImpl(dq1, dq2, first == second)
    }

    public func formatRange(first: Number, second: Number): FormattedNumberRange {
        if (first.isNone() || second.isNone()) {
            throw IllegalArgumentException("Cannot format null values in range")
        }
        let dq1: DecimalQuantity = DecimalQuantity_DualStorageBCD(first)
        let dq2: DecimalQuantity = DecimalQuantity_DualStorageBCD(second)
        return formatImpl(dq1, dq2, refEq(first, second))
    }

    public func withoutLocale(): UnlocalizedNumberRangeFormatter {
        return UnlocalizedNumberRangeFormatter(this, KEY_LOCALE, None)
    }

    public func formatImpl(first: DecimalQuantity, second: DecimalQuantity, equalBeforeRounding: Bool): FormattedNumberRange {
        if (fImpl.isNone()) {
            fImpl = NumberRangeFormatterImpl(resolve())
        }
        return fImpl.format(first, second, equalBeforeRounding)
    }

    public override func create(key: Int32, value: Object): LocalizedNumberRangeFormatter {
        return LocalizedNumberRangeFormatter(this, key, value)
    }
}
