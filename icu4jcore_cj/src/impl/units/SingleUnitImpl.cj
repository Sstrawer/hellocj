package icu4cj.impl.units


public class SingleUnitImpl {

    private var index = -1

    private var simpleUnitID: String = ""

    private var dimensionality = 1

    private var unitPrefix: MeasureUnit_MeasurePrefix = MeasureUnit_MeasurePrefix.ONE

    public func copy(): SingleUnitImpl {
        let result = SingleUnitImpl()
        result.index = this.index
        result.dimensionality = this.dimensionality
        result.simpleUnitID = this.simpleUnitID
        result.unitPrefix = this.unitPrefix
        return result
    }

    public func build(): MeasureUnit {
        let measureUnit = MeasureUnitImpl(this)
        return measureUnit.build()
    }

    public func getNeutralIdentifier(): String {
        let result = StringBuilder()
        let absPower = abs(this.getDimensionality())
        if (!(absPower > 0)) {
            throw Exception("this function does not support the dimensionless single units")
        }
        if (absPower == 1) { } else if (absPower == 2) {
            result.append("square-")
        } else if (absPower == 3) {
            result.append("cubic-")
        } else if (absPower <= 15) {
            result.append("pow")
            result.append(absPower)
            result.append('-')
        } else {
            throw IllegalArgumentException("Unit Identifier Syntax Error")
        }
        result.append(this.getPrefix().getIdentifier())
        result.append(this.getSimpleUnitID())
        return result.toString()
    }

    public func compareTo(other: SingleUnitImpl): Int32 {
        if (dimensionality < 0 && other.dimensionality > 0) {
            return 1
        }
        if (dimensionality > 0 && other.dimensionality < 0) {
            return -1
        }
        let thisCategoryIndex = UnitsData.getCategoryIndexOfSimpleUnit(index)
        let otherCategoryIndex = UnitsData.getCategoryIndexOfSimpleUnit(other.index)
        if (thisCategoryIndex < otherCategoryIndex) {
            return -1
        }
        if (thisCategoryIndex > otherCategoryIndex) {
            return 1
        }
        if (index < other.index) {
            return -1
        }
        if (index > other.index) {
            return 1
        }
        let unitBase = this.unitPrefix.getBase()
        let otherUnitBase = other.unitPrefix.getBase()
        let unitPowerComp = if (unitBase == 1024) { this.unitPrefix.getPower() * 3 } else { this.unitPrefix.getPower() }
        let otherUnitPowerComp = if (otherUnitBase == 1024) { other.unitPrefix.getPower() * 3 } else { other.unitPrefix.getPower() }
        if (unitPowerComp < otherUnitPowerComp) {
            return 1
        }
        if (unitPowerComp > otherUnitPowerComp) {
            return -1
        }
        if (unitBase < otherUnitBase) {
            return 1
        }
        if (unitBase > otherUnitBase) {
            return -1
        }
        return 0
    }

    public func isCompatibleWith(other: SingleUnitImpl): Bool {
        return (compareTo(other) == 0)
    }

    public func getSimpleUnitID(): String {
        return simpleUnitID
    }

    public func setSimpleUnit(simpleUnitIndex: Int32, simpleUnits: Array<String>): Unit {
        this.index = simpleUnitIndex
        this.simpleUnitID = simpleUnits[Int64(simpleUnitIndex)]
    }

    public func getDimensionality(): Int32 {
        return dimensionality
    }

    public func setDimensionality(dimensionality: Int32): Unit {
        this.dimensionality = dimensionality
    }

    public func getPrefix(): MeasureUnit_MeasurePrefix {
        return unitPrefix
    }

    public func setPrefix(unitPrefix: MeasureUnit_MeasurePrefix): Unit {
        this.unitPrefix = unitPrefix
    }

    public func getIndex(): Int32 {
        return index
    }
}
