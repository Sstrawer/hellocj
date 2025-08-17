package icu4cj.impl.units


public class UnitPreferences {
    private static let measurementSystem: Map<String, String>


    private var mapToUnitPreferences: HashMap<String, HashMap<String, Array<UnitPreferences_UnitPreference>>> = HashMap<String, HashMap<String, Array<UnitPreferences_UnitPreference>>>()

    public init() {
        let resource: ICUResourceBundle
        resource = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "units")
        let sink = UnitPreferences_UnitPreferencesSink()
        resource.getAllItemsWithFallback(UnitsData_Constants.UNIT_PREFERENCE_TABLE_NAME, sink)
        this.mapToUnitPreferences = sink.getMapToUnitPreferences()
    }

    public static func formMapKey(category: String, usage: String): String {
        return (category) + "++" + (usage)
    }

    private static func getAllUsages(usage: String): Array<String> {
        let result = ArrayList<String>()
        result.append(usage)
        var i = Int32(usage.size) - 1
        while (i >= 0) {
            if (Char(usage[Int64(i)]) == '-') {
                result.append(usage[0..Int64(i)])
            }
            i--
        }
        if (!usage.equals(UnitsData_Constants.DEFAULT_USAGE)) {
            result.append(UnitsData_Constants.DEFAULT_USAGE)
        }
        return result.toArray(Array<String>(0))
    }

    public func getPreferencesFor(category: String, usage: String, locale: ULocale, data: UnitsData): Array<UnitPreferences_UnitPreference> {
        if ("temperature".equals(category)) {
            var localeUnit = locale.getKeywordValue("mu")
            if ("fahrenhe".equals(localeUnit)) {
                localeUnit = "fahrenheit"
            }
            var localeUnitCategory: String
            try {
                localeUnitCategory = if (localeUnit.isNone()) { None } else { data.getCategory(MeasureUnitImpl.forIdentifier(localeUnit)) }
            } catch (e: Exception) {
                localeUnitCategory = None
            }
            if (localeUnitCategory.isSome() && category.equals(localeUnitCategory)) {
                let preferences: Array<UnitPreferences_UnitPreference> = [UnitPreferences_UnitPreference(localeUnit, None, None)]
                return preferences
            }
        }
        let region = ULocale.getRegionForSupplementalData(locale, true)
        let localeSystem = locale.getKeywordValue("measure")
        let isLocaleSystem = measurementSystem.contains(localeSystem)
        let subUsages = getAllUsages(usage)
        var result: Array<UnitPreferences_UnitPreference>
        for (subUsage in subUsages) {
            result = getUnitPreferences(category, subUsage, region)
            if (result.isSome() && isLocaleSystem) {
                let rates = ConversionRates()
                var unitsMatchSystem = true
                for (unitPref in result) {
                    let measureUnit = MeasureUnitImpl.forIdentifier(unitPref.getUnit())
                    let singleUnits = ArrayList<SingleUnitImpl>(measureUnit.getSingleUnits())
                    for (singleUnit in singleUnits) {
                        let systems = rates.extractSystems(singleUnit)
                        if (!systems.contains("metric_adjacent")) {
                            if (!systems.contains(localeSystem)) {
                                unitsMatchSystem = false
                            }
                        }
                    }
                }
                if (!unitsMatchSystem) {
                    let newRegion = measurementSystem.get(localeSystem)
                    result = getUnitPreferences(category, subUsage, newRegion)
                }
            }
            if (result.isSome()) {
                break
            }
        }
        if (!(result.isSome())) {
            throw Exception("At least the category must be exist")
        }
        return result
    }

    private func getUnitPreferences(category: String, usage: String, region: String): Array<UnitPreferences_UnitPreference> {
        let key = formMapKey(category, usage)
        if (this.mapToUnitPreferences.contains(key)) {
            let unitPreferencesMap = this.mapToUnitPreferences.get(key)
            let result = if (unitPreferencesMap.contains(region)) { unitPreferencesMap.get(region) } else { unitPreferencesMap.get(UnitsData_Constants.DEFAULT_REGION) }
            if (!(result.isSome())) {
                throw AssertionError()
            }
            return result
        }
        return None
    }
}


public class UnitPreferences_UnitPreference {
    private let unit: String

