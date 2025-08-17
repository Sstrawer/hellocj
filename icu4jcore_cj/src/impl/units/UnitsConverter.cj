package icu4cj.impl.units


public class UnitsConverter {
    private var conversionRate: BigDecimal = None

    private var reciprocal: Bool = false

    private var offset: BigDecimal = None

    private var specialSource: String

    private var specialTarget: String

    public init(sourceIdentifier: String, targetIdentifier: String) {
        this(MeasureUnitImpl.forIdentifier(sourceIdentifier), MeasureUnitImpl.forIdentifier(targetIdentifier), ConversionRates())
    }

    public init(source: MeasureUnitImpl, target: MeasureUnitImpl, conversionRates: ConversionRates) {
        let convertibility = extractConvertibility(source, target, conversionRates)
        if (!refEq(convertibility, UnitsConverter_Convertibility.CONVERTIBLE) && !refEq(convertibility, UnitsConverter_Convertibility.RECIPROCAL)) {
            throw IllegalIcuArgumentException("input units must be convertible or reciprocal")
        }
        this.specialSource = conversionRates.getSpecialMappingName(source)
        this.specialTarget = conversionRates.getSpecialMappingName(target)
        if (this.specialSource.isNone() && this.specialTarget.isNone()) {
            let sourceToBase = conversionRates.getFactorToBase(source)
            let targetToBase = conversionRates.getFactorToBase(target)
            if (refEq(convertibility, UnitsConverter_Convertibility.CONVERTIBLE)) {
                this.conversionRate = sourceToBase.divide(targetToBase).getConversionRate()
            } else {
                if (!refEq(convertibility, UnitsConverter_Convertibility.RECIPROCAL)) {
                    throw AssertionError()
                }
                this.conversionRate = sourceToBase.multiply(targetToBase).getConversionRate()
            }
            this.reciprocal = refEq(convertibility, UnitsConverter_Convertibility.RECIPROCAL)
            this.offset = conversionRates.getOffset(source, target, sourceToBase, targetToBase, convertibility)
            if (!(!refEq(convertibility, UnitsConverter_Convertibility.RECIPROCAL) || refEq(this.offset, BigDecimal.ZERO))) {
                throw AssertionError()
            }
        } else {
            this.reciprocal = false
            this.offset = BigDecimal.ZERO
            if (this.specialSource.isNone()) {
                this.conversionRate = conversionRates.getFactorToBase(source).getConversionRate()
            } else if (this.specialTarget.isNone()) {
                this.conversionRate = conversionRates.getFactorToBase(target).getConversionRate()
            } else {
                this.conversionRate = BigDecimal.ONE
            }
        }
    }

    public static func extractConvertibility(source: MeasureUnitImpl, target: MeasureUnitImpl, conversionRates: ConversionRates): UnitsConverter_Convertibility {
        let sourceSingleUnits = conversionRates.extractBaseUnits(source)
        let targetSingleUnits = conversionRates.extractBaseUnits(target)
        let dimensionMap = HashMap<String, Int32>()
        insertInMap(dimensionMap, sourceSingleUnits, 1)
        insertInMap(dimensionMap, targetSingleUnits, -1)
        if (areDimensionsZeroes(dimensionMap)) {
            return UnitsConverter_Convertibility.CONVERTIBLE
        }
        insertInMap(dimensionMap, targetSingleUnits, 2)
        if (areDimensionsZeroes(dimensionMap)) {
            return UnitsConverter_Convertibility.RECIPROCAL
        }
        return UnitsConverter_Convertibility.UNCONVERTIBLE
    }

    private static func insertInMap(dimensionMap: HashMap<String, Int32>, singleUnits: ArrayList<SingleUnitImpl>, multiplier: Int32): Unit {
        for (singleUnit in singleUnits) {
            if (dimensionMap.contains(singleUnit.getSimpleUnitID())) {
                dimensionMap.put(singleUnit.getSimpleUnitID(), dimensionMap.get(singleUnit.getSimpleUnitID()) + singleUnit.getDimensionality() * multiplier)
            } else {
                dimensionMap.put(singleUnit.getSimpleUnitID(), singleUnit.getDimensionality() * multiplier)
            }
        }
    }

