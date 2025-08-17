package icu4cj.text



public class RuleBasedTransliterator <: Transliterator {
    private let data: RuleBasedTransliterator_Data

    init(ID: String, data: RuleBasedTransliterator_Data, filter: UnicodeFilter) {
        super(ID, filter)
        this.data = data
        setMaximumContextLength(data.ruleSet.getMaximumContextLength())
    }

    
    override protected func handleTransliterate(text: Replaceable, index: Transliterator_Position, incremental: Bool): Unit {
        synchronized (getMonitorByObject(data)) {
            var loopCount = 0
            var loopLimit = shl((index.limit - index.start), 4)
            if (loopLimit < 0) {
                loopLimit = 2147483647
            }
            while (index.start < index.limit && loopCount <= loopLimit && data.ruleSet.transliterate(text, index, incremental)) {
                loopCount++
            }
        }
    }

    
    public override func toRules(escapeUnprintable: Bool): String {
        return data.ruleSet.toRules(escapeUnprintable)
    }

    
    public override func addSourceTargetSet(filter: UnicodeSet, sourceSet: UnicodeSet, targetSet: UnicodeSet): Unit {
        data.ruleSet.addSourceTargetSet(filter, sourceSet, targetSet)
    }

    
    public func safeClone(): Transliterator {
        var filter = getFilter()
        if (filter.isSome() && checkOptionalIs<UnicodeSet, UnicodeFilter>(filter)) {
            filter = UnicodeSet(filter)
        }
        return RuleBasedTransliterator(getID(), data, filter)
    }
}


class RuleBasedTransliterator_Data {
    public init() {
        variableNames = HashMap<String, Array<Char>>()
        ruleSet = TransliterationRuleSet()
    }

    public var ruleSet: TransliterationRuleSet

    var variableNames: Map<String, Array<Char>> = None

    var variables: Array<Object>

    var variablesBase: Char = '\u{0000}'

    public func lookupMatcher(standIn: Int32): UnicodeMatcher {
        let i = standIn - Int32(UInt32(variablesBase))
        return if (i >= 0 && i < Int32(variables.size)) { variables[Int64(i)] } else { None }
    }

    public func lookupReplacer(standIn: Int32): UnicodeReplacer {
        let i = standIn - Int32(UInt32(variablesBase))
        return if (i >= 0 && i < Int32(variables.size)) { variables[Int64(i)] } else { None }
    }
}
