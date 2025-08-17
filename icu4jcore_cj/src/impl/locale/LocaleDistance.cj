package icu4cj.impl.locale


public class LocaleDistance {
    public static let END_OF_SUBTAG = 128

    public static let DISTANCE_SKIP_SCRIPT = 128

    private static let DISTANCE_IS_FINAL = 256

    private static let DISTANCE_IS_FINAL_OR_SKIP_SCRIPT = DISTANCE_IS_FINAL | DISTANCE_SKIP_SCRIPT

    private static let DISTANCE_SHIFT = 3

    private static let DISTANCE_FRACTION_MASK = 7

    private static let DISTANCE_INT_SHIFT = 7

    private static let INDEX_SHIFT = DISTANCE_INT_SHIFT + DISTANCE_SHIFT

    private static let DISTANCE_MASK = 1023

    private static let INDEX_NEG_1 = -1024

    public static let IX_DEF_LANG_DISTANCE = 0

    public static let IX_DEF_SCRIPT_DISTANCE = 1

    public static let IX_DEF_REGION_DISTANCE = 2

    public static let IX_MIN_REGION_DISTANCE = 3

    public static let IX_LIMIT = 4

    private static let ABOVE_THRESHOLD = 100

    private static let DEBUG_OUTPUT = LSR.DEBUG_OUTPUT

    private let trie: BytesTrie

    private let regionToPartitionsIndex: Array<UInt8>

    private let partitionArrays: Array<String>

    private let paradigmLSRs: Set<LSR>

    private let defaultLanguageDistance: Int32

    private let defaultScriptDistance: Int32

    private let defaultRegionDistance: Int32

    private let minRegionDistance: Int32

    private let defaultDemotionPerDesiredLocale: Int32

    public static func shiftDistance(distance: Int32): Int32 {
        return shl(distance, DISTANCE_SHIFT)
    }

    public static func getShiftedDistance(indexAndDistance: Int32): Int32 {
        return indexAndDistance & DISTANCE_MASK
    }

    public static func getDistanceDouble(indexAndDistance: Int32): Float64 {
        let shiftedDistance = Float64(getShiftedDistance(indexAndDistance))
        return shiftedDistance / (Float64(shl(1, DISTANCE_SHIFT)))
    }

    public static func getDistanceFloor(indexAndDistance: Int32): Int32 {
        return shr((indexAndDistance & DISTANCE_MASK), DISTANCE_SHIFT)
    }

    public static func getIndex(indexAndDistance: Int32): Int32 {
        if (!(indexAndDistance >= 0)) {
            throw AssertionError()
        }
        return shr(indexAndDistance, INDEX_SHIFT)
    }

    public static let INSTANCE = LocaleDistance(LocaleDistance_Data.load())

    private init(data: LocaleDistance_Data) {
        trie = BytesTrie(data.trie, 0)
        regionToPartitionsIndex = data.regionToPartitionsIndex
        partitionArrays = data.partitionArrays
        paradigmLSRs = data.paradigmLSRs
        defaultLanguageDistance = data.distances[Int64(IX_DEF_LANG_DISTANCE)]
        defaultScriptDistance = data.distances[Int64(IX_DEF_SCRIPT_DISTANCE)]
        defaultRegionDistance = data.distances[Int64(IX_DEF_REGION_DISTANCE)]
        minRegionDistance = data.distances[Int64(IX_MIN_REGION_DISTANCE)]
        let en = LSR("en", "Latn", "US", LSR.EXPLICIT_LSR)
        let enGB = LSR("en", "Latn", "GB", LSR.EXPLICIT_LSR)
        let indexAndDistance = getBestIndexAndDistance(en, [enGB], 1, shiftDistance(50), LocaleMatcher_FavorSubtag.LANGUAGE, LocaleMatcher_Direction.WITH_ONE_WAY)
        defaultDemotionPerDesiredLocale = getDistanceFloor(indexAndDistance)
        if (DEBUG_OUTPUT) {
            println("*** locale distance")
            println("defaultLanguageDistance=" + defaultLanguageDistance.toString())
            println("defaultScriptDistance=" + defaultScriptDistance.toString())
            println("defaultRegionDistance=" + defaultRegionDistance.toString())
            testOnlyPrintDistanceTable()
        }
    }

