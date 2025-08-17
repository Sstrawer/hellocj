package icu4cj.util


public class MeasureUnit <: Serializable {
    private static let GeneratedStaticLockObject = Monitor()

    private static let serialVersionUID = -1839973855554750484

    private static let cache: Map<String, Map<String, MeasureUnit>> = HashMap<String, Map<String, MeasureUnit>>()

    private static var cacheIsPopulated = false

    
    protected let Type: String

    
    protected let subType: String

    private var measureUnitImpl: MeasureUnitImpl

    
    protected init(Type: String, subType: String) {
        this.Type = Type
        this.subType = subType
    }

    public static func forIdentifier(identifier: String): MeasureUnit {
        if (identifier.isNone() || identifier.isEmpty()) {
            return NoUnit.BASE
        }
        return MeasureUnitImpl.forIdentifier(identifier).build()
    }

    
    public static func fromMeasureUnitImpl(measureUnitImpl: MeasureUnitImpl): MeasureUnit {
        measureUnitImpl.serialize()
        let identifier = measureUnitImpl.getIdentifier()
        let result = MeasureUnit.findBySubType(identifier)
        if (result.isSome()) {
            return result
        }
        return MeasureUnit(measureUnitImpl)
    }

    private init(measureUnitImpl: MeasureUnitImpl) {
        Type = None
        subType = None
        this.measureUnitImpl = measureUnitImpl.copy()
    }

    public func getType(): String {
        return Type
    }

    public func getSubtype(): String {
        return subType
    }

    public func getIdentifier(): String {
        let result = if (measureUnitImpl.isNone()) { getSubtype() } else { measureUnitImpl.getIdentifier() }
        return if (result.isNone()) { "" } else { result }
    }

    public func getComplexity(): MeasureUnit_Complexity {
        if (measureUnitImpl.isNone()) {
            return MeasureUnitImpl.forIdentifier(getIdentifier()).getComplexity()
        }
        return measureUnitImpl.getComplexity()
    }

    public func withPrefix(prefix: MeasureUnit_MeasurePrefix): MeasureUnit {
        let singleUnit = getSingleUnitImpl()
        singleUnit.setPrefix(prefix)
        return singleUnit.build()
    }

    public func getPrefix(): MeasureUnit_MeasurePrefix {
        return getSingleUnitImpl().getPrefix()
    }

    public func getDimensionality(): Int32 {
        return getSingleUnitImpl().getDimensionality()
    }

    public func withDimensionality(dimensionality: Int32): MeasureUnit {
        let singleUnit = getSingleUnitImpl()
        singleUnit.setDimensionality(dimensionality)
        return singleUnit.build()
    }

    public func reciprocal(): MeasureUnit {
        let measureUnit = getCopyOfMeasureUnitImpl()
        measureUnit.takeReciprocal()
        return measureUnit.build()
    }

    public func product(other: MeasureUnit): MeasureUnit {
        let implCopy = getCopyOfMeasureUnitImpl()
        if (other.isNone()) {
            return implCopy.build()
        }
        let otherImplRef = other.getMaybeReferenceOfMeasureUnitImpl()
        if (refEq(implCopy.getComplexity(), MeasureUnit_Complexity.MIXED) || refEq(otherImplRef.getComplexity(), MeasureUnit_Complexity.MIXED)) {
            throw UnsupportedOperationException()
        }
        for (singleUnit in otherImplRef.getSingleUnits()) {
            implCopy.appendSingleUnit(singleUnit)
        }
        return implCopy.build()
    }

    public func splitToSingleUnits(): ArrayList<MeasureUnit> {
        let singleUnits = getMaybeReferenceOfMeasureUnitImpl().getSingleUnits()
        let result = ArrayList<MeasureUnit>(singleUnits.size)
        for (singleUnit in singleUnits) {
            result.append(singleUnit.build())
        }
        return result
    }

    public override func hashCode(): Int64 {
        return Int64(31 * Int32(Type.hashCode()) + Int32(subType.hashCode()))
    }

    public override func equals(rhs: Object): Bool {
        if (refEq(rhs, this)) {
            return true
        }
        if (!(checkOptionalIs<MeasureUnit, Object>(rhs))) {
            return false
        }
        return this.getIdentifier().equals(rhs.getIdentifier())
    }

    public override func toString(): String {
        let result = if (measureUnitImpl.isNone()) { Some((Type) + "-" + (subType)) } else { measureUnitImpl.getIdentifier() }
        return if (result.isNone()) { "" } else { result }
    }

    public static func getAvailableTypes(): Set<String> {
        populateCache()
        return Collections.unmodifiableSet(SetCollectionView<String>(cache.keys()) as Set<T>)
    }

