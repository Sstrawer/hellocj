package icu4cj.text


public abstract class CaseMap {
    
    protected var internalOptions: Int32 = 0

    init(opt: Int32) {
        internalOptions = opt
    }

    static func getCaseLocale(locale: Locale): Int32 {
        var templocale = locale
        if (templocale.isNone()) {
            templocale = Locale.getDefault()
        }
        return UCaseProps.getCaseLocale(templocale)
    }

    public static func toLower(): CaseMap_Lower {
        return CaseMap_Lower.DEFAULT
    }

    public static func toUpper(): CaseMap_Upper {
        return CaseMap_Upper.DEFAULT
    }

    public static func toTitle(): CaseMap_Title {
        return CaseMap_Title.DEFAULT
    }

    public static func fold(): CaseMap_Fold {
        return CaseMap_Fold.DEFAULT
    }

    public func omitUnchangedText(): CaseMap
}


public class CaseMap_Lower <: CaseMap {
    static let DEFAULT = CaseMap_Lower(0)

    private static let OMIT_UNCHANGED = CaseMap_Lower(CaseMapImpl.OMIT_UNCHANGED_TEXT)

    private init(opt: Int32) {
        super(opt)
    }

    public override func omitUnchangedText(): CaseMap_Lower {
        return OMIT_UNCHANGED
    }

    public func apply(locale: Locale, src: String): String {
        return CaseMapImpl.toLower(CaseMap.getCaseLocale(locale), internalOptions, src)
    }

    public func apply<A>(locale: Locale, src: String, dest: A, edits: Edits): A {
        return CaseMapImpl.toLower(getCaseLocale(locale), internalOptions, src, dest, edits)
    }
}


public class CaseMap_Upper <: CaseMap {
    static let DEFAULT = CaseMap_Upper(0)

    private static let OMIT_UNCHANGED = CaseMap_Upper(CaseMapImpl.OMIT_UNCHANGED_TEXT)

    private init(opt: Int32) {
        super(opt)
    }

    public override func omitUnchangedText(): CaseMap_Upper {
        return OMIT_UNCHANGED
    }

    public func apply(locale: Locale, src: String): String {
        return CaseMapImpl.toUpper(getCaseLocale(locale), internalOptions, src)
    }

    public func apply<A>(locale: Locale, src: String, dest: A, edits: Edits): A {
        return CaseMapImpl.toUpper(getCaseLocale(locale), internalOptions, src, dest, edits)
    }
}


public class CaseMap_Title <: CaseMap {
    static let DEFAULT = CaseMap_Title(0)

    private static let OMIT_UNCHANGED = CaseMap_Title(CaseMapImpl.OMIT_UNCHANGED_TEXT)

    private init(opt: Int32) {
        super(opt)
    }

    public func wholeString(): CaseMap_Title {
        return CaseMap_Title(CaseMapImpl.addTitleIteratorOption(internalOptions, CaseMapImpl.TITLECASE_WHOLE_STRING))
    }

    public func sentences(): CaseMap_Title {
        return CaseMap_Title(CaseMapImpl.addTitleIteratorOption(internalOptions, CaseMapImpl.TITLECASE_SENTENCES))
    }

    public override func omitUnchangedText(): CaseMap_Title {
        if (internalOptions == 0 || internalOptions == CaseMapImpl.OMIT_UNCHANGED_TEXT) {
            return OMIT_UNCHANGED
        }
        return CaseMap_Title(internalOptions | CaseMapImpl.OMIT_UNCHANGED_TEXT)
    }

    public func noLowercase(): CaseMap_Title {
        return CaseMap_Title(internalOptions | UCharacter.TITLECASE_NO_LOWERCASE)
    }

    public func noBreakAdjustment(): CaseMap_Title {
        return CaseMap_Title(CaseMapImpl.addTitleAdjustmentOption(internalOptions, UCharacter.TITLECASE_NO_BREAK_ADJUSTMENT))
    }

    public func adjustToCased(): CaseMap_Title {
        return CaseMap_Title(CaseMapImpl.addTitleAdjustmentOption(internalOptions, CaseMapImpl.TITLECASE_ADJUST_TO_CASED))
    }

    public func apply(locale: Locale, iter: BreakIterator, src: String): String {
        var templocale = locale
        var tempiter = iter
        if (tempiter.isNone() && templocale.isNone()) {
            templocale = Locale.getDefault()
        }
        tempiter = CaseMapImpl.getTitleBreakIterator(templocale, internalOptions, tempiter)
        tempiter.setText(src)
        return CaseMapImpl.toTitle(getCaseLocale(templocale), internalOptions, tempiter, src)
    }

    public func apply<A>(locale: Locale, iter: BreakIterator, src: String, dest: A, edits: Edits): A {
        var templocale = locale
        var tempiter = iter
        if (tempiter.isNone() && templocale.isNone()) {
            templocale = Locale.getDefault()
        }
        tempiter = CaseMapImpl.getTitleBreakIterator(templocale, internalOptions, tempiter)
        tempiter.setText(src)
        return CaseMapImpl.toTitle(getCaseLocale(templocale), internalOptions, tempiter, src, dest, edits)
    }
}


public class CaseMap_Fold <: CaseMap {
    static let DEFAULT = CaseMap_Fold(0)

    private static let TURKIC = CaseMap_Fold(UCharacter.FOLD_CASE_EXCLUDE_SPECIAL_I)

    private static let OMIT_UNCHANGED = CaseMap_Fold(CaseMapImpl.OMIT_UNCHANGED_TEXT)

    private static let TURKIC_OMIT_UNCHANGED = CaseMap_Fold(UCharacter.FOLD_CASE_EXCLUDE_SPECIAL_I | CaseMapImpl.OMIT_UNCHANGED_TEXT)

    private init(opt: Int32) {
        super(opt)
    }

    public override func omitUnchangedText(): CaseMap_Fold {
        return if ((internalOptions & UCharacter.FOLD_CASE_EXCLUDE_SPECIAL_I) == 0) { OMIT_UNCHANGED } else { TURKIC_OMIT_UNCHANGED }
    }

    public func turkic(): CaseMap_Fold {
        return if ((internalOptions & CaseMapImpl.OMIT_UNCHANGED_TEXT) == 0) { TURKIC } else { TURKIC_OMIT_UNCHANGED }
    }

    public func apply(src: String): String {
        return CaseMapImpl.fold(internalOptions, src)
    }

    public func apply<A>(src: String, dest: A, edits: Edits): A {
        return CaseMapImpl.fold(internalOptions, src, dest, edits)
    }
}
