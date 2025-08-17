package icu4cj.impl.number.parse


public class AffixMatcher <: NumberParseMatcher {
    let prefix: AffixPatternMatcher

    let suffix: AffixPatternMatcher

    private let flags: Int32

    public static let COMPARATOR = AffixMatcher_1()

    private static func isInteresting(patternInfo: AffixPatternProvider, ignorables: IgnorablesMatcher, parseFlags: Int32): Bool {
        let posPrefixString = patternInfo.getString(AffixPatternProvider.FLAG_POS_PREFIX)
        let posSuffixString = patternInfo.getString(AffixPatternProvider.FLAG_POS_SUFFIX)
        var negPrefixString: String
        var negSuffixString: String
        if (patternInfo.hasNegativeSubpattern()) {
            negPrefixString = patternInfo.getString(AffixPatternProvider.FLAG_NEG_PREFIX)
            negSuffixString = patternInfo.getString(AffixPatternProvider.FLAG_NEG_SUFFIX)
        }
        if (0 == (parseFlags & ParsingUtils.PARSE_FLAG_USE_FULL_AFFIXES) && AffixUtils.containsOnlySymbolsAndIgnorables(posPrefixString, ignorables.getSet()) && AffixUtils.containsOnlySymbolsAndIgnorables(posSuffixString, ignorables.getSet()) && AffixUtils.containsOnlySymbolsAndIgnorables(negPrefixString, ignorables.getSet()) && AffixUtils.containsOnlySymbolsAndIgnorables(negSuffixString, ignorables.getSet()) && !AffixUtils.containsType(posSuffixString, AffixUtils.TYPE_PLUS_SIGN) && !AffixUtils.containsType(posSuffixString, AffixUtils.TYPE_MINUS_SIGN) && !AffixUtils.containsType(negSuffixString, AffixUtils.TYPE_PLUS_SIGN) && !AffixUtils.containsType(negSuffixString, AffixUtils.TYPE_MINUS_SIGN)) {
            return false
        }
        return true
    }

    public static func createMatchers(patternInfo: AffixPatternProvider, output: NumberParserImpl, factory: AffixTokenMatcherFactory, ignorables: IgnorablesMatcher, parseFlags: Int32): Unit {
        if (!isInteresting(patternInfo, ignorables, parseFlags)) {
            return
        }
        let sb = StringBuilder()
        let matchers = ArrayList<AffixMatcher>(6)
        let includeUnpaired = 0 != (parseFlags & ParsingUtils.PARSE_FLAG_INCLUDE_UNPAIRED_AFFIXES)
        var posPrefix: AffixPatternMatcher
        var posSuffix: AffixPatternMatcher
        for (Type in PatternStringUtils_PatternSignType.VALUES) {
            if (refEq(Type, PatternStringUtils_PatternSignType.POS) && 0 != (parseFlags & ParsingUtils.PARSE_FLAG_PLUS_SIGN_ALLOWED)) {
                continue
            }
            if (refEq(Type, PatternStringUtils_PatternSignType.POS_SIGN) && 0 == (parseFlags & ParsingUtils.PARSE_FLAG_PLUS_SIGN_ALLOWED)) {
                continue
            }
            PatternStringUtils.patternInfoToStringBuilder(patternInfo, true, Type, false, StandardPlural.OTHER, false, sb)
            let prefix = AffixPatternMatcher.fromAffixPattern(sb.toString(), factory, parseFlags)
            PatternStringUtils.patternInfoToStringBuilder(patternInfo, false, Type, false, StandardPlural.OTHER, false, sb)
            let suffix = AffixPatternMatcher.fromAffixPattern(sb.toString(), factory, parseFlags)
            if (refEq(Type, PatternStringUtils_PatternSignType.POS)) {
                posPrefix = prefix
                posSuffix = suffix
            } else if (Objects.equals(prefix, posPrefix) && Objects.equals(suffix, posSuffix)) {
                continue
            }
            let flags = if (refEq(Type, PatternStringUtils_PatternSignType.NEG)) { ParsedNumber.FLAG_NEGATIVE } else { 0 }
            matchers.append(getInstance(prefix, suffix, flags))
            if (includeUnpaired && prefix.isSome() && suffix.isSome()) {
                if (refEq(Type, PatternStringUtils_PatternSignType.POS) || !Objects.equals(prefix, posPrefix)) {
                    matchers.append(getInstance(prefix, None, flags))
                }
                if (refEq(Type, PatternStringUtils_PatternSignType.POS) || !Objects.equals(suffix, posSuffix)) {
                    matchers.append(getInstance(None, suffix, flags))
                }
            }
        }
        Collections.sort(matchers, COMPARATOR as Comparator)
        output.addMatchers(matchers as Collection<NumberParseMatcher>)
    }

