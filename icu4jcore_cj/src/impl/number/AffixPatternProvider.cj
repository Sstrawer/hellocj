package icu4cj.impl.number

public interface AffixPatternProvider {
    let FLAG_POS_PREFIX = AffixPatternProvider_Flags.PREFIX

    let FLAG_POS_SUFFIX = 0

    let FLAG_NEG_PREFIX = AffixPatternProvider_Flags.PREFIX | AffixPatternProvider_Flags.NEGATIVE_SUBPATTERN

    let FLAG_NEG_SUFFIX = AffixPatternProvider_Flags.NEGATIVE_SUBPATTERN

    public func charAt(flags: Int32, i: Int32): Char

    public func length(flags: Int32): Int32

    public func getString(flags: Int32): String

    public func hasCurrencySign(): Bool

    public func positiveHasPlusSign(): Bool

    public func hasNegativeSubpattern(): Bool

    public func negativeHasMinusSign(): Bool

    public func containsSymbolType(Type: Int32): Bool

    public func hasBody(): Bool

    public func currencyAsDecimal(): Bool
}

public static class AffixPatternProvider_Flags {

    public static let PLURAL_MASK = 255

    public static let PREFIX = 256

    public static let NEGATIVE_SUBPATTERN = 512

    public static let PADDING = 1024
}
