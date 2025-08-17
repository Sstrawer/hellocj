package icu4cj.impl.breakiter

abstract class DictionaryMatcher {

    public func matches(text: CharacterIterator, maxLength: Int32, lengths: Array<Int32>, count: Array<Int32>, limit: Int32, values: Array<Int32>): Int32

    public func matches(text: CharacterIterator, maxLength: Int32, lengths: Array<Int32>, count: Array<Int32>, limit: Int32): Int32 {
        return matches(text, maxLength, lengths, count, limit, None)
    }

    public func getType(): Int32
}
