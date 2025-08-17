package icu4cj.impl.number

public class CurrencyPluralInfoAffixProvider <: AffixPatternProvider {
    private let affixesByPlural: Array<PropertiesAffixPatternProvider>

    public init(cpi: CurrencyPluralInfo, properties: DecimalFormatProperties) {
        affixesByPlural = Array<PropertiesAffixPatternProvider>(Int64(StandardPlural.COUNT))
        let pluralProperties = DecimalFormatProperties()
        pluralProperties.copyFrom(properties)
        for (plural in StandardPlural.VALUES) {
            let pattern = cpi.getCurrencyPluralPattern(plural.getKeyword())
            PatternStringParser.parseToExistingProperties(pattern, pluralProperties)
            affixesByPlural[Int64(plural.ordinal)] = PropertiesAffixPatternProvider(pluralProperties)
        }
    }

    public override func charAt(flags: Int32, i: Int32): Char {
        let pluralOrdinal = (flags & AffixPatternProvider_Flags.PLURAL_MASK)
        return affixesByPlural[Int64(pluralOrdinal)].toRuneArray()[flags, i]
    }

    public override func length(flags: Int32): Int32 {
        let pluralOrdinal = (flags & AffixPatternProvider_Flags.PLURAL_MASK)
        return affixesByPlural[Int64(pluralOrdinal)].length(flags)
    }

    public override func getString(flags: Int32): String {
        let pluralOrdinal = (flags & AffixPatternProvider_Flags.PLURAL_MASK)
        return affixesByPlural[Int64(pluralOrdinal)].getString(flags)
    }

    public override func positiveHasPlusSign(): Bool {
        return affixesByPlural[Int64(StandardPlural.OTHER.ordinal)].positiveHasPlusSign()
    }

    public override func hasNegativeSubpattern(): Bool {
        return affixesByPlural[Int64(StandardPlural.OTHER.ordinal)].hasNegativeSubpattern()
    }

    public override func negativeHasMinusSign(): Bool {
        return affixesByPlural[Int64(StandardPlural.OTHER.ordinal)].negativeHasMinusSign()
    }

    public override func hasCurrencySign(): Bool {
        return affixesByPlural[Int64(StandardPlural.OTHER.ordinal)].hasCurrencySign()
    }

    public override func containsSymbolType(Type: Int32): Bool {
        return affixesByPlural[Int64(StandardPlural.OTHER.ordinal)].containsSymbolType(Type)
    }

    public override func hasBody(): Bool {
        return affixesByPlural[Int64(StandardPlural.OTHER.ordinal)].hasBody()
    }

    public override func currencyAsDecimal(): Bool {
        return affixesByPlural[Int64(StandardPlural.OTHER.ordinal)].currencyAsDecimalMethod()
    }
}
