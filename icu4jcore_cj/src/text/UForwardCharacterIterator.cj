package icu4cj.text

public interface UForwardCharacterIterator {
    let DONE = -1

    public func next(): Int32

    public func nextCodePoint(): Int32
}