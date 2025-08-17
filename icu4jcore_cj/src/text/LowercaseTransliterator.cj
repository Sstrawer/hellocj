package icu4cj.text


class LowercaseTransliterator <: Transliterator & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    static let _ID = "Any-Lower"

    static func register(): Unit {
        Transliterator.registerFactory(_ID, LowercaseTransliterator_1())
        Transliterator.registerSpecialInverse("Lower", "Upper", true)
    }

    let locale: ULocale

    private let csp: UCaseProps

    private var iter: ReplaceableContextIterator

    private var result: StringBuilder

    private var caseLocale: Int32 = 0

    public init(loc: ULocale) {
        super(_ID, None)
        locale = loc
        csp = UCaseProps.INSTANCE
        iter = ReplaceableContextIterator()
        result = StringBuilder()
        caseLocale = UCaseProps.getCaseLocale(locale)
    }

    override protected func handleTransliterate(text: Replaceable, offsets: Transliterator_Position, isIncremental: Bool): Unit {
        synchronized (GeneratedLockObject) {
            if (csp.isNone()) {
                return
            }
            if (offsets.start >= offsets.limit) {
                return
            }
            iter.setText(text)
            result.setLength(0)
            var c: Int32 = 0
            var delta: Int32 = 0
            iter.setIndex(offsets.start)
            iter.setLimit(offsets.limit)
            iter.setContextLimits(offsets.contextStart, offsets.contextLimit)
            while ((match (0) { case _ => c = iter.nextCaseMapCP(); c }) >= 0) {
                c = csp.toFullLower(c, iter, result, caseLocale)
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
            offsets.start = offsets.limit
        }
    }

    var sourceTargetUtility: SourceTargetUtility

    public override func addSourceTargetSet(inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        synchronized (getMonitorByObject(this)) {
            if (sourceTargetUtility.isNone()) {
                sourceTargetUtility = SourceTargetUtility(LowercaseTransliterator_2(this))
            }
        }
        sourceTargetUtility.addSourceTargetSet(this, inputFilter, sourceSet, targetSet)
    }
}


class LowercaseTransliterator_1 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return LowercaseTransliterator(ULocale.US)
    }
}


class LowercaseTransliterator_2 <: Transform<String, String> {
    let this_0: LowercaseTransliterator

    init(this_0: LowercaseTransliterator) {
        this.this_0 = this_0
    }

    public override func transform(source: String): String {
        return UCharacter.toLowerCase(this_0.locale, source)
    }
}