    public func testOnlyDistance(desired: ULocale, supported: ULocale, threshold: Int32, favorSubtag: LocaleMatcher_FavorSubtag): Int32 {
        let supportedLSR = LikelySubtags.INSTANCE.makeMaximizedLsrFrom(supported, false)
        let desiredLSR = LikelySubtags.INSTANCE.makeMaximizedLsrFrom(desired, false)
        let indexAndDistance = getBestIndexAndDistance(desiredLSR, [supportedLSR], 1, shiftDistance(threshold), favorSubtag, LocaleMatcher_Direction.WITH_ONE_WAY)
        return getDistanceFloor(indexAndDistance)
    }

    public func getBestIndexAndDistance(desired: LSR, supportedLSRs: Array<LSR>, supportedLSRsLength: Int32, shiftedThreshold: Int32, favorSubtag: LocaleMatcher_FavorSubtag, direction: LocaleMatcher_Direction): Int32 {
        var tempshiftedThreshold = shiftedThreshold
        let iter = BytesTrie(trie)
        let desLangDistance = trieNext(iter, desired.language, false)
        let desLangState = if (desLangDistance >= 0 && supportedLSRsLength > 1) { iter.getState64() } else { 0 }
        var bestIndex = -1
        var bestLikelyInfo = -1
        var slIndex = 0
        while (slIndex < supportedLSRsLength) {
            let supported = supportedLSRs[Int64(slIndex)]
            var star = false
            var distance = desLangDistance
            if (distance >= 0) {
                if (!((distance & DISTANCE_IS_FINAL) == 0)) {
                    throw AssertionError()
                }
                if (slIndex != 0) {
                    iter.resetToState64(desLangState)
                }
                distance = trieNext(iter, supported.language, true)
            }
            var flags: Int32 = 0
            if (distance >= 0) {
                flags = distance & DISTANCE_IS_FINAL_OR_SKIP_SCRIPT
                distance &= 
            } else {
                if (desired.language.equals(supported.language)) {
                    distance = 0
                } else {
                    distance = defaultLanguageDistance
                }
                flags = 0
                star = true
            }
            if (!(0 <= distance && distance <= 100)) {
                throw AssertionError()
            }
            let roundedThreshold = shr((tempshiftedThreshold + DISTANCE_FRACTION_MASK), DISTANCE_SHIFT)
            if (refEq(favorSubtag, LocaleMatcher_FavorSubtag.SCRIPT)) {
                distance >>= 2
            }
            if (distance > roundedThreshold) {
                continue
            }
            var scriptDistance: Int32 = 0
            if (star || flags != 0) {
                if (desired.script.equals(supported.script)) {
                    scriptDistance = 0
                } else {
                    scriptDistance = defaultScriptDistance
                }
            } else {
                scriptDistance = getDesSuppScriptDistance(iter, iter.getState64(), desired.script, supported.script)
                flags = scriptDistance & DISTANCE_IS_FINAL
                scriptDistance &= 
            }
            distance += scriptDistance
            if (distance > roundedThreshold) {
                continue
            }
            if (desired.region.equals(supported.region)) { } else if (star || (flags & DISTANCE_IS_FINAL) != 0) {
                distance += defaultRegionDistance
            } else {
                let remainingThreshold = roundedThreshold - distance
                if (minRegionDistance > remainingThreshold) {
                    continue
                }
                distance += getRegionPartitionsDistance(iter, iter.getState64(), partitionsForRegion(desired), partitionsForRegion(supported), remainingThreshold)
            }
            var shiftedDistance = shiftDistance(distance)
            if (shiftedDistance == 0) {
                shiftedDistance |= (desired.flags ^ supported.flags)
                if (shiftedDistance < tempshiftedThreshold) {
                    if (!refEq(direction, LocaleMatcher_Direction.ONLY_TWO_WAY) || isMatch(supported, desired, tempshiftedThreshold, favorSubtag)) {
                        if (shiftedDistance == 0) {
                            return shl(slIndex, INDEX_SHIFT)
                        }
                        bestIndex = slIndex
                        tempshiftedThreshold = shiftedDistance
                        bestLikelyInfo = -1
                    }
                }
            } else {
                if (shiftedDistance < tempshiftedThreshold) {
                    if (!refEq(direction, LocaleMatcher_Direction.ONLY_TWO_WAY) || isMatch(supported, desired, tempshiftedThreshold, favorSubtag)) {
                        bestIndex = slIndex
                        tempshiftedThreshold = shiftedDistance
                        bestLikelyInfo = -1
                    }
                } else if (shiftedDistance == tempshiftedThreshold && bestIndex >= 0) {
                    if (!refEq(direction, LocaleMatcher_Direction.ONLY_TWO_WAY) || isMatch(supported, desired, tempshiftedThreshold, favorSubtag)) {
                        bestLikelyInfo = LikelySubtags.INSTANCE.compareLikely(supported, supportedLSRs[Int64(bestIndex)], bestLikelyInfo)
                        if ((bestLikelyInfo & 1) != 0) {
                            bestIndex = slIndex
                        }
                    }
                }
            }
            slIndex++
        }
        return if (bestIndex >= 0) { (shl(bestIndex, INDEX_SHIFT)) | tempshiftedThreshold } else { INDEX_NEG_1 | shiftDistance(ABOVE_THRESHOLD) }
    }

