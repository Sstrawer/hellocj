package icu4cj.util

public class DateInterval <: Serializable {
    private static let serialVersionUID = 1

    private let fromDate: Int64

    private let toDate: Int64

    public init(comefrom: Int64, to: Int64) {
        fromDate = comefrom
        toDate = to
    }

    public func getFromDate(): Int64 {
        return fromDate
    }

    public func getToDate(): Int64 {
        return toDate
    }

    public override func equals(a: Object): Bool {
        if (checkOptionalIs<DateInterval, Object>(a)) {
            let di = a
            return fromDate == di.fromDate && toDate == di.toDate
        }
        return false
    }

    public override func hashCode(): Int64 {
        return Int64(Int32(fromDate + toDate))
    }

    public override func toString(): String {
        return fromDate.toString() + " " + toDate.toString()
    }
}
