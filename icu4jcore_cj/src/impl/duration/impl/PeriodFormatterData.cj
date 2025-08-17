package icu4cj.impl.duration.impl


public class PeriodFormatterData {
    let dr: DataRecord

    var localeName: String

    public static var trace = false

    public init(localeName: String, dr: DataRecord) {
        this.dr = dr
        this.localeName = localeName
        if (localeName.isNone()) {
            throw NoneValueException("localename is null")
        }
        if (dr.isNone()) {
            throw NoneValueException("data record is null")
        }
    }

    public func pluralization(): Int32 {
        return Int32(dr.pl)
    }

    public func allowZero(): Bool {
        return dr.allowZero
    }

    public func weeksAloneOnly(): Bool {
        return dr.weeksAloneOnly
    }

    public func useMilliseconds(): Int32 {
        return Int32(dr.useMilliseconds)
    }

    public func appendPrefix(tl: Int32, td: Int32, sb: StringBuffer): Bool {
        if (dr.scopeData.isSome()) {
            let ix = tl * 3 + td
            let sd = dr.scopeData[Int64(ix)]
            if (sd.isSome()) {
                let prefix = sd.prefix
                if (prefix.isSome()) {
                    sb.append(prefix)
                    return sd.requiresDigitPrefix
                }
            }
        }
        return false
    }

    public func appendSuffix(tl: Int32, td: Int32, sb: StringBuffer): Unit {
        if (dr.scopeData.isSome()) {
            let ix = tl * 3 + td
            let sd = dr.scopeData[Int64(ix)]
            if (sd.isSome()) {
                let suffix = sd.suffix
                if (suffix.isSome()) {
                    if (trace) {
                        println("appendSuffix '" + (suffix) + "'")
                    }
                    sb.append(suffix)
                }
            }
        }
    }

    public func appendUnit(unit: TimeUnit, count: Int32, cv: Int32, uv: Int32, useCountSep: Bool, useDigitPrefix: Bool, multiple: Bool, last: Bool, wasSkipped: Bool, sb: StringBuffer): Bool {
        var tempcount = count
        var tempcv = cv
        let px = unit.ordinalMethod()
        var willRequireSkipMarker = false
        if (dr.requiresSkipMarker.isSome() && dr.requiresSkipMarker[Int64(px)] && dr.skippedUnitMarker.isSome()) {
            if (!wasSkipped && last) {
                sb.append(dr.skippedUnitMarker)
            }
            willRequireSkipMarker = true
        }
        if (uv != Int32(DataRecord_EUnitVariant.PLURALIZED)) {
            let useMedium = uv == Int32(DataRecord_EUnitVariant.MEDIUM)
            var names = if (useMedium) { dr.mediumNames } else { dr.shortNames }
            if (names.isNone() || names[Int64(px)].isNone()) {
                names = if (useMedium) { dr.shortNames } else { dr.mediumNames }
            }
            if (names.isSome() && names[Int64(px)].isSome()) {
                appendCount(unit, false, false, tempcount, tempcv, useCountSep, names[Int64(px)], last, sb)
                return false
            }
        }
        if (tempcv == Int32(DataRecord_ECountVariant.HALF_FRACTION) && dr.halfSupport.isSome()) {
            match (dr.halfSupport[Int64(px)]) {
                case 0u8 => ()
                case 2u8 => if (tempcount > 1000) {
                    break
                }
                case 1u8 =>
                    tempcount = (tempcount / 500) * 500
                    tempcv = Int32(DataRecord_ECountVariant.DECIMAL1)
                case _ => ()
            }
        }
        var name: String
        var form = computeForm(unit, tempcount, tempcv, multiple && last)
        if (form == FORM_SINGULAR_SPELLED) {
            if (dr.singularNames.isNone()) {
                form = FORM_SINGULAR
                name = dr.pluralNames[Int64(px)][Int64(form)]
            } else {
                name = dr.singularNames[Int64(px)]
            }
        } else if (form == FORM_SINGULAR_NO_OMIT) {
            name = dr.pluralNames[Int64(px)][Int64(FORM_SINGULAR)]
        } else if (form == FORM_HALF_SPELLED) {
            name = dr.halfNames[Int64(px)]
        } else {
            try {
                name = dr.pluralNames[Int64(px)][Int64(form)]
            } catch (e: NoneValueException) {
                println("Null Pointer in PeriodFormatterData[" + (localeName) + "].au px: " + px.toString() + " form: " + form.toString() + " pn: " + (Arrays.toString(dr.pluralNames)))
                throw e
            }
        }
        if (name.isNone()) {
            form = FORM_PLURAL
            name = dr.pluralNames[Int64(px)][Int64(form)]
        }
        let omitCount = (form == FORM_SINGULAR_SPELLED || form == FORM_HALF_SPELLED) || (dr.omitSingularCount && form == FORM_SINGULAR) || (dr.omitDualCount && form == FORM_DUAL)
        let suffixIndex = appendCount(unit, omitCount, useDigitPrefix, tempcount, tempcv, useCountSep, name, last, sb)
        if (last && suffixIndex >= 0) {
            var suffix: String
            if (dr.rqdSuffixes.isSome() && suffixIndex < Int32(dr.rqdSuffixes.size)) {
                suffix = dr.rqdSuffixes[Int64(suffixIndex)]
            }
            if (suffix.isNone() && dr.optSuffixes.isSome() && suffixIndex < Int32(dr.optSuffixes.size)) {
                suffix = dr.optSuffixes[Int64(suffixIndex)]
            }
            if (suffix.isSome()) {
                sb.append(suffix)
            }
        }
        return willRequireSkipMarker
    }

