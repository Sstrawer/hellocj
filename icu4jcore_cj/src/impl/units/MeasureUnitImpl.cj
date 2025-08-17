package icu4cj.impl.units


public class MeasureUnitImpl {
    private var identifier: String

    private var complexity: MeasureUnit_Complexity = MeasureUnit_Complexity.SINGLE

    let singleUnits: ArrayList<SingleUnitImpl>

    public init() {
        singleUnits = ArrayList<SingleUnitImpl>()
    }

    public init(singleUnit: SingleUnitImpl) {
        this()
        this.appendSingleUnit(singleUnit)
    }

    public static func forIdentifier(identifier: String): MeasureUnitImpl {
        return MeasureUnitImpl_UnitsParser.parseForIdentifier(identifier)
    }

    public static func forCurrencyCode(currencyCode: String): MeasureUnitImpl {
        let result = MeasureUnitImpl()
        result.identifier = currencyCode
        return result
    }

    public func copy(): MeasureUnitImpl {
        let result = MeasureUnitImpl()
        result.complexity = this.complexity
        result.identifier = this.identifier
        for (singleUnit in this.singleUnits) {
            result.singleUnits.append(singleUnit.copy())
        }
        return result
    }

    public func copyAndSimplify(): MeasureUnitImpl {
        let result = MeasureUnitImpl()
        for (singleUnit in this.getSingleUnits()) {
            var unitExist = false
            for (resultSingleUnit in result.getSingleUnits()) {
                if (resultSingleUnit.getSimpleUnitID().compare(singleUnit.getSimpleUnitID()).value() == 0 && resultSingleUnit.getPrefix().getIdentifier().compare(singleUnit.getPrefix().getIdentifier()).value() == 0) {
                    unitExist = true
                    resultSingleUnit.setDimensionality(resultSingleUnit.getDimensionality() + singleUnit.getDimensionality())
                    break
                }
            }
            if (!unitExist) {
                result.appendSingleUnit(singleUnit)
            }
        }
        return result
    }

    public func getSingleUnits(): ArrayList<SingleUnitImpl> {
        return singleUnits
    }

    public func takeReciprocal(): Unit {
        this.identifier = None
        for (singleUnit in this.singleUnits) {
            singleUnit.setDimensionality(singleUnit.getDimensionality() * -1)
        }
    }

    public func extractIndividualUnitsWithIndices(): ArrayList<MeasureUnitImpl_MeasureUnitImplWithIndex> {
        let result = ArrayList<MeasureUnitImpl_MeasureUnitImplWithIndex>()
        if (refEq(this.getComplexity(), MeasureUnit_Complexity.MIXED)) {
            var i = 0
            for (singleUnit in this.getSingleUnits()) {
                result.append(MeasureUnitImpl_MeasureUnitImplWithIndex(match (0) { case _ => i++; i - 1 }, MeasureUnitImpl(singleUnit)))
            }
            return result
        }
        result.append(MeasureUnitImpl_MeasureUnitImplWithIndex(0, this.copy()))
        return result
    }

    public func applyDimensionality(dimensionality: Int32): Unit {
        for (singleUnit in singleUnits) {
            singleUnit.setDimensionality(singleUnit.getDimensionality() * dimensionality)
        }
    }

    public func appendSingleUnit(singleUnit: SingleUnitImpl): Bool {
        identifier = None
        if (singleUnit.isNone()) {
            return false
        }
        var oldUnit: SingleUnitImpl
        for (candidate in this.singleUnits) {
            if (candidate.isCompatibleWith(singleUnit)) {
                oldUnit = candidate
                break
            }
        }
        if (oldUnit.isSome()) {
            oldUnit.setDimensionality(oldUnit.getDimensionality() + singleUnit.getDimensionality())
            return false
        }
        this.singleUnits.append(singleUnit.copy())
        if (Int32(this.singleUnits.size) > 1 && refEq(this.complexity, MeasureUnit_Complexity.SINGLE)) {
            this.setComplexity(MeasureUnit_Complexity.COMPOUND)
        }
        return true
    }

    public func build(): MeasureUnit {
        return MeasureUnit.fromMeasureUnitImpl(this)
    }

    public func getSingleUnitImpl(): SingleUnitImpl {
        if (Int32(this.singleUnits.size) == 0) {
            return SingleUnitImpl()
        }
        if (Int32(this.singleUnits.size) == 1) {
            return this.singleUnits[0].copy()
        }
        throw UnsupportedOperationException()
    }

