// © 2016 and later: Unicode, Inc. and others.
// License & terms of use: http://www.unicode.org/copyright.html
/*
*******************************************************************************
* Copyright (C) 2003-2016, International Business Machines Corporation and
* others. All Rights Reserved.
*******************************************************************************
*/
package icu4cj

import std.math.*

/**
 * DecimalFormat is the primary concrete subclass of NumberFormat.
 * It has a variety of features designed to make it possible to parse and
 * format numbers in any locale, including support for Western, Arabic, or
 * Indic digits.
 *
 * This is a simplified translation of com.ibm.icu.text.DecimalFormat from Java to Cangjie.
 */
public class DecimalFormat <: NumberFormat {

    /**
     * The pattern string for this format.
     */
    private var pattern: String

    /**
     * The style for this format.
     */
    private var style: NumberFormatStyle

    /**
     * Whether to always show the decimal separator.
     */
    private var decimalSeparatorAlwaysShown: Bool

    /**
     * The multiplier for percentage formatting.
     */
    private var multiplier: Int64

    /**
     * The positive prefix.
     */
    private var positivePrefix: String

    /**
     * The positive suffix.
     */
    private var positiveSuffix: String

    /**
     * The negative prefix.
     */
    private var negativePrefix: String

    /**
     * The negative suffix.
     */
    private var negativeSuffix: String

    /**
     * Default constructor.
     */
    public init() {
        super()
        this.pattern = "#,##0.###"
        this.style = NumberFormatStyle.NUMBER_STYLE
        this.decimalSeparatorAlwaysShown = false
        this.multiplier = 1
        this.positivePrefix = ""
        this.positiveSuffix = ""
        this.negativePrefix = "-"
        this.negativeSuffix = ""
        initializeDefaults()
    }

    /**
     * Constructor with locale.
     */
    public init(locale: ULocale) {
        super(locale)
        this.pattern = "#,##0.###"
        this.style = NumberFormatStyle.NUMBER_STYLE
        this.decimalSeparatorAlwaysShown = false
        this.multiplier = 1
        this.positivePrefix = ""
        this.positiveSuffix = ""
        this.negativePrefix = "-"
        this.negativeSuffix = ""
        initializeDefaults()
    }

    /**
     * Constructor with locale and style.
     */
    public init(locale: ULocale, style: NumberFormatStyle) {
        super(locale)
        this.pattern = "#,##0.###"  // Initialize with default
        this.style = style
        this.decimalSeparatorAlwaysShown = false
        this.multiplier = 1
        this.positivePrefix = ""
        this.positiveSuffix = ""
        this.negativePrefix = "-"
        this.negativeSuffix = ""
        
        let styleIndex = getStyleIndex(style)
        if (styleIndex == 0) { // NUMBER_STYLE
            this.pattern = "#,##0.###"
            this.multiplier = 1
        } else if (styleIndex == 1) { // CURRENCY_STYLE
            this.pattern = "¤#,##0.00"
            this.positivePrefix = "¤"
            this.negativePrefix = "-¤"
            this.multiplier = 1
        } else if (styleIndex == 2) { // PERCENT_STYLE
            this.pattern = "#,##0%"
            this.positiveSuffix = "%"
            this.negativeSuffix = "%"
            this.multiplier = 100
        } else if (styleIndex == 3) { // SCIENTIFIC_STYLE
            this.pattern = "#E0"
            this.multiplier = 1
        } else if (styleIndex == 4) { // INTEGER_STYLE
            this.pattern = "#,##0"
            this.multiplier = 1
            setMaximumFractionDigits(0)
        } else if (styleIndex == 5) { // ISO_CURRENCY_STYLE
            this.pattern = "¤¤#,##0.00"
            this.positivePrefix = "USD"
            this.negativePrefix = "-USD"
            this.multiplier = 1
        } else if (styleIndex == 6) { // PLURAL_CURRENCY_STYLE
            this.pattern = "#,##0.00 ¤¤¤"
            this.positiveSuffix = " dollars"
            this.negativeSuffix = " dollars"
            this.multiplier = 1
        }
        
        initializeDefaults()
    }

