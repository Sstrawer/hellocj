// © 2016 and later: Unicode, Inc. and others.
// License & terms of use: http://www.unicode.org/copyright.html
/**
*******************************************************************************
* Copyright (C) 2003-2016, International Business Machines Corporation and    *
* others. All Rights Reserved.                                                *
*******************************************************************************
*/
package icu4cj

/**
 * Types for getAvailableLocalesByType
 */
public enum AvailableType {
    /**
     * Locales that return data when passed to ICU APIs,
     * but not including legacy or alias locales.
     */
    | DEFAULT

    /**
     * Legacy or alias locales that return data when passed to ICU APIs.
     */
    | ONLY_LEGACY_ALIASES

    /**
     * The union of the locales in DEFAULT and ONLY_LEGACY_ALIASES.
     */
    | WITH_LEGACY_ALIASES
}

/**
 * Enum for locale categories. These locale categories are used to get/set the default locale for
 * the specific functionality represented by the category.
 */
public enum Category {
    /**
     * Category used to represent the default locale for displaying user interfaces.
     */
    | DISPLAY
    
    /**
     * Category used to represent the default locale for formatting date, number and/or currency.
     */
    | FORMAT
}

/**
* A class analogous to Java Locale that provides additional support for ICU protocol.
* In ICU 3.0 this class is enhanced to support RFC 3066 language identifiers.
* 
* ULocale performs 'normalization' and 'canonicalization' of locale ids.
* Normalization 'cleans up' ICU locale ids as follows:
* - language, script, country, variant, and keywords are properly cased
* - hyphens used as separators are converted to underscores
* - three-letter language and country ids are converted to two-letter equivalents where available
* - surrounding spaces are removed from keywords and values
* - if there are multiple keywords, they are put in sorted order
* 
* This is a simplified translation of com.ibm.icu.util.ULocale from Java to Cangjie.
*/
public class ULocale {

    // Useful constants for common locales
    
    /**
     * Useful constant for language.
     */
    public static let ENGLISH: ULocale = ULocale("en")

    /**
     * Useful constant for language.
     */
    public static let FRENCH: ULocale = ULocale("fr")

    /**
     * Useful constant for language.
     */
    public static let GERMAN: ULocale = ULocale("de")

    /**
     * Useful constant for language.
     */
    public static let ITALIAN: ULocale = ULocale("it")

    /**
     * Useful constant for language.
     */
    public static let JAPANESE: ULocale = ULocale("ja")

    /**
     * Useful constant for language.
     */
    public static let KOREAN: ULocale = ULocale("ko")

    /**
     * Useful constant for language.
     */
    public static let CHINESE: ULocale = ULocale("zh")

    /**
     * Simplified Chinese
     */
    public static let SIMPLIFIED_CHINESE: ULocale = ULocale("zh_Hans")

    /**
     * Traditional Chinese
     */
    public static let TRADITIONAL_CHINESE: ULocale = ULocale("zh_Hant")

    /**
     * Useful constant for country.
     */
    public static let FRANCE: ULocale = ULocale("fr_FR")

    /**
     * Useful constant for country.
     */
    public static let GERMANY: ULocale = ULocale("de_DE")

    /**
     * Useful constant for country.
     */
    public static let ITALY: ULocale = ULocale("it_IT")

    /**
     * Useful constant for country.
     */
    public static let JAPAN: ULocale = ULocale("ja_JP")

    /**
     * Useful constant for country.
     */
    public static let KOREA: ULocale = ULocale("ko_KR")

    /**
     * Useful constant for country.
     */
    public static let CHINA: ULocale = ULocale("zh_Hans_CN")

    /**
     * Useful constant for country.
     */
    public static let TAIWAN: ULocale = ULocale("zh_Hant_TW")

    /**
     * Useful constant for country.
     */
    public static let UK: ULocale = ULocale("en_GB")

    /**
     * Useful constant for country.
     */
    public static let US: ULocale = ULocale("en_US")

    /**
     * Useful constant for country.
     */
    public static let CANADA: ULocale = ULocale("en_CA")

    /**
     * Useful constant for country.
     */
    public static let CANADA_FRENCH: ULocale = ULocale("fr_CA")

    /**
     * The root ULocale.
     */
    public static let ROOT: ULocale = ULocale("")

    // Private constants
    private static let EMPTY_STRING: String = ""
    private static let UNDERSCORE: UInt8 = UInt8(95)  // '_'

    // Instance variables
    
    /**
     * The raw localeID that we were passed in.
     */
    private let localeID: String

    /**
     * Default ULocale instance
     */
    private static var defaultULocale: ULocale = ULocale("en_US")

    /**
     * Default ULocales for categories
     */
    private static var defaultCategoryULocales: Array<ULocale> = [ULocale("en_US"), ULocale("en_US")]