    private func isMatch(desired: LSR, supported: LSR, shiftedThreshold: Int32, favorSubtag: LocaleMatcher_FavorSubtag): Bool {
        return getBestIndexAndDistance(desired, [supported], 1, shiftedThreshold, favorSubtag, None) >= 0
    }

    private static func getDesSuppScriptDistance(iter: BytesTrie, startState: Int64, desired: String, supported: String): Int32 {
        var distance = trieNext(iter, desired, false)
        if (distance >= 0) {
            distance = trieNext(iter, supported, true)
        }
        if (distance < 0) {
            let result = iter.resetToState64(startState).next(Int32(UInt32('*')))
            if (!result.hasValue()) {
                throw AssertionError()
            }
            if (desired.equals(supported)) {
                distance = 0
            } else {
                distance = iter.getValue()
                if (!(distance >= 0)) {
                    throw AssertionError()
                }
            }
            if (refEq(result, BytesTrie_Result.FINAL_VALUE)) {
                distance |= DISTANCE_IS_FINAL
            }
        }
        return distance
    }

    private static func getRegionPartitionsDistance(iter: BytesTrie, startState: Int64, desiredPartitions: String, supportedPartitions: String, threshold: Int32): Int32 {
        let desLength = Int32(desiredPartitions.size)
        let suppLength = Int32(supportedPartitions.size)
        if (desLength == 1 && suppLength == 1) {
            var result = iter.next(Int32(UInt32(Char(desiredPartitions[0]))) | END_OF_SUBTAG)
            if (result.hasNext()) {
                result = iter.next(Int32(UInt32(Char(supportedPartitions[0]))) | END_OF_SUBTAG)
                if (result.hasValue()) {
                    return iter.getValue()
                }
            }
            return getFallbackRegionDistance(iter, startState)
        }
        var regionDistance = 0
        var star = false
        var di = 0
        while (true) {
            var result = iter.next(Int32(UInt32(Char(desiredPartitions[Int64(match (0) { case _ => di++; di - 1 })]))) | END_OF_SUBTAG)
            if (result.hasNext()) {
                let desState = if (suppLength > 1) { iter.getState64() } else { 0 }
                var si = 0
                while (true) {
                    result = iter.next(Int32(UInt32(Char(supportedPartitions[Int64(match (0) { case _ => si++; si - 1 })]))) | END_OF_SUBTAG)
                    let d: Int32
                    if (result.hasValue()) {
                        d = iter.getValue()
                    } else if (star) {
                        d = 0
                    } else {
                        d = getFallbackRegionDistance(iter, startState)
                        star = true
                    }
                    if (d > threshold) {
                        return d
                    } else if (regionDistance < d) {
                        regionDistance = d
                    }
                    if (si < suppLength) {
                        iter.resetToState64(desState)
                    } else {
                        break
                    }
                }
            } else if (!star) {
                let d = getFallbackRegionDistance(iter, startState)
                if (d > threshold) {
                    return d
                } else if (regionDistance < d) {
                    regionDistance = d
                }
                star = true
            }
            if (di < desLength) {
                iter.resetToState64(startState)
            } else {
                break
            }
        }
        return regionDistance
    }

