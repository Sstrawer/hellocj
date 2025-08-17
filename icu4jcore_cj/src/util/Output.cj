package icu4cj.util

public class Output<T> {
    public var value: T

    public override func toString(): String {
        return if (value.isNone()) { "null" } else { toString(value) }
    }


    public init(value: T) {
        this.value = value
    }
}