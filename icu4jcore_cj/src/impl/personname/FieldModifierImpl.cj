package icu4cj.impl.personname


abstract class FieldModifierImpl {

    public func modifyField(fieldValue: String): String

    public static func forName(modifierID: PersonName_FieldModifier, formatterImpl: PersonNameFormatterImpl): FieldModifierImpl {
        match (modifierID) {
            case PersonName_FieldModifier.INFORMAL => return NOOP_MODIFIER
            case PersonName_FieldModifier.PREFIX => return NULL_MODIFIER
            case PersonName_FieldModifier.CORE => return NOOP_MODIFIER
            case PersonName_FieldModifier.ALL_CAPS => return FieldModifierImpl_AllCapsModifier(formatterImpl.getLocale())
            case PersonName_FieldModifier.INITIAL_CAP => return FieldModifierImpl_InitialCapModifier(formatterImpl.getLocale())
            case PersonName_FieldModifier.INITIAL => return FieldModifierImpl_InitialModifier(formatterImpl.getLocale(), formatterImpl.getInitialPattern(), formatterImpl.getInitialSequencePattern())
            case PersonName_FieldModifier.RETAIN => return NOOP_MODIFIER
            case PersonName_FieldModifier.MONOGRAM => return MONOGRAM_MODIFIER
            case PersonName_FieldModifier.GENITIVE => return NOOP_MODIFIER
            case PersonName_FieldModifier.VOCATIVE => return NOOP_MODIFIER
            case _ => throw IllegalArgumentException("Invalid modifier ID " + modifierID.asString())
        }
    }

    private static let NOOP_MODIFIER: FieldModifierImpl = FieldModifierImpl_1()

    private static let NULL_MODIFIER: FieldModifierImpl = FieldModifierImpl_2()

    private static let MONOGRAM_MODIFIER: FieldModifierImpl = FieldModifierImpl_3()

    static func getFirstGrapheme(s: String): String {
        if (s.isEmpty()) {
            return ""
        }
        let bi = BreakIterator.getCharacterInstance(Locale.ROOT)
        bi.setText(s)
        return s[0..Int64(bi.next())]
    }
}


class FieldModifierImpl_1 <: FieldModifierImpl {
    init() {
        super()
    }

    public override func modifyField(fieldValue: String): String {
        return fieldValue
    }
}


class FieldModifierImpl_2 <: FieldModifierImpl {
    init() {
        super()
    }

    public override func modifyField(fieldValue: String): String {
        return ""
    }
}


class FieldModifierImpl_AllCapsModifier <: FieldModifierImpl {
    private let locale: Locale

    public init(locale: Locale) {
        super()
        this.locale = locale
    }

    public override func modifyField(fieldValue: String): String {
        return UCharacter.toUpperCase(locale, fieldValue)
    }
}


class FieldModifierImpl_InitialCapModifier <: FieldModifierImpl {
    private let locale: Locale

    private static let TO_TITLE_WHOLE_STRING_NO_LOWERCASE = CaseMap.toTitle().wholeString().noLowercase()

    public init(locale: Locale) {
        super()
        this.locale = locale
    }

    public override func modifyField(fieldValue: String): String {
        return TO_TITLE_WHOLE_STRING_NO_LOWERCASE.apply(locale, None, fieldValue)
    }
}


class FieldModifierImpl_InitialModifier <: FieldModifierImpl {
    private let locale: Locale

    private let initialFormatter: SimpleFormatter

    private let initialSequenceFormatter: SimpleFormatter

    private var retainPunctuation: Bool = false

    public init(locale: Locale, initialPattern: String, initialSequencePattern: String) {
        super()
        this.locale = locale
        this.initialFormatter = SimpleFormatter.compile(initialPattern)
        this.initialSequenceFormatter = SimpleFormatter.compile(initialSequencePattern)
        this.retainPunctuation = false
    }

    public func setRetainPunctuation(retain: Bool): Unit {
        this.retainPunctuation = retain
    }

    public override func modifyField(fieldValue: String): String {
        var separator: String = ""
        var result: String
        let bi = BreakIterator.getWordInstance(locale)
        bi.setText(fieldValue)
        var wordStart = bi.first()
        var wordEnd = bi.next()
        while (wordEnd != BreakIterator.DONE) {
            let word: String = fieldValue[Int64(wordStart)..Int64(wordEnd)]
            if ((Char(word[0])).isLetter()) {
                let curInitial = FieldModifierImpl.getFirstGrapheme(word)
                if (result.isNone()) {
                    result = initialFormatter.format([curInitial])
                } else if (retainPunctuation) {
                    result = (result) + (separator) + (initialFormatter.format([curInitial]))
                    separator = ""
                } else {
                    result = initialSequenceFormatter.format([result, initialFormatter.format([curInitial])])
                }
            } else if ((Char(word[0])).isWhiteSpace()) {
                separator = (separator) + (Char(word[0])).toString()
            } else {
                separator = (separator) + (word)
            }
            wordStart = wordEnd
            wordEnd = bi.next()
        }
        return result
    }
}


class FieldModifierImpl_3 <: FieldModifierImpl {
    init() {
        super()
    }

    public override func modifyField(fieldValue: String): String {
        return getFirstGrapheme(fieldValue)
    }
}
