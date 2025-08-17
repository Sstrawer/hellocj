package icu4cj.impl.number


public class MacroProps <: Cloneable {

    public var notation: Notation

    public var unit: MeasureUnit

    public var perUnit: MeasureUnit

    public var precision: Precision

    public var roundingMode: RoundingMode = None

    public var grouping: Object

    public var padder: Padder

    public var integerWidth: IntegerWidth

    public var symbols: Object

    public var unitWidth: NumberFormatter_UnitWidth

    public var unitDisplayCase: String

    public var sign: NumberFormatter_SignDisplay

    public var approximately: Bool = None

    public var decimal: NumberFormatter_DecimalSeparatorDisplay

    public var scale: Scale

    public var usage: String

    public var affixProvider: AffixPatternProvider

    public var rules: PluralRules

    public var threshold: Int64

    public var loc: ULocale

    public func fallback(fallback: MacroProps): Unit {
        if (notation.isNone()) {
            notation = fallback.notation
        }
        if (unit.isNone()) {
            unit = fallback.unit
        }
        if (perUnit.isNone()) {
            perUnit = fallback.perUnit
        }
        if (precision.isNone()) {
            precision = fallback.precision
        }
        if (roundingMode.isNone()) {
            roundingMode = fallback.roundingMode
        }
        if (grouping.isNone()) {
            grouping = fallback.grouping
        }
        if (padder.isNone()) {
            padder = fallback.padder
        }
        if (integerWidth.isNone()) {
            integerWidth = fallback.integerWidth
        }
        if (symbols.isNone()) {
            symbols = fallback.symbols
        }
        if (unitWidth.isNone()) {
            unitWidth = fallback.unitWidth
        }
        if (unitDisplayCase.isNone()) {
            unitDisplayCase = fallback.unitDisplayCase
        }
        if (sign.isNone()) {
            sign = fallback.sign
        }
        if (approximately.isNone()) {
            approximately = fallback.approximately
        }
        if (decimal.isNone()) {
            decimal = fallback.decimal
        }
        if (affixProvider.isNone()) {
            affixProvider = fallback.affixProvider
        }
        if (scale.isNone()) {
            scale = fallback.scale
        }
        if (usage.isNone()) {
            usage = fallback.usage
        }
        if (rules.isNone()) {
            rules = fallback.rules
        }
        if (loc.isNone()) {
            loc = fallback.loc
        }
    }

    public override func hashCode(): Int64 {
        return Int64(Objects.hash([notation, unit, perUnit, precision, roundingMode, grouping, padder, integerWidth, symbols, unitWidth, unitDisplayCase, sign, approximately, decimal, affixProvider, scale, usage, rules, loc]))
    }

    public override func equals(_other: Object): Bool {
        if (_other.isNone()) {
            return false
        }
        if (refEq(this, _other)) {
            return true
        }
        if (!(checkOptionalIs<MacroProps, Object>(_other))) {
            return false
        }
        let other = _other
        return Objects.equals(notation, other.notation) && Objects.equals(unit, other.unit) && Objects.equals(perUnit, other.perUnit) && Objects.equals(precision, other.precision) && Objects.equals(roundingMode, other.roundingMode) && Objects.equals(grouping, other.grouping) && Objects.equals(padder, other.padder) && Objects.equals(integerWidth, other.integerWidth) && Objects.equals(symbols, other.symbols) && Objects.equals(unitWidth, other.unitWidth) && Objects.equals(unitDisplayCase, other.unitDisplayCase) && Objects.equals(sign, other.sign) && Objects.equals(approximately, other.approximately) && Objects.equals(decimal, other.decimal) && Objects.equals(affixProvider, other.affixProvider) && Objects.equals(scale, other.scale) && Objects.equals(usage, other.usage) && Objects.equals(rules, other.rules) && Objects.equals(loc, other.loc)
    }

    public override func clone(): Object {
        try {
            return super.toString()
        } catch (e: CloneNotSupportedException) {
            throw AssertionError(e)
        }
    }
}
