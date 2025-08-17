package icu4cj.util

public class InitialTimeZoneRule <: TimeZoneRule {
    private static let serialVersionUID = 1876594993064051206

    public init(name: String, rawOffset: Int32, dstSavings: Int32) {
        super(name, rawOffset, dstSavings)
    }

    public override func isEquivalentTo(other: TimeZoneRule): Bool {
        if (checkOptionalIs<InitialTimeZoneRule, TimeZoneRule>(other)) {
            return super.isEquivalentTo(other)
        }
        return false
    }

    public override func getFinalStart(prevRawOffset: Int32, prevDSTSavings: Int32): DateTime {
        return None
    }

    public override func getFirstStart(prevRawOffset: Int32, prevDSTSavings: Int32): DateTime {
        return None
    }

    public override func getNextStart(base: Int64, prevRawOffset: Int32, prevDSTSavings: Int32, inclusive: Bool): DateTime {
        return None
    }

    public override func getPreviousStart(base: Int64, prevRawOffset: Int32, prevDSTSavings: Int32, inclusive: Bool): DateTime {
        return None
    }

    public override func isTransitionRule(): Bool {
        return false
    }
}
