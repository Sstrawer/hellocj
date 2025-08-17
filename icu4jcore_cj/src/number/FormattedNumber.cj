package icu4cj.number


public class FormattedNumber <: FormattedValue {
    let string: FormattedStringBuilder

    let fq: DecimalQuantity

    let outputUnit: MeasureUnit

    let gender: String

    init(nsb: FormattedStringBuilder, fq: DecimalQuantity, outputUnit: MeasureUnit, gender: String) {
        this.string = nsb
        this.fq = fq
        this.outputUnit = outputUnit
        this.gender = gender
    }

    public override func toString(): String {
        return string.toString()
    }

    public override func length(): Int32 {
        return string.lengthMethod()
    }

    public override func charAt(index: Int32): Char {
        return string.toRuneArray()[index]
    }

    public override func subSequence(start: Int32, end: Int32): String {
        return string.subString(start, end)
    }

    public override func appendTo<A>(appendable: A): A {
        return Utility.appendTo(string, appendable)
    }

    public override func nextPosition(cfpos: ConstrainedFieldPosition): Bool {
        return FormattedValueStringBuilderImpl.nextPosition(string, cfpos, None)
    }

    public override func toCharacterIterator(): AttributedCharacterIterator {
        return FormattedValueStringBuilderImpl.toCharacterIterator(string, None)
    }

    public func toBigDecimal(): BigDecimal {
        return fq.toBigDecimal()
    }

    public func getOutputUnit(): MeasureUnit {
        return this.outputUnit
    }

    public func getNounClass(): DisplayOptions_NounClass {
        return DisplayOptions_NounClass.fromIdentifier(this.gender)
    }

    
    public func getGender(): String {
        if (this.gender.isNone()) {
            return ""
        }
        return this.gender
    }

    
    public func getFixedDecimal(): PluralRules_IFixedDecimal {
        return fq
    }
}
