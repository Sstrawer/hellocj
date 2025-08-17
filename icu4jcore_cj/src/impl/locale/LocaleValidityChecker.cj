package icu4cj.impl.locale


public class LocaleValidityChecker {
    private let datasubtypes: Set<ValidIdentifiers_Datasubtype>

    private let allowsDeprecated: Bool

    public init(datasubtypes: Set<ValidIdentifiers_Datasubtype>) {
        this.datasubtypes = EnumSet.copyOf(datasubtypes)
        allowsDeprecated = datasubtypes.contains(ValidIdentifiers_Datasubtype.deprecated)
    }

    public init(datasubtypes: Array<ValidIdentifiers_Datasubtype>) {
        this.datasubtypes = EnumSet.copyOf(datasubtypes)
        allowsDeprecated = this.datasubtypes.contains(ValidIdentifiers_Datasubtype.deprecated)
    }

    public func getDatasubtypes(): Set<ValidIdentifiers_Datasubtype> {
        return EnumSet.copyOf(datasubtypes)
    }

    static var SEPARATOR = Pattern.compile("[-_]")

    private static let VALID_X = Pattern.compile("[a-zA-Z0-9]{2,8}(-[a-zA-Z0-9]{2,8})*")

    public func isValid(locale: ULocale, `where`: LocaleValidityChecker_Where): Bool {
        `where`.set(None, None)
        let language = locale.getLanguage()
        let script = locale.getScript()
        let region = locale.getCountry()
        let variantString = locale.getVariant()
        let extensionKeys = locale.getExtensionKeys()
        if (!isValid(ValidIdentifiers_Datatype.language, language, `where`)) {
            if (language == "x") {
                `where`.set(None, None)
                return true
            }
            return false
        }
        if (!isValid(ValidIdentifiers_Datatype.script, script, `where`)) {
            return false
        }
        if (!isValid(ValidIdentifiers_Datatype.region, region, `where`)) {
            return false
        }
        if (!variantString.isEmpty()) {
            for (variant in SEPARATOR.split(variantString)) {
                if (!isValid(ValidIdentifiers_Datatype.variant, variant, `where`)) {
                    return false
                }
            }
        }
        for (c in extensionKeys) {
            try {
                let datatype = ValidIdentifiers_Datatype.valueOf(toString(c) + "")
                match (datatype) {
                    case ValidIdentifiers_Datatype.x => return true
                    case ValidIdentifiers_Datatype.t | ValidIdentifiers_Datatype.u => if (!isValidU(locale, datatype, locale.getExtension(c.charValue()), `where`)) {
                        return false
                    }
                    case _ => ()
                }
            } catch (e: Exception) {
                return `where`.set(ValidIdentifiers_Datatype.illegal, toString(c) + "")
            }
        }
        return true
    }

