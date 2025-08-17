package icu4cj.impl.duration


class BasicPeriodFormatter <: PeriodFormatter {
    private var factory: BasicPeriodFormatterFactory

    private var localeName: String

    private var data: PeriodFormatterData

    private var customs: BasicPeriodFormatterFactory_Customizations

    init(factory: BasicPeriodFormatterFactory, localeName: String, data: PeriodFormatterData, customs: BasicPeriodFormatterFactory_Customizations) {
        this.factory = factory
        this.localeName = localeName
        this.data = data
        this.customs = customs
    }

    public override func format(period: Period): String {
        if (!period.isSet()) {
            throw IllegalArgumentException("period is not set")
        }
        return format(Int32(period.timeLimit), period.inFuture, period.counts)
    }

    public override func withLocale(locName: String): PeriodFormatter {
        if (!this.localeName.equals(locName)) {
            let newData = factory.getData(locName)
            return BasicPeriodFormatter(factory, locName, newData, customs)
        }
        return this
    }

    private func format(tl: Int32, inFuture: Bool, counts: Array<Int32>): String {
        var temptl = tl
        var mask = 0
                i++
            }
        } while (false)
        if (!data.allowZero()) {
                    i++
                    m <<= 1
                }
            } while (false)
            if (mask == 0) {
                return None
            }
        }
        var forceD3Seconds = false
        if (data.useMilliseconds() != Int32(DataRecord_EMilliSupport.YES) && (mask & (shl(1, Int32(TimeUnit.MILLISECOND.ordinal)))) != 0) {
            let sx = Int32(TimeUnit.SECOND.ordinal)
            let mx = Int32(TimeUnit.MILLISECOND.ordinal)
            let sf = shl(1, sx)
            let mf = shl(1, mx)
            match (data.useMilliseconds()) {
                case 2 => if ((mask & sf) != 0) {
                    counts[Int64(sx)] += (counts[Int64(mx)] - 1) / 1000
                    mask &= 
                    forceD3Seconds = true
                }
                case 1 =>
                    if ((mask & sf) == 0) {
                        mask |= sf
                        counts[Int64(sx)] = 1
                    }
                    counts[Int64(sx)] += (counts[Int64(mx)] - 1) / 1000
                    mask &= 
                    forceD3Seconds = true
                case _ => ()
            }
        }
        var first = 0
        var last = Int32(counts.size) - 1
        while (first < Int32(counts.size) && (mask & (shl(1, first))) == 0) {
            first++
        }
        while (last > first && (mask & (shl(1, last))) == 0) {
            last--
        }
        var isZero = true
                i++
            }
        } while (false)
        let sb = StringBuffer()
        if (!customs.displayLimit || isZero) {
            temptl = Int32(DataRecord_ETimeLimit.NOLIMIT)
        }
        let td: Int32
        if (!customs.displayDirection || isZero) {
            td = Int32(DataRecord_ETimeDirection.NODIRECTION)
        } else {
            td = if (inFuture) { Int32(DataRecord_ETimeDirection.FUTURE) } else { Int32(DataRecord_ETimeDirection.PAST) }
        }
        var useDigitPrefix = data.appendPrefix(temptl, td, sb)
        let multiple = first != last
        var wasSkipped = true
        var skipped = false
        let countSep = customs.separatorVariant != DataRecord_ESeparatorVariant.NONE
                while (match (0) { case _ => j++; j } < last && (mask & (shl(1, j))) == 0) {
                    skipped = true
                }
                let unit = TimeUnit.units[Int64(i)]
                let count = counts[Int64(i)] - 1
                var cv = Int32(customs.countVariant)
                if (i == last) {
                    if (forceD3Seconds) {
                        cv = Int32(DataRecord_ECountVariant.DECIMAL3)
                    }
                } else {
                    cv = Int32(DataRecord_ECountVariant.INTEGER)
                }
                let isLast = i == last
                let mustSkip = data.appendUnit(unit, count, cv, Int32(customs.unitVariant), countSep, useDigitPrefix, multiple, isLast, wasSkipped, sb)
                skipped |= mustSkip
                wasSkipped = false
                if (customs.separatorVariant != DataRecord_ESeparatorVariant.NONE && j <= last) {
                    let afterFirst = i == first
                    let beforeLast = j == last
                    let fullSep = customs.separatorVariant == DataRecord_ESeparatorVariant.FULL
                    useDigitPrefix = data.appendUnitSeparator(unit, fullSep, afterFirst, beforeLast, sb)
                } else {
                    useDigitPrefix = false
                }
                i = j
            }
        } while (false)
        data.appendSuffix(temptl, td, sb)
        return toString(sb)
    }
}
