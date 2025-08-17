package icu4cj.util


public class LocaleMatcher {
    private static let UND_LSR = LSR("und", "", "", LSR.EXPLICIT_LSR)

    private static let UND_ULOCALE = ULocale("und")

    private static let UND_LOCALE = Locale("und")

    private static let EMPTY_LOCALE = Locale("")

    private static let TRACE_MATCHER = false

    private let thresholdDistance: Int32

    private let demotionPerDesiredLocale: Int32

    private let favorSubtag: LocaleMatcher_FavorSubtag

    private let direction: LocaleMatcher_Direction

    private let supportedULocales: Array<ULocale>

    private let supportedLocales: Array<Locale>

    private let supportedLsrToIndex: Map<LSR, Int32>

    private let supportedLSRs: Array<LSR>

    private let supportedIndexes: Array<Int32>

    private let supportedLSRsLength: Int32

    private let defaultULocale: ULocale

    private let defaultLocale: Locale

    public static func builder(): LocaleMatcher_Builder {
        return LocaleMatcher_Builder()
    }

    public init(supportedLocales: LocalePriorityList) {
        this(builder().setSupportedULocales(supportedLocales.getULocales()))
    }

    public init(supportedLocales: String) {
        this(builder().setSupportedLocales(supportedLocales))
    }

    init(builder: LocaleMatcher_Builder) {
        var udef = builder.defaultLocale
        var def: Locale = None
        var defLSR: LSR
        if (udef.isSome()) {
            def = udef.toLocale()
            defLSR = getMaximalLsrOrUnd(udef)
        }
        let supportedLocalesLength = if (builder.supportedLocales.isSome()) { Int32(builder.supportedLocales.size) } else { 0 }
        supportedULocales = Array<ULocale>(Int64(supportedLocalesLength))
        supportedLocales = Array<Locale>(Int64(supportedLocalesLength))
        let lsrs = Array<LSR>(Int64(supportedLocalesLength))
        var i = 0
        if (supportedLocalesLength > 0) {
            for (locale in builder.supportedLocales) {
                supportedULocales[Int64(i)] = locale
                supportedLocales[Int64(i)] = locale.toLocale()
                lsrs[Int64(i)] = getMaximalLsrOrUnd(locale)
                i++
            }
        }
        supportedLsrToIndex = HashMap<LSR, Int32>(Int64(supportedLocalesLength))
        supportedLSRs = Array<LSR>(Int64(supportedLocalesLength))
        supportedIndexes = Array<Int32>(Int64(supportedLocalesLength)) { _ => 0 }
        var suppLength = 0
        let order = Array<UInt8>(Int64(supportedLocalesLength)) { _ => 0 }
        var numParadigms = 0
        i = 0
        for (locale in supportedULocales) {
            let lsr = lsrs[Int64(i)]
            if (defLSR.isNone() && builder.withDefault) {
                if (!(i == 0)) {
                    throw AssertionError()
                }
                udef = locale
                def = supportedLocales[0]
                defLSR = lsr
                suppLength = putIfAbsent(lsr, 0, suppLength)
            } else if (defLSR.isSome() && lsr.isEquivalentTo(defLSR)) {
                suppLength = putIfAbsent(lsr, i, suppLength)
            } else if (LocaleDistance.INSTANCE.isParadigmLSR(lsr)) {
                order[Int64(i)] = 2
                numParadigms++
            } else {
                order[Int64(i)] = 3
            }
            i++
        }
        let paradigmLimit = suppLength + numParadigms
        i = 0
        while (i < supportedLocalesLength && suppLength < paradigmLimit) {
            if (Int32(order[Int64(i)]) == 2) {
                suppLength = putIfAbsent(lsrs[Int64(i)], i, suppLength)
            }
            i++
        }
        i = 0
        while (i < supportedLocalesLength) {
            if (Int32(order[Int64(i)]) == 3) {
                suppLength = putIfAbsent(lsrs[Int64(i)], i, suppLength)
            }
            i++
        }
        supportedLSRsLength = suppLength
        defaultULocale = udef
        defaultLocale = def
        demotionPerDesiredLocale = if (refEq(builder.demotion, LocaleMatcher_Demotion.NONE)) { 0 } else { LocaleDistance.INSTANCE.getDefaultDemotionPerDesiredLocale() }
        favorSubtag = builder.favor
        direction = builder.direction
        let threshold: Int32
        if (builder.thresholdDistance >= 0) {
            threshold = builder.thresholdDistance
        } else if (builder.maxDistanceDesired.isSome()) {
            let indexAndDistance = LocaleDistance.INSTANCE.getBestIndexAndDistance(getMaximalLsrOrUnd(builder.maxDistanceDesired), [getMaximalLsrOrUnd(builder.maxDistanceSupported)], 1, LocaleDistance.shiftDistance(100), favorSubtag, direction)
            threshold = LocaleDistance.getDistanceFloor(indexAndDistance) + 1
        } else {
            threshold = LocaleDistance.INSTANCE.getDefaultScriptDistance()
        }
        thresholdDistance = threshold
        if (TRACE_MATCHER) {
            Console.stdErr.printf("new LocaleMatcher: %s\n", [toString()])
        }
    }