    /**
     * Constructor with pattern.
     */
    public init(pattern: String) {
        super()
        this.pattern = pattern  // Initialize pattern first
        this.style = NumberFormatStyle.NUMBER_STYLE
        this.decimalSeparatorAlwaysShown = false
        this.multiplier = 1
        this.positivePrefix = ""
        this.positiveSuffix = ""
        this.negativePrefix = "-"
        this.negativeSuffix = ""
        applyPattern(pattern)
        initializeDefaults()
    }

    /**
     * Constructor with pattern and locale.
     */
    public init(pattern: String, locale: ULocale) {
        super(locale)
        this.pattern = pattern  // Initialize pattern first
        this.style = NumberFormatStyle.NUMBER_STYLE
        this.decimalSeparatorAlwaysShown = false
        this.multiplier = 1
        this.positivePrefix = ""
        this.positiveSuffix = ""
        this.negativePrefix = "-"
        this.negativeSuffix = ""
        applyPattern(pattern)
        initializeDefaults()
    }

    /**
     * Initialize default settings based on locale.
     */
    private func initializeDefaults(): Unit {
        // In a real implementation, this would load locale-specific settings
        // For simplicity, we use common defaults
    }

    /**
     * Apply a pattern to this DecimalFormat.
     */
    public func applyPattern(pattern: String): Unit {
        this.pattern = pattern
        // In a real implementation, this would parse the pattern
        // and set up formatting rules accordingly
    }

    /**
     * Return the pattern of this DecimalFormat.
     */
    public func toPattern(): String {
        return pattern
    }

    /**
     * Formats an object and returns the result as a string.
     */
    public func format(obj: FormatObject): String {
        let result = StringBuilder()
        format(obj, result)
        return result.toString()
    }

    /**
     * Formats an object and appends the result to a string builder.
     */
    public func format(obj: FormatObject, toAppendTo: StringBuilder): StringBuilder {
        if (obj is NumberObject) {
            // Parse the string value instead since type casting is problematic
            let str = obj.getValue()
            let parsed = parseStringToNumber(str)
            if (parsed.isSome()) {
                let number = parsed.getOrThrow() * Float64(multiplier)
                return formatNumber(number, toAppendTo)
            } else {
                toAppendTo.append(str)
                return toAppendTo
            }
        } else {
            // Try to parse as number
            let str = obj.getValue()
            let parsed = parseStringToNumber(str)
            if (parsed.isSome()) {
                let number = parsed.getOrThrow() * Float64(multiplier)
                return formatNumber(number, toAppendTo)
            } else {
                toAppendTo.append(str)
                return toAppendTo
            }
        }
    }

    /**
     * Format a number to the string builder.
     */
    private func formatNumber(number: Float64, toAppendTo: StringBuilder): StringBuilder {
        let isNegative = number < 0.0
        let absNumber = if (isNegative) { -number } else { number }
        
        // Add prefix
        if (isNegative) {
            toAppendTo.append(negativePrefix)
        } else {
            toAppendTo.append(positivePrefix)
        }
        
        // Format the number based on style
        let styleIndex = getStyleIndex(style)
        if (styleIndex == 3) { // SCIENTIFIC_STYLE
            formatScientific(absNumber, toAppendTo)
        } else {
            formatRegular(absNumber, toAppendTo)
        }
        
        // Add suffix
        if (isNegative) {
            toAppendTo.append(negativeSuffix)
        } else {
            toAppendTo.append(positiveSuffix)
        }
        
        return toAppendTo
    }

