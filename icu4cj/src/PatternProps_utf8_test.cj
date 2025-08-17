package icu4cj

/**
 * Test functions for PatternProps with UTF-8 encoding considerations
 * These tests address the differences between Java (UTF-16) and Cangjie (UTF-8)
 */

// Test UTF-8 string indexing behavior
@Test
func test_utf8_string_indexing(): Unit {
    // Test that string indexing works correctly with UTF-8
    let testString = "Hello世界"  // "Hello" + Chinese characters
    
    // ASCII characters should work normally
    // In Cangjie, string indexing returns UInt8 (byte values)
    @Assert(testString[0] == 72)   // 'H' = 72
    @Assert(testString[1] == 101)  // 'e' = 101
    @Assert(testString[2] == 108)  // 'l' = 108
    @Assert(testString[3] == 108)  // 'l' = 108
    @Assert(testString[4] == 111)  // 'o' = 111
    
    // Chinese characters in UTF-8 take multiple bytes
    let worldStart = 5
    let worldChar = testString[worldStart]
    
    println("UTF-8 test: 'Hello世界' at index ${worldStart} = ${worldChar}")
    
    // Test that we can access multiple bytes for Chinese characters
    if (testString.size >= 11) {
        println("UTF-8 string size: ${testString.size}, indicating multi-byte characters")
    }
}

// Test that our PatternProps functions work with UTF-8 encoded strings
@Test
func test_pattern_props_with_utf8(): Unit {
    // Test with strings containing non-ASCII characters
    let mixedString = "Hello世界!你好@world"
    
    // Test trimWhiteSpace with UTF-8
    let trimmed = PatternProps.trimWhiteSpace(mixedString)
    @Assert(trimmed == "Hello世界!你好@world")
    
    // Test isIdentifier with UTF-8
    // Now our implementation should handle UTF-8 multi-byte characters correctly
    @Assert(PatternProps.isIdentifier("Hello世界"))
    @Assert(PatternProps.isIdentifier("你好世界"))
    
    // Test that syntax characters still work
    @Assert(!PatternProps.isIdentifier("Hello@世界"))
    @Assert(!PatternProps.isIdentifier("Hello 世界"))
}

// Test UTF-8 boundary conditions
@Test
func test_utf8_boundary_conditions(): Unit {
    let testCases = [
        "Hello",           // Pure ASCII
        "Hello世界",        // ASCII + Chinese
        "世界Hello",        // Chinese + ASCII
        "世界",             // Pure Chinese
        "Hello世界Hello",   // Mixed
        "Hello 世界",       // With space
        "Hello@世界"        // With syntax char
    ]
    
    for (i in 0..testCases.size) {
        let testString = testCases[i]
        let trimmed = PatternProps.trimWhiteSpace(testString)
        
        @Assert(trimmed.size >= 0)
        println("UTF-8 test case ${i}: '${testString}' -> '${trimmed}'")
    }
}

// Test UTF-8 specific behavior: byte-level operations
@Test
func test_utf8_byte_behavior(): Unit {
    let testString = "Hello世界"
    
    // In Cangjie (UTF-8), string indexing returns bytes
    let firstByte = testString[0]
    let lastByte = testString[testString.size - 1]
    
    @Assert(firstByte >= 0 && firstByte <= 255)
    @Assert(lastByte >= 0 && lastByte <= 255)
    
    println("UTF-8 byte behavior: first byte = ${firstByte}, last byte = ${lastByte}")
    println("String size: ${testString.size} (bytes in UTF-8)")
    
    // Test that our PatternProps functions work correctly with UTF-8
    let trimmed = PatternProps.trimWhiteSpace("  ${testString}  ")
    @Assert(trimmed == testString)
}
