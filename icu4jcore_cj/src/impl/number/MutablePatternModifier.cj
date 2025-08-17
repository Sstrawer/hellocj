package icu4cj.impl.number


public class MutablePatternModifier <: Modifier & AffixUtils_SymbolProvider & MicroPropsGenerator {
    let isStrong: Bool

    var patternInfo: AffixPatternProvider

    var field: NumberFormat_Field

    var signDisplay: NumberFormatter_SignDisplay

    var perMilleReplacesPercent: Bool = false

    var approximately: Bool = false

    var symbols: DecimalFormatSymbols

    var unitWidth: NumberFormatter_UnitWidth

    var currency: Currency

    var rules: PluralRules

    var signum: Modifier_Signum

    var plural: StandardPlural

    var parent: MicroPropsGenerator

    var currentAffix: StringBuilder

    public init(isStrong: Bool) {
        this.isStrong = isStrong
    }

    public func setPatternInfo(patternInfo: AffixPatternProvider, field: NumberFormat_Field): Unit {
        this.patternInfo = patternInfo
        this.field = field
    }

    public func setPatternAttributes(signDisplay: NumberFormatter_SignDisplay, perMille: Bool, approximately: Bool): Unit {
        this.signDisplay = signDisplay
        this.perMilleReplacesPercent = perMille
        this.approximately = approximately
    }

    public func setSymbols(symbols: DecimalFormatSymbols, currency: Currency, unitWidth: NumberFormatter_UnitWidth, rules: PluralRules): Unit {
        if (!((rules.isSome()) == needsPlurals())) {
            throw AssertionError()
        }
        this.symbols = symbols
        this.currency = currency
        this.unitWidth = unitWidth
        this.rules = rules
    }

    public func setNumberProperties(signum: Modifier_Signum, plural: StandardPlural): Unit {
        if (!((plural.isSome()) == needsPlurals())) {
            throw AssertionError()
        }
        this.signum = signum
        this.plural = plural
    }

    public func needsPlurals(): Bool {
        return patternInfo.containsSymbolType(AffixUtils.TYPE_CURRENCY_TRIPLE)
    }

    public func createImmutable(): MutablePatternModifier_ImmutablePatternModifier {
        let a = FormattedStringBuilder()
        let b = FormattedStringBuilder()
        if (needsPlurals()) {
            let pm = AdoptingModifierStore()
            for (plural in StandardPlural.VALUES) {
                setNumberProperties(Modifier_Signum.POS, plural)
                pm.setModifier(Modifier_Signum.POS, plural, createConstantModifier(a, b))
                setNumberProperties(Modifier_Signum.POS_ZERO, plural)
                pm.setModifier(Modifier_Signum.POS_ZERO, plural, createConstantModifier(a, b))
                setNumberProperties(Modifier_Signum.NEG_ZERO, plural)
                pm.setModifier(Modifier_Signum.NEG_ZERO, plural, createConstantModifier(a, b))
                setNumberProperties(Modifier_Signum.NEG, plural)
                pm.setModifier(Modifier_Signum.NEG, plural, createConstantModifier(a, b))
            }
            pm.freeze()
            return MutablePatternModifier_ImmutablePatternModifier(pm, rules)
        } else {
            setNumberProperties(Modifier_Signum.POS, None)
            let positive = createConstantModifier(a, b)
            setNumberProperties(Modifier_Signum.POS_ZERO, None)
            let posZero = createConstantModifier(a, b)
            setNumberProperties(Modifier_Signum.NEG_ZERO, None)
            let negZero = createConstantModifier(a, b)
            setNumberProperties(Modifier_Signum.NEG, None)
            let negative = createConstantModifier(a, b)
            let pm = AdoptingModifierStore(positive, posZero, negZero, negative)
            return MutablePatternModifier_ImmutablePatternModifier(pm, None)
        }
    }

    private func createConstantModifier(a: FormattedStringBuilder, b: FormattedStringBuilder): ConstantMultiFieldModifier {
        insertPrefix(a.clear(), 0)
        insertSuffix(b.clear(), 0)
        if (patternInfo.hasCurrencySign()) {
            return CurrencySpacingEnabledModifier(a, b, !patternInfo.hasBody(), isStrong, symbols)
        } else {
            return ConstantMultiFieldModifier(a, b, !patternInfo.hasBody(), isStrong)
        }
    }

    public func addToChain(parent: MicroPropsGenerator): MicroPropsGenerator {
        this.parent = parent
        return this
    }

    public override func processQuantity(fq: DecimalQuantity): MicroProps {
        let micros = parent.processQuantity(fq)
        if (micros.rounder.isSome()) {
            micros.rounder.apply(fq)
        }
        if (micros.modMiddle.isSome()) {
            return micros
        }
        if (needsPlurals()) {
            let pluralForm = RoundingUtils.getPluralSafe(micros.rounder, rules, fq)
            setNumberProperties(fq.signum(), pluralForm)
        } else {
            setNumberProperties(fq.signum(), None)
        }
        micros.modMiddle = this
        return micros
    }

