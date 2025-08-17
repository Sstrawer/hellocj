package icu4cj.util


public class VTimeZone <: BasicTimeZone {
    private static let serialVersionUID = -6851467294127795902

    public static func create(tzid: String): VTimeZone {
        let basicTimeZone = TimeZone.getFrozenICUTimeZone(tzid, true)
        if (basicTimeZone.isNone()) {
            return None
        }
        let vtz = VTimeZone(tzid)
        vtz.tz = basicTimeZone.cloneAsThawed()
        vtz.olsonzid = vtz.tz.getID()
        return vtz
    }

    public static func create(reader: StringReader<InputStream>): VTimeZone {
        let vtz = VTimeZone()
        if (vtz.load(reader)) {
            return vtz
        }
        return None
    }

    public override func getOffset(era: Int32, year: Int32, month: Int32, day: Int32, dayOfWeek: Int32, milliseconds: Int32): Int32 {
        return tz.getOffset(era, year, month, day, dayOfWeek, milliseconds)
    }

    public override func getOffset(date: Int64, local: Bool, offsets: Array<Int32>): Unit {
        tz.getOffset(date, local, offsets)
    }

    public override func getOffsetFromLocal(date: Int64, nonExistingTimeOpt: BasicTimeZone_LocalOption, duplicatedTimeOpt: BasicTimeZone_LocalOption, offsets: Array<Int32>): Unit {
        tz.getOffsetFromLocal(date, nonExistingTimeOpt, duplicatedTimeOpt, offsets)
    }

    public override func getRawOffset(): Int32 {
        return tz.getRawOffset()
    }

    public override func inDaylightTime(date: DateTime): Bool {
        return tz.inDaylightTime(date)
    }