    private static func areDimensionsZeroes(dimensionMap: HashMap<String, Int32>): Bool {
        for (value in dimensionMap.values()) {
            if (!refEq(value, 0)) {
                return false
            }
        }
        return true
    }

    public func convert(inputValue: BigDecimal): BigDecimal {
        var result = inputValue
        if (this.specialSource.isSome() || this.specialTarget.isSome()) {
            var base = inputValue
            if (this.specialSource.isSome()) {
                base = if (this.specialSource == "beaufort") { scaleToBase(inputValue, minMetersPerSecForBeaufort) } else { inputValue }
            } else {
                base = inputValue.multiply(this.conversionRate)
            }
            if (this.specialTarget.isSome()) {
                result = if (this.specialTarget == "beaufort") { baseToScale(base, minMetersPerSecForBeaufort) } else { base }
            } else {
                result = base.divide(this.conversionRate, MathContext.DECIMAL128)
            }
            return result
        }
        result = inputValue.multiply(this.conversionRate).add(offset)
        if (this.reciprocal) {
            if (!refEq(offset, BigDecimal.ZERO)) {
                throw AssertionError()
            }
            if (result.compare(<--.ZERO) : Any => Int32 --> == 0) {
                return BigDecimal.ZERO
            }
            result = BigDecimal.ONE.divide(result, MathContext.DECIMAL128)
        }
        return result
    }

    public func convertInverse(inputValue: BigDecimal): BigDecimal {
        var result = inputValue
        if (this.specialSource.isSome() || this.specialTarget.isSome()) {
            var base = inputValue
            if (this.specialTarget.isSome()) {
                base = if (this.specialTarget == "beaufort") { scaleToBase(inputValue, minMetersPerSecForBeaufort) } else { inputValue }
            } else {
                base = inputValue.multiply(this.conversionRate)
            }
            if (this.specialSource.isSome()) {
                result = if (this.specialSource == "beaufort") { baseToScale(base, minMetersPerSecForBeaufort) } else { base }
            } else {
                result = base.divide(this.conversionRate, MathContext.DECIMAL128)
            }
            return result
        }
        if (this.reciprocal) {
            if (!refEq(offset, BigDecimal.ZERO)) {
                throw AssertionError()
            }
            if (result.compare(<--.ZERO) : Any => Int32 --> == 0) {
                return BigDecimal.ZERO
            }
            result = BigDecimal.ONE.divide(result, MathContext.DECIMAL128)
        }
        result = result.subtract(offset).divide(this.conversionRate, MathContext.DECIMAL128)
        return result
    }

    private static let minMetersPerSecForBeaufort = [BigDecimal.valueOf(0.0), BigDecimal.valueOf(0.3), BigDecimal.valueOf(1.6), BigDecimal.valueOf(3.4), BigDecimal.valueOf(5.5), BigDecimal.valueOf(8.0), BigDecimal.valueOf(10.8), BigDecimal.valueOf(13.9), BigDecimal.valueOf(17.2), BigDecimal.valueOf(20.8), BigDecimal.valueOf(24.5), BigDecimal.valueOf(28.5), BigDecimal.valueOf(32.7), BigDecimal.valueOf(36.9), BigDecimal.valueOf(41.4), BigDecimal.valueOf(46.1), BigDecimal.valueOf(51.1), BigDecimal.valueOf(55.8), BigDecimal.valueOf(61.4)]

