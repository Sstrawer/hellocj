package icu4cj.impl.number.parse


public class NumberParserImpl {
    public static func createSimpleParser(locale: ULocale, pattern: String, parseFlags: Int32): NumberParserImpl {
        let parser = NumberParserImpl(parseFlags)
        let currency = Currency.getInstance("USD")
        let symbols = DecimalFormatSymbols.getInstance(locale)
        let ignorables = IgnorablesMatcher.getInstance(parseFlags)
        let factory = AffixTokenMatcherFactory()
        factory.currency = currency
        factory.symbols = symbols
        factory.ignorables = ignorables
        factory.locale = locale
        factory.parseFlags = parseFlags
        let patternInfo = PatternStringParser.parseToPatternInfo(pattern)
        AffixMatcher.createMatchers(patternInfo, parser, factory, ignorables, parseFlags)
        let grouper = Grouper.forStrategy(NumberFormatter_GroupingStrategy.AUTO).withLocaleData(locale, patternInfo)
        parser.addMatcher(ignorables)
        parser.addMatcher(DecimalMatcher.getInstance(symbols, grouper, parseFlags))
        parser.addMatcher(MinusSignMatcher.getInstance(symbols, false))
        parser.addMatcher(PlusSignMatcher.getInstance(symbols, false))
        parser.addMatcher(PercentMatcher.getInstance(symbols))
        parser.addMatcher(PermilleMatcher.getInstance(symbols))
        parser.addMatcher(NanMatcher.getInstance(symbols, parseFlags))
        parser.addMatcher(InfinityMatcher.getInstance(symbols))
        parser.addMatcher(PaddingMatcher.getInstance("@"))
        parser.addMatcher(ScientificMatcher.getInstance(symbols, grouper))
        parser.addMatcher(CombinedCurrencyMatcher.getInstance(currency, symbols, parseFlags))
        parser.addMatcher(RequireNumberValidator())
        parser.freeze()
        return parser
    }

    public static func parseStatic(input: String, ppos: ParsePosition, properties: DecimalFormatProperties, symbols: DecimalFormatSymbols): Number {
        let parser = createParserFromProperties(properties, symbols, false)
        let result = ParsedNumber()
        parser.parse(input, true, result)
        if (result.success()) {
            ppos.setIndex(result.charEnd)
            return result.getNumber()
        } else {
            ppos.setErrorIndex(result.charEnd)
            return None
        }
    }

    public static func parseStaticCurrency(input: String, ppos: ParsePosition, properties: DecimalFormatProperties, symbols: DecimalFormatSymbols): CurrencyAmount {
        let parser = createParserFromProperties(properties, symbols, true)
        let result = ParsedNumber()
        parser.parse(input, true, result)
        if (result.success()) {
            ppos.setIndex(result.charEnd)
            if (!result.currencyCode.isSome()) {
                throw AssertionError()
            }
            return CurrencyAmount(result.getNumber(), Currency.getInstance(result.currencyCode))
        } else {
            ppos.setErrorIndex(result.charEnd)
            return None
        }
    }

    public static func createDefaultParserForLocale(loc: ULocale): NumberParserImpl {
        let symbols = DecimalFormatSymbols.getInstance(loc)
        let properties = PatternStringParser.parseToProperties("0")
        return createParserFromProperties(properties, symbols, false)
    }

