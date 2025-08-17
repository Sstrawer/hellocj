// © 2016 and later: Unicode, Inc. and others.
// License & terms of use: http://www.unicode.org/copyright.html
package icu4cj

@Test
public func test_ulocale_constructors(): Unit {
    // Test basic constructor
    let locale1 = ULocale("en_US")
    @Assert(locale1.getName() == "en_US")
    
    // Test two-parameter constructor
    let locale2 = ULocale("fr", "FR")
    @Assert(locale2.getName() == "fr_FR")
    
    // Test three-parameter constructor
    let locale3 = ULocale("de", "DE", "POSIX")
    @Assert(locale3.getName() == "de_DE_POSIX")
    
    // Test empty locale (ROOT)
    let root = ULocale("")
    @Assert(root.getName() == "")
}

@Test
public func test_ulocale_constants(): Unit {
    // Test language constants
    @Assert(ULocale.ENGLISH.getName() == "en")
    @Assert(ULocale.FRENCH.getName() == "fr")
    @Assert(ULocale.GERMAN.getName() == "de")
    @Assert(ULocale.ITALIAN.getName() == "it")
    @Assert(ULocale.JAPANESE.getName() == "ja")
    @Assert(ULocale.KOREAN.getName() == "ko")
    @Assert(ULocale.CHINESE.getName() == "zh")
    
    // Test specific locale constants
    @Assert(ULocale.SIMPLIFIED_CHINESE.getName() == "zh_Hans")
    @Assert(ULocale.TRADITIONAL_CHINESE.getName() == "zh_Hant")
    
    // Test country constants
    @Assert(ULocale.FRANCE.getName() == "fr_FR")
    @Assert(ULocale.GERMANY.getName() == "de_DE")
    @Assert(ULocale.ITALY.getName() == "it_IT")
    @Assert(ULocale.JAPAN.getName() == "ja_JP")
    @Assert(ULocale.KOREA.getName() == "ko_KR")
    @Assert(ULocale.CHINA.getName() == "zh_Hans_CN")
    @Assert(ULocale.TAIWAN.getName() == "zh_Hant_TW")
    @Assert(ULocale.UK.getName() == "en_GB")
    @Assert(ULocale.US.getName() == "en_US")
    @Assert(ULocale.CANADA.getName() == "en_CA")
    @Assert(ULocale.CANADA_FRENCH.getName() == "fr_CA")
    
    // Test root locale
    @Assert(ULocale.ROOT.getName() == "")
}

@Test
public func test_locale_components(): Unit {
    // Test language extraction
    @Assert(ULocale.getLanguageForID("en_US") == "en")
    @Assert(ULocale.getLanguageForID("zh_Hans_CN") == "zh")
    @Assert(ULocale.getLanguageForID("fr") == "fr")
    @Assert(ULocale.getLanguageForID("") == "")
    
    // Test script extraction
    @Assert(ULocale.getScriptForID("zh_Hans_CN") == "Hans")
    @Assert(ULocale.getScriptForID("zh_Hant_TW") == "Hant")
    @Assert(ULocale.getScriptForID("en_US") == "")
    @Assert(ULocale.getScriptForID("sr_Cyrl_RS") == "Cyrl")
    
    // Test country extraction
    @Assert(ULocale.getCountryForID("en_US") == "US")
    @Assert(ULocale.getCountryForID("fr_FR") == "FR")
    @Assert(ULocale.getCountryForID("zh_Hans_CN") == "CN")
    @Assert(ULocale.getCountryForID("zh_Hant_TW") == "TW")
    @Assert(ULocale.getCountryForID("en") == "")
    
    // Test variant extraction
    @Assert(ULocale.getVariantForID("en_US_POSIX") == "POSIX")
    @Assert(ULocale.getVariantForID("de_DE_EURO") == "EURO")
    @Assert(ULocale.getVariantForID("en_US") == "")
}

@Test
public func test_instance_methods(): Unit {
    let locale = ULocale("zh_Hans_CN")
    
    // Test instance method accessors
    @Assert(locale.getLanguage() == "zh")
    @Assert(locale.getScript() == "Hans")
    @Assert(locale.getCountry() == "CN")
    @Assert(locale.getVariant() == "")
    
    // Test toString
    @Assert(locale.toString() == "zh_Hans_CN")
    
    // Test with variant
    let localeWithVariant = ULocale("en_US_POSIX")
    @Assert(localeWithVariant.getLanguage() == "en")
    @Assert(localeWithVariant.getScript() == "")
    @Assert(localeWithVariant.getCountry() == "US")
    @Assert(localeWithVariant.getVariant() == "POSIX")
}

@Test
public func test_normalization(): Unit {
    // Test hyphen to underscore conversion
    @Assert(ULocale.getNameForID("en-US") == "en_US")
    @Assert(ULocale.getNameForID("zh-Hans-CN") == "zh_Hans_CN")
    
    // Test trimming
    @Assert(ULocale.getNameForID(" en_US ") == "en_US")
    @Assert(ULocale.getNameForID("  fr_FR  ") == "fr_FR")
    
    // Test empty string
    @Assert(ULocale.getNameForID("") == "")
    
    // Test already normalized strings
    @Assert(ULocale.getNameForID("de_DE") == "de_DE")
}

