package icu4cj.impl.number

public class PropertiesAffixPatternProvider <: AffixPatternProvider {
    private let posPrefix: String

    private let posSuffix: String

    private let negPrefix: String

    private let negSuffix: String

    private let isCurrencyPattern: Bool

    private let currencyAsDecimal: Bool

    public static func forProperties(properties: DecimalFormatProperties): AffixPatternProvider {
        if (properties.getCurrencyPluralInfo().isNone()) {
            return PropertiesAffixPatternProvider(properties)
        } else {
            return CurrencyPluralInfoAffixProvider(properties.getCurrencyPluralInfo(), properties)
        }
    }

    init(properties: DecimalFormatProperties) {
        let ppo = AffixUtils.escape(properties.getPositivePrefix())
        let pso = AffixUtils.escape(properties.getPositiveSuffix())
        let npo = AffixUtils.escape(properties.getNegativePrefix())
        let nso = AffixUtils.escape(properties.getNegativeSuffix())
        let ppp = properties.getPositivePrefixPattern()
        let psp = properties.getPositiveSuffixPattern()
        let npp = properties.getNegativePrefixPattern()
        let nsp = properties.getNegativeSuffixPattern()
        if (ppo.isSome()) {
            posPrefix = ppo
        } else if (ppp.isSome()) {
            posPrefix = ppp
        } else {
            posPrefix = ""
        }
        if (pso.isSome()) {
            posSuffix = pso
        } else if (psp.isSome()) {
            posSuffix = psp
        } else {
            posSuffix = ""
        }
        if (npo.isSome()) {
            negPrefix = npo
        } else if (npp.isSome()) {
            negPrefix = npp
        } else {
            negPrefix = if (ppp.isNone()) { "-" } else { "-" + (ppp) }
        }
        if (nso.isSome()) {
            negSuffix = nso
        } else if (nsp.isSome()) {
            negSuffix = nsp
        } else {
            negSuffix = if (psp.isNone()) { "" } else { psp }
        }
        isCurrencyPattern = (AffixUtils.hasCurrencySymbols(ppp) || AffixUtils.hasCurrencySymbols(psp) || AffixUtils.hasCurrencySymbols(npp) || AffixUtils.hasCurrencySymbols(nsp) || properties.getCurrencyAsDecimal())
        currencyAsDecimal = properties.getCurrencyAsDecimal()
    }

    public override func charAt(flags: Int32, i: Int32): Char {
        return Char(getString(flags)[Int64(i)])
    }

    public override func length(flags: Int32): Int32 {
        return Int32(getString(flags).size)
    }

    public override func getString(flags: Int32): String {
        let prefix = (flags & AffixPatternProvider_Flags.PREFIX) != 0
        let negative = (flags & AffixPatternProvider_Flags.NEGATIVE_SUBPATTERN) != 0
        if (prefix && negative) {
            return negPrefix
        } else if (prefix) {
            return posPrefix
        } else if (negative) {
            return negSuffix
        } else {
            return posSuffix
        }
    }

    public override func positiveHasPlusSign(): Bool {
        return AffixUtils.containsType(posPrefix, AffixUtils.TYPE_PLUS_SIGN) || AffixUtils.containsType(posSuffix, AffixUtils.TYPE_PLUS_SIGN)
    }

    public override func hasNegativeSubpattern(): Bool {
        return (!refEq(negSuffix, posSuffix) || Int32(negPrefix.size) != Int32(posPrefix.size) + 1 || !negPrefix.regionMatches(1, posPrefix, 0, Int32(posPrefix.size)) || Char(negPrefix[0]) != '-')
    }

    public override func negativeHasMinusSign(): Bool {
        return AffixUtils.containsType(negPrefix, AffixUtils.TYPE_MINUS_SIGN) || AffixUtils.containsType(negSuffix, AffixUtils.TYPE_MINUS_SIGN)
    }

    public override func hasCurrencySign(): Bool {
        return isCurrencyPattern
    }

    public override func containsSymbolType(Type: Int32): Bool {
        return AffixUtils.containsType(posPrefix, Type) || AffixUtils.containsType(posSuffix, Type) || AffixUtils.containsType(negPrefix, Type) || AffixUtils.containsType(negSuffix, Type)
    }

    public override func hasBody(): Bool {
        return true
    }

    public override func currencyAsDecimalMethod(): Bool {
        return currencyAsDecimal
    }

    public override func toString(): String {
        return toString(super) + " {" + (posPrefix) + "#" + (posSuffix) + ";" + (negPrefix) + "#" + (negSuffix) + "}"
    }
}
