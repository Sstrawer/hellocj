package icu4cj.message2


class DateTimeFormatterFactory <: FormatterFactory {
    private let kind: String

    init(kind: String) {
        var tempkind = kind
        match (tempkind) {
            case "date" => ()
            case "time" => ()
            case "datetime" => ()
            case _ => tempkind = "datetime"
        }
        this.kind = tempkind
    }

    private static func stringToStyle(option: String): Int32 {
        match (option) {
            case "full" => return DateFormat.FULL
            case "long" => return DateFormat.LONG
            case "medium" => return DateFormat.MEDIUM
            case "short" => return DateFormat.SHORT
            case _ => throw IllegalArgumentException("Invalid datetime style: " + (option))
        }
    }

    public override func createFormatter(locale: Locale, fixedOptions: Map<String, Object>): Formatter {
        var dateStyle = DateFormat.NONE
        var timeStyle = DateFormat.NONE
        match (kind) {
            case "date" => dateStyle = getDateTimeStyle(fixedOptions, "style")
            case "time" => timeStyle = getDateTimeStyle(fixedOptions, "style")
            case "datetime" =>
                dateStyle = getDateTimeStyle(fixedOptions, "dateStyle")
                timeStyle = getDateTimeStyle(fixedOptions, "timeStyle")
            case _ =>
                dateStyle = getDateTimeStyle(fixedOptions, "dateStyle")
                timeStyle = getDateTimeStyle(fixedOptions, "timeStyle")
        }
        if (dateStyle == DateFormat.NONE && timeStyle == DateFormat.NONE) {
            var skeleton: String = ""
            match (kind) {
                case "date" => skeleton = getDateFieldOptions(fixedOptions)
                case "time" => skeleton = getTimeFieldOptions(fixedOptions)
                case "datetime" =>
                    skeleton = getDateFieldOptions(fixedOptions)
                    skeleton += getTimeFieldOptions(fixedOptions)
                case _ =>
                    skeleton = getDateFieldOptions(fixedOptions)
                    skeleton += getTimeFieldOptions(fixedOptions)
            }
            if (skeleton.isEmpty()) {
                skeleton = OptUtils.getString(fixedOptions, "icu:skeleton", "")
            }
            if (!skeleton.isEmpty()) {
                let df = DateFormat.getInstanceForSkeleton(skeleton, locale)
                return DateTimeFormatterFactory_DateTimeFormatter(locale, df)
            }
            match (kind) {
                case "date" =>
                    dateStyle = DateFormat.SHORT
                    timeStyle = DateFormat.NONE
                case "time" =>
                    dateStyle = DateFormat.NONE
                    timeStyle = DateFormat.SHORT
                case "datetime" =>
                    dateStyle = DateFormat.SHORT
                    timeStyle = DateFormat.SHORT
                case _ =>
                    dateStyle = DateFormat.SHORT
                    timeStyle = DateFormat.SHORT
            }
        }
        let df = DateFormat.getDateTimeInstance(dateStyle, timeStyle, locale)
        return DateTimeFormatterFactory_DateTimeFormatter(locale, df)
    }

    private static func getDateTimeStyle(options: Map<String, Object>, key: String): Int32 {
        let opt = OptUtils.getString(options, key)
        if (opt.isSome()) {
            return stringToStyle(opt)
        }
        return DateFormat.NONE
    }

    private static func getDateFieldOptions(options: Map<String, Object>): String {
        let skeleton = StringBuilder()
        var opt: String
        opt = OptUtils.getString(options, "weekday", "")
        match (opt) {
            case "long" => skeleton.append("EEEE")
            case "short" => skeleton.append("E")
            case "narrow" => skeleton.append("EEEEEE")
            case _ => ()
        }
        opt = OptUtils.getString(options, "era", "")
        match (opt) {
            case "long" => skeleton.append("GGGG")
            case "short" => skeleton.append("G")
            case "narrow" => skeleton.append("GGGGG")
            case _ => ()
        }
        opt = OptUtils.getString(options, "year", "")
        match (opt) {
            case "numeric" => skeleton.append("y")
            case "2-digit" => skeleton.append("yy")
            case _ => ()
        }
        opt = OptUtils.getString(options, "month", "")
        match (opt) {
            case "numeric" => skeleton.append("M")
            case "2-digit" => skeleton.append("MM")
            case "long" => skeleton.append("MMMM")
            case "short" => skeleton.append("MMM")
            case "narrow" => skeleton.append("MMMMM")
            case _ => ()
        }
        opt = OptUtils.getString(options, "day", "")
        match (opt) {
            case "numeric" => skeleton.append("d")
            case "2-digit" => skeleton.append("dd")
            case _ => ()
        }
        return skeleton.toString()
    }

