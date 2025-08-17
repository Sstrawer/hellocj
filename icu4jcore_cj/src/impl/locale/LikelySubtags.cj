package icu4cj.impl.locale


public class LikelySubtags {
    private static let PSEUDO_ACCENTS_PREFIX = "'"

    private static let PSEUDO_BIDI_PREFIX = "+"

    private static let PSEUDO_CRACKED_PREFIX = ","

    public static let SKIP_SCRIPT = 1

    private static let DEBUG_OUTPUT = LSR.DEBUG_OUTPUT

    public static let INSTANCE = LikelySubtags(LikelySubtags_Data.load())

    private let languageAliases: Map<String, String>

    private let regionAliases: Map<String, String>

    private let trie: BytesTrie

    private let trieUndState: Int64

    private let trieUndZzzzState: Int64

    private let defaultLsrIndex: Int32

    private let trieFirstLetterStates = Array<Int64>(26) { _ => 0 }

    private let lsrs: Array<LSR>

    private init(data: LikelySubtags_Data) {
        languageAliases = data.languageAliases
        regionAliases = data.regionAliases
        trie = BytesTrie(data.trie, 0)
        lsrs = data.lsrs
        var result = trie.next(Int32(UInt32('*')))
        if (!result.hasNext()) {
            throw AssertionError()
        }
        trieUndState = trie.getState64()
        result = trie.next(Int32(UInt32('*')))
        if (!result.hasNext()) {
            throw AssertionError()
        }
        trieUndZzzzState = trie.getState64()
        result = trie.next(Int32(UInt32('*')))
        if (!result.hasValue()) {
            throw AssertionError()
        }
        defaultLsrIndex = trie.getValue()
        trie.reset()
        var c = 'a'
        while (c <= 'z') {
            result = trie.next(Int32(UInt32(c)))
            if (refEq(result, BytesTrie_Result.NO_VALUE)) {
                trieFirstLetterStates[0] = trie.getState64()
            }
            trie.reset()
            c++
        }
        if (DEBUG_OUTPUT) {
            println("*** likely subtags")
            for (mapping in getTable().entrySet()) {
                println(toString(mapping))
            }
        }
    }

    public func canonicalize(locale: ULocale): ULocale {
        let lang = locale.getLanguage()
        let lang2 = languageAliases.get(lang)
        let region = locale.getCountry()
        let region2 = regionAliases.get(region)
        if (lang2.isSome() || region2.isSome()) {
            return ULocale(if (lang2.isNone()) { lang } else { lang2 }, locale.getScript(), if (region2.isNone()) { region } else { region2 })
        }
        return locale
    }

    private static func getCanonical(aliases: Map<String, String>, alias: String): String {
        let canonical = aliases.get(alias)
        return if (canonical.isNone()) { alias } else { canonical }
    }

    public func makeMaximizedLsrFrom(locale: ULocale, returnInputIfUnmatch: Bool): LSR {
        let name = locale.getName()
        if (name.startsWith("@x=")) {
            let tag = locale.toLanguageTag()
            if (!tag.startsWith("und-x-")) {
                throw AssertionError()
            }
            return LSR(tag, "", "", LSR.EXPLICIT_LSR)
        }
        let max = makeMaximizedLsr(locale.getLanguage(), locale.getScript(), locale.getCountry(), locale.getVariant(), returnInputIfUnmatch)
        if (max.language.isEmpty() && max.script.isEmpty() && max.region.isEmpty()) {
            return LSR(locale.getLanguage(), locale.getScript(), locale.getCountry(), LSR.EXPLICIT_LSR)
        }
        return max
    }

    public func makeMaximizedLsrFrom(locale: Locale): LSR {
        let tag = locale.toLanguageTag()
        if (tag.startsWith("x-") || tag.startsWith("und-x-")) {
            return LSR(tag, "", "", LSR.EXPLICIT_LSR)
        }
        return makeMaximizedLsr(locale.getLanguage(), locale.getScript(), locale.getCountry(), locale.getVariant(), false)
    }