    private func putIfAbsent(lsr: LSR, i: Int32, suppLength: Int32): Int32 {
        var tempsuppLength = suppLength
        if (!supportedLsrToIndex.contains(lsr)) {
            supportedLsrToIndex.put(lsr, i)
            supportedLSRs[Int64(tempsuppLength)] = lsr
            supportedIndexes[Int64(match (0) { case _ => tempsuppLength++; tempsuppLength - 1 })] = i
        }
        return tempsuppLength
    }

    static func getMaximalLsrOrUnd(locale: ULocale): LSR {
        if (locale.equals(UND_ULOCALE)) {
            return UND_LSR
        } else {
            return LikelySubtags.INSTANCE.makeMaximizedLsrFrom(locale, false)
        }
    }

    static func getMaximalLsrOrUnd(locale: Locale): LSR {
        if (refEq(locale, UND_LOCALE) || refEq(locale, EMPTY_LOCALE)) {
            return UND_LSR
        } else {
            return LikelySubtags.INSTANCE.makeMaximizedLsrFrom(locale)
        }
    }

    public func getBestMatch(desiredLocale: ULocale): ULocale {
        let desiredLSR = getMaximalLsrOrUnd(desiredLocale)
        let suppIndex = getBestSuppIndex(desiredLSR, None)
        return if (suppIndex >= 0) { supportedULocales[Int64(suppIndex)] } else { defaultULocale }
    }

    public func getBestMatch(desiredLocales: Iterable<ULocale>): ULocale {
        let desiredIter: Iterator<ULocale> = desiredLocales.iterator()
        if (!desiredIter.hasNext()) {
            return defaultULocale
        }
        let lsrIter = LocaleMatcher_ULocaleLsrIterator(desiredIter)
        let desiredLSR = lsrIter.next()
        let suppIndex = getBestSuppIndex(desiredLSR, lsrIter)
        return if (suppIndex >= 0) { supportedULocales[Int64(suppIndex)] } else { defaultULocale }
    }

    public func getBestMatch(desiredLocaleList: String): ULocale {
        return getBestMatch(LocalePriorityList.add(desiredLocaleList).build())
    }

    public func getBestLocale(desiredLocale: Locale): Locale {
        let desiredLSR = getMaximalLsrOrUnd(desiredLocale)
        let suppIndex = getBestSuppIndex(desiredLSR, None)
        return if (suppIndex >= 0) { supportedLocales[Int64(suppIndex)] } else { defaultLocale }
    }

    public func getBestLocale(desiredLocales: Iterable<Locale>): Locale {
        let desiredIter: Iterator<Locale> = desiredLocales.iterator()
        if (!desiredIter.hasNext()) {
            return defaultLocale
        }
        let lsrIter = LocaleMatcher_LocaleLsrIterator(desiredIter)
        let desiredLSR = lsrIter.next()
        let suppIndex = getBestSuppIndex(desiredLSR, lsrIter)
        return if (suppIndex >= 0) { supportedLocales[Int64(suppIndex)] } else { defaultLocale }
    }

    private func defaultResult(): LocaleMatcher_Result {
        return LocaleMatcher_Result(None, defaultULocale, None, defaultLocale, -1, -1)
    }

    private func makeResult(desiredLocale: ULocale, lsrIter: LocaleMatcher_ULocaleLsrIterator, suppIndex: Int32): LocaleMatcher_Result {
        if (suppIndex < 0) {
            return defaultResult()
        } else if (desiredLocale.isSome()) {
            return LocaleMatcher_Result(desiredLocale, supportedULocales[Int64(suppIndex)], None, supportedLocales[Int64(suppIndex)], 0, suppIndex)
        } else {
            return LocaleMatcher_Result(lsrIter.remembered, supportedULocales[Int64(suppIndex)], None, supportedLocales[Int64(suppIndex)], lsrIter.bestDesiredIndex, suppIndex)
        }
    }