    public static func getAvailable(Type: String): Set<MeasureUnit> {
        populateCache()
        let units = cache.get(Type)
        return if (units.isNone()) { Collections.emptySet<<--> -->() } else { Collections.unmodifiableSet(CollectionSet<E>(units.values() as Collection<E>) as Set<T>) }
    }

    public static func getAvailable(): Set<MeasureUnit> {
        synchronized (GeneratedStaticLockObject) {
            let result: Set<MeasureUnit> = HashSet<MeasureUnit>()
            for (Type in HashSet<String>(MeasureUnit.getAvailableTypes())) {
                for (unit in MeasureUnit.getAvailable(Type)) {
                    result.put(unit)
                }
            }
            return Collections.unmodifiableSet(result as Set<T>)
        }
    }

    
    public static func internalGetInstance(Type: String, subType: String): MeasureUnit {
        if (Type.isNone() || subType.isNone()) {
            throw NoneValueException("Type and subType must be non-null")
        }
        if (!"currency".equals(Type)) {
            if (!ASCII.containsAll(Type) || !ASCII_HYPHEN_DIGITS.containsAll(subType)) {
                throw IllegalArgumentException("The type or subType are invalid.")
            }
        }
        let factory: MeasureUnit_Factory
        if ("currency".equals(Type)) {
            factory = CURRENCY_FACTORY
        } else if ("duration".equals(Type)) {
            factory = TIMEUNIT_FACTORY
        } else {
            factory = UNIT_FACTORY
        }
        return MeasureUnit.addUnit(Type, subType, factory)
    }

    
    public static func findBySubType(subType: String): MeasureUnit {
        populateCache()
        for (unitsForType in cache.values()) {
            if (unitsForType.contains(subType)) {
                return unitsForType.get(subType)
            }
        }
        return None
    }

    static let ASCII = UnicodeSet(Int32(UInt32('a')), Int32(UInt32('z'))).freeze()

    static let ASCII_HYPHEN_DIGITS = UnicodeSet([Int32(UInt32('-')), Int32(UInt32('-')), Int32(UInt32('0')), Int32(UInt32('9')), Int32(UInt32('a')), Int32(UInt32('z'))]).freeze()

    private static var UNIT_FACTORY: MeasureUnit_Factory = MeasureUnit_1()

    static var CURRENCY_FACTORY: MeasureUnit_Factory = MeasureUnit_2()

    static var TIMEUNIT_FACTORY: MeasureUnit_Factory = MeasureUnit_3()

    private static func populateCache(): Unit {
        synchronized (GeneratedStaticLockObject) {
            if (cacheIsPopulated) {
                return
            }
            cacheIsPopulated = true
            let rb1 = UResourceBundle.getBundleInstance(ICUData.ICU_UNIT_BASE_NAME, "en")
            rb1.getAllItemsWithFallback("units", MeasureUnit_MeasureUnitSink())
            let rb2 = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "currencyNumericCodes", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
            rb2.getAllItemsWithFallback("codeMap", MeasureUnit_CurrencyNumericCodeSink())
        }
    }

    
    protected static func addUnit(Type: String, unitName: String, factory: MeasureUnit_Factory): MeasureUnit {
        synchronized (GeneratedStaticLockObject) {
            var temptype = Type
            var tmp = cache.get(temptype)
            if (tmp.isNone()) {
                cache.put(temptype, match (0) { case _ => tmp = HashMap<String, MeasureUnit>(); tmp })
            } else {
                temptype = tmp.entrySet().iterator().next().getValue().Type
            }
            var unit = tmp.get(unitName)
            if (unit.isNone()) {
                tmp.put(unitName, match (0) { case _ => unit = factory.create(temptype, unitName); unit })
            }
            return unit
        }
    }

    public static let G_FORCE = MeasureUnit.internalGetInstance("acceleration", "g-force")

    public static let METER_PER_SECOND_SQUARED = MeasureUnit.internalGetInstance("acceleration", "meter-per-square-second")

    public static let ARC_MINUTE = MeasureUnit.internalGetInstance("angle", "arc-minute")

    public static let ARC_SECOND = MeasureUnit.internalGetInstance("angle", "arc-second")

    public static let DEGREE = MeasureUnit.internalGetInstance("angle", "degree")

    public static let RADIAN = MeasureUnit.internalGetInstance("angle", "radian")

    public static let REVOLUTION_ANGLE = MeasureUnit.internalGetInstance("angle", "revolution")

    public static let ACRE = MeasureUnit.internalGetInstance("area", "acre")

    public static let DUNAM = MeasureUnit.internalGetInstance("area", "dunam")

    public static let HECTARE = MeasureUnit.internalGetInstance("area", "hectare")

    public static let SQUARE_CENTIMETER = MeasureUnit.internalGetInstance("area", "square-centimeter")

