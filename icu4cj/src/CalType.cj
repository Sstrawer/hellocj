package icu4cj

/**
 * Calendar type enum, moved from com.ibm.icu.util.Calendar.
 * Translated from Java to Cangjie
 */
class CalType {
    // Calendar type constants
    public static let GREGORIAN: String = "gregorian"
    public static let ISO8601: String = "iso8601"
    public static let BUDDHIST: String = "buddhist"
    public static let CHINESE: String = "chinese"
    public static let COPTIC: String = "coptic"
    public static let DANGI: String = "dangi"
    public static let ETHIOPIC: String = "ethiopic"
    public static let ETHIOPIC_AMETE_ALEM: String = "ethiopic-amete-alem"
    public static let HEBREW: String = "hebrew"
    public static let INDIAN: String = "indian"
    public static let ISLAMIC: String = "islamic"
    public static let ISLAMIC_CIVIL: String = "islamic-civil"
    public static let ISLAMIC_RGSA: String = "islamic-rgsa"
    public static let ISLAMIC_TBLA: String = "islamic-tbla"
    public static let ISLAMIC_UMALQURA: String = "islamic-umalqura"
    public static let JAPANESE: String = "japanese"
    public static let PERSIAN: String = "persian"
    public static let ROC: String = "roc"
    
    /**
     * Get calendar type by name
     */
    public static func getById(id: String): String {
        let types = [
            GREGORIAN, ISO8601, BUDDHIST, CHINESE, COPTIC, DANGI,
            ETHIOPIC, ETHIOPIC_AMETE_ALEM, HEBREW, INDIAN, ISLAMIC,
            ISLAMIC_CIVIL, ISLAMIC_RGSA, ISLAMIC_TBLA, ISLAMIC_UMALQURA,
            JAPANESE, PERSIAN, ROC
        ]
        
        for (i in 0..types.size) {
            let typeName = types[i]
            if (typeName == id) {
                return typeName
            }
        }
        return GREGORIAN // default fallback
    }
    
    /**
     * Check if a calendar type is valid
     */
    public static func isValid(id: String): Bool {
        let types = [
            GREGORIAN, ISO8601, BUDDHIST, CHINESE, COPTIC, DANGI,
            ETHIOPIC, ETHIOPIC_AMETE_ALEM, HEBREW, INDIAN, ISLAMIC,
            ISLAMIC_CIVIL, ISLAMIC_RGSA, ISLAMIC_TBLA, ISLAMIC_UMALQURA,
            JAPANESE, PERSIAN, ROC
        ]
        
        for (i in 0..types.size) {
            let typeName = types[i]
            if (typeName == id) {
                return true
            }
        }
        return false
    }
    
    /**
     * Get all available calendar types
     */
    public static func getAllTypes(): Array<String> {
        return [
            GREGORIAN, ISO8601, BUDDHIST, CHINESE, COPTIC, DANGI,
            ETHIOPIC, ETHIOPIC_AMETE_ALEM, HEBREW, INDIAN, ISLAMIC,
            ISLAMIC_CIVIL, ISLAMIC_RGSA, ISLAMIC_TBLA, ISLAMIC_UMALQURA,
            JAPANESE, PERSIAN, ROC
        ]
    }
}
