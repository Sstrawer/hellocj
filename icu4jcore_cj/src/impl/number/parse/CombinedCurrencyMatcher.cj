package icu4cj.impl.number.parse


public class CombinedCurrencyMatcher <: NumberParseMatcher {
    private let isoCode: String

    private let currency1: String

    private let currency2: String

    private let localLongNames: Array<String>

    private let afterPrefixInsert: String

    private let beforeSuffixInsert: String

    private let longNameTrie: TextTrieMap<Currency_CurrencyStringInfo>

    private let symbolTrie: TextTrieMap<Currency_CurrencyStringInfo>

    public static func getInstance(currency: Currency, dfs: DecimalFormatSymbols, parseFlags: Int32): CombinedCurrencyMatcher {
        return CombinedCurrencyMatcher(currency, dfs, parseFlags)
    }

    private init(currency: Currency, dfs: DecimalFormatSymbols, parseFlags: Int32) {
        this.isoCode = currency.getSubtype()
        this.currency1 = currency.getSymbol(dfs.getULocale())
        this.currency2 = currency.getCurrencyCode()
        afterPrefixInsert = dfs.getPatternForCurrencySpacing(DecimalFormatSymbols.CURRENCY_SPC_INSERT, false)
        beforeSuffixInsert = dfs.getPatternForCurrencySpacing(DecimalFormatSymbols.CURRENCY_SPC_INSERT, true)
        if (0 == (parseFlags & ParsingUtils.PARSE_FLAG_NO_FOREIGN_CURRENCIES)) {
            longNameTrie = Currency.getParsingTrie(dfs.getULocale(), Currency.LONG_NAME)
            symbolTrie = Currency.getParsingTrie(dfs.getULocale(), Currency.SYMBOL_NAME)
            localLongNames = None
        } else {
            longNameTrie = None
            symbolTrie = None
            localLongNames = Array<String>(Int64(StandardPlural.COUNT))
            var i = 0
            while (i < StandardPlural.COUNT) {
                let pluralKeyword = StandardPlural.VALUES[Int64(i)].getKeyword()
                localLongNames[Int64(i)] = currency.getName(dfs.getLocale(), Currency.PLURAL_LONG_NAME, pluralKeyword, None)
                i++
            }
        }
    }

    public override func match(segment: StringSegment, result: ParsedNumber): Bool {
        if (result.currencyCode.isSome()) {
            return false
        }
        let initialOffset = segment.getOffset()
        var maybeMore = false
        if (result.seenNumber() && !beforeSuffixInsert.isEmpty()) {
            let overlap = segment.getCommonPrefixLength(beforeSuffixInsert)
            if (overlap == Int32(beforeSuffixInsert.size)) {
                segment.adjustOffset(overlap)
            }
            maybeMore = maybeMore || overlap == segment.size
        }
        maybeMore = maybeMore || matchCurrency(segment, result)
        if (result.currencyCode.isNone()) {
            segment.setOffset(initialOffset)
            return maybeMore
        }
        if (!result.seenNumber() && !afterPrefixInsert.isEmpty()) {
            let overlap = segment.getCommonPrefixLength(afterPrefixInsert)
            if (overlap == Int32(afterPrefixInsert.size)) {
                segment.adjustOffset(overlap)
            }
            maybeMore = maybeMore || overlap == segment.size
        }
        return maybeMore
    }

    private func matchCurrency(segment: StringSegment, result: ParsedNumber): Bool {
        var maybeMore = false
        let overlap1: Int32
        if (!currency1.isEmpty()) {
            overlap1 = segment.getCaseSensitivePrefixLength(currency1)
        } else {
            overlap1 = -1
        }
        maybeMore = maybeMore || overlap1 == segment.size
        if (overlap1 == Int32(currency1.size)) {
            result.currencyCode = isoCode
            segment.adjustOffset(overlap1)
            result.setCharsConsumed(segment)
            return maybeMore
        }
        let overlap2: Int32
        if (!currency2.isEmpty()) {
            overlap2 = segment.getCommonPrefixLength(currency2)
        } else {
            overlap2 = -1
        }
        maybeMore = maybeMore || overlap2 == segment.size
        if (overlap2 == Int32(currency2.size)) {
            result.currencyCode = isoCode
            segment.adjustOffset(overlap2)
            result.setCharsConsumed(segment)
            return maybeMore
        }
        if (longNameTrie.isSome()) {
            let trieOutput = TextTrieMap_Output()
            var values = longNameTrie.get(segment, 0, trieOutput)
            maybeMore = maybeMore || trieOutput.partialMatch
            if (values.isNone()) {
                values = symbolTrie.get(segment, 0, trieOutput)
                maybeMore = maybeMore || trieOutput.partialMatch
            }
            if (values.isSome()) {
                result.currencyCode = values.next().getISOCode()
                segment.adjustOffset(trieOutput.matchLength)
                result.setCharsConsumed(segment)
                return maybeMore
            }
        } else {
            var longestFullMatch = 0
            var i = 0
            while (i < StandardPlural.COUNT) {
                let name = localLongNames[Int64(i)]
                if (name.isEmpty()) {
                    continue
                }
                let overlap = segment.getCommonPrefixLength(name)
                if (overlap == Int32(name.size) && Int32(name.size) > longestFullMatch) {
                    longestFullMatch = Int32(name.size)
                }
                maybeMore = maybeMore || overlap > 0
                i++
            }
            if (longestFullMatch > 0) {
                result.currencyCode = isoCode
                segment.adjustOffset(longestFullMatch)
                result.setCharsConsumed(segment)
                return maybeMore
            }
        }
        return maybeMore
    }

    public override func smokeTest(segment: StringSegment): Bool {
        return true
    }

    public override func postProcess(result: ParsedNumber): Unit { }

    public override func toString(): String {
        return "<CombinedCurrencyMatcher " + (isoCode) + ">"
    }
}