    private func isValidU(locale: ULocale, datatype: ValidIdentifiers_Datatype, extensionString: String, `where`: LocaleValidityChecker_Where): Bool {
        var key: String = ""
        var typeCount = 0
        var valueType: KeyTypeData_ValueType
        var specialCase: LocaleValidityChecker_SpecialCase
        let prefix = StringBuilder()
        let seen: Set<String> = HashSet<String>()
        var tBuffer: StringBuilder = if (refEq(datatype, ValidIdentifiers_Datatype.t)) { StringBuilder() } else { None }
        for (subtag in SEPARATOR.split(extensionString)) {
            if (Int32(subtag.size) == 2 && (tBuffer.isNone() || Char(subtag[1]) <= '9')) {
                if (tBuffer.isSome()) {
                    if (Int32(tBuffer.size) != 0 && !isValidLocale(tBuffer.toString(), `where`)) {
                        return false
                    }
                    tBuffer = None
                }
                key = KeyTypeData.toBcpKey(subtag)
                if (key.isNone()) {
                    return `where`.set(datatype, subtag)
                }
                if (!allowsDeprecated && KeyTypeData.isDeprecated(key)) {
                    return `where`.set(datatype, key)
                }
                valueType = KeyTypeData.getValueType(key)
                specialCase = LocaleValidityChecker_SpecialCase.get(key)
                typeCount = 0
            } else if (tBuffer.isSome()) {
                if (Int32(tBuffer.size) != 0) {
                    tBuffer.append('-')
                }
                tBuffer.append(subtag)
            } else {
                typeCount++
                match (valueType) {
                    case KeyTypeData_ValueType.single => if (typeCount > 1) {
                        return `where`.set(datatype, (key) + "-" + (subtag))
                    }
                    case KeyTypeData_ValueType.incremental => if (typeCount == 1) {
                        prefix.setLength(0)
                        prefix.append(subtag)
                    } else {
                        prefix.append('-').append(subtag)
                        subtag = prefix.toString()
                    }
                    case KeyTypeData_ValueType.multiple => if (typeCount == 1) {
                        seen.clear()
                    }
                    case _ => ()
                }
                match (specialCase) {
                    case LocaleValidityChecker_SpecialCase.anything => continue
                    case LocaleValidityChecker_SpecialCase.codepoints =>
                        try {
                            if (parse<Int32>(subtag, 16) > 1114111) {
                                return `where`.set(datatype, (key) + "-" + (subtag))
                            }
                        } catch (e: TimeParseException) {
                            return `where`.set(datatype, (key) + "-" + (subtag))
                        }
                        continue
                    case LocaleValidityChecker_SpecialCase.reorder =>
                        let newlyAdded = seen.put(if (subtag == "zzzz") { "others" } else { subtag })
                        if (!newlyAdded || !isScriptReorder(subtag)) {
                            return `where`.set(datatype, (key) + "-" + (subtag))
                        }
                        continue
                    case LocaleValidityChecker_SpecialCase.subdivision =>
                        if (!isSubdivision(locale, subtag)) {
                            return `where`.set(datatype, (key) + "-" + (subtag))
                        }
                        continue
                    case LocaleValidityChecker_SpecialCase.rgKey =>
                        if (Int32(subtag.size) < 6 || !subtag.endsWith("zzzz")) {
                            return `where`.set(datatype, subtag)
                        }
                        if (!isValid(ValidIdentifiers_Datatype.region, subtag[0..Int64(Int32(subtag.size) - 4)], `where`)) {
                            return false
                        }
                        continue
                    case _ => ()
                }
                let isKnownKey = Output<Bool>()
                let isSpecialType = Output<Bool>()
                let Type = KeyTypeData.toBcpType(key, subtag, isKnownKey, isSpecialType)
                if (Type.isNone()) {
                    return `where`.set(datatype, (key) + "-" + (subtag))
                }
                if (!allowsDeprecated && KeyTypeData.isDeprecated(key, subtag)) {
                    return `where`.set(datatype, (key) + "-" + (subtag))
                }
            }
        }
        if (tBuffer.isSome() && Int32(tBuffer.size) != 0 && !isValidLocale(tBuffer.toString(), `where`)) {
            return false
        }
        return true
    }

    private func isSubdivision(locale: ULocale, subtag: String): Bool {
        if (Int32(subtag.size) < 3) {
            return false
        }
        let region: String = subtag[0..if (Char(subtag[0]) <= '9') { 3 } else { 2 }]
        let subdivision: String = subtag[region.size..]
        if (ValidIdentifiers.isValid(ValidIdentifiers_Datatype.subdivision, datasubtypes, region, subdivision).isNone()) {
            return false
        }
        var localeRegion = locale.getCountry()
        if (localeRegion.isEmpty()) {
            let max = ULocale.addLikelySubtags(locale)
            localeRegion = max.getCountry()
        }
        if (!region.equalsIgnoreCase(localeRegion)) {
            return false
        }
        return true
    }

    static let REORDERING_INCLUDE: Set<String> = // Мapping is present but failed: HashSet<String>(ArrayList<String>(["space", "punct", "symbol", "currency", "digit", "others", "zzzz"]))