    private func makeMaximizedLsr(language: String, script: String, region: String, variant: String, returnInputIfUnmatch: Bool): LSR {
        var templanguage = language
        var tempregion = region
        if (Int32(tempregion.size) == 2 && Char(tempregion[0]) == 'X') {
            match (Char(tempregion[1])) {
                case 'A' =>
                    if (returnInputIfUnmatch) {
                        return LSR(templanguage, script, tempregion, LSR.EXPLICIT_LSR)
                    }
                    return LSR(PSEUDO_ACCENTS_PREFIX + (templanguage), PSEUDO_ACCENTS_PREFIX + (script), tempregion, LSR.EXPLICIT_LSR)
                case 'B' =>
                    if (returnInputIfUnmatch) {
                        return LSR(templanguage, script, tempregion, LSR.EXPLICIT_LSR)
                    }
                    return LSR(PSEUDO_BIDI_PREFIX + (templanguage), PSEUDO_BIDI_PREFIX + (script), tempregion, LSR.EXPLICIT_LSR)
                case 'C' =>
                    if (returnInputIfUnmatch) {
                        return LSR(templanguage, script, tempregion, LSR.EXPLICIT_LSR)
                    }
                    return LSR(PSEUDO_CRACKED_PREFIX + (templanguage), PSEUDO_CRACKED_PREFIX + (script), tempregion, LSR.EXPLICIT_LSR)
                case _ => ()
            }
        }
        if (variant.startsWith("PS")) {
            let lsrFlags = if (tempregion.isEmpty()) { LSR.EXPLICIT_LANGUAGE | LSR.EXPLICIT_SCRIPT } else { LSR.EXPLICIT_LSR }
            match (variant) {
                case "PSACCENT" => return LSR(PSEUDO_ACCENTS_PREFIX + (templanguage), PSEUDO_ACCENTS_PREFIX + (script), if (tempregion.isEmpty()) { "XA" } else { tempregion }, lsrFlags)
                case "PSBIDI" => return LSR(PSEUDO_BIDI_PREFIX + (templanguage), PSEUDO_BIDI_PREFIX + (script), if (tempregion.isEmpty()) { "XB" } else { tempregion }, lsrFlags)
                case "PSCRACK" => return LSR(PSEUDO_CRACKED_PREFIX + (templanguage), PSEUDO_CRACKED_PREFIX + (script), if (tempregion.isEmpty()) { "XC" } else { tempregion }, lsrFlags)
                case _ => ()
            }
        }
        templanguage = getCanonical(languageAliases, templanguage)
        tempregion = getCanonical(regionAliases, tempregion)
        return maximize(templanguage, script, tempregion, returnInputIfUnmatch)
    }

    private func isMacroregion(region: String): Bool {
        let Type = Region.getInstance(region).getType()
        return refEq(Type, Region_RegionType.WORLD) || refEq(Type, Region_RegionType.CONTINENT) || refEq(Type, Region_RegionType.SUBCONTINENT)
    }