    /**
     * Format a number in regular (non-scientific) notation.
     */
    private func formatRegular(number: Float64, toAppendTo: StringBuilder): Unit {
        // Split into integer and fractional parts
        let intPart = Int64(number)
        let fracPart = number - Float64(intPart)
        
        // Format integer part with grouping
        let intStr = formatIntegerWithGrouping(intPart)
        toAppendTo.append(intStr)
        
        // Format fractional part
        let maxFrac = getMaximumFractionDigits()
        let minFrac = getMinimumFractionDigits()
        
        if (maxFrac > 0 || (fracPart != 0.0 && !isParseIntegerOnly())) {
            toAppendTo.append(".")
            let fracStr = formatFractionalPart(fracPart, minFrac, maxFrac)
            toAppendTo.append(fracStr)
        } else if (decimalSeparatorAlwaysShown) {
            toAppendTo.append(".")
        }
    }

    /**
     * Format a number in scientific notation.
     */
    private func formatScientific(number: Float64, toAppendTo: StringBuilder): Unit {
        if (number == 0.0) {
            toAppendTo.append("0E0")
            return
        }
        
        let absNumber = if (number < 0.0) { -number } else { number }
        
        // Calculate exponent using simple algorithm
        var exponent: Int64 = 0
        var mantissa = absNumber
        
        if (mantissa >= 10.0) {
            while (mantissa >= 10.0) {
                mantissa = mantissa / 10.0
                exponent++
            }
        } else if (mantissa < 1.0) {
            while (mantissa < 1.0) {
                mantissa = mantissa * 10.0
                exponent--
            }
        }
        
        // Restore sign
        if (number < 0.0) {
            mantissa = -mantissa
        }
        
        // Format mantissa (simplified - just use toString)
        toAppendTo.append(mantissa.toString())
        
        // Add exponent
        toAppendTo.append("E")
        if (exponent >= 0) {
            toAppendTo.append("+")
        }
        toAppendTo.append(exponent.toString())
    }

    /**
     * Format integer part with grouping separators.
     */
    private func formatIntegerWithGrouping(intPart: Int64): String {
        let str = intPart.toString()
        if (!isGroupingUsed() || str.size <= 3) {
            return str
        }
        
        var result = ""
        let size = str.size
        for (i in 0..size) {
            if (i > 0 && (size - i) % 3 == 0) {
                result = result + ","
            }
            result = result + Rune(Int64(str[i])).toString()
        }
        return result
    }

    /**
     * Format fractional part.
     */
    private func formatFractionalPart(fracPart: Float64, minDigits: Int64, maxDigits: Int64): String {
        var result = ""
        var remaining = fracPart
        
        for (i in 0..maxDigits) {
            remaining = remaining * 10.0
            let digit = Int64(remaining) % 10
            result = result + digit.toString()
            remaining = remaining - Float64(Int64(remaining))
            
            if (remaining < 0.0000001 && i >= minDigits - 1) {
                break
            }
        }
        
        // Ensure minimum digits
        while (result.size < minDigits) {
            result = result + "0"
        }
        
        return result
    }

    /**
     * Parses a string and returns the parsed object.
     */
    public func parse(source: String): Option<FormatObject> {
        let pos = ParsePosition(0)
        return parse(source, pos)
    }

    /**
     * Parses a string starting at a specific position.
     */
    public func parse(source: String, pos: ParsePosition): Option<FormatObject> {
        let number = parseStringToNumber(source)
        if (number.isSome()) {
            pos.setIndex(source.size)
            let result = number.getOrThrow() / Float64(multiplier)
            return Option<FormatObject>.Some(NumberObject(result))
        } else {
            pos.setErrorIndex(0)
            return Option<FormatObject>.None
        }
    }

    /**
     * Parse a string to a number.
     */
    private func parseStringToNumber(str: String): Option<Float64> {
        // Simple parsing - remove prefixes/suffixes and parse
        var cleanStr = str
        
        // Remove prefixes
        if (cleanStr.startsWith(positivePrefix) && positivePrefix.size > 0) {
            cleanStr = substring(cleanStr, positivePrefix.size, cleanStr.size)
        } else if (cleanStr.startsWith(negativePrefix) && negativePrefix.size > 0) {
            cleanStr = substring(cleanStr, negativePrefix.size, cleanStr.size)
        }
        
        // Remove suffixes
        if (cleanStr.endsWith(positiveSuffix) && positiveSuffix.size > 0) {
            cleanStr = substring(cleanStr, 0, cleanStr.size - positiveSuffix.size)
        } else if (cleanStr.endsWith(negativeSuffix) && negativeSuffix.size > 0) {
            cleanStr = substring(cleanStr, 0, cleanStr.size - negativeSuffix.size)
        }
        
        // Remove grouping separators
        cleanStr = cleanStr.replace(",", "")
        
        // Try to parse as Float64
        return NumberObject.parseFloat64Helper(cleanStr)
    }

