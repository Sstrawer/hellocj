// © 2016 and later: Unicode, Inc. and others.
// License & terms of use: http://www.unicode.org/copyright.html
/*
*******************************************************************************
* Copyright (C) 2003-2016, International Business Machines Corporation and
* others. All Rights Reserved.
*******************************************************************************
*/
package icu4cj

/**
 * Field constant used to construct a FieldPosition object.
 */
public enum NumberFormatField {
    | INTEGER
    | FRACTION
    | EXPONENT
    | DECIMAL_SEPARATOR
    | GROUPING_SEPARATOR
    | PERCENT
    | CURRENCY
    | SIGN
}

/**
 * Format styles for number formatting.
 */
public enum NumberFormatStyle {
    | NUMBER_STYLE
    | CURRENCY_STYLE
    | PERCENT_STYLE
    | SCIENTIFIC_STYLE
    | INTEGER_STYLE
    | ISO_CURRENCY_STYLE
    | PLURAL_CURRENCY_STYLE
}

/**
 * NumberFormat is the abstract base class for all number formats.
 * This class provides the interface for formatting and parsing numbers.
 * NumberFormat also provides methods for determining which locales have
 * number formats, and what their names are.
 *
 * This is a simplified translation of com.ibm.icu.text.NumberFormat from Java to Cangjie.
 */
public open class NumberFormat <: UFormat {

    /**
     * The locale for this number format.
     */
    protected var locale: ULocale

    /**
     * Whether to parse integers only.
     */
    private var parseIntegerOnly: Bool

    /**
     * Maximum number of digits allowed in the integer portion of a number.
     */
    private var maximumIntegerDigits: Int64

    /**
     * Minimum number of digits allowed in the integer portion of a number.
     */
    private var minimumIntegerDigits: Int64

    /**
     * Maximum number of digits allowed in the fractional portion of a number.
     */
    private var maximumFractionDigits: Int64

    /**
     * Minimum number of digits allowed in the fractional portion of a number.
     */
    private var minimumFractionDigits: Int64

    /**
     * Whether to use grouping (thousands separators).
     */
    private var groupingUsed: Bool

    /**
     * Default constructor.
     */
    public init() {
        super()
        this.locale = ULocale.getDefault(Category.FORMAT)
        this.parseIntegerOnly = false
        this.maximumIntegerDigits = 40
        this.minimumIntegerDigits = 1
        this.maximumFractionDigits = 3
        this.minimumFractionDigits = 0
        this.groupingUsed = true
    }

    /**
     * Constructor with locale.
     */
    public init(locale: ULocale) {
        super()
        this.locale = locale
        this.parseIntegerOnly = false
        this.maximumIntegerDigits = 40
        this.minimumIntegerDigits = 1
        this.maximumFractionDigits = 3
        this.minimumFractionDigits = 0
        this.groupingUsed = true
    }

    /**
     * Formats a number and returns the result as a string.
     * @param number the number to format
     * @return the formatted string
     */
    public func format(number: Float64): String {
        let obj = NumberObject(number)
        return format(obj)
    }

    /**
     * Formats an integer and returns the result as a string.
     * @param number the integer to format
     * @return the formatted string
     */
    public func format(number: Int64): String {
        let obj = NumberObject(Float64(number))
        return format(obj)
    }

    /**
     * Formats a number and appends the result to a string builder.
     * @param number the number to format
     * @param toAppendTo the string builder to append to
     * @return the string builder
     */
    public func format(number: Float64, toAppendTo: StringBuilder): StringBuilder {
        let obj = NumberObject(number)
        return format(obj, toAppendTo)
    }

    /**
     * Formats an integer and appends the result to a string builder.
     * @param number the integer to format
     * @param toAppendTo the string builder to append to
     * @return the string builder
     */
    public func format(number: Int64, toAppendTo: StringBuilder): StringBuilder {
        let obj = NumberObject(Float64(number))
        return format(obj, toAppendTo)
    }

