package icu4cj.impl

public class EraRules {
    private static let MAX_ENCODED_START_YEAR = 32767

    private static let MIN_ENCODED_START_YEAR = -32768

    public static let MIN_ENCODED_START = encodeDate(MIN_ENCODED_START_YEAR, 1, 1)

    private static let YEAR_MASK = -65536

    private static let MONTH_MASK = 65280

    private static let DAY_MASK = 255

    private var startDates: Array<Int32>

    private var numEras: Int32 = 0

    private var currentEra: Int32 = 0

    private init(startDates: Array<Int32>, numEras: Int32) {
        this.startDates = startDates
        this.numEras = numEras
        initCurrentEra()
    }

    public static func getInstance(calType: CalType, includeTentativeEra: Bool): EraRules {
        let supplementalDataRes = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "supplementalData", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
        let calendarDataRes = supplementalDataRes.get("calendarData")
        let calendarTypeRes = calendarDataRes.get(calType.getId())
        let erasRes = calendarTypeRes.get("eras")
        let numEras = erasRes.getSize()
        var firstTentativeIdx = Int32.Max
        let startDates = Array<Int32>(Int64(numEras)) { _ => 0 }
        let itr = erasRes.getIterator()
        while (itr.hasNext()) {
            let eraRuleRes = itr.next()
            let eraIdxStr = eraRuleRes.getKey()
            var eraIdx = -1
            try {
                eraIdx = parse<Int32>(eraIdxStr)
            } catch (e: TimeParseException) {
                throw ICUException("Invalid era rule key:" + (eraIdxStr) + " in era rule data for " + (calType.getId()))
            }
            if (eraIdx < 0 || eraIdx >= numEras) {
                throw ICUException("Era rule key:" + (eraIdxStr) + " in era rule data for " + (calType.getId()) + " must be in range [0, " + ((numEras - 1).toString()) + "]")
            }
            if (isSet(startDates[Int64(eraIdx)])) {
                throw ICUException("Duplicated era rule for rule key:" + (eraIdxStr) + " in era rule data for " + (calType.getId()))
            }
            var hasName = true
            var hasEnd = false
            let ruleItr = eraRuleRes.getIterator()
            while (ruleItr.hasNext()) {
                let res = ruleItr.next()
                let key = res.getKey()
                if (key == "start") {
                    let fields = res.getIntVector()
                    if (Int32(fields.size) != 3 || !isValidRuleStartDate(fields[0], fields[1], fields[2])) {
                        throw ICUException("Invalid era rule date data:" + (Arrays.toString(fields)) + " in era rule data for " + (calType.getId()))
                    }
                    startDates[Int64(eraIdx)] = encodeDate(fields[0], fields[1], fields[2])
                } else if (key == "named") {
                    let val = res.getString()
                    if (val == "false") {
                        hasName = false
                    }
                } else if (key == "end") {
                    hasEnd = true
                }
            }
            if (isSet(startDates[Int64(eraIdx)])) {
                if (hasEnd) { }
            } else {
                if (hasEnd) {
                    if (eraIdx != 0) {
                        throw ICUException("Era data for " + (eraIdxStr) + " in era rule data for " + (calType.getId()) + " has only end rule.")
                    }
                    startDates[Int64(eraIdx)] = MIN_ENCODED_START
                } else {
                    throw ICUException("Missing era start/end rule date for key:" + (eraIdxStr) + " in era rule data for " + (calType.getId()))
                }
            }
            if (hasName) {
                if (eraIdx >= firstTentativeIdx) {
                    throw ICUException("Non-tentative era(" + eraIdx.toString() + ") must be placed before the first tentative era")
                }
            } else {
                if (eraIdx < firstTentativeIdx) {
                    firstTentativeIdx = eraIdx
                }
            }
        }
        if (firstTentativeIdx < Int32.Max && !includeTentativeEra) {
            return EraRules(startDates, firstTentativeIdx)
        }
        return EraRules(startDates, numEras)
    }

