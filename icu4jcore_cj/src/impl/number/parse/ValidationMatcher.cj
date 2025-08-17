package icu4cj.impl.number.parse

public abstract class ValidationMatcher <: NumberParseMatcher {

    public override func match(segment: StringSegment, result: ParsedNumber): Bool {
        return false
    }

    public override func smokeTest(segment: StringSegment): Bool {
        return false
    }
}
