package icu4cj.impl


public class PluralRulesLoader <: PluralRules_Factory & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    private let pluralRulesCache: Map<String, PluralRules>

    private var localeIdToCardinalRulesId: Map<String, String> = None

    private var localeIdToOrdinalRulesId: Map<String, String> = None

    private var rulesIdToEquivalentULocale: Map<String, ULocale> = None

    private init() {
        super()
        pluralRulesCache = HashMap<String, PluralRules>()
    }

    public override func getAvailableULocales(): Array<ULocale> {
        let keys: Set<String> = SetCollectionView<String>(getLocaleIdToRulesIdMap(PluralRules_PluralType.CARDINAL).keys())
        let locales = LinkedHashSet(Int32(keys.size))
        let iter: Iterator<String> = keys.iterator()
        while (iter.hasNext()) {
            locales.put(ULocale.createCanonical(iter.next()))
        }
        return locales.toArray(Array<ULocale>(0))
    }

    public override func getFunctionalEquivalent(locale: ULocale, isAvailable: Array<Bool>): ULocale {
        if (isAvailable.isSome() && Int32(isAvailable.size) > 0) {
            let localeId = ULocale.canonicalize(locale.getBaseName())
            let idMap = getLocaleIdToRulesIdMap(PluralRules_PluralType.CARDINAL)
            isAvailable[0] = idMap.contains(localeId)
        }
        let rulesId = getRulesIdForLocale(locale, PluralRules_PluralType.CARDINAL)
        if (rulesId.isNone() || Int32(rulesId.trimAscii().size) == 0) {
            return ULocale.ROOT
        }
        let result = getRulesIdToEquivalentULocaleMap().get(rulesId)
        if (result.isNone()) {
            return ULocale.ROOT
        }
        return result
    }

    private func getLocaleIdToRulesIdMap(Type: PluralRules_PluralType): Map<String, String> {
        checkBuildRulesIdMaps()
        return if (refEq(Type, PluralRules_PluralType.CARDINAL)) { localeIdToCardinalRulesId } else { localeIdToOrdinalRulesId }
    }

    private func getRulesIdToEquivalentULocaleMap(): Map<String, ULocale> {
        checkBuildRulesIdMaps()
        return rulesIdToEquivalentULocale
    }

    private func checkBuildRulesIdMaps(): Unit {
        let haveMap: Bool
        synchronized (getMonitorByObject(this)) {
            haveMap = localeIdToCardinalRulesId.isSome()
        }
        if (!haveMap) {
            var tempLocaleIdToCardinalRulesId: Map<String, String> = None
            var tempLocaleIdToOrdinalRulesId: Map<String, String> = None
            var tempRulesIdToEquivalentULocale: Map<String, ULocale> = None
            try {
                let pluralb = getPluralBundle()
                var localeb = pluralb.get("locales")
                tempLocaleIdToCardinalRulesId = TreeMap() as Map<String, String>
                tempRulesIdToEquivalentULocale = HashMap<String, ULocale>()
                        i++
                    }
                } while (false)
                localeb = pluralb.get("locales_ordinals")
                tempLocaleIdToOrdinalRulesId = TreeMap() as Map<String, String>
                } while (false)
            } catch (e: MissingResourceException) {
                tempLocaleIdToCardinalRulesId = Collections.emptyMap<<--, // Cannot infer type argument: V -->>()
                tempLocaleIdToOrdinalRulesId = Collections.emptyMap<<--, // Cannot infer type argument: V -->>()
                tempRulesIdToEquivalentULocale = Collections.emptyMap<<--, // Cannot infer type argument: V -->>()
            }
            synchronized (getMonitorByObject(this)) {
                if (localeIdToCardinalRulesId.isNone()) {
                    localeIdToCardinalRulesId = tempLocaleIdToCardinalRulesId
                    localeIdToOrdinalRulesId = tempLocaleIdToOrdinalRulesId
                    rulesIdToEquivalentULocale = tempRulesIdToEquivalentULocale
                }
            }
        }
    }

    public func getRulesIdForLocale(locale: ULocale, Type: PluralRules_PluralType): String {
        let idMap = getLocaleIdToRulesIdMap(Type)
        var localeId = ULocale.canonicalize(locale.getBaseName())
        var rulesId: String
        while ((match (0) { case _ => rulesId = idMap.get(localeId); rulesId }).isNone()) {
            let ix = indexOfWrap(localeId.lastIndexOf("_"))
            if (ix == -1) {
                break
            }
            localeId = localeId[0..Int64(ix)]
        }
        return rulesId
    }

    public func getOrCreateRulesForLocale(locale: ULocale, Type: PluralRules_PluralType): PluralRules {
        let rulesId = getRulesIdForLocale(locale, Type)
        if (rulesId.isNone() || Int32(rulesId.trimAscii().size) == 0) {
            return None
        }
        let rangesId = StandardPluralRanges.getSetForLocale(locale)
        let cacheKey: String = (rulesId) + "/" + (rangesId)
        var rules: PluralRules
        let hasRules: Bool
        synchronized (// Expecting Object descendant, got interface std$collection.Map<struct std$core.String, class com.ibm.icu.text.PluralRules>: pluralRulesCache) {
            hasRules = pluralRulesCache.contains(cacheKey)
            if (hasRules) {
                rules = pluralRulesCache.get(cacheKey)
            }
        }
        if (!hasRules) {
            try {
                let pluralb = getPluralBundle()
                let rulesb = pluralb.get("rules")
                let setb = rulesb.get(rulesId)
                let sb = StringBuilder()
                var i = 0
                while (i < setb.getSize()) {
                    let b = setb.get(i)
                    if (i > 0) {
                        sb.append("; ")
                    }
                    sb.append(b.getKey())
                    sb.append(": ")
                    sb.append(b.getString())
                    i++
                }
                let ranges = StandardPluralRanges.forSet(rangesId)
                rules = PluralRules.newInternal(sb.toString(), ranges)
            } catch (e: ParseException) { } catch (e: MissingResourceException) { }
            synchronized (// Expecting Object descendant, got interface std$collection.Map<struct std$core.String, class com.ibm.icu.text.PluralRules>: pluralRulesCache) {
                if (pluralRulesCache.contains(cacheKey)) {
                    rules = pluralRulesCache.get(cacheKey)
                } else {
                    pluralRulesCache.put(cacheKey, rules)
                }
            }
        }
        return rules
    }

    public func getPluralBundle(): UResourceBundle {
        return ICUResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "plurals", ICUResourceBundle.ICU_DATA_CLASS_LOADER, true)
    }

    public override func forLocale(locale: ULocale, Type: PluralRules_PluralType): PluralRules {
        var rules = getOrCreateRulesForLocale(locale, Type)
        if (rules.isNone()) {
            rules = PluralRules.DEFAULT
        }
        return rules
    }

    public static let loader = PluralRulesLoader()

    public override func hasOverride(locale: ULocale): Bool {
        return false
    }
}