    private func maximize(language: String, script: String, region: String, returnInputIfUnmatch: Bool): LSR {
        var templanguage = language
        var tempscript = script
        var tempregion = region
        if (templanguage == "und") {
            templanguage = ""
        }
        if (tempscript == "Zzzz") {
            tempscript = ""
        }
        if (tempregion == "ZZ") {
            tempregion = ""
        }
        if (!tempscript.isEmpty() && !tempregion.isEmpty() && !templanguage.isEmpty()) {
            return LSR(templanguage, tempscript, tempregion, LSR.EXPLICIT_LSR)
        }
        var retainLanguage = false
        var retainScript = false
        var retainRegion = false
        let iter = BytesTrie(trie)
        var state: Int64 = 0
        var value: Int32 = 0
        let c0: Int32
        if (Int32(templanguage.size) >= 2 && 0 <= (match (0) { case _ => c0 = ; c0 }) && c0 <= 25 && (match (0) { case _ => state = trieFirstLetterStates[Int64(c0)]; state }) != 0) {
            value = trieNext(iter.resetToState64(state), templanguage, 1)
        } else {
            value = trieNext(iter, templanguage, 0)
        }
        let matchLanguage = (value >= 0)
        var matchScript = false
        if (value >= 0) {
            retainLanguage = !templanguage.isEmpty()
            state = iter.getState64()
        } else {
            retainLanguage = true
            iter.resetToState64(trieUndState)
            state = 0
        }
        if (value >= 0 && !tempscript.isEmpty()) {
            matchScript = true
        }
        if (value > 0) {
            if (value == SKIP_SCRIPT) {
                value = 0
            }
            retainScript = !tempscript.isEmpty()
        } else {
            value = trieNext(iter, tempscript, 0)
            if (value >= 0) {
                retainScript = !tempscript.isEmpty()
                state = iter.getState64()
            } else {
                retainScript = true
                if (state == 0) {
                    iter.resetToState64(trieUndZzzzState)
                } else {
                    iter.resetToState64(state)
                    value = trieNext(iter, "", 0)
                    if (!(value >= 0)) {
                        throw AssertionError()
                    }
                    state = iter.getState64()
                }
            }
        }
        var matchRegion = false
        if (value > 0) {
            retainRegion = !tempregion.isEmpty()
        } else {
            value = trieNext(iter, tempregion, 0)
            if (value >= 0) {
                if (!tempregion.isEmpty() && !isMacroregion(tempregion)) {
                    retainRegion = true
                    matchRegion = true
                }
            } else {
                retainRegion = true
                if (state == 0) {
                    value = defaultLsrIndex
                } else {
                    iter.resetToState64(state)
                    value = trieNext(iter, "", 0)
                    if (!(value > 0)) {
                        throw AssertionError()
                    }
                }
            }
        }
        let result = lsrs[Int64(value)]
        if (returnInputIfUnmatch && (!(matchLanguage || matchScript || (matchRegion && templanguage.isEmpty())))) {
            return LSR("", "", "", LSR.EXPLICIT_LSR)
        }
        if (templanguage.isEmpty()) {
            templanguage = "und"
        }
        if (!(retainLanguage || retainScript || retainRegion)) {
            if (!(result.flags == LSR.IMPLICIT_LSR)) {
                throw AssertionError()
            }
            return result
        }
        if (!retainLanguage) {
            templanguage = result.language
        }
        if (!retainScript) {
            tempscript = result.script
        }
        if (!retainRegion) {
            tempregion = result.region
        }
        let retainMask = (if (retainLanguage) { 4 } else { 0 }) + (if (retainScript) { 2 } else { 0 }) + (if (retainRegion) { 1 } else { 0 })
        return LSR(templanguage, tempscript, tempregion, retainMask)
    }

    public func compareLikely(lsr: LSR, other: LSR, likelyInfo: Int32): Int32 {
        var templikelyInfo = likelyInfo
        if (!lsr.language.equals(other.language)) {
            return -4
        }
        if (!lsr.script.equals(other.script)) {
            let index: Int32
            if (templikelyInfo >= 0 && (templikelyInfo & 2) == 0) {
                index = shr(templikelyInfo, 2)
            } else {
                index = getLikelyIndex(lsr.language, "")
                templikelyInfo = shl(index, 2)
            }
            let likely = lsrs[Int64(index)]
            if (lsr.script.equals(likely.script)) {
                return templikelyInfo | 1
            } else {
                return templikelyInfo & 
            }
        }
        if (!lsr.region.equals(other.region)) {
            let index: Int32
            if (templikelyInfo >= 0 && (templikelyInfo & 2) != 0) {
                index = shr(templikelyInfo, 2)
            } else {
                index = getLikelyIndex(lsr.language, lsr.region)
                templikelyInfo = (shl(index, 2)) | 2
            }
            let likely = lsrs[Int64(index)]
            if (lsr.region.equals(likely.region)) {
                return templikelyInfo | 1
            } else {
                return templikelyInfo & 
            }
        }
        return templikelyInfo & 
    }

