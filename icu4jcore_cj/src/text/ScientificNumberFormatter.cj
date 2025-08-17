package icu4cj.text


public class ScientificNumberFormatter {
    private let preExponent: String

    private let fmt: DecimalFormat

    private let style: ScientificNumberFormatter_Style

    public static func getSuperscriptInstance(locale: ULocale): ScientificNumberFormatter {
        return getInstanceForLocale(locale, SUPER_SCRIPT)
    }

    public static func getSuperscriptInstance(df: DecimalFormat): ScientificNumberFormatter {
        return getInstance(df, SUPER_SCRIPT)
    }

    public static func getMarkupInstance(locale: ULocale, beginMarkup: String, endMarkup: String): ScientificNumberFormatter {
        return getInstanceForLocale(locale, ScientificNumberFormatter_MarkupStyle(beginMarkup, endMarkup))
    }

    public static func getMarkupInstance(df: DecimalFormat, beginMarkup: String, endMarkup: String): ScientificNumberFormatter {
        return getInstance(df, ScientificNumberFormatter_MarkupStyle(beginMarkup, endMarkup))
    }

    public func format(number: Object): String {
        synchronized (getMonitorByObject(fmt)) {
            return style.format(fmt.formatToCharacterIterator(number), preExponent)
        }
    }

    private static func getPreExponent(dfs: DecimalFormatSymbols): String {
        let preExponent = StringBuilder()
        preExponent.append(dfs.getExponentMultiplicationSign())
        let digits = dfs.getDigits()
        preExponent.append(digits[1]).append(digits[0])
        return preExponent.toString()
    }

    private static func getInstance(decimalFormat: DecimalFormat, style: ScientificNumberFormatter_Style): ScientificNumberFormatter {
        let dfs = decimalFormat.getDecimalFormatSymbols()
        return ScientificNumberFormatter(decimalFormat.clone(), getPreExponent(dfs), style)
    }

    private static func getInstanceForLocale(locale: ULocale, style: ScientificNumberFormatter_Style): ScientificNumberFormatter {
        let decimalFormat = DecimalFormat.getScientificInstance(locale)
        return ScientificNumberFormatter(decimalFormat, getPreExponent(decimalFormat.getDecimalFormatSymbols()), style)
    }

    private static let SUPER_SCRIPT: ScientificNumberFormatter_Style = ScientificNumberFormatter_SuperscriptStyle()

    private init(decimalFormat: DecimalFormat, preExponent: String, style: ScientificNumberFormatter_Style) {
        this.fmt = decimalFormat
        this.preExponent = preExponent
        this.style = style
    }
}


abstract class ScientificNumberFormatter_Style {

    public func format(iterator: AttributedCharacterIterator, preExponent: String): String

    static func append(iterator: AttributedCharacterIterator, start: Int32, limit: Int32, result: StringBuilder): Unit {
        let oldIndex = iterator.getIndex()
        iterator.setIndex(start)
        var i = start
        while (i < limit) {
            result.append(iterator.current())
            iterator.next()
            i++
        }
        iterator.setIndex(oldIndex)
    }
}


class ScientificNumberFormatter_MarkupStyle <: ScientificNumberFormatter_Style {
    private let beginMarkup: String

    private let endMarkup: String

    init(beginMarkup: String, endMarkup: String) {
        super()
        this.beginMarkup = beginMarkup
        this.endMarkup = endMarkup
    }

    public override func format(iterator: AttributedCharacterIterator, preExponent: String): String {
        var copyFromOffset = 0
        let result = StringBuilder()
        iterator.first()
        while (iterator.current() != CharacterIterator.DONE) {
            let attributeSet = iterator.getAttributes()
            if (attributeSet.contains(NumberFormat_Field.EXPONENT_SYMBOL)) {
                append(iterator, copyFromOffset, iterator.getRunStart(NumberFormat_Field.EXPONENT_SYMBOL), result)
                copyFromOffset = iterator.getRunLimit(NumberFormat_Field.EXPONENT_SYMBOL)
                iterator.setIndex(copyFromOffset)
                result.append(preExponent)
                result.append(beginMarkup)
            } else if (attributeSet.contains(NumberFormat_Field.EXPONENT)) {
                let limit = iterator.getRunLimit(NumberFormat_Field.EXPONENT)
                append(iterator, copyFromOffset, limit, result)
                copyFromOffset = limit
                iterator.setIndex(copyFromOffset)
                result.append(endMarkup)
            } else {
                iterator.next()
            }
        }
        append(iterator, copyFromOffset, iterator.getEndIndex(), result)
        return result.toString()
    }
}