    public func getIdentifier(): String {
        return identifier
    }

    public func getComplexity(): MeasureUnit_Complexity {
        return complexity
    }

    public func setComplexity(complexity: MeasureUnit_Complexity): Unit {
        this.complexity = complexity
    }

    public func serialize(): Unit {
        if (Int32(this.getSingleUnits().size) == 0) {
            return
        }
        if (refEq(this.complexity, MeasureUnit_Complexity.COMPOUND)) {
            Collections.sort(this.getSingleUnits(), MeasureUnitImpl_SingleUnitComparator() as Comparator)
        }
        let result = StringBuilder()
        var beforePer = true
        var firstTimeNegativeDimension = false
        for (singleUnit in this.getSingleUnits()) {
            if (beforePer && singleUnit.getDimensionality() < 0) {
                beforePer = false
                firstTimeNegativeDimension = true
            } else if (singleUnit.getDimensionality() < 0) {
                firstTimeNegativeDimension = false
            }
            if (refEq(this.getComplexity(), MeasureUnit_Complexity.MIXED)) {
                if (Int32(result.size) != 0) {
                    result.append("-and-")
                }
            } else {
                if (firstTimeNegativeDimension) {
                    if (Int32(result.size) == 0) {
                        result.append("per-")
                    } else {
                        result.append("-per-")
                    }
                } else {
                    if (Int32(result.size) != 0) {
                        result.append("-")
                    }
                }
            }
            result.append(singleUnit.getNeutralIdentifier())
        }
        this.identifier = result.toString()
    }

    public override func toString(): String {
        return "MeasureUnitImpl [" + (build().getIdentifier()) + "]"
    }
}


public class MeasureUnitImpl_CompoundPart <: Enum<MeasureUnitImpl_CompoundPart> {
    public static let PER = MeasureUnitImpl_CompoundPart("PER", 0, 0)

    public static let TIMES = MeasureUnitImpl_CompoundPart("TIMES", 1, 1)

    public static let AND = MeasureUnitImpl_CompoundPart("AND", 2, 2)

    private static func _values(): Array<MeasureUnitImpl_CompoundPart> {
        return [MeasureUnitImpl_CompoundPart.PER, MeasureUnitImpl_CompoundPart.TIMES, MeasureUnitImpl_CompoundPart.AND]
    }

    private static let _VALUES = MeasureUnitImpl_CompoundPart._values()

    public static func values(): Array<MeasureUnitImpl_CompoundPart> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): MeasureUnitImpl_CompoundPart {
        return (TypeInfo.of<MeasureUnitImpl_CompoundPart>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as MeasureUnitImpl_CompoundPart
    }

    private let index: Int32

    init(_enum_name: String, _enum_ordinal: Int32, index: Int32) {
        super(_enum_name, _enum_ordinal)
        this.index = index
    }

    public static func getCompoundPartFromTrieIndex(trieIndex: Int32): MeasureUnitImpl_CompoundPart {
        let index = trieIndex - UnitsData_Constants.kCompoundPartOffset
        match (index) {
            case 0 => return MeasureUnitImpl_CompoundPart.PER
            case 1 => return MeasureUnitImpl_CompoundPart.TIMES
            case 2 => return MeasureUnitImpl_CompoundPart.AND
            case _ => throw Exception("CompoundPart index must be 0, 1 or 2")
        }
    }

    public func getTrieIndex(): Int32 {
        return this.index + UnitsData_Constants.kCompoundPartOffset
    }

    public func getValue(): Int32 {
        return index
    }
}


public class MeasureUnitImpl_PowerPart <: Enum<MeasureUnitImpl_PowerPart> {
    public static let P2 = MeasureUnitImpl_PowerPart("P2", 0, 2)

    public static let P3 = MeasureUnitImpl_PowerPart("P3", 1, 3)

    public static let P4 = MeasureUnitImpl_PowerPart("P4", 2, 4)

    public static let P5 = MeasureUnitImpl_PowerPart("P5", 3, 5)

    public static let P6 = MeasureUnitImpl_PowerPart("P6", 4, 6)

    public static let P7 = MeasureUnitImpl_PowerPart("P7", 5, 7)

    public static let P8 = MeasureUnitImpl_PowerPart("P8", 6, 8)

