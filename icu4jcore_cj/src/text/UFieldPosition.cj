package icu4cj.text


public class UFieldPosition <: FieldPosition {
    private var countVisibleFractionDigits = -1

    private var fractionDigits = 0

    
    public init() {
        FieldPosition(-1)
    }

    
    public init(field: Int32) {
        FieldPosition(field)
    }

    
    public init(attribute: Format_Field, fieldID: Int32) {
        FieldPosition(attribute, fieldID)
    }

    
    public init(attribute: Format_Field) {
        FieldPosition(attribute)
    }

    
    public func setFractionDigits(countVisibleFractionDigits: Int32, fractionDigits: Int64): Unit {
        this.countVisibleFractionDigits = countVisibleFractionDigits
        this.fractionDigits = fractionDigits
    }

    
    public func getCountVisibleFractionDigits(): Int32 {
        return countVisibleFractionDigits
    }

    
    public func getFractionDigits(): Int64 {
        return fractionDigits
    }
}
