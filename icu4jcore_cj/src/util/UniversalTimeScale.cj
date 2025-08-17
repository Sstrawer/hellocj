package icu4cj.util


public class UniversalTimeScale {
    public static let JAVA_TIME = 0

    public static let UNIX_TIME = 1

    public static let ICU4C_TIME = 2

    public static let WINDOWS_FILE_TIME = 3

    public static let DOTNET_DATE_TIME = 4

    public static let MAC_OLD_TIME = 5

    public static let MAC_TIME = 6

    public static let EXCEL_TIME = 7

    public static let DB2_TIME = 8

    public static let UNIX_MICROSECONDS_TIME = 9

    
    public static let MAX_SCALE = 10

    public static let UNITS_VALUE = 0

    public static let EPOCH_OFFSET_VALUE = 1

    public static let FROM_MIN_VALUE = 2

    public static let FROM_MAX_VALUE = 3

    public static let TO_MIN_VALUE = 4

    public static let TO_MAX_VALUE = 5

    public static let EPOCH_OFFSET_PLUS_1_VALUE = 6

    
    public static let EPOCH_OFFSET_MINUS_1_VALUE = 7

    
    public static let UNITS_ROUND_VALUE = 8

    
    public static let MIN_ROUND_VALUE = 9

    
    public static let MAX_ROUND_VALUE = 10

    
    public static let MAX_SCALE_VALUE = 11

    private static let ticks = 1

    private static let microseconds = ticks * 10

    private static let milliseconds = microseconds * 1000

    private static let seconds = milliseconds * 1000

    private static let minutes = seconds * 60

    private static let hours = minutes * 60

    private static let days = hours * 24

    private static let timeScaleTable: Array<UniversalTimeScale_TimeScaleData> = [UniversalTimeScale_TimeScaleData(milliseconds, 621355968000000000, -9223372036854774999, 9223372036854774999, -984472800485477, 860201606885477), UniversalTimeScale_TimeScaleData(seconds, 621355968000000000, -9223372036854775808, 9223372036854775807, -984472800485, 860201606885), UniversalTimeScale_TimeScaleData(milliseconds, 621355968000000000, -9223372036854774999, 9223372036854774999, -984472800485477, 860201606885477), UniversalTimeScale_TimeScaleData(ticks, 504911232000000000, -8718460804854775808, 9223372036854775807, -9223372036854775808, 8718460804854775807), UniversalTimeScale_TimeScaleData(ticks, 0, -9223372036854775808, 9223372036854775807, -9223372036854775808, 9223372036854775807), UniversalTimeScale_TimeScaleData(seconds, 600527520000000000, -9223372036854775808, 9223372036854775807, -982389955685, 862284451685), UniversalTimeScale_TimeScaleData(seconds, 631139040000000000, -9223372036854775808, 9223372036854775807, -985451107685, 859223299685), UniversalTimeScale_TimeScaleData(days, 599265216000000000, -9223372036854775808, 9223372036854775807, -11368793, 9981605), UniversalTimeScale_TimeScaleData(days, 599265216000000000, -9223372036854775808, 9223372036854775807, -11368793, 9981605), UniversalTimeScale_TimeScaleData(microseconds, 621355968000000000, -9223372036854775804, 9223372036854775804, -984472800485477580, 860201606885477580)]


    public static func comefrom(otherTime: Int64, timeScale: Int32): Int64 {
        let data = fromRangeCheck(otherTime, timeScale)
        return (otherTime + data.epochOffset) * data.units
    }

    public static func bigDecimalFrom(otherTime: Float64, timeScale: Int32): BigDecimal {
        let data = getTimeScaleData(timeScale)
        let other = BigDecimal(otherTime.toString())
        let units = BigDecimal(data.units)
        let epochOffset = BigDecimal(data.epochOffset)
        return other.add(epochOffset).multiply(units)
    }

    public static func bigDecimalFrom(otherTime: Int64, timeScale: Int32): BigDecimal {
        let data = getTimeScaleData(timeScale)
        let other = BigDecimal(otherTime)
        let units = BigDecimal(data.units)
        let epochOffset = BigDecimal(data.epochOffset)
        return other.add(epochOffset).multiply(units)
    }

    public static func bigDecimalFrom(otherTime: BigDecimal, timeScale: Int32): BigDecimal {
        let data = getTimeScaleData(timeScale)
        let units = BigDecimal(data.units)
        let epochOffset = BigDecimal(data.epochOffset)
        return otherTime.add(epochOffset).multiply(units)
    }

