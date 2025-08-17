package icu4cj

/**
 * Base class for cache implementations.
 * To use, instantiate a subclass of a concrete implementation class, where the subclass
 * implements the createInstance() method, and call get() with the key and the data.
 * The get() call will use the data only if it needs to call createInstance(),
 * otherwise the data is ignored.
 *
 * Note: Cangjie doesn't support generics like Java, so we'll use specific types
 * or create a more flexible implementation
 */
class CacheBase {
    /**
     * Retrieves an instance from the cache. Calls createInstance(key, data) if the cache
     * does not already contain an instance with this key.
     * Ignores data if the cache already contains an instance with this key.
     * @param key Cache lookup key for the requested instance
     * @param data Data for createInstance() if the instance is not already cached
     * @return The requested instance
     */
    public func getInstance(key: String, data: String): String {
        // This is a base implementation - subclasses should override
        return createInstance(key, data)
    }
    
    /**
     * Creates an instance for the key and data. Must be overridden.
     * @param key Cache lookup key for the requested instance
     * @param data Data for the instance creation
     * @return The requested instance
     */
    protected func createInstance(key: String, data: String): String {
        // Base implementation - subclasses must override
        return ""
    }
}

/**
 * A more flexible cache implementation using arrays
 */
class FlexibleCache {
    private var cacheKeys: Array<String> = []
    private var cacheValues: Array<String> = []
    
    /**
     * Get an instance from cache or create it
     */
    public func getInstance(key: String, data: String, creator: (String, String) -> String): String {
        let keyStr = key.toString()
        for (i in 0..cacheKeys.size) {
            if (cacheKeys[i] == keyStr) {
                return cacheValues[i]
            }
        }
        
        let instance = creator(key, data)
        // In Cangjie, we'll use a simple approach - just store the latest
        // This is a simplified implementation
        if (cacheKeys.size == 0) {
            cacheKeys = [keyStr]
            cacheValues = [instance]
        } else {
            // For simplicity, just replace the first element
            cacheKeys[0] = keyStr
            cacheValues[0] = instance
        }
        return instance
    }
    
    /**
     * Clear the cache
     */
    public func clear(): Unit {
        cacheKeys = []
        cacheValues = []
    }
    
    /**
     * Get cache size
     */
    public func size(): Int64 {
        return cacheKeys.size
    }
}
