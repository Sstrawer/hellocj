package icu4cj.impl.units


public class UnitsData {
    private static var simpleUnits: Array<String>

    private static var simpleUnitCategories: Array<Int32>

    private var conversionRates: ConversionRates

    private var unitPreferences: UnitPreferences

    public init() {
        this.conversionRates = ConversionRates()
        this.unitPreferences = UnitPreferences()
    }

    public static func getSimpleUnits(): Array<String> {
        return simpleUnits
    }


    public func getConversionRates(): ConversionRates {
        return conversionRates
    }

    public func getUnitPreferences(): UnitPreferences {
        return unitPreferences
    }

    public static func getCategoryIndexOfSimpleUnit(simpleUnitIndex: Int32): Int32 {
        return simpleUnitCategories[Int64(simpleUnitIndex)]
    }

    public func getCategory(measureUnit: MeasureUnitImpl): String {
        let baseMeasureUnitImpl = this.getConversionRates().extractCompoundBaseUnit(measureUnit)
        baseMeasureUnitImpl.serialize()
        var identifier = baseMeasureUnitImpl.getIdentifier()
        var index = UnitsData_Categories.baseUnitToIndex.get(identifier)
        if (index.isNone()) {
            baseMeasureUnitImpl.takeReciprocal()
            baseMeasureUnitImpl.serialize()
            identifier = baseMeasureUnitImpl.getIdentifier()
            index = UnitsData_Categories.baseUnitToIndex.get(identifier)
        }
        baseMeasureUnitImpl.takeReciprocal()
        let simplifiedUnit = baseMeasureUnitImpl.copyAndSimplify()
        if (index.isNone()) {
            simplifiedUnit.serialize()
            identifier = simplifiedUnit.getIdentifier()
            index = UnitsData_Categories.baseUnitToIndex.get(identifier)
        }
        if (index.isNone()) {
            simplifiedUnit.takeReciprocal()
            simplifiedUnit.serialize()
            identifier = simplifiedUnit.getIdentifier()
            index = UnitsData_Categories.baseUnitToIndex.get(identifier)
        }
        if (index.isNone()) {
            throw IllegalIcuArgumentException("This unit does not has a category" + (measureUnit.getIdentifier()))
        }
        return UnitsData_Categories.indexToCategory[Int64(index)]
    }

    public func getPreferencesFor(category: String, usage: String, locale: ULocale): Array<UnitPreferences_UnitPreference> {
        return this.unitPreferences.getPreferencesFor(category, usage, locale, this)
    }
}


public class UnitsData_SimpleUnitIdentifiersSink <: UResource_Sink {
    public init() {
        super()
    }

    var simpleUnits: Array<String>

    var simpleUnitCategories: Array<Int32>

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        if (!key.toString().equals(UnitsData_Constants.CONVERSION_UNIT_TABLE_NAME)) {
            throw AssertionError()
        }
        if (!(value.getType() == UResourceBundle.TABLE)) {
            throw AssertionError()
        }
        let simpleUnitsTable = value.getTable()
        let simpleUnits = ArrayList<String>()
        let simpleUnitCategories = ArrayList<Int32>()
                let table = value.getTable()
                if (!table.findValue("target", value)) {
                    if (!false) {
                        throw Exception("Could not find \"target\" for simple unit: " + key.asString())
                    }
                    continue
                }
                let target = value.getString()
                simpleUnits.append(key.toString())
                simpleUnitCategories.append(UnitsData_Categories.baseUnitToIndex.get(target))
                i++
            }
        this.simpleUnits = simpleUnits.toArray(Array<String>(0))
        this.simpleUnitCategories = Array<Int32>(simpleUnitCategories.size) { _ => 0 }
        let iter: Iterator<Int32> = simpleUnitCategories.iterator()
    }
}


public class UnitsData_Constants {

    public static let kSimpleUnitOffset = 512

    public static let kPowerPartOffset = 256

    public static let kInitialCompoundPartOffset = 192

    public static let kCompoundPartOffset = 128

    public static let kPrefixOffset = 64

    public static let CONVERSION_UNIT_TABLE_NAME = "convertUnits"

    public static let UNIT_PREFERENCE_TABLE_NAME = "unitPreferenceData"

    public static let CATEGORY_TABLE_NAME = "unitQuantities"

    public static let DEFAULT_REGION = "001"

    public static let DEFAULT_USAGE = "default"
}


public class UnitsData_Categories {

    static var baseUnitToIndex: HashMap<String, Int32> = None

    static var indexToCategory: Array<String>

}


public class UnitsData_CategoriesSink <: UResource_Sink {
    var mapFromUnitToIndex: HashMap<String, Int32> = None

    var categories: ArrayList<String>

    public init() {
        super()
        mapFromUnitToIndex = HashMap<String, Int32>()
        categories = ArrayList<String>()
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        if (!(key.toString().equals(UnitsData_Constants.CATEGORY_TABLE_NAME))) {
            throw AssertionError()
        }
        if (!(value.getType() == UResourceBundle.ARRAY)) {
            throw AssertionError()
        }
        let categoryArray = value.getArray()
        var i = 0
        while (categoryArray.getValue(i, value)) {
            if (!(value.getType() == UResourceBundle.TABLE)) {
                throw AssertionError()
            }
            let table = value.getTable()
            if (!(table.getSize() == 1)) {
                throw Exception("expecting single-entry table, got size: " + table.getSize().toString())
            }
            table.getKeyAndValue(0, key, value)
            if (!(value.getType() == UResourceBundle.STRING)) {
                throw Exception("expecting category string")
            }
            mapFromUnitToIndex.put(key.toString(), Int32(categories.size))
            categories.append(value.toString())
            i++
        }
    }
}