    public func appendCount(unit: TimeUnit, omitCount: Bool, useDigitPrefix: Bool, count: Int32, cv: Int32, useSep: Bool, name: String, last: Bool, sb: StringBuffer): Int32 {
        var tempcv = cv
        var tempname = name
        if (tempcv == Int32(DataRecord_ECountVariant.HALF_FRACTION) && dr.halves.isNone()) {
            tempcv = Int32(DataRecord_ECountVariant.INTEGER)
        }
        if (!omitCount && useDigitPrefix && dr.digitPrefix.isSome()) {
            sb.append(dr.digitPrefix)
        }
        var index = unit.ordinalMethod()
        match (tempcv) {
            case 0 => if (!omitCount) {
                appendInteger(count / 1000, 1, 10, sb)
            }
            case 1 =>
                var val = count / 1000
                if (refEq(unit, TimeUnit.MINUTE) && (dr.fiveMinutes.isSome() || dr.fifteenMinutes.isSome())) {
                    if (val != 0 && val % 5 == 0) {
                        if (dr.fifteenMinutes.isSome() && (val == 15 || val == 45)) {
                            val = if (val == 15) { 1 } else { 3 }
                            if (!omitCount) {
                                appendInteger(val, 1, 10, sb)
                            }
                            tempname = dr.fifteenMinutes
                            index = 8
                            break
                        }
                        if (dr.fiveMinutes.isSome()) {
                            val = val / 5
                            if (!omitCount) {
                                appendInteger(val, 1, 10, sb)
                            }
                            tempname = dr.fiveMinutes
                            index = 9
                            break
                        }
                    }
                }
                if (!omitCount) {
                    appendInteger(val, 1, 10, sb)
                }
            case 2 =>
                let v = count / 500
                if (v != 1) {
                    if (!omitCount) {
                        appendCountValue(count, 1, 0, sb)
                    }
                }
                if ((v & 1) == 1) {
                    if (v == 1 && dr.halfNames.isSome() && dr.halfNames[Int64(index)].isSome()) {
                        sb.append(tempname)
                        return if (last) { index } else { -1 }
                    }
                    var solox = if (v == 1) { 0 } else { 1 }
                    if (dr.genders.isSome() && Int32(dr.halves.size) > 2) {
                        if (dr.genders[Int64(index)] == DataRecord_EGender.F) {
                            solox += 2
                        }
                    }
                    let hp = if (dr.halfPlacements.isNone()) { Int32(DataRecord_EHalfPlacement.PREFIX) } else { Int32(dr.halfPlacements[Int64(solox & 1)]) }
                    let half = dr.halves[Int64(solox)]
                    let measure: String = if (dr.measures.isNone()) { None } else { dr.measures[Int64(index)] }
                    match (hp) {
                        case 0 => sb.append(half)
                        case 1 =>
                            {
                                if (measure.isSome()) {
                                    sb.append(measure)
                                    sb.append(half)
                                    if (useSep && !omitCount) {
                                        sb.append(dr.countSep)
                                    }
                                    sb.append(tempname)
                                } else {
                                    sb.append(tempname)
                                    sb.append(half)
                                    return if (last) { index } else { -1 }
                                }
                            }
                            return -1
                        case 2 =>
                            {
                                if (measure.isSome()) {
                                    sb.append(measure)
                                }
                                if (useSep && !omitCount) {
                                    sb.append(dr.countSep)
                                }
                                sb.append(tempname)
                                sb.append(half)
                            }
                            return if (last) { index } else { -1 }
                        case _ => ()
                    }
                }
            case _ =>
                var decimals = 1
                match (tempcv) {
                    case 4 => decimals = 2
                    case 5 => decimals = 3
                    case _ => ()
                }
                if (!omitCount) {
                    appendCountValue(count, 1, decimals, sb)
                }
        }
        if (!omitCount && useSep) {
            sb.append(dr.countSep)
        }
        if (!omitCount && dr.measures.isSome() && index < Int32(dr.measures.size)) {
            let measure = dr.measures[Int64(index)]
            if (measure.isSome()) {
                sb.append(measure)
            }
        }
        sb.append(tempname)
        return if (last) { index } else { -1 }
    }

