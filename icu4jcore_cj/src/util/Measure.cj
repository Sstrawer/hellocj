package icu4cj.util


public class Measure {
    private let number: Number

    private let unit: MeasureUnit

    public init(number: Number, unit: MeasureUnit) {
        if (number.isNone() || unit.isNone()) {
            throw NoneValueException("Number and MeasureUnit must not be null")
        }
        this.number = number
        this.unit = unit
    }

    public override func equals(obj: Object): Bool {
        if (refEq(obj, this)) {
            return true
        }
        if (!(checkOptionalIs<Measure, Object>(obj))) {
            return false
        }
        let m = obj
        return unit.equals(m.unit) && numbersEqual(number, m.number)
    }

    private static func numbersEqual(a: Number, b: Number): Bool {
        if (refEq(a, b)) {
            return true
        }
        if (a.doubleValue() == b.doubleValue()) {
            return true
        }
        return false
    }

    public override func hashCode(): Int64 {
        return Int64(31 * Int32(number.doubleValue().hashCode()) + Int32(unit.hashCode()))
    }

    public override func toString(): String {
        return toString(number) + ' '.toString() + unit.toString()
    }

    public func getNumber(): Number {
        return number
    }

    public func getUnit(): MeasureUnit {
        return unit
    }
}
