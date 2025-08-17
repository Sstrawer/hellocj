package icu4cj.impl.units


public class ComplexUnitsConverter {
    public static let EPSILON = BigDecimal.valueOf(Math.ulp(1.0))

    public static let EPSILON_MULTIPLIER = BigDecimal.valueOf(1).add(EPSILON)

    public var unitsConverters_: ArrayList<UnitsConverter>

    public var units_: ArrayList<MeasureUnitImpl_MeasureUnitImplWithIndex>

    private var inputUnit_: MeasureUnitImpl

    public init(targetUnit: MeasureUnitImpl, conversionRates: ConversionRates) {
        this.units_ = targetUnit.extractIndividualUnitsWithIndices()
        if (!(!this.units_.isEmpty())) {
            throw AssertionError()
        }
        this.inputUnit_ = this.units_[0].unitImpl
        let comparator = MeasureUnitImpl_MeasureUnitImplComparator(conversionRates)
        for (unitWithIndex in this.units_) {
            if (comparator.compare(unitWithIndex.unitImpl, this.inputUnit_) > 0) {
                this.inputUnit_ = unitWithIndex.unitImpl
            }
        }
        this.initself(conversionRates)
    }

    public init(inputUnitIdentifier: String, outputUnitsIdentifier: String) {
        this(MeasureUnitImpl.forIdentifier(inputUnitIdentifier), MeasureUnitImpl.forIdentifier(outputUnitsIdentifier), ConversionRates())
    }

    public init(inputUnit: MeasureUnitImpl, outputUnits: MeasureUnitImpl, conversionRates: ConversionRates) {
        this.inputUnit_ = inputUnit
        this.units_ = outputUnits.extractIndividualUnitsWithIndices()
        if (!(!this.units_.isEmpty())) {
            throw AssertionError()
        }
        this.initself(conversionRates)
    }

    private func initself(conversionRates: ConversionRates): Unit {
        Collections.sort(this.units_, Collections.reverseOrder(MeasureUnitImpl_MeasureUnitImplWithIndexComparator(conversionRates) as Comparator))
        unitsConverters_ = ArrayList<UnitsConverter>()
        var i = 0
        let n = Int32(units_.size)
        while (i < n) {
            if (i == 0) {
                unitsConverters_.append(UnitsConverter(this.inputUnit_, units_[Int64(i)].unitImpl, conversionRates))
            } else {
                unitsConverters_.append(UnitsConverter(units_[Int64(i - 1)].unitImpl, units_[Int64(i)].unitImpl, conversionRates))
            }
            i++
        }
    }

    public func greaterThanOrEqual(quantity: BigDecimal, limit: BigDecimal): Bool {
        if (!(!units_.isEmpty())) {
            throw AssertionError()
        }
        return unitsConverters_[0].convert(quantity).multiply(EPSILON_MULTIPLIER).compare(limit) >= 0
    }

    public func convert(quantity: BigDecimal, rounder: Precision): ComplexUnitsConverter_ComplexConverterResult {
        var tempquantity = quantity
        var sign = BigInt.ONE
        if (tempquantity.compare(<--.ZERO) : Any => Int32 --> < 0 && Int32(unitsConverters_.size) > 1) {
            tempquantity = tempquantity.abs()
            sign = sign.negate()
        }
        let intValues = ArrayList<BigInt>(Int64(Int32(unitsConverters_.size) - 1))
                        tempquantity = remainder
                    }
                }
                i++
            }
        } while (false)
        tempquantity = applyRounder(intValues, tempquantity, rounder)
        let measures = ArrayList<Measure>(unitsConverters_.size)
        } while (false)
        var indexOfQuantity = -1
                    indexOfQuantity = units_[Int64(i)].index
                    let measure = Measure(tempquantity.multiply(BigDecimal.valueOf(sign.toInt64())), units_[Int64(i)].unitImpl.build())
                    measures.set(Int64(indexOfQuantity), measure)
                }
                i++
            }
        } while (false)
        return ComplexUnitsConverter_ComplexConverterResult(indexOfQuantity, measures)
    }

    private func applyRounder(intValues: ArrayList<BigInt>, quantity: BigDecimal, rounder: Precision): BigDecimal {
        var tempquantity = quantity
        if (rounder.isNone()) {
            return tempquantity
        }
        let quantityBCD: DecimalQuantity = DecimalQuantity_DualStorageBCD(tempquantity)
        rounder.apply(quantityBCD)
        tempquantity = quantityBCD.toBigDecimal()
        if (Int32(intValues.size) == 0) {
            return tempquantity
        }
        let lastIndex = Int32(unitsConverters_.size) - 1
        var carry = unitsConverters_[Int64(lastIndex)].convertInverse(tempquantity).multiply(EPSILON_MULTIPLIER).setScale(0, RoundingMode.FLOOR)
        if (carry.compare(<--.ZERO) : Any => Int32 --> <= 0) {
            return tempquantity
        }
        tempquantity = tempquantity.subtract(unitsConverters_[Int64(lastIndex)].convert(carry))
        intValues.set(Int64(lastIndex - 1), intValues[Int64(lastIndex - 1)].add(carry.toBigInt()))
        var j = lastIndex - 1
        while (j > 0) {
            carry = unitsConverters_[Int64(j)].convertInverse(BigDecimal.valueOf(intValues[Int64(j)].toInt64())).multiply(EPSILON_MULTIPLIER).setScale(0, RoundingMode.FLOOR)
            if (carry.compare(<--.ZERO) : Any => Int32 --> <= 0) {
                break
            }
            intValues.set(Int64(j), intValues[Int64(j)].subtract(unitsConverters_[Int64(j)].convert(carry).toBigInt()))
            intValues.set(Int64(j - 1), intValues[Int64(j - 1)].add(carry.toBigInt()))
            j--
        }
        return tempquantity
    }

    public override func toString(): String {
        return "ComplexUnitsConverter [unitsConverters_=" + unitsConverters_.asString() + ", units_=" + units_.asString() + "]"
    }
}


public class ComplexUnitsConverter_ComplexConverterResult {
    public let indexOfQuantity: Int32

    public let measures: ArrayList<Measure>

    init(indexOfQuantity: Int32, measures: ArrayList<Measure>) {
        this.indexOfQuantity = indexOfQuantity
        this.measures = measures
    }
}