    public static let P9 = MeasureUnitImpl_PowerPart("P9", 7, 9)

    public static let P10 = MeasureUnitImpl_PowerPart("P10", 8, 10)

    public static let P11 = MeasureUnitImpl_PowerPart("P11", 9, 11)

    public static let P12 = MeasureUnitImpl_PowerPart("P12", 10, 12)

    public static let P13 = MeasureUnitImpl_PowerPart("P13", 11, 13)

    public static let P14 = MeasureUnitImpl_PowerPart("P14", 12, 14)

    public static let P15 = MeasureUnitImpl_PowerPart("P15", 13, 15)

    private static func _values(): Array<MeasureUnitImpl_PowerPart> {
        return [MeasureUnitImpl_PowerPart.P2, MeasureUnitImpl_PowerPart.P3, MeasureUnitImpl_PowerPart.P4, MeasureUnitImpl_PowerPart.P5, MeasureUnitImpl_PowerPart.P6, MeasureUnitImpl_PowerPart.P7, MeasureUnitImpl_PowerPart.P8, MeasureUnitImpl_PowerPart.P9, MeasureUnitImpl_PowerPart.P10, MeasureUnitImpl_PowerPart.P11, MeasureUnitImpl_PowerPart.P12, MeasureUnitImpl_PowerPart.P13, MeasureUnitImpl_PowerPart.P14, MeasureUnitImpl_PowerPart.P15]
    }

    private static let _VALUES = MeasureUnitImpl_PowerPart._values()

    public static func values(): Array<MeasureUnitImpl_PowerPart> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): MeasureUnitImpl_PowerPart {
        return (TypeInfo.of<MeasureUnitImpl_PowerPart>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as MeasureUnitImpl_PowerPart
    }

    private let power: Int32

    init(_enum_name: String, _enum_ordinal: Int32, power: Int32) {
        super(_enum_name, _enum_ordinal)
        this.power = power
    }

    public static func getPowerFromTrieIndex(trieIndex: Int32): Int32 {
        return trieIndex - UnitsData_Constants.kPowerPartOffset
    }

    public func getTrieIndex(): Int32 {
        return this.power + UnitsData_Constants.kPowerPartOffset
    }

    public func getValue(): Int32 {
        return power
    }
}


public class MeasureUnitImpl_InitialCompoundPart <: Enum<MeasureUnitImpl_InitialCompoundPart> {
    public static let INITIAL_COMPOUND_PART_PER = MeasureUnitImpl_InitialCompoundPart("INITIAL_COMPOUND_PART_PER", 0, 0)

    private static func _values(): Array<MeasureUnitImpl_InitialCompoundPart> {
        return [MeasureUnitImpl_InitialCompoundPart.INITIAL_COMPOUND_PART_PER]
    }

    private static let _VALUES = MeasureUnitImpl_InitialCompoundPart._values()

    public static func values(): Array<MeasureUnitImpl_InitialCompoundPart> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): MeasureUnitImpl_InitialCompoundPart {
        return (TypeInfo.of<MeasureUnitImpl_InitialCompoundPart>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as MeasureUnitImpl_InitialCompoundPart
    }

    private let index: Int32

    init(_enum_name: String, _enum_ordinal: Int32, powerIndex: Int32) {
        super(_enum_name, _enum_ordinal)
        this.index = powerIndex
    }

    public static func getInitialCompoundPartFromTrieIndex(trieIndex: Int32): MeasureUnitImpl_InitialCompoundPart {
        let index = trieIndex - UnitsData_Constants.kInitialCompoundPartOffset
        if (index == 0) {
            return INITIAL_COMPOUND_PART_PER
        }
        throw IllegalArgumentException("Incorrect trieIndex")
    }

    public func getTrieIndex(): Int32 {
        return this.index + UnitsData_Constants.kInitialCompoundPartOffset
    }

    public func getValue(): Int32 {
        return index
    }
}


public class MeasureUnitImpl_MeasureUnitImplWithIndex {
    var index: Int32 = 0

    var unitImpl: MeasureUnitImpl

    init(index: Int32, unitImpl: MeasureUnitImpl) {
        this.index = index
        this.unitImpl = unitImpl
    }
}


public class MeasureUnitImpl_UnitsParser {
     private static var savedTrie: CharsTrie

    private let trie: CharsTrie

    private let fSource: String

    private var fIndex = 0

    private var fAfterPer = false