    public static func createParserFromProperties(properties: DecimalFormatProperties, symbols: DecimalFormatSymbols, parseCurrency: Bool): NumberParserImpl {
        let locale = symbols.getULocale()
        let affixProvider = PropertiesAffixPatternProvider.forProperties(properties)
        let currency = CustomSymbolCurrency.resolve(properties.getCurrency(), locale, symbols)
        var parseMode = properties.getParseMode()
        if (parseMode.isNone()) {
            parseMode = DecimalFormatProperties_ParseMode.LENIENT
        }
        let grouper = Grouper.forProperties(properties)
        var parseFlags = 0
        if (!properties.getParseCaseSensitive()) {
            parseFlags |= ParsingUtils.PARSE_FLAG_IGNORE_CASE
        }
        if (properties.getParseIntegerOnly()) {
            parseFlags |= ParsingUtils.PARSE_FLAG_INTEGER_ONLY
        }
        if (properties.getParseToBigDecimal()) {
            parseFlags |= ParsingUtils.PARSE_FLAG_FORCE_BIG_DECIMAL
        }
        if (properties.getSignAlwaysShown()) {
            parseFlags |= ParsingUtils.PARSE_FLAG_PLUS_SIGN_ALLOWED
        }
        if (refEq(parseMode, DecimalFormatProperties_ParseMode.JAVA_COMPATIBILITY)) {
            parseFlags |= ParsingUtils.PARSE_FLAG_STRICT_SEPARATORS
            parseFlags |= ParsingUtils.PARSE_FLAG_USE_FULL_AFFIXES
            parseFlags |= ParsingUtils.PARSE_FLAG_EXACT_AFFIX
            parseFlags |= ParsingUtils.PARSE_FLAG_JAVA_COMPATIBILITY_IGNORABLES
        } else if (refEq(parseMode, DecimalFormatProperties_ParseMode.STRICT)) {
            parseFlags |= ParsingUtils.PARSE_FLAG_STRICT_GROUPING_SIZE
            parseFlags |= ParsingUtils.PARSE_FLAG_STRICT_SEPARATORS
            parseFlags |= ParsingUtils.PARSE_FLAG_USE_FULL_AFFIXES
            parseFlags |= ParsingUtils.PARSE_FLAG_EXACT_AFFIX
            parseFlags |= ParsingUtils.PARSE_FLAG_STRICT_IGNORABLES
        } else {
            parseFlags |= ParsingUtils.PARSE_FLAG_INCLUDE_UNPAIRED_AFFIXES
        }
        if (Int32(grouper.getPrimary()) <= 0) {
            parseFlags |= ParsingUtils.PARSE_FLAG_GROUPING_DISABLED
        }
        if (parseCurrency || affixProvider.hasCurrencySign()) {
            parseFlags |= ParsingUtils.PARSE_FLAG_MONETARY_SEPARATORS
        }
        if (!parseCurrency) {
            parseFlags |= ParsingUtils.PARSE_FLAG_NO_FOREIGN_CURRENCIES
        }
        let parser = NumberParserImpl(parseFlags)
        let ignorables = IgnorablesMatcher.getInstance(parseFlags)
        let factory = AffixTokenMatcherFactory()
        factory.currency = currency
        factory.symbols = symbols
        factory.ignorables = ignorables
        factory.locale = locale
        factory.parseFlags = parseFlags
        AffixMatcher.createMatchers(affixProvider, parser, factory, ignorables, parseFlags)
        if (parseCurrency || affixProvider.hasCurrencySign()) {
            parser.addMatcher(CombinedCurrencyMatcher.getInstance(currency, symbols, parseFlags))
        }
        if (refEq(parseMode, DecimalFormatProperties_ParseMode.LENIENT) && affixProvider.containsSymbolType(AffixUtils.TYPE_PERCENT)) {
            parser.addMatcher(PercentMatcher.getInstance(symbols))
        }
        if (refEq(parseMode, DecimalFormatProperties_ParseMode.LENIENT) && affixProvider.containsSymbolType(AffixUtils.TYPE_PERMILLE)) {
            parser.addMatcher(PermilleMatcher.getInstance(symbols))
        }
        if (refEq(parseMode, DecimalFormatProperties_ParseMode.LENIENT)) {
            parser.addMatcher(PlusSignMatcher.getInstance(symbols, false))
            parser.addMatcher(MinusSignMatcher.getInstance(symbols, false))
        }
        parser.addMatcher(NanMatcher.getInstance(symbols, parseFlags))
        parser.addMatcher(InfinityMatcher.getInstance(symbols))
        let padString = properties.getPadString()
        if (padString.isSome() && !ignorables.getSet().contains(padString)) {
            parser.addMatcher(PaddingMatcher.getInstance(padString))
        }
        parser.addMatcher(ignorables)
        parser.addMatcher(DecimalMatcher.getInstance(symbols, grouper, parseFlags))
        if (!properties.getParseNoExponent() || properties.getMinimumExponentDigits() > 0) {
            parser.addMatcher(ScientificMatcher.getInstance(symbols, grouper))
        }
        parser.addMatcher(RequireNumberValidator())
        if (!refEq(parseMode, DecimalFormatProperties_ParseMode.LENIENT)) {
            parser.addMatcher(RequireAffixValidator())
        }
        if (parseCurrency) {
            parser.addMatcher(RequireCurrencyValidator())
        }
        if (properties.getDecimalPatternMatchRequired()) {
            let patternHasDecimalSeparator = properties.getDecimalSeparatorAlwaysShown() || properties.getMaximumFractionDigits() != 0
            parser.addMatcher(RequireDecimalSeparatorValidator.getInstance(patternHasDecimalSeparator))
        }
        let multiplier = RoundingUtils.scaleFromProperties(properties)
        if (multiplier.isSome()) {
            parser.addMatcher(MultiplierParseHandler(multiplier))
        }
        parser.freeze()
        return parser
    }