    /**
     * Constructs a ULocale from a RFC 3066 locale ID. The locale ID consists
     * of optional language, script, country, and variant fields in that order,
     * separated by underscores, followed by an optional keyword list.
     *
     * @param localeID string representation of the locale, e.g:
     * "en_US", "sy_Cyrl_YU", "zh__pinyin", "es_ES@currency=EUR;collation=traditional"
     */
    public init(localeID: String) {
        this.localeID = getNameForID(localeID)
    }

    /**
     * Convenience overload for compatibility.
     */
    public init(a: String, b: String) {
        this.localeID = getNameForID(lscvToID(a, b, "", ""))
    }

    /**
     * Constructs a ULocale from a localeID constructed from the three 'fields' a, b, and c.
     * These fields are concatenated using underscores to form a localeID.
     * @param a first component of the locale id
     * @param b second component of the locale id
     * @param c third component of the locale id
     */
    public init(a: String, b: String, c: String) {
        this.localeID = getNameForID(lscvToID(a, b, c, ""))
    }

    /**
     * Creates a ULocale from the id by first canonicalizing the id.
     * @param nonCanonicalID the locale id to canonicalize
     * @return the locale created from the canonical version of the ID.
     */
    public static func createCanonical(nonCanonicalID: String): ULocale {
        return ULocale(canonicalize(nonCanonicalID))
    }

    /**
     * Returns a string representation of this object.
     * @return a string representation of the object.
     */
    public func toString(): String {
        return localeID
    }

    /**
     * Returns the name of this locale.
     * @return the name of this locale
     */
    public func getName(): String {
        return localeID
    }

    /**
     * Returns the language component of this locale.
     * @return the language component
     */
    public func getLanguage(): String {
        return getLanguageForID(localeID)
    }

    /**
     * Returns the script component of this locale.
     * @return the script component
     */
    public func getScript(): String {
        return getScriptForID(localeID)
    }

    /**
     * Returns the country component of this locale.
     * @return the country component
     */
    public func getCountry(): String {
        return getCountryForID(localeID)
    }

    /**
     * Returns the variant component of this locale.
     * @return the variant component
     */
    public func getVariant(): String {
        return getVariantForID(localeID)
    }

    /**
     * Returns the current default ULocale.
     * @return the default ULocale.
     */
    public static func getDefault(): ULocale {
        return defaultULocale
    }

    /**
     * Sets the default ULocale.
     * @param newLocale the new default locale
     */
    public static func setDefault(newLocale: ULocale): Unit {
        defaultULocale = newLocale
    }

    /**
     * Returns the default ULocale for the specified Category.
     * @param category the specified category
     * @return the default ULocale for the specified Category.
     */
    public static func getDefault(category: Category): ULocale {
        let idx = getCategoryIndex(category)
        return defaultCategoryULocales[idx]
    }

    /**
     * Sets the default ULocale for the specified Category.
     * @param category the specified category to set the default locale
     * @param newLocale the new default locale
     */
    public static func setDefault(category: Category, newLocale: ULocale): Unit {
        let idx = getCategoryIndex(category)
        defaultCategoryULocales[idx] = newLocale
    }

    /**
     * Returns the hashCode.
     * @return a hash code value for this object.
     */
    public func hashCode(): Int64 {
        // Simple hash based on string hash
        var hash: Int64 = 0
        let size = localeID.size
        for (i in 0..size) {
            hash = hash * 31 + Int64(localeID[i])
        }
        return hash
    }

    /**
     * Returns true if the other object is another ULocale with the same full name.
     * @param obj the object to compare against
     * @return true if this equals the other ULocale.
     */
    public func equals(obj: Option<ULocale>): Bool {
        if (obj.isNone()) {
            return false
        }
        let other = obj.getOrThrow()
        return localeID == other.localeID
    }

    /**
     * Compare this ULocale to another ULocale.
     * @param other the ULocale to compare to.
     * @return a negative, zero, or positive integer as this ULocale is less than, equal to, or greater than the specified ULocale.
     */
    public func compareTo(other: ULocale): Int64 {
        let cmp = compareStrings(localeID, other.localeID)
        return cmp
    }

    // Static helper methods

    /**
     * Returns the normalized locale name for the given locale ID.
     * @param localeID the locale ID to normalize
     * @return the normalized locale name
     */
    public static func getNameForID(localeID: String): String {
        if (localeID.size == 0) {
            return ""
        }
        // Basic normalization - convert hyphens to underscores and trim
        var result = ""
        let size = localeID.size
        for (i in 0..size) {
            let c = localeID[i]
            if (c == UInt8(45)) {  // '-'
                result = result + "_"
            } else {
                result = result + Rune(Int64(c)).toString()
            }
        }
        return trim(result)
    }

