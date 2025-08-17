package icu4cj.impl.duration


public class BasicDurationFormat <: DurationFormat {
    private static let serialVersionUID = -3146984141909457700

     var formatter: DurationFormatter

     var pformatter: PeriodFormatter

     var pfs: PeriodFormatterService

    public static func getInstance(locale: ULocale): BasicDurationFormat {
        return BasicDurationFormat(locale)
    }

    public override func format(object: Object, toAppend: StringBuffer, pos: FieldPosition): StringBuffer {
        if (object) {
            let res = formatDurationFromNow(object)
            return toAppend.append(res)
        } else if (checkOptionalIs<Date, Object>(object)) {
            let res = formatDurationFromNowTo(object)
            return toAppend.append(res)
        } else if (checkOptionalIs<Duration, Object>(object)) {
            let res = formatDuration(object)
            return toAppend.append(res)
        }
        throw IllegalArgumentException("Cannot format given Object as a Duration")
    }

    public init() {
        super()
        pfs = BasicPeriodFormatterService.getInstance()
        formatter = pfs.newDurationFormatterFactory().getFormatter()
        pformatter = pfs.newPeriodFormatterFactory().setDisplayPastFuture(false).getFormatter()
    }

    public init(locale: ULocale) {
        super(locale)
        pfs = BasicPeriodFormatterService.getInstance()
        formatter = pfs.newDurationFormatterFactory().setLocale(locale.getName()).getFormatter()
        pformatter = pfs.newPeriodFormatterFactory().setDisplayPastFuture(false).setLocale(locale.getName()).getFormatter()
    }

    public override func formatDurationFrom(duration: Int64, referenceDate: Int64): String {
        return formatter.formatDurationFrom(duration, referenceDate)
    }

    public override func formatDurationFromNow(duration: Int64): String {
        return formatter.formatDurationFromNow(duration)
    }

    public override func formatDurationFromNowTo(targetDate: DateTime): String {
        return formatter.formatDurationFromNowTo(targetDate)
    }

    public func formatDuration(obj: Object): String {
        let inFields = [DatatypeConstants.YEARS, DatatypeConstants.MONTHS, DatatypeConstants.DAYS, DatatypeConstants.HOURS, DatatypeConstants.MINUTES, DatatypeConstants.SECONDS]
        let outFields: Array<TimeUnit> = [TimeUnit.YEAR, TimeUnit.MONTH, TimeUnit.DAY, TimeUnit.HOUR, TimeUnit.MINUTE, TimeUnit.SECOND]
        let inDuration = obj
        var p: Period
        var duration = inDuration
        var inPast = false
        if (inDuration.getSign() < 0) {
            duration = inDuration.negate()
            inPast = true
        }
        var sawNonZero = false
        var i = 0
        while (i < Int32(inFields.size)) {
            if (duration.isSet(inFields[Int64(i)])) {
                let n = duration.getField(inFields[Int64(i)])
                if (n.intValue() == 0 && !sawNonZero) {
                    continue
                } else {
                    sawNonZero = true
                }
                var floatVal = n.floatValue()
                var alternateUnit: TimeUnit
                var alternateVal = 0.0
                if (refEq(outFields[Int64(i)], TimeUnit.SECOND)) {
                    let fullSeconds = Float64(floatVal)
                    let intSeconds = Float64(floor(floatVal))
                    let millis = (fullSeconds - intSeconds) * 1000.0
                    if (millis > 0.0) {
                        alternateUnit = TimeUnit.MILLISECOND
                        alternateVal = Float32(millis)
                        floatVal = Float32(intSeconds)
                    }
                }
                if (p.isNone()) {
                    p = Period.atStatic(floatVal, outFields[Int64(i)])
                } else {
                    p = p.and(floatVal, outFields[Int64(i)])
                }
                if (alternateUnit.isSome()) {
                    p = p.and(alternateVal, alternateUnit)
                }
            }
            i++
        }
        if (p.isNone()) {
            return formatDurationFromNow(0)
        } else {
            if (inPast) {
                p = p.inPast()
            } else {
                p = p.inFutureMethod()
            }
        }
        return pformatter.format(p)
    }
}