    static let REORDERING_EXCLUDE: Set<String> = // Мapping is present but failed: HashSet<String>(ArrayList<String>(["zinh", "zyyy"]))

    static let REGULAR_ONLY = EnumSet.of(ValidIdentifiers_Datasubtype.regular)

    private func isScriptReorder(subtag: String): Bool {
        var tempsubtag = subtag
        tempsubtag = AsciiUtil.toLowerString(tempsubtag)
        if (REORDERING_INCLUDE.contains(tempsubtag)) {
            return true
        } else if (REORDERING_EXCLUDE.contains(tempsubtag)) {
            return false
        }
        return ValidIdentifiers.isValid(ValidIdentifiers_Datatype.script, REGULAR_ONLY, tempsubtag).isSome()
    }

    private func isValidLocale(extensionString: String, `where`: LocaleValidityChecker_Where): Bool {
        try {
            let locale = ULocale_Builder().setLanguageTag(extensionString).build()
            return isValid(locale, `where`)
        } catch (e: IllformedLocaleException) {
            let startIndex = e.getErrorIndex()
            let list = SEPARATOR.split(extensionString[Int64(startIndex)..])
            return `where`.set(ValidIdentifiers_Datatype.t, list[0])
        } catch (e: Exception) {
            return `where`.set(ValidIdentifiers_Datatype.t, e.message)
        }
    }

    private func isValid(datatype: ValidIdentifiers_Datatype, code: String, `where`: LocaleValidityChecker_Where): Bool {
        if (code.isEmpty()) {
            return true
        }
        if (refEq(datatype, ValidIdentifiers_Datatype.variant) && "posix".equalsIgnoreCase(code)) {
            return true
        }
        return if (ValidIdentifiers.isValid(datatype, datasubtypes, code).isSome()) { true } else { (if (`where`.isNone()) { false } else { `where`.set(datatype, code) }) }
    }
}


public class LocaleValidityChecker_Where {

    public var fieldFailure: ValidIdentifiers_Datatype

    public var codeFailure: String

    public func set(datatype: ValidIdentifiers_Datatype, code: String): Bool {
        fieldFailure = datatype
        codeFailure = code
        return false
    }

    public override func toString(): String {
        return if (fieldFailure.isNone()) { "OK" } else { "{" + fieldFailure.asString() + ", " + (codeFailure) + "}" }
    }
}


class LocaleValidityChecker_SpecialCase <: Enum<LocaleValidityChecker_SpecialCase> {
    public static let normal = LocaleValidityChecker_SpecialCase("normal", 0)

    public static let anything = LocaleValidityChecker_SpecialCase("anything", 1)

    public static let reorder = LocaleValidityChecker_SpecialCase("reorder", 2)

    public static let codepoints = LocaleValidityChecker_SpecialCase("codepoints", 3)

    public static let subdivision = LocaleValidityChecker_SpecialCase("subdivision", 4)

    public static let rgKey = LocaleValidityChecker_SpecialCase("rgKey", 5)

    private static func _values(): Array<LocaleValidityChecker_SpecialCase> {
        return [LocaleValidityChecker_SpecialCase.normal, LocaleValidityChecker_SpecialCase.anything, LocaleValidityChecker_SpecialCase.reorder, LocaleValidityChecker_SpecialCase.codepoints, LocaleValidityChecker_SpecialCase.subdivision, LocaleValidityChecker_SpecialCase.rgKey]
    }

    private static let _VALUES = LocaleValidityChecker_SpecialCase._values()

    public static func values(): Array<LocaleValidityChecker_SpecialCase> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): LocaleValidityChecker_SpecialCase {
        return (TypeInfo.of<LocaleValidityChecker_SpecialCase>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as LocaleValidityChecker_SpecialCase
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    static func get(key: String): LocaleValidityChecker_SpecialCase {
        if (key == "kr") {
            return reorder
        } else if (key == "vt") {
            return codepoints
        } else if (key == "sd") {
            return subdivision
        } else if (key == "rg") {
            return rgKey
        } else if (key == "x0") {
            return anything
        } else {
            return normal
        }
    }
}
