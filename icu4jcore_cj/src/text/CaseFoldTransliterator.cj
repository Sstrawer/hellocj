package icu4cj.text

class CaseFoldTransliterator <: Transliterator & Synchronizable {
    private let GeneratedLockObject = Monitor()

    public override func getMonitor(): Monitor { return GeneratedLockObject }

    static let _ID = "Any-CaseFold"

    static func register(): Unit {
        Transliterator.registerFactory(_ID, CaseFoldTransliterator_1())
        Transliterator.registerSpecialInverse("CaseFold", "Upper", false)
    }

    private let csp: UCaseProps

    private var iter: ReplaceableContextIterator

    private var result: StringBuilder

    public init() {
        super(_ID, None)
        csp = UCaseProps.INSTANCE
        iter = ReplaceableContextIterator()
        result = StringBuilder()
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
                c = csp.toFullFolding(c, result, 0)
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

    static var sourceTargetUtility: SourceTargetUtility

    public override func addSourceTargetSet(inputFilter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        synchronized (getMonitorByObject(TypeInfo.of<UppercaseTransliterator>())) {
            if (sourceTargetUtility.isNone()) {
                sourceTargetUtility = SourceTargetUtility(CaseFoldTransliterator_2(this))
            }
        }
        sourceTargetUtility.addSourceTargetSet(this, inputFilter, sourceSet, targetSet)
    }
}


class CaseFoldTransliterator_1 <: Transliterator_Factory {

    public override func getInstance(ID: String): Transliterator {
        return CaseFoldTransliterator()
    }
}


class CaseFoldTransliterator_2 <: Transform<String, String> {
    init(this_0: CaseFoldTransliterator) { }

    public override func transform(source: String): String {
        return UCharacter.foldCase(source, true)
    }
}
