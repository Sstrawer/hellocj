package icu4cj.impl.duration


class BasicPeriodBuilderFactory <: PeriodBuilderFactory {
    var ds: PeriodFormatterDataService

    private var settings: BasicPeriodBuilderFactory_Settings

    static let allBits = 255i16

    init(ds: PeriodFormatterDataService) {
        this.ds = ds
        this.settings = BasicPeriodBuilderFactory_Settings(this)
    }

    static func approximateDurationOf(unit: TimeUnit): Int64 {
        return TimeUnit.approxDurations[Int64(unit.ordinal)]
    }

    public override func setAvailableUnitRange(minUnit: TimeUnit, maxUnit: TimeUnit): PeriodBuilderFactory {
        var uset = 0
        var i = Int32(maxUnit.ordinal)
        while (i <= Int32(minUnit.ordinal)) {
            uset |= shl(1, i)
            i++
        }
        if (uset == 0) {
            throw IllegalArgumentException("range " + minUnit.asString() + " to " + maxUnit.asString() + " is empty")
        }
        settings = settings.setUnits(uset)
        return this
    }

    public override func setUnitIsAvailable(unit: TimeUnit, available: Bool): PeriodBuilderFactory {
        var uset = Int32(settings.uset)
        if (available) {
            uset |= shl(1, Int32(unit.ordinal))
        } else {
            uset &= 
        }
        settings = settings.setUnits(uset)
        return this
    }

    public override func setMaxLimit(maxLimit: Float32): PeriodBuilderFactory {
        settings = settings.setMaxLimit(maxLimit)
        return this
    }

    public override func setMinLimit(minLimit: Float32): PeriodBuilderFactory {
        settings = settings.setMinLimit(minLimit)
        return this
    }

    public override func setAllowZero(allow: Bool): PeriodBuilderFactory {
        settings = settings.setAllowZero(allow)
        return this
    }

    public override func setWeeksAloneOnly(aloneOnly: Bool): PeriodBuilderFactory {
        settings = settings.setWeeksAloneOnly(aloneOnly)
        return this
    }

    public override func setAllowMilliseconds(allow: Bool): PeriodBuilderFactory {
        settings = settings.setAllowMilliseconds(allow)
        return this
    }

    public override func setLocale(localeName: String): PeriodBuilderFactory {
        settings = settings.setLocale(localeName)
        return this
    }

    public override func setTimeZone(timeZone: TimeZone): PeriodBuilderFactory {
        return this
    }

    private func getSettings(): BasicPeriodBuilderFactory_Settings {
        if (Int32(settings.effectiveSet()) == 0) {
            return None
        }
        return settings.setInUse()
    }

    public override func getFixedUnitBuilder(unit: TimeUnit): PeriodBuilder {
        return FixedUnitBuilder.get(unit, getSettings())
    }

    public override func getSingleUnitBuilder(): PeriodBuilder {
        return SingleUnitBuilder.get(getSettings())
    }

    public override func getOneOrTwoUnitBuilder(): PeriodBuilder {
        return OneOrTwoUnitBuilder.get(getSettings())
    }

    public override func getMultiUnitBuilder(periodCount: Int32): PeriodBuilder {
        return MultiUnitBuilder.get(periodCount, getSettings())
    }
}


class BasicPeriodBuilderFactory_Settings {
    let this_0: BasicPeriodBuilderFactory

    init(this_0: BasicPeriodBuilderFactory) {
        this.this_0 = this_0
    }

    var inUse: Bool = false

    var uset = BasicPeriodBuilderFactory.allBits

    var maxUnit: TimeUnit = TimeUnit.YEAR

    var minUnit: TimeUnit = TimeUnit.MILLISECOND

    var maxLimit: Int32 = 0

    var minLimit: Int32 = 0

    var allowZero = true

    var weeksAloneOnly: Bool = false

    var allowMillis = true