class ScientificNumberFormatter_SuperscriptStyle <: ScientificNumberFormatter_Style {
    init() {
        super()
    }

    private static let SUPERSCRIPT_DIGITS: Array<Char> = [Char(8304), Char(185), Char(178), Char(179), Char(8308), Char(8309), Char(8310), Char(8311), Char(8312), Char(8313)]

    private static let SUPERSCRIPT_PLUS_SIGN = Char(8314)

    private static let SUPERSCRIPT_MINUS_SIGN = Char(8315)

    public override func format(iterator: AttributedCharacterIterator, preExponent: String): String {
        var copyFromOffset = 0
        let result = StringBuilder()
        iterator.first()
        while (iterator.current() != CharacterIterator.DONE) {
            let attributeSet = iterator.getAttributes()
            if (attributeSet.contains(NumberFormat_Field.EXPONENT_SYMBOL)) {
                append(iterator, copyFromOffset, iterator.getRunStart(NumberFormat_Field.EXPONENT_SYMBOL), result)
                copyFromOffset = iterator.getRunLimit(NumberFormat_Field.EXPONENT_SYMBOL)
                iterator.setIndex(copyFromOffset)
                result.append(preExponent)
            } else if (attributeSet.contains(NumberFormat_Field.EXPONENT_SIGN)) {
                let start = iterator.getRunStart(NumberFormat_Field.EXPONENT_SIGN)
                let limit = iterator.getRunLimit(NumberFormat_Field.EXPONENT_SIGN)
                let aChar = char32AtAndAdvance(iterator)
                if (StaticUnicodeSets.get(StaticUnicodeSets_Key.MINUS_SIGN).contains(aChar)) {
                    append(iterator, copyFromOffset, start, result)
                    result.append(SUPERSCRIPT_MINUS_SIGN)
                } else if (StaticUnicodeSets.get(StaticUnicodeSets_Key.PLUS_SIGN).contains(aChar)) {
                    append(iterator, copyFromOffset, start, result)
                    result.append(SUPERSCRIPT_PLUS_SIGN)
                } else {
                    throw IllegalArgumentException()
                }
                copyFromOffset = limit
                iterator.setIndex(copyFromOffset)
            } else if (attributeSet.contains(NumberFormat_Field.EXPONENT)) {
                let start = iterator.getRunStart(NumberFormat_Field.EXPONENT)
                let limit = iterator.getRunLimit(NumberFormat_Field.EXPONENT)
                append(iterator, copyFromOffset, start, result)
                copyAsSuperscript(iterator, start, limit, result)
                copyFromOffset = limit
                iterator.setIndex(copyFromOffset)
            } else {
                iterator.next()
            }
        }
        append(iterator, copyFromOffset, iterator.getEndIndex(), result)
        return result.toString()
    }

    private static func copyAsSuperscript(iterator: AttributedCharacterIterator, start: Int32, limit: Int32, result: StringBuilder): Unit {
        let oldIndex = iterator.getIndex()
        iterator.setIndex(start)
        while (iterator.getIndex() < limit) {
            let aChar = char32AtAndAdvance(iterator)
            let digit = UCharacter.digit(aChar)
            if (digit < 0) {
                throw IllegalArgumentException()
            }
            result.append(SUPERSCRIPT_DIGITS[Int64(digit)])
        }
        iterator.setIndex(oldIndex)
    }

    private static func char32AtAndAdvance(iterator: AttributedCharacterIterator): Int32 {
        let c1 = iterator.current()
        let c2 = iterator.next()
        if (UCharacter.isHighSurrogate(Int32(UInt32(c1)))) {
            if (UCharacter.isLowSurrogate(Int32(UInt32(c2)))) {
                iterator.next()
                return UCharacter.toCodePoint(Int32(UInt32(c1)), Int32(UInt32(c2)))
            }
        }
        return Int32(UInt32(c1))
    }
}
