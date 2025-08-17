package icu4cj.impl.number.parse


public class AffixPatternMatcher <: SeriesMatcher & AffixUtils_TokenConsumer {
    private let affixPattern: String

    private var factory: AffixTokenMatcherFactory

    private var ignorables: IgnorablesMatcher

    private var lastTypeOrCp: Int32 = 0

    private init(affixPattern: String) {
        super()
        this.affixPattern = affixPattern
    }

    public static func fromAffixPattern(affixPattern: String, factory: AffixTokenMatcherFactory, parseFlags: Int32): AffixPatternMatcher {
        if (affixPattern.isEmpty()) {
            return None
        }
        let series = AffixPatternMatcher(affixPattern)
        series.factory = factory
        series.ignorables = if (0 != (parseFlags & ParsingUtils.PARSE_FLAG_EXACT_AFFIX)) { None } else { factory.ignorablesMethod() }
        series.lastTypeOrCp = 0
        AffixUtils.iterateWithConsumer(affixPattern, series)
        series.factory = None
        series.ignorables = None
        series.lastTypeOrCp = 0
        series.freeze()
        return series
    }

    public override func consumeToken(typeOrCp: Int32): Unit {
        if (ignorables.isSome() && length() > 0 && (lastTypeOrCp < 0 || !ignorables.getSet().contains(lastTypeOrCp))) {
            addMatcher(ignorables)
        }
        if (typeOrCp < 0) {
            match (typeOrCp) {
                case -1 => addMatcher(factory.minusSign())
                case -2 => addMatcher(factory.plusSign())
                case -4 => addMatcher(factory.percent())
                case -5 => addMatcher(factory.permille())
                case -6 | -7 | -8 | -9 | -10 => addMatcher(factory.currencyMethod())
                case _ => throw AssertionError()
            }
        } else if (ignorables.isSome() && ignorables.getSet().contains(typeOrCp)) { } else {
            addMatcher(CodePointMatcher.getInstance(typeOrCp))
        }
        lastTypeOrCp = typeOrCp
    }

    public func getPattern(): String {
        return affixPattern
    }

    public override func equals(other: Object): Bool {
        if (refEq(this, other)) {
            return true
        }
        if (!(checkOptionalIs<AffixPatternMatcher, Object>(other))) {
            return false
        }
        return affixPattern.equals(other.affixPattern)
    }

    public override func hashCode(): Int64 {
        return affixPattern.hashCode()
    }

    public override func toString(): String {
        return affixPattern
    }
}