    private let parseFlags: Int32

    private let matchers: ArrayList<NumberParseMatcher>

    private var frozen: Bool = false

    public init(parseFlags: Int32) {
        matchers = ArrayList<NumberParseMatcher>()
        this.parseFlags = parseFlags
        frozen = false
    }

    public func addMatcher(matcher: NumberParseMatcher): Unit {
        if (!(!frozen)) {
            throw AssertionError()
        }
        this.matchers.append(matcher)
    }

    public func addMatchers(matchers: Collection<NumberParseMatcher>): Unit {
        if (!(!frozen)) {
            throw AssertionError()
        }
        this.matchers.appendAll(matchers)
    }

    public func freeze(): Unit {
        frozen = true
    }

    public func getParseFlags(): Int32 {
        return parseFlags
    }

    public func parse(input: String, greedy: Bool, result: ParsedNumber): Unit {
        parse(input, 0, greedy, result)
    }

    public func parse(input: String, start: Int32, greedy: Bool, result: ParsedNumber): Unit {
        if (!frozen) {
            throw AssertionError()
        }
        if (!(start >= 0 && start < Int32(input.size))) {
            throw AssertionError()
        }
        let segment = StringSegment(input, 0 != (parseFlags & ParsingUtils.PARSE_FLAG_IGNORE_CASE))
        segment.adjustOffset(start)
        if (greedy) {
            parseGreedy(segment, result)
        } else if (0 != (parseFlags & ParsingUtils.PARSE_FLAG_ALLOW_INFINITE_RECURSION)) {
            parseLongestRecursive(segment, result, 1)
        } else {
            parseLongestRecursive(segment, result, -100)
        }
        for (matcher in matchers) {
            matcher.postProcess(result)
        }
        result.postProcess()
    }

    private func parseGreedy(segment: StringSegment, result: ParsedNumber): Unit {
        var i = 0
        while (i < Int32(matchers.size)) {
            if (segment.size == 0) {
                return
            }
            let matcher = matchers[Int64(i)]
            if (!matcher.smokeTest(segment)) {
                i++
                continue
            }
            let initialOffset = segment.getOffset()
            matcher.match(segment, result)
            if (segment.getOffset() != initialOffset) {
                i = 0
                continue
            } else {
                i++
                continue
            }
        }
    }

    private func parseLongestRecursive(segment: StringSegment, result: ParsedNumber, recursionLevels: Int32): Unit {
        if (segment.size == 0) {
            return
        }
        if (recursionLevels == 0) {
            return
        }
        let initial = ParsedNumber()
        initial.copyFrom(result)
        let candidate = ParsedNumber()
        let initialOffset = segment.getOffset()
        var i = 0
        while (i < Int32(matchers.size)) {
            let matcher = matchers[Int64(i)]
            if (!matcher.smokeTest(segment)) {
                continue
            }
            var charsToConsume = 0
            while (charsToConsume < segment.size) {
                charsToConsume += Character.charCount(segment.codePointAt(charsToConsume))
                candidate.copyFrom(initial)
                segment.setLength(charsToConsume)
                let maybeMore = matcher.match(segment, candidate)
                segment.resetLength()
                if (segment.getOffset() - initialOffset == charsToConsume) {
                    parseLongestRecursive(segment, candidate, recursionLevels + 1)
                    if (candidate.isBetterThan(result)) {
                        result.copyFrom(candidate)
                    }
                }
                segment.setOffset(initialOffset)
                if (!maybeMore) {
                    break
                }
            }
            i++
        }
    }

    public override func toString(): String {
        return "<NumberParserImpl matchers=" + toString(matchers) + ">"
    }
}
