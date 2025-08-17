package icu4cj.util


public class GenderInfo {
    private let style: GenderInfo_ListGenderStyle

    
    public static func getInstance(uLocale: ULocale): GenderInfo {
        return genderInfoCache.get(uLocale)
    }

    
    public static func getInstance(locale: Locale): GenderInfo {
        return getInstance(ULocale.forLocale(locale))
    }

    
    public func getListGender(genders: Array<GenderInfo_Gender>): GenderInfo_Gender {
        return getListGender(ArrayList(genders))
    }

    
    public func getListGender(genders: ArrayList<GenderInfo_Gender>): GenderInfo_Gender {
        if (Int32(genders.size) == 0) {
            return GenderInfo_Gender.OTHER
        }
        if (Int32(genders.size) == 1) {
            return genders[0]
        }
        match (style) {
            case GenderInfo_ListGenderStyle.NEUTRAL => return GenderInfo_Gender.OTHER
            case GenderInfo_ListGenderStyle.MIXED_NEUTRAL =>
                var hasFemale = false
                var hasMale = false
                for (gender in genders) {
                    match (gender) {
                        case GenderInfo_Gender.FEMALE =>
                            if (hasMale) {
                                return GenderInfo_Gender.OTHER
                            }
                            hasFemale = true
                        case GenderInfo_Gender.MALE =>
                            if (hasFemale) {
                                return GenderInfo_Gender.OTHER
                            }
                            hasMale = true
                        case GenderInfo_Gender.OTHER => return GenderInfo_Gender.OTHER
                        case _ => ()
                    }
                }
                return if (hasMale) { GenderInfo_Gender.MALE } else { GenderInfo_Gender.FEMALE }
            case GenderInfo_ListGenderStyle.MALE_TAINTS =>
                for (gender in genders) {
                    if (!refEq(gender, GenderInfo_Gender.FEMALE)) {
                        return GenderInfo_Gender.MALE
                    }
                }
                return GenderInfo_Gender.FEMALE
            case _ => return GenderInfo_Gender.OTHER
        }
    }

    
    public init(genderStyle: GenderInfo_ListGenderStyle) {
        style = genderStyle
    }

    static var neutral: GenderInfo = GenderInfo(GenderInfo_ListGenderStyle.NEUTRAL)

    private static var genderInfoCache: GenderInfo_Cache = GenderInfo_Cache()
}



public class GenderInfo_Gender <: Enum<GenderInfo_Gender> {
    
    public static let MALE = GenderInfo_Gender("MALE", 0)

    
    public static let FEMALE = GenderInfo_Gender("FEMALE", 1)

    
    public static let OTHER = GenderInfo_Gender("OTHER", 2)

    private static func _values(): Array<GenderInfo_Gender> {
        return [GenderInfo_Gender.MALE, GenderInfo_Gender.FEMALE, GenderInfo_Gender.OTHER]
    }

    private static let _VALUES = GenderInfo_Gender._values()

    public static func values(): Array<GenderInfo_Gender> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): GenderInfo_Gender {
        return (TypeInfo.of<GenderInfo_Gender>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as GenderInfo_Gender
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }
}



public class GenderInfo_ListGenderStyle <: Enum<GenderInfo_ListGenderStyle> {
    
    public static let NEUTRAL = GenderInfo_ListGenderStyle("NEUTRAL", 0)

    
    public static let MIXED_NEUTRAL = GenderInfo_ListGenderStyle("MIXED_NEUTRAL", 1)

    
    public static let MALE_TAINTS = GenderInfo_ListGenderStyle("MALE_TAINTS", 2)

    private static func _values(): Array<GenderInfo_ListGenderStyle> {
        return [GenderInfo_ListGenderStyle.NEUTRAL, GenderInfo_ListGenderStyle.MIXED_NEUTRAL, GenderInfo_ListGenderStyle.MALE_TAINTS]
    }

    private static let _VALUES = GenderInfo_ListGenderStyle._values()

    public static func values(): Array<GenderInfo_ListGenderStyle> {
        return _VALUES.clone()
    }

    public static func valueOf(name: String): GenderInfo_ListGenderStyle {
        return (TypeInfo.of<GenderInfo_ListGenderStyle>() as ClassTypeInfo).findStaticMemberVariable(name).getValue() as GenderInfo_ListGenderStyle
    }

    private init(_enum_name: String, _enum_ordinal: Int32) {
        super(_enum_name, _enum_ordinal)
    }

    private static var fromNameMap: Map<String, GenderInfo_ListGenderStyle> = HashMap<String, GenderInfo_ListGenderStyle>(3)


    
    public static func fromName(name: String): GenderInfo_ListGenderStyle {
        let result = fromNameMap.get(name)
        if (result.isNone()) {
            throw IllegalArgumentException("Unknown gender style name: " + (name))
        }
        return result
    }
}


class GenderInfo_Cache {

    private let cache: ICUCache<ULocale, GenderInfo> = SimpleCache<ULocale, GenderInfo>()

    public func get(locale: ULocale): GenderInfo {
        var result = cache.get(locale)
        if (result.isNone()) {
            result = load(locale)
            if (result.isNone()) {
                let fallback = locale.getFallback()
                result = if (fallback.isNone()) { GenderInfo.neutral } else { get(fallback) }
            }
            cache.put(locale, result)
        }
        return result
    }

    private static func load(ulocale: ULocale): GenderInfo {
        let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "genderList", ICUResourceBundle.ICU_DATA_CLASS_LOADER, true)
        let genderList = rb.get("genderList")
        try {
            return GenderInfo(GenderInfo_ListGenderStyle.fromName(genderList.getString(ulocale.toString())))
        } catch (mre: MissingResourceException) {
            return None
        }
    }
}
