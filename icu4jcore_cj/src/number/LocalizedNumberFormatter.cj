package icu4cj.number


public class LocalizedNumberFormatter <: NumberFormatterSettings<LocalizedNumberFormatter> {
    static let callCount = AtomicLongFieldUpdater.newUpdater<LocalizedNumberFormatter>(TypeInfo.of<LocalizedNumberFormatter>() as ClassTypeInfo, "callCountInternal")

     var callCountInternal: Int64 = 0

     var savedWithUnit: LocalizedNumberFormatter

     var compiled: NumberFormatterImpl

    <-- Internal error: 
    <init>(NumberFormatterSettings<> parent, int key, Object value) {
        super(parent, key, value);
    } -->

    public func format(input: Int64): FormattedNumber {
        return format(DecimalQuantity_DualStorageBCD(input))
    }

    public func format(input: Float64): FormattedNumber {
        return format(DecimalQuantity_DualStorageBCD(input))
    }

    public func format(input: Number): FormattedNumber {
        return format(DecimalQuantity_DualStorageBCD(input))
    }

    public func format(input: Measure): FormattedNumber {
        let fq: DecimalQuantity = DecimalQuantity_DualStorageBCD(input.getNumber())
        let unit = input.getUnit()
        let string = FormattedStringBuilder()
        let micros = formatImpl(fq, unit, string)
        return FormattedNumber(string, fq, micros.outputUnit, micros.gender)
    }

    public func toFormat(): Format {
        return LocalizedNumberFormatterAsFormat(this, resolve().loc)
    }

    public func withoutLocale(): UnlocalizedNumberFormatter {
        return UnlocalizedNumberFormatter(this, KEY_LOCALE, None)
    }

    private func format(fq: DecimalQuantity): FormattedNumber {
        let string = FormattedStringBuilder()
        let micros = formatImpl(fq, string)
        return FormattedNumber(string, fq, micros.outputUnit, micros.gender)
    }

    
    public func formatImpl(fq: DecimalQuantity, string: FormattedStringBuilder): MicroProps {
        if (computeCompiled()) {
            return compiled.format(fq, string)
        }
        return NumberFormatterImpl.formatStatic(resolve(), fq, string)
    }

    
    public func formatImpl(fq: DecimalQuantity, unit: MeasureUnit, string: FormattedStringBuilder): MicroProps {
        if (Objects.equals(resolve().unit, unit)) {
            return formatImpl(fq, string)
        }
        var withUnit = savedWithUnit
        if (withUnit.isNone() || !Objects.equals(withUnit.resolve().unit, unit)) {
            withUnit = LocalizedNumberFormatter(this, KEY_UNIT, unit)
            savedWithUnit = withUnit
        }
        return withUnit.formatImpl(fq, string)
    }

    
    public func getAffixImpl(isPrefix: Bool, isNegative: Bool): String {
        let string = FormattedStringBuilder()
        let signum = if (isNegative) { 255u8 } else { 1u8 }
        let plural = StandardPlural.OTHER
        let prefixLength: Int32
        if (computeCompiled()) {
            prefixLength = compiled.getPrefixSuffix(signum, plural, string)
        } else {
            prefixLength = NumberFormatterImpl.getPrefixSuffixStatic(resolve(), signum, plural, string)
        }
        if (isPrefix) {
            return toString(string.subSequence(0, prefixLength))
        } else {
            return toString(string.subSequence(prefixLength, string.lengthMethod()))
        }
    }

    private func computeCompiled(): Bool {
        let macros = resolve()
        let currentCount = callCount.incrementAndGet(this)
        if (currentCount == macros.threshold) {
            compiled = NumberFormatterImpl(macros)
            return true
        } else if (compiled.isSome()) {
            return true
        } else {
            return false
        }
    }

    public override func create(key: Int32, value: Object): LocalizedNumberFormatter {
        return LocalizedNumberFormatter(this, key, value)
    }
}