    private func makeResult(desiredLocale: Locale, lsrIter: LocaleMatcher_LocaleLsrIterator, suppIndex: Int32): LocaleMatcher_Result {
        if (suppIndex < 0) {
            return defaultResult()
        } else if (desiredLocale.isSome()) {
            return LocaleMatcher_Result(None, supportedULocales[Int64(suppIndex)], desiredLocale, supportedLocales[Int64(suppIndex)], 0, suppIndex)
        } else {
            return LocaleMatcher_Result(None, supportedULocales[Int64(suppIndex)], lsrIter.remembered, supportedLocales[Int64(suppIndex)], lsrIter.bestDesiredIndex, suppIndex)
        }
    }

    public func getBestMatchResult(desiredLocale: ULocale): LocaleMatcher_Result {
        let desiredLSR = getMaximalLsrOrUnd(desiredLocale)
        let suppIndex = getBestSuppIndex(desiredLSR, None)
        return makeResult(desiredLocale, None, suppIndex)
    }

    public func getBestMatchResult(desiredLocales: Iterable<ULocale>): LocaleMatcher_Result {
        let desiredIter: Iterator<ULocale> = desiredLocales.iterator()
        if (!desiredIter.hasNext()) {
            return defaultResult()
        }
        let lsrIter = LocaleMatcher_ULocaleLsrIterator(desiredIter)
        let desiredLSR = lsrIter.next()
        let suppIndex = getBestSuppIndex(desiredLSR, lsrIter)
        return makeResult(None, lsrIter, suppIndex)
    }

    public func getBestLocaleResult(desiredLocale: Locale): LocaleMatcher_Result {
        let desiredLSR = getMaximalLsrOrUnd(desiredLocale)
        let suppIndex = getBestSuppIndex(desiredLSR, None)
        return makeResult(desiredLocale, None, suppIndex)
    }

    public func getBestLocaleResult(desiredLocales: Iterable<Locale>): LocaleMatcher_Result {
        let desiredIter: Iterator<Locale> = desiredLocales.iterator()
        if (!desiredIter.hasNext()) {
            return defaultResult()
        }
        let lsrIter = LocaleMatcher_LocaleLsrIterator(desiredIter)
        let desiredLSR = lsrIter.next()
        let suppIndex = getBestSuppIndex(desiredLSR, lsrIter)
        return makeResult(None, lsrIter, suppIndex)
    }

