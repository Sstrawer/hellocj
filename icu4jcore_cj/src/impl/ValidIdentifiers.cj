package icu4cj.impl


public class ValidIdentifiers {

    public static func getData(): Map<ValidIdentifiers_Datatype, Map<ValidIdentifiers_Datasubtype, ValidIdentifiers_ValiditySet>> {
        return ValidIdentifiers_ValidityData.data
    }

    public static func isValid(datatype: ValidIdentifiers_Datatype, datasubtypes: Set<ValidIdentifiers_Datasubtype>, code: String): ValidIdentifiers_Datasubtype {
        let subtable = ValidIdentifiers_ValidityData.data.get(datatype)
        if (subtable.isSome()) {
            for (datasubtype in datasubtypes) {
                let validitySet = subtable.get(datasubtype)
                if (validitySet.isSome()) {
                    if (validitySet.contains(AsciiUtil.toLowerString(code))) {
                        return datasubtype
                    }
                }
            }
        }
        return None
    }

    public static func isValid(datatype: ValidIdentifiers_Datatype, datasubtypes: Set<ValidIdentifiers_Datasubtype>, code: String, value: String): ValidIdentifiers_Datasubtype {
        var tempcode = code
        var tempvalue = value
        let subtable = ValidIdentifiers_ValidityData.data.get(datatype)
        if (subtable.isSome()) {
            tempcode = AsciiUtil.toLowerString(tempcode)
            tempvalue = AsciiUtil.toLowerString(tempvalue)
            for (datasubtype in datasubtypes) {
                let validitySet = subtable.get(datasubtype)
                if (validitySet.isSome()) {
                    if (validitySet.contains(tempcode, tempvalue)) {
                        return datasubtype
                    }
                }
            }
        }
        return None
    }
}


public class ValidIdentifiers_Datatype <: Enum<ValidIdentifiers_Datatype> {
    public static let currency = ValidIdentifiers_Datatype("currency", 0)

    public static let language = ValidIdentifiers_Datatype("language", 1)

    public static let region = ValidIdentifiers_Datatype("region", 2)

    public static let script = ValidIdentifiers_Datatype("script", 3)

    public static let subdivision = ValidIdentifiers_Datatype("subdivision", 4)

    public static let unit = ValidIdentifiers_Datatype("unit", 5)

    public static let variant = ValidIdentifiers_Datatype("variant", 6)

    public static let u = ValidIdentifiers_Datatype("u", 7)

    public static let t = ValidIdentifiers_Datatype("t", 8)

    public static let x = ValidIdentifiers_Datatype("x", 9)

    public static let illegal = ValidIdentifiers_Datatype("illegal", 10)

    private static func _values(): Array<ValidIdentifiers_Datatype> {
        return [ValidIdentifiers_Datatype.currency, ValidIdentifiers_Datatype.language, ValidIdentifiers_Datatype.region, ValidIdentifiers_Datatype.script, ValidIdentifiers_Datatype.subdivision, ValidIdentifiers_Datatype.unit, ValidIdentifiers_Datatype.variant, ValidIdentifiers_Datatype.u, ValidIdentifiers_Datatype.t, ValidIdentifiers_Datatype.x, ValidIdentifiers_Datatype.illegal]
    }

    private static let _VALUES = ValidIdentifiers_Datatype._values()

