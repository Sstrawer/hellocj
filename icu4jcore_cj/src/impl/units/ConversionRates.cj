package icu4cj.impl.units


public class ConversionRates {
    private var mapToConversionRate: HashMap<String, ConversionRates_ConversionRateInfo> = None

    public init() {
        let resource: ICUResourceBundle
        resource = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "units")
        let sink = ConversionRates_ConversionRatesSink()
        resource.getAllItemsWithFallback(UnitsData_Constants.CONVERSION_UNIT_TABLE_NAME, sink)
        this.mapToConversionRate = sink.getMapToConversionRate()
    }

    private func getFactorToBase(singleUnit: SingleUnitImpl): UnitsConverter_Factor {
        let power = singleUnit.getDimensionality()
        let unitPrefix = singleUnit.getPrefix()
        let result = UnitsConverter_Factor.processFactor(mapToConversionRate.get(singleUnit.getSimpleUnitID()).getConversionRate())
        return result.applyPrefix(unitPrefix).power(power)
    }

    public func getFactorToBase(measureUnit: MeasureUnitImpl): UnitsConverter_Factor {
        var result: UnitsConverter_Factor = UnitsConverter_Factor()
        for (singleUnit in measureUnit.getSingleUnits()) {
            result = result.multiply(getFactorToBase(singleUnit))
        }
        return result
    }

    protected func getOffset(source: MeasureUnitImpl, target: MeasureUnitImpl, sourceToBase: UnitsConverter_Factor, targetToBase: UnitsConverter_Factor, convertibility: UnitsConverter_Convertibility): BigDecimal {
        if (!refEq(convertibility, UnitsConverter_Convertibility.CONVERTIBLE)) {
            return BigDecimal.valueOf(0)
        }
        if (!(checkSimpleUnit(source) && checkSimpleUnit(target))) {
            return BigDecimal.valueOf(0)
        }
        let sourceSimpleIdentifier = source.getSingleUnits()[0].getSimpleUnitID()
        let targetSimpleIdentifier = target.getSingleUnits()[0].getSimpleUnitID()
        let sourceOffset = this.mapToConversionRate.get(sourceSimpleIdentifier).getOffset()
        let targetOffset = this.mapToConversionRate.get(targetSimpleIdentifier).getOffset()
        return sourceOffset.subtract(targetOffset).divide(targetToBase.getConversionRate(), MathContext.DECIMAL128)
    }

    protected func getSpecialMappingName(simpleUnit: MeasureUnitImpl): String {
        if (!checkSimpleUnit(simpleUnit)) {
            return None
        }
        let simpleIdentifier = simpleUnit.getSingleUnits()[0].getSimpleUnitID()
        return this.mapToConversionRate.get(simpleIdentifier).getSpecialMappingName()
    }

    public func extractCompoundBaseUnit(measureUnit: MeasureUnitImpl): MeasureUnitImpl {
        let baseUnits = this.extractBaseUnits(measureUnit)
        let result = MeasureUnitImpl()
        for (baseUnit in baseUnits) {
            result.appendSingleUnit(baseUnit)
        }
        return result
    }

    public func extractBaseUnits(measureUnitImpl: MeasureUnitImpl): ArrayList<SingleUnitImpl> {
        let result = ArrayList<SingleUnitImpl>()
        let singleUnits = measureUnitImpl.getSingleUnits()
        for (singleUnit in singleUnits) {
            result.appendAll(extractBaseUnits(singleUnit))
        }
        return result
    }

    public func extractBaseUnits(singleUnit: SingleUnitImpl): ArrayList<SingleUnitImpl> {
        let target = mapToConversionRate.get(singleUnit.getSimpleUnitID()).getTarget()
        let targetImpl = MeasureUnitImpl_UnitsParser.parseForIdentifier(target)
        targetImpl.applyDimensionality(singleUnit.getDimensionality())
        return targetImpl.getSingleUnits()
    }

    public func extractSystems(singleUnit: SingleUnitImpl): String {
        return mapToConversionRate.get(singleUnit.getSimpleUnitID()).getSystems()
    }

    private func checkSimpleUnit(measureUnitImpl: MeasureUnitImpl): Bool {
        if (!refEq(measureUnitImpl.getComplexity(), MeasureUnit_Complexity.SINGLE)) {
            return false
        }
        let singleUnit = measureUnitImpl.getSingleUnits()[0]
        if (!refEq(singleUnit.getPrefix(), MeasureUnit_MeasurePrefix.ONE)) {
            return false
        }
        if (singleUnit.getDimensionality() != 1) {
            return false
        }
        return true
    }
}