    private func getLikelyIndex(language: String, script: String): Int32 {
        var templanguage = language
        var tempscript = script
        if (templanguage == "und") {
            templanguage = ""
        }
        if (tempscript == "Zzzz") {
            tempscript = ""
        }
        let iter = BytesTrie(trie)
        var state: Int64 = 0
        var value: Int32 = 0
        let c0: Int32
        if (Int32(templanguage.size) >= 2 && 0 <= (match (0) { case _ => c0 = ; c0 }) && c0 <= 25 && (match (0) { case _ => state = trieFirstLetterStates[Int64(c0)]; state }) != 0) {
            value = trieNext(iter.resetToState64(state), templanguage, 1)
        } else {
            value = trieNext(iter, templanguage, 0)
        }
        if (value >= 0) {
            state = iter.getState64()
        } else {
            iter.resetToState64(trieUndState)
            state = 0
        }
        if (value > 0) {
            if (value == SKIP_SCRIPT) {
                value = 0
            }
        } else {
            value = trieNext(iter, tempscript, 0)
            if (value >= 0) {
                state = iter.getState64()
            } else {
                if (state == 0) {
                    iter.resetToState64(trieUndZzzzState)
                } else {
                    iter.resetToState64(state)
                    value = trieNext(iter, "", 0)
                    if (!(value >= 0)) {
                        throw AssertionError()
                    }
                    state = iter.getState64()
                }
            }
        }
        if (value > 0) { } else {
            value = trieNext(iter, "", 0)
            if (!(value > 0)) {
                throw AssertionError()
            }
        }
        return value
    }

    private static func trieNext(iter: BytesTrie, s: String, i: Int32): Int32 {
        var tempi = i
        let result: BytesTrie_Result
        if (s.isEmpty()) {
            result = iter.next(Int32(UInt32('*')))
        } else {
            let end = Int32(s.size) - 1
            while (true) {
                let c = Int32(UInt32(Char(s[Int64(tempi)])))
                if (tempi < end) {
                    if (!iter.next(c).hasNext()) {
                        return -1
                    }
                } else {
                    result = iter.next(c | 128)
                    break
                }
                tempi++
            }
        }
        match (result) {
            case BytesTrie_Result.NO_MATCH => return -1
            case BytesTrie_Result.NO_VALUE => return 0
            case BytesTrie_Result.INTERMEDIATE_VALUE =>
                if (!(iter.getValue() == SKIP_SCRIPT)) {
                    throw AssertionError()
                }
                return SKIP_SCRIPT
            case BytesTrie_Result.FINAL_VALUE => return iter.getValue()
            case _ => return -1
        }
    }

    public func minimizeSubtags(languageIn: String, scriptIn: String, regionIn: String, fieldToFavor: ULocale_Minimize): LSR {
        let max = maximize(languageIn, scriptIn, regionIn, true)
        if (max.language.isEmpty() && max.region.isEmpty() && max.script.isEmpty()) {
            return LSR(languageIn, scriptIn, regionIn, LSR.EXPLICIT_LSR)
        }
        var test = maximize(max.language, "", "", true)
        if (test.isEquivalentTo(max)) {
            return LSR(max.language, "", "", LSR.DONT_CARE_FLAGS)
        }
        if (refEq(ULocale_Minimize.FAVOR_REGION, fieldToFavor)) {
            test = maximize(max.language, "", max.region, true)
            if (test.isEquivalentTo(max)) {
                return LSR(max.language, "", max.region, LSR.DONT_CARE_FLAGS)
            }
            test = maximize(max.language, max.script, "", true)
            if (test.isEquivalentTo(max)) {
                return LSR(max.language, max.script, "", LSR.DONT_CARE_FLAGS)
            }
        } else {
            test = maximize(max.language, max.script, "", true)
            if (test.isEquivalentTo(max)) {
                return LSR(max.language, max.script, "", LSR.DONT_CARE_FLAGS)
            }
            test = maximize(max.language, "", max.region, true)
            if (test.isEquivalentTo(max)) {
                return LSR(max.language, "", max.region, LSR.DONT_CARE_FLAGS)
            }
        }
        return LSR(max.language, max.script, max.region, LSR.DONT_CARE_FLAGS)
    }