    private var fSawAnd = false

    private static var measurePrefixValues = MeasureUnit_MeasurePrefix.values()

    private init(identifier: String) {
        this.fSource = identifier
        try {
            this.trie = MeasureUnitImpl_UnitsParser.savedTrie.clone()
        } catch (e: CloneNotSupportedException) {
            throw ICUCloneNotSupportedException()
        }
    }


    public static func parseForIdentifier(identifier: String): MeasureUnitImpl {
        if (identifier.isNone() || identifier.isEmpty()) {
            return None
        }
        let parser = MeasureUnitImpl_UnitsParser(identifier)
        return parser.parse()
    }

    static func getPrefixFromTrieIndex(trieIndex: Int32): MeasureUnit_MeasurePrefix {
        return measurePrefixValues[Int64(trieIndex - UnitsData_Constants.kPrefixOffset)]
    }

    private static func getTrieIndexForPrefix(prefix: MeasureUnit_MeasurePrefix): Int32 {
        return prefix.ordinal + UnitsData_Constants.kPrefixOffset
    }

    private func parse(): MeasureUnitImpl {
        let result = MeasureUnitImpl()
        if (fSource.isEmpty()) {
            return None
        }
        while (hasNext()) {
            fSawAnd = false
            let singleUnit = nextSingleUnit()
            let added = result.appendSingleUnit(singleUnit)
            if (fSawAnd && !added) {
                throw IllegalArgumentException("Two similar units are not allowed in a mixed unit.")
            }
            if ((Int32(result.singleUnits.size)) >= 2) {
                let complexity: MeasureUnit_Complexity = if (fSawAnd) { MeasureUnit_Complexity.MIXED } else { MeasureUnit_Complexity.COMPOUND }
                if (Int32(result.getSingleUnits().size) == 2) {
                    if (!refEq(result.getComplexity(), MeasureUnit_Complexity.COMPOUND)) {
                        throw AssertionError()
                    }
                    result.setComplexity(complexity)
                } else if (!refEq(result.getComplexity(), complexity)) {
                    throw IllegalArgumentException("Can't have mixed compound units")
                }
            }
        }
        return result
    }

    private func nextSingleUnit(): SingleUnitImpl {
        let result = SingleUnitImpl()
        var state = 0
        let atStart = fIndex == 0
        var token = nextToken()
        if (atStart) {
            if (refEq(token.getType(), MeasureUnitImpl_UnitsParser_Token_Type.TYPE_INITIAL_COMPOUND_PART)) {
                if (!refEq(token.getInitialCompoundPart(), MeasureUnitImpl_InitialCompoundPart.INITIAL_COMPOUND_PART_PER)) {
                    throw AssertionError()
                }
                fAfterPer = true
                result.setDimensionality(-1)
                token = nextToken()
            }
        } else {
            if (!refEq(token.getType(), MeasureUnitImpl_UnitsParser_Token_Type.TYPE_COMPOUND_PART)) {
                throw IllegalArgumentException("token type must be TYPE_COMPOUND_PART")
            }
            let compoundPart = MeasureUnitImpl_CompoundPart.getCompoundPartFromTrieIndex(token.getMatch())
            match (compoundPart) {
                case MeasureUnitImpl_CompoundPart.PER =>
                    if (fSawAnd) {
                        throw IllegalArgumentException("Mixed compound units not yet supported")
                    }
                    fAfterPer = true
                    result.setDimensionality(-1)
                case MeasureUnitImpl_CompoundPart.TIMES => if (fAfterPer) {
                    result.setDimensionality(-1)
                }
                case MeasureUnitImpl_CompoundPart.AND =>
                    if (fAfterPer) {
                        throw IllegalArgumentException("Can't start with \"-and-\", and mixed compound units")
                    }
                    fSawAnd = true
                case _ => ()
            }
            token = nextToken()
        }
        while (true) {
            match (token.getType()) {
                case MeasureUnitImpl_UnitsParser_Token_Type.TYPE_POWER_PART =>
                    if (state > 0) {
                        throw IllegalArgumentException()
                    }
                    result.setDimensionality(result.getDimensionality() * token.getPower())
                    state = 1
                case MeasureUnitImpl_UnitsParser_Token_Type.TYPE_PREFIX =>
                    if (state > 1) {
                        throw IllegalArgumentException()
                    }
                    result.setPrefix(token.getPrefix())
                    state = 2
                case MeasureUnitImpl_UnitsParser_Token_Type.TYPE_SIMPLE_UNIT =>
                    result.setSimpleUnit(token.getSimpleUnitIndex(), UnitsData.getSimpleUnits())
                    return result
                case _ => throw IllegalArgumentException()
            }
            if (!hasNext()) {
                throw IllegalArgumentException("We ran out of tokens before finding a complete single unit.")
            }
            token = nextToken()
        }
        throw Exception()
    }