    public func appendCountValue(count: Int32, integralDigits: Int32, decimalDigits: Int32, sb: StringBuffer): Unit {
        let ival = count / 1000
        if (decimalDigits == 0) {
            appendInteger(ival, integralDigits, 10, sb)
            return
        }
        if (dr.requiresDigitSeparator && Int32(sb.size) > 0) {
            sb.append(' ')
        }
        appendDigits(Int64(ival), integralDigits, 10, sb)
        var dval = count % 1000
        if (decimalDigits == 1) {
            dval /= 100
        } else if (decimalDigits == 2) {
            dval /= 10
        }
        sb.append(dr.decimalSep)
        appendDigits(Int64(dval), decimalDigits, decimalDigits, sb)
        if (dr.requiresDigitSeparator) {
            sb.append(' ')
        }
    }

    public func appendInteger(num: Int32, mindigits: Int32, maxdigits: Int32, sb: StringBuffer): Unit {
        if (dr.numberNames.isSome() && num < Int32(dr.numberNames.size)) {
            let name = dr.numberNames[Int64(num)]
            if (name.isSome()) {
                sb.append(name)
                return
            }
        }
        if (dr.requiresDigitSeparator && Int32(sb.size) > 0) {
            sb.append(' ')
        }
        match (dr.numberSystem) {
            case 0u8 => appendDigits(Int64(num), mindigits, maxdigits, sb)
            case 1u8 => sb.append(Utils.chineseNumber(Int64(num), Utils_ChineseDigits.TRADITIONAL))
            case 2u8 => sb.append(Utils.chineseNumber(Int64(num), Utils_ChineseDigits.SIMPLIFIED))
            case 3u8 => sb.append(Utils.chineseNumber(Int64(num), Utils_ChineseDigits.KOREAN))
            case _ => ()
        }
        if (dr.requiresDigitSeparator) {
            sb.append(' ')
        }
    }

    public func appendDigits(num: Int64, mindigits: Int32, maxdigits: Int32, sb: StringBuffer): Unit {
        var tempnum = num
        let buf = Array<Char>(Int64(maxdigits)) { _ => '\u{0000}' }
        var ix = maxdigits
        while (ix > 0 && tempnum > 0) {
            buf[Int64(match (0) { case _ => ix--; ix })] = Char(Int64(UInt32(dr.zero)) + (tempnum % 10))
            tempnum /= 10
        }
        let e = maxdigits - mindigits
        while (ix > e) {
            buf[Int64(match (0) { case _ => ix--; ix })] = dr.zero
        }
        sb.append(buf, ix, maxdigits - ix)
    }

    public func appendSkippedUnit(sb: StringBuffer): Unit {
        if (dr.skippedUnitMarker.isSome()) {
            sb.append(dr.skippedUnitMarker)
        }
    }

    public func appendUnitSeparator(unit: TimeUnit, longSep: Bool, afterFirst: Bool, beforeLast: Bool, sb: StringBuffer): Bool {
        if ((longSep && dr.unitSep.isSome()) || dr.shortUnitSep.isSome()) {
            if (longSep && dr.unitSep.isSome()) {
                let ix = (if (afterFirst) { 2 } else { 0 }) + (if (beforeLast) { 1 } else { 0 })
                sb.append(dr.unitSep[Int64(ix)])
                return dr.unitSepRequiresDP.isSome() && dr.unitSepRequiresDP[Int64(ix)]
            }
            sb.append(dr.shortUnitSep)
        }
        return false
    }

