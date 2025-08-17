package icu4cj.impl

public class CalType <: Enum<CalType> {
    public static let GREGORIAN = CalType("GREGORIAN", 0, "gregorian")

    public static let ISO8601 = CalType("ISO8601", 1, "iso8601")

    public static let BUDDHIST = CalType("BUDDHIST", 2, "buddhist")

    public static let CHINESE = CalType("CHINESE", 3, "chinese")

    public static let COPTIC = CalType("COPTIC", 4, "coptic")

    public static let DANGI = CalType("DANGI", 5, "dangi")

    public static let ETHIOPIC = CalType("ETHIOPIC", 6, "ethiopic")

    public static let ETHIOPIC_AMETE_ALEM = CalType("ETHIOPIC_AMETE_ALEM", 7, "ethiopic-amete-alem")

    public static let HEBREW = CalType("HEBREW", 8, "hebrew")

    public static let INDIAN = CalType("INDIAN", 9, "indian")

    public static let ISLAMIC = CalType("ISLAMIC", 10, "islamic")

    public static let ISLAMIC_CIVIL = CalType("ISLAMIC_CIVIL", 11, "islamic-civil")

    public static let ISLAMIC_RGSA = CalType("ISLAMIC_RGSA", 12, "islamic-rgsa")

    public static let ISLAMIC_TBLA = CalType("ISLAMIC_TBLA", 13, "islamic-tbla")

    public static let ISLAMIC_UMALQURA = CalType("ISLAMIC_UMALQURA", 14, "islamic-umalqura")

    public static let JAPANESE = CalType("JAPANESE", 15, "japanese")

    public static let PERSIAN = CalType("PERSIAN", 16, "persian")

    public static let ROC = CalType("ROC", 17, "roc")

    private static func _values(): Array<CalType> {
        return [CalType.GREGORIAN, CalType.ISO8601, CalType.BUDDHIST, CalType.CHINESE, CalType.COPTIC, CalType.DANGI, CalType.ETHIOPIC, CalType.ETHIOPIC_AMETE_ALEM, CalType.HEBREW, CalType.INDIAN, CalType.ISLAMIC, CalType.ISLAMIC_CIVIL, CalType.ISLAMIC_RGSA, CalType.ISLAMIC_TBLA, CalType.ISLAMIC_UMALQURA, CalType.JAPANESE, CalType.PERSIAN, CalType.ROC]
    }

    private static let _VALUES = CalType._values()

    public static func values(): Array<CalType> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): CalType {
        return (TypeInfo.of<CalType>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as CalType
    }

    var id: String

    init(_enum_name: String, _enum_ordinal: Int32, id: String) {
        super(_enum_name, _enum_ordinal)
        this.id = id
    }

    public func getId(): String {
        return id
    }
}
