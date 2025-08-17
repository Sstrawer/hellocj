package icu4cj.text

public interface FormattedValue <: String {
    public override func toString(): String

    public func appendTo<A>(appendable: A): A

    public func nextPosition(cfpos: ConstrainedFieldPosition): Bool

    public func toCharacterIterator(): AttributedCharacterIterator
}