    /**
     * Parses a string to a number.
     * @param source the string to parse
     * @return the parsed number, or None if parsing failed
     */
    public func parseNumber(source: String): Option<Float64> {
        let result = parse(source)
        if (result.isSome()) {
            let obj = result.getOrThrow()
            if (obj is NumberObject) {
                // Parse the string value instead
                let str = obj.getValue()
                let parsed = NumberObject.parseFloat64Helper(str)
                if (parsed.isSome()) {
                    return parsed
                }
            }
        }
        return Option<Float64>.None
    }

    /**
     * Returns a general-purpose number format for the current default locale.
     */
    public static func getInstance(): NumberFormat {
        return DecimalFormat()
    }

    /**
     * Returns a general-purpose number format for the specified locale.
     */
    public static func getInstance(locale: ULocale): NumberFormat {
        return DecimalFormat(locale)
    }

    /**
     * Returns a general-purpose number format for the specified locale and style.
     */
    public static func getInstance(locale: ULocale, style: NumberFormatStyle): NumberFormat {
        return DecimalFormat(locale, style)
    }

    /**
     * Returns a currency format for the current default locale.
     */
    public static func getCurrencyInstance(): NumberFormat {
        return DecimalFormat(ULocale.getDefault(Category.FORMAT), NumberFormatStyle.CURRENCY_STYLE)
    }

    /**
     * Returns a currency format for the specified locale.
     */
    public static func getCurrencyInstance(locale: ULocale): NumberFormat {
        return DecimalFormat(locale, NumberFormatStyle.CURRENCY_STYLE)
    }

    /**
     * Returns a percentage format for the current default locale.
     */
    public static func getPercentInstance(): NumberFormat {
        return DecimalFormat(ULocale.getDefault(Category.FORMAT), NumberFormatStyle.PERCENT_STYLE)
    }

    /**
     * Returns a percentage format for the specified locale.
     */
    public static func getPercentInstance(locale: ULocale): NumberFormat {
        return DecimalFormat(locale, NumberFormatStyle.PERCENT_STYLE)
    }

    /**
     * Returns an integer format for the current default locale.
     */
    public static func getIntegerInstance(): NumberFormat {
        return DecimalFormat(ULocale.getDefault(Category.FORMAT), NumberFormatStyle.INTEGER_STYLE)
    }

    /**
     * Returns an integer format for the specified locale.
     */
    public static func getIntegerInstance(locale: ULocale): NumberFormat {
        return DecimalFormat(locale, NumberFormatStyle.INTEGER_STYLE)
    }

    // Getters and setters

    public func isParseIntegerOnly(): Bool {
        return parseIntegerOnly
    }

    public func setParseIntegerOnly(value: Bool): Unit {
        this.parseIntegerOnly = value
    }

    public func getMaximumIntegerDigits(): Int64 {
        return maximumIntegerDigits
    }

    public func setMaximumIntegerDigits(newValue: Int64): Unit {
        this.maximumIntegerDigits = if (newValue >= 0) { newValue } else { 0 }
    }

    public func getMinimumIntegerDigits(): Int64 {
        return minimumIntegerDigits
    }

    public func setMinimumIntegerDigits(newValue: Int64): Unit {
        this.minimumIntegerDigits = if (newValue >= 0) { newValue } else { 0 }
        if (minimumIntegerDigits > maximumIntegerDigits) {
            maximumIntegerDigits = minimumIntegerDigits
        }
    }

    public func getMaximumFractionDigits(): Int64 {
        return maximumFractionDigits
    }

    public func setMaximumFractionDigits(newValue: Int64): Unit {
        this.maximumFractionDigits = if (newValue >= 0) { newValue } else { 0 }
    }

    public func getMinimumFractionDigits(): Int64 {
        return minimumFractionDigits
    }

    public func setMinimumFractionDigits(newValue: Int64): Unit {
        this.minimumFractionDigits = if (newValue >= 0) { newValue } else { 0 }
        if (minimumFractionDigits > maximumFractionDigits) {
            maximumFractionDigits = minimumFractionDigits
        }
    }