    private func hasNext(): Bool {
        return fIndex < Int32(fSource.size)
    }

    private func nextToken(): MeasureUnitImpl_UnitsParser_Token {
        trie.reset()
        var match = -1
        var previ = -1
        while (fIndex < Int32(fSource.size)) {
            let result = trie.next(Int32(UInt32(Char(fSource[Int64(match (0) { case _ => fIndex++; fIndex - 1 })]))))
            if (refEq(result, BytesTrie_Result.NO_MATCH)) {
                break
            } else if (refEq(result, BytesTrie_Result.NO_VALUE)) {
                continue
            }
            match = trie.getValue()
            previ = fIndex
            if (refEq(result, BytesTrie_Result.FINAL_VALUE)) {
                break
            }
            if (!refEq(result, BytesTrie_Result.INTERMEDIATE_VALUE)) {
                throw IllegalArgumentException("result must has an intermediate value")
            }
        }
        if (match < 0) {
            throw IllegalArgumentException("Encountered unknown token starting at index " + previ.toString())
        } else {
            fIndex = previ
        }
        return MeasureUnitImpl_UnitsParser_Token(match)
    }
}


class MeasureUnitImpl_UnitsParser_Token {
    private let fMatch: Int32

    private let Type: MeasureUnitImpl_UnitsParser_Token_Type

    public init(fMatch: Int32) {
        this.fMatch = fMatch
        Type = calculateType(fMatch)
    }

    public func getType(): MeasureUnitImpl_UnitsParser_Token_Type {
        return this.Type
    }

    public func getPrefix(): MeasureUnit_MeasurePrefix {
        if (!refEq(this.Type, MeasureUnitImpl_UnitsParser_Token_Type.TYPE_PREFIX)) {
            throw AssertionError()
        }
        return MeasureUnitImpl_UnitsParser.getPrefixFromTrieIndex(this.fMatch)
    }

    public func getMatch(): Int32 {
        if (!refEq(getType(), MeasureUnitImpl_UnitsParser_Token_Type.TYPE_COMPOUND_PART)) {
            throw AssertionError()
        }
        return fMatch
    }

    public func getInitialCompoundPart(): MeasureUnitImpl_InitialCompoundPart {
        if (!(refEq(this.Type, MeasureUnitImpl_UnitsParser_Token_Type.TYPE_INITIAL_COMPOUND_PART) && fMatch == MeasureUnitImpl_InitialCompoundPart.INITIAL_COMPOUND_PART_PER.getTrieIndex())) {
            throw AssertionError()
        }
        return MeasureUnitImpl_InitialCompoundPart.getInitialCompoundPartFromTrieIndex(fMatch)
    }

    public func getPower(): Int32 {
        if (!refEq(this.Type, MeasureUnitImpl_UnitsParser_Token_Type.TYPE_POWER_PART)) {
            throw AssertionError()
        }
        return MeasureUnitImpl_PowerPart.getPowerFromTrieIndex(this.fMatch)
    }

    public func getSimpleUnitIndex(): Int32 {
        if (!refEq(this.Type, MeasureUnitImpl_UnitsParser_Token_Type.TYPE_SIMPLE_UNIT)) {
            throw AssertionError()
        }
        return this.fMatch - UnitsData_Constants.kSimpleUnitOffset
    }

    private func calculateType(fMatch: Int32): MeasureUnitImpl_UnitsParser_Token_Type {
        if (fMatch <= 0) {
            throw Exception("fMatch must have a positive value")
        }
        if (fMatch < UnitsData_Constants.kCompoundPartOffset) {
            return MeasureUnitImpl_UnitsParser_Token_Type.TYPE_PREFIX
        }
        if (fMatch < UnitsData_Constants.kInitialCompoundPartOffset) {
            return MeasureUnitImpl_UnitsParser_Token_Type.TYPE_COMPOUND_PART
        }
        if (fMatch < UnitsData_Constants.kPowerPartOffset) {
            return MeasureUnitImpl_UnitsParser_Token_Type.TYPE_INITIAL_COMPOUND_PART
        }
        if (fMatch < UnitsData_Constants.kSimpleUnitOffset) {
            return MeasureUnitImpl_UnitsParser_Token_Type.TYPE_POWER_PART
        }
        return MeasureUnitImpl_UnitsParser_Token_Type.TYPE_SIMPLE_UNIT
    }
}


