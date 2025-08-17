// © 2016 and later: Unicode, Inc. and others.
// License & terms of use: http://www.unicode.org/copyright.html
/*
**********************************************************************
* Copyright (c) 2004-2016, International Business Machines
* Corporation and others.  All Rights Reserved.
**********************************************************************
* Author: Alan Liu
* Created: April 6, 2004
* Since: ICU 3.0
**********************************************************************
*/
package icu4cj

import std.collection.HashMap

/**
 * MessageFormat prepares strings for display to users,
 * with optional arguments (variables/placeholders).
 * The arguments can occur in any order, which is necessary for translation
 * into languages with different grammars.
 *
 * A MessageFormat is constructed from a pattern string
 * with arguments in {curly braces} which will be replaced by formatted values.
 *
 * This is a simplified translation of com.ibm.icu.text.MessageFormat from Java to Cangjie.
 */
public class MessageFormat <: UFormat {

    /**
     * The pattern string.
     */
    private var pattern: String

    /**
     * The locale for this message format.
     */
    private var locale: ULocale

    /**
     * Arguments for formatting.
     */
    private var arguments: Array<FormatObject>

    /**
     * Named arguments map.
     */
    private var namedArguments: HashMap<String, FormatObject>

    /**
     * Constructs a MessageFormat for the default FORMAT locale and the
     * specified pattern.
     * Sets the locale and calls applyPattern(pattern).
     *
     * @param pattern the pattern for this message format
     */
    public init(pattern: String) {
        super()
        this.pattern = pattern  // Initialize pattern first
        this.locale = ULocale.getDefault(Category.FORMAT)
        this.arguments = Array<FormatObject>(0, { _ => FormatObject("") })
        this.namedArguments = HashMap<String, FormatObject>()
        applyPattern(pattern)
    }

    /**
     * Constructs a MessageFormat for the specified locale and pattern.
     * Sets the locale and calls applyPattern(pattern).
     *
     * @param pattern the pattern for this message format
     * @param locale the locale for this message format
     */
    public init(pattern: String, locale: ULocale) {
        super()
        this.pattern = pattern  // Initialize pattern first
        this.locale = locale
        this.arguments = Array<FormatObject>(0, { _ => FormatObject("") })
        this.namedArguments = HashMap<String, FormatObject>()
        applyPattern(pattern)
    }

    /**
     * Sets the pattern for this MessageFormat.
     * @param pattern the new pattern
     */
    public func applyPattern(pattern: String): Unit {
        this.pattern = pattern
        // In a real implementation, this would parse the pattern
        // For simplicity, we just store it
    }

    /**
     * Returns the pattern for this MessageFormat.
     * @return the pattern string
     */
    public func toPattern(): String {
        return pattern
    }

    /**
     * Sets the locale to be used for creating argument Format objects.
     * @param locale the locale to be used when creating or comparing subformats
     */
    public func setLocale(locale: ULocale): Unit {
        this.locale = locale
    }

    /**
     * Gets the locale that's used when creating or comparing subformats.
     * @return the locale used when creating or comparing subformats
     */
    public func getLocale(): ULocale {
        return locale
    }

    /**
     * Sets the arguments to be formatted by this MessageFormat.
     * @param arguments the arguments to be formatted
     */
    public func setArguments(arguments: Array<FormatObject>): Unit {
        this.arguments = arguments
    }

    /**
     * Sets named arguments for formatting.
     * @param namedArguments map of named arguments
     */
    public func setNamedArguments(namedArguments: HashMap<String, FormatObject>): Unit {
        this.namedArguments = namedArguments
    }

    /**
     * Formats an object and returns the result as a string.
     * @param obj the object to format (can be an array or map)
     * @return the formatted string
     */
    public func format(obj: FormatObject): String {
        // If no arguments are set, use the passed object as argument 0
        if (arguments.size == 0) {
            let tempArgs = Array<FormatObject>(1, { _ => obj })
            let oldArgs = arguments
            this.arguments = tempArgs
            let result = formatInternal()
            this.arguments = oldArgs
            return result
        } else {
            return formatInternal()
        }
    }

    /**
     * Formats an object and appends the result to a string builder.
     * @param obj the object to format
     * @param toAppendTo the string builder to append to
     * @return the string builder
     */
    public func format(obj: FormatObject, toAppendTo: StringBuilder): StringBuilder {
        let result = formatInternal()
        toAppendTo.append(result)
        return toAppendTo
    }