public class ConversionRates_ConversionRatesSink <: UResource_Sink {
    public init() {
        super()
    }

    private var mapToConversionRate: HashMap<String, ConversionRates_ConversionRateInfo> = HashMap<String, ConversionRates_ConversionRateInfo>()

    public override func put(key: UResource_Key, value: UResource_Value, noFallback: Bool): Unit {
        if (!(UnitsData_Constants.CONVERSION_UNIT_TABLE_NAME.equals(key.toString()))) {
            throw AssertionError()
        }
        let conversionRateTable = value.getTable()
        var i = 0
        while (conversionRateTable.getKeyAndValue(i, key, value)) {
            if (!(value.getType() == UResourceBundle.TABLE)) {
                throw AssertionError()
            }
            let simpleUnit: String = key.toString()
            let simpleUnitConversionInfo = value.getTable()
            var target: String
            var factor: String
            var offset: String = "0"
            var special: String
            var systems: String
            var j = 0
            while (simpleUnitConversionInfo.getKeyAndValue(j, key, value)) {
                if (!(value.getType() == UResourceBundle.STRING)) {
                    throw AssertionError()
                }
                let keyString: String = key.toString()
                let valueString = value.toString().replaceAll(" ", "")
                if ("target".equals(keyString)) {
                    target = valueString
                } else if ("factor".equals(keyString)) {
                    factor = valueString
                } else if ("offset".equals(keyString)) {
                    offset = valueString
                } else if ("special".equals(keyString)) {
                    special = valueString
                } else if ("systems".equals(keyString)) {
                    systems = value.toString()
                } else {
                    if (!false) {
                        throw Exception("The key must be target, factor, offset, special, or systems")
                    }
                }
                j++
            }
            if (!(target.isSome())) {
                throw AssertionError()
            }
            if (!(factor.isSome() || special.isSome())) {
                throw AssertionError()
            }
            mapToConversionRate.put(simpleUnit, ConversionRates_ConversionRateInfo(simpleUnit, target, factor, offset, special, systems))
            i++
        }
    }

    public func getMapToConversionRate(): HashMap<String, ConversionRates_ConversionRateInfo> {
        return mapToConversionRate
    }
}


public class ConversionRates_ConversionRateInfo {
    private let simpleUnit: String

    private let target: String

    private let conversionRate: String

    private let offset: BigDecimal

    private let specialMappingName: String

    private let systems: String

    public init(simpleUnit: String, target: String, conversionRate: String, offset: String, special: String, systems: String) {
        this.simpleUnit = simpleUnit
        this.target = target
        this.conversionRate = conversionRate
        this.offset = forNumberWithDivision(offset)
        this.specialMappingName = special
        this.systems = systems
    }

    private static func forNumberWithDivision(numberWithDivision: String): BigDecimal {
        let numbers = numberWithDivision.split("/")
        if (!(Int32(numbers.size) <= 2)) {
            throw AssertionError()
        }
        if (Int32(numbers.size) == 1) {
            return Decimal(numbers[0])
        }
        return Decimal(numbers[0]).divide(Decimal(numbers[1]), MathContext.DECIMAL128)
    }

    public func getTarget(): String {
        return this.target
    }

    public func getOffset(): BigDecimal {
        return this.offset
    }

    public func getConversionRate(): String {
        if (conversionRate.isNone()) {
            throw IllegalIcuArgumentException("trying to use a null conversion rate (for special)")
        }
        return conversionRate
    }

    public func getSpecialMappingName(): String {
        return specialMappingName
    }

    public func getSystems(): String {
        return systems
    }
}