    public func isGroupingUsed(): Bool {
        return groupingUsed
    }

    public func setGroupingUsed(newValue: Bool): Unit {
        this.groupingUsed = newValue
    }

    public func getLocale(): ULocale {
        return locale
    }

    /**
     * Returns a string representation of this NumberFormat.
     */
    public open func toString(): String {
        return "NumberFormat[locale=" + locale.toString() + "]"
    }

    /**
     * Returns true if this NumberFormat equals the other formatter.
     */
    public func equals(other: Option<NumberFormat>): Bool {
        if (other.isNone()) {
            return false
        }
        let otherFormat = other.getOrThrow()
        return locale.equals(Option.Some(otherFormat.locale)) &&
               parseIntegerOnly == otherFormat.parseIntegerOnly &&
               maximumIntegerDigits == otherFormat.maximumIntegerDigits &&
               minimumIntegerDigits == otherFormat.minimumIntegerDigits &&
               maximumFractionDigits == otherFormat.maximumFractionDigits &&
               minimumFractionDigits == otherFormat.minimumFractionDigits &&
               groupingUsed == otherFormat.groupingUsed
    }

    /**
     * Returns a hash code for this NumberFormat.
     */
    public func hashCode(): Int64 {
        var result: Int64 = 17
        result = result * 31 + locale.hashCode()
        result = result * 31 + (if (parseIntegerOnly) { 1 } else { 0 })
        result = result * 31 + maximumIntegerDigits
        result = result * 31 + minimumIntegerDigits
        result = result * 31 + maximumFractionDigits
        result = result * 31 + minimumFractionDigits
        result = result * 31 + (if (groupingUsed) { 1 } else { 0 })
        return result
    }
}

/**
 * A specific FormatObject for numbers.
 */
public class NumberObject <: FormatObject {
    private let number: Float64

    public init(number: Float64) {
        super(number.toString())
        this.number = number
    }

    public func getNumberValue(): Float64 {
        return number
    }

    public func getDoubleValue(): Float64 {
        return number
    }

    public func getIntValue(): Int64 {
        return Int64(number)
    }

    public func toString(): String {
        return number.toString()
    }

    public func equals(other: Option<NumberObject>): Bool {
        if (other.isNone()) {
            return false
        }
        let otherObj = other.getOrThrow()
        return number == otherObj.number
    }

    public func hashCode(): Int64 {
        // Simple hash for Float64
        let bits = if (number >= 0.0) { Int64(number * 1000000.0) } else { Int64(number * -1000000.0)         }
        return bits
    }

    /**
     * Simple Float64 parser helper.
     */
    public static func parseFloat64Helper(str: String): Option<Float64> {
        try {
            var result: Float64 = 0.0
            var isNegative = false
            var hasDecimal = false
            var decimalPlaces: Float64 = 1.0
            var i: Int64 = 0
            
            if (str.size == 0) {
                return Option<Float64>.None
            }
            
            // Check for negative sign
            if (str[0] == UInt8(45)) { // '-'
                isNegative = true
                i = 1
            }
            
            while (i < str.size) {
                let c = str[i]
                if (c >= UInt8(48) && c <= UInt8(57)) { // '0' to '9'
                    let digit = Int64(c) - 48
                    if (hasDecimal) {
                        decimalPlaces = decimalPlaces * 10.0
                        result = result + Float64(digit) / decimalPlaces
                    } else {
                        result = result * 10.0 + Float64(digit)
                    }
                } else if (c == UInt8(46)) { // '.'
                    if (hasDecimal) {
                        return Option<Float64>.None // Multiple decimal points
                    }
                    hasDecimal = true
                } else {
                    return Option<Float64>.None // Invalid character
                }
                i++
            }
            
            if (isNegative) {
                result = -result
            }
            
            return Option<Float64>.Some(result)
        } catch (e: Exception) {
            return Option<Float64>.None
        }
    }
}