    public static func values(): Array<ValidIdentifiers_Datatype> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): ValidIdentifiers_Datatype {
        return (TypeInfo.of<ValidIdentifiers_Datatype>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as ValidIdentifiers_Datatype
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class ValidIdentifiers_Datasubtype <: Enum<ValidIdentifiers_Datasubtype> {
    public static let deprecated = ValidIdentifiers_Datasubtype("deprecated", 0)

    public static let private_use = ValidIdentifiers_Datasubtype("private_use", 1)

    public static let regular = ValidIdentifiers_Datasubtype("regular", 2)

    public static let special = ValidIdentifiers_Datasubtype("special", 3)

    public static let unknown = ValidIdentifiers_Datasubtype("unknown", 4)

    public static let macroregion = ValidIdentifiers_Datasubtype("macroregion", 5)

    public static let reserved = ValidIdentifiers_Datasubtype("reserved", 6)

    private static func _values(): Array<ValidIdentifiers_Datasubtype> {
        return [ValidIdentifiers_Datasubtype.deprecated, ValidIdentifiers_Datasubtype.private_use, ValidIdentifiers_Datasubtype.regular, ValidIdentifiers_Datasubtype.special, ValidIdentifiers_Datasubtype.unknown, ValidIdentifiers_Datasubtype.macroregion, ValidIdentifiers_Datasubtype.reserved]
    }

    private static let _VALUES = ValidIdentifiers_Datasubtype._values()

    public static func values(): Array<ValidIdentifiers_Datasubtype> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): ValidIdentifiers_Datasubtype {
        return (TypeInfo.of<ValidIdentifiers_Datasubtype>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as ValidIdentifiers_Datasubtype
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


public class ValidIdentifiers_ValiditySet {
    public let regularData: Set<String>

    public let subdivisionData: Map<String, Set<String>>

    public init(plainData: Set<String>, makeMap: Bool) {
        if (makeMap) {
            let _subdivisionData = HashMap<String, Set<String>>()
            for (s in plainData) {
                var pos = indexOfWrap(s.indexOf(UInt8(UInt32('-'))))
                var pos2 = pos + 1
                if (pos < 0) {
                    pos2 = match (0) { case _ => pos = if (Char(s[0]) < 'A') { 3 } else { 2 }; pos }
                }
                let key: String = s[0..Int64(pos)]
                let subdivision: String = s[Int64(pos2)..]
                var oldSet = _subdivisionData.get(key)
                if (oldSet.isNone()) {
                    _subdivisionData.put(key, match (0) { case _ => oldSet = HashSet<String>(); oldSet })
                }
                oldSet.put(subdivision)
            }
            this.regularData = None
            let _subdivisionData2 = HashMap<String, Set<String>>()
            for (e in _subdivisionData.entrySet()) {
                let value = e.getValue()
                let set = if (Int32(value.size) == 1) { Collections.singleton(value.iterator().next()) } else { Collections.unmodifiableSet(value) }
                _subdivisionData2.put(e.getKey(), set)
            }
            this.subdivisionData = Collections.unmodifiableMap(_subdivisionData2 as Map<K, V>)
        } else {
            this.regularData = Collections.unmodifiableSet(plainData)
            this.subdivisionData = None
        }
    }

    public func contains(code: String): Bool {
        if (regularData.isSome()) {
            return regularData.contains(code)
        } else {
            let pos = indexOfWrap(code.indexOf(UInt8(UInt32('-'))))
            let key: String = code[0..Int64(pos)]
            let value: String = code[Int64(pos + 1)..]
            return contains(key, value)
        }
    }

    public func contains(key: String, value: String): Bool {
        let oldSet = subdivisionData.get(key)
        return oldSet.isSome() && oldSet.contains(value)
    }

    public override func toString(): String {
        if (regularData.isSome()) {
            return toString(regularData)
        } else {
            return toString(subdivisionData)
        }
    }
}


class ValidIdentifiers_ValidityData {

    static let data: Map<ValidIdentifiers_Datatype, Map<ValidIdentifiers_Datasubtype, ValidIdentifiers_ValiditySet>>


    private static func addRange(string: String, subvalues: Set<String>): Unit {
        var tempstring = string
        tempstring = AsciiUtil.toLowerString(tempstring)
        let pos = indexOfWrap(tempstring.indexOf(UInt8(UInt32('~'))))
        if (pos < 0) {
            subvalues.put(tempstring)
        } else {
            StringRange.expand(tempstring[0..Int64(pos)], tempstring[Int64(pos + 1)..], false, subvalues)
        }
    }
}
