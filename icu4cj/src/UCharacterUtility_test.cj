// © 2016 and later: Unicode, Inc. and others.
// License & terms of use: http://www.unicode.org/copyright.html
package icu4cj

@Test
public func test_isNonCharacter(): Unit {
    // Test Unicode 3.0 non-characters (0xFFFE, 0xFFFF)
    @Assert(UCharacterUtility.isNonCharacter(0xFFFE))
    @Assert(UCharacterUtility.isNonCharacter(0xFFFF))
    @Assert(UCharacterUtility.isNonCharacter(0x1FFFE))
    @Assert(UCharacterUtility.isNonCharacter(0x1FFFF))
    @Assert(UCharacterUtility.isNonCharacter(0x10FFFE))
    @Assert(UCharacterUtility.isNonCharacter(0x10FFFF))
    
    // Test Unicode 3.1 non-characters (0xFDD0..0xFDEF)
    @Assert(UCharacterUtility.isNonCharacter(0xFDD0))
    @Assert(UCharacterUtility.isNonCharacter(0xFDD5))
    @Assert(UCharacterUtility.isNonCharacter(0xFDEF))
    
    // Test regular characters (should not be non-characters)
    @Assert(!UCharacterUtility.isNonCharacter(0x0041)) // 'A'
    @Assert(!UCharacterUtility.isNonCharacter(0x0020)) // Space
    @Assert(!UCharacterUtility.isNonCharacter(0x4E2D)) // Chinese character
    @Assert(!UCharacterUtility.isNonCharacter(0xFDCF)) // Just before Unicode 3.1 range
    @Assert(!UCharacterUtility.isNonCharacter(0xFDF0)) // Just after Unicode 3.1 range
    @Assert(!UCharacterUtility.isNonCharacter(0xFFFD)) // Replacement character
}

@Test
public func test_toInt(): Unit {
    // Test combining two chars into an int
    @Assert(UCharacterUtility.toInt(0x00FF, 0x00FF) == 0x00FF00FF)
    @Assert(UCharacterUtility.toInt(0x1234, 0x5678) == 0x12345678)
    @Assert(UCharacterUtility.toInt(0x0000, 0x0000) == 0x00000000)
    @Assert(UCharacterUtility.toInt(0xFFFF, 0xFFFF) == 0xFFFFFFFF)
    @Assert(UCharacterUtility.toInt(0x0001, 0x0000) == 0x00010000)
}

@Test
public func test_getNullTermByteSubString(): Unit {
    // Create test byte array with null-terminated string
    var testArray = Array<Int8>(20, { _ => Int8(0) })
    testArray[0] = Int8(65) // 'A'
    testArray[1] = Int8(66) // 'B'
    testArray[2] = Int8(67) // 'C'
    testArray[3] = Int8(0)  // null terminator
    testArray[4] = Int8(68) // 'D' (should not be included)
    
    let (resultStr, endPos) = UCharacterUtility.getNullTermByteSubString(testArray, 0)
    
    @Assert(resultStr == "ABC")
    @Assert(endPos == 4) // Position after null terminator
}

@Test
public func test_compareNullTermByteSubString(): Unit {
    // Create test byte array with null-terminated string "HELLO"
    var testArray = Array<Int8>(20, { _ => Int8(0) })
    testArray[0] = Int8(72) // 'H'
    testArray[1] = Int8(69) // 'E'
    testArray[2] = Int8(76) // 'L'
    testArray[3] = Int8(76) // 'L'
    testArray[4] = Int8(79) // 'O'
    testArray[5] = Int8(0)  // null terminator
    
    // Test matching string
    let result1 = UCharacterUtility.compareNullTermByteSubString("HELLO", testArray, 0, 0)
    @Assert(result1 == 5) // Should match entire string
    
    // Test non-matching string
    let result2 = UCharacterUtility.compareNullTermByteSubString("WORLD", testArray, 0, 0)
    @Assert(result2 == -1) // Should not match
    
    // Test partial matching from middle of string
    let result3 = UCharacterUtility.compareNullTermByteSubString("XHELLO", testArray, 1, 0)
    @Assert(result3 == 6) // Should match from position 1
}

@Test
public func test_skipNullTermByteSubString(): Unit {
    // Create test byte array with multiple null-terminated strings
    var testArray = Array<Int8>(20, { _ => Int8(0) })
    var index = 0
    
    // First string: "AB"
    testArray[index] = Int8(65) // 'A'
    index++
    testArray[index] = Int8(66) // 'B'
    index++
    testArray[index] = Int8(0)  // null terminator
    index++
    
    // Second string: "CD"
    testArray[index] = Int8(67) // 'C'
    index++
    testArray[index] = Int8(68) // 'D'
    index++
    testArray[index] = Int8(0)  // null terminator
    index++
    
    // Third string: "EF"
    testArray[index] = Int8(69) // 'E'
    index++
    testArray[index] = Int8(70) // 'F'
    index++
    testArray[index] = Int8(0)  // null terminator
    index++
    
    // Skip first string (should move to position 3)
    let pos1 = UCharacterUtility.skipNullTermByteSubString(testArray, 0, 1)
    @Assert(pos1 == 3)
    
    // Skip two strings from beginning (should move to position 6)
    let pos2 = UCharacterUtility.skipNullTermByteSubString(testArray, 0, 2)
    @Assert(pos2 == 6)
    
    // Skip all three strings from beginning (should move to position 9)
    let pos3 = UCharacterUtility.skipNullTermByteSubString(testArray, 0, 3)
    @Assert(pos3 == 9)
}

@Test
public func test_skipByteSubString(): Unit {
    // Create test byte array
    var testArray = Array<Int8>(20, { _ => Int8(0) })
    testArray[0] = Int8(65) // 'A'
    testArray[1] = Int8(66) // 'B'
    testArray[2] = Int8(67) // 'C'
    testArray[3] = Int8(68) // 'D' - target byte
    testArray[4] = Int8(69) // 'E'
    
    // Skip until finding 'D' (68)
    let skipped1 = UCharacterUtility.skipByteSubString(testArray, 0, 10, Int8(68))
    @Assert(skipped1 == 4) // Should skip 3 bytes + 1 for the target
    
    // Skip until finding non-existent byte
    let skipped2 = UCharacterUtility.skipByteSubString(testArray, 0, 3, Int8(90))
    @Assert(skipped2 == 3) // Should skip max length
    
    // Skip from middle position
    let skipped3 = UCharacterUtility.skipByteSubString(testArray, 2, 5, Int8(68))
    @Assert(skipped3 == 2) // Should find target at relative position 1
}

@Test
public func test_edgeCases(): Unit {
    // Test boundary values for isNonCharacter
    @Assert(!UCharacterUtility.isNonCharacter(0xFDCF)) // Just before range
    @Assert(UCharacterUtility.isNonCharacter(0xFDD0))  // Start of range
    @Assert(UCharacterUtility.isNonCharacter(0xFDEF))  // End of range
    @Assert(!UCharacterUtility.isNonCharacter(0xFDF0)) // Just after range
    
    // Test toInt with edge values
    @Assert(UCharacterUtility.toInt(0, 0) == 0)
    @Assert(UCharacterUtility.toInt(0xFFFF, 0) == 0xFFFF0000)
    @Assert(UCharacterUtility.toInt(0, 0xFFFF) == 0x0000FFFF)
}