    public static let SQUARE_FOOT = MeasureUnit.internalGetInstance("area", "square-foot")

    public static let SQUARE_INCH = MeasureUnit.internalGetInstance("area", "square-inch")

    public static let SQUARE_KILOMETER = MeasureUnit.internalGetInstance("area", "square-kilometer")

    public static let SQUARE_METER = MeasureUnit.internalGetInstance("area", "square-meter")

    public static let SQUARE_MILE = MeasureUnit.internalGetInstance("area", "square-mile")

    public static let SQUARE_YARD = MeasureUnit.internalGetInstance("area", "square-yard")

    public static let ITEM = MeasureUnit.internalGetInstance("concentr", "item")

    public static let KARAT = MeasureUnit.internalGetInstance("concentr", "karat")

    public static let MILLIGRAM_OFGLUCOSE_PER_DECILITER = MeasureUnit.internalGetInstance("concentr", "milligram-ofglucose-per-deciliter")

    public static let MILLIGRAM_PER_DECILITER = MeasureUnit.internalGetInstance("concentr", "milligram-per-deciliter")

    public static let MILLIMOLE_PER_LITER = MeasureUnit.internalGetInstance("concentr", "millimole-per-liter")

    public static let MOLE = MeasureUnit.internalGetInstance("concentr", "mole")

    public static let PERCENT = MeasureUnit.internalGetInstance("concentr", "percent")

    public static let PERMILLE = MeasureUnit.internalGetInstance("concentr", "permille")

    public static let PART_PER_MILLION = MeasureUnit.internalGetInstance("concentr", "permillion")

    public static let PERMYRIAD = MeasureUnit.internalGetInstance("concentr", "permyriad")

    public static let LITER_PER_100KILOMETERS = MeasureUnit.internalGetInstance("consumption", "liter-per-100-kilometer")

    public static let LITER_PER_KILOMETER = MeasureUnit.internalGetInstance("consumption", "liter-per-kilometer")

    public static let MILE_PER_GALLON = MeasureUnit.internalGetInstance("consumption", "mile-per-gallon")

    public static let MILE_PER_GALLON_IMPERIAL = MeasureUnit.internalGetInstance("consumption", "mile-per-gallon-imperial")

    public static let BIT = MeasureUnit.internalGetInstance("digital", "bit")

    public static let BYTE = MeasureUnit.internalGetInstance("digital", "byte")

    public static let GIGABIT = MeasureUnit.internalGetInstance("digital", "gigabit")

    public static let GIGABYTE = MeasureUnit.internalGetInstance("digital", "gigabyte")

    public static let KILOBIT = MeasureUnit.internalGetInstance("digital", "kilobit")

    public static let KILOBYTE = MeasureUnit.internalGetInstance("digital", "kilobyte")

    public static let MEGABIT = MeasureUnit.internalGetInstance("digital", "megabit")

    public static let MEGABYTE = MeasureUnit.internalGetInstance("digital", "megabyte")

    public static let PETABYTE = MeasureUnit.internalGetInstance("digital", "petabyte")

    public static let TERABIT = MeasureUnit.internalGetInstance("digital", "terabit")

    public static let TERABYTE = MeasureUnit.internalGetInstance("digital", "terabyte")

    public static let CENTURY = MeasureUnit.internalGetInstance("duration", "century")

    public static let DAY = MeasureUnit.internalGetInstance("duration", "day")

    public static let DAY_PERSON = MeasureUnit.internalGetInstance("duration", "day-person")

    public static let DECADE = MeasureUnit.internalGetInstance("duration", "decade")

    public static let HOUR = MeasureUnit.internalGetInstance("duration", "hour")

    public static let MICROSECOND = MeasureUnit.internalGetInstance("duration", "microsecond")

    public static let MILLISECOND = MeasureUnit.internalGetInstance("duration", "millisecond")

    public static let MINUTE = MeasureUnit.internalGetInstance("duration", "minute")

    public static let MONTH = MeasureUnit.internalGetInstance("duration", "month")

    public static let MONTH_PERSON = MeasureUnit.internalGetInstance("duration", "month-person")

    public static let NANOSECOND = MeasureUnit.internalGetInstance("duration", "nanosecond")

    public static let QUARTER = MeasureUnit.internalGetInstance("duration", "quarter")

    public static let SECOND = MeasureUnit.internalGetInstance("duration", "second")

    public static let WEEK = MeasureUnit.internalGetInstance("duration", "week")

    public static let WEEK_PERSON = MeasureUnit.internalGetInstance("duration", "week-person")

    public static let YEAR = MeasureUnit.internalGetInstance("duration", "year")

    public static let YEAR_PERSON = MeasureUnit.internalGetInstance("duration", "year-person")

    public static let AMPERE = MeasureUnit.internalGetInstance("electric", "ampere")