    private func scaleToBase(scaleValue: BigDecimal, minBaseForScaleValues: Array<BigDecimal>): BigDecimal {
        let pointFive = BigDecimal.valueOf(0.5)
        let scaleAdjust = scaleValue.abs().add(pointFive)
        let scaleAdjustCapped = scaleAdjust.min(BigDecimal.valueOf(Int64(Int32(minBaseForScaleValues.size) - 2)))
        let scaleIndex = scaleAdjustCapped.intValue()
        return minBaseForScaleValues[Int64(scaleIndex)].add(minBaseForScaleValues[Int64(scaleIndex + 1)]).multiply(pointFive)
    }

    private func baseToScale(baseValue: BigDecimal, minBaseForScaleValues: Array<BigDecimal>): BigDecimal {
        var scaleIndex = Arrays.binarySearch(minBaseForScaleValues, baseValue.abs())
        if (scaleIndex < 0) {
            scaleIndex = -scaleIndex - 2
        }
        let scaleMax = Int32(minBaseForScaleValues.size) - 2
        if (scaleIndex > scaleMax) {
            scaleIndex = scaleMax
        }
        return BigDecimal.valueOf(Int64(scaleIndex))
    }

    public func getConversionInfo(): UnitsConverter_ConversionInfo {
        let result = UnitsConverter_ConversionInfo()
        result.conversionRate = this.conversionRate
        result.offset = this.offset
        result.reciprocal = this.reciprocal
        return result
    }

    public override func toString(): String {
        return "UnitsConverter [conversionRate=" + toString(conversionRate) + ", offset=" + toString(offset) + "]"
    }
}


public class UnitsConverter_Convertibility <: Enum<UnitsConverter_Convertibility> {
    public static let CONVERTIBLE = UnitsConverter_Convertibility("CONVERTIBLE", 0)

    public static let RECIPROCAL = UnitsConverter_Convertibility("RECIPROCAL", 1)

    public static let UNCONVERTIBLE = UnitsConverter_Convertibility("UNCONVERTIBLE", 2)

    private static func _values(): Array<UnitsConverter_Convertibility> {
        return [UnitsConverter_Convertibility.CONVERTIBLE, UnitsConverter_Convertibility.RECIPROCAL, UnitsConverter_Convertibility.UNCONVERTIBLE]
    }

    private static let _VALUES = UnitsConverter_Convertibility._values()

