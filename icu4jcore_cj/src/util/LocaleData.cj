package icu4cj.util

public class LocaleData {
    private static let MEASUREMENT_SYSTEM = "MeasurementSystem"

    private static let PAPER_SIZE = "PaperSize"

    private static let LOCALE_DISPLAY_PATTERN = "localeDisplayPattern"

    private static let PATTERN = "pattern"

    private static let SEPARATOR = "separator"

    private var noSubstitute: Bool = false

    private var bundle: ICUResourceBundle

    private var langBundle: ICUResourceBundle

    private var langBundleException: MissingResourceException = None

    public static let ES_STANDARD = 0

    public static let ES_AUXILIARY = 1

    public static let ES_INDEX = 2

    
    public static let ES_CURRENCY = 3

    public static let ES_PUNCTUATION = 4

    
    public static let ES_COUNT = 5

    public static let QUOTATION_START = 0

    public static let QUOTATION_END = 1

    public static let ALT_QUOTATION_START = 2

    public static let ALT_QUOTATION_END = 3

    
    public static let DELIMITER_COUNT = 4


    public static func getExemplarSetStatic(locale: ULocale, options: Int32): UnicodeSet {
        return LocaleData.getInstance(locale).getExemplarSet(options, ES_STANDARD)
    }

    public static func getExemplarSetStatic(locale: ULocale, options: Int32, extype: Int32): UnicodeSet {
        return LocaleData.getInstance(locale).getExemplarSet(options, extype)
    }

    public func getExemplarSet(options: Int32, extype: Int32): UnicodeSet {
        let exemplarSetTypes: Array<String> = ["ExemplarCharacters", "AuxExemplarCharacters", "ExemplarCharactersIndex", "ExemplarCharactersCurrency", "ExemplarCharactersPunctuation"]
        if (extype == ES_CURRENCY) {
            return if (noSubstitute) { None } else { UnicodeSet.EMPTY }
        }
        try {
            let aKey = exemplarSetTypes[Int64(extype)]
            let stringBundle = bundle.get(aKey)
            if (noSubstitute && !bundle.isRoot() && stringBundle.isRoot()) {
                return None
            }
            let unicodeSetPattern = stringBundle.getString()
            return UnicodeSet(unicodeSetPattern, UnicodeSet.IGNORE_SPACE | options)
        } catch (aiooe: IndexOutOfBoundsException) {
            throw IllegalArgumentException()
        } catch (ex: Exception) {
            return if (noSubstitute) { None } else { UnicodeSet.EMPTY }
        }
    }

    public static func getInstance(locale: ULocale): LocaleData {
        let ld = LocaleData()
        ld.bundle = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, locale)
        try {
            ld.langBundle = UResourceBundle.getBundleInstance(ICUData.ICU_LANG_BASE_NAME, locale)
        } catch (mre: MissingResourceException) {
            ld.langBundleException = mre
        }
        ld.noSubstitute = false
        return ld
    }

    public static func getInstance(): LocaleData {
        return LocaleData.getInstance(ULocale.getDefault(ULocale_Category.FORMAT))
    }

    public func setNoSubstitute(setting: Bool): Unit {
        noSubstitute = setting
    }

    public func getNoSubstitute(): Bool {
        return noSubstitute
    }

    private static let DELIMITER_TYPES: Array<String> = ["quotationStart", "quotationEnd", "alternateQuotationStart", "alternateQuotationEnd"]

    public func getDelimiter(Type: Int32): String {
        let delimitersBundle = bundle.get("delimiters")
        let stringBundle = delimitersBundle.getWithFallback(DELIMITER_TYPES[Int64(Type)])
        if (noSubstitute && !bundle.isRoot() && stringBundle.isRoot()) {
            return None
        }
        return stringBundle.getString()
    }

    private static func measurementTypeBundleForLocale(locale: ULocale, measurementType: String): UResourceBundle {
        var measTypeBundle: UResourceBundle
        let region = ULocale.getRegionForSupplementalData(locale, true)
        try {
            let rb = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "supplementalData", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
            let measurementData = rb.get("measurementData")
            var measDataBundle: UResourceBundle
            try {
                measDataBundle = measurementData.get(region)
                measTypeBundle = measDataBundle.get(measurementType)
            } catch (mre: MissingResourceException) {
                measDataBundle = measurementData.get("001")
                measTypeBundle = measDataBundle.get(measurementType)
            }
        } catch (mre: MissingResourceException) { }
        return measTypeBundle
    }

    public static func getMeasurementSystem(locale: ULocale): LocaleData_MeasurementSystem {
        let sysBundle = measurementTypeBundleForLocale(locale, MEASUREMENT_SYSTEM)
        match (sysBundle.getInt()) {
            case 0 => return LocaleData_MeasurementSystem.SI
            case 1 => return LocaleData_MeasurementSystem.US
            case 2 => return LocaleData_MeasurementSystem.UK
            case _ => return None
        }
    }

    public static func getPaperSize(locale: ULocale): LocaleData_PaperSize {
        let obj = measurementTypeBundleForLocale(locale, PAPER_SIZE)
        let size = obj.getIntVector()
        return LocaleData_PaperSize(size[0], size[1])
    }

    public func getLocaleDisplayPattern(): String {
        if (langBundle.isNone()) {
            throw langBundleException
        }
        let locDispBundle = langBundle.get(LOCALE_DISPLAY_PATTERN)
        let localeDisplayPattern = locDispBundle.getStringWithFallback(PATTERN)
        return localeDisplayPattern
    }

    public func getLocaleSeparator(): String {
        if (langBundle.isNone()) {
            throw langBundleException
        }
        let sub0 = "{0}"
        let sub1 = "{1}"
        let locDispBundle = langBundle.get(LOCALE_DISPLAY_PATTERN)
        let localeSeparator = locDispBundle.getStringWithFallback(SEPARATOR)
        let index0 = indexOfWrap(localeSeparator.indexOf(sub0))
        let index1 = indexOfWrap(localeSeparator.indexOf(sub1))
        if (index0 >= 0 && index1 >= 0 && index0 <= index1) {
            return localeSeparator[Int64(index0 + Int32(sub0.size))..Int64(index1)]
        }
        return localeSeparator
    }

    private static var gCLDRVersion: VersionInfo

    public static func getCLDRVersion(): VersionInfo {
        if (gCLDRVersion.isNone()) {
            let supplementalDataBundle = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, "supplementalData", ICUResourceBundle.ICU_DATA_CLASS_LOADER)
            let cldrVersionBundle = supplementalDataBundle.get("cldrVersion")
            gCLDRVersion = VersionInfo.getInstance(cldrVersionBundle.getString())
        }
        return gCLDRVersion
    }
}


public class LocaleData_MeasurementSystem {
    public static let SI = LocaleData_MeasurementSystem()

    public static let US = LocaleData_MeasurementSystem()

    public static let UK = LocaleData_MeasurementSystem()

}


public class LocaleData_PaperSize {
    private var height: Int32 = 0

    private var width: Int32 = 0

    init(h: Int32, w: Int32) {
        height = h
        width = w
    }

    public func getHeight(): Int32 {
        return height
    }

    public func getWidth(): Int32 {
        return width
    }
}
