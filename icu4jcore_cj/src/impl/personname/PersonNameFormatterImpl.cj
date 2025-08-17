package icu4cj.impl.personname


public class PersonNameFormatterImpl {
    private let locale: Locale

    private let gnFirstPatterns: Array<PersonNamePattern>

    private let snFirstPatterns: Array<PersonNamePattern>

    private let gnFirstLocales: Set<String>

    private let snFirstLocales: Set<String>

    private let initialPattern: String

    private let initialSequencePattern: String

    private let capitalizeSurname: Bool

    private let foreignSpaceReplacement: String

    private let nativeSpaceReplacement: String

    private let length: PersonNameFormatter_Length

    private let usage: PersonNameFormatter_Usage

    private let formality: PersonNameFormatter_Formality

    private let displayOrder: PersonNameFormatter_DisplayOrder

    public init(locale: Locale, length: PersonNameFormatter_Length, usage: PersonNameFormatter_Usage, formality: PersonNameFormatter_Formality, displayOrder: PersonNameFormatter_DisplayOrder, surnameAllCaps: Bool) {
        var tempdisplayOrder = displayOrder
        var tempusage = usage
        this.length = length
        this.usage = tempusage
        this.formality = formality
        this.displayOrder = tempdisplayOrder
        this.capitalizeSurname = surnameAllCaps
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, locale)
        this.locale = locale
        this.initialPattern = rb.getStringWithFallback("personNames/initialPattern/initial")
        this.initialSequencePattern = rb.getStringWithFallback("personNames/initialPattern/initialSequence")
        this.foreignSpaceReplacement = rb.getStringWithFallback("personNames/foreignSpaceReplacement")
        this.nativeSpaceReplacement = rb.getStringWithFallback("personNames/nativeSpaceReplacement")
        if (refEq(tempusage, PersonNameFormatter_Usage.MONOGRAM)) {
            tempdisplayOrder = PersonNameFormatter_DisplayOrder.DEFAULT
        } else if (refEq(tempdisplayOrder, PersonNameFormatter_DisplayOrder.SORTING)) {
            tempusage = PersonNameFormatter_Usage.REFERRING
        }
        let RESOURCE_PATH_PREFIX = "personNames/namePattern/"
        let lengthStr = if (!refEq(length, PersonNameFormatter_Length.DEFAULT)) { Some(length.toString().toLower()) } else { rb.getStringWithFallback("personNames/parameterDefault/length") }
        let formalityStr = if (!refEq(formality, PersonNameFormatter_Formality.DEFAULT)) { Some(formality.toString().toLower()) } else { rb.getStringWithFallback("personNames/parameterDefault/formality") }
        let resourceNameBody: String = (lengthStr) + "-" + tempusage.toString().toLower() + "-" + (formalityStr)
        if (!refEq(tempdisplayOrder, PersonNameFormatter_DisplayOrder.SORTING)) {
            let gnFirstResource = rb.getWithFallback(RESOURCE_PATH_PREFIX + "givenFirst-" + (resourceNameBody))
            let snFirstResource = rb.getWithFallback(RESOURCE_PATH_PREFIX + "surnameFirst-" + (resourceNameBody))
            gnFirstPatterns = PersonNamePattern.makePatterns(asStringArray(gnFirstResource), this)
            snFirstPatterns = PersonNamePattern.makePatterns(asStringArray(snFirstResource), this)
            gnFirstLocales = HashSet<String>()
            Collections.addAll(gnFirstLocales, asStringArray(rb.getWithFallback("personNames/nameOrderLocales/givenFirst")))
            snFirstLocales = HashSet<String>()
            Collections.addAll(snFirstLocales, asStringArray(rb.getWithFallback("personNames/nameOrderLocales/surnameFirst")))
        } else {
            let patternResource = rb.getWithFallback(RESOURCE_PATH_PREFIX + "sorting-" + (resourceNameBody))
            gnFirstPatterns = PersonNamePattern.makePatterns(asStringArray(patternResource), this)
            snFirstPatterns = None
            gnFirstLocales = None
            snFirstLocales = None
        }
    }

    public init(locale: Locale, gnFirstPatterns: Array<String>, snFirstPatterns: Array<String>, gnFirstLocales: Array<String>, snFirstLocales: Array<String>) {
        length = PersonNameFormatter_Length.MEDIUM
        usage = PersonNameFormatter_Usage.REFERRING
        formality = PersonNameFormatter_Formality.FORMAL
        displayOrder = PersonNameFormatter_DisplayOrder.DEFAULT
        initialPattern = "{0}."
        initialSequencePattern = "{0} {1}"
        capitalizeSurname = false
        foreignSpaceReplacement = " "
        nativeSpaceReplacement = " "
        this.locale = locale
        this.gnFirstPatterns = PersonNamePattern.makePatterns(gnFirstPatterns, this)
        this.snFirstPatterns = if (snFirstPatterns.isSome()) { PersonNamePattern.makePatterns(snFirstPatterns, this) } else { None }
        if (gnFirstLocales.isSome()) {
            this.gnFirstLocales = HashSet<String>()
            Collections.addAll(this.gnFirstLocales, gnFirstLocales)
        } else {
            this.gnFirstLocales = None
        }
        if (snFirstLocales.isSome()) {
            this.snFirstLocales = HashSet<String>()
            Collections.addAll(this.snFirstLocales, snFirstLocales)
        } else {
            this.snFirstLocales = None
        }
    }

    public override func toString(): String {
        return "PersonNameFormatter: " + displayOrder.asString() + "-" + length.asString() + "-" + usage.asString() + "-" + formality.asString() + ", " + toString(locale)
    }

    public func formatToString(name: PersonName): String {
        let nameLocale = getNameLocale(name)
        let nameScript = getNameScript(name)
        if (!nameScriptMatchesLocale(nameScript, this.locale)) {
            let newFormattingLocale: Locale
            if (formattingLocaleExists(nameLocale)) {
                newFormattingLocale = nameLocale
            } else {
                newFormattingLocale = newLocaleWithScript(None, nameScript, nameLocale.getCountry())
            }
            let nameLocaleFormatter = PersonNameFormatterImpl(newFormattingLocale, this.length, this.usage, this.formality, this.displayOrder, this.capitalizeSurname)
            return nameLocaleFormatter.formatToString(name)
        }
        var result: String
        if (snFirstPatterns.isNone() || nameIsGnFirst(name)) {
            result = getBestPattern(gnFirstPatterns, name).format(name)
        } else {
            result = getBestPattern(snFirstPatterns, name).format(name)
        }
        if (!(nativeSpaceReplacement == " ") || !(foreignSpaceReplacement == " ")) {
            if (localesMatch(nameLocale, this.locale)) {
                result = result.replace(" ", nativeSpaceReplacement)
            } else {
                result = result.replace(" ", foreignSpaceReplacement)
            }
        }
        return result
    }

    public func getLocale(): Locale {
        return locale
    }

    public func getLength(): PersonNameFormatter_Length {
        return length
    }

    public func getUsage(): PersonNameFormatter_Usage {
        return usage
    }

    public func getFormality(): PersonNameFormatter_Formality {
        return formality
    }

    public func getDisplayOrder(): PersonNameFormatter_DisplayOrder {
        return displayOrder
    }

    public func getSurnameAllCaps(): Bool {
        return capitalizeSurname
    }

    public func getInitialPattern(): String {
        return initialPattern
    }

    public func getInitialSequencePattern(): String {
        return initialSequencePattern
    }

    public func shouldCapitalizeSurname(): Bool {
        return capitalizeSurname
    }

    static let NON_DEFAULT_SCRIPTS: Set<String> = // Мapping is present but failed: HashSet<String>(ArrayList<String>(["Hani", "Hira", "Kana"]))

    private func asStringArray(resource: ICUResourceBundle): Array<String> {
        if (resource.getType() == UResourceBundle.STRING) {
            return [resource.getString()]
        } else if (resource.getType() == UResourceBundle.ARRAY) {
            return resource.getStringArray()
        } else {
            throw Exception("Unsupported resource type " + resource.getType().toString())
        }
    }

    private func nameIsGnFirst(name: PersonName): Bool {
        if (refEq(this.displayOrder, PersonNameFormatter_DisplayOrder.FORCE_GIVEN_FIRST)) {
            return true
        } else if (refEq(this.displayOrder, PersonNameFormatter_DisplayOrder.FORCE_SURNAME_FIRST)) {
            return false
        }
        if (refEq(name.getPreferredOrder(), PersonName_PreferredOrder.GIVEN_FIRST)) {
            return true
        } else if (refEq(name.getPreferredOrder(), PersonName_PreferredOrder.SURNAME_FIRST)) {
            return false
        }
        var nameLocale = name.getNameLocale()
        if (nameLocale.isNone()) {
            nameLocale = getNameLocale(name)
        }
        var nameULocale = ULocale.forLocale(nameLocale)
        if (NON_DEFAULT_SCRIPTS.contains(nameULocale.getScript())) {
            let builder = ULocale_Builder()
            builder.setLocale(nameULocale)
            builder.setScript(None)
            nameULocale = ULocale.addLikelySubtags(builder.build())
        }
        var localeStr = nameULocale.getName()
        let origLocaleStr = localeStr
        let languageCode = nameULocale.getLanguage()
                return false
            }
            let undStr = localeStr.replaceAll("^" + (languageCode), "und")
            if (gnFirstLocales.contains(undStr)) {
                return true
            } else if (snFirstLocales.contains(undStr)) {
                return false
            }
            let parentLocaleStr = ICUResourceBundle.getParentLocaleID(localeStr, origLocaleStr, ICUResourceBundle_OpenType.LOCALE_DEFAULT_ROOT)
            localeStr = if (parentLocaleStr.isSome()) { parentLocaleStr } else { languageCode }
        // End of do-while loop
        return true
    }

    private func getBestPattern(patterns: Array<PersonNamePattern>, name: PersonName): PersonNamePattern {
        if (Int32(patterns.size) == 1) {
            return patterns[0]
        } else {
            var maxPopulatedFields = 0
            var minEmptyFields = Int32.Max
            var bestPattern: PersonNamePattern
            for (pattern in patterns) {
                let populatedFields = pattern.numPopulatedFields(name)
                let emptyFields = pattern.numEmptyFields(name)
                if (populatedFields > maxPopulatedFields) {
                    maxPopulatedFields = populatedFields
                    minEmptyFields = emptyFields
                    bestPattern = pattern
                } else if (populatedFields == maxPopulatedFields && emptyFields < minEmptyFields) {
                    minEmptyFields = emptyFields
                    bestPattern = pattern
                }
            }
            return bestPattern
        }
    }

    private func getNameScript(name: PersonName): String {
        let givenName = name.getFieldValue(PersonName_NameField.SURNAME, Collections.emptySet<PersonName_FieldModifier>())
        let surname = name.getFieldValue(PersonName_NameField.GIVEN, Collections.emptySet<PersonName_FieldModifier>())
        let nameText: String = (if (surname.isSome()) { surname } else { "" }) + (if (givenName.isSome()) { givenName } else { "" })
        var stringScript = UScript.UNKNOWN
        var i = 0
        while (stringScript == UScript.UNKNOWN && i < Int32(nameText.size)) {
            let c = nameText.codePointAt(i)
            let charScript = UScript.getScript(c)
            if (charScript != UScript.COMMON && charScript != UScript.INHERITED && charScript != UScript.UNKNOWN) {
                stringScript = charScript
            }
            i++
        }
        return UScript.getShortName(stringScript)
    }

    private func newLocaleWithScript(oldLocale: Locale, scriptCode: String, regionCode: String): Locale {
        var tempscriptCode = scriptCode
        let workingLocale: Locale
        let localeScript: String
        if (tempscriptCode == "Zzzz") {
            return oldLocale
        }
        let builder = Locale_Builder()
        if (oldLocale.isSome()) {
            workingLocale = oldLocale
            builder.setLocale(oldLocale)
            localeScript = ULocale.addLikelySubtags(ULocale.forLocale(oldLocale)).getScript()
        } else {
            let tmpLocale = ULocale.addLikelySubtags(ULocale("und_" + (tempscriptCode)))
            builder.setLanguage(tmpLocale.getLanguage())
            workingLocale = ULocale.addLikelySubtags(ULocale(tmpLocale.getLanguage())).toLocale()
            localeScript = workingLocale.getScript()
            if (regionCode.isSome()) {
                builder.setRegion(regionCode)
            }
        }
        if (!tempscriptCode.equals(localeScript) && nameScriptMatchesLocale(tempscriptCode, workingLocale)) {
            tempscriptCode = localeScript
        }
        builder.setScript(tempscriptCode)
        return builder.build()
    }

    private func getNameLocale(name: PersonName): Locale {
        return newLocaleWithScript(name.getNameLocale(), getNameScript(name), None)
    }

    private func nameScriptMatchesLocale(nameScriptID: String, formatterLocale: Locale): Bool {
        if (nameScriptID == "Zzzz") {
            return true
        }
        let localeScripts = UScript.getCode(formatterLocale)
        let nameScript = UScript.getCodeFromName(nameScriptID)
        for (localeScript in localeScripts) {
            if (localeScript == nameScript || (localeScript == UScript.SIMPLIFIED_HAN && nameScript == UScript.HAN) || (localeScript == UScript.TRADITIONAL_HAN && nameScript == UScript.HAN)) {
                return true
            }
        }
        return false
    }

    private func formattingLocaleExists(formattingLocale: Locale): Bool {
        let formattingLanguage = formattingLocale.getLanguage()
        let mainRB = ICUResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, ULocale.forLocale(formattingLocale), ICUResourceBundle_OpenType.LOCALE_DEFAULT_ROOT)
        if (!mainRB.getULocale().getLanguage().equals(formattingLanguage)) {
            return false
        }
        let gnFirstResource = mainRB.getWithFallback("personNames/nameOrderLocales/givenFirst")
        let snFirstResource = mainRB.getWithFallback("personNames/nameOrderLocales/surnameFirst")
        return gnFirstResource.getULocale().getLanguage().equals(formattingLanguage) || snFirstResource.getULocale().getLanguage().equals(formattingLanguage)
    }

    private func localesMatch(nameLocale: Locale, formatterLocale: Locale): Bool {
        let nameLanguage = nameLocale.getLanguage()
        let formatterLanguage = formatterLocale.getLanguage()
        if (nameLanguage.equals(formatterLanguage)) {
            return true
        }
        if ((nameLanguage == "ja" || nameLanguage == "zh") && (formatterLanguage == "ja" || formatterLanguage == "zh")) {
            return true
        }
        return false
    }
}