    public static func toLong(universalTime: Int64, timeScale: Int32): Int64 {
        let data = toRangeCheck(universalTime, timeScale)
        if (universalTime < 0) {
            if (universalTime < data.minRound) {
                return (universalTime + data.unitsRound) / data.units - data.epochOffsetP1
            }
            return (universalTime - data.unitsRound) / data.units - data.epochOffset
        }
        if (universalTime > data.maxRound) {
            return (universalTime - data.unitsRound) / data.units - data.epochOffsetM1
        }
        return (universalTime + data.unitsRound) / data.units - data.epochOffset
    }

    public static func toBigDecimal(universalTime: Int64, timeScale: Int32): BigDecimal {
        let data = getTimeScaleData(timeScale)
        let universal = BigDecimal(universalTime)
        let units = BigDecimal(data.units)
        let epochOffset = BigDecimal(data.epochOffset)
        return universal.divide(units, BigDecimal.ROUND_HALF_UP).subtract(epochOffset)
    }

    public static func toBigDecimal(universalTime: BigDecimal, timeScale: Int32): BigDecimal {
        let data = getTimeScaleData(timeScale)
        let units = BigDecimal(data.units)
        let epochOffset = BigDecimal(data.epochOffset)
        return universalTime.divide(units, BigDecimal.ROUND_HALF_UP).subtract(epochOffset)
    }

    private static func getTimeScaleData(scale: Int32): UniversalTimeScale_TimeScaleData {
        if (scale < 0 || scale >= MAX_SCALE) {
            throw IllegalArgumentException("scale out of range: " + scale.toString())
        }
        return timeScaleTable[Int64(scale)]
    }

    public static func getTimeScaleValue(scale: Int32, value: Int32): Int64 {
        let data = getTimeScaleData(scale)
        match (value) {
            case 0 => return data.units
            case 1 => return data.epochOffset
            case 2 => return data.fromMin
            case 3 => return data.fromMax
            case 4 => return data.toMin
            case 5 => return data.toMax
            case 6 => return data.epochOffsetP1
            case 7 => return data.epochOffsetM1
            case 8 => return data.unitsRound
            case 9 => return data.minRound
            case 10 => return data.maxRound
            case _ => throw IllegalArgumentException("value out of range: " + value.toString())
        }
    }

    private static func toRangeCheck(universalTime: Int64, scale: Int32): UniversalTimeScale_TimeScaleData {
        let data = getTimeScaleData(scale)
        if (universalTime >= data.toMin && universalTime <= data.toMax) {
            return data
        }
        throw IllegalArgumentException("universalTime out of range:" + universalTime.toString())
    }

    private static func fromRangeCheck(otherTime: Int64, scale: Int32): UniversalTimeScale_TimeScaleData {
        let data = getTimeScaleData(scale)
        if (otherTime >= data.fromMin && otherTime <= data.fromMax) {
            return data
        }
        throw IllegalArgumentException("otherTime out of range:" + otherTime.toString())
    }

    
    public static func toBigDecimalTrunc(universalTime: BigDecimal, timeScale: Int32): BigDecimal {
        let data = getTimeScaleData(timeScale)
        let units = BigDecimal(data.units)
        let epochOffset = BigDecimal(data.epochOffset)
        return universalTime.divide(units, BigDecimal.ROUND_DOWN).subtract(epochOffset)
    }
}


class UniversalTimeScale_TimeScaleData {
    init(theUnits: Int64, theEpochOffset: Int64, theToMin: Int64, theToMax: Int64, theFromMin: Int64, theFromMax: Int64) {
        units = theUnits
        unitsRound = theUnits / 2
        minRound = Int64.Min + unitsRound
        maxRound = Int64.Max - unitsRound
        epochOffset = theEpochOffset / theUnits
        if (theUnits == 1) {
            epochOffsetP1 = match (0) { case _ => epochOffsetM1 = epochOffset; epochOffsetM1 }
        } else {
            epochOffsetP1 = epochOffset + 1
            epochOffsetM1 = epochOffset - 1
        }
        toMin = theToMin
        toMax = theToMax
        fromMin = theFromMin
        fromMax = theFromMax
    }

    var units: Int64 = 0

    var epochOffset: Int64 = 0

    var fromMin: Int64 = 0

    var fromMax: Int64 = 0

    var toMin: Int64 = 0

    var toMax: Int64 = 0

    var epochOffsetP1: Int64 = 0

    var epochOffsetM1: Int64 = 0

    var unitsRound: Int64 = 0

    var minRound: Int64 = 0

    var maxRound: Int64 = 0
}
