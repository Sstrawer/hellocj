package icu4cj.impl.number


public class MicroProps <: Cloneable & MicroPropsGenerator {
    public var sign: NumberFormatter_SignDisplay

    public var symbols: DecimalFormatSymbols

    public var nsName: String

    public var padding: Padder

    public var decimal: NumberFormatter_DecimalSeparatorDisplay

    public var integerWidth: IntegerWidth

    public var modOuter: Modifier

    public var modMiddle: Modifier

    public var modInner: Modifier

    public var rounder: Precision

    public var grouping: Grouper

    public var useCurrency: Bool = false

    public var gender: String

    public var currencyAsDecimal: String

    private let immutable: Bool

    public var outputUnit: MeasureUnit

    public var mixedMeasures: ArrayList<Measure>

    public var indexOfQuantity = -1

     private var exhausted: Bool = false

    public init(immutable: Bool) {
        this.immutable = immutable
    }

    public override func processQuantity(quantity: DecimalQuantity): MicroProps {
        if (immutable) {
            return this.clone()
        } else if (exhausted) {
            throw Exception("Cannot re-use a mutable MicroProps in the quantity chain")
        } else {
            exhausted = true
            return this
        }
    }

    public override func clone(): Object {
        try {
            return super.toString()
        } catch (e: CloneNotSupportedException) {
            throw AssertionError(e)
        }
    }
}