    private static func getFallbackRegionDistance(iter: BytesTrie, startState: Int64): Int32 {
        let result = iter.resetToState64(startState).next(Int32(UInt32('*')))
        if (!result.hasValue()) {
            throw AssertionError()
        }
        let distance = iter.getValue()
        if (!(distance >= 0)) {
            throw AssertionError()
        }
        return distance
    }

    private static func trieNext(iter: BytesTrie, s: String, wantValue: Bool): Int32 {
        if (s.isEmpty()) {
            return -1
        }
        var i = 0
        let end = Int32(s.size) - 1
        while (true) {
            let c = Int32(UInt32(Char(s[Int64(i)])))
            if (i < end) {
                if (!iter.next(c).hasNext()) {
                    return -1
                }
            } else {
                let result = iter.next(c | END_OF_SUBTAG)
                if (wantValue) {
                    if (result.hasValue()) {
                        var value = iter.getValue()
                        if (refEq(result, BytesTrie_Result.FINAL_VALUE)) {
                            value |= DISTANCE_IS_FINAL
                        }
                        return value
                    }
                } else {
                    if (result.hasNext()) {
                        return 0
                    }
                }
                return -1
            }
            i++
        }
    }

    public override func toString(): String {
        return toString(testOnlyGetDistanceTable())
    }

    private func partitionsForRegion(lsr: LSR): String {
        let pIndex = Int32(regionToPartitionsIndex[Int64(lsr.regionIndex)])
        return partitionArrays[Int64(pIndex)]
    }

    public func isParadigmLSR(lsr: LSR): Bool {
        if (!(Int32(paradigmLSRs.size) <= 15)) {
            throw AssertionError()
        }
        for (plsr in paradigmLSRs) {
            if (lsr.isEquivalentTo(plsr)) {
                return true
            }
        }
        return false
    }

    public func getDefaultScriptDistance(): Int32 {
        return defaultScriptDistance
    }

    public func getDefaultRegionDistance(): Int32 {
        return defaultRegionDistance
    }

    public func getDefaultDemotionPerDesiredLocale(): Int32 {
        return defaultDemotionPerDesiredLocale
    }

    public func testOnlyGetDistanceTable(): Map<String, Int32> {
        let map = TreeMap()
        let sb = StringBuilder()
        for (entry in trie) {
            sb.setLength(0)
            let length = entry.bytesLength()
            var i = 0
            while (i < length) {
                let b = entry.byteAt(i)
                if (Int32(b) == Int32(UInt32('*'))) {
                    sb.append("*-*-")
                } else {
                    if (Int32(b) >= 0) {
                        sb.append(Char(b))
                    } else {
                        sb.append(Char(Int32(b) & 127)).append('-')
                    }
                }
                i++
            }
            if (!(Int32(sb.size) > 0 && sb.get(Int64(Int32(sb.size) - 1)) == '-')) {
                throw AssertionError()
            }
            sb.setLength(Int64(Int32(sb.size) - 1))
            map.put(sb.toString(), entry.value)
        }
        return map
    }

