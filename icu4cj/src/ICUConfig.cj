package icu4cj

/**
 * ICUConfig class for Cangjie
 * ICUConfig is a class used for accessing ICU4J runtime configuration.
 * Translated from Java to Cangjie
 */
class ICUConfig {
    public static let CONFIG_PROPS_FILE: String = "/com/ibm/icu/ICUConfig.properties"
    private static var CONFIG_PROPS: Array<String> = ["77.1", "en", "US", "", "15.0"]
    private static var CONFIG_KEYS: Array<String> = ["icu.version", "icu.language", "icu.country", "icu.variant", "icu.unicode.version"]
    
    /**
     * Get ICU configuration property value for the given name.
     * @param name The configuration property name
     * @return The configuration property value, or null if it does not exist.
     */
    public static func get(name: String): String {
        return get(name, "")
    }
    
    /**
     * Get ICU configuration property value for the given name.
     * @param name The configuration property name
     * @param def The default value
     * @return The configuration property value. If the property does not
     * exist, def is returned.
     */
    public static func get(name: String, def: String): String {
        // In Cangjie, we'll use environment variables and our config arrays
        var val: String = ""
        
        // Try to get from environment variables first
        val = getEnvironmentVariable(name)
        
        // If not found in environment, try our config properties
        if (val == "") {
            val = getConfigValue(name)
        }
        
        // If still not found, return default
        if (val == "") {
            val = def
        }
        
        return val
    }
    
    /**
     * Set a configuration property
     */
    public static func set(name: String, value: String): Unit {
        // Find the index and update the value
        for (i in 0..CONFIG_KEYS.size) {
            if (CONFIG_KEYS[i] == name) {
                CONFIG_PROPS[i] = value
                return
            }
        }
        // If not found, add new entry
        // For simplicity, we'll just ignore new entries in this implementation
        // In a real implementation, you would need to handle dynamic array growth
    }
    
    /**
     * Get all configuration properties
     */
    public static func getAllProperties(): Array<String> {
        return CONFIG_PROPS
    }
    
    /**
     * Clear all configuration properties
     */
    public static func clear(): Unit {
        CONFIG_PROPS = []
        CONFIG_KEYS = []
    }
    
    /**
     * Helper function to get environment variables
     * In Cangjie, this would typically interface with the system
     */
    private static func getEnvironmentVariable(name: String): String {
        // This is a simplified implementation
        // In a real Cangjie environment, you would use system calls
        let envName = "ICU_" + name
        
        // For now, return empty string as we don't have system environment access
        return ""
    }
    
    /**
     * Helper function to get config value from parallel arrays
     */
    private static func getConfigValue(name: String): String {
        for (i in 0..CONFIG_KEYS.size) {
            if (CONFIG_KEYS[i] == name) {
                return CONFIG_PROPS[i]
            }
        }
        return ""
    }
    
    /**
     * Check if a configuration property exists
     */
    public static func hasProperty(name: String): Bool {
        for (i in 0..CONFIG_KEYS.size) {
            if (CONFIG_KEYS[i] == name) {
                return true
            }
        }
        return false
    }
    
    /**
     * Get configuration property names
     */
    public static func getPropertyNames(): Array<String> {
        return CONFIG_KEYS
    }
}
