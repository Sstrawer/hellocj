package icu4cj.message2



public class FormattedPlaceholder {
    private let formattedValue: FormattedValue

    private let inputValue: Object

    
    public init(inputValue: Object, formattedValue: FormattedValue) {
        if (formattedValue.isNone()) {
            throw IllegalAccessError("Should not try to wrap a null formatted value")
        }
        this.inputValue = inputValue
        this.formattedValue = formattedValue
    }

    
    public func getInput(): Object {
        return inputValue
    }

    
    public func getFormattedValue(): FormattedValue {
        return formattedValue
    }

    
    public override func toString(): String {
        return formattedValue.toString()
    }
}
