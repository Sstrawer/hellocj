package icu4cj.util

public abstract class TimeZoneRule <: Serializable {
    private static let serialVersionUID = 6374143828553768100

    private let name: String

    private let rawOffset: Int32

    private let dstSavings: Int32

    public init(name: String, rawOffset: Int32, dstSavings: Int32) {
        this.name = name
        this.rawOffset = rawOffset
        this.dstSavings = dstSavings
    }

    public func getName(): String {
        return name
    }

    public func getRawOffset(): Int32 {
        return rawOffset
    }

    public func getDSTSavings(): Int32 {
        return dstSavings
    }

    public func isEquivalentTo(other: TimeZoneRule): Bool {
        if (rawOffset == other.rawOffset && dstSavings == other.dstSavings) {
            return true
        }
        return false
    }

    public func getFirstStart(prevRawOffset: Int32, prevDSTSavings: Int32): DateTime

    public func getFinalStart(prevRawOffset: Int32, prevDSTSavings: Int32): DateTime

    public func getNextStart(base: Int64, prevRawOffset: Int32, prevDSTSavings: Int32, inclusive: Bool): DateTime

    public func getPreviousStart(base: Int64, prevRawOffset: Int32, prevDSTSavings: Int32, inclusive: Bool): DateTime

    public func isTransitionRule(): Bool

    public override func toString(): String {
        let buf = StringBuilder()
        buf.append("name=" + (name))
        buf.append(", stdOffset=" + rawOffset.toString())
        buf.append(", dstSaving=" + dstSavings.toString())
        return buf.toString()
    }
}
