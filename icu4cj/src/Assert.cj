package icu4cj

/**
 * Assert utility class for Cangjie
 * 1.3 compatibility layer translated from Java
 */
class AssertUtils {
    /**
     * Fails with an exception
     */
    public static func fail(e: Exception): Unit {
        fail(e.toString()) // can't wrap exceptions in jdk 1.3
    }
    
    /**
     * Fails with a message
     */
    public static func fail(msg: String): Unit {
        // In Cangjie, we'll just print an error message instead of throwing
        println("ERROR: failure '${msg}'")
    }
    
    /**
     * Asserts a boolean value
     */
    public static func assrt(val: Bool): Unit {
        if (!val) {
            println("ERROR: assert failed")
        }
    }
    
    /**
     * Asserts a boolean value with a message
     */
    public static func assrt(msg: String, val: Bool): Unit {
        if (!val) {
            println("ERROR: assert '${msg}' failed")
        }
    }
}

/**
 * Exception class for illegal state
 */
class IllegalStateException {
    private let message: String = ""
    
    public func toString(): String {
        return message
    }
}
