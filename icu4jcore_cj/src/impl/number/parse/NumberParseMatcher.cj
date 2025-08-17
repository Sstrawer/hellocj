package icu4cj.impl.number.parse

public interface NumberParseMatcher {
    public func match(segment: StringSegment, result: ParsedNumber): Bool

    public func smokeTest(segment: StringSegment): Bool

    public func postProcess(result: ParsedNumber): Unit
}

public interface NumberParseMatcher_Flexible {

}