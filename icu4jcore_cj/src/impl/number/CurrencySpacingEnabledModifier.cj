package icu4cj.impl.number

public class CurrencySpacingEnabledModifier <: ConstantMultiFieldModifier {
    private static let UNISET_DIGIT = UnicodeSet("[:digit:]").freeze()

    private static let UNISET_NOTSZ = UnicodeSet("[[:^S:]&[:^Z:]]").freeze()

    static let PREFIX = 0u8

    static let SUFFIX = 1u8

    static let IN_CURRENCY = 0i16

    static let IN_NUMBER = 1i16

    private let afterPrefixUnicodeSet: UnicodeSet

    private let afterPrefixInsert: String

    private let beforeSuffixUnicodeSet: UnicodeSet

    private let beforeSuffixInsert: String

    public init(prefix: FormattedStringBuilder, suffix: FormattedStringBuilder, overwrite: Bool, strong: Bool, symbols: DecimalFormatSymbols) {
        super(prefix, suffix, overwrite, strong)
        if (prefix.lengthMethod() > 0 && refEq(prefix.fieldAt(prefix.lengthMethod() - 1), NumberFormat_Field.CURRENCY)) {
            let prefixCp = prefix.getLastCodePoint()
            let prefixUnicodeSet = getUnicodeSet(symbols, IN_CURRENCY, PREFIX)
            if (prefixUnicodeSet.contains(prefixCp)) {
                afterPrefixUnicodeSet = getUnicodeSet(symbols, IN_NUMBER, PREFIX)
                afterPrefixUnicodeSet.freeze()
                afterPrefixInsert = getInsertString(symbols, PREFIX)
            } else {
                afterPrefixUnicodeSet = None
                afterPrefixInsert = None
            }
        } else {
            afterPrefixUnicodeSet = None
            afterPrefixInsert = None
        }
        if (suffix.lengthMethod() > 0 && refEq(suffix.fieldAt(0), NumberFormat_Field.CURRENCY)) {
            let suffixCp = suffix.getFirstCodePoint()
            let suffixUnicodeSet = getUnicodeSet(symbols, IN_CURRENCY, SUFFIX)
            if (suffixUnicodeSet.contains(suffixCp)) {
                beforeSuffixUnicodeSet = getUnicodeSet(symbols, IN_NUMBER, SUFFIX)
                beforeSuffixUnicodeSet.freeze()
                beforeSuffixInsert = getInsertString(symbols, SUFFIX)
            } else {
                beforeSuffixUnicodeSet = None
                beforeSuffixInsert = None
            }
        } else {
            beforeSuffixUnicodeSet = None
            beforeSuffixInsert = None
        }
    }

    public override func apply(output: FormattedStringBuilder, leftIndex: Int32, rightIndex: Int32): Int32 {
        var length = 0
        if (rightIndex - leftIndex > 0 && afterPrefixUnicodeSet.isSome() && afterPrefixUnicodeSet.contains(output.codePointAt(leftIndex))) {
            length += output.insert(leftIndex, afterPrefixInsert, None)
        }
        if (rightIndex - leftIndex > 0 && beforeSuffixUnicodeSet.isSome() && beforeSuffixUnicodeSet.contains(output.codePointBefore(rightIndex))) {
            length += output.insert(rightIndex + length, beforeSuffixInsert, None)
        }
        length += super.apply(output, leftIndex, rightIndex + length)
        return length
    }

    public static func applyCurrencySpacing(output: FormattedStringBuilder, prefixStart: Int32, prefixLen: Int32, suffixStart: Int32, suffixLen: Int32, symbols: DecimalFormatSymbols): Int32 {
        var length = 0
        let hasPrefix = (prefixLen > 0)
        let hasSuffix = (suffixLen > 0)
        let hasNumber = (suffixStart - prefixStart - prefixLen > 0)
        if (hasPrefix && hasNumber) {
            length += applyCurrencySpacingAffix(output, prefixStart + prefixLen, PREFIX, symbols)
        }
        if (hasSuffix && hasNumber) {
            length += applyCurrencySpacingAffix(output, suffixStart + length, SUFFIX, symbols)
        }
        return length
    }

    private static func applyCurrencySpacingAffix(output: FormattedStringBuilder, index: Int32, affix: UInt8, symbols: DecimalFormatSymbols): Int32 {
        let affixField = if (affix == PREFIX) { output.fieldAt(index - 1) } else { output.fieldAt(index) }
        if (!refEq(affixField, NumberFormat_Field.CURRENCY)) {
            return 0
        }
        let affixCp = if (affix == PREFIX) { output.codePointBefore(index) } else { output.codePointAt(index) }
        let affixUniset = getUnicodeSet(symbols, IN_CURRENCY, affix)
        if (!affixUniset.contains(affixCp)) {
            return 0
        }
        let numberCp = if (affix == PREFIX) { output.codePointAt(index) } else { output.codePointBefore(index) }
        let numberUniset = getUnicodeSet(symbols, IN_NUMBER, affix)
        if (!numberUniset.contains(numberCp)) {
            return 0
        }
        let spacingString = getInsertString(symbols, affix)
        return output.insert(index, spacingString, None)
    }

    private static func getUnicodeSet(symbols: DecimalFormatSymbols, position: Int16, affix: UInt8): UnicodeSet {
        let pattern = symbols.getPatternForCurrencySpacing(if (position == IN_CURRENCY) { DecimalFormatSymbols.CURRENCY_SPC_CURRENCY_MATCH } else { DecimalFormatSymbols.CURRENCY_SPC_SURROUNDING_MATCH }, affix == SUFFIX)
        if (pattern == "[:digit:]") {
            return UNISET_DIGIT
        } else if (pattern == "[[:^S:]&[:^Z:]]") {
            return UNISET_NOTSZ
        } else {
            return UnicodeSet(pattern)
        }
    }

    private static func getInsertString(symbols: DecimalFormatSymbols, affix: UInt8): String {
        return symbols.getPatternForCurrencySpacing(DecimalFormatSymbols.CURRENCY_SPC_INSERT, affix == SUFFIX)
    }
}