    private func getTable(): Map<String, LSR> {
        let map = TreeMap()
        let sb = StringBuilder()
        for (entry in trie) {
            sb.setLength(0)
            let length = entry.bytesLength()
            var i = 0
            while (i < length) {
                let b = entry.byteAt(match (0) { case _ => i++; i - 1 })
                if (Int32(b) == Int32(UInt32('*'))) {
                    sb.append("*-")
                } else if (Int32(b) >= 0) {
                    sb.append(Char(b))
                } else {
                    sb.append(Char(Int32(b) & 127)).append('-')
                }
            }
            if (!(Int32(sb.size) > 0 && sb.get(Int64(Int32(sb.size) - 1)) == '-')) {
                throw AssertionError()
            }
            sb.setLength(Int64(Int32(sb.size) - 1))
            map.put(sb.toString(), lsrs[Int64(entry.value)])
        }
        return map
    }

    public override func toString(): String {
        return toString(getTable())
    }
}


public class LikelySubtags_Data {
    public let languageAliases: Map<String, String>

    public let regionAliases: Map<String, String>

    public let trie: Array<UInt8>

    public let lsrs: Array<LSR>

    public init(languageAliases: Map<String, String>, regionAliases: Map<String, String>, trie: Array<UInt8>, lsrs: Array<LSR>) {
        this.languageAliases = languageAliases
        this.regionAliases = regionAliases
        this.trie = trie
        this.lsrs = lsrs
    }

    private static func getValue(table: UResource_Table, key: String, value: UResource_Value): UResource_Value {
        if (!table.findValue(key, value)) {
            throw MissingResourceException("langInfo.res missing data", "", "likely/" + (key))
        }
        return value
    }

    public static func load(): LikelySubtags_Data {
        let langInfo = ICUResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "langInfo", ICUResourceBundle.ICU_DATA_CLASS_LOADER, ICUResourceBundle_OpenType.DIRECT)
        let value = langInfo.getValueWithFallback("likely")
        let likelyTable = value.getTable()
        let languageAliases: Map<String, String>
        if (likelyTable.findValue("languageAliases", value)) {
            let pairs = value.getStringArray()
            languageAliases = HashMap<String, String>(Int64(Int32(pairs.size) / 2))
            } while (false)
        } else {
            languageAliases = Collections.emptyMap<<--, // Cannot infer type argument: V -->>()
        }
        let regionAliases: Map<String, String>
        if (likelyTable.findValue("regionAliases", value)) {
            let pairs = value.getStringArray()
            regionAliases = HashMap<String, String>(Int64(Int32(pairs.size) / 2))
            } while (false)
        } else {
            regionAliases = Collections.emptyMap<<--, // Cannot infer type argument: V -->>()
        }
        let buffer = getValue(likelyTable, "trie", value).getBinary()
        let trie = Array<UInt8>(Int64(buffer.remaining())) { _ => 0 }
        buffer.get(trie)
        let m49 = getValue(likelyTable, "m49", value).getStringArray()
        let lsrs = LSR.decodeInts(getValue(likelyTable, "lsrnum", value).getIntVector(), m49)
        return LikelySubtags_Data(languageAliases, regionAliases, trie, lsrs)
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (other.isNone() || !refEq(TypeInfo.of(this), TypeInfo.of(other))) {
            return false
        }
        let od = other
        return // Мapping is present but failed: refEq -->(languageAliases, od.languageAliases) && <-- Мapping is present but failed: refEq(regionAliases, od.regionAliases) && trie == od.trie && lsrs == od.lsrs
    }

    public override func hashCode(): Int64 {
        return 1
    }
}