    public static let MILLIAMPERE = MeasureUnit.internalGetInstance("electric", "milliampere")

    public static let OHM = MeasureUnit.internalGetInstance("electric", "ohm")

    public static let VOLT = MeasureUnit.internalGetInstance("electric", "volt")

    public static let BRITISH_THERMAL_UNIT = MeasureUnit.internalGetInstance("energy", "british-thermal-unit")

    public static let CALORIE = MeasureUnit.internalGetInstance("energy", "calorie")

    public static let ELECTRONVOLT = MeasureUnit.internalGetInstance("energy", "electronvolt")

    public static let FOODCALORIE = MeasureUnit.internalGetInstance("energy", "foodcalorie")

    public static let JOULE = MeasureUnit.internalGetInstance("energy", "joule")

    public static let KILOCALORIE = MeasureUnit.internalGetInstance("energy", "kilocalorie")

    public static let KILOJOULE = MeasureUnit.internalGetInstance("energy", "kilojoule")

    public static let KILOWATT_HOUR = MeasureUnit.internalGetInstance("energy", "kilowatt-hour")

    public static let THERM_US = MeasureUnit.internalGetInstance("energy", "therm-us")

    public static let KILOWATT_HOUR_PER_100_KILOMETER = MeasureUnit.internalGetInstance("force", "kilowatt-hour-per-100-kilometer")

    public static let NEWTON = MeasureUnit.internalGetInstance("force", "newton")

    public static let POUND_FORCE = MeasureUnit.internalGetInstance("force", "pound-force")

    public static let GIGAHERTZ = MeasureUnit.internalGetInstance("frequency", "gigahertz")

    public static let HERTZ = MeasureUnit.internalGetInstance("frequency", "hertz")

    public static let KILOHERTZ = MeasureUnit.internalGetInstance("frequency", "kilohertz")

    public static let MEGAHERTZ = MeasureUnit.internalGetInstance("frequency", "megahertz")

    public static let DOT = MeasureUnit.internalGetInstance("graphics", "dot")

    public static let DOT_PER_CENTIMETER = MeasureUnit.internalGetInstance("graphics", "dot-per-centimeter")

    public static let DOT_PER_INCH = MeasureUnit.internalGetInstance("graphics", "dot-per-inch")

    public static let EM = MeasureUnit.internalGetInstance("graphics", "em")

    public static let MEGAPIXEL = MeasureUnit.internalGetInstance("graphics", "megapixel")

    public static let PIXEL = MeasureUnit.internalGetInstance("graphics", "pixel")

    public static let PIXEL_PER_CENTIMETER = MeasureUnit.internalGetInstance("graphics", "pixel-per-centimeter")

    public static let PIXEL_PER_INCH = MeasureUnit.internalGetInstance("graphics", "pixel-per-inch")

    public static let ASTRONOMICAL_UNIT = MeasureUnit.internalGetInstance("length", "astronomical-unit")

    public static let CENTIMETER = MeasureUnit.internalGetInstance("length", "centimeter")

    public static let DECIMETER = MeasureUnit.internalGetInstance("length", "decimeter")

    public static let EARTH_RADIUS = MeasureUnit.internalGetInstance("length", "earth-radius")

    public static let FATHOM = MeasureUnit.internalGetInstance("length", "fathom")

    public static let FOOT = MeasureUnit.internalGetInstance("length", "foot")

    public static let FURLONG = MeasureUnit.internalGetInstance("length", "furlong")

    public static let INCH = MeasureUnit.internalGetInstance("length", "inch")

    public static let KILOMETER = MeasureUnit.internalGetInstance("length", "kilometer")

    public static let LIGHT_YEAR = MeasureUnit.internalGetInstance("length", "light-year")

    public static let METER = MeasureUnit.internalGetInstance("length", "meter")

    public static let MICROMETER = MeasureUnit.internalGetInstance("length", "micrometer")

    public static let MILE = MeasureUnit.internalGetInstance("length", "mile")

    public static let MILE_SCANDINAVIAN = MeasureUnit.internalGetInstance("length", "mile-scandinavian")

    public static let MILLIMETER = MeasureUnit.internalGetInstance("length", "millimeter")

    public static let NANOMETER = MeasureUnit.internalGetInstance("length", "nanometer")

    public static let NAUTICAL_MILE = MeasureUnit.internalGetInstance("length", "nautical-mile")

    public static let PARSEC = MeasureUnit.internalGetInstance("length", "parsec")

    public static let PICOMETER = MeasureUnit.internalGetInstance("length", "picometer")

    public static let POINT = MeasureUnit.internalGetInstance("length", "point")

    public static let SOLAR_RADIUS = MeasureUnit.internalGetInstance("length", "solar-radius")