    private static func getInstance(prefix: AffixPatternMatcher, suffix: AffixPatternMatcher, flags: Int32): AffixMatcher {
        return AffixMatcher(prefix, suffix, flags)
    }

    private init(prefix: AffixPatternMatcher, suffix: AffixPatternMatcher, flags: Int32) {
        this.prefix = prefix
        this.suffix = suffix
        this.flags = flags
    }

    public override func match(segment: StringSegment, result: ParsedNumber): Bool {
        if (!result.seenNumber()) {
            if (result.prefix.isSome() || prefix.isNone()) {
                return false
            }
            let initialOffset = segment.getOffset()
            let maybeMore = prefix.match(segment, result)
            if (initialOffset != segment.getOffset()) {
                result.prefix = prefix.getPattern()
            }
            return maybeMore
        } else {
            if (result.suffix.isSome() || suffix.isNone() || !matched(prefix, result.prefix)) {
                return false
            }
            let initialOffset = segment.getOffset()
            let maybeMore = suffix.match(segment, result)
            if (initialOffset != segment.getOffset()) {
                result.suffix = suffix.getPattern()
            }
            return maybeMore
        }
    }

    public override func smokeTest(segment: StringSegment): Bool {
        return (prefix.isSome() && prefix.smokeTest(segment)) || (suffix.isSome() && suffix.smokeTest(segment))
    }

    public override func postProcess(result: ParsedNumber): Unit {
        if (matched(prefix, result.prefix) && matched(suffix, result.suffix)) {
            if (result.prefix.isNone()) {
                result.prefix = ""
            }
            if (result.suffix.isNone()) {
                result.suffix = ""
            }
            result.flags |= flags
            if (prefix.isSome()) {
                prefix.postProcess(result)
            }
            if (suffix.isSome()) {
                suffix.postProcess(result)
            }
        }
    }

    static func matched(affix: AffixPatternMatcher, patternString: String): Bool {
        return (affix.isNone() && patternString.isNone()) || (affix.isSome() && affix.getPattern().equals(patternString))
    }

    static func length(matcher: AffixPatternMatcher): Int32 {
        return if (matcher.isNone()) { 0 } else { Int32(matcher.getPattern().size) }
    }

    public override func equals(_other: Object): Bool {
        if (!(checkOptionalIs<AffixMatcher, Object>(_other))) {
            return false
        }
        let other = _other
        return Objects.equals(prefix, other.prefix) && Objects.equals(suffix, other.suffix) && flags == other.flags
    }

    public override func hashCode(): Int64 {
        return Int64(Objects.hashCode(prefix) ^ Objects.hashCode(suffix) ^ flags)
    }

    public override func toString(): String {
        let isNegative = 0 != (flags & ParsedNumber.FLAG_NEGATIVE)
        return "<AffixMatcher" + (if (isNegative) { ":negative " } else { " " }) + prefix.asString() + "#" + suffix.asString() + ">"
    }
}


class AffixMatcher_1 <: Comparator {

    public override func compare(lhs: AffixMatcher, rhs: AffixMatcher): Int32 {
        if (AffixMatcher.length(lhs.prefix) != AffixMatcher.length(rhs.prefix)) {
            return if (AffixMatcher.length(lhs.prefix) > AffixMatcher.length(rhs.prefix)) { -1 } else { 1 }
        } else if (AffixMatcher.length(lhs.suffix) != AffixMatcher.length(rhs.suffix)) {
            return if (AffixMatcher.length(lhs.suffix) > AffixMatcher.length(rhs.suffix)) { -1 } else { 1 }
        } else if (!lhs.equals(rhs)) {
            return if (Int32(lhs.hashCode()) > Int32(rhs.hashCode())) { -1 } else { 1 }
        } else {
            return 0
        }
    }
}
