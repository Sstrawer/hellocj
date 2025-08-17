package icu4cj.impl.personname


class PersonNamePattern {
    private var patternText: String

    private var patternElements: Array<PersonNamePattern_Element>

    public static func makePatterns(patternText: Array<String>, formatterImpl: PersonNameFormatterImpl): Array<PersonNamePattern> {
        let result = Array<PersonNamePattern>(patternText.size)
        var i = 0
        while (i < Int32(patternText.size)) {
            result[Int64(i)] = PersonNamePattern(patternText[Int64(i)], formatterImpl)
            i++
        }
        return result
    }

    public override func toString(): String {
        return patternText
    }

    private init(patternText: String, formatterImpl: PersonNameFormatterImpl) {
        this.patternText = patternText
        let elements = ArrayList<PersonNamePattern_Element>()
        var inField = false
        var inEscape = false
        var workingString: StringBuilder = StringBuilder()
        var i = 0
        while (i < Int32(patternText.size)) {
            let c = Char(patternText[Int64(i)])
            if (inEscape) {
                workingString.append(c)
                inEscape = false
            } else {
                match (c) {
                    case '\'' => inEscape = true
                    case '{' => if (!inField) {
                        if (Int32(workingString.size) > 0) {
                            elements.append(PersonNamePattern_LiteralText(workingString.toString()))
                            workingString = StringBuilder()
                        }
                        inField = true
                    } else {
                        throw IllegalArgumentException("Nested braces are not allowed in name patterns")
                    }
                    case '}' => if (inField) {
                        if (Int32(workingString.size) > 0) {
                            elements.append(PersonNamePattern_NameFieldImpl(workingString.toString(), formatterImpl))
                            workingString = StringBuilder()
                        } else {
                            throw IllegalArgumentException("No field name inside braces")
                        }
                        inField = false
                    } else {
                        throw IllegalArgumentException("Unmatched closing brace in literal text")
                    }
                    case _ => workingString.append(c)
                }
            }
            i++
        }
        if (Int32(workingString.size) > 0) {
            elements.append(PersonNamePattern_LiteralText(workingString.toString()))
        }
        this.patternElements = elements.toArray(Array<PersonNamePattern_Element>(0))
    }

    public func format(name: PersonName): String {
        var tempname = name
        let result = StringBuilder()
        var seenLeadingField = false
        var seenEmptyLeadingField = false
        var seenEmptyField = false
        let textBefore = StringBuilder()
        let textAfter = StringBuilder()
        tempname = hackNameForEmptyFields(tempname)
        for (element in patternElements) {
            if (element.isLiteral()) {
                if (seenEmptyLeadingField) { } else if (seenEmptyField) {
                    textAfter.append(element.format(tempname))
                } else {
                    textBefore.append(element.format(tempname))
                }
            } else {
                let fieldText = element.format(tempname)
                if (fieldText.isNone() || fieldText.isEmpty()) {
                    if (!seenLeadingField) {
                        seenEmptyLeadingField = true
                        textBefore.setLength(0)
                    } else {
                        seenEmptyField = true
                        textAfter.setLength(0)
                    }
                } else {
                    seenLeadingField = true
                    seenEmptyLeadingField = false
                    if (seenEmptyField) {
                        result.append(coalesce(textBefore, textAfter))
                        result.append(fieldText)
                        seenEmptyField = false
                    } else {
                        result.append(textBefore)
                        textBefore.setLength(0)
                        result.append(element.format(tempname))
                    }
                }
            }
        }
        if (!seenEmptyField) {
            result.append(textBefore)
        }
        return result.toString()
    }

    public func numPopulatedFields(name: PersonName): Int32 {
        var result = 0
        for (element in patternElements) {
            result += if (element.isPopulated(name)) { 1 } else { 0 }
        }
        return result
    }

    public func numEmptyFields(name: PersonName): Int32 {
        var result = 0
        for (element in patternElements) {
            result += if (!element.isLiteral() && !element.isPopulated(name)) { 1 } else { 0 }
        }
        return result
    }

    private func coalesce(s1: StringBuilder, s2: StringBuilder): String {
        if (endsWith(s1, s2)) {
            s2.setLength(0)
        }
        var p1 = 0
        while (p1 < Int32(s1.size) && !s1.get(Int64(p1)).isWhiteSpace()) {
            p1++
        }
        var p2 = Int32(s2.size) - 1
        while (p2 >= 0 && !s2.get(Int64(p2)).isWhiteSpace()) {
            p2--
        }
        if (p1 < Int32(s1.size)) {
            p1++
        } else if (p2 >= 0) {
            p2--
        }
        let result: String = (s1.substring(0, p1)) + (s2.substring(p2 + 1))
        s1.setLength(0)
        s2.setLength(0)
        return result
    }