    public static let YARD = MeasureUnit.internalGetInstance("length", "yard")

    public static let CANDELA = MeasureUnit.internalGetInstance("light", "candela")

    public static let LUMEN = MeasureUnit.internalGetInstance("light", "lumen")

    public static let LUX = MeasureUnit.internalGetInstance("light", "lux")

    public static let SOLAR_LUMINOSITY = MeasureUnit.internalGetInstance("light", "solar-luminosity")

    public static let CARAT = MeasureUnit.internalGetInstance("mass", "carat")

    public static let DALTON = MeasureUnit.internalGetInstance("mass", "dalton")

    public static let EARTH_MASS = MeasureUnit.internalGetInstance("mass", "earth-mass")

    public static let GRAIN = MeasureUnit.internalGetInstance("mass", "grain")

    public static let GRAM = MeasureUnit.internalGetInstance("mass", "gram")

    public static let KILOGRAM = MeasureUnit.internalGetInstance("mass", "kilogram")

    public static let METRIC_TON = MeasureUnit.internalGetInstance("mass", "tonne")

    public static let MICROGRAM = MeasureUnit.internalGetInstance("mass", "microgram")

    public static let MILLIGRAM = MeasureUnit.internalGetInstance("mass", "milligram")

    public static let OUNCE = MeasureUnit.internalGetInstance("mass", "ounce")

    public static let OUNCE_TROY = MeasureUnit.internalGetInstance("mass", "ounce-troy")

    public static let POUND = MeasureUnit.internalGetInstance("mass", "pound")

    public static let SOLAR_MASS = MeasureUnit.internalGetInstance("mass", "solar-mass")

    public static let STONE = MeasureUnit.internalGetInstance("mass", "stone")

    public static let TON = MeasureUnit.internalGetInstance("mass", "ton")

    public static let TONNE = MeasureUnit.internalGetInstance("mass", "tonne")

    public static let GIGAWATT = MeasureUnit.internalGetInstance("power", "gigawatt")

    public static let HORSEPOWER = MeasureUnit.internalGetInstance("power", "horsepower")

    public static let KILOWATT = MeasureUnit.internalGetInstance("power", "kilowatt")

    public static let MEGAWATT = MeasureUnit.internalGetInstance("power", "megawatt")

    public static let MILLIWATT = MeasureUnit.internalGetInstance("power", "milliwatt")

    public static let WATT = MeasureUnit.internalGetInstance("power", "watt")

    public static let ATMOSPHERE = MeasureUnit.internalGetInstance("pressure", "atmosphere")

    public static let BAR = MeasureUnit.internalGetInstance("pressure", "bar")

    public static let GASOLINE_ENERGY_DENSITY = MeasureUnit.internalGetInstance("pressure", "gasoline-energy-density")

    public static let HECTOPASCAL = MeasureUnit.internalGetInstance("pressure", "hectopascal")

    public static let INCH_HG = MeasureUnit.internalGetInstance("pressure", "inch-ofhg")

    public static let KILOPASCAL = MeasureUnit.internalGetInstance("pressure", "kilopascal")

    public static let MEGAPASCAL = MeasureUnit.internalGetInstance("pressure", "megapascal")

    public static let MILLIBAR = MeasureUnit.internalGetInstance("pressure", "millibar")

    public static let MILLIMETER_OF_MERCURY = MeasureUnit.internalGetInstance("pressure", "millimeter-ofhg")

    public static let PASCAL = MeasureUnit.internalGetInstance("pressure", "pascal")

    public static let POUND_PER_SQUARE_INCH = MeasureUnit.internalGetInstance("pressure", "pound-force-per-square-inch")

    public static let BEAUFORT = MeasureUnit.internalGetInstance("speed", "beaufort")

    public static let KILOMETER_PER_HOUR = MeasureUnit.internalGetInstance("speed", "kilometer-per-hour")

    public static let KNOT = MeasureUnit.internalGetInstance("speed", "knot")

    public static let METER_PER_SECOND = MeasureUnit.internalGetInstance("speed", "meter-per-second")

    public static let MILE_PER_HOUR = MeasureUnit.internalGetInstance("speed", "mile-per-hour")

    public static let CELSIUS = MeasureUnit.internalGetInstance("temperature", "celsius")

    public static let FAHRENHEIT = MeasureUnit.internalGetInstance("temperature", "fahrenheit")

    public static let GENERIC_TEMPERATURE = MeasureUnit.internalGetInstance("temperature", "generic")

    public static let KELVIN = MeasureUnit.internalGetInstance("temperature", "kelvin")

    public static let NEWTON_METER = MeasureUnit.internalGetInstance("torque", "newton-meter")

    public static let POUND_FOOT = MeasureUnit.internalGetInstance("torque", "pound-force-foot")