    public func setUnits(uset: Int32): BasicPeriodBuilderFactory_Settings {
        if (Int32(this.uset) == uset) {
            return this
        }
        let result = if (inUse) { copy() } else { Some(this) }
        result.uset = Int16(uset)
        if ((uset & Int32(BasicPeriodBuilderFactory.allBits)) == Int32(BasicPeriodBuilderFactory.allBits)) {
            result.uset = BasicPeriodBuilderFactory.allBits
            result.maxUnit = TimeUnit.YEAR
            result.minUnit = TimeUnit.MILLISECOND
        } else {
            var lastUnit = -1
            var i = 0
            while (i < Int32(TimeUnit.units.size)) {
                if (0 != (uset & (shl(1, i)))) {
                    if (lastUnit == -1) {
                        result.maxUnit = TimeUnit.units[Int64(i)]
                    }
                    lastUnit = i
                }
                i++
            }
            if (lastUnit == -1) {
                result.minUnit = match (0) { case _ => result.maxUnit = None; result.maxUnit }
            } else {
                result.minUnit = TimeUnit.units[Int64(lastUnit)]
            }
        }
        return result
    }

    public func effectiveSet(): Int16 {
        if (allowMillis) {
            return uset
        }
        return Int16(Int32(uset) & )
    }

    public func effectiveMinUnit(): TimeUnit {
        if (allowMillis || !refEq(minUnit, TimeUnit.MILLISECOND)) {
            return minUnit
        }
        var i = Int32(TimeUnit.units.size) - 1
        while (match (0) { case _ => i--; i } >= 0) {
            if (0 != (Int32(uset) & (shl(1, i)))) {
                return TimeUnit.units[Int64(i)]
            }
        }
        return TimeUnit.SECOND
    }

    public func setMaxLimit(maxLimit: Float32): BasicPeriodBuilderFactory_Settings {
        let val = if (maxLimit <= 0.0) { 0 } else { Int32(maxLimit * 1000.0) }
        if (maxLimit == Float32(val)) {
            return this
        }
        let result = if (inUse) { copy() } else { Some(this) }
        result.maxLimit = val
        return result
    }

    public func setMinLimit(minLimit: Float32): BasicPeriodBuilderFactory_Settings {
        let val = if (minLimit <= 0.0) { 0 } else { Int32(minLimit * 1000.0) }
        if (minLimit == Float32(val)) {
            return this
        }
        let result = if (inUse) { copy() } else { Some(this) }
        result.minLimit = val
        return result
    }

    public func setAllowZero(allow: Bool): BasicPeriodBuilderFactory_Settings {
        if (this.allowZero == allow) {
            return this
        }
        let result = if (inUse) { copy() } else { Some(this) }
        result.allowZero = allow
        return result
    }

    public func setWeeksAloneOnly(weeksAlone: Bool): BasicPeriodBuilderFactory_Settings {
        if (this.weeksAloneOnly == weeksAlone) {
            return this
        }
        let result = if (inUse) { copy() } else { Some(this) }
        result.weeksAloneOnly = weeksAlone
        return result
    }

    public func setAllowMilliseconds(allowMillis: Bool): BasicPeriodBuilderFactory_Settings {
        if (this.allowMillis == allowMillis) {
            return this
        }
        let result = if (inUse) { copy() } else { Some(this) }
        result.allowMillis = allowMillis
        return result
    }

    public func setLocale(localeName: String): BasicPeriodBuilderFactory_Settings {
        let data = this_0.ds.get(localeName)
        return this.setAllowZero(data.allowZero()).setWeeksAloneOnly(data.weeksAloneOnly()).setAllowMilliseconds(data.useMilliseconds() != Int32(DataRecord_EMilliSupport.NO))
    }

    public func setInUse(): BasicPeriodBuilderFactory_Settings {
        inUse = true
        return this
    }

