package icu4cj.impl.locale


public class KeyTypeData {

    public static func toBcpKey(key: String): String {
        var tempkey = key
        tempkey = AsciiUtil.toLowerString(tempkey)
        let keyData = KEYMAP.get(tempkey)
        if (keyData.isSome()) {
            return keyData.bcpId
        }
        return None
    }

    public static func toLegacyKey(key: String): String {
        var tempkey = key
        tempkey = AsciiUtil.toLowerString(tempkey)
        let keyData = KEYMAP.get(tempkey)
        if (keyData.isSome()) {
            return keyData.legacyId
        }
        return None
    }

    public static func toBcpType(key: String, Type: String, isKnownKey: Output<Bool>, isSpecialType: Output<Bool>): String {
        var tempkey = key
        var temptype = Type
        if (isKnownKey.isSome()) {
            isKnownKey.value = Bool.valueOf(false)
        }
        if (isSpecialType.isSome()) {
            isSpecialType.value = Bool.valueOf(false)
        }
        tempkey = AsciiUtil.toLowerString(tempkey)
        temptype = AsciiUtil.toLowerString(temptype)
        let keyData = KEYMAP.get(tempkey)
        if (keyData.isSome()) {
            if (isKnownKey.isSome()) {
                isKnownKey.value = Bool.TRUE
            }
            let t = keyData.typeMap.get(temptype)
            if (t.isSome()) {
                return t.bcpId
            }
            if (keyData.specialTypes.isSome()) {
                for (st in keyData.specialTypes) {
                    if (st.handler.isWellFormed(temptype)) {
                        if (isSpecialType.isSome()) {
                            isSpecialType.value = Bool.valueOf(true)
                        }
                        return st.handler.canonicalize(temptype)
                    }
                }
            }
        }
        return None
    }

    public static func toLegacyType(key: String, Type: String, isKnownKey: Output<Bool>, isSpecialType: Output<Bool>): String {
        var tempkey = key
        var temptype = Type
        if (isKnownKey.isSome()) {
            isKnownKey.value = Bool.valueOf(false)
        }
        if (isSpecialType.isSome()) {
            isSpecialType.value = Bool.valueOf(false)
        }
        tempkey = AsciiUtil.toLowerString(tempkey)
        temptype = AsciiUtil.toLowerString(temptype)
        let keyData = KEYMAP.get(tempkey)
        if (keyData.isSome()) {
            if (isKnownKey.isSome()) {
                isKnownKey.value = Bool.TRUE
            }
            let t = keyData.typeMap.get(temptype)
            if (t.isSome()) {
                return t.legacyId
            }
            if (keyData.specialTypes.isSome()) {
                for (st in keyData.specialTypes) {
                    if (st.handler.isWellFormed(temptype)) {
                        if (isSpecialType.isSome()) {
                            isSpecialType.value = Bool.valueOf(true)
                        }
                        return st.handler.canonicalize(temptype)
                    }
                }
            }
        }
        return None
    }