    public static let ACRE_FOOT = MeasureUnit.internalGetInstance("volume", "acre-foot")

    public static let BARREL = MeasureUnit.internalGetInstance("volume", "barrel")

    public static let BUSHEL = MeasureUnit.internalGetInstance("volume", "bushel")

    public static let CENTILITER = MeasureUnit.internalGetInstance("volume", "centiliter")

    public static let CUBIC_CENTIMETER = MeasureUnit.internalGetInstance("volume", "cubic-centimeter")

    public static let CUBIC_FOOT = MeasureUnit.internalGetInstance("volume", "cubic-foot")

    public static let CUBIC_INCH = MeasureUnit.internalGetInstance("volume", "cubic-inch")

    public static let CUBIC_KILOMETER = MeasureUnit.internalGetInstance("volume", "cubic-kilometer")

    public static let CUBIC_METER = MeasureUnit.internalGetInstance("volume", "cubic-meter")

    public static let CUBIC_MILE = MeasureUnit.internalGetInstance("volume", "cubic-mile")

    public static let CUBIC_YARD = MeasureUnit.internalGetInstance("volume", "cubic-yard")

    public static let CUP = MeasureUnit.internalGetInstance("volume", "cup")

    public static let CUP_METRIC = MeasureUnit.internalGetInstance("volume", "cup-metric")

    public static let DECILITER = MeasureUnit.internalGetInstance("volume", "deciliter")

    public static let DESSERT_SPOON = MeasureUnit.internalGetInstance("volume", "dessert-spoon")

    public static let DESSERT_SPOON_IMPERIAL = MeasureUnit.internalGetInstance("volume", "dessert-spoon-imperial")

    public static let DRAM = MeasureUnit.internalGetInstance("volume", "dram")

    public static let DROP = MeasureUnit.internalGetInstance("volume", "drop")

    public static let FLUID_OUNCE = MeasureUnit.internalGetInstance("volume", "fluid-ounce")

    public static let FLUID_OUNCE_IMPERIAL = MeasureUnit.internalGetInstance("volume", "fluid-ounce-imperial")

    public static let GALLON = MeasureUnit.internalGetInstance("volume", "gallon")

    public static let GALLON_IMPERIAL = MeasureUnit.internalGetInstance("volume", "gallon-imperial")

    public static let HECTOLITER = MeasureUnit.internalGetInstance("volume", "hectoliter")

    public static let JIGGER = MeasureUnit.internalGetInstance("volume", "jigger")

    public static let LITER = MeasureUnit.internalGetInstance("volume", "liter")

    public static let MEGALITER = MeasureUnit.internalGetInstance("volume", "megaliter")

    public static let MILLILITER = MeasureUnit.internalGetInstance("volume", "milliliter")

    public static let PINCH = MeasureUnit.internalGetInstance("volume", "pinch")

    public static let PINT = MeasureUnit.internalGetInstance("volume", "pint")

    public static let PINT_METRIC = MeasureUnit.internalGetInstance("volume", "pint-metric")

    public static let QUART = MeasureUnit.internalGetInstance("volume", "quart")

    public static let QUART_IMPERIAL = MeasureUnit.internalGetInstance("volume", "quart-imperial")

    public static let TABLESPOON = MeasureUnit.internalGetInstance("volume", "tablespoon")

    public static let TEASPOON = MeasureUnit.internalGetInstance("volume", "teaspoon")

    private func writeReplace(): Object {
        return MeasureUnit_MeasureUnitProxy(Type, subType)
    }

    private func getSingleUnitImpl(): SingleUnitImpl {
        if (measureUnitImpl.isNone()) {
            return MeasureUnitImpl.forIdentifier(getIdentifier()).getSingleUnitImpl()
        }
        return measureUnitImpl.getSingleUnitImpl()
    }

    
    public func getCopyOfMeasureUnitImpl(): MeasureUnitImpl {
        return if (this.measureUnitImpl.isNone()) { MeasureUnitImpl.forIdentifier(getIdentifier()) } else { this.measureUnitImpl.copy() }
    }

    private func getMaybeReferenceOfMeasureUnitImpl(): MeasureUnitImpl {
        return if (this.measureUnitImpl.isNone()) { MeasureUnitImpl.forIdentifier(getIdentifier()) } else { this.measureUnitImpl }
    }
}


public class MeasureUnit_Complexity <: Enum<MeasureUnit_Complexity> {
    public static let SINGLE = MeasureUnit_Complexity("SINGLE", 0)

    public static let COMPOUND = MeasureUnit_Complexity("COMPOUND", 1)

    public static let MIXED = MeasureUnit_Complexity("MIXED", 2)

    private static func _values(): Array<MeasureUnit_Complexity> {
        return [MeasureUnit_Complexity.SINGLE, MeasureUnit_Complexity.COMPOUND, MeasureUnit_Complexity.MIXED]
    }

