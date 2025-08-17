package icu4cj.util

public abstract class CodePointMap <: Iterable<CodePointMap_Range> {

    public func get(c: Int32): Int32

    public func getRange(start: Int32, filter: CodePointMap_ValueFilter, range: CodePointMap_Range): Bool

    public func getRange(start: Int32, option: CodePointMap_RangeOption, surrogateValue: Int32, filter: CodePointMap_ValueFilter, range: CodePointMap_Range): Bool {
        if (!option.isSome()) {
            throw AssertionError()
        }
        if (!getRange(start, filter, range)) {
            return false
        }
        if (refEq(option, CodePointMap_RangeOption.NORMAL)) {
            return true
        }
        let surrEnd = if (refEq(option, CodePointMap_RangeOption.FIXED_ALL_SURROGATES)) { 57343 } else { 56319 }
        let end = range.end
        if (end < 55295 || start > surrEnd) {
            return true
        }
        if (range.value == surrogateValue) {
            if (end >= surrEnd) {
                return true
            }
        } else {
            if (start <= 55295) {
                range.end = 55295
                return true
            }
            range.value = surrogateValue
            if (end > surrEnd) {
                range.end = surrEnd
                return true
            }
        }
        if (getRange(surrEnd + 1, filter, range) && range.value == surrogateValue) {
            range.start = start
            return true
        }
        range.start = start
        range.end = surrEnd
        range.value = surrogateValue
        return true
    }

    public override func iterator(): Iterator<CodePointMap_Range> {
        return CodePointMap_RangeIterator(this) as Iterator<CodePointMap_Range>
    }

    public func stringIterator(s: String, sIndex: Int32): CodePointMap_StringIterator {
        return CodePointMap_StringIterator(this, s, sIndex)
    }
}


public class CodePointMap_RangeOption <: Enum<CodePointMap_RangeOption> {
    public static let NORMAL = CodePointMap_RangeOption("NORMAL", 0)

    public static let FIXED_LEAD_SURROGATES = CodePointMap_RangeOption("FIXED_LEAD_SURROGATES", 1)

    public static let FIXED_ALL_SURROGATES = CodePointMap_RangeOption("FIXED_ALL_SURROGATES", 2)

    private static func _values(): Array<CodePointMap_RangeOption> {
        return [CodePointMap_RangeOption.NORMAL, CodePointMap_RangeOption.FIXED_LEAD_SURROGATES, CodePointMap_RangeOption.FIXED_ALL_SURROGATES]
    }

    private static let _VALUES = CodePointMap_RangeOption._values()

    public static func values(): Array<CodePointMap_RangeOption> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): CodePointMap_RangeOption {
        return (TypeInfo.of<CodePointMap_RangeOption>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as CodePointMap_RangeOption
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public interface CodePointMap_ValueFilter {
    public func apply(value: Int32): Int32
}

public class CodePointMap_Range {
    var start: Int32 = 0

    var end: Int32 = 0

    var value: Int32 = 0

    public init() {
        start = match (0) { case _ => end = -1; end }
        value = 0
    }

    public func getStart(): Int32 {
        return start
    }

    public func getEnd(): Int32 {
        return end
    }

    public func getValue(): Int32 {
        return value
    }

    public func set(start: Int32, end: Int32, value: Int32): Unit {
        this.start = start
        this.end = end
        this.value = value
    }
}


class CodePointMap_RangeIterator <: Iterator<CodePointMap_Range> {
    let this_0: CodePointMap

    init(this_0: CodePointMap) {
        this.this_0 = this_0
    }

    private var range: CodePointMap_Range = CodePointMap_Range()

    public override func hasNext(): Bool {
        return -1 <= range.end && range.end < 1114111
    }

    public override func next(): CodePointMap_Range {
        if (this_0.getRange(range.end + 1, None, range)) {
            return range
        } else {
            throw NoSuchElementException()
        }
    }

    public override func remove(): Unit {
        throw UnsupportedOperationException()
    }
}


public class CodePointMap_StringIterator {
    let this_0: CodePointMap

    
    protected var s: String

    
    protected var sIndex: Int32 = 0

    
    protected var c: Int32 = 0

    
    protected var value: Int32 = 0

    
    protected init(this_0: CodePointMap, s: String, sIndex: Int32) {
        this.this_0 = this_0
        this.s = s
        this.sIndex = sIndex
        c = -1
        value = 0
    }

    public func reset(s: String, sIndex: Int32): Unit {
        this.s = s
        this.sIndex = sIndex
        c = -1
        value = 0
    }

    public func next(): Bool {
        if (sIndex >= s.size) {
            return false
        }
        c = Character.codePointAt(s, sIndex)
        sIndex += Character.charCount(c)
        value = this_0.get(c)
        return true
    }

    public func previous(): Bool {
        if (sIndex <= 0) {
            return false
        }
        c = Character.codePointBefore(s, sIndex)
        sIndex -= Character.charCount(c)
        value = this_0.get(c)
        return true
    }

    public func getIndex(): Int32 {
        return sIndex
    }

    public func getCodePoint(): Int32 {
        return c
    }

    public func getValue(): Int32 {
        return value
    }
}