    public override func apply(output: FormattedStringBuilder, leftIndex: Int32, rightIndex: Int32): Int32 {
        let prefixLen = insertPrefix(output, leftIndex)
        let suffixLen = insertSuffix(output, rightIndex + prefixLen)
        var overwriteLen = 0
        if (!patternInfo.hasBody()) {
            overwriteLen = output.splice(leftIndex + prefixLen, rightIndex + prefixLen, "", 0, 0, None)
        }
        CurrencySpacingEnabledModifier.applyCurrencySpacing(output, leftIndex, prefixLen, rightIndex + prefixLen + overwriteLen, suffixLen, symbols)
        return prefixLen + overwriteLen + suffixLen
    }

    public override func getPrefixLength(): Int32 {
        prepareAffix(true)
        let result = AffixUtils.unescapedCount(currentAffix.asString(), true, this)
        return result
    }

    public override func getCodePointCount(): Int32 {
        prepareAffix(true)
        var result = AffixUtils.unescapedCount(currentAffix.asString(), false, this)
        prepareAffix(false)
        result += AffixUtils.unescapedCount(currentAffix.asString(), false, this)
        return result
    }

    public override func isStrongMethod(): Bool {
        return isStrong
    }

    public override func containsField(field: Format_Field): Bool {
        if (!false) {
            throw AssertionError()
        }
        return false
    }

    public override func getParameters(): Modifier_Parameters {
        if (!false) {
            throw AssertionError()
        }
        return None
    }

    public override func strictEquals(other: Modifier): Bool {
        if (!false) {
            throw AssertionError()
        }
        return false
    }

    private func insertPrefix(sb: FormattedStringBuilder, position: Int32): Int32 {
        prepareAffix(true)
        let length = AffixUtils.unescape(currentAffix.asString(), sb, position, this, field)
        return length
    }

    private func insertSuffix(sb: FormattedStringBuilder, position: Int32): Int32 {
        prepareAffix(false)
        let length = AffixUtils.unescape(currentAffix.asString(), sb, position, this, field)
        return length
    }

    private func prepareAffix(isPrefix: Bool): Unit {
        if (currentAffix.isNone()) {
            currentAffix = StringBuilder()
        }
        PatternStringUtils.patternInfoToStringBuilder(patternInfo, isPrefix, PatternStringUtils.resolveSignDisplay(signDisplay, signum), approximately, plural, perMilleReplacesPercent, currentAffix)
    }

    public override func getSymbol(Type: Int32): String {
        match (Type) {
            case -1 => return symbols.getMinusSignString()
            case -2 => return symbols.getPlusSignString()
            case -3 => return symbols.getApproximatelySignString()
            case -4 => return symbols.getPercentString()
            case -5 => return symbols.getPerMillString()
            case -6 => return getCurrencySymbolForUnitWidth()
            case -7 => return currency.getCurrencyCode()
            case -8 =>
                if (!plural.isSome()) {
                    throw AssertionError()
                }
                return currency.getName(symbols.getULocale(), Currency.PLURAL_LONG_NAME, plural.getKeyword(), None)
            case -9 => return "\u{fffd}"
            case -10 => return currency.getName(symbols.getULocale(), Currency.NARROW_SYMBOL_NAME, None)
            case _ => throw AssertionError()
        }
    }

    public func getCurrencySymbolForUnitWidth(): String {
        if (refEq(unitWidth, NumberFormatter_UnitWidth.ISO_CODE)) {
            return currency.getCurrencyCode()
        } else if (refEq(unitWidth, NumberFormatter_UnitWidth.HIDDEN)) {
            return ""
        } else {
            let selector: Int32
            match (unitWidth) {
                case NumberFormatter_UnitWidth.SHORT => selector = Currency.SYMBOL_NAME
                case NumberFormatter_UnitWidth.NARROW => selector = Currency.NARROW_SYMBOL_NAME
                case NumberFormatter_UnitWidth.FORMAL => selector = Currency.FORMAL_SYMBOL_NAME
                case NumberFormatter_UnitWidth.VARIANT => selector = Currency.VARIANT_SYMBOL_NAME
                case _ => throw AssertionError()
            }
            return currency.getName(symbols.getULocale(), selector, None)
        }
    }
}


public class MutablePatternModifier_ImmutablePatternModifier <: MicroPropsGenerator {
    let pm: AdoptingModifierStore

    let rules: PluralRules

    var parent: MicroPropsGenerator

    init(pm: AdoptingModifierStore, rules: PluralRules) {
        this.pm = pm
        this.rules = rules
        this.parent = None
    }

    public func addToChain(parent: MicroPropsGenerator): MutablePatternModifier_ImmutablePatternModifier {
        this.parent = parent
        return this
    }

    public override func processQuantity(quantity: DecimalQuantity): MicroProps {
        let micros = parent.processQuantity(quantity)
        if (micros.rounder.isSome()) {
            micros.rounder.apply(quantity)
        }
        if (micros.modMiddle.isSome()) {
            return micros
        }
        applyToMicros(micros, quantity)
        return micros
    }

    public func applyToMicros(micros: MicroProps, quantity: DecimalQuantity): Unit {
        if (rules.isNone()) {
            micros.modMiddle = pm.getModifierWithoutPlural(quantity.signum())
        } else {
            let pluralForm = RoundingUtils.getPluralSafe(micros.rounder, rules, quantity)
            micros.modMiddle = pm.getModifier(quantity.signum(), pluralForm)
        }
    }
}
