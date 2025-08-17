package icu4cj.impl.number.range


public class RangeMacroProps {

    public var formatter1: UnlocalizedNumberFormatter

    public var formatter2: UnlocalizedNumberFormatter

    public var sameFormatters = -1

    public var collapse: NumberRangeFormatter_RangeCollapse

    public var identityFallback: NumberRangeFormatter_RangeIdentityFallback

    public var loc: ULocale

    public override func hashCode(): Int64 {
        return Int64(Objects.hash([formatter1, formatter2, collapse, identityFallback, loc]))
    }

    public override func equals(_other: Object): Bool {
        if (_other.isNone()) {
            return false
        }
        if (refEq(this, _other)) {
            return true
        }
        if (!(checkOptionalIs<RangeMacroProps, Object>(_other))) {
            return false
        }
        let other = _other
        return Objects.equals(formatter1, other.formatter1) && Objects.equals(formatter2, other.formatter2) && Objects.equals(collapse, other.collapse) && Objects.equals(identityFallback, other.identityFallback) && Objects.equals(loc, other.loc)
    }
}
