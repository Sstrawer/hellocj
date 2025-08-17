package icu4cj.util


public class TimeUnit <: MeasureUnit {
    private static let serialVersionUID = -2839973855554750484

    private let index: Int32

    init(Type: String, code: String) {
        super(Type, code)
        index = 0
    }

    public static func values(): Array<TimeUnit> {
        return [SECOND, MINUTE, HOUR, DAY, WEEK, MONTH, YEAR]
    }

    private func writeReplace(): Object {
        return MeasureUnit_MeasureUnitProxy(Type, subType)
    }

    private func readResolve(): Object {
        match (index) {
            case 6 => return SECOND
            case 5 => return MINUTE
            case 4 => return HOUR
            case 3 => return DAY
            case 2 => return WEEK
            case 1 => return MONTH
            case 0 => return YEAR
            case _ => throw InvalidObjectException("Bad index: " + index.toString())
        }
    }
}