class MeasureUnitImpl_UnitsParser_Token_Type <: Enum<MeasureUnitImpl_UnitsParser_Token_Type> {
    public static let TYPE_UNDEFINED = MeasureUnitImpl_UnitsParser_Token_Type("TYPE_UNDEFINED", 0)

    public static let TYPE_PREFIX = MeasureUnitImpl_UnitsParser_Token_Type("TYPE_PREFIX", 1)

    public static let TYPE_COMPOUND_PART = MeasureUnitImpl_UnitsParser_Token_Type("TYPE_COMPOUND_PART", 2)

    public static let TYPE_INITIAL_COMPOUND_PART = MeasureUnitImpl_UnitsParser_Token_Type("TYPE_INITIAL_COMPOUND_PART", 3)

    public static let TYPE_POWER_PART = MeasureUnitImpl_UnitsParser_Token_Type("TYPE_POWER_PART", 4)

    public static let TYPE_SIMPLE_UNIT = MeasureUnitImpl_UnitsParser_Token_Type("TYPE_SIMPLE_UNIT", 5)

    private static func _values(): Array<MeasureUnitImpl_UnitsParser_Token_Type> {
        return [MeasureUnitImpl_UnitsParser_Token_Type.TYPE_UNDEFINED, MeasureUnitImpl_UnitsParser_Token_Type.TYPE_PREFIX, MeasureUnitImpl_UnitsParser_Token_Type.TYPE_COMPOUND_PART, MeasureUnitImpl_UnitsParser_Token_Type.TYPE_INITIAL_COMPOUND_PART, MeasureUnitImpl_UnitsParser_Token_Type.TYPE_POWER_PART, MeasureUnitImpl_UnitsParser_Token_Type.TYPE_SIMPLE_UNIT]
    }

    private static let _VALUES = MeasureUnitImpl_UnitsParser_Token_Type._values()

    public static func values(): Array<MeasureUnitImpl_UnitsParser_Token_Type> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): MeasureUnitImpl_UnitsParser_Token_Type {
        return (TypeInfo.of<MeasureUnitImpl_UnitsParser_Token_Type>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as MeasureUnitImpl_UnitsParser_Token_Type
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class MeasureUnitImpl_MeasureUnitImplComparator <: Comparator {
    private let conversionRates: ConversionRates

    public init(conversionRates: ConversionRates) {
        this.conversionRates = conversionRates
    }

    public override func compare(o1: MeasureUnitImpl, o2: MeasureUnitImpl): Int32 {
        let special1 = this.conversionRates.getSpecialMappingName(o1)
        let special2 = this.conversionRates.getSpecialMappingName(o2)
        if (special1.isSome() || special2.isSome()) {
            if (special1.isNone()) {
                return -1
            }
            if (special2.isNone()) {
                return 1
            }
            return special1.compare(special2).value()
        }
        let factor1 = this.conversionRates.getFactorToBase(o1).getConversionRate()
        let factor2 = this.conversionRates.getFactorToBase(o2).getConversionRate()
        return factor1.compare(factor2)
    }
}


class MeasureUnitImpl_MeasureUnitImplWithIndexComparator <: Comparator {
    private var measureUnitImplComparator: MeasureUnitImpl_MeasureUnitImplComparator

    public init(conversionRates: ConversionRates) {
        this.measureUnitImplComparator = MeasureUnitImpl_MeasureUnitImplComparator(conversionRates)
    }

    public override func compare(o1: MeasureUnitImpl_MeasureUnitImplWithIndex, o2: MeasureUnitImpl_MeasureUnitImplWithIndex): Int32 {
        return this.measureUnitImplComparator.compare(o1.unitImpl, o2.unitImpl)
    }
}


class MeasureUnitImpl_SingleUnitComparator <: Comparator {

    public override func compare(o1: SingleUnitImpl, o2: SingleUnitImpl): Int32 {
        return o1.compareTo(o2)
    }
}