    private static func getTimeFieldOptions(options: Map<String, Object>): String {
        let skeleton = StringBuilder()
        var opt: String
        var showHour = 0
        opt = OptUtils.getString(options, "hour", "")
        match (opt) {
            case "numeric" => showHour = 1
            case "2-digit" => showHour = 2
            case _ => ()
        }
        if (showHour > 0) {
            var hourCycle: String = ""
            opt = OptUtils.getString(options, "hourCycle", "")
            match (opt) {
                case "h11" => hourCycle = "K"
                case "h12" => hourCycle = "h"
                case "h23" => hourCycle = "H"
                case "h24" => hourCycle = "k"
                case _ => hourCycle = "j"
            }
            skeleton.append(hourCycle)
            if (showHour == 2) {
                skeleton.append(hourCycle)
            }
        }
        opt = OptUtils.getString(options, "minute", "")
        match (opt) {
            case "numeric" => skeleton.append("m")
            case "2-digit" => skeleton.append("mm")
            case _ => ()
        }
        opt = OptUtils.getString(options, "second", "")
        match (opt) {
            case "numeric" => skeleton.append("s")
            case "2-digit" => skeleton.append("ss")
            case _ => ()
        }
        opt = OptUtils.getString(options, "fractionalSecondDigits", "")
        match (opt) {
            case "1" => skeleton.append("S")
            case "2" => skeleton.append("SS")
            case "3" => skeleton.append("SSS")
            case _ => ()
        }
        opt = OptUtils.getString(options, "timeZoneName", "")
        match (opt) {
            case "long" => skeleton.append("z")
            case "short" => skeleton.append("zzzz")
            case "shortOffset" => skeleton.append("O")
            case "longOffset" => skeleton.append("OOOO")
            case "shortGeneric" => skeleton.append("v")
            case "longGeneric" => skeleton.append("vvvv")
            case _ => ()
        }
        return skeleton.toString()
    }

    private static let ISO_PATTERN = Pattern.compile("^(([0-9]{4})-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])){1}(T([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])(\\.[0-9]{1,3})(Z|[+-]((0[0-9]|1[0-3]):[0-5][0-9]|14:00)))$")

    private static func safeParse(str: String): Int32 {
        if (str.isNone() || str.isEmpty()) {
            return None
        }
        return parse<Int32>(str)
    }

    static func parseIso8601(text: String): Object {
        let m = ISO_PATTERN.matcher(text)
        if (m.find() && m.groupCount() == 12 && !m.group().isEmpty()) {
            let year = safeParse(m.group(2))
            let month = safeParse(m.group(3))
            let day = safeParse(m.group(4))
            var hour = safeParse(m.group(6))
            var minute = safeParse(m.group(7))
            var second = safeParse(m.group(8))
            var millisecond: Int32 = 0
            if (m.group(9).isSome()) {
                let z: String = ((m.group(9)) + "000")[1..4]
                millisecond = safeParse(z)
            } else {
                millisecond = 0
            }
            let tzPart = m.group(10)
            if (hour.isNone()) {
                hour = 0
                minute = 0
                second = 0
            }
            let gc = GregorianCalendar(year, month - 1, day, hour, minute, second)
            gc.set(Calendar.MILLISECOND, millisecond)
            if (tzPart.isSome()) {
                if (tzPart == "Z") {
                    gc.setTimeZone(TimeZone.GMT_ZONE)
                } else {
                    let sign = if (tzPart.startsWith("-")) { -1 } else { 1 }
                    let tzParts = tzPart[1..].split(":")
                    if (Int32(tzParts.size) == 2) {
                        let tzHour = safeParse(tzParts[0])
                        let tzMin = safeParse(tzParts[1])
                        if (tzHour.isSome() && tzMin.isSome()) {
                            let offset = sign * (tzHour * 60 + tzMin) * 60 * 1000
                            gc.setTimeZone(SimpleTimeZone(offset, "offset"))
                        }
                    }
                }
            }
            return gc
        }
        return text
    }
}


class DateTimeFormatterFactory_DateTimeFormatter <: Formatter {
    private let icuFormatter: DateFormat

    private let locale: Locale

    init(locale: Locale, df: DateFormat) {
        this.locale = locale
        this.icuFormatter = df
    }

    public override func format(toFormat: Object, variableOptions: Map<String, Object>): FormattedPlaceholder {
        var temptoFormat = toFormat
        if (temptoFormat.isNone()) {
            return None
        }
        if (temptoFormat) {
            temptoFormat = DateTimeFormatterFactory.parseIso8601(toString(temptoFormat))
            if (temptoFormat) {
                return FormattedPlaceholder(temptoFormat, PlainStringFormattedValue("{|" + toString(temptoFormat) + "|}"))
            }
        }
        if (checkOptionalIs<Calendar, Object>(temptoFormat)) {
            let tz = temptoFormat.getTimeZone()
            let milis = temptoFormat.getTimeInMillis()
            let icuTz = TimeZone.getTimeZone(tz.getID())
            let calendar = Calendar.getInstance(icuTz, locale)
            calendar.setTimeInMillis(milis)
            temptoFormat = calendar
        }
        let result = icuFormatter.format(temptoFormat)
        return FormattedPlaceholder(temptoFormat, PlainStringFormattedValue(result))
    }

    public override func formatToString(toFormat: Object, variableOptions: Map<String, Object>): String {
        let result = format(toFormat, variableOptions)
        return if (result.isSome()) { result.toString() } else { None }
    }
}
