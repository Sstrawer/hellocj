package icu4cj.impl

public class ICUResourceTableAccess {

    public static func getTableString(path: String, locale: ULocale, tableName: String, itemName: String, defaultValue: String): String {
        let bundle = UResourceBundle.getBundleInstance(path, locale.getBaseName())
        return getTableString(bundle, tableName, None, itemName, defaultValue)
    }

    public static func getTableString(bundle: ICUResourceBundle, tableName: String, subtableName: String, item: String, defaultValue: String): String {
        var tempbundle = bundle
        var result: String
        @AssertThrows[Exception]({
            while (true) {
                let table = tempbundle.findWithFallback(tableName)
                if (table.isNone()) {
                    return defaultValue
                }
                var stable = table
                if (subtableName.isSome()) {
                    stable = table.findWithFallback(subtableName)
                }
                if (stable.isSome()) {
                    result = stable.findStringWithFallback(item)
                    if (result.isSome()) {
                        break
                    }
                }
                if (subtableName.isNone()) {
                    var currentName: String
                    if (tableName == "Countries") {
                        currentName = LocaleIDs.getCurrentCountryID(item)
                    } else if (tableName == "Languages") {
                        currentName = LocaleIDs.getCurrentLanguageID(item)
                    }
                    if (currentName.isSome()) {
                        result = table.findStringWithFallback(currentName)
                        if (result.isSome()) {
                            break
                        }
                    }
                }
                var fallbackLocale = table.findStringWithFallback("Fallback")
                if (fallbackLocale.isNone()) {
                    return defaultValue
                }
                if (Int32(fallbackLocale.size) == 0) {
                    fallbackLocale = "root"
                }
                if (fallbackLocale.equals(table.getULocale().getName())) {
                    return defaultValue
                }
                tempbundle = UResourceBundle.getBundleInstance(tempbundle.getBaseName(), fallbackLocale)
            }
        })
        return (if (result.isSome() && Int32(result.size) > 0) { result } else { defaultValue })
    }
}