    /**
     * Returns the canonical form of the locale ID.
     * @param localeID the locale ID to canonicalize
     * @return the canonical form
     */
    public static func canonicalize(localeID: String): String {
        // Basic canonicalization
        return getNameForID(localeID)
    }

    /**
     * Returns the language component of the specified locale ID.
     * @param localeID the locale ID
     * @return the language component
     */
    public static func getLanguageForID(localeID: String): String {
        let parts = split(localeID, UNDERSCORE)
        if (parts.size > 0) {
            return parts[0]
        }
        return ""
    }

    /**
     * Returns the script component of the specified locale ID.
     * @param localeID the locale ID
     * @return the script component
     */
    public static func getScriptForID(localeID: String): String {
        let parts = split(localeID, UNDERSCORE)
        if (parts.size > 1 && parts[1].size == 4) {
            // Script codes are 4 characters long
            return parts[1]
        }
        return ""
    }

    /**
     * Returns the country component of the specified locale ID.
     * @param localeID the locale ID
     * @return the country component
     */
    public static func getCountryForID(localeID: String): String {
        let parts = split(localeID, UNDERSCORE)
        var idx = 1
        
        // Skip empty parts (handle double underscores)
        while (idx < parts.size && parts[idx].size == 0) {
            idx++
        }
        
        // Skip script if present
        if (idx < parts.size && parts[idx].size == 4) {
            idx++
            // Skip more empty parts
            while (idx < parts.size && parts[idx].size == 0) {
                idx++
            }
        }
        
        if (idx < parts.size && parts[idx].size == 2) {
            // Country codes are typically 2 characters long
            return parts[idx]
        }
        return ""
    }

    /**
     * Returns the variant component of the specified locale ID.
     * @param localeID the locale ID
     * @return the variant component
     */
    public static func getVariantForID(localeID: String): String {
        let parts = split(localeID, UNDERSCORE)
        var idx = 1
        
        // Skip script if present
        if (parts.size > 1 && parts[1].size == 4) {
            idx = 2
        }
        
        // Skip country if present
        if (parts.size > idx && parts[idx].size == 2) {
            idx++
        }
        
        // Collect remaining parts as variant
        var variant = ""
        for (i in idx..parts.size) {
            if (i > idx) {
                variant = variant + "_"
            }
            variant = variant + parts[i]
        }
        return variant
    }

    // Private helper methods

    private static func getCategoryIndex(category: Category): Int64 {
        match (category) {
            case DISPLAY => return 0
            case FORMAT => return 1
        }
    }

    private static func lscvToID(lang: String, script: String, country: String, variant: String): String {
        var result = ""
        
        if (lang.size > 0) {
            result = result + lang
        }
        if (script.size > 0) {
            result = result + "_" + script
        }
        if (country.size > 0) {
            result = result + "_" + country
        }
        if (variant.size > 0) {
            if (country.size == 0) {
                result = result + "_"
            }
            result = result + "_" + variant
        }
        return result
    }

    private static func split(s: String, delimiter: UInt8): Array<String> {
        // Count the number of parts first
        var partCount: Int64 = 1
        for (i in 0..s.size) {
            if (s[i] == delimiter) {
                partCount++
            }
        }
        
        // Create array with exact size
        var result = Array<String>(partCount, { _ => "" })
        var partIndex: Int64 = 0
        var start: Int64 = 0
        let size = s.size
        
        for (i in 0..size) {
            if (s[i] == delimiter) {
                if (i > start) {
                    result[partIndex] = substring(s, start, i)
                } else {
                    result[partIndex] = ""
                }
                partIndex++
                start = i + 1
            }
        }
        
        // Add the last part
        if (start < size) {
            result[partIndex] = substring(s, start, size)
        } else if (partCount == 1) {
            result[partIndex] = s
        }
        
        return result
    }

    private static func substring(s: String, start: Int64, end: Int64): String {
        var result = ""
        for (i in start..end) {
            result = result + Rune(Int64(s[i])).toString()
        }
        return result
    }

    private static func trim(s: String): String {
        let size = s.size
        var start: Int64 = 0
        var end = size
        
        // Find first non-space character
        while (start < size && s[start] == UInt8(32)) {  // space
            start++
        }
        
        // Find last non-space character
        while (end > start && s[end - 1] == UInt8(32)) {  // space
            end--
        }
        
        return substring(s, start, end)
    }

    private static func compareStrings(a: String, b: String): Int64 {
        let minSize = if (a.size < b.size) { a.size } else { b.size }
        
        for (i in 0..minSize) {
            let ca = Int64(a[i])
            let cb = Int64(b[i])
            if (ca < cb) {
                return -1
            } else if (ca > cb) {
                return 1
            }
        }
        
        if (a.size < b.size) {
            return -1
        } else if (a.size > b.size) {
            return 1
        } else {
            return 0
        }
    }
}
