package icu4cj.number


public class CompactNotation <: Notation {
    let compactStyle: CompactDecimalFormat_CompactStyle

    let compactCustomData: Map<String, Map<String, String>>

    
    public static func forCustomData(compactCustomData: Map<String, Map<String, String>>): CompactNotation {
        return CompactNotation(compactCustomData)
    }

    init(compactStyle: CompactDecimalFormat_CompactStyle) {
        super()
        compactCustomData = None
        this.compactStyle = compactStyle
    }

    init(compactCustomData: Map<String, Map<String, String>>) {
        super()
        compactStyle = None
        this.compactCustomData = compactCustomData
    }

    public func withLocaleData(locale: ULocale, nsName: String, compactType: CompactData_CompactType, rules: PluralRules, buildReference: MutablePatternModifier, safe: Bool, parent: MicroPropsGenerator): MicroPropsGenerator {
        return CompactNotation_CompactHandler(this, locale, nsName, compactType, rules, buildReference, safe, parent)
    }
}


class CompactNotation_CompactHandler <: MicroPropsGenerator {
    let rules: PluralRules

    let parent: MicroPropsGenerator

    let precomputedMods: Map<String, MutablePatternModifier_ImmutablePatternModifier>

    let unsafePatternModifier: MutablePatternModifier

    let data: CompactData

    init(notation: CompactNotation, locale: ULocale, nsName: String, compactType: CompactData_CompactType, rules: PluralRules, buildReference: MutablePatternModifier, safe: Bool, parent: MicroPropsGenerator) {
        this.rules = rules
        this.parent = parent
        this.data = CompactData()
        if (notation.compactStyle.isSome()) {
            data.populate(locale, nsName, notation.compactStyle, compactType)
        } else {
            data.populate(notation.compactCustomData)
        }
        if (safe) {
            precomputedMods = HashMap<String, MutablePatternModifier_ImmutablePatternModifier>()
            precomputeAllModifiers(buildReference)
            unsafePatternModifier = None
        } else {
            precomputedMods = None
            unsafePatternModifier = buildReference
        }
    }

    private func precomputeAllModifiers(buildReference: MutablePatternModifier): Unit {
        let allPatterns: Set<String> = HashSet<String>()
        data.getUniquePatterns(allPatterns)
        for (patternString in allPatterns) {
            let patternInfo = PatternStringParser.parseToPatternInfo(patternString)
            buildReference.setPatternInfo(patternInfo, NumberFormat_Field.COMPACT)
            precomputedMods.put(patternString, buildReference.createImmutable())
        }
    }

    public override func processQuantity(quantity: DecimalQuantity): MicroProps {
        let micros = parent.processQuantity(quantity)
        if (!micros.rounder.isSome()) {
            throw AssertionError()
        }
        var magnitude: Int32 = 0
        var multiplier = 0
        if (quantity.isZeroish()) {
            magnitude = 0
            micros.rounder.apply(quantity)
        } else {
            multiplier = micros.rounder.chooseMultiplierAndApply(quantity, data)
            magnitude = if (quantity.isZeroish()) { 0 } else { quantity.getMagnitude() }
            magnitude -= multiplier
        }
        let patternString = data.getPattern(magnitude, rules, quantity)
        if (patternString.isNone()) { } else if (precomputedMods.isSome()) {
            let mod = precomputedMods.get(patternString)
            mod.applyToMicros(micros, quantity)
        } else {
            let patternInfo = PatternStringParser.parseToPatternInfo(patternString)
            unsafePatternModifier.setPatternInfo(patternInfo, NumberFormat_Field.COMPACT)
            unsafePatternModifier.setNumberProperties(quantity.signum(), None)
            micros.modMiddle = unsafePatternModifier
        }
        quantity.adjustExponent(-1 * multiplier)
        micros.rounder = None
        return micros
    }
}
