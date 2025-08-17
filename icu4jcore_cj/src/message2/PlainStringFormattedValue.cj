package icu4cj.message2



public class PlainStringFormattedValue <: FormattedValue {
    private let value: String

    
    public init(value: String) {
        if (value.isNone()) {
            throw IllegalAccessError("Should not try to wrap a null in a formatted value")
        }
        this.value = value
    }

    
    public override func length(): Int32 {
        return if (value.isNone()) { 0 } else { Int32(value.size) }
    }

    
    public override func charAt(index: Int32): Char {
        return Char(value[Int64(index)])
    }

    
    public override func subSequence(start: Int32, end: Int32): String {
        return value.subSequence(start, end)
    }

    
    public override func appendTo<A>(appendable: A): A {
        try {
            appendable.append(value)
        } catch (e: IOException) {
            throw UncheckedIOException("problem appending", e)
        }
        return appendable
    }

    
    public override func nextPosition(cfpos: ConstrainedFieldPosition): Bool {
        throw Exception("nextPosition not yet implemented")
    }

    
    public override func toCharacterIterator(): AttributedCharacterIterator {
        throw Exception("toCharacterIterator not yet implemented")
    }

    
    public override func toString(): String {
        return value
    }
}