    public static func values(): Array<UnitsConverter_Convertibility> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): UnitsConverter_Convertibility {
        return (TypeInfo.of<UnitsConverter_Convertibility>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as UnitsConverter_Convertibility
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class UnitsConverter_ConversionInfo {

    public var conversionRate: BigDecimal = None

    public var offset: BigDecimal = None

    public var reciprocal: Bool = false
}


class UnitsConverter_Factor {
    private var factorNum: BigDecimal = None

    private var factorDen: BigDecimal = None

    private var exponentFtToM = 0

    private var exponentPi = 0

    private var exponentGravity = 0

    private var exponentG = 0

    private var exponentGalImpToM3 = 0

    private var exponentLbToKg = 0

    private var exponentGlucoseMolarMass = 0

    private var exponentItemPerMole = 0

    private var exponentMetersPerAU = 0

    private var exponentSecPerJulianYear = 0

    private var exponentSpeedOfLightMetersPerSecond = 0

    private var exponentShoToM3 = 0

    private var exponentTsuboToM2 = 0

    private var exponentShakuToM = 0

    private var exponentAMU = 0

    public init() {
        this.factorNum = BigDecimal.valueOf(1)
        this.factorDen = BigDecimal.valueOf(1)
    }

    public static func processFactor(factor: String): UnitsConverter_Factor {
        var tempfactor = factor
        if (!(!tempfactor.isEmpty())) {
            throw AssertionError()
        }
        tempfactor = tempfactor.replaceAll("\\s+", "")
        let fractions = tempfactor.split("/")
        if (!(Int32(fractions.size) == 1 || Int32(fractions.size) == 2)) {
            throw AssertionError()
        }
        if (Int32(fractions.size) == 1) {
            return processFactorWithoutDivision(fractions[0])
        }
        let num = processFactorWithoutDivision(fractions[0])
        let den = processFactorWithoutDivision(fractions[1])
        return num.divide(den)
    }

    private static func processFactorWithoutDivision(factorWithoutDivision: String): UnitsConverter_Factor {
        let result = UnitsConverter_Factor()
        for (poweredEntity in factorWithoutDivision.split(Pattern.`quote`("*"))) {
            result.addPoweredEntity(poweredEntity)
        }
        return result
    }

    protected func copy(): UnitsConverter_Factor {
        let result = UnitsConverter_Factor()
        result.factorNum = this.factorNum
        result.factorDen = this.factorDen
        result.exponentFtToM = this.exponentFtToM
        result.exponentPi = this.exponentPi
        result.exponentGravity = this.exponentGravity
        result.exponentG = this.exponentG
        result.exponentGalImpToM3 = this.exponentGalImpToM3
        result.exponentLbToKg = this.exponentLbToKg
        result.exponentGlucoseMolarMass = this.exponentGlucoseMolarMass
        result.exponentItemPerMole = this.exponentItemPerMole
        result.exponentMetersPerAU = this.exponentMetersPerAU
        result.exponentSecPerJulianYear = this.exponentSecPerJulianYear
        result.exponentSpeedOfLightMetersPerSecond = this.exponentSpeedOfLightMetersPerSecond
        result.exponentShoToM3 = this.exponentShoToM3
        result.exponentTsuboToM2 = this.exponentTsuboToM2
        result.exponentShakuToM = this.exponentShakuToM
        result.exponentAMU = this.exponentAMU
        return result
    }

    public func getConversionRate(): BigDecimal {
        let resultCollector = this.copy()
        resultCollector.multiply(Decimal("0.3048"), this.exponentFtToM)
        resultCollector.multiply(Decimal("411557987.0").divide(Decimal("131002976.0"), MathContext.DECIMAL128), this.exponentPi)
        resultCollector.multiply(Decimal("9.80665"), this.exponentGravity)
        resultCollector.multiply(Decimal("6.67408E-11"), this.exponentG)
        resultCollector.multiply(Decimal("0.00454609"), this.exponentGalImpToM3)
        resultCollector.multiply(Decimal("0.45359237"), this.exponentLbToKg)
        resultCollector.multiply(Decimal("180.1557"), this.exponentGlucoseMolarMass)
        resultCollector.multiply(Decimal("6.02214076E+23"), this.exponentItemPerMole)
        resultCollector.multiply(Decimal("149597870700"), this.exponentMetersPerAU)
        resultCollector.multiply(Decimal("31557600"), this.exponentSecPerJulianYear)
        resultCollector.multiply(Decimal("299792458"), this.exponentSpeedOfLightMetersPerSecond)
        resultCollector.multiply(Decimal("0.001803906836964688204"), this.exponentShoToM3)
        resultCollector.multiply(Decimal("3.305785123966942"), this.exponentTsuboToM2)
        resultCollector.multiply(Decimal("0.033057851239669"), this.exponentShakuToM)
        resultCollector.multiply(Decimal("1.66053878283E-27"), this.exponentAMU)
        return resultCollector.factorNum.divide(resultCollector.factorDen, MathContext.DECIMAL128)
    }

    private func multiply(value: BigDecimal, power: Int32): Unit {
        if (power == 0) {
            return
        }
        let absPoweredValue = value.pow(abs(power), MathContext.DECIMAL128)
        if (power > 0) {
            this.factorNum = this.factorNum.multiply(absPoweredValue)
        } else {
            this.factorDen = this.factorDen.multiply(absPoweredValue)
        }
    }

    public func applyPrefix(unitPrefix: MeasureUnit_MeasurePrefix): UnitsConverter_Factor {
        let result = this.copy()
        if (refEq(unitPrefix, MeasureUnit_MeasurePrefix.ONE)) {
            return result
        }
        let base = unitPrefix.getBase()
        let power = unitPrefix.getPower()
        let absFactor = BigDecimal.valueOf(Int64(base)).pow(abs(power), MathContext.DECIMAL128)
        if (power < 0) {
            result.factorDen = this.factorDen.multiply(absFactor)
            return result
        }
        result.factorNum = this.factorNum.multiply(absFactor)
        return result
    }

    public func power(power: Int32): UnitsConverter_Factor {
        let result = UnitsConverter_Factor()
        if (power == 0) {
            return result
        }
        if (power > 0) {
            result.factorNum = this.factorNum.pow(power)
            result.factorDen = this.factorDen.pow(power)
        } else {
            result.factorNum = this.factorDen.pow(power * -1)
            result.factorDen = this.factorNum.pow(power * -1)
        }
        result.exponentFtToM = this.exponentFtToM * power
        result.exponentPi = this.exponentPi * power
        result.exponentGravity = this.exponentGravity * power
        result.exponentG = this.exponentG * power
        result.exponentGalImpToM3 = this.exponentGalImpToM3 * power
        result.exponentLbToKg = this.exponentLbToKg * power
        result.exponentGlucoseMolarMass = this.exponentGlucoseMolarMass * power
        result.exponentItemPerMole = this.exponentItemPerMole * power
        result.exponentMetersPerAU = this.exponentMetersPerAU * power
        result.exponentSecPerJulianYear = this.exponentSecPerJulianYear * power
        result.exponentSpeedOfLightMetersPerSecond = this.exponentSpeedOfLightMetersPerSecond * power
        result.exponentShoToM3 = this.exponentShoToM3 * power
        result.exponentTsuboToM2 = this.exponentTsuboToM2 * power
        result.exponentShakuToM = this.exponentShakuToM * power
        result.exponentAMU = this.exponentAMU * power
        return result
    }

    public func divide(other: UnitsConverter_Factor): UnitsConverter_Factor {
        let result = UnitsConverter_Factor()
        result.factorNum = this.factorNum.multiply(other.factorDen)
        result.factorDen = this.factorDen.multiply(other.factorNum)
        result.exponentFtToM = this.exponentFtToM - other.exponentFtToM
        result.exponentPi = this.exponentPi - other.exponentPi
        result.exponentGravity = this.exponentGravity - other.exponentGravity
        result.exponentG = this.exponentG - other.exponentG
        result.exponentGalImpToM3 = this.exponentGalImpToM3 - other.exponentGalImpToM3
        result.exponentLbToKg = this.exponentLbToKg - other.exponentLbToKg
        result.exponentGlucoseMolarMass = this.exponentGlucoseMolarMass - other.exponentGlucoseMolarMass
        result.exponentItemPerMole = this.exponentItemPerMole - other.exponentItemPerMole
        result.exponentMetersPerAU = this.exponentMetersPerAU - other.exponentMetersPerAU
        result.exponentSecPerJulianYear = this.exponentSecPerJulianYear - other.exponentSecPerJulianYear
        result.exponentSpeedOfLightMetersPerSecond = this.exponentSpeedOfLightMetersPerSecond - other.exponentSpeedOfLightMetersPerSecond
        result.exponentShoToM3 = this.exponentShoToM3 - other.exponentShoToM3
        result.exponentTsuboToM2 = this.exponentTsuboToM2 - other.exponentTsuboToM2
        result.exponentShakuToM = this.exponentShakuToM - other.exponentShakuToM
        result.exponentAMU = this.exponentAMU - other.exponentAMU
        return result
    }

    public func multiply(other: UnitsConverter_Factor): UnitsConverter_Factor {
        let result = UnitsConverter_Factor()
        result.factorNum = this.factorNum.multiply(other.factorNum)
        result.factorDen = this.factorDen.multiply(other.factorDen)
        result.exponentFtToM = this.exponentFtToM + other.exponentFtToM
        result.exponentPi = this.exponentPi + other.exponentPi
        result.exponentGravity = this.exponentGravity + other.exponentGravity
        result.exponentG = this.exponentG + other.exponentG
        result.exponentGalImpToM3 = this.exponentGalImpToM3 + other.exponentGalImpToM3
        result.exponentLbToKg = this.exponentLbToKg + other.exponentLbToKg
        result.exponentGlucoseMolarMass = this.exponentGlucoseMolarMass + other.exponentGlucoseMolarMass
        result.exponentItemPerMole = this.exponentItemPerMole + other.exponentItemPerMole
        result.exponentMetersPerAU = this.exponentMetersPerAU + other.exponentMetersPerAU
        result.exponentSecPerJulianYear = this.exponentSecPerJulianYear + other.exponentSecPerJulianYear
        result.exponentSpeedOfLightMetersPerSecond = this.exponentSpeedOfLightMetersPerSecond + other.exponentSpeedOfLightMetersPerSecond
        result.exponentShoToM3 = this.exponentShoToM3 + other.exponentShoToM3
        result.exponentTsuboToM2 = this.exponentTsuboToM2 + other.exponentTsuboToM2
        result.exponentShakuToM = this.exponentShakuToM + other.exponentShakuToM
        result.exponentAMU = this.exponentAMU + other.exponentAMU
        return result
    }

    private func addPoweredEntity(poweredEntity: String): Unit {
        let entities = poweredEntity.split(Pattern.`quote`("^"))
        if (!(Int32(entities.size) == 1 || Int32(entities.size) == 2)) {
            throw AssertionError()
        }
        let power = if (Int32(entities.size) == 2) { parse<Int32>(entities[1]) } else { 1 }
        this.addEntity(entities[0], power)
    }

    private func addEntity(entity: String, power: Int32): Unit {
        if ("ft_to_m".equals(entity)) {
            this.exponentFtToM += power
        } else if ("ft2_to_m2".equals(entity)) {
            this.exponentFtToM += 2 * power
        } else if ("ft3_to_m3".equals(entity)) {
            this.exponentFtToM += 3 * power
        } else if ("in3_to_m3".equals(entity)) {
            this.exponentFtToM += 3 * power
            this.factorDen = this.factorDen.multiply(BigDecimal.valueOf(Math.pow(12.0, 3.0)))
        } else if ("gal_to_m3".equals(entity)) {
            this.factorNum = this.factorNum.multiply(BigDecimal.valueOf(231))
            this.exponentFtToM += 3 * power
            this.factorDen = this.factorDen.multiply(BigDecimal.valueOf(Int64(12 * 12 * 12)))
        } else if ("gal_imp_to_m3".equals(entity)) {
            this.exponentGalImpToM3 += power
        } else if ("G".equals(entity)) {
            this.exponentG += power
        } else if ("gravity".equals(entity)) {
            this.exponentGravity += power
        } else if ("lb_to_kg".equals(entity)) {
            this.exponentLbToKg += power
        } else if ("glucose_molar_mass".equals(entity)) {
            this.exponentGlucoseMolarMass += power
        } else if ("item_per_mole".equals(entity)) {
            this.exponentItemPerMole += power
        } else if ("meters_per_AU".equals(entity)) {
            this.exponentMetersPerAU += power
        } else if ("PI".equals(entity)) {
            this.exponentPi += power
        } else if ("sec_per_julian_year".equals(entity)) {
            this.exponentSecPerJulianYear += power
        } else if ("speed_of_light_meters_per_second".equals(entity)) {
            this.exponentSpeedOfLightMetersPerSecond += power
        } else if ("sho_to_m3".equals(entity)) {
            this.exponentShoToM3 += power
        } else if ("tsubo_to_m2".equals(entity)) {
            this.exponentTsuboToM2 += power
        } else if ("shaku_to_m".equals(entity)) {
            this.exponentShakuToM += power
        } else if ("AMU".equals(entity)) {
            this.exponentAMU += power
        } else {
            let decimalEntity = Decimal(entity).pow(power, MathContext.DECIMAL128)
            this.factorNum = this.factorNum.multiply(decimalEntity)
        }
    }
}