    public func createLimited(duration: Int64, inPast: Bool): Period {
        if (maxLimit > 0) {
            let maxUnitDuration = BasicPeriodBuilderFactory.approximateDurationOf(maxUnit)
            if (duration * 1000 > Int64(maxLimit) * maxUnitDuration) {
                return Period.moreThanStatic(Float32(maxLimit) / 1000.0, maxUnit).inPast(inPast)
            }
        }
        if (minLimit > 0) {
            let emu = effectiveMinUnit()
            let emud = BasicPeriodBuilderFactory.approximateDurationOf(emu)
            let eml = if (refEq(emu, minUnit)) { Int64(minLimit) } else { Math.max(1000, (BasicPeriodBuilderFactory.approximateDurationOf(minUnit) * Int64(minLimit)) / emud) }
            if (duration * 1000 < eml * emud) {
                return Period.lessThanStatic(Float32(eml) / 1000.0, emu).inPast(inPast)
            }
        }
        return None
    }

    public func copy(): BasicPeriodBuilderFactory_Settings {
        let result = BasicPeriodBuilderFactory_Settings(this_0)
        result.inUse = inUse
        result.uset = uset
        result.maxUnit = maxUnit
        result.minUnit = minUnit
        result.maxLimit = maxLimit
        result.minLimit = minLimit
        result.allowZero = allowZero
        result.weeksAloneOnly = weeksAloneOnly
        result.allowMillis = allowMillis
        return result
    }
}


abstract class PeriodBuilderImpl <: PeriodBuilder {
    protected var settings: BasicPeriodBuilderFactory_Settings

    public override func create(duration: Int64): Period {
        return createWithReferenceDate(duration, DateTime.now().toUnixTimeStamp().toMilliseconds())
    }

    public func approximateDurationOf(unit: TimeUnit): Int64 {
        return BasicPeriodBuilderFactory.approximateDurationOf(unit)
    }

    public override func createWithReferenceDate(duration: Int64, referenceDate: Int64): Period {
        var tempduration = duration
        let inPast = tempduration < 0
        if (inPast) {
            tempduration = -tempduration
        }
        var ts = settings.createLimited(tempduration, inPast)
        if (ts.isNone()) {
            ts = handleCreate(tempduration, referenceDate, inPast)
            if (ts.isNone()) {
                ts = Period.lessThanStatic(1.0, settings.effectiveMinUnit()).inPast(inPast)
            }
        }
        return ts
    }

    public override func withTimeZone(timeZone: TimeZone): PeriodBuilder {
        return this
    }

    public override func withLocale(localeName: String): PeriodBuilder {
        let newSettings = settings.setLocale(localeName)
        if (!refEq(newSettings, settings)) {
            return withSettings(newSettings)
        }
        return this
    }

    protected func withSettings(settingsToUse: BasicPeriodBuilderFactory_Settings): PeriodBuilder

    protected func handleCreate(duration: Int64, referenceDate: Int64, inPast: Bool): Period

    protected init(settings: BasicPeriodBuilderFactory_Settings) {
        this.settings = settings
    }
}


class FixedUnitBuilder <: PeriodBuilderImpl {
    private var unit: TimeUnit

    public static func get(unit: TimeUnit, settingsToUse: BasicPeriodBuilderFactory_Settings): FixedUnitBuilder {
        if (settingsToUse.isSome() && (Int32(settingsToUse.effectiveSet()) & (shl(1, Int32(unit.ordinal)))) != 0) {
            return FixedUnitBuilder(unit, settingsToUse)
        }
        return None
    }

    init(unit: TimeUnit, settings: BasicPeriodBuilderFactory_Settings) {
        super(settings)
        this.unit = unit
    }

    override protected func withSettings(settingsToUse: BasicPeriodBuilderFactory_Settings): PeriodBuilder {
        return get(unit, settingsToUse)
    }

    override protected func handleCreate(duration: Int64, referenceDate: Int64, inPast: Bool): Period {
        if (unit.isNone()) {
            return None
        }
        let unitDuration = approximateDurationOf(unit)
        return Period.atStatic(Float32(Float64(duration) / Float64(unitDuration)), unit).inPast(inPast)
    }
}


class SingleUnitBuilder <: PeriodBuilderImpl {
    init(settings: BasicPeriodBuilderFactory_Settings) {
        super(settings)
    }

    public static func get(settings: BasicPeriodBuilderFactory_Settings): SingleUnitBuilder {
        if (settings.isNone()) {
            return None
        }
        return SingleUnitBuilder(settings)
    }