    private func endsWith(s1: StringBuilder, s2: StringBuilder): Bool {
        var p1 = Int32(s1.size) - 1
        var p2 = Int32(s2.size) - 1
        while (p1 >= 0 && p2 >= 0 && s1.get(Int64(p1)) == s2.get(Int64(p2))) {
            p1--
            p2--
        }
        return p2 < 0
    }

    private func hackNameForEmptyFields(originalName: PersonName): PersonName {
        let result = originalName
        if (originalName.getFieldValue(PersonName_NameField.SURNAME, Collections.emptySet<PersonName_FieldModifier>()).isNone()) {
            var patternHasNonInitialGivenName = false
            for (element in patternElements) {
                if (!element.isLiteral() && refEq(element.fieldID, PersonName_NameField.GIVEN) && !element.modifiers.contains(PersonName_FieldModifier.INITIAL)) {
                    patternHasNonInitialGivenName = true
                    break
                }
            }
            if (!patternHasNonInitialGivenName) {
                return PersonNamePattern_GivenToSurnamePersonName(originalName)
            }
        }
        return result
    }
}


interface PersonNamePattern_Element {
    func isLiteral(): Bool

    func format(name: PersonName): String

    func isPopulated(name: PersonName): Bool
}

class PersonNamePattern_LiteralText <: PersonNamePattern_Element {
    private var text: String

    public init(text: String) {
        this.text = text
    }

    public override func toString(): String {
        return text
    }

    public override func isLiteral(): Bool {
        return true
    }

    public override func format(name: PersonName): String {
        return text
    }

    public override func isPopulated(name: PersonName): Bool {
        return false
    }
}


class PersonNamePattern_NameFieldImpl <: PersonNamePattern_Element {
    var fieldID: PersonName_NameField

    var modifiers: Map<PersonName_FieldModifier, FieldModifierImpl> = None

    public init(fieldNameAndModifiers: String, formatterImpl: PersonNameFormatterImpl) {
        let modifierIDs = ArrayList<PersonName_FieldModifier>()
        let tok = StringTokenizer(fieldNameAndModifiers, "-")
        this.fieldID = PersonName_NameField.forString(tok.nextToken())
        while (tok.hasMoreTokens()) {
            modifierIDs.append(PersonName_FieldModifier.forString(tok.nextToken()))
        }
        if (refEq(this.fieldID, PersonName_NameField.SURNAME) && formatterImpl.shouldCapitalizeSurname()) {
            modifierIDs.append(PersonName_FieldModifier.ALL_CAPS)
        }
        this.modifiers = HashMap<PersonName_FieldModifier, FieldModifierImpl>()
        for (modifierID in modifierIDs) {
            this.modifiers.put(modifierID, FieldModifierImpl.forName(modifierID, formatterImpl))
        }
        if (this.modifiers.contains(PersonName_FieldModifier.RETAIN) && this.modifiers.contains(PersonName_FieldModifier.INITIAL)) {
            let initialModifier = this.modifiers.get(PersonName_FieldModifier.INITIAL)
            initialModifier.setRetainPunctuation(true)
        }
    }

    public override func toString(): String {
        let sb = StringBuilder()
        sb.append("{")
        sb.append(fieldID.asString())
        for (modifier in SetCollectionView<PersonName_FieldModifier>(modifiers.keys())) {
            sb.append("-")
            sb.append(modifier.toString())
        }
        sb.append("}")
        return sb.toString()
    }

    public override func isLiteral(): Bool {
        return false
    }

    public override func format(name: PersonName): String {
        let modifierIDs: Set<PersonName_FieldModifier> = HashSet<PersonName_FieldModifier>(modifiers.keys())
        var result = name.getFieldValue(fieldID, modifierIDs)
        if (result.isSome()) {
            for (modifierID in modifierIDs) {
                result = modifiers.get(modifierID).modifyField(result)
            }
        }
        return result
    }

    public override func isPopulated(name: PersonName): Bool {
        let result = this.format(name)
        return result.isSome() && !result.isEmpty()
    }
}


class PersonNamePattern_GivenToSurnamePersonName <: PersonName {
    private var underlyingPersonName: PersonName

    public init(underlyingPersonName: PersonName) {
        this.underlyingPersonName = underlyingPersonName
    }

    public override func toString(): String {
        return "Inverted version of " + toString(underlyingPersonName)
    }

    public override func getNameLocale(): Locale {
        return underlyingPersonName.getNameLocale()
    }

    public override func getPreferredOrder(): PersonName_PreferredOrder {
        return underlyingPersonName.getPreferredOrder()
    }

    public override func getFieldValue(identifier: PersonName_NameField, modifiers: Set<PersonName_FieldModifier>): String {
        if (refEq(identifier, PersonName_NameField.SURNAME)) {
            return underlyingPersonName.getFieldValue(PersonName_NameField.GIVEN, modifiers)
        } else if (refEq(identifier, PersonName_NameField.GIVEN)) {
            return None
        } else {
            return underlyingPersonName.getFieldValue(identifier, modifiers)
        }
    }
}