    /**
     * Internal method to perform the actual formatting.
     */
    private func formatInternal(): String {
        // Simple implementation that replaces {0}, {1}, etc. with arguments
        var result = pattern
        
        // Replace numbered arguments {0}, {1}, etc.
        for (i in 0..arguments.size) {
            let placeholder = "{" + i.toString() + "}"
            result = replaceAll(result, placeholder, arguments[i].getValue())
        }
        
        // Replace named arguments {name}
        let keys = namedArguments.keys()
        for (key in keys) {
            let placeholder = "{" + key + "}"
            let value = namedArguments.get(key)
            if (value.isSome()) {
                result = replaceAll(result, placeholder, value.getOrThrow().getValue())
            }
        }
        
        return result
    }

    /**
     * Parses a string and returns the parsed object.
     * @param source the string to parse
     * @return the parsed object, or None if parsing failed
     */
    public func parse(source: String): Option<FormatObject> {
        let pos = ParsePosition(0)
        return parse(source, pos)
    }

    /**
     * Parses a string starting at a specific position.
     * @param source the string to parse
     * @param pos the parse position
     * @return the parsed object, or None if parsing failed
     */
    public func parse(source: String, pos: ParsePosition): Option<FormatObject> {
        // Simple implementation - just return the source as a FormatObject
        if (pos.getIndex() < source.size) {
            pos.setIndex(source.size)
            return Option<FormatObject>.Some(FormatObject(source))
        }
        return Option<FormatObject>.None
    }

    /**
     * Static method to format a pattern with arguments.
     * @param pattern the pattern string
     * @param arguments the arguments to substitute
     * @return the formatted string
     */
    public static func formatString(pattern: String, arguments: Array<FormatObject>): String {
        let fmt = MessageFormat(pattern)
        fmt.setArguments(arguments)
        return fmt.format(FormatObject(""))
    }

    /**
     * Static method to format a pattern with named arguments.
     * @param pattern the pattern string
     * @param namedArguments the named arguments to substitute
     * @return the formatted string
     */
    public static func formatWithNames(pattern: String, namedArguments: HashMap<String, FormatObject>): String {
        let fmt = MessageFormat(pattern)
        fmt.setNamedArguments(namedArguments)
        return fmt.format(FormatObject(""))
    }

    /**
     * Returns a string representation of this MessageFormat.
     */
    public func toString(): String {
        return "MessageFormat[pattern=" + pattern + ",locale=" + locale.toString() + "]"
    }

    /**
     * Returns true if this MessageFormat equals the other formatter.
     */
    public func equals(other: Option<MessageFormat>): Bool {
        if (other.isNone()) {
            return false
        }
        let otherFormat = other.getOrThrow()
        return pattern == otherFormat.pattern && locale.equals(Option.Some(otherFormat.locale))
    }

    /**
     * Returns a hash code for this MessageFormat.
     */
    public func hashCode(): Int64 {
        var result: Int64 = 17
        result = result * 31 + stringHashCode(pattern)
        result = result * 31 + locale.hashCode()
        return result
    }

    /**
     * Helper function to compute string hash code.
     */
    private static func stringHashCode(str: String): Int64 {
        var hash: Int64 = 0
        let size = str.size
        for (i in 0..size) {
            hash = hash * 31 + Int64(str[i])
        }
        return hash
    }

    // Private helper methods

    /**
     * Replace all occurrences of target with replacement in the source string.
     */
    private static func replaceAll(source: String, target: String, replacement: String): String {
        if (target.size == 0) {
            return source
        }
        
        var result = ""
        var pos: Int64 = 0
        let sourceSize = source.size
        let targetSize = target.size
        
        while (pos < sourceSize) {
            let foundPos = indexOf(source, target, pos)
            if (foundPos == -1) {
                // No more occurrences, append the rest
                result = result + substring(source, pos, sourceSize)
                break
            } else {
                // Found occurrence, append text before it and the replacement
                result = result + substring(source, pos, foundPos) + replacement
                pos = foundPos + targetSize
            }
        }
        
        return result
    }

    /**
     * Find the index of target in source starting from fromIndex.
     */
    private static func indexOf(source: String, target: String, fromIndex: Int64): Int64 {
        let sourceSize = source.size
        let targetSize = target.size
        
        if (targetSize == 0) {
            return fromIndex
        }
        
        if (fromIndex >= sourceSize) {
            return -1
        }
        
        for (i in fromIndex..(sourceSize - targetSize + 1)) {
            var isMatch = true
            for (j in 0..targetSize) {
                if (source[i + j] != target[j]) {
                    isMatch = false
                    break
                }
            }
            if (isMatch) {
                return i
            }
        }
        
        return -1
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


