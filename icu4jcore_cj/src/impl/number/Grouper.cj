package icu4cj.impl.number


public class Grouper {
    private static let GROUPER_NEVER = Grouper(-1i16, -1i16, -2i16)

    private static let GROUPER_MIN2 = Grouper(-2i16, -2i16, -3i16)

    private static let GROUPER_AUTO = Grouper(-2i16, -2i16, -2i16)

    private static let GROUPER_ON_ALIGNED = Grouper(-4i16, -4i16, 1i16)

    private static let GROUPER_WESTERN = Grouper(3i16, 3i16, 1i16)

    private static let GROUPER_INDIC = Grouper(3i16, 2i16, 1i16)

    private static let GROUPER_WESTERN_MIN2 = Grouper(3i16, 3i16, 2i16)

    private static let GROUPER_INDIC_MIN2 = Grouper(3i16, 2i16, 2i16)

    public static func forStrategy(grouping: NumberFormatter_GroupingStrategy): Grouper {
        match (grouping) {
            case NumberFormatter_GroupingStrategy.OFF => return GROUPER_NEVER
            case NumberFormatter_GroupingStrategy.MIN2 => return GROUPER_MIN2
            case NumberFormatter_GroupingStrategy.AUTO => return GROUPER_AUTO
            case NumberFormatter_GroupingStrategy.ON_ALIGNED => return GROUPER_ON_ALIGNED
            case NumberFormatter_GroupingStrategy.THOUSANDS => return GROUPER_WESTERN
            case _ => throw AssertionError()
        }
    }

    public static func forProperties(properties: DecimalFormatProperties): Grouper {
        if (!properties.getGroupingUsed()) {
            return GROUPER_NEVER
        }
        var grouping1 = Int16(properties.getGroupingSize())
        var grouping2 = Int16(properties.getSecondaryGroupingSize())
        let minGrouping = Int16(properties.getMinimumGroupingDigits())
        grouping1 = if (Int32(grouping1) > 0) { grouping1 } else { if (Int32(grouping2) > 0) { grouping2 } else { grouping1 } }
        grouping2 = if (Int32(grouping2) > 0) { grouping2 } else { grouping1 }
        return getInstance(grouping1, grouping2, minGrouping)
    }

    public static func getInstance(grouping1: Int16, grouping2: Int16, minGrouping: Int16): Grouper {
        if (Int32(grouping1) == -1) {
            return GROUPER_NEVER
        } else if (Int32(grouping1) == 3 && Int32(grouping2) == 3 && Int32(minGrouping) == 1) {
            return GROUPER_WESTERN
        } else if (Int32(grouping1) == 3 && Int32(grouping2) == 2 && Int32(minGrouping) == 1) {
            return GROUPER_INDIC
        } else if (Int32(grouping1) == 3 && Int32(grouping2) == 3 && Int32(minGrouping) == 2) {
            return GROUPER_WESTERN_MIN2
        } else if (Int32(grouping1) == 3 && Int32(grouping2) == 2 && Int32(minGrouping) == 2) {
            return GROUPER_INDIC_MIN2
        } else {
            return Grouper(grouping1, grouping2, minGrouping)
        }
    }

    private static func getMinGroupingForLocale(locale: ULocale): Int16 {
        let resource = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, locale)
        let result = resource.getStringWithFallback("NumberElements/minimumGroupingDigits")
        return parse<Int16>(result)
    }

    private let grouping1: Int16

    private let grouping2: Int16

    private let minGrouping: Int16

    private init(grouping1: Int16, grouping2: Int16, minGrouping: Int16) {
        this.grouping1 = grouping1
        this.grouping2 = grouping2
        this.minGrouping = minGrouping
    }

    public func withLocaleData(locale: ULocale, patternInfo: PatternStringParser_ParsedPatternInfo): Grouper {
        let minGrouping: Int16
        if (Int32(this.minGrouping) == -2) {
            minGrouping = getMinGroupingForLocale(locale)
        } else if (Int32(this.minGrouping) == -3) {
            minGrouping = Int16(Math.max(2, Int32(getMinGroupingForLocale(locale))))
        } else {
            minGrouping = this.minGrouping
        }
        if (Int32(this.grouping1) != -2 && Int32(this.grouping2) != -4) {
            if (minGrouping == this.minGrouping) {
                return this
            }
            return getInstance(this.grouping1, this.grouping2, minGrouping)
        }
        var grouping1 = Int16(patternInfo.positive.groupingSizes & 65535)
        var grouping2 = Int16((ushr(patternInfo.positive.groupingSizes, 16)) & 65535)
        let grouping3 = Int16((ushr(patternInfo.positive.groupingSizes, 32)) & 65535)
        if (Int32(grouping2) == -1) {
            grouping1 = if (Int32(this.grouping1) == -4) { 3i16 } else { -1i16 }
        }
        if (Int32(grouping3) == -1) {
            grouping2 = grouping1
        }
        return getInstance(grouping1, grouping2, minGrouping)
    }

    public func groupAtPosition(position: Int32, value: DecimalQuantity): Bool {
        var tempposition = position
        if (!(Int32(grouping1) != -2 && Int32(grouping1) != -4)) {
            throw AssertionError()
        }
        if (Int32(grouping1) == -1 || Int32(grouping1) == 0) {
            return false
        }
        tempposition -= Int32(grouping1)
        return tempposition >= 0 && (tempposition % Int32(grouping2)) == 0 && value.getUpperDisplayMagnitude() - Int32(grouping1) + 1 >= Int32(minGrouping)
    }

    public func getPrimary(): Int16 {
        return grouping1
    }

    public func getSecondary(): Int16 {
        return grouping2
    }
}