    private static func initFromResourceBundle(): Unit {
        let keyTypeDataRes = ICUResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "keyTypeData", ICUResourceBundle.ICU_DATA_CLASS_LOADER, ICUResourceBundle_OpenType.DIRECT)
        getKeyInfo(keyTypeDataRes.get("keyInfo"))
        getTypeInfo(keyTypeDataRes.get("typeInfo"))
        let keyMapRes = keyTypeDataRes.get("keyMap")
        let typeMapRes = keyTypeDataRes.get("typeMap")
        var typeAliasRes: UResourceBundle
        var bcpTypeAliasRes: UResourceBundle
        try {
            typeAliasRes = keyTypeDataRes.get("typeAlias")
        } catch (e: MissingResourceException) { }
        try {
            bcpTypeAliasRes = keyTypeDataRes.get("bcpTypeAlias")
        } catch (e: MissingResourceException) { }
        let keyMapItr = keyMapRes.getIterator()
        let _Bcp47Keys = LinkedHashMap()
        while (keyMapItr.hasNext()) {
            let keyMapEntry = keyMapItr.next()
            let legacyKeyId = keyMapEntry.getKey()
            var bcpKeyId = keyMapEntry.getString()
            var hasSameKey = false
            if (Int32(bcpKeyId.size) == 0) {
                bcpKeyId = legacyKeyId
                hasSameKey = true
            }
            let _bcp47Types = LinkedHashSet()
            _Bcp47Keys.put(bcpKeyId, Collections.unmodifiableSet(_bcp47Types as Set<T>))
            let isTZ = legacyKeyId == "timezone"
            var typeAliasMap: Map<String, Set<String>> = None
            if (typeAliasRes.isSome()) {
                var typeAliasResByKey: UResourceBundle
                try {
                    typeAliasResByKey = typeAliasRes.get(legacyKeyId)
                } catch (e: MissingResourceException) { }
                if (typeAliasResByKey.isSome()) {
                    typeAliasMap = HashMap<String, Set<String>>()
                    let typeAliasResItr = typeAliasResByKey.getIterator()
                    while (typeAliasResItr.hasNext()) {
                        let typeAliasDataEntry = typeAliasResItr.next()
                        var comefrom = typeAliasDataEntry.getKey()
                        let to = typeAliasDataEntry.getString()
                        if (isTZ) {
                            comefrom = comefrom.replace(':'.toString(), '/'.toString())
                        }
                        var aliasSet = typeAliasMap.get(to)
                        if (aliasSet.isNone()) {
                            aliasSet = HashSet<String>()
                            typeAliasMap.put(to, aliasSet)
                        }
                        aliasSet.put(comefrom)
                    }
                }
            }
            var bcpTypeAliasMap: Map<String, Set<String>> = None
            if (bcpTypeAliasRes.isSome()) {
                var bcpTypeAliasResByKey: UResourceBundle
                try {
                    bcpTypeAliasResByKey = bcpTypeAliasRes.get(bcpKeyId)
                } catch (e: MissingResourceException) { }
                if (bcpTypeAliasResByKey.isSome()) {
                    bcpTypeAliasMap = HashMap<String, Set<String>>()
                    let bcpTypeAliasResItr = bcpTypeAliasResByKey.getIterator()
                    while (bcpTypeAliasResItr.hasNext()) {
                        let bcpTypeAliasDataEntry = bcpTypeAliasResItr.next()
                        let comefrom = bcpTypeAliasDataEntry.getKey()
                        let to = bcpTypeAliasDataEntry.getString()
                        var aliasSet = bcpTypeAliasMap.get(to)
                        if (aliasSet.isNone()) {
                            aliasSet = HashSet<String>()
                            bcpTypeAliasMap.put(to, aliasSet)
                        }
                        aliasSet.put(comefrom)
                    }
                }
            }
            let typeDataMap: Map<String, KeyTypeData_Type> = HashMap<String, KeyTypeData_Type>()
            var specialTypeSet: EnumSet = None
            var typeMapResByKey: UResourceBundle
            try {
                typeMapResByKey = typeMapRes.get(legacyKeyId)
            } catch (e: MissingResourceException) {
                if (!false) {
                    throw AssertionError()
                }
            }
            if (typeMapResByKey.isSome()) {
                let typeMapResByKeyItr = typeMapResByKey.getIterator()
                while (typeMapResByKeyItr.hasNext()) {
                    let typeMapEntry = typeMapResByKeyItr.next()
                    var legacyTypeId = typeMapEntry.getKey()
                    var bcpTypeId = typeMapEntry.getString()
                    let first = Char(legacyTypeId[0])
                    let isSpecialType = '9' < first && first < 'a' && Int32(bcpTypeId.size) == 0
                    if (isSpecialType) {
                        if (specialTypeSet.isNone()) {
                            specialTypeSet = EnumSet.noneOf(TypeInfo.of<KeyTypeData_SpecialType>() as ClassTypeInfo)
                        }
                        specialTypeSet.add(KeyTypeData_SpecialType.valueOf(legacyTypeId))
                        _bcp47Types.put(legacyTypeId)
                        continue
                    }
                    if (isTZ) {
                        legacyTypeId = legacyTypeId.replace(':'.toString(), '/'.toString())
                    }
                    var hasSameType = false
                    if (Int32(bcpTypeId.size) == 0) {
                        bcpTypeId = legacyTypeId
                        hasSameType = true
                    }
                    _bcp47Types.put(bcpTypeId)
                    let t = KeyTypeData_Type(legacyTypeId, bcpTypeId)
                    typeDataMap.put(AsciiUtil.toLowerString(legacyTypeId), t)
                    if (!hasSameType) {
                        typeDataMap.put(AsciiUtil.toLowerString(bcpTypeId), t)
                    }
                    if (typeAliasMap.isSome()) {
                        let typeAliasSet = typeAliasMap.get(legacyTypeId)
                        if (typeAliasSet.isSome()) {
                            for (alias in typeAliasSet) {
                                typeDataMap.put(AsciiUtil.toLowerString(alias), t)
                            }
                        }
                    }
                    if (bcpTypeAliasMap.isSome()) {
                        let bcpTypeAliasSet = bcpTypeAliasMap.get(bcpTypeId)
                        if (bcpTypeAliasSet.isSome()) {
                            for (alias in bcpTypeAliasSet) {
                                typeDataMap.put(AsciiUtil.toLowerString(alias), t)
                            }
                        }
                    }
                }
            }
            let keyData = KeyTypeData_KeyData(legacyKeyId, bcpKeyId, typeDataMap, specialTypeSet)
            KEYMAP.put(AsciiUtil.toLowerString(legacyKeyId), keyData)
            if (!hasSameKey) {
                KEYMAP.put(AsciiUtil.toLowerString(bcpKeyId), keyData)
            }
        }
        BCP47_KEYS = Collections.unmodifiableMap(_Bcp47Keys as Map<K, V>)
    }

    static var DEPRECATED_KEYS = Collections.emptySet<<--> -->()

    static var VALUE_TYPES = Collections.emptyMap<<--, // Cannot infer type argument: V -->>()

    static var DEPRECATED_KEY_TYPES = Collections.emptyMap<<--, // Cannot infer type argument: V -->>()

    private static func getKeyInfo(keyInfoRes: UResourceBundle): Unit {
        let _deprecatedKeys = LinkedHashSet()
        let _valueTypes = LinkedHashMap()
        let keyInfoIt = keyInfoRes.getIterator()
        while (keyInfoIt.hasNext()) {
            let keyInfoEntry = keyInfoIt.next()
            let key = keyInfoEntry.getKey()
            let keyInfo = KeyTypeData_KeyInfoType.valueOf(key)
            let keyInfoIt2 = keyInfoEntry.getIterator()
            while (keyInfoIt2.hasNext()) {
                let keyInfoEntry2 = keyInfoIt2.next()
                let key2 = keyInfoEntry2.getKey()
                let value2 = keyInfoEntry2.getString()
                match (keyInfo) {
                    case KeyTypeData_KeyInfoType.deprecated => _deprecatedKeys.put(key2)
                    case KeyTypeData_KeyInfoType.valueType => _valueTypes.put(key2, KeyTypeData_ValueType.valueOf(value2))
                    case _ => ()
                }
            }
        }
        DEPRECATED_KEYS = Collections.unmodifiableSet(_deprecatedKeys as Set<T>)
        VALUE_TYPES = Collections.unmodifiableMap(_valueTypes as Map<K, V>)
    }

    private static func getTypeInfo(typeInfoRes: UResourceBundle): Unit {
        let _deprecatedKeyTypes = LinkedHashMap()
        let keyInfoIt = typeInfoRes.getIterator()
        while (keyInfoIt.hasNext()) {
            let keyInfoEntry = keyInfoIt.next()
            let key = keyInfoEntry.getKey()
            let typeInfo = KeyTypeData_TypeInfoType.valueOf(key)
            let keyInfoIt2 = keyInfoEntry.getIterator()
            while (keyInfoIt2.hasNext()) {
                let keyInfoEntry2 = keyInfoIt2.next()
                let key2 = keyInfoEntry2.getKey()
                let _deprecatedTypes = LinkedHashSet()
                let keyInfoIt3 = keyInfoEntry2.getIterator()
                while (keyInfoIt3.hasNext()) {
                    let keyInfoEntry3 = keyInfoIt3.next()
                    let key3 = keyInfoEntry3.getKey()
                    match (typeInfo) {
                        case KeyTypeData_TypeInfoType.deprecated => _deprecatedTypes.put(key3)
                        case _ => ()
                    }
                }
                _deprecatedKeyTypes.put(key2, Collections.unmodifiableSet(_deprecatedTypes as Set<T>))
            }
        }
        DEPRECATED_KEY_TYPES = Collections.unmodifiableMap(_deprecatedKeyTypes as Map<K, V>)
    }

    private static let KEY_DATA = [0]

    private static func initFromTables(): Unit {
        for (keyDataEntry in KEY_DATA) {
            let legacyKeyId = keyDataEntry[0]
            var bcpKeyId = keyDataEntry[1]
            let typeData = keyDataEntry[2]
            let typeAliasData = keyDataEntry[3]
            let bcpTypeAliasData = keyDataEntry[4]
            var hasSameKey = false
            if (bcpKeyId.isNone()) {
                bcpKeyId = legacyKeyId
                hasSameKey = true
            }
            var typeAliasMap: Map<String, Set<String>> = None
            if (typeAliasData.isSome()) {
                typeAliasMap = HashMap<String, Set<String>>()
                for (typeAliasDataEntry in typeAliasData) {
                    let comefrom = typeAliasDataEntry[0]
                    let to = typeAliasDataEntry[1]
                    var aliasSet = typeAliasMap.get(to)
                    if (aliasSet.isNone()) {
                        aliasSet = HashSet<String>()
                        typeAliasMap.put(to, aliasSet)
                    }
                    aliasSet.put(comefrom)
                }
            }
            var bcpTypeAliasMap: Map<String, Set<String>> = None
            if (bcpTypeAliasData.isSome()) {
                bcpTypeAliasMap = HashMap<String, Set<String>>()
                for (bcpTypeAliasDataEntry in bcpTypeAliasData) {
                    let comefrom = bcpTypeAliasDataEntry[0]
                    let to = bcpTypeAliasDataEntry[1]
                    var aliasSet = bcpTypeAliasMap.get(to)
                    if (aliasSet.isNone()) {
                        aliasSet = HashSet<String>()
                        bcpTypeAliasMap.put(to, aliasSet)
                    }
                    aliasSet.put(comefrom)
                }
            }
            if (!typeData.isSome()) {
                throw AssertionError()
            }
            let typeDataMap: Map<String, KeyTypeData_Type> = HashMap<String, KeyTypeData_Type>()
            var specialTypeSet: Set<KeyTypeData_SpecialType>
            for (typeDataEntry in typeData) {
                let legacyTypeId = typeDataEntry[0]
                var bcpTypeId = typeDataEntry[1]
                var isSpecialType = false
                for (st in KeyTypeData_SpecialType.values()) {
                    if (legacyTypeId.equals(st.toString())) {
                        isSpecialType = true
                        if (specialTypeSet.isNone()) {
                            specialTypeSet = HashSet<KeyTypeData_SpecialType>()
                        }
                        specialTypeSet.put(st)
                        break
                    }
                }
                if (isSpecialType) {
                    continue
                }
                var hasSameType = false
                if (bcpTypeId.isNone()) {
                    bcpTypeId = legacyTypeId
                    hasSameType = true
                }
                let t = KeyTypeData_Type(legacyTypeId, bcpTypeId)
                typeDataMap.put(AsciiUtil.toLowerString(legacyTypeId), t)
                if (!hasSameType) {
                    typeDataMap.put(AsciiUtil.toLowerString(bcpTypeId), t)
                }
                let typeAliasSet = typeAliasMap.get(legacyTypeId)
                if (typeAliasSet.isSome()) {
                    for (alias in typeAliasSet) {
                        typeDataMap.put(AsciiUtil.toLowerString(alias), t)
                    }
                }
                let bcpTypeAliasSet = bcpTypeAliasMap.get(bcpTypeId)
                if (bcpTypeAliasSet.isSome()) {
                    for (alias in bcpTypeAliasSet) {
                        typeDataMap.put(AsciiUtil.toLowerString(alias), t)
                    }
                }
            }
            var specialTypes: EnumSet = None
            if (specialTypeSet.isSome()) {
                specialTypes = EnumSet.copyOf(specialTypeSet)
            }
            let keyData = KeyTypeData_KeyData(legacyKeyId, bcpKeyId, typeDataMap, specialTypes)
            KEYMAP.put(AsciiUtil.toLowerString(legacyKeyId), keyData)
            if (!hasSameKey) {
                KEYMAP.put(AsciiUtil.toLowerString(bcpKeyId), keyData)
            }
        }
    }

    private static let KEYMAP: Map<String, KeyTypeData_KeyData> = HashMap<String, KeyTypeData_KeyData>()

    private static var BCP47_KEYS: Map<String, Set<String>> = None


    public static func getBcp47Keys(): Set<String> {
        return SetCollectionView<String>(BCP47_KEYS.keys())
    }

    public static func getBcp47KeyTypes(key: String): Set<String> {
        return BCP47_KEYS.get(key)
    }

    public static func isDeprecated(key: String): Bool {
        return DEPRECATED_KEYS.contains(key)
    }

    public static func isDeprecated(key: String, Type: String): Bool {
        let deprecatedTypes = DEPRECATED_KEY_TYPES.get(key)
        if (deprecatedTypes.isNone()) {
            return false
        }
        return deprecatedTypes.contains(Type)
    }

    public static func getValueType(key: String): KeyTypeData_ValueType {
        let Type = VALUE_TYPES.get(key)
        return if (Type.isNone()) { KeyTypeData_ValueType.single } else { Type }
    }
}