    private func getBestSuppIndex(desiredLSR: LSR, remainingIter: LocaleMatcher_LsrIterator): Int32 {
        var tempdesiredLSR = desiredLSR
        var desiredIndex = 0
        var bestSupportedLsrIndex = -1
        let sb: StringBuilder = None
        if (TRACE_MATCHER) {
            sb = StringBuilder("LocaleMatcher desired:")
        }
        var bestShiftedDistance = LocaleDistance.shiftDistance(thresholdDistance)
        while (true) {
            if (TRACE_MATCHER) {
                sb.append(' ').append(tempdesiredLSR.asString())
            }
            let index = supportedLsrToIndex.get(tempdesiredLSR)
            if (index.isSome()) {
                let suppIndex = index
                if (TRACE_MATCHER) {
                    Console.stdErr.printf("%s --> best=%s: desiredLSR=supportedLSR\n", [sb, supportedULocales[Int64(suppIndex)]])
                }
                if (remainingIter.isSome()) {
                    remainingIter.rememberCurrent(desiredIndex)
                }
                return suppIndex
            }
            let bestIndexAndDistance = LocaleDistance.INSTANCE.getBestIndexAndDistance(tempdesiredLSR, supportedLSRs, supportedLSRsLength, bestShiftedDistance, favorSubtag, direction)
            if (bestIndexAndDistance >= 0) {
                bestShiftedDistance = LocaleDistance.getShiftedDistance(bestIndexAndDistance)
                if (remainingIter.isSome()) {
                    remainingIter.rememberCurrent(desiredIndex)
                }
                bestSupportedLsrIndex = LocaleDistance.getIndex(bestIndexAndDistance)
            }
            if ((bestShiftedDistance <= 0) {
                break
            }
            if (remainingIter.isNone() || !remainingIter.hasNext()) {
                break
            }
            tempdesiredLSR = remainingIter.next()
            desiredIndex++
        }
        if (bestSupportedLsrIndex < 0) {
            if (TRACE_MATCHER) {
                Console.stdErr.printf("%s --> best=default %s: no good match\n", [sb, defaultULocale])
            }
            return -1
        }
        let suppIndex = supportedIndexes[Int64(bestSupportedLsrIndex)]
        if (TRACE_MATCHER) {
            Console.stdErr.printf("%s --> best=%s: best matching supported locale\n", [sb, supportedULocales[Int64(suppIndex)]])
        }
        return suppIndex
    }

    public func isMatch(desired: Locale, supported: Locale): Bool {
        let indexAndDistance = LocaleDistance.INSTANCE.getBestIndexAndDistance(getMaximalLsrOrUnd(desired), [getMaximalLsrOrUnd(supported)], 1, LocaleDistance.shiftDistance(thresholdDistance), favorSubtag, direction)
        return indexAndDistance >= 0
    }

    public func isMatch(desired: ULocale, supported: ULocale): Bool {
        let indexAndDistance = LocaleDistance.INSTANCE.getBestIndexAndDistance(getMaximalLsrOrUnd(desired), [getMaximalLsrOrUnd(supported)], 1, LocaleDistance.shiftDistance(thresholdDistance), favorSubtag, direction)
        return indexAndDistance >= 0
    }

    
    public func match(desired: ULocale, desiredMax: ULocale, supported: ULocale, supportedMax: ULocale): Float64 {
        let indexAndDistance = LocaleDistance.INSTANCE.getBestIndexAndDistance(getMaximalLsrOrUnd(desired), [getMaximalLsrOrUnd(supported)], 1, LocaleDistance.shiftDistance(thresholdDistance), favorSubtag, direction)
        let distance = LocaleDistance.getDistanceDouble(indexAndDistance)
        if (TRACE_MATCHER) {
            Console.stdErr.printf("LocaleMatcher distance(desired=%s, supported=%s)=%g\n", [String.valueOf(desired), String.valueOf(supported), distance])
        }
        return (100.0 - distance) / 100.0
    }

    public func canonicalize(locale: ULocale): ULocale {
        return LikelySubtags.INSTANCE.canonicalize(locale)
    }

    public override func toString(): String {
        let s: StringBuilder = StringBuilder().append("{LocaleMatcher")
        if (supportedLSRsLength > 0) {
            s.append(" supportedLSRs={").append(supportedLSRs[0].asString())
            var i = 1
            while (i < supportedLSRsLength) {
                s.append(", ").append(supportedLSRs[Int64(i)].asString())
                i++
            }
            s.append('}')
        }
        s.append(" default=").append(defaultULocale.asString())
        if (favorSubtag.isSome()) {
            s.append(" favor=").append(favorSubtag.asString())
        }
        if (direction.isSome()) {
            s.append(" direction=").append(direction.asString())
        }
        if (thresholdDistance >= 0) {
            s.append(String.format(" threshold=%d", [thresholdDistance]))
        }
        s.append(String.format(" demotion=%d", [demotionPerDesiredLocale]))
        return s.append('}').toString()
    }
}


abstract class LocaleMatcher_LsrIterator <: Iterator<LSR> {

    var bestDesiredIndex = -1

    public override func remove(): Unit {
        throw UnsupportedOperationException()
    }

    public func rememberCurrent(desiredIndex: Int32): Unit
}


public class LocaleMatcher_FavorSubtag <: Enum<LocaleMatcher_FavorSubtag> {
    public static let LANGUAGE = LocaleMatcher_FavorSubtag("LANGUAGE", 0)

    public static let SCRIPT = LocaleMatcher_FavorSubtag("SCRIPT", 1)

    private static func _values(): Array<LocaleMatcher_FavorSubtag> {
        return [LocaleMatcher_FavorSubtag.LANGUAGE, LocaleMatcher_FavorSubtag.SCRIPT]
    }

    private static let _VALUES = LocaleMatcher_FavorSubtag._values()

