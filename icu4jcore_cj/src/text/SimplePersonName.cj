package icu4cj.text


public class SimplePersonName <: PersonName {
    public static func builder(): SimplePersonName_Builder {
        return SimplePersonName_Builder()
    }

    init(nameLocale: Locale, preferredOrder: PersonName_PreferredOrder, fieldValues: Map<String, String>) {
        this.nameLocale = nameLocale
        this.preferredOrder = preferredOrder
        this.fieldValues = HashMap<String, String>(fieldValues)
    }

    public override func getNameLocale(): Locale {
        return nameLocale
    }

    public override func getPreferredOrder(): PersonName_PreferredOrder {
        return preferredOrder
    }

    public override func getFieldValue(nameField: PersonName_NameField, modifiers: Set<PersonName_FieldModifier>): String {
        let fieldName: String = nameField.toString()
        var result = fieldValues.get(makeModifiedFieldName(nameField, modifiers))
        if (result.isSome()) {
            modifiers.clear()
            return result
        }
        result = fieldValues.get(fieldName)
        if (result.isNone()) {
            return None
        } else if (Int32(modifiers.size) == 1) {
            return result
        }
        var winningKey = fieldName
        var winningScore = 0
        for (key in SetCollectionView<String>(fieldValues.keys())) {
            if (key.startsWith(fieldName)) {
                let keyModifiers = makeModifiersFromName(key)
                if (modifiers.containsAll(keyModifiers)) {
                    if (Int32(keyModifiers.size) > winningScore || (Int32(keyModifiers.size) == winningScore && key.compare(winningKey).value() < 0)) {
                        winningKey = key
                        winningScore = Int32(keyModifiers.size)
                    }
                }
            }
        }
        result = fieldValues.get(winningKey)
        modifiers.removeAll(makeModifiersFromName(winningKey))
        return result
    }

    
    public override func toString(): String {
        let sb = StringBuilder()
        for (key in SetCollectionView<String>(fieldValues.keys())) {
            if (Int32(sb.size) > 0) {
                sb.append(",")
            }
            sb.append((key) + "=" + fieldValues.get(key).asString())
        }
        sb.append(",locale=" + toString(nameLocale))
        return sb.toString()
    }

    private static func makeModifiedFieldName(fieldName: PersonName_NameField, modifiers: Collection<PersonName_FieldModifier>): String {
        let result = StringBuilder()
        result.append(fieldName.asString())
        let sortedModifierNames = TreeSet()
        for (modifier in modifiers) {
            sortedModifierNames.put(modifier.toString())
        }
        for (modifierName in sortedModifierNames) {
            result.append("-")
            result.append(modifierName)
        }
        return result.toString()
    }

    private static func makeModifiersFromName(modifiedName: String): Set<PersonName_FieldModifier> {
        let tok = StringTokenizer(modifiedName, "-")
        let result: Set<PersonName_FieldModifier> = HashSet<PersonName_FieldModifier>()
        let fieldName = tok.nextToken()
        while (tok.hasMoreTokens()) {
            result.put(PersonName_FieldModifier.forString(tok.nextToken()))
        }
        return result
    }

    private let nameLocale: Locale

    private let preferredOrder: PersonName_PreferredOrder

    private let fieldValues: Map<String, String>
}


public class SimplePersonName_Builder {
    public func setLocale(locale: Locale): SimplePersonName_Builder {
        this.locale = locale
        return this
    }

    public func setPreferredOrder(preferredOrder: PersonName_PreferredOrder): SimplePersonName_Builder {
        this.preferredOrder = preferredOrder
        return this
    }

    public func addField(field: PersonName_NameField, modifiers: Collection<PersonName_FieldModifier>, value: String): SimplePersonName_Builder {
        let modifierNames = TreeSet()
        if (modifiers.isSome()) {
            for (modifier in modifiers) {
                modifierNames.put(modifier.toString())
            }
        }
        let fieldName = StringBuilder()
        fieldName.append(field.toString())
        for (modifierName in modifierNames) {
            fieldName.append("-")
            fieldName.append(modifierName)
        }
        fieldValues.put(fieldName.toString(), value)
        return this
    }

    public func build(): SimplePersonName {
        if (fieldValues.get("surname").isNone()) {
            let surnamePrefix = fieldValues.get("surname-prefix")
            let surnameCore = fieldValues.get("surname-core")
            if (surnamePrefix.isSome() && surnameCore.isSome()) {
                fieldValues.put("surname", (surnamePrefix) + " " + (surnameCore))
            } else if (surnamePrefix.isSome()) {
                fieldValues.put("surname", surnamePrefix)
            } else if (surnameCore.isSome()) {
                fieldValues.put("surname", surnameCore)
            }
        }
        return SimplePersonName(locale, preferredOrder, fieldValues)
    }

    init() {
        locale = None
        preferredOrder = PersonName_PreferredOrder.DEFAULT
        fieldValues = HashMap<String, String>()
    }

    private var locale: Locale = None

    private var preferredOrder: PersonName_PreferredOrder

    private var fieldValues: Map<String, String> = None
}