    override protected func withSettings(settingsToUse: BasicPeriodBuilderFactory_Settings): PeriodBuilder {
        return SingleUnitBuilder.get(settingsToUse)
    }

    override protected func handleCreate(duration: Int64, referenceDate: Int64, inPast: Bool): Period {
        let uset = settings.effectiveSet()
        var i = 0
        while (i < Int32(TimeUnit.units.size)) {
            if (0 != (Int32(uset) & (shl(1, i)))) {
                let unit = TimeUnit.units[Int64(i)]
                let unitDuration = approximateDurationOf(unit)
                if (duration >= unitDuration) {
                    return Period.atStatic(Float32(Float64(duration) / Float64(unitDuration)), unit).inPast(inPast)
                }
            }
            i++
        }
        return None
    }
}


class OneOrTwoUnitBuilder <: PeriodBuilderImpl {
    init(settings: BasicPeriodBuilderFactory_Settings) {
        super(settings)
    }

    public static func get(settings: BasicPeriodBuilderFactory_Settings): OneOrTwoUnitBuilder {
        if (settings.isNone()) {
            return None
        }
        return OneOrTwoUnitBuilder(settings)
    }

    override protected func withSettings(settingsToUse: BasicPeriodBuilderFactory_Settings): PeriodBuilder {
        return OneOrTwoUnitBuilder.get(settingsToUse)
    }

    override protected func handleCreate(duration: Int64, referenceDate: Int64, inPast: Bool): Period {
        var tempduration = duration
        var period: Period
        let uset = settings.effectiveSet()
        var i = 0
        while (i < Int32(TimeUnit.units.size)) {
            if (0 != (Int32(uset) & (shl(1, i)))) {
                let unit = TimeUnit.units[Int64(i)]
                let unitDuration = approximateDurationOf(unit)
                if (tempduration >= unitDuration || period.isSome()) {
                    let count = Float64(tempduration) / Float64(unitDuration)
                    if (period.isNone()) {
                        if (count >= 2.0) {
                            period = Period.atStatic(Float32(count), unit)
                            break
                        }
                        period = Period.atStatic(1.0, unit).inPast(inPast)
                        tempduration -= unitDuration
                    } else {
                        if (count >= 1.0) {
                            period = period.and(Float32(count), unit)
                        }
                        break
                    }
                }
            }
            i++
        }
        return period
    }
}


class MultiUnitBuilder <: PeriodBuilderImpl {
    private var nPeriods: Int32 = 0

    init(nPeriods: Int32, settings: BasicPeriodBuilderFactory_Settings) {
        super(settings)
        this.nPeriods = nPeriods
    }

    public static func get(nPeriods: Int32, settings: BasicPeriodBuilderFactory_Settings): MultiUnitBuilder {
        if (nPeriods > 0 && settings.isSome()) {
            return MultiUnitBuilder(nPeriods, settings)
        }
        return None
    }

    override protected func withSettings(settingsToUse: BasicPeriodBuilderFactory_Settings): PeriodBuilder {
        return MultiUnitBuilder.get(nPeriods, settingsToUse)
    }

    override protected func handleCreate(duration: Int64, referenceDate: Int64, inPast: Bool): Period {
        var tempduration = duration
        var period: Period
        var n = 0
        let uset = settings.effectiveSet()
        var i = 0
        while (i < Int32(TimeUnit.units.size)) {
            if (0 != (Int32(uset) & (shl(1, i)))) {
                let unit = TimeUnit.units[Int64(i)]
                if (n == nPeriods) {
                    break
                }
                let unitDuration = approximateDurationOf(unit)
                if (tempduration >= unitDuration || n > 0) {
                    n++
                    var count = Float64(tempduration) / Float64(unitDuration)
                    if (n < nPeriods) {
                        count = floor(count)
                        tempduration -= Int64(count * Float64(unitDuration))
                    }
                    if (period.isNone()) {
                        period = Period.atStatic(Float32(count), unit).inPast(inPast)
                    } else {
                        period = period.and(Float32(count), unit)
                    }
                }
            }
            i++
        }
        return period
    }
}