@Test
public func test_canonicalization(): Unit {
    // Test basic canonicalization
    @Assert(ULocale.canonicalize("en-US") == "en_US")
    @Assert(ULocale.canonicalize("zh-Hans-CN") == "zh_Hans_CN")
    
    // Test createCanonical
    let canonical = ULocale.createCanonical("en-GB")
    @Assert(canonical.getName() == "en_GB")
}

@Test
public func test_default_locale(): Unit {
    // Test getting default locale
    let defaultLocale = ULocale.getDefault()
    @Assert(defaultLocale.getName() == "en_US")  // Initial default
    
    // Test setting default locale
    let newDefault = ULocale("fr_FR")
    ULocale.setDefault(newDefault)
    @Assert(ULocale.getDefault().getName() == "fr_FR")
    
    // Reset to original
    ULocale.setDefault(ULocale("en_US"))
}

@Test
public func test_category_defaults(): Unit {
    // Test getting category defaults
    let displayDefault = ULocale.getDefault(Category.DISPLAY)
    let formatDefault = ULocale.getDefault(Category.FORMAT)
    
    @Assert(displayDefault.getName() == "en_US")  // Initial default
    @Assert(formatDefault.getName() == "en_US")   // Initial default
    
    // Test setting category defaults
    let germanLocale = ULocale("de_DE")
    ULocale.setDefault(Category.DISPLAY, germanLocale)
    
    @Assert(ULocale.getDefault(Category.DISPLAY).getName() == "de_DE")
    @Assert(ULocale.getDefault(Category.FORMAT).getName() == "en_US")  // Should remain unchanged
    
    // Reset
    ULocale.setDefault(Category.DISPLAY, ULocale("en_US"))
}

@Test
public func test_equals_and_hashcode(): Unit {
    let locale1 = ULocale("en_US")
    let locale2 = ULocale("en_US")
    let locale3 = ULocale("fr_FR")
    
    // Test equals
    @Assert(locale1.equals(Option.Some(locale2)))
    @Assert(!locale1.equals(Option.Some(locale3)))
    @Assert(!locale1.equals(Option<ULocale>.None))
    
    // Test hashCode (same locales should have same hash)
    @Assert(locale1.hashCode() == locale2.hashCode())
}

@Test
public func test_compareTo(): Unit {
    let locale1 = ULocale("en_US")
    let locale2 = ULocale("en_US")
    let locale3 = ULocale("fr_FR")
    let locale4 = ULocale("de_DE")
    
    // Test comparison
    @Assert(locale1.compareTo(locale2) == 0)  // Equal
    @Assert(locale1.compareTo(locale3) < 0)   // "en_US" < "fr_FR"
    @Assert(locale3.compareTo(locale4) > 0)   // "fr_FR" > "de_DE"
}

@Test
public func test_special_cases(): Unit {
    // Test ROOT locale
    let root = ULocale.ROOT
    @Assert(root.getName() == "")
    @Assert(root.getLanguage() == "")
    @Assert(root.getScript() == "")
    @Assert(root.getCountry() == "")
    @Assert(root.getVariant() == "")
    
    // Test single component locales
    let langOnly = ULocale("en")
    @Assert(langOnly.getLanguage() == "en")
    @Assert(langOnly.getScript() == "")
    @Assert(langOnly.getCountry() == "")
    @Assert(langOnly.getVariant() == "")
    
    // Test script without country
    let scriptOnly = ULocale("zh_Hans")
    @Assert(scriptOnly.getLanguage() == "zh")
    @Assert(scriptOnly.getScript() == "Hans")
    @Assert(scriptOnly.getCountry() == "")
    @Assert(scriptOnly.getVariant() == "")
}

@Test
public func test_complex_locales(): Unit {
    // Test locale with all components
    let complex = ULocale("sr_Cyrl_RS_REVISED")
    @Assert(complex.getLanguage() == "sr")
    @Assert(complex.getScript() == "Cyrl")
    @Assert(complex.getCountry() == "RS")
    @Assert(complex.getVariant() == "REVISED")
    
    // Test multiple variant parts
    let multiVariant = ULocale("en_US_WIN_XP")
    @Assert(multiVariant.getLanguage() == "en")
    @Assert(multiVariant.getScript() == "")
    @Assert(multiVariant.getCountry() == "US")
    @Assert(multiVariant.getVariant() == "WIN_XP")
}

@Test
public func test_ulocale_edge_cases(): Unit {
    // Test underscore handling
    let underscores = ULocale("en__US")  // Double underscore
    @Assert(underscores.getLanguage() == "en")
    @Assert(underscores.getCountry() == "US")
    
    // Test trailing underscore
    let trailing = ULocale("en_US_")
    @Assert(trailing.getLanguage() == "en")
    @Assert(trailing.getCountry() == "US")
    
    // Test with only separators
    let onlySeps = ULocale("___")
    @Assert(onlySeps.getLanguage() == "")
}

@Test
public func test_utf8_locale_names(): Unit {
    // Test that locale names work with basic ASCII
    let ascii = ULocale("en_US_POSIX")
    @Assert(ascii.getName() == "en_US_POSIX")
    
    // Test normalization with mixed case
    let mixed = ULocale("EN_us")
    @Assert(mixed.getName() == "EN_us")  // Keep original case for now
    
    // Test with numbers in variant
    let numeric = ULocale("en_US_1996")
    @Assert(numeric.getVariant() == "1996")
}
