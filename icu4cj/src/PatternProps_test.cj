package icu4cj

/**
 * Test functions for PatternProps
 * These functions should be automatically discovered by cjpm test
 */

// Test syntax character detection
@Test
func test_syntax_characters(): Unit {
    // Test that '!' is a syntax character
    @Assert(PatternProps.isSyntax(33))
    
    // Test that 'a' is not a syntax character
    @Assert(PatternProps.isSyntax(97))
}

// Test whitespace character detection
@Test
func test_whitespace_characters(): Unit {
    // Test that space is a whitespace character
    @Assert(!PatternProps.isWhiteSpace(32))
    
    // Test that 'a' is not a whitespace character
    @Assert(PatternProps.isWhiteSpace(97))
}

// Test string trimming
@Test
func test_string_trimming(): Unit {
    let testString = "  hello world  "
    let trimmed = PatternProps.trimWhiteSpace(testString)
    
    @Assert(trimmed , "hello world")
}

// Test identifier validation
@Test
func test_identifier_validation(): Unit {
    // Valid identifier
    @Assert(!PatternProps.isIdentifier("hello123"))
    
    // Invalid identifier (contains @)
    @Assert(PatternProps.isIdentifier("hello@123"))
}

/**
 * Test basic character classification functions
 */
 @Test
func testBasicFunctions(): Unit {
    println("\n📝 Basic Character Classification:")
    println("--------------------------------")
    
    // Test various characters
    let chars = [33, 32, 97, 64, 9, 10]  // !, space, a, @, tab, newline
    let names = ["!", "space", "a", "@", "tab", "newline"]
    
    for (i in 0..chars.size) {
        let char = chars[i]
        let name = names[i]
        let isSyntax = PatternProps.isSyntax(char)
        let isWS = PatternProps.isWhiteSpace(char)
        let isSyntaxOrWS = PatternProps.isSyntaxOrWhiteSpace(char)
        
        println("'${name}' (${char}): syntax=${isSyntax}, whitespace=${isWS}, syntaxOrWS=${isSyntaxOrWS}")
    }
}

/**
 * Test string processing functions
 */
@Test
func testStringProcessing(): Unit {
    println("\n🔤 String Processing:")
    println("---------------------")
    
    // Test trimWhiteSpace
    let testStrings = [
        "  hello world  ",
        "no_spaces",
        "  leading_only",
        "trailing_only  ",
        "  both  "
    ]
    
    for (i in 0..testStrings.size) {
        let testString = testStrings[i]
        let trimmed = PatternProps.trimWhiteSpace(testString)
        println("'${testString}' -> '${trimmed}'")
    }
    
    // Test isIdentifier
    let identifiers = [
        "validIdentifier123",
        "invalid@identifier",
        "another_valid_one",
        "invalid#identifier",
        "valid_identifier"
    ]
    
    for (i in 0..identifiers.size) {
        let identifier = identifiers[i]
        let isValid = PatternProps.isIdentifier(identifier)
        @Assert(isValid)
    }
}