    private let geq: BigDecimal

    private let skeleton: String

    public init(unit: String, geq: String, skeleton: String) {
        this.unit = unit
        this.geq = if (geq.isNone()) { Decimal.valueOf(Float64.Min) } else { Decimal(geq) }
        this.skeleton = if (skeleton.isNone()) { "" } else { skeleton }
    }

    public func getUnit(): String {
        return this.unit
    }

    public func getGeq(): BigDecimal {
        return geq
    }

    public func getSkeleton(): String {
        return skeleton
    }
}


public class UnitPreferences_UnitPreferencesSink <: UResource_Sink {
    private var mapToUnitPreferences: HashMap<String, HashMap<String, Array<UnitPreferences_UnitPreference>>> = None

    public init() {
        super()
        this.mapToUnitPreferences = HashMap<String, HashMap<String, Array<UnitPreferences_UnitPreference>>>()
    }

    public func getMapToUnitPreferences(): HashMap<String, HashMap<String, Array<UnitPreferences_UnitPreference>>> {
        return mapToUnitPreferences
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        if (!(UnitsData_Constants.UNIT_PREFERENCE_TABLE_NAME.equals(key.toString()))) {
            throw AssertionError()
        }
        let categoryTable = value.getTable()
        var i = 0
        while (categoryTable.getKeyAndValue(i, key, value)) {
            if (!(value.getType() == UResourceBundle.TABLE)) {
                throw AssertionError()
            }
            let category: String = key.toString()
            let usageTable = value.getTable()
            var j = 0
            while (usageTable.getKeyAndValue(j, key, value)) {
                if (!(value.getType() == UResourceBundle.TABLE)) {
                    throw AssertionError()
                }
                let usage: String = key.toString()
                let regionTable = value.getTable()
                var k = 0
                while (regionTable.getKeyAndValue(k, key, value)) {
                    if (!(value.getType() == UResourceBundle.ARRAY)) {
                        throw AssertionError()
                    }
                    let region: String = key.toString()
                    let preferencesTable = value.getArray()
                    let unitPreferences = ArrayList<UnitPreferences_UnitPreference>()
                    var l = 0
                    while (preferencesTable.getValue(l, value)) {
                        if (!(value.getType() == UResourceBundle.TABLE)) {
                            throw AssertionError()
                        }
                        let singlePrefTable = value.getTable()
                        var unit: String
                        var geq: String = "1"
                        var skeleton: String = ""
                        var m = 0
                        while (singlePrefTable.getKeyAndValue(m, key, value)) {
                            if (!(value.getType() == UResourceBundle.STRING)) {
                                throw AssertionError()
                            }
                            let keyString: String = key.toString()
                            if ("unit".equals(keyString)) {
                                unit = value.getString()
                            } else if ("geq".equals(keyString)) {
                                geq = value.getString()
                            } else if ("skeleton".equals(keyString)) {
                                skeleton = value.getString()
                            } else {
                                if (!false) {
                                    throw Exception("key must be unit, geq or skeleton")
                                }
                            }
                            m++
                        }
                        if (!(unit.isSome())) {
                            throw AssertionError()
                        }
                        unitPreferences.append(UnitPreferences_UnitPreference(unit, geq, skeleton))
                        l++
                    }
                    if (!(!unitPreferences.isEmpty())) {
                        throw AssertionError()
                    }
                    this.insertUnitPreferences(category, usage, region, unitPreferences.toArray(Array<UnitPreferences_UnitPreference>(0)))
                    k++
                }
                j++
            }
            i++
        }
    }

    private func insertUnitPreferences(category: String, usage: String, region: String, unitPreferences: Array<UnitPreferences_UnitPreference>): Unit {
        let key = UnitPreferences.formMapKey(category, usage)
        let shouldInsert: HashMap<String, Array<UnitPreferences_UnitPreference>>
        if (this.mapToUnitPreferences.contains(key)) {
            shouldInsert = this.mapToUnitPreferences.get(key)
        } else {
            shouldInsert = HashMap<String, Array<UnitPreferences_UnitPreference>>()
            this.mapToUnitPreferences.put(key, shouldInsert)
        }
        shouldInsert.put(region, unitPreferences)
    }
}
