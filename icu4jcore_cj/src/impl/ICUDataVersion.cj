package icu4cj.impl

public class ICUDataVersion {

    private static let U_ICU_VERSION_BUNDLE = "icuver"

    private static let U_ICU_DATA_KEY = "DataVersion"

    public static func getDataVersion(): VersionInfo {
        var icudatares: UResourceBundle
        try {
            icudatares = UResourceBundle.getBundleInstance(ICUData.ICU_BASE_NAME, ICUDataVersion.U_ICU_VERSION_BUNDLE, ICUResourceBundle.ICU_DATA_CLASS_LOADER)
            icudatares = icudatares.get(ICUDataVersion.U_ICU_DATA_KEY)
        } catch (ex: MissingResourceException) {
            return None
        }
        return VersionInfo.getInstance(icudatares.getString())
    }
}