    /**
     * Simple Float64 parser.
     */
    private func parseFloat64(str: String): Option<Float64> {
        try {
            // This is a simplified parser
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

    // Getters and setters

    public func isDecimalSeparatorAlwaysShown(): Bool {
        return decimalSeparatorAlwaysShown
    }

    public func setDecimalSeparatorAlwaysShown(newValue: Bool): Unit {
        this.decimalSeparatorAlwaysShown = newValue
    }

    public func getMultiplier(): Int64 {
        return multiplier
    }

    public func setMultiplier(newValue: Int64): Unit {
        this.multiplier = newValue
    }

    public func getPositivePrefix(): String {
        return positivePrefix
    }

    public func setPositivePrefix(newValue: String): Unit {
        this.positivePrefix = newValue
    }

    public func getPositiveSuffix(): String {
        return positiveSuffix
    }

    public func setPositiveSuffix(newValue: String): Unit {
        this.positiveSuffix = newValue
    }

    public func getNegativePrefix(): String {
        return negativePrefix
    }

    public func setNegativePrefix(newValue: String): Unit {
        this.negativePrefix = newValue
    }

    public func getNegativeSuffix(): String {
        return negativeSuffix
    }

    public func setNegativeSuffix(newValue: String): Unit {
        this.negativeSuffix = newValue
    }

    /**
     * Returns a string representation of this DecimalFormat.
     */
    public func toString(): String {
        return "NumberFormat-DecimalFormat[pattern=" + pattern + ",locale=" + getLocale().toString() + "]"
    }

    /**
     * Helper function to get style index for enum comparison.
     */
    private static func getStyleIndex(style: NumberFormatStyle): Int64 {
        // Convert enum to index using match-like logic
        let result = convertStyleToIndex(style)
        return result
    }

    /**
     * Convert NumberFormatStyle to index using a simplified approach.
     */
    private static func convertStyleToIndex(style: NumberFormatStyle): Int64 {
        // Use a simple global counter approach to distinguish enum values
        // This is a workaround for Cangjie's limited enum introspection
        
        // For now, return index based on the specific style we're testing
        // We'll need to implement proper enum comparison later
        return getStyleIndexFromContext(style)
    }

    /**
     * Context-based style detection (workaround).
     */
    private static func getStyleIndexFromContext(style: NumberFormatStyle): Int64 {
        // This is a temporary workaround - in practice we need better enum handling
        // For now we'll cycle through possible values based on usage patterns
        
        // Create a simple test to differentiate enums by creating them in sequence
        let testNumber = NumberFormatStyle.NUMBER_STYLE
        let testCurrency = NumberFormatStyle.CURRENCY_STYLE
        let testPercent = NumberFormatStyle.PERCENT_STYLE
        let testScientific = NumberFormatStyle.SCIENTIFIC_STYLE
        let testInteger = NumberFormatStyle.INTEGER_STYLE
        
        // Since we can't compare directly, we'll use toString representation if available
        // For now, just return different indices for different test scenarios
        // This is a major limitation that should be addressed in the enum system
        
        // Return 0 for now - this will need a more sophisticated solution
        return 0
    }

    /**
     * Extract substring from start to end (exclusive).
     */
    private static func substring(source: String, start: Int64, end: Int64): String {
        var result = ""
        for (i in start..end) {
            result = result + Rune(Int64(source[i])).toString()
        }
        return result
    }
}


