// © 2016 and later: Unicode, Inc. and others.
// License & terms of use: http://www.unicode.org/copyright.html
package icu4cj

@Test
public func test_arrayEquals_strings(): Unit {
    // Test equal arrays
    let arr1 = ["hello", "world", "test"]
    let arr2 = ["hello", "world", "test"]
    @Assert(Utility.arrayEquals(Option.Some(arr1), Option.Some(arr2)))
    
    // Test different arrays
    let arr3 = ["hello", "world", "different"]
    @Assert(!Utility.arrayEquals(Option.Some(arr1), Option.Some(arr3)))
    
    // Test different sizes
    let arr4 = ["hello", "world"]
    @Assert(!Utility.arrayEquals(Option.Some(arr1), Option.Some(arr4)))
    
    // Test null arrays
    @Assert(Utility.arrayEquals(Option<Array<String>>.None, Option<Array<String>>.None))
    @Assert(!Utility.arrayEquals(Option.Some(arr1), Option<Array<String>>.None))
    @Assert(!Utility.arrayEquals(Option<Array<String>>.None, Option.Some(arr1)))
}

@Test
public func test_arrayEquals_integers(): Unit {
    // Test equal arrays
    let arr1 = [1, 2, 3, 4, 5]
    let arr2 = [1, 2, 3, 4, 5]
    @Assert(Utility.arrayEquals(Option.Some(arr1), Option.Some(arr2)))
    
    // Test different arrays
    let arr3 = [1, 2, 3, 4, 6]
    @Assert(!Utility.arrayEquals(Option.Some(arr1), Option.Some(arr3)))
    
    // Test empty arrays
    let empty1 = Array<Int64>()
    let empty2 = Array<Int64>()
    @Assert(Utility.arrayEquals(Option.Some(empty1), Option.Some(empty2)))
}

@Test
public func test_arrayEquals_doubles(): Unit {
    // Test equal arrays
    let arr1 = [1.0, 2.5, 3.14, -4.2]
    let arr2 = [1.0, 2.5, 3.14, -4.2]
    @Assert(Utility.arrayEquals(Option.Some(arr1), Option.Some(arr2)))
    
    // Test different arrays
    let arr3 = [1.0, 2.5, 3.14, -4.3]
    @Assert(!Utility.arrayEquals(Option.Some(arr1), Option.Some(arr3)))
}

@Test
public func test_arrayEquals_bytes(): Unit {
    // Test equal arrays
    let arr1 = [Int8(1), Int8(2), Int8(3)]
    let arr2 = [Int8(1), Int8(2), Int8(3)]
    @Assert(Utility.arrayEquals(Option.Some(arr1), Option.Some(arr2)))
    
    // Test different arrays
    let arr3 = [Int8(1), Int8(2), Int8(4)]
    @Assert(!Utility.arrayEquals(Option.Some(arr1), Option.Some(arr3)))
}

@Test
public func test_arrayRegionMatches_strings(): Unit {
    let source = ["a", "b", "c", "d", "e"]
    let target = ["x", "b", "c", "d", "y"]
    
    // Test matching region
    @Assert(Utility.arrayRegionMatches(source, 1, target, 1, 3))
    
    // Test non-matching region
    @Assert(!Utility.arrayRegionMatches(source, 0, target, 0, 3))
    
    // Test zero length
    @Assert(Utility.arrayRegionMatches(source, 0, target, 0, 0))
    
    // Test negative length
    @Assert(!Utility.arrayRegionMatches(source, 0, target, 0, -1))
    
    // Test out of bounds
    @Assert(!Utility.arrayRegionMatches(source, 3, target, 3, 5))
}

@Test
public func test_arrayRegionMatches_integers(): Unit {
    let source = [10, 20, 30, 40, 50]
    let target = [99, 20, 30, 40, 88]
    
    // Test matching region
    @Assert(Utility.arrayRegionMatches(source, 1, target, 1, 3))
    
    // Test non-matching region
    @Assert(!Utility.arrayRegionMatches(source, 0, target, 0, 3))
}