    private static let FORM_PLURAL = 0

    private static let FORM_SINGULAR = 1

    private static let FORM_DUAL = 2

    private static let FORM_PAUCAL = 3

    private static let FORM_SINGULAR_SPELLED = 4

    private static let FORM_SINGULAR_NO_OMIT = 5

    private static let FORM_HALF_SPELLED = 6

    private func computeForm(unit: TimeUnit, count: Int32, cv: Int32, lastOfMultiple: Bool): Int32 {
        if (trace) {
            eprintln("pfd.cf unit: " + unit.asString() + " count: " + count.toString() + " cv: " + cv.toString() + " dr.pl: " + dr.pl.toString())
            Thread.dumpStack()
        }
        if (dr.pl == DataRecord_EPluralization.NONE) {
            return FORM_PLURAL
        }
        let val = count / 1000
        match (cv) {
            case 0 | 1 =>
            case 2 => match (dr.fractionHandling) {
                case 0u8 => return FORM_PLURAL
                case 2u8 | 1u8 =>
                    let v = count / 500
                    if (v == 1) {
                        if (dr.halfNames.isSome() && dr.halfNames[Int64(unit.ordinalMethod())].isSome()) {
                            return FORM_HALF_SPELLED
                        }
                        return FORM_SINGULAR_NO_OMIT
                    }
                    if ((v & 1) == 1) {
                        if (dr.pl == DataRecord_EPluralization.ARABIC && v > 21) {
                            return FORM_SINGULAR_NO_OMIT
                        }
                        if (v == 3 && dr.pl == DataRecord_EPluralization.PLURAL && dr.fractionHandling != DataRecord_EFractionHandling.FSINGULAR_PLURAL_ANDAHALF) {
                            return FORM_PLURAL
                        }
                    }
                case 3u8 =>
                    let v = count / 500
                    if (v == 1 || v == 3) {
                        return FORM_PAUCAL
                    }
                case _ => throw Exception()
            }
            case _ =>
                match (dr.decimalHandling) {
                    case 0u8 => ()
                    case 1u8 => return FORM_SINGULAR_NO_OMIT
                    case 2u8 => if (count < 1000) {
                        return FORM_SINGULAR_NO_OMIT
                    }
                    case 3u8 => if (dr.pl == DataRecord_EPluralization.PAUCAL) {
                        return FORM_PAUCAL
                    }
                    case _ => ()
                }
                return FORM_PLURAL
        }
        if (trace && count == 0) {
            eprintln("EZeroHandling = " + dr.zeroHandling.toString())
        }
        if (count == 0 && dr.zeroHandling == DataRecord_EZeroHandling.ZSINGULAR) {
            return FORM_SINGULAR_SPELLED
        }
        var form = FORM_PLURAL
        match (dr.pl) {
            case 0u8 => ()
            case 1u8 => if (val == 1) {
                form = FORM_SINGULAR_SPELLED
            }
            case 2u8 => if (val == 2) {
                form = FORM_DUAL
            } else if (val == 1) {
                form = FORM_SINGULAR
            }
            case 3u8 =>
                var v = val
                v = v % 100
                if (v > 20) {
                    v = v % 10
                }
                if (v == 1) {
                    form = FORM_SINGULAR
                } else if (v > 1 && v < 5) {
                    form = FORM_PAUCAL
                }
            case 4u8 => if (val == 2) {
                form = FORM_DUAL
            } else if (val == 1) {
                if (lastOfMultiple) {
                    form = FORM_SINGULAR_SPELLED
                } else {
                    form = FORM_SINGULAR
                }
            } else if (refEq(unit, TimeUnit.YEAR) && val > 11) {
                form = FORM_SINGULAR_NO_OMIT
            }
            case 5u8 => if (val == 2) {
                form = FORM_DUAL
            } else if (val == 1) {
                form = FORM_SINGULAR
            } else if (val > 10) {
                form = FORM_SINGULAR_NO_OMIT
            }
            case _ =>
                eprintln("dr.pl is " + dr.pl.toString())
                throw Exception()
        }
        return form
    }
}
