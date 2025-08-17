package icu4cj.impl.number.range

public class PrefixInfixSuffixLengthHelper {

    public var lengthPrefix = 0

    public var length1 = 0

    public var lengthInfix = 0

    public var length2 = 0

    public var lengthSuffix = 0

    public func index0(): Int32 {
        return lengthPrefix
    }

    public func index1(): Int32 {
        return lengthPrefix + length1
    }

    public func index2(): Int32 {
        return lengthPrefix + length1 + lengthInfix
    }

    public func index3(): Int32 {
        return lengthPrefix + length1 + lengthInfix + length2
    }

    public func index4(): Int32 {
        return lengthPrefix + length1 + lengthInfix + length2 + lengthSuffix
    }
}