public class KeyTypeData_ValueType <: Enum<KeyTypeData_ValueType> {
    public static let single = KeyTypeData_ValueType("single", 0)

    public static let multiple = KeyTypeData_ValueType("multiple", 1)

    public static let incremental = KeyTypeData_ValueType("incremental", 2)

    public static let any = KeyTypeData_ValueType("any", 3)

    private static func _values(): Array<KeyTypeData_ValueType> {
        return [KeyTypeData_ValueType.single, KeyTypeData_ValueType.multiple, KeyTypeData_ValueType.incremental, KeyTypeData_ValueType.any]
    }

    private static let _VALUES = KeyTypeData_ValueType._values()

    public static func values(): Array<KeyTypeData_ValueType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): KeyTypeData_ValueType {
        return (TypeInfo.of<KeyTypeData_ValueType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as KeyTypeData_ValueType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


abstract class KeyTypeData_SpecialTypeHandler {

    public func isWellFormed(value: String): Bool

    public func canonicalize(value: String): String {
        return AsciiUtil.toLowerString(value)
    }
}


class KeyTypeData_CodepointsTypeHandler <: KeyTypeData_SpecialTypeHandler {
    init() {
        super()
    }

    private static let pat = Pattern.compile("[0-9a-fA-F]{4,6}(-[0-9a-fA-F]{4,6})*")

    public override func isWellFormed(value: String): Bool {
        return pat.matcher(value).matches()
    }
}


class KeyTypeData_ReorderCodeTypeHandler <: KeyTypeData_SpecialTypeHandler {
    init() {
        super()
    }

    private static let pat = Pattern.compile("[a-zA-Z]{3,8}(-[a-zA-Z]{3,8})*")

    public override func isWellFormed(value: String): Bool {
        return pat.matcher(value).matches()
    }
}


class KeyTypeData_RgKeyValueTypeHandler <: KeyTypeData_SpecialTypeHandler {
    init() {
        super()
    }

    private static let pat = Pattern.compile("([a-zA-Z]{2}|[0-9]{3})[zZ]{4}")

    public override func isWellFormed(value: String): Bool {
        return pat.matcher(value).matches()
    }
}


class KeyTypeData_ScriptCodeTypeHandler <: KeyTypeData_SpecialTypeHandler {
    init() {
        super()
    }

    private static let pat = Pattern.compile("[a-zA-Z]{4}(-[a-zA-Z]{4})*")

    public override func isWellFormed(value: String): Bool {
        return pat.matcher(value).matches()
    }
}


class KeyTypeData_SubdivisionKeyValueTypeHandler <: KeyTypeData_SpecialTypeHandler {
    init() {
        super()
    }

    private static let pat = Pattern.compile("([a-zA-Z]{2}|[0-9]{3})")

    public override func isWellFormed(value: String): Bool {
        return pat.matcher(value).matches()
    }
}


class KeyTypeData_PrivateUseKeyValueTypeHandler <: KeyTypeData_SpecialTypeHandler {
    init() {
        super()
    }

    private static let pat = Pattern.compile("[a-zA-Z0-9]{3,8}(-[a-zA-Z0-9]{3,8})*")

    public override func isWellFormed(value: String): Bool {
        return pat.matcher(value).matches()
    }
}


class KeyTypeData_SpecialType <: Enum<KeyTypeData_SpecialType> {
    public static let CODEPOINTS = KeyTypeData_SpecialType("CODEPOINTS", 0, KeyTypeData_CodepointsTypeHandler())

    public static let REORDER_CODE = KeyTypeData_SpecialType("REORDER_CODE", 1, KeyTypeData_ReorderCodeTypeHandler())

    public static let RG_KEY_VALUE = KeyTypeData_SpecialType("RG_KEY_VALUE", 2, KeyTypeData_RgKeyValueTypeHandler())

    public static let SCRIPT_CODE = KeyTypeData_SpecialType("SCRIPT_CODE", 3, KeyTypeData_ScriptCodeTypeHandler())

    public static let SUBDIVISION_CODE = KeyTypeData_SpecialType("SUBDIVISION_CODE", 4, KeyTypeData_SubdivisionKeyValueTypeHandler())

    public static let PRIVATE_USE = KeyTypeData_SpecialType("PRIVATE_USE", 5, KeyTypeData_PrivateUseKeyValueTypeHandler())

    private static func _values(): Array<KeyTypeData_SpecialType> {
        return [KeyTypeData_SpecialType.CODEPOINTS, KeyTypeData_SpecialType.REORDER_CODE, KeyTypeData_SpecialType.RG_KEY_VALUE, KeyTypeData_SpecialType.SCRIPT_CODE, KeyTypeData_SpecialType.SUBDIVISION_CODE, KeyTypeData_SpecialType.PRIVATE_USE]
    }

    private static let _VALUES = KeyTypeData_SpecialType._values()

    public static func values(): Array<KeyTypeData_SpecialType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): KeyTypeData_SpecialType {
        return (TypeInfo.of<KeyTypeData_SpecialType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as KeyTypeData_SpecialType
    }

    var handler: KeyTypeData_SpecialTypeHandler

    init(_enum_name: String, _enum_ordinal: Int32, handler: KeyTypeData_SpecialTypeHandler) {
        super(_enum_name, _enum_ordinal)
        this.handler = handler
    }
}


class KeyTypeData_KeyData {
    var legacyId: String

    var bcpId: String

    var typeMap: Map<String, KeyTypeData_Type> = None

    var specialTypes: EnumSet = None

    init(legacyId: String, bcpId: String, typeMap: Map<String, KeyTypeData_Type>, specialTypes: EnumSet) {
        this.legacyId = legacyId
        this.bcpId = bcpId
        this.typeMap = typeMap
        this.specialTypes = specialTypes
    }
}


class KeyTypeData_Type {
    var legacyId: String

    var bcpId: String

    init(legacyId: String, bcpId: String) {
        this.legacyId = legacyId
        this.bcpId = bcpId
    }
}


class KeyTypeData_KeyInfoType <: Enum<KeyTypeData_KeyInfoType> {
    public static let deprecated = KeyTypeData_KeyInfoType("deprecated", 0)

    public static let valueType = KeyTypeData_KeyInfoType("valueType", 1)

    private static func _values(): Array<KeyTypeData_KeyInfoType> {
        return [KeyTypeData_KeyInfoType.deprecated, KeyTypeData_KeyInfoType.valueType]
    }

    private static let _VALUES = KeyTypeData_KeyInfoType._values()

    public static func values(): Array<KeyTypeData_KeyInfoType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): KeyTypeData_KeyInfoType {
        return (TypeInfo.of<KeyTypeData_KeyInfoType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as KeyTypeData_KeyInfoType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}


class KeyTypeData_TypeInfoType <: Enum<KeyTypeData_TypeInfoType> {
    public static let deprecated = KeyTypeData_TypeInfoType("deprecated", 0)

    private static func _values(): Array<KeyTypeData_TypeInfoType> {
        return [KeyTypeData_TypeInfoType.deprecated]
    }

    private static let _VALUES = KeyTypeData_TypeInfoType._values()

    public static func values(): Array<KeyTypeData_TypeInfoType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): KeyTypeData_TypeInfoType {
        return (TypeInfo.of<KeyTypeData_TypeInfoType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as KeyTypeData_TypeInfoType
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}