    private static let _VALUES = MeasureUnit_Complexity._values()

    public static func values(): Array<MeasureUnit_Complexity> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): MeasureUnit_Complexity {
        return (TypeInfo.of<MeasureUnit_Complexity>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as MeasureUnit_Complexity
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class MeasureUnit_MeasurePrefix <: Enum<MeasureUnit_MeasurePrefix> {
    public static let QUETTA = MeasureUnit_MeasurePrefix("QUETTA", 0, 30, "quetta", 10)

    public static let RONNA = MeasureUnit_MeasurePrefix("RONNA", 1, 27, "ronna", 10)

    public static let YOTTA = MeasureUnit_MeasurePrefix("YOTTA", 2, 24, "yotta", 10)

    public static let ZETTA = MeasureUnit_MeasurePrefix("ZETTA", 3, 21, "zetta", 10)

    public static let EXA = MeasureUnit_MeasurePrefix("EXA", 4, 18, "exa", 10)

    public static let PETA = MeasureUnit_MeasurePrefix("PETA", 5, 15, "peta", 10)

    public static let TERA = MeasureUnit_MeasurePrefix("TERA", 6, 12, "tera", 10)

    public static let GIGA = MeasureUnit_MeasurePrefix("GIGA", 7, 9, "giga", 10)

    public static let MEGA = MeasureUnit_MeasurePrefix("MEGA", 8, 6, "mega", 10)

    public static let KILO = MeasureUnit_MeasurePrefix("KILO", 9, 3, "kilo", 10)

    public static let HECTO = MeasureUnit_MeasurePrefix("HECTO", 10, 2, "hecto", 10)

    public static let DEKA = MeasureUnit_MeasurePrefix("DEKA", 11, 1, "deka", 10)

    public static let ONE = MeasureUnit_MeasurePrefix("ONE", 12, 0, "", 10)

    public static let DECI = MeasureUnit_MeasurePrefix("DECI", 13, -1, "deci", 10)

    public static let CENTI = MeasureUnit_MeasurePrefix("CENTI", 14, -2, "centi", 10)

    public static let MILLI = MeasureUnit_MeasurePrefix("MILLI", 15, -3, "milli", 10)

    public static let MICRO = MeasureUnit_MeasurePrefix("MICRO", 16, -6, "micro", 10)

    public static let NANO = MeasureUnit_MeasurePrefix("NANO", 17, -9, "nano", 10)

    public static let PICO = MeasureUnit_MeasurePrefix("PICO", 18, -12, "pico", 10)

    public static let FEMTO = MeasureUnit_MeasurePrefix("FEMTO", 19, -15, "femto", 10)

    public static let ATTO = MeasureUnit_MeasurePrefix("ATTO", 20, -18, "atto", 10)

    public static let ZEPTO = MeasureUnit_MeasurePrefix("ZEPTO", 21, -21, "zepto", 10)

    public static let YOCTO = MeasureUnit_MeasurePrefix("YOCTO", 22, -24, "yocto", 10)

    public static let RONTO = MeasureUnit_MeasurePrefix("RONTO", 23, -27, "ronto", 10)

    public static let QUECTO = MeasureUnit_MeasurePrefix("QUECTO", 24, -30, "quecto", 10)

    public static let KIBI = MeasureUnit_MeasurePrefix("KIBI", 25, 1, "kibi", 1024)

    public static let MEBI = MeasureUnit_MeasurePrefix("MEBI", 26, 2, "mebi", 1024)

    public static let GIBI = MeasureUnit_MeasurePrefix("GIBI", 27, 3, "gibi", 1024)

    public static let TEBI = MeasureUnit_MeasurePrefix("TEBI", 28, 4, "tebi", 1024)

    public static let PEBI = MeasureUnit_MeasurePrefix("PEBI", 29, 5, "pebi", 1024)

    public static let EXBI = MeasureUnit_MeasurePrefix("EXBI", 30, 6, "exbi", 1024)

    public static let ZEBI = MeasureUnit_MeasurePrefix("ZEBI", 31, 7, "zebi", 1024)

    public static let YOBI = MeasureUnit_MeasurePrefix("YOBI", 32, 8, "yobi", 1024)

    private static func _values(): Array<MeasureUnit_MeasurePrefix> {
        return [MeasureUnit_MeasurePrefix.QUETTA, MeasureUnit_MeasurePrefix.RONNA, MeasureUnit_MeasurePrefix.YOTTA, MeasureUnit_MeasurePrefix.ZETTA, MeasureUnit_MeasurePrefix.EXA, MeasureUnit_MeasurePrefix.PETA, MeasureUnit_MeasurePrefix.TERA, MeasureUnit_MeasurePrefix.GIGA, MeasureUnit_MeasurePrefix.MEGA, MeasureUnit_MeasurePrefix.KILO, MeasureUnit_MeasurePrefix.HECTO, MeasureUnit_MeasurePrefix.DEKA, MeasureUnit_MeasurePrefix.ONE, MeasureUnit_MeasurePrefix.DECI, MeasureUnit_MeasurePrefix.CENTI, MeasureUnit_MeasurePrefix.MILLI, MeasureUnit_MeasurePrefix.MICRO, MeasureUnit_MeasurePrefix.NANO, MeasureUnit_MeasurePrefix.PICO, MeasureUnit_MeasurePrefix.FEMTO, MeasureUnit_MeasurePrefix.ATTO, MeasureUnit_MeasurePrefix.ZEPTO, MeasureUnit_MeasurePrefix.YOCTO, MeasureUnit_MeasurePrefix.RONTO, MeasureUnit_MeasurePrefix.QUECTO, MeasureUnit_MeasurePrefix.KIBI, MeasureUnit_MeasurePrefix.MEBI, MeasureUnit_MeasurePrefix.GIBI, MeasureUnit_MeasurePrefix.TEBI, MeasureUnit_MeasurePrefix.PEBI, MeasureUnit_MeasurePrefix.EXBI, MeasureUnit_MeasurePrefix.ZEBI, MeasureUnit_MeasurePrefix.YOBI]
    }

    private static let _VALUES = MeasureUnit_MeasurePrefix._values()

    public static func values(): Array<MeasureUnit_MeasurePrefix> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): MeasureUnit_MeasurePrefix {
        return (TypeInfo.of<MeasureUnit_MeasurePrefix>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as MeasureUnit_MeasurePrefix
    }

    private let base: Int32

    private let power: Int32

    private let identifier: String

    init(_enum_name: String, _enum_ordinal: Int32, power: Int32, identifier: String, base: Int32) {
        super(_enum_name, _enum_ordinal)
        this.base = base
        this.power = power
        this.identifier = identifier
    }

    
    public func getIdentifier(): String {
        return identifier
    }

    public func getBase(): Int32 {
        return base
    }

    public func getPower(): Int32 {
        return power
    }
}



public interface MeasureUnit_Factory {
    
    func create(Type: String, subType: String): MeasureUnit
}

class MeasureUnit_1 <: MeasureUnit_Factory {

    public override func create(Type: String, subType: String): MeasureUnit {
        return MeasureUnit(Type, subType)
    }
}


class MeasureUnit_2 <: MeasureUnit_Factory {

    public override func create(unusedType: String, subType: String): MeasureUnit {
        return Currency(subType)
    }
}


class MeasureUnit_3 <: MeasureUnit_Factory {

    public override func create(Type: String, subType: String): MeasureUnit {
        return TimeUnit(Type, subType)
    }
}


class MeasureUnit_MeasureUnitSink <: UResource_Sink {
    init() {
        super()
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let unitTypesTable = value.getTable()
        var i2 = 0
        while (unitTypesTable.getKeyAndValue(i2, key, value)) {
            if (key.contentEquals("compound") || key.contentEquals("coordinate")) {
                continue
            }
            let unitType: String = key.toString()
            let unitNamesTable = value.getTable()
            var i3 = 0
            while (unitNamesTable.getKeyAndValue(i3, key, value)) {
                let unitName: String = key.toString()
                MeasureUnit.internalGetInstance(unitType, unitName)
                i3++
            }
            i2++
        }
    }
}


class MeasureUnit_CurrencyNumericCodeSink <: UResource_Sink {
    init() {
        super()
    }

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        let codesTable = value.getTable()
        var i1 = 0
        while (codesTable.getKeyAndValue(i1, key, value)) {
            MeasureUnit.internalGetInstance("currency", key.toString())
            i1++
        }
    }
}


class MeasureUnit_MeasureUnitProxy <: Externalizable {
    private static let serialVersionUID = -3910681415330989598

    private var Type: String

    private var subType: String

    public init(Type: String, subType: String) {
        this.Type = Type
        this.subType = subType
    }


    public override func writeExternal(out: ObjectOutput): Unit {
        out.writeByte(0)
        out.writeUTF(Type)
        out.writeUTF(subType)
        out.writeShort(0)
    }

    public override func readExternal(input: ObjectInput): Unit {
        input.readByte()
        Type = input.readUTF()
        subType = input.readUTF()
        let extra = Int32(input.readShort())
        if (extra > 0) {
            let extraBytes = Array<UInt8>(Int64(extra)) { _ => 0 }
            input.read(extraBytes, 0, extra)
        }
    }

    private func readResolve(): Object {
        return MeasureUnit.internalGetInstance(Type, subType)
    }
}
