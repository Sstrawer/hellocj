package icu4cj.text

class TitlecaseTransliterator <: Transliterator & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    static let _ID = "Any-Title"

    static func register(): Unit {
        Transliterator.registerFactory(_ID, TitlecaseTransliterator_1())
        registerSpecialInverse("Title", "Lower", false)
    }

    let locale: ULocale

    private let csp: UCaseProps

    private var iter: ReplaceableContextIterator

    private var result: StringBuilder

    private var caseLocale: Int32 = 0

    public init(loc: ULocale) {
        super(_ID, None)
        locale = loc
        setMaximumContextLength(2)
        csp = UCaseProps.INSTANCE
        iter = ReplaceableContextIterator()
        result = StringBuilder()
        caseLocale = UCaseProps.getCaseLocale(locale)
    }

    override protected func handleTransliterate(text: Replaceable, offsets: Transliterator_Position, isIncremental: Bool): Unit {
        synchronized (GeneratedLockObject) {
            if (offsets.start >= offsets.limit) {
                return
            }
            var Type: Int32 = 0
            var doTitle = true
            var c: Int32 = 0
            var start: Int32 = 0
            start = offsets.start - 1
            while (start >= offsets.contextStart) {
                c = text.char32At(start)
                Type = csp.getTypeOrIgnorable(c)
                if (Type > 0) {
                    doTitle = false
                    break
                } else if (Type == 0) {
                    break
                }
                start -= UTF16.getCharCount(c)
            }
            iter.setText(text)
            iter.setIndex(offsets.start)
            iter.setLimit(offsets.limit)
            iter.setContextLimits(offsets.contextStart, offsets.contextLimit)
            result.setLength(0)
            var delta: Int32 = 0
            while ((match (0) { case _ => c = iter.nextCaseMapCP(); c }) >= 0) {
                Type = csp.getTypeOrIgnorable(c)
                if (Type >= 0) {
                    if (doTitle) {
                        c = csp.toFullTitle(c, iter, result, caseLocale)
                    } else {
                        c = csp.toFullLower(c, iter, result, caseLocale)
                    }
                    doTitle = Type == 0
                    if (iter.didReachLimit() && isIncremental) {
                        offsets.start = iter.getCaseMapCPStart()
                        return
                    }
                    if (c < 0) {
                        continue
                    } else if (c <= UCaseProps.MAX_STRING_LENGTH) {
                        delta = iter.replace(result.toString())
                        result.setLength(0)
                    } else {
                        delta = iter.replace(UTF16.valueOf(c))
                    }
                    if (delta != 0) {
                        offsets.limit += delta
                        offsets.contextLimit += delta
                    }
                }
            }
            offsets.start = offsets.limit
        }
    }

    var sourceTargetUtility: SourceTargetUtility

    public override func addSourceTargetSet(inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        synchronized (getMonitorByObject(this)) {
            if (sourceTargetUtility.isNone()) {
                sourceTargetUtility = SourceTargetUtility(TitlecaseTransliterator_2(this))
            }
        }
        sourceTargetUtility.addSourceTargetSet(this, inputFilter, sourceSet, targetSet)
    }
}


class TitlecaseTransliterator_1 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return TitlecaseTransliterator(ULocale.US)
    }
}


class TitlecaseTransliterator_2 <: Transform<String, String> {
    let this_0: TitlecaseTransliterator

    init(this_0: TitlecaseTransliterator) {
        this.this_0 = this_0
    }

    public override func transform(source: String): String {
        return UCharacter.toTitleCase(this_0.locale, source, None)
    }
}