@Test
public func test_sameObjects(): Unit {
    let str1 = "hello"
    let str2 = "hello"
    let str3 = "world"
    
    // Test same content
    @Assert(Utility.sameObjects(Option.Some(str1), Option.Some(str2)))
    
    // Test different content
    @Assert(!Utility.sameObjects(Option.Some(str1), Option.Some(str3)))
    
    // Test null values
    @Assert(Utility.sameObjects(Option<String>.None, Option<String>.None))
    @Assert(!Utility.sameObjects(Option.Some(str1), Option<String>.None))
    @Assert(!Utility.sameObjects(Option<String>.None, Option.Some(str1)))
}

@Test
public func test_hex(): Unit {
    // Test basic hex conversion
    @Assert(Utility.hex(65) == "0041")  // 'A'
    @Assert(Utility.hex(255) == "00FF")
    @Assert(Utility.hex(0) == "0000")
    @Assert(Utility.hex(15) == "000F")
}

@Test
public func test_lookup(): Unit {
    let array = ["apple", "banana", "cherry", "date"]
    
    // Test found items
    @Assert(Utility.lookup("banana", array) == 1)
    @Assert(Utility.lookup("cherry", array) == 2)
    @Assert(Utility.lookup("apple", array) == 0)
    
    // Test not found
    @Assert(Utility.lookup("orange", array) == -1)
    @Assert(Utility.lookup("", array) == -1)
    
    // Test empty array
    let emptyArray = Array<String>()
    @Assert(Utility.lookup("test", emptyArray) == -1)
}

@Test
public func test_isUnprintable(): Unit {
    // Test printable characters
    @Assert(!Utility.isUnprintable(65))   // 'A'
    @Assert(!Utility.isUnprintable(97))   // 'a'
    @Assert(!Utility.isUnprintable(48))   // '0'
    @Assert(!Utility.isUnprintable(32))   // space
    @Assert(!Utility.isUnprintable(126))  // '~'
    
    // Test unprintable characters
    @Assert(Utility.isUnprintable(9))     // tab
    @Assert(Utility.isUnprintable(10))    // newline
    @Assert(Utility.isUnprintable(31))    // control char
    @Assert(Utility.isUnprintable(127))   // DEL
    @Assert(Utility.isUnprintable(200))   // extended ASCII
}

@Test
public func test_shouldAlwaysBeEscaped(): Unit {
    // Test characters that should be escaped
    @Assert(Utility.shouldAlwaysBeEscaped(9))     // tab
    @Assert(Utility.shouldAlwaysBeEscaped(10))    // newline
    @Assert(Utility.shouldAlwaysBeEscaped(127))   // DEL
    @Assert(Utility.shouldAlwaysBeEscaped(128))   // extended control
    @Assert(Utility.shouldAlwaysBeEscaped(159))   // extended control
    
    // Test characters that should not be escaped
    @Assert(!Utility.shouldAlwaysBeEscaped(65))   // 'A'
    @Assert(!Utility.shouldAlwaysBeEscaped(32))   // space
    @Assert(!Utility.shouldAlwaysBeEscaped(126))  // '~'
    @Assert(!Utility.shouldAlwaysBeEscaped(160))  // beyond control range
}

@Test
public func test_charSequenceEquals(): Unit {
    // Test equal strings
    @Assert(Utility.charSequenceEquals(Option.Some("hello"), Option.Some("hello")))
    
    // Test different strings
    @Assert(!Utility.charSequenceEquals(Option.Some("hello"), Option.Some("world")))
    
    // Test null values
    @Assert(Utility.charSequenceEquals(Option<String>.None, Option<String>.None))
    @Assert(!Utility.charSequenceEquals(Option.Some("hello"), Option<String>.None))
    @Assert(!Utility.charSequenceEquals(Option<String>.None, Option.Some("hello")))
    
    // Test empty strings
    @Assert(Utility.charSequenceEquals(Option.Some(""), Option.Some("")))
    @Assert(!Utility.charSequenceEquals(Option.Some(""), Option.Some("a")))
}

@Test
public func test_edge_cases(): Unit {
    // Test boundary values for hex
    @Assert(Utility.hex(4095) == "0FFF")  // Max 3-digit hex
    @Assert(Utility.hex(4096) == "1000")  // Min 4-digit hex
    
    // Test single element arrays
    let singleStr = ["only"]
    let singleInt = [42]
    @Assert(Utility.arrayEquals(Option.Some(singleStr), Option.Some(["only"])))
    @Assert(Utility.arrayEquals(Option.Some(singleInt), Option.Some([42])))
    @Assert(!Utility.arrayEquals(Option.Some(singleStr), Option.Some(["different"])))
}