    public func getNumberOfEras(): Int32 {
        return numEras
    }

    public func getStartDate(eraIdx: Int32, fillIn: Array<Int32>): Array<Int32> {
        if (eraIdx < 0 || eraIdx >= numEras) {
            throw IllegalArgumentException("eraIdx is out of range")
        }
        return decodeDate(startDates[Int64(eraIdx)], fillIn)
    }

    public func getStartYear(eraIdx: Int32): Int32 {
        if (eraIdx < 0 || eraIdx >= numEras) {
            throw IllegalArgumentException("eraIdx is out of range")
        }
        let fields = decodeDate(startDates[Int64(eraIdx)], None)
        return fields[0]
    }

    public func getEraIndex(year: Int32, month: Int32, day: Int32): Int32 {
        if (month < 1 || month > 12 || day < 1 || day > 31) {
            throw IllegalArgumentException("Illegal date - year:" + year.toString() + "month:" + month.toString() + "day:" + day.toString())
        }
        var high = numEras
        var low: Int32 = 0
        if (compareEncodedDateWithYMD(startDates[Int64(getCurrentEraIndex())], year, month, day) <= 0) {
            low = getCurrentEraIndex()
        } else {
            low = 0
        }
        while (low < high - 1) {
            let i = (low + high) / 2
            if (compareEncodedDateWithYMD(startDates[Int64(i)], year, month, day) <= 0) {
                low = i
            } else {
                high = i
            }
        }
        return low
    }

    public func getCurrentEraIndex(): Int32 {
        return currentEra
    }

    private func initCurrentEra(): Unit {
        var localMillis = DateTime.now().toUnixTimeStamp().toMilliseconds()
        let zone = TimeZone.getDefault()
        localMillis += Int64(zone.getOffset(localMillis))
        let fields = Grego.timeToFields(localMillis, None)
        let currentEncodedDate = encodeDate(fields[0], fields[1] + 1, fields[2])
        var eraIdx = numEras - 1
        while (eraIdx > 0) {
            if (currentEncodedDate >= startDates[Int64(eraIdx)]) {
                break
            }
            eraIdx--
        }
        currentEra = eraIdx
    }

    private static func isSet(startDate: Int32): Bool {
        return startDate != 0
    }

    private static func isValidRuleStartDate(year: Int32, month: Int32, day: Int32): Bool {
        return year >= MIN_ENCODED_START_YEAR && year <= MAX_ENCODED_START_YEAR && month >= 1 && month <= 12 && day >= 1 && day <= 31
    }

    private static func encodeDate(year: Int32, month: Int32, day: Int32): Int32 {
        return shl(year, 16) | shl(month, 8) | day
    }

    private static func decodeDate(encodedDate: Int32, fillIn: Array<Int32>): Array<Int32> {
        let year: Int32
        let month: Int32
        let day: Int32
        if (encodedDate == MIN_ENCODED_START) {
            year = Int32.Min
            month = 1
            day = 1
        } else {
            year = shr((encodedDate & YEAR_MASK), 16)
            month = shr((encodedDate & MONTH_MASK), 8)
            day = encodedDate & DAY_MASK
        }
        if (fillIn.isSome() && Int32(fillIn.size) >= 3) {
            fillIn[0] = year
            fillIn[1] = month
            fillIn[2] = day
            return fillIn
        }
        let result = [year, month, day]
        return result
    }

    private static func compareEncodedDateWithYMD(encoded: Int32, year: Int32, month: Int32, day: Int32): Int32 {
        if (year < MIN_ENCODED_START_YEAR) {
            if (encoded == MIN_ENCODED_START) {
                if (year > Int32.Min || month > 1 || day > 1) {
                    return -1
                }
                return 0
            } else {
                return 1
            }
        } else if (year > MAX_ENCODED_START_YEAR) {
            return -1
        } else {
            let tmp = encodeDate(year, month, day)
            if (encoded < tmp) {
                return -1
            } else if (encoded == tmp) {
                return 0
            } else {
                return 1
            }
        }
    }
}