    public func testOnlyPrintDistanceTable(): Unit {
        for (mapping in testOnlyGetDistanceTable().entrySet()) {
            var suffix: String = ""
            var value = mapping.getValue()
            if ((value & DISTANCE_SKIP_SCRIPT) != 0) {
                value &= 
                suffix = " skip script"
            }
            println(mapping.getKey().asString() + '='.toString() + value.toString() + (suffix))
        }
    }
}


public class LocaleDistance_Data {
    public var trie: Array<UInt8>

    public var regionToPartitionsIndex: Array<UInt8>

    public var partitionArrays: Array<String>

    public var paradigmLSRs: Set<LSR>

    public var distances: Array<Int32>

    public init(trie: Array<UInt8>, regionToPartitionsIndex: Array<UInt8>, partitionArrays: Array<String>, paradigmLSRs: Set<LSR>, distances: Array<Int32>) {
        this.trie = trie
        this.regionToPartitionsIndex = regionToPartitionsIndex
        this.partitionArrays = partitionArrays
        this.paradigmLSRs = paradigmLSRs
        this.distances = distances
    }

    private static func getValue(table: UResource_Table, key: String, value: UResource_Value): UResource_Value {
        if (!table.findValue(key, value)) {
            throw MissingResourceException("langInfo.res missing data", "", "match/" + (key))
        }
        return value
    }

    public static func load(): LocaleDistance_Data {
        let langInfo = ICUResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "langInfo", ICUResourceBundle.ICU_DATA_CLASS_LOADER, ICUResourceBundle_OpenType.DIRECT)
        let value = langInfo.getValueWithFallback("match")
        let matchTable = value.getTable()
        var buffer = getValue(matchTable, "trie", value).getBinary()
        let trie = Array<UInt8>(Int64(buffer.remaining())) { _ => 0 }
        buffer.get(trie)
        buffer = getValue(matchTable, "regionToPartitions", value).getBinary()
        let regionToPartitions = Array<UInt8>(Int64(buffer.remaining())) { _ => 0 }
        buffer.get(regionToPartitions)
        if (Int32(regionToPartitions.size) < LSR.REGION_INDEX_LIMIT) {
            throw MissingResourceException("langInfo.res binary data too short", "", "match/regionToPartitions")
        }
        let partitions = getValue(matchTable, "partitions", value).getStringArray()
        let paradigmLSRs: Set<LSR>
        if (matchTable.findValue("paradigmnum", value)) {
            let m49 = getValue(langInfo.getValueWithFallback("likely").getTable(), "m49", value).getStringArray()
            let paradigms = LSR.decodeInts(getValue(matchTable, "paradigmnum", value).getIntVector(), m49)
            paradigmLSRs = LinkedHashSet(paradigms) as Set<LSR>
        } else {
            paradigmLSRs = Collections.emptySet<<--> -->()
        }
        let distances = getValue(matchTable, "distances", value).getIntVector()
        if (Int32(distances.size) < LocaleDistance.IX_LIMIT) {
            throw MissingResourceException("langInfo.res intvector too short", "", "match/distances")
        }
        return LocaleDistance_Data(trie, regionToPartitions, partitions, paradigmLSRs, distances)
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (other.isNone() || !refEq(TypeInfo.of(this), TypeInfo.of(other))) {
            return false
        }
        let od = other
        return trie == od.trie && regionToPartitionsIndex == od.regionToPartitionsIndex && partitionArrays == od.partitionArrays && // Мapping is present but failed: refEq(paradigmLSRs, od.paradigmLSRs) && distances == od.distances
    }

    public override func hashCode(): Int64 {
        return 1
    }
}
