package icu4cj.number


public class FormattedNumberRange <: FormattedValue {
    let string: FormattedStringBuilder

    let quantity1: DecimalQuantity

    let quantity2: DecimalQuantity

    let identityResult: NumberRangeFormatter_RangeIdentityResult

    init(string: FormattedStringBuilder, quantity1: DecimalQuantity, quantity2: DecimalQuantity, identityResult: NumberRangeFormatter_RangeIdentityResult) {
        this.string = string
        this.quantity1 = quantity1
        this.quantity2 = quantity2
        this.identityResult = identityResult
    }

    public override func toString(): String {
        return string.toString()
    }

    public override func appendTo<A>(appendable: A): A {
        try {
            appendable.append(string)
        } catch (e: IOException) {
            throw ICUUncheckedIOException(e)
        }
        return appendable
    }

    public override func charAt(index: Int32): Char {
        return string.toRuneArray()[index]
    }

    public override func length(): Int32 {
        return string.lengthMethod()
    }

    public override func subSequence(start: Int32, end: Int32): String {
        return string.subString(start, end)
    }

    public override func nextPosition(cfpos: ConstrainedFieldPosition): Bool {
        return FormattedValueStringBuilderImpl.nextPosition(string, cfpos, None)
    }

    public override func toCharacterIterator(): AttributedCharacterIterator {
        return FormattedValueStringBuilderImpl.toCharacterIterator(string, None)
    }

    public func getFirstBigDecimal(): BigDecimal {
        return quantity1.toBigDecimal()
    }

    public func getSecondBigDecimal(): BigDecimal {
        return quantity2.toBigDecimal()
    }

    public func getIdentityResult(): NumberRangeFormatter_RangeIdentityResult {
        return identityResult
    }

    public override func hashCode(): Int64 {
        return Int64(Arrays.hashCode(string.toCharArray()) ^ Arrays.hashCode(string.toFieldArray()) ^ Int32(quantity1.toBigDecimal().hashCode()) ^ Int32(quantity2.toBigDecimal().hashCode()))
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (other.isNone()) {
            return false
        }
        if (!(checkOptionalIs<FormattedNumberRange, Object>(other))) {
            return false
        }
        let _other = other
        return string.contentEquals(_other.string) && refEq(quantity1.toBigDecimal(), _other.quantity1.toBigDecimal()) && refEq(quantity2.toBigDecimal(), _other.quantity2.toBigDecimal())
    }

    
    public func getFirstFixedDecimal(): PluralRules_IFixedDecimal {
        return quantity1
    }

    
    public func getSecondFixedDecimal(): PluralRules_IFixedDecimal {
        return quantity2
    }
}
