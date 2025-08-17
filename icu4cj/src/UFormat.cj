// © 2016 and later: Unicode, Inc. and others.
// License & terms of use: http://www.unicode.org/copyright.html
/*
*******************************************************************************
* Copyright (C) 2003-2015, International Business Machines Corporation and
* others. All Rights Reserved.
*******************************************************************************
*/
package icu4cj

/**
 * Enum for locale type information.
 */
public enum LocaleType {
    /**
     * Selector for getLocale() indicating the valid locale.
     */
    | VALID_LOCALE

    /**
     * Selector for getLocale() indicating the actual locale.
     */
    | ACTUAL_LOCALE
}

/**
 * A field that represents a span of text that may be composed with other fields.
 * SpanField classes usually have an associated value.
 */
public class SpanField {
    private let name: String

    /**
     * Construct a new instance.
     */
    protected init(name: String) {
        this.name = name
    }

    /**
     * Get the name of this field.
     */
    public func getName(): String {
        return name
    }

    /**
     * Returns a string representation of this field.
     */
    public func toString(): String {
        return name
    }

    /**
     * Returns true if this field equals the other field.
     */
    public func equals(other: Option<SpanField>): Bool {
        if (other.isNone()) {
            return false
        }
        let otherField = other.getOrThrow()
        return name == otherField.name
    }

    /**
     * Returns a hash code for this field.
     */
    public func hashCode(): Int64 {
        var hash: Int64 = 0
        let size = name.size
        for (i in 0..size) {
            hash = hash * 31 + Int64(name[i])
        }
        return hash
    }
}

/**
 * A general object type that can be formatted.
 */
public open class FormatObject {
    private let value: String

    public init(value: String) {
        this.value = value
    }

    public func getValue(): String {
        return value
    }

    public open func toString(): String {
        return value
    }

    public func equals(other: Option<FormatObject>): Bool {
        if (other.isNone()) {
            return false
        }
        let otherObj = other.getOrThrow()
        return value == otherObj.value
    }

    public open func hashCode(): Int64 {
        var hash: Int64 = 0
        let size = value.size
        for (i in 0..size) {
            hash = hash * 31 + Int64(value[i])
        }
        return hash
    }
}

/**
 * A simple string builder utility for formatting.
 */
public class StringBuilder {
    private var buffer: String

    public init() {
        this.buffer = ""
    }

    public init(initial: String) {
        this.buffer = initial
    }

    public func append(str: String): StringBuilder {
        buffer = buffer + str
        return this
    }

    public func append(ch: Int64): StringBuilder {
        buffer = buffer + Rune(ch).toString()
        return this
    }

    public func toString(): String {
        return buffer
    }

    public func length(): Int64 {
        return buffer.size
    }

    public func clear(): Unit {
        buffer = ""
    }

    public func equals(other: Option<StringBuilder>): Bool {
        if (other.isNone()) {
            return false
        }
        let otherBuilder = other.getOrThrow()
        return buffer == otherBuilder.buffer
    }

    public func hashCode(): Int64 {
        var hash: Int64 = 0
        let size = buffer.size
        for (i in 0..size) {
            hash = hash * 31 + Int64(buffer[i])
        }
        return hash
    }
}

/**
 * A class to track position during parsing.
 */
public class ParsePosition {
    private var index: Int64
    private var errorIndex: Int64

    public init(index: Int64) {
        this.index = index
        this.errorIndex = -1
    }

    public func getIndex(): Int64 {
        return index
    }

    public func setIndex(index: Int64): Unit {
        this.index = index
    }

    public func getErrorIndex(): Int64 {
        return errorIndex
    }

    public func setErrorIndex(errorIndex: Int64): Unit {
        this.errorIndex = errorIndex
    }

    public func toString(): String {
        return "ParsePosition[index=" + index.toString() + ",errorIndex=" + errorIndex.toString() + "]"
    }

    public func equals(other: Option<ParsePosition>): Bool {
        if (other.isNone()) {
            return false
        }
        let otherPos = other.getOrThrow()
        return index == otherPos.index && errorIndex == otherPos.errorIndex
    }

    public func hashCode(): Int64 {
        return index * 31 + errorIndex
    }
}