    public override func setRawOffset(offsetMillis: Int32): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen VTimeZone instance.")
        }
        tz.setRawOffset(offsetMillis)
    }

    public override func useDaylightTime(): Bool {
        return tz.useDaylightTime()
    }

    public override func observesDaylightTime(): Bool {
        return tz.observesDaylightTime()
    }

    public override func hasSameRules(other: TimeZone): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (checkOptionalIs<VTimeZone, TimeZone>(other)) {
            return tz.hasSameRules(other.tz)
        }
        return tz.hasSameRules(other)
    }

    public func getTZURL(): String {
        return tzurl
    }

    public func setTZURL(url: String): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen VTimeZone instance.")
        }
        tzurl = url
    }

    public func getLastModified(): DateTime {
        return lastmod
    }

    public func setLastModified(date: DateTime): Unit {
        if (isFrozenMethod()) {
            throw UnsupportedOperationException("Attempt to modify a frozen VTimeZone instance.")
        }
        lastmod = date
    }

    public func write(writer: StringWriter<OutputStream>): Unit {
        let bw = BufferedWriter(writer)
        if (vtzlines.isSome()) {
            for (line in vtzlines) {
                if (line.startsWith(ICAL_TZURL + COLON)) {
                    if (tzurl.isSome()) {
                        bw.write(ICAL_TZURL)
                        bw.write(COLON)
                        bw.write(tzurl)
                        bw.write(NEWLINE)
                    }
                } else if (line.startsWith(ICAL_LASTMOD + COLON)) {
                    if (lastmod.isSome()) {
                        bw.write(ICAL_LASTMOD)
                        bw.write(COLON)
                        bw.write(getUTCDateTimeString(lastmod.getTime()))
                        bw.write(NEWLINE)
                    }
                } else {
                    bw.write(line)
                    bw.write(NEWLINE)
                }
            }
            bw.flush()
        } else {
            var customProperties: Array<String>
            if (olsonzid.isSome() && ICU_TZVERSION.isSome()) {
                customProperties = Array<String>(1)
                customProperties[0] = ICU_TZINFO_PROP + COLON + (olsonzid) + "[" + (ICU_TZVERSION) + "]"
            }
            writeZone(writer, tz, customProperties)
        }
    }

    public func write(writer: StringWriter<OutputStream>, start: Int64): Unit {
        let rules = tz.getTimeZoneRules(start)
        let rbtz = RuleBasedTimeZone(tz.getID(), rules[0])
        var i = 1
        while (i < Int32(rules.size)) {
            rbtz.addTransitionRule(rules[Int64(i)])
            i++
        }
        var customProperties: Array<String>
        if (olsonzid.isSome() && ICU_TZVERSION.isSome()) {
            customProperties = Array<String>(1)
            customProperties[0] = ICU_TZINFO_PROP + COLON + (olsonzid) + "[" + (ICU_TZVERSION) + "/Partial@" + start.toString() + "]"
        }
        writeZone(writer, rbtz, customProperties)
    }

    public func writeSimple(writer: StringWriter<OutputStream>, time: Int64): Unit {
        let rules = tz.getSimpleTimeZoneRulesNear(time)
        let rbtz = RuleBasedTimeZone(tz.getID(), rules[0])
        var i = 1
        while (i < Int32(rules.size)) {
            rbtz.addTransitionRule(rules[Int64(i)])
            i++
        }
        var customProperties: Array<String>
        if (olsonzid.isSome() && ICU_TZVERSION.isSome()) {
            customProperties = Array<String>(1)
            customProperties[0] = ICU_TZINFO_PROP + COLON + (olsonzid) + "[" + (ICU_TZVERSION) + "/Simple@" + time.toString() + "]"
        }
        writeZone(writer, rbtz, customProperties)
    }

    public override func getNextTransition(base: Int64, inclusive: Bool): TimeZoneTransition {
        return tz.getNextTransition(base, inclusive)
    }

    public override func getPreviousTransition(base: Int64, inclusive: Bool): TimeZoneTransition {
        return tz.getPreviousTransition(base, inclusive)
    }

    public override func hasEquivalentTransitions(other: TimeZone, start: Int64, end: Int64): Bool {
        if (refEq(this, other)) {
            return true
        }
        return tz.hasEquivalentTransitions(other, start, end)
    }

    public override func getTimeZoneRules(): Array<TimeZoneRule> {
        return tz.getTimeZoneRules()
    }

    public override func getTimeZoneRules(start: Int64): Array<TimeZoneRule> {
        return tz.getTimeZoneRules(start)
    }

    public override func clone(): Object {
        if (isFrozenMethod()) {
            return this
        }
        return cloneAsThawed()
    }

    private var tz: BasicTimeZone

    private var vtzlines: ArrayList<String>

    private var olsonzid: String

    private var tzurl: String

    private var lastmod: DateTime = None

    private static var ICU_TZVERSION: String

    private static let ICU_TZINFO_PROP = "X-TZINFO"

    private static let DEF_DSTSAVINGS = 60 * 60 * 1000

    private static let DEF_TZSTARTTIME = 0

    private static let MIN_TIME = Int64.Min

    private static let MAX_TIME = Int64.Max

    private static let COLON = ":"

    private static let SEMICOLON = ";"

    private static let EQUALS_SIGN = "="

    private static let COMMA = ","

    private static let NEWLINE = "\r\n"

    private static let ICAL_BEGIN_VTIMEZONE = "BEGIN:VTIMEZONE"

    private static let ICAL_END_VTIMEZONE = "END:VTIMEZONE"

    private static let ICAL_BEGIN = "BEGIN"

    private static let ICAL_END = "END"

    private static let ICAL_VTIMEZONE = "VTIMEZONE"

    private static let ICAL_TZID = "TZID"

    private static let ICAL_STANDARD = "STANDARD"

    private static let ICAL_DAYLIGHT = "DAYLIGHT"

    private static let ICAL_DTSTART = "DTSTART"

    private static let ICAL_TZOFFSETFROM = "TZOFFSETFROM"

    private static let ICAL_TZOFFSETTO = "TZOFFSETTO"

    private static let ICAL_RDATE = "RDATE"

    private static let ICAL_RRULE = "RRULE"

    private static let ICAL_TZNAME = "TZNAME"

    private static let ICAL_TZURL = "TZURL"

    private static let ICAL_LASTMOD = "LAST-MODIFIED"

    private static let ICAL_FREQ = "FREQ"

    private static let ICAL_UNTIL = "UNTIL"

    private static let ICAL_YEARLY = "YEARLY"

    private static let ICAL_BYMONTH = "BYMONTH"

    private static let ICAL_BYDAY = "BYDAY"

    private static let ICAL_BYMONTHDAY = "BYMONTHDAY"

    private static let ICAL_DOW_NAMES: Array<String> = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]

    private static let MONTHLENGTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]


    private init() {
        super()
    }

    private init(tzid: String) {
        super(tzid)
    }

    private func load(reader: StringReader<InputStream>): Bool {
        try {
            vtzlines = LinkedList<String>() as ArrayList<String>
            var eol = false
            var start = false
            var success = false
            let line = StringBuilder()
            while (true) {
                let ch = readWrap(reader.read())
                if (ch == -1) {
                    if (start && line.toString().startsWith(ICAL_END_VTIMEZONE)) {
                        vtzlines.append(line.toString())
                        success = true
                    }
                    break
                }
                if (ch == 13) {
                    continue
                }
                if (eol) {
                    if (ch != 9 && ch != 32) {
                        if (start) {
                            if (Int32(line.size) > 0) {
                                vtzlines.append(line.toString())
                            }
                        }
                        line.setLength(0)
                        if (ch != 10) {
                            line.append(Char(ch))
                        }
                    }
                    eol = false
                } else {
                    if (ch == 10) {
                        eol = true
                        if (start) {
                            if (line.toString().startsWith(ICAL_END_VTIMEZONE)) {
                                vtzlines.append(line.toString())
                                success = true
                                break
                            }
                        } else {
                            if (line.toString().startsWith(ICAL_BEGIN_VTIMEZONE)) {
                                vtzlines.append(line.toString())
                                line.setLength(0)
                                start = true
                                eol = false
                            }
                        }
                    } else {
                        line.append(Char(ch))
                    }
                }
            }
            if (!success) {
                return false
            }
        } catch (ioe: IOException) {
            return false
        }
        return parse()
    }

    private static let INI = 0

    private static let VTZ = 1

    private static let TZI = 2

    private static let ERR = 3

    private func parse(): Bool {
        if (vtzlines.isNone() || Int32(vtzlines.size) == 0) {
            return false
        }
        var tzid: String
        var state = INI
        var dst = false
        var comefrom: String
        var to: String
        var tzname: String
        var dtstart: String
        var isRRULE = false
        var dates: ArrayList<String>
        let rules = ArrayList<TimeZoneRule>()
        var initialRawOffset = 0
        var initialDSTSavings = 0
        var firstStart = MAX_TIME
        for (line in vtzlines) {
            let valueSep = indexOfWrap(line.indexOf(COLON))
            if (valueSep < 0) {
                continue
            }
            let name: String = line[0..Int64(valueSep)]
            let value: String = line[Int64(valueSep + 1)..]
            match (state) {
                case 0 => if (name.append(ICAL_VTIMEZONE)) {
                    state = VTZ
                }
                case 1 => if (name.equals(ICAL_TZID)) {
                    tzid = value
                } else if (name.equals(ICAL_TZURL)) {
                    tzurl = value
                } else if (name.equals(ICAL_LASTMOD)) {
                    lastmod = Date(parseDateTimeString(value, 0))
                } else if (name.equals(ICAL_BEGIN)) {
                    let isDST = value.append(ICAL_DAYLIGHT)
                    if (value.append(ICAL_STANDARD) || isDST) {
                        if (tzid.isNone()) {
                            state = ERR
                            break
                        }
                        dates = None
                        isRRULE = false
                        comefrom = None
                        to = None
                        tzname = None
                        dst = isDST
                        state = TZI
                    } else {
                        state = ERR
                        break
                    }
                } else if (name.equals(ICAL_END)) {
                    break
                }
                case 2 => if (name.equals(ICAL_DTSTART)) {
                    dtstart = value
                } else if (name.equals(ICAL_TZNAME)) {
                    tzname = value
                } else if (name.equals(ICAL_TZOFFSETFROM)) {
                    comefrom = value
                } else if (name.equals(ICAL_TZOFFSETTO)) {
                    to = value
                } else if (name.equals(ICAL_RDATE)) {
                    if (isRRULE) {
                        state = ERR
                        break
                    }
                    if (dates.isNone()) {
                        dates = LinkedList<String>() as ArrayList<String>
                    }
                    let st = StringTokenizer(value, COMMA)
                    while (st.hasMoreTokens()) {
                        let date = st.nextToken()
                        dates.append(date)
                    }
                } else if (name.equals(ICAL_RRULE)) {
                    if (!isRRULE && dates.isSome()) {
                        state = ERR
                        break
                    } else if (dates.isNone()) {
                        dates = LinkedList<String>() as ArrayList<String>
                    }
                    isRRULE = true
                    dates.append(value)
                } else if (name.equals(ICAL_END)) {
                    if (dtstart.isNone() || comefrom.isNone() || to.isNone()) {
                        state = ERR
                        break
                    }
                    if (tzname.isNone()) {
                        tzname = getDefaultTZName(tzid, dst)
                    }
                    var rule: TimeZoneRule
                    var fromOffset = 0
                    var toOffset = 0
                    var rawOffset = 0
                    var dstSavings = 0
                    var start = 0
                    try {
                        fromOffset = offsetStrToMillis(comefrom)
                        toOffset = offsetStrToMillis(to)
                        if (dst) {
                            if (toOffset - fromOffset > 0) {
                                rawOffset = fromOffset
                                dstSavings = toOffset - fromOffset
                            } else {
                                rawOffset = toOffset - DEF_DSTSAVINGS
                                dstSavings = DEF_DSTSAVINGS
                            }
                        } else {
                            rawOffset = toOffset
                            dstSavings = 0
                        }
                        start = parseDateTimeString(dtstart, fromOffset)
                        var actualStart: DateTime = None
                        if (isRRULE) {
                            rule = createRuleByRRULE(tzname, rawOffset, dstSavings, start, dates, fromOffset)
                        } else {
                            rule = createRuleByRDATE(tzname, rawOffset, dstSavings, start, dates, fromOffset)
                        }
                        if (rule.isSome()) {
                            actualStart = rule.getFirstStart(fromOffset, 0)
                            if (actualStart.getTime() < firstStart) {
                                firstStart = actualStart.getTime()
                                if (dstSavings > 0) {
                                    initialRawOffset = fromOffset
                                    initialDSTSavings = 0
                                } else {
                                    if (fromOffset - toOffset == DEF_DSTSAVINGS) {
                                        initialRawOffset = fromOffset - DEF_DSTSAVINGS
                                        initialDSTSavings = DEF_DSTSAVINGS
                                    } else {
                                        initialRawOffset = fromOffset
                                        initialDSTSavings = 0
                                    }
                                }
                            }
                        }
                    } catch (iae: IllegalArgumentException) { }
                    if (rule.isNone()) {
                        state = ERR
                        break
                    }
                    rules.append(rule)
                    state = VTZ
                }
                case _ => ()
            }
            if (state == ERR) {
                vtzlines = None
                return false
            }
        }
        if (Int32(rules.size) == 0) {
            return false
        }
        let initialRule = InitialTimeZoneRule(getDefaultTZName(tzid, false), initialRawOffset, initialDSTSavings)
        let rbtz = RuleBasedTimeZone(tzid, initialRule)
        var finalRuleIdx = -1
        var finalRuleCount = 0
                }
                i++
            }
        } while (false)
        if (finalRuleCount > 2) {
            return false
        }
        if (finalRuleCount == 1) {
            if (Int32(rules.size) == 1) {
                rules.clear()
            } else {
                let finalRule = rules[Int64(finalRuleIdx)]
                let tmpRaw = finalRule.getRawOffset()
                let tmpDST = finalRule.getDSTSavings()
                let finalStart = finalRule.getFirstStart(initialRawOffset, initialDSTSavings)
                var start = finalStart
                        let r = rules[Int64(i)]
                        let lastStart = r.getFinalStart(tmpRaw, tmpDST)
                        if (lastStart.after(start)) {
                            start = finalRule.getNextStart(lastStart.getTime(), r.getRawOffset(), r.getDSTSavings(), false)
                        }
                        i++
                    }
                } while (false)
                let newRule: TimeZoneRule
                if (refEq(start, finalStart)) {
                    newRule = TimeArrayTimeZoneRule(finalRule.getName(), finalRule.getRawOffset(), finalRule.getDSTSavings(), [finalStart.getTime()], DateTimeRule.UTC_TIME)
                } else {
                    let fields = Grego.timeToFields(start.getTime(), None)
                    newRule = AnnualTimeZoneRule(finalRule.getName(), finalRule.getRawOffset(), finalRule.getDSTSavings(), finalRule.getRule(), finalRule.getStartYear(), fields[0])
                }
                rules.set(Int64(finalRuleIdx), newRule)
            }
        }
        for (r in rules) {
            rbtz.addTransitionRule(r)
        }
        tz = rbtz
        setID(tzid)
        return true
    }

    private static func getDefaultTZName(tzid: String, isDST: Bool): String {
        if (isDST) {
            return (tzid) + "(DST)"
        }
        return (tzid) + "(STD)"
    }

    private static func createRuleByRRULE(tzname: String, rawOffset: Int32, dstSavings: Int32, start: Int64, dates: ArrayList<String>, fromOffset: Int32): TimeZoneRule {
        if (dates.isNone() || Int32(dates.size) == 0) {
            return None
        }
        var rrule = dates[0]
        var until: Array<Int64> = Array<Int64>(1) { _ => 0 }
        let ruleFields = parseRRULE(rrule, until)
        if (ruleFields.isNone()) {
            return None
        }
        var month = ruleFields[0]
        let dayOfWeek = ruleFields[1]
        let nthDayOfWeek = ruleFields[2]
        var dayOfMonth = ruleFields[3]
        if (Int32(dates.size) == 1) {
            if (Int32(ruleFields.size) > 4) {
                if (Int32(ruleFields.size) != 10 || month == -1 || dayOfWeek == 0) {
                    return None
                }
                var firstDay = 31
                let days = Array<Int32>(7) { _ => 0 }
                } while (false)
                                j++
                            }
                        } while (false)
                        if (!found) {
                            return None
                        }
                        i++
                    }
                } while (false)
                dayOfMonth = firstDay
            }
        } else {
            if (month == -1 || dayOfWeek == 0 || dayOfMonth == 0) {
                return None
            }
            if (Int32(dates.size) > 7) {
                return None
            }
            var earliestMonth = month
            var daysCount = Int32(ruleFields.size) - 3
            var earliestDay = 31
            } while (false)
            var anotherMonth = -1
                    if (fields[0] == -1 || fields[1] == 0 || fields[3] == 0) {
                        return None
                    }
                    let count = Int32(fields.size) - 3
                    if (daysCount + count > 7) {
                        return None
                    }
                    if (fields[1] != dayOfWeek) {
                        return None
                    }
                    if (fields[0] != month) {
                        if (anotherMonth == -1) {
                            let diff = fields[0] - month
                            if (diff == -11 || diff == -1) {
                                anotherMonth = fields[0]
                                earliestMonth = anotherMonth
                                earliestDay = 31
                            } else if (diff == 11 || diff == 1) {
                                anotherMonth = fields[0]
                            } else {
                                return None
                            }
                        } else if (fields[0] != month && fields[0] != anotherMonth) {
                            return None
                        }
                    }
                    if (fields[0] == earliestMonth) {
                        } while (false)
                    }
                    daysCount += count
                    i++
                }
            } while (false)
            if (daysCount != 7) {
                return None
            }
            month = earliestMonth
            dayOfMonth = earliestDay
        }
        let dfields = Grego.timeToFields(start + Int64(fromOffset), None)
        let startYear = dfields[0]
        if (month == -1) {
            month = dfields[1]
        }
        if (dayOfWeek == 0 && nthDayOfWeek == 0 && dayOfMonth == 0) {
            dayOfMonth = dfields[2]
        }
        let timeInDay = dfields[5]
        var endYear = AnnualTimeZoneRule.MAX_YEAR
        if (until[0] != MIN_TIME) {
            Grego.timeToFields(until[0], dfields)
            endYear = dfields[0]
        }
        var adtr: DateTimeRule
        if (dayOfWeek == 0 && nthDayOfWeek == 0 && dayOfMonth != 0) {
            adtr = DateTimeRule(month, dayOfMonth, timeInDay, DateTimeRule.WALL_TIME)
        } else if (dayOfWeek != 0 && nthDayOfWeek != 0 && dayOfMonth == 0) {
            adtr = DateTimeRule(month, nthDayOfWeek, dayOfWeek, timeInDay, DateTimeRule.WALL_TIME)
        } else if (dayOfWeek != 0 && nthDayOfWeek == 0 && dayOfMonth != 0) {
            adtr = DateTimeRule(month, dayOfMonth, dayOfWeek, true, timeInDay, DateTimeRule.WALL_TIME)
        } else {
            return None
        }
        return AnnualTimeZoneRule(tzname, rawOffset, dstSavings, adtr, startYear, endYear)
    }

    private static func parseRRULE(rrule: String, until: Array<Int64>): Array<Int32> {
        var month = -1
        var dayOfWeek = 0
        var nthDayOfWeek = 0
        var dayOfMonth: Array<Int32>
        var untilTime = MIN_TIME
        var yearly = false
        var parseError = false
        let st = StringTokenizer(rrule, SEMICOLON)
        while (st.hasMoreTokens()) {
            let attr: String
            var value: String
            let property = st.nextToken()
            let sep = indexOfWrap(property.indexOf(EQUALS_SIGN))
            if (sep != -1) {
                attr = property[0..Int64(sep)]
                value = property[Int64(sep + 1)..]
            } else {
                parseError = true
                break
            }
            if (attr.equals(ICAL_FREQ)) {
                if (value.equals(ICAL_YEARLY)) {
                    yearly = true
                } else {
                    parseError = true
                    break
                }
            } else if (attr.equals(ICAL_UNTIL)) {
                try {
                    untilTime = parseDateTimeString(value, 0)
                } catch (iae: IllegalArgumentException) {
                    parseError = true
                    break
                }
            } else if (attr.equals(ICAL_BYMONTH)) {
                if (Int32(value.size) > 2) {
                    parseError = true
                    break
                }
                try {
                    month = parse<Int32>(value) - 1
                    if (month < 0 || month >= 12) {
                        parseError = true
                        break
                    }
                } catch (nfe: TimeParseException) {
                    parseError = true
                    break
                }
            } else if (attr.equals(ICAL_BYDAY)) {
                let length = Int32(value.size)
                if (length < 2 || length > 4) {
                    parseError = true
                    break
                }
                if (length > 2) {
                    var sign = 1
                    if (Char(value[0]) == '+') {
                        sign = 1
                    } else if (Char(value[0]) == '-') {
                        sign = -1
                    } else if (length == 4) {
                        parseError = true
                        break
                    }
                    try {
                        let n = parse<Int32>(value[Int64(length - 3)..Int64(length - 2)])
                        if (n == 0 || n > 4) {
                            parseError = true
                            break
                        }
                        nthDayOfWeek = n * sign
                    } catch (nfe: TimeParseException) {
                        parseError = true
                        break
                    }
                    value = value[Int64(length - 2)..]
                }
                var wday: Int32 = 0
                wday = 0
                while (wday < Int32(ICAL_DOW_NAMES.size)) {
                    if (value.equals(ICAL_DOW_NAMES[Int64(wday)])) {
                        break
                    }
                    wday++
                }
                if (wday < Int32(ICAL_DOW_NAMES.size)) {
                    dayOfWeek = wday + 1
                } else {
                    parseError = true
                    break
                }
            } else if (attr.equals(ICAL_BYMONTHDAY)) {
                let days = StringTokenizer(value, COMMA)
                let count = days.countTokens()
                dayOfMonth = Array<Int32>(Int64(count)) { _ => 0 }
                var index = 0
                while (days.hasMoreTokens()) {
                    try {
                        dayOfMonth[Int64(match (0) { case _ => index++; index - 1 })] = parse<Int32>(days.nextToken())
                    } catch (nfe: TimeParseException) {
                        parseError = true
                        break
                    }
                }
            }
        }
        if (parseError) {
            return None
        }
        if (!yearly) {
            return None
        }
        until[0] = untilTime
        let results: Array<Int32>
        if (dayOfMonth.isNone()) {
            results = Array<Int32>(4) { _ => 0 }
            results[3] = 0
        } else {
            results = Array<Int32>(Int64(3 + Int32(dayOfMonth.size))) { _ => 0 }
            var i = 0
            while (i < Int32(dayOfMonth.size)) {
                results[Int64(3 + i)] = dayOfMonth[Int64(i)]
                i++
            }
        }
        results[0] = month
        results[1] = dayOfWeek
        results[2] = nthDayOfWeek
        return results
    }

    private static func createRuleByRDATE(tzname: String, rawOffset: Int32, dstSavings: Int32, start: Int64, dates: ArrayList<String>, fromOffset: Int32): TimeZoneRule {
        let times: Array<Int64>
        if (dates.isNone() || Int32(dates.size) == 0) {
            times = Array<Int64>(1) { _ => 0 }
            times[0] = start
        } else {
            times = Array<Int64>(dates.size) { _ => 0 }
            var idx = 0
            try {
                for (date in dates) {
                    times[Int64(match (0) { case _ => idx++; idx - 1 })] = parseDateTimeString(date, fromOffset)
                }
            } catch (iae: IllegalArgumentException) {
                return None
            }
        }
        return TimeArrayTimeZoneRule(tzname, rawOffset, dstSavings, times, DateTimeRule.UTC_TIME)
    }

    private func writeZone(w: StringWriter<OutputStream>, basictz: BasicTimeZone, customProperties: Array<String>): Unit {
        writeHeader(w)
        if (customProperties.isSome() && Int32(customProperties.size) > 0) {
            var i = 0
            while (i < Int32(customProperties.size)) {
                if (customProperties[Int64(i)].isSome()) {
                    w.write(customProperties[Int64(i)])
                    w.write(NEWLINE)
                }
                i++
            }
        }
        var t = MIN_TIME
        var dstName: String
        var dstFromOffset = 0
        var dstFromDSTSavings = 0
        var dstToOffset = 0
        var dstStartYear = 0
        var dstMonth = 0
        var dstDayOfWeek = 0
        var dstWeekInMonth = 0
        var dstMillisInDay = 0
        var dstStartTime = 0
        var dstUntilTime = 0
        var dstCount = 0
        var finalDstRule: AnnualTimeZoneRule
        var stdName: String
        var stdFromOffset = 0
        var stdFromDSTSavings = 0
        var stdToOffset = 0
        var stdStartYear = 0
        var stdMonth = 0
        var stdDayOfWeek = 0
        var stdWeekInMonth = 0
        var stdMillisInDay = 0
        var stdStartTime = 0
        var stdUntilTime = 0
        var stdCount = 0
        var finalStdRule: AnnualTimeZoneRule
        let dtfields = Array<Int32>(6) { _ => 0 }
        var hasTransitions = false
        while (true) {
            let tzt = basictz.getNextTransition(t, false)
            if (tzt.isNone()) {
                break
            }
            hasTransitions = true
            t = tzt.getTime()
            let name = tzt.getTo().getName()
            let isDst = (tzt.getTo().getDSTSavings() != 0)
            let fromOffset = tzt.getFrom().getRawOffset() + tzt.getFrom().getDSTSavings()
            let fromDSTSavings = tzt.getFrom().getDSTSavings()
            let toOffset = tzt.getTo().getRawOffset() + tzt.getTo().getDSTSavings()
            Grego.timeToFields(tzt.getTime() + Int64(fromOffset), dtfields)
            let weekInMonth = Grego.getDayOfWeekInMonth(dtfields[0], dtfields[1], dtfields[2])
            let year = dtfields[0]
            var sameRule = false
            if (isDst) {
                if (finalDstRule.isNone() && checkOptionalIs<AnnualTimeZoneRule, TimeZoneRule>(tzt.getTo())) {
                    if (tzt.getTo().getEndYear() == AnnualTimeZoneRule.MAX_YEAR) {
                        finalDstRule = tzt.getTo()
                    }
                }
                if (dstCount > 0) {
                    if (year == dstStartYear + dstCount && name.equals(dstName) && dstFromOffset == fromOffset && dstToOffset == toOffset && dstMonth == dtfields[1] && dstDayOfWeek == dtfields[3] && dstWeekInMonth == weekInMonth && dstMillisInDay == dtfields[5]) {
                        dstUntilTime = t
                        dstCount++
                        sameRule = true
                    }
                    if (!sameRule) {
                        if (dstCount == 1) {
                            writeZonePropsByTime(w, true, dstName, dstFromOffset, dstToOffset, dstStartTime, true)
                        } else {
                            writeZonePropsByDOW(w, true, dstName, dstFromOffset, dstToOffset, dstMonth, dstWeekInMonth, dstDayOfWeek, dstStartTime, dstUntilTime)
                        }
                    }
                }
                if (!sameRule) {
                    dstName = name
                    dstFromOffset = fromOffset
                    dstFromDSTSavings = fromDSTSavings
                    dstToOffset = toOffset
                    dstStartYear = year
                    dstMonth = dtfields[1]
                    dstDayOfWeek = dtfields[3]
                    dstWeekInMonth = weekInMonth
                    dstMillisInDay = dtfields[5]
                    dstStartTime = match (0) { case _ => dstUntilTime = t; dstUntilTime }
                    dstCount = 1
                }
                if (finalStdRule.isSome() && finalDstRule.isSome()) {
                    break
                }
            } else {
                if (finalStdRule.isNone() && checkOptionalIs<AnnualTimeZoneRule, TimeZoneRule>(tzt.getTo())) {
                    if (tzt.getTo().getEndYear() == AnnualTimeZoneRule.MAX_YEAR) {
                        finalStdRule = tzt.getTo()
                    }
                }
                if (stdCount > 0) {
                    if (year == stdStartYear + stdCount && name.equals(stdName) && stdFromOffset == fromOffset && stdToOffset == toOffset && stdMonth == dtfields[1] && stdDayOfWeek == dtfields[3] && stdWeekInMonth == weekInMonth && stdMillisInDay == dtfields[5]) {
                        stdUntilTime = t
                        stdCount++
                        sameRule = true
                    }
                    if (!sameRule) {
                        if (stdCount == 1) {
                            writeZonePropsByTime(w, false, stdName, stdFromOffset, stdToOffset, stdStartTime, true)
                        } else {
                            writeZonePropsByDOW(w, false, stdName, stdFromOffset, stdToOffset, stdMonth, stdWeekInMonth, stdDayOfWeek, stdStartTime, stdUntilTime)
                        }
                    }
                }
                if (!sameRule) {
                    stdName = name
                    stdFromOffset = fromOffset
                    stdFromDSTSavings = fromDSTSavings
                    stdToOffset = toOffset
                    stdStartYear = year
                    stdMonth = dtfields[1]
                    stdDayOfWeek = dtfields[3]
                    stdWeekInMonth = weekInMonth
                    stdMillisInDay = dtfields[5]
                    stdStartTime = match (0) { case _ => stdUntilTime = t; stdUntilTime }
                    stdCount = 1
                }
                if (finalStdRule.isSome() && finalDstRule.isSome()) {
                    break
                }
            }
        }
        if (!hasTransitions) {
            let offset = basictz.getOffset(0)
            let isDst = (offset != basictz.getRawOffset())
            writeZonePropsByTime(w, isDst, getDefaultTZName(basictz.getID(), isDst), offset, offset, DEF_TZSTARTTIME - Int64(offset), false)
        } else {
            if (dstCount > 0) {
                if (finalDstRule.isNone()) {
                    if (dstCount == 1) {
                        writeZonePropsByTime(w, true, dstName, dstFromOffset, dstToOffset, dstStartTime, true)
                    } else {
                        writeZonePropsByDOW(w, true, dstName, dstFromOffset, dstToOffset, dstMonth, dstWeekInMonth, dstDayOfWeek, dstStartTime, dstUntilTime)
                    }
                } else {
                    if (dstCount == 1) {
                        writeFinalRule(w, true, finalDstRule, dstFromOffset - dstFromDSTSavings, dstFromDSTSavings, dstStartTime)
                    } else {
                        if (isEquivalentDateRule(dstMonth, dstWeekInMonth, dstDayOfWeek, finalDstRule.getRule())) {
                            writeZonePropsByDOW(w, true, dstName, dstFromOffset, dstToOffset, dstMonth, dstWeekInMonth, dstDayOfWeek, dstStartTime, MAX_TIME)
                        } else {
                            writeZonePropsByDOW(w, true, dstName, dstFromOffset, dstToOffset, dstMonth, dstWeekInMonth, dstDayOfWeek, dstStartTime, dstUntilTime)
                            let nextStart = finalDstRule.getNextStart(dstUntilTime, dstFromOffset - dstFromDSTSavings, dstFromDSTSavings, false)
                            if (!nextStart.isSome()) {
                                throw AssertionError()
                            }
                            if (nextStart.isSome()) {
                                writeFinalRule(w, true, finalDstRule, dstFromOffset - dstFromDSTSavings, dstFromDSTSavings, nextStart.getTime())
                            }
                        }
                    }
                }
            }
            if (stdCount > 0) {
                if (finalStdRule.isNone()) {
                    if (stdCount == 1) {
                        writeZonePropsByTime(w, false, stdName, stdFromOffset, stdToOffset, stdStartTime, true)
                    } else {
                        writeZonePropsByDOW(w, false, stdName, stdFromOffset, stdToOffset, stdMonth, stdWeekInMonth, stdDayOfWeek, stdStartTime, stdUntilTime)
                    }
                } else {
                    if (stdCount == 1) {
                        writeFinalRule(w, false, finalStdRule, stdFromOffset - stdFromDSTSavings, stdFromDSTSavings, stdStartTime)
                    } else {
                        if (isEquivalentDateRule(stdMonth, stdWeekInMonth, stdDayOfWeek, finalStdRule.getRule())) {
                            writeZonePropsByDOW(w, false, stdName, stdFromOffset, stdToOffset, stdMonth, stdWeekInMonth, stdDayOfWeek, stdStartTime, MAX_TIME)
                        } else {
                            writeZonePropsByDOW(w, false, stdName, stdFromOffset, stdToOffset, stdMonth, stdWeekInMonth, stdDayOfWeek, stdStartTime, stdUntilTime)
                            let nextStart = finalStdRule.getNextStart(stdUntilTime, stdFromOffset - stdFromDSTSavings, stdFromDSTSavings, false)
                            if (!nextStart.isSome()) {
                                throw AssertionError()
                            }
                            if (nextStart.isSome()) {
                                writeFinalRule(w, false, finalStdRule, stdFromOffset - stdFromDSTSavings, stdFromDSTSavings, nextStart.getTime())
                            }
                        }
                    }
                }
            }
        }
        writeFooter(w)
    }

    private static func isEquivalentDateRule(month: Int32, weekInMonth: Int32, dayOfWeek: Int32, dtrule: DateTimeRule): Bool {
        if (month != dtrule.getRuleMonth() || dayOfWeek != dtrule.getRuleDayOfWeek()) {
            return false
        }
        if (dtrule.getTimeRuleType() != DateTimeRule.WALL_TIME) {
            return false
        }
        if (dtrule.getDateRuleType() == DateTimeRule.DOW && dtrule.getRuleWeekInMonth() == weekInMonth) {
            return true
        }
        let ruleDOM = dtrule.getRuleDayOfMonth()
        if (dtrule.getDateRuleType() == DateTimeRule.DOW_GEQ_DOM) {
            if (ruleDOM % 7 == 1 && (ruleDOM + 6) / 7 == weekInMonth) {
                return true
            }
            if (month != Calendar.FEBRUARY && (MONTHLENGTH[Int64(month)] - ruleDOM) % 7 == 6 && weekInMonth == -1 * ((MONTHLENGTH[Int64(month)] - ruleDOM + 1) / 7)) {
                return true
            }
        }
        if (dtrule.getDateRuleType() == DateTimeRule.DOW_LEQ_DOM) {
            if (ruleDOM % 7 == 0 && ruleDOM / 7 == weekInMonth) {
                return true
            }
            if (month != Calendar.FEBRUARY && (MONTHLENGTH[Int64(month)] - ruleDOM) % 7 == 0 && weekInMonth == -1 * ((MONTHLENGTH[Int64(month)] - ruleDOM) / 7 + 1)) {
                return true
            }
        }
        return false
    }

    private static func writeZonePropsByTime(writer: StringWriter<OutputStream>, isDst: Bool, tzname: String, fromOffset: Int32, toOffset: Int32, time: Int64, withRDATE: Bool): Unit {
        beginZoneProps(writer, isDst, tzname, fromOffset, toOffset, time)
        if (withRDATE) {
            writer.write(ICAL_RDATE)
            writer.write(COLON)
            writer.write(getDateTimeString(time + Int64(fromOffset)))
            writer.write(NEWLINE)
        }
        endZoneProps(writer, isDst)
    }

    private static func writeZonePropsByDOM(writer: StringWriter<OutputStream>, isDst: Bool, tzname: String, fromOffset: Int32, toOffset: Int32, month: Int32, dayOfMonth: Int32, startTime: Int64, untilTime: Int64): Unit {
        beginZoneProps(writer, isDst, tzname, fromOffset, toOffset, startTime)
        beginRRULE(writer, month)
        writer.write(ICAL_BYMONTHDAY)
        writer.write(EQUALS_SIGN)
        writer.write(dayOfMonth.toString())
        if (untilTime != MAX_TIME) {
            appendUNTIL(writer, getDateTimeString(untilTime + Int64(fromOffset)))
        }
        writer.write(NEWLINE)
        endZoneProps(writer, isDst)
    }

    private static func writeZonePropsByDOW(writer: StringWriter<OutputStream>, isDst: Bool, tzname: String, fromOffset: Int32, toOffset: Int32, month: Int32, weekInMonth: Int32, dayOfWeek: Int32, startTime: Int64, untilTime: Int64): Unit {
        beginZoneProps(writer, isDst, tzname, fromOffset, toOffset, startTime)
        beginRRULE(writer, month)
        writer.write(ICAL_BYDAY)
        writer.write(EQUALS_SIGN)
        writer.write(weekInMonth.toString())
        writer.write(ICAL_DOW_NAMES[Int64(dayOfWeek - 1)])
        if (untilTime != MAX_TIME) {
            appendUNTIL(writer, getDateTimeString(untilTime + Int64(fromOffset)))
        }
        writer.write(NEWLINE)
        endZoneProps(writer, isDst)
    }

    private static func writeZonePropsByDOW_GEQ_DOM(writer: StringWriter<OutputStream>, isDst: Bool, tzname: String, fromOffset: Int32, toOffset: Int32, month: Int32, dayOfMonth: Int32, dayOfWeek: Int32, startTime: Int64, untilTime: Int64): Unit {
        if (dayOfMonth % 7 == 1) {
            writeZonePropsByDOW(writer, isDst, tzname, fromOffset, toOffset, month, (dayOfMonth + 6) / 7, dayOfWeek, startTime, untilTime)
        } else if (month != Calendar.FEBRUARY && (MONTHLENGTH[Int64(month)] - dayOfMonth) % 7 == 6) {
            writeZonePropsByDOW(writer, isDst, tzname, fromOffset, toOffset, month, -1 * ((MONTHLENGTH[Int64(month)] - dayOfMonth + 1) / 7), dayOfWeek, startTime, untilTime)
        } else {
            beginZoneProps(writer, isDst, tzname, fromOffset, toOffset, startTime)
            var startDay = dayOfMonth
            var currentMonthDays = 7
            if (dayOfMonth <= 0) {
                let prevMonthDays = 1 - dayOfMonth
                currentMonthDays -= prevMonthDays
                let prevMonth = if ((month - 1) < 0) { 11 } else { month - 1 }
                writeZonePropsByDOW_GEQ_DOM_sub(writer, prevMonth, -prevMonthDays, dayOfWeek, prevMonthDays, MAX_TIME, fromOffset)
                startDay = 1
            } else if (dayOfMonth + 6 > MONTHLENGTH[Int64(month)]) {
                let nextMonthDays = dayOfMonth + 6 - MONTHLENGTH[Int64(month)]
                currentMonthDays -= nextMonthDays
                let nextMonth = if ((month + 1) > 11) { 0 } else { month + 1 }
                writeZonePropsByDOW_GEQ_DOM_sub(writer, nextMonth, 1, dayOfWeek, nextMonthDays, MAX_TIME, fromOffset)
            }
            writeZonePropsByDOW_GEQ_DOM_sub(writer, month, startDay, dayOfWeek, currentMonthDays, untilTime, fromOffset)
            endZoneProps(writer, isDst)
        }
    }

    private static func writeZonePropsByDOW_GEQ_DOM_sub(writer: StringWriter<OutputStream>, month: Int32, dayOfMonth: Int32, dayOfWeek: Int32, numDays: Int32, untilTime: Int64, fromOffset: Int32): Unit {
        var startDayNum = dayOfMonth
        let isFeb = (month == Calendar.FEBRUARY)
        if (dayOfMonth < 0 && !isFeb) {
            startDayNum = MONTHLENGTH[Int64(month)] + dayOfMonth + 1
        }
        beginRRULE(writer, month)
        writer.write(ICAL_BYDAY)
        writer.write(EQUALS_SIGN)
        writer.write(ICAL_DOW_NAMES[Int64(dayOfWeek - 1)])
        writer.write(SEMICOLON)
        writer.write(ICAL_BYMONTHDAY)
        writer.write(EQUALS_SIGN)
        writer.write(startDayNum.toString())
        var i = 1
        while (i < numDays) {
            writer.write(COMMA)
            writer.write((startDayNum + i).toString())
            i++
        }
        if (untilTime != MAX_TIME) {
            appendUNTIL(writer, getDateTimeString(untilTime + Int64(fromOffset)))
        }
        writer.write(NEWLINE)
    }

    private static func writeZonePropsByDOW_LEQ_DOM(writer: StringWriter<OutputStream>, isDst: Bool, tzname: String, fromOffset: Int32, toOffset: Int32, month: Int32, dayOfMonth: Int32, dayOfWeek: Int32, startTime: Int64, untilTime: Int64): Unit {
        if (dayOfMonth % 7 == 0) {
            writeZonePropsByDOW(writer, isDst, tzname, fromOffset, toOffset, month, dayOfMonth / 7, dayOfWeek, startTime, untilTime)
        } else if (month != Calendar.FEBRUARY && (MONTHLENGTH[Int64(month)] - dayOfMonth) % 7 == 0) {
            writeZonePropsByDOW(writer, isDst, tzname, fromOffset, toOffset, month, -1 * ((MONTHLENGTH[Int64(month)] - dayOfMonth) / 7 + 1), dayOfWeek, startTime, untilTime)
        } else if (month == Calendar.FEBRUARY && dayOfMonth == 29) {
            writeZonePropsByDOW(writer, isDst, tzname, fromOffset, toOffset, Calendar.FEBRUARY, -1, dayOfWeek, startTime, untilTime)
        } else {
            writeZonePropsByDOW_GEQ_DOM(writer, isDst, tzname, fromOffset, toOffset, month, dayOfMonth - 6, dayOfWeek, startTime, untilTime)
        }
    }

    private static func writeFinalRule(writer: StringWriter<OutputStream>, isDst: Bool, rule: AnnualTimeZoneRule, fromRawOffset: Int32, fromDSTSavings: Int32, startTime: Int64): Unit {
        var tempstartTime = startTime
        let dtrule = toWallTimeRule(rule.getRule(), fromRawOffset, fromDSTSavings)
        let timeInDay = dtrule.getRuleMillisInDay()
        if (timeInDay < 0) {
            tempstartTime = tempstartTime + (Int64(0 - timeInDay))
        } else if (timeInDay >= Grego.MILLIS_PER_DAY) {
            tempstartTime = tempstartTime - (Int64(timeInDay - (Grego.MILLIS_PER_DAY - 1)))
        }
        let toOffset = rule.getRawOffset() + rule.getDSTSavings()
        match (dtrule.getDateRuleType()) {
            case 0 => writeZonePropsByDOM(writer, isDst, rule.getName(), fromRawOffset + fromDSTSavings, toOffset, dtrule.getRuleMonth(), dtrule.getRuleDayOfMonth(), tempstartTime, MAX_TIME)
            case 1 => writeZonePropsByDOW(writer, isDst, rule.getName(), fromRawOffset + fromDSTSavings, toOffset, dtrule.getRuleMonth(), dtrule.getRuleWeekInMonth(), dtrule.getRuleDayOfWeek(), tempstartTime, MAX_TIME)
            case 2 => writeZonePropsByDOW_GEQ_DOM(writer, isDst, rule.getName(), fromRawOffset + fromDSTSavings, toOffset, dtrule.getRuleMonth(), dtrule.getRuleDayOfMonth(), dtrule.getRuleDayOfWeek(), tempstartTime, MAX_TIME)
            case 3 => writeZonePropsByDOW_LEQ_DOM(writer, isDst, rule.getName(), fromRawOffset + fromDSTSavings, toOffset, dtrule.getRuleMonth(), dtrule.getRuleDayOfMonth(), dtrule.getRuleDayOfWeek(), tempstartTime, MAX_TIME)
            case _ => ()
        }
    }

    private static func toWallTimeRule(rule: DateTimeRule, rawOffset: Int32, dstSavings: Int32): DateTimeRule {
        if (rule.getTimeRuleType() == DateTimeRule.WALL_TIME) {
            return rule
        }
        var wallt = rule.getRuleMillisInDay()
        if (rule.getTimeRuleType() == DateTimeRule.UTC_TIME) {
            wallt += (rawOffset + dstSavings)
        } else if (rule.getTimeRuleType() == DateTimeRule.STANDARD_TIME) {
            wallt += dstSavings
        }
        var month = -1
        var dom = 0
        var dow = 0
        var dtype = -1
        var dshift = 0
        if (wallt < 0) {
            dshift = -1
            wallt += Grego.MILLIS_PER_DAY
        } else if (wallt >= Grego.MILLIS_PER_DAY) {
            dshift = 1
            wallt -= Grego.MILLIS_PER_DAY
        }
        month = rule.getRuleMonth()
        dom = rule.getRuleDayOfMonth()
        dow = rule.getRuleDayOfWeek()
        dtype = rule.getDateRuleType()
        if (dshift != 0) {
            if (dtype == DateTimeRule.DOW) {
                let wim = rule.getRuleWeekInMonth()
                if (wim > 0) {
                    dtype = DateTimeRule.DOW_GEQ_DOM
                    dom = 7 * (wim - 1) + 1
                } else {
                    dtype = DateTimeRule.DOW_LEQ_DOM
                    dom = MONTHLENGTH[Int64(month)] + 7 * (wim + 1)
                }
            }
            dom += dshift
            if (dom == 0) {
                month--
                month = if (month < Calendar.JANUARY) { Calendar.DECEMBER } else { month }
                dom = MONTHLENGTH[Int64(month)]
            } else if (dom > MONTHLENGTH[Int64(month)]) {
                month++
                month = if (month > Calendar.DECEMBER) { Calendar.JANUARY } else { month }
                dom = 1
            }
            if (dtype != DateTimeRule.DOM) {
                dow += dshift
                if (dow < Calendar.SUNDAY) {
                    dow = Calendar.SATURDAY
                } else if (dow > Calendar.SATURDAY) {
                    dow = Calendar.SUNDAY
                }
            }
        }
        let modifiedRule: DateTimeRule
        if (dtype == DateTimeRule.DOM) {
            modifiedRule = DateTimeRule(month, dom, wallt, DateTimeRule.WALL_TIME)
        } else {
            modifiedRule = DateTimeRule(month, dom, dow, (dtype == DateTimeRule.DOW_GEQ_DOM), wallt, DateTimeRule.WALL_TIME)
        }
        return modifiedRule
    }

    private static func beginZoneProps(writer: StringWriter<OutputStream>, isDst: Bool, tzname: String, fromOffset: Int32, toOffset: Int32, startTime: Int64): Unit {
        writer.write(ICAL_BEGIN)
        writer.write(COLON)
        if (isDst) {
            writer.write(ICAL_DAYLIGHT)
        } else {
            writer.write(ICAL_STANDARD)
        }
        writer.write(NEWLINE)
        writer.write(ICAL_TZOFFSETTO)
        writer.write(COLON)
        writer.write(millisToOffset(toOffset))
        writer.write(NEWLINE)
        writer.write(ICAL_TZOFFSETFROM)
        writer.write(COLON)
        writer.write(millisToOffset(fromOffset))
        writer.write(NEWLINE)
        writer.write(ICAL_TZNAME)
        writer.write(COLON)
        writer.write(tzname)
        writer.write(NEWLINE)
        writer.write(ICAL_DTSTART)
        writer.write(COLON)
        writer.write(getDateTimeString(startTime + Int64(fromOffset)))
        writer.write(NEWLINE)
    }

    private static func endZoneProps(writer: StringWriter<OutputStream>, isDst: Bool): Unit {
        writer.write(ICAL_END)
        writer.write(COLON)
        if (isDst) {
            writer.write(ICAL_DAYLIGHT)
        } else {
            writer.write(ICAL_STANDARD)
        }
        writer.write(NEWLINE)
    }

    private static func beginRRULE(writer: StringWriter<OutputStream>, month: Int32): Unit {
        writer.write(ICAL_RRULE)
        writer.write(COLON)
        writer.write(ICAL_FREQ)
        writer.write(EQUALS_SIGN)
        writer.write(ICAL_YEARLY)
        writer.write(SEMICOLON)
        writer.write(ICAL_BYMONTH)
        writer.write(EQUALS_SIGN)
        writer.write((month + 1).toString())
        writer.write(SEMICOLON)
    }

    private static func appendUNTIL(writer: StringWriter<OutputStream>, until: String): Unit {
        if (until.isSome()) {
            writer.write(SEMICOLON)
            writer.write(ICAL_UNTIL)
            writer.write(EQUALS_SIGN)
            writer.write(until)
        }
    }

    private func writeHeader(writer: StringWriter<OutputStream>): Unit {
        writer.write(ICAL_BEGIN)
        writer.write(COLON)
        writer.write(ICAL_VTIMEZONE)
        writer.write(NEWLINE)
        writer.write(ICAL_TZID)
        writer.write(COLON)
        writer.write(tz.getID())
        writer.write(NEWLINE)
        if (tzurl.isSome()) {
            writer.write(ICAL_TZURL)
            writer.write(COLON)
            writer.write(tzurl)
            writer.write(NEWLINE)
        }
        if (lastmod.isSome()) {
            writer.write(ICAL_LASTMOD)
            writer.write(COLON)
            writer.write(getUTCDateTimeString(lastmod.getTime()))
            writer.write(NEWLINE)
        }
    }

    private static func writeFooter(writer: StringWriter<OutputStream>): Unit {
        writer.write(ICAL_END)
        writer.write(COLON)
        writer.write(ICAL_VTIMEZONE)
        writer.write(NEWLINE)
    }

    private static func getDateTimeString(time: Int64): String {
        let fields = Grego.timeToFields(time, None)
        let sb = StringBuilder()
        sb.append(numToString(fields[0], 4))
        sb.append(numToString(fields[1] + 1, 2))
        sb.append(numToString(fields[2], 2))
        sb.append('T')
        var t = fields[5]
        let hour = t / Grego.MILLIS_PER_HOUR
        t %= Grego.MILLIS_PER_HOUR
        let min = t / Grego.MILLIS_PER_MINUTE
        t %= Grego.MILLIS_PER_MINUTE
        let sec = t / Grego.MILLIS_PER_SECOND
        sb.append(numToString(hour, 2))
        sb.append(numToString(min, 2))
        sb.append(numToString(sec, 2))
        return sb.toString()
    }

    private static func getUTCDateTimeString(time: Int64): String {
        return (getDateTimeString(time)) + "Z"
    }

    private static func parseDateTimeString(str: String, offset: Int32): Int64 {
        var year = 0
        var month = 0
        var day = 0
        var hour = 0
        var min = 0
        var sec = 0
        var isUTC = false
        var isValid = false
            let length = Int32(str.size)
            if (length != 15 && length != 16) {
                break
            }
            if (Char(str[8]) != 'T') {
                break
            }
            if (length == 16) {
                if (Char(str[15]) != 'Z') {
                    break
                }
                isUTC = true
            }
            try {
                year = parse<Int32>(str[0..4])
                month = parse<Int32>(str[4..6]) - 1
                day = parse<Int32>(str[6..8])
                hour = parse<Int32>(str[9..11])
                min = parse<Int32>(str[11..13])
                sec = parse<Int32>(str[13..15])
            } catch (nfe: TimeParseException) {
                break
            }
            let maxDayOfMonth = Grego.monthLength(year, month)
            if (year < 0 || month < 0 || month > 11 || day < 1 || day > maxDayOfMonth || hour < 0 || hour >= 24 || min < 0 || min >= 60 || sec < 0 || sec >= 60) {
                break
            }
            isValid = true
        } while (false)
        if (!isValid) {
            throw IllegalArgumentException("Invalid date time string format")
        }
        var time = Grego.fieldsToDay(year, month, day) * Int64(Grego.MILLIS_PER_DAY)
        time += (Int64(hour * Grego.MILLIS_PER_HOUR + min * Grego.MILLIS_PER_MINUTE + sec * Grego.MILLIS_PER_SECOND))
        if (!isUTC) {
            time -= Int64(offset)
        }
        return time
    }

    private static func offsetStrToMillis(str: String): Int32 {
        var isValid = false
        var sign = 0
        var hour = 0
        var min = 0
        var sec = 0
            let length = Int32(str.size)
            if (length != 5 && length != 7) {
                break
            }
            let s = Char(str[0])
            if (s == '+') {
                sign = 1
            } else if (s == '-') {
                sign = -1
            } else {
                break
            }
            try {
                hour = parse<Int32>(str[1..3])
                min = parse<Int32>(str[3..5])
                if (length == 7) {
                    sec = parse<Int32>(str[5..7])
                }
            } catch (nfe: TimeParseException) {
                break
            }
            isValid = true
        } while (false)
        if (!isValid) {
            throw IllegalArgumentException("Bad offset string")
        }
        let millis = sign * ((hour * 60 + min) * 60 + sec) * 1000
        return millis
    }

    private static func millisToOffset(millis: Int32): String {
        var tempmillis = millis
        let sb = StringBuilder()
        if (tempmillis >= 0) {
            sb.append('+')
        } else {
            sb.append('-')
            tempmillis = -tempmillis
        }
        let hour: Int32
        let min: Int32
        let sec: Int32
        var t = tempmillis / 1000
        sec = t % 60
        t = (t - sec) / 60
        min = t % 60
        hour = t / 60
        sb.append(numToString(hour, 2))
        sb.append(numToString(min, 2))
        sb.append(numToString(sec, 2))
        return sb.toString()
    }

    private static func numToString(num: Int32, width: Int32): String {
        let str: String = num.toString()
        let len = Int32(str.size)
        if (len >= width) {
            return str[Int64(len - width)..Int64(len)]
        }
        let sb = StringBuilder()
        var i = len
        while (i < width) {
            sb.append('0')
            i++
        }
        sb.append(str)
        return sb.toString()
    }

      private var isFrozen = false

    public override func isFrozenMethod(): Bool {
        return isFrozen
    }

    public override func freeze(): TimeZone {
        isFrozen = true
        return this
    }

    public override func cloneAsThawed(): TimeZone {
        let vtz = super.cloneAsThawed()
        vtz.tz = tz.cloneAsThawed()
        vtz.isFrozen = false
        return vtz
    }
}
