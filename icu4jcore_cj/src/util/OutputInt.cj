package icu4cj.util


public class OutputInt {
    
    public var value: Int32 = 0

    

    
    public init(value: Int32) {
        this.value = value
    }

    
    public override func toString(): String {
        return value.toString()
    }
}