/**
 * An abstract class that provides additional ICU protocol, specifically, 
 * the getLocale() API. All ICU format classes are subclasses of this class.
 *
 * This is a simplified translation of com.ibm.icu.text.UFormat from Java to Cangjie.
 */
public open class UFormat {

    /**
     * The most specific locale containing any resource data, or null.
     */
    private var validLocale: Option<ULocale>

    /**
     * The locale containing data used to construct this object, or null.
     */
    private var actualLocale: Option<ULocale>

    /**
     * Default constructor.
     */
    public init() {
        this.validLocale = Option<ULocale>.None
        this.actualLocale = Option<ULocale>.None
    }

    /**
     * Return the locale that was used to create this object, or null.
     * This may differ from the locale requested at the time of
     * this object's creation. For example, if an object is created
     * for locale en_US_CALIFORNIA, the actual data may be
     * drawn from en (the actual locale), and
     * en_US may be the most specific locale that exists (the
     * valid locale).
     *
     * @param localeType type of information requested, either VALID_LOCALE or ACTUAL_LOCALE.
     * @return the information specified by localeType, or null if
     * this object was not constructed from locale data.
     */
    public func getLocale(localeType: LocaleType): Option<ULocale> {
        match (localeType) {
            case ACTUAL_LOCALE => return actualLocale
            case VALID_LOCALE => return validLocale
        }
    }

    /**
     * Set information about the locales that were used to create this
     * object. If the object was not constructed from locale data,
     * both arguments should be set to null. Otherwise, neither
     * should be null. The actual locale must be at the same level or
     * less specific than the valid locale. This method is intended
     * for use by factories or other entities that create objects of
     * this class.
     * @param valid the most specific locale containing any resource
     * data, or null
     * @param actual the locale containing data used to construct this
     * object, or null
     */
    public func setLocale(valid: Option<ULocale>, actual: Option<ULocale>): Unit {
        // Validate that both are null or both are non-null
        if (valid.isSome() != actual.isSome()) {
            throw Exception("Both valid and actual locales must be null or both must be non-null")
        }
        this.validLocale = valid
        this.actualLocale = actual
    }

    /**
     * Format an object and return the result as a string.
     * This method should be overridden by concrete subclasses.
     */
    public open func format(obj: FormatObject): String {
        throw Exception("format method must be implemented by subclasses")
    }

    /**
     * Format an object and append the result to a string builder.
     * This method should be overridden by concrete subclasses.
     */
    public open func format(obj: FormatObject, toAppendTo: StringBuilder): StringBuilder {
        throw Exception("format method must be implemented by subclasses")
    }

    /**
     * Parse a string and return the parsed object.
     * This method should be overridden by concrete subclasses.
     */
    public open func parse(source: String): Option<FormatObject> {
        throw Exception("parse method must be implemented by subclasses")
    }

    /**
     * Parse a string starting at a specific position.
     * This method should be overridden by concrete subclasses.
     */
    public open func parse(source: String, pos: ParsePosition): Option<FormatObject> {
        throw Exception("parse method must be implemented by subclasses")
    }

    /**
     * Returns a string representation of this formatter.
     */
    public open func toString(): String {
        return "UFormat"
    }

    /**
     * Returns true if this formatter equals the other formatter.
     */
    public open func equals(other: Option<UFormat>): Bool {
        if (other.isNone()) {
            return false
        }
        let otherFormat = other.getOrThrow()
        return compareOptions(validLocale, otherFormat.validLocale) && 
               compareOptions(actualLocale, otherFormat.actualLocale)
    }

    /**
     * Helper function to compare Option values.
     */
    private static func compareOptions(opt1: Option<ULocale>, opt2: Option<ULocale>): Bool {
        if (opt1.isNone() && opt2.isNone()) {
            return true
        }
        if (opt1.isSome() && opt2.isSome()) {
            let val1 = opt1.getOrThrow()
            let val2 = opt2.getOrThrow()
            return val1.equals(Option.Some(val2))
        }
        return false
    }

    /**
     * Returns a hash code for this formatter.
     */
    public open func hashCode(): Int64 {
        var result: Int64 = 17
        if (validLocale.isSome()) {
            result = result * 31 + validLocale.getOrThrow().hashCode()
        }
        if (actualLocale.isSome()) {
            result = result * 31 + actualLocale.getOrThrow().hashCode()
        }
        return result
    }
}