    public static func values(): Array<LocaleMatcher_FavorSubtag> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): LocaleMatcher_FavorSubtag {
        return (TypeInfo.of<LocaleMatcher_FavorSubtag>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as LocaleMatcher_FavorSubtag
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class LocaleMatcher_Demotion <: Enum<LocaleMatcher_Demotion> {
    public static let NONE = LocaleMatcher_Demotion("NONE", 0)

    public static let REGION = LocaleMatcher_Demotion("REGION", 1)

    private static func _values(): Array<LocaleMatcher_Demotion> {
        return [LocaleMatcher_Demotion.NONE, LocaleMatcher_Demotion.REGION]
    }

    private static let _VALUES = LocaleMatcher_Demotion._values()

    public static func values(): Array<LocaleMatcher_Demotion> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): LocaleMatcher_Demotion {
        return (TypeInfo.of<LocaleMatcher_Demotion>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as LocaleMatcher_Demotion
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class LocaleMatcher_Direction <: Enum<LocaleMatcher_Direction> {
    public static let WITH_ONE_WAY = LocaleMatcher_Direction("WITH_ONE_WAY", 0)

    public static let ONLY_TWO_WAY = LocaleMatcher_Direction("ONLY_TWO_WAY", 1)

    private static func _values(): Array<LocaleMatcher_Direction> {
        return [LocaleMatcher_Direction.WITH_ONE_WAY, LocaleMatcher_Direction.ONLY_TWO_WAY]
    }

    private static let _VALUES = LocaleMatcher_Direction._values()

    public static func values(): Array<LocaleMatcher_Direction> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): LocaleMatcher_Direction {
        return (TypeInfo.of<LocaleMatcher_Direction>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as LocaleMatcher_Direction
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class LocaleMatcher_Result {
    private let desiredULocale: ULocale

    private let supportedULocale: ULocale

    private let desiredLocale: Locale

    private let supportedLocale: Locale

    private let desiredIndex: Int32

    private let supportedIndex: Int32

    init(udesired: ULocale, usupported: ULocale, desired: Locale, supported: Locale, desIndex: Int32, suppIndex: Int32) {
        desiredULocale = udesired
        supportedULocale = usupported
        desiredLocale = desired
        supportedLocale = supported
        desiredIndex = desIndex
        supportedIndex = suppIndex
    }

    public func getDesiredULocale(): ULocale {
        return if (desiredULocale.isNone() && desiredLocale.isSome()) { ULocale.forLocale(desiredLocale) } else { desiredULocale }
    }

    public func getDesiredLocale(): Locale {
        return if (desiredLocale.isNone() && desiredULocale.isSome()) { desiredULocale.toLocale() } else { desiredLocale }
    }

    public func getSupportedULocale(): ULocale {
        return supportedULocale
    }

    public func getSupportedLocale(): Locale {
        return supportedLocale
    }

    public func getDesiredIndex(): Int32 {
        return desiredIndex
    }

    public func getSupportedIndex(): Int32 {
        return supportedIndex
    }

    public func makeResolvedULocale(): ULocale {
        let bestDesired = getDesiredULocale()
        if (supportedULocale.isNone() || bestDesired.isNone() || supportedULocale.equals(bestDesired)) {
            return supportedULocale
        }
        let b = ULocale_Builder().setLocale(supportedULocale)
        let region = bestDesired.getCountry()
        if (!region.isEmpty()) {
            b.setRegion(region)
        }
        let variants = bestDesired.getVariant()
        if (!variants.isEmpty()) {
            b.setVariant(variants)
        }
        for (extensionKey in bestDesired.getExtensionKeys()) {
            b.setExtension(extensionKey, bestDesired.getExtension(extensionKey))
        }
        return b.build()
    }

    public func makeResolvedLocale(): Locale {
        let resolved = makeResolvedULocale()
        return if (resolved.isSome()) { resolved.toLocale() } else { None }
    }
}


public class LocaleMatcher_Builder {
    var supportedLocales: ArrayList<ULocale>

    var thresholdDistance = -1

    var demotion: LocaleMatcher_Demotion

    var defaultLocale: ULocale

    var withDefault = true

    var favor: LocaleMatcher_FavorSubtag

    var direction: LocaleMatcher_Direction

    var maxDistanceDesired: ULocale

    var maxDistanceSupported: ULocale


    public func setSupportedLocales(locales: String): LocaleMatcher_Builder {
        return setSupportedULocales(LocalePriorityList.add(locales).build().getULocales())
    }

    public func setSupportedULocales(locales: Collection<ULocale>): LocaleMatcher_Builder {
        supportedLocales = ArrayList<ULocale>(locales)
        return this
    }

    public func setSupportedLocales(locales: Collection<Locale>): LocaleMatcher_Builder {
        supportedLocales = ArrayList<ULocale>(locales.size)
        for (locale in locales) {
            supportedLocales.append(ULocale.forLocale(locale))
        }
        return this
    }

    public func addSupportedULocale(locale: ULocale): LocaleMatcher_Builder {
        if (supportedLocales.isNone()) {
            supportedLocales = ArrayList<ULocale>()
        }
        supportedLocales.append(locale)
        return this
    }

    public func addSupportedLocale(locale: Locale): LocaleMatcher_Builder {
        return addSupportedULocale(ULocale.forLocale(locale))
    }

    public func setNoDefaultLocale(): LocaleMatcher_Builder {
        this.defaultLocale = None
        withDefault = false
        return this
    }

    public func setDefaultULocale(defaultLocale: ULocale): LocaleMatcher_Builder {
        this.defaultLocale = defaultLocale
        withDefault = true
        return this
    }

    public func setDefaultLocale(defaultLocale: Locale): LocaleMatcher_Builder {
        this.defaultLocale = ULocale.forLocale(defaultLocale)
        withDefault = true
        return this
    }

    public func setFavorSubtag(subtag: LocaleMatcher_FavorSubtag): LocaleMatcher_Builder {
        this.favor = subtag
        return this
    }

    public func setDemotionPerDesiredLocale(demotion: LocaleMatcher_Demotion): LocaleMatcher_Builder {
        this.demotion = demotion
        return this
    }

    public func setDirection(direction: LocaleMatcher_Direction): LocaleMatcher_Builder {
        this.direction = direction
        return this
    }

    public func setMaxDistance(desired: Locale, supported: Locale): LocaleMatcher_Builder {
        if (desired.isNone() || supported.isNone()) {
            throw IllegalArgumentException("desired/supported locales must not be null")
        }
        return setMaxDistance(ULocale.forLocale(desired), ULocale.forLocale(supported))
    }

    public func setMaxDistance(desired: ULocale, supported: ULocale): LocaleMatcher_Builder {
        if (desired.isNone() || supported.isNone()) {
            throw IllegalArgumentException("desired/supported locales must not be null")
        }
        maxDistanceDesired = desired
        maxDistanceSupported = supported
        return this
    }

    
    public func internalSetThresholdDistance(thresholdDistance: Int32): LocaleMatcher_Builder {
        var tempthresholdDistance = thresholdDistance
        if (tempthresholdDistance > 100) {
            tempthresholdDistance = 100
        }
        this.thresholdDistance = tempthresholdDistance
        return this
    }

    public func build(): LocaleMatcher {
        return LocaleMatcher(this)
    }

    public override func toString(): String {
        let s: StringBuilder = StringBuilder().append("{LocaleMatcher.Builder")
        if (supportedLocales.isSome() && !supportedLocales.isEmpty()) {
            s.append(" supported={").append(supportedLocales.asString()).append('}')
        }
        if (defaultLocale.isSome()) {
            s.append(" default=").append(defaultLocale.asString())
        }
        if (favor.isSome()) {
            s.append(" distance=").append(favor.asString())
        }
        if (thresholdDistance >= 0) {
            s.append(String.format(" threshold=%d", [thresholdDistance]))
        }
        if (demotion.isSome()) {
            s.append(" demotion=").append(demotion.asString())
        }
        return s.append('}').toString()
    }
}


class LocaleMatcher_ULocaleLsrIterator <: LocaleMatcher_LsrIterator {
    private var locales: Iterator<ULocale>

    var current: ULocale

    var remembered: ULocale

    init(locales: Iterator<ULocale>) {
        super()
        this.locales = locales
    }

    public override func hasNext(): Bool {
        return locales.hasNext()
    }

    public override func next(): LSR {
        current = locales.next()
        return LocaleMatcher.getMaximalLsrOrUnd(current)
    }

    public override func rememberCurrent(desiredIndex: Int32): Unit {
        bestDesiredIndex = desiredIndex
        remembered = current
    }
}


class LocaleMatcher_LocaleLsrIterator <: LocaleMatcher_LsrIterator {
    private var locales: Iterator<Locale> = None

    var current: Locale = None

    var remembered: Locale = None

    init(locales: Iterator<Locale>) {
        super()
        this.locales = locales
    }

    public override func hasNext(): Bool {
        return locales.hasNext()
    }

    public override func next(): LSR {
        current = locales.next()
        return LocaleMatcher.getMaximalLsrOrUnd(current)
    }

    public override func rememberCurrent(desiredIndex: Int32): Unit {
        bestDesiredIndex = desiredIndex
        remembered = current
